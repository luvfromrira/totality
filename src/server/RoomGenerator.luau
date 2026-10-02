--[[
	Builds the sequence of 100 rooms from presets and streams them in/out.

	Preset setup (in Studio, under ServerStorage):
	  ServerStorage
	    Rooms
	      Normal      <- random-pool rooms (Models)
	      Special     <- fixed rooms named in Config.FIXED_ROOMS

	Each room Model needs:
	  Entrance  (Part) - where this room attaches to the previous room.
	  Exit      (Part) - where the next room attaches.
	  Both parts' front face (LookVector) must point in the direction players walk.
	  Door      (Part, optional) - touching it opens it and advances the run.
	  ResearchSpawn (Parts, optional, any number) - possible research locations.

	Optional attributes on a room Model:
	  Weight  (number) - how often it's picked, default 1
	  Turn    (number) - 1 if the exit turns left, -1 if right, 0/none if straight
	  MinRoom (number) - earliest room number it can appear in
	  MaxRoom (number) - latest room number it can appear in
]]

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Research = require(script.Parent.Research)
local RoomPresets = require(script.Parent.RoomPresets)

local RoomGenerator = {}

local rng: Random
local sequence: { Model } = {} -- preset chosen for each room number
local loaded: { [number]: Model } = {}
local roomsFolder: Folder
local furthestOpened = 0

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

local function pickWeighted(candidates: { Model }): Model
	local total = 0
	for _, m in candidates do
		total += m:GetAttribute("Weight") or 1
	end
	local roll = rng:NextNumber() * total
	for _, m in candidates do
		roll -= m:GetAttribute("Weight") or 1
		if roll <= 0 then
			return m
		end
	end
	return candidates[#candidates]
end

local function buildSequence()
	local normal, special = getPresets()
	-- Net heading: -1 = facing right, 0 = forward, 1 = left. Keeping it in that
	-- range stops the path from curling back into rooms that are still loaded.
	local heading = 0
	for n = 1, Config.TOTAL_ROOMS do
		local fixedName = Config.FIXED_ROOMS[n]
		if fixedName and special[fixedName] then
			sequence[n] = special[fixedName]
			heading += special[fixedName]:GetAttribute("Turn") or 0
			continue
		end
		local candidates = {}
		for _, m in normal do
			local min = m:GetAttribute("MinRoom") or 1
			local max = m:GetAttribute("MaxRoom") or math.huge
			-- Avoid the same preset twice in a row when there's another option.
			local turn = m:GetAttribute("Turn") or 0
			if n >= min and n <= max and math.abs(heading + turn) <= 1
				and (m ~= sequence[n - 1] or #normal == 1) then
				table.insert(candidates, m)
			end
		end
		if #candidates == 0 then
			candidates = normal
		end
		sequence[n] = pickWeighted(candidates)
		heading += sequence[n]:GetAttribute("Turn") or 0
	end
end

local function spawnRoom(n: number)
	if loaded[n] or not sequence[n] then
		return
	end
	local room = sequence[n]:Clone()
	room.Name = "Room" .. n
	room:SetAttribute("RoomNumber", n)

	local entrance = room:FindFirstChild("Entrance", true)
	assert(entrance, `Preset {sequence[n].Name} is missing an Entrance part`)
	assert(n == Config.TOTAL_ROOMS or room:FindFirstChild("Exit", true),
		`Preset {sequence[n].Name} is missing an Exit part`)

	-- Line this room's Entrance up with the previous room's Exit.
	local attachTo = Config.START_CFRAME
	local prev = loaded[n - 1]
	if prev then
		attachTo = prev:FindFirstChild("Exit", true).CFrame
	end
	local entranceOffset = room:GetPivot():ToObjectSpace(entrance.CFrame)
	room:PivotTo(attachTo * entranceOffset:Inverse())

	room.Parent = roomsFolder
	loaded[n] = room

	local door = room:FindFirstChild("Door", true)
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

	buildSequence()
	for i = 1, 1 + Config.ROOMS_AHEAD do
		spawnRoom(i)
	end
end

return RoomGenerator
