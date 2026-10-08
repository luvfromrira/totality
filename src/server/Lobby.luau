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
	      hallway (players spawn here) x 0..30,  z 23..38.6
	      steps down to the lobby      x 30..34, z 24..36
	    launch pods A, B, C            in an annex behind the back wall, z -14..0,
	                                   doorways flush with the wall
	    stairs to floor 2              x 80..97, z 11..22 (two flights)
	    open atrium with the orrery, lounge seating along the windows
	  Floor 2 (y 14)
	    Peri's office                  x 0..29, z 0..38.6, window over the atrium
	    stair landing                  x 68..98, z 0..20
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
local Research = require(script.Parent.Research)

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

-- Posts and end caps already placed, so railings that meet share one instead
-- of two identical parts in the same spot (which flicker).
local placedPosts: { [string]: boolean } = {}
local function once(kind: string, x: number, y: number, z: number): boolean
	local key = string.format("%s %.2f %.2f %.2f", kind, x, y, z)
	if placedPosts[key] then
		return false
	end
	placedPosts[key] = true
	return true
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
local VOID = { v(29, 0), v(68, 0), v(68, 20), v(85, 20), v(85, 31), v(76, 39.4), v(39, 39.4), v(29, 30) }

local H1, H2 = 14, 34 -- floor 2 level, roof underside
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
	-- The pods sit in an annex behind it, their doorways flush with the wall.
	solid("Wall", 0, 0, 82, 0, { { 32, 74, 22, 30 }, { 30.6, 77, 0, 12.6 } })
	-- West wall: EVA airlock from the locker room, office window.
	solid("Wall", 0, 38.6, 0, 0, { { 24.6, 29.6, PLAT, PLAT + 8 }, { 8, 30, 16, 23 } })
	-- South-west wall along the hallway: window band on both floors.
	solid("Wall", 28, 38.6, 0, 38.6, { { 3, 25, 5, 11 }, { 4, 24, 16, 23 } })

	-- Glass fill and frames for those openings.
	local glassProps = { Color = GLASS, Material = Enum.Material.Glass, Transparency = 0.7, CanCollide = true }
	box("Glass", 32, 22, -0.6, 74, 30, -0.4, glassProps)
	box("Glass", -0.6, 16, 8.6, -0.4, 23, 30.6, glassProps)
	box("Glass", 3, 5, 38.9, 25, 11, 39.1, glassProps)
	box("Glass", 4, 16, 38.9, 24, 23, 39.1, glassProps)
	for x = 32, 74, 6 do
		box("Mullion", x - 0.2, 22, -0.8, x + 0.2, 30, -0.1, { Color = DARK, Material = METAL })
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
		seg("Glass", ax, az, bx, bz, 14.4, H2 - 0.6, 0.3, -0.25, glass)
		-- Sill, spandrel at the floor-2 slab, head.
		seg("Sill", ax, az, bx, bz, 0, 0.8, 0.9, -0.15, { Color = DARK, Material = METAL })
		seg("Spandrel", ax, az, bx, bz, 12.6, 14.4, 0.9, -0.15, { Color = PANEL, Material = SMOOTH })
		seg("Head", ax, az, bx, bz, H2 - 0.6, H2, 0.9, -0.15, { Color = DARK, Material = METAL })
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
		seg("Transom", ax, az, bx, bz, 27, 27.3, 0.6, -0.2, { Color = DARK, Material = METAL })
	end

	-- Structural columns at every corner of the outline.
	for _, p in OUTLINE do
		box("Column", p.X - 0.7, 0, p.Y - 0.7, p.X + 0.7, H2, p.Y + 0.7, { Color = DARK, Material = METAL })
	end
end

-- Raised platform: locker room, hallway, steps ---------------------------------
local function buildPlatform()
	box("Platform", 0, 0.1, 0, 30, PLAT, 38.6, { Color = Color3.fromRGB(196, 190, 182), Material = Enum.Material.Marble })
	-- Steps down into the lobby, with glowing nosings.
	for k = 1, 4 do
		local top = PLAT - 0.5 * k
		box("Step", 30 + (k - 1), 0.1, 24, 30 + k, top, 36, { Color = Color3.fromRGB(196, 190, 182), Material = Enum.Material.Marble })
		box("Nosing", 30 + (k - 1), top, 24, 30 + (k - 1) + 0.15, top + 0.04, 36, { Color = AMBER, Material = NEON, CanCollide = false })
	end
	box("Nosing", 29.85, PLAT, 24, 30, PLAT + 0.04, 36, { Color = AMBER, Material = NEON, CanCollide = false })
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

	-- EVA suits hanging on racks along the east wall, a little taller than a
	-- player (bulky suit plus helmet). They face into the room (-x).
	local white = { Color = Color3.fromRGB(236, 234, 228), Material = Enum.Material.Fabric }
	local joint = { Color = Color3.fromRGB(150, 150, 150), Material = METAL }
	local dark = { Color = Color3.fromRGB(40, 42, 46), Material = SMOOTH }
	for i, z in { 4, 9.5, 15 } do
		local x = 28
		-- Rack: base plate, post behind the suit, shoulder hanger.
		box("RackBase", x - 0.9, y, z - 1.2, x + 1.5, y + 0.15, z + 1.2, { Color = DARK, Material = METAL })
		box("RackPost", x + 1.1, y + 0.15, z - 0.12, x + 1.35, y + 6.2, z + 0.12, { Color = STEEL, Material = METAL })
		box("RackArm", x + 0.6, y + 4.55, z - 0.1, x + 1.1, y + 4.75, z + 0.1, { Color = STEEL, Material = METAL })
		-- Boots and legs with knee rings.
		for _, side in { -1, 1 } do
			local lz = z + side * 0.42
			box("SuitBoot", x - 0.55, y + 0.15, lz - 0.32, x + 0.35, y + 0.6, lz + 0.32, dark)
			box("SuitLeg", x - 0.3, y + 0.6, lz - 0.3, x + 0.3, y + 1.4, lz + 0.3, white)
			box("SuitKnee", x - 0.33, y + 1.4, lz - 0.33, x + 0.33, y + 1.55, lz + 0.33, joint)
			box("SuitLeg", x - 0.3, y + 1.55, lz - 0.3, x + 0.3, y + 2.4, lz + 0.3, white)
		end
		-- Waist, torso, chest controls, orange band, name tag.
		box("SuitBelt", x - 0.38, y + 2.4, z - 0.78, x + 0.38, y + 2.6, z + 0.78, joint)
		box("SuitTorso", x - 0.45, y + 2.6, z - 0.8, x + 0.45, y + 4.3, z + 0.8, white)
		box("SuitBand", x - 0.47, y + 3.05, z - 0.81, x + 0.47, y + 3.2, z + 0.81, { Color = ORANGE })
		box("ChestBox", x - 0.7, y + 3.3, z - 0.4, x - 0.45, y + 3.85, z + 0.4, { Color = Color3.fromRGB(200, 200, 196) })
		box("ChestLight", x - 0.72, y + 3.7, z - 0.3, x - 0.7, y + 3.78, z - 0.15, { Color = Color3.fromRGB(80, 255, 120), Material = NEON })
		box("ChestLight", x - 0.72, y + 3.7, z - 0.05, x - 0.7, y + 3.78, z + 0.1, { Color = ORANGE, Material = NEON })
		local tag = box("SuitTag", x - 0.47, y + 3.95, z + 0.2, x - 0.45, y + 4.2, z + 0.75, { Color = DARK })
		sign(tag, `EVA-0{i}`, Enum.NormalId.Left, WHITE)
		-- Life-support pack with hoses running to the chest box.
		box("SuitPack", x + 0.45, y + 2.8, z - 0.65, x + 1.05, y + 4.5, z + 0.65, { Color = Color3.fromRGB(205, 203, 196) })
		box("PackVent", x + 1.05, y + 3.2, z - 0.4, x + 1.08, y + 3.6, z + 0.4, dark)
		for _, side in { -1, 1 } do
			box("Hose", x - 0.62, y + 3.85, z + side * 0.3 - 0.05, x + 0.5, y + 3.95, z + side * 0.3 + 0.05, dark)
		end
		-- Arms hanging at the sides: shoulder, elbow ring, glove.
		for _, side in { -1, 1 } do
			local az = z + side * 1.05
			box("SuitShoulder", x - 0.32, y + 3.9, az - 0.28, x + 0.32, y + 4.3, az + 0.28, white)
			box("SuitArm", x - 0.25, y + 3.05, az - 0.24, x + 0.25, y + 3.9, az + 0.24, white)
			box("SuitElbow", x - 0.28, y + 2.9, az - 0.27, x + 0.28, y + 3.05, az + 0.27, joint)
			box("SuitArm", x - 0.25, y + 2.2, az - 0.24, x + 0.25, y + 2.9, az + 0.24, white)
			box("SuitGlove", x - 0.27, y + 1.85, az - 0.22, x + 0.27, y + 2.2, az + 0.22, dark)
		end
		-- Collar ring and helmet with a gold visor and a lamp.
		local collar = cyl("SuitCollar", x, y + 4.3, z, 0.62, 0.18, joint)
		_ = collar
		ball("SuitHelmet", x, y + 5.08, z, 1.45, white)
		ball("Visor", x - 0.26, y + 5.12, z, 1.1, { Color = Color3.fromRGB(205, 140, 45), Material = SMOOTH, Reflectance = 0.5 })
		box("HelmetLamp", x - 0.35, y + 5.7, z - 0.6, x + 0.1, y + 5.9, z - 0.38, joint)
		box("HelmetLampLens", x - 0.37, y + 5.72, z - 0.58, x - 0.35, y + 5.88, z - 0.4, { Color = WARM, Material = NEON })
	end
	local s3 = box("Sign", 29.95, y + 7, 6, 30, y + 8.2, 13, { Color = DARK })
	sign(s3, "SUIT UP BEFORE SURFACE ACCESS", Enum.NormalId.Left, AMBER)

	-- Lights.
	for _, p in { { 7, 6 }, { 15, 6 }, { 23, 6 }, { 7, 16 }, { 15, 16 }, { 23, 16 } } do
		panel(p[1], top - 0.1, p[2], COOL, Vector3.new(4, 0.3, 1.6), 14)
	end
end

-- Annex behind the back wall that the pods sit in, with filler panels and a
-- header so the wall reads as one flat face with three pod doorways in it.
local function podAnnex()
	local wallProps = { Color = WHITE, Material = SMOOTH }
	for _, f in { { 30.6, 32 }, { 45, 47.5 }, { 60.5, 63 }, { 76, 77 } } do
		box("Wall", f[1], 0, -1, f[2], 11, 0, wallProps)
	end
	box("Wall", 30.6, 11, -1, 77, 12.6, 0, wallProps)
	box("Trim", 30.6, 12.4, 0, 77, 12.6, 0.2, { Color = ORANGE, Material = NEON, CanCollide = false })
	box("Foundation", 29, -2, -17, 79, 0, -3, { Color = Color3.fromRGB(150, 112, 92), Material = Enum.Material.Concrete })
	box("Floor", 30, 0, -16, 78, 0.1, -1, { Color = DARK, Material = METAL })
	box("Wall", 30, 0, -16, 78, 13.6, -15, wallProps)
	box("Wall", 29, 0, -16, 30, 13.6, -1, wallProps)
	box("Wall", 77, 0, -15, 78, 13.6, -1, wallProps)
	box("Roof", 29, 12.6, -16, 78, 13.6, -1, { Color = Color3.fromRGB(190, 186, 180), Material = Enum.Material.Concrete })
end

-- Railing up a straight flight of stairs running along x, at depth z.
local function stairRail(xa: number, ya: number, xb: number, yb: number, z: number)
	local len = math.sqrt((xb - xa) ^ 2 + (yb - ya) ^ 2)
	local angle = math.atan2(yb - ya, xb - xa)
	-- Offsets are vertical (in world space) so the rail sits exactly on top of
	-- the posts, and the glass keeps the same vertical height along the slope.
	local function along(up: number): CFrame
		return cf((xa + xb) / 2, (ya + yb) / 2 + up, z) * CFrame.Angles(0, 0, angle)
	end
	local c = math.cos(angle)
	B.part(folder, "Rail", Vector3.new(len, 0.25 * c, 0.3), along(3.5), { Color = STEEL, Material = METAL })
	B.part(folder, "RailGlass", Vector3.new(len, 3.1 * c, 0.1), along(1.85),
		{ Color = GLASS, Material = Enum.Material.Glass, Transparency = 0.65 })
	B.part(folder, "RailBase", Vector3.new(len, 0.2 * c, 0.3), along(0.2), { Color = DARK, Material = METAL })
	local n = math.max(1, math.round(math.abs(xb - xa) / 3.5))
	for i = 0, n do
		local t = i / n
		local x, y = xa + (xb - xa) * t, ya + (yb - ya) * t
		if once("post", x, y, z) then
			box("RailPost", x - 0.12, y, z - 0.12, x + 0.12, y + 3.6, z + 0.12, { Color = STEEL, Material = METAL })
		end
	end
	for _, e in { { xa, ya }, { xb, yb } } do
		if not once("cap", e[1], e[2], z) then
			continue
		end
		box("RailCap", e[1] - 0.2, e[2] + 3.36, z - 0.2, e[1] + 0.2, e[2] + 3.7, z + 0.2, { Color = STEEL, Material = METAL })
	end
end

-- Launch pods ---------------------------------------------------------------------
type Pod = { name: string, screen: TextLabel, lamp: Part, zone: CFrame, zoneSize: Vector3,
	doors: { { part: Part, open: CFrame, shut: CFrame } }, spawn: CFrame }
local pods: { Pod } = {}

local function buildPod(name: string, x0: number)
	local x1 = x0 + 13
	local cx = (x0 + x1) / 2
	local z0, z1 = -14, 0
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
	pb("Roof", x0 - 0.2, 11, z0 - 0.2, x1 + 0.2, 11.8, z1 - 0.6, trimDark)
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
	for _, x in { cx - 3.2, cx + 2.98 } do
		pb("DoorGlow", x, 0.5, z1 - 0.05, x + 0.22, 8.98, z1 + 0.05, { Color = ORANGE, Material = NEON, CanCollide = false })
	end
	pb("DoorGlow", cx - 3.2, 8.98, z1 - 0.05, cx + 3.2, 9.2, z1 + 0.05, { Color = ORANGE, Material = NEON, CanCollide = false })
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
		pb("SeatBack", sx - face * 0.8 - 0.2, 2.4, sz - 0.98, sx - face * 0.8 + 0.2, 6.4, sz + 0.98, { Color = ORANGE, Material = Enum.Material.Fabric })
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
	local lamp = pb("StatusLamp", cx - 0.6, 11.4, z1, cx + 0.6, 12, z1 + 0.3, { Color = Color3.fromRGB(80, 255, 120), Material = NEON, CanCollide = false }) :: Part
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
		if once("post", x, y, z) then
			box("RailPost", x - 0.12, y, z - 0.12, x + 0.12, y + 3.4, z + 0.12, { Color = STEEL, Material = METAL })
		end
	end
	-- Square caps over the ends so corners where two railings meet are clean.
	for _, e in { { ax, az }, { bx, bz } } do
		if not once("cap", e[1], y, e[2]) then
			continue
		end
		box("RailCap", e[1] - 0.2, y + 3.36, e[2] - 0.2, e[1] + 0.2, y + 3.7, e[2] + 0.2, { Color = STEEL, Material = METAL })
		box("RailCap", e[1] - 0.2, y, e[2] - 0.2, e[1] + 0.2, y + 0.24, e[2] + 0.2, { Color = DARK, Material = METAL })
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
	-- Railings on both sides of both flights and around the mid landing.
	stairRail(80, 0, 92, 7, 22)
	stairRail(80, 0, 92, 7, 17.15)
	-- (The north rail of the upper flight stops where the landing above closes
	-- in over it; the railing around the stair opening takes over from there.)
	stairRail(92, 7, 87.9, 9.4, 11.15)
	stairRail(92, 7, 80, 14, 15.85)
	railing(92, 11, 97.4, 11, 7)
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
	slabBox(68, 0, 80, 20)
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
		if (x >= 68 and x < 80 and z < 20) or (x >= 80 and z < 17) then
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
		{ 29, 30, 39, 39.4 }, { 39, 39.4, 76, 39.4 }, { 76, 39.4, 85, 31 }, { 85, 31, 85, 20 }, { 85, 20, 68, 20 },
	}
	for _, e in edges do
		seg("Beam", e[1], e[2], e[3], e[4], H1 - 1.4, H1 - 0.35, 0.6, -0.3, { Color = DARK, Material = METAL })
		local lit = seg("BeamLight", e[1], e[2], e[3], e[4], H1 - 1.5, H1 - 1.4, 0.3, -0.3, { Color = COOL, Material = NEON, CanCollide = false })
		glow(lit, COOL, 12, 0.5, "SurfaceLight")
	end
	for _, p in { v(39, 39.4), v(57.5, 39.4), v(76, 39.4), v(85, 31), v(85, 23.5), v(68.5, 19.5) } do
		box("Column", p.X - 0.45, 0.1, p.Y - 0.45, p.X + 0.45, H1 - 1.4, p.Y + 0.45, { Color = DARK, Material = METAL })
	end

	-- Balustrades around the atrium on floor 2.
	railing(29.6, 30.6, 39, 39.4, H1)
	railing(39, 39.4, 76, 39.4, H1)
	railing(76, 39.4, 85, 31, H1)
	railing(85, 31, 85, 20, H1)
	railing(68, 0.7, 68, 20, H1)
	railing(68, 20, 85, 20, H1)
	railing(80, 11, 92, 11, H1)
	railing(92, 11, 92, 17, H1)
	railing(80, 17, 92, 17, H1)
end

-- A little picture of Aphe and Peri, drawn with UI on the photo's face:
-- the two of them in front of a Martian sunset, with a heart between them.
local function photoOfApheAndPeri(photo: Part)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Right
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 250
	gui.LightInfluence = 0.6
	gui.Parent = photo
	local function shape(color: Color3, x: number, y: number, w: number, h: number, round: number?, z: number?): Frame
		local f = Instance.new("Frame")
		f.BackgroundColor3 = color
		f.BorderSizePixel = 0
		f.AnchorPoint = Vector2.new(0.5, 0.5)
		f.Position = UDim2.fromScale(x, y)
		f.Size = UDim2.fromScale(w, h)
		f.ZIndex = z or 1
		if round then
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(round, 0)
			c.Parent = f
		end
		f.Parent = gui
		return f
	end
	-- Sky (sunset gradient), sun, ground.
	local sky = shape(Color3.new(1, 1, 1), 0.5, 0.5, 1, 1)
	local g = Instance.new("UIGradient")
	g.Rotation = 90
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 80, 150)),
		ColorSequenceKeypoint.new(0.55, Color3.fromRGB(240, 150, 110)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 200, 140)),
	})
	g.Parent = sky
	shape(Color3.fromRGB(255, 225, 170), 0.5, 0.62, 0.34, 0.3, 0.5, 2)
	shape(Color3.fromRGB(160, 70, 45), 0.5, 0.88, 1, 0.28, nil, 3)
	shape(Color3.fromRGB(130, 55, 38), 0.2, 0.76, 0.5, 0.12, 0.5, 3)
	shape(Color3.fromRGB(140, 60, 40), 0.85, 0.75, 0.45, 0.14, 0.5, 3)
	-- Aphe on the left (before the illness turned him purple): tan skin, black suit.
	shape(Color3.fromRGB(25, 25, 30), 0.3, 0.83, 0.28, 0.42, 0.35, 4)
	shape(Color3.fromRGB(214, 172, 132), 0.3, 0.5, 0.22, 0.22, 0.5, 5)
	shape(Color3.fromRGB(40, 30, 50), 0.3, 0.42, 0.24, 0.1, 0.5, 6)
	-- Peri on the right: tan skin, green cardigan.
	shape(Color3.fromRGB(70, 115, 72), 0.7, 0.83, 0.28, 0.42, 0.35, 4)
	shape(Color3.fromRGB(230, 225, 210), 0.7, 0.8, 0.06, 0.3, nil, 5)
	shape(Color3.fromRGB(189, 154, 121), 0.7, 0.5, 0.22, 0.22, 0.5, 5)
	shape(Color3.fromRGB(60, 40, 30), 0.7, 0.42, 0.24, 0.1, 0.5, 6)
	-- Heart between them.
	local heart = Instance.new("TextLabel")
	heart.BackgroundTransparency = 1
	heart.AnchorPoint = Vector2.new(0.5, 0.5)
	heart.Position = UDim2.fromScale(0.5, 0.32)
	heart.Size = UDim2.fromScale(0.3, 0.2)
	heart.Text = "♥"
	heart.TextScaled = true
	heart.Font = Enum.Font.GothamBold
	heart.TextColor3 = Color3.fromRGB(255, 110, 150)
	heart.ZIndex = 7
	heart.Parent = gui
	-- White photo border.
	local border = Instance.new("UIStroke")
	border.Color = Color3.fromRGB(245, 240, 230)
	border.Thickness = 6
	border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	border.Parent = sky
end

-- Peri's office -------------------------------------------------------------------
local function office()
	local y = H1
	local ceil = H1 + 10
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
	box("DoorFrame", 28.9, y, 32.8, 29.7, y + 8.2, 33.03, { Color = ORANGE })
	box("DoorFrame", 28.9, y, 36.97, 29.7, y + 8.2, 37.2, { Color = ORANGE })
	box("DoorFrame", 28.9, y + 7.97, 33.03, 29.7, y + 8.2, 36.97, { Color = ORANGE })
	local plate = box("DoorPlate", 29.6, y + 5, 37.4, 29.65, y + 6.4, 38.4, { Color = DARK })
	sign(plate, "PERI", Enum.NormalId.Right, AMBER)
	-- Ceiling with crown moulding, plank floor, rugs.
	box("Ceiling", 0, ceil, 0, 29, ceil + 0.2, 38.6, { Color = Color3.fromRGB(232, 228, 220), Material = SMOOTH })
	local trimWood = { Color = Color3.fromRGB(92, 62, 42), Material = Enum.Material.Wood }
	box("Crown", 0, ceil - 0.35, 0, 29, ceil, 0.25, trimWood)
	box("Crown", 0, ceil - 0.35, 0.25, 0.25, ceil, 38.35, trimWood)
	box("Crown", 0, ceil - 0.35, 38.35, 29, ceil, 38.6, trimWood)
	local planks = { Color3.fromRGB(150, 108, 72), Color3.fromRGB(140, 100, 66), Color3.fromRGB(158, 116, 78) }
	for i = 0, 18 do
		local z0 = i * 38.6 / 19
		box("Plank", 0, y, z0, 29, y + 0.05, z0 + 38.6 / 19, { Color = planks[i % 3 + 1], Material = Enum.Material.WoodPlanks })
	end
	box("Rug", 13, y + 0.05, 9, 27.5, y + 0.08, 23, { Color = Color3.fromRGB(110, 46, 40), Material = Enum.Material.Fabric })
	box("RugBorder", 13.4, y + 0.08, 9.4, 27.1, y + 0.09, 9.8, { Color = Color3.fromRGB(200, 160, 90), Material = Enum.Material.Fabric })
	box("RugBorder", 13.4, y + 0.08, 22.2, 27.1, y + 0.09, 22.6, { Color = Color3.fromRGB(200, 160, 90), Material = Enum.Material.Fabric })
	box("Rug", 4.2, y + 0.05, 23.5, 12, y + 0.08, 34.5, { Color = Color3.fromRGB(60, 70, 90), Material = Enum.Material.Fabric })
	-- Wainscoting: dark wood panels along the lower walls, with a rail on top.
	box("Wainscot", 0, y, 0, 3, y + 3, 0.2, trimWood)
	box("Wainscot", 0, y, 0.2, 0.2, y + 2, 38.4, trimWood)
	box("Wainscot", 0.2, y, 38.4, 29, y + 2, 38.6, trimWood)
	box("ChairRail", 0, y + 3, 0, 3, y + 3.2, 0.3, trimWood)
	for _, p in { { 8, 8 }, { 8, 28 }, { 21, 6 } } do
		panel(p[1], ceil, p[2], WARM, Vector3.new(3, 0.25, 3), 16)
	end

	-- The desk: a proper executive desk, back to the atrium window, with a
	-- return wing. Peri's chair sits behind it; no visitor chairs.
	local walnut = { Color = Color3.fromRGB(96, 60, 38), Material = Enum.Material.Wood }
	local walnutDark = { Color = Color3.fromRGB(64, 40, 26), Material = Enum.Material.Wood }
	local brass = { Color = Color3.fromRGB(200, 165, 90), Material = METAL }
	local top = y + 2.9
	box("DeskTop", 18.5, top, 11, 24.5, top + 0.25, 21, walnut)
	box("DeskEdge", 18.4, top - 0.1, 10.9, 24.6, top, 21.1, walnutDark)
	box("DeskPad", 21.6, top + 0.25, 13.6, 24.2, top + 0.28, 18.4, { Color = Color3.fromRGB(40, 34, 30), Material = Enum.Material.Leather })
	-- Pedestals with drawers at each end, modesty panel facing the visitor side.
	for _, z0 in { 11.2, 18.3 } do
		box("Pedestal", 18.7, y, z0, 24.3, top - 0.1, z0 + 2.5, walnutDark)
		for d = 0, 2 do
			local dy = y + 0.25 + d * 0.85
			box("Drawer", 24.3, dy, z0 + 0.15, 24.38, dy + 0.75, z0 + 2.35, walnut)
			box("DrawerPull", 24.38, dy + 0.3, z0 + 0.9, 24.48, dy + 0.42, z0 + 1.6, brass)
		end
	end
	box("Modesty", 18.6, y + 0.6, 13.7, 18.9, top - 0.1, 18.3, walnutDark)
	for _, z in { 14.6, 16, 17.4 } do
		box("ModestyGroove", 18.55, y + 0.9, z - 0.05, 18.6, top - 0.4, z + 0.05, walnut)
	end
	-- Return wing along the window side with the printer.
	box("ReturnTop", 22.5, top, 21, 24.5, top + 0.25, 25, walnut)
	box("ReturnBase", 22.7, y, 21.2, 24.3, top, 24.8, walnutDark)
	box("Printer", 22.8, top + 0.25, 22.6, 24.2, top + 1.05, 24.4, { Color = Color3.fromRGB(70, 72, 78) })
	box("PrinterTray", 22.6, top + 0.55, 22.9, 22.8, top + 0.6, 24.1, { Color = Color3.fromRGB(230, 230, 225) })
	-- Two monitors on a single arm.
	box("MonitorArm", 19.1, top + 0.25, 15.85, 19.4, top + 2.2, 16.15, { Color = DARK, Material = METAL })
	box("MonitorArm", 19.4, top + 2, 14, 19.8, top + 2.2, 18, { Color = DARK, Material = METAL })
	for i, z in { 14.6, 17.4 } do
		box("Monitor", 19.8, top + 1.1, z - 1.35, 20, top + 3.1, z + 1.35, { Color = DARK })
		box("Screen", 20, top + 1.2, z - 1.25, 20.05, top + 3, z + 1.25,
			{ Color = if i == 1 then Color3.fromRGB(90, 150, 210) else Color3.fromRGB(255, 160, 80), Material = NEON })
	end
	box("Keyboard", 22.4, top + 0.28, 14.9, 23, top + 0.38, 17.1, { Color = DARK })
	box("Mouse", 22.5, top + 0.28, 17.6, 22.9, top + 0.4, 17.85, { Color = DARK })
	-- Desk things: nameplate, photo, lamp, mug, paperwork, pen cup, a Mars rock.
	local nameplate = B.part(folder, "Nameplate", Vector3.new(0.5, 0.4, 2), cf(19, top + 0.45, 16) * CFrame.Angles(0, 0, math.rad(20)),
		{ Color = Color3.fromRGB(30, 28, 26), Material = SMOOTH })
	sign(nameplate, "PERI", Enum.NormalId.Left, Color3.fromRGB(220, 190, 120), Enum.Font.Garamond)
	box("PhotoFrame", 20.3, top + 0.25, 19.3, 20.45, top + 1.35, 20.3, brass)
	local photo = box("Photo", 20.45, top + 0.35, 19.4, 20.5, top + 1.25, 20.2, { Color = Color3.fromRGB(230, 220, 235) })
	if photo then
		photoOfApheAndPeri(photo)
	end
	cyl("LampBase", 23.6, top + 0.25, 12, 0.4, 0.15, brass)
	box("LampStem", 23.55, top + 0.4, 11.95, 23.65, top + 2.1, 12.05, brass)
	box("LampArm", 22.7, top + 2.05, 11.95, 23.65, top + 2.15, 12.05, brass)
	local shade = cyl("LampShade", 22.7, top + 1.65, 12, 0.45, 0.45, { Color = Color3.fromRGB(40, 90, 60), Material = Enum.Material.Glass, Transparency = 0.1 })
	glow(shade, WARM, 12, 0.7)
	cyl("Mug", 24, top + 0.25, 19.4, 0.22, 0.5, { Color = ORANGE })
	cyl("Coffee", 24, top + 0.7, 19.4, 0.18, 0.06, { Color = Color3.fromRGB(60, 36, 20) })
	-- The same research folder players collect on the ship.
	Research.Prop(cf(21, top + 0.28, 12) * CFrame.Angles(0, math.rad(18), 0), Random.new(5)).Parent = folder
	cyl("PenCup", 21.2, top + 0.25, 20.3, 0.22, 0.55, { Color = DARK })
	for k = 0, 2 do
		box("Pen", 21.15 + k * 0.05, top + 0.6, 20.25, 21.2 + k * 0.05, top + 1.1, 20.3, { Color = ({ Color3.fromRGB(30, 60, 160), Color3.fromRGB(180, 30, 30), DARK })[k + 1] })
	end
	ball("MarsRock", 19.6, top + 0.45, 20.4, 0.45, { Color = Color3.fromRGB(170, 80, 50), Material = Enum.Material.Rock })
	-- Wastebasket under the desk.
	cyl("Bin", 23.4, y, 20.5, 0.4, 1.1, { Color = DARK, Material = METAL })

	-- Peri's chair: five-star base, gas lift, padded seat and high back.
	local leather = { Color = Color3.fromRGB(34, 32, 34), Material = Enum.Material.Leather }
	local chairX, chairZ = 25.8, 16
	for k = 0, 4 do
		local a = k * math.pi * 2 / 5
		B.part(folder, "ChairLeg", Vector3.new(1.1, 0.12, 0.18),
			cf(chairX + math.cos(a) * 0.55, y + 0.3, chairZ + math.sin(a) * 0.55) * CFrame.Angles(0, -a, 0), { Color = DARK, Material = METAL })
		ball("Caster", chairX + math.cos(a) * 1.05, y + 0.12, chairZ + math.sin(a) * 1.05, 0.24, { Color = DARK })
	end
	cyl("GasLift", chairX, y + 0.3, chairZ, 0.12, 1.4, { Color = STEEL, Material = METAL })
	box("ChairSeat", chairX - 0.9, y + 1.7, chairZ - 0.95, chairX + 0.8, y + 2.15, chairZ + 0.95, leather)
	box("ChairBack", chairX + 0.75, y + 2.1, chairZ - 0.9, chairX + 1.05, y + 5.3, chairZ + 0.9, leather)
	box("ChairHead", chairX + 0.8, y + 5.3, chairZ - 0.6, chairX + 1.05, y + 5.9, chairZ + 0.6, leather)
	for _, side in { -1, 1 } do
		box("ArmPost", chairX + 0.1, y + 2.15, chairZ + side * 0.95 - 0.08, chairX + 0.3, y + 2.9, chairZ + side * 0.95 + 0.08, { Color = DARK, Material = METAL })
		box("ArmPad", chairX - 0.5, y + 2.9, chairZ + side * 0.95 - 0.14, chairX + 0.7, y + 3.05, chairZ + side * 0.95 + 0.14, leather)
	end

	-- Low credenza under the atrium window behind the chair, with a Mars globe,
	-- an award and a plant.
	box("Credenza", 27.4, y, 9, 28.9, y + 2.4, 23, walnutDark)
	box("CredenzaTop", 27.3, y + 2.4, 8.9, 29, y + 2.6, 23.1, walnut)
	for z = 9.4, 22, 3.4 do
		box("CredenzaDoor", 27.32, y + 0.3, z, 27.4, y + 2.2, z + 3.1, walnut)
		box("DrawerPull", 27.22, y + 1.2, z + 1.4, 27.32, y + 1.5, z + 1.7, brass)
	end
	cyl("GlobeStand", 28.15, y + 2.6, 11, 0.35, 0.2, brass)
	box("GlobeAxis", 28.1, y + 2.8, 10.95, 28.2, y + 3.2, 11.05, brass)
	ball("MarsGlobe", 28.15, y + 3.75, 11, 1.2, { Color = Color3.fromRGB(190, 90, 55), Material = SMOOTH })
	box("Award", 27.9, y + 2.6, 15.6, 28.4, y + 3.9, 16.2, { Color = Color3.fromRGB(180, 210, 230), Material = Enum.Material.Glass, Transparency = 0.2 })
	box("AwardBase", 27.85, y + 2.6, 15.5, 28.45, y + 2.8, 16.3, walnutDark)
	cyl("Pot", 28.15, y + 2.6, 21, 0.45, 0.6, { Color = WHITE })
	ball("Succulent", 28.15, y + 3.4, 21, 0.9, { Color = Color3.fromRGB(80, 140, 90), Material = Enum.Material.Grass })

	-- Built-in bookshelf along the north wall: books, boxes, a few keepsakes.
	box("ShelfSide", 3, y, 0.2, 3.3, y + 8.6, 2, walnutDark)
	box("ShelfSide", 17.7, y, 0.2, 18, y + 8.6, 2, walnutDark)
	box("ShelfBack", 3.3, y, 0.2, 17.7, y + 8.6, 0.35, walnut)
	box("ShelfTop", 2.9, y + 8.6, 0.2, 18.1, y + 8.9, 2.2, walnutDark)
	local bookColors = { Color3.fromRGB(150, 50, 40), Color3.fromRGB(40, 70, 120), Color3.fromRGB(200, 170, 90),
		Color3.fromRGB(50, 100, 70), Color3.fromRGB(90, 60, 110), Color3.fromRGB(220, 220, 210), Color3.fromRGB(30, 30, 34) }
	local rng = Random.new(7)
	for shelf = 0, 3 do
		local sy = y + 0.6 + shelf * 2
		box("ShelfBoard", 3.3, sy - 0.15, 0.35, 17.7, sy, 2, walnutDark)
		local x = 3.5
		while x < 17.3 do
			local roll = rng:NextNumber()
			if roll < 0.08 and x < 16 then
				-- A keepsake instead of books.
				ball("Keepsake", x + 0.6, sy + 0.45, 1.2, 0.8, { Color = Color3.fromRGB(rng:NextInteger(120, 220), rng:NextInteger(80, 160), rng:NextInteger(60, 120)), Material = METAL })
				x += 1.4
			elseif roll < 0.14 and x < 15.8 then
				box("StoreBox", x, sy, 0.6, x + 1.4, sy + 1, 1.9, { Color = Color3.fromRGB(180, 160, 130), Material = Enum.Material.Cardboard })
				x += 1.5
			else
				local w = rng:NextNumber(0.22, 0.45)
				local h = rng:NextNumber(1.1, 1.7)
				box("Book", x, sy, 0.6, x + w, sy + h, 1.9, { Color = bookColors[rng:NextInteger(1, #bookColors)] })
				x += w + 0.03
			end
		end
	end
	cyl("Pot", 10.5, y + 8.9, 1.2, 0.5, 0.6, { Color = Color3.fromRGB(190, 120, 80) })
	for k = 0, 4 do
		box("Vine", 10.3 + k * 0.1, y + 7.2 - k * 0.3, 1.9, 10.5 + k * 0.1, y + 9.4, 2.05, { Color = Color3.fromRGB(70, 130, 70), Material = Enum.Material.Grass })
	end

	-- Cork board with pinned notes, and a filing cabinet under it.
	box("CorkFrame", 18.6, y + 4.6, 0.2, 24.4, y + 8.6, 0.35, walnutDark)
	box("Cork", 18.8, y + 4.8, 0.35, 24.2, y + 8.4, 0.4, { Color = Color3.fromRGB(190, 150, 100), Material = Enum.Material.Fabric })
	local noteColors = { Color3.fromRGB(255, 240, 140), Color3.fromRGB(255, 255, 250), Color3.fromRGB(170, 220, 255), Color3.fromRGB(255, 190, 200) }
	for k = 0, 7 do
		local nx, ny = 19.2 + (k % 4) * 1.25, y + 5.2 + math.floor(k / 4) * 1.5
		box("Note", nx, ny, 0.4, nx + 0.9, ny + 1.1, 0.42, { Color = noteColors[k % 4 + 1] })
		ball("Pin", nx + 0.45, ny + 0.95, 0.44, 0.12, { Color = Color3.fromRGB(200, 40, 40) })
	end
	local memo = box("Memo", 21.7, y + 6.7, 0.43, 23.8, y + 8.1, 0.45, { Color = Color3.fromRGB(255, 255, 250) })
	sign(memo, "RECOVERY TEAM\nbring them home", Enum.NormalId.Back, Color3.fromRGB(60, 60, 70), Enum.Font.Garamond)
	box("Cabinet", 19, y, 0.2, 21.4, y + 3.6, 2, { Color = STEEL, Material = METAL })
	for d = 0, 1 do
		box("Drawer", 19.15, y + 0.3 + d * 1.65, 2, 21.25, y + 1.75 + d * 1.65, 2.05, { Color = Color3.fromRGB(120, 124, 130), Material = METAL })
		box("DrawerPull", 19.8, y + 1.3 + d * 1.65, 2.05, 20.6, y + 1.42 + d * 1.65, 2.15, brass)
	end

	-- Coffee corner: counter, machine, mugs, a tiny fridge.
	box("Counter", 22, y, 0.2, 28.8, y + 3, 2.2, walnutDark)
	box("CounterTop", 21.9, y + 3, 0.2, 28.9, y + 3.2, 2.3, { Color = Color3.fromRGB(40, 42, 48), Material = Enum.Material.Granite })
	box("Fridge", 26.4, y + 0.1, 2.2, 28.6, y + 2.8, 2.25, { Color = Color3.fromRGB(220, 220, 215), Material = METAL })
	box("Espresso", 22.6, y + 3.2, 0.6, 24, y + 4.8, 1.8, { Color = Color3.fromRGB(150, 150, 155), Material = METAL })
	box("EspressoSpout", 22.9, y + 3.9, 1.8, 23.7, y + 4.1, 2.1, { Color = DARK, Material = METAL })
	for k = 0, 2 do
		cyl("Mug", 24.8 + k * 0.6, y + 3.2, 1.4, 0.2, 0.45, { Color = ({ WHITE, ORANGE, Color3.fromRGB(60, 110, 70) })[k + 1] })
	end
	local clock = cyl("Clock", 0, 0, 0, 0.7, 0.1, { Color = WHITE })
	if clock then
		clock.CFrame = cf(28.95, y + 9.2, 35) * CFrame.Angles(0, 0, 0)
		sign(clock, "16:40\nARES", Enum.NormalId.Left, DARK, Enum.Font.Code)
	end

	-- Lounge corner: couch with pillows and Peri's green cardigan, coffee
	-- table, floor lamp, side table.
	local couch = { Color = Color3.fromRGB(150, 135, 120), Material = Enum.Material.Fabric }
	box("CouchBase", 0.4, y + 0.3, 24, 3.6, y + 1.6, 34, couch)
	box("CouchBack", 0.4, y + 1.6, 24, 1.3, y + 4, 34, couch)
	box("CouchArm", 0.4, y + 0.3, 23.3, 3.6, y + 2.8, 24, couch)
	box("CouchArm", 0.4, y + 0.3, 34, 3.6, y + 2.8, 34.7, couch)
	for _, z in { 24.1, 27.4, 30.7 } do
		box("Cushion", 1.3, y + 1.6, z, 3.6, y + 2, z + 3.2, { Color = Color3.fromRGB(165, 150, 134), Material = Enum.Material.Fabric })
	end
	for _, f in { { 1.3, 24.8 }, { 1.3, 33.2 } } do
		local pillow = B.part(folder, "Pillow", Vector3.new(0.5, 1.3, 1.3), cf(f[1] + 0.3, y + 2.6, f[2]) * CFrame.Angles(math.rad(10), 0, math.rad(-12)),
			{ Color = Color3.fromRGB(200, 120, 70), Material = Enum.Material.Fabric })
		_ = pillow
	end
	for k = 0, 3 do
		box("CouchFoot", 0.6 + (k % 2) * 2.6, y, 24.2 + math.floor(k / 2) * 9.4, 0.9 + (k % 2) * 2.6, y + 0.3, 24.5 + math.floor(k / 2) * 9.4, walnutDark)
	end
	-- The cardigan: thrown over the back of the couch. The body drapes over
	-- the backrest with one half hanging behind; the open front falls onto
	-- the seat cushion; one sleeve lies across the seat, the other hangs
	-- down the back. Everything is a little off-square so it looks soft.
	local knit = { Color = Color3.fromRGB(68, 112, 72), Material = Enum.Material.Fabric, CanCollide = false }
	local rib = { Color = Color3.fromRGB(56, 94, 60), Material = Enum.Material.Fabric, CanCollide = false }
	local function piece(name, size, at, rx, ry, rz, props)
		B.part(folder, name, size, at * CFrame.Angles(math.rad(rx), math.rad(ry), math.rad(rz)), props)
	end
	-- Over the top of the backrest, and the part hanging down behind it.
	piece("Cardigan", Vector3.new(1.3, 0.16, 2.75), cf(0.85, y + 4.07, 29.9), 0, 4, 3, knit)
	piece("Cardigan", Vector3.new(0.12, 1.5, 2.6), cf(0.3, y + 3.3, 29.85), 0, 3, -4, knit)
	piece("CardiganRib", Vector3.new(0.14, 0.18, 2.6), cf(0.3, y + 2.5, 29.85), 0, 3, -4, rib)
	-- Collar ribbing along the front edge of the drape.
	piece("CardiganRib", Vector3.new(0.2, 0.2, 2.8), cf(1.42, y + 4.12, 29.9), 0, 4, 0, rib)
	-- The two front halves hanging down the front of the backrest, splayed.
	piece("Cardigan", Vector3.new(0.13, 1.95, 1.3), cf(1.44, y + 3.05, 29.25), -3, 0, -7, knit)
	piece("Cardigan", Vector3.new(0.13, 1.9, 1.3), cf(1.46, y + 3.02, 30.62), 4, 0, -10, knit)
	piece("ButtonBand", Vector3.new(0.15, 1.95, 0.16), cf(1.48, y + 3.05, 29.86), -3, 0, -7, rib)
	for k = 0, 4 do
		local by = y + 3.85 - k * 0.42
		ball("Button", 1.56 + (y + 3.85 - by) * 0.12, by, 29.86, 0.11, { Color = Color3.fromRGB(205, 185, 145), CanCollide = false })
	end
	piece("Pocket", Vector3.new(0.05, 0.55, 0.6), cf(1.58, y + 2.65, 30.75), 4, 0, -10, rib)
	-- Where the front pools on the seat, with the ribbed hem.
	piece("Cardigan", Vector3.new(0.95, 0.13, 2.65), cf(1.85, y + 2.07, 29.95), 0, 5, 2, knit)
	piece("CardiganRib", Vector3.new(0.22, 0.15, 2.66), cf(2.38, y + 2.07, 30.0), 0, 5, 2, rib)
	-- Sleeve lying across the seat, ending in a cuff near the front edge.
	piece("CardiganSleeve", Vector3.new(0.42, 0.3, 2.3), cf(2.2, y + 2.15, 31.75), 0, -38, 3, knit)
	piece("CardiganCuff", Vector3.new(0.44, 0.32, 0.4), cf(2.92, y + 2.15, 32.62), 0, -38, 3, rib)
	-- Other sleeve hanging down the back of the couch.
	piece("CardiganSleeve", Vector3.new(0.32, 1.8, 0.42), cf(0.28, y + 3.1, 28.35), 6, 0, -3, knit)
	piece("CardiganCuff", Vector3.new(0.34, 0.3, 0.44), cf(0.24, y + 2.1, 28.3), 6, 0, -3, rib)
	-- Coffee table with a couple of books and a tablet.
	box("CoffeeTable", 5.5, y + 1.3, 26.5, 9, y + 1.5, 31.5, walnut)
	for _, p in { { 5.7, 26.7 }, { 8.6, 26.7 }, { 5.7, 31.1 }, { 8.6, 31.1 } } do
		box("TableLeg", p[1], y, p[2], p[1] + 0.2, y + 1.3, p[2] + 0.2, walnutDark)
	end
	box("Book", 6, y + 1.5, 27.2, 7.4, y + 1.7, 29, { Color = Color3.fromRGB(40, 70, 120) })
	box("Book", 6.1, y + 1.7, 27.4, 7.2, y + 1.85, 28.8, { Color = Color3.fromRGB(200, 170, 90) })
	box("Tablet", 7.6, y + 1.5, 29.6, 8.6, y + 1.56, 31, { Color = DARK })
	cyl("Mug", 8.2, y + 1.5, 27.4, 0.2, 0.45, { Color = Color3.fromRGB(60, 110, 70) })
	-- Floor lamp and side table.
	cyl("FloorLampBase", 2, y, 36.2, 0.6, 0.15, { Color = DARK, Material = METAL })
	box("FloorLampPole", 1.95, y + 0.15, 36.15, 2.05, y + 6, 36.25, { Color = DARK, Material = METAL })
	local fshade = cyl("FloorLampShade", 2, y + 5.6, 36.2, 0.9, 1, { Color = Color3.fromRGB(240, 225, 200), Material = Enum.Material.Fabric })
	glow(fshade, WARM, 14, 0.6)
	cyl("SideTable", 2, y, 22.2, 0.8, 1.8, walnutDark)
	cyl("Pot", 2, y + 1.8, 22.2, 0.35, 0.5, { Color = WHITE })
	ball("Succulent", 2, y + 2.5, 22.2, 0.7, { Color = Color3.fromRGB(80, 140, 90), Material = Enum.Material.Grass })

	-- Display case with a model of the S.S. Totality.
	box("Pedestal", 10, y, 33, 13, y + 3.4, 36, { Color = WHITE, Material = SMOOTH })
	box("Case", 10.1, y + 3.4, 33.1, 12.9, y + 6.2, 35.9, { Color = GLASS, Material = Enum.Material.Glass, Transparency = 0.8 })
	box("ShipHull", 10.6, y + 4.4, 34.2, 12.4, y + 4.9, 34.8, { Color = Color3.fromRGB(220, 222, 228), Material = METAL })
	box("ShipRing", 11.3, y + 4, 33.7, 11.5, y + 5.3, 35.3, { Color = STEEL, Material = METAL })
	box("ShipSail", 10.4, y + 4.62, 33.4, 10.6, y + 4.68, 35.6, { Color = Color3.fromRGB(230, 170, 60), Material = METAL })
	local caseLight = box("CaseLight", 11, y + 6.1, 34, 12, y + 6.15, 35, { Color = COOL, Material = NEON })
	glow(caseLight, COOL, 5, 0.6)
	local tag = box("CaseTag", 10.5, y + 2.4, 36, 12.5, y + 3, 36.05, { Color = DARK })
	sign(tag, "S.S. TOTALITY · 1:400", Enum.NormalId.Back, AMBER)

	-- Tall plants in the corners, art on the walls.
	for _, p in { { 1.6, 1.8 }, { 27.2, 37 } } do
		cyl("Planter", p[1], y, p[2], 0.9, 1.8, { Color = Color3.fromRGB(60, 60, 64), Material = SMOOTH })
		box("PlantStem", p[1] - 0.08, y + 1.8, p[2] - 0.08, p[1] + 0.08, y + 4.6, p[2] + 0.08, { Color = Color3.fromRGB(90, 70, 50) })
		ball("Plant", p[1], y + 5, p[2], 2.6, { Color = Color3.fromRGB(70, 120, 60), Material = Enum.Material.Grass })
		ball("Plant", p[1] + 0.5, y + 4, p[2] - 0.3, 1.6, { Color = Color3.fromRGB(80, 135, 66), Material = Enum.Material.Grass })
	end
	box("PaintingFrame", 0, y + 3.3, 31.2, 0.05, y + 7.2, 37.8, { Color = Color3.fromRGB(200, 165, 90), Material = METAL })
	local art = box("Painting", 0.05, y + 3.5, 31.4, 0.1, y + 7, 37.6, { Color = Color3.fromRGB(190, 100, 60) })
	sign(art, "SOLSTICE SOLUTIONS\nreach for the sun", Enum.NormalId.Right, Color3.fromRGB(255, 230, 200), Enum.Font.Garamond)
	-- Venetian blinds, half down, on the outside windows.
	for k = 0, 6 do
		local by = y + 9 - k * 0.32
		box("Blind", 0.25, by, 8.8, 0.3, by + 0.22, 30.4, { Color = Color3.fromRGB(235, 232, 225) })
		box("Blind", 4.2, by, 38.3, 23.8, by + 0.22, 38.35, { Color = Color3.fromRGB(235, 232, 225) })
	end
end

-- Atrium centrepiece and lobby furniture --------------------------------------------
local function atrium()
	local cx, cz = 50, 22
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
	local sy = 24
	box("Cable", cx - 0.06, sy + 3, cz - 0.06, cx + 0.06, H2, cz + 0.06, { Color = DARK, CanCollide = false })
	local sun = ball("Sun", cx, sy, cz, 6, { Color = Color3.fromRGB(255, 150, 50), Material = NEON, CanCollide = false }, orrery) :: Part
	glow(sun, Color3.fromRGB(255, 170, 90), 60, 1.4)
	orrery.PrimaryPart = sun
	local planets = {
		{ 5.2, 0.8, Color3.fromRGB(170, 160, 150) }, { 7.4, 1.2, Color3.fromRGB(230, 200, 140) },
		{ 9.6, 1.3, Color3.fromRGB(80, 130, 200) }, { 11.6, 1, Color3.fromRGB(200, 90, 50) },
		{ 13.5, 2.2, Color3.fromRGB(210, 170, 120) },
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
	box("Board", 33.5, 16.4, 0, 66, 17.4, 0.4, { Color = DARK })
	local board = box("BoardScreen", 34, 13, 0, 65.5, 16.4, 0.35, { Color = Color3.fromRGB(14, 18, 24) })
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
		B.part(model, "Back", Vector3.new(6.98, 2.6, 0.8), base * CFrame.new(0, 2.01, 1.65), fabric)
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

	-- Coffee cart under the east walkway.
	box("Cart", 80, 0.1, 40, 85, 3.4, 42.4, { Color = WHITE, Material = SMOOTH })
	box("CartTop", 79.8, 3.4, 39.8, 85.2, 3.6, 42.6, { Color = Color3.fromRGB(40, 42, 48), Material = Enum.Material.Granite })
	box("CoffeeMachine", 81, 3.6, 41, 83, 5.8, 42.4, { Color = DARK, Material = METAL })
	local cup = cyl("Cup", 83.8, 3.6, 40.6, 0.25, 0.6, { Color = WHITE })
	_ = cup
	local cs = box("CartSign", 80.4, 1.2, 39.95, 84.6, 2.6, 40, { Color = DARK })
	sign(cs, "RED DUST ROAST", Enum.NormalId.Front, AMBER)

	-- Pendant lights hanging into the atrium.
	for _, p in { { 38, 8 }, { 48, 5 }, { 64, 5 }, { 36, 34 }, { 74, 34 }, { 47, 38 }, { 67, 38 } } do
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
	panel(72, H1 - 1, 12, WARM, Vector3.new(4, 0.3, 1.6), 16)
	-- Floor 2 walkway lights on the ceiling.
	for _, p in { { 34, 44 }, { 50, 46 }, { 66, 46 }, { 82, 42 }, { 92, 24 }, { 88, 8 } } do
		panel(p[1], H2, p[2], COOL, Vector3.new(4, 0.3, 1.6), 28)
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
	terrain:FillBlock(CFrame.new(pos(49, 40, 25)), Vector3.new(124, 80, 96), Enum.Material.Air)

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
-- Generates the Martian terrain around the lobby. Can be run from the Studio
-- command bar so the terrain is saved into the place:
--   require(game.ServerScriptService.Server.Lobby).GenerateTerrain()
function Lobby.GenerateTerrain()
	landscape()
end

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
		podAnnex()
		buildPlatform()
		lockerRoom()
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
	-- In the hallway by the locker rooms, facing the steps down into the lobby.
	return CFrame.lookAt(pos(12, PLAT + 3, 30), pos(20, PLAT + 3, 30))
end

return Lobby
