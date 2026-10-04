--[[
	Built-in room presets, built from code with RoomBuilder. Used whenever
	ServerStorage.Rooms.Normal / Special doesn't have presets made in Studio.

	The style is liminal: ordinary, empty places that feel slightly wrong.
	Bright, flat fluorescent light, repeated details, signs that don't quite
	make sense, and no people.

	Attributes: Weight, MinRoom, MaxRoom, Turn (1 = exit on the left, -1 = right).
]]

local B = require(script.Parent.RoomBuilder)
local part = B.part

local RoomPresets = {}

local function rgb(r: number, g: number, b: number)
	return Color3.fromRGB(r, g, b)
end

local M = Enum.Material

local PAL = {
	office = { wall = rgb(205, 195, 165), wallMat = M.Plaster, floor = rgb(95, 100, 110), floorMat = M.Carpet,
		ceiling = rgb(225, 222, 212), ceilingMat = M.SmoothPlastic, trim = rgb(70, 60, 50), light = rgb(255, 244, 220) },
	backrooms = { wall = rgb(200, 182, 105), wallMat = M.Plaster, floor = rgb(150, 130, 80), floorMat = M.Carpet,
		ceiling = rgb(215, 205, 165), ceilingMat = M.SmoothPlastic, trim = rgb(120, 100, 60), light = rgb(255, 240, 190) },
	pool = { wall = rgb(235, 240, 242), wallMat = M.CeramicTiles, floor = rgb(225, 232, 235), floorMat = M.CeramicTiles,
		ceiling = rgb(240, 242, 244), ceilingMat = M.CeramicTiles, trim = rgb(150, 190, 200), light = rgb(235, 245, 255) },
	hotel = { wall = rgb(180, 150, 120), wallMat = M.Plaster, floor = rgb(110, 32, 38), floorMat = M.Carpet,
		ceiling = rgb(200, 190, 170), ceilingMat = M.SmoothPlastic, trim = rgb(70, 40, 30), light = rgb(255, 210, 150) },
	clinic = { wall = rgb(190, 210, 195), wallMat = M.Plaster, floor = rgb(200, 200, 195), floorMat = M.SmoothPlastic,
		ceiling = rgb(230, 230, 225), ceilingMat = M.SmoothPlastic, trim = rgb(90, 110, 100), light = rgb(240, 250, 255) },
	concrete = { wall = rgb(130, 130, 128), wallMat = M.Concrete, floor = rgb(105, 105, 103), floorMat = M.Concrete,
		ceiling = rgb(120, 120, 118), ceilingMat = M.Concrete, trim = rgb(200, 170, 40), light = rgb(255, 180, 90) },
	school = { wall = rgb(215, 210, 190), wallMat = M.Plaster, floor = rgb(180, 180, 175), floorMat = M.CeramicTiles,
		ceiling = rgb(230, 228, 220), ceilingMat = M.SmoothPlastic, trim = rgb(60, 90, 140), light = rgb(235, 245, 255) },
	restroom = { wall = rgb(170, 205, 200), wallMat = M.CeramicTiles, floor = rgb(220, 220, 215), floorMat = M.CeramicTiles,
		ceiling = rgb(230, 230, 228), ceilingMat = M.SmoothPlastic, trim = rgb(120, 150, 150), light = rgb(240, 250, 255) },
	play = { wall = rgb(240, 190, 200), wallMat = M.Plaster, floor = rgb(140, 190, 230), floorMat = M.Fabric,
		ceiling = rgb(245, 240, 230), ceilingMat = M.SmoothPlastic, trim = rgb(250, 220, 90), light = rgb(255, 240, 220) },
	mall = { wall = rgb(220, 215, 205), wallMat = M.Plaster, floor = rgb(200, 195, 185), floorMat = M.Marble,
		ceiling = rgb(225, 222, 215), ceilingMat = M.SmoothPlastic, trim = rgb(150, 140, 120), light = rgb(235, 245, 255) },
	archive = { wall = rgb(120, 105, 90), wallMat = M.Plaster, floor = rgb(90, 75, 60), floorMat = M.WoodPlanks,
		ceiling = rgb(150, 140, 125), ceilingMat = M.SmoothPlastic, trim = rgb(60, 45, 35), light = rgb(255, 214, 160) },
	cosmic = { wall = rgb(40, 38, 52), wallMat = M.Slate, floor = rgb(30, 28, 40), floorMat = M.Slate,
		ceiling = rgb(25, 24, 35), ceilingMat = M.Slate, trim = rgb(90, 70, 150), light = rgb(180, 160, 255) },
}

local COSMIC = rgb(150, 110, 255)

-- Simple chair; faces -Z of `cf` (backrest on the +Z side).
local function chair(m: Model, cf: CFrame, color: Color3)
	part(m, "Chair", Vector3.new(1.4, 1.6, 1.4), cf * CFrame.new(0, 0.8, 0), { Color = rgb(60, 60, 64) })
	part(m, "Chair", Vector3.new(2, 0.4, 2), cf * CFrame.new(0, 1.8, 0), { Color = color, Material = M.Fabric })
	part(m, "Chair", Vector3.new(2, 2.2, 0.3), cf * CFrame.new(0, 3.1, 0.85), { Color = color, Material = M.Fabric })
end

-- Glowing core with a light (observatory / final room).
local function glowing(p: Part?, color: Color3, range: number, brightness: number)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = range
	light.Brightness = brightness
	light.Shadows = true
	light.Parent = p
end

---------------------------------------------------------------- normal rooms

-- Beige office corridor lined with closed doors that never open.
local function hallway(): Model
	local m = B.newRoom("Hallway", { Weight = 3 })
	local w, L, h, pal = 12, 48, 10, PAL.office
	B.shell(m, w, L, h, pal)
	B.baseboards(m, w, L, pal.trim)
	for i, z in { -10, -22, -34 } do
		local side = if i % 2 == 0 then 1 else -1
		B.onWall(m, w, side, z, 4.25, Vector2.new(4, 8.5), 0.3, "FakeDoor", { Color = rgb(150, 130, 110), Material = M.Wood })
	end
	B.panelGrid(m, w, L, h, 1, 6, pal.light)
	return m
end

-- Square office room whose exit is on the left (1) or right (-1).
local function turn(direction: number): Model
	local m = B.newRoom(if direction == 1 then "TurnLeft" else "TurnRight", { Weight = 2, Turn = direction })
	local w, L, h, pal = 24, 24, 10, PAL.office
	B.shell(m, w, L, h, pal, { exit = if direction == 1 then "left" else "right" })
	-- Water cooler in the far corner on the solid side.
	local x = direction * (w / 2 - 0.8)
	part(m, "Cooler", Vector3.new(1.6, 4, 1.6), CFrame.new(x, 2, -L + 0.8), { Color = rgb(225, 225, 220) })
	part(m, "Jug", Vector3.new(1.2, 1.2, 1.2), CFrame.new(x, 4.6, -L + 0.8),
		{ Shape = Enum.PartType.Ball, Material = M.Glass, Color = rgb(150, 200, 255), Transparency = 0.3 })
	-- One chair facing the wall, as if someone just left.
	chair(m, CFrame.new(direction * 4, 0, -L + 4), rgb(70, 80, 110))
	B.panelGrid(m, w, L, h, 2, 2, pal.light)
	return m
end

-- Cubicle farm: four empty cubicles, monitors still on.
local function office(): Model
	local m = B.newRoom("Office", { Weight = 2 })
	local w, L, h, pal = 36, 40, 10, PAL.office
	B.shell(m, w, L, h, pal)
	local partition = { Color = rgb(150, 150, 160), Material = M.Fabric }
	for _, cx in { -12, 12 } do
		local s = math.sign(cx) -- 1 = right side; cubicles open toward the centre aisle
		for _, cz in { -10, -26 } do
			part(m, "Partition", Vector3.new(0.4, 5, 10), CFrame.new(cx + s * 4.8, 2.5, cz), partition)
			for _, dz in { -4.8, 4.8 } do
				part(m, "Partition", Vector3.new(9.6, 5, 0.4), CFrame.new(cx - s * 0.2, 2.5, cz + dz), partition)
			end
			part(m, "Desk", Vector3.new(3, 0.3, 6), CFrame.new(cx + s * 3.1, 2.85, cz), { Color = rgb(170, 150, 120), Material = M.Wood })
			for _, dz in { -2.7, 2.7 } do
				part(m, "DeskLeg", Vector3.new(2.6, 2.7, 0.3), CFrame.new(cx + s * 3.1, 1.35, cz + dz), { Color = rgb(90, 90, 95) })
			end
			part(m, "Monitor", Vector3.new(0.3, 1.6, 2.4), CFrame.new(cx + s * 4, 3.8, cz), { Color = rgb(40, 40, 44) })
			part(m, "Screen", Vector3.new(0.05, 1.3, 2.1), CFrame.new(cx + s * 3.825, 3.8, cz),
				{ Material = M.Neon, Color = rgb(70, 110, 160), CanCollide = false })
			chair(m, CFrame.new(cx, 0, cz) * CFrame.Angles(0, math.rad(-s * 90), 0), rgb(50, 55, 70))
		end
	end
	B.panelGrid(m, w, L, h, 3, 4, pal.light)
	return m
end

-- Mono-yellow wallpaper, damp carpet, half-walls that go nowhere.
local function backrooms(): Model
	local m = B.newRoom("Backrooms", { Weight = 2, MinRoom = 8 })
	local w, L, h, pal = 40, 48, 10, PAL.backrooms
	B.shell(m, w, L, h, pal)
	local stubs = {
		{ -12, -10, 12, 1 }, { 10, -14, 1, 12 }, { -8, -24, 1, 10 },
		{ 12, -30, 14, 1 }, { -11, -36, 1, 12 }, { 4, -40, 10, 1 },
	}
	for _, s in stubs do
		part(m, "Partition", Vector3.new(s[3], h, s[4]), CFrame.new(s[1], h / 2, s[2]), { Color = pal.wall, Material = pal.wallMat })
	end
	part(m, "Stain", Vector3.new(6, 0.05, 4), CFrame.new(6, 0.025, -22), { Color = rgb(110, 95, 55), Material = M.Carpet, CanCollide = false })
	B.panelGrid(m, w, L, h, 4, 5, pal.light, 1.3)
	return m
end

-- Endless white tile and still water.
local function poolRooms(): Model
	local m = B.newRoom("PoolRooms", { Weight = 1, MinRoom = 12 })
	local w, L, h, pal = 32, 44, 14, PAL.pool
	B.shell(m, w, L, h, pal)
	local tile = { Color = pal.trim, Material = M.CeramicTiles }
	for _, sx in { -1, 1 } do
		part(m, "Rim", Vector3.new(1, 1.2, 24), CFrame.new(sx * 9.5, 0.6, -22), tile)
	end
	for _, z in { -10.5, -33.5 } do
		part(m, "Rim", Vector3.new(18, 1.2, 1), CFrame.new(0, 0.6, z), tile)
	end
	part(m, "Water", Vector3.new(18, 0.8, 22), CFrame.new(0, 0.4, -22), {
		Material = M.Glass, Color = rgb(120, 190, 215), Transparency = 0.35, CanCollide = false, CanQuery = false,
	})
	for _, x in { -14, 14 } do
		for _, z in { -16, -30 } do
			part(m, "Pillar", Vector3.new(2, h, 2), CFrame.new(x, h / 2, z), { Color = pal.wall, Material = pal.wallMat })
		end
	end
	B.panelGrid(m, w, L, h, 3, 4, pal.light, 1.8, 22)
	return m
end

-- Long hotel corridor. Every door is room 237.
local function hotel(): Model
	local m = B.newRoom("HotelCorridor", { Weight = 2, MinRoom = 4 })
	local w, L, h, pal = 10, 64, 10, PAL.hotel
	B.shell(m, w, L, h, pal)
	B.baseboards(m, w, L, pal.trim)
	for i = 0, 4 do
		local z = -6 - i * 12
		for _, side in { -1, 1 } do
			B.onWall(m, w, side, z, 4.25, Vector2.new(4, 8.5), 0.3, "FakeDoor", { Color = rgb(90, 55, 40), Material = M.Wood })
			local plate = B.onWall(m, w, side, z, 6.8, Vector2.new(1.2, 0.5), 0.4, "Plate",
				{ Color = rgb(200, 170, 90), Material = M.Metal }) :: Part
			B.label(plate, "237", if side == -1 then Enum.NormalId.Right else Enum.NormalId.Left, rgb(40, 30, 20), Enum.Font.Garamond)
		end
	end
	for z = -12, -48, -12 do
		for _, side in { -1, 1 } do
			B.bulb(m, Vector3.new(side * (w / 2 - 0.6), 6.5, z), pal.light, 14, 1, 0.8)
		end
	end
	for z = -8, -56, -16 do
		B.bulb(m, Vector3.new(0, h - 0.6, z), pal.light, 18, 1.2, 1)
	end
	return m
end

-- Clinic waiting room. Rows of chairs facing nothing.
local function waitingRoom(): Model
	local m = B.newRoom("WaitingRoom", { Weight = 2 })
	local w, L, h, pal = 28, 32, 10, PAL.clinic
	B.shell(m, w, L, h, pal)
	B.baseboards(m, w, L, pal.trim)
	local counter = part(m, "Counter", Vector3.new(8, 3.5, 2), CFrame.new(-8, 1.75, -26), { Color = rgb(170, 160, 140), Material = M.Wood }) :: Part
	B.label(counter, "PLEASE WAIT", Enum.NormalId.Back, rgb(60, 60, 60))
	for _, z in { -8, -14, -20 } do
		for _, x in { 3, 5.5, 8, 10.5 } do
			chair(m, CFrame.new(x, 0, z), rgb(80, 120, 120))
			chair(m, CFrame.new(-x, 0, z), rgb(80, 120, 120))
		end
	end
	-- Clock on the right wall, stopped.
	part(m, "Clock", Vector3.new(0.3, 2, 2), CFrame.new(w / 2 - 0.15, 7.5, -16), { Shape = Enum.PartType.Cylinder, Color = rgb(240, 240, 235) })
	part(m, "Hand", Vector3.new(0.05, 0.8, 0.08), CFrame.new(w / 2 - 0.325, 7.85, -16), { Color = rgb(20, 20, 20), CanCollide = false })
	part(m, "Hand", Vector3.new(0.05, 0.08, 0.6), CFrame.new(w / 2 - 0.325, 7.5, -15.75), { Color = rgb(20, 20, 20), CanCollide = false })
	part(m, "Pot", Vector3.new(1.6, 1.6, 1.6), CFrame.new(-w / 2 + 1, 0.8, -2), { Color = rgb(150, 90, 60), Material = M.Concrete })
	part(m, "Plant", Vector3.new(3, 3, 3), CFrame.new(-w / 2 + 1.6, 3, -2.2), { Shape = Enum.PartType.Ball, Color = rgb(70, 120, 60), Material = M.Grass })
	B.panelGrid(m, w, L, h, 3, 3, pal.light)
	return m
end

-- Underground parking. Sodium lights, one abandoned car.
local function garage(): Model
	local m = B.newRoom("ParkingGarage", { Weight = 1, MinRoom = 15 })
	local w, L, h, pal = 44, 52, 11, PAL.concrete
	B.shell(m, w, L, h, pal)
	for _, x in { -11, 11 } do
		for _, z in { -13, -26, -39 } do
			part(m, "Pillar", Vector3.new(2, h, 2), CFrame.new(x, h / 2, z), { Color = pal.wall, Material = pal.wallMat })
		end
	end
	local paint = { Color = rgb(225, 225, 215), CanCollide = false }
	for z = -4, -46, -6 do
		for _, sx in { -1, 1 } do
			part(m, "Line", Vector3.new(9, 0.05, 0.3), CFrame.new(sx * 17, 0.025, z), paint)
		end
	end
	for z = -3, -49, -6 do
		part(m, "Line", Vector3.new(0.3, 0.05, 3), CFrame.new(0, 0.025, z), { Color = pal.trim, CanCollide = false })
	end
	part(m, "Car", Vector3.new(5, 2, 10), CFrame.new(17, 1.4, -30), { Color = rgb(90, 30, 30), Material = M.Metal })
	part(m, "Car", Vector3.new(4.4, 1.6, 5), CFrame.new(17, 3.2, -30.5), { Color = rgb(20, 25, 30), Material = M.Glass })
	for _, dx in { -2.4, 2.4 } do
		for _, dz in { -3.5, 3.5 } do
			part(m, "Wheel", Vector3.new(0.8, 1.2, 1.2), CFrame.new(17 + dx, 0.6, -30 + dz), { Shape = Enum.PartType.Cylinder, Color = rgb(25, 25, 25) })
		end
	end
	B.panelGrid(m, w, L, h, 3, 4, pal.light, 1.4, 20)
	return m
end

-- School hallway, lockers, a bulletin board with one notice.
local function school(): Model
	local m = B.newRoom("SchoolHallway", { Weight = 2, MinRoom = 3 })
	local w, L, h, pal = 14, 56, 11, PAL.school
	B.shell(m, w, L, h, pal)
	local function lockerRun(side: number, from: number, count: number)
		for i = 0, count - 1 do
			local color = if i % 2 == 0 then rgb(60, 90, 140) else rgb(55, 84, 132)
			part(m, "Locker", Vector3.new(1.5, 7, 2), CFrame.new(side * (w / 2 - 0.75), 3.5, from - i * 2), { Color = color, Material = M.Metal })
		end
	end
	for _, side in { -1, 1 } do
		lockerRun(side, -5, 8)
		lockerRun(side, -31, 10)
	end
	local board = B.onWall(m, w, -1, -25, 5.5, Vector2.new(6, 3.5), 0.2, "Board", { Color = rgb(170, 130, 90), Material = M.Cardboard }) :: Part
	B.label(board, "STAY WITH YOUR GROUP", Enum.NormalId.Right, rgb(30, 30, 30), Enum.Font.Cartoon)
	B.panelGrid(m, w, L, h, 1, 7, pal.light)
	return m
end

-- Public restroom: stalls, sinks, a long mirror.
local function restroom(): Model
	local m = B.newRoom("Restroom", { Weight = 1, MinRoom = 6 })
	local w, L, h, pal = 24, 28, 10, PAL.restroom
	B.shell(m, w, L, h, pal)
	local stall = { Color = rgb(120, 150, 150) }
	for _, z in { -3, -7, -11, -15, -19 } do
		part(m, "Partition", Vector3.new(5, 7, 0.3), CFrame.new(-9.5, 4, z), stall)
	end
	for _, z in { -5, -9, -13, -17 } do
		part(m, "StallDoor", Vector3.new(0.3, 6.5, 3.4), CFrame.new(-6.85, 3.75, z), stall)
		part(m, "Toilet", Vector3.new(1.6, 1.6, 2), CFrame.new(-11, 0.8, z), { Color = rgb(240, 240, 240) })
	end
	part(m, "Counter", Vector3.new(2.4, 3, 12), CFrame.new(w / 2 - 1.2, 1.5, -10), { Color = rgb(200, 200, 195), Material = M.Marble })
	for _, z in { -6, -10, -14 } do
		part(m, "Sink", Vector3.new(1.6, 0.3, 1.6), CFrame.new(w / 2 - 1.4, 3.15, z), { Color = rgb(245, 245, 245) })
	end
	B.onWall(m, w, 1, -10, 6, Vector2.new(12, 3.5), 0.1, "Mirror", { Color = rgb(200, 205, 210), Material = M.Glass, Reflectance = 0.5 })
	B.panelGrid(m, w, L, h, 2, 3, pal.light)
	return m
end

-- A children's play room, too clean and too quiet.
local function playroom(): Model
	local m = B.newRoom("Playroom", { Weight = 1, MinRoom = 25 })
	local w, L, h, pal = 32, 36, 12, PAL.play
	B.shell(m, w, L, h, pal)
	local rim = { Color = pal.trim }
	for _, x in { 4.3, 13.7 } do
		part(m, "PitRim", Vector3.new(0.6, 1.5, 12), CFrame.new(x, 0.75, -12), rim)
	end
	for _, z in { -6.3, -17.7 } do
		part(m, "PitRim", Vector3.new(8.8, 1.5, 0.6), CFrame.new(9, 0.75, z), rim)
	end
	local rand = Random.new(11)
	local colors = { rgb(230, 70, 70), rgb(70, 140, 230), rgb(250, 210, 60), rgb(80, 190, 110) }
	for _ = 1, 60 do
		part(m, "Ball", Vector3.new(1, 1, 1),
			CFrame.new(rand:NextNumber(5.2, 12.8), rand:NextNumber(0.5, 1.2), rand:NextNumber(-16.8, -7.2)),
			{ Shape = Enum.PartType.Ball, Color = colors[rand:NextInteger(1, #colors)], CanCollide = false, CastShadow = false })
	end
	part(m, "Table", Vector3.new(4, 0.3, 4), CFrame.new(-8, 2.15, -12), { Color = rgb(250, 250, 250) })
	part(m, "TableLeg", Vector3.new(0.6, 2, 0.6), CFrame.new(-8, 1, -12), { Color = rgb(250, 250, 250) })
	for _, o in { Vector3.new(3, 0, 0), Vector3.new(-3, 0, 0), Vector3.new(0, 0, 3), Vector3.new(0, 0, -3) } do
		part(m, "Stool", Vector3.new(1.2, 1.2, 1.2), CFrame.new(-8 + o.X, 0.6, -12 + o.Z), { Color = colors[1 + (math.abs(o.X + o.Z) % 4)] })
	end
	for _, b in { { -13, 1, -30 }, { -11, 1, -30 }, { -13, 3, -30 } } do
		part(m, "Block", Vector3.new(2, 2, 2), CFrame.new(b[1], b[2], b[3]), { Color = rgb(170, 140, 230), Material = M.Fabric })
	end
	local paper = B.onWall(m, w, 1, -24, 5, Vector2.new(4, 3), 0.1, "Drawing", { Color = rgb(250, 250, 245) }) :: Part
	B.label(paper, "DON'T LOOK BACK", Enum.NormalId.Left, rgb(200, 40, 40), Enum.Font.Cartoon)
	B.panelGrid(m, w, L, h, 3, 3, pal.light)
	return m
end

-- Concrete stairwell climbing to a door one floor up.
local function stairwell(): Model
	local m = B.newRoom("Stairwell", { Weight = 1, MinRoom = 3 })
	local w, L, rise, pal = 14, 40, 10, PAL.concrete
	local h = rise + 12
	B.shell(m, w, L, h, pal, { exitY = rise })
	local steps, run = 20, 22 / 20
	for i = 1, steps do
		local y = i * (rise / steps)
		part(m, "Step", Vector3.new(w, y, run), CFrame.new(0, y / 2, -8 - (i - 0.5) * run), { Color = pal.floor, Material = pal.floorMat })
	end
	part(m, "Landing", Vector3.new(w, rise, 10), CFrame.new(0, rise / 2, -35), { Color = pal.floor, Material = pal.floorMat })
	local length = math.sqrt(22 ^ 2 + rise ^ 2)
	for _, sx in { -1, 1 } do
		part(m, "Rail", Vector3.new(0.3, 0.3, length),
			CFrame.new(sx * (w / 2 - 0.25), 3 + rise / 2, -19) * CFrame.Angles(math.atan2(rise, 22), 0, 0),
			{ Color = pal.trim, Material = M.Metal, CanCollide = false })
	end
	local sign = B.onWall(m, w, -1, -35, rise + 5, Vector2.new(3, 1.5), 0.1, "Sign", { Color = rgb(230, 230, 225) }) :: Part
	B.label(sign, "FLOOR ??", Enum.NormalId.Right, rgb(20, 20, 20))
	for _, z in { -4, -14, -24, -35 } do
		B.panel(m, 0, h, z, rgb(240, 245, 255), 1.6, 28)
	end
	return m
end

-- Dim archive of shelves and boxes nobody will open again.
local function archive(): Model
	local m = B.newRoom("Archive", { Weight = 2, MinRoom = 5 })
	local w, L, h, pal = 30, 48, 14, PAL.archive
	B.shell(m, w, L, h, pal)
	for _, x in { -11, -5, 5, 11 } do
		for _, z in { -8, -22, -36 } do
			part(m, "Shelf", Vector3.new(2, 10, 10), CFrame.new(x, 5, z), { Color = pal.trim, Material = M.Wood })
		end
	end
	for _, b in { { 8, -15 }, { -8, -29 }, { 8.4, -40 } } do
		part(m, "Box", Vector3.new(2, 1.5, 2), CFrame.new(b[1], 0.75, b[2]), { Color = rgb(170, 140, 100), Material = M.Cardboard })
	end
	for _, z in { -6, -18, -30, -42 } do
		for _, x in { -8, 0, 8 } do
			B.panel(m, x, h, z, pal.light, 1.3, 20)
		end
	end
	return m
end

-- Dead mall atrium. Every store is closed.
local function mall(): Model
	local m = B.newRoom("DeadMall", { Weight = 1, MinRoom = 20 })
	local w, L, h, pal = 48, 60, 22, PAL.mall
	B.shell(m, w, L, h, pal)
	local names = { "ELSEWHERE", "MEMORIES", "AFTER", "NOWHERE", "STILL", "RETURN" }
	local i = 0
	for _, side in { -1, 1 } do
		for _, z in { -10, -30, -50 } do
			i += 1
			B.onWall(m, w, side, z, 5.5, Vector2.new(14, 9), 0.4, "Storefront",
				{ Color = rgb(20, 22, 26), Material = M.Glass, Reflectance = 0.3 })
			local band = B.onWall(m, w, side, z, 12, Vector2.new(14, 2), 0.6, "StoreSign", { Color = rgb(70, 70, 75) }) :: Part
			B.label(band, names[i], if side == -1 then Enum.NormalId.Right else Enum.NormalId.Left, rgb(230, 230, 230))
		end
	end
	for _, z in { -20, -40 } do
		part(m, "Planter", Vector3.new(6, 2, 6), CFrame.new(0, 1, z), { Color = rgb(170, 160, 145), Material = M.Concrete })
		part(m, "Tree", Vector3.new(5, 5, 5), CFrame.new(0, 4.3, z), { Shape = Enum.PartType.Ball, Color = rgb(60, 110, 60), Material = M.Grass })
	end
	for _, x in { -6, 6 } do
		part(m, "Bench", Vector3.new(6, 1.5, 2), CFrame.new(x, 0.75, -30), { Color = rgb(120, 90, 60), Material = M.Wood })
	end
	for _, x in { -12, 12 } do
		for _, z in { -10, -30, -50 } do
			B.panel(m, x, h, z, pal.light, 2, 34, Vector3.new(12, 0.3, 8))
		end
	end
	return m
end

-- Dark ring of stones around a glowing core. Something is wrong here.
local function observatory(): Model
	local m = B.newRoom("Observatory", { Weight = 1, MinRoom = 30 })
	local w, L, h, pal = 36, 36, 22, PAL.cosmic
	B.shell(m, w, L, h, pal)
	part(m, "Pedestal", Vector3.new(6, 3, 6), CFrame.new(0, 1.5, -18), { Color = pal.trim, Material = M.Slate })
	local core = part(m, "Core", Vector3.new(5, 5, 5), CFrame.new(0, 6, -18),
		{ Shape = Enum.PartType.Ball, Material = M.Neon, Color = COSMIC, CanCollide = false })
	glowing(core, COSMIC, 32, 2)
	for k = 0, 7 do
		part(m, "Stone", Vector3.new(2, 1.5, 3),
			CFrame.new(0, 0, -18) * CFrame.Angles(0, k * math.pi / 4, 0) * CFrame.new(0, 0.75, 11),
			{ Color = rgb(60, 58, 70), Material = M.Slate })
	end
	local rand = Random.new(3)
	for _ = 1, 30 do
		part(m, "Star", Vector3.new(0.3, 0.1, 0.3),
			CFrame.new(rand:NextNumber(-17, 17), h - 0.05, rand:NextNumber(-35, -1)),
			{ Material = M.Neon, Color = rgb(230, 230, 255), CanCollide = false, CastShadow = false })
	end
	for _, x in { -10, 10 } do
		for _, z in { -8, -28 } do
			B.panel(m, x, h, z, pal.light, 1.2, 26)
		end
	end
	return m
end

---------------------------------------------------------------- special rooms

local function start(): Model
	local m = B.newRoom("Start")
	local w, L, h, pal = 24, 32, 10, PAL.office
	B.shell(m, w, L, h, pal, { entrance = false })
	B.baseboards(m, w, L, pal.trim)
	local sign = part(m, "Sign", Vector3.new(10, 2, 0.2), CFrame.new(0, 7, -0.1), { Color = rgb(40, 40, 46) }) :: Part
	B.label(sign, "TOTALITY RESEARCH DIVISION", Enum.NormalId.Front, rgb(220, 220, 230))
	local sub = part(m, "Sign", Vector3.new(6, 0.8, 0.2), CFrame.new(0, 5.2, -0.1), { Color = rgb(40, 40, 46) }) :: Part
	B.label(sub, "RECOVER ALL FINDINGS", Enum.NormalId.Front, rgb(180, 180, 190))
	part(m, "Bench", Vector3.new(8, 1.5, 2), CFrame.new(-7, 0.75, -4), { Color = rgb(120, 90, 60), Material = M.Wood })
	B.marker(m, "PlayerSpawn", CFrame.new(0, 3, -8))
	B.panelGrid(m, w, L, h, 2, 4, pal.light)
	return m
end

local function final(): Model
	local m = B.newRoom("Final")
	local w, L, h, pal = 48, 60, 30, PAL.cosmic
	B.shell(m, w, L, h, pal, { exit = "none" })
	local rift = part(m, "Rift", Vector3.new(14, 20, 0.6), CFrame.new(0, 12, -L + 3),
		{ Material = M.Neon, Color = COSMIC, CanCollide = false })
	glowing(rift, COSMIC, 50, 3)
	for _, x in { -14, 14 } do
		for _, z in { -12, -30 } do
			part(m, "Monolith", Vector3.new(3, 14, 3), CFrame.new(x, 7, z), { Color = rgb(20, 18, 28), Material = M.Basalt })
		end
	end
	for _, x in { -15, 15 } do
		for _, z in { -10, -30, -50 } do
			B.panel(m, x, h, z, pal.light, 1.4, 34)
		end
	end
	return m
end

function RoomPresets.BuildNormal(): { Model }
	return {
		hallway(), turn(1), turn(-1), office(), backrooms(), poolRooms(), hotel(), waitingRoom(),
		garage(), school(), restroom(), playroom(), stairwell(), archive(), mall(), observatory(),
	}
end

function RoomPresets.BuildSpecial(): { [string]: Model }
	return { Start = start(), Final = final() }
end

return RoomPresets
