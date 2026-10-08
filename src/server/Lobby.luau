--[[
	The Solstice Solutions Mars lobby (Config.LOBBY = true).

	Players start here. Three launch pods (1-4 crew each) sit along the back
	wall; stepping into one starts its countdown, and when it reaches zero the
	pod's crew is sent up to the S.S. Totality (room 1).

	Layout follows the floor plan, in studs, seen from above: x runs right,
	z runs "down" the page toward the big windows, y is up.

	  Floor 1 (y 0)
	    raised platform (y 2), x 0..30, z 0..38.6
	      locker room / EVA suit-up    x 0..30,  z 0..23
	      reception island             x 4..28,  z 24..36
	      steps down to the lobby      x 30..34, z 24..36
	    launch pods A, B, C            along the back wall, z 1.4..15.4
	    stairs to floor 2              x 80..97, z 11..22 (two flights)
	    open atrium with the orrery, lounge seating along the windows
	  Floor 2 (y 14)
	    Peri's office                  x 0..29, z 0..38.6, window over the atrium
	    stair landing                  x 76..98, z 0..17
	    see-through grate walkway      around the atrium, along the windows

	Everything is anchored parts plus Terrain for the Martian landscape.
	To edit the lobby by hand: play, copy Workspace.Lobby, stop, paste it into
	the Workspace and save. From then on that saved copy is used instead of
	building a new one (the terrain is still generated each time).
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage.Shared.Config)
local B = require(script.Parent.RoomBuilder)
local CrewNPC = require(script.Parent.CrewNPC)

local Lobby = {}

-- Called with the list of players in a pod when it launches. Set by init.
Lobby.OnLaunch = nil :: ((players: { Player }) -> boolean)?

local O: CFrame = Config.LOBBY_CFRAME
local folder: Folder

-- Palette ---------------------------------------------------------------------
local WHITE = Color3.fromRGB(228, 226, 221)
local PANEL = Color3.fromRGB(214, 211, 205)
local SEAM = Color3.fromRGB(150, 148, 144)
local DARK = Color3.fromRGB(52, 54, 60)
local STEEL = Color3.fromRGB(140, 143, 150)
local ORANGE = Color3.fromRGB(240, 128, 40)
local AMBER = Color3.fromRGB(255, 190, 120)
local FLOOR = Color3.fromRGB(205, 200, 192)
local INLAY = Color3.fromRGB(70, 72, 78)
local GLASS = Color3.fromRGB(215, 180, 160)
local SAND = Color3.fromRGB(176, 92, 56)
local WOOD = Color3.fromRGB(120, 84, 58)
local FABRIC = Color3.fromRGB(64, 70, 84)
local COOL = Color3.fromRGB(235, 240, 255)
local WARM = Color3.fromRGB(255, 225, 190)

local SMOOTH = Enum.Material.SmoothPlastic
local METAL = Enum.Material.Metal
local NEON = Enum.Material.Neon

-- Geometry helpers --------------------------------------------------------------
local function cf(x: number, y: number, z: number): CFrame
	return O * CFrame.new(x, y, z)
end

local function pos(x: number, y: number, z: number): Vector3
	return O:PointToWorldSpace(Vector3.new(x, y, z))
end

-- Axis-aligned box from two corners.
local function box(name: string, x0: number, y0: number, z0: number, x1: number, y1: number, z1: number,
	props: { [string]: any }?, parent: Instance?): Part?
	return B.part(parent or folder, name, Vector3.new(math.abs(x1 - x0), math.abs(y1 - y0), math.abs(z1 - z0)),
		cf((x0 + x1) / 2, (y0 + y1) / 2, (z0 + z1) / 2), props)
end

-- Slab along the line a -> b (seen from above). `t` thick, centred `off` studs to
-- the right of the line (the right side of every outline edge is indoors).
local function seg(name: string, ax: number, az: number, bx: number, bz: number, y0: number, y1: number,
	t: number, off: number, props: { [string]: any }?, parent: Instance?): Part?
	local a, b = Vector3.new(ax, 0, az), Vector3.new(bx, 0, bz)
	local dir = b - a
	local mid = (a + b) / 2
	local frame = CFrame.lookAt(mid, mid + dir)
	frame = frame + frame.RightVector * off + Vector3.new(0, (y0 + y1) / 2, 0)
	return B.part(parent or folder, name, Vector3.new(t, y1 - y0, dir.Magnitude), O * frame, props)
end

local function cyl(name: string, x: number, y: number, z: number, radius: number, height: number,
	props: { [string]: any }?, parent: Instance?): Part?
	-- Cylinders run along their X axis, so stand them up.
	local p = B.part(parent or folder, name, Vector3.new(height, radius * 2, radius * 2),
		cf(x, y + height / 2, z) * CFrame.Angles(0, 0, math.rad(90)), props)
	if p then
		p.Shape = Enum.PartType.Cylinder
	end
	return p
end

local function ball(name: string, x: number, y: number, z: number, d: number, props: { [string]: any }?,
	parent: Instance?): Part?
	local p = B.part(parent or folder, name, Vector3.new(d, d, d), cf(x, y, z), props)
	if p then
		p.Shape = Enum.PartType.Ball
	end
	return p
end

local function sign(target: Part?, text: string, face: Enum.NormalId, color: Color3?, font: Enum.Font?)
	if target then
		B.label(target, text, face, color or WHITE, font or Enum.Font.GothamBold)
	end
end

local function glow(p: Part?, color: Color3, range: number, brightness: number, kind: string?)
	if not p then
		return
	end
	local light = Instance.new(kind or "PointLight") :: any
	light.Color = color
	light.Range = range
	light.Brightness = brightness
	if kind == "SurfaceLight" then
		light.Face = Enum.NormalId.Bottom
		light.Angle = 110
	end
	light.Shadows = true
	light.Parent = p
end

-- Ceiling panel lamp hanging flush under height y.
local function panel(x: number, y: number, z: number, color: Color3?, size: Vector3?, range: number?)
	local p = B.panel(folder, 0, 0, 0, color or COOL, 0.7, range or 18, size)
	p.CFrame = cf(x, y - p.Size.Y / 2, z)
end

-- Point-in-polygon on the floor plan (x, z pairs).
local function inside(poly: { Vector2 }, x: number, z: number): boolean
	local hit = false
	local j = #poly
	for i = 1, #poly do
		local a, b = poly[i], poly[j]
		if (a.Y > z) ~= (b.Y > z) and x < (b.X - a.X) * (z - a.Y) / (b.Y - a.Y) + a.X then
			hit = not hit
		end
		j = i
	end
	return hit
end

local function v(x: number, z: number): Vector2
	return Vector2.new(x, z)
end

-- Building outline (both floors) and the open atrium above the lobby.
local OUTLINE = { v(0, 0), v(82, 0), v(98, 11), v(98, 34), v(79, 50), v(36, 50), v(28, 38.6), v(0, 38.6) }
local VOID = { v(29, 0), v(76, 0), v(76, 17), v(85, 17), v(85, 31), v(76, 39.4), v(39, 39.4), v(29, 30) }

local H1, H2 = 14, 26 -- floor 2 level, roof underside
local PLAT = 2 -- raised platform height

-- Shell ---------------------------------------------------------------------------
local function buildShell()
	-- Foundation pad (also the floor everywhere indoors) and the roof, both a
	-- little bigger than the building so they make a terrace and an overhang.
	box("Foundation", -3, -2, -3, 101, 0, 53, { Color = Color3.fromRGB(150, 112, 92), Material = Enum.Material.Concrete })
	box("Floor", 0, 0, 0, 98, 0.1, 50, { Color = FLOOR, Material = Enum.Material.Marble })
	-- Dark inlay bands across the lobby floor.
	for _, z in { 18.5, 42 } do
		box("Inlay", 34, 0.1, z, 96, 0.12, z + 0.5, { Color = INLAY })
	end
	box("Inlay", 33.5, 0.1, 18.5, 34, 0.12, 48, { Color = INLAY })

	-- Roof with a skylight over the atrium.
	local roof = { Color = Color3.fromRGB(190, 186, 180), Material = Enum.Material.Concrete }
	box("Roof", -2, H2, -2, 100, H2 + 1.2, 8, roof)
	box("Roof", -2, H2, 30, 100, H2 + 1.2, 52, roof)
	box("Roof", -2, H2, 8, 40, H2 + 1.2, 30, roof)
	box("Roof", 70, H2, 8, 100, H2 + 1.2, 30, roof)
	box("Skylight", 40, H2 + 0.4, 8, 70, H2 + 0.6, 30, { Color = GLASS, Material = Enum.Material.Glass, Transparency = 0.6, CanCollide = false })
	for x = 40, 70, 5 do
		box("SkylightFrame", x - 0.25, H2 - 0.4, 8, x + 0.25, H2 + 1.3, 30, { Color = DARK, Material = METAL })
	end
	for _, z in { 8, 15.3, 22.6, 30 } do
		box("SkylightFrame", 40, H2 - 0.4, z - 0.25, 70, H2 + 1.3, z + 0.25, { Color = DARK, Material = METAL })
	end

	-- Solid walls ------------------------------------------------------------
	local wallProps = { Color = WHITE, Material = SMOOTH }
	local function solid(name, ax, az, bx, bz, openings)
		-- Walls go outward from the outline; openings = { {u0, u1, y0, y1}, ... } along the edge.
		local len = (Vector2.new(bx, bz) - Vector2.new(ax, az)).Magnitude
		local dx, dz = (bx - ax) / len, (bz - az) / len
		local function piece(u0, u1, y0, y1)
			if u1 - u0 > 0.01 and y1 - y0 > 0.01 then
				seg(name, ax + dx * u0, az + dz * u0, ax + dx * u1, az + dz * u1, y0, y1, 1, -0.5, wallProps)
			end
		end
		-- Split the wall at every opening edge; in each strip, fill the height
		-- around whichever openings cover it (openings can be stacked).
		local cuts = { 0, len }
		for _, o in openings do
			table.insert(cuts, o[1])
			table.insert(cuts, o[2])
		end
		table.sort(cuts)
		for i = 1, #cuts - 1 do
			local u0, u1 = cuts[i], cuts[i + 1]
			if u1 - u0 > 0.01 then
				local holes = {}
				for _, o in openings do
					if o[1] <= u0 + 0.001 and o[2] >= u1 - 0.001 then
						table.insert(holes, o)
					end
				end
				table.sort(holes, function(p, q)
					return p[3] < q[3]
				end)
				local y = 0
				for _, o in holes do
					piece(u0, u1, y, o[3])
					y = o[4]
				end
				piece(u0, u1, y, H2)
			end
		end
	end
	-- North (back) wall: clerestory windows high over the atrium.
	solid("Wall", 0, 0, 82, 0, { { 32, 74, 17.5, 24 } })
	-- West wall: EVA airlock from the locker room, office window.
	solid("Wall", 0, 38.6, 0, 0, { { 24.6, 29.6, PLAT, PLAT + 8 }, { 8, 30, 16, 23 } })
	-- South-west wall behind the reception: window band on both floors.
	solid("Wall", 28, 38.6, 0, 38.6, { { 3, 25, 5, 11 }, { 4, 24, 16, 23 } })

	-- Glass fill and frames for those openings.
	local glassProps = { Color = GLASS, Material = Enum.Material.Glass, Transparency = 0.7, CanCollide = true }
	box("Glass", 32, 17.5, -0.6, 74, 24, -0.4, glassProps)
	box("Glass", -0.6, 16, 8.6, -0.4, 23, 30.6, glassProps)
	box("Glass", 3, 5, 38.9, 25, 11, 39.1, glassProps)
	box("Glass", 4, 16, 38.9, 24, 23, 39.1, glassProps)
	for x = 32, 74, 6 do
		box("Mullion", x - 0.2, 17.5, -0.8, x + 0.2, 24, -0.1, { Color = DARK, Material = METAL })
	end
	for z = 8.6, 30.6, 5.5 do
		box("Mullion", -0.8, 16, z - 0.2, -0.1, 23, z + 0.2, { Color = DARK, Material = METAL })
	end
	for x = 3, 25, 5.5 do
		box("Mullion", x - 0.2, 5, 38.7, x + 0.2, 11, 39.4, { Color = DARK, Material = METAL })
	end
	for x = 4, 24, 5 do
		box("Mullion", x - 0.2, 16, 38.7, x + 0.2, 23, 39.4, { Color = DARK, Material = METAL })
	end

	-- Curtain walls: floor-to-roof glass onto Mars ------------------------------
	local curtains = {
		{ 82, 0, 98, 11 }, { 98, 11, 98, 34 }, { 98, 34, 79, 50 }, { 79, 50, 36, 50 }, { 36, 50, 28, 38.6 },
	}
	for _, c in curtains do
		local ax, az, bx, bz = c[1], c[2], c[3], c[4]
		local len = (Vector2.new(bx, bz) - Vector2.new(ax, az)).Magnitude
		local dx, dz = (bx - ax) / len, (bz - az) / len
		local glass = { Color = GLASS, Material = Enum.Material.Glass, Transparency = 0.72 }
		seg("Glass", ax, az, bx, bz, 0.8, 12.6, 0.3, -0.25, glass)
		seg("Glass", ax, az, bx, bz, 14.4, 25.4, 0.3, -0.25, glass)
		-- Sill, spandrel at the floor-2 slab, head.
		seg("Sill", ax, az, bx, bz, 0, 0.8, 0.9, -0.15, { Color = DARK, Material = METAL })
		seg("Spandrel", ax, az, bx, bz, 12.6, 14.4, 0.9, -0.15, { Color = PANEL, Material = SMOOTH })
		seg("Head", ax, az, bx, bz, 25.4, H2, 0.9, -0.15, { Color = DARK, Material = METAL })
		-- Warm cove light along the underside of the spandrel.
		local cove = seg("Cove", ax, az, bx, bz, 12.45, 12.6, 0.3, 0.45, { Color = AMBER, Material = NEON, CanCollide = false })
		glow(cove, WARM, 10, 0.35, "SurfaceLight")
		-- Mullions and transoms.
		local n = math.max(1, math.round(len / 5.5))
		for i = 0, n do
			local u = len * i / n
			local x, z = ax + dx * u, az + dz * u
			seg("Mullion", x - dx * 0.2, z - dz * 0.2, x + dx * 0.2, z + dz * 0.2, 0, H2, 0.7, -0.15, { Color = DARK, Material = METAL })
		end
		seg("Transom", ax, az, bx, bz, 6.9, 7.2, 0.6, -0.2, { Color = DARK, Material = METAL })
		seg("Transom", ax, az, bx, bz, 20, 20.3, 0.6, -0.2, { Color = DARK, Material = METAL })
	end

	-- Structural columns at every corner of the outline.
	for _, p in OUTLINE do
		box("Column", p.X - 0.7, 0, p.Y - 0.7, p.X + 0.7, H2, p.Y + 0.7, { Color = DARK, Material = METAL })
	end
end

-- Raised platform: locker room, reception, steps ---------------------------------
local function buildPlatform()
	box("Platform", 0, 0.1, 0, 30, PLAT, 38.6, { Color = Color3.fromRGB(196, 190, 182), Material = Enum.Material.Marble })
	-- Steps down into the lobby, with glowing nosings.
	for k = 1, 4 do
		local top = PLAT - 0.5 * k
		box("Step", 30 + (k - 1), 0.1, 24, 30 + k, top, 36, { Color = Color3.fromRGB(196, 190, 182), Material = Enum.Material.Marble })
		box("Nosing", 30 + (k - 1), top, 24, 30 + (k - 1) + 0.15, top + 0.04, 36, { Color = AMBER, Material = NEON, CanCollide = false })
	end
	box("Nosing", 29.85, PLAT, 24, 30, PLAT + 0.04, 36, { Color = AMBER, Material = NEON, CanCollide = false })
	-- Rails where the platform edge drops off.
	for _, r in { { 23, 24 }, { 36, 38.6 } } do
		box("RailPost", 29.6, PLAT, r[1] + 0.1, 29.9, PLAT + 3.4, r[1] + 0.4, { Color = STEEL, Material = METAL })
		box("Rail", 29.55, PLAT + 3.4, r[1], 29.95, PLAT + 3.6, r[2], { Color = STEEL, Material = METAL })
		box("RailGlass", 29.7, PLAT + 0.2, r[1], 29.8, PLAT + 3.4, r[2], { Color = GLASS, Material = Enum.Material.Glass, Transparency = 0.6 })
	end
	-- Ceiling lights under the office.
	for _, p in { { 8, 30 }, { 18, 30 }, { 25, 30 } } do
		panel(p[1], H1 - 1.1, p[2], WARM, Vector3.new(5, 0.3, 1.6))
	end
	box("Soffit", 0, H1 - 1.1, 23, 29, H1 - 1, 38.6, { Color = PANEL, Material = SMOOTH })
end

local function lockerRoom()
	local y = PLAT
	local top = H1 - 1
	-- Walls (east and the south partition with the doorway at its west end).
	box("Wall", 30, y, 0, 30.6, top, 23, { Color = WHITE, Material = SMOOTH })
	box("Wall", 7, y, 22.4, 30, top, 23, { Color = WHITE, Material = SMOOTH })
	box("Wall", 0, y + 9, 22.4, 7, top, 23, { Color = WHITE, Material = SMOOTH })
	box("DoorFrame", 6.7, y, 22.2, 7, y + 9, 23.2, { Color = ORANGE, Material = SMOOTH })
	box("Ceiling", 0, top - 0.1, 0, 30.6, top, 23, { Color = PANEL, Material = SMOOTH })
	local s = box("Sign", 9, y + 7.2, 23, 17, y + 8.6, 23.15, { Color = DARK })
	sign(s, "CREW LOCKERS · EVA", Enum.NormalId.Back, AMBER)

	-- Lockers along the north wall, numbered.
	for i = 0, 12 do
		local x0 = 1.2 + i * 2.1
		local l = box("Locker", x0, y, 0, x0 + 2, y + 7.4, 1.6, { Color = Color3.fromRGB(96, 104, 118), Material = METAL })
		box("LockerVent", x0 + 0.4, y + 6.2, 1.6, x0 + 1.6, y + 6.9, 1.65, { Color = DARK })
		box("LockerVent", x0 + 0.4, y + 0.5, 1.6, x0 + 1.6, y + 1.2, 1.65, { Color = DARK })
		box("Handle", x0 + 1.55, y + 3.4, 1.6, x0 + 1.7, y + 4.4, 1.75, { Color = STEEL, Material = METAL })
		local tag = box("LockerTag", x0 + 0.6, y + 5.2, 1.6, x0 + 1.4, y + 5.7, 1.65, { Color = WHITE })
		sign(tag, string.format("%02d", i + 1), Enum.NormalId.Back, DARK)
		_ = l
	end
	-- West wall lockers either side of the airlock.
	for _, span in { { 1.8, 7.8 }, { 15.6, 21.6 } } do
		for z0 = span[1], span[2] - 2, 2.1 do
			box("Locker", 0, y, z0, 1.6, y + 7.4, z0 + 2, { Color = Color3.fromRGB(96, 104, 118), Material = METAL })
			box("Handle", 1.6, y + 3.4, z0 + 1.55, 1.75, y + 4.4, z0 + 1.7, { Color = STEEL, Material = METAL })
			box("LockerVent", 1.6, y + 6.2, z0 + 0.4, 1.65, y + 6.9, z0 + 1.6, { Color = DARK })
		end
	end

	-- EVA airlock (sealed) through the west wall onto the Martian surface.
	box("AirlockFrame", 0, y, 8.6, 1.4, y + 8.4, 9, { Color = ORANGE })
	box("AirlockFrame", 0, y, 14, 1.4, y + 8.4, 14.4, { Color = ORANGE })
	box("AirlockFrame", 0, y + 8, 9, 1.4, y + 8.4, 14, { Color = ORANGE })
	box("AirlockDoor", 0.2, y, 9, 0.8, y + 8, 11.5, { Color = Color3.fromRGB(180, 184, 190), Material = METAL })
	box("AirlockDoor", 0.2, y, 11.5, 0.8, y + 8, 14, { Color = Color3.fromRGB(180, 184, 190), Material = METAL })
	box("AirlockPort", 0.8, y + 5, 10.4, 0.85, y + 6.4, 11.1, { Color = Color3.fromRGB(255, 170, 120), Material = Enum.Material.Glass, Transparency = 0.3 })
	box("AirlockPort", 0.8, y + 5, 11.9, 0.85, y + 6.4, 12.6, { Color = Color3.fromRGB(255, 170, 120), Material = Enum.Material.Glass, Transparency = 0.3 })
	for i = 0, 4 do
		box("Hazard", 1.4, y + 0.01, 9 + i, 4, y + 0.03, 9.5 + i, { Color = if i % 2 == 0 then Color3.fromRGB(240, 190, 30) else DARK })
	end
	local lamp = box("Lamp", 0.9, y + 8.6, 11.1, 1.3, y + 9.2, 11.9, { Color = Color3.fromRGB(255, 60, 40), Material = NEON })
	glow(lamp, Color3.fromRGB(255, 70, 50), 8, 0.6)
	local a = box("Sign", 1.4, y + 9.4, 9.5, 1.45, y + 10.6, 13.5, { Color = DARK })
	sign(a, "AIRLOCK · SURFACE ACCESS", Enum.NormalId.Right, Color3.fromRGB(255, 120, 90))

	-- Benches.
	for _, z in { 8.2, 15.2 } do
		box("BenchTop", 8, y + 1.6, z, 22, y + 2, z + 1.6, { Color = WOOD, Material = Enum.Material.Wood })
		for _, x in { 9, 15, 21 } do
			box("BenchLeg", x - 0.2, y, z + 0.6, x + 0.2, y + 1.6, z + 1, { Color = STEEL, Material = METAL })
		end
	end

	-- EVA suits on stands along the east wall.
	for i, z in { 4, 9.5, 15 } do
		local x = 28
		box("SuitStand", x - 0.15, y, z - 0.15, x + 0.15, y + 7.6, z + 0.15, { Color = STEEL, Material = METAL })
		box("SuitBase", x - 1, y, z - 1, x + 1, y + 0.2, z + 1, { Color = DARK, Material = METAL })
		local white = { Color = Color3.fromRGB(236, 234, 228), Material = Enum.Material.Fabric }
		box("SuitTorso", x - 0.7, y + 4.2, z - 1.1, x + 0.5, y + 6.6, z + 1.1, white)
		box("SuitPack", x + 0.5, y + 4.4, z - 0.9, x + 1.3, y + 6.8, z + 0.9, { Color = Color3.fromRGB(200, 198, 192) })
		box("SuitLeg", x - 0.5, y + 0.4, z - 0.85, x + 0.3, y + 4.2, z - 0.15, white)
		box("SuitLeg", x - 0.5, y + 0.4, z + 0.15, x + 0.3, y + 4.2, z + 0.85, white)
		box("SuitBoot", x - 0.8, y + 0.2, z - 0.9, x + 0.35, y + 0.9, z - 0.1, { Color = DARK })
		box("SuitBoot", x - 0.8, y + 0.2, z + 0.1, x + 0.35, y + 0.9, z + 0.9, { Color = DARK })
		box("SuitArm", x - 0.5, y + 3.3, z - 1.6, x + 0.2, y + 6.4, z - 1.1, white)
		box("SuitArm", x - 0.5, y + 3.3, z + 1.1, x + 0.2, y + 6.4, z + 1.6, white)
		box("SuitBand", x - 0.72, y + 5.4, z - 1.12, x + 0.52, y + 5.7, z + 1.12, { Color = ORANGE })
		ball("SuitHelmet", x - 0.1, y + 7.4, z, 1.6, white)
		ball("Visor", x - 0.45, y + 7.4, z, 1.2, { Color = Color3.fromRGB(230, 150, 40), Material = Enum.Material.Glass, Reflectance = 0.4 })
		local tag = box("SuitTag", x - 0.72, y + 6, z - 0.6, x - 0.7, y + 6.4, z + 0.6, { Color = DARK })
		sign(tag, `EVA-0{i}`, Enum.NormalId.Left, WHITE)
	end
	local s3 = box("Sign", 29.95, y + 8, 6, 30, y + 9.2, 13, { Color = DARK })
	sign(s3, "SUIT UP BEFORE SURFACE ACCESS", Enum.NormalId.Left, AMBER)

	-- Lights.
	for _, p in { { 7, 6 }, { 15, 6 }, { 23, 6 }, { 7, 16 }, { 15, 16 }, { 23, 16 } } do
		panel(p[1], top - 0.1, p[2], COOL, Vector3.new(4, 0.3, 1.6), 14)
	end
end

local function reception()
	local y = PLAT
	local counter = { Color = WHITE, Material = SMOOTH }
	local topProps = { Color = Color3.fromRGB(40, 42, 48), Material = Enum.Material.Granite }
	-- U-shaped counter open to the west.
	box("Counter", 24, y, 25, 26, y + 3.4, 35, counter)
	box("Counter", 12, y, 25, 24, y + 3.4, 26.6, counter)
	box("Counter", 12, y, 33.4, 24, y + 3.4, 35, counter)
	box("CounterTop", 23.8, y + 3.4, 24.8, 26.4, y + 3.6, 35.2, topProps)
	box("CounterTop", 11.8, y + 3.4, 24.8, 23.8, y + 3.6, 26.8, topProps)
	box("CounterTop", 11.8, y + 3.4, 33.2, 23.8, y + 3.6, 35.2, topProps)
	-- Orange light strip along the front and the company name.
	local strip = box("CounterStrip", 26, y + 0.3, 25.2, 26.05, y + 0.5, 34.8, { Color = ORANGE, Material = NEON, CanCollide = false })
	glow(strip, ORANGE, 6, 0.4)
	local name = box("CounterSign", 26, y + 1.4, 26, 26.05, y + 2.8, 34, { Color = WHITE })
	sign(name, "SOLSTICE SOLUTIONS", Enum.NormalId.Right, DARK)
	-- Terminals and chairs.
	for _, z in { 27.5, 32.5 } do
		box("Monitor", 24.4, y + 3.8, z - 1.2, 24.6, y + 5.2, z + 1.2, { Color = DARK })
		local scr = box("Screen", 24.35, y + 3.9, z - 1.1, 24.4, y + 5.1, z + 1.1, { Color = Color3.fromRGB(90, 160, 220), Material = NEON })
		_ = scr
		box("MonitorStand", 24.5, y + 3.6, z - 0.2, 24.7, y + 3.8, z + 0.2, { Color = DARK })
		box("ChairSeat", 21, y + 1.6, z - 0.9, 22.8, y + 2, z + 0.9, { Color = FABRIC })
		box("ChairBack", 20.6, y + 2, z - 0.9, 21, y + 4, z + 0.9, { Color = FABRIC })
		box("ChairPost", 21.8, y, z - 0.15, 22.1, y + 1.6, z + 0.15, { Color = STEEL, Material = METAL })
	end
	-- Freestanding logo wall behind the desk.
	box("LogoWall", 5, y, 26, 6, y + 9, 34, { Color = DARK, Material = SMOOTH })
	local sun = cyl("SunEmblem", 6, y + 5.5, 30, 1.8, 0.2, { Color = ORANGE, Material = NEON }, nil)
	if sun then
		sun.CFrame = cf(6.1, y + 5.5, 30) * CFrame.Angles(0, 0, 0)
		glow(sun, ORANGE, 10, 0.6)
	end
	for i = 0, 7 do
		local a = i * math.pi / 4
		local p = B.part(folder, "SunRay", Vector3.new(0.12, 0.35, 1.4),
			cf(6.08, y + 5.5 + math.sin(a) * 2.8, 30 + math.cos(a) * 2.8) * CFrame.Angles(-a, 0, 0),
			{ Color = AMBER, Material = NEON })
		_ = p
	end
	local lw = box("LogoText", 6, y + 1.2, 26.5, 6.05, y + 2.6, 33.5, { Color = DARK })
	sign(lw, "MARS OPERATIONS · ARES BASIN", Enum.NormalId.Right, AMBER)
	-- Plants at the counter ends.
	for _, z in { 23.6, 36.6 } do
		cyl("Planter", 27.5, y, z, 0.9, 1.6, { Color = DARK, Material = SMOOTH })
		ball("Plant", 27.5, y + 2.6, z, 2, { Color = Color3.fromRGB(150, 50, 45), Material = Enum.Material.Grass })
	end
end

-- Launch pods ---------------------------------------------------------------------
type Pod = { name: string, screen: TextLabel, lamp: Part, zone: CFrame, zoneSize: Vector3,
	doors: { { part: Part, open: CFrame, shut: CFrame } }, spawn: CFrame }
local pods: { Pod } = {}

local function buildPod(name: string, x0: number)
	local x1 = x0 + 13
	local cx = (x0 + x1) / 2
	local z0, z1 = 1.4, 15.4
	local hull = { Color = Color3.fromRGB(205, 208, 214), Material = METAL }
	local trimDark = { Color = DARK, Material = METAL }
	local model = Instance.new("Model")
	model.Name = "Pod" .. name
	model.Parent = folder
	local function pb(n, a, b, c, d, e, f, props)
		return box(n, a, b, c, d, e, f, props, model)
	end

	pb("Plinth", x0 - 0.3, 0.1, z0 - 0.3, x1 + 0.3, 0.5, z1 + 0.6, trimDark)
	-- Side, back walls and roof.
	pb("Hull", x0, 0.5, z0, x0 + 0.6, 11, z1, hull)
	pb("Hull", x1 - 0.6, 0.5, z0, x1, 11, z1, hull)
	pb("Hull", x0 + 0.6, 0.5, z0, x1 - 0.6, 11, z0 + 0.6, hull)
	pb("Roof", x0 - 0.2, 11, z0 - 0.2, x1 + 0.2, 11.8, z1 + 0.4, trimDark)
	-- Ribs and roof gear.
	for _, z in { z0 + 3.5, z0 + 7, z0 + 10.5 } do
		pb("Rib", x0 - 0.15, 0.5, z - 0.3, x0, 11, z + 0.3, trimDark)
		pb("Rib", x1, 0.5, z - 0.3, x1 + 0.15, 11, z + 0.3, trimDark)
	end
	pb("Vent", cx - 3, 11.8, z0 + 2, cx + 3, 12.6, z0 + 6, trimDark)
	cyl("Pipe", x0 + 1.5, 11.8, z0 + 9, 0.5, 2.4, trimDark, model)
	cyl("Pipe", x1 - 1.5, 11.8, z0 + 9, 0.5, 2.4, trimDark, model)

	-- Front wall with the doorway (6 wide, 8.5 tall).
	pb("Front", x0 + 0.6, 0.5, z1 - 0.6, cx - 3, 11, z1, hull)
	pb("Front", cx + 3, 0.5, z1 - 0.6, x1 - 0.6, 11, z1, hull)
	pb("Front", cx - 3, 9, z1 - 0.6, cx + 3, 11, z1, hull)
	for _, x in { cx - 3.2, cx + 3 } do
		pb("DoorGlow", x, 0.5, z1 - 0.05, x + 0.2, 9, z1 + 0.05, { Color = ORANGE, Material = NEON, CanCollide = false })
	end
	pb("DoorGlow", cx - 3.2, 9, z1 - 0.05, cx + 3.2, 9.2, z1 + 0.05, { Color = ORANGE, Material = NEON, CanCollide = false })
	-- Hazard stripes on the floor in front.
	for i = 0, 5 do
		pb("Hazard", cx - 3 + i, 0.5, z1, cx - 2.5 + i, 0.52, z1 + 0.6, { Color = Color3.fromRGB(240, 190, 30) })
	end

	-- Sliding doors (open = tucked behind the front wall).
	local doors = {}
	for _, side in { -1, 1 } do
		local shut = cf(cx + side * 1.5, 4.75, z1 - 0.9)
		local open = shut * CFrame.new(side * 3.1, 0, 0)
		local d = B.part(model, "Door", Vector3.new(3, 8.5, 0.3), open, { Color = Color3.fromRGB(170, 175, 182), Material = METAL }) :: Part
		local win = B.part(model, "DoorWindow", Vector3.new(1.2, 2, 0.05), open * CFrame.new(0, 1.8, 0.16),
			{ Color = Color3.fromRGB(140, 200, 230), Material = Enum.Material.Glass, Transparency = 0.4, CanCollide = false }) :: Part
		local weld = Instance.new("WeldConstraint")
		weld.Part0, weld.Part1 = d, win
		weld.Parent = d
		win.Anchored = false
		table.insert(doors, { part = d, open = open, shut = shut })
	end

	-- Interior: four harness seats, floor ring light, ceiling light, rails.
	pb("InnerFloor", x0 + 0.6, 0.5, z0 + 0.6, x1 - 0.6, 0.6, z1 - 0.6, { Color = Color3.fromRGB(60, 64, 72), Material = Enum.Material.DiamondPlate })
	local ring = cyl("FloorRing", cx, 0.6, (z0 + z1) / 2, 2.6, 0.06, { Color = Color3.fromRGB(120, 220, 255), Material = NEON, CanCollide = false }, model)
	glow(ring, Color3.fromRGB(140, 220, 255), 10, 0.5)
	cyl("FloorDisc", cx, 0.6, (z0 + z1) / 2, 2.3, 0.08, { Color = Color3.fromRGB(60, 64, 72), Material = Enum.Material.DiamondPlate, CanCollide = false }, model)
	local seats = {
		{ x0 + 1.4, z0 + 4, 1 }, { x0 + 1.4, z0 + 9, 1 }, { x1 - 1.4, z0 + 4, -1 }, { x1 - 1.4, z0 + 9, -1 },
	}
	for _, s in seats do
		local sx, sz, face = s[1], s[2], s[3]
		pb("SeatBase", sx - 0.8, 0.6, sz - 1, sx + 0.8, 2.4, sz + 1, trimDark)
		pb("SeatCushion", sx - 0.8, 2.4, sz - 1, sx + 0.8, 2.8, sz + 1, { Color = ORANGE, Material = Enum.Material.Fabric })
		pb("SeatBack", sx - face * 0.8 - 0.2, 2.4, sz - 1, sx - face * 0.8 + 0.2, 6.4, sz + 1, { Color = ORANGE, Material = Enum.Material.Fabric })
		pb("Headrest", sx - face * 0.8 - 0.25, 6.4, sz - 0.6, sx - face * 0.8 + 0.25, 7.4, sz + 0.6, trimDark)
		pb("Harness", sx - face * 0.4 - 0.1, 3, sz - 0.6, sx - face * 0.4 + 0.1, 6.2, sz - 0.4, { Color = DARK })
		pb("Harness", sx - face * 0.4 - 0.1, 3, sz + 0.4, sx - face * 0.4 + 0.1, 6.2, sz + 0.6, { Color = DARK })
	end
	pb("GrabRail", cx - 4, 8.4, z0 + 2, cx + 4, 8.6, z0 + 2.2, { Color = STEEL, Material = METAL })
	pb("GrabRail", cx - 4, 8.4, z0 + 11, cx + 4, 8.6, z0 + 11.2, { Color = STEEL, Material = METAL })
	local inner = pb("Lamp", cx - 2, 10.7, z0 + 4, cx + 2, 11, z0 + 10, { Color = Color3.fromRGB(200, 230, 255), Material = NEON, CanCollide = false })
	glow(inner, Color3.fromRGB(210, 235, 255), 14, 0.6, "SurfaceLight")
	local backScreen = pb("InfoScreen", cx - 3, 4, z0 + 0.6, cx + 3, 7, z0 + 0.65, { Color = Color3.fromRGB(20, 30, 40) })
	sign(backScreen, "ORBITAL TRANSFER\nS.S. TOTALITY", Enum.NormalId.Back, Color3.fromRGB(140, 220, 255), Enum.Font.Code)

	-- Outside: status screen over the door, crew sign, status lamp.
	local screenPart = pb("StatusScreen", cx - 3.2, 9.4, z1, cx + 3.2, 10.8, z1 + 0.15, { Color = Color3.fromRGB(16, 20, 26) }) :: Part
	local gui = B.label(screenPart, "", Enum.NormalId.Back, Color3.fromRGB(140, 220, 255), Enum.Font.Code)
	local screen = gui:FindFirstChildOfClass("TextLabel") :: TextLabel
	local plate = pb("PodSign", x0 + 1, 6, z1, x0 + 3.6, 8.2, z1 + 0.1, { Color = DARK })
	sign(plate, `POD {name}`, Enum.NormalId.Back, ORANGE)
	local crew = pb("CrewSign", x1 - 3.6, 6, z1, x1 - 1, 8.2, z1 + 0.1, { Color = DARK })
	sign(crew, "1–4\nCREW", Enum.NormalId.Back, WHITE)
	local lamp = pb("StatusLamp", cx - 0.6, 11.8, z1 - 0.2, cx + 0.6, 12.4, z1 + 0.3, { Color = Color3.fromRGB(80, 255, 120), Material = NEON, CanCollide = false }) :: Part
	glow(lamp, Color3.fromRGB(80, 255, 120), 8, 0.5)
	-- Guide lights on the lobby floor leading to the door.
	for i = 1, 4 do
		local z = z1 + 0.6 + i * 1.3
		pb("Guide", cx - 3.4, 0.1, z, cx - 3.1, 0.14, z + 0.6, { Color = AMBER, Material = NEON, CanCollide = false })
		pb("Guide", cx + 3.1, 0.1, z, cx + 3.4, 0.14, z + 0.6, { Color = AMBER, Material = NEON, CanCollide = false })
	end

	model:SetAttribute("PodName", name)
	model:SetAttribute("ZoneCFrame", cf(cx, 4, (z0 + z1) / 2 - 0.4))
	model:SetAttribute("ZoneSize", Vector3.new(11.6, 8, 12.6))
	for _, d in doors do
		d.part:SetAttribute("OpenCFrame", d.open)
		d.part:SetAttribute("ShutCFrame", d.shut)
	end
	_ = screen
	_ = lamp
end

-- Reads the pods back out of the lobby folder (freshly built or saved in the place).
local function findPods()
	for _, model in folder:GetDescendants() do
		if model:IsA("Model") and model:GetAttribute("PodName") then
			local screenPart = model:FindFirstChild("StatusScreen")
			local gui = screenPart and screenPart:FindFirstChildOfClass("SurfaceGui")
			local screen = gui and gui:FindFirstChildOfClass("TextLabel")
			local lamp = model:FindFirstChild("StatusLamp")
			if not (screen and lamp) then
				warn(`[Totality] Pod {model.Name} is missing its StatusScreen or StatusLamp; it won't launch`)
				continue
			end
			local doors = {}
			for _, d in model:GetChildren() do
				if d:IsA("BasePart") and d:GetAttribute("OpenCFrame") then
					table.insert(doors, { part = d, open = d:GetAttribute("OpenCFrame"), shut = d:GetAttribute("ShutCFrame") })
				end
			end
			table.insert(pods, {
				name = model:GetAttribute("PodName"),
				screen = screen,
				lamp = lamp,
				zone = model:GetAttribute("ZoneCFrame"),
				zoneSize = model:GetAttribute("ZoneSize"),
				doors = doors,
				spawn = CFrame.identity,
			})
		end
	end
	table.sort(pods, function(a, b)
		return a.name < b.name
	end)
end

-- Stairs, landing, walkway, balustrades ---------------------------------------------
local function railing(ax: number, az: number, bx: number, bz: number, y: number)
	local len = (Vector2.new(bx, bz) - Vector2.new(ax, az)).Magnitude
	seg("RailGlass", ax, az, bx, bz, y + 0.2, y + 3.4, 0.12, 0, { Color = GLASS, Material = Enum.Material.Glass, Transparency = 0.65 })
	seg("Rail", ax, az, bx, bz, y + 3.4, y + 3.65, 0.3, 0, { Color = STEEL, Material = METAL })
	seg("RailBase", ax, az, bx, bz, y, y + 0.2, 0.3, 0, { Color = DARK, Material = METAL })
	local n = math.max(1, math.round(len / 4))
	for i = 0, n do
		local t = i / n
		local x, z = ax + (bx - ax) * t, az + (bz - az) * t
		box("RailPost", x - 0.12, y, z - 0.12, x + 0.12, y + 3.4, z + 0.12, { Color = STEEL, Material = METAL })
	end
end

local function buildStairs()
	local stepProps = { Color = Color3.fromRGB(80, 84, 92), Material = Enum.Material.DiamondPlate }
	-- Flight 1: x 80 -> 92 along z 17..22, rising 0 -> 7 (solid underneath).
	local run = 12 / 14
	for i = 1, 14 do
		local xa, xb = 80 + (i - 1) * run, 80 + i * run
		box("Step", xa, 0.1, 17, xb, i * 0.5, 22, stepProps)
		box("Nosing", xa, i * 0.5, 17, xa + 0.12, i * 0.5 + 0.03, 22, { Color = AMBER, Material = NEON, CanCollide = false })
	end
	-- Mid landing at y 7 on a column.
	box("Landing", 92, 6.4, 11, 97.4, 7, 22, stepProps)
	box("LandingColumn", 94, 0.1, 15.5, 95, 6.4, 16.5, { Color = DARK, Material = METAL })
	-- Flight 2: x 92 -> 80 along z 11..16, rising 7 -> 14 (open treads on stringers).
	for j = 1, 14 do
		local xa, xb = 92 - j * run, 92 - (j - 1) * run
		box("Tread", xa, 6.6 + j * 0.5, 11, xb, 7 + j * 0.5, 16, stepProps)
		box("Nosing", xb - 0.12, 7 + j * 0.5, 11, xb, 7.03 + j * 0.5, 16, { Color = AMBER, Material = NEON, CanCollide = false })
	end
	for _, z in { 11, 15.7 } do
		local s = B.part(folder, "Stringer", Vector3.new(14.2, 0.8, 0.3),
			cf(86, 10.3, z + 0.15) * CFrame.Angles(0, 0, math.atan2(-7, 12)), { Color = DARK, Material = METAL })
		_ = s
	end
	-- Railings: outer side of flight 1, divider between flights, landing edge.
	local p1 = B.part(folder, "Rail", Vector3.new(14, 0.25, 0.3), cf(86, 7.1, 22.1) * CFrame.Angles(0, 0, math.atan2(7, 12)), { Color = STEEL, Material = METAL })
	_ = p1
	for i = 0, 3 do
		local x = 80.5 + i * 3.8
		local top = (x - 80) / run * 0.5
		box("RailPost", x - 0.12, top, 21.9, x + 0.12, top + 3.6, 22.2, { Color = STEEL, Material = METAL })
	end
	local p2 = B.part(folder, "Rail", Vector3.new(14, 0.25, 0.3), cf(86, 7.1, 16.9) * CFrame.Angles(0, 0, math.atan2(7, 12)), { Color = STEEL, Material = METAL })
	_ = p2
	for i = 0, 3 do
		local x = 80.5 + i * 3.8
		local top = (x - 80) / run * 0.5
		box("RailPost", x - 0.12, top, 16.8, x + 0.12, top + 3.6, 17.1, { Color = STEEL, Material = METAL })
	end
	railing(97.4, 22, 92, 22, 7)
end

local function buildFloor2()
	local slab = { Color = Color3.fromRGB(196, 190, 182), Material = Enum.Material.Marble }
	local under = { Color = PANEL, Material = SMOOTH }
	local function slabBox(x0, z0, x1, z1)
		box("Slab", x0, H1 - 1, z0, x1, H1, z1, slab)
	end
	-- Office floor, and a beam under the office wall where it overhangs the atrium.
	slabBox(0, 0, 29, 38.6)
	box("Beam", 29, H1 - 1, 0, 29.6, H1, 30, { Color = DARK, Material = METAL })
	-- Stair landing (with the hole over flight 2) and its corner along the diagonal glass.
	slabBox(76, 0, 80, 17)
	slabBox(80, 0, 82, 11)
	slabBox(82, 3, 86, 11)
	slabBox(86, 6, 90, 11)
	slabBox(90, 8, 92, 11)
	slabBox(92, 9.5, 95, 11)
	slabBox(92, 11, 98, 17)
	local strip = seg("Slab", 82, 0, 98, 11, H1 - 1.02, H1 - 0.02, 4, 2, slab)
	_ = strip
	_ = under

	-- Grate walkway: every 1-stud row of the walkway area gets an invisible
	-- collision strip plus a thin visible slat; cross bars run the other way.
	local function walkway(x: number, z: number): boolean
		if not inside(OUTLINE, x, z) or inside(VOID, x, z) then
			return false
		end
		if x < 29 and z < 38.6 then
			return false -- office
		end
		if x >= 76 and z < 17 then
			return false -- landing
		end
		return true
	end
	local grate = { Color = Color3.fromRGB(110, 114, 122), Material = METAL }
	local function runs(fixed: number, alongX: boolean, from: number, to: number): { { number } }
		local list, start = {}, nil
		for u = from, to, 0.5 do
			local ok = if alongX then walkway(u, fixed) else walkway(fixed, u)
			if ok and not start then
				start = u - 0.25
			elseif not ok and start then
				table.insert(list, { start, u - 0.25 })
				start = nil
			end
		end
		if start then
			table.insert(list, { start, to + 0.25 })
		end
		return list
	end
	for z = 0.5, 49.5, 1 do
		for _, r in runs(z, true, 0.25, 97.75) do
			box("WalkFloor", r[1], H1 - 0.2, z - 0.5, r[2], H1, z + 0.5, { Transparency = 1, CanCollide = true })
			box("Grate", r[1], H1 - 0.12, z - 0.12, r[2], H1, z + 0.12, grate)
		end
	end
	for x = 1, 97, 2 do
		for _, r in runs(x, false, 0.25, 49.75) do
			box("GrateBar", x - 0.1, H1 - 0.35, r[1], x + 0.1, H1 - 0.12, r[2], grate)
		end
	end
	-- Edge beams under the walkway, along the atrium edge, on columns.
	local edges = {
		{ 29, 30, 39, 39.4 }, { 39, 39.4, 76, 39.4 }, { 76, 39.4, 85, 31 }, { 85, 31, 85, 17 },
	}
	for _, e in edges do
		seg("Beam", e[1], e[2], e[3], e[4], H1 - 1.4, H1 - 0.35, 0.6, -0.3, { Color = DARK, Material = METAL })
		local lit = seg("BeamLight", e[1], e[2], e[3], e[4], H1 - 1.5, H1 - 1.4, 0.3, -0.3, { Color = COOL, Material = NEON, CanCollide = false })
		glow(lit, COOL, 12, 0.5, "SurfaceLight")
	end
	for _, p in { v(39, 39.4), v(57.5, 39.4), v(76, 39.4), v(85, 31), v(85, 23.5), v(29, 30) } do
		box("Column", p.X - 0.45, 0.1, p.Y - 0.45, p.X + 0.45, H1 - 1.4, p.Y + 0.45, { Color = DARK, Material = METAL })
	end

	-- Balustrades around the atrium on floor 2.
	railing(29.6, 30.6, 39, 39.4, H1)
	railing(39, 39.4, 76, 39.4, H1)
	railing(76, 39.4, 85, 31, H1)
	railing(85, 31, 85, 17, H1)
	railing(76, 17, 80, 17, H1)
	railing(76, 0.7, 76, 17, H1)
	railing(80, 11, 92, 11, H1)
	railing(92, 11, 92, 17, H1)
	railing(85, 17, 92, 17, H1)
end

-- Peri's office -------------------------------------------------------------------
local function office()
	local y = H1
	local ceil = H2 - 2
	-- East wall: big window over the atrium, door at the south end.
	box("Wall", 29, y, 0, 29.6, y + 1.5, 31, { Color = WHITE, Material = SMOOTH })
	box("Wall", 29, ceil - 0.5, 0, 29.6, H2, 31, { Color = WHITE, Material = SMOOTH })
	box("Glass", 29.2, y + 1.5, 0, 29.4, ceil - 0.5, 31, { Color = GLASS, Material = Enum.Material.Glass, Transparency = 0.7 })
	for z = 0.5, 31, 5 do
		box("Mullion", 29, y + 1.5, z - 0.2, 29.6, ceil - 0.5, z + 0.2, { Color = DARK, Material = METAL })
	end
	box("Wall", 29, y, 31, 29.6, H2, 33, { Color = WHITE, Material = SMOOTH })
	box("Wall", 29, y + 8, 33, 29.6, H2, 37, { Color = WHITE, Material = SMOOTH })
	box("Wall", 29, y, 37, 29.6, H2, 38.6, { Color = WHITE, Material = SMOOTH })
	box("DoorFrame", 28.9, y, 32.8, 29.7, y + 8.2, 33, { Color = ORANGE })
	box("DoorFrame", 28.9, y, 37, 29.7, y + 8.2, 37.2, { Color = ORANGE })
	box("DoorFrame", 28.9, y + 8, 33, 29.7, y + 8.2, 37, { Color = ORANGE })
	local plate = box("DoorPlate", 29.6, y + 5, 37.4, 29.65, y + 6.4, 38.4, { Color = DARK })
	sign(plate, "PERI", Enum.NormalId.Right, AMBER)
	-- Drop ceiling, floor and rug.
	box("Ceiling", 0, ceil, 0, 29, ceil + 0.2, 38.6, { Color = PANEL, Material = SMOOTH })
	box("Carpet", 0, y, 0, 29, y + 0.05, 38.6, { Color = Color3.fromRGB(70, 60, 64), Material = Enum.Material.Carpet })
	box("Rug", 9, y + 0.05, 9, 26, y + 0.08, 23, { Color = Color3.fromRGB(120, 60, 50), Material = Enum.Material.Fabric })
	for _, p in { { 8, 10 }, { 20, 10 }, { 8, 26 }, { 20, 26 } } do
		panel(p[1], ceil, p[2], WARM, Vector3.new(4, 0.3, 4), 16)
	end

	-- Desk with its back to the atrium window.
	local wood = { Color = WOOD, Material = Enum.Material.Wood }
	box("DeskTop", 19, y + 2.8, 11, 24, y + 3.1, 21, wood)
	box("DeskSide", 19.2, y, 11.2, 23.8, y + 2.8, 11.8, wood)
	box("DeskSide", 19.2, y, 20.2, 23.8, y + 2.8, 20.8, wood)
	box("DeskFront", 19, y + 0.4, 11.8, 19.4, y + 2.8, 20.2, wood)
	for i, z in { 13.2, 16, 18.8 } do
		box("Monitor", 22.6, y + 3.6, z - 1.2, 22.8, y + 5.3, z + 1.2, { Color = DARK })
		box("Screen", 22.55, y + 3.7, z - 1.1, 22.6, y + 5.2, z + 1.1, { Color = if i == 2 then Color3.fromRGB(255, 160, 80) else Color3.fromRGB(90, 160, 220), Material = NEON })
		box("MonitorStand", 22.7, y + 3.1, z - 0.2, 22.9, y + 3.6, z + 0.2, { Color = DARK })
	end
	box("Keyboard", 21.2, y + 3.1, 15, 21.8, y + 3.2, 17, { Color = DARK })
	-- The photo on the desk.
	local frame = box("PhotoFrame", 20.2, y + 3.1, 19.2, 20.4, y + 4.1, 20.2, { Color = Color3.fromRGB(200, 170, 110), Material = METAL })
	local photo = box("Photo", 20.15, y + 3.2, 19.3, 20.2, y + 4, 20.1, { Color = Color3.fromRGB(230, 220, 235) })
	sign(photo, "A + P", Enum.NormalId.Left, Color3.fromRGB(150, 90, 170))
	_ = frame
	local lamp = box("Lamp", 20, y + 4.2, 12, 20.8, y + 4.5, 12.8, { Color = WARM, Material = NEON })
	box("LampStem", 20.3, y + 3.1, 12.3, 20.5, y + 4.2, 12.5, { Color = STEEL, Material = METAL })
	glow(lamp, WARM, 10, 0.6)
	-- Chair behind the desk, visitor chairs in front.
	box("ChairSeat", 24.6, y + 1.8, 15, 26.6, y + 2.2, 17, { Color = Color3.fromRGB(30, 30, 34) })
	box("ChairBack", 26.6, y + 2.2, 15, 27, y + 5.4, 17, { Color = Color3.fromRGB(30, 30, 34) })
	box("ChairPost", 25.45, y, 15.85, 25.75, y + 1.8, 16.15, { Color = STEEL, Material = METAL })
	for _, z in { 13, 19 } do
		box("ChairSeat", 15, y + 1.6, z - 1, 17, y + 2, z + 1, { Color = FABRIC })
		box("ChairBack", 14.6, y + 2, z - 1, 15, y + 4.4, z + 1, { Color = FABRIC })
		for _, dx in { 15.2, 16.6 } do
			for _, dz in { z - 0.8, z + 0.6 } do
				box("ChairLeg", dx, y, dz, dx + 0.2, y + 1.6, dz + 0.2, { Color = STEEL, Material = METAL })
			end
		end
	end

	-- Bookshelf along the north wall.
	box("Shelf", 3, y, 0, 18, y + 8, 1.6, wood)
	local bookColors = { Color3.fromRGB(150, 50, 40), Color3.fromRGB(40, 70, 120), Color3.fromRGB(200, 170, 90),
		Color3.fromRGB(50, 100, 70), Color3.fromRGB(90, 60, 110), Color3.fromRGB(220, 220, 210) }
	local rng = Random.new(7)
	for shelf = 0, 3 do
		local sy = y + 0.6 + shelf * 1.9
		box("ShelfBoard", 3, sy - 0.15, 1.6, 18, sy, 1.7, wood)
		local x = 3.4
		while x < 17.2 do
			local w = rng:NextNumber(0.25, 0.5)
			local h = rng:NextNumber(1.1, 1.6)
			box("Book", x, sy, 1.62, x + w, sy + h, 2.6, { Color = bookColors[rng:NextInteger(1, #bookColors)] })
			x += w + 0.03
		end
	end
	-- Lounge corner: couch, coffee table, plant.
	box("Couch", 1, y, 24, 3.5, y + 1.8, 34, { Color = Color3.fromRGB(150, 135, 120), Material = Enum.Material.Fabric })
	box("CouchBack", 0.4, y, 24, 1.2, y + 4, 34, { Color = Color3.fromRGB(150, 135, 120), Material = Enum.Material.Fabric })
	box("CouchArm", 1, y, 23.4, 3.5, y + 2.8, 24, { Color = Color3.fromRGB(140, 125, 110), Material = Enum.Material.Fabric })
	box("CouchArm", 1, y, 34, 3.5, y + 2.8, 34.6, { Color = Color3.fromRGB(140, 125, 110), Material = Enum.Material.Fabric })
	box("CoffeeTable", 5.5, y + 1.3, 26.5, 9, y + 1.5, 31.5, { Color = Color3.fromRGB(40, 42, 48), Material = Enum.Material.Glass, Transparency = 0.2 })
	for _, p in { { 5.7, 26.7 }, { 8.6, 26.7 }, { 5.7, 31.1 }, { 8.6, 31.1 } } do
		box("TableLeg", p[1], y, p[2], p[1] + 0.2, y + 1.3, p[2] + 0.2, { Color = STEEL, Material = METAL })
	end
	cyl("Planter", 2.5, y, 37, 0.9, 1.8, { Color = DARK })
	ball("Plant", 2.5, y + 3, 37, 2.4, { Color = Color3.fromRGB(70, 120, 60), Material = Enum.Material.Grass })
	cyl("Planter", 27.5, y, 2, 0.8, 1.6, { Color = DARK })
	ball("Plant", 27.5, y + 2.6, 2, 2, { Color = Color3.fromRGB(70, 120, 60), Material = Enum.Material.Grass })

	-- Display case with a model of the S.S. Totality.
	box("Pedestal", 10, y, 33, 13, y + 3.4, 36, { Color = WHITE, Material = SMOOTH })
	box("Case", 10.1, y + 3.4, 33.1, 12.9, y + 6.2, 35.9, { Color = GLASS, Material = Enum.Material.Glass, Transparency = 0.8 })
	box("ShipHull", 10.6, y + 4.4, 34.2, 12.4, y + 4.9, 34.8, { Color = Color3.fromRGB(220, 222, 228), Material = METAL })
	box("ShipRing", 11.3, y + 4, 33.7, 11.5, y + 5.3, 35.3, { Color = STEEL, Material = METAL })
	box("ShipSail", 10.4, y + 4.62, 33.4, 10.6, y + 4.68, 35.6, { Color = Color3.fromRGB(230, 170, 60), Material = METAL })
	local tag = box("CaseTag", 10.5, y + 2.4, 36, 12.5, y + 3, 36.05, { Color = DARK })
	sign(tag, "S.S. TOTALITY · 1:400", Enum.NormalId.Back, AMBER)

	-- Filing cabinets and wall art.
	for i = 0, 1 do
		box("Cabinet", 22 + i * 2.2, y, 0, 24 + i * 2.2, y + 4.4, 1.8, { Color = STEEL, Material = METAL })
		for d = 0, 2 do
			box("Drawer", 22.2 + i * 2.2, y + 0.4 + d * 1.4, 1.8, 23.8 + i * 2.2, y + 1.6 + d * 1.4, 1.85, { Color = Color3.fromRGB(120, 124, 130), Material = METAL })
		end
	end
	local art = box("Painting", 10, y + 4, 38.4, 20, y + 9, 38.6, { Color = Color3.fromRGB(190, 100, 60) })
	sign(art, "SOLSTICE SOLUTIONS\nreach for the sun", Enum.NormalId.Front, Color3.fromRGB(255, 230, 200), Enum.Font.Garamond)
end

-- Atrium centrepiece and lobby furniture --------------------------------------------
local function atrium()
	local cx, cz = 57, 26
	-- Floor inlay rings under the orrery.
	for i, r in { 9, 7.6, 4.8 } do
		cyl("InlayRing", cx, 0.1, cz, r, 0.02 + i * 0.01, { Color = if i == 2 then FLOOR else (if i == 1 then INLAY else ORANGE), CanCollide = false })
	end
	-- Round bench around a planter of Martian greenhouse plants.
	for i = 0, 15 do
		local a = i * math.pi / 8
		local p = B.part(folder, "Bench", Vector3.new(1.4, 1.6, 2.1),
			cf(cx + math.cos(a) * 4.2, 0.9, cz + math.sin(a) * 4.2) * CFrame.Angles(0, -a, 0),
			{ Color = WOOD, Material = Enum.Material.Wood })
		_ = p
	end
	cyl("BenchCore", cx, 0.1, cz, 3.5, 2.2, { Color = WHITE, Material = SMOOTH })
	cyl("Soil", cx, 2.3, cz, 3.2, 0.1, { Color = Color3.fromRGB(90, 50, 35), Material = Enum.Material.Ground })
	local rng = Random.new(3)
	for _ = 1, 9 do
		local a, r = rng:NextNumber(0, math.pi * 2), rng:NextNumber(0, 2.2)
		ball("Plant", cx + math.cos(a) * r, 3 + rng:NextNumber(0, 1.2), cz + math.sin(a) * r, rng:NextNumber(1.4, 2.4),
			{ Color = Color3.fromRGB(rng:NextInteger(120, 170), rng:NextInteger(40, 60), 45), Material = Enum.Material.Grass })
	end

	-- The orrery: a glowing sun with rings and planets, hung from the skylight.
	local orrery = Instance.new("Model")
	orrery.Name = "Orrery"
	orrery.Parent = folder
	local sy = 19
	box("Cable", cx - 0.06, sy + 2.4, cz - 0.06, cx + 0.06, H2, cz + 0.06, { Color = DARK, CanCollide = false })
	local sun = ball("Sun", cx, sy, cz, 4.4, { Color = Color3.fromRGB(255, 150, 50), Material = NEON, CanCollide = false }, orrery) :: Part
	glow(sun, Color3.fromRGB(255, 170, 90), 40, 1.2)
	orrery.PrimaryPart = sun
	local planets = {
		{ 4.5, 0.7, Color3.fromRGB(170, 160, 150) }, { 6.5, 1, Color3.fromRGB(230, 200, 140) },
		{ 8.5, 1.1, Color3.fromRGB(80, 130, 200) }, { 10.5, 0.9, Color3.fromRGB(200, 90, 50) },
		{ 12, 1.8, Color3.fromRGB(210, 170, 120) },
	}
	for i, p in planets do
		local a = i * 1.3
		-- Thin ring for the orbit, an arm, and the planet.
		for k = 0, 23 do
			local t = k * math.pi / 12
			B.part(orrery, "Orbit", Vector3.new(0.08, 0.08, p[1] * math.pi / 12 + 0.05),
				cf(cx + math.cos(t) * p[1], sy, cz + math.sin(t) * p[1]) * CFrame.Angles(0, -t, 0),
				{ Color = Color3.fromRGB(200, 170, 120), Material = METAL, CanCollide = false })
		end
		B.part(orrery, "Arm", Vector3.new(p[1], 0.12, 0.12),
			cf(cx + math.cos(a) * p[1] / 2, sy, cz + math.sin(a) * p[1] / 2) * CFrame.Angles(0, -a, 0),
			{ Color = STEEL, Material = METAL, CanCollide = false })
		ball("Planet", cx + math.cos(a) * p[1], sy, cz + math.sin(a) * p[1], p[2], { Color = p[3], CanCollide = false }, orrery)
	end
	-- The client turns models with a Spin attribute (degrees per second).
	orrery:SetAttribute("Spin", 6)
	-- Hide the planet arms from collisions etc.
	for _, d in orrery:GetDescendants() do
		if d:IsA("BasePart") then
			d.CanQuery = false
		end
	end

	-- Departure board on the back wall above the pods.
	box("Board", 34, 16, 0, 74, 17.2, 0.4, { Color = DARK })
	local board = box("BoardScreen", 34.5, 12.4, 0, 73.5, 16, 0.35, { Color = Color3.fromRGB(14, 18, 24) })
	sign(board, "EXPEDITION DEPARTURES  ·  S.S. TOTALITY RESEARCH RECOVERY  ·  BOARD A POD TO BEGIN", Enum.NormalId.Back, AMBER, Enum.Font.Code)
	_ = board

	-- Lounge seating along the windows.
	local function sofa(x: number, z: number, facing: number)
		local model = Instance.new("Model")
		model.Name = "Sofa"
		model.Parent = folder
		local base = cf(x, 0, z) * CFrame.Angles(0, facing, 0)
		local fabric = { Color = FABRIC, Material = Enum.Material.Fabric }
		B.part(model, "Seat", Vector3.new(7, 1.6, 2.6), base * CFrame.new(0, 0.9, 0), fabric)
		B.part(model, "Back", Vector3.new(7, 2.6, 0.8), base * CFrame.new(0, 2, 1.6), fabric)
		B.part(model, "Arm", Vector3.new(0.8, 2.4, 3.4), base * CFrame.new(-3.9, 1.3, 0.4), fabric)
		B.part(model, "Arm", Vector3.new(0.8, 2.4, 3.4), base * CFrame.new(3.9, 1.3, 0.4), fabric)
		B.part(model, "Cushion", Vector3.new(3.2, 0.3, 2.2), base * CFrame.new(-1.7, 1.85, -0.1), { Color = Color3.fromRGB(80, 88, 104), Material = Enum.Material.Fabric })
		B.part(model, "Cushion", Vector3.new(3.2, 0.3, 2.2), base * CFrame.new(1.7, 1.85, -0.1), { Color = Color3.fromRGB(80, 88, 104), Material = Enum.Material.Fabric })
	end
	-- Facing the south windows (players look out at Mars).
	sofa(46, 44, math.pi)
	sofa(60, 44, math.pi)
	sofa(72, 43, math.pi)
	-- Facing the east windows.
	sofa(92, 28, -math.pi / 2)
	for _, t in { { 46, 47.3 }, { 60, 47.3 } } do
		box("LowTable", t[1] - 2, 1, t[2] - 1, t[1] + 2, 1.2, t[2] + 1, { Color = Color3.fromRGB(40, 42, 48), Material = Enum.Material.Granite })
		box("TableBase", t[1] - 0.4, 0.1, t[2] - 0.4, t[1] + 0.4, 1, t[2] + 0.4, { Color = STEEL, Material = METAL })
	end
	-- Planters between the seating groups.
	for _, p in { { 53, 46 }, { 67, 46 }, { 40, 45 }, { 90, 36 }, { 94, 20 } } do
		cyl("Planter", p[1], 0.1, p[2], 1.1, 2, { Color = WHITE, Material = SMOOTH })
		ball("Plant", p[1], 3.6, p[2], 2.8, { Color = Color3.fromRGB(150, 55, 45), Material = Enum.Material.Grass })
	end

	-- Info kiosks.
	for _, k in { { 36, 28, 0.6 }, { 76, 30, -0.6 } } do
		local base = cf(k[1], 0, k[2]) * CFrame.Angles(0, k[3], 0)
		B.part(folder, "Kiosk", Vector3.new(1.6, 4, 1.2), base * CFrame.new(0, 2.1, 0), { Color = WHITE, Material = SMOOTH })
		local scr = B.part(folder, "KioskScreen", Vector3.new(1.4, 1.8, 0.1), base * CFrame.new(0, 3.3, 0.62) * CFrame.Angles(math.rad(-15), 0, 0),
			{ Color = Color3.fromRGB(20, 30, 40) }) :: Part
		sign(scr, "WELCOME TO\nARES BASIN\n\nLocal time 16:40\nDust: LOW\nSurface: −63°C", Enum.NormalId.Back, Color3.fromRGB(140, 220, 255), Enum.Font.Code)
		B.part(folder, "KioskStripe", Vector3.new(1.62, 0.2, 1.22), base * CFrame.new(0, 0.6, 0), { Color = ORANGE, Material = NEON })
	end

	-- Coffee cart under the east walkway.
	box("Cart", 80, 0.1, 40, 85, 3.4, 42.4, { Color = WHITE, Material = SMOOTH })
	box("CartTop", 79.8, 3.4, 39.8, 85.2, 3.6, 42.6, { Color = Color3.fromRGB(40, 42, 48), Material = Enum.Material.Granite })
	box("CoffeeMachine", 81, 3.6, 41, 83, 5.8, 42.4, { Color = DARK, Material = METAL })
	local cup = cyl("Cup", 83.8, 3.6, 40.6, 0.25, 0.6, { Color = WHITE })
	_ = cup
	local cs = box("CartSign", 80.4, 1.2, 39.95, 84.6, 2.6, 40, { Color = DARK })
	sign(cs, "RED DUST ROAST", Enum.NormalId.Front, AMBER)

	-- Pendant lights hanging into the atrium.
	for _, p in { { 38, 8 }, { 48, 5 }, { 66, 5 }, { 74, 9 }, { 40, 33 }, { 74, 34 }, { 47, 38 }, { 67, 38 } } do
		box("PendantCable", p[1] - 0.04, 18, p[2] - 0.04, p[1] + 0.04, H2, p[2] + 0.04, { Color = DARK, CanCollide = false })
		cyl("PendantShade", p[1], 17, p[2], 1.2, 1, { Color = DARK, Material = METAL, CanCollide = false })
		local bulb = ball("Lamp", p[1], 16.9, p[2], 0.9, { Color = WARM, Material = NEON, CanCollide = false })
		glow(bulb, WARM, 22, 0.7)
	end
	-- Lights under the walkways and landing.
	for _, p in { { 45, 45 }, { 58, 45 }, { 71, 45 }, { 92, 26 }, { 92, 38 }, { 88, 33 } } do
		panel(p[1], H1 - 0.35, p[2], WARM, Vector3.new(4, 0.3, 1.6), 16)
	end
	panel(79, H1 - 1, 6, WARM, Vector3.new(4, 0.3, 1.6), 16)
	-- Floor 2 walkway lights on the ceiling.
	for _, p in { { 34, 44 }, { 50, 46 }, { 66, 46 }, { 82, 42 }, { 92, 24 }, { 88, 8 } } do
		panel(p[1], H2, p[2], COOL, Vector3.new(4, 0.3, 1.6), 16)
	end
end

-- Martian landscape ----------------------------------------------------------------
local function landscape()
	local terrain = workspace.Terrain
	terrain:SetMaterialColor(Enum.Material.Sand, SAND)
	terrain:SetMaterialColor(Enum.Material.Sandstone, Color3.fromRGB(150, 72, 46))
	terrain:SetMaterialColor(Enum.Material.Rock, Color3.fromRGB(112, 58, 42))
	terrain:SetMaterialColor(Enum.Material.Basalt, Color3.fromRGB(72, 42, 36))
	terrain:SetMaterialColor(Enum.Material.Ground, Color3.fromRGB(160, 84, 54))

	local centre = pos(49, 0, 25)
	-- Flat ground, its top just under the foundation pad.
	terrain:FillBlock(CFrame.new(centre - Vector3.new(0, 6, 0)), Vector3.new(2400, 12, 2400), Enum.Material.Sand)
	local rng = Random.new(42)
	local function around(minR: number, maxR: number): Vector3
		local a = rng:NextNumber(0, math.pi * 2)
		local r = rng:NextNumber(minR, maxR)
		return centre + Vector3.new(math.cos(a) * r, 0, math.sin(a) * r)
	end
	-- Rolling dunes nearby.
	for _ = 1, 40 do
		local p = around(120, 600)
		local r = rng:NextNumber(30, 90)
		terrain:FillBall(p - Vector3.new(0, r * 0.75, 0), r, Enum.Material.Sand)
	end
	-- Ground patches for colour variation.
	for _ = 1, 30 do
		local p = around(130, 500)
		terrain:FillBlock(CFrame.new(p - Vector3.new(0, 2.5, 0)) * CFrame.Angles(0, rng:NextNumber(0, 6), 0),
			Vector3.new(rng:NextNumber(30, 80), 4, rng:NextNumber(30, 80)), Enum.Material.Ground)
	end
	-- Distant mesas and buttes.
	for _ = 1, 16 do
		local p = around(500, 1000)
		local h = rng:NextNumber(60, 180)
		local r = rng:NextNumber(50, 160)
		terrain:FillCylinder(CFrame.new(p + Vector3.new(0, h / 2 - 6, 0)), h, r, Enum.Material.Sandstone)
		terrain:FillCylinder(CFrame.new(p + Vector3.new(0, h - 6, 0)), 8, r * 0.85, Enum.Material.Rock)
		terrain:FillBall(p - Vector3.new(0, r * 0.3, 0), r * 1.2, Enum.Material.Sand)
	end
	-- Rocks and boulders.
	for _ = 1, 140 do
		local p = around(60, 420)
		local r = rng:NextNumber(1.5, 7)
		terrain:FillBall(p, r, if rng:NextNumber() < 0.5 then Enum.Material.Basalt else Enum.Material.Rock)
	end
	-- A crater to the south-west.
	local crater = centre + Vector3.new(-220, 0, 260)
	terrain:FillBall(crater, 70, Enum.Material.Air)
	for k = 0, 23 do
		local a = k * math.pi / 12
		terrain:FillBall(crater + Vector3.new(math.cos(a) * 72, -8, math.sin(a) * 72), 18, Enum.Material.Sandstone)
	end
	terrain:FillBlock(CFrame.new(crater - Vector3.new(0, 30, 0)), Vector3.new(150, 8, 150), Enum.Material.Sand)

	-- Keep the building and its surroundings clear of terrain (nothing may
	-- poke up through the floor or walls).
	terrain:FillBlock(CFrame.new(pos(49, 40, 25)), Vector3.new(124, 80, 80), Enum.Material.Air)

end

-- Base structures outside: solar array, comms mast, rover, cargo, a dome.
local function outsideStructures()
	local outside = Instance.new("Folder")
	outside.Name = "Outside"
	outside.Parent = folder
	local function ob(n, a, b, c, d, e, f, props)
		return box(n, a, b, c, d, e, f, props, outside)
	end
	-- Solar panel field south of the windows.
	for row = 0, 3 do
		for col = 0, 6 do
			local x, z = 30 + col * 9, 70 + row * 9
			ob("PanelPost", x - 0.2, 0, z - 0.2, x + 0.2, 3, z + 0.2, { Color = STEEL, Material = METAL })
			local panelPart = B.part(outside, "SolarPanel", Vector3.new(8, 0.2, 4.5), cf(x, 3.4, z) * CFrame.Angles(math.rad(-30), 0, 0),
				{ Color = Color3.fromRGB(30, 40, 70), Material = Enum.Material.Glass, Reflectance = 0.3 })
			_ = panelPart
		end
	end
	-- Comms mast with a blinking beacon.
	ob("Mast", 120, 0, -20, 121, 70, -19, { Color = Color3.fromRGB(200, 200, 205), Material = METAL })
	for h = 10, 60, 10 do
		ob("MastBrace", 118, h, -20.5, 123, h + 0.4, -18.5, { Color = Color3.fromRGB(200, 200, 205), Material = METAL })
	end
	local dish = cyl("Dish", 120.5, 55, -16, 4, 0.6, { Color = WHITE, Material = METAL }, outside)
	if dish then
		dish.CFrame = cf(120.5, 56, -16) * CFrame.Angles(math.rad(40), 0, math.rad(90))
	end
	local beacon = ball("Led", 120.5, 71, -19.5, 1.4, { Color = Color3.fromRGB(255, 40, 30), Material = NEON }, outside)
	glow(beacon, Color3.fromRGB(255, 40, 30), 30, 1)
	-- Rover parked by the airlock.
	local rx, rz = -18, 12
	ob("RoverBody", rx - 4, 2.2, rz - 7, rx + 4, 5.4, rz + 7, { Color = WHITE, Material = METAL })
	ob("RoverCab", rx - 3.5, 5.4, rz - 6.5, rx + 3.5, 7.6, rz - 1, { Color = WHITE, Material = METAL })
	ob("RoverWindow", rx - 3.4, 5.8, rz - 6.6, rx + 3.4, 7.2, rz - 6.5, { Color = Color3.fromRGB(230, 150, 40), Material = Enum.Material.Glass, Reflectance = 0.3 })
	ob("RoverStripe", rx - 4.05, 3.6, rz - 7, rx + 4.05, 4, rz + 7, { Color = ORANGE })
	for _, wz in { rz - 5, rz, rz + 5 } do
		for _, side in { -1, 1 } do
			local w = cyl("Wheel", rx + side * 4.6, 0, wz, 1.8, 1.2, { Color = Color3.fromRGB(40, 40, 44) }, outside)
			if w then
				w.CFrame = cf(rx + side * 4.6, 1.8, wz)
			end
		end
	end
	-- Cargo containers.
	for i, c in { { 112, 30, 0 }, { 112, 40, 0.2 }, { 118, 34, -0.1 } } do
		local col = if i == 2 then ORANGE else Color3.fromRGB(80, 90, 110)
		local p = B.part(outside, "Container", Vector3.new(6, 6, 12), cf(c[1], 3, c[2]) * CFrame.Angles(0, c[3], 0),
			{ Color = col, Material = Enum.Material.CorrodedMetal })
		_ = p
	end
	-- Habitat dome in the distance with a light inside.
	local dome = ball("Dome", -120, -6, -110, 60, { Color = Color3.fromRGB(230, 200, 180), Material = Enum.Material.Glass, Transparency = 0.4 }, outside)
	glow(dome, WARM, 40, 0.8)
	cyl("DomeRing", -120, -0.5, -110, 30.5, 1.2, { Color = Color3.fromRGB(190, 190, 195), Material = METAL }, outside)
	-- Pipeline from the lobby to the dome.
	local pipeA, pipeB = pos(0, 1.4, 20), pos(-90, 1.4, -90)
	local pipe = Instance.new("Part")
	pipe.Name = "Pipeline"
	pipe.Anchored = true
	pipe.Shape = Enum.PartType.Cylinder
	pipe.Size = Vector3.new((pipeB - pipeA).Magnitude, 1.6, 1.6)
	pipe.CFrame = CFrame.lookAt((pipeA + pipeB) / 2, pipeB) * CFrame.Angles(0, math.rad(90), 0)
	pipe.Color = Color3.fromRGB(170, 170, 175)
	pipe.Material = METAL
	pipe.Parent = outside
end

-- Pod logic -------------------------------------------------------------------------
local COUNTDOWN = 10
local RUN_LOCK_TEXT = "EXPEDITION\nUNDERWAY"

local function setDoors(pod: Pod, open: boolean)
	for _, d in pod.doors do
		TweenService:Create(d.part, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{ CFrame = if open then d.open else d.shut }):Play()
	end
end

local function playersIn(pod: Pod): { Player }
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { folder }
	local found, list = {}, {}
	for _, p in workspace:GetPartBoundsInBox(pod.zone, pod.zoneSize, params) do
		local player = Players:GetPlayerFromCharacter(p.Parent)
		if player and not found[player] then
			local humanoid = p.Parent:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				found[player] = true
				table.insert(list, player)
			end
		end
	end
	return list
end

local function runPod(pod: Pod)
	local lampColors = { idle = Color3.fromRGB(80, 255, 120), counting = Color3.fromRGB(255, 190, 60), gone = Color3.fromRGB(255, 60, 50) }
	local function lamp(state: string)
		pod.lamp.Color = lampColors[state]
		local light = pod.lamp:FindFirstChildWhichIsA("PointLight")
		if light then
			light.Color = lampColors[state]
		end
	end
	local timer = COUNTDOWN
	while folder.Parent do
		if ReplicatedStorage:GetAttribute("RunStarted") then
			pod.screen.Text = `POD {pod.name}\n{RUN_LOCK_TEXT}`
			lamp("gone")
			task.wait(1)
			continue
		end
		local crew = playersIn(pod)
		if #crew == 0 then
			timer = COUNTDOWN
			pod.screen.Text = `POD {pod.name} · 0/4\nSTEP INSIDE TO BOARD`
			lamp("idle")
		elseif #crew > 4 then
			timer = COUNTDOWN
			pod.screen.Text = `POD {pod.name} · {#crew}/4\nTOO MANY CREW`
			lamp("counting")
		else
			pod.screen.Text = `POD {pod.name} · {#crew}/4\nLAUNCH IN {timer}`
			lamp("counting")
			if timer <= 0 then
				pod.screen.Text = `POD {pod.name}\nDEPARTING`
				lamp("gone")
				setDoors(pod, false)
				task.wait(2)
				crew = playersIn(pod)
				if #crew > 0 and Lobby.OnLaunch then
					Lobby.OnLaunch(crew)
				end
				task.wait(2)
				setDoors(pod, true)
				timer = COUNTDOWN
				continue
			end
			timer -= 1
		end
		task.wait(1)
	end
end

-- Builds the lobby, starts the pods and returns where players spawn.
-- If a folder named Lobby is already in the Workspace (a copy saved into the
-- place), that one is used as-is and nothing is built; only the terrain is
-- generated, and only when there isn't terrain at the lobby already.
function Lobby.Build(): CFrame
	local saved = workspace:FindFirstChild("Lobby")
	if saved and saved:IsA("Folder") then
		folder = saved
		print("[Totality] Using the Lobby saved in the Workspace.")
	else
		folder = Instance.new("Folder")
		folder.Name = "Lobby"
		buildShell()
		buildPlatform()
		lockerRoom()
		reception()
		buildPod("A", 32)
		buildPod("B", 47.5)
		buildPod("C", 63)
		buildStairs()
		buildFloor2()
		office()
		atrium()
		outsideStructures()
	end

	local probe = pos(49, -6, 25)
	local region = Region3.new(probe - Vector3.new(2, 2, 2), probe + Vector3.new(2, 2, 2)):ExpandToGrid(4)
	local materials = workspace.Terrain:ReadVoxels(region, 4)
	if materials[1][1][1] == Enum.Material.Air then
		landscape()
	end

	folder.Parent = workspace
	findPods()

	-- Peri at his office window, looking out over the lobby.
	task.spawn(function()
		if folder:FindFirstChild("Peri", true) then
			return
		end
		local at = pos(27.6, H1, 24)
		local ok, err = pcall(CrewNPC.Spawn, "Peri", CFrame.lookAt(at, at + Vector3.new(1, 0, 0)), folder)
		if not ok then
			warn(`[Totality] Couldn't place Peri in the lobby: {err}`)
		end
	end)

	for _, pod in pods do
		task.spawn(runPod, pod)
	end
	print("[Totality] Lobby built. Step into a pod to launch. Set Config.LOBBY = false to skip the lobby.")
	-- On the lobby floor in front of the pods, facing the windows.
	return cf(57, 3, 34) * CFrame.Angles(0, math.pi, 0)
end

return Lobby
