--[[
	Plans the full 100-room layout up front, then streams rooms in and out.

	Preset setup (in Studio, under ServerStorage):
	  ServerStorage
	    Rooms
	      Normal      <- random-pool rooms (Models)
	      Special     <- fixed rooms named in Config.FIXED_ROOMS

	Each room Model needs:
	  Entrance  (Part) - where this room attaches to the previous room.
	  Exit      (Part) - where the next room attaches (not needed for the last room).
	  Both parts' front face (LookVector) must point in the direction players walk.
	  Door      (Part, optional) - touching it opens it and advances the run.
	  ResearchSpawn (Parts, optional) - extra places research is allowed to appear.

	Optional attributes on a room Model:
	  Weight  (number) - how often it's picked, default 1
	  Turn    (number) - 1 if the exit turns left, -1 if right, 0/none if straight
	  MinRoom (number) - earliest room number it can appear in
	  MaxRoom (number) - latest room number it can appear in

	Rooms never overlap: every room's bounding box is checked against all the
	rooms placed before it, and the planner backtracks when it gets stuck.
]]

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Decay = require(script.Parent.Decay)
local Research = require(script.Parent.Research)
local RoomPresets = require(script.Parent.RoomPresets)

local RoomGenerator = {}

type Info = { exitRel: CFrame?, boxRel: CFrame, size: Vector3, turn: number }
type Placement = { template: Model, attach: CFrame, min: Vector3, max: Vector3, heading: number }

local rng: Random
local plan: { Placement } = {}
local loaded: { [number]: Model } = {}
local roomsFolder: Folder
local furthestOpened = 0

local MAX_PLAN_STEPS = 20000
-- Touching rooms share a wall face; shrink boxes slightly so that doesn't count as overlap.
local TOUCH_TOLERANCE = 0.6

local function getPresets(): ({ Model }, { [string]: Model })
	local rooms = ServerStorage:FindFirstChild("Rooms")
	local normal, special = {}, {}
	if rooms then
		local normalFolder = rooms:FindFirstChild("Normal")
		local specialFolder = rooms:FindFirstChild("Special")
		if normalFolder then
			for _, m in normalFolder:GetChildren() do
				if m:IsA("Model") then
					table.insert(normal, m)
				end
			end
		end
		if specialFolder then
			for _, m in specialFolder:GetChildren() do
				if m:IsA("Model") then
					special[m.Name] = m
				end
			end
		end
	end
	-- Fall back to the built-in rooms for anything not built in Studio.
	if #normal == 0 then
		normal = RoomPresets.BuildNormal()
	end
	for name, m in RoomPresets.BuildSpecial() do
		if not special[name] then
			special[name] = m
		end
	end
	return normal, special
end

local infoCache: { [Model]: Info } = {}

-- Exit and bounding box of a preset, relative to its Entrance.
local function measure(template: Model): Info
	local cached = infoCache[template]
	if cached then
		return cached
	end
	local entrance = template:FindFirstChild("Entrance", true) :: BasePart
	assert(entrance, `Preset {template.Name} is missing an Entrance part`)
	local exit = template:FindFirstChild("Exit", true) :: BasePart?
	local inverse = entrance.CFrame:Inverse()
	local boxCf, size = template:GetBoundingBox()
	local info = {
		exitRel = if exit then inverse * exit.CFrame else nil,
		boxRel = inverse * boxCf,
		size = size,
		turn = template:GetAttribute("Turn") or 0,
	}
	infoCache[template] = info
	return info
end

-- World-space axis-aligned bounds of a box, shrunk by the touch tolerance.
local function bounds(cf: CFrame, size: Vector3): (Vector3, Vector3)
	local h = size / 2
	local r, u, l = cf.RightVector, cf.UpVector, cf.LookVector
	local extent = Vector3.new(
		math.abs(r.X) * h.X + math.abs(u.X) * h.Y + math.abs(l.X) * h.Z,
		math.abs(r.Y) * h.X + math.abs(u.Y) * h.Y + math.abs(l.Y) * h.Z,
		math.abs(r.Z) * h.X + math.abs(u.Z) * h.Y + math.abs(l.Z) * h.Z
	) - Vector3.one * TOUCH_TOLERANCE
	return cf.Position - extent, cf.Position + extent
end

local function overlaps(min: Vector3, max: Vector3, upTo: number): boolean
	for i = 1, upTo do
		local p = plan[i]
		if min.X < p.max.X and max.X > p.min.X and min.Y < p.max.Y and max.Y > p.min.Y
			and min.Z < p.max.Z and max.Z > p.min.Z then
			return true
		end
	end
	return false
end

-- Candidate presets for room n, in weighted-random order.
local function candidatesFor(n: number, normal: { Model }, special: { [string]: Model }, heading: number): { Model }
	local fixed = Config.FIXED_ROOMS[n]
	if fixed and special[fixed] then
		return { special[fixed] }
	end
	-- Presets used in the last few rooms are skipped so nothing repeats too often.
	local function usedRecently(m: Model, within: number): boolean
		for k = 1, within do
			local p = plan[n - k]
			if p and p.template == m then
				return true
			end
		end
		return false
	end
	local function gather(within: number): { Model }
		local pool = {}
		for _, m in normal do
			local turn = measure(m).turn
			local min = m:GetAttribute("MinRoom") or 1
			local max = m:GetAttribute("MaxRoom") or math.huge
			-- The last room needs an exit only if it isn't the final room.
			local hasExit = measure(m).exitRel ~= nil or n == Config.TOTAL_ROOMS
			-- Heading stays within one turn of "forward", so the path never doubles back.
			if n >= min and n <= max and hasExit and math.abs(heading + turn) <= 1
				and not usedRecently(m, within) then
				table.insert(pool, m)
			end
		end
		return pool
	end
	local pool = gather(Config.NO_REPEAT_WITHIN)
	if #pool == 0 then
		pool = gather(if #normal > 1 then 1 else 0)
	end
	-- Weighted shuffle: repeatedly draw by weight without replacement.
	local ordered = {}
	while #pool > 0 do
		local total = 0
		for _, m in pool do
			total += m:GetAttribute("Weight") or 1
		end
		local roll = rng:NextNumber() * total
		local pick = #pool
		for i, m in pool do
			roll -= m:GetAttribute("Weight") or 1
			if roll <= 0 then
				pick = i
				break
			end
		end
		table.insert(ordered, table.remove(pool, pick))
	end
	return ordered
end

-- Depth-first search over room choices, backtracking whenever no preset fits.
local function buildPlan()
	local normal, special = getPresets()
	local remaining: { [number]: { Model } } = {}
	local n, steps = 1, 0
	while n <= Config.TOTAL_ROOMS do
		steps += 1
		if steps == MAX_PLAN_STEPS + 1 then
			warn("[Totality] Room planner gave up avoiding overlaps; some rooms may intersect")
		end
		local prev = plan[n - 1]
		local attach = if prev then prev.attach * (measure(prev.template).exitRel :: CFrame) else Config.START_CFRAME
		local heading = if prev then prev.heading else 0

		if not remaining[n] then
			remaining[n] = candidatesFor(n, normal, special, heading)
		end
		local template = table.remove(remaining[n], 1)

		if not template then
			-- Dead end: undo the previous room and try its next option.
			remaining[n] = nil
			plan[n - 1] = nil
			n -= 1
			assert(n >= 1, "[Totality] Could not fit the rooms together. Check the presets' Entrance/Exit parts.")
			continue
		end

		local info = measure(template)
		local min, max = bounds(attach * info.boxRel, info.size)
		if steps > MAX_PLAN_STEPS or not overlaps(min, max, n - 1) then
			plan[n] = { template = template, attach = attach, min = min, max = max, heading = heading + info.turn }
			n += 1
		end
	end
end

local function spawnRoom(n: number)
	local placement = plan[n]
	if loaded[n] or not placement then
		return
	end
	local room = placement.template:Clone()
	room.Name = "Room" .. n
	room:SetAttribute("RoomNumber", n)

	local entrance = room:FindFirstChild("Entrance", true) :: BasePart
	local entranceOffset = room:GetPivot():ToObjectSpace(entrance.CFrame)
	room:PivotTo(placement.attach * entranceOffset:Inverse())

	room.Parent = roomsFolder
	loaded[n] = room

	-- Damage from the attack gets worse the deeper into the ship you go.
	Decay.Apply(room, n, rng)

	local door = room:FindFirstChild("Door", true) :: BasePart?
	if door then
		local opened = false
		door.Touched:Connect(function(hit)
			if opened or not hit.Parent:FindFirstChildOfClass("Humanoid") then
				return
			end
			opened = true
			door.CanCollide = false
			door.Transparency = 1
			RoomGenerator.OnDoorOpened(n)
		end)
	end

	Research.PopulateRoom(room, rng)
end

function RoomGenerator.OnDoorOpened(n: number)
	if n <= furthestOpened then
		return
	end
	furthestOpened = n
	ReplicatedStorage:SetAttribute("CurrentRoom", n + 1)

	for i = n + 1, math.min(n + Config.ROOMS_AHEAD, Config.TOTAL_ROOMS) do
		spawnRoom(i)
	end
	for i, room in loaded do
		if i < n - Config.ROOMS_BEHIND then
			room:Destroy()
			loaded[i] = nil
		end
	end
end

function RoomGenerator.Start(seed: number?)
	seed = seed or math.random(1, 2 ^ 31 - 1)
	rng = Random.new(seed)
	ReplicatedStorage:SetAttribute("Seed", seed)
	ReplicatedStorage:SetAttribute("CurrentRoom", 1)
	print(`[Totality] Generating run with seed {seed}`)

	roomsFolder = Instance.new("Folder")
	roomsFolder.Name = "GeneratedRooms"
	roomsFolder.Parent = workspace

	buildPlan()
	for i = 1, 1 + Config.ROOMS_AHEAD do
		spawnRoom(i)
	end
end

return RoomGenerator
