--[[
	The S.S. Totality was ransacked and attacked. Damage creeps in from the
	first few rooms and builds up slowly the deeper you go. Rooms marked with
	the Pristine attribute (the final room) are left untouched.

	Each kind of damage is built as a small connected scene rather than a
	loose shape, and they unlock in stages as severity rises:

	  from the start     grime, flickering lamps, dust piles, scattered papers
	  light damage       debris piles against the walls, water leaks with puddles,
	                     soot-streaked scorch marks, smashed lamps
	  moderate damage    ceiling panels down (hole above, wires hanging, panel below),
	                     wall plating peeled open with pipes behind, twisted metal,
	                     cracked windows with glass on the floor, lamps on red
	                     emergency power, sparking wires
	  heavy damage       claw gouges through torn plating, alien residue dripping from
	                     the ceiling and pooling on the floor, webbing across corners,
	                     growths on the walls

	Everything is decoration only (CanCollide off) so it never blocks the path,
	debris prefers the edges of the room, nothing lands near a doorway, and exit
	lights are never touched.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Decay = {}

local GRIME = Color3.fromRGB(28, 24, 20)
local SOOT = Color3.fromRGB(18, 16, 14)
local CONCRETE = { Color3.fromRGB(95, 95, 98), Color3.fromRGB(80, 80, 82), Color3.fromRGB(110, 108, 104) }
local METAL = Color3.fromRGB(85, 88, 94)
local RESIDUE = Color3.fromRGB(110, 60, 150)
local RESIDUE_DARK = Color3.fromRGB(45, 25, 60)
local WATER = Color3.fromRGB(90, 110, 120)
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

local function deco(room: Model, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, props: { [string]: any }?): Part
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

-- Flat disc lying on a surface (cylinder turned on its side).
local function disc(room: Model, name: string, pos: Vector3, diameter: number, thickness: number, color: Color3, material: Enum.Material?, props: { [string]: any }?): Part
	return deco(room, name, Vector3.new(thickness, diameter, diameter), CFrame.new(pos) * CFrame.Angles(0, 0, math.pi / 2), color, material,
		props and table.clone(props) or nil):: Part
end

-- A strand between two points.
local function strand(room: Model, name: string, a: Vector3, b: Vector3, thickness: number, color: Color3, material: Enum.Material?, props: { [string]: any }?)
	local mid = (a + b) / 2
	return deco(room, name, Vector3.new(thickness, thickness, (b - a).Magnitude), CFrame.lookAt(mid, b), color, material, props)
end

---------------------------------------------------------------- surfaces

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
	local breakChance = severity * 0.4
	local redChance = if severity > 0.35 then severity * 0.25 else 0
	local flickerChance = Config.FLICKER_CHANCE + severity * 0.25
	local working = #lamps
	for _, lamp in lamps do
		local light = lamp:FindFirstChildWhichIsA("Light")
		local roll = rng:NextNumber()
		-- Always leave at least one lamp working so rooms are never pitch black.
		if roll < breakChance and working > 1 then
			working -= 1
			lamp.Material = Enum.Material.SmoothPlastic
			lamp.Color = Color3.fromRGB(45, 45, 48)
			if light then
				light.Enabled = false
			end
		elseif roll < breakChance + redChance then
			-- Running on red emergency power.
			lamp.Color = Color3.fromRGB(120, 20, 15)
			if light then
				light.Color = Color3.fromRGB(255, 50, 35)
				light.Brightness *= 0.7
			end
		elseif roll < breakChance + redChance + flickerChance then
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

-- Random points on the room's floors, away from doorways. With edgeBias they
-- favour the sides of the room, leaving the walkway clear.
local function floorSpots(room: Model, count: number, rng: Random, params: RaycastParams, edgeBias: boolean?): { RaycastResult }
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
	if #floors == 0 or count <= 0 then
		return spots
	end
	for _ = 1, count * 5 do
		if #spots >= count then
			break
		end
		local floor = floors[rng:NextInteger(1, #floors)]
		local half = floor.Size / 2 - Vector3.new(1.8, 0, 2)
		local x = rng:NextNumber(-half.X, half.X)
		if edgeBias then
			x = (if rng:NextNumber() < 0.5 then -1 else 1) * half.X * rng:NextNumber(0.45, 1)
		end
		local origin = floor.CFrame:PointToWorldSpace(Vector3.new(x, half.Y + 6, rng:NextNumber(-half.Z, half.Z)))
		local hit = workspace:Raycast(origin, Vector3.new(0, -8, 0), params)
		if hit and hit.Normal.Y > 0.9 then
			local nearDoor = false
			for _, pos in doors do
				if Vector3.new(pos.X - hit.Position.X, 0, pos.Z - hit.Position.Z).Magnitude < DOOR_CLEARANCE then
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

-- Points on walls (vertical surfaces), found by casting sideways from floor points.
local function wallSpots(room: Model, count: number, rng: Random, params: RaycastParams, minY: number?, maxY: number?): { RaycastResult }
	local spots = {}
	for _, floorHit in floorSpots(room, count * 3, rng, params) do
		if #spots >= count then
			break
		end
		local angle = rng:NextNumber(0, math.pi * 2)
		local origin = floorHit.Position + Vector3.new(0, rng:NextNumber(minY or 2, maxY or 7), 0)
		local hit = workspace:Raycast(origin, Vector3.new(math.cos(angle), 0, math.sin(angle)) * 40, params)
		if hit and math.abs(hit.Normal.Y) < 0.2 and hit.Instance.Name == "Wall" then
			table.insert(spots, hit)
		end
	end
	return spots
end

-- Points on the ceiling above random floor spots.
local function ceilingSpots(room: Model, count: number, rng: Random, params: RaycastParams): { { floor: RaycastResult, ceiling: RaycastResult } }
	local spots = {}
	for _, floorHit in floorSpots(room, count * 2, rng, params, true) do
		if #spots >= count then
			break
		end
		local up = workspace:Raycast(floorHit.Position + Vector3.new(0, 0.5, 0), Vector3.new(0, 40, 0), params)
		if up and up.Normal.Y < -0.9 and up.Instance.Name == "Ceiling" then
			table.insert(spots, { floor = floorHit, ceiling = up })
		end
	end
	return spots
end

-- CFrame on a wall hit, facing out of the wall, rotated `roll` around the normal.
local function onSurface(hit: RaycastResult, offset: number, roll: number): CFrame
	local pos = hit.Position + hit.Normal * offset
	return CFrame.lookAt(pos, pos + hit.Normal) * CFrame.Angles(0, 0, roll)
end

---------------------------------------------------------------- scenes

-- A pile of broken concrete and junk against a wall, on a dust patch.
local function debrisPile(room: Model, hit: RaycastResult, rng: Random, size: number)
	local base = hit.Position
	disc(room, "Dust", base + Vector3.new(0, 0.012, 0), size * 2.4, 0.02, Color3.fromRGB(120, 118, 112), Enum.Material.Sand, { Transparency = 0.25 })
	local big = size * rng:NextNumber(0.9, 1.3)
	deco(room, "Debris", Vector3.new(big, big * 0.7, big * 0.9), CFrame.new(base + Vector3.new(0, big * 0.3, 0)) * CFrame.Angles(rng:NextNumber(-0.3, 0.3), rng:NextNumber(0, 3), rng:NextNumber(-0.3, 0.3)),
		CONCRETE[rng:NextInteger(1, #CONCRETE)], Enum.Material.Concrete)
	for _ = 1, rng:NextInteger(4, 7) do
		local s = size * rng:NextNumber(0.25, 0.6)
		local offset = Vector3.new(rng:NextNumber(-1, 1), 0, rng:NextNumber(-1, 1)).Unit * rng:NextNumber(0.4, size * 1.2)
		deco(room, "Debris", Vector3.new(s, s * rng:NextNumber(0.4, 0.8), s * rng:NextNumber(0.6, 1.2)),
			CFrame.new(base + offset + Vector3.new(0, s * 0.25, 0)) * CFrame.Angles(rng:NextNumber(-0.6, 0.6), rng:NextNumber(0, 3), rng:NextNumber(-0.6, 0.6)),
			if rng:NextNumber() < 0.75 then CONCRETE[rng:NextInteger(1, #CONCRETE)] else METAL,
			if rng:NextNumber() < 0.75 then Enum.Material.Concrete else Enum.Material.CorrodedMetal)
	end
	if rng:NextNumber() < 0.5 then
		-- A length of pipe or rebar sticking out of the pile.
		local len = rng:NextNumber(1.5, 3)
		deco(room, "Rebar", Vector3.new(0.15, len, 0.15), CFrame.new(base + Vector3.new(0, len * 0.3, 0)) * CFrame.Angles(rng:NextNumber(0.6, 1.1), rng:NextNumber(0, 6), 0),
			Color3.fromRGB(110, 70, 50), Enum.Material.CorrodedMetal)
	end
end

-- Paper scattered across the floor.
local function papers(room: Model, hit: RaycastResult, rng: Random)
	for k = 1, rng:NextInteger(3, 6) do
		local offset = Vector3.new(rng:NextNumber(-1.5, 1.5), 0.012 + k * 0.004, rng:NextNumber(-1.5, 1.5))
		deco(room, "Paper", Vector3.new(0.8, 0.02, 1.1), CFrame.new(hit.Position + offset) * CFrame.Angles(rng:NextNumber(-0.05, 0.05), rng:NextNumber(0, 3), 0),
			Color3.fromRGB(215, 210, 195))
	end
end

-- A sheet of metal plating, bent in two.
local function twistedMetal(room: Model, hit: RaycastResult, rng: Random)
	local yaw = rng:NextNumber(0, math.pi * 2)
	local base = CFrame.new(hit.Position + Vector3.new(0, 0.06, 0)) * CFrame.Angles(0, yaw, 0)
	deco(room, "TwistedMetal", Vector3.new(1.6, 0.08, 1.4), base * CFrame.new(-0.8, 0, 0), METAL, Enum.Material.CorrodedMetal)
	local bend = rng:NextNumber(0.4, 1)
	deco(room, "TwistedMetal", Vector3.new(1.6, 0.08, 1.4), base * CFrame.Angles(0, 0, bend) * CFrame.new(0.8, 0, 0), METAL, Enum.Material.CorrodedMetal)
end

-- Leak: dark stain running down the wall and a puddle below it.
local function leak(room: Model, hit: RaycastResult, rng: Random, floorY: number, ceilingY: number)
	local top = ceilingY - 0.1
	local len = top - floorY
	local cf = CFrame.lookAt(Vector3.new(hit.Position.X, floorY + len / 2, hit.Position.Z) + hit.Normal * 0.03, Vector3.new(hit.Position.X, floorY + len / 2, hit.Position.Z) + hit.Normal * 2)
	deco(room, "WaterStain", Vector3.new(rng:NextNumber(0.6, 1.4), len, 0.04), cf, Color3.fromRGB(40, 38, 32), nil, { Transparency = 0.45 })
	local puddleCenter = Vector3.new(hit.Position.X, floorY, hit.Position.Z) + hit.Normal * 1.2
	for k = 1, 3 do
		local offset = Vector3.new(rng:NextNumber(-0.6, 0.6), 0.01 + k * 0.006, rng:NextNumber(-0.6, 0.6))
		disc(room, "Puddle", puddleCenter + offset, rng:NextNumber(1.2, 2.4), 0.02, WATER, Enum.Material.Glass, { Transparency = 0.35, Reflectance = 0.35 })
	end
end

-- Scorch mark with soot streaks rising above it.
local function scorch(room: Model, hit: RaycastResult, rng: Random)
	local size = rng:NextNumber(1.8, 3.5)
	deco(room, "Scorch", Vector3.new(size * 1.4, size, 0.04), onSurface(hit, 0.025, rng:NextNumber(-0.4, 0.4)), Color3.fromRGB(40, 34, 28), nil, { Transparency = 0.35 })
	deco(room, "Scorch", Vector3.new(size * 0.8, size * 0.6, 0.04), onSurface(hit, 0.035, rng:NextNumber(0, 3)), SOOT, nil, { Transparency = 0.1 })
	for k = 1, 3 do
		local up = hit.Position + Vector3.new(0, size * 0.4 + k * 0.9, 0)
		local cf = CFrame.lookAt(up + hit.Normal * (0.02 + k * 0.004), up + hit.Normal * 2)
		deco(room, "Soot", Vector3.new(size * (1.1 - k * 0.2), 1, 0.03), cf, SOOT, nil, { Transparency = 0.35 + k * 0.17 })
	end
end

-- Ceiling panel down: a dark hole, wires spilling out (some sparking), the panel leaning on the floor below.
local function fallenPanel(room: Model, spot: { floor: RaycastResult, ceiling: RaycastResult }, rng: Random, severity: number)
	local c = spot.ceiling.Position
	local f = spot.floor.Position
	local yaw = rng:NextNumber(0, math.pi * 2)
	deco(room, "CeilingHole", Vector3.new(3.6, 0.05, 2.4), CFrame.new(c - Vector3.new(0, 0.025, 0)) * CFrame.Angles(0, yaw, 0), Color3.fromRGB(8, 8, 9))
	-- Duct and pipe glimpsed through the hole.
	deco(room, "ExposedDuct", Vector3.new(3.2, 0.06, 0.6), CFrame.new(c - Vector3.new(0, 0.06, 0)) * CFrame.Angles(0, yaw + 0.3, 0), Color3.fromRGB(70, 72, 76), Enum.Material.Metal)
	for k = 1, rng:NextInteger(2, 4) do
		local top = c + (CFrame.Angles(0, yaw, 0) * Vector3.new(rng:NextNumber(-1.4, 1.4), -0.05, rng:NextNumber(-0.9, 0.9)))
		local len = rng:NextNumber(1.5, math.min(5, c.Y - f.Y - 2))
		local endPos = top + Vector3.new(rng:NextNumber(-0.6, 0.6), -len, rng:NextNumber(-0.6, 0.6))
		strand(room, "Wire", top, endPos, 0.12, if k % 2 == 0 then Color3.fromRGB(150, 40, 30) else Color3.fromRGB(20, 20, 20))
		if severity > 0.3 and k == 1 and rng:NextNumber() < 0.6 then
			local spark = deco(room, "Lamp", Vector3.new(0.25, 0.25, 0.25), CFrame.new(endPos), Color3.fromRGB(255, 200, 120), Enum.Material.Neon, { Shape = Enum.PartType.Ball })
			spark:SetAttribute("Flicker", true)
			spark:SetAttribute("Spark", true)
			local glow = Instance.new("PointLight")
			glow.Color = Color3.fromRGB(255, 190, 110)
			glow.Range = 6
			glow.Brightness = 0.8
			glow.Parent = spark
		end
	end
	-- The panel itself, one edge on the floor, propped at an angle.
	local tilt = rng:NextNumber(0.25, 0.6)
	deco(room, "FallenPanel", Vector3.new(3.6, 0.15, 2.4),
		CFrame.new(f) * CFrame.Angles(0, yaw, 0) * CFrame.new(0, 2.4 / 2 * math.sin(tilt) + 0.08, 0) * CFrame.Angles(tilt, 0, 0),
		Color3.fromRGB(150, 152, 155), Enum.Material.Metal)
	for _ = 1, 3 do
		local s = rng:NextNumber(0.2, 0.5)
		deco(room, "Debris", Vector3.new(s, s * 0.6, s), CFrame.new(f + Vector3.new(rng:NextNumber(-1.8, 1.8), s * 0.3, rng:NextNumber(-1.8, 1.8))) * CFrame.Angles(0, rng:NextNumber(0, 3), 0),
			Color3.fromRGB(170, 170, 165), Enum.Material.SmoothPlastic)
	end
end

-- Wall plating peeled away from its frame, showing the dark cavity and pipes behind.
local function peeledPlating(room: Model, hit: RaycastResult, rng: Random)
	local w, h = rng:NextNumber(1.8, 2.8), rng:NextNumber(1.8, 2.6)
	deco(room, "WallCavity", Vector3.new(w, h, 0.04), onSurface(hit, 0.02, 0), Color3.fromRGB(10, 10, 11))
	for k = 1, 2 do
		local y = (k - 1.5) * h * 0.45
		deco(room, "CavityPipe", Vector3.new(w * 0.95, 0.25, 0.25), onSurface(hit, 0.15, 0) * CFrame.new(0, y, 0), Color3.fromRGB(90, 80, 70), Enum.Material.CorrodedMetal)
	end
	-- The plate, hinged on one vertical edge and bent outward.
	local hingeSide = if rng:NextNumber() < 0.5 then -1 else 1
	local open = rng:NextNumber(0.5, 1)
	deco(room, "PeeledPlate", Vector3.new(w, h, 0.12),
		onSurface(hit, 0.06, 0) * CFrame.new(hingeSide * w / 2, 0, 0) * CFrame.Angles(0, -hingeSide * open, 0) * CFrame.new(-hingeSide * w / 2, 0, 0),
		METAL, Enum.Material.Metal)
end

-- Claw gouges raked through a wall, plating torn at the bottom of the strokes.
local function claws(room: Model, hit: RaycastResult, rng: Random)
	local base = onSurface(hit, 0.03, rng:NextNumber(-0.5, 0.5))
	for k = -2, 1 do
		local len = rng:NextNumber(2.4, 3.6)
		deco(room, "Claw", Vector3.new(0.22, len, 0.05), base * CFrame.new((k + 0.5) * 0.55, k * 0.1, 0) * CFrame.Angles(0, 0, 0.08 * k), Color3.fromRGB(14, 10, 10))
		deco(room, "ClawLip", Vector3.new(0.08, len * 0.9, 0.08), base * CFrame.new((k + 0.5) * 0.55 + 0.15, k * 0.1, 0.02) * CFrame.Angles(0, 0, 0.08 * k), Color3.fromRGB(150, 150, 150), Enum.Material.Metal)
	end
	deco(room, "TornPlate", Vector3.new(1.6, 0.6, 0.1), base * CFrame.new(-0.2, -1.9, 0.3) * CFrame.Angles(0.6, 0, 0.2), METAL, Enum.Material.Metal)
end

-- Cracks across a window and broken glass on the floor beneath it.
local function crackedWindow(room: Model, window: BasePart, rng: Random, floorY: number)
	local cf = window.CFrame
	local origin = cf * CFrame.new(rng:NextNumber(-window.Size.X * 0.25, window.Size.X * 0.25), rng:NextNumber(-window.Size.Y * 0.2, window.Size.Y * 0.2), 0.12)
	for k = 0, 5 do
		local len = rng:NextNumber(0.8, math.min(window.Size.X, window.Size.Y) * 0.6)
		deco(room, "Crack", Vector3.new(0.04, len, 0.02), origin * CFrame.Angles(0, 0, k * 1.05 + rng:NextNumber(-0.3, 0.3)) * CFrame.new(0, len / 2, 0), Color3.fromRGB(220, 230, 235), nil, { Transparency = 0.2 })
	end
	local below = (cf * CFrame.new(0, 0, 1.6)).Position
	for _ = 1, 6 do
		deco(room, "Shard", Vector3.new(rng:NextNumber(0.2, 0.6), 0.04, rng:NextNumber(0.15, 0.45)),
			CFrame.new(below.X + rng:NextNumber(-1.5, 1.5), floorY + 0.03, below.Z + rng:NextNumber(-1.5, 1.5)) * CFrame.Angles(0, rng:NextNumber(0, 3), 0),
			Color3.fromRGB(180, 200, 210), Enum.Material.Glass, { Transparency = 0.4 })
	end
end

-- Alien residue: drips hanging from the ceiling over a glistening pool.
local function residueDrip(room: Model, spot: { floor: RaycastResult, ceiling: RaycastResult }, rng: Random)
	local c, f = spot.ceiling.Position, spot.floor.Position
	for _ = 1, rng:NextInteger(3, 5) do
		local top = c + Vector3.new(rng:NextNumber(-1, 1), -0.02, rng:NextNumber(-1, 1))
		local len = rng:NextNumber(0.8, 2.6)
		for seg = 0, 2 do
			local s = 0.35 - seg * 0.1
			deco(room, "Residue", Vector3.new(s, len / 3, s), CFrame.new(top - Vector3.new(0, len / 6 + seg * len / 3, 0)), RESIDUE, Enum.Material.Glass, { Transparency = 0.15, Reflectance = 0.2 })
		end
	end
	disc(room, "ResiduePool", c * Vector3.new(1, 0, 1) + Vector3.new(0, f.Y + 0.015, 0), rng:NextNumber(2.5, 4), 0.03, RESIDUE, Enum.Material.Glass, { Transparency = 0.1, Reflectance = 0.25 })
	disc(room, "ResiduePool", c * Vector3.new(1, 0, 1) + Vector3.new(rng:NextNumber(-1, 1), f.Y + 0.025, rng:NextNumber(-1, 1)), rng:NextNumber(1, 2), 0.03, RESIDUE_DARK, Enum.Material.Glass, { Transparency = 0.1 })
	local glow = deco(room, "ResidueGlow", Vector3.new(0.2, 0.2, 0.2), CFrame.new(f + Vector3.new(0, 0.2, 0)), RESIDUE, nil, { Transparency = 1 })
	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(170, 90, 255)
	light.Range = 6
	light.Brightness = 0.4
	light.Parent = glow
end

-- Webbing strung between two nearby wall points.
local function webbing(room: Model, a: RaycastResult, b: RaycastResult, rng: Random)
	local pa, pb = a.Position + a.Normal * 0.05, b.Position + b.Normal * 0.05
	for k = 0, rng:NextInteger(3, 6) do
		local sag = Vector3.new(0, -rng:NextNumber(0.3, 1.2), 0)
		local offA = Vector3.new(0, rng:NextNumber(-0.6, 0.6), 0)
		local offB = Vector3.new(0, rng:NextNumber(-0.6, 0.6), 0)
		local midPoint = (pa + pb) / 2 + sag + Vector3.new(0, k * 0.1, 0)
		strand(room, "Web", pa + offA, midPoint, 0.05, Color3.fromRGB(200, 185, 220), Enum.Material.Glass, { Transparency = 0.4 })
		strand(room, "Web", midPoint, pb + offB, 0.05, Color3.fromRGB(200, 185, 220), Enum.Material.Glass, { Transparency = 0.4 })
	end
end

-- Cluster of growths bulging out of a wall.
local function growth(room: Model, hit: RaycastResult, rng: Random)
	local base = onSurface(hit, 0, 0)
	for _ = 1, rng:NextInteger(5, 9) do
		local d = rng:NextNumber(0.4, 1.3)
		local p = deco(room, "Growth", Vector3.new(d, d, d), base * CFrame.new(rng:NextNumber(-1.2, 1.2), rng:NextNumber(-1.2, 1.2), d * 0.25),
			RESIDUE_DARK:Lerp(RESIDUE, rng:NextNumber(0, 0.5)), Enum.Material.SmoothPlastic, { Shape = Enum.PartType.Ball, Reflectance = 0.15 })
		if rng:NextNumber() < 0.25 then
			p.Material = Enum.Material.Neon
			p.Color = Color3.fromRGB(90, 40, 120)
		end
	end
end

---------------------------------------------------------------- apply

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
	local entrance = room:FindFirstChild("Entrance") :: BasePart?
	local floorY = if entrance then entrance.Position.Y else room:GetPivot().Position.Y
	local ceilingY = floorY + (room:GetAttribute("H") or 10)

	-- Light damage.
	for _, hit in floorSpots(room, amount(rng, severity * 4), rng, params, true) do
		debrisPile(room, hit, rng, rng:NextNumber(0.6, 1) + severity * 0.6)
	end
	for _, hit in floorSpots(room, amount(rng, 0.4 + severity * 2), rng, params) do
		papers(room, hit, rng)
	end
	for _, hit in wallSpots(room, amount(rng, severity * 2), rng, params) do
		leak(room, hit, rng, floorY, ceilingY)
	end
	for _, hit in wallSpots(room, amount(rng, severity * 4), rng, params) do
		scorch(room, hit, rng)
	end

	-- Moderate damage.
	if severity > 0.2 then
		for _, spot in ceilingSpots(room, amount(rng, severity * 2.5), rng, params) do
			fallenPanel(room, spot, rng, severity)
		end
		for _, hit in wallSpots(room, amount(rng, severity * 2.5), rng, params, 2.5, 6) do
			peeledPlating(room, hit, rng)
		end
		for _, hit in floorSpots(room, amount(rng, severity * 3), rng, params, true) do
			twistedMetal(room, hit, rng)
		end
		for _, d in room:GetDescendants() do
			if d.Name == "Window" and d:IsA("BasePart") and rng:NextNumber() < severity * 0.6 then
				crackedWindow(room, d, rng, floorY)
			end
		end
	end

	-- Heavy damage.
	if severity > 0.35 then
		for _, hit in wallSpots(room, amount(rng, severity * 3), rng, params) do
			claws(room, hit, rng)
		end
	end
	if severity > 0.5 then
		local amountResidue = amount(rng, (severity - 0.5) * 8)
		for _, spot in ceilingSpots(room, amountResidue, rng, params) do
			residueDrip(room, spot, rng)
		end
		local walls = wallSpots(room, amountResidue * 2 + 2, rng, params, 5, 9)
		for i = 1, #walls - 1, 2 do
			if (walls[i].Position - walls[i + 1].Position).Magnitude < 14 then
				webbing(room, walls[i], walls[i + 1], rng)
			end
		end
	end
	if severity > 0.7 then
		for _, hit in wallSpots(room, amount(rng, (severity - 0.7) * 10), rng, params) do
			growth(room, hit, rng)
		end
	end
end

return Decay
