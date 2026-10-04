--[[
	Built-in room presets for the S.S. Totality, a Solstice Solutions vessel
	built to study the Sun, now abandoned in orbit above Earth after it was
	ransacked and attacked. (Damage is added per room by Decay.luau.) Used whenever ServerStorage.Rooms
	doesn't have presets made in Studio.

	Style: liminal spaceship. Ordinary, empty crew spaces that feel slightly
	wrong: repeated details, corporate signage, dim lights that still hum, and
	windows out into space.

	Attributes: Weight, MinRoom, MaxRoom, Turn (1 = exit on the left, -1 = right).
]]

local B = require(script.Parent.RoomBuilder)
local part = B.part

local RoomPresets = {}

local function rgb(r: number, g: number, b: number)
	return Color3.fromRGB(r, g, b)
end

local M = Enum.Material

local function pal(wall, wallMat, floor, floorMat, ceiling, ceilingMat, trim, light)
	return { wall = wall, wallMat = wallMat, floor = floor, floorMat = floorMat,
		ceiling = ceiling, ceilingMat = ceilingMat, trim = trim, light = light }
end

local PAL = {
	hull = pal(rgb(118, 122, 130), M.Metal, rgb(62, 64, 70), M.DiamondPlate, rgb(84, 87, 94), M.Metal, rgb(70, 74, 82), rgb(200, 215, 235)),
	office = pal(rgb(168, 170, 172), M.SmoothPlastic, rgb(70, 76, 88), M.Carpet, rgb(150, 152, 156), M.SmoothPlastic, rgb(80, 84, 92), rgb(220, 225, 230)),
	overflow = pal(rgb(170, 155, 95), M.Plaster, rgb(120, 105, 65), M.Carpet, rgb(160, 150, 115), M.SmoothPlastic, rgb(100, 85, 50), rgb(240, 220, 160)),
	pool = pal(rgb(150, 170, 175), M.CeramicTiles, rgb(140, 160, 165), M.CeramicTiles, rgb(120, 135, 140), M.CeramicTiles, rgb(80, 110, 120), rgb(180, 215, 235)),
	quarters = pal(rgb(120, 100, 85), M.Plaster, rgb(80, 28, 32), M.Carpet, rgb(100, 92, 85), M.SmoothPlastic, rgb(60, 45, 35), rgb(255, 200, 140)),
	med = pal(rgb(150, 175, 165), M.SmoothPlastic, rgb(150, 155, 152), M.SmoothPlastic, rgb(160, 165, 162), M.SmoothPlastic, rgb(80, 100, 95), rgb(210, 240, 235)),
	hangar = pal(rgb(95, 97, 100), M.Metal, rgb(75, 75, 78), M.Concrete, rgb(70, 72, 76), M.Metal, rgb(200, 160, 40), rgb(255, 170, 90)),
	lab = pal(rgb(180, 185, 188), M.SmoothPlastic, rgb(120, 125, 130), M.SmoothPlastic, rgb(165, 168, 170), M.SmoothPlastic, rgb(80, 90, 100), rgb(225, 235, 245)),
	hygiene = pal(rgb(130, 165, 160), M.CeramicTiles, rgb(160, 162, 160), M.CeramicTiles, rgb(150, 152, 150), M.SmoothPlastic, rgb(90, 120, 120), rgb(210, 235, 240)),
	promenade = pal(rgb(165, 162, 155), M.Plaster, rgb(150, 146, 140), M.Marble, rgb(130, 128, 124), M.SmoothPlastic, rgb(110, 105, 95), rgb(215, 225, 240)),
	archive = pal(rgb(70, 72, 80), M.Metal, rgb(50, 52, 58), M.DiamondPlate, rgb(60, 62, 68), M.Metal, rgb(40, 42, 48), rgb(190, 205, 230)),
	cryo = pal(rgb(90, 105, 120), M.Metal, rgb(55, 62, 72), M.DiamondPlate, rgb(70, 80, 92), M.Metal, rgb(60, 70, 85), rgb(150, 200, 255)),
	mess = pal(rgb(150, 150, 145), M.SmoothPlastic, rgb(110, 112, 110), M.CeramicTiles, rgb(135, 135, 132), M.SmoothPlastic, rgb(90, 95, 100), rgb(230, 230, 215)),
	hydro = pal(rgb(100, 115, 105), M.Metal, rgb(60, 65, 62), M.DiamondPlate, rgb(80, 88, 84), M.Metal, rgb(70, 80, 74), rgb(200, 140, 255)),
	engine = pal(rgb(85, 80, 78), M.Metal, rgb(55, 52, 50), M.DiamondPlate, rgb(65, 62, 60), M.Metal, rgb(200, 120, 40), rgb(255, 190, 140)),
	cosmic = pal(rgb(40, 38, 52), M.Slate, rgb(30, 28, 40), M.Slate, rgb(25, 24, 35), M.Slate, rgb(90, 70, 150), rgb(180, 160, 255)),
}

local COSMIC = rgb(150, 110, 255)
local SIGN_BG = rgb(30, 32, 38)
local SIGN_TEXT = rgb(210, 215, 225)

-- Simple chair; faces -Z of `cf` (backrest on the +Z side).
local function chair(m: Model, cf: CFrame, color: Color3)
	part(m, "Chair", Vector3.new(1.4, 1.6, 1.4), cf * CFrame.new(0, 0.8, 0), { Color = rgb(60, 60, 64) })
	part(m, "Chair", Vector3.new(2, 0.4, 2), cf * CFrame.new(0, 1.8, 0), { Color = color, Material = M.Fabric })
	part(m, "Chair", Vector3.new(2, 2.2, 0.3), cf * CFrame.new(0, 3.1, 0.85), { Color = color, Material = M.Fabric })
end

local function glowing(p: Part?, color: Color3, range: number, brightness: number)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = range
	light.Brightness = brightness
	light.Shadows = true
	light.Parent = p
end

-- Sign on a side wall (side -1 = left, 1 = right).
local function wallSign(m: Model, w: number, side: number, z: number, y: number, size: Vector2, text: string,
	bg: Color3?, fg: Color3?, font: Enum.Font?)
	local sign = B.onWall(m, w, side, z, y, size, 0.15, "Sign", { Color = bg or SIGN_BG }) :: Part
	B.label(sign, text, if side == -1 then Enum.NormalId.Right else Enum.NormalId.Left, fg or SIGN_TEXT, font)
	return sign
end

-- Sign on the front (z = -L) or back (z = 0) wall, readable from inside the room.
local function endSign(m: Model, z: number, facing: number, x: number, y: number, size: Vector2, text: string,
	bg: Color3?, fg: Color3?)
	local sign = part(m, "Sign", Vector3.new(size.X, size.Y, 0.15), CFrame.new(x, y, z + facing * 0.075), { Color = bg or SIGN_BG }) :: Part
	B.label(sign, text, if facing == 1 then Enum.NormalId.Back else Enum.NormalId.Front, fg or SIGN_TEXT)
	return sign
end

-- Pipe running along the room's length near the ceiling.
local function pipe(m: Model, x: number, y: number, L: number, color: Color3?)
	part(m, "Pipe", Vector3.new(L, 0.8, 0.8), CFrame.new(x, y, -L / 2) * CFrame.Angles(0, math.pi / 2, 0),
		{ Shape = Enum.PartType.Cylinder, Color = color or rgb(90, 94, 100), Material = M.Metal })
end

---------------------------------------------------------------- corridors

-- Main ship corridor: ribbed walls, sealed hatches, a few windows.
local function corridor(): Model
	local m = B.newRoom("Corridor", { Weight = 3 })
	local w, L, h, p = 12, 48, 10, PAL.hull
	B.shell(m, w, L, h, p, {
		windows = {
			{ side = "right", z = -16, y = 3.5, w = 6, h = 3 },
			{ side = "right", z = -32, y = 3.5, w = 6, h = 3 },
		},
	})
	for _, z in { -8, -24, -40 } do
		for _, sx in { -1, 1 } do
			part(m, "Rib", Vector3.new(0.4, h, 1), CFrame.new(sx * (w / 2 - 0.2), h / 2, z), { Color = p.trim, Material = M.Metal })
		end
	end
	for _, z in { -16, -32 } do
		B.onWall(m, w, -1, z, 4.25, Vector2.new(4, 8.5), 0.3, "Hatch", { Color = rgb(80, 84, 92), Material = M.DiamondPlate })
		wallSign(m, w, -1, z, 9.2, Vector2.new(2.4, 0.6), "SEALED", rgb(120, 30, 30), rgb(240, 220, 220))
	end
	pipe(m, -(w / 2 - 0.5), h - 0.6, L)
	part(m, "Grate", Vector3.new(2, 0.04, L), CFrame.new(0, 0.02, -L / 2), { Color = rgb(45, 46, 50), Material = M.DiamondPlate, CanCollide = false })
	B.panelGrid(m, w, L, h, 1, 6, p.light, 0.7)
	return m
end

-- Corridor corner: turns left (1) or right (-1).
local function bend(direction: number): Model
	local m = B.newRoom(if direction == 1 then "BendLeft" else "BendRight", { Weight = 2, Turn = direction, Group = "Bend" })
	local w, L, h, p = 14, 14, 10, PAL.hull
	B.shell(m, w, L, h, p, { exit = if direction == 1 then "left" else "right" })
	endSign(m, -L, 1, 0, 6, Vector2.new(5, 1.2), if direction == 1 then "<  CONTINUE" else "CONTINUE  >")
	part(m, "Pipe", Vector3.new(w, 0.8, 0.8), CFrame.new(0, h - 0.6, -L + 0.5), { Shape = Enum.PartType.Cylinder, Color = rgb(90, 94, 100), Material = M.Metal })
	part(m, "Hazard", Vector3.new(w, 0.05, 1), CFrame.new(0, 0.025, -L + 0.5), { Color = p.trim, CanCollide = false })
	B.panel(m, 0, h, -L / 2, p.light, 0.8, 18)
	return m
end

-- Concrete-and-steel stairwell climbing to a door one deck up.
local function stairwell(): Model
	local m = B.newRoom("DeckStairwell", { Weight = 1, MinRoom = 3 })
	local w, L, rise, p = 14, 40, 10, PAL.hull
	local h = rise + 12
	B.shell(m, w, L, h, p, { exitY = rise })
	local steps, run = 20, 22 / 20
	for i = 1, steps do
		local y = i * (rise / steps)
		part(m, "Step", Vector3.new(w, y, run), CFrame.new(0, y / 2, -8 - (i - 0.5) * run), { Color = p.floor, Material = p.floorMat })
	end
	part(m, "Landing", Vector3.new(w, rise, 10), CFrame.new(0, rise / 2, -35), { Color = p.floor, Material = p.floorMat })
	local length = math.sqrt(22 ^ 2 + rise ^ 2)
	for _, sx in { -1, 1 } do
		part(m, "Rail", Vector3.new(0.3, 0.3, length),
			CFrame.new(sx * (w / 2 - 0.25), 3 + rise / 2, -19) * CFrame.Angles(math.atan2(rise, 22), 0, 0),
			{ Color = rgb(200, 160, 40), Material = M.Metal, CanCollide = false })
	end
	wallSign(m, w, -1, -35, rise + 5, Vector2.new(3, 1.5), "DECK ??", rgb(200, 200, 195), rgb(20, 20, 20))
	for _, z in { -4, -14, -24, -35 } do
		B.panel(m, 0, h, z, p.light, 0.9, 26)
	end
	return m
end

---------------------------------------------------------------- crew areas

-- Research office: empty cubicles, monitors still on.
local function office(): Model
	local m = B.newRoom("ResearchOffice", { Weight = 2 })
	local w, L, h, p = 36, 40, 10, PAL.office
	B.shell(m, w, L, h, p)
	local partition = { Color = rgb(120, 122, 132), Material = M.Fabric }
	for _, cx in { -12, 12 } do
		local s = math.sign(cx)
		for _, cz in { -10, -26 } do
			part(m, "Partition", Vector3.new(0.4, 5, 10), CFrame.new(cx + s * 4.8, 2.5, cz), partition)
			for _, dz in { -4.8, 4.8 } do
				part(m, "Partition", Vector3.new(9.6, 5, 0.4), CFrame.new(cx - s * 0.2, 2.5, cz + dz), partition)
			end
			part(m, "Desk", Vector3.new(3, 0.3, 6), CFrame.new(cx + s * 3.1, 2.85, cz), { Color = rgb(140, 142, 148), Material = M.Metal })
			for _, dz in { -2.7, 2.7 } do
				part(m, "DeskLeg", Vector3.new(2.6, 2.7, 0.3), CFrame.new(cx + s * 3.1, 1.35, cz + dz), { Color = rgb(70, 72, 78) })
			end
			part(m, "Monitor", Vector3.new(0.3, 1.6, 2.4), CFrame.new(cx + s * 4, 3.8, cz), { Color = rgb(30, 30, 34) })
			part(m, "Screen", Vector3.new(0.05, 1.3, 2.1), CFrame.new(cx + s * 3.825, 3.8, cz),
				{ Material = M.Neon, Color = rgb(30, 60, 90), CanCollide = false })
			chair(m, CFrame.new(cx, 0, cz) * CFrame.Angles(0, math.rad(-s * 90), 0), rgb(50, 55, 70))
		end
	end
	wallSign(m, w, -1, -18, 7.2, Vector2.new(6, 2.2), "SOLSTICE SOLUTIONS\nCLOSER TO THE SUN", rgb(225, 140, 50), rgb(30, 25, 20))
	B.panelGrid(m, w, L, h, 3, 4, p.light, 0.7)
	return m
end

-- Mess hall: long tables, trays left mid-meal, windows to space.
local function messHall(): Model
	local m = B.newRoom("MessHall", { Weight = 2, MinRoom = 2 })
	local w, L, h, p = 30, 40, 10, PAL.mess
	B.shell(m, w, L, h, p, {
		windows = {
			{ side = "right", z = -12, y = 3, w = 8, h = 3.5 },
			{ side = "right", z = -28, y = 3, w = 8, h = 3.5 },
		},
	})
	for _, x in { -8, 8 } do
		part(m, "Table", Vector3.new(3, 0.3, 24), CFrame.new(x, 2.85, -20), { Color = rgb(170, 172, 175), Material = M.Metal })
		for _, z in { -9, -31 } do
			part(m, "TableLeg", Vector3.new(2.6, 2.7, 0.4), CFrame.new(x, 1.35, z), { Color = rgb(80, 82, 88) })
		end
		for _, dx in { -2.1, 2.1 } do
			part(m, "Bench", Vector3.new(1.2, 1.6, 24), CFrame.new(x + dx, 0.8, -20), { Color = rgb(70, 90, 120), Material = M.Fabric })
		end
		for _, z in { -12, -19, -27 } do
			part(m, "Tray", Vector3.new(1.2, 0.1, 0.8), CFrame.new(x + 0.6, 3.05, z), { Color = rgb(200, 200, 195) })
		end
	end
	part(m, "Counter", Vector3.new(8, 3.5, 2), CFrame.new(-10, 1.75, -37), { Color = rgb(160, 162, 165), Material = M.Metal })
	wallSign(m, w, -1, -20, 7, Vector2.new(8, 2.5), "TODAY:  ---", rgb(25, 28, 30), rgb(120, 220, 140), Enum.Font.Code)
	B.panelGrid(m, w, L, h, 2, 4, p.light, 0.7)
	return m
end

-- Crew quarters corridor. Every cabin is 237.
local function quarters(): Model
	local m = B.newRoom("CrewQuarters", { Weight = 2, MinRoom = 4 })
	local w, L, h, p = 10, 64, 10, PAL.quarters
	B.shell(m, w, L, h, p)
	B.baseboards(m, w, L, p.trim)
	for i = 0, 4 do
		local z = -6 - i * 12
		for _, side in { -1, 1 } do
			B.onWall(m, w, side, z, 4.25, Vector2.new(4, 8.5), 0.3, "CabinDoor", { Color = rgb(85, 60, 48), Material = M.Wood })
			local plate = B.onWall(m, w, side, z, 6.8, Vector2.new(1.2, 0.5), 0.4, "Plate",
				{ Color = rgb(170, 145, 80), Material = M.Metal }) :: Part
			B.label(plate, "237", if side == -1 then Enum.NormalId.Right else Enum.NormalId.Left, rgb(40, 30, 20), Enum.Font.Garamond)
		end
	end
	for z = -12, -48, -12 do
		for _, side in { -1, 1 } do
			B.bulb(m, Vector3.new(side * (w / 2 - 0.6), 6.5, z), p.light, 12, 0.6, 0.8)
		end
	end
	for z = -8, -56, -16 do
		B.bulb(m, Vector3.new(0, h - 0.6, z), p.light, 16, 0.7, 1)
	end
	return m
end

-- Medical bay waiting area.
local function medBay(): Model
	local m = B.newRoom("MedBay", { Weight = 2 })
	local w, L, h, p = 28, 32, 10, PAL.med
	B.shell(m, w, L, h, p)
	B.baseboards(m, w, L, p.trim)
	local counter = part(m, "Counter", Vector3.new(8, 3.5, 2), CFrame.new(-8, 1.75, -26), { Color = rgb(170, 175, 172), Material = M.SmoothPlastic }) :: Part
	B.label(counter, "SOLSTICE MEDICAL - PLEASE WAIT", Enum.NormalId.Back, rgb(50, 70, 65))
	for _, z in { -8, -14, -20 } do
		for _, x in { 3, 5.5, 8, 10.5 } do
			chair(m, CFrame.new(x, 0, z), rgb(80, 120, 120))
		end
	end
	-- Gurney, left where it was abandoned.
	part(m, "Gurney", Vector3.new(3, 0.4, 7), CFrame.new(-8, 2.6, -12), { Color = rgb(225, 228, 225), Material = M.Fabric })
	for _, dz in { -3, 3 } do
		part(m, "GurneyLeg", Vector3.new(2.6, 2.4, 0.4), CFrame.new(-8, 1.2, -12 + dz), { Color = rgb(150, 152, 155), Material = M.Metal })
	end
	part(m, "Clock", Vector3.new(0.3, 2, 2), CFrame.new(w / 2 - 0.15, 7.5, -16), { Shape = Enum.PartType.Cylinder, Color = rgb(230, 230, 225) })
	part(m, "Hand", Vector3.new(0.05, 0.8, 0.08), CFrame.new(w / 2 - 0.325, 7.85, -16), { Color = rgb(20, 20, 20), CanCollide = false })
	part(m, "Hand", Vector3.new(0.05, 0.08, 0.6), CFrame.new(w / 2 - 0.325, 7.5, -15.75), { Color = rgb(20, 20, 20), CanCollide = false })
	B.panelGrid(m, w, L, h, 3, 3, p.light, 0.7)
	return m
end

-- Solar spectroscopy lab: benches of instruments and samples, notes left mid-sentence.
local function laboratory(): Model
	local m = B.newRoom("Laboratory", { Weight = 2, MinRoom = 3 })
	local w, L, h, p = 28, 40, 11, PAL.lab
	B.shell(m, w, L, h, p)
	for _, x in { -7, 7 } do
		part(m, "Bench", Vector3.new(4, 3, 22), CFrame.new(x, 1.5, -20), { Color = rgb(150, 155, 160), Material = M.Metal })
		part(m, "BenchTop", Vector3.new(4, 0.2, 22), CFrame.new(x, 3.1, -20), { Color = rgb(40, 42, 46), Material = M.Slate })
		for _, z in { -12, -18, -24, -28 } do
			-- Sample vials still glowing faintly orange.
			part(m, "Vial", Vector3.new(1, 0.6, 0.6), CFrame.new(x - 1, 3.7, z) * CFrame.Angles(0, 0, math.pi / 2),
				{ Shape = Enum.PartType.Cylinder, Material = M.Glass, Color = rgb(255, 160, 60), Transparency = 0.3 })
		end
		part(m, "Instrument", Vector3.new(1.6, 1.4, 2), CFrame.new(x + 0.8, 3.9, -15), { Color = rgb(60, 62, 68), Material = M.Metal })
		part(m, "Instrument", Vector3.new(1.6, 2, 1.6), CFrame.new(x + 0.8, 4.2, -26), { Color = rgb(200, 200, 195) })
	end
	wallSign(m, w, 1, -20, 6, Vector2.new(8, 3.5), "656.3 nm ... ?\nCORONAL OUTPUT x14\nTHIS IS NOT POSSIBLE", rgb(225, 228, 230), rgb(40, 50, 90), Enum.Font.Cartoon)
	wallSign(m, w, -1, -20, 8.5, Vector2.new(7, 1.2), "SOLAR SPECTROSCOPY LAB")
	B.panelGrid(m, w, L, h, 2, 4, p.light, 0.7)
	return m
end

local function hygiene(): Model
	local m = B.newRoom("HygieneStation", { Weight = 1, MinRoom = 6 })
	local w, L, h, p = 24, 28, 10, PAL.hygiene
	B.shell(m, w, L, h, p)
	local stall = { Color = rgb(100, 125, 125) }
	for _, z in { -3, -7, -11, -15, -19 } do
		part(m, "Partition", Vector3.new(5, 7, 0.3), CFrame.new(-9.5, 4, z), stall)
	end
	for _, z in { -5, -9, -13, -17 } do
		part(m, "StallDoor", Vector3.new(0.3, 6.5, 3.4), CFrame.new(-6.85, 3.75, z), stall)
		part(m, "Toilet", Vector3.new(1.6, 1.6, 2), CFrame.new(-11, 0.8, z), { Color = rgb(215, 215, 215) })
	end
	part(m, "Counter", Vector3.new(2.4, 3, 12), CFrame.new(w / 2 - 1.2, 1.5, -10), { Color = rgb(170, 170, 168), Material = M.Marble })
	for _, z in { -6, -10, -14 } do
		part(m, "Sink", Vector3.new(1.6, 0.3, 1.6), CFrame.new(w / 2 - 1.4, 3.15, z), { Color = rgb(220, 220, 220) })
	end
	B.onWall(m, w, 1, -10, 6, Vector2.new(12, 3.5), 0.1, "Mirror", { Color = rgb(170, 175, 180), Material = M.Glass, Reflectance = 0.4 })
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.6)
	return m
end

-- Overflow habitation deck. Nobody remembers what it was for.
local function overflow(): Model
	local m = B.newRoom("OverflowDeck", { Weight = 2, MinRoom = 8 })
	local w, L, h, p = 40, 48, 10, PAL.overflow
	B.shell(m, w, L, h, p)
	local stubs = {
		{ -12, -10, 12, 1 }, { 10, -14, 1, 12 }, { -8, -24, 1, 10 },
		{ 12, -30, 14, 1 }, { -11, -36, 1, 12 }, { 4, -40, 10, 1 },
	}
	for _, s in stubs do
		part(m, "Partition", Vector3.new(s[3], h, s[4]), CFrame.new(s[1], h / 2, s[2]), { Color = p.wall, Material = p.wallMat })
	end
	part(m, "Stain", Vector3.new(6, 0.05, 4), CFrame.new(6, 0.025, -22), { Color = rgb(90, 78, 45), Material = M.Carpet, CanCollide = false })
	B.panelGrid(m, w, L, h, 4, 5, p.light, 0.6)
	return m
end

-- Recreation pool with windows out into space.
local function pool(): Model
	local m = B.newRoom("RecreationPool", { Weight = 1, MinRoom = 12 })
	local w, L, h, p = 32, 44, 14, PAL.pool
	B.shell(m, w, L, h, p, {
		windows = {
			{ side = "right", z = -14, y = 3, w = 10, h = 5 },
			{ side = "right", z = -30, y = 3, w = 10, h = 5 },
		},
	})
	local tile = { Color = p.trim, Material = M.CeramicTiles }
	for _, sx in { -1, 1 } do
		part(m, "Rim", Vector3.new(1, 1.2, 24), CFrame.new(sx * 9.5, 0.6, -22), tile)
	end
	for _, z in { -10.5, -33.5 } do
		part(m, "Rim", Vector3.new(18, 1.2, 1), CFrame.new(0, 0.6, z), tile)
	end
	part(m, "Water", Vector3.new(18, 0.8, 22), CFrame.new(0, 0.4, -22), {
		Material = M.Glass, Color = rgb(60, 120, 145), Transparency = 0.35, CanCollide = false, CanQuery = false,
	})
	for _, z in { -16, -30 } do
		part(m, "Pillar", Vector3.new(2, h, 2), CFrame.new(-14, h / 2, z), { Color = p.wall, Material = p.wallMat })
	end
	B.panelGrid(m, w, L, h, 3, 4, p.light, 0.7, 20)
	return m
end

-- Shuttle hangar. One shuttle never left.
local function hangar(): Model
	local m = B.newRoom("ShuttleHangar", { Weight = 1, MinRoom = 15 })
	local w, L, h, p = 44, 52, 14, PAL.hangar
	B.shell(m, w, L, h, p)
	for _, x in { -11, 11 } do
		for _, z in { -13, -26, -39 } do
			part(m, "Pillar", Vector3.new(2, h, 2), CFrame.new(x, h / 2, z), { Color = p.wall, Material = p.wallMat })
		end
	end
	for z = -3, -49, -6 do
		part(m, "Line", Vector3.new(0.3, 0.05, 3), CFrame.new(0, 0.025, z), { Color = p.trim, CanCollide = false })
	end
	-- Shuttle
	local hull = { Color = rgb(190, 192, 195), Material = M.Metal }
	part(m, "Shuttle", Vector3.new(6, 4, 14), CFrame.new(17, 2.6, -28), hull)
	part(m, "Wing", Vector3.new(10, 0.4, 5), CFrame.new(17, 2.5, -24), hull)
	part(m, "Cockpit", Vector3.new(4, 1.6, 3), CFrame.new(17, 3, -36.5), { Color = rgb(20, 25, 35), Material = M.Glass })
	for _, o in { Vector3.new(-2, 0, -5), Vector3.new(2, 0, -5), Vector3.new(0, 0, 5) } do
		part(m, "Strut", Vector3.new(0.6, 0.6, 0.6), CFrame.new(17 + o.X, 0.3, -28 + o.Z), { Color = rgb(60, 60, 62) })
	end
	local bay = B.onWall(m, w, -1, -26, 5.5, Vector2.new(20, 10), 0.4, "BayDoor", { Color = rgb(70, 70, 72), Material = M.DiamondPlate }) :: Part
	B.label(bay, "BAY DOOR - DO NOT OPEN", Enum.NormalId.Right, rgb(220, 180, 50))
	B.panelGrid(m, w, L, h, 3, 4, p.light, 0.8, 22)
	return m
end

-- Solar monitoring control room. The big screen still shows the Sun.
local function solarControl(): Model
	local m = B.newRoom("SolarControl", { Weight = 1, MinRoom = 10 })
	local w, L, h, p = 32, 36, 12, PAL.office
	B.shell(m, w, L, h, p)
	B.onWall(m, w, -1, -18, 6.5, Vector2.new(16, 7), 0.2, "Screen", { Color = rgb(10, 10, 14) })
	local sun = part(m, "Sun", Vector3.new(0.1, 5, 5), CFrame.new(-w / 2 + 0.25, 7, -18),
		{ Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(255, 130, 40), CanCollide = false }) :: Part
	glowing(sun, rgb(255, 140, 60), 14, 0.8)
	wallSign(m, w, -1, -18, 2.2, Vector2.new(10, 1), "SOL ACTIVITY: ABNORMAL", rgb(60, 15, 10), rgb(255, 120, 80), Enum.Font.Code)
	-- Two rows of consoles facing the screen, chairs pushed back.
	for _, x in { -4, 4 } do
		part(m, "Console", Vector3.new(2, 3, 12), CFrame.new(x, 1.5, -18), { Color = rgb(55, 58, 64), Material = M.Metal })
		for _, z in { -14, -18, -22 } do
			part(m, "Display", Vector3.new(0.1, 1.4, 2.4), CFrame.new(x - 0.6, 3.7, z) * CFrame.Angles(0, 0, -0.3),
				{ Material = M.Neon, Color = rgb(70, 40, 25), CanCollide = false })
			chair(m, CFrame.new(x + 2.6, 0, z) * CFrame.Angles(0, math.rad(90), 0), rgb(60, 65, 80))
		end
	end
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.6)
	return m
end

---------------------------------------------------------------- big / late rooms

-- Data archive: rows of server racks, a few still blinking.
local function archive(): Model
	local m = B.newRoom("DataArchive", { Weight = 1, MinRoom = 5 })
	local w, L, h, p = 30, 48, 14, PAL.archive
	B.shell(m, w, L, h, p)
	local rand = Random.new(5)
	for _, x in { -11, -5, 5, 11 } do
		for _, z in { -8, -22, -36 } do
			part(m, "Rack", Vector3.new(2, 10, 10), CFrame.new(x, 5, z), { Color = rgb(35, 37, 42), Material = M.Metal })
			for _, face in { -1, 1 } do
				for _ = 1, 6 do
					local color = if rand:NextNumber() < 0.7 then rgb(60, 200, 110) else rgb(230, 160, 40)
					part(m, "Led", Vector3.new(0.05, 0.25, 0.25),
						CFrame.new(x + face * 1.025, rand:NextNumber(2, 9), z + rand:NextNumber(-4.5, 4.5)),
						{ Material = M.Neon, Color = color, CanCollide = false, CastShadow = false })
				end
			end
		end
	end
	for _, z in { -6, -18, -30, -42 } do
		for _, x in { -8, 0, 8 } do
			B.panel(m, x, h, z, p.light, 0.6, 18)
		end
	end
	return m
end

-- Promenade: closed shops on one side, a long window wall on the other.
local function promenade(): Model
	local m = B.newRoom("Promenade", { Weight = 1, MinRoom = 20 })
	local w, L, h, p = 48, 60, 22, PAL.promenade
	local windows = {}
	for _, z in { -10, -30, -50 } do
		table.insert(windows, { side = "right", z = z, y = 3, w = 14, h = 8 })
	end
	B.shell(m, w, L, h, p, { windows = windows })
	local names = { "ELSEWHERE", "MEMORIES", "AFTER" }
	for i, z in { -10, -30, -50 } do
		B.onWall(m, w, -1, z, 5.5, Vector2.new(14, 9), 0.4, "Storefront", { Color = rgb(15, 17, 20), Material = M.Glass, Reflectance = 0.3 })
		wallSign(m, w, -1, z, 12, Vector2.new(14, 2), names[i], rgb(55, 55, 60), rgb(200, 200, 200))
	end
	for _, z in { -20, -40 } do
		part(m, "Planter", Vector3.new(6, 2, 6), CFrame.new(0, 1, z), { Color = rgb(140, 132, 120), Material = M.Concrete })
		part(m, "Tree", Vector3.new(5, 5, 5), CFrame.new(0, 4.3, z), { Shape = Enum.PartType.Ball, Color = rgb(50, 90, 50), Material = M.Grass })
	end
	for _, x in { -6, 6 } do
		part(m, "Bench", Vector3.new(6, 1.5, 2), CFrame.new(x, 0.75, -30), { Color = rgb(100, 75, 55), Material = M.Wood })
	end
	for _, x in { -12, 12 } do
		for _, z in { -10, -30, -50 } do
			B.panel(m, x, h, z, p.light, 1.1, 30, Vector3.new(12, 0.3, 8))
		end
	end
	return m
end

-- Cryo bay: rows of stasis pods. Some are still occupied. One is open.
local function cryo(): Model
	local m = B.newRoom("CryoBay", { Weight = 2, MinRoom = 12 })
	local w, L, h, p = 28, 44, 12, PAL.cryo
	B.shell(m, w, L, h, p)
	local i = 0
	for _, side in { -1, 1 } do
		for _, z in { -6, -14, -22, -30, -38 } do
			i += 1
			local x = side * (w / 2 - 2.5)
			local base = part(m, "PodBase", Vector3.new(3, 0.6, 3), CFrame.new(x, 0.3, z), { Color = rgb(70, 78, 90), Material = M.Metal }) :: Part
			part(m, "PodCap", Vector3.new(3, 0.6, 3), CFrame.new(x, 7.9, z), { Color = rgb(70, 78, 90), Material = M.Metal })
			if i == 7 then
				-- The open pod: no glass, frost on the floor in front of it.
				part(m, "Frost", Vector3.new(3, 0.05, 3), CFrame.new(x - side * 3, 0.025, z), { Color = rgb(200, 225, 240), Material = M.Ice, CanCollide = false })
			else
				part(m, "PodGlass", Vector3.new(7, 2.6, 2.6), CFrame.new(x, 4.1, z) * CFrame.Angles(0, 0, math.pi / 2),
					{ Shape = Enum.PartType.Cylinder, Material = M.Glass, Color = rgb(150, 200, 230), Transparency = 0.6, CastShadow = false })
				if i % 3 ~= 0 then
					part(m, "Occupant", Vector3.new(1, 4.5, 1), CFrame.new(x, 3.1, z), { Color = rgb(55, 62, 72), CanCollide = false })
				end
			end
			glowing(base, rgb(120, 180, 255), 6, 0.6)
		end
	end
	endSign(m, -L, 1, 0, 10.8, Vector2.new(10, 1.2), "CRYO STASIS - DO NOT WAKE")
	B.panelGrid(m, w, L, h, 1, 5, p.light, 0.6)
	return m
end

-- Observatory: dark ring of stones around a glowing core.
local function observatory(): Model
	local m = B.newRoom("Observatory", { Weight = 1, MinRoom = 30 })
	local w, L, h, p = 36, 36, 22, PAL.cosmic
	local windows = {}
	for _, side in { "left", "right" } do
		for _, z in { -10, -26 } do
			table.insert(windows, { side = side, z = z, y = 4, w = 10, h = 8 })
		end
	end
	B.shell(m, w, L, h, p, { windows = windows })
	part(m, "Pedestal", Vector3.new(6, 3, 6), CFrame.new(0, 1.5, -18), { Color = p.trim, Material = M.Slate })
	local core = part(m, "Core", Vector3.new(5, 5, 5), CFrame.new(0, 6, -18),
		{ Shape = Enum.PartType.Ball, Material = M.Neon, Color = rgb(100, 70, 180), CanCollide = false })
	glowing(core, COSMIC, 30, 1.5)
	for k = 0, 7 do
		part(m, "Stone", Vector3.new(2, 1.5, 3),
			CFrame.new(0, 0, -18) * CFrame.Angles(0, k * math.pi / 4, 0) * CFrame.new(0, 0.75, 11),
			{ Color = rgb(60, 58, 70), Material = M.Slate })
	end
	for _, x in { -10, 10 } do
		for _, z in { -4, -32 } do
			B.panel(m, x, h, z, p.light, 0.6, 24)
		end
	end
	return m
end

---------------------------------------------------------------- more rooms

-- Simple crate.
local function crate(m: Model, cf: CFrame, size: Vector3, color: Color3?)
	part(m, "Crate", size, cf, { Color = color or rgb(110, 95, 70), Material = M.WoodPlanks })
end

-- Airlock: benches, red warning lights, and the outer door shows OPEN.
local function airlock(): Model
	local m = B.newRoom("Airlock", { Weight = 1, MinRoom = 4 })
	local w, L, h, p = 14, 18, 10, PAL.hull
	B.shell(m, w, L, h, p)
	for _, sx in { -1, 1 } do
		part(m, "Bench", Vector3.new(1.5, 1.5, 8), CFrame.new(sx * (w / 2 - 0.75), 0.75, -9), { Color = rgb(70, 74, 82), Material = M.Metal })
		B.bulb(m, Vector3.new(sx * 5, h - 0.6, -3), rgb(255, 60, 50), 12, 0.6, 1)
	end
	wallSign(m, w, -1, -9, 5.5, Vector2.new(5, 2), "OUTER DOOR: OPEN\nPRESSURE: 0.0 kPa", rgb(40, 10, 10), rgb(255, 90, 80), Enum.Font.Code)
	wallSign(m, w, 1, -9, 5.5, Vector2.new(4, 1.2), "AIRLOCK 3")
	B.panel(m, 0, h, -12, p.light, 0.6, 16)
	return m
end

-- Coolant loop: glowing tanks and channels of coolant.
local function coolant(): Model
	local m = B.newRoom("CoolantRoom", { Weight = 1, MinRoom = 18 })
	local w, L, h, p = 24, 36, 14, PAL.engine
	B.shell(m, w, L, h, p)
	local glow = rgb(70, 170, 220)
	for _, sx in { -1, 1 } do
		part(m, "Channel", Vector3.new(1, 0.05, L - 4), CFrame.new(sx * 5, 0.025, -L / 2), { Material = M.Neon, Color = rgb(40, 110, 150), CanCollide = false })
		for _, z in { -9, -27 } do
			local tank = part(m, "Tank", Vector3.new(10, 4, 4), CFrame.new(sx * 8, 5, z) * CFrame.Angles(0, 0, math.pi / 2),
				{ Shape = Enum.PartType.Cylinder, Color = rgb(120, 125, 130), Material = M.Metal }) :: Part
			for _, y in { 3, 7 } do
				part(m, "Ring", Vector3.new(0.3, 4.4, 4.4), CFrame.new(sx * 8, y, z) * CFrame.Angles(0, 0, math.pi / 2),
					{ Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(50, 130, 170), CanCollide = false })
			end
			glowing(tank, glow, 10, 0.5)
		end
	end
	endSign(m, -L, 1, 0, 11, Vector2.new(9, 1.2), "COOLANT LOOP B - DO NOT TOUCH")
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.5)
	return m
end

-- EVA suits standing in their racks. One slot is empty.
local function suitStorage(): Model
	local m = B.newRoom("SuitStorage", { Weight = 1, MinRoom = 8 })
	local w, L, h, p = 20, 32, 10, PAL.hull
	B.shell(m, w, L, h, p)
	local i = 0
	for _, side in { -1, 1 } do
		for z = -4, -28, -4 do
			i += 1
			part(m, "Rack", Vector3.new(0.2, 7, 3), CFrame.new(side * (w / 2 - 0.1), 3.5, z), { Color = rgb(60, 62, 68), Material = M.Metal })
			if i ~= 9 then
				local x = side * (w / 2 - 1.2)
				part(m, "Suit", Vector3.new(1.4, 4.5, 2), CFrame.new(x, 2.75, z), { Color = rgb(205, 205, 198), Material = M.Fabric })
				part(m, "Helmet", Vector3.new(1.6, 1.6, 1.6), CFrame.new(x, 5.8, z), { Shape = Enum.PartType.Ball, Color = rgb(215, 215, 210) })
				part(m, "Visor", Vector3.new(0.1, 0.8, 1), CFrame.new(x - side * 0.75, 5.85, z), { Color = rgb(20, 22, 28), Material = M.Glass, Reflectance = 0.3 })
			end
		end
	end
	B.panelGrid(m, w, L, h, 1, 4, p.light, 0.6)
	return m
end

-- Hydroponics: planter beds of dead crops under purple grow lights.
local function hydroponics(): Model
	local m = B.newRoom("Hydroponics", { Weight = 2, MinRoom = 6 })
	local w, L, h, p = 28, 40, 12, PAL.hydro
	B.shell(m, w, L, h, p)
	local rand = Random.new(21)
	for _, x in { -10.5, -5.5, 5.5, 10.5 } do
		part(m, "Bed", Vector3.new(3, 1.5, 26), CFrame.new(x, 0.75, -20), { Color = rgb(80, 86, 82), Material = M.Metal })
		part(m, "Soil", Vector3.new(2.6, 0.1, 25.6), CFrame.new(x, 1.55, -20), { Color = rgb(60, 45, 32), Material = M.Ground })
		for _ = 1, 8 do
			local sh = rand:NextNumber(0.8, 2.4)
			part(m, "Plant", Vector3.new(0.2, sh, 0.2), CFrame.new(x + rand:NextNumber(-1, 1), 1.6 + sh / 2, rand:NextNumber(-32, -8))
				* CFrame.Angles(rand:NextNumber(-0.3, 0.3), 0, rand:NextNumber(-0.3, 0.3)),
				{ Color = rgb(90, 85, 50), CanCollide = false })
		end
		for _, z in { -10, -20, -30 } do
			B.panel(m, x, h, z, p.light, 0.5, 14, Vector3.new(2.4, 0.3, 6))
		end
	end
	wallSign(m, w, -1, -20, 8, Vector2.new(7, 1.2), "HYDROPONICS - CROP CYCLE 412")
	return m
end

-- Crew gym.
local function gym(): Model
	local m = B.newRoom("Gym", { Weight = 1, MinRoom = 5 })
	local w, L, h, p = 28, 32, 11, PAL.office
	B.shell(m, w, L, h, p)
	for _, z in { -6, -12, -18, -24 } do
		part(m, "Treadmill", Vector3.new(2.4, 0.5, 5), CFrame.new(-10, 0.25, z), { Color = rgb(40, 42, 46) })
		part(m, "Console", Vector3.new(2.4, 3, 0.3), CFrame.new(-10, 2, z - 2.35), { Color = rgb(60, 62, 68), Material = M.Metal })
	end
	part(m, "WeightBench", Vector3.new(1.2, 1.6, 4.5), CFrame.new(8, 0.8, -10), { Color = rgb(30, 30, 34), Material = M.Leather })
	part(m, "WeightRack", Vector3.new(1, 4, 6), CFrame.new(w / 2 - 0.5, 2, -20), { Color = rgb(70, 72, 78), Material = M.Metal })
	for _, y in { 1, 2.5 } do
		for _, dz in { -2, 0, 2 } do
			part(m, "Weight", Vector3.new(0.8, 0.8, 0.8), CFrame.new(w / 2 - 1.4, y, -20 + dz), { Shape = Enum.PartType.Ball, Color = rgb(30, 30, 30) })
		end
	end
	part(m, "Mat", Vector3.new(6, 0.1, 6), CFrame.new(7, 0.05, -26), { Color = rgb(50, 80, 120), Material = M.Rubber, CanCollide = false })
	B.onWall(m, w, 1, -8, 6, Vector2.new(8, 4), 0.1, "Mirror", { Color = rgb(170, 175, 180), Material = M.Glass, Reflectance = 0.4 })
	wallSign(m, w, -1, -15, 7.5, Vector2.new(9, 1.4), "SOLSTICE WELLNESS: STAY STRONG FOR THE SUN", rgb(225, 140, 50), rgb(30, 25, 20))
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.6)
	return m
end

-- Memorial / quiet room. There is room on the wall for more names.
local function memorial(): Model
	local m = B.newRoom("MemorialRoom", { Weight = 1, MinRoom = 25 })
	local w, L, h, p = 22, 28, 12, PAL.quarters
	B.shell(m, w, L, h, p)
	for _, sx in { -1, 1 } do
		for _, z in { -6, -10, -14, -18 } do
			local x = sx * 6.5
			part(m, "Pew", Vector3.new(5.6, 1.6, 1), CFrame.new(x, 0.8, z), { Color = rgb(70, 50, 38), Material = M.Wood })
			part(m, "Pew", Vector3.new(6, 0.4, 1.4), CFrame.new(x, 1.8, z), { Color = rgb(80, 58, 44), Material = M.Wood })
			part(m, "Pew", Vector3.new(6, 1.8, 0.3), CFrame.new(x, 2.9, z + 0.55), { Color = rgb(80, 58, 44), Material = M.Wood })
		end
		-- Name plaques on the front wall, either side of the door.
		for col = 0, 2 do
			for row = 0, 3 do
				local plate = part(m, "Plaque", Vector3.new(1.6, 0.8, 0.1), CFrame.new(sx * (4.5 + col * 2.2), 2.5 + row * 1.6, -L + 0.05),
					{ Color = rgb(170, 140, 80), Material = M.Metal }) :: Part
				B.label(plate, if row == 3 and col == 2 then "" else "- - -", Enum.NormalId.Back, rgb(50, 35, 20))
			end
		end
	end
	wallSign(m, w, -1, -12, 7, Vector2.new(7, 1.6), "IN MEMORY OF THE CREW OF THE S.S. TOTALITY")
	wallSign(m, w, 1, -12, 7, Vector2.new(5, 1.2), "THERE IS ROOM FOR MORE", rgb(30, 25, 22), rgb(190, 170, 140))
	for _, z in { -6, -16 } do
		B.bulb(m, Vector3.new(0, h - 0.6, z), p.light, 16, 0.6, 1)
	end
	return m
end

-- Reading room: shelves of real paper books, armchairs, a reading lamp.
local function library(): Model
	local m = B.newRoom("ReadingRoom", { Weight = 1, MinRoom = 7 })
	local w, L, h, p = 28, 36, 12, PAL.quarters
	B.shell(m, w, L, h, p)
	local rand = Random.new(8)
	local bookColors = { rgb(110, 40, 35), rgb(40, 60, 90), rgb(50, 80, 50), rgb(120, 100, 60), rgb(70, 50, 70) }
	for _, side in { -1, 1 } do
		for _, z in { -9, -27 } do
			local x = side * (w / 2 - 0.75)
			part(m, "Bookshelf", Vector3.new(1.5, 9, 10), CFrame.new(x, 4.5, z), { Color = rgb(70, 50, 38), Material = M.Wood })
			for _, y in { 1.5, 3.5, 5.5, 7.5 } do
				part(m, "Books", Vector3.new(0.1, 1.2, 9.6), CFrame.new(x - side * 0.8, y, z),
					{ Color = bookColors[rand:NextInteger(1, #bookColors)], Material = M.Fabric })
			end
		end
	end
	for _, sx in { -1, 1 } do
		chair(m, CFrame.new(sx * 6, 0, -18) * CFrame.Angles(0, math.rad(sx * 90), 0), rgb(100, 60, 45))
	end
	part(m, "LampStand", Vector3.new(0.3, 4, 0.3), CFrame.new(-6, 2, -21.5), { Color = rgb(40, 35, 30), Material = M.Metal })
	B.bulb(m, Vector3.new(-6, 4.6, -21.5), rgb(255, 200, 140), 12, 0.6, 1)
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.5)
	return m
end

-- Dormitory: rows of bunks, beds still unmade.
local function dormitory(): Model
	local m = B.newRoom("Dormitory", { Weight = 2, MinRoom = 4 })
	local w, L, h, p = 24, 36, 11, PAL.hull
	B.shell(m, w, L, h, p)
	for _, side in { -1, 1 } do
		for _, z in { -5, -13, -21, -29 } do
			local x = side * (w / 2 - 1.5)
			for _, y in { 1.5, 5 } do
				part(m, "Bunk", Vector3.new(3, 0.6, 7), CFrame.new(x, y, z), { Color = rgb(80, 84, 92), Material = M.Metal })
				part(m, "Mattress", Vector3.new(2.8, 0.3, 6.8), CFrame.new(x, y + 0.45, z), { Color = rgb(150, 150, 145), Material = M.Fabric })
			end
			for _, dx in { -1.35, 1.35 } do
				for _, dz in { -3.35, 3.35 } do
					part(m, "Post", Vector3.new(0.3, 6.5, 0.3), CFrame.new(x + dx, 3.25, z + dz), { Color = rgb(60, 62, 68), Material = M.Metal })
				end
			end
		end
	end
	wallSign(m, w, -1, -17, 8.8, Vector2.new(4, 1), "LIGHTS OUT 22:00")
	B.panelGrid(m, w, L, h, 1, 4, p.light, 0.5)
	return m
end

-- Laundry: rows of machines, one still has clothes in it.
local function laundry(): Model
	local m = B.newRoom("Laundry", { Weight = 1, MinRoom = 6 })
	local w, L, h, p = 20, 24, 10, PAL.hygiene
	B.shell(m, w, L, h, p)
	for z = -3, -21, -3 do
		for _, y in { 1.5, 4.5 } do
			part(m, "Washer", Vector3.new(2.6, 3, 2.6), CFrame.new(-w / 2 + 1.3, y, z), { Color = rgb(215, 215, 210) })
			part(m, "WasherDoor", Vector3.new(0.1, 1.8, 1.8), CFrame.new(-w / 2 + 2.65, y + 0.1, z),
				{ Shape = Enum.PartType.Cylinder, Color = rgb(30, 35, 40), Material = M.Glass })
		end
	end
	part(m, "FoldingTable", Vector3.new(3, 0.2, 10), CFrame.new(6.5, 3, -12), { Color = rgb(200, 200, 195) })
	for _, dz in { -4.5, 4.5 } do
		part(m, "TableLeg", Vector3.new(2.6, 2.9, 0.3), CFrame.new(6.5, 1.45, -12 + dz), { Color = rgb(90, 92, 96), Material = M.Metal })
	end
	part(m, "Basket", Vector3.new(2, 1.4, 1.5), CFrame.new(7, 0.7, -20), { Color = rgb(70, 100, 140), Material = M.Plastic })
	wallSign(m, w, 1, -12, 6.5, Vector2.new(6, 1.4), "DO NOT LEAVE CLOTHES UNATTENDED")
	B.panelGrid(m, w, L, h, 1, 3, p.light, 0.6)
	return m
end

-- Galley kitchen.
local function galley(): Model
	local m = B.newRoom("Galley", { Weight = 2, MinRoom = 3 })
	local w, L, h, p = 26, 30, 10, PAL.mess
	B.shell(m, w, L, h, p)
	part(m, "Counter", Vector3.new(2.5, 3.4, 24), CFrame.new(w / 2 - 1.25, 1.7, -15), { Color = rgb(150, 152, 155), Material = M.Metal })
	for _, z in { -8, -10 } do
		for _, dx in { -0.5, 0.5 } do
			part(m, "Burner", Vector3.new(0.8, 0.05, 0.8), CFrame.new(w / 2 - 1.25 + dx, 3.425, z + dx), { Color = rgb(20, 20, 20), CanCollide = false })
		end
	end
	part(m, "Island", Vector3.new(3, 3.4, 10), CFrame.new(-6, 1.7, -14), { Color = rgb(150, 152, 155), Material = M.Metal })
	part(m, "Fridge", Vector3.new(3, 8, 3), CFrame.new(-w / 2 + 1.5, 4, -L + 1.5), { Color = rgb(200, 202, 205), Material = M.Metal })
	for _, z in { -12, -16 } do
		part(m, "Pot", Vector3.new(1, 1, 1), CFrame.new(-6, 3.9, z) * CFrame.Angles(0, 0, math.pi / 2),
			{ Shape = Enum.PartType.Cylinder, Color = rgb(120, 122, 126), Material = M.Metal })
	end
	wallSign(m, w, -1, -8, 6.5, Vector2.new(7, 1.4), "ALL CREW MEALS ARE MANDATORY")
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.6)
	return m
end

-- Comms array: the ship has been trying to call home for a long time.
local function comms(): Model
	local m = B.newRoom("CommsArray", { Weight = 1, MinRoom = 9 })
	local w, L, h, p = 24, 28, 12, PAL.archive
	B.shell(m, w, L, h, p)
	part(m, "Console", Vector3.new(2.5, 3, 10), CFrame.new(-w / 2 + 1.25, 1.5, -14), { Color = rgb(55, 58, 64), Material = M.Metal })
	local screen = B.onWall(m, w, -1, -14, 7, Vector2.new(8, 3.5), 0.2, "Screen", { Color = rgb(10, 30, 15), Material = M.Neon }) :: Part
	B.label(screen, "SIGNAL LOST\nLAST CONTACT: 4,812 DAYS AGO", Enum.NormalId.Right, rgb(120, 230, 140), Enum.Font.Code)
	chair(m, CFrame.new(-w / 2 + 4.5, 0, -14) * CFrame.Angles(0, math.rad(90), 0), rgb(60, 65, 80))
	part(m, "RadioTower", Vector3.new(3, 10, 6), CFrame.new(w / 2 - 1.5, 5, -14), { Color = rgb(40, 42, 48), Material = M.Metal })
	local rand = Random.new(4)
	for _ = 1, 10 do
		part(m, "Led", Vector3.new(0.05, 0.25, 0.25), CFrame.new(w / 2 - 3.025, rand:NextNumber(1.5, 9), -14 + rand:NextNumber(-2.6, 2.6)),
			{ Material = M.Neon, Color = if rand:NextNumber() < 0.5 then rgb(230, 60, 50) else rgb(230, 160, 40), CanCollide = false })
	end
	B.panelGrid(m, w, L, h, 2, 2, p.light, 0.5)
	return m
end

-- Captain's office. The nameplate has been scratched off.
local function captain(): Model
	local m = B.newRoom("CaptainsOffice", { Weight = 1, MinRoom = 15 })
	local w, L, h, p = 22, 22, 11, PAL.office
	B.shell(m, w, L, h, p, { windows = { { side = "right", z = -11, y = 3, w = 8, h = 4 } } })
	part(m, "Desk", Vector3.new(8, 0.3, 3.5), CFrame.new(-6, 3, -12), { Color = rgb(70, 50, 38), Material = M.Wood })
	for _, dx in { -3.6, 3.6 } do
		part(m, "DeskLeg", Vector3.new(0.4, 2.85, 3.2), CFrame.new(-6 + dx, 1.425, -12), { Color = rgb(60, 42, 32), Material = M.Wood })
	end
	local plate = part(m, "Nameplate", Vector3.new(2, 0.5, 0.3), CFrame.new(-6, 3.4, -10.6), { Color = rgb(170, 140, 80), Material = M.Metal }) :: Part
	B.label(plate, "CAPT. ######", Enum.NormalId.Back, rgb(40, 30, 20))
	chair(m, CFrame.new(-6, 0, -15.2) * CFrame.Angles(0, math.pi, 0), rgb(40, 30, 26))
	local flag = B.onWall(m, w, -1, -5, 6, Vector2.new(3, 5), 0.1, "Flag", { Color = rgb(225, 140, 50), Material = M.Fabric }) :: Part
	B.label(flag, "SOLSTICE", Enum.NormalId.Right, rgb(40, 25, 15))
	part(m, "Bookcase", Vector3.new(1.5, 7, 4), CFrame.new(-w / 2 + 0.75, 3.5, -18), { Color = rgb(70, 50, 38), Material = M.Wood })
	B.panelGrid(m, w, L, h, 2, 2, p.light, 0.5)
	return m
end

-- Conference room. The last presentation is still up.
local function conference(): Model
	local m = B.newRoom("ConferenceRoom", { Weight = 1, MinRoom = 2 })
	local w, L, h, p = 24, 28, 10, PAL.office
	B.shell(m, w, L, h, p)
	part(m, "Table", Vector3.new(5, 0.3, 16), CFrame.new(-5.5, 2.85, -14), { Color = rgb(60, 44, 34), Material = M.Wood })
	for _, z in { -7, -21 } do
		part(m, "TableLeg", Vector3.new(4, 2.7, 0.4), CFrame.new(-5.5, 1.35, z), { Color = rgb(50, 36, 28), Material = M.Wood })
	end
	for _, z in { -8, -12, -16, -20 } do
		chair(m, CFrame.new(-9.3, 0, z) * CFrame.Angles(0, math.rad(-90), 0), rgb(50, 55, 70))
		chair(m, CFrame.new(-1.7, 0, z) * CFrame.Angles(0, math.rad(90), 0), rgb(50, 55, 70))
	end
	local screen = B.onWall(m, w, 1, -14, 5.5, Vector2.new(10, 5), 0.2, "Screen", { Color = rgb(30, 40, 60), Material = M.Neon }) :: Part
	B.label(screen, "Q3 SOLAR YIELD: +1400%\nTHANK YOU, TEAM", Enum.NormalId.Left, rgb(220, 230, 255))
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.6)
	return m
end

-- Engineering workshop.
local function workshop(): Model
	local m = B.newRoom("Workshop", { Weight = 2, MinRoom = 5 })
	local w, L, h, p = 28, 32, 11, PAL.engine
	B.shell(m, w, L, h, p)
	for _, side in { -1, 1 } do
		for _, z in { -8, -22 } do
			local x = side * (w / 2 - 1.5)
			part(m, "Workbench", Vector3.new(3, 3, 10), CFrame.new(x, 1.5, z), { Color = rgb(90, 80, 70), Material = M.Metal })
			part(m, "Vise", Vector3.new(1, 0.8, 1.4), CFrame.new(x, 3.4, z - 3), { Color = rgb(60, 70, 90), Material = M.Metal })
			part(m, "Toolbox", Vector3.new(1.4, 0.8, 2), CFrame.new(x, 3.4, z + 2.5), { Color = rgb(170, 40, 35), Material = M.Metal })
			local board = B.onWall(m, w, side, z, 6, Vector2.new(10, 3), 0.1, "Pegboard", { Color = rgb(150, 125, 90), Material = M.Cardboard }) :: Part
			for k = -2, 2 do
				part(m, "Tool", Vector3.new(0.1, 1.6, 0.3), (board.CFrame * CFrame.new(-side * 0.1, 0, k * 1.6)) * CFrame.Angles(k * 0.3, 0, 0),
					{ Color = rgb(40, 40, 44), Material = M.Metal, CanCollide = false })
			end
		end
	end
	for _, dz in { -1.2, 0, 1.2 } do
		part(m, "GasCylinder", Vector3.new(4, 1, 1), CFrame.new(w / 2 - 0.6, 2, -15 + dz) * CFrame.Angles(0, 0, math.pi / 2),
			{ Shape = Enum.PartType.Cylinder, Color = rgb(60, 110, 70), Material = M.Metal })
	end
	crate(m, CFrame.new(-w / 2 + 1.5, 1.5, -L + 1.5), Vector3.new(3, 3, 3))
	wallSign(m, w, -1, -15, 8.5, Vector2.new(7, 1.2), "EYE PROTECTION REQUIRED", rgb(200, 160, 40), rgb(30, 25, 10))
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.6)
	return m
end

-- Cargo hold: containers and crates nobody unpacked.
local function cargo(): Model
	local m = B.newRoom("CargoHold", { Weight = 1, MinRoom = 10 })
	local w, L, h, p = 40, 48, 16, PAL.hangar
	B.shell(m, w, L, h, p)
	part(m, "Container", Vector3.new(8, 7, 16), CFrame.new(14, 3.5, -24), { Color = rgb(130, 60, 40), Material = M.CorrodedMetal })
	part(m, "Container", Vector3.new(8, 7, 16), CFrame.new(14, 10.5, -26), { Color = rgb(50, 80, 110), Material = M.CorrodedMetal })
	for _, c in { { -10, 1.5, -10, 3 }, { -13, 1.5, -10, 3 }, { -11.5, 4.5, -10, 3 }, { -14, 2, -30, 4 }, { -9, 1, -33, 2 } } do
		crate(m, CFrame.new(c[1], c[2], c[3]), Vector3.new(c[4], c[4], c[4]))
	end
	for z = -4, -44, -8 do
		part(m, "Line", Vector3.new(0.3, 0.05, 4), CFrame.new(-5, 0.025, z), { Color = p.trim, CanCollide = false })
		part(m, "Line", Vector3.new(0.3, 0.05, 4), CFrame.new(5, 0.025, z), { Color = p.trim, CanCollide = false })
	end
	B.panelGrid(m, w, L, h, 3, 4, p.light, 0.7, 22)
	return m
end

-- Elevator lobby. None of the elevators come.
local function elevators(): Model
	local m = B.newRoom("ElevatorLobby", { Weight = 1, MinRoom = 6 })
	local w, L, h, p = 24, 20, 12, PAL.promenade
	B.shell(m, w, L, h, p)
	for _, side in { -1, 1 } do
		for _, z in { -6, -14 } do
			B.onWall(m, w, side, z, 4.7, Vector2.new(5.4, 9.4), 0.3, "ElevatorFrame", { Color = rgb(70, 72, 78), Material = M.Metal })
			B.onWall(m, w, side, z, 4.2, Vector2.new(4.4, 8.4), 0.4, "ElevatorDoor", { Color = rgb(170, 172, 176), Material = M.Metal, Reflectance = 0.2 })
			wallSign(m, w, side, z, 10.2, Vector2.new(1.6, 0.8), "--", rgb(20, 10, 10), rgb(255, 70, 50), Enum.Font.Code)
			B.onWall(m, w, side, z + 3.3, 4, Vector2.new(0.5, 0.8), 0.15, "CallButton", { Color = rgb(60, 62, 66), Material = M.Metal })
		end
	end
	local sign = B.onWall(m, w, 1, -6, 5, Vector2.new(3, 1), 0.5, "Sign", { Color = rgb(230, 230, 225) }) :: Part
	B.label(sign, "OUT OF ORDER", Enum.NormalId.Left, rgb(20, 20, 20))
	B.panelGrid(m, w, L, h, 2, 2, p.light, 0.6)
	return m
end

-- Infirmary ward: beds behind curtains. One is occupied.
local function infirmary(): Model
	local m = B.newRoom("InfirmaryWard", { Weight = 2, MinRoom = 8 })
	local w, L, h, p = 26, 36, 11, PAL.med
	B.shell(m, w, L, h, p)
	for _, side in { -1, 1 } do
		for i, z in { -5, -12, -19, -26, -33 } do
			part(m, "BedBase", Vector3.new(7, 2, 3), CFrame.new(side * 9.5, 1, z), { Color = rgb(170, 175, 172), Material = M.Metal })
			part(m, "Mattress", Vector3.new(6.6, 0.4, 2.8), CFrame.new(side * 9.3, 2.2, z), { Color = rgb(225, 228, 225), Material = M.Fabric })
			part(m, "Headboard", Vector3.new(0.3, 2.5, 3), CFrame.new(side * 12.85, 3.25, z), { Color = rgb(150, 155, 152), Material = M.Metal })
			if side == 1 and i == 3 then
				part(m, "Sheet", Vector3.new(4, 0.8, 1.6), CFrame.new(side * 8.8, 2.8, z), { Color = rgb(235, 235, 232), Material = M.Fabric })
			end
		end
		for _, z in { -8.5, -15.5, -22.5, -29.5 } do
			part(m, "Curtain", Vector3.new(7, 7, 0.1), CFrame.new(side * 9.5, 4.5, z),
				{ Color = rgb(150, 190, 175), Material = M.Fabric, Transparency = 0.15, CanCollide = false })
		end
	end
	B.panelGrid(m, w, L, h, 2, 4, p.light, 0.6)
	return m
end

-- Helioscope bay: the giant solar telescope the ship was built around.
local function helioscope(): Model
	local m = B.newRoom("HelioscopeBay", { Weight = 1, MinRoom = 20 })
	local w, L, h, p = 30, 40, 22, PAL.lab
	B.shell(m, w, L, h, p)
	part(m, "Mount", Vector3.new(6, 3, 6), CFrame.new(-8, 1.5, -20), { Color = rgb(70, 72, 78), Material = M.Metal })
	local tubeCf = CFrame.new(-8, 9, -20) * CFrame.Angles(0, math.pi / 2, 0) * CFrame.Angles(0, 0, math.rad(40))
	part(m, "Telescope", Vector3.new(20, 6, 6), tubeCf, { Shape = Enum.PartType.Cylinder, Color = rgb(210, 212, 215), Material = M.Metal })
	local filter = part(m, "Filter", Vector3.new(0.1, 6.2, 6.2), tubeCf * CFrame.new(10.05, 0, 0),
		{ Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(255, 130, 40), CanCollide = false }) :: Part
	glowing(filter, rgb(255, 140, 60), 16, 0.8)
	part(m, "Console", Vector3.new(3, 3, 8), CFrame.new(9, 1.5, -20), { Color = rgb(55, 58, 64), Material = M.Metal })
	local screen = B.onWall(m, w, 1, -20, 10, Vector2.new(10, 5), 0.2, "Screen", { Color = rgb(30, 12, 8), Material = M.Neon }) :: Part
	B.label(screen, "SURFACE TEMP\n5,772 K\n5,772 K\n9,9?? K", Enum.NormalId.Left, rgb(255, 150, 90), Enum.Font.Code)
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.6, 26)
	return m
end

-- Xenobiology lab. Whatever they found, they brought it aboard.
local function xenolab(): Model
	local m = B.newRoom("XenoLab", { Weight = 1, MinRoom = 40 })
	local w, L, h, p = 28, 36, 12, PAL.lab
	B.shell(m, w, L, h, p)
	local i = 0
	for _, side in { -1, 1 } do
		for _, z in { -6, -14, -22, -30 } do
			i += 1
			local x = side * 10.5
			local base = part(m, "TankBase", Vector3.new(3.4, 0.8, 3.4), CFrame.new(x, 0.4, z), { Color = rgb(60, 64, 70), Material = M.Metal }) :: Part
			part(m, "TankCap", Vector3.new(3.4, 0.6, 3.4), CFrame.new(x, 8.1, z), { Color = rgb(60, 64, 70), Material = M.Metal })
			if i == 6 then
				-- Broken from the inside.
				part(m, "Spill", Vector3.new(0.05, 5, 5), CFrame.new(x - side * 3, 0.025, z) * CFrame.Angles(0, 0, math.pi / 2),
					{ Shape = Enum.PartType.Cylinder, Color = rgb(110, 60, 150), Material = M.Glass, Transparency = 0.15, CanCollide = false })
			else
				part(m, "TankGlass", Vector3.new(7, 3, 3), CFrame.new(x, 4.3, z) * CFrame.Angles(0, 0, math.pi / 2),
					{ Shape = Enum.PartType.Cylinder, Material = M.Glass, Color = rgb(150, 210, 180), Transparency = 0.55, CastShadow = false })
				part(m, "Specimen", Vector3.new(1.4, 1.4, 1.4), CFrame.new(x, 4.8, z), { Shape = Enum.PartType.Ball, Color = rgb(45, 35, 60), CanCollide = false })
				part(m, "Specimen", Vector3.new(0.4, 2.6, 0.4), CFrame.new(x, 3.2, z) * CFrame.Angles(0.4, 0, 0.3), { Color = rgb(45, 35, 60), CanCollide = false })
			end
			glowing(base, rgb(130, 220, 170), 6, 0.5)
		end
	end
	endSign(m, -L, 1, 0, 10.4, Vector2.new(10, 1.2), "XENOBIOLOGY - LEVEL 4 CLEARANCE")
	wallSign(m, w, -1, -18, 9.6, Vector2.new(6, 1.6), "SPECIMEN ORIGIN:\nSOLAR CORONA ??", rgb(225, 228, 230), rgb(40, 50, 90), Enum.Font.Cartoon)
	B.panelGrid(m, w, L, h, 1, 4, p.light, 0.5)
	return m
end

-- Quarantine: plastic sheeting, warning lights, things in bags.
local function quarantine(): Model
	local m = B.newRoom("Quarantine", { Weight = 1, MinRoom = 45 })
	local w, L, h, p = 24, 36, 11, PAL.med
	B.shell(m, w, L, h, p)
	for _, sx in { -1, 1 } do
		for _, z in { -7, -15, -23, -31 } do
			part(m, "Sheeting", Vector3.new(0.1, 9, 6), CFrame.new(sx * 4, 4.5, z),
				{ Color = rgb(220, 230, 225), Material = M.Glass, Transparency = 0.5, CanCollide = false, CastShadow = false })
		end
		for _, z in { -10, -24 } do
			part(m, "Bag", Vector3.new(2, 0.8, 5), CFrame.new(sx * 8, 0.4, z), { Color = rgb(45, 48, 52), Material = M.Plastic })
		end
		B.bulb(m, Vector3.new(sx * 9, h - 0.6, -18), rgb(255, 60, 50), 14, 0.6, 1)
	end
	for _, side in { -1, 1 } do
		wallSign(m, w, side, -17, 7, Vector2.new(6, 1.6), "QUARANTINE\nDO NOT BREAK SEAL", rgb(200, 160, 40), rgb(30, 20, 10))
	end
	part(m, "Tape", Vector3.new(w, 0.05, 0.4), CFrame.new(0, 0.025, -3), { Color = rgb(170, 30, 30), CanCollide = false })
	B.panelGrid(m, w, L, h, 1, 4, p.light, 0.45)
	return m
end

-- The bridge. Course still set for the Sun.
local function bridge(): Model
	local m = B.newRoom("Bridge", { Weight = 1, MinRoom = 35 })
	local w, L, h, p = 36, 36, 14, PAL.hull
	local windows = {}
	for _, side in { "left", "right" } do
		for _, z in { -12, -24 } do
			table.insert(windows, { side = side, z = z, y = 3, w = 10, h = 6 })
		end
	end
	B.shell(m, w, L, h, p, { windows = windows })
	for _, sx in { -1, 1 } do
		part(m, "Console", Vector3.new(8, 3, 2), CFrame.new(sx * 10, 1.5, -31), { Color = rgb(55, 58, 64), Material = M.Metal })
		for _, dx in { -2.5, 0, 2.5 } do
			part(m, "Display", Vector3.new(2, 1.2, 0.1), CFrame.new(sx * 10 + dx, 3.7, -31.4) * CFrame.Angles(-0.3, 0, 0),
				{ Material = M.Neon, Color = rgb(60, 35, 20), CanCollide = false })
		end
	end
	part(m, "CaptainChairBase", Vector3.new(2, 1.4, 2), CFrame.new(6, 0.7, -17), { Color = rgb(60, 62, 68), Material = M.Metal })
	part(m, "CaptainChair", Vector3.new(3, 0.6, 3), CFrame.new(6, 1.7, -17), { Color = rgb(70, 35, 30), Material = M.Leather })
	part(m, "CaptainChair", Vector3.new(3, 3.5, 0.5), CFrame.new(6, 3.75, -15.75), { Color = rgb(70, 35, 30), Material = M.Leather })
	endSign(m, -L, 1, 0, 11.5, Vector2.new(12, 1.2), "NAVIGATION OFFLINE - COURSE: SOL", rgb(30, 12, 8), rgb(255, 140, 80))
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.5)
	return m
end

-- Capacitor bank: rows of humming capacitors, still charged.
local function capacitors(): Model
	local m = B.newRoom("CapacitorBank", { Weight = 1, MinRoom = 14 })
	local w, L, h, p = 28, 36, 16, PAL.engine
	B.shell(m, w, L, h, p)
	for _, sx in { -1, 1 } do
		for _, z in { -6, -14, -22, -30 } do
			local cap = part(m, "Capacitor", Vector3.new(12, 3, 3), CFrame.new(sx * 10.5, 6, z) * CFrame.Angles(0, 0, math.pi / 2),
				{ Shape = Enum.PartType.Cylinder, Color = rgb(110, 112, 118), Material = M.Metal }) :: Part
			for _, y in { 4, 8 } do
				part(m, "Band", Vector3.new(0.3, 3.3, 3.3), CFrame.new(sx * 10.5, y, z) * CFrame.Angles(0, 0, math.pi / 2),
					{ Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(170, 140, 40), CanCollide = false })
			end
			glowing(cap, rgb(255, 210, 90), 8, 0.4)
		end
		part(m, "Cable", Vector3.new(0.5, 0.25, L - 4), CFrame.new(sx * 7, 0.125, -L / 2), { Color = rgb(20, 20, 22), Material = M.Rubber })
	end
	wallSign(m, w, -1, -18, 13, Vector2.new(6, 1.4), "DANGER - HIGH VOLTAGE", rgb(200, 160, 40), rgb(30, 20, 10))
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.5, 22)
	return m
end

-- Maintenance tunnel: narrow, pipes on both sides, caged bulbs.
local function tunnel(): Model
	local m = B.newRoom("MaintenanceTunnel", { Weight = 2, MinRoom = 4 })
	local w, L, h, p = 8, 40, 10, PAL.hull
	B.shell(m, w, L, h, p)
	for _, sx in { -1, 1 } do
		pipe(m, sx * 3.5, 2, L, rgb(80, 84, 90))
		pipe(m, sx * 3.5, 5.5, L, rgb(110, 70, 50))
	end
	part(m, "Grate", Vector3.new(3, 0.04, L), CFrame.new(0, 0.02, -L / 2), { Color = rgb(45, 46, 50), Material = M.DiamondPlate, CanCollide = false })
	for _, z in { -6, -16, -26, -36 } do
		B.bulb(m, Vector3.new(0, h - 0.6, z), rgb(255, 210, 160), 12, 0.6, 0.9)
	end
	wallSign(m, w, -1, -20, 8.2, Vector2.new(3, 0.8), "SECTOR 7-G")
	return m
end

-- Security office: camera feeds, one shows movement.
local function security(): Model
	local m = B.newRoom("SecurityOffice", { Weight = 1, MinRoom = 10 })
	local w, L, h, p = 24, 28, 10, PAL.office
	B.shell(m, w, L, h, p)
	B.onWall(m, w, -1, -14, 6, Vector2.new(11, 4), 0.1, "MonitorWall", { Color = rgb(20, 20, 24), Material = M.Metal })
	for row = 0, 1 do
		for col = 0, 3 do
			local cam = row * 4 + col + 1
			local screen = part(m, "CamScreen", Vector3.new(0.05, 1.6, 2.4),
				CFrame.new(-w / 2 + 0.125, 5.1 + row * 1.9, -14 - 3.9 + col * 2.6),
				{ Material = M.Neon, Color = if cam == 7 then rgb(80, 30, 30) else rgb(30, 45, 40), CanCollide = false }) :: Part
			B.label(screen, if cam == 7 then "CAM 7: MOVEMENT" else `CAM {cam}`, Enum.NormalId.Right, rgb(200, 220, 210), Enum.Font.Code)
		end
	end
	part(m, "Desk", Vector3.new(2.5, 3, 10), CFrame.new(-w / 2 + 1.25, 1.5, -14), { Color = rgb(55, 58, 64), Material = M.Metal })
	chair(m, CFrame.new(-w / 2 + 4.5, 0, -14) * CFrame.Angles(0, math.rad(90), 0), rgb(40, 45, 60))
	for i = 0, 5 do
		part(m, "Locker", Vector3.new(1.5, 7, 2), CFrame.new(w / 2 - 0.75, 3.5, -8 - i * 2), { Color = rgb(60, 66, 74), Material = M.Metal })
	end
	wallSign(m, w, 1, -22, 6, Vector2.new(4, 1.2), "SECURITY", rgb(30, 50, 90), rgb(220, 230, 255))
	B.panelGrid(m, w, L, h, 2, 2, p.light, 0.5)
	return m
end

-- Brig: holding cells. One set of bars has been torn open.
local function brig(): Model
	local m = B.newRoom("Brig", { Weight = 1, MinRoom = 22 })
	local w, L, h, p = 26, 36, 11, PAL.hull
	B.shell(m, w, L, h, p)
	local bar = { Color = rgb(70, 72, 78), Material = M.Metal }
	for _, side in { -1, 1 } do
		for _, z in { -4, -10, -16, -22, -28, -34 } do
			part(m, "CellWall", Vector3.new(6, h, 0.4), CFrame.new(side * 10, h / 2, z), { Color = p.wall, Material = p.wallMat })
		end
		for c = 0, 4 do
			local z0 = -4.2 - c * 6
			local broken = side == 1 and c == 2
			for b = 0, 6 do
				if not (broken and b >= 2 and b <= 4) then
					part(m, "Bar", Vector3.new(0.2, 9, 0.2), CFrame.new(side * 7.1, 4.5, z0 - 0.4 - b * 0.8), bar)
				end
			end
			part(m, "BarTop", Vector3.new(0.3, 0.3, 5.6), CFrame.new(side * 7.1, 9.15, z0 - 2.8), bar)
		end
	end
	endSign(m, -L, 1, 0, 10.2, Vector2.new(5, 1), "HOLDING")
	B.panelGrid(m, w, L, h, 1, 4, p.light, 0.5)
	return m
end

-- Waste reclamation: a compactor, chutes, bins.
local function recycling(): Model
	local m = B.newRoom("Recycling", { Weight = 1, MinRoom = 12 })
	local w, L, h, p = 28, 32, 14, PAL.engine
	B.shell(m, w, L, h, p)
	part(m, "Compactor", Vector3.new(8, 8, 8), CFrame.new(-8, 4, -16), { Color = rgb(90, 92, 96), Material = M.DiamondPlate })
	part(m, "WarningStrip", Vector3.new(0.1, 0.6, 8), CFrame.new(-3.95, 6, -16), { Color = rgb(200, 160, 40), CanCollide = false })
	part(m, "Chute", Vector3.new(3, 5, 3), CFrame.new(-8, 11.5, -16), { Color = rgb(70, 72, 76), Material = M.Metal })
	local colors = { rgb(60, 100, 60), rgb(50, 70, 120), rgb(120, 100, 40) }
	for i = 0, 5 do
		part(m, "Bin", Vector3.new(2, 2.5, 2), CFrame.new(w / 2 - 1, 1.25, -5 - i * 2.4), { Color = colors[i % 3 + 1], Material = M.Plastic })
	end
	part(m, "Conveyor", Vector3.new(3, 1.2, 12), CFrame.new(7, 0.6, -24), { Color = rgb(40, 40, 44), Material = M.Rubber })
	for _, b in { { -12, -27 }, { -9, -29 }, { 9, -10 } } do
		part(m, "Bag", Vector3.new(1.6, 1.4, 1.6), CFrame.new(b[1], 0.7, b[2]), { Color = rgb(30, 32, 34), Material = M.Plastic })
	end
	wallSign(m, w, -1, -28, 8, Vector2.new(7, 1.2), "WASTE RECLAMATION")
	-- Lamps placed around the chute rather than in a grid.
	for _, pos in { { 7, -6 }, { 7, -16 }, { 7, -26 }, { -8, -6 }, { -8, -26 } } do
		B.panel(m, pos[1], h, pos[2], p.light, 0.5)
	end
	return m
end

-- Crew lounge: a bar called The Last Light.
local function lounge(): Model
	local m = B.newRoom("Lounge", { Weight = 1, MinRoom = 9 })
	local w, L, h, p = 30, 32, 10, PAL.quarters
	B.shell(m, w, L, h, p)
	part(m, "Bar", Vector3.new(2.5, 3.6, 14), CFrame.new(-10, 1.8, -16), { Color = rgb(60, 40, 30), Material = M.Wood })
	for z = -10, -22, -3 do
		part(m, "Stool", Vector3.new(2.6, 1.2, 1.2), CFrame.new(-7.6, 1.3, z) * CFrame.Angles(0, 0, math.pi / 2),
			{ Shape = Enum.PartType.Cylinder, Color = rgb(110, 40, 40), Material = M.Leather })
	end
	B.onWall(m, w, -1, -16, 5, Vector2.new(12, 0.4), 1, "Shelf", { Color = rgb(60, 40, 30), Material = M.Wood })
	local rand = Random.new(9)
	for k = 0, 10 do
		part(m, "Bottle", Vector3.new(0.4, 1.2, 0.4), CFrame.new(-w / 2 + 0.5, 5.8, -21.5 + k * 1.1),
			{ Color = rgb(rand:NextInteger(40, 120), rand:NextInteger(60, 120), rand:NextInteger(30, 70)), Material = M.Glass, Transparency = 0.2 })
	end
	wallSign(m, w, -1, -16, 7.8, Vector2.new(6, 1.2), "THE LAST LIGHT", rgb(25, 15, 15), rgb(140, 60, 50), Enum.Font.Garamond)
	for _, z in { -8, -22 } do
		part(m, "BoothTable", Vector3.new(2.5, 0.3, 3), CFrame.new(11, 2.85, z), { Color = rgb(60, 40, 30), Material = M.Wood })
		part(m, "TableLeg", Vector3.new(0.5, 2.7, 0.5), CFrame.new(11, 1.35, z), { Color = rgb(40, 30, 25) })
		for _, dz in { -2.6, 2.6 } do
			part(m, "BoothSeat", Vector3.new(3, 1.6, 1.6), CFrame.new(11, 0.8, z + dz), { Color = rgb(110, 40, 40), Material = M.Leather })
			part(m, "BoothBack", Vector3.new(3, 2.4, 0.5), CFrame.new(11, 2.8, z + dz + math.sign(dz) * 0.55), { Color = rgb(110, 40, 40), Material = M.Leather })
		end
	end
	for _, z in { -6, -16, -26 } do
		B.bulb(m, Vector3.new(0, h - 0.6, z), p.light, 16, 0.6, 1)
	end
	return m
end

-- Ship cinema. The film ended a long time ago.
local function cinema(): Model
	local m = B.newRoom("Cinema", { Weight = 1, MinRoom = 16 })
	local w, L, h, p = 30, 36, 14, PAL.quarters
	B.shell(m, w, L, h, p)
	local screen = B.onWall(m, w, -1, -18, 7, Vector2.new(18, 8), 0.2, "Screen", { Color = rgb(40, 42, 46), Material = M.Neon }) :: Part
	B.label(screen, "PLEASE REMAIN SEATED", Enum.NormalId.Right, rgb(150, 150, 150), Enum.Font.Garamond)
	for _, x in { -9, -6, 5, 8, 11 } do
		for z = -8, -28, -2.5 do
			chair(m, CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(90), 0), rgb(90, 30, 35))
		end
	end
	for _, z in { -6, -18, -30 } do
		B.bulb(m, Vector3.new(w / 2 - 0.6, 7, z), p.light, 12, 0.5, 0.8)
	end
	return m
end

-- Gallery of the Sun, photographed over the mission. It changes.
local function gallery(): Model
	local m = B.newRoom("SolarGallery", { Weight = 1, MinRoom = 28 })
	local w, L, h, p = 14, 44, 11, PAL.promenade
	B.shell(m, w, L, h, p)
	local photos = {
		{ "SOL - DAY 1", rgb(255, 220, 120) }, { "SOL - DAY 90", rgb(255, 200, 90) },
		{ "SOL - DAY 400", rgb(255, 160, 60) }, { "SOL - DAY 1,200", rgb(240, 110, 50) },
		{ "SOL - DAY 2,000", rgb(200, 60, 50) }, { "SOL - DAY 3,100", rgb(150, 40, 80) },
		{ "SOL - DAY 4,000", rgb(100, 40, 130) }, { "SOL - DAY ????", rgb(60, 30, 110) },
		{ "SOL - DAY ????", rgb(25, 15, 40) }, { "", rgb(5, 5, 8) },
	}
	for i, ph in photos do
		local side = if i % 2 == 1 then -1 else 1
		local z = -4 - math.floor((i - 1) / 2) * 9
		B.onWall(m, w, side, z, 5.5, Vector2.new(4, 4), 0.2, "Frame", { Color = rgb(30, 28, 26), Material = M.Wood })
		part(m, "Sun", Vector3.new(0.1, 2.6, 2.6), CFrame.new(side * (w / 2 - 0.25), 5.5, z),
			{ Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = ph[2]:Lerp(Color3.new(0, 0, 0), 0.3), CanCollide = false })
		if ph[1] ~= "" then
			wallSign(m, w, side, z, 2.9, Vector2.new(3, 0.6), ph[1], rgb(200, 190, 170), rgb(30, 25, 20))
		end
		B.bulb(m, Vector3.new(side * (w / 2 - 1), 9, z), rgb(255, 230, 200), 8, 0.5, 0.6)
	end
	return m
end

-- Arboretum: a dead tree under a skylight.
local function deadTree(m: Model, x: number, z: number, scale: number)
	local bark = { Color = rgb(70, 55, 42), Material = M.Wood }
	local trunkH = 14 * scale
	part(m, "Trunk", Vector3.new(3 * scale, trunkH, 3 * scale), CFrame.new(x, 0.1 + trunkH / 2, z), bark)
	for k = 0, 3 do
		part(m, "Branch", Vector3.new(0.8 * scale, 7 * scale, 0.8 * scale),
			CFrame.new(x, trunkH - 1, z) * CFrame.Angles(0, k * math.pi / 2 + 0.4, 0) * CFrame.Angles(0.7, 0, 0) * CFrame.new(0, 3.5 * scale, 0), bark)
	end
end

local function arboretum(): Model
	local m = B.newRoom("Arboretum", { Weight = 1, MinRoom = 24 })
	local w, L, h, p = 40, 44, 24, PAL.hydro
	B.shell(m, w, L, h, p)
	local rim = { Color = rgb(90, 95, 92), Material = M.Concrete }
	part(m, "PlanterRim", Vector3.new(10, 1, 0.6), CFrame.new(-9, 0.5, -16.3), rim)
	part(m, "PlanterRim", Vector3.new(10, 1, 0.6), CFrame.new(-9, 0.5, -25.7), rim)
	part(m, "PlanterRim", Vector3.new(0.6, 1, 8.8), CFrame.new(-13.7, 0.5, -21), rim)
	part(m, "PlanterRim", Vector3.new(0.6, 1, 8.8), CFrame.new(-4.3, 0.5, -21), rim)
	part(m, "Soil", Vector3.new(8.8, 0.1, 8.8), CFrame.new(-9, 0.05, -21), { Color = rgb(60, 45, 32), Material = M.Ground })
	deadTree(m, -9, -21, 1)
	part(m, "Grass", Vector3.new(8, 0.05, 10), CFrame.new(11, 0.025, -34), { Color = rgb(80, 85, 50), Material = M.Grass, CanCollide = false })
	deadTree(m, 11, -34, 0.6)
	for _, z in { -10, -30 } do
		part(m, "Bench", Vector3.new(2, 1.5, 6), CFrame.new(8, 0.75, z), { Color = rgb(100, 75, 55), Material = M.Wood })
	end
	wallSign(m, w, -1, -34, 4, Vector2.new(8, 1.2), "PLEASE DO NOT TOUCH THE TREE")
	for _, x in { -10, 10 } do
		for _, z in { -11, -33 } do
			B.panel(m, x, h, z, rgb(220, 230, 255), 0.9, 30, Vector3.new(10, 0.3, 10))
		end
	end
	return m
end

-- Decontamination corridor: shower arches and floor drains.
local function decon(): Model
	local m = B.newRoom("Decontamination", { Weight = 1, MinRoom = 10 })
	local w, L, h, p = 10, 24, 10, PAL.hygiene
	B.shell(m, w, L, h, p)
	for _, z in { -5, -11, -17 } do
		for _, sx in { -1, 1 } do
			part(m, "ArchPost", Vector3.new(0.6, 8.4, 0.6), CFrame.new(sx * 4.2, 4.2, z), { Color = rgb(170, 175, 178), Material = M.Metal })
		end
		part(m, "ArchTop", Vector3.new(9, 0.6, 0.6), CFrame.new(0, 8.7, z), { Color = rgb(170, 175, 178), Material = M.Metal })
		for _, x in { -2.5, 0, 2.5 } do
			part(m, "Nozzle", Vector3.new(0.4, 0.3, 0.4), CFrame.new(x, 8.25, z), { Color = rgb(60, 62, 66), Material = M.Metal })
		end
		part(m, "Drain", Vector3.new(1.5, 0.05, 1.5), CFrame.new(0, 0.025, z - 3), { Color = rgb(30, 32, 34), Material = M.DiamondPlate, CanCollide = false })
	end
	wallSign(m, w, -1, -20, 6, Vector2.new(5, 1.4), "DECONTAMINATION\nIN PROGRESS", rgb(20, 40, 25), rgb(120, 230, 140), Enum.Font.Code)
	B.panelGrid(m, w, L, h, 1, 2, p.light, 0.6)
	return m
end

-- Mail room: letters home that were never sent.
local function mailRoom(): Model
	local m = B.newRoom("MailRoom", { Weight = 1, MinRoom = 7 })
	local w, L, h, p = 20, 24, 10, PAL.office
	B.shell(m, w, L, h, p)
	part(m, "Cubbies", Vector3.new(1.5, 7, 16), CFrame.new(-w / 2 + 0.75, 3.5, -12), { Color = rgb(110, 90, 70), Material = M.Wood })
	local rand = Random.new(12)
	for row = 0, 4 do
		for col = 0, 5 do
			local y, z = 1.2 + row * 1.3, -12 - 6.5 + col * 2.6
			part(m, "Cubby", Vector3.new(0.05, 1, 2.2), CFrame.new(-w / 2 + 1.525, y, z), { Color = rgb(40, 32, 26), CanCollide = false })
			if rand:NextNumber() < 0.5 then
				part(m, "Letter", Vector3.new(0.3, 0.6, 1.2), CFrame.new(-w / 2 + 1.7, y - 0.1, z + rand:NextNumber(-0.4, 0.4)),
					{ Color = rgb(225, 220, 205), CanCollide = false })
			end
		end
	end
	part(m, "SortingTable", Vector3.new(3, 0.3, 8), CFrame.new(6, 3, -12), { Color = rgb(150, 152, 155), Material = M.Metal })
	for _, dz in { -3.5, 3.5 } do
		part(m, "TableLeg", Vector3.new(2.6, 2.85, 0.3), CFrame.new(6, 1.425, -12 + dz), { Color = rgb(80, 82, 86), Material = M.Metal })
	end
	for _, b in { { 7, -20 }, { 4, -21 } } do
		part(m, "MailBag", Vector3.new(2, 2, 1.5), CFrame.new(b[1], 1, b[2]), { Color = rgb(90, 80, 60), Material = M.Fabric })
	end
	wallSign(m, w, 1, -12, 6.5, Vector2.new(6, 1.4), "UNDELIVERED\nRETURN TO SENDER")
	B.panelGrid(m, w, L, h, 1, 2, p.light, 0.6)
	return m
end

---------------------------------------------------------------- special rooms

-- Docking bay where the team boards.
local function start(): Model
	local m = B.newRoom("Start")
	local w, L, h, p = 24, 32, 10, PAL.hull
	B.shell(m, w, L, h, p, {
		entrance = false,
		windows = {
			{ side = "right", z = -10, y = 3, w = 8, h = 4 },
			{ side = "right", z = -22, y = 3, w = 8, h = 4 },
		},
	})
	endSign(m, 0, -1, 0, 7, Vector2.new(12, 1.8), "WELCOME ABOARD THE S.S. TOTALITY")
	endSign(m, 0, -1, 0, 5.3, Vector2.new(7, 0.9), "SOLSTICE SOLUTIONS - SOLAR RESEARCH DIVISION", rgb(225, 140, 50), rgb(30, 25, 20))
	part(m, "Bench", Vector3.new(8, 1.5, 2), CFrame.new(-7, 0.75, -4), { Color = rgb(70, 74, 82), Material = M.Metal })
	wallSign(m, w, -1, -16, 6, Vector2.new(7, 3),
		"OBJECTIVE:\nRECOVER ALL RESEARCH\nSOLSTICE THANKS YOU", rgb(25, 28, 30), rgb(120, 220, 140), Enum.Font.Code)
	B.marker(m, "PlayerSpawn", CFrame.new(0, 3, -8))
	B.panelGrid(m, w, L, h, 2, 4, p.light, 0.7)
	return m
end

-- Room 50: a briefing room with a message from Solstice.
local function midpoint(): Model
	local m = B.newRoom("Midpoint")
	local w, L, h, p = 32, 32, 12, PAL.office
	B.shell(m, w, L, h, p)
	local screen = B.onWall(m, w, -1, -16, 6.5, Vector2.new(14, 6), 0.2, "Screen", { Color = rgb(15, 30, 55), Material = M.Neon }) :: Part
	B.label(screen, "SOLSTICE SOLUTIONS THANKS YOU\nFOR YOUR CONTINUED COOPERATION\n\n50 / 100", Enum.NormalId.Right, rgb(200, 220, 255), Enum.Font.Code)
	for _, x in { 2, 5, 8 } do
		for _, z in { -10, -14, -18, -22 } do
			chair(m, CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(90), 0), rgb(60, 65, 80))
		end
	end
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.6)
	return m
end

-- Room 100: the heart of the ship.
local function final(): Model
	-- Pristine: untouched by the attack, which makes it worse.
	local m = B.newRoom("Final", { Pristine = true })
	local w, L, h, p = 48, 60, 30, PAL.cosmic
	B.shell(m, w, L, h, p, { exit = "none" })
	local rift = part(m, "Rift", Vector3.new(14, 20, 0.6), CFrame.new(0, 12, -L + 3),
		{ Material = M.Neon, Color = rgb(110, 70, 200), CanCollide = false })
	glowing(rift, COSMIC, 50, 2)
	for _, x in { -14, 14 } do
		for _, z in { -12, -30 } do
			part(m, "Monolith", Vector3.new(3, 14, 3), CFrame.new(x, 7, z), { Color = rgb(20, 18, 28), Material = M.Basalt })
		end
	end
	for _, x in { -15, 15 } do
		for _, z in { -10, -30, -50 } do
			B.panel(m, x, h, z, p.light, 0.7, 34)
		end
	end
	return m
end

local function detailed(rooms)
	for _, m in rooms do
		B.shipDetails(m)
	end
	return rooms
end

function RoomPresets.BuildNormal(): { Model }
	return detailed({
		corridor(), bend(1), bend(-1), stairwell(), office(), messHall(), quarters(), medBay(),
		laboratory(), hygiene(), overflow(), pool(), hangar(), solarControl(), archive(), promenade(),
		cryo(), observatory(),
		airlock(), coolant(), suitStorage(), hydroponics(), gym(), memorial(), library(), dormitory(),
		laundry(), galley(), comms(), captain(), conference(), workshop(), cargo(), elevators(),
		infirmary(), helioscope(), xenolab(), quarantine(),
		bridge(), capacitors(), tunnel(), security(), brig(), recycling(), lounge(), cinema(),
		gallery(), arboretum(), decon(), mailRoom(),
	})
end

function RoomPresets.BuildSpecial(): { [string]: Model }
	return detailed({ Start = start(), Midpoint = midpoint(), Final = final() })
end

return RoomPresets
