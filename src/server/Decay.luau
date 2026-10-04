--[[
	The S.S. Totality was ransacked and attacked. Damage creeps in from the
	first few rooms and builds up slowly the deeper you go (rooms marked with
	the Pristine attribute, like the final room, are left untouched):
	  - grime: every surface gets darker and dirtier
	  - lights: more lamps flicker, more are smashed and dead
	  - debris: rubble, scattered junk and fallen ceiling panels
	  - scorch marks on the walls
	  - hanging wires torn out of the ceiling
	  - hanging wires and claw marks (from around halfway)
	  - alien residue puddles and streaks (in the last third)

	All damage is decoration only (CanCollide off), so it never blocks the path.
	Exit lights are never broken, so the way forward is always visible.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Decay = {}

local GRIME = Color3.fromRGB(28, 24, 20)
local RESIDUE = Color3.fromRGB(110, 60, 150)
local DOOR_CLEARANCE = 6 -- keep debris this far from doorways

-- 0 = pristine, 1 = wrecked. Curved so it creeps in early and builds up slowly.
function Decay.Severity(n: number): number
	local t = math.clamp((n - Config.DECAY_START) / (Config.DECAY_FULL - Config.DECAY_START), 0, 1)
	return t ^ Config.DECAY_CURVE
end

-- Random rounding, so even a tiny severity sometimes produces one piece.
local function amount(rng: Random, x: number): number
	return math.floor(x + rng:NextNumber())
end

local function deco(room: Model, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, props: { [string]: any }?)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	for k, v in props or {} do
		(p :: any)[k] = v
	end
	p.Parent = room
	return p
end

local function grime(room: Model, severity: number)
	local strength = severity * 0.45
	for _, d in room:GetDescendants() do
		if d:IsA("BasePart") and d.Transparency < 1 and d.Material ~= Enum.Material.Neon
			and d.Material ~= Enum.Material.Glass and d.Name ~= "Research" then
			d.Color = d.Color:Lerp(GRIME, strength)
		end
	end
end

local function lights(room: Model, severity: number, rng: Random)
	local lamps = {}
	for _, d in room:GetDescendants() do
		if d.Name == "Lamp" and d:IsA("BasePart") then
			table.insert(lamps, d)
		end
	end
	local breakChance = severity * 0.45
	local flickerChance = Config.FLICKER_CHANCE + severity * 0.25
	local working = #lamps
	for _, lamp in lamps do
		local roll = rng:NextNumber()
		-- Always leave at least one lamp working so rooms are never pitch black.
		if roll < breakChance and working > 1 then
			working -= 1
			lamp.Material = Enum.Material.SmoothPlastic
			lamp.Color = Color3.fromRGB(45, 45, 48)
			local light = lamp:FindFirstChildWhichIsA("Light")
			if light then
				light.Enabled = false
			end
		elseif roll < breakChance + flickerChance then
			lamp:SetAttribute("Flicker", true)
		end
	end
end

local function makeParams(room: Model): RaycastParams
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = { room }
	params.RespectCanCollide = true
	return params
end

-- Random points on the room's floors, away from the doorways.
local function floorSpots(room: Model, count: number, rng: Random, params: RaycastParams): { RaycastResult }
	local floors, doors = {}, {}
	for _, d in room:GetDescendants() do
		if d:IsA("BasePart") then
			if d.Name == "Floor" or d.Name == "Landing" then
				table.insert(floors, d)
			elseif d.Name == "Entrance" or d.Name == "Exit" then
				table.insert(doors, d.Position)
			end
		end
	end
	local spots = {}
	if #floors == 0 then
		return spots
	end
	for _ = 1, count * 4 do
		if #spots >= count then
			break
		end
		local floor = floors[rng:NextInteger(1, #floors)]
		local half = floor.Size / 2 - Vector3.new(2, 0, 2)
		local origin = floor.CFrame:PointToWorldSpace(Vector3.new(rng:NextNumber(-half.X, half.X), half.Y + 6, rng:NextNumber(-half.Z, half.Z)))
		local hit = workspace:Raycast(origin, Vector3.new(0, -8, 0), params)
		if hit and hit.Normal.Y > 0.9 then
			local nearDoor = false
			for _, pos in doors do
				local flat = Vector3.new(pos.X - hit.Position.X, 0, pos.Z - hit.Position.Z)
				if flat.Magnitude < DOOR_CLEARANCE then
					nearDoor = true
					break
				end
			end
			if not nearDoor then
				table.insert(spots, hit)
			end
		end
	end
	return spots
end

-- Random points on walls (vertical surfaces), found by casting sideways from floor spots.
local function wallSpots(room: Model, count: number, rng: Random, params: RaycastParams): { RaycastResult }
	local spots = {}
	for _, floorHit in floorSpots(room, count * 2, rng, params) do
		if #spots >= count then
			break
		end
		local angle = rng:NextNumber(0, math.pi * 2)
		local origin = floorHit.Position + Vector3.new(0, rng:NextNumber(2, 7), 0)
		local hit = workspace:Raycast(origin, Vector3.new(math.cos(angle), 0, math.sin(angle)) * 40, params)
		if hit and math.abs(hit.Normal.Y) < 0.2 then
			table.insert(spots, hit)
		end
	end
	return spots
end

-- CFrame on a wall hit, facing out of the wall, rotated `roll` around the normal.
local function onSurface(hit: RaycastResult, offset: number, roll: number): CFrame
	local pos = hit.Position + hit.Normal * offset
	return CFrame.lookAt(pos, pos + hit.Normal) * CFrame.Angles(0, 0, roll)
end

function Decay.Apply(room: Model, n: number, rng: Random)
	if room:GetAttribute("Pristine") then
		return
	end
	local severity = Decay.Severity(n)
	lights(room, severity, rng)
	if severity <= 0 then
		return
	end
	grime(room, severity)
	local params = makeParams(room)

	-- Rubble and junk.
	for _, hit in floorSpots(room, amount(rng, severity * 6), rng, params) do
		local s = Vector3.new(rng:NextNumber(0.4, 1.8), rng:NextNumber(0.3, 1.2), rng:NextNumber(0.4, 1.8))
		local cf = CFrame.new(hit.Position + Vector3.new(0, s.Y / 2 - 0.1, 0))
			* CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, math.pi * 2), rng:NextNumber(-0.3, 0.3))
		local metal = rng:NextNumber() < 0.5
		deco(room, "Debris", s, cf, if metal then Color3.fromRGB(70, 72, 78) else Color3.fromRGB(95, 92, 88),
			if metal then Enum.Material.CorrodedMetal else Enum.Material.Concrete)
	end

	-- Ceiling panels that fell and lean at an angle.
	for _, hit in floorSpots(room, amount(rng, severity * 1.5), rng, params) do
		local cf = CFrame.new(hit.Position + Vector3.new(0, 0.6, 0))
			* CFrame.Angles(0, rng:NextNumber(0, math.pi * 2), 0) * CFrame.Angles(rng:NextNumber(0.2, 0.45), 0, 0)
		deco(room, "FallenPanel", Vector3.new(4, 0.2, 2.5), cf, Color3.fromRGB(120, 122, 125), Enum.Material.Metal)
	end

	-- Scorch marks.
	for _, hit in wallSpots(room, amount(rng, severity * 6), rng, params) do
		deco(room, "Scorch", Vector3.new(rng:NextNumber(2, 5), rng:NextNumber(1.5, 4), 0.05),
			onSurface(hit, 0.03, rng:NextNumber(0, math.pi)), Color3.fromRGB(20, 18, 16), nil, { Transparency = 0.2 })
	end

	-- Wires hanging out of the ceiling.
	if severity > 0.3 then
		for _, hit in floorSpots(room, amount(rng, severity * 5), rng, params) do
			local up = workspace:Raycast(hit.Position + Vector3.new(0, 1, 0), Vector3.new(0, 40, 0), params)
			if up then
				local length = rng:NextNumber(2, 4.5)
				for k = 0, 1 do
					local top = up.Position + Vector3.new(k * 0.3, 0, 0)
					deco(room, "Wire", Vector3.new(0.12, length, 0.12),
						CFrame.new(top - Vector3.new(0, length / 2, 0)) * CFrame.Angles(rng:NextNumber(-0.15, 0.15), 0, rng:NextNumber(-0.15, 0.15)),
						if k == 0 then Color3.fromRGB(20, 20, 20) else Color3.fromRGB(150, 40, 30))
				end
			end
		end
	end

	-- Claw marks: three parallel slashes.
	if severity > 0.35 then
		for _, hit in wallSpots(room, amount(rng, severity * 3), rng, params) do
			local base = onSurface(hit, 0.03, rng:NextNumber(-0.5, 0.5))
			for k = -1, 1 do
				deco(room, "Claw", Vector3.new(0.2, rng:NextNumber(2.2, 3.2), 0.05), base * CFrame.new(k * 0.55, k * 0.15, 0),
					Color3.fromRGB(25, 12, 12))
			end
		end
	end

	-- Alien residue: puddles on the floor and streaks on the walls.
	if severity > 0.5 then
		local residue = amount(rng, (severity - 0.5) * 10)
		for _, hit in floorSpots(room, residue, rng, params) do
			local d = rng:NextNumber(1.5, 4)
			deco(room, "Residue", Vector3.new(0.05, d, d * rng:NextNumber(0.6, 1)),
				CFrame.new(hit.Position + Vector3.new(0, 0.025, 0)) * CFrame.Angles(0, rng:NextNumber(0, math.pi), math.pi / 2),
				RESIDUE, Enum.Material.Glass, { Shape = Enum.PartType.Cylinder, Transparency = 0.15, Reflectance = 0.2 })
		end
		for _, hit in wallSpots(room, residue, rng, params) do
			deco(room, "Residue", Vector3.new(rng:NextNumber(0.4, 1), rng:NextNumber(2, 5), 0.05),
				onSurface(hit, 0.03, 0), RESIDUE, Enum.Material.Glass, { Transparency = 0.2, Reflectance = 0.2 })
		end
	end
end

return Decay
