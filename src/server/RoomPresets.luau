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
	part(m, "Grate", Vector3.new(2, 0.05, L), CFrame.new(0, 0.025, -L / 2), { Color = rgb(45, 46, 50), Material = M.DiamondPlate, CanCollide = false })
	B.panelGrid(m, w, L, h, 1, 6, p.light, 0.7)
	return m
end

-- Corridor corner: turns left (1) or right (-1).
local function bend(direction: number): Model
	local m = B.newRoom(if direction == 1 then "BendLeft" else "BendRight", { Weight = 2, Turn = direction })
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
	local m = B.newRoom("CryoBay", { Weight = 1, MinRoom = 35 })
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
	local m = B.newRoom("Final")
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

function RoomPresets.BuildNormal(): { Model }
	return {
		corridor(), bend(1), bend(-1), stairwell(), office(), messHall(), quarters(), medBay(),
		laboratory(), hygiene(), overflow(), pool(), hangar(), solarControl(), archive(), promenade(),
		cryo(), observatory(),
	}
end

function RoomPresets.BuildSpecial(): { [string]: Model }
	return { Start = start(), Midpoint = midpoint(), Final = final() }
end

return RoomPresets
