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
	gym = pal(rgb(175, 178, 182), M.SmoothPlastic, rgb(55, 57, 62), M.Rubber, rgb(150, 152, 156), M.SmoothPlastic, rgb(60, 64, 72), rgb(225, 232, 240)),
	library = pal(rgb(120, 95, 75), M.Plaster, rgb(85, 60, 42), M.WoodPlanks, rgb(95, 80, 66), M.Wood, rgb(55, 38, 28), rgb(255, 205, 150)),
	quarantine = pal(rgb(185, 195, 192), M.SmoothPlastic, rgb(160, 168, 165), M.SmoothPlastic, rgb(175, 182, 180), M.SmoothPlastic, rgb(90, 110, 105), rgb(215, 240, 235)),
	captain = pal(rgb(105, 78, 58), M.Wood, rgb(35, 40, 60), M.Carpet, rgb(80, 62, 48), M.Wood, rgb(60, 42, 30), rgb(255, 205, 150)),
	xeno = pal(rgb(90, 100, 98), M.Metal, rgb(50, 56, 55), M.DiamondPlate, rgb(70, 78, 76), M.Metal, rgb(50, 60, 58), rgb(190, 225, 215)),
	memorial = pal(rgb(95, 75, 62), M.Plaster, rgb(55, 40, 32), M.WoodPlanks, rgb(75, 60, 50), M.Wood, rgb(55, 38, 28), rgb(255, 200, 140)),
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

-- Research office: six cubicles with L-shaped desks, dual monitors, papers left mid-task.
local function office(): Model
	local m = B.newRoom("ResearchOffice", { Weight = 2 })
	local w, L, h, p = 36, 40, 11, PAL.office
	B.shell(m, w, L, h, p)
	local rand = Random.new(31)
	local fabric = { Color = rgb(105, 110, 122), Material = M.Fabric }
	local glass = { Color = rgb(200, 215, 220), Material = M.Glass, Transparency = 0.55, CastShadow = false }
	local cap = { Color = rgb(150, 152, 158), Material = M.Metal }
	local desk = { Color = rgb(150, 145, 135), Material = M.Wood }
	local dark = { Color = rgb(30, 31, 35) }
	local function panel(size: Vector3, x: number, z: number)
		-- Fabric lower half, frosted glass upper strip, metal cap.
		part(m, "Partition", Vector3.new(size.X, 4.2, size.Z), CFrame.new(x, 2.1, z), fabric)
		part(m, "PartitionGlass", Vector3.new(size.X, 1.2, size.Z), CFrame.new(x, 4.8, z), glass)
		part(m, "PartitionCap", Vector3.new(size.X + 0.1, 0.15, size.Z + 0.1), CFrame.new(x, 5.475, z), cap)
	end
	for _, cx in { -12, 12 } do
		local s = math.sign(cx)
		for _, cz in { -7.5, -17.5, -27.5 } do
			panel(Vector3.new(0.3, 0, 9), cx + s * 4.85, cz)
			for _, dz in { -4.35, 4.35 } do
				panel(Vector3.new(9.7, 0, 0.3), cx - s * 0.15, cz + dz)
			end
			-- L-shaped desk: main run along the outer panel, return along the back.
			part(m, "Desk", Vector3.new(2.6, 0.2, 7), CFrame.new(cx + s * 3.4, 2.9, cz), desk)
			part(m, "Desk", Vector3.new(5, 0.2, 2.2), CFrame.new(cx - s * 0.4, 2.9, cz - 3.1), desk)
			part(m, "DeskEnd", Vector3.new(2.4, 2.8, 0.2), CFrame.new(cx + s * 3.4, 1.4, cz + 3.4), dark)
			part(m, "DeskEnd", Vector3.new(0.2, 2.8, 2), CFrame.new(cx - s * 2.8, 1.4, cz - 3.1), dark)
			-- Two monitors, one still showing solar flux.
			for i, dz in { -1.3, 1.3 } do
				part(m, "MonitorStand", Vector3.new(0.4, 0.2, 0.8), CFrame.new(cx + s * 4.2, 3.1, cz + dz), dark)
				part(m, "Monitor", Vector3.new(0.25, 1.5, 2.2), CFrame.new(cx + s * 4.2, 3.95, cz + dz), dark)
				local screen = part(m, "Screen", Vector3.new(0.05, 1.2, 1.9), CFrame.new(cx + s * 4.05, 3.95, cz + dz),
					{ Material = M.Neon, Color = if i == 1 then rgb(25, 45, 70) else rgb(60, 30, 15), CanCollide = false }) :: Part
				if i == 2 then
					B.label(screen, "SOL FLUX +14%", if s == 1 then Enum.NormalId.Left else Enum.NormalId.Right, rgb(255, 160, 90), Enum.Font.Code)
				end
			end
			part(m, "Keyboard", Vector3.new(0.6, 0.06, 1.6), CFrame.new(cx + s * 3, 3.03, cz), dark)
			part(m, "Mug", Vector3.new(0.5, 0.4, 0.4), CFrame.new(cx + s * 2.6, 3.25, cz + 2.4) * CFrame.Angles(0, 0, math.pi / 2),
				{ Shape = Enum.PartType.Cylinder, Color = rgb(200, 195, 185) })
			for k = 1, 3 do
				part(m, "Paper", Vector3.new(0.8, 0.02, 1.1),
					CFrame.new(cx - s * rand:NextNumber(-1.5, 1.5), 3.01 + k * 0.021, cz - 3.1 + rand:NextNumber(-0.4, 0.4)) * CFrame.Angles(0, rand:NextNumber(0, math.pi), 0),
					{ Color = rgb(235, 232, 222), CanCollide = false })
			end
			-- Chair pushed back at an angle, as if someone stood up fast.
			chair(m, CFrame.new(cx + s * 0.6, 0, cz + rand:NextNumber(-1, 1)) * CFrame.Angles(0, math.rad(-s * 90) + rand:NextNumber(-0.7, 0.7), 0), rgb(45, 50, 65))
		end
	end
	-- Filing cabinets by the far wall, copier, water cooler.
	for _, sx in { -1, 1 } do
		for k = 0, 2 do
			local x = sx * (16.2 - k * 1.85)
			part(m, "FilingCabinet", Vector3.new(1.8, 4.5, 2), CFrame.new(x, 2.25, -38.95), { Color = rgb(120, 124, 130), Material = M.Metal })
			for d = 0, 2 do
				part(m, "Drawer", Vector3.new(1.5, 0.05, 0.05), CFrame.new(x, 1.2 + d * 1.4, -37.925), dark)
			end
		end
	end
	part(m, "Copier", Vector3.new(3, 3.5, 2.2), CFrame.new(-6.5, 1.75, -38.8), { Color = rgb(190, 190, 185) })
	part(m, "CopierLid", Vector3.new(2.6, 0.2, 1.8), CFrame.new(-6.5, 3.6, -38.8), dark)
	part(m, "Cooler", Vector3.new(1.4, 3.6, 1.4), CFrame.new(-16.8, 1.8, -1.4), { Color = rgb(225, 225, 220) })
	part(m, "Jug", Vector3.new(1.1, 1.1, 1.1), CFrame.new(-16.8, 4.15, -1.4), { Shape = Enum.PartType.Ball, Material = M.Glass, Color = rgb(150, 200, 255), Transparency = 0.3 })
	wallSign(m, w, -1, -17.5, 7.6, Vector2.new(8, 2.6), "SOLAR FLARE MODEL v7\nPEAK PREDICTED: ???\nWHY IS IT GETTING CLOSER", rgb(230, 232, 234), rgb(40, 50, 90), Enum.Font.Cartoon)
	wallSign(m, w, 1, -17.5, 7.6, Vector2.new(6, 2.2), "SOLSTICE SOLUTIONS\nCLOSER TO THE SUN", rgb(225, 140, 50), rgb(30, 25, 20))
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

-- Solar spectroscopy lab: two wet-lab islands, fume hoods, a spectrum chart, a deep freezer.
local function microscope(m: Model, x: number, y: number, z: number, facing: number)
	local white = { Color = rgb(225, 225, 220) }
	local dark = { Color = rgb(40, 40, 44) }
	part(m, "Microscope", Vector3.new(0.9, 0.15, 1.1), CFrame.new(x, y + 0.075, z), white)
	part(m, "Microscope", Vector3.new(0.25, 1.3, 0.25), CFrame.new(x - facing * 0.3, y + 0.8, z), white)
	part(m, "Microscope", Vector3.new(0.5, 0.35, 0.9), CFrame.new(x - facing * 0.05, y + 1.4, z) * CFrame.Angles(0, 0, facing * 0.3), white)
	part(m, "Microscope", Vector3.new(0.15, 0.5, 0.15), CFrame.new(x + facing * 0.15, y + 0.7, z), dark)
end

local function laboratory(): Model
	local m = B.newRoom("Laboratory", { Weight = 2, MinRoom = 3 })
	local w, L, h, p = 30, 40, 12, PAL.lab
	B.shell(m, w, L, h, p)
	local rand = Random.new(17)
	local steel = { Color = rgb(150, 155, 160), Material = M.Metal }
	local slate = { Color = rgb(35, 37, 42), Material = M.Slate }
	local liquid = { rgb(255, 150, 60), rgb(90, 160, 220), rgb(120, 200, 120), rgb(230, 220, 200) }
	for _, cx in { -7.5, 7.5 } do
		local s = math.sign(cx)
		part(m, "BenchCabinet", Vector3.new(4, 3, 20), CFrame.new(cx, 1.5, -18), { Color = rgb(200, 202, 205), Material = M.SmoothPlastic })
		for k = 0, 4 do
			part(m, "CabinetSeam", Vector3.new(4.02, 2.4, 0.06), CFrame.new(cx, 1.5, -10 - k * 4), { Color = rgb(150, 152, 156) })
		end
		part(m, "BenchTop", Vector3.new(4.3, 0.25, 20.3), CFrame.new(cx, 3.125, -18), slate)
		-- Reagent rack down the middle of the bench.
		for _, z in { -10, -18, -26 } do
			part(m, "RackPost", Vector3.new(0.2, 3.2, 0.2), CFrame.new(cx, 4.85, z), steel)
		end
		for _, y in { 5.1, 6.4 } do
			part(m, "RackShelf", Vector3.new(0.8, 0.12, 16.4), CFrame.new(cx, y, -18), steel)
			for z = -10.6, -25.4, -0.9 do
				if rand:NextNumber() < 0.7 then
					local bh = rand:NextNumber(0.4, 0.8)
					part(m, "Bottle", Vector3.new(bh, 0.35, 0.35), CFrame.new(cx + rand:NextNumber(-0.15, 0.15), y + 0.06 + bh / 2, z) * CFrame.Angles(0, 0, math.pi / 2),
						{ Shape = Enum.PartType.Cylinder, Color = liquid[rand:NextInteger(1, #liquid)], Material = M.Glass, Transparency = 0.25 })
				end
			end
		end
		-- Aisle side: microscopes and beaker clusters. Outer side: sinks and a centrifuge.
		local inner, outer = cx - s * 1.3, cx + s * 1.3
		for _, z in { -14, -22 } do
			microscope(m, inner, 3.25, z, -s)
		end
		for _, z in { -10.5, -18, -25.5 } do
			for k = 0, 2 do
				local bh = rand:NextNumber(0.5, 1)
				local glow = k == 0 and z == -18
				part(m, "Beaker", Vector3.new(bh, 0.55, 0.55), CFrame.new(inner + (k - 1) * 0.05, 3.25 + bh / 2, z + (k - 1) * 0.65) * CFrame.Angles(0, 0, math.pi / 2),
					{ Shape = Enum.PartType.Cylinder, Color = if glow then rgb(255, 140, 50) else liquid[rand:NextInteger(1, #liquid)],
						Material = if glow then M.Neon else M.Glass, Transparency = if glow then 0 else 0.3 })
			end
		end
		for _, z in { -12, -24 } do
			part(m, "Sink", Vector3.new(1.6, 0.03, 1.2), CFrame.new(outer, 3.265, z), { Color = rgb(20, 22, 24) })
			part(m, "Faucet", Vector3.new(0.15, 0.9, 0.15), CFrame.new(outer + s * 0.65, 3.7, z), steel)
			part(m, "Spout", Vector3.new(0.6, 0.12, 0.12), CFrame.new(outer + s * 0.4, 4.1, z), steel)
		end
		part(m, "Centrifuge", Vector3.new(0.9, 1.4, 1.4), CFrame.new(outer, 3.7, -18) * CFrame.Angles(0, 0, math.pi / 2),
			{ Shape = Enum.PartType.Cylinder, Color = rgb(215, 215, 210) })
	end
	-- Fume hoods along the left wall.
	for _, z in { -10, -22 } do
		local x = -w / 2 + 1.3
		part(m, "HoodBase", Vector3.new(2.6, 3, 5), CFrame.new(x, 1.5, z), { Color = rgb(200, 202, 205) })
		part(m, "HoodBody", Vector3.new(2.6, 4.2, 0.3), CFrame.new(x, 5.1, z - 2.35), { Color = rgb(190, 192, 195) })
		part(m, "HoodBody", Vector3.new(2.6, 4.2, 0.3), CFrame.new(x, 5.1, z + 2.35), { Color = rgb(190, 192, 195) })
		part(m, "HoodTop", Vector3.new(2.6, 1, 5), CFrame.new(x, 7.7, z), { Color = rgb(190, 192, 195) })
		part(m, "HoodSash", Vector3.new(0.08, 3.4, 4.4), CFrame.new(x + 1.26, 5.1, z),
			{ Color = rgb(190, 215, 225), Material = M.Glass, Transparency = 0.6, CastShadow = false })
		B.panel(m, x - 0.2, 7.2, z, rgb(220, 235, 245), 0.4, 6, Vector3.new(1.4, 0.15, 3.6))
		part(m, "Flask", Vector3.new(0.9, 0.7, 0.7), CFrame.new(x - 0.2, 3.45, z) * CFrame.Angles(0, 0, math.pi / 2),
			{ Shape = Enum.PartType.Cylinder, Color = rgb(255, 150, 60), Material = M.Glass, Transparency = 0.25 })
	end
	-- Spectrum chart with one line that shouldn't be there.
	local chart = B.onWall(m, w, 1, -18, 6.5, Vector2.new(10, 4.2), 0.1, "Whiteboard", { Color = rgb(230, 232, 234) }) :: Part
	local colors = { rgb(140, 60, 160), rgb(60, 70, 200), rgb(60, 160, 210), rgb(70, 180, 80), rgb(230, 210, 60), rgb(240, 140, 50), rgb(210, 50, 50) }
	for i, c in colors do
		part(m, "Spectrum", Vector3.new(0.05, 1.2, 1.1), CFrame.new(w / 2 - 0.125, 7.2, -18 - 3.85 + (i - 1) * 1.1), { Color = c, Material = M.Neon, CanCollide = false })
	end
	part(m, "AbsorptionLine", Vector3.new(0.06, 1.4, 0.12), CFrame.new(w / 2 - 0.13, 7.2, -16.1), { Color = rgb(10, 10, 10), CanCollide = false })
	B.label(chart, "\n\n\n656.3 nm ... ?  CORONAL OUTPUT x14  THIS IS NOT POSSIBLE", Enum.NormalId.Left, rgb(40, 50, 90), Enum.Font.Cartoon)
	-- Deep freezer and eyewash station near the far wall.
	part(m, "Freezer", Vector3.new(2.5, 8, 3.2), CFrame.new(w / 2 - 1.25, 4, -35), { Color = rgb(210, 212, 215), Material = M.Metal })
	local display = part(m, "FreezerDisplay", Vector3.new(0.05, 0.6, 1.4), CFrame.new(w / 2 - 2.525, 6.5, -35), { Material = M.Neon, Color = rgb(30, 50, 70), CanCollide = false }) :: Part
	B.label(display, "-80 C", Enum.NormalId.Left, rgb(150, 210, 255), Enum.Font.Code)
	part(m, "Eyewash", Vector3.new(1.4, 0.4, 1.4), CFrame.new(-w / 2 + 0.9, 3.6, -35), { Color = rgb(60, 160, 80) })
	part(m, "EyewashPipe", Vector3.new(0.2, 3.4, 0.2), CFrame.new(-w / 2 + 0.9, 1.7, -35), steel)
	wallSign(m, w, -1, -35, 5.6, Vector2.new(2.2, 0.7), "EYEWASH", rgb(40, 140, 70), rgb(240, 250, 240))
	wallSign(m, w, -1, -16, 10, Vector2.new(7, 1.1), "SOLAR SPECTROSCOPY LAB")
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

-- Cryo bay: tilted stasis pods with occupants. One pod is open, and footprints lead away from it.
local function cryo(): Model
	local m = B.newRoom("CryoBay", { Weight = 2, MinRoom = 12 })
	local w, L, h, p = 30, 46, 13, PAL.cryo
	B.shell(m, w, L, h, p)
	local metal = { Color = rgb(70, 78, 90), Material = M.Metal }
	local frost = rgb(200, 225, 240)
	local i = 0
	local openPod
	for _, side in { -1, 1 } do
		for c = -6, -38, -6.4 do
			i += 1
			local x = side * 11.5
			local plinth = part(m, "PodBase", Vector3.new(3.4, 0.8, 3.4), CFrame.new(x, 0.4, c), metal) :: Part
			part(m, "PodRing", Vector3.new(0.12, 3.2, 3.2), CFrame.new(x, 0.86, c) * CFrame.Angles(0, 0, math.pi / 2),
				{ Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(70, 120, 170), CanCollide = false })
			local tilt = CFrame.new(x, 0.8, c) * CFrame.Angles(0, 0, side * -0.15)
			part(m, "PodBack", Vector3.new(0.6, 7.6, 3), tilt * CFrame.new(side * 1.4, 3.8, 0), metal)
			part(m, "PodCap", Vector3.new(3.2, 0.6, 3.2), tilt * CFrame.new(0, 7.9, 0), metal)
			if i == 8 then
				openPod = Vector3.new(x, 0, c)
				part(m, "Frost", Vector3.new(4, 0.05, 4), CFrame.new(x - side * 3, 0.025, c), { Color = frost, Material = M.Ice, CanCollide = false })
			else
				part(m, "PodGlass", Vector3.new(7.2, 2.8, 2.8), tilt * CFrame.new(0, 4, 0) * CFrame.Angles(0, 0, math.pi / 2),
					{ Shape = Enum.PartType.Cylinder, Material = M.Glass, Color = rgb(170, 210, 235), Transparency = 0.55, CastShadow = false })
				part(m, "Frost", Vector3.new(7, 2.85, 2.85), tilt * CFrame.new(0, 4, 0) * CFrame.Angles(0, 0, math.pi / 2),
					{ Shape = Enum.PartType.Cylinder, Material = M.Glass, Color = frost, Transparency = 0.85, CastShadow = false, CanCollide = false })
				if i % 4 ~= 0 then
					part(m, "Occupant", Vector3.new(1, 4.6, 1.1), tilt * CFrame.new(side * 0.4, 3.3, 0), { Color = rgb(55, 62, 72), CanCollide = false })
					part(m, "OccupantHead", Vector3.new(0.9, 0.9, 0.9), tilt * CFrame.new(side * 0.4, 6.1, 0), { Shape = Enum.PartType.Ball, Color = rgb(60, 66, 76), CanCollide = false })
				end
			end
			-- Vitals console beside each pod.
			part(m, "PodConsole", Vector3.new(0.8, 1.8, 1.2), CFrame.new(side * 9.6, 0.9, c + 2.4), metal)
			local screen = part(m, "PodScreen", Vector3.new(0.05, 0.6, 0.9), CFrame.new(side * 9.175, 1.4, c + 2.4),
				{ Material = M.Neon, Color = if i == 8 then rgb(70, 20, 15) else rgb(15, 50, 30), CanCollide = false }) :: Part
			B.label(screen, if i == 8 then "OPEN" else "VITALS --", if side == -1 then Enum.NormalId.Right else Enum.NormalId.Left,
				if i == 8 then rgb(255, 90, 70) else rgb(120, 230, 150), Enum.Font.Code)
			local glow = Instance.new("PointLight")
			glow.Color = rgb(120, 180, 255)
			glow.Range = 7
			glow.Brightness = 0.5
			glow.Parent = plinth
		end
	end
	-- Frosty footprints from the open pod toward the exit.
	if openPod then
		local from = openPod + Vector3.new(-3.5, 0, 0)
		local to = Vector3.new(1, 0, -L + 4)
		for k = 0, 13 do
			local t = k / 13
			local pos = from:Lerp(to, t)
			local dir = (to - from).Unit
			local offset = Vector3.new(-dir.Z, 0, dir.X) * (if k % 2 == 0 then 0.35 else -0.35)
			part(m, "Footprint", Vector3.new(0.45, 0.03, 0.8), CFrame.lookAt(pos + offset + Vector3.new(0, 0.015, 0), pos + offset + dir + Vector3.new(0, 0.015, 0)),
				{ Color = frost, Material = M.Ice, CanCollide = false, Transparency = 0.2 })
		end
	end
	-- Frosted coolant pipes overhead, glowing trench lines along the floor.
	for _, sx in { -1, 1 } do
		part(m, "CoolantPipe", Vector3.new(L, 0.8, 0.8), CFrame.new(sx * 6, h - 1.2, -L / 2) * CFrame.Angles(0, math.pi / 2, 0),
			{ Shape = Enum.PartType.Cylinder, Color = rgb(190, 210, 225), Material = M.Ice })
		part(m, "TrenchLight", Vector3.new(0.5, 0.03, L - 6), CFrame.new(sx * 3, 0.015, -L / 2), { Material = M.Neon, Color = rgb(40, 80, 120), CanCollide = false })
	end
	-- Main stasis console near the exit.
	part(m, "MainConsole", Vector3.new(4, 3, 2), CFrame.new(-6.5, 1.5, -L + 2.5), metal)
	local main = part(m, "MainScreen", Vector3.new(3.4, 1.6, 0.05), CFrame.new(-6.5, 4, -L + 3.3) * CFrame.Angles(-0.3, 0, 0),
		{ Material = M.Neon, Color = rgb(20, 35, 50), CanCollide = false }) :: Part
	B.label(main, "STASIS 11/12\nPOD 08: OPEN", Enum.NormalId.Back, rgb(150, 210, 255), Enum.Font.Code)
	endSign(m, -L, 1, 0, 11, Vector2.new(10, 1.2), "CRYO STASIS - DO NOT WAKE")
	B.panelGrid(m, w, L, h, 1, 5, p.light, 0.5)
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

-- EVA suit storage: lit alcoves with full suits. One alcove is empty, its suit lies on the floor.
local function suit(m: Model, x: number, z: number, side: number, standing: boolean)
	local white = { Color = rgb(215, 215, 208), Material = M.Fabric }
	local grey = { Color = rgb(150, 152, 155), Material = M.Metal }
	if standing then
		for _, dz in { -0.4, 0.4 } do
			part(m, "SuitLeg", Vector3.new(0.65, 2.2, 0.65), CFrame.new(x, 1.1, z + dz), white)
			part(m, "SuitBoot", Vector3.new(0.9, 0.35, 0.75), CFrame.new(x - side * 0.1, 0.175, z + dz), grey)
		end
		part(m, "SuitTorso", Vector3.new(1.1, 2, 1.6), CFrame.new(x, 3.2, z), white)
		part(m, "SuitPack", Vector3.new(0.6, 1.6, 1.4), CFrame.new(x + side * 0.85, 3.3, z), grey)
		for _, dz in { -1.05, 1.05 } do
			part(m, "SuitArm", Vector3.new(0.5, 1.8, 0.5), CFrame.new(x, 3.1, z + dz), white)
		end
		part(m, "SuitHelmet", Vector3.new(1.5, 1.5, 1.5), CFrame.new(x, 4.95, z), { Shape = Enum.PartType.Ball, Color = rgb(225, 225, 220) })
		part(m, "SuitVisor", Vector3.new(0.1, 0.7, 1), CFrame.new(x - side * 0.72, 5, z), { Color = rgb(200, 160, 60), Material = M.Glass, Reflectance = 0.5 })
	else
		part(m, "SuitTorso", Vector3.new(2, 1.1, 1.6), CFrame.new(x, 0.55, z) * CFrame.Angles(0, 0.4, 0), white)
		part(m, "SuitLeg", Vector3.new(2.2, 0.65, 0.65), CFrame.new(x - side * 1.9, 0.33, z + 0.6) * CFrame.Angles(0, 0.6, 0), white)
		part(m, "SuitHelmet", Vector3.new(1.5, 1.5, 1.5), CFrame.new(x - side * 1.5, 0.75, z - 2.2), { Shape = Enum.PartType.Ball, Color = rgb(225, 225, 220) })
	end
end

local function suitStorage(): Model
	local m = B.newRoom("SuitStorage", { Weight = 1, MinRoom = 8 })
	local w, L, h, p = 22, 34, 11, PAL.hull
	B.shell(m, w, L, h, p)
	local fin = { Color = rgb(70, 74, 82), Material = M.Metal }
	local i = 0
	for _, side in { -1, 1 } do
		for c = -5, -29, -4 do
			i += 1
			for _, dz in { -1.85, 1.85 } do
				part(m, "AlcoveFin", Vector3.new(1.8, 8, 0.3), CFrame.new(side * (w / 2 - 0.9), 4, c + dz), fin)
			end
			part(m, "AlcoveTop", Vector3.new(1.8, 0.4, 3.4), CFrame.new(side * (w / 2 - 0.9), 8.2, c), fin)
			local backlight = part(m, "Lamp", Vector3.new(0.1, 6, 0.4), CFrame.new(side * (w / 2 - 0.05), 4, c),
				{ Material = M.Neon, Color = if i == 4 then rgb(140, 30, 25) else rgb(50, 80, 110), CanCollide = false }) :: Part
			local glow = Instance.new("PointLight")
			glow.Range = 6
			glow.Brightness = 0.4
			glow.Color = if i == 4 then rgb(255, 60, 50) else rgb(120, 170, 220)
			glow.Parent = backlight
			if i == 9 then
				suit(m, side * 6.5, c, side, false)
			else
				suit(m, side * (w / 2 - 1.4), c, side, true)
			end
		end
	end
	-- Oxygen tanks by the door, benches by the far wall.
	for k = 0, 2 do
		part(m, "O2Tank", Vector3.new(3.5, 0.8, 0.8), CFrame.new(-w / 2 + 0.6 + k * 0.9, 1.75, -1.5) * CFrame.Angles(0, 0, math.pi / 2),
			{ Shape = Enum.PartType.Cylinder, Color = rgb(60, 120, 70), Material = M.Metal })
	end
	for _, sx in { -1, 1 } do
		part(m, "Bench", Vector3.new(5, 1.4, 1.6), CFrame.new(sx * 6, 0.7, -32.6), { Color = rgb(70, 74, 82), Material = M.Metal })
	end
	wallSign(m, w, -1, -17, 9.6, Vector2.new(7, 1), "EVA PREP - CHECK SEALS TWICE")
	endSign(m, -L, 1, -6.5, 5, Vector2.new(4, 2.4), "SUIT STATUS\n07 MISSING\n09 RECOVERED?\n12 MISSING", rgb(25, 28, 30), rgb(255, 120, 90))
	B.panelGrid(m, w, L, h, 1, 4, p.light, 0.6)
	return m
end

-- Hydroponics: troughs of dead crops under hanging grow-light bars. One plant is still alive.
local function hydroponics(): Model
	local m = B.newRoom("Hydroponics", { Weight = 2, MinRoom = 6 })
	local w, L, h, p = 30, 44, 13, PAL.hydro
	B.shell(m, w, L, h, p)
	local rand = Random.new(21)
	local frame = { Color = rgb(85, 92, 88), Material = M.Metal }
	local pipeColor = rgb(170, 175, 172)
	local purple = rgb(200, 120, 255)
	for bed, x in { -10.5, -5.5, 5.5, 10.5 } do
		part(m, "Trough", Vector3.new(3, 1.6, 24), CFrame.new(x, 0.8, -20), frame)
		part(m, "Soil", Vector3.new(2.6, 0.1, 23.6), CFrame.new(x, 1.65, -20), { Color = rgb(55, 42, 30), Material = M.Ground })
		-- Irrigation pipe along the trough edge with drip heads.
		part(m, "Irrigation", Vector3.new(24, 0.25, 0.25), CFrame.new(x + 1.35, 1.85, -20) * CFrame.Angles(0, math.pi / 2, 0),
			{ Shape = Enum.PartType.Cylinder, Color = pipeColor, Material = M.Metal })
		for z = -9, -31, -4 do
			part(m, "Dripper", Vector3.new(0.15, 0.3, 0.15), CFrame.new(x + 1.35, 1.6, z), { Color = rgb(40, 40, 44) })
		end
		-- Plants: a stalk with a couple of drooping leaves each.
		for k = 1, 10 do
			local z = -9.5 - (k - 1) * 2.3 + rand:NextNumber(-0.4, 0.4)
			local alive = bed == 3 and k == 6
			local stem = rand:NextNumber(1.2, 2.6)
			local color = if alive then rgb(70, 190, 90) else (if rand:NextNumber() < 0.5 then rgb(95, 80, 50) else rgb(85, 85, 50))
			local base = CFrame.new(x + rand:NextNumber(-0.7, 0.4), 1.7, z) * CFrame.Angles(rand:NextNumber(-0.25, 0.25), 0, rand:NextNumber(-0.25, 0.25))
			local stalk = part(m, "Plant", Vector3.new(0.18, stem, 0.18), base * CFrame.new(0, stem / 2, 0), { Color = color, CanCollide = false })
			for leaf = 1, 2 do
				local yaw = rand:NextNumber(0, math.pi * 2)
				part(m, "Leaf", Vector3.new(0.9, 0.05, 0.4), base * CFrame.new(0, stem * (0.45 + leaf * 0.2), 0) * CFrame.Angles(0, yaw, 0)
					* CFrame.new(0.45, 0, 0) * CFrame.Angles(0, 0, if alive then 0.2 else -0.7),
					{ Color = color, Material = M.Grass, CanCollide = false, CastShadow = false })
			end
			if alive then
				local glow = Instance.new("PointLight")
				glow.Color = rgb(120, 255, 140)
				glow.Range = 7
				glow.Brightness = 0.6
				glow.Parent = stalk
			end
		end
		-- Grow-light bar hanging on two chains.
		local bar = part(m, "Lamp", Vector3.new(0.6, 0.25, 22), CFrame.new(x, 8, -20), { Material = M.Neon, Color = purple:Lerp(Color3.new(0, 0, 0), 0.4), CanCollide = false }) :: Part
		local light = Instance.new("SurfaceLight")
		light.Face = Enum.NormalId.Bottom
		light.Color = purple
		light.Range = 12
		light.Angle = 100
		light.Brightness = 0.6
		light.Parent = bar
		for _, z in { -12, -28 } do
			part(m, "Chain", Vector3.new(0.1, h - 8.125, 0.1), CFrame.new(x, 8.125 + (h - 8.125) / 2, z), { Color = rgb(120, 122, 126), Material = M.Metal })
		end
	end
	-- Main feed pipe across the far end, water tanks either side of the exit.
	for _, sx in { -1, 1 } do
		part(m, "WaterTank", Vector3.new(6, 3.5, 3.5), CFrame.new(sx * 9.5, 3, -40.25) * CFrame.Angles(0, 0, math.pi / 2),
			{ Shape = Enum.PartType.Cylinder, Color = rgb(150, 170, 175), Material = M.Metal })
		part(m, "TankBand", Vector3.new(0.3, 3.7, 3.7), CFrame.new(sx * 9.5, 4.5, -40.25) * CFrame.Angles(0, 0, math.pi / 2),
			{ Shape = Enum.PartType.Cylinder, Color = rgb(90, 100, 104), Material = M.Metal })
	end
	part(m, "FeedPipe", Vector3.new(w - 1, 0.5, 0.5), CFrame.new(0, 11, -42.8), { Shape = Enum.PartType.Cylinder, Color = pipeColor, Material = M.Metal })
	-- Seed tray shelves on the left wall, nutrient controls on the right.
	for _, y in { 2, 4, 6 } do
		B.onWall(m, w, -1, -20, y, Vector2.new(16, 0.15), 1.2, "SeedShelf", frame)
		for z = -13, -27, -2 do
			part(m, "SeedTray", Vector3.new(1, 0.25, 1.4), CFrame.new(-w / 2 + 0.6, y + 0.2, z), { Color = rgb(35, 36, 38) })
			part(m, "Sprouts", Vector3.new(0.8, 0.1, 1.2), CFrame.new(-w / 2 + 0.6, y + 0.375, z), { Color = rgb(90, 90, 55), Material = M.Grass, CanCollide = false })
		end
	end
	local screen = B.onWall(m, w, 1, -20, 6, Vector2.new(5, 3), 0.2, "Screen", { Color = rgb(10, 30, 15), Material = M.Neon }) :: Part
	B.label(screen, "NUTRIENT FLOW: 0%\nCO2: 0.04%\nLIGHT CYCLE: ERR", Enum.NormalId.Left, rgb(120, 230, 140), Enum.Font.Code)
	wallSign(m, w, 1, -20, 8.6, Vector2.new(7, 1.1), "HYDROPONICS - CROP CYCLE 412")
	for _, z in { -4, -38 } do
		B.panel(m, 0, h, z, rgb(220, 230, 225), 0.5, 16)
	end
	return m
end

-- Crew gym: treadmills facing a mirror wall, a squat rack, a bench, a punching bag.
local function gym(): Model
	local m = B.newRoom("Gym", { Weight = 1, MinRoom = 5 })
	local w, L, h, p = 30, 36, 12, PAL.gym
	B.shell(m, w, L, h, p)
	local black = { Color = rgb(28, 28, 32), Material = M.Rubber }
	local steel = { Color = rgb(150, 152, 158), Material = M.Metal }
	local dark = { Color = rgb(45, 47, 52), Material = M.Metal }

	-- Mirror wall on the left, treadmills facing it.
	B.onWall(m, w, -1, -15, 6.5, Vector2.new(24, 5), 0.1, "Mirror", { Color = rgb(150, 158, 165), Material = M.Glass, Reflectance = 0.45 })
	for _, z in { -7, -13, -19, -25 } do
		local x = -9.5
		part(m, "TreadmillDeck", Vector3.new(5, 0.4, 2.4), CFrame.new(x, 0.2, z), dark)
		part(m, "TreadmillBelt", Vector3.new(4.4, 0.05, 2), CFrame.new(x + 0.2, 0.425, z), black)
		for _, dz in { -1.1, 1.1 } do
			part(m, "Upright", Vector3.new(0.2, 3.4, 0.2), CFrame.new(x - 2.3, 2.1, z + dz), steel)
			part(m, "Handrail", Vector3.new(1.8, 0.15, 0.15), CFrame.new(x - 1.5, 3.3, z + dz), steel)
		end
		part(m, "Console", Vector3.new(0.6, 1, 2.4), CFrame.new(x - 2.3, 4.2, z) * CFrame.Angles(0, 0, -0.35), dark)
		part(m, "ConsoleScreen", Vector3.new(0.05, 0.6, 1.4), CFrame.new(x - 2.05, 4.3, z) * CFrame.Angles(0, 0, -0.35),
			{ Material = M.Neon, Color = rgb(30, 70, 60), CanCollide = false })
	end

	-- Lifting area on the right, on rubber matting.
	part(m, "Mat", Vector3.new(9, 0.06, 18), CFrame.new(9.5, 0.03, -15), { Color = rgb(35, 36, 40), Material = M.Rubber, CanCollide = false })
	-- Squat rack: four posts, a bar with plates.
	for _, dx in { -1.6, 1.6 } do
		for _, dz in { -1.6, 1.6 } do
			part(m, "RackPost", Vector3.new(0.3, 7, 0.3), CFrame.new(10 + dx, 3.56, -10 + dz), dark)
		end
	end
	part(m, "Barbell", Vector3.new(0.2, 0.2, 6), CFrame.new(10, 5, -10), steel)
	for _, dz in { -2.6, 2.6 } do
		part(m, "Plate", Vector3.new(0.3, 1.8, 1.8), CFrame.new(10, 5, -10 + dz) * CFrame.Angles(0, math.pi / 2, 0),
			{ Shape = Enum.PartType.Cylinder, Color = rgb(30, 30, 34), Material = M.Rubber })
	end
	-- Weight bench with uprights and an empty bar.
	part(m, "Bench", Vector3.new(1.2, 0.4, 4.5), CFrame.new(10, 1.6, -20), { Color = rgb(40, 40, 46), Material = M.Leather })
	part(m, "BenchLeg", Vector3.new(0.8, 1.34, 0.8), CFrame.new(10, 0.73, -18.4), dark)
	part(m, "BenchLeg", Vector3.new(0.8, 1.34, 0.8), CFrame.new(10, 0.73, -21.6), dark)
	for _, dx in { -1.4, 1.4 } do
		part(m, "BenchUpright", Vector3.new(0.25, 3.6, 0.25), CFrame.new(10 + dx, 1.86, -22.4), dark)
	end
	part(m, "Barbell", Vector3.new(4.2, 0.2, 0.2), CFrame.new(10, 3.4, -22.4), steel)
	-- Dumbbell rack in the corner.
	part(m, "DumbbellRack", Vector3.new(1.6, 2.4, 6), CFrame.new(w / 2 - 0.8, 1.2, -30), dark)
	for i = 0, 4 do
		local z = -32.4 + i * 1.2
		part(m, "Dumbbell", Vector3.new(0.9, 0.3, 0.3), CFrame.new(w / 2 - 0.8, 2.7, z), steel)
		for _, dx in { -0.4, 0.4 } do
			part(m, "DumbbellHead", Vector3.new(0.25, 0.6, 0.6), CFrame.new(w / 2 - 0.8 + dx, 2.7, z),
				{ Shape = Enum.PartType.Cylinder, Color = rgb(30, 30, 34), Material = M.Metal })
		end
	end
	-- Punching bag on a chain.
	part(m, "Chain", Vector3.new(0.15, h - 6.5, 0.15), CFrame.new(6, h - (h - 6.5) / 2, -30), steel)
	part(m, "PunchingBag", Vector3.new(3.5, 1.6, 1.6), CFrame.new(6, 4.75, -30) * CFrame.Angles(0, 0, math.pi / 2),
		{ Shape = Enum.PartType.Cylinder, Color = rgb(120, 30, 30), Material = M.Leather })

	-- Water fountain by the door.
	part(m, "Fountain", Vector3.new(1, 3, 1.4), CFrame.new(-w / 2 + 0.5, 1.5, -3), steel)
	wallSign(m, w, 1, -15, 9.5, Vector2.new(12, 1.4), "SOLSTICE WELLNESS: STAY STRONG FOR THE SUN", rgb(225, 140, 50), rgb(30, 25, 20))
	B.panelGrid(m, w, L, h, 2, 4, p.light, 0.7)
	return m
end

-- Memorial room (always room 24): pews, a wall of brass name plaques, candles, a book of condolences.
-- There is room on the wall for more names.
local MEMORIAL_NAMES = {
	"ABRAHAM LINCOLN", "DOLLY PARTON", "RYAN", "SEBASTIAN SOLACE", "JEFF", "AMELIA SHEPHERD",
	"HIBISCUS GALAXY ROSE", "WILLO WISP", "JANE DOE", "RON FROM ACCOUNTING", "EVERETT HARLOW", "ADDISON MONTGOMERY",
	"M", "CYNTHIA", "LILLIE", "MONICA STEVENS", "BEABADOOBEE", "TOWA BIRD",
	"RENEE RAPP", "TATE", "UMBREON", "CORSOLA", "DEWGONG", "SPHEAL",
	'"DAVE"', "HEROBRINE?", "APHELION", "ROOMBA", "NEKO TIFA",
}

local function candle(m: Model, x: number, y: number, z: number, lit: boolean, height: number)
	part(m, "Candle", Vector3.new(height, 0.3, 0.3), CFrame.new(x, y + height / 2, z) * CFrame.Angles(0, 0, math.pi / 2),
		{ Shape = Enum.PartType.Cylinder, Color = rgb(230, 222, 200) })
	if lit then
		local flame = part(m, "Flame", Vector3.new(0.12, 0.25, 0.12), CFrame.new(x, y + height + 0.15, z),
			{ Material = M.Neon, Color = rgb(255, 170, 70), CanCollide = false, CastShadow = false }) :: Part
		local glow = Instance.new("PointLight")
		glow.Color = rgb(255, 170, 90)
		glow.Range = 5
		glow.Brightness = 0.4
		glow.Parent = flame
	end
end

local function memorial(): Model
	local m = B.newRoom("MemorialRoom")
	local w, L, h, p = 26, 32, 13, PAL.memorial
	B.shell(m, w, L, h, p)
	local rand = Random.new(24)
	local wood = { Color = rgb(70, 48, 34), Material = M.Wood }
	local darkWood = { Color = rgb(45, 30, 22), Material = M.Wood }
	local brass = { Color = rgb(175, 145, 85), Material = M.Metal }

	-- Plaque wall: dark wood panels either side of the exit, five rows of three brass plaques each.
	local slots = {}
	for row = 0, 4 do
		for _, side in { -1, 1 } do
			for col = 0, 2 do
				table.insert(slots, { side * (4.8 + col * 2.2), 8.6 - row * 1.6 })
			end
		end
	end
	for _, side in { -1, 1 } do
		part(m, "PlaqueWall", Vector3.new(7.2, 8.8, 0.2), CFrame.new(side * 7, 5.4, -L + 0.1), darkWood)
		part(m, "PlaqueWallTrim", Vector3.new(7.6, 0.3, 0.35), CFrame.new(side * 7, 9.95, -L + 0.175), brass)
	end
	for i, slot in slots do
		local plate = part(m, "Plaque", Vector3.new(1.9, 0.8, 0.06), CFrame.new(slot[1], slot[2], -L + 0.23), brass) :: Part
		B.label(plate, MEMORIAL_NAMES[i] or "", Enum.NormalId.Back, rgb(45, 32, 18), Enum.Font.Garamond)
	end
	-- Dead flowers in vases along the base of the wall.
	for _, x in { -8.5, -5, 5, 8.5 } do
		part(m, "Vase", Vector3.new(1.2, 0.7, 0.7), CFrame.new(x, 0.6, -L + 0.9) * CFrame.Angles(0, 0, math.pi / 2),
			{ Shape = Enum.PartType.Cylinder, Color = rgb(60, 62, 70), Material = M.Glass })
		for k = 1, 4 do
			part(m, "DeadFlower", Vector3.new(0.08, 1.4, 0.08), CFrame.new(x, 1.8, -L + 0.9) * CFrame.Angles(rand:NextNumber(-0.4, 0.4), 0, rand:NextNumber(-0.4, 0.4)) * CFrame.new(0, 0.3, 0),
				{ Color = rgb(80, 70, 45), CanCollide = false })
			part(m, "Petals", Vector3.new(0.35, 0.2, 0.35), CFrame.new(x + rand:NextNumber(-0.4, 0.4), 2.4 + rand:NextNumber(-0.2, 0.2), -L + 0.9 + rand:NextNumber(-0.3, 0.3)),
				{ Shape = Enum.PartType.Ball, Color = if k % 2 == 0 then rgb(90, 40, 45) else rgb(110, 95, 70), CanCollide = false })
		end
	end
	-- Solstice sun emblem above the exit.
	local sun = part(m, "SunEmblem", Vector3.new(0.1, 2.4, 2.4), CFrame.new(0, 10.9, -L + 0.15) * CFrame.Angles(0, math.pi / 2, 0),
		{ Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(150, 85, 30), CanCollide = false }) :: Part
	glowing(sun, rgb(255, 160, 80), 10, 0.4)
	for k = 0, 7 do
		part(m, "SunRay", Vector3.new(0.25, 0.7, 0.08), CFrame.new(0, 10.9, -L + 0.12) * CFrame.Angles(0, 0, k * math.pi / 4) * CFrame.new(0, 1.5, 0), brass)
	end

	-- Pews with carved end panels and kneelers.
	for _, sx in { -1, 1 } do
		for _, z in { -7, -10.5, -14, -17.5, -21, -24.5 } do
			local x = sx * 6.6
			part(m, "PewSeat", Vector3.new(5.6, 0.35, 1.3), CFrame.new(x, 1.75, z), wood)
			part(m, "PewBack", Vector3.new(5.6, 2, 0.25), CFrame.new(x, 2.95, z + 0.6), wood)
			for _, dx in { -2.95, 2.95 } do
				part(m, "PewEnd", Vector3.new(0.3, 3.2, 1.6), CFrame.new(x + dx, 1.6, z + 0.1), darkWood)
			end
			part(m, "Kneeler", Vector3.new(5.6, 0.3, 0.5), CFrame.new(x, 0.35, z - 1.05), { Color = rgb(90, 30, 35), Material = M.Fabric })
		end
	end
	part(m, "Runner", Vector3.new(4, 0.04, L - 3), CFrame.new(0, 0.02, -L / 2 - 0.5), { Color = rgb(90, 30, 35), Material = M.Carpet, CanCollide = false })

	-- Candle shelves on both side walls; most of the candles have gone out.
	for _, side in { -1, 1 } do
		for _, zc in { -11, -21 } do
			B.onWall(m, w, side, zc, 3.5, Vector2.new(5, 0.2), 0.9, "CandleShelf", darkWood)
			for k = 0, 6 do
				local lit = rand:NextNumber() < 0.35
				candle(m, side * (w / 2 - 0.45), 3.6, zc - 2.1 + k * 0.7, lit, rand:NextNumber(0.4, 1))
			end
		end
	end

	-- Book of condolences on a lectern by the entrance.
	part(m, "Lectern", Vector3.new(1.2, 3.4, 1), CFrame.new(-6, 1.7, -3), darkWood)
	part(m, "LecternTop", Vector3.new(1.6, 0.15, 1.3), CFrame.new(-6, 3.5, -3) * CFrame.Angles(-0.3, 0, 0), darkWood)
	for _, dx in { -0.35, 0.35 } do
		local page = part(m, "Page", Vector3.new(0.65, 0.04, 0.9), CFrame.new(-6 + dx, 3.62, -3) * CFrame.Angles(-0.3, 0, dx * 0.3), { Color = rgb(235, 228, 205), CanCollide = false }) :: Part
		if dx > 0 then
			B.label(page, "SIGN HERE", Enum.NormalId.Top, rgb(60, 50, 40), Enum.Font.Garamond)
		end
	end

	wallSign(m, w, -1, -16, 9.5, Vector2.new(9, 1.6), "IN MEMORY OF THE CREW\nOF THE S.S. TOTALITY", rgb(45, 30, 22), rgb(210, 180, 120), Enum.Font.Garamond)
	wallSign(m, w, 1, -16, 9.5, Vector2.new(6, 1), "THERE IS ROOM FOR MORE", rgb(30, 25, 22), rgb(190, 170, 140), Enum.Font.Garamond)
	for _, z in { -8, -20 } do
		B.bulb(m, Vector3.new(0, h - 0.8, z), p.light, 16, 0.5, 1.2)
	end
	return m
end

-- Reading room: floor-to-ceiling shelves, study tables with green lamps, armchairs.
local function bankerLamp(m: Model, x: number, y: number, z: number)
	part(m, "LampBase", Vector3.new(0.6, 0.15, 0.6), CFrame.new(x, y + 0.075, z), { Color = rgb(150, 120, 50), Material = M.Metal })
	part(m, "LampStem", Vector3.new(0.12, 0.9, 0.12), CFrame.new(x, y + 0.6, z), { Color = rgb(150, 120, 50), Material = M.Metal })
	local shade = part(m, "Lamp", Vector3.new(1.4, 0.35, 0.6), CFrame.new(x, y + 1.2, z), { Color = rgb(30, 90, 50), Material = M.Glass, Transparency = 0.1 }) :: Part
	local light = Instance.new("PointLight")
	light.Color = rgb(255, 210, 150)
	light.Range = 10
	light.Brightness = 0.7
	light.Shadows = true
	light.Parent = shade
end

local function library(): Model
	local m = B.newRoom("ReadingRoom", { Weight = 1, MinRoom = 7 })
	local w, L, h, p = 30, 36, 13, PAL.library
	B.shell(m, w, L, h, p)
	local wood = { Color = rgb(70, 48, 34), Material = M.Wood }
	local rand = Random.new(8)
	local bookColors = { rgb(110, 40, 35), rgb(40, 60, 90), rgb(50, 80, 50), rgb(130, 105, 60), rgb(70, 50, 70), rgb(150, 140, 120), rgb(35, 35, 40) }

	-- Floor-to-ceiling shelving down both walls, in 6-stud bays.
	for _, side in { -1, 1 } do
		local back = side * (w / 2 - 0.1)
		for bay = 0, 4 do
			local z0 = -3 - bay * 6 -- bay runs from z0 to z0 - 6
			part(m, "ShelfBack", Vector3.new(0.2, 10.4, 6), CFrame.new(back, 5.2, z0 - 3), wood)
			for _, y in { 0.1, 2.6, 5.1, 7.6, 10.1 } do
				part(m, "ShelfBoard", Vector3.new(1.4, 0.2, 6), CFrame.new(side * (w / 2 - 0.9), y + 0.1, z0 - 3), wood)
			end
			-- Books on the four lower boards, packed with the odd gap.
			for _, y in { 0.3, 2.8, 5.3, 7.8 } do
				local z = z0 - 0.2
				while z > z0 - 5.6 do
					local bw = rand:NextNumber(0.25, 0.55)
					local bh = rand:NextNumber(1.3, 2.1)
					if rand:NextNumber() < 0.08 then
						z -= rand:NextNumber(0.5, 1.2) -- missing books
					elseif z - bw > z0 - 5.8 then
						part(m, "Book", Vector3.new(1.1, bh, bw), CFrame.new(side * (w / 2 - 0.85), y + bh / 2, z - bw / 2),
							{ Color = bookColors[rand:NextInteger(1, #bookColors)], Material = M.Fabric })
					end
					z -= bw + 0.02
				end
			end
		end
		-- Uprights between bays.
		for bay = 0, 5 do
			part(m, "ShelfPost", Vector3.new(1.6, 10.4, 0.3), CFrame.new(side * (w / 2 - 0.8), 5.2, -3 - bay * 6), wood)
		end
	end

	-- Two study tables with lamps and chairs.
	for _, sx in { -1, 1 } do
		local x = sx * 7.5
		for _, z in { -12, -23 } do
			part(m, "StudyTable", Vector3.new(3.4, 0.3, 6), CFrame.new(x, 2.85, z), wood)
			for _, dx in { -1.4, 1.4 } do
				for _, dz in { -2.6, 2.6 } do
					part(m, "TableLeg", Vector3.new(0.3, 2.7, 0.3), CFrame.new(x + dx, 1.35, z + dz), wood)
				end
			end
			bankerLamp(m, x, 3, z)
			for _, dz in { -1.6, 1.6 } do
				chair(m, CFrame.new(x - 2.6, 0, z + dz) * CFrame.Angles(0, math.rad(-90), 0), rgb(90, 40, 35))
				chair(m, CFrame.new(x + 2.6, 0, z + dz) * CFrame.Angles(0, math.rad(90), 0), rgb(90, 40, 35))
			end
		end
	end

	-- Reading nook by the far wall: rug, two armchairs, a floor lamp.
	part(m, "Rug", Vector3.new(10, 0.05, 5), CFrame.new(-6, 0.025, -31), { Color = rgb(90, 30, 35), Material = M.Fabric, CanCollide = false })
	chair(m, CFrame.new(-9, 0, -31) * CFrame.Angles(0, math.rad(-90), 0), rgb(110, 75, 50))
	chair(m, CFrame.new(-4.5, 0, -31) * CFrame.Angles(0, math.rad(90), 0), rgb(110, 75, 50))
	part(m, "LampStand", Vector3.new(0.25, 5, 0.25), CFrame.new(-6.75, 2.5, -33.5), { Color = rgb(40, 35, 30), Material = M.Metal })
	B.bulb(m, Vector3.new(-6.75, 5.5, -33.5), rgb(255, 205, 150), 14, 0.6, 1)

	-- Library ladder leaning on the right-hand shelves.
	for _, dz in { -0.7, 0.7 } do
		part(m, "LadderRail", Vector3.new(0.2, 10, 0.2), CFrame.new(w / 2 - 2.6, 5, -18 + dz) * CFrame.Angles(0, 0, -0.17), wood)
	end
	for i = 1, 8 do
		local y = i * 1.15
		part(m, "LadderRung", Vector3.new(0.15, 0.15, 1.4), CFrame.new(w / 2 - 2.6 + (y - 5) * math.tan(0.17), y, -18), wood)
	end

	endSign(m, -L, 1, 0, 11.4, Vector2.new(9, 1), "SOLSTICE LIBRARY - QUIET PLEASE", rgb(40, 28, 22), rgb(210, 180, 120))
	for _, z in { -6, -17.5, -29 } do
		B.bulb(m, Vector3.new(0, h - 0.8, z), rgb(255, 205, 150), 18, 0.6, 1.2)
	end
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

-- Crew laundry: stacked machines, one door hanging open, folded Solstice uniforms, a hanging rail.
local function laundry(): Model
	local m = B.newRoom("Laundry", { Weight = 1, MinRoom = 6 })
	local w, L, h, p = 22, 28, 10, PAL.hygiene
	B.shell(m, w, L, h, p)
	local white = { Color = rgb(215, 215, 210) }
	local steel = { Color = rgb(160, 162, 166), Material = M.Metal }
	local dark = { Color = rgb(30, 32, 36) }
	local uniform = rgb(200, 110, 40)
	local i = 0
	for z = -3.5, -21.5, -3 do
		for _, y in { 1.5, 4.5 } do
			i += 1
			local x = -w / 2 + 1.3
			part(m, "Washer", Vector3.new(2.6, 3, 2.6), CFrame.new(x, y, z), white)
			part(m, "ControlStrip", Vector3.new(0.05, 0.35, 2.2), CFrame.new(x + 1.325, y + 1.2, z), dark)
			part(m, "StatusLight", Vector3.new(0.05, 0.12, 0.12), CFrame.new(x + 1.35, y + 1.2, z + 0.8),
				{ Material = M.Neon, Color = if i % 3 == 0 then rgb(220, 60, 50) else rgb(50, 60, 55), CanCollide = false })
			if i == 5 then
				-- Door hanging open, clothes spilled on the floor.
				part(m, "DoorRing", Vector3.new(0.15, 2, 2), CFrame.new(x + 1.6, y - 0.1, z + 1.9) * CFrame.Angles(0, -1.2, 0),
					{ Shape = Enum.PartType.Cylinder, Color = rgb(160, 162, 166), Material = M.Metal })
				part(m, "DoorHole", Vector3.new(0.05, 1.7, 1.7), CFrame.new(x + 1.325, y - 0.1, z), { Shape = Enum.PartType.Cylinder, Color = rgb(15, 15, 18) })
				for k, c in { uniform, rgb(90, 95, 110), uniform, rgb(200, 200, 195) } do
					part(m, "Clothes", Vector3.new(1.1, 0.35, 0.9), CFrame.new(x + 2.3 + k * 0.6, 0.175, z + (k % 2) * 0.7 - 0.3) * CFrame.Angles(0, k, 0),
						{ Color = c, Material = M.Fabric, CanCollide = false })
				end
			else
				part(m, "DoorRing", Vector3.new(0.15, 2, 2), CFrame.new(x + 1.375, y - 0.1, z), { Shape = Enum.PartType.Cylinder, Color = rgb(160, 162, 166), Material = M.Metal })
				part(m, "DoorGlass", Vector3.new(0.1, 1.6, 1.6), CFrame.new(x + 1.5, y - 0.1, z), { Shape = Enum.PartType.Cylinder, Color = rgb(25, 30, 36), Material = M.Glass, Reflectance = 0.2 })
			end
		end
	end
	-- Detergent shelf above the machines.
	B.onWall(m, w, -1, -12.5, 7.4, Vector2.new(14, 0.2), 1, "Shelf", steel)
	for z = -6.5, -18.5, -1.5 do
		part(m, "Detergent", Vector3.new(0.6, 0.9, 0.5), CFrame.new(-w / 2 + 0.5, 7.95, z), { Color = if z % 3 == 0 then rgb(60, 120, 190) else rgb(230, 230, 225) })
	end
	-- Folding counter with stacks of folded uniforms and baskets.
	part(m, "Counter", Vector3.new(3, 3, 10), CFrame.new(w / 2 - 1.5, 1.5, -10), { Color = rgb(190, 192, 195) })
	part(m, "CounterTop", Vector3.new(3.2, 0.15, 10.2), CFrame.new(w / 2 - 1.6, 3.075, -10), steel)
	for k = 0, 2 do
		for layer = 0, 3 do
			part(m, "FoldedUniform", Vector3.new(1.3, 0.25, 1), CFrame.new(w / 2 - 1.6, 3.275 + layer * 0.25, -7 - k * 1.6),
				{ Color = if (k + layer) % 3 == 0 then rgb(90, 95, 110) else uniform, Material = M.Fabric })
		end
	end
	part(m, "Basket", Vector3.new(2, 1.2, 1.5), CFrame.new(w / 2 - 1.5, 3.75, -13), { Color = rgb(70, 100, 140), Material = M.Plastic })
	-- Hanging rail with uniforms.
	for _, z in { -19, -26 } do
		part(m, "RailPost", Vector3.new(0.2, 6.2, 0.2), CFrame.new(w / 2 - 1.5, 3.1, z), steel)
	end
	part(m, "Rail", Vector3.new(0.15, 0.15, 7), CFrame.new(w / 2 - 1.5, 6.1, -22.5), steel)
	for k = 0, 4 do
		part(m, "HangingUniform", Vector3.new(0.3, 3, 1.3), CFrame.new(w / 2 - 1.5, 4.5, -20.3 - k * 1.1) * CFrame.Angles(0, 0.15 * (k % 2), 0),
			{ Color = if k == 2 then rgb(90, 95, 110) else uniform, Material = M.Fabric, CanCollide = false })
	end
	-- Laundry cart.
	part(m, "Cart", Vector3.new(2, 1.6, 3), CFrame.new(5.5, 1.2, -22), { Color = rgb(120, 125, 130), Material = M.Metal })
	for _, o in { Vector3.new(-0.8, 0, -1.2), Vector3.new(0.8, 0, -1.2), Vector3.new(-0.8, 0, 1.2), Vector3.new(0.8, 0, 1.2) } do
		part(m, "Wheel", Vector3.new(0.2, 0.4, 0.4), CFrame.new(5.5 + o.X, 0.2, -22 + o.Z), { Shape = Enum.PartType.Cylinder, Color = rgb(30, 30, 30) })
	end
	part(m, "Drain", Vector3.new(1.4, 0.04, 1.4), CFrame.new(-3.5, 0.02, -14), { Color = rgb(30, 32, 34), Material = M.DiamondPlate, CanCollide = false })
	wallSign(m, w, 1, -4, 6.5, Vector2.new(6, 1.4), "UNIFORMS MUST BE WORN\nAT ALL TIMES")
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

-- Captain's office: wood paneling, an executive desk, a model of the ship, a final log entry.
local function captain(): Model
	local m = B.newRoom("CaptainsOffice", { Weight = 1, MinRoom = 15 })
	local w, L, h, p = 24, 24, 11, PAL.captain
	B.shell(m, w, L, h, p, { windows = { { side = "right", z = -12, y = 3, w = 10, h = 4.5 } } })
	local wood = { Color = rgb(75, 50, 35), Material = M.Wood }
	local brass = { Color = rgb(170, 140, 80), Material = M.Metal }
	local dark = { Color = rgb(28, 28, 32) }
	part(m, "Rug", Vector3.new(10, 0.05, 9), CFrame.new(-6.5, 0.025, -13), { Color = rgb(90, 30, 35), Material = M.Fabric, CanCollide = false })
	-- Executive desk on two drawer pedestals.
	part(m, "Desk", Vector3.new(7, 0.3, 3.2), CFrame.new(-6.5, 3.05, -13), wood)
	part(m, "DeskInlay", Vector3.new(4, 0.02, 1.8), CFrame.new(-6.5, 3.21, -13), { Color = rgb(40, 60, 45), Material = M.Leather, CanCollide = false })
	for _, x in { -9, -4 } do
		part(m, "Pedestal", Vector3.new(1.8, 2.9, 2.8), CFrame.new(x, 1.45, -13), wood)
		for d = 0, 2 do
			part(m, "Handle", Vector3.new(0.5, 0.08, 0.08), CFrame.new(x, 0.6 + d * 0.9, -11.56), brass)
		end
	end
	part(m, "Monitor", Vector3.new(1.8, 1.2, 0.15), CFrame.new(-6.5, 3.95, -12.2), dark)
	local screen = part(m, "Screen", Vector3.new(1.6, 1, 0.05), CFrame.new(-6.5, 3.95, -12.3), { Material = M.Neon, Color = rgb(20, 30, 45), CanCollide = false }) :: Part
	B.label(screen, "LOG 4,811", Enum.NormalId.Front, rgb(160, 200, 255), Enum.Font.Code)
	local plate = part(m, "Nameplate", Vector3.new(2, 0.5, 0.3), CFrame.new(-6.5, 3.45, -11.55), brass) :: Part
	B.label(plate, "CAPT. ######", Enum.NormalId.Back, rgb(40, 30, 20))
	part(m, "PhotoFrame", Vector3.new(0.7, 0.55, 0.08), CFrame.new(-8.8, 3.48, -13.6) * CFrame.Angles(0.2, 0.5, 0), wood)
	part(m, "Glass", Vector3.new(0.3, 0.4, 0.3), CFrame.new(-4.3, 3.4, -13.4) * CFrame.Angles(0, 0, math.pi / 2),
		{ Shape = Enum.PartType.Cylinder, Color = rgb(170, 110, 50), Material = M.Glass, Transparency = 0.3 })
	chair(m, CFrame.new(-6.5, 0, -15.8) * CFrame.Angles(0, math.pi, 0), rgb(60, 30, 25))
	for _, x in { -8.5, -4.5 } do
		chair(m, CFrame.new(x, 0, -9.6), rgb(60, 45, 40))
	end
	-- Model of the S.S. Totality in a glass case.
	part(m, "DisplayBase", Vector3.new(1.8, 3, 4.2), CFrame.new(-w / 2 + 0.9, 1.5, -4.6), wood)
	part(m, "DisplayCase", Vector3.new(1.6, 2.2, 4), CFrame.new(-w / 2 + 0.9, 4.1, -4.6), { Color = rgb(200, 215, 220), Material = M.Glass, Transparency = 0.7, CastShadow = false })
	part(m, "ModelHull", Vector3.new(0.35, 0.35, 3), CFrame.new(-w / 2 + 0.9, 4, -4.6), { Color = rgb(200, 202, 205), Material = M.Metal })
	for _, dz in { -0.8, 0.6 } do
		part(m, "ModelRing", Vector3.new(0.1, 1.2, 1.2), CFrame.new(-w / 2 + 0.9, 4, -4.6 + dz) * CFrame.Angles(0, math.pi / 2, 0),
			{ Shape = Enum.PartType.Cylinder, Color = rgb(160, 162, 166), Material = M.Metal })
	end
	part(m, "Bookcase", Vector3.new(1.5, 7, 5), CFrame.new(-w / 2 + 0.75, 3.5, -20), wood)
	local flag = B.onWall(m, w, -1, -12, 6.5, Vector2.new(3, 4.5), 0.1, "Flag", { Color = rgb(225, 140, 50), Material = M.Fabric }) :: Part
	B.label(flag, "SOLSTICE", Enum.NormalId.Right, rgb(40, 25, 15))
	-- Globe and bar cart by the window, the captain's last log on the wall.
	part(m, "GlobeStand", Vector3.new(0.3, 3, 0.3), CFrame.new(8.5, 1.5, -20), brass)
	part(m, "Globe", Vector3.new(1.8, 1.8, 1.8), CFrame.new(8.5, 3.9, -20), { Shape = Enum.PartType.Ball, Color = rgb(50, 90, 140) })
	part(m, "BarCart", Vector3.new(1.6, 2.8, 2.4), CFrame.new(w / 2 - 1, 1.4, -4.5), wood)
	for k = 0, 2 do
		part(m, "Bottle", Vector3.new(0.9, 0.35, 0.35), CFrame.new(w / 2 - 1, 3.25, -5.3 + k * 0.8) * CFrame.Angles(0, 0, math.pi / 2),
			{ Shape = Enum.PartType.Cylinder, Color = rgb(70 + k * 30, 50, 30), Material = M.Glass, Transparency = 0.2 })
	end
	local log = B.onWall(m, w, 1, -20.5, 5.5, Vector2.new(3.4, 2.2), 0.15, "LogTerminal", { Color = rgb(10, 18, 28), Material = M.Neon }) :: Part
	B.label(log, "LOG 4,811:\nTHEY ARE IN\nTHE WALLS", Enum.NormalId.Left, rgb(150, 200, 255), Enum.Font.Code)
	endSign(m, 0, -1, 7.5, 7.5, Vector2.new(4, 0.8), "CAPTAIN", rgb(60, 42, 30), rgb(210, 180, 120))
	for _, z in { -6, -17 } do
		B.bulb(m, Vector3.new(0, h - 0.8, z), rgb(255, 205, 150), 18, 0.6, 1.2)
	end
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

-- Elevator lobby: four framed elevators, call panels, a deck directory. None of them come.
local function elevator(m: Model, w: number, side: number, z: number, outOfOrder: boolean)
	local frame = { Color = rgb(55, 57, 63), Material = M.Metal }
	local steel = { Color = rgb(165, 168, 174), Material = M.Metal, Reflectance = 0.15 }
	local face = side * (w / 2) -- the wall's inner face
	local function at(depth: number, y: number, dz: number): CFrame
		return CFrame.new(face - side * depth / 2, y, z + dz)
	end
	-- Jambs, header and sill frame the opening.
	for _, dz in { -3.2, 3.2 } do
		part(m, "Jamb", Vector3.new(0.8, 10.5, 0.8), at(0.8, 5.25, dz), frame)
	end
	part(m, "Header", Vector3.new(0.8, 1.2, 5.6), at(0.8, 9.9, 0), frame)
	part(m, "Sill", Vector3.new(0.8, 0.1, 5.6), at(0.8, 0.05, 0), steel)
	-- Two sliding door panels with a seam down the middle.
	for _, dz in { -1.4, 1.4 } do
		part(m, "ElevatorDoor", Vector3.new(0.3, 9.2, 2.7), at(0.3, 4.7, dz), steel)
	end
	-- Floor indicator above the header.
	local indicator = part(m, "Indicator", Vector3.new(0.3, 0.8, 2), at(0.3, 11.2, 0), { Color = rgb(15, 12, 12) }) :: Part
	B.label(indicator, if outOfOrder then "--" else "?", if side == -1 then Enum.NormalId.Right else Enum.NormalId.Left, rgb(255, 70, 50), Enum.Font.Code)
	-- Call panel with up/down buttons beside the doors.
	part(m, "CallPanel", Vector3.new(0.15, 1.4, 0.7), at(0.15, 4.2, 4.1), frame)
	for i, y in { 4.5, 3.9 } do
		part(m, "CallButton", Vector3.new(0.08, 0.3, 0.3), at(0.38, y, 4.1),
			{ Material = M.Neon, Color = if i == 1 and not outOfOrder then rgb(230, 160, 50) else rgb(60, 50, 40), CanCollide = false })
	end
	if outOfOrder then
		-- Paper sign taped across the doors.
		local paper = part(m, "Notice", Vector3.new(0.05, 1.4, 2), at(0.66, 5.2, 0) * CFrame.Angles(0.06, 0, 0), { Color = rgb(235, 232, 220), CanCollide = false }) :: Part
		B.label(paper, "OUT OF ORDER", if side == -1 then Enum.NormalId.Right else Enum.NormalId.Left, rgb(30, 30, 30))
	end
end

local function elevators(): Model
	local m = B.newRoom("ElevatorLobby", { Weight = 1, MinRoom = 6 })
	local w, L, h, p = 26, 24, 14, PAL.promenade
	B.shell(m, w, L, h, p)
	elevator(m, w, -1, -7, false)
	elevator(m, w, -1, -16, true)
	elevator(m, w, 1, -7, true)
	elevator(m, w, 1, -16, false)

	-- Carpet runner down the middle.
	part(m, "Runner", Vector3.new(5, 0.04, L - 2), CFrame.new(0, 0.02, -L / 2), { Color = rgb(70, 25, 30), Material = M.Carpet, CanCollide = false })
	-- Benches and planters by the far wall, either side of the exit.
	for _, sx in { -1, 1 } do
		part(m, "Bench", Vector3.new(5, 1.5, 1.8), CFrame.new(sx * 8, 0.75, -L + 1.9), { Color = rgb(70, 72, 78), Material = M.Metal })
		part(m, "Planter", Vector3.new(1.6, 1.6, 1.6), CFrame.new(sx * (w / 2 - 1.2), 0.8, -L + 1.2), { Color = rgb(90, 88, 84), Material = M.Concrete })
		part(m, "Plant", Vector3.new(2.4, 2.4, 2.4), CFrame.new(sx * (w / 2 - 1.2), 2.6, -L + 1.2), { Shape = Enum.PartType.Ball, Color = rgb(60, 70, 45), Material = M.Grass })
	end
	-- Deck directory on the far wall.
	endSign(m, -L, 1, -7.5, 7, Vector2.new(5, 4),
		"DECK DIRECTORY\n1  DOCKING\n2  CREW\n3  RESEARCH\n4  SOLAR OBS.\n5  ENGINEERING\n6  [REMOVED]", rgb(25, 27, 32), rgb(200, 205, 215))
	-- Wall sconces between the elevators, ceiling strip lights over the runner.
	for _, sx in { -1, 1 } do
		B.bulb(m, Vector3.new(sx * (w / 2 - 0.6), 8.5, -11.5), rgb(255, 220, 180), 12, 0.6, 0.8)
	end
	for _, z in { -5, -12, -19 } do
		B.panel(m, 0, h, z, p.light, 0.7, 20, Vector3.new(2, 0.3, 5))
	end
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

-- Xenobiology lab: specimen tanks with something in them. One broke out and went into the vents.
local function specimen(m: Model, x: number, z: number, side: number)
	local flesh = { Color = rgb(45, 35, 60), CanCollide = false }
	part(m, "Specimen", Vector3.new(1.5, 1.5, 1.5), CFrame.new(x, 5.2, z), { Shape = Enum.PartType.Ball, Color = rgb(45, 35, 60), CanCollide = false })
	for k = 0, 2 do
		local yaw = k * 2.1
		local seg = CFrame.new(x, 4.6, z) * CFrame.Angles(0, yaw, 0)
		part(m, "Tentacle", Vector3.new(0.3, 1.3, 0.3), seg * CFrame.Angles(0.6, 0, 0) * CFrame.new(0, -0.6, 0), flesh)
		part(m, "Tentacle", Vector3.new(0.22, 1.2, 0.22), seg * CFrame.Angles(0.6, 0, 0) * CFrame.new(0, -1.2, 0) * CFrame.Angles(-0.9, 0, 0) * CFrame.new(0, -0.55, 0), flesh)
	end
	part(m, "Eye", Vector3.new(0.35, 0.35, 0.35), CFrame.new(x - side * 0.65, 5.4, z), { Shape = Enum.PartType.Ball, Material = M.Neon, Color = rgb(190, 40, 40), CanCollide = false })
end

local function xenolab(): Model
	local m = B.newRoom("XenoLab", { Weight = 1, MinRoom = 40 })
	local w, L, h, p = 30, 40, 13, PAL.xeno
	B.shell(m, w, L, h, p)
	local rand = Random.new(44)
	local metal = { Color = rgb(60, 64, 70), Material = M.Metal }
	local liquidColor = rgb(110, 190, 150)
	local i = 0
	local broken
	for _, side in { -1, 1 } do
		for _, z in { -7, -16, -25 } do
			i += 1
			local x = side * 11.5
			local base = part(m, "TankBase", Vector3.new(3.6, 1, 3.6), CFrame.new(x, 0.5, z), metal) :: Part
			part(m, "TankRing", Vector3.new(0.1, 3.3, 3.3), CFrame.new(x, 1.05, z) * CFrame.Angles(0, 0, math.pi / 2),
				{ Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(60, 140, 100), CanCollide = false })
			part(m, "TankCap", Vector3.new(3.6, 0.8, 3.6), CFrame.new(x, 8.5, z), metal)
			for _, dx in { -0.8, 0.8 } do
				part(m, "TankPipe", Vector3.new(0.3, h - 8.9, 0.3), CFrame.new(x + dx, 8.9 + (h - 8.9) / 2, z), metal)
			end
			if side == 1 and z == -16 then
				broken = Vector3.new(x, 0, z)
				part(m, "Spill", Vector3.new(0.05, 5, 6), CFrame.new(x - 3, 0.025, z) * CFrame.Angles(0, 0, math.pi / 2),
					{ Shape = Enum.PartType.Cylinder, Color = rgb(110, 60, 150), Material = M.Glass, Transparency = 0.15, CanCollide = false })
				for _ = 1, 10 do
					part(m, "Shard", Vector3.new(rand:NextNumber(0.3, 0.8), 0.05, rand:NextNumber(0.2, 0.6)),
						CFrame.new(x - rand:NextNumber(1.5, 5), 0.05, z + rand:NextNumber(-2.5, 2.5)) * CFrame.Angles(rand:NextNumber(-0.3, 0.3), rand:NextNumber(0, 3), 0),
						{ Color = rgb(190, 220, 210), Material = M.Glass, Transparency = 0.4, CanCollide = false })
				end
			else
				part(m, "TankGlass", Vector3.new(7, 3, 3), CFrame.new(x, 4.6, z) * CFrame.Angles(0, 0, math.pi / 2),
					{ Shape = Enum.PartType.Cylinder, Material = M.Glass, Color = rgb(170, 220, 200), Transparency = 0.6, CastShadow = false })
				part(m, "TankLiquid", Vector3.new(6.6, 2.7, 2.7), CFrame.new(x, 4.6, z) * CFrame.Angles(0, 0, math.pi / 2),
					{ Shape = Enum.PartType.Cylinder, Material = M.Glass, Color = liquidColor, Transparency = 0.55, CastShadow = false, CanCollide = false })
				specimen(m, x, z, side)
				for _ = 1, 4 do
					part(m, "Bubble", Vector3.new(0.2, 0.2, 0.2), CFrame.new(x + rand:NextNumber(-0.9, 0.9), rand:NextNumber(2, 7.5), z + rand:NextNumber(-0.9, 0.9)),
						{ Shape = Enum.PartType.Ball, Color = rgb(230, 255, 240), Transparency = 0.3, CanCollide = false })
				end
			end
			local glow = Instance.new("PointLight")
			glow.Color = rgb(130, 220, 170)
			glow.Range = 8
			glow.Brightness = 0.6
			glow.Parent = base
		end
	end
	-- The vent it escaped into, grille torn off, a residue trail leading to it.
	B.onWall(m, w, 1, -21, 1.2, Vector2.new(2, 1.6), 0.1, "VentHole", { Color = rgb(5, 5, 6) })
	part(m, "VentGrille", Vector3.new(1.6, 0.08, 2), CFrame.new(w / 2 - 2.2, 0.04, -20.6) * CFrame.Angles(0, 0.4, 0), metal)
	if broken then
		for k = 1, 5 do
			local t = k / 6
			local pos = broken:Lerp(Vector3.new(w / 2 - 0.5, 0, -21), t) + Vector3.new(-1.5 * (1 - t), 0.03, 0)
			part(m, "Residue", Vector3.new(0.05, 1.2 - t * 0.5, 1.6 - t * 0.6), CFrame.new(pos) * CFrame.Angles(0, k, math.pi / 2),
				{ Shape = Enum.PartType.Cylinder, Color = rgb(110, 60, 150), Material = M.Glass, Transparency = 0.2, CanCollide = false })
		end
	end
	-- Dissection table under a surgical lamp, a tray of instruments.
	part(m, "ExamTable", Vector3.new(3, 0.3, 6), CFrame.new(-6.5, 3, -33), { Color = rgb(170, 175, 178), Material = M.Metal })
	part(m, "ExamLeg", Vector3.new(0.8, 2.85, 0.8), CFrame.new(-6.5, 1.425, -33), metal)
	part(m, "Tray", Vector3.new(1.2, 0.08, 1.8), CFrame.new(-4, 3.2, -30.6), { Color = rgb(190, 192, 195), Material = M.Metal })
	part(m, "TrayStand", Vector3.new(0.15, 3.15, 0.15), CFrame.new(-4, 1.585, -30.6), metal)
	for k = -1, 1 do
		part(m, "Instrument", Vector3.new(0.08, 0.04, 1.2), CFrame.new(-4 + k * 0.3, 3.26, -30.6), { Color = rgb(220, 222, 225), Material = M.Metal })
	end
	part(m, "Chain", Vector3.new(0.12, h - 8.3, 0.12), CFrame.new(-6.5, 8.3 + (h - 8.3) / 2, -33), metal)
	local lampDisc = part(m, "Lamp", Vector3.new(0.4, 2.4, 2.4), CFrame.new(-6.5, 8.1, -33) * CFrame.Angles(0, 0, math.pi / 2),
		{ Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(150, 160, 165), CanCollide = false }) :: Part
	local spot = Instance.new("SpotLight")
	spot.Face = Enum.NormalId.Left
	spot.Angle = 50
	spot.Range = 10
	spot.Brightness = 1
	spot.Color = rgb(230, 240, 245)
	spot.Parent = lampDisc
	-- Specimen jars either side of the exit.
	for _, sx in { -1, 1 } do
		local x = sx * 9
		part(m, "JarShelf", Vector3.new(5, 0.2, 1.2), CFrame.new(x, 4, -L + 0.6), metal)
		part(m, "JarShelf", Vector3.new(5, 0.2, 1.2), CFrame.new(x, 6.5, -L + 0.6), metal)
		for _, y in { 4.1, 6.6 } do
			for k = -2, 2 do
				part(m, "Jar", Vector3.new(0.9, 0.6, 0.6), CFrame.new(x + k * 0.95, y + 0.45, -L + 0.6) * CFrame.Angles(0, 0, math.pi / 2),
					{ Shape = Enum.PartType.Cylinder, Color = liquidColor:Lerp(rgb(150, 120, 90), rand:NextNumber()), Material = M.Glass, Transparency = 0.35 })
			end
		end
	end
	endSign(m, -L, 1, 0, 11, Vector2.new(10, 1.2), "XENOBIOLOGY - LEVEL 4 CLEARANCE")
	wallSign(m, w, -1, -16, 10, Vector2.new(6, 1.6), "SPECIMEN ORIGIN:\nSOLAR CORONA ??", rgb(225, 228, 230), rgb(40, 50, 90), Enum.Font.Cartoon)
	B.panelGrid(m, w, L, h, 1, 4, p.light, 0.45)
	return m
end

-- Quarantine zone: a sealed plastic tunnel through the middle, isolation tents either side.
local function quarantine(): Model
	local m = B.newRoom("Quarantine", { Weight = 1, MinRoom = 45 })
	local w, L, h, p = 26, 40, 12, PAL.quarantine
	B.shell(m, w, L, h, p)
	local metal = { Color = rgb(150, 155, 158), Material = M.Metal }
	local plastic = { Color = rgb(215, 230, 225), Material = M.Glass, Transparency = 0.55, CanCollide = false, CastShadow = false }

	-- The tunnel: metal hoops every 8 studs with plastic sheeting between.
	local hoops = { -2, -10, -18, -26, -34 }
	for _, z in hoops do
		for _, sx in { -1, 1 } do
			part(m, "Hoop", Vector3.new(0.3, 8, 0.3), CFrame.new(sx * 3.6, 4, z), metal)
		end
		part(m, "Hoop", Vector3.new(7.5, 0.3, 0.3), CFrame.new(0, 8.15, z), metal)
	end
	for i = 1, #hoops - 1 do
		local zc = (hoops[i] + hoops[i + 1]) / 2
		for _, sx in { -1, 1 } do
			part(m, "Sheeting", Vector3.new(0.05, 8, 7.7), CFrame.new(sx * 3.6, 4, zc), plastic)
		end
		part(m, "Sheeting", Vector3.new(6.9, 0.05, 7.7), CFrame.new(0, 8.0, zc), plastic)
	end
	-- Hazard tape along the tunnel edges.
	for _, sx in { -1, 1 } do
		local i = 0
		for z = -1.5, -37.5, -1 do
			i += 1
			part(m, "Tape", Vector3.new(0.3, 0.05, 1), CFrame.new(sx * 4.1, 0.025, z),
				{ Color = if i % 2 == 0 then rgb(200, 160, 40) else rgb(25, 25, 25), CanCollide = false })
		end
	end

	-- Isolation tents with beds, either side of the tunnel.
	for _, side in { -1, 1 } do
		for k, z in { -10, -24 } do
			local x = side * 9.5
			part(m, "BedBase", Vector3.new(3, 2, 6.5), CFrame.new(x, 1, z), metal)
			part(m, "Mattress", Vector3.new(2.8, 0.4, 6.3), CFrame.new(x, 2.2, z), { Color = rgb(225, 228, 225), Material = M.Fabric })
			if (side == 1 and k == 1) or (side == -1 and k == 2) then
				part(m, "Sheet", Vector3.new(1.6, 0.8, 4.5), CFrame.new(x, 2.8, z - 0.5), { Color = rgb(235, 235, 232), Material = M.Fabric })
			end
			for _, dx in { -2.3, 2.3 } do
				part(m, "Tent", Vector3.new(0.05, 6, 8), CFrame.new(x + dx, 3, z), plastic)
			end
			for _, dz in { -4, 4 } do
				part(m, "Tent", Vector3.new(4.55, 6, 0.05), CFrame.new(x, 3, z + dz), plastic)
			end
			part(m, "Tent", Vector3.new(4.55, 0.05, 8), CFrame.new(x, 6.025, z), plastic)
			part(m, "IVStand", Vector3.new(0.15, 5, 0.15), CFrame.new(x - side * 1.9, 2.5, z - 2.5), metal)
		end
		-- Biohazard bins and bags near the far wall.
		for _, dz in { 0, 1.8 } do
			part(m, "BioBin", Vector3.new(2.2, 1.4, 1.4), CFrame.new(side * (w / 2 - 1), 1.1, -L + 1.2 + dz) * CFrame.Angles(0, 0, math.pi / 2),
				{ Shape = Enum.PartType.Cylinder, Color = rgb(210, 170, 40), Material = M.Plastic })
		end
		part(m, "Bag", Vector3.new(2, 0.8, 5), CFrame.new(side * 7.5, 0.4, -34), { Color = rgb(45, 48, 52), Material = M.Plastic })
		-- Air scrubbers high on the walls.
		B.onWall(m, w, side, -17, 9.5, Vector2.new(4, 2), 0.8, "AirScrubber", { Color = rgb(170, 175, 172), Material = M.Metal })
		B.bulb(m, Vector3.new(side * (w / 2 - 0.6), 10.5, -6), rgb(255, 50, 40), 14, 0.6, 1)
		B.bulb(m, Vector3.new(side * (w / 2 - 0.6), 10.5, -30), rgb(255, 50, 40), 14, 0.6, 1)
	end

	-- Hazmat suits hanging by the entrance.
	for _, dz in { -2.5, -4.6 } do
		part(m, "Hazmat", Vector3.new(1.2, 4.2, 1.8), CFrame.new(-w / 2 + 0.7, 3.2, dz), { Color = rgb(220, 190, 40), Material = M.Plastic })
		part(m, "HazmatHood", Vector3.new(1.4, 1.4, 1.4), CFrame.new(-w / 2 + 0.7, 5.95, dz), { Shape = Enum.PartType.Ball, Color = rgb(220, 190, 40), Material = M.Plastic })
	end

	wallSign(m, w, 1, -4, 6, Vector2.new(5, 2.4), "QUARANTINE ZONE\nDO NOT BREAK SEAL", rgb(200, 160, 40), rgb(30, 20, 10))
	endSign(m, -L, 1, 0, 10.4, Vector2.new(5, 1.2), "BIOHAZARD", rgb(160, 30, 30), rgb(255, 230, 220))
	for _, x in { -9.5, 9.5 } do
		for _, z in { -10, -24 } do
			B.panel(m, x, h, z, p.light, 0.5, 16)
		end
	end
	for _, z in { -6, -14, -22, -30 } do
		B.panel(m, 0, h, z, p.light, 0.4, 14, Vector3.new(2, 0.3, 3))
	end
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

-- Simulation bay: reclined VR couches for crew recreation. The last session never ended.
local function simulationBay(): Model
	local m = B.newRoom("SimulationBay", { Weight = 1, MinRoom = 16 })
	local w, L, h, p = 30, 34, 12, PAL.hull
	B.shell(m, w, L, h, p)
	local frameP = { Color = rgb(50, 54, 62), Material = M.Metal }
	local cushion = { Color = rgb(40, 60, 90), Material = M.Leather }
	-- Projection grid on the floor.
	for x = -12, 12, 4 do
		part(m, "GridLine", Vector3.new(0.12, 0.03, L - 2), CFrame.new(x, 0.015, -L / 2), { Material = M.Neon, Color = rgb(25, 60, 70), CanCollide = false })
	end
	for z = -3, -31, -4 do
		part(m, "GridLine", Vector3.new(w - 2, 0.04, 0.12), CFrame.new(0, 0.02, z), { Material = M.Neon, Color = rgb(25, 60, 70), CanCollide = false })
	end
	-- Couches in four columns, heads toward the far wall.
	local i = 0
	for _, x in { -11, -6.5, 6.5, 11 } do
		for _, z in { -8, -15, -22, -29 } do
			i += 1
			part(m, "CouchBase", Vector3.new(2.2, 1.2, 4.2), CFrame.new(x, 0.6, z + 0.4), frameP)
			part(m, "CouchSeat", Vector3.new(2, 0.4, 3.8), CFrame.new(x, 1.4, z + 0.6), cushion)
			part(m, "CouchBack", Vector3.new(2, 0.4, 2.6), CFrame.new(x, 2.3, z - 2.1) * CFrame.Angles(0.6, 0, 0), cushion)
			if i ~= 7 then
				part(m, "Headset", Vector3.new(1.1, 0.7, 0.9), CFrame.new(x, 3.25, z - 2.75) * CFrame.Angles(0.6, 0, 0), { Color = rgb(25, 25, 28) })
				part(m, "Visor", Vector3.new(0.9, 0.3, 0.05), CFrame.new(x, 3.4, z - 2.25) * CFrame.Angles(0.6, 0, 0), { Material = M.Neon, Color = rgb(40, 110, 130), CanCollide = false })
				part(m, "Cable", Vector3.new(0.1, h - 3.6, 0.1), CFrame.new(x, 3.6 + (h - 3.6) / 2, z - 3), { Color = rgb(20, 20, 22) })
			else
				-- Headset dangling from its cable over an empty couch.
				part(m, "Cable", Vector3.new(0.1, h - 5, 0.1), CFrame.new(x, 5 + (h - 5) / 2, z - 1), { Color = rgb(20, 20, 22) })
				part(m, "Headset", Vector3.new(1.1, 0.7, 0.9), CFrame.new(x, 4.6, z - 1) * CFrame.Angles(0.3, 0.8, 0.2), { Color = rgb(25, 25, 28) })
			end
		end
	end
	local screen = B.onWall(m, w, -1, -17, 8.5, Vector2.new(16, 4), 0.2, "Screen", { Color = rgb(15, 30, 40), Material = M.Neon }) :: Part
	B.label(screen, "SIMULATION: EARTH - BEACH 04\nSESSION ENDED 4,811 DAYS AGO\nPLEASE REMAIN RECLINED", Enum.NormalId.Right, rgb(150, 220, 235), Enum.Font.Code)
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.4)
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

-- Arboretum: a huge dead tree with its roots over the planter, a stone path, a dry pond, the sunlamp off.
local function deadTree(m: Model, x: number, z: number, scale: number, rand: Random)
	local bark = { Color = rgb(70, 55, 42), Material = M.Wood }
	-- Trunk in three tapering sections.
	local y = 0.1
	for k, size in { 3.2, 2.5, 1.8 } do
		local sh = 5 * scale
		part(m, "Trunk", Vector3.new(size * scale, sh, size * scale), CFrame.new(x, y + sh / 2, z) * CFrame.Angles(0, k * 0.3, 0), bark)
		y += sh
	end
	-- Main branches at two heights, each with a smaller branch off it.
	for k = 0, 5 do
		local height = if k < 3 then y - 1.5 * scale else y - 4 * scale
		local yaw = k * 1.05 + rand:NextNumber(-0.3, 0.3)
		local base = CFrame.new(x, height, z) * CFrame.Angles(0, yaw, 0) * CFrame.Angles(rand:NextNumber(0.6, 0.9), 0, 0)
		local len = rand:NextNumber(5, 7.5) * scale
		part(m, "Branch", Vector3.new(0.8 * scale, len, 0.8 * scale), base * CFrame.new(0, len / 2, 0), bark)
		local tip = base * CFrame.new(0, len * 0.7, 0)
		local sub = rand:NextNumber(2.5, 4) * scale
		part(m, "Twig", Vector3.new(0.4 * scale, sub, 0.4 * scale), tip * CFrame.Angles(0, 0, rand:NextNumber(-0.8, 0.8)) * CFrame.new(0, sub / 2, 0), bark)
	end
	-- Roots spreading over the soil.
	for k = 0, 4 do
		local yaw = k * 1.26 + rand:NextNumber(-0.2, 0.2)
		local len = rand:NextNumber(3, 4.5) * scale
		part(m, "Root", Vector3.new(0.7 * scale, 0.5 * scale, len),
			CFrame.new(x, 0.3, z) * CFrame.Angles(0, yaw, 0) * CFrame.new(0, 0, -len / 2 - 0.8 * scale) * CFrame.Angles(0.08, 0, 0), bark)
	end
	-- Dead leaves around it.
	for _ = 1, 18 do
		local r, a = rand:NextNumber(2, 7) * scale, rand:NextNumber(0, math.pi * 2)
		part(m, "DeadLeaf", Vector3.new(0.5, 0.03, 0.35), CFrame.new(x + math.cos(a) * r, 0.12, z + math.sin(a) * r) * CFrame.Angles(0, a, 0),
			{ Color = rgb(110, 80, 45), Material = M.Grass, CanCollide = false, CastShadow = false })
	end
end

local function arboretum(): Model
	local m = B.newRoom("Arboretum", { Weight = 1, MinRoom = 24 })
	local w, L, h, p = 40, 48, 24, PAL.hydro
	B.shell(m, w, L, h, p)
	local rand = Random.new(77)
	local stone = { Color = rgb(95, 98, 96), Material = M.Concrete }
	-- Raised planter around the big tree.
	for _, dz in { -6.3, 6.3 } do
		part(m, "PlanterRim", Vector3.new(13.2, 1.2, 0.6), CFrame.new(-10.5, 0.6, -19 + dz), stone)
	end
	for _, dx in { -6.3, 6.3 } do
		part(m, "PlanterRim", Vector3.new(0.6, 1.2, 12), CFrame.new(-10.5 + dx, 0.6, -19), stone)
	end
	part(m, "Soil", Vector3.new(12, 0.1, 12), CFrame.new(-10.5, 0.05, -19), { Color = rgb(55, 42, 30), Material = M.Ground })
	deadTree(m, -10.5, -19, 1, rand)
	-- Grass bed with a smaller tree.
	part(m, "Grass", Vector3.new(10, 0.06, 12), CFrame.new(12, 0.03, -36), { Color = rgb(85, 85, 52), Material = M.Grass, CanCollide = false })
	deadTree(m, 12, -36, 0.6, rand)
	-- Stone stepping path down the middle.
	for z = -2, -46, -2.6 do
		part(m, "PathStone", Vector3.new(2.2, 0.06, 1.6), CFrame.new(rand:NextNumber(-0.4, 0.4), 0.03, z) * CFrame.Angles(0, rand:NextNumber(-0.2, 0.2), 0),
			{ Color = rgb(110, 112, 108), Material = M.Slate, CanCollide = false })
	end
	-- Dry pond ringed with stones.
	part(m, "PondBed", Vector3.new(0.05, 6, 6), CFrame.new(-11, 0.025, -38) * CFrame.Angles(0, 0, math.pi / 2),
		{ Shape = Enum.PartType.Cylinder, Color = rgb(70, 65, 58), Material = M.Ground, CanCollide = false })
	for k = 0, 9 do
		local a = k / 10 * math.pi * 2
		part(m, "PondStone", Vector3.new(1.4, 0.8, 1.1), CFrame.new(-11 + math.cos(a) * 3.6, 0.4, -38 + math.sin(a) * 3.6) * CFrame.Angles(0, a, 0), stone)
	end
	-- Benches facing the path, old lamp posts.
	for _, z in { -12, -24 } do
		part(m, "BenchSeat", Vector3.new(1.8, 0.3, 5), CFrame.new(6.5, 1.6, z), { Color = rgb(100, 75, 55), Material = M.Wood })
		part(m, "BenchBack", Vector3.new(0.3, 1.6, 5), CFrame.new(7.25, 2.55, z), { Color = rgb(100, 75, 55), Material = M.Wood })
		for _, dz in { -2, 2 } do
			part(m, "BenchLeg", Vector3.new(1.4, 1.45, 0.3), CFrame.new(6.5, 0.725, z + dz), { Color = rgb(40, 40, 42), Material = M.Metal })
		end
	end
	for _, pos in { Vector3.new(-4.5, 0, -6), Vector3.new(4.5, 0, -18), Vector3.new(-4.5, 0, -30), Vector3.new(4.5, 0, -42) } do
		part(m, "LampPost", Vector3.new(0.3, 7, 0.3), CFrame.new(pos.X, 3.5, pos.Z), { Color = rgb(40, 40, 42), Material = M.Metal })
		B.bulb(m, Vector3.new(pos.X, 7.5, pos.Z), rgb(255, 210, 150), 20, 0.7, 1)
	end
	-- Dim emergency lighting while the sunlamp is down.
	for _, x in { -16, 16 } do
		B.panel(m, x, h, -24, rgb(200, 210, 220), 0.4, 26)
	end
	-- The artificial sun overhead, switched off.
	for _, x in { -12, 0, 12 } do
		for _, z in { -12, -36 } do
			part(m, "Sunlamp", Vector3.new(10, 0.3, 10), CFrame.new(x, h - 0.15, z), { Color = rgb(70, 68, 60), Material = M.Glass })
		end
	end
	wallSign(m, w, -1, -24, 14, Vector2.new(8, 1.4), "SUNLAMP OFFLINE", rgb(40, 12, 10), rgb(255, 120, 90), Enum.Font.Code)
	wallSign(m, w, 1, -36, 4, Vector2.new(7, 1.2), "PLEASE DO NOT TOUCH THE TREE")
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

-- Sample vault: freezers of sealed solar plasma samples. One freezer has been emptied.
local function sampleVault(): Model
	local m = B.newRoom("SampleVault", { Weight = 1, MinRoom = 7 })
	local w, L, h, p = 26, 32, 12, PAL.cryo
	B.shell(m, w, L, h, p)
	local metal = { Color = rgb(170, 175, 182), Material = M.Metal }
	local frameP = { Color = rgb(60, 66, 76), Material = M.Metal }
	local i = 0
	for _, side in { -1, 1 } do
		for _, z in { -5, -10, -15, -20, -25 } do
			i += 1
			local face = side * (w / 2)
			part(m, "FreezerBody", Vector3.new(1.8, 8.6, 4.4), CFrame.new(face - side * 0.9, 4.3, z), metal)
			for _, y in { 1, 3, 5, 7 } do
				part(m, "FreezerShelf", Vector3.new(0.6, 0.1, 4.2), CFrame.new(face - side * 2.1, y, z), frameP)
				if i ~= 3 then
					for k = -2, 2 do
						part(m, "Canister", Vector3.new(0.9, 0.45, 0.45), CFrame.new(face - side * 2.1, y + 0.5, z + k * 0.8) * CFrame.Angles(0, 0, math.pi / 2),
							{ Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(150, 80, 30) })
					end
				end
			end
			-- Frame and frosted door.
			for _, dz in { -2.15, 2.15 } do
				part(m, "FreezerFrame", Vector3.new(0.8, 8.6, 0.1), CFrame.new(face - side * 2.2, 4.3, z + dz), frameP)
			end
			if i == 3 then
				part(m, "Frost", Vector3.new(3, 0.05, 3), CFrame.new(face - side * 4, 0.025, z), { Color = rgb(200, 225, 240), Material = M.Ice, CanCollide = false })
			else
				part(m, "FreezerDoor", Vector3.new(0.06, 8.4, 4.2), CFrame.new(face - side * 2.55, 4.3, z),
					{ Color = rgb(200, 220, 235), Material = M.Glass, Transparency = 0.5, CastShadow = false })
			end
			local label = part(m, "FreezerLabel", Vector3.new(0.05, 0.4, 1.6), CFrame.new(face - side * 0.025, 9.2, z), { Color = rgb(30, 32, 36) }) :: Part
			B.label(label, `SOL-{if side == -1 then "A" else "B"}{i}`, if side == -1 then Enum.NormalId.Right else Enum.NormalId.Left, rgb(220, 225, 230), Enum.Font.Code)
		end
	end
	-- Scanning station with a canister on a cradle.
	part(m, "Station", Vector3.new(3, 3, 6), CFrame.new(6.8, 1.5, -15), metal)
	part(m, "Cradle", Vector3.new(1, 0.5, 1.6), CFrame.new(6.8, 3.25, -15), frameP)
	local sample = part(m, "Canister", Vector3.new(1.2, 0.6, 0.6), CFrame.new(6.8, 3.6, -15) * CFrame.Angles(0, math.pi / 2, 0) * CFrame.Angles(0, 0, 0),
		{ Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(255, 130, 40) }) :: Part
	glowing(sample, rgb(255, 140, 60), 8, 0.6)
	for _, dz in { -1.6, 1.6 } do
		part(m, "ScannerPost", Vector3.new(0.3, 3, 0.3), CFrame.new(6.8, 4.5, -15 + dz), frameP)
	end
	part(m, "ScannerTop", Vector3.new(0.4, 0.3, 3.5), CFrame.new(6.8, 6.15, -15), frameP)
	part(m, "ScanLine", Vector3.new(0.05, 0.05, 3.2), CFrame.new(6.8, 5.95, -15), { Material = M.Neon, Color = rgb(255, 50, 40), CanCollide = false })
	-- Cart of empty canister crates.
	part(m, "Cart", Vector3.new(2.4, 1.6, 4), CFrame.new(-6.5, 1.2, -18), frameP)
	part(m, "Crate", Vector3.new(2, 1, 1.6), CFrame.new(-6.5, 2.5, -17.2), { Color = rgb(150, 155, 160), Material = M.Metal })
	endSign(m, -L, 1, -7, 6, Vector2.new(4.5, 3), "VAULT TEMP\n-196 C\n-112 C\n-12 C  WARNING", rgb(20, 24, 30), rgb(255, 130, 100))
	B.panelGrid(m, w, L, h, 1, 4, p.light, 0.5)
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
		airlock(), coolant(), suitStorage(), hydroponics(), gym(), library(), dormitory(),
		laundry(), galley(), comms(), captain(), conference(), workshop(), cargo(), elevators(),
		infirmary(), helioscope(), xenolab(), quarantine(),
		bridge(), capacitors(), tunnel(), security(), brig(), recycling(), lounge(), simulationBay(),
		gallery(), arboretum(), decon(), sampleVault(),
	})
end

function RoomPresets.BuildSpecial(): { [string]: Model }
	return detailed({ Start = start(), MemorialRoom = memorial(), Midpoint = midpoint(), Final = final() })
end

return RoomPresets
