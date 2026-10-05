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
	control = pal(rgb(70, 74, 82), M.Metal, rgb(45, 48, 54), M.DiamondPlate, rgb(55, 58, 64), M.Metal, rgb(50, 54, 62), rgb(200, 210, 230)),
	galley = pal(rgb(200, 202, 198), M.CeramicTiles, rgb(120, 125, 125), M.CeramicTiles, rgb(170, 172, 170), M.SmoothPlastic, rgb(90, 95, 100), rgb(235, 240, 235)),
	executive = pal(rgb(120, 95, 80), M.Wood, rgb(60, 30, 35), M.Carpet, rgb(95, 80, 70), M.Wood, rgb(60, 42, 30), rgb(255, 215, 170)),
	pristine = pal(rgb(228, 228, 222), M.SmoothPlastic, rgb(235, 232, 225), M.Marble, rgb(218, 218, 212), M.SmoothPlastic, rgb(200, 165, 90), rgb(255, 245, 230)),
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

-- Simple crate.
local function crate(m: Model, cf: CFrame, size: Vector3, color: Color3?)
	part(m, "Crate", size, cf, { Color = color or rgb(110, 95, 70), Material = M.WoodPlanks })
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

-- Main ship corridor: ribbed walls, handrails, sealed hatches with wheels, an O2 box, windows, a cable tray overhead.
local function corridor(): Model
	local m = B.newRoom("Corridor", { Weight = 3 })
	local w, L, h, p = 12, 48, 10, PAL.hull
	B.shell(m, w, L, h, p, {
		windows = {
			{ side = "right", z = -16, y = 3.5, w = 6, h = 3 },
			{ side = "right", z = -32, y = 3.5, w = 6, h = 3 },
			{ side = "left", z = -4, y = 3.5, w = 6, h = 3 },
			{ side = "left", z = -44, y = 3.5, w = 6, h = 3 },
		},
	})
	local steel = { Color = rgb(150, 154, 160), Material = M.Metal }
	local dark = { Color = rgb(55, 58, 64), Material = M.Metal }
	for _, z in { -8, -24, -40 } do
		for _, sx in { -1, 1 } do
			part(m, "Rib", Vector3.new(0.4, h, 1), CFrame.new(sx * (w / 2 - 0.2), h / 2, z), { Color = p.trim, Material = M.Metal })
		end
	end
	-- Handrails on brackets, broken around the hatches on the left.
	local function rail(sx: number, z0: number, z1: number)
		local len = z0 - z1
		part(m, "Handrail", Vector3.new(len, 0.2, 0.2), CFrame.new(sx * (w / 2 - 0.65), 3.2, (z0 + z1) / 2) * CFrame.Angles(0, math.pi / 2, 0),
			{ Shape = Enum.PartType.Cylinder, Color = steel.Color, Material = steel.Material })
		for z = z0 - 1, z1 + 1, -4 do
			part(m, "RailBracket", Vector3.new(0.45, 0.12, 0.12), CFrame.new(sx * (w / 2 - 0.42), 3.2, z), steel)
		end
	end
	rail(1, -1, -47)
	rail(-1, -1, -13.6)
	rail(-1, -18.4, -29.6)
	rail(-1, -34.4, -47)
	-- Sealed hatches with locking wheels and red status lights.
	for _, z in { -16, -32 } do
		B.onWall(m, w, -1, z, 4.25, Vector2.new(4, 8.5), 0.3, "Hatch", { Color = rgb(80, 84, 92), Material = M.DiamondPlate })
		for _, dz in { -2.15, 2.15 } do
			part(m, "HatchFrame", Vector3.new(0.45, 8.8, 0.3), CFrame.new(-w / 2 + 0.225, 4.4, z + dz), { Color = rgb(200, 160, 40), Material = M.Metal })
		end
		part(m, "HatchWheel", Vector3.new(0.15, 1.6, 1.6), CFrame.new(-w / 2 + 0.38, 4.2, z), { Shape = Enum.PartType.Cylinder, Color = rgb(170, 40, 35), Material = M.Metal })
		part(m, "StatusLight", Vector3.new(0.1, 0.25, 0.25), CFrame.new(-w / 2 + 0.05, 7.6, z + 2.8), { Material = M.Neon, Color = rgb(220, 40, 30), CanCollide = false })
		wallSign(m, w, -1, z, 9.2, Vector2.new(2.4, 0.6), "SEALED", rgb(120, 30, 30), rgb(240, 220, 220))
	end
	-- Emergency O2 box between a window and a rib.
	local box = B.onWall(m, w, 1, -20.5, 4.6, Vector2.new(1.2, 1.6), 0.4, "O2Box", { Color = rgb(170, 40, 35), Material = M.Metal }) :: Part
	B.label(box, "EMERGENCY O2", Enum.NormalId.Left, rgb(240, 230, 220))
	-- Overhead cable tray with a few sagging cables, conduit along the left.
	part(m, "CableTray", Vector3.new(1.4, 0.15, L - 2), CFrame.new(0, h - 1.2, -L / 2), dark)
	for _, z in { -12, -29, -43 } do
		part(m, "TrayHanger", Vector3.new(0.1, 1.05, 0.1), CFrame.new(0, h - 0.6, z), dark)
		part(m, "LooseCable", Vector3.new(0.1, 1.4, 0.1), CFrame.new(0.4, h - 2, z + 2) * CFrame.Angles(0.3, 0, 0.2), { Color = rgb(30, 30, 32), CanCollide = false })
	end
	part(m, "Pipe", Vector3.new(L, 0.8, 0.8), CFrame.new(-(w / 2 - 0.5), h - 0.6, -L / 2) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Color = rgb(90, 94, 100), Material = M.Metal })
	-- Floor: centre grating and vents near the walls.
	part(m, "Grate", Vector3.new(2, 0.04, L), CFrame.new(0, 0.02, -L / 2), { Color = rgb(45, 46, 50), Material = M.DiamondPlate, CanCollide = false })
	for _, z in { -4, -20, -36 } do
		part(m, "FloorVent", Vector3.new(1.4, 0.05, 2), CFrame.new(-3.6, 0.025, z), { Color = rgb(25, 26, 30), Material = M.DiamondPlate, CanCollide = false })
	end
	wallSign(m, w, -1, -36.3, 6.5, Vector2.new(3.4, 1.2), "DECK 2 - SECTION C")
	B.panelGrid(m, w, L, h, 1, 6, p.light, 0.7)
	return m
end

-- Corridor corner: chamfered corner, pipes turning the bend, painted arrows on the floor, a junction box.
local function bend(direction: number): Model
	local m = B.newRoom(if direction == 1 then "BendLeft" else "BendRight", { Weight = 2, Turn = direction, Group = "Bend" })
	local w, L, h, p = 14, 14, 10, PAL.hull
	B.shell(m, w, L, h, p, { exit = if direction == 1 then "left" else "right" })
	local dark = { Color = rgb(55, 58, 64), Material = M.Metal }
	local pipeColor = rgb(90, 94, 100)
	local solid = direction -- the wall opposite the exit: +x for a left turn, -x for a right turn
	-- Chamfer the far corner on the solid side.
	part(m, "Chamfer", Vector3.new(4.2, h, 4.2), CFrame.new(solid * (w / 2), h / 2, -L) * CFrame.Angles(0, math.pi / 4, 0), { Color = p.wall, Material = p.wallMat })
	-- Pipe along the front wall that elbows round toward the exit.
	part(m, "Pipe", Vector3.new(w - 4, 0.8, 0.8), CFrame.new(-solid * 2, h - 0.6, -L + 0.5), { Shape = Enum.PartType.Cylinder, Color = pipeColor, Material = M.Metal })
	part(m, "PipeElbow", Vector3.new(1, 1, 1), CFrame.new(-solid * (w / 2 - 0.5), h - 0.6, -L + 0.5), { Shape = Enum.PartType.Ball, Color = pipeColor, Material = M.Metal })
	part(m, "Pipe", Vector3.new(3.4, 0.8, 0.8), CFrame.new(-solid * (w / 2 - 0.5), h - 0.6, -L + 2.2) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Color = pipeColor, Material = M.Metal })
	-- Direction sign and painted chevrons pointing to the exit.
	endSign(m, -L, 1, -solid * 1.5, 6, Vector2.new(5, 1.2), if direction == 1 then "<  SECTION D" else "SECTION D  >")
	for k = 0, 2 do
		local x = -solid * (1 + k * 1.6)
		for _, a in { 0.6, -0.6 } do
			part(m, "Chevron", Vector3.new(1.2, 0.05, 0.3), CFrame.new(x, 0.025, -L / 2) * CFrame.Angles(0, a * -solid, 0) * CFrame.new(0, 0, a * -0.35),
				{ Color = rgb(200, 160, 40), CanCollide = false })
		end
	end
	-- Junction box and conduit on the solid side wall.
	B.onWall(m, w, solid, -5, 5, Vector2.new(1.6, 2), 0.5, "JunctionBox", dark)
	part(m, "Conduit", Vector3.new(0.3, h - 6, 0.3), CFrame.new(solid * (w / 2 - 0.25), 6 + (h - 6) / 2, -5), dark)
	part(m, "Hazard", Vector3.new(w, 0.05, 1), CFrame.new(0, 0.025, -L + 0.5), { Color = rgb(200, 160, 40), CanCollide = false })
	B.panel(m, 0, h, -L / 2, p.light, 0.8, 18)
	return m
end

-- Deck stairwell: yellow step nosings, wall lights following the stairs, a big painted deck number, a fire extinguisher.
local function stairwell(): Model
	local m = B.newRoom("DeckStairwell", { Weight = 1, MinRoom = 3 })
	local w, L, rise, p = 14, 40, 10, PAL.hull
	local h = rise + 12
	B.shell(m, w, L, h, p, { exitY = rise })
	local steel = { Color = rgb(150, 152, 158), Material = M.Metal }
	local steps, run = 20, 22 / 20
	for i = 1, steps do
		local y = i * (rise / steps)
		local front = -8 - (i - 1) * run
		part(m, "Step", Vector3.new(w, y, run), CFrame.new(0, y / 2, front - run / 2), { Color = p.floor, Material = p.floorMat })
		part(m, "Nosing", Vector3.new(w - 1, 0.06, 0.25), CFrame.new(0, y + 0.03, front - 0.125), { Color = rgb(200, 160, 40), CanCollide = false })
	end
	part(m, "Landing", Vector3.new(w, rise, 10), CFrame.new(0, rise / 2, -35), { Color = p.floor, Material = p.floorMat })
	-- Wall handrails on posts following the slope.
	local length = math.sqrt(22 ^ 2 + rise ^ 2)
	local slope = math.atan2(rise, 22)
	for _, sx in { -1, 1 } do
		part(m, "Rail", Vector3.new(0.25, 0.25, length), CFrame.new(sx * (w / 2 - 0.5), 3 + rise / 2, -19) * CFrame.Angles(slope, 0, 0),
			{ Color = rgb(200, 160, 40), Material = M.Metal, CanCollide = false })
		for k = 0, 4 do
			local t = k / 4
			part(m, "RailPost", Vector3.new(0.12, 0.6, 0.12), CFrame.new(sx * (w / 2 - 0.5), 2.7 + rise * t, -8 - 22 * t), steel)
			-- Small amber wall lights stepping up with the stairs.
			local lamp = part(m, "Lamp", Vector3.new(0.15, 0.3, 0.6), CFrame.new(sx * (w / 2 - 0.075), 1 + rise * t, -9 - 20 * t), { Material = M.Neon, Color = rgb(170, 110, 40), CanCollide = false }) :: Part
			if k % 2 == 0 then
				local glow = Instance.new("PointLight")
				glow.Color = rgb(255, 170, 80)
				glow.Range = 8
				glow.Brightness = 0.5
				glow.Parent = lamp
			end
		end
	end
	-- Pipes angled up along the ceiling.
	part(m, "Pipe", Vector3.new(L, 0.7, 0.7), CFrame.new(w / 2 - 1, h - 0.6, -L / 2) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Color = rgb(90, 94, 100), Material = M.Metal })
	-- Deck markings and safety gear.
	local deck = B.onWall(m, w, -1, -35, rise + 5, Vector2.new(5, 3), 0.1, "DeckMark", { Color = rgb(200, 160, 40) }) :: Part
	B.label(deck, "DECK ??", Enum.NormalId.Right, rgb(25, 25, 25), Enum.Font.GothamBlack)
	wallSign(m, w, 1, -19, 9, Vector2.new(3, 1), "UP ^", rgb(200, 160, 40), rgb(25, 25, 25))
	part(m, "Extinguisher", Vector3.new(1.4, 0.6, 0.6), CFrame.new(w / 2 - 0.4, rise + 1.2, -38) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(190, 30, 30), Material = M.Metal })
	B.onWall(m, w, 1, -38, rise + 3.2, Vector2.new(1, 0.6), 0.1, "ExtSign", { Color = rgb(190, 30, 30) })
	for _, z in { -4, -14, -24, -35 } do
		B.panel(m, 0, h, z, rgb(240, 245, 255), 0.7, 28)
	end
	return m
end

---------------------------------------------------------------- crew areas

-- Research office: six cubicles with L-shaped desks, dual monitors, papers left mid-task.
local function office(): Model
	local m = B.newRoom("ResearchOffice", { Weight = 2 })
	local w, L, h, p = 36, 40, 11, PAL.office
	B.shell(m, w, L, h, p, {
		windows = {
			{ side = "left", z = -7.5, y = 6.2, w = 6, h = 2.6 },
			{ side = "left", z = -27.5, y = 6.2, w = 6, h = 2.6 },
			{ side = "right", z = -7.5, y = 6.2, w = 6, h = 2.6 },
			{ side = "right", z = -27.5, y = 6.2, w = 6, h = 2.6 },
		},
	})
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

-- Mess hall: long tables with trays left mid-meal, a serving line, drink dispensers, windows to space.
local function messHall(): Model
	local m = B.newRoom("MessHall", { Weight = 2, MinRoom = 2 })
	local w, L, h, p = 32, 40, 11, PAL.mess
	B.shell(m, w, L, h, p, {
		windows = {
			{ side = "right", z = -12, y = 3, w = 8, h = 3.5 },
			{ side = "right", z = -28, y = 3, w = 8, h = 3.5 },
			{ side = "left", z = -12, y = 3, w = 8, h = 3.5 },
			{ side = "left", z = -28, y = 3, w = 8, h = 3.5 },
		},
	})
	local rand = Random.new(40)
	local steel = { Color = rgb(170, 172, 175), Material = M.Metal }
	local dark = { Color = rgb(70, 72, 78), Material = M.Metal }
	local food = { rgb(180, 120, 60), rgb(110, 140, 70), rgb(200, 180, 120), rgb(140, 60, 50) }
	for _, x in { -8, 8 } do
		part(m, "Table", Vector3.new(3.2, 0.2, 22), CFrame.new(x, 2.9, -19), steel)
		for _, z in { -10, -19, -28 } do
			part(m, "TablePedestal", Vector3.new(0.6, 2.8, 0.6), CFrame.new(x, 1.4, z), dark)
			part(m, "TableFoot", Vector3.new(2.4, 0.15, 0.6), CFrame.new(x, 0.075, z), dark)
		end
		for _, dx in { -2.2, 2.2 } do
			part(m, "Bench", Vector3.new(1.2, 0.3, 22), CFrame.new(x + dx, 1.75, -19), { Color = rgb(60, 85, 120), Material = M.Fabric })
			for _, z in { -10, -19, -28 } do
				part(m, "BenchLeg", Vector3.new(0.3, 1.6, 0.3), CFrame.new(x + dx, 0.8, z), dark)
			end
		end
		-- Trays, plates and cups, a few knocked over.
		for _, z in { -11, -14.5, -18, -21.5, -25, -28 } do
			local tx = x + (if rand:NextNumber() < 0.5 then -0.7 else 0.7)
			part(m, "Tray", Vector3.new(1.2, 0.08, 1.6), CFrame.new(tx, 3.04, z) * CFrame.Angles(0, rand:NextNumber(-0.3, 0.3), 0), { Color = rgb(180, 180, 175) })
			part(m, "Plate", Vector3.new(0.06, 0.8, 0.8), CFrame.new(tx, 3.11, z) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(230, 228, 220) })
			part(m, "Food", Vector3.new(0.4, 0.15, 0.35), CFrame.new(tx + 0.1, 3.2, z), { Color = food[rand:NextInteger(1, #food)], Material = M.Ground, CanCollide = false })
			local tipped = rand:NextNumber() < 0.3
			part(m, "Cup", Vector3.new(0.45, 0.3, 0.3), CFrame.new(tx + 0.35, if tipped then 3.15 else 3.305, z + 0.55) * (if tipped then CFrame.Angles(0, 0.6, 0) else CFrame.Angles(0, 0, math.pi / 2)),
				{ Shape = Enum.PartType.Cylinder, Color = rgb(200, 205, 210) })
		end
	end
	-- Serving line with sneeze guard and food wells.
	part(m, "ServingCounter", Vector3.new(10, 3.4, 2.2), CFrame.new(-10, 1.7, -L + 1.1), steel)
	part(m, "SneezeGuard", Vector3.new(9.6, 1.2, 0.08), CFrame.new(-10, 4.2, -L + 1.9), { Color = rgb(200, 215, 220), Material = M.Glass, Transparency = 0.6 })
	for k = 0, 2 do
		part(m, "FoodWell", Vector3.new(2, 0.04, 1.2), CFrame.new(-13.5 + k * 2.3, 3.42, -L + 1.1), { Color = rgb(30, 32, 34) })
	end
	for k = 0, 5 do
		part(m, "StackedTray", Vector3.new(1.2, 0.08, 1.6), CFrame.new(-6.2, 3.44 + k * 0.09, -L + 1.1), { Color = rgb(180, 180, 175) })
	end
	wallSign(m, w, -1, -L + 3, 7, Vector2.new(5, 2), "TODAY:  ---\nTOMORROW: ---", rgb(25, 28, 30), rgb(120, 220, 140), Enum.Font.Code)
	-- Drink dispensers and a bin.
	for k = 0, 1 do
		local x = w / 2 - 1.25 - k * 2.6
		part(m, "Dispenser", Vector3.new(2.5, 7, 2), CFrame.new(x, 3.5, -L + 1), { Color = rgb(60, 62, 70), Material = M.Metal })
		part(m, "DispenserPanel", Vector3.new(2, 2.6, 0.05), CFrame.new(x, 5, -L + 2.025), { Material = M.Neon, Color = if k == 0 then rgb(30, 50, 80) else rgb(20, 20, 24), CanCollide = false })
	end
	part(m, "Bin", Vector3.new(1.4, 2.4, 1.4), CFrame.new(5, 1.2, -L + 1), { Color = rgb(60, 80, 60), Material = M.Plastic })
	B.panelGrid(m, w, L, h, 2, 4, p.light, 0.7)
	return m
end

-- Crew quarters: wood-panelled hallway of cabin doors (all 237), keycard readers, art, one door ajar, an abandoned cart.
local function quarters(): Model
	local m = B.newRoom("CrewQuarters", { Weight = 2, MinRoom = 4 })
	local w, L, h, p = 10, 64, 10, PAL.quarters
	B.shell(m, w, L, h, p)
	B.baseboards(m, w, L, p.trim)
	local wood = { Color = rgb(85, 60, 48), Material = M.Wood }
	local brass = { Color = rgb(170, 145, 80), Material = M.Metal }
	for _, side in { -1, 1 } do
		-- Wainscoting with a chair rail.
		B.onWall(m, w, side, -L / 2, 1.5, Vector2.new(L, 3), 0.15, "Wainscot", { Color = rgb(70, 48, 36), Material = M.Wood })
		B.onWall(m, w, side, -L / 2, 3.05, Vector2.new(L, 0.15), 0.25, "ChairRail", wood)
		local inward = if side == -1 then Enum.NormalId.Right else Enum.NormalId.Left
		for i = 0, 4 do
			local z = -6 - i * 12
			local ajar = side == 1 and i == 2
			-- Frame, door (or a dark gap with the door swung open), handle, number plate, keycard reader.
			for _, dz in { -2.2, 2.2 } do
				B.onWall(m, w, side, z + dz, 4.4, Vector2.new(0.4, 8.8), 0.4, "DoorFrame", wood)
			end
			B.onWall(m, w, side, z, 8.65, Vector2.new(4.8, 0.3), 0.4, "DoorFrame", wood)
			if ajar then
				-- Door swung well open into the corridor, its number plate and handle going with it.
				B.onWall(m, w, side, z, 4.25, Vector2.new(4, 8.5), 0.32, "DarkGap", { Color = rgb(8, 6, 6) })
				local doorCf = CFrame.new(side * (w / 2 - 0.3), 4.25, z - 2) * CFrame.Angles(0, -side * 1.1, 0) * CFrame.new(0, 0, 2)
				part(m, "CabinDoor", Vector3.new(0.3, 8.5, 4), doorCf, { Color = rgb(90, 55, 40), Material = M.Wood })
				local ajarPlate = part(m, "Plate", Vector3.new(0.05, 0.5, 1.2), doorCf * CFrame.new(-side * 0.175, 2.75, 0), { Color = rgb(170, 145, 80), Material = M.Metal }) :: Part
				B.label(ajarPlate, "237", if side == 1 then Enum.NormalId.Left else Enum.NormalId.Right, rgb(40, 30, 20), Enum.Font.Garamond)
				part(m, "Handle", Vector3.new(0.35, 0.15, 0.15), doorCf * CFrame.new(-side * 0.3, -0.25, 1.4), brass)
			else
				B.onWall(m, w, side, z, 4.25, Vector2.new(4, 8.5), 0.3, "CabinDoor", { Color = rgb(90, 55, 40), Material = M.Wood })
				part(m, "Handle", Vector3.new(0.35, 0.15, 0.15), CFrame.new(side * (w / 2 - 0.45), 4, z + 1.4), brass)
			end
			if not ajar then
				local plate = B.onWall(m, w, side, z, 7, Vector2.new(1.2, 0.5), 0.42, "Plate", { Color = rgb(170, 145, 80), Material = M.Metal }) :: Part
				B.label(plate, "237", inward, rgb(40, 30, 20), Enum.Font.Garamond)
			end
			B.onWall(m, w, side, z + 3, 4.2, Vector2.new(0.4, 0.7), 0.12, "CardReader", { Color = rgb(30, 30, 34) })
			part(m, "ReaderLight", Vector3.new(0.05, 0.12, 0.12), CFrame.new(side * (w / 2 - 0.145), 4.4, z + 3),
				{ Material = M.Neon, Color = if ajar then rgb(60, 220, 90) else rgb(220, 50, 40), CanCollide = false })
			if side == -1 and i == 3 then
				part(m, "DoNotDisturb", Vector3.new(0.04, 0.9, 0.4), CFrame.new(side * (w / 2 - 0.5), 3.6, z + 1.4), { Color = rgb(200, 60, 50), CanCollide = false })
			end
		end
		-- Framed art between the doors, under each sconce.
		for z = -12, -48, -12 do
			B.onWall(m, w, side, z, 4.8, Vector2.new(1.8, 1.4), 0.1, "ArtFrame", brass)
			B.onWall(m, w, side, z, 4.8, Vector2.new(1.5, 1.1), 0.12, "Art", { Color = rgb(60 + (z % 7) * 10, 70, 90), Material = M.Fabric })
			B.bulb(m, Vector3.new(side * (w / 2 - 0.6), 6.6, z), p.light, 12, 0.6, 0.8)
		end
	end
	-- Carpet runner with gold border, room-service cart, a laundry bag.
	part(m, "Runner", Vector3.new(5, 0.04, L - 2), CFrame.new(0, 0.02, -L / 2), { Color = rgb(90, 25, 30), Material = M.Carpet, CanCollide = false })
	for _, sx in { -1, 1 } do
		part(m, "RunnerBorder", Vector3.new(0.25, 0.045, L - 2), CFrame.new(sx * 2.4, 0.0225, -L / 2), { Color = rgb(170, 140, 70), Material = M.Fabric, CanCollide = false })
	end
	part(m, "ServiceCart", Vector3.new(1.6, 0.15, 3), CFrame.new(-3, 2.6, -36), { Color = rgb(200, 202, 205), Material = M.Metal })
	part(m, "ServiceCartShelf", Vector3.new(1.6, 0.15, 3), CFrame.new(-3, 0.9, -36), { Color = rgb(200, 202, 205), Material = M.Metal })
	for _, o in { Vector3.new(-0.7, 0, -1.4), Vector3.new(0.7, 0, -1.4), Vector3.new(-0.7, 0, 1.4), Vector3.new(0.7, 0, 1.4) } do
		part(m, "CartPost", Vector3.new(0.1, 2.5, 0.1), CFrame.new(-3 + o.X, 1.45, -36 + o.Z), brass)
	end
	part(m, "Cloche", Vector3.new(1, 1, 1), CFrame.new(-3, 2.9, -36.6), { Shape = Enum.PartType.Ball, Color = rgb(190, 192, 195), Material = M.Metal })
	part(m, "LaundryBag", Vector3.new(1.2, 1.4, 1), CFrame.new(3.6, 0.7, -42.5), { Color = rgb(200, 195, 180), Material = M.Fabric })
	for z = -8, -56, -16 do
		B.bulb(m, Vector3.new(0, h - 0.6, z), p.light, 16, 0.6, 1)
	end
	return m
end

-- Medical bay: reception, waiting chairs, a triage bay with a gurney and a monitor showing a flat line.
local function medBay(): Model
	local m = B.newRoom("MedBay", { Weight = 2 })
	local w, L, h, p = 28, 34, 10, PAL.med
	B.shell(m, w, L, h, p)
	B.baseboards(m, w, L, p.trim)
	local steel = { Color = rgb(170, 175, 178), Material = M.Metal }
	local white = { Color = rgb(225, 228, 225) }
	-- Reception counter with a ticket display.
	part(m, "Counter", Vector3.new(8, 3.5, 2), CFrame.new(-9, 1.75, -27), { Color = rgb(170, 180, 176) })
	local counterSign = part(m, "CounterSign", Vector3.new(6, 1, 0.05), CFrame.new(-9, 2.3, -25.975), { Color = rgb(225, 232, 228) }) :: Part
	B.label(counterSign, "SOLSTICE MEDICAL - PLEASE WAIT", Enum.NormalId.Back, rgb(50, 80, 72), Enum.Font.GothamBold)
	part(m, "CounterTop", Vector3.new(8.3, 0.15, 2.3), CFrame.new(-9, 3.575, -27), { Color = rgb(120, 130, 128), Material = M.Marble })
	part(m, "CounterReturn", Vector3.new(2, 3.5, 4), CFrame.new(-12, 1.75, -30), { Color = rgb(170, 180, 176) })
	part(m, "Terminal", Vector3.new(1.4, 1, 0.15), CFrame.new(-9.5, 4.25, -27.4), { Color = rgb(30, 30, 34) })
	local nowServing = B.onWall(m, w, -1, -27, 7, Vector2.new(3.4, 1.4), 0.15, "Display", { Color = rgb(20, 10, 10), Material = M.Neon }) :: Part
	B.label(nowServing, "NOW SERVING\n000", Enum.NormalId.Right, rgb(255, 80, 60), Enum.Font.Code)
	-- Waiting area: rows of linked chairs, a magazine table.
	for _, z in { -6, -10.5, -15 } do
		part(m, "ChairBeam", Vector3.new(9.6, 0.3, 0.4), CFrame.new(8.1, 0.9, z), steel)
		for _, x in { 4.5, 6.9, 9.3, 11.7 } do
			chair(m, CFrame.new(x, 0, z), rgb(80, 120, 120))
		end
	end
	part(m, "MagazineTable", Vector3.new(3, 0.2, 2), CFrame.new(8, 1.6, -19.5), { Color = rgb(150, 140, 120), Material = M.Wood })
	part(m, "TableLeg", Vector3.new(0.4, 1.5, 0.4), CFrame.new(8, 0.75, -19.5), steel)
	for k = 0, 2 do
		part(m, "Magazine", Vector3.new(0.8, 0.03, 1.1), CFrame.new(7.3 + k * 0.7, 1.72 + k * 0.03, -19.5) * CFrame.Angles(0, k * 0.4, 0), { Color = rgb(200, 120 + k * 30, 80), CanCollide = false })
	end
	-- Triage bay: gurney with rails, IV stand, vitals cart, half-drawn curtain.
	part(m, "Gurney", Vector3.new(3, 0.4, 7), CFrame.new(-9, 2.6, -10), white)
	part(m, "GurneyPillow", Vector3.new(2, 0.4, 1.2), CFrame.new(-9, 3, -13), { Color = rgb(235, 235, 232), Material = M.Fabric })
	for _, dx in { -1.6, 1.6 } do
		part(m, "GurneyRail", Vector3.new(0.12, 0.6, 5), CFrame.new(-9 + dx, 3.1, -10), steel)
	end
	for _, dz in { -3, 3 } do
		part(m, "GurneyLeg", Vector3.new(2.6, 2.4, 0.4), CFrame.new(-9, 1.2, -10 + dz), steel)
	end
	part(m, "IVStand", Vector3.new(0.15, 6, 0.15), CFrame.new(-11.5, 3, -13), steel)
	part(m, "IVBag", Vector3.new(0.6, 1, 0.3), CFrame.new(-11.5, 5.6, -12.8), { Color = rgb(220, 230, 235), Material = M.Glass, Transparency = 0.3 })
	part(m, "VitalsCart", Vector3.new(1.2, 3, 1.2), CFrame.new(-6.2, 1.5, -13.5), steel)
	part(m, "VitalsScreen", Vector3.new(1.2, 1, 0.12), CFrame.new(-6.2, 3.5, -13.5), { Color = rgb(30, 30, 34) })
	part(m, "FlatLine", Vector3.new(0.9, 0.04, 0.02), CFrame.new(-6.2, 3.5, -13.43), { Material = M.Neon, Color = rgb(80, 255, 120), CanCollide = false })
	part(m, "CurtainRail", Vector3.new(6, 0.1, 0.1), CFrame.new(-9, h - 0.05, -15.5), steel)
	part(m, "Curtain", Vector3.new(3.5, 7, 0.1), CFrame.new(-10.25, h - 3.6, -15.5), { Color = rgb(150, 190, 175), Material = M.Fabric, CanCollide = false })
	-- Medicine cabinet and sharps bin.
	B.onWall(m, w, -1, -20, 6, Vector2.new(4, 3), 0.2, "MedCabinet", white)
	for _, y in { 4.55, 5.55, 6.55 } do
		B.onWall(m, w, -1, -20, y, Vector2.new(4, 0.1), 0.8, "MedShelf", white)
	end
	for k = 0, 5 do
		part(m, "Pill", Vector3.new(0.5, 0.25, 0.25), CFrame.new(-w / 2 + 0.5, 4.85 + (k % 2) * 1, -21.4 + math.floor(k / 2) * 1.3) * CFrame.Angles(0, 0, math.pi / 2),
			{ Shape = Enum.PartType.Cylinder, Color = rgb(200, 140 + k * 15, 80) })
	end
	part(m, "CabinetGlass", Vector3.new(0.05, 3, 4), CFrame.new(-w / 2 + 0.825, 6, -20), { Color = rgb(200, 215, 220), Material = M.Glass, Transparency = 0.6 })
	part(m, "SharpsBin", Vector3.new(0.8, 1, 0.6), CFrame.new(-w / 2 + 0.4, 3.5, -17.2), { Color = rgb(200, 40, 40), Material = M.Plastic })
	part(m, "Clock", Vector3.new(0.3, 2, 2), CFrame.new(w / 2 - 0.15, 7.5, -22), { Shape = Enum.PartType.Cylinder, Color = rgb(230, 230, 225) })
	part(m, "Hand", Vector3.new(0.05, 0.8, 0.08), CFrame.new(w / 2 - 0.325, 7.85, -22), { Color = rgb(20, 20, 20), CanCollide = false })
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
		-- Sash raised most of the way, so you can see what was left running inside.
		part(m, "HoodSash", Vector3.new(0.08, 1.4, 4.4), CFrame.new(x + 1.26, 6.5, z),
			{ Color = rgb(200, 225, 235), Material = M.Glass, Transparency = 0.8, CastShadow = false })
		part(m, "SashHandle", Vector3.new(0.15, 0.12, 3.6), CFrame.new(x + 1.35, 5.8, z), steel)
		B.panel(m, x - 0.2, 7.2, z, rgb(220, 235, 245), 0.5, 7, Vector3.new(1.4, 0.15, 3.6))
		-- Ring stand holding a round flask that still glows.
		part(m, "StandBase", Vector3.new(1, 0.1, 0.8), CFrame.new(x - 0.3, 3.05, z - 1), steel)
		part(m, "StandRod", Vector3.new(0.08, 2.4, 0.08), CFrame.new(x - 0.7, 4.2, z - 1), steel)
		part(m, "StandClamp", Vector3.new(0.6, 0.08, 0.08), CFrame.new(x - 0.4, 4.4, z - 1), steel)
		local flask = part(m, "Flask", Vector3.new(0.9, 0.9, 0.9), CFrame.new(x - 0.1, 3.95, z - 1),
			{ Shape = Enum.PartType.Ball, Color = rgb(255, 140, 50), Material = M.Neon, Transparency = 0.15 }) :: Part
		part(m, "FlaskNeck", Vector3.new(0.6, 0.25, 0.25), CFrame.new(x - 0.1, 4.6, z - 1) * CFrame.Angles(0, 0, math.pi / 2),
			{ Shape = Enum.PartType.Cylinder, Color = rgb(210, 225, 230), Material = M.Glass, Transparency = 0.4 })
		glowing(flask, rgb(255, 150, 70), 6, 0.6)
		part(m, "Burner", Vector3.new(0.4, 0.3, 0.3), CFrame.new(x - 0.1, 3.2, z - 1) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(60, 62, 66), Material = M.Metal })
		-- Test tube rack and a beaker.
		part(m, "TubeRack", Vector3.new(0.6, 0.4, 1.8), CFrame.new(x - 0.2, 3.2, z + 1), { Color = rgb(225, 225, 220) })
		for k = -2, 2 do
			part(m, "TestTube", Vector3.new(0.8, 0.18, 0.18), CFrame.new(x - 0.2, 3.65, z + 1 + k * 0.32) * CFrame.Angles(0, 0, math.pi / 2),
				{ Shape = Enum.PartType.Cylinder, Color = if k % 2 == 0 then rgb(120, 200, 120) else rgb(90, 160, 220), Material = M.Glass, Transparency = 0.3 })
		end
		part(m, "Beaker", Vector3.new(0.7, 0.6, 0.6), CFrame.new(x + 0.5, 3.35, z + 0.1) * CFrame.Angles(0, 0, math.pi / 2),
			{ Shape = Enum.PartType.Cylinder, Color = rgb(230, 220, 200), Material = M.Glass, Transparency = 0.35 })
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

-- Hygiene station: toilet stalls (one door ajar), glass shower stalls, a sink counter under mirrors (one cracked),
-- lockers and a bench, a wet-floor sign.
local function hygiene(): Model
	local m = B.newRoom("HygieneStation", { Weight = 1, MinRoom = 6 })
	local w, L, h, p = 26, 32, 10, PAL.hygiene
	B.shell(m, w, L, h, p)
	local steel = { Color = rgb(175, 178, 182), Material = M.Metal }
	local stall = { Color = rgb(95, 125, 125) }
	local white = { Color = rgb(225, 228, 228) }
	local glass = { Color = rgb(190, 215, 220), Material = M.Glass, Transparency = 0.6, CastShadow = false }
	local lx = -w / 2
	-- Toilet stalls along the left wall.
	for _, z in { -2.5, -6.5, -10.5, -14.5 } do
		part(m, "StallWall", Vector3.new(5, 7, 0.25), CFrame.new(lx + 2.5, 4, z), stall)
	end
	for i, zc in { -4.5, -8.5, -12.5 } do
		part(m, "Toilet", Vector3.new(1.6, 1.4, 1.8), CFrame.new(lx + 1.2, 0.7, zc), white)
		part(m, "Cistern", Vector3.new(0.6, 1.4, 1.6), CFrame.new(lx + 0.3, 1.9, zc), white)
		part(m, "PaperRoll", Vector3.new(0.4, 0.5, 0.5), CFrame.new(lx + 2.2, 2.6, zc - 1.6), { Shape = Enum.PartType.Cylinder, Color = rgb(240, 240, 235) })
		if i == 2 then
			part(m, "StallDoor", Vector3.new(3.6, 6.5, 0.2), CFrame.new(lx + 5, 3.75, zc - 1.75) * CFrame.Angles(0, -1.2, 0) * CFrame.new(1.8, 0, 0), stall)
		else
			part(m, "StallDoor", Vector3.new(0.2, 6.5, 3.6), CFrame.new(lx + 5.1, 3.75, zc), stall)
			part(m, "OccupiedSign", Vector3.new(0.05, 0.3, 0.6), CFrame.new(lx + 5.225, 4.4, zc + 1.1), { Material = M.Neon, Color = if i == 1 then rgb(200, 40, 30) else rgb(40, 160, 70), CanCollide = false })
		end
	end
	-- Glass shower stalls further along, with heads and drains.
	for _, z in { -16.5, -21, -25.5, -30 } do
		part(m, "ShowerWall", Vector3.new(4.5, 7.5, 0.2), CFrame.new(lx + 2.25, 3.75, z), glass)
	end
	for _, zc in { -18.75, -23.25, -27.75 } do
		part(m, "ShowerPipe", Vector3.new(0.15, 6.5, 0.15), CFrame.new(lx + 0.15, 3.25, zc), steel)
		part(m, "ShowerHead", Vector3.new(0.9, 0.2, 0.9), CFrame.new(lx + 0.6, 6.6, zc) * CFrame.Angles(0, 0, 0.3), steel)
		part(m, "ShowerDrain", Vector3.new(0.7, 0.04, 0.7), CFrame.new(lx + 2.2, 0.02, zc), { Color = rgb(40, 42, 44), Material = M.DiamondPlate, CanCollide = false })
		part(m, "ShowerCurtain", Vector3.new(0.05, 6.5, 3.4), CFrame.new(lx + 4.5, 4, zc + 0.3), { Color = rgb(170, 200, 210), Material = M.Fabric, Transparency = 0.3, CanCollide = false })
	end
	-- Sink counter with mirrors on the right; one mirror is cracked.
	local rx = w / 2
	part(m, "SinkCounter", Vector3.new(2.4, 3, 14), CFrame.new(rx - 1.2, 1.5, -10), { Color = rgb(170, 172, 170), Material = M.Marble })
	for i, z in { -5, -8.3, -11.7, -15 } do
		part(m, "Basin", Vector3.new(1.4, 0.04, 1.6), CFrame.new(rx - 1.3, 3.02, z), { Color = rgb(235, 235, 235) })
		part(m, "Tap", Vector3.new(0.15, 0.7, 0.15), CFrame.new(rx - 0.3, 3.35, z), steel)
		part(m, "Soap", Vector3.new(0.3, 0.6, 0.35), CFrame.new(rx - 0.15, 5, z + 1.65), white)
		B.onWall(m, w, 1, z, 5.5, Vector2.new(2.8, 3.2), 0.08, "Mirror", { Color = rgb(170, 178, 182), Material = M.Glass, Reflectance = 0.45 })
		if i == 3 then
			for k = 0, 4 do
				part(m, "Crack", Vector3.new(0.02, 1.4, 0.06), CFrame.new(rx - 0.09, 5.6, z) * CFrame.Angles(k * 1.25, 0, 0) * CFrame.new(0, 0.6, 0), { Color = rgb(40, 40, 42), CanCollide = false })
			end
		end
	end
	part(m, "HandDryer", Vector3.new(0.6, 1.2, 1), CFrame.new(rx - 0.3, 4.6, -18.5), steel)
	part(m, "TowelRack", Vector3.new(0.15, 0.15, 3), CFrame.new(rx - 0.35, 5.5, -21.5), steel)
	for k = 0, 2 do
		part(m, "Towel", Vector3.new(0.12, 1.8, 0.9), CFrame.new(rx - 0.42, 4.6, -22.6 + k * 1.1), { Color = rgb(200, 205, 210), Material = M.Fabric, CanCollide = false })
	end
	for k = 0, 3 do
		part(m, "Locker", Vector3.new(1.5, 7, 1.8), CFrame.new(rx - 0.75, 3.5, -25 - k * 1.9), { Color = rgb(80, 110, 110), Material = M.Metal })
	end
	part(m, "Bench", Vector3.new(1.4, 1.5, 6), CFrame.new(rx - 3.6, 0.75, -27.8), { Color = rgb(150, 120, 90), Material = M.Wood })
	-- Wet floor sign and a puddle.
	-- A-frame wet floor sign: two panels leaning together, warning on both faces.
	local signBase = CFrame.new(3.6, 0, -14) * CFrame.Angles(0, 0.4, 0)
	for _, f in { 1, -1 } do
		local panelCf = signBase * CFrame.new(0, 1.06, f * 0.29) * CFrame.Angles(-f * 0.26, 0, 0)
		local panel = part(m, "WetFloorSign", Vector3.new(1.3, 2.2, 0.08), panelCf, { Color = rgb(235, 195, 30), Material = M.Plastic }) :: Part
		part(m, "WetFloorStripe", Vector3.new(1.32, 0.18, 0.09), panelCf * CFrame.new(0, 0.85, 0), { Color = rgb(25, 25, 25), CanCollide = false })
		B.label(panel, "CAUTION\nWET\nFLOOR", if f == 1 then Enum.NormalId.Back else Enum.NormalId.Front, rgb(25, 25, 25), Enum.Font.GothamBlack)
	end
	for k, d in { { 1.2, 0, 2.2 }, { 2.2, 0.5, 1.4 }, { 0.6, -0.8, 1 } } do
		part(m, "Puddle", Vector3.new(0.02, d[3], d[3] * 1.3), CFrame.new(1.5 + d[1], 0.008 + k * 0.005, -16 + d[2]) * CFrame.Angles(0, 0, math.pi / 2),
			{ Shape = Enum.PartType.Cylinder, Color = rgb(160, 180, 190), Material = M.Glass, Transparency = 0.6, Reflectance = 0.4, CanCollide = false })
	end
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
			{ side = "left", z = -14, y = 3, w = 10, h = 5 },
			{ side = "left", z = -30, y = 3, w = 10, h = 5 },
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
	for _, x in { -12, 12 } do
		part(m, "Pillar", Vector3.new(2, h, 2), CFrame.new(x, h / 2, -22), { Color = p.wall, Material = p.wallMat })
	end
	B.panelGrid(m, w, L, h, 3, 4, p.light, 0.7, 20)
	return m
end

-- Shuttle hangar: a proper shuttle on a marked pad, fuel cart and hose, tool chests, a control booth.
local function hangar(): Model
	local m = B.newRoom("ShuttleHangar", { Weight = 1, MinRoom = 15 })
	local w, L, h, p = 44, 52, 16, PAL.hangar
	B.shell(m, w, L, h, p)
	local hull = { Color = rgb(195, 197, 200), Material = M.Metal }
	local dark = { Color = rgb(55, 57, 62), Material = M.Metal }
	local yellow = { Color = rgb(200, 160, 40), CanCollide = false }
	-- Landing pad outline.
	part(m, "PadLine", Vector3.new(16, 0.05, 0.4), CFrame.new(10, 0.025, -15.8), yellow)
	part(m, "PadLine", Vector3.new(16, 0.05, 0.4), CFrame.new(10, 0.025, -38.2), yellow)
	part(m, "PadLine", Vector3.new(0.4, 0.05, 22), CFrame.new(2.2, 0.025, -27), yellow)
	part(m, "PadLine", Vector3.new(0.4, 0.05, 22), CFrame.new(17.8, 0.025, -27), yellow)
	-- Shuttle: fuselage, cockpit, wings, tail, engines, landing gear, open ramp.
	part(m, "Fuselage", Vector3.new(14, 4.5, 4.5), CFrame.new(10, 3.2, -26) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Color = hull.Color, Material = hull.Material })
	part(m, "Nose", Vector3.new(4.5, 4.5, 4.5), CFrame.new(10, 3.2, -19), { Shape = Enum.PartType.Ball, Color = hull.Color, Material = hull.Material })
	part(m, "Cockpit", Vector3.new(3, 1.4, 2.4), CFrame.new(10, 4.9, -19.8) * CFrame.Angles(-0.25, 0, 0), { Color = rgb(20, 28, 38), Material = M.Glass, Reflectance = 0.3 })
	part(m, "Wing", Vector3.new(14, 0.4, 5), CFrame.new(10, 2.6, -28), hull)
	for _, dx in { -7, 7 } do
		part(m, "WingTip", Vector3.new(0.4, 1.4, 3), CFrame.new(10 + dx, 3.1, -28.5), dark)
	end
	part(m, "TailFin", Vector3.new(0.4, 4, 3), CFrame.new(10, 6.8, -31.5), hull)
	for _, dx in { -1.3, 1.3 } do
		part(m, "Engine", Vector3.new(3, 1.4, 1.4), CFrame.new(10 + dx, 2.4, -33.8) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Color = dark.Color, Material = dark.Material })
		local exhaust = part(m, "Exhaust", Vector3.new(0.05, 1.1, 1.1), CFrame.new(10 + dx, 2.4, -35.33) * CFrame.Angles(0, math.pi / 2, 0),
			{ Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(120, 60, 30), CanCollide = false }) :: Part
		glowing(exhaust, rgb(255, 140, 70), 6, 0.4)
	end
	for _, o in { Vector3.new(0, 0, -20.5), Vector3.new(-2.5, 0, -29), Vector3.new(2.5, 0, -29) } do
		part(m, "Gear", Vector3.new(0.4, 1.1, 0.4), CFrame.new(10 + o.X, 0.75, o.Z), dark)
		part(m, "GearFoot", Vector3.new(0.9, 0.2, 0.9), CFrame.new(10 + o.X, 0.1, o.Z), dark)
	end
	part(m, "Ramp", Vector3.new(3, 0.25, 4), CFrame.new(10, 0.9, -35.4) * CFrame.Angles(-0.35, 0, 0), dark)
	-- Fuel cart with a hose running to the shuttle.
	part(m, "FuelCart", Vector3.new(3, 2.5, 5), CFrame.new(-8, 1.6, -26), { Color = rgb(170, 60, 40), Material = M.Metal })
	part(m, "FuelTank", Vector3.new(4, 2, 2), CFrame.new(-8, 3.6, -26) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Color = rgb(200, 200, 195), Material = M.Metal })
	part(m, "Hose", Vector3.new(14.2, 0.3, 0.3), CFrame.new(-0.4, 0.15, -26.5), { Color = rgb(25, 25, 25), Material = M.Rubber, CanCollide = false })
	-- Bay door with warning lights.
	local bay = B.onWall(m, w, -1, -26, 6.5, Vector2.new(20, 12), 0.4, "BayDoor", { Color = rgb(70, 70, 72), Material = M.DiamondPlate }) :: Part
	B.label(bay, "BAY DOOR - DO NOT OPEN", Enum.NormalId.Right, rgb(220, 180, 50))
	for _, dz in { -11, 11 } do
		B.bulb(m, Vector3.new(-w / 2 + 0.6, 12, -26 + dz), rgb(255, 60, 40), 12, 0.6, 1)
	end
	-- Tool chests and crates.
	for k = 0, 1 do
		part(m, "ToolChest", Vector3.new(2, 4, 3), CFrame.new(-w / 2 + 1, 2, -41 - k * 3.2), { Color = rgb(170, 40, 35), Material = M.Metal })
		for d = 0, 3 do
			part(m, "Drawer", Vector3.new(0.05, 0.08, 2.4), CFrame.new(-w / 2 + 2.025, 0.8 + d * 0.9, -41 - k * 3.2), { Color = rgb(30, 30, 30) })
		end
	end
	crate(m, CFrame.new(-16, 1.5, -10), Vector3.new(3, 3, 3))
	crate(m, CFrame.new(-16, 4.5, -10.3), Vector3.new(2.6, 3, 2.6))
	-- Control booth in the corner.
	part(m, "BoothBase", Vector3.new(5, 3, 6), CFrame.new(w / 2 - 2.5, 1.5, -L + 3), dark)
	part(m, "BoothGlass", Vector3.new(5, 4, 6), CFrame.new(w / 2 - 2.5, 5, -L + 3), { Color = rgb(170, 190, 200), Material = M.Glass, Transparency = 0.6 })
	part(m, "BoothRoof", Vector3.new(5, 0.4, 6), CFrame.new(w / 2 - 2.5, 7.2, -L + 3), dark)
	B.panelGrid(m, w, L, h, 3, 4, p.light, 0.8, 24)
	return m
end

-- Solar monitoring: rows of consoles facing a wall screen of the Sun and its corona, a supervisor's platform.
local function solarControl(): Model
	local m = B.newRoom("SolarControl", { Weight = 1, MinRoom = 10 })
	local w, L, h, p = 34, 36, 13, PAL.control
	B.shell(m, w, L, h, p)
	local rand = Random.new(10)
	local dark = { Color = rgb(40, 42, 48), Material = M.Metal }
	local face = -w / 2
	-- Main screen with the Sun, its corona, and side readouts.
	B.onWall(m, w, -1, -18, 7, Vector2.new(16, 7.5), 0.2, "Screen", { Color = rgb(8, 8, 12) })
	part(m, "Corona", Vector3.new(0.04, 6.4, 6.4), CFrame.new(face + 0.22, 7.2, -18), { Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(90, 40, 15), Transparency = 0.3, CanCollide = false })
	local sun = part(m, "Sun", Vector3.new(0.06, 4.6, 4.6), CFrame.new(face + 0.27, 7.2, -18), { Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(255, 130, 40), CanCollide = false }) :: Part
	glowing(sun, rgb(255, 140, 60), 16, 0.8)
	for k = 0, 5 do
		part(m, "Flare", Vector3.new(0.05, 0.3, rand:NextNumber(1, 2)), CFrame.new(face + 0.25, 7.2, -18) * CFrame.Angles(k * 1.05, 0, 0) * CFrame.new(0, 0, 3.2),
			{ Material = M.Neon, Color = rgb(255, 110, 40), CanCollide = false })
	end
	for i, z in { -7, -29 } do
		local side = B.onWall(m, w, -1, z, 7, Vector2.new(4.5, 4), 0.2, "Readout", { Color = rgb(30, 12, 8), Material = M.Neon }) :: Part
		B.label(side, if i == 1 then "FLUX  +1400%\nTEMP  RISING\nDIST  ????" else "LAST CONTACT\nWITH EARTH:\n4,811 DAYS", Enum.NormalId.Right, rgb(255, 150, 90), Enum.Font.Code)
	end
	wallSign(m, w, -1, -18, 2.2, Vector2.new(10, 1), "SOL ACTIVITY: ABNORMAL", rgb(60, 15, 10), rgb(255, 120, 80), Enum.Font.Code)
	-- Two rows of consoles facing the screen.
	for _, x in { -6, 5 } do
		part(m, "Console", Vector3.new(2, 3, 12), CFrame.new(x, 1.5, -18), dark)
		part(m, "ConsoleTop", Vector3.new(2.3, 0.15, 12.2), CFrame.new(x, 3.075, -18), { Color = rgb(25, 27, 30) })
		for _, z in { -14, -18, -22 } do
			part(m, "Display", Vector3.new(0.12, 1.3, 2.2), CFrame.new(x - 0.5, 3.85, z) * CFrame.Angles(0, 0, -0.25), dark)
			part(m, "DisplayGlow", Vector3.new(0.03, 1.1, 2), CFrame.new(x - 0.58, 3.83, z) * CFrame.Angles(0, 0, -0.25),
				{ Material = M.Neon, Color = if rand:NextNumber() < 0.3 then rgb(80, 25, 15) else rgb(60, 35, 20), CanCollide = false })
			part(m, "Keyboard", Vector3.new(0.6, 0.06, 1.6), CFrame.new(x + 0.4, 3.18, z), { Color = rgb(20, 20, 22) })
			chair(m, CFrame.new(x + 2.4, 0, z + rand:NextNumber(-0.4, 0.4)) * CFrame.Angles(0, math.rad(90) + rand:NextNumber(-0.4, 0.4), 0), rgb(60, 65, 80))
		end
	end
	-- Supervisor platform at the back.
	part(m, "Platform", Vector3.new(7, 0.5, 14), CFrame.new(w / 2 - 3.5, 0.25, -18), { Color = rgb(55, 58, 64), Material = M.DiamondPlate })
	part(m, "SupervisorDesk", Vector3.new(2, 3, 6), CFrame.new(w / 2 - 4.5, 2, -18), dark)
	part(m, "SupervisorScreen", Vector3.new(0.12, 1.4, 3), CFrame.new(w / 2 - 5, 4.25, -18), { Material = M.Neon, Color = rgb(60, 35, 20) })
	chair(m, CFrame.new(w / 2 - 2.2, 0.5, -18) * CFrame.Angles(0, math.rad(90), 0), rgb(70, 35, 30))
	for _, z in { -11, -25 } do
		part(m, "Railing", Vector3.new(0.15, 1.2, 0.15), CFrame.new(w / 2 - 7, 1.1, z), { Color = rgb(150, 152, 158), Material = M.Metal })
	end
	part(m, "Railing", Vector3.new(0.12, 0.12, 14), CFrame.new(w / 2 - 7, 1.7, -18), { Color = rgb(150, 152, 158), Material = M.Metal })
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.5)
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

-- Promenade: shops with real interiors behind the glass, Solstice banners, benches facing a wall of windows.
local function promenade(): Model
	local m = B.newRoom("Promenade", { Weight = 1, MinRoom = 20 })
	local w, L, h, p = 48, 60, 22, PAL.promenade
	local windows = {}
	for _, z in { -10, -30, -50 } do
		table.insert(windows, { side = "right", z = z, y = 3, w = 14, h = 8 })
	end
	B.shell(m, w, L, h, p, { windows = windows })
	local rand = Random.new(60)
	local frame = { Color = rgb(60, 58, 55), Material = M.Metal }
	local names = { "ELSEWHERE", "MEMORIES", "AFTER" }
	local back = -w / 2 -- left wall face
	for i, c in { -10, -30, -50 } do
		-- Shop box: 3 deep, partitions either side, ceiling slab with a sign band.
		for _, dz in { -7, 7 } do
			part(m, "ShopWall", Vector3.new(3, 10.5, 0.4), CFrame.new(back + 1.5, 5.25, c + dz), frame)
		end
		part(m, "ShopCeiling", Vector3.new(3, 0.4, 13.6), CFrame.new(back + 1.5, 10.3, c), frame)
		part(m, "ShopFloor", Vector3.new(3, 0.1, 13.6), CFrame.new(back + 1.5, 0.05, c), { Color = rgb(70, 60, 55), Material = M.WoodPlanks })
		part(m, "Kickplate", Vector3.new(0.4, 0.6, 13.6), CFrame.new(back + 3.2, 0.3, c), frame)
		if i == 2 then
			-- Smashed shopfront: only shards of glass left in the frame.
			for k = 0, 3 do
				part(m, "Shard", Vector3.new(0.08, rand:NextNumber(1, 3), rand:NextNumber(0.6, 1.4)),
					CFrame.new(back + 3.2, 1.2 + rand:NextNumber(0, 0.5), c - 6 + k * 4) * CFrame.Angles(rand:NextNumber(-0.3, 0.3), 0, 0),
					{ Color = rgb(150, 160, 170), Material = M.Glass, Transparency = 0.4, CanCollide = false })
			end
		else
			part(m, "ShopGlass", Vector3.new(0.1, 9.3, 13.6), CFrame.new(back + 3.2, 5.25, c), { Color = rgb(40, 45, 52), Material = M.Glass, Transparency = 0.35, Reflectance = 0.2 })
		end
		wallSign(m, w, -1, c, 11.3, Vector2.new(13, 1.6), names[i], rgb(50, 50, 55), rgb(210, 210, 210))
		-- Contents: shelves, a counter, a couple of mannequins.
		for _, y in { 2, 4.5, 7 } do
			part(m, "ShopShelf", Vector3.new(1, 0.15, 5), CFrame.new(back + 0.5, y, c - 4), frame)
			for k = 0, 3 do
				part(m, "Goods", Vector3.new(0.6, rand:NextNumber(0.5, 1.2), 0.8), CFrame.new(back + 0.5, y + 0.4, c - 5.7 + k * 1.1),
					{ Color = rgb(rand:NextInteger(60, 160), rand:NextInteger(60, 140), rand:NextInteger(60, 140)), CanCollide = false })
			end
		end
		for _, dz in { 2, 4.5 } do
			part(m, "Mannequin", Vector3.new(0.8, 3.6, 1.2), CFrame.new(back + 1.6, 1.9, c + dz), { Color = rgb(215, 210, 200) })
			part(m, "MannequinHead", Vector3.new(0.8, 0.8, 0.8), CFrame.new(back + 1.6, 4.1, c + dz), { Shape = Enum.PartType.Ball, Color = rgb(215, 210, 200) })
		end
	end
	-- Hanging Solstice banners.
	for _, x in { -8, 8 } do
		for _, z in { -15, -35, -55 } do
			part(m, "BannerRod", Vector3.new(3, 0.15, 0.15), CFrame.new(x, 20, z), frame)
			part(m, "Banner", Vector3.new(2.6, 6, 0.08), CFrame.new(x, 16.9, z), { Color = rgb(200, 110, 40), Material = M.Fabric, CanCollide = false })
		end
	end
	-- Info kiosk, planters with dead trees, benches facing the windows.
	part(m, "Kiosk", Vector3.new(2, 4, 2), CFrame.new(-8, 2, -22), { Color = rgb(70, 72, 78), Material = M.Metal })
	local kiosk = part(m, "KioskScreen", Vector3.new(0.05, 1.6, 1.4), CFrame.new(-6.975, 3.2, -22), { Material = M.Neon, Color = rgb(20, 35, 50), CanCollide = false }) :: Part
	B.label(kiosk, "WELCOME TO\nTHE PROMENADE", Enum.NormalId.Right, rgb(170, 210, 240), Enum.Font.Code)
	for _, z in { -20, -40 } do
		part(m, "Planter", Vector3.new(6, 2, 6), CFrame.new(10, 1, z), { Color = rgb(140, 132, 120), Material = M.Concrete })
		part(m, "Soil", Vector3.new(5.4, 0.1, 5.4), CFrame.new(10, 2.05, z), { Color = rgb(55, 42, 30), Material = M.Ground })
		part(m, "Trunk", Vector3.new(0.8, 6, 0.8), CFrame.new(10, 5.1, z), { Color = rgb(70, 55, 42), Material = M.Wood })
		for k = 0, 3 do
			part(m, "Branch", Vector3.new(0.35, 3, 0.35), CFrame.new(10, 7.5, z) * CFrame.Angles(0, k * 1.6, 0) * CFrame.Angles(0.7, 0, 0) * CFrame.new(0, 1.5, 0), { Color = rgb(70, 55, 42), Material = M.Wood })
		end
	end
	for _, z in { -10, -30, -50 } do
		part(m, "BenchSeat", Vector3.new(1.8, 0.3, 6), CFrame.new(18, 1.6, z), { Color = rgb(100, 75, 55), Material = M.Wood })
		part(m, "BenchBack", Vector3.new(0.3, 1.6, 6), CFrame.new(17.25, 2.55, z), { Color = rgb(100, 75, 55), Material = M.Wood })
		for _, dz in { -2.4, 2.4 } do
			part(m, "BenchLeg", Vector3.new(1.4, 1.45, 0.3), CFrame.new(18, 0.725, z + dz), frame)
		end
	end
	for _, x in { -12, 12 } do
		for _, z in { -10, -30, -50 } do
			B.panel(m, x, h, z, p.light, 1, 30, Vector3.new(10, 0.3, 6))
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

-- Airlock: suit-up benches, oxygen masks, pressure gauges, and an outer hatch rimmed with frost.
local function airlock(): Model
	local m = B.newRoom("Airlock", { Weight = 1, MinRoom = 4 })
	local w, L, h, p = 16, 20, 11, PAL.hull
	B.shell(m, w, L, h, p)
	local steel = { Color = rgb(140, 145, 150), Material = M.Metal }
	local dark = { Color = rgb(55, 58, 64), Material = M.Metal }
	-- Hazard stripes framing both doorways.
	for _, z in { -0.55, -L + 0.65 } do
		for k = -3, 3 do
			if k % 2 ~= 0 then
				part(m, "Stripe", Vector3.new(0.9, 0.07, 0.9), CFrame.new(k * 1, 0.035, z), { Color = rgb(25, 25, 25), CanCollide = false })
			end
		end
	end
	-- Floor grate with drains.
	part(m, "Grate", Vector3.new(6, 0.04, L - 4), CFrame.new(0, 0.02, -L / 2), { Color = rgb(40, 42, 46), Material = M.DiamondPlate, CanCollide = false })
	-- Suit-up benches and hanging oxygen masks on the left.
	part(m, "Bench", Vector3.new(1.5, 1.5, 8), CFrame.new(-w / 2 + 0.75, 0.75, -9), dark)
	for k = 0, 3 do
		local z = -6 - k * 2
		part(m, "MaskHose", Vector3.new(0.08, 1.6, 0.08), CFrame.new(-w / 2 + 0.6, 5.4, z), { Color = rgb(30, 30, 30) })
		part(m, "Mask", Vector3.new(0.4, 0.5, 0.6), CFrame.new(-w / 2 + 0.6, 4.4, z), { Color = rgb(200, 190, 60), Material = M.Plastic })
	end
	part(m, "MaskRail", Vector3.new(0.15, 0.15, 7), CFrame.new(-w / 2 + 0.6, 6.25, -9), steel)
	-- Pressure gauges with stuck needles.
	for k = 0, 2 do
		local z = -14 - k * 1.6
		part(m, "Gauge", Vector3.new(0.15, 1.2, 1.2), CFrame.new(-w / 2 + 0.075, 6, z), { Shape = Enum.PartType.Cylinder, Color = rgb(225, 225, 220) })
		part(m, "Needle", Vector3.new(0.03, 0.5, 0.05), CFrame.new(-w / 2 + 0.17, 6, z) * CFrame.Angles(-2.2 + k * 0.2, 0, 0) * CFrame.new(0, 0.2, 0), { Color = rgb(200, 30, 30), CanCollide = false })
	end
	-- Control panel with a big red button.
	B.onWall(m, w, -1, -16, 3.6, Vector2.new(3, 2.4), 0.4, "ControlPanel", dark)
	part(m, "Button", Vector3.new(0.3, 0.6, 0.6), CFrame.new(-w / 2 + 0.55, 3.2, -15.2) * CFrame.Angles(0, 0, 0), { Shape = Enum.PartType.Cylinder, Color = rgb(200, 30, 30) })
	wallSign(m, w, -1, -11.5, 8.6, Vector2.new(5, 2), "OUTER DOOR: OPEN\nPRESSURE: 0.0 kPa", rgb(40, 10, 10), rgb(255, 90, 80), Enum.Font.Code)
	-- Outer hatch on the right wall, frosted around the rim.
	local face = w / 2
	part(m, "HatchRim", Vector3.new(0.5, 7.2, 7.2), CFrame.new(face - 0.25, 4.6, -10), { Shape = Enum.PartType.Cylinder, Color = rgb(70, 72, 78), Material = M.Metal })
	part(m, "Hatch", Vector3.new(0.3, 6, 6), CFrame.new(face - 0.65, 4.6, -10), { Shape = Enum.PartType.Cylinder, Color = rgb(110, 114, 120), Material = M.DiamondPlate })
	part(m, "Frost", Vector3.new(0.05, 7.6, 7.6), CFrame.new(face - 0.03, 4.6, -10), { Shape = Enum.PartType.Cylinder, Color = rgb(210, 230, 245), Material = M.Ice, Transparency = 0.2, CanCollide = false })
	part(m, "Wheel", Vector3.new(0.2, 2.2, 2.2), CFrame.new(face - 0.9, 4.6, -10), { Shape = Enum.PartType.Cylinder, Color = rgb(170, 40, 35), Material = M.Metal })
	for k = 0, 1 do
		part(m, "WheelSpoke", Vector3.new(0.12, 2, 0.15), CFrame.new(face - 1.05, 4.6, -10) * CFrame.Angles(k * math.pi / 2, 0, 0), steel)
	end
	wallSign(m, w, 1, -10, 8.9, Vector2.new(3.2, 0.8), "OUTER HATCH", rgb(200, 160, 40), rgb(30, 20, 10))
	-- Red warning beacons.
	for _, x in { -5, 5 } do
		B.bulb(m, Vector3.new(x, h - 0.6, -3), rgb(255, 60, 50), 12, 0.6, 1)
	end
	B.panel(m, 0, h, -13, p.light, 0.6, 16)
	return m
end

-- Coolant loop: tall domed tanks with level gauges and valve wheels, pumps, an overhead manifold, glowing channels.
local function coolant(): Model
	local m = B.newRoom("CoolantRoom", { Weight = 1, MinRoom = 18 })
	local w, L, h, p = 26, 38, 16, PAL.engine
	B.shell(m, w, L, h, p)
	local metal = { Color = rgb(120, 125, 130), Material = M.Metal }
	local dark = { Color = rgb(60, 62, 66), Material = M.Metal }
	local glow = rgb(70, 170, 220)
	for _, sx in { -1, 1 } do
		local x = sx * 9.5
		part(m, "ChannelGrate", Vector3.new(1.6, 0.04, L - 4), CFrame.new(sx * 5, 0.06, -L / 2), { Color = rgb(40, 42, 46), Material = M.DiamondPlate, Transparency = 0.3, CanCollide = false })
		part(m, "Channel", Vector3.new(1.2, 0.03, L - 4), CFrame.new(sx * 5, 0.015, -L / 2), { Material = M.Neon, Color = rgb(40, 110, 150), CanCollide = false })
		for _, z in { -9, -27 } do
			local tank = part(m, "Tank", Vector3.new(10, 4.5, 4.5), CFrame.new(x, 5, z) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = metal.Color, Material = metal.Material }) :: Part
			part(m, "TankDome", Vector3.new(4.5, 4.5, 4.5), CFrame.new(x, 10, z), { Shape = Enum.PartType.Ball, Color = metal.Color, Material = metal.Material })
			for _, y in { 2, 8 } do
				part(m, "TankBand", Vector3.new(0.3, 4.7, 4.7), CFrame.new(x, y, z) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = dark.Color, Material = dark.Material })
			end
			part(m, "LevelGauge", Vector3.new(0.06, 4.6, 0.4), CFrame.new(x - sx * 2.27, 5, z), { Material = M.Neon, Color = rgb(40, 120, 160), CanCollide = false })
			part(m, "Riser", Vector3.new(0.6, h - 12, 0.6), CFrame.new(x, 12 + (h - 12) / 2, z), dark)
			glowing(tank, glow, 9, 0.4)
		end
		-- Pump between the tanks.
		part(m, "Pump", Vector3.new(3, 2.2, 3), CFrame.new(x, 1.1, -18), dark)
		part(m, "Valve", Vector3.new(0.2, 1.3, 1.3), CFrame.new(x - sx * 1.6, 1.3, -18), { Shape = Enum.PartType.Cylinder, Color = rgb(170, 40, 35), Material = M.Metal })
		part(m, "PumpMotor", Vector3.new(2.4, 1.6, 1.6), CFrame.new(x, 3, -18) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Color = rgb(40, 80, 120), Material = M.Metal })
		-- Overhead manifold linking the tanks.
		part(m, "Manifold", Vector3.new(22, 0.9, 0.9), CFrame.new(x, h - 1.5, -18) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Color = metal.Color, Material = metal.Material })
	end
	local panel = B.onWall(m, w, -1, -36, 5, Vector2.new(3, 2), 0.2, "ControlPanel", { Color = rgb(10, 25, 35), Material = M.Neon }) :: Part
	B.label(panel, "COOLANT TEMP\nRISING", Enum.NormalId.Right, rgb(120, 200, 240), Enum.Font.Code)
	for _, sx in { -1, 1 } do
		B.bulb(m, Vector3.new(sx * (w / 2 - 0.6), 12, -18), rgb(255, 160, 50), 12, 0.6, 1)
	end
	endSign(m, -L, 1, 0, 11, Vector2.new(9, 1.2), "COOLANT LOOP B - DO NOT TOUCH")
	B.panelGrid(m, w, L, h, 1, 3, p.light, 0.5, 20)
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
	"M", "CYNTHIA", "LILLIE", "MONICA STEVENS", "D3RLORD3", "TOWA BIRD",
	"RENEE RAPP", "TATE", "UMBREON", "CORSOLA", "DEWGONG", "SPHEAL",
	'"DAVE"', "HEROBRINE?", "APHELION", "ROOMBA", "NEKO TIFA", "AVERITT", "AEL <3",
	"PIZZA", "ERIN", "ETHAN", "SANE", "FLIP",
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

	-- Plaque wall: dark wood panels either side of the exit, five rows of four brass plaques each.
	local slots = {}
	for row = 0, 4 do
		for _, side in { -1, 1 } do
			for col = 0, 3 do
				table.insert(slots, { side * (4.4 + col * 2.1), 8.6 - row * 1.6 })
			end
		end
	end
	for _, side in { -1, 1 } do
		part(m, "PlaqueWall", Vector3.new(9.2, 8.8, 0.2), CFrame.new(side * 7.95, 5.4, -L + 0.1), darkWood)
		part(m, "PlaqueWallTrim", Vector3.new(9.6, 0.3, 0.35), CFrame.new(side * 7.95, 9.95, -L + 0.175), brass)
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

-- Dormitory: bunks with ladders, rails, pillows and privacy curtains; a card table; lockers by the exit.
local function dormitory(): Model
	local m = B.newRoom("Dormitory", { Weight = 2, MinRoom = 4 })
	local w, L, h, p = 24, 36, 11, PAL.hull
	B.shell(m, w, L, h, p)
	local rand = Random.new(33)
	local frame = { Color = rgb(70, 74, 82), Material = M.Metal }
	local blankets = { rgb(70, 80, 100), rgb(90, 95, 85), rgb(110, 60, 50), rgb(60, 70, 60) }
	local k = 0
	for _, side in { -1, 1 } do
		for _, z in { -5, -13, -21, -29 } do
			k += 1
			local x = side * (w / 2 - 1.5)
			for level, y in { 1.5, 5 } do
				part(m, "Bunk", Vector3.new(3, 0.4, 7), CFrame.new(x, y, z), frame)
				part(m, "Mattress", Vector3.new(2.8, 0.35, 6.8), CFrame.new(x, y + 0.375, z), { Color = rgb(150, 150, 145), Material = M.Fabric })
				part(m, "Pillow", Vector3.new(1.8, 0.35, 1.1), CFrame.new(x, y + 0.72, z - 2.7), { Color = rgb(210, 210, 205), Material = M.Fabric })
				local occupied = side == -1 and z == -21 and level == 1
				part(m, "Blanket", Vector3.new(2.7, if occupied then 0.7 else 0.12, 4.2), CFrame.new(x, y + (if occupied then 0.9 else 0.61), z + 1) * CFrame.Angles(0, rand:NextNumber(-0.1, 0.1), 0),
					{ Color = blankets[rand:NextInteger(1, #blankets)], Material = M.Fabric })
				-- Reading light on the wall at the head of each bunk.
				part(m, "ReadingLight", Vector3.new(0.12, 0.3, 0.5), CFrame.new(side * (w / 2 - 0.06), y + 1.6, z - 2.6), { Material = M.Neon, Color = if rand:NextNumber() < 0.3 then rgb(255, 210, 150) else rgb(60, 55, 50), CanCollide = false })
			end
			for _, dx in { -1.35, 1.35 } do
				for _, dz in { -3.35, 3.35 } do
					part(m, "Post", Vector3.new(0.3, 7, 0.3), CFrame.new(x + dx, 3.5, z + dz), frame)
				end
			end
			-- Top bunk safety rail and a ladder on the aisle side.
			part(m, "SafetyRail", Vector3.new(0.12, 0.12, 4.6), CFrame.new(x - side * 1.35, 6.2, z - 1), frame)
			for _, dz in { 2.1, 2.9 } do
				part(m, "LadderRail", Vector3.new(0.12, 5.4, 0.12), CFrame.new(x - side * 1.6, 2.7, z + dz), frame)
			end
			for r = 1, 4 do
				part(m, "LadderRung", Vector3.new(0.1, 0.1, 0.9), CFrame.new(x - side * 1.6, r * 1.15, z + 2.5), frame)
			end
			-- Half-drawn privacy curtain on the lower bunk.
			if k % 2 == 0 then
				part(m, "Curtain", Vector3.new(0.05, 3, 3.2), CFrame.new(x - side * 1.5, 3.1, z - 1.8), { Color = rgb(90, 100, 120), Material = M.Fabric, CanCollide = false })
			end
		end
	end
	-- Card table with chairs and a scattered hand of cards.
	part(m, "CardTable", Vector3.new(3, 0.2, 4), CFrame.new(5, 2.9, -17), { Color = rgb(70, 74, 82), Material = M.Metal })
	part(m, "TableLeg", Vector3.new(0.4, 2.8, 0.4), CFrame.new(5, 1.4, -17), frame)
	for _, dz in { -2.8, 2.8 } do
		chair(m, CFrame.new(5, 0, -17 + dz) * CFrame.Angles(0, if dz > 0 then 0 else math.pi, 0), rgb(60, 65, 80))
	end
	for _ = 1, 7 do
		part(m, "Card", Vector3.new(0.5, 0.02, 0.7), CFrame.new(5 + rand:NextNumber(-1, 1), 3.01 + rand:NextNumber(0, 0.02), -17 + rand:NextNumber(-1.5, 1.5)) * CFrame.Angles(0, rand:NextNumber(0, 3), 0),
			{ Color = rgb(235, 232, 225), CanCollide = false })
	end
	-- Personal lockers either side of the exit.
	for _, sx in { -1, 1 } do
		for j = 0, 3 do
			local x = sx * (5 + j * 1.6)
			part(m, "Locker", Vector3.new(1.5, 7, 1.5), CFrame.new(x, 3.5, -L + 0.75), { Color = if j % 2 == 0 then rgb(70, 80, 95) else rgb(65, 74, 88), Material = M.Metal })
			part(m, "LockerVent", Vector3.new(1, 0.6, 0.05), CFrame.new(x, 6, -L + 1.525), { Color = rgb(30, 32, 36) })
		end
	end
	part(m, "LaundryPile", Vector3.new(2, 0.8, 1.6), CFrame.new(-6, 0.4, -33), { Color = rgb(90, 95, 110), Material = M.Fabric })
	wallSign(m, w, -1, -17, 9, Vector2.new(4, 1), "LIGHTS OUT 22:00")
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

-- Galley: a working ship's kitchen frozen mid-service. A range with one burner still glowing under a pot,
-- an extractor hood, a prep island under a hanging pot rack, sinks and dish racks, a walk-in freezer.
local function galley(): Model
	local m = B.newRoom("Galley", { Weight = 2, MinRoom = 3 })
	local w, L, h, p = 26, 32, 11, PAL.galley
	B.shell(m, w, L, h, p)
	local rand = Random.new(3)
	local steel = { Color = rgb(175, 178, 182), Material = M.Metal }
	local darkSteel = { Color = rgb(70, 72, 78), Material = M.Metal }
	local black = { Color = rgb(22, 22, 24) }
	local tile = { Color = rgb(210, 212, 205), Material = M.CeramicTiles }
	local rotten = { rgb(70, 60, 30), rgb(60, 50, 40), rgb(90, 80, 40), rgb(50, 60, 35) }
	local function counter(x: number, z0: number, z1: number, side: number)
		local len, zc = z0 - z1, (z0 + z1) / 2
		part(m, "CounterBase", Vector3.new(2.5, 3.2, len), CFrame.new(x, 1.6, zc), steel)
		part(m, "CounterTop", Vector3.new(2.7, 0.15, len), CFrame.new(x - side * 0.1, 3.275, zc), { Color = rgb(195, 198, 202), Material = M.Metal })
		for z = z0 - 1.5, z1 + 1.5, -3 do
			part(m, "CabinetSeam", Vector3.new(0.05, 2.6, 0.06), CFrame.new(x - side * 1.275, 1.6, z), darkSteel)
		end
		B.onWall(m, w, side, zc, 4.55, Vector2.new(len, 2.4), 0.05, "Backsplash", tile)
	end

	-- RIGHT WALL: counter runs either side of a big range with an extractor hood.
	local rx = w / 2 - 1.25
	counter(rx, -2.5, -9.5, 1)
	counter(rx, -16.5, -27.5, 1)
	part(m, "Range", Vector3.new(2.5, 3.3, 7), CFrame.new(rx, 1.65, -13), darkSteel)
	part(m, "RangeTop", Vector3.new(2.5, 0.12, 7), CFrame.new(rx, 3.36, -13), black)
	for i = 0, 5 do
		local bx, bz = rx + (if i % 2 == 0 then -0.6 else 0.6), -15.2 + math.floor(i / 2) * 2.2
		local lit = i == 3
		part(m, "Burner", Vector3.new(0.06, 0.9, 0.9), CFrame.new(bx, 3.45, bz) * CFrame.Angles(0, 0, math.pi / 2),
			{ Shape = Enum.PartType.Cylinder, Material = if lit then M.Neon else M.Metal, Color = if lit then rgb(200, 50, 20) else rgb(45, 45, 48), CanCollide = false })
		if lit then
			-- A pot left on the one burner that never went out.
			local pot = part(m, "StockPot", Vector3.new(1.3, 1.2, 1.2), CFrame.new(bx, 4.13, bz) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(150, 152, 156), Material = M.Metal }) :: Part
			glowing(pot, rgb(255, 90, 40), 6, 0.5)
		end
	end
	part(m, "Frypan", Vector3.new(0.12, 1.1, 1.1), CFrame.new(rx - 0.6, 3.51, -15.2) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(35, 35, 38), Material = M.Metal })
	part(m, "FrypanHandle", Vector3.new(0.12, 0.08, 1.1), CFrame.new(rx - 1.5, 3.53, -15.2) * CFrame.Angles(0, 0.3, 0), black)
	for _, dz in { -1.7, 1.7 } do
		part(m, "OvenDoor", Vector3.new(0.06, 2, 3), CFrame.new(rx - 1.33, 1.5, -13 + dz), darkSteel)
		part(m, "OvenWindow", Vector3.new(0.04, 0.9, 1.8), CFrame.new(rx - 1.37, 1.7, -13 + dz), { Color = rgb(20, 20, 22), Material = M.Glass, Reflectance = 0.2 })
		part(m, "OvenHandle", Vector3.new(0.15, 0.12, 2.2), CFrame.new(rx - 1.45, 2.6, -13 + dz), steel)
	end
	part(m, "Hood", Vector3.new(3, 1.4, 7.4), CFrame.new(w / 2 - 1.5, 7.9, -13), steel)
	part(m, "HoodDuct", Vector3.new(1.6, h - 8.6, 2.4), CFrame.new(w / 2 - 0.8, 8.6 + (h - 8.6) / 2, -13), steel)
	local hoodLight = part(m, "Lamp", Vector3.new(1.6, 0.1, 5), CFrame.new(w / 2 - 1.6, 7.15, -13), { Material = M.Neon, Color = rgb(200, 190, 160), CanCollide = false }) :: Part
	local hl = Instance.new("SurfaceLight")
	hl.Face = Enum.NormalId.Bottom
	hl.Range = 8
	hl.Brightness = 0.6
	hl.Color = rgb(255, 230, 190)
	hl.Parent = hoodLight
	-- Utensils on the right counters.
	part(m, "Mixer", Vector3.new(1, 1.6, 1.2), CFrame.new(rx, 4.15, -5), { Color = rgb(170, 40, 35) })
	part(m, "MixBowl", Vector3.new(0.8, 0.9, 0.9), CFrame.new(rx - 0.2, 3.75, -7.2) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(190, 192, 196), Material = M.Metal })
	for k = 0, 3 do
		part(m, "Tray", Vector3.new(1.4, 0.08, 2), CFrame.new(rx, 3.39 + k * 0.09, -20), { Color = rgb(180, 180, 175), Material = M.Metal })
	end
	part(m, "RiceCooker", Vector3.new(1, 0.9, 1), CFrame.new(rx, 3.8, -24) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(220, 220, 215) })

	-- LEFT WALL: double sink with a dish rack, shelves of jars, then a prep counter with a knife strip.
	local lx = -w / 2 + 1.25
	counter(lx, -2.5, -14.5, -1)
	counter(lx, -16.5, -27.5, -1)
	for _, dz in { -1.3, 1.3 } do
		part(m, "SinkBasin", Vector3.new(1.8, 0.04, 2.2), CFrame.new(lx + 0.1, 3.37, -8.5 + dz), { Color = rgb(40, 42, 44) })
	end
	part(m, "Faucet", Vector3.new(0.18, 1.4, 0.18), CFrame.new(lx - 0.9, 4.05, -8.5), steel)
	part(m, "Spout", Vector3.new(1, 0.15, 0.15), CFrame.new(lx - 0.45, 4.7, -8.5), steel)
	part(m, "DishRack", Vector3.new(1.6, 0.1, 2.6), CFrame.new(lx + 0.1, 3.4, -4.6), steel)
	for k = 0, 5 do
		part(m, "Plate", Vector3.new(0.06, 0.9, 0.9), CFrame.new(lx + 0.1, 3.9, -5.7 + k * 0.42), { Shape = Enum.PartType.Cylinder, Color = rgb(230, 228, 220) })
	end
	part(m, "Dishes", Vector3.new(1.4, 0.6, 1.8), CFrame.new(lx + 0.1, 3.67, -12.6), { Color = rgb(150, 150, 140) })
	for _, y in { 6.6, 8.2 } do
		B.onWall(m, w, -1, -8.5, y, Vector2.new(11, 0.15), 1, "Shelf", steel)
		for k = 0, 9 do
			local jh = rand:NextNumber(0.6, 1)
			part(m, "Jar", Vector3.new(jh, 0.45, 0.45), CFrame.new(-w / 2 + 0.5, y + 0.075 + jh / 2, -13.5 + k * 1.05) * CFrame.Angles(0, 0, math.pi / 2),
				{ Shape = Enum.PartType.Cylinder, Color = rgb(rand:NextInteger(120, 210), rand:NextInteger(90, 170), rand:NextInteger(50, 110)), Material = M.Glass, Transparency = 0.25 })
		end
	end
	-- Prep counter: cutting boards, a cleaver, rotting vegetables, a magnetic knife strip.
	for _, z in { -19, -24 } do
		part(m, "CuttingBoard", Vector3.new(1.4, 0.12, 2), CFrame.new(lx + 0.2, 3.41, z), { Color = rgb(160, 120, 80), Material = M.Wood })
		for _ = 1, 4 do
			part(m, "Vegetable", Vector3.new(rand:NextNumber(0.3, 0.6), rand:NextNumber(0.25, 0.45), rand:NextNumber(0.3, 0.7)),
				CFrame.new(lx + 0.2 + rand:NextNumber(-0.4, 0.4), 3.62, z + rand:NextNumber(-0.7, 0.7)) * CFrame.Angles(0, rand:NextNumber(0, 3), 0),
				{ Color = rotten[rand:NextInteger(1, #rotten)], Material = M.Ground, CanCollide = false })
		end
	end
	part(m, "Cleaver", Vector3.new(0.5, 0.05, 1), CFrame.new(lx + 0.5, 3.5, -21.5) * CFrame.Angles(0, 0.5, 0), steel)
	B.onWall(m, w, -1, -21.5, 5.6, Vector2.new(3, 0.3), 0.08, "KnifeStrip", black)
	for k = -2, 2 do
		if k ~= 1 then
			part(m, "Knife", Vector3.new(0.04, 1.1, 0.2), CFrame.new(-w / 2 + 0.11, 5.2, -21.5 + k * 0.55), steel)
		end
	end
	-- Order ticket rail with the last orders still clipped to it.
	B.onWall(m, w, -1, -22, 7.6, Vector2.new(5, 0.2), 0.15, "TicketRail", steel)
	for k = 0, 3 do
		local t = part(m, "Ticket", Vector3.new(0.03, 1, 0.8), CFrame.new(-w / 2 + 0.17, 7, -23.8 + k * 1.2) * CFrame.Angles(rand:NextNumber(-0.1, 0.1), 0, 0), { Color = rgb(240, 238, 225), CanCollide = false }) :: Part
		B.label(t, if k == 3 then "MESS\n18:00\nx214" else "MESS\n12:00", Enum.NormalId.Right, rgb(40, 40, 40), Enum.Font.Code)
	end

	-- CENTRE-LEFT: prep island under a hanging pot rack.
	local ix, iz = -6, -15
	for _, dx in { -1.35, 1.35 } do
		for _, dz in { -4.85, 4.85 } do
			part(m, "IslandLeg", Vector3.new(0.3, 3.2, 0.3), CFrame.new(ix + dx, 1.6, iz + dz), steel)
		end
	end
	part(m, "IslandTop", Vector3.new(3.3, 0.15, 10.3), CFrame.new(ix, 3.275, iz), { Color = rgb(195, 198, 202), Material = M.Metal })
	part(m, "IslandShelf", Vector3.new(2.8, 0.1, 9.6), CFrame.new(ix, 0.8, iz), darkSteel)
	for k = 0, 2 do
		part(m, "StockPot", Vector3.new(1, 1, 1), CFrame.new(ix + (k - 1) * 0.9, 1.35, iz + 2), { Shape = Enum.PartType.Cylinder, Color = rgb(150, 152, 156), Material = M.Metal })
	end
	part(m, "Ladle", Vector3.new(0.1, 0.1, 1.4), CFrame.new(ix + 0.6, 3.41, iz - 2) * CFrame.Angles(0, 0.4, 0), steel)
	part(m, "Flour", Vector3.new(1, 1.3, 0.8), CFrame.new(ix - 0.7, 4, iz - 3.5), { Color = rgb(225, 220, 200), Material = M.Fabric })
	part(m, "Spill", Vector3.new(0.03, 1.4, 1.8), CFrame.new(ix - 0.3, 3.365, iz - 1.8) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(230, 228, 215), CanCollide = false })
	part(m, "PotRack", Vector3.new(2.4, 0.15, 8), CFrame.new(ix, 8, iz), darkSteel)
	for _, dz in { -3.5, 3.5 } do
		part(m, "RackChain", Vector3.new(0.08, h - 8.08, 0.08), CFrame.new(ix, 8.08 + (h - 8.08) / 2, iz + dz), darkSteel)
	end
	for k = 0, 5 do
		local z = iz - 3 + k * 1.2
		local big = k % 2 == 0
		part(m, "PotHook", Vector3.new(0.05, 0.5, 0.05), CFrame.new(ix + (if big then -0.6 else 0.6), 7.67, z), darkSteel)
		part(m, if big then "HangingPot" else "HangingPan", if big then Vector3.new(0.8, 0.9, 0.9) else Vector3.new(0.1, 0.9, 0.9),
			CFrame.new(ix + (if big then -0.6 else 0.6), 6.95, z) * (if big then CFrame.Angles(0, 0, math.pi / 2) else CFrame.Angles(0, math.pi / 2, 0)),
			{ Shape = Enum.PartType.Cylinder, Color = if big then rgb(150, 152, 156) else rgb(40, 40, 42), Material = M.Metal })
	end

	-- FAR WALL: walk-in freezer door rimmed with frost, and ration crates with a trolley.
	local fx = -8
	for _, dx in { -2.3, 2.3 } do
		part(m, "FreezerFrame", Vector3.new(0.5, 8, 0.6), CFrame.new(fx + dx, 4, -L + 0.3), darkSteel)
	end
	part(m, "FreezerFrame", Vector3.new(5.1, 0.5, 0.6), CFrame.new(fx, 8.25, -L + 0.3), darkSteel)
	part(m, "FreezerDoor", Vector3.new(4.1, 7.8, 0.4), CFrame.new(fx, 3.9, -L + 0.2), { Color = rgb(190, 205, 215), Material = M.Metal })
	part(m, "FreezerHandle", Vector3.new(0.2, 1.8, 0.25), CFrame.new(fx + 1.5, 4, -L + 0.52), steel)
	part(m, "FreezerWindow", Vector3.new(1.2, 1.2, 0.05), CFrame.new(fx, 6, -L + 0.42), { Color = rgb(200, 225, 240), Material = M.Ice, Transparency = 0.2 })
	part(m, "Frost", Vector3.new(5, 0.04, 2.5), CFrame.new(fx, 0.02, -L + 1.85), { Color = rgb(210, 230, 245), Material = M.Ice, CanCollide = false, Transparency = 0.2 })
	endSign(m, -L, 1, fx, 9.5, Vector2.new(4.6, 0.9), "COLD STORAGE  -18 C", rgb(30, 50, 80), rgb(200, 225, 255))
	for _, c in { { 7.5, 1.25, -30, 2.5 }, { 10.2, 1.25, -30, 2.5 }, { 8.8, 3.75, -30.2, 2.5 }, { 5, 1, -30.5, 2 } } do
		local cr = part(m, "RationCrate", Vector3.new(c[4], c[4], c[4]), CFrame.new(c[1], c[2], c[3]) * CFrame.Angles(0, rand:NextNumber(-0.1, 0.1), 0), { Color = rgb(70, 90, 70), Material = M.Metal }) :: Part
		B.label(cr, "RATIONS", Enum.NormalId.Back, rgb(220, 220, 200), Enum.Font.Code)
	end
	part(m, "Trolley", Vector3.new(2, 0.15, 3), CFrame.new(6, 2.4, -22), steel)
	part(m, "TrolleyShelf", Vector3.new(2, 0.15, 3), CFrame.new(6, 0.8, -22), steel)
	for _, o in { Vector3.new(-0.9, 0, -1.4), Vector3.new(0.9, 0, -1.4), Vector3.new(-0.9, 0, 1.4), Vector3.new(0.9, 0, 1.4) } do
		part(m, "TrolleyPost", Vector3.new(0.1, 2.3, 0.1), CFrame.new(6 + o.X, 1.35, -22 + o.Z), steel)
	end
	for k = 0, 1 do
		part(m, "Tray", Vector3.new(1.4, 0.08, 2), CFrame.new(6, 2.52 + k * 0.09, -22), { Color = rgb(180, 180, 175), Material = M.Metal })
	end
	-- Floor drain, mop and bucket, the menu.
	part(m, "Drain", Vector3.new(1.2, 0.04, 1.2), CFrame.new(-2, 0.02, -15), { Color = rgb(30, 32, 34), Material = M.DiamondPlate, CanCollide = false })
	part(m, "Bucket", Vector3.new(1, 1.1, 1.1), CFrame.new(4, 0.5, -5) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(200, 170, 40), Material = M.Plastic })
	part(m, "Mop", Vector3.new(0.1, 5, 0.1), CFrame.new(4.3, 2.8, -5.3) * CFrame.Angles(0.15, 0, -0.2), { Color = rgb(140, 110, 70), Material = M.Wood })
	wallSign(m, w, -1, -27, 9.4, Vector2.new(5, 1.2), "ALL CREW MEALS ARE MANDATORY")
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.7)
	return m
end

-- Comms array: banks of transmitter racks with patch cables, an operator's console, a call that was never answered.
local function comms(): Model
	local m = B.newRoom("CommsArray", { Weight = 1, MinRoom = 9 })
	local w, L, h, p = 26, 30, 13, PAL.archive
	B.shell(m, w, L, h, p)
	local rand = Random.new(4)
	local rack = { Color = rgb(40, 42, 48), Material = M.Metal }
	local dark = { Color = rgb(28, 30, 34) }
	-- Three racks on the right wall with blinking lights and drooping patch cables.
	for _, z in { -8, -14, -20 } do
		local x = w / 2 - 1.5
		part(m, "Rack", Vector3.new(3, 10, 5), CFrame.new(x, 5, z), rack)
		for k = 0, 3 do
			part(m, "PatchPanel", Vector3.new(0.06, 0.8, 4.4), CFrame.new(x - 1.53, 2.5 + k * 2, z), dark)
		end
		for _ = 1, 10 do
			part(m, "Led", Vector3.new(0.05, 0.2, 0.2), CFrame.new(x - 1.58, rand:NextNumber(1.5, 9), z + rand:NextNumber(-2.1, 2.1)),
				{ Material = M.Neon, Color = if rand:NextNumber() < 0.5 then rgb(230, 60, 50) else rgb(230, 160, 40), CanCollide = false })
		end
		for _ = 1, 3 do
			local y = rand:NextNumber(3, 8)
			part(m, "PatchCable", Vector3.new(0.08, 0.08, rand:NextNumber(1.5, 3)), CFrame.new(x - 1.65, y, z + rand:NextNumber(-1, 1)) * CFrame.Angles(rand:NextNumber(-0.6, 0.6), 0, 0),
				{ Color = if rand:NextNumber() < 0.5 then rgb(200, 180, 40) else rgb(40, 90, 180), CanCollide = false })
		end
	end
	-- Operator's console on the left: screens with waveforms, headset, mic, logbook.
	local cx = -w / 2 + 1.25
	part(m, "Console", Vector3.new(2.5, 3, 12), CFrame.new(cx, 1.5, -14), rack)
	part(m, "ConsoleTop", Vector3.new(2.7, 0.15, 12.2), CFrame.new(cx + 0.1, 3.075, -14), { Color = rgb(25, 27, 30) })
	for _, z in { -10, -14, -18 } do
		part(m, "Monitor", Vector3.new(0.15, 1.4, 2.4), CFrame.new(cx - 0.5, 3.95, z) * CFrame.Angles(0, 0, 0.2), dark)
		local wave = part(m, "Waveform", Vector3.new(0.03, 1.1, 2.1), CFrame.new(cx - 0.4, 3.97, z) * CFrame.Angles(0, 0, 0.2),
			{ Material = M.Neon, Color = rgb(10, 30, 15), CanCollide = false }) :: Part
		B.label(wave, if z == -14 then "NO CARRIER" else "~ ~ ~ ~ ~", Enum.NormalId.Right, rgb(120, 230, 140), Enum.Font.Code)
	end
	part(m, "Headset", Vector3.new(0.5, 0.5, 1.2), CFrame.new(cx + 0.6, 3.4, -12), dark)
	part(m, "MicStand", Vector3.new(0.12, 1, 0.12), CFrame.new(cx + 0.5, 3.65, -16), dark)
	part(m, "Mic", Vector3.new(0.5, 0.25, 0.25), CFrame.new(cx + 0.5, 4.25, -16) * CFrame.Angles(0, 0, 0.6), { Shape = Enum.PartType.Cylinder, Color = rgb(60, 62, 68) })
	local log = part(m, "Logbook", Vector3.new(0.8, 0.12, 1.1), CFrame.new(cx + 0.6, 3.21, -19), { Color = rgb(80, 30, 30) }) :: Part
	B.label(log, "CALL LOG", Enum.NormalId.Top, rgb(220, 200, 160))
	part(m, "MorseKey", Vector3.new(0.6, 0.15, 0.3), CFrame.new(cx + 0.6, 3.225, -8.8), { Color = rgb(170, 140, 80), Material = M.Metal })
	chair(m, CFrame.new(cx + 3.2, 0, -14) * CFrame.Angles(0, math.rad(90), 0), rgb(60, 65, 80))
	local screen = B.onWall(m, w, -1, -14, 8.5, Vector2.new(10, 3.5), 0.2, "Screen", { Color = rgb(10, 30, 15), Material = M.Neon }) :: Part
	B.label(screen, "SIGNAL LOST\nLAST CONTACT: 4,811 DAYS AGO\nRETRYING...", Enum.NormalId.Right, rgb(120, 230, 140), Enum.Font.Code)
	-- Cable bundle along the floor between the racks and the console.
	part(m, "CableBundle", Vector3.new(w - 6, 0.3, 0.6), CFrame.new(0, 0.15, -24), { Color = rgb(25, 25, 28), Material = M.Rubber, CanCollide = false })
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
	B.label(plate, "CAPT. ZOE ANDERSEN", Enum.NormalId.Back, rgb(40, 30, 20))
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

-- Conference room: a long rounded table set for a meeting, a projector, a chart that only goes up.
local function conference(): Model
	local m = B.newRoom("ConferenceRoom", { Weight = 1, MinRoom = 2 })
	local w, L, h, p = 26, 28, 10, PAL.office
	B.shell(m, w, L, h, p, {
		windows = {
			{ side = "left", z = -5.5, y = 3.5, w = 6, h = 3.5 },
			{ side = "right", z = -5.5, y = 3.5, w = 6, h = 3.5 },
		},
	})
	local rand = Random.new(2)
	local wood = { Color = rgb(60, 44, 34), Material = M.Wood }
	local dark = { Color = rgb(30, 31, 35) }
	local tx = -7
	part(m, "Table", Vector3.new(5, 0.3, 14), CFrame.new(tx, 2.85, -15), wood)
	for _, z in { -8, -22 } do
		part(m, "TableEnd", Vector3.new(0.3, 5, 5), CFrame.new(tx, 2.85, z) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = wood.Color, Material = wood.Material })
		part(m, "TableBase", Vector3.new(1.2, 2.7, 2.4), CFrame.new(tx, 1.35, z + (if z == -8 then -2 else 2)), wood)
	end
	part(m, "Speakerphone", Vector3.new(0.15, 1.2, 1.2), CFrame.new(tx, 3.075, -15) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(20, 20, 22) })
	for _, z in { -9.5, -13, -16.5, -20 } do
		for _, sx in { -1, 1 } do
			local seat = tx + sx * 3.9
			chair(m, CFrame.new(seat, 0, z + rand:NextNumber(-0.3, 0.3)) * CFrame.Angles(0, math.rad(sx * 90) + rand:NextNumber(-0.3, 0.3), 0), rgb(50, 55, 70))
			local nx = tx + sx * 1.6
			part(m, "Notepad", Vector3.new(0.8, 0.03, 1.1), CFrame.new(nx, 3.015, z), { Color = rgb(235, 232, 210), CanCollide = false })
			part(m, "Glass", Vector3.new(0.4, 0.25, 0.25), CFrame.new(nx + sx * -0.6, 3.2, z + 0.7) * CFrame.Angles(0, 0, math.pi / 2),
				{ Shape = Enum.PartType.Cylinder, Color = rgb(200, 220, 230), Material = M.Glass, Transparency = 0.5 })
			if rand:NextNumber() < 0.5 then
				part(m, "Laptop", Vector3.new(0.9, 0.06, 1.3), CFrame.new(nx, 3.06, z - 0.1), dark)
				part(m, "LaptopLid", Vector3.new(0.05, 0.85, 1.3), CFrame.new(nx + sx * 0.45, 3.45, z - 0.1) * CFrame.Angles(0, 0, sx * 0.25), dark)
			end
		end
	end
	-- Projector and the screen it's aimed at.
	part(m, "ProjectorMount", Vector3.new(0.15, 1.2, 0.15), CFrame.new(3, h - 0.6, -15), dark)
	part(m, "Projector", Vector3.new(1.2, 0.5, 1.2), CFrame.new(3, h - 1.45, -15), { Color = rgb(200, 200, 195) })
	local screen = B.onWall(m, w, 1, -15, 5.5, Vector2.new(10, 5), 0.2, "Screen", { Color = rgb(30, 40, 60), Material = M.Neon }) :: Part
	B.label(screen, "Q3 SOLAR YIELD: +1400%\n\n\n\nTHANK YOU, TEAM", Enum.NormalId.Left, rgb(220, 230, 255))
	for k = 0, 4 do
		local bh = 0.5 + k ^ 1.8 * 0.25
		part(m, "ChartBar", Vector3.new(0.03, bh, 0.9), CFrame.new(w / 2 - 0.215, 4 + bh / 2, -18 + k * 1.5), { Material = M.Neon, Color = rgb(255, 150, 60), CanCollide = false })
	end
	-- Credenza with a coffee machine, a plant, a whiteboard, a clock.
	part(m, "Credenza", Vector3.new(6, 3, 1.6), CFrame.new(-8, 1.5, -L + 0.8), wood)
	part(m, "CoffeeMachine", Vector3.new(1.2, 1.6, 1), CFrame.new(-9.5, 3.8, -L + 0.8), dark)
	part(m, "CoffeePot", Vector3.new(0.6, 0.5, 0.5), CFrame.new(-8.3, 3.3, -L + 0.8) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(60, 40, 30), Material = M.Glass, Transparency = 0.3 })
	part(m, "Pot", Vector3.new(1.4, 1.4, 1.4), CFrame.new(w / 2 - 1, 0.7, -L + 1), { Color = rgb(150, 90, 60), Material = M.Concrete })
	part(m, "Plant", Vector3.new(2.4, 2.4, 2.4), CFrame.new(w / 2 - 1, 2.5, -L + 1), { Shape = Enum.PartType.Ball, Color = rgb(70, 90, 50), Material = M.Grass })
	wallSign(m, w, -1, -15, 6.5, Vector2.new(7, 3), "SOL = ?\nYIELD > SAFETY\n(do not erase)", rgb(230, 232, 234), rgb(40, 50, 90), Enum.Font.Cartoon)
	part(m, "Clock", Vector3.new(0.15, 1.6, 1.6), CFrame.new(6, 8, -L + 0.075) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Color = rgb(230, 230, 225) })
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.6)
	return m
end

-- Engineering workshop: tool chests, a drill press, a lathe, a welding bay, and a half-built drone under a hoist.
local function workshop(): Model
	local m = B.newRoom("Workshop", { Weight = 2, MinRoom = 5 })
	local w, L, h, p = 30, 34, 12, PAL.engine
	B.shell(m, w, L, h, p)
	local rand = Random.new(5)
	local steel = { Color = rgb(130, 132, 138), Material = M.Metal }
	local dark = { Color = rgb(45, 47, 52), Material = M.Metal }
	local red = { Color = rgb(170, 40, 35), Material = M.Metal }
	-- Workbenches along both walls with vises, pegboards and tool chests.
	for _, side in { -1, 1 } do
		for _, z in { -7, -19 } do
			local x = side * (w / 2 - 1.5)
			part(m, "Workbench", Vector3.new(3, 0.3, 9), CFrame.new(x, 3, z), { Color = rgb(110, 90, 65), Material = M.WoodPlanks })
			for _, dz in { -4.2, 4.2 } do
				part(m, "BenchLeg", Vector3.new(2.8, 2.85, 0.3), CFrame.new(x, 1.425, z + dz), dark)
			end
			part(m, "Vise", Vector3.new(1, 0.8, 1.4), CFrame.new(x - side * 0.6, 3.55, z - 3), { Color = rgb(60, 70, 90), Material = M.Metal })
			for k = 0, 2 do
				part(m, "Part", Vector3.new(rand:NextNumber(0.3, 0.8), 0.25, rand:NextNumber(0.3, 0.8)), CFrame.new(x + rand:NextNumber(-0.8, 0.8), 3.275, z + k * 1.5) * CFrame.Angles(0, rand:NextNumber(0, 3), 0), steel)
			end
			local board = B.onWall(m, w, side, z, 6.2, Vector2.new(9, 3), 0.1, "Pegboard", { Color = rgb(150, 125, 90), Material = M.Cardboard }) :: Part
			for k = -3, 3 do
				local present = rand:NextNumber() < 0.7
				part(m, if present then "Tool" else "ToolOutline", Vector3.new(0.05, rand:NextNumber(1, 1.8), 0.3),
					(board.CFrame * CFrame.new(-side * 0.075, 0, k * 1.2)) * CFrame.Angles(k * 0.2, 0, 0),
					{ Color = if present then rgb(40, 40, 44) else rgb(110, 90, 65), Material = if present then M.Metal else M.Cardboard, CanCollide = false })
			end
		end
		-- Rolling tool chest.
		part(m, "ToolChest", Vector3.new(2, 4.2, 3), CFrame.new(side * (w / 2 - 1), 2.1, -25.5), red)
		for d = 0, 4 do
			part(m, "Drawer", Vector3.new(0.05, 0.08, 2.4), CFrame.new(side * (w / 2 - 2.025), 0.7 + d * 0.75, -25.5), dark)
		end
	end
	-- Drill press and lathe near the far wall.
	part(m, "DrillBase", Vector3.new(2, 0.4, 2), CFrame.new(10, 0.2, -30), dark)
	part(m, "DrillColumn", Vector3.new(0.35, 6, 0.35), CFrame.new(10.6, 3.2, -30), steel)
	part(m, "DrillTable", Vector3.new(1.6, 0.2, 1.6), CFrame.new(10, 3, -30), steel)
	part(m, "DrillHead", Vector3.new(1.2, 1.4, 2), CFrame.new(10.3, 5.8, -30), { Color = rgb(60, 100, 70), Material = M.Metal })
	part(m, "DrillBit", Vector3.new(0.08, 0.9, 0.08), CFrame.new(10, 4.75, -30), steel)
	part(m, "LatheBed", Vector3.new(2, 3, 6), CFrame.new(-10, 1.5, -30), dark)
	part(m, "LatheHead", Vector3.new(1.6, 1.6, 1.4), CFrame.new(-10, 3.8, -32.2), { Color = rgb(60, 100, 70), Material = M.Metal })
	part(m, "LatheStock", Vector3.new(3.6, 0.5, 0.5), CFrame.new(-10, 3.6, -30) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Color = steel.Color, Material = steel.Material })
	-- Welding bay in the corner behind a red curtain.
	part(m, "WeldCurtain", Vector3.new(0.1, 6, 5), CFrame.new(-9, 3.2, -24.5), { Color = rgb(150, 40, 30), Material = M.Glass, Transparency = 0.35, CanCollide = false })
	for k = 0, 1 do
		part(m, "GasBottle", Vector3.new(4, 1, 1), CFrame.new(-10.5 - k * 1.1, 2, -25.5 + k * 0.6) * CFrame.Angles(0, 0, math.pi / 2),
			{ Shape = Enum.PartType.Cylinder, Color = if k == 0 then rgb(60, 110, 70) else rgb(70, 70, 75), Material = M.Metal })
	end
	-- Half-built drone on a table under a ceiling hoist.
	part(m, "AssemblyTable", Vector3.new(3, 0.3, 6), CFrame.new(7.5, 2.85, -13), steel)
	part(m, "TableLeg", Vector3.new(2.6, 2.7, 0.3), CFrame.new(7.5, 1.35, -10.4), dark)
	part(m, "TableLeg", Vector3.new(2.6, 2.7, 0.3), CFrame.new(7.5, 1.35, -15.6), dark)
	part(m, "DroneBody", Vector3.new(1.8, 0.8, 2.4), CFrame.new(7.5, 3.4, -13), { Color = rgb(200, 202, 205), Material = M.Metal })
	for _, o in { Vector3.new(-1.3, 0, -1.5), Vector3.new(1.3, 0, -1.5), Vector3.new(-1.3, 0, 1.5) } do
		part(m, "DroneArm", Vector3.new(0.25, 0.2, 1.6), CFrame.new(7.5 + o.X * 0.6, 3.5, -13 + o.Z * 0.6) * CFrame.Angles(0, math.atan2(o.X, o.Z), 0), steel)
		part(m, "Rotor", Vector3.new(0.08, 1.2, 1.2), CFrame.new(7.5 + o.X, 3.65, -13 + o.Z) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(40, 40, 44) })
	end
	part(m, "LooseRotor", Vector3.new(0.08, 1.2, 1.2), CFrame.new(8.3, 3.04, -10.8) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(40, 40, 44) })
	part(m, "HoistRail", Vector3.new(0.4, 0.4, 20), CFrame.new(7.5, h - 0.2, -15), steel)
	part(m, "HoistChain", Vector3.new(0.12, h - 6.2, 0.12), CFrame.new(7.5, 6 + (h - 6.2) / 2 - 0.2, -13), steel)
	part(m, "HoistHook", Vector3.new(0.4, 0.6, 0.15), CFrame.new(7.5, 5.7, -13), { Color = rgb(200, 160, 40), Material = M.Metal })
	wallSign(m, w, -1, -13, 9.5, Vector2.new(7, 1.2), "EYE PROTECTION REQUIRED", rgb(200, 160, 40), rgb(30, 25, 10))
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.6)
	return m
end

-- Cargo hold: corrugated containers stacked two high, pallets, a forklift, a gantry crane, one container left open.
local function container(m: Model, cf: CFrame, color: Color3, open: boolean)
	local body = { Color = color, Material = M.CorrodedMetal }
	part(m, "Container", Vector3.new(8, 7, 16), cf, body)
	-- Corrugation ribs on both long sides.
	for _, sx in { -1, 1 } do
		for k = -7, 7, 1.5 do
			part(m, "Corrugation", Vector3.new(0.12, 6.6, 0.4), cf * CFrame.new(sx * 4.06, 0, k), { Color = color:Lerp(Color3.new(0, 0, 0), 0.2), Material = M.CorrodedMetal })
		end
	end
	-- Doors with lock bars on the end facing the room.
	local doorFace = cf * CFrame.new(0, 0, 8.05)
	if open then
		part(m, "ContainerInside", Vector3.new(7.4, 6.4, 0.05), cf * CFrame.new(0, 0, 8.01), { Color = rgb(10, 10, 12) })
		part(m, "ContainerDoor", Vector3.new(0.15, 6.6, 3.8), cf * CFrame.new(-4.1, 0, 9.95), body)
	else
		for _, dx in { -1.9, 1.9 } do
			part(m, "ContainerDoor", Vector3.new(3.7, 6.6, 0.1), doorFace * CFrame.new(dx, 0, 0), body)
			for _, bx in { -1, 1 } do
				part(m, "LockBar", Vector3.new(0.12, 6.4, 0.12), doorFace * CFrame.new(dx + bx * 0.9, 0, 0.11), { Color = rgb(150, 150, 150), Material = M.Metal })
			end
		end
	end
	local label = part(m, "ContainerLabel", Vector3.new(0.05, 1.2, 6), cf * CFrame.new(-4.2, 2, 0), { Color = color:Lerp(Color3.new(1, 1, 1), 0.6) }) :: Part
	B.label(label, "SOLSTICE", Enum.NormalId.Left, rgb(40, 30, 25))
end

local function cargo(): Model
	local m = B.newRoom("CargoHold", { Weight = 1, MinRoom = 10 })
	local w, L, h, p = 40, 48, 16, PAL.hangar
	B.shell(m, w, L, h, p)
	local rand = Random.new(10)
	local dark = { Color = rgb(55, 57, 62), Material = M.Metal }
	container(m, CFrame.new(14, 3.5, -22), rgb(130, 60, 40), false)
	container(m, CFrame.new(14, 10.5, -24), rgb(50, 80, 110), false)
	container(m, CFrame.new(14, 3.5, -40), rgb(60, 100, 60), true)
	-- Pallets and crates on the left, one stack under a cargo net.
	for _, c in { { -12, -10 }, { -12, -18 }, { -14, -30 } } do
		for k = -1, 1 do
			part(m, "PalletSlat", Vector3.new(3.6, 0.15, 0.8), CFrame.new(c[1], 0.45, c[2] + k * 1.3), { Color = rgb(150, 120, 80), Material = M.WoodPlanks })
		end
		for _, dx in { -1.5, 1.5 } do
			part(m, "PalletBlock", Vector3.new(0.6, 0.38, 3.6), CFrame.new(c[1] + dx, 0.19, c[2]), { Color = rgb(130, 100, 65), Material = M.Wood })
		end
		local size = rand:NextNumber(2.4, 3.2)
		crate(m, CFrame.new(c[1], 0.525 + size / 2, c[2]) * CFrame.Angles(0, rand:NextNumber(-0.1, 0.1), 0), Vector3.new(size, size, size))
		crate(m, CFrame.new(c[1] + 0.3, 0.525 + size + 1, c[2] - 0.2) * CFrame.Angles(0, rand:NextNumber(-0.3, 0.3), 0), Vector3.new(2, 2, 2))
	end
	for k = -4, 4 do
		part(m, "CargoNet", Vector3.new(0.06, 6, 0.06), CFrame.new(-12 + k * 0.45, 3.3, -8.6) * CFrame.Angles(0.2, 0, 0), { Color = rgb(50, 45, 40), CanCollide = false })
	end
	-- Forklift.
	local fx, fz = -6, -38
	part(m, "ForkliftBody", Vector3.new(3, 2.4, 4.5), CFrame.new(fx, 1.6, fz), { Color = rgb(210, 170, 40), Material = M.Metal })
	part(m, "ForkliftSeat", Vector3.new(1.4, 0.4, 1.4), CFrame.new(fx, 3, fz + 0.8), { Color = rgb(30, 30, 30) })
	part(m, "ForkliftCage", Vector3.new(3, 0.2, 3), CFrame.new(fx, 6, fz + 0.5), dark)
	for _, o in { Vector3.new(-1.4, 0, -0.9), Vector3.new(1.4, 0, -0.9), Vector3.new(-1.4, 0, 1.9), Vector3.new(1.4, 0, 1.9) } do
		part(m, "CagePost", Vector3.new(0.15, 3.2, 0.15), CFrame.new(fx + o.X, 4.4, fz + o.Z), dark)
	end
	part(m, "Mast", Vector3.new(2.6, 6, 0.3), CFrame.new(fx, 3.4, fz - 2.4), dark)
	for _, dx in { -0.8, 0.8 } do
		part(m, "Fork", Vector3.new(0.3, 0.15, 3), CFrame.new(fx + dx, 0.3, fz - 4), { Color = rgb(150, 150, 150), Material = M.Metal })
	end
	for _, o in { Vector3.new(-1.6, 0, -1.4), Vector3.new(1.6, 0, -1.4), Vector3.new(-1.6, 0, 1.4), Vector3.new(1.6, 0, 1.4) } do
		part(m, "Wheel", Vector3.new(0.5, 1, 1), CFrame.new(fx + o.X, 0.5, fz + o.Z), { Shape = Enum.PartType.Cylinder, Color = rgb(25, 25, 25) })
	end
	-- Gantry crane across the hold.
	part(m, "Gantry", Vector3.new(w - 0.2, 1, 1), CFrame.new(0, h - 1.5, -30), { Color = rgb(200, 160, 40), Material = M.Metal })
	part(m, "Trolley", Vector3.new(2, 1, 1.6), CFrame.new(2, h - 2.5, -30), dark)
	part(m, "CraneCable", Vector3.new(0.12, 6, 0.12), CFrame.new(2, h - 6, -30), dark)
	part(m, "CraneHook", Vector3.new(0.5, 0.8, 0.2), CFrame.new(2, h - 9.4, -30), { Color = rgb(200, 160, 40), Material = M.Metal })
	for z = -4, -44, -8 do
		part(m, "Line", Vector3.new(0.3, 0.05, 4), CFrame.new(-4, 0.025, z), { Color = p.trim, CanCollide = false })
		part(m, "Line", Vector3.new(0.3, 0.05, 4), CFrame.new(4, 0.025, z), { Color = p.trim, CanCollide = false })
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

-- Infirmary ward: proper hospital beds behind ceiling-track curtains, heart monitors, a nurse station. One bed is overturned.
local function infirmary(): Model
	local m = B.newRoom("InfirmaryWard", { Weight = 2, MinRoom = 8 })
	local w, L, h, p = 28, 38, 11, PAL.med
	B.shell(m, w, L, h, p)
	local steel = { Color = rgb(170, 175, 178), Material = M.Metal }
	local white = { Color = rgb(230, 232, 230), Material = M.Fabric }
	for _, side in { -1, 1 } do
		for i, z in { -5, -12, -19, -26, -33 } do
			local overturned = side == 1 and i == 4
			local bedCf = CFrame.new(side * 9.6, 0, z)
			if overturned then
				bedCf = bedCf * CFrame.new(-side * 1.5, 1.6, 0) * CFrame.Angles(side * 1.5, 0, 0) * CFrame.new(0, -1.6, 0)
			end
			part(m, "BedFrame", Vector3.new(7, 0.4, 3), bedCf * CFrame.new(0, 2, 0), steel)
			for _, dx in { -3.2, 3.2 } do
				for _, dz in { -1.3, 1.3 } do
					part(m, "BedLeg", Vector3.new(0.2, 1.8, 0.2), bedCf * CFrame.new(dx, 0.9, dz), steel)
				end
			end
			part(m, "Headboard", Vector3.new(0.25, 2.6, 3), bedCf * CFrame.new(side * 3.4, 3.1, 0), steel)
			part(m, "Footboard", Vector3.new(0.25, 1.4, 3), bedCf * CFrame.new(-side * 3.4, 2.5, 0), steel)
			part(m, "Mattress", Vector3.new(6.4, 0.45, 2.8), bedCf * CFrame.new(0, 2.43, 0), white)
			part(m, "Pillow", Vector3.new(1.2, 0.35, 2), bedCf * CFrame.new(side * 2.6, 2.83, 0), white)
			part(m, "Blanket", Vector3.new(3, 0.12, 2.85), bedCf * CFrame.new(-side * 1.2, 2.71, 0), { Color = rgb(150, 180, 175), Material = M.Fabric })
			if side == -1 and i == 2 then
				part(m, "Sheet", Vector3.new(4.5, 0.8, 1.6), bedCf * CFrame.new(-side * 0.2, 3.05, 0), { Color = rgb(235, 235, 232), Material = M.Fabric })
			end
			if not overturned then
				-- Bedside table, IV stand, heart monitor on the wall.
				part(m, "BedsideTable", Vector3.new(1.4, 2.4, 1.4), CFrame.new(side * 12.2, 1.2, z + 2.3), { Color = rgb(200, 202, 200) })
				part(m, "Cup", Vector3.new(0.4, 0.3, 0.3), CFrame.new(side * 12.2, 2.6, z + 2.3) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(220, 225, 230) })
				part(m, "IVStand", Vector3.new(0.12, 5.5, 0.12), CFrame.new(side * 12.3, 2.75, z - 2.2), steel)
				part(m, "IVBag", Vector3.new(0.5, 0.9, 0.25), CFrame.new(side * 12.3, 5.2, z - 2), { Color = rgb(220, 230, 235), Material = M.Glass, Transparency = 0.3 })
				B.onWall(m, w, side, z, 6.3, Vector2.new(1.6, 1.1), 0.25, "HeartMonitor", { Color = rgb(30, 30, 34) })
				part(m, "HeartLine", Vector3.new(0.02, 0.04, 1.2), CFrame.new(side * (w / 2 - 0.26), 6.3, z), { Material = M.Neon, Color = rgb(80, 255, 120), CanCollide = false })
			end
		end
		-- Curtain track and curtains between beds.
		part(m, "CurtainTrack", Vector3.new(0.12, 0.1, 34), CFrame.new(side * 6, h - 0.05, -19), steel)
		for _, z in { -8.5, -15.5, -22.5, -29.5 } do
			part(m, "Curtain", Vector3.new(7, 7.5, 0.1), CFrame.new(side * 9.5, h - 3.95, z), { Color = rgb(150, 190, 175), Material = M.Fabric, Transparency = 0.1, CanCollide = false })
		end
	end
	-- Nurse station near the far wall.
	part(m, "NurseDesk", Vector3.new(6, 3.4, 2), CFrame.new(-8.5, 1.7, -36.5), { Color = rgb(190, 200, 196) })
	part(m, "NurseTop", Vector3.new(6.3, 0.15, 2.3), CFrame.new(-8.5, 3.475, -36.5), { Color = rgb(120, 130, 128), Material = M.Marble })
	part(m, "NurseMonitor", Vector3.new(1.4, 1, 0.12), CFrame.new(-9, 4.1, -36.9), { Color = rgb(30, 30, 34) })
	part(m, "Files", Vector3.new(0.9, 0.5, 1.2), CFrame.new(-6.6, 3.8, -36.5), { Color = rgb(200, 180, 120) })
	part(m, "MedCart", Vector3.new(1.4, 3, 2), CFrame.new(8.5, 1.5, -36.8), steel)
	B.panelGrid(m, w, L, h, 2, 4, p.light, 0.6)
	return m
end

-- Helioscope bay: the giant solar telescope on its fork mount, an observing chair, the Sun projected on the floor.
local function helioscope(): Model
	local m = B.newRoom("HelioscopeBay", { Weight = 1, MinRoom = 20 })
	local w, L, h, p = 32, 42, 24, PAL.lab
	B.shell(m, w, L, h, p)
	local mount = { Color = rgb(70, 72, 78), Material = M.Metal }
	local white = { Color = rgb(215, 217, 220), Material = M.Metal }
	local cx, cz = -8, -21
	-- Pedestal and fork mount.
	part(m, "Pedestal", Vector3.new(5, 3, 5), CFrame.new(cx, 1.5, cz), mount)
	part(m, "Turntable", Vector3.new(0.6, 5.6, 5.6), CFrame.new(cx, 3.3, cz) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(55, 57, 62), Material = M.Metal })
	for _, dx in { -3.6, 3.6 } do
		part(m, "ForkArm", Vector3.new(0.8, 6.5, 1.6), CFrame.new(cx + dx, 6.85, cz), mount)
	end
	part(m, "Counterweight", Vector3.new(2, 2, 2), CFrame.new(cx, 6, cz - 4.2), mount)
	-- The tube with rings, a finder scope, and the glowing solar filter.
	local tubeCf = CFrame.new(cx, 9.5, cz) * CFrame.Angles(0, math.pi / 2, 0) * CFrame.Angles(0, 0, math.rad(40))
	part(m, "Telescope", Vector3.new(20, 6, 6), tubeCf, { Shape = Enum.PartType.Cylinder, Color = white.Color, Material = white.Material })
	for _, d in { -7, -2, 3, 8 } do
		part(m, "TubeRing", Vector3.new(0.5, 6.4, 6.4), tubeCf * CFrame.new(d, 0, 0), { Shape = Enum.PartType.Cylinder, Color = rgb(60, 62, 68), Material = M.Metal })
	end
	part(m, "Finder", Vector3.new(6, 0.8, 0.8), tubeCf * CFrame.new(2, 3.6, 0), { Shape = Enum.PartType.Cylinder, Color = white.Color, Material = white.Material })
	local filter = part(m, "Filter", Vector3.new(0.1, 6.2, 6.2), tubeCf * CFrame.new(10.05, 0, 0), { Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(255, 130, 40), CanCollide = false }) :: Part
	glowing(filter, rgb(255, 140, 60), 16, 0.8)
	part(m, "Eyepiece", Vector3.new(1.4, 0.6, 0.6), tubeCf * CFrame.new(-10.6, 0, 0), { Shape = Enum.PartType.Cylinder, Color = rgb(40, 40, 44) })
	-- Observing chair at the eyepiece end.
	part(m, "ObsChairPost", Vector3.new(0.3, 3, 0.3), CFrame.new(cx, 1.5, -9), mount)
	part(m, "ObsChairSeat", Vector3.new(1.8, 0.3, 1.8), CFrame.new(cx, 3.15, -9), { Color = rgb(60, 30, 30), Material = M.Leather })
	part(m, "ObsChairBase", Vector3.new(0.15, 2, 2), CFrame.new(cx, 0.075, -9) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = mount.Color, Material = mount.Material })
	-- The Sun projected onto the floor.
	part(m, "Projection", Vector3.new(0.04, 5, 5), CFrame.new(7, 0.02, -32) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(140, 70, 25), CanCollide = false })
	part(m, "Sunspot", Vector3.new(0.05, 0.8, 0.8), CFrame.new(7.8, 0.025, -31.4) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(20, 10, 5), CanCollide = false })
	-- Consoles and the readout.
	part(m, "Console", Vector3.new(3, 3, 8), CFrame.new(w / 2 - 3, 1.5, -18), mount)
	for _, z in { -16, -20 } do
		part(m, "ConsoleScreen", Vector3.new(0.1, 1.2, 2.4), CFrame.new(w / 2 - 4.3, 3.7, z) * CFrame.Angles(0, 0, 0.3), { Material = M.Neon, Color = rgb(60, 30, 15), CanCollide = false })
	end
	local screen = B.onWall(m, w, 1, -18, 10, Vector2.new(10, 5), 0.2, "Screen", { Color = rgb(30, 12, 8), Material = M.Neon }) :: Part
	B.label(screen, "SURFACE TEMP\n5,772 K\n5,772 K\n9,9?? K", Enum.NormalId.Left, rgb(255, 150, 90), Enum.Font.Code)
	-- Radial ribs across the ceiling, like an observatory dome.
	for k = 0, 5 do
		part(m, "CeilingRib", Vector3.new(0.6, 0.6, 30), CFrame.new(0, h - 1.4, -L / 2) * CFrame.Angles(0, k * math.pi / 6, 0), mount)
	end
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

-- The bridge: helm stations under the forward screen, a holo-table showing the Sun, the captain's chair on a dais.
local function bridge(): Model
	local m = B.newRoom("Bridge", { Weight = 1, MinRoom = 35 })
	local w, L, h, p = 38, 38, 14, PAL.hull
	local windows = {}
	for _, side in { "left", "right" } do
		for _, z in { -12, -24 } do
			table.insert(windows, { side = side, z = z, y = 3, w = 10, h = 6 })
		end
	end
	B.shell(m, w, L, h, p, { windows = windows })
	local rand = Random.new(35)
	local dark = { Color = rgb(45, 47, 52), Material = M.Metal }
	local trim = { Color = rgb(150, 152, 158), Material = M.Metal }
	-- Helm and navigation stations, angled toward the centre, with pilot seats.
	for _, sx in { -1, 1 } do
		local base = CFrame.new(sx * 9, 0, -31) * CFrame.Angles(0, sx * 0.35, 0)
		part(m, "HelmConsole", Vector3.new(8, 3, 2.4), base * CFrame.new(0, 1.5, 0), dark)
		part(m, "HelmTop", Vector3.new(8.2, 0.15, 2.6), base * CFrame.new(0, 3.075, 0), { Color = rgb(25, 27, 30) })
		for _, dx in { -2.6, 0, 2.6 } do
			part(m, "HelmDisplay", Vector3.new(2.2, 1.3, 0.1), base * CFrame.new(dx, 3.9, -0.6) * CFrame.Angles(-0.35, 0, 0),
				{ Material = M.Neon, Color = if rand:NextNumber() < 0.4 then rgb(80, 25, 15) else rgb(25, 45, 70), CanCollide = false })
		end
		part(m, "Throttle", Vector3.new(0.2, 0.7, 0.2), base * CFrame.new(sx * 3.2, 3.5, 0.5) * CFrame.Angles(0.5, 0, 0), { Color = rgb(170, 40, 35) })
		chair(m, base * CFrame.new(0, 0, 2.6), rgb(50, 55, 70))
	end
	-- Holo-table projecting the Sun.
	part(m, "HoloTable", Vector3.new(3, 5, 5), CFrame.new(-8, 1.5, -16) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = dark.Color, Material = dark.Material })
	part(m, "HoloEmitter", Vector3.new(0.06, 4, 4), CFrame.new(-8, 3.03, -16) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(60, 110, 140), CanCollide = false })
	local holo = part(m, "Hologram", Vector3.new(2.4, 2.4, 2.4), CFrame.new(-8, 5.2, -16), { Shape = Enum.PartType.Ball, Material = M.Neon, Color = rgb(255, 140, 50), Transparency = 0.45, CanCollide = false, CastShadow = false }) :: Part
	glowing(holo, rgb(255, 150, 70), 10, 0.6)
	part(m, "HoloOrbit", Vector3.new(0.05, 4.4, 4.4), CFrame.new(-8, 5.2, -16) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(90, 160, 200), Transparency = 0.7, CanCollide = false, CastShadow = false })
	-- Captain's dais and chair.
	part(m, "Dais", Vector3.new(6, 0.5, 6), CFrame.new(8, 0.25, -16), { Color = rgb(60, 62, 68), Material = M.DiamondPlate })
	part(m, "DaisTrim", Vector3.new(6.2, 0.1, 6.2), CFrame.new(8, 0.55, -16), trim)
	part(m, "CaptainChairBase", Vector3.new(1.4, 1.2, 1.4), CFrame.new(8, 1.2, -16), dark)
	part(m, "CaptainChair", Vector3.new(3, 0.6, 3), CFrame.new(8, 2.1, -16), { Color = rgb(70, 35, 30), Material = M.Leather })
	part(m, "CaptainChair", Vector3.new(3, 4, 0.5), CFrame.new(8, 4.4, -14.75), { Color = rgb(70, 35, 30), Material = M.Leather })
	for _, dx in { -1.7, 1.7 } do
		part(m, "Armrest", Vector3.new(0.4, 0.3, 2.6), CFrame.new(8 + dx, 2.9, -16), dark)
		part(m, "ArmPanel", Vector3.new(0.35, 0.05, 0.8), CFrame.new(8 + dx, 3.07, -16.7), { Material = M.Neon, Color = rgb(70, 40, 25), CanCollide = false })
	end
	-- Hanging status monitors.
	for _, sx in { -1, 1 } do
		part(m, "MonitorCable", Vector3.new(0.12, h - 11, 0.12), CFrame.new(sx * 6, 11 + (h - 11) / 2, -24), dark)
		part(m, "HangingMonitor", Vector3.new(3, 1.8, 0.2), CFrame.new(sx * 6, 10.1, -24), dark)
		local face = part(m, "HangingScreen", Vector3.new(2.7, 1.5, 0.03), CFrame.new(sx * 6, 10.1, -23.88), { Material = M.Neon, Color = rgb(30, 15, 10), CanCollide = false }) :: Part
		B.label(face, if sx == -1 then "HULL 31%" else "CREW 0", Enum.NormalId.Back, rgb(255, 120, 80), Enum.Font.Code)
	end
	endSign(m, -L, 1, 0, 11.5, Vector2.new(12, 1.2), "NAVIGATION OFFLINE - COURSE: SOL", rgb(30, 12, 8), rgb(255, 140, 80))
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.5)
	return m
end

-- Capacitor bank: finned capacitors in safety cages, insulator stacks, arcing between two of them.
local function capacitors(): Model
	local m = B.newRoom("CapacitorBank", { Weight = 1, MinRoom = 14 })
	local w, L, h, p = 28, 36, 16, PAL.engine
	B.shell(m, w, L, h, p)
	local metal = { Color = rgb(110, 112, 118), Material = M.Metal }
	local dark = { Color = rgb(55, 57, 62), Material = M.Metal }
	local rail = { Color = rgb(200, 160, 40), Material = M.Metal }
	local caps = {}
	for _, sx in { -1, 1 } do
		for _, z in { -6, -14, -22, -30 } do
			local x = sx * 10.5
			table.insert(caps, Vector3.new(x, 0, z))
			local cap = part(m, "Capacitor", Vector3.new(10, 3, 3), CFrame.new(x, 5.6, z) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = metal.Color, Material = metal.Material }) :: Part
			part(m, "CapBase", Vector3.new(3.6, 0.6, 3.6), CFrame.new(x, 0.3, z), dark)
			for y = 2, 9, 1.4 do
				part(m, "CoolingFin", Vector3.new(0.12, 3.5, 3.5), CFrame.new(x, y, z) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = dark.Color, Material = dark.Material })
			end
			part(m, "Band", Vector3.new(0.3, 3.3, 3.3), CFrame.new(x, 6.3, z) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(170, 140, 40), CanCollide = false })
			for k = 0, 2 do
				part(m, "Insulator", Vector3.new(0.35, 1.4 - k * 0.3, 1.4 - k * 0.3), CFrame.new(x, 10.8 + k * 0.5, z) * CFrame.Angles(0, 0, math.pi / 2),
					{ Shape = Enum.PartType.Cylinder, Color = rgb(150, 90, 60), Material = M.SmoothPlastic })
			end
			glowing(cap, rgb(255, 210, 90), 8, 0.4)
			-- Safety cage: corner posts and two rails on the aisle side.
			for _, dz in { -2.3, 2.3 } do
				part(m, "CagePost", Vector3.new(0.2, 3.6, 0.2), CFrame.new(x - sx * 2.3, 1.8, z + dz), rail)
			end
			for _, y in { 1.6, 3.4 } do
				part(m, "CageRail", Vector3.new(0.12, 0.12, 4.6), CFrame.new(x - sx * 2.3, y, z), rail)
			end
		end
		-- Overhead cable linking the row.
		part(m, "Busbar", Vector3.new(0.3, 0.3, 24.4), CFrame.new(sx * 10.5, 12.6, -18), { Color = rgb(170, 110, 60), Material = M.Metal })
		part(m, "FloorMat", Vector3.new(3, 0.05, L - 4), CFrame.new(sx * 5.2, 0.025, -L / 2), { Color = rgb(30, 30, 32), Material = M.Rubber, CanCollide = false })
	end
	-- An arc jumping between two capacitors (flickers like a lamp).
	local a, b = caps[2] + Vector3.new(0, 11.6, 0), caps[3] + Vector3.new(0, 11.6, 0)
	local prev = a
	for k = 1, 5 do
		local t = k / 5
		local nxt = a:Lerp(b, t) + (if k < 5 then Vector3.new(math.sin(k * 2.3) * 0.5, math.cos(k * 1.7) * 0.6, 0) else Vector3.zero)
		local mid = (prev + nxt) / 2
		local arc = part(m, "Lamp", Vector3.new(0.1, 0.1, (nxt - prev).Magnitude), CFrame.lookAt(mid, nxt), { Material = M.Neon, Color = rgb(180, 210, 255), CanCollide = false, CastShadow = false }) :: Part
		if k == 3 then
			local glowArc = Instance.new("PointLight")
			glowArc.Color = rgb(170, 200, 255)
			glowArc.Range = 10
			glowArc.Brightness = 0.8
			glowArc.Parent = arc
			arc:SetAttribute("Flicker", true)
		end
		prev = nxt
	end
	-- Breaker panel by the exit.
	B.onWall(m, w, -1, -33, 4.5, Vector2.new(3, 4), 0.3, "BreakerPanel", dark)
	for k = 0, 5 do
		part(m, "Breaker", Vector3.new(0.15, 0.3, 0.5), CFrame.new(-w / 2 + 0.38, 3.2 + (k % 3) * 1.1, -33.7 + math.floor(k / 3) * 1.3), { Color = if k == 4 then rgb(200, 40, 30) else rgb(25, 25, 25) })
	end
	wallSign(m, w, -1, -18, 13, Vector2.new(6, 1.4), "DANGER - HIGH VOLTAGE", rgb(200, 160, 40), rgb(30, 20, 10))
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.5, 22)
	return m
end

-- Maintenance tunnel: tight, pipes of every size with valves and gauges, a lit grating, steam leaks, an access hatch.
local function tunnel(): Model
	local m = B.newRoom("MaintenanceTunnel", { Weight = 2, MinRoom = 4 })
	local w, L, h, p = 8, 44, 10, PAL.hull
	B.shell(m, w, L, h, p)
	local rand = Random.new(7)
	local dark = { Color = rgb(55, 58, 64), Material = M.Metal }
	local steel = { Color = rgb(140, 144, 150), Material = M.Metal }
	local function runPipe(x: number, y: number, d: number, color: Color3)
		part(m, "Pipe", Vector3.new(L, d, d), CFrame.new(x, y, -L / 2) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Color = color, Material = M.Metal })
		for z = -4, -L + 4, -8 do
			part(m, "PipeClamp", Vector3.new(0.3, d + 0.2, d + 0.2), CFrame.new(x, y, z) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Color = rgb(40, 40, 44), Material = M.Metal })
		end
	end
	runPipe(-3.45, 1.6, 1, rgb(80, 84, 90))
	runPipe(-3.6, 4.6, 0.7, rgb(110, 70, 50))
	runPipe(-3.65, 6.2, 0.6, rgb(60, 90, 120))
	runPipe(3.45, 2.2, 1, rgb(80, 84, 90))
	runPipe(3.6, 5.2, 0.7, rgb(200, 160, 40))
	-- Valve wheels and pressure gauges along the pipes.
	for _, z in { -10, -26, -38 } do
		part(m, "Valve", Vector3.new(0.15, 1.1, 1.1), CFrame.new(-2.85, 1.6, z), { Shape = Enum.PartType.Cylinder, Color = rgb(170, 40, 35), Material = M.Metal })
		part(m, "Gauge", Vector3.new(0.1, 0.8, 0.8), CFrame.new(3.05, 3.4, z + 3), { Shape = Enum.PartType.Cylinder, Color = rgb(225, 225, 220) })
		part(m, "GaugeStem", Vector3.new(0.4, 0.1, 0.1), CFrame.new(3.3, 3.4, z + 3), steel)
	end
	-- Cable trays overhead, a low cross pipe you have to duck under (visually).
	for _, sx in { -1, 1 } do
		part(m, "CableTray", Vector3.new(1, 0.12, L - 2), CFrame.new(sx * 2.4, h - 0.9, -L / 2), dark)
		part(m, "Cables", Vector3.new(0.8, 0.25, L - 2), CFrame.new(sx * 2.4, h - 0.71, -L / 2), { Color = rgb(30, 30, 32), Material = M.Rubber })
	end
	part(m, "CrossPipe", Vector3.new(w, 0.8, 0.8), CFrame.new(0, 8.2, -22), { Shape = Enum.PartType.Cylinder, Color = rgb(110, 70, 50), Material = M.Metal })
	-- Grating with a glow underneath.
	part(m, "UnderGlow", Vector3.new(2.6, 0.02, L - 2), CFrame.new(0, 0.01, -L / 2), { Material = M.Neon, Color = rgb(40, 70, 90), CanCollide = false })
	for z = -1.5, -L + 1.5, -1 do
		part(m, "GrateBar", Vector3.new(3, 0.06, 0.25), CFrame.new(0, 0.05, z), { Color = rgb(45, 46, 50), Material = M.Metal, CanCollide = false })
	end
	-- Steam leaking from a joint, an access hatch, a forgotten toolbox, a puddle.
	for k = 0, 3 do
		part(m, "Steam", Vector3.new(0.8 + k * 0.4, 0.8 + k * 0.4, 0.8 + k * 0.4), CFrame.new(3 - k * 0.3, 5.6 + k * 0.6, -30 + k * 0.2), { Shape = Enum.PartType.Ball, Color = rgb(220, 225, 230), Transparency = 0.75 + k * 0.05, CanCollide = false, CastShadow = false })
	end
	local hatch = B.onWall(m, w, -1, -32, 7.9, Vector2.new(1.8, 1.8), 0.15, "AccessHatch", { Color = rgb(80, 84, 92), Material = M.DiamondPlate }) :: Part
	B.label(hatch, "ACCESS 7-G", Enum.NormalId.Right, rgb(220, 180, 50), Enum.Font.Code)
	part(m, "Toolbox", Vector3.new(0.9, 0.8, 1.6), CFrame.new(-2.2, 0.4, -17), { Color = rgb(170, 40, 35), Material = M.Metal })
	part(m, "Wrench", Vector3.new(0.12, 0.06, 1.2), CFrame.new(-1.3, 0.08, -18.4) * CFrame.Angles(0, 0.6, 0), steel)
	part(m, "Puddle", Vector3.new(0.03, 2, 2.8), CFrame.new(0.8, 0.09, -35) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(70, 80, 85), Material = M.Glass, Transparency = 0.3, Reflectance = 0.3, CanCollide = false })
	wallSign(m, w, 1, -14, 8.1, Vector2.new(2.6, 0.7), "SECTOR 7-G")
	-- Caged bulbs.
	for k, z in { -5, -16, -27, -38 } do
		local bulb = B.bulb(m, Vector3.new(0, h - 0.9, z), rgb(255, 205, 150), 12, 0.6, 0.8)
		for c = 0, 1 do
			part(m, "Cage", Vector3.new(0.05, 1.1, 1.1), CFrame.new(0, h - 0.9, z) * CFrame.Angles(0, c * math.pi / 2, 0), { Color = rgb(40, 40, 44), Material = M.Metal, Transparency = 0.5, CanCollide = false })
		end
		if k == 3 then
			bulb:SetAttribute("Flicker", true)
		end
	end
	return m
end

-- Security office: wall of camera feeds, an operator desk, an empty weapons rack, evidence shelves, a missing-crew board.
local function security(): Model
	local m = B.newRoom("SecurityOffice", { Weight = 1, MinRoom = 10 })
	local w, L, h, p = 26, 30, 10, PAL.office
	B.shell(m, w, L, h, p)
	local dark = { Color = rgb(40, 42, 48), Material = M.Metal }
	local steel = { Color = rgb(140, 145, 150), Material = M.Metal }
	-- Monitor wall: framed bank of eight feeds.
	B.onWall(m, w, -1, -14, 6, Vector2.new(11.4, 4.4), 0.1, "MonitorWall", { Color = rgb(20, 20, 24), Material = M.Metal })
	for row = 0, 1 do
		for col = 0, 3 do
			local cam = row * 4 + col + 1
			local screen = part(m, "CamScreen", Vector3.new(0.05, 1.6, 2.4), CFrame.new(-w / 2 + 0.125, 5.1 + row * 1.9, -14 - 3.9 + col * 2.6),
				{ Material = M.Neon, Color = if cam == 7 then rgb(80, 30, 30) else rgb(30, 45, 40), CanCollide = false }) :: Part
			B.label(screen, if cam == 7 then "CAM 7: MOVEMENT" else `CAM {cam}`, Enum.NormalId.Right, rgb(200, 220, 210), Enum.Font.Code)
		end
	end
	-- Operator desk with keyboards and a joystick.
	part(m, "Desk", Vector3.new(2.5, 3, 10), CFrame.new(-w / 2 + 1.25, 1.5, -14), dark)
	part(m, "DeskTop", Vector3.new(2.7, 0.12, 10.2), CFrame.new(-w / 2 + 1.35, 3.06, -14), { Color = rgb(25, 27, 30) })
	for _, z in { -12, -16 } do
		part(m, "Keyboard", Vector3.new(0.6, 0.06, 1.6), CFrame.new(-w / 2 + 2, 3.15, z), { Color = rgb(20, 20, 22) })
	end
	part(m, "Joystick", Vector3.new(0.15, 0.6, 0.15), CFrame.new(-w / 2 + 2, 3.42, -14), { Color = rgb(170, 40, 35) })
	part(m, "Radio", Vector3.new(0.6, 0.9, 0.4), CFrame.new(-w / 2 + 1.6, 3.57, -18.4), dark)
	chair(m, CFrame.new(-w / 2 + 4.5, 0, -14) * CFrame.Angles(0, math.rad(90), 0), rgb(40, 45, 60))
	-- Lockers and an empty weapons rack on the right.
	for i = 0, 4 do
		part(m, "Locker", Vector3.new(1.5, 7, 2), CFrame.new(w / 2 - 0.75, 3.5, -5 - i * 2), { Color = rgb(60, 66, 74), Material = M.Metal })
		part(m, "LockerVent", Vector3.new(0.05, 0.6, 1.2), CFrame.new(w / 2 - 1.525, 5.8, -5 - i * 2), { Color = rgb(30, 32, 36) })
	end
	B.onWall(m, w, 1, -18, 5, Vector2.new(5, 4), 0.2, "WeaponRack", { Color = rgb(50, 52, 58), Material = M.Metal })
	for k = -2, 2 do
		part(m, "RackPeg", Vector3.new(0.6, 0.12, 0.12), CFrame.new(w / 2 - 0.5, 4, -18 + k), steel)
		part(m, "RackPeg", Vector3.new(0.6, 0.12, 0.12), CFrame.new(w / 2 - 0.5, 6, -18 + k), steel)
	end
	-- Evidence shelves in the corner.
	for _, y in { 1, 3, 5 } do
		part(m, "EvidenceShelf", Vector3.new(1.6, 0.15, 5), CFrame.new(w / 2 - 0.8, y, -26.5), steel)
		for k = -1, 1 do
			part(m, "EvidenceBox", Vector3.new(1.2, 0.9, 1.2), CFrame.new(w / 2 - 0.8, y + 0.53, -26.5 + k * 1.5), { Color = rgb(170, 140, 100), Material = M.Cardboard })
		end
	end
	-- Missing-crew board and a keycard reader at the exit.
	local MISSING = {
		"CREW 0412\nLAST SEEN\nDECK 3", "CREW 0088\nLAST SEEN\nHYDROPONICS", "CREW 1170\nLAST SEEN\nCRYO BAY",
		"CREW 0203\nLAST SEEN\nAIRLOCK 3", "CREW 0951\nLAST SEEN\n???", "CREW 0001\nLAST SEEN\nBRIDGE",
	}
	local board = B.onWall(m, w, -1, -24, 6, Vector2.new(5, 3), 0.1, "Board", { Color = rgb(160, 125, 90), Material = M.Cardboard }) :: Part
	for k = 0, 5 do
		local notice = part(m, "Notice", Vector3.new(0.03, 0.9, 1.2), CFrame.new(-w / 2 + 0.115, 5.1 + (k % 2) * 1.15, -25.6 + math.floor(k / 2) * 1.6) * CFrame.Angles(0.04 * (k % 3 - 1), 0, 0),
			{ Color = rgb(235, 232, 220), CanCollide = false }) :: Part
		B.label(notice, MISSING[k + 1], Enum.NormalId.Right, rgb(40, 35, 30), Enum.Font.Code)
	end
	local header = part(m, "BoardHeader", Vector3.new(0.05, 0.6, 4.6), CFrame.new(-w / 2 + 0.125, 7.1, -24), { Color = rgb(235, 232, 220), CanCollide = false }) :: Part
	B.label(header, "MISSING CREW", Enum.NormalId.Right, rgb(170, 30, 30), Enum.Font.GothamBold)
	part(m, "KeycardReader", Vector3.new(0.6, 1, 0.15), CFrame.new(4.2, 4, -L + 0.075), { Color = rgb(30, 30, 34) })
	part(m, "ReaderLight", Vector3.new(0.2, 0.2, 0.05), CFrame.new(4.2, 4.3, -L + 0.17), { Material = M.Neon, Color = rgb(255, 50, 40), CanCollide = false })
	wallSign(m, w, 1, -10, 8.4, Vector2.new(4, 1), "SECURITY", rgb(30, 50, 90), rgb(220, 230, 255))
	B.panelGrid(m, w, L, h, 2, 2, p.light, 0.5)
	return m
end

-- Brig: a two-tier cell block. Cells on the ground floor and on an upper tier behind a catwalk you can climb up to.
-- One ground cell's bars are torn open; an upper cell's bars are gone entirely and lie on the floor below.
local function brig(): Model
	local m = B.newRoom("Brig", { Weight = 1, MinRoom = 22 })
	local w, L, h, p = 34, 58, 22, PAL.hull
	B.shell(m, w, L, h, p)
	local bar = { Color = rgb(70, 72, 78), Material = M.Metal }
	local steel = { Color = rgb(150, 152, 158), Material = M.Metal }
	local yellow = { Color = rgb(200, 160, 40), Material = M.Metal }
	local cellsPerSide, cellLen = 8, 6.5
	local zb = function(k: number) return -2 - k * cellLen end
	local wreckTornCell, wreckGoneCell
	local wreck = Random.new(22)
	local rubble = { Color = rgb(95, 95, 98), Material = M.Concrete }

	-- A bar made of several bent segments; each step is { length, pitch, roll } relative to the last.
	local function bentBar(start: CFrame, steps: { { number } })
		local cf = start
		for _, st in steps do
			cf = cf * CFrame.Angles(st[2], 0, st[3])
			part(m, "BentBar", Vector3.new(0.2, st[1], 0.2), cf * CFrame.new(0, st[1] / 2, 0), bar)
			cf = cf * CFrame.new(0, st[1], 0)
		end
	end
	local function rubbleAround(center: Vector3, spread: Vector3, count: number)
		for _ = 1, count do
			local sz = wreck:NextNumber(0.3, 1.1)
			local pos = center + Vector3.new(wreck:NextNumber(-spread.X, spread.X), 0, wreck:NextNumber(-spread.Z, spread.Z))
			part(m, "Rubble", Vector3.new(sz, sz * wreck:NextNumber(0.5, 0.9), sz * wreck:NextNumber(0.7, 1.3)),
				CFrame.new(pos.X, center.Y + sz * 0.3, pos.Z) * CFrame.Angles(wreck:NextNumber(-0.5, 0.5), wreck:NextNumber(0, 3), wreck:NextNumber(-0.5, 0.5)), rubble)
		end
	end
	local function gouges(center: Vector3, count: number, yaw: number)
		for k = 1, count do
			part(m, "Gouge", Vector3.new(0.12, 0.03, wreck:NextNumber(1.5, 3)), CFrame.new(center + Vector3.new(0, 0.015, (k - count / 2) * 0.35)) * CFrame.Angles(0, yaw + wreck:NextNumber(-0.1, 0.1), 0),
				{ Color = rgb(20, 20, 22), CanCollide = false })
		end
	end

	-- Ground cell whose bars were torn outward: stubs, one bar bowed out, one ripped away, the crossbar snapped.
	wreckTornCell = function(x: number, base: number, mid: number, side: number)
		local out = side -- roll toward the aisle
		local b3, b4, b5 = mid - 2.8 + 3 * 0.8, mid - 2.8 + 4 * 0.8, mid - 2.8 + 5 * 0.8
		bentBar(CFrame.new(x, base, b3), { { 1.4, 0, 0 }, { 0.9, 0, out * 0.9 }, { 0.5, 0.3, out * 0.4 } })
		bentBar(CFrame.new(x, base + 9.3, b3) * CFrame.Angles(math.pi, 0, 0), { { 1.8, 0, -out * 0.3 }, { 1, 0.4, -out * 0.6 } })
		bentBar(CFrame.new(x, base, b4), { { 3.4, 0, out * 0.35 }, { 2.9, 0, -out * 0.35 }, { 3.4, 0, -out * 0.35 } })
		bentBar(CFrame.new(x, base, b5), { { 0.6, 0, out * 1.1 }, { 0.5, 0.5, out * 0.5 } })
		bentBar(CFrame.new(x, base + 9.3, b5) * CFrame.Angles(math.pi, 0, 0), { { 1.5, 0, out * 0.2 }, { 0.8, -0.5, out * 0.7 } })
		-- The ripped-away length of bar, bent double on the floor.
		bentBar(CFrame.new(x - out * 2.6, base + 0.11, mid - 0.5) * CFrame.Angles(0, 0.4, 0) * CFrame.Angles(math.pi / 2, 0, 0), { { 3, 0, 0 }, { 2.4, 0, out * 1.1 } })
		-- Snapped crossbar: one half hanging off its weld, the other on the floor.
		part(m, "CrossBar", Vector3.new(0.3, 0.3, 2.8), CFrame.new(x, base + 2.3, mid - 1.8) * CFrame.Angles(0.55, 0, 0), bar)
		part(m, "CrossBar", Vector3.new(0.3, 0.3, 2.9), CFrame.new(x - out * 1.6, base + 0.15, mid + 1.4) * CFrame.Angles(0, 0.7, 0), bar)
		rubbleAround(Vector3.new(x - out * 1.8, base, mid), Vector3.new(1.4, 0, 2.6), 7)
		gouges(Vector3.new(x - out * 2, base, mid), 4, out * 0.5)
	end

	-- Upper cell whose bars were ripped out entirely and thrown over the catwalk.
	wreckGoneCell = function(x: number, base: number, mid: number, side: number)
		local out = side
		for b = 0, 7 do
			local bz = mid - 2.8 + b * 0.8
			bentBar(CFrame.new(x, base + 9.3, bz) * CFrame.Angles(math.pi, 0, 0), { { wreck:NextNumber(0.4, 1.6), 0, wreck:NextNumber(-0.3, 0.3) }, { wreck:NextNumber(0.3, 0.9), wreck:NextNumber(-0.4, 0.4), -out * wreck:NextNumber(0.3, 0.9) } })
			bentBar(CFrame.new(x, base, bz), { { wreck:NextNumber(0.25, 0.9), 0, out * wreck:NextNumber(0.2, 0.8) } })
		end
		-- Top crossbar torn loose at one end and hanging.
		part(m, "CrossBar", Vector3.new(0.3, 0.3, 6), CFrame.new(x, base + 9.3, mid + 3) * CFrame.Angles(-0.65, 0, 0) * CFrame.new(0, 0, -3), bar)
		-- Broken lip of the tier slab and the bent railing where it all went over.
		rubbleAround(Vector3.new(x - out * 1.6, base, mid), Vector3.new(0.9, 0, 2.2), 5)
		gouges(Vector3.new(x - out * 1.4, base, mid), 4, 0.2)
		part(m, "BentRailing", Vector3.new(0.12, 0.12, 2.6), CFrame.new(side * 8.15, base + 0.9, -35.6) * CFrame.Angles(0.8, 0, 0), { Color = rgb(200, 160, 40), Material = M.Metal })
		part(m, "BentRailing", Vector3.new(0.12, 0.12, 2.2), CFrame.new(side * 8.3, base + 0.5, -40) * CFrame.Angles(-0.9, 0.3, 0), { Color = rgb(200, 160, 40), Material = M.Metal })
		-- The bars themselves, tangled in a heap on the floor below.
		for k = 0, 6 do
			-- Lying flat (bends are sideways only), stacked so they pile instead of sinking into the floor.
			local start = CFrame.new(x - out * wreck:NextNumber(3.5, 6.5), 0.11 + k * 0.2, mid + wreck:NextNumber(-2.5, 2.5)) * CFrame.Angles(0, wreck:NextNumber(0, math.pi * 2), 0) * CFrame.Angles(math.pi / 2, 0, 0)
			bentBar(start, { { wreck:NextNumber(2, 3.5), 0, wreck:NextNumber(-0.8, 0.8) }, { wreck:NextNumber(1.5, 3), 0, wreck:NextNumber(-1, 1) }, { wreck:NextNumber(0.8, 2), 0, wreck:NextNumber(-0.6, 0.6) } })
		end
		bentBar(CFrame.new(x - out * 4.5, 1.6, mid + 1) * CFrame.Angles(0, 0.9, 0) * CFrame.Angles(math.pi / 2, 0, 0), { { 3.2, 0, 0.5 }, { 2.8, 0, -0.7 } })
		rubbleAround(Vector3.new(x - out * 5, 0, mid), Vector3.new(1.8, 0, 3), 9)
		gouges(Vector3.new(x - out * 5, 0, mid), 5, 0.8)
	end
	local cellNo = 0
	for _, side in { -1, 1 } do
		-- Upper-tier floor + catwalk, its supports and railing.
		part(m, "TierSlab", Vector3.new(9, 0.5, cellsPerSide * cellLen), CFrame.new(side * 12.5, 9.75, -2 - cellsPerSide * cellLen / 2), { Color = rgb(70, 72, 78), Material = M.DiamondPlate })
		for k = 0, cellsPerSide do
			local z = zb(k)
			part(m, "CellWall", Vector3.new(6, 9.5, 0.4), CFrame.new(side * 14, 4.75, z), { Color = p.wall, Material = p.wallMat })
			part(m, "CellWall", Vector3.new(6, 9.5, 0.4), CFrame.new(side * 14, 14.75, z), { Color = p.wall, Material = p.wallMat })
			part(m, "Support", Vector3.new(0.6, 9.5, 0.6), CFrame.new(side * 8.4, 4.75, z), steel)
			part(m, "RailPost", Vector3.new(0.15, 1.2, 0.15), CFrame.new(side * 8.15, 10.6, z), yellow)
		end
		-- Railing runs, with a gap on the left where the ladder comes up.
		local runs = if side == -1 then { { -2, -35 }, { -40.5, -48.5 }, { -51.5, -54 } } else { { -2, -54 } }
		for _, r in runs do
			for _, y in { 10.6, 11.15 } do
				part(m, "Railing", Vector3.new(0.12, 0.12, r[1] - r[2]), CFrame.new(side * 8.15, y, (r[1] + r[2]) / 2), yellow)
			end
		end
		for level, base in { 0, 10 } do
			for c = 0, cellsPerSide - 1 do
				cellNo += 1
				local mid = zb(c) - cellLen / 2
				local torn = level == 1 and side == 1 and c == 3
				local gone = level == 2 and side == -1 and c == 5
				for b = 0, 7 do
					local bz = mid - 2.8 + b * 0.8
					if not gone and not (torn and b >= 3 and b <= 5) then
						part(m, "Bar", Vector3.new(0.2, 9.3, 0.2), CFrame.new(side * 11.1, base + 4.65, bz), bar)
					end
				end
				if torn then
					wreckTornCell(side * 11.1, base, mid, side)
				elseif gone then
					wreckGoneCell(side * 11.1, base, mid, side)
				end
				if not gone then
					for _, y in { 3, 9.15 } do
						if not (torn and y == 3) then
							part(m, "CrossBar", Vector3.new(0.3, 0.3, 6), CFrame.new(side * 11.1, base + y, mid), bar)
						end
					end
				end
				if not gone then
					local num = part(m, "CellNumber", Vector3.new(0.1, 0.6, 1.2), CFrame.new(side * 10.85, base + 8.3, mid), { Color = rgb(30, 32, 36) }) :: Part
					B.label(num, tostring(cellNo), if side == -1 then Enum.NormalId.Right else Enum.NormalId.Left, rgb(230, 230, 230), Enum.Font.Code)
				end
				-- Bunk, chains, blanket, toilet.
				part(m, "Bunk", Vector3.new(1.6, 0.25, 4.4), CFrame.new(side * 16.1, base + 2.2, mid + 0.6), steel)
				for _, dz in { -1.6, 2.8 } do
					part(m, "BunkChain", Vector3.new(0.08, 3, 0.08), CFrame.new(side * 15.5, base + 3.8, mid + dz), steel)
				end
				part(m, "Blanket", Vector3.new(1.4, 0.1, 2.4), CFrame.new(side * 16.1, base + 2.375, mid + 1.2), { Color = rgb(90, 95, 85), Material = M.Fabric })
				part(m, "Toilet", Vector3.new(1.2, 1.4, 1.4), CFrame.new(side * 16.2, base + 0.7, mid - 2.3), { Color = rgb(170, 172, 175), Material = M.Metal })
				if level == 2 and side == 1 and c == 2 then
					part(m, "Figure", Vector3.new(1, 2.4, 1.2), CFrame.new(side * 15.9, base + 3.6, mid + 1), { Color = rgb(30, 30, 34), CanCollide = false })
					part(m, "FigureHead", Vector3.new(0.9, 0.9, 0.9), CFrame.new(side * 15.9, base + 5.2, mid + 1), { Shape = Enum.PartType.Ball, Color = rgb(30, 30, 34), CanCollide = false })
				end
			end
		end
		-- Lights under the catwalk.
		for c = 0, cellsPerSide - 1, 2 do
			B.bulb(m, Vector3.new(side * 9.5, 9, zb(c) - cellLen / 2), rgb(255, 210, 160), 12, 0.5, 0.8)
		end
	end
	-- Climbable ladder (truss) up to the left catwalk.
	local truss = Instance.new("TrussPart")
	truss.Name = "Ladder"
	truss.Size = Vector3.new(2, 10, 2)
	truss.CFrame = CFrame.new(-7, 5, -50)
	truss.Anchored = true
	truss.Color = rgb(200, 160, 40)
	truss.Material = M.Metal
	truss.Parent = m
	-- Guard station by the exit: desk, monitors, a spotlight aimed at the cells, the key board.
	part(m, "GuardDesk", Vector3.new(6, 3, 2.4), CFrame.new(-6, 1.5, -56.3), { Color = rgb(55, 58, 64), Material = M.Metal })
	for k = -1, 1 do
		part(m, "GuardMonitor", Vector3.new(1.6, 1.1, 0.12), CFrame.new(-6 + k * 1.8, 3.6, -56.8), { Color = rgb(30, 30, 34) })
		part(m, "GuardScreen", Vector3.new(1.4, 0.9, 0.03), CFrame.new(-6 + k * 1.8, 3.6, -56.72), { Material = M.Neon, Color = rgb(30, 45, 40), CanCollide = false })
	end
	part(m, "SpotStand", Vector3.new(0.2, 4, 0.2), CFrame.new(6, 2, -55), steel)
	local spot = part(m, "Lamp", Vector3.new(1.2, 1, 1.4), CFrame.new(6, 4.4, -55) * CFrame.Angles(0.3, 0.5, 0), { Material = M.Neon, Color = rgb(220, 220, 200), CanCollide = false }) :: Part
	local beam = Instance.new("SpotLight")
	beam.Face = Enum.NormalId.Front
	beam.Angle = 40
	beam.Range = 40
	beam.Brightness = 1.2
	beam.Parent = spot
	endSign(m, -L, 1, -10, 5.5, Vector2.new(2.4, 1.6), "", rgb(80, 60, 40))
	for k = 0, 4 do
		part(m, "KeyHook", Vector3.new(0.1, 0.1, 0.25), CFrame.new(-11 + k * 0.5, 5.8, -L + 0.27), steel)
		if k ~= 2 then
			part(m, "Key", Vector3.new(0.12, 0.4, 0.05), CFrame.new(-11 + k * 0.5, 5.5, -L + 0.33), { Color = rgb(190, 160, 80), Material = M.Metal, CanCollide = false })
		end
	end
	endSign(m, -L, 1, 0, 16, Vector2.new(9, 1.6), "HOLDING - BLOCK C")
	for _, z in { -8, -20, -32, -44 } do
		B.panel(m, 0, h, z, p.light, 0.8, 30, Vector3.new(4, 0.3, 2))
	end
	return m
end

-- Waste reclamation: a hydraulic compactor with cubes of crushed trash, a sorting conveyor, labelled bins.
local function recycling(): Model
	local m = B.newRoom("Recycling", { Weight = 1, MinRoom = 12 })
	local w, L, h, p = 30, 34, 14, PAL.engine
	B.shell(m, w, L, h, p)
	local rand = Random.new(12)
	local dark = { Color = rgb(60, 62, 66), Material = M.Metal }
	local steel = { Color = rgb(140, 142, 146), Material = M.Metal }
	-- Compactor with hydraulic rams and a feed chute.
	part(m, "Compactor", Vector3.new(8, 7, 8), CFrame.new(-9, 3.5, -15), { Color = rgb(90, 92, 96), Material = M.DiamondPlate })
	part(m, "CompactorDoor", Vector3.new(0.1, 4, 6), CFrame.new(-4.95, 2.4, -15), dark)
	part(m, "WarningStrip", Vector3.new(0.1, 0.6, 8), CFrame.new(-4.95, 5.6, -15), { Color = rgb(200, 160, 40), CanCollide = false })
	for _, dz in { -2.2, 2.2 } do
		part(m, "Ram", Vector3.new(3, 1, 1), CFrame.new(-9, 8.5, -15 + dz) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = steel.Color, Material = steel.Material })
	end
	part(m, "Chute", Vector3.new(3, h - 10.5, 3), CFrame.new(-9, 10.5 + (h - 10.5) / 2, -18), dark)
	-- Crushed trash cubes stacked nearby.
	for k = 0, 3 do
		part(m, "TrashCube", Vector3.new(2, 2, 2), CFrame.new(-11 + (k % 2) * 2.1, 1 + math.floor(k / 2) * 2, -24.5) * CFrame.Angles(0, rand:NextNumber(-0.15, 0.15), 0),
			{ Color = rgb(rand:NextInteger(70, 110), rand:NextInteger(60, 90), rand:NextInteger(50, 80)), Material = M.CorrodedMetal })
	end
	-- Sorting conveyor with rollers and junk on the belt.
	part(m, "ConveyorFrame", Vector3.new(3, 2.4, 14), CFrame.new(7, 1.2, -17), dark)
	part(m, "Belt", Vector3.new(2.6, 0.1, 14), CFrame.new(7, 2.45, -17), { Color = rgb(25, 25, 27), Material = M.Rubber })
	for z = -10.5, -23.5, -1.3 do
		part(m, "Roller", Vector3.new(3.1, 0.3, 0.3), CFrame.new(7, 2.3, z), steel)
	end
	for _ = 1, 6 do
		part(m, "Junk", Vector3.new(rand:NextNumber(0.4, 1), rand:NextNumber(0.3, 0.7), rand:NextNumber(0.4, 1)), CFrame.new(7 + rand:NextNumber(-0.8, 0.8), 2.75, -17 + rand:NextNumber(-6, 6)) * CFrame.Angles(0, rand:NextNumber(0, 3), 0),
			{ Color = rgb(rand:NextInteger(60, 160), rand:NextInteger(60, 140), rand:NextInteger(60, 120)), CanCollide = false })
	end
	-- Labelled bins along the right wall.
	local bins = { { "METAL", rgb(70, 80, 95) }, { "ORGANIC", rgb(60, 100, 60) }, { "PLASTIC", rgb(120, 100, 40) }, { "???", rgb(90, 50, 110) } }
	for i, b in bins do
		local z = -6 - (i - 1) * 3
		part(m, "Bin", Vector3.new(2, 2.6, 2.4), CFrame.new(w / 2 - 1, 1.3, z), { Color = b[2], Material = M.Plastic })
		local label = part(m, "BinLabel", Vector3.new(0.05, 0.6, 1.8), CFrame.new(w / 2 - 2.025, 2, z), { Color = rgb(230, 230, 225) }) :: Part
		B.label(label, b[1], Enum.NormalId.Left, rgb(30, 30, 30), Enum.Font.Code)
	end
	for _, c in { { -12, -29 }, { -9.5, -30.5 }, { 10, -29 }, { 11.5, -30 } } do
		part(m, "Bag", Vector3.new(1.6, 1.4, 1.6), CFrame.new(c[1], 0.7, c[2]) * CFrame.Angles(0, rand:NextNumber(0, 3), 0), { Color = rgb(30, 32, 34), Material = M.Plastic })
	end
	local panel = B.onWall(m, w, -1, -28, 4.5, Vector2.new(2.6, 1.8), 0.2, "ControlPanel", { Color = rgb(30, 12, 8), Material = M.Neon }) :: Part
	B.label(panel, "CYCLE: JAMMED", Enum.NormalId.Right, rgb(255, 120, 80), Enum.Font.Code)
	B.bulb(m, Vector3.new(-4.4, 8.6, -15), rgb(255, 160, 40), 10, 0.5, 0.8)
	wallSign(m, w, -1, -28, 8, Vector2.new(7, 1.2), "WASTE RECLAMATION")
	for _, pos in { { 7, -6 }, { 7, -16 }, { 7, -26 }, { -8, -6 }, { -8, -27 } } do
		B.panel(m, pos[1], h, pos[2], p.light, 0.5)
	end
	return m
end

-- Crew lounge "The Last Light": a full bar with back shelving, booths with lamps, a pool table, a jukebox, a dartboard.
local function lounge(): Model
	local m = B.newRoom("Lounge", { Weight = 1, MinRoom = 9 })
	local w, L, h, p = 30, 34, 10, PAL.quarters
	B.shell(m, w, L, h, p)
	local rand = Random.new(9)
	local wood = { Color = rgb(60, 40, 30), Material = M.Wood }
	local brass = { Color = rgb(175, 145, 85), Material = M.Metal }
	local leather = { Color = rgb(110, 40, 40), Material = M.Leather }
	-- Bar counter with paneling, brass foot rail, stools.
	part(m, "Bar", Vector3.new(2.5, 3.6, 14), CFrame.new(-10, 1.8, -16), wood)
	part(m, "BarTop", Vector3.new(2.9, 0.15, 14.4), CFrame.new(-10, 3.675, -16), { Color = rgb(40, 26, 20), Material = M.Wood })
	for z = -10, -22, -2 do
		part(m, "BarPanel", Vector3.new(0.06, 2.6, 1.6), CFrame.new(-8.72, 1.8, z), { Color = rgb(75, 50, 36), Material = M.Wood })
	end
	part(m, "FootRail", Vector3.new(14, 0.15, 0.15), CFrame.new(-8.3, 0.6, -16) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Color = brass.Color, Material = brass.Material })
	for z = -10, -22, -3 do
		part(m, "StoolPost", Vector3.new(0.2, 2.4, 0.2), CFrame.new(-7.4, 1.2, z), brass)
		part(m, "StoolBase", Vector3.new(0.1, 1.2, 1.2), CFrame.new(-7.4, 0.05, z) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = brass.Color, Material = brass.Material })
		part(m, "StoolSeat", Vector3.new(0.35, 1.4, 1.4), CFrame.new(-7.4, 2.55, z) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = leather.Color, Material = leather.Material })
	end
	-- Taps and glasses on the bar.
	for k = 0, 2 do
		part(m, "Tap", Vector3.new(0.15, 1, 0.15), CFrame.new(-10.6, 4.25, -14 - k * 0.8), brass)
	end
	for _ = 1, 5 do
		part(m, "Glass", Vector3.new(0.5, 0.3, 0.3), CFrame.new(-9.6 + rand:NextNumber(-0.4, 0.4), 4, -16 + rand:NextNumber(-5, 5)) * CFrame.Angles(0, 0, math.pi / 2),
			{ Shape = Enum.PartType.Cylinder, Color = rgb(200, 210, 220), Material = M.Glass, Transparency = 0.4 })
	end
	-- Back bar: tiered shelves of bottles with a glowing strip under each.
	for tier, y in { 4.5, 5.8, 7.1 } do
		B.onWall(m, w, -1, -16, y, Vector2.new(12, 0.15), 1 - tier * 0.15, "BackShelf", wood)
		part(m, "ShelfGlow", Vector3.new(0.6, 0.05, 11.6), CFrame.new(-w / 2 + 0.4, y - 0.1, -16), { Material = M.Neon, Color = rgb(120, 60, 30), CanCollide = false })
		for k = 0, 10 do
			local bh = rand:NextNumber(0.8, 1.2)
			part(m, "Bottle", Vector3.new(bh, 0.35, 0.35), CFrame.new(-w / 2 + 0.35, y + 0.075 + bh / 2, -21.5 + k * 1.1) * CFrame.Angles(0, 0, math.pi / 2),
				{ Shape = Enum.PartType.Cylinder, Color = rgb(rand:NextInteger(40, 140), rand:NextInteger(50, 120), rand:NextInteger(30, 70)), Material = M.Glass, Transparency = 0.2 })
		end
	end
	local sign = wallSign(m, w, -1, -16, 8.6, Vector2.new(6, 1.1), "THE LAST LIGHT", rgb(25, 15, 15), rgb(255, 140, 90), Enum.Font.Garamond)
	glowing(sign, rgb(255, 140, 90), 8, 0.4)
	-- Booths along the right wall, each with a little table lamp.
	for _, z in { -7, -15 } do
		part(m, "BoothTable", Vector3.new(2.5, 0.3, 3), CFrame.new(12.5, 2.85, z), wood)
		part(m, "TableLeg", Vector3.new(0.5, 2.7, 0.5), CFrame.new(12.5, 1.35, z), { Color = rgb(40, 30, 25) })
		for _, dz in { -2.6, 2.6 } do
			part(m, "BoothSeat", Vector3.new(3, 1.6, 1.6), CFrame.new(12.5, 0.8, z + dz), leather)
			part(m, "BoothBack", Vector3.new(3, 2.4, 0.5), CFrame.new(12.5, 2.8, z + dz + math.sign(dz) * 0.55), leather)
		end
		part(m, "TableLamp", Vector3.new(0.5, 0.5, 0.5), CFrame.new(13.2, 3.25, z), { Shape = Enum.PartType.Ball, Material = M.Neon, Color = rgb(200, 140, 80), CanCollide = false })
	end
	-- Pool table with balls and a cue left on the felt.
	part(m, "PoolTable", Vector3.new(4.4, 2.6, 8.4), CFrame.new(8.5, 1.3, -26), wood)
	part(m, "Felt", Vector3.new(3.8, 0.06, 7.8), CFrame.new(8.5, 2.63, -26), { Color = rgb(30, 90, 50), Material = M.Fabric })
	local ballColors = { rgb(230, 230, 220), rgb(220, 180, 40), rgb(40, 60, 160), rgb(170, 40, 40), rgb(90, 40, 120), rgb(220, 120, 40), rgb(30, 110, 60), rgb(20, 20, 20) }
	for _, c in ballColors do
		part(m, "PoolBall", Vector3.new(0.4, 0.4, 0.4), CFrame.new(8.5 + rand:NextNumber(-1.5, 1.5), 2.86, -26 + rand:NextNumber(-3.5, 3.5)), { Shape = Enum.PartType.Ball, Color = c })
	end
	part(m, "Cue", Vector3.new(0.08, 0.08, 6), CFrame.new(8.2, 2.75, -25.5) * CFrame.Angles(0, 0.3, 0), { Color = rgb(150, 110, 70), Material = M.Wood, CanCollide = false })
	-- Jukebox and dartboard.
	part(m, "Jukebox", Vector3.new(2.2, 4.4, 1.4), CFrame.new(w / 2 - 1.1, 2.2, -31.5), { Color = rgb(70, 40, 35), Material = M.Wood })
	part(m, "JukeboxTop", Vector3.new(1.4, 2.2, 2.2), CFrame.new(w / 2 - 1.1, 4.4, -31.5) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Color = rgb(70, 40, 35), Material = M.Wood })
	part(m, "JukeboxGlow", Vector3.new(1.6, 2.4, 0.05), CFrame.new(w / 2 - 1.1, 2.6, -30.775), { Material = M.Neon, Color = rgb(120, 50, 70), CanCollide = false })
	part(m, "Dartboard", Vector3.new(0.15, 1.6, 1.6), CFrame.new(w / 2 - 0.075, 5.5, -22), { Shape = Enum.PartType.Cylinder, Color = rgb(30, 30, 30) })
	part(m, "Bullseye", Vector3.new(0.05, 0.3, 0.3), CFrame.new(w / 2 - 0.17, 5.5, -22), { Shape = Enum.PartType.Cylinder, Color = rgb(170, 30, 30) })
	for _, z in { -6, -16, -26 } do
		B.bulb(m, Vector3.new(0, h - 0.6, z), p.light, 16, 0.6, 1)
	end
	return m
end

-- Escape pod bay: a row of pod hatches down each wall, every one launched except one, standing open.
local function escapePods(): Model
	local m = B.newRoom("EscapePodBay", { Weight = 1, MinRoom = 16 })
	local w, L, h, p = 30, 44, 14, PAL.hull
	B.shell(m, w, L, h, p)
	local dark = { Color = rgb(55, 58, 64), Material = M.Metal }
	local steel = { Color = rgb(150, 154, 160), Material = M.Metal }
	local n = 0
	for _, side in { -1, 1 } do
		local face = side * (w / 2)
		for _, z in { -6, -14, -22, -30, -38 } do
			n += 1
			local open = n == 7
			local inward = if side == -1 then Enum.NormalId.Right else Enum.NormalId.Left
			part(m, "HatchRing", Vector3.new(0.5, 6, 6), CFrame.new(face - side * 0.25, 4, z), { Shape = Enum.PartType.Cylinder, Color = rgb(200, 160, 40), Material = M.Metal })
			if open then
				-- Open hatch: a dark tube going back into the hull, a seat, a dim light inside.
				local hole = part(m, "PodInterior", Vector3.new(0.05, 4.8, 4.8), CFrame.new(face - side * 0.52, 4, z), { Shape = Enum.PartType.Cylinder, Color = rgb(10, 10, 12) }) :: Part
				part(m, "PodSeat", Vector3.new(0.6, 1.6, 1.4), CFrame.new(face - side * 0.85, 3.4, z), { Color = rgb(150, 60, 40), Material = M.Fabric })
				part(m, "HatchDoor", Vector3.new(0.4, 5, 5), CFrame.new(face - side * 2.7, 4, z + 2.6) * CFrame.Angles(0, side * 1.2, 0), { Shape = Enum.PartType.Cylinder, Color = rgb(120, 124, 130), Material = M.DiamondPlate })
				local inner = Instance.new("PointLight")
				inner.Color = rgb(120, 220, 140)
				inner.Range = 6
				inner.Brightness = 0.5
				inner.Parent = hole
			else
				part(m, "HatchDoor", Vector3.new(0.3, 5, 5), CFrame.new(face - side * 0.65, 4, z), { Shape = Enum.PartType.Cylinder, Color = rgb(120, 124, 130), Material = M.DiamondPlate })
				part(m, "HatchWindow", Vector3.new(0.05, 1.4, 1.4), CFrame.new(face - side * 0.82, 4.6, z), { Shape = Enum.PartType.Cylinder, Color = rgb(10, 10, 14), Material = M.Glass })
			end
			local status = part(m, "PodStatus", Vector3.new(0.1, 0.8, 3), CFrame.new(face - side * 0.05, 7.8, z), { Material = M.Neon, Color = if open then rgb(20, 60, 30) else rgb(70, 15, 12), CanCollide = false }) :: Part
			B.label(status, if open then `POD {string.format("%02d", n)} READY` else `POD {string.format("%02d", n)} LAUNCHED`, inward, if open then rgb(120, 255, 150) else rgb(255, 80, 60), Enum.Font.Code)
			-- Painted floor arrow leading to each hatch.
			part(m, "FloorArrow", Vector3.new(2.4, 0.04, 0.5), CFrame.new(face - side * 3.5, 0.02, z), { Color = rgb(200, 160, 40), CanCollide = false })
		end
	end
	-- Launch control console in the middle of the far end.
	part(m, "LaunchConsole", Vector3.new(5, 3, 2), CFrame.new(-6.5, 1.5, -41.5), dark)
	local screen = part(m, "LaunchScreen", Vector3.new(4, 1.6, 0.05), CFrame.new(-6.5, 3.9, -40.6) * CFrame.Angles(-0.3, 0, 0), { Material = M.Neon, Color = rgb(30, 10, 8), CanCollide = false }) :: Part
	B.label(screen, "PODS REMAINING: 1\nABANDON SHIP", Enum.NormalId.Back, rgb(255, 100, 80), Enum.Font.Code)
	part(m, "LaunchLever", Vector3.new(0.2, 1, 0.2), CFrame.new(-4.6, 3.5, -41.6) * CFrame.Angles(-0.6, 0, 0), { Color = rgb(170, 40, 35) })
	-- Emergency lockers hanging open, O2 packs dropped on the floor.
	for k = 0, 2 do
		part(m, "EmergencyLocker", Vector3.new(2, 5, 1.2), CFrame.new(6 + k * 2.2, 2.5, -L + 0.6), { Color = rgb(170, 40, 35), Material = M.Metal })
		part(m, "LockerDoor", Vector3.new(1.9, 4.8, 0.1), CFrame.new(5 + k * 2.2, 2.5, -L + 1.25) * CFrame.Angles(0, -1.3, 0) * CFrame.new(0.95, 0, 0), { Color = rgb(150, 35, 30), Material = M.Metal })
	end
	for _, c in { { 2.5, -33 }, { -1.5, -26 }, { 4, -18 } } do
		part(m, "O2Pack", Vector3.new(1.2, 0.6, 1.6), CFrame.new(c[1], 0.3, c[2]) * CFrame.Angles(0, c[1], 0), { Color = rgb(200, 170, 40), Material = M.Plastic })
	end
	wallSign(m, w, -1, -2, 9.5, Vector2.new(3, 1.2), "ABANDON SHIP PROCEDURE", rgb(160, 30, 30), rgb(255, 230, 220))
	for _, sx in { -1, 1 } do
		for _, z in { -10, -26, -34 } do
			B.bulb(m, Vector3.new(sx * 4, h - 0.6, z), rgb(255, 50, 40), 14, 0.5, 1)
		end
	end
	B.panelGrid(m, w, L, h, 1, 3, p.light, 0.4)
	return m
end

-- Solar exhibit hall: a giant orrery hangs over the floor, display cases of the mission's artifacts, a company timeline.
-- Earth's arm on the orrery is snapped off. Earth is on the floor.
local function gallery(): Model
	local m = B.newRoom("SolarGallery", { Weight = 1, MinRoom = 28 })
	local w, L, h, p = 30, 42, 16, PAL.promenade
	B.shell(m, w, L, h, p)
	local rand = Random.new(28)
	local brass = { Color = rgb(175, 145, 85), Material = M.Metal }
	local dark = { Color = rgb(40, 38, 36), Material = M.Metal }
	local cz = -21
	-- Inlaid sun motif on the floor under the orrery.
	part(m, "FloorSun", Vector3.new(0.04, 6, 6), CFrame.new(0, 0.02, cz) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(150, 110, 50), Material = M.Marble, CanCollide = false })
	for k = 0, 11 do
		part(m, "FloorRay", Vector3.new(0.3, 0.035, 3), CFrame.new(0, 0.0175, cz) * CFrame.Angles(0, k * math.pi / 6, 0) * CFrame.new(0, 0, 4.6), { Color = rgb(150, 110, 50), Material = M.Marble, CanCollide = false })
	end
	-- Orrery: the Sun on a hub rod, planets on radial arms.
	local y = 12
	part(m, "HubRod", Vector3.new(0.4, h - y, 0.4), CFrame.new(0, y + (h - y) / 2, cz), brass)
	local sun = part(m, "OrrerySun", Vector3.new(3, 3, 3), CFrame.new(0, y, cz), { Shape = Enum.PartType.Ball, Material = M.Neon, Color = rgb(255, 140, 50), CanCollide = false }) :: Part
	glowing(sun, rgb(255, 150, 70), 24, 1)
	local planets = {
		{ 3, 0.5, rgb(150, 140, 130) }, { 4.6, 0.8, rgb(220, 190, 130) }, { 6.3, 0.85, nil },
		{ 8, 0.6, rgb(190, 90, 60) }, { 10, 1.6, rgb(200, 170, 130) }, { 11.6, 1.3, rgb(220, 200, 150) },
	}
	for i, pl in planets do
		local angle = i * 1.1 + rand:NextNumber(-0.2, 0.2)
		local dir = CFrame.new(0, y, cz) * CFrame.Angles(0, angle, 0)
		if pl[3] == nil then
			-- Earth's arm, snapped short.
			part(m, "OrreryArm", Vector3.new(0.12, 0.12, 2.6), dir * CFrame.new(0, 0, -2.8), brass)
		else
			part(m, "OrreryArm", Vector3.new(0.12, 0.12, pl[1] - 1.5), dir * CFrame.new(0, 0, -(pl[1] + 1.5) / 2), brass)
			part(m, "Planet", Vector3.new(pl[2], pl[2], pl[2]), dir * CFrame.new(0, 0, -pl[1]), { Shape = Enum.PartType.Ball, Color = pl[3], CanCollide = false })
		end
	end
	part(m, "FallenEarth", Vector3.new(0.85, 0.85, 0.85), CFrame.new(3.2, 0.425, cz + 4.5), { Shape = Enum.PartType.Ball, Color = rgb(50, 90, 150) })
	-- Display cases along both sides.
	local exhibits = {
		{ "FIRST PROBE - SOL I", "probe" }, { "CORONAL SAMPLE A1", "sample" },
		{ "FOUNDER  E. SOLSTICE", "bust" }, { "FIRST LIGHT  2093", "photo" },
		{ "HELIOS CORE FRAGMENT", "rock" }, { "SOL I - FINAL TRANSMISSION", "tape" },
		{ "S.S. TOTALITY  1:400", "ship" }, { "UNCATALOGUED", "empty" },
	}
	for i, ex in exhibits do
		local side = if i % 2 == 1 then -1 else 1
		local z = -6 - math.floor((i - 1) / 2) * 9.5
		local x = side * 10
		part(m, "Pedestal", Vector3.new(2.4, 3, 2.4), CFrame.new(x, 1.5, z), { Color = rgb(40, 38, 36), Material = M.Marble })
		part(m, "CaseGlass", Vector3.new(2.2, 2.2, 2.2), CFrame.new(x, 4.1, z), { Color = rgb(200, 215, 225), Material = M.Glass, Transparency = 0.75, CastShadow = false })
		part(m, "CaseLid", Vector3.new(2.3, 0.1, 2.3), CFrame.new(x, 5.25, z), brass)
		local kind = ex[2]
		local c = Vector3.new(x, 3.6, z)
		if kind == "probe" then
			part(m, "ProbeBody", Vector3.new(0.6, 0.6, 0.6), CFrame.new(c), { Color = rgb(190, 170, 120), Material = M.Foil })
			part(m, "ProbePanel", Vector3.new(1.8, 0.05, 0.5), CFrame.new(c), { Color = rgb(40, 60, 120), Material = M.Glass })
		elseif kind == "sample" then
			local s = part(m, "Canister", Vector3.new(0.9, 0.5, 0.5), CFrame.new(c) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(255, 130, 40) }) :: Part
			glowing(s, rgb(255, 140, 60), 6, 0.5)
		elseif kind == "bust" then
			part(m, "BustBase", Vector3.new(0.8, 0.6, 0.6), CFrame.new(c), { Color = rgb(200, 195, 185), Material = M.Marble })
			part(m, "BustHead", Vector3.new(0.6, 0.6, 0.6), CFrame.new(c + Vector3.new(0, 0.6, 0)), { Shape = Enum.PartType.Ball, Color = rgb(200, 195, 185), Material = M.Marble })
		elseif kind == "photo" then
			part(m, "PhotoFrame", Vector3.new(0.1, 1, 1.2), CFrame.new(c + Vector3.new(0, 0.2, 0)) * CFrame.Angles(0, 0, side * 0.2), brass)
			part(m, "PhotoSun", Vector3.new(0.04, 0.6, 0.6), CFrame.new(c + Vector3.new(-side * 0.07, 0.2, 0)) * CFrame.Angles(0, 0, side * 0.2), { Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(220, 180, 90), CanCollide = false })
		elseif kind == "rock" then
			part(m, "Fragment", Vector3.new(0.8, 0.6, 0.7), CFrame.new(c) * CFrame.Angles(0.4, 0.7, 0.2), { Color = rgb(60, 40, 35), Material = M.Basalt })
		elseif kind == "tape" then
			part(m, "TapeReel", Vector3.new(0.15, 1, 1), CFrame.new(c + Vector3.new(0, 0.1, 0)), { Shape = Enum.PartType.Cylinder, Color = rgb(30, 30, 32) })
		elseif kind == "ship" then
			part(m, "ModelHull", Vector3.new(0.3, 0.3, 1.8), CFrame.new(c), { Color = rgb(200, 202, 205), Material = M.Metal })
			part(m, "ModelRing", Vector3.new(0.08, 0.9, 0.9), CFrame.new(c) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Color = rgb(160, 162, 166), Material = M.Metal })
		end
		local plaque = part(m, "Plaque", Vector3.new(2, 0.5, 0.05), CFrame.new(x, 2.2, z + 1.225), brass) :: Part
		B.label(plaque, ex[1], Enum.NormalId.Back, rgb(40, 30, 20), Enum.Font.Garamond)
		local spot = part(m, "Lamp", Vector3.new(0.5, 0.3, 0.5), CFrame.new(x, h - 0.15, z), { Material = M.Neon, Color = rgb(200, 185, 150), CanCollide = false }) :: Part
		local beam = Instance.new("SpotLight")
		beam.Face = Enum.NormalId.Bottom
		beam.Angle = 30
		beam.Range = 14
		beam.Brightness = 1.2
		beam.Color = rgb(255, 230, 190)
		beam.Parent = spot
	end
	-- Company timeline along the left wall.
	B.onWall(m, w, -1, cz, 8.5, Vector2.new(34, 0.2), 0.15, "TimelineBar", brass)
	local events = { "2071\nFOUNDED", "2080\nSOL I", "2093\nTOTALITY\nLAUNCHED", "2098\nFIRST\nSAMPLE", "2101\nCONTACT\nLOST", "2105\n?" }
	for i, ev in events do
		local z = -5 - (i - 1) * 6.4
		wallSign(m, w, -1, z, 10.4, Vector2.new(3.2, 2.6), ev, rgb(35, 33, 30), rgb(215, 190, 130), Enum.Font.Garamond)
		part(m, "TimelineDot", Vector3.new(0.2, 0.5, 0.5), CFrame.new(-w / 2 + 0.25, 8.5, z), { Shape = Enum.PartType.Cylinder, Color = rgb(175, 145, 85), Material = M.Metal })
	end
	-- Wall of small Sun photographs on the right, drifting from gold to black.
	local tones = { rgb(255, 220, 120), rgb(255, 190, 90), rgb(250, 150, 60), rgb(230, 100, 50), rgb(190, 60, 60), rgb(140, 40, 90), rgb(90, 40, 130), rgb(50, 25, 90), rgb(20, 12, 30) }
	for i = 0, 9 do
		local col, row = i % 5, math.floor(i / 5)
		local z, yy = -11 - col * 5, 9 + row * 3.2 - 1.6
		B.onWall(m, w, 1, z, yy, Vector2.new(2.4, 2.4), 0.12, "PhotoFrame", brass)
		B.onWall(m, w, 1, z, yy, Vector2.new(2, 2), 0.14, "PhotoBack", { Color = rgb(12, 12, 16) })
		if tones[i + 1] then
			part(m, "PhotoSun", Vector3.new(0.04, 1.3, 1.3), CFrame.new(w / 2 - 0.16, yy, z), { Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = tones[i + 1]:Lerp(Color3.new(0, 0, 0), 0.3), CanCollide = false })
		end
	end
	wallSign(m, w, 1, -21, 13.4, Vector2.new(10, 1.2), "SOL - A PORTRAIT OVER 4,811 DAYS", rgb(35, 33, 30), rgb(215, 190, 130), Enum.Font.Garamond)
	-- Benches facing the orrery.
	for _, sx in { -1, 1 } do
		part(m, "Bench", Vector3.new(1.6, 1.5, 5), CFrame.new(sx * 5, 0.75, cz), { Color = rgb(60, 45, 35), Material = M.Wood })
	end
	endSign(m, -L, 1, 0, 12.6, Vector2.new(11, 1.2), "SOLSTICE SOLUTIONS HERITAGE EXHIBIT", rgb(35, 33, 30), rgb(215, 190, 130))
	B.panelGrid(m, w, L, h, 2, 2, p.light, 0.35, 24)
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

-- Decontamination: three spray arches with nozzle arrays, purple UV strips, a drain trench, chemical tanks,
-- and a status board that doesn't like what it found.
local function decon(): Model
	local m = B.newRoom("Decontamination", { Weight = 1, MinRoom = 10 })
	local w, L, h, p = 12, 28, 10, PAL.hygiene
	B.shell(m, w, L, h, p)
	local steel = { Color = rgb(170, 175, 178), Material = M.Metal }
	local yellow = rgb(200, 160, 40)
	for _, z in { -6, -13, -20 } do
		for _, sx in { -1, 1 } do
			part(m, "ArchPost", Vector3.new(0.7, 8.4, 0.7), CFrame.new(sx * 4.9, 4.2, z), steel)
			for k = 0, 3 do
				part(m, "ArchStripe", Vector3.new(0.72, 0.4, 0.72), CFrame.new(sx * 4.9, 0.6 + k * 0.9, z), { Color = if k % 2 == 0 then yellow else rgb(25, 25, 25) })
			end
			for k = 0, 3 do
				part(m, "SideNozzle", Vector3.new(0.4, 0.25, 0.25), CFrame.new(sx * 4.4, 2 + k * 1.6, z), { Color = rgb(60, 62, 66) })
			end
		end
		part(m, "ArchTop", Vector3.new(10.5, 0.7, 0.7), CFrame.new(0, 8.75, z), steel)
		for k = -3, 3 do
			part(m, "Nozzle", Vector3.new(0.3, 0.35, 0.3), CFrame.new(k * 1.2, 8.22, z), { Color = rgb(60, 62, 66) })
		end
	end
	-- UV strips along both walls.
	for _, sx in { -1, 1 } do
		local uv = part(m, "Lamp", Vector3.new(0.15, 0.3, L - 6), CFrame.new(sx * (w / 2 - 0.075), 7.5, -L / 2), { Material = M.Neon, Color = rgb(110, 50, 180), CanCollide = false }) :: Part
		local light = Instance.new("SurfaceLight")
		light.Face = if sx == -1 then Enum.NormalId.Right else Enum.NormalId.Left
		light.Color = rgb(150, 80, 255)
		light.Range = 10
		light.Brightness = 0.6
		light.Parent = uv
	end
	-- Drain trench down the middle.
	part(m, "Trench", Vector3.new(1.6, 0.03, L - 4), CFrame.new(0, 0.015, -L / 2), { Color = rgb(25, 27, 30) })
	for z = -2.5, -L + 2.5, -0.8 do
		part(m, "TrenchBar", Vector3.new(1.8, 0.06, 0.2), CFrame.new(0, 0.05, z), { Color = rgb(60, 62, 66), Material = M.Metal, CanCollide = false })
	end
	-- Chemical tanks with hoses on the walls.
	for _, sx in { -1, 1 } do
		part(m, "ChemTank", Vector3.new(3, 1.4, 1.4), CFrame.new(sx * (w / 2 - 0.8), 1.5, -24.5) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = if sx == -1 then rgb(60, 120, 170) else rgb(200, 170, 40), Material = M.Plastic })
		part(m, "Hose", Vector3.new(0.15, 4, 0.15), CFrame.new(sx * (w / 2 - 0.8), 5, -24.5), { Color = rgb(30, 30, 32) })
	end
	part(m, "HazmatSuit", Vector3.new(0.8, 4, 1.6), CFrame.new(-w / 2 + 0.5, 3.2, -2.8), { Color = rgb(220, 190, 40), Material = M.Plastic })
	part(m, "HazmatHood", Vector3.new(1.2, 1.2, 1.2), CFrame.new(-w / 2 + 0.5, 5.8, -2.8), { Shape = Enum.PartType.Ball, Color = rgb(220, 190, 40), Material = M.Plastic })
	local board = B.onWall(m, w, 1, -3, 5.5, Vector2.new(3, 2.2), 0.15, "StatusBoard", { Color = rgb(30, 10, 10), Material = M.Neon }) :: Part
	B.label(board, "DECON CYCLE 3/3\nCONTAMINANT\nSTILL DETECTED", Enum.NormalId.Left, rgb(255, 100, 80), Enum.Font.Code)
	B.panelGrid(m, w, L, h, 1, 3, p.light, 0.4)
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

-- Docking bay (room 1): the round docking port the team came through, a check-in desk, a mission screen,
-- benches by the windows, a painted path to the exit, the Solstice sun over the door.
local function start(): Model
	local m = B.newRoom("Start")
	local w, L, h, p = 26, 36, 12, PAL.hull
	B.shell(m, w, L, h, p, {
		entrance = false,
		windows = {
			{ side = "left", z = -12, y = 3, w = 8, h = 4 },
			{ side = "left", z = -26, y = 3, w = 8, h = 4 },
			{ side = "right", z = -12, y = 3, w = 8, h = 4 },
			{ side = "right", z = -26, y = 3, w = 8, h = 4 },
		},
	})
	local steel = { Color = rgb(150, 154, 160), Material = M.Metal }
	local dark = { Color = rgb(55, 58, 64), Material = M.Metal }
	local yellow = rgb(200, 160, 40)
	-- Docking port on the back wall.
	part(m, "DockRing", Vector3.new(0.6, 8, 8), CFrame.new(0, 4.8, -0.3) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Color = yellow, Material = M.Metal })
	part(m, "DockHatch", Vector3.new(0.3, 6.6, 6.6), CFrame.new(0, 4.8, -0.75) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Color = rgb(120, 124, 130), Material = M.DiamondPlate })
	part(m, "DockWheel", Vector3.new(0.2, 2.4, 2.4), CFrame.new(0, 4.8, -1) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Color = rgb(170, 40, 35), Material = M.Metal })
	for k = 0, 1 do
		part(m, "WheelSpoke", Vector3.new(2.2, 0.15, 0.12), CFrame.new(0, 4.8, -1.15) * CFrame.Angles(0, 0, k * math.pi / 2), steel)
	end
	for k = -3, 3 do
		if k % 2 ~= 0 then
			part(m, "Stripe", Vector3.new(0.9, 0.07, 1.4), CFrame.new(k * 1, 0.035, -1.2), { Color = rgb(25, 25, 25), CanCollide = false })
		else
			part(m, "Stripe", Vector3.new(0.9, 0.06, 1.4), CFrame.new(k * 1, 0.03, -1.2), { Color = yellow, CanCollide = false })
		end
	end
	endSign(m, 0, -1, 0, 10.2, Vector2.new(14, 1.6), "WELCOME ABOARD THE S.S. TOTALITY")
	endSign(m, 0, -1, -9, 6, Vector2.new(4.5, 1), "DOCKING PORT A", rgb(200, 160, 40), rgb(30, 25, 10))
	-- Check-in desk.
	part(m, "CheckInDesk", Vector3.new(2.5, 3.4, 6), CFrame.new(-w / 2 + 2.25, 1.7, -7), { Color = rgb(70, 74, 82), Material = M.Metal })
	part(m, "DeskTop", Vector3.new(2.8, 0.15, 6.3), CFrame.new(-w / 2 + 2.25, 3.475, -7), { Color = rgb(200, 140, 60), Material = M.Metal })
	local checkIn = part(m, "CheckInScreen", Vector3.new(0.1, 1.2, 2), CFrame.new(-w / 2 + 2.6, 4.2, -7) * CFrame.Angles(0, 0, -0.25), { Material = M.Neon, Color = rgb(20, 35, 50), CanCollide = false }) :: Part
	B.label(checkIn, "CREW CHECK-IN\n0 / 214", Enum.NormalId.Right, rgb(160, 210, 255), Enum.Font.Code)
	-- Mission screen.
	local mission = B.onWall(m, w, -1, -19, 6, Vector2.new(6, 3.6), 0.2, "MissionScreen", { Color = rgb(10, 20, 15), Material = M.Neon }) :: Part
	B.label(mission, "OBJECTIVE:\nRECOVER ALL RESEARCH\n100 SECTIONS\nSOLSTICE THANKS YOU", Enum.NormalId.Right, rgb(120, 220, 140), Enum.Font.Code)
	-- Benches beneath the right windows, a luggage cart and lockers.
	for _, z in { -12, -26 } do
		part(m, "BenchSeat", Vector3.new(1.8, 0.3, 6), CFrame.new(w / 2 - 1.6, 1.6, z), { Color = rgb(70, 74, 82), Material = M.Metal })
		part(m, "BenchCushion", Vector3.new(1.6, 0.2, 5.8), CFrame.new(w / 2 - 1.6, 1.85, z), { Color = rgb(40, 60, 90), Material = M.Fabric })
		for _, dz in { -2.4, 2.4 } do
			part(m, "BenchLeg", Vector3.new(1.4, 1.45, 0.3), CFrame.new(w / 2 - 1.6, 0.725, z + dz), dark)
		end
	end
	part(m, "LuggageCart", Vector3.new(2.2, 0.2, 3.5), CFrame.new(8, 1.2, -19), steel)
	for _, o in { Vector3.new(-1, 0, -1.6), Vector3.new(1, 0, -1.6), Vector3.new(-1, 0, 1.6), Vector3.new(1, 0, 1.6) } do
		part(m, "CartWheel", Vector3.new(0.2, 0.5, 0.5), CFrame.new(8 + o.X, 0.25, -19 + o.Z), { Shape = Enum.PartType.Cylinder, Color = rgb(25, 25, 25) })
	end
	crate(m, CFrame.new(8, 2.3, -18.3), Vector3.new(2, 2, 2))
	crate(m, CFrame.new(8.2, 2, -20.3) * CFrame.Angles(0, 0.2, 0), Vector3.new(1.6, 1.4, 1.6))
	for k = 0, 2 do
		part(m, "SuitLocker", Vector3.new(1.6, 7, 1.5), CFrame.new(w / 2 - 0.8, 3.5, -31.5 - k * 1.7), { Color = rgb(60, 70, 85), Material = M.Metal })
	end
	-- Painted path from the spawn to the exit.
	for z = -10, -32, -2.4 do
		part(m, "PathDash", Vector3.new(0.4, 0.04, 1.4), CFrame.new(0, 0.02, z), { Color = yellow, CanCollide = false })
	end
	-- Solstice sun over the exit.
	local sun = part(m, "SunEmblem", Vector3.new(0.1, 2.2, 2.2), CFrame.new(0, 10.3, -L + 0.15) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(170, 100, 40), CanCollide = false }) :: Part
	glowing(sun, rgb(255, 170, 90), 10, 0.5)
	for k = 0, 7 do
		if k ~= 4 then
			part(m, "SunRay", Vector3.new(0.22, 0.5, 0.08), CFrame.new(0, 10.3, -L + 0.12) * CFrame.Angles(0, 0, k * math.pi / 4) * CFrame.new(0, 1.2, 0), { Color = rgb(200, 160, 90), Material = M.Metal })
		end
	end
	B.marker(m, "PlayerSpawn", CFrame.new(0, 3, -7))
	B.panelGrid(m, w, L, h, 2, 4, p.light, 0.7)
	return m
end

-- Room 50: an executive briefing hall. Tiered seats face a giant screen; a hologram of a Solstice executive
-- stands at the podium to thank you.
local function midpoint(): Model
	local m = B.newRoom("Midpoint")
	local w, L, h, p = 34, 36, 14, PAL.executive
	B.shell(m, w, L, h, p)
	local wood = { Color = rgb(55, 40, 32), Material = M.Wood }
	-- The screen.
	B.onWall(m, w, -1, -18, 7, Vector2.new(18, 8), 0.2, "ScreenFrame", { Color = rgb(30, 30, 34), Material = M.Metal })
	local screen = B.onWall(m, w, -1, -18, 7, Vector2.new(17, 7.2), 0.25, "Screen", { Color = rgb(15, 30, 55), Material = M.Neon }) :: Part
	B.label(screen, "SOLSTICE SOLUTIONS THANKS YOU\nFOR YOUR CONTINUED COOPERATION\n\n50 / 100\nYOU ARE HALFWAY THERE", Enum.NormalId.Right, rgb(200, 220, 255), Enum.Font.Code)
	-- Podium and hologram.
	part(m, "Podium", Vector3.new(1.6, 3.6, 2.4), CFrame.new(-9, 1.8, -18), wood)
	part(m, "PodiumTop", Vector3.new(1.8, 0.15, 2.6), CFrame.new(-9, 3.675, -18) * CFrame.Angles(0, 0, 0.2), wood)
	local holoBase = part(m, "HoloPad", Vector3.new(0.1, 2.4, 2.4), CFrame.new(-11, 0.05, -18) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(60, 150, 180), CanCollide = false }) :: Part
	glowing(holoBase, rgb(120, 220, 255), 10, 0.6)
	local holo = { Material = M.Neon, Color = rgb(110, 210, 240), Transparency = 0.55, CanCollide = false, CastShadow = false }
	part(m, "HoloBody", Vector3.new(1, 3.4, 1.8), CFrame.new(-11, 2.5, -18), holo)
	part(m, "HoloHead", Vector3.new(1.1, 1.1, 1.1), CFrame.new(-11, 4.8, -18), { Shape = Enum.PartType.Ball, Material = M.Neon, Color = rgb(110, 210, 240), Transparency = 0.55, CanCollide = false, CastShadow = false })
	part(m, "HoloArm", Vector3.new(0.4, 1.8, 0.4), CFrame.new(-10.6, 3, -16.9) * CFrame.Angles(0, 0, -0.6), holo)
	-- Three tiers of seating facing the screen.
	for t = 0, 2 do
		local x, rise = 6 + t * 4, t * 0.6
		if t > 0 then
			part(m, "Tier", Vector3.new(4, rise, 24), CFrame.new(x, rise / 2, -18), { Color = rgb(60, 30, 35), Material = M.Carpet })
		end
		for z = -8, -28, -2.6 do
			chair(m, CFrame.new(x, rise, z) * CFrame.Angles(0, math.rad(90), 0), rgb(80, 30, 35))
		end
	end
	-- Banners, a water station, the number over the door.
	for _, z in { -4, -32 } do
		for _, side in { -1, 1 } do
			B.onWall(m, w, side, z, 8.5, Vector2.new(2.6, 7), 0.1, "Banner", { Color = rgb(200, 110, 40), Material = M.Fabric })
		end
	end
	part(m, "WaterTable", Vector3.new(1.6, 3, 3), CFrame.new(-w / 2 + 0.8, 1.5, -31), wood)
	part(m, "Pitcher", Vector3.new(1, 0.6, 0.6), CFrame.new(-w / 2 + 0.8, 3.5, -31) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = rgb(200, 220, 235), Material = M.Glass, Transparency = 0.4 })
	endSign(m, -L, 1, 0, 11.4, Vector2.new(3, 2), "50", rgb(30, 30, 34), rgb(255, 170, 90))
	B.panelGrid(m, w, L, h, 2, 3, p.light, 0.55)
	return m
end

-- Room 100: the heart of the ship. Spotless. A solar core hangs in containment rings over a gleaming platform,
-- fed by four conduits. The research upload terminal waits in front of it. Nothing here was touched.
local function final(): Model
	local m = B.newRoom("Final", { Pristine = true })
	local w, L, h, p = 50, 64, 34, PAL.pristine
	local windows = {}
	for _, side in { "left", "right" } do
		for _, z in { -16, -32, -48 } do
			table.insert(windows, { side = side, z = z, y = 4, w = 10, h = 10 })
		end
	end
	B.shell(m, w, L, h, p, { exit = "none", windows = windows })
	local gold = { Color = rgb(200, 165, 90), Material = M.Metal }
	local white = { Color = rgb(235, 235, 230), Material = M.Marble }
	local cz, coreY = -36, 17
	-- Platform and the energy column under the core.
	part(m, "Platform", Vector3.new(1, 18, 18), CFrame.new(0, 0.5, cz) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = white.Color, Material = white.Material })
	part(m, "PlatformTrim", Vector3.new(0.2, 18.6, 18.6), CFrame.new(0, 0.1, cz) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Color = gold.Color, Material = gold.Material })
	part(m, "EnergyColumn", Vector3.new(coreY - 5, 1.2, 1.2), CFrame.new(0, 1 + (coreY - 5) / 2, cz) * CFrame.Angles(0, 0, math.pi / 2), { Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(255, 220, 170), Transparency = 0.3, CanCollide = false })
	-- The core.
	local core = part(m, "SolarCore", Vector3.new(8, 8, 8), CFrame.new(0, coreY, cz), { Shape = Enum.PartType.Ball, Material = M.Neon, Color = rgb(255, 170, 70), CanCollide = false }) :: Part
	glowing(core, rgb(255, 190, 110), 60, 2.5)
	part(m, "CoreHalo", Vector3.new(10, 10, 10), CFrame.new(0, coreY, cz), { Shape = Enum.PartType.Ball, Material = M.Neon, Color = rgb(255, 230, 190), Transparency = 0.8, CanCollide = false, CastShadow = false })
	-- Three containment rings made of segments.
	local orientations = { CFrame.Angles(0, 0, 0), CFrame.Angles(math.pi / 2, 0, 0), CFrame.Angles(0, 0, math.pi / 2) }
	for r, o in orientations do
		local radius = 6.5 + r * 0.8
		for k = 0, 23 do
			local a = k / 24 * math.pi * 2
			part(m, "ContainmentRing", Vector3.new(0.6, 0.6, 1.9), CFrame.new(0, coreY, cz) * o * CFrame.Angles(0, a, 0) * CFrame.new(0, 0, -radius), gold)
		end
	end
	-- Four conduits from the platform edge up to the core.
	for _, c in { Vector3.new(-7, 1, cz - 7), Vector3.new(7, 1, cz - 7), Vector3.new(-7, 1, cz + 7), Vector3.new(7, 1, cz + 7) } do
		local target = Vector3.new(0, coreY - 4, cz)
		local mid = (c + target) / 2
		part(m, "Conduit", Vector3.new(1.4, 1.4, (target - c).Magnitude), CFrame.lookAt(mid, target), { Color = rgb(220, 220, 215), Material = M.Metal })
		part(m, "ConduitBase", Vector3.new(2.4, 1.6, 2.4), CFrame.new(c.X, 1.8, c.Z), gold)
	end
	-- Gold lines across the floor leading to the platform.
	for _, x in { -3, 3 } do
		part(m, "FloorLine", Vector3.new(0.3, 0.04, 26), CFrame.new(x, 0.02, -13), { Color = gold.Color, Material = M.Metal, CanCollide = false })
	end
	-- Research upload terminal in front of the platform.
	part(m, "Terminal", Vector3.new(4, 3, 1.6), CFrame.new(0, 2.5, cz + 8), white)
	local screen = part(m, "TerminalScreen", Vector3.new(3.4, 1.8, 0.05), CFrame.new(0, 4.9, cz + 8.6) * CFrame.Angles(-0.25, 0, 0), { Material = M.Neon, Color = rgb(30, 25, 15), CanCollide = false }) :: Part
	B.label(screen, "RESEARCH UPLOAD\nAWAITING CREW", Enum.NormalId.Back, rgb(255, 210, 150), Enum.Font.Code)
	-- Gold pilasters between the windows, and a great sun on the far wall.
	for _, side in { -1, 1 } do
		for _, z in { -6, -24, -40, -56 } do
			B.onWall(m, w, side, z, h / 2, Vector2.new(1.4, h), 0.6, "Pilaster", gold)
		end
	end
	local sun = part(m, "SunEmblem", Vector3.new(0.2, 12, 12), CFrame.new(0, 20, -L + 0.2) * CFrame.Angles(0, math.pi / 2, 0), { Shape = Enum.PartType.Cylinder, Material = M.Neon, Color = rgb(220, 170, 90), CanCollide = false }) :: Part
	glowing(sun, rgb(255, 210, 150), 30, 0.8)
	for k = 0, 15 do
		part(m, "SunRay", Vector3.new(0.6, 4, 0.12), CFrame.new(0, 20, -L + 0.15) * CFrame.Angles(0, 0, k * math.pi / 8) * CFrame.new(0, 8.5, 0), gold)
	end
	for _, x in { -15, 15 } do
		for _, z in { -10, -30, -50 } do
			B.panel(m, x, h, z, p.light, 0.8, 40)
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
		bridge(), capacitors(), tunnel(), security(), brig(), recycling(), lounge(), escapePods(),
		gallery(), arboretum(), decon(), sampleVault(),
	})
end

function RoomPresets.BuildSpecial(): { [string]: Model }
	return detailed({ Start = start(), MemorialRoom = memorial(), Midpoint = midpoint(), Final = final() })
end

return RoomPresets
