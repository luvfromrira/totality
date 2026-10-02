--[[
	Built-in room presets made from code. These are used whenever
	ServerStorage.Rooms.Normal / Special doesn't have presets built in Studio.

	Every room is built in local space:
	  - Entrance at (0, 0, 0), players walk toward -Z.
	  - Exit is a CFrame at floor level whose LookVector points out of the room.
	Attributes: Weight, MinRoom, MaxRoom, Turn (-1 = right, 0 = straight, 1 = left).
]]

local RoomPresets = {}

local WALL_HEIGHT = 12
local DOOR_WIDTH = 6
local DOOR_HEIGHT = 9

local COLORS = {
	wall = Color3.fromRGB(62, 60, 70),
	floor = Color3.fromRGB(45, 43, 50),
	ceiling = Color3.fromRGB(35, 34, 40),
	trim = Color3.fromRGB(25, 24, 28),
	door = Color3.fromRGB(80, 56, 40),
	wood = Color3.fromRGB(92, 70, 52),
	metal = Color3.fromRGB(110, 112, 120),
	lampWarm = Color3.fromRGB(255, 214, 160),
	lampCold = Color3.fromRGB(180, 210, 255),
	cosmic = Color3.fromRGB(150, 110, 255),
}

local function part(model: Model, name: string, size: Vector3, cframe: CFrame, props: { [string]: any }?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.CFrame = cframe
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	p.Color = COLORS.wall
	for k, v in props or {} do
		(p :: any)[k] = v
	end
	p.Parent = model
	return p
end

local function marker(model: Model, name: string, cframe: CFrame)
	return part(model, name, Vector3.new(1, 1, 1), cframe, {
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
	})
end

-- Ceiling lamp: glowing fixture + shadow-casting point light.
local function lamp(model: Model, position: Vector3, color: Color3?, range: number?, brightness: number?)
	color = color or COLORS.lampWarm
	local fixture = part(model, "Lamp", Vector3.new(3, 0.4, 3), CFrame.new(position), {
		Material = Enum.Material.Neon,
		Color = color,
		CanCollide = false,
	})
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = range or 24
	light.Brightness = brightness or 1.6
	light.Shadows = true
	light.Parent = fixture
	return fixture
end

-- A row of lamps along the ceiling from z=0 to z=-length.
local function lampRow(model: Model, x: number, y: number, length: number, spacing: number, color: Color3?)
	local count = math.max(1, math.floor(length / spacing))
	for i = 1, count do
		local z = -(i - 0.5) * (length / count)
		lamp(model, Vector3.new(x, y - 0.3, z), color)
	end
end

--[[
	Solid wall, or a wall with a doorway + Door + Exit.
	`cf` is the wall's center at floor level, LookVector pointing out of the room.
]]
local function wall(model: Model, cf: CFrame, width: number, height: number, isExit: boolean?, color: Color3?)
	local c = color or COLORS.wall
	local center = cf * CFrame.new(0, height / 2, -0.5)
	if not isExit then
		part(model, "Wall", Vector3.new(width, height, 1), center, { Color = c })
		return
	end
	local side = (width - DOOR_WIDTH) / 2
	local offset = DOOR_WIDTH / 2 + side / 2
	part(model, "Wall", Vector3.new(side, height, 1), center * CFrame.new(-offset, 0, 0), { Color = c })
	part(model, "Wall", Vector3.new(side, height, 1), center * CFrame.new(offset, 0, 0), { Color = c })
	part(model, "Wall", Vector3.new(DOOR_WIDTH, height - DOOR_HEIGHT, 1),
		cf * CFrame.new(0, DOOR_HEIGHT + (height - DOOR_HEIGHT) / 2, -0.5), { Color = c })
	-- Door frame
	part(model, "Frame", Vector3.new(0.6, DOOR_HEIGHT, 1.4), cf * CFrame.new(-DOOR_WIDTH / 2 - 0.3, DOOR_HEIGHT / 2, -0.5),
		{ Color = COLORS.trim })
	part(model, "Frame", Vector3.new(0.6, DOOR_HEIGHT, 1.4), cf * CFrame.new(DOOR_WIDTH / 2 + 0.3, DOOR_HEIGHT / 2, -0.5),
		{ Color = COLORS.trim })
	part(model, "Door", Vector3.new(DOOR_WIDTH, DOOR_HEIGHT, 0.6), cf * CFrame.new(0, DOOR_HEIGHT / 2, -0.5),
		{ Color = COLORS.door, Material = Enum.Material.Wood })
	-- Lamp above every door so exits are easy to spot.
	lamp(model, (cf * CFrame.new(0, DOOR_HEIGHT + 1, 1.5)).Position, COLORS.lampWarm, 14, 1.2)
	marker(model, "Exit", cf)
end

-- Floor + ceiling for a rectangular area (x from -w/2..w/2, z from 0..-length).
local function shell(model: Model, w: number, length: number, height: number, y: number?)
	y = y or 0
	part(model, "Floor", Vector3.new(w, 1, length), CFrame.new(0, y - 0.5, -length / 2),
		{ Color = COLORS.floor, Material = Enum.Material.Concrete })
	part(model, "Ceiling", Vector3.new(w, 1, length), CFrame.new(0, y + height + 0.5, -length / 2),
		{ Color = COLORS.ceiling })
end

local function sideWalls(model: Model, w: number, length: number, height: number)
	wall(model, CFrame.new(-w / 2, 0, -length / 2) * CFrame.Angles(0, math.rad(90), 0), length, height)
	wall(model, CFrame.new(w / 2, 0, -length / 2) * CFrame.Angles(0, math.rad(-90), 0), length, height)
end

local function newRoom(name: string, attrs: { [string]: any }?): Model
	local model = Instance.new("Model")
	model.Name = name
	for k, v in attrs or {} do
		model:SetAttribute(k, v)
	end
	marker(model, "Entrance", CFrame.new(0, 0, 0))
	return model
end

local function finish(model: Model): Model
	model.PrimaryPart = model:FindFirstChild("Entrance") :: BasePart
	return model
end

---------------------------------------------------------------- rooms

local function hallway(): Model
	local m = newRoom("Hallway", { Weight = 3 })
	local w, l, h = 14, 44, WALL_HEIGHT
	shell(m, w, l, h)
	sideWalls(m, w, l, h)
	wall(m, CFrame.new(0, 0, -l), w, h, true)
	lampRow(m, 0, h, l, 11)
	marker(m, "ResearchSpawn", CFrame.new(-5, 1, -l / 2))
	return finish(m)
end

local function turn(direction: number): Model
	-- direction: 1 = left, -1 = right
	local m = newRoom(direction == 1 and "TurnLeft" or "TurnRight", { Weight = 2, Turn = direction })
	local s, h = 24, WALL_HEIGHT
	shell(m, s, s, h)
	wall(m, CFrame.new(0, 0, -s), s, h) -- far wall
	local exitCf = CFrame.new(-direction * s / 2, 0, -s / 2) * CFrame.Angles(0, math.rad(90 * direction), 0)
	local solidCf = CFrame.new(direction * s / 2, 0, -s / 2) * CFrame.Angles(0, math.rad(-90 * direction), 0)
	wall(m, exitCf, s, h, true)
	wall(m, solidCf, s, h)
	lamp(m, Vector3.new(-6, h - 0.3, -6))
	lamp(m, Vector3.new(6, h - 0.3, -18))
	lamp(m, Vector3.new(-6, h - 0.3, -18))
	lamp(m, Vector3.new(6, h - 0.3, -6))
	-- A crate in the corner the player walks toward.
	part(m, "Crate", Vector3.new(4, 4, 4), CFrame.new(direction * 8, 2, -20) * CFrame.Angles(0, 0.3, 0),
		{ Color = COLORS.wood, Material = Enum.Material.WoodPlanks })
	marker(m, "ResearchSpawn", CFrame.new(direction * 8, 4.5, -20))
	return finish(m)
end

local function office(): Model
	local m = newRoom("Office", { Weight = 2 })
	local w, l, h = 30, 36, WALL_HEIGHT
	shell(m, w, l, h)
	sideWalls(m, w, l, h)
	wall(m, CFrame.new(0, 0, -l), w, h, true)
	for _, x in { -9, 9 } do
		for _, z in { -10, -24 } do
			part(m, "Desk", Vector3.new(7, 0.4, 4), CFrame.new(x, 3, z), { Color = COLORS.wood, Material = Enum.Material.Wood })
			for _, dx in { -3, 3 } do
				part(m, "Leg", Vector3.new(0.4, 3, 0.4), CFrame.new(x + dx, 1.5, z), { Color = COLORS.trim })
			end
			part(m, "Monitor", Vector3.new(2.4, 1.6, 0.3), CFrame.new(x, 4, z - 1), { Color = COLORS.trim })
			part(m, "Screen", Vector3.new(2.1, 1.3, 0.05), CFrame.new(x, 4, z - 0.83), {
				Material = Enum.Material.Neon,
				Color = Color3.fromRGB(60, 90, 80),
				CanCollide = false,
			})
			part(m, "Chair", Vector3.new(2, 2.5, 2), CFrame.new(x, 1.25, z + 3), { Color = COLORS.metal })
		end
	end
	lampRow(m, -8, h, l, 12, COLORS.lampCold)
	lampRow(m, 8, h, l, 12, COLORS.lampCold)
	marker(m, "ResearchSpawn", CFrame.new(-9, 3.6, -10))
	marker(m, "ResearchSpawn", CFrame.new(9, 3.6, -24))
	return finish(m)
end

local function archive(): Model
	local m = newRoom("Archive", { Weight = 2, MinRoom = 5 })
	local w, l, h = 32, 48, 16
	shell(m, w, l, h)
	sideWalls(m, w, l, h)
	wall(m, CFrame.new(0, 0, -l), w, h, true)
	-- Rows of tall shelves with a clear center aisle.
	for _, x in { -11, -6, 6, 11 } do
		for z = -8, -40, -16 do
			part(m, "Shelf", Vector3.new(2, 10, 12), CFrame.new(x, 5, z), { Color = COLORS.wood, Material = Enum.Material.Wood })
		end
	end
	for z = -6, -42, -12 do
		lamp(m, Vector3.new(0, h - 0.3, z))
		lamp(m, Vector3.new(-8.5, h - 0.3, z), COLORS.lampWarm, 18, 1.2)
		lamp(m, Vector3.new(8.5, h - 0.3, z), COLORS.lampWarm, 18, 1.2)
	end
	marker(m, "ResearchSpawn", CFrame.new(-8.5, 1, -16))
	marker(m, "ResearchSpawn", CFrame.new(8.5, 1, -32))
	return finish(m)
end

local function greatHall(): Model
	local m = newRoom("GreatHall", { Weight = 1, MinRoom = 10 })
	local w, l, h = 44, 64, 26
	shell(m, w, l, h)
	sideWalls(m, w, l, h)
	wall(m, CFrame.new(0, 0, -l), w, h, true)
	for z = -12, -52, -20 do
		for _, x in { -14, 14 } do
			part(m, "Pillar", Vector3.new(4, h, 4), CFrame.new(x, h / 2, z), { Color = COLORS.trim, Material = Enum.Material.Marble })
			lamp(m, Vector3.new(x, 8, z + 2.3), COLORS.lampWarm, 20, 1.4) -- wall sconce on the pillar
		end
		lamp(m, Vector3.new(0, h - 0.3, z), COLORS.lampWarm, 36, 2)
	end
	marker(m, "ResearchSpawn", CFrame.new(-14, 1, -24))
	marker(m, "ResearchSpawn", CFrame.new(14, 1, -44))
	return finish(m)
end

local function stairwell(): Model
	local m = newRoom("Stairwell", { Weight = 1, MinRoom = 3 })
	local w, l, rise = 16, 44, 10
	local h = WALL_HEIGHT + rise
	-- Floor before, steps, landing after.
	part(m, "Floor", Vector3.new(w, 1, 10), CFrame.new(0, -0.5, -5), { Color = COLORS.floor, Material = Enum.Material.Concrete })
	local steps = 20
	local run = 24 / steps
	for i = 1, steps do
		local y = i * (rise / steps)
		part(m, "Step", Vector3.new(w, y, run), CFrame.new(0, y / 2, -10 - (i - 0.5) * run),
			{ Color = COLORS.floor, Material = Enum.Material.Concrete })
	end
	part(m, "Floor", Vector3.new(w, rise + 1, 10), CFrame.new(0, (rise - 1) / 2, -39),
		{ Color = COLORS.floor, Material = Enum.Material.Concrete })
	part(m, "Ceiling", Vector3.new(w, 1, l), CFrame.new(0, h + 0.5, -l / 2), { Color = COLORS.ceiling })
	sideWalls(m, w, l, h)
	-- Exit on the landing, wall filler below it.
	wall(m, CFrame.new(0, rise, -l), w, WALL_HEIGHT, true)
	part(m, "Wall", Vector3.new(w, rise, 1), CFrame.new(0, rise / 2, -l - 0.5))
	lamp(m, Vector3.new(0, h - 0.3, -5))
	lamp(m, Vector3.new(0, h - 0.3, -16))
	lamp(m, Vector3.new(0, h - 0.3, -28))
	lamp(m, Vector3.new(0, h - 0.3, -39))
	-- Railings
	for _, x in { -w / 2 + 1, w / 2 - 1 } do
		part(m, "Rail", Vector3.new(0.4, 0.4, 26), CFrame.new(x, 3 + rise / 2, -22) * CFrame.Angles(math.atan2(rise, 24), 0, 0),
			{ Color = COLORS.metal, Material = Enum.Material.Metal, CanCollide = false })
	end
	marker(m, "ResearchSpawn", CFrame.new(5, rise + 1, -40))
	return finish(m)
end

local function observatory(): Model
	-- Cosmic-horror flavor room: dark ring of seats around a glowing core.
	local m = newRoom("Observatory", { Weight = 1, MinRoom = 20 })
	local s, h = 40, 22
	shell(m, s, s, h)
	sideWalls(m, s, s, h)
	wall(m, CFrame.new(0, 0, -s), s, h, true)
	local core = part(m, "Core", Vector3.new(5, 5, 5), CFrame.new(0, 7, -s / 2), {
		Shape = Enum.PartType.Ball,
		Material = Enum.Material.Neon,
		Color = COLORS.cosmic,
		CanCollide = false,
	})
	local glow = Instance.new("PointLight")
	glow.Color = COLORS.cosmic
	glow.Range = 30
	glow.Brightness = 2
	glow.Shadows = true
	glow.Parent = core
	part(m, "Pedestal", Vector3.new(6, 3, 6), CFrame.new(0, 1.5, -s / 2), { Color = COLORS.trim, Material = Enum.Material.Slate })
	for _, pos in { Vector3.new(-12, 0, -8), Vector3.new(12, 0, -8), Vector3.new(-12, 0, -32), Vector3.new(12, 0, -32) } do
		lamp(m, pos + Vector3.new(0, h - 0.3, 0), COLORS.lampCold, 26, 1.5)
	end
	marker(m, "ResearchSpawn", CFrame.new(0, 3.6, -s / 2 + 2.5))
	return finish(m)
end

---------------------------------------------------------------- special

local function start(): Model
	local m = newRoom("Start")
	local w, l, h = 24, 32, WALL_HEIGHT
	shell(m, w, l, h)
	sideWalls(m, w, l, h)
	wall(m, CFrame.new(0, 0, 0) * CFrame.Angles(0, math.pi, 0), w, h) -- back wall
	wall(m, CFrame.new(0, 0, -l), w, h, true)
	lampRow(m, -6, h, l, 10)
	lampRow(m, 6, h, l, 10)
	marker(m, "PlayerSpawn", CFrame.new(0, 3, -6))
	return finish(m)
end

local function final(): Model
	local m = newRoom("Final")
	local w, l, h = 50, 60, 30
	shell(m, w, l, h)
	sideWalls(m, w, l, h)
	wall(m, CFrame.new(0, 0, -l), w, h) -- no way forward
	local rift = part(m, "Rift", Vector3.new(14, 20, 1), CFrame.new(0, 12, -l + 3), {
		Material = Enum.Material.Neon,
		Color = COLORS.cosmic,
		CanCollide = false,
	})
	local glow = Instance.new("PointLight")
	glow.Color = COLORS.cosmic
	glow.Range = 50
	glow.Brightness = 3
	glow.Parent = rift
	for z = -10, -50, -20 do
		lamp(m, Vector3.new(-15, h - 0.3, z), COLORS.lampCold, 30, 1.5)
		lamp(m, Vector3.new(15, h - 0.3, z), COLORS.lampCold, 30, 1.5)
	end
	marker(m, "ResearchSpawn", CFrame.new(0, 1, -l + 8))
	return finish(m)
end

function RoomPresets.BuildNormal(): { Model }
	return { hallway(), turn(1), turn(-1), office(), archive(), greatHall(), stairwell(), observatory() }
end

function RoomPresets.BuildSpecial(): { [string]: Model }
	return { Start = start(), Final = final() }
end

return RoomPresets
