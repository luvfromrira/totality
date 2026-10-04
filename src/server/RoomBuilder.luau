--[[
	Helpers for building rooms out of parts without gaps or z-fighting.

	Room layout in local space (players walk toward -Z):
	  interior        x from -w/2 to w/2, z from 0 to -L, y from 0 to h
	  entrance wall   z from 1 to 0     (Entrance marker on its outer face, z = 1)
	  exit wall       z from -L to -L-1 (Exit marker on its outer face)
	  side walls      1 stud thick outside the interior, running the full length
	                  so the corners are filled
	  floor/ceiling   cover the whole footprint, walls included

	Rules that keep surfaces clean:
	  - Parts never overlap. They only touch, so no two faces share a plane
	    while facing the same way (that's what causes z-fighting).
	  - Rooms must be at least 10 studs tall (door + the lamp above it).
	  - Only the exit doorway gets a frame. The next room's entrance doorway
	    is a plain opening, so the two rooms' walls sit back to back cleanly.
]]

local RoomBuilder = {}

RoomBuilder.DOOR_WIDTH = 6
RoomBuilder.DOOR_HEIGHT = 9
local DOOR_CLEAR = RoomBuilder.DOOR_WIDTH / 2 + 1

export type Palette = {
	wall: Color3,
	wallMat: Enum.Material,
	floor: Color3,
	floorMat: Enum.Material,
	ceiling: Color3,
	ceilingMat: Enum.Material,
	trim: Color3,
	light: Color3,
}

function RoomBuilder.part(parent: Instance, name: string, size: Vector3, cframe: CFrame, props: { [string]: any }?): Part?
	if size.X < 0.01 or size.Y < 0.01 or size.Z < 0.01 then
		return nil
	end
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.CFrame = cframe
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.SmoothPlastic
	for k, v in props or {} do
		(p :: any)[k] = v
	end
	p.Parent = parent
	return p
end
local part = RoomBuilder.part

function RoomBuilder.marker(parent: Instance, name: string, cframe: CFrame)
	return part(parent, name, Vector3.new(1, 1, 1), cframe, {
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		CanTouch = false,
	})
end

-- Fluorescent ceiling panel. `y` is the ceiling height; the panel sits flush under it.
function RoomBuilder.panel(parent: Instance, x: number, y: number, z: number, color: Color3,
	brightness: number?, range: number?, size: Vector3?)
	local s = size or Vector3.new(4, 0.3, 1.6)
	local p = part(parent, "Lamp", s, CFrame.new(x, y - s.Y / 2, z), {
		Material = Enum.Material.Neon,
		Color = color:Lerp(Color3.new(0, 0, 0), 0.35),
		CanCollide = false,
	}) :: Part
	local light = Instance.new("SurfaceLight")
	light.Face = Enum.NormalId.Bottom
	light.Angle = 120
	light.Color = color
	light.Brightness = brightness or 0.8
	light.Range = range or 16
	light.Shadows = true
	light.Parent = p
	return p
end

-- Grid of ceiling panels evenly spread over the interior.
function RoomBuilder.panelGrid(parent: Instance, w: number, L: number, h: number, cols: number, rows: number,
	color: Color3, brightness: number?, range: number?)
	for i = 1, rows do
		for j = 1, cols do
			local x = -w / 2 + (j - 0.5) * (w / cols)
			local z = -(i - 0.5) * (L / rows)
			RoomBuilder.panel(parent, x, h, z, color, brightness, range)
		end
	end
end

-- Glowing bulb / sconce with a point light.
function RoomBuilder.bulb(parent: Instance, position: Vector3, color: Color3, range: number?, brightness: number?, size: number?)
	local d = size or 1.2
	local p = part(parent, "Lamp", Vector3.new(d, d, d), CFrame.new(position), {
		Shape = Enum.PartType.Ball,
		Material = Enum.Material.Neon,
		Color = color:Lerp(Color3.new(0, 0, 0), 0.35),
		CanCollide = false,
	}) :: Part
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = range or 16
	light.Brightness = brightness or 0.8
	light.Shadows = true
	light.Parent = p
	return p
end

-- Text on a part face (signs, room numbers, clocks).
function RoomBuilder.label(target: BasePart, text: string, face: Enum.NormalId, color: Color3?, font: Enum.Font?)
	local gui = Instance.new("SurfaceGui")
	gui.Face = face
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 40
	gui.LightInfluence = 1
	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextScaled = true
	t.Font = font or Enum.Font.Arial
	t.TextColor3 = color or Color3.fromRGB(30, 30, 30)
	t.Parent = gui
	gui.Parent = target
	return gui
end

--[[
	Wall slab. `cf` is the centre of the wall's inner face at floor level,
	LookVector pointing out of the room. The slab fills 1 stud outward from there.
	`openings` cut holes in it: { { x = offset along the wall, y = bottom, w, h }, ... }
	(must not overlap each other).
]]
function RoomBuilder.wall(parent: Instance, cf: CFrame, span: number, height: number, pal: Palette,
	openings: { { [string]: number } }?)
	local function piece(x0: number, x1: number, y0: number, y1: number)
		part(parent, "Wall", Vector3.new(x1 - x0, y1 - y0, 1),
			cf * CFrame.new((x0 + x1) / 2, (y0 + y1) / 2, -0.5),
			{ Color = pal.wall, Material = pal.wallMat })
	end
	local list = table.clone(openings or {})
	table.sort(list, function(a, b)
		return a.x < b.x
	end)
	local cursor = -span / 2
	for _, o in list do
		local ox0, ox1 = o.x - o.w / 2, o.x + o.w / 2
		piece(cursor, ox0, 0, height)
		piece(ox0, ox1, 0, o.y)
		piece(ox0, ox1, math.min(o.y + o.h, height), height)
		cursor = ox1
	end
	piece(cursor, span / 2, 0, height)
end

-- Frame strips lining the inside edges of an opening (they stick out 0.1 past the wall).
local function frame(parent: Instance, cf: CFrame, o: { [string]: number }, t: number, props: { [string]: any }, bottom: boolean)
	part(parent, "Frame", Vector3.new(t, o.h, 1.2), cf * CFrame.new(o.x - o.w / 2 + t / 2, o.y + o.h / 2, -0.5), props)
	part(parent, "Frame", Vector3.new(t, o.h, 1.2), cf * CFrame.new(o.x + o.w / 2 - t / 2, o.y + o.h / 2, -0.5), props)
	part(parent, "Frame", Vector3.new(o.w - t * 2, t, 1.2), cf * CFrame.new(o.x, o.y + o.h - t / 2, -0.5), props)
	if bottom then
		part(parent, "Frame", Vector3.new(o.w - t * 2, t, 1.2), cf * CFrame.new(o.x, o.y + t / 2, -0.5), props)
	end
end

-- Frame + sliding bulkhead Door filling an opening made by `wall`.
local function doorway(parent: Instance, cf: CFrame, o: { [string]: number }, pal: Palette)
	local t = 0.5
	frame(parent, cf, o, t, { Color = pal.trim, Material = Enum.Material.Metal }, false)
	part(parent, "Door", Vector3.new(o.w - t * 2, o.h - t, 0.4),
		cf * CFrame.new(o.x, o.y + (o.h - t) / 2, -0.5),
		{ Color = Color3.fromRGB(88, 92, 100), Material = Enum.Material.DiamondPlate })
	-- Small indicator light above every door so the exit is always easy to find.
	local light = RoomBuilder.bulb(parent, (cf * CFrame.new(o.x, o.y + o.h + 0.6, 0.9)).Position, Color3.fromRGB(120, 220, 160), 12, 0.8, 0.6)
	light.Name = "ExitLight" -- not a "Lamp", so ship damage never breaks it
end

-- Framed glass window in an opening made by `wall`, looking out into space.
local function window(parent: Instance, cf: CFrame, o: { [string]: number }, pal: Palette)
	local t = 0.4
	frame(parent, cf, o, t, { Color = pal.trim, Material = Enum.Material.Metal }, true)
	part(parent, "Window", Vector3.new(o.w - t * 2, o.h - t * 2, 0.2), cf * CFrame.new(o.x, o.y + o.h / 2, -0.5), {
		Material = Enum.Material.Glass,
		Color = Color3.fromRGB(170, 190, 210),
		Transparency = 0.8,
		CastShadow = false,
	})
end

--[[
	Builds floor, ceiling, all four walls, doorways and the Entrance/Exit markers.
	opts:
	  entrance  boolean, default true (false = solid back wall, e.g. the Start room)
	  exit      "front" | "left" | "right" | "none" (default "front")
	  exitY     height of the exit doorway's floor (default 0, used by stairs)
	  windows   list of { side = "left" | "right" | "front", z or x = centre, y = bottom, w, h }
	            (side walls use z, the room's depth; the front wall uses x)
]]
function RoomBuilder.shell(model: Model, w: number, L: number, h: number, pal: Palette, opts: { [string]: any }?)
	local o = opts or {}
	local exit = o.exit or "front"
	local exitY = o.exitY or 0
	local footprint = Vector3.new(w + 2, 1, L + 2)

	part(model, "Floor", footprint, CFrame.new(0, -0.5, -L / 2), { Color = pal.floor, Material = pal.floorMat })
	part(model, "Ceiling", footprint, CFrame.new(0, h + 0.5, -L / 2), { Color = pal.ceiling, Material = pal.ceilingMat })

	local walls = {
		back = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.pi, 0),
		front = CFrame.new(0, 0, -L),
		left = CFrame.new(-w / 2, 0, -L / 2) * CFrame.Angles(0, math.rad(90), 0),
		right = CFrame.new(w / 2, 0, -L / 2) * CFrame.Angles(0, math.rad(-90), 0),
	}
	local spans = { back = w, front = w, left = L + 2, right = L + 2 }

	-- Gather each wall's openings: doorways first, then windows.
	local openings = { back = {}, front = {}, left = {}, right = {} }
	local windowsBySide = { back = {}, front = {}, left = {}, right = {} }
	if o.entrance ~= false then
		table.insert(openings.back, { x = 0, y = 0, w = RoomBuilder.DOOR_WIDTH, h = RoomBuilder.DOOR_HEIGHT })
	end
	local exitDoor = { x = 0, y = exitY, w = RoomBuilder.DOOR_WIDTH, h = RoomBuilder.DOOR_HEIGHT }
	if openings[exit] then
		table.insert(openings[exit], exitDoor)
	end
	for _, win in o.windows or {} do
		-- Convert room depth (z) into a position along the side wall.
		local x = win.x or 0
		if win.side == "left" then
			x = -(win.z + L / 2)
		elseif win.side == "right" then
			x = win.z + L / 2
		end
		local opening = { x = x, y = win.y, w = win.w, h = win.h }
		table.insert(openings[win.side], opening)
		table.insert(windowsBySide[win.side], opening)
	end

	for side, cf in walls do
		RoomBuilder.wall(model, cf, spans[side], h, pal, openings[side])
		for _, win in windowsBySide[side] do
			window(model, cf, win, pal)
		end
	end
	if openings[exit] then
		doorway(model, walls[exit], exitDoor, pal)
		RoomBuilder.marker(model, "Exit", walls[exit] * CFrame.new(0, exitY, -1))
	end

	RoomBuilder.marker(model, "Entrance", CFrame.new(0, 0, 1))
	model.PrimaryPart = model:FindFirstChild("Entrance") :: BasePart
	-- Remembered for the ship-detail pass that runs after the room is furnished.
	model:SetAttribute("W", w)
	model:SetAttribute("L", L)
	model:SetAttribute("H", h)
	model:SetAttribute("TrimColor", pal.trim)
	model:SetAttribute("HasEntrance", o.entrance ~= false)
end

--[[
	Ship-detail pass, run after a room is fully furnished. Adds spaceship
	structure everywhere it fits:
	  - frame rings: a ceiling beam with a rib down each side wall
	  - conduit pipes along the upper wall edges
	  - wall vents near the floor
	  - small guide lights along the floor edges
	  - hazard strips in front of each doorway
	Every piece is checked against what's already in the room and skipped if
	it would intersect anything (furniture, windows, doors, lamps, signs...).
]]
local function aabb(p: BasePart): (Vector3, Vector3)
	local h = p.Size / 2
	local c = p.CFrame
	local r, u, l = c.RightVector, c.UpVector, c.LookVector
	local e = Vector3.new(
		math.abs(r.X) * h.X + math.abs(u.X) * h.Y + math.abs(l.X) * h.Z,
		math.abs(r.Y) * h.X + math.abs(u.Y) * h.Y + math.abs(l.Y) * h.Z,
		math.abs(r.Z) * h.X + math.abs(u.Z) * h.Y + math.abs(l.Z) * h.Z
	)
	return c.Position - e, c.Position + e
end

local STRUCTURE = { Floor = true, Ceiling = true, Wall = true }

function RoomBuilder.shipDetails(model: Model)
	local w, L, h = model:GetAttribute("W"), model:GetAttribute("L"), model:GetAttribute("H")
	if not w then
		return
	end
	local trim: Color3 = model:GetAttribute("TrimColor")

	-- Hazard strips just inside each doorway.
	local hazard = { Color = Color3.fromRGB(200, 160, 40), Material = Enum.Material.SmoothPlastic, CanCollide = false }
	local exit = model:FindFirstChild("Exit") :: BasePart?
	if exit then
		part(model, "Hazard", Vector3.new(RoomBuilder.DOOR_WIDTH, 0.05, 1), exit.CFrame * CFrame.new(0, 0.025, 1.65), hazard)
	end
	if model:GetAttribute("HasEntrance") then
		part(model, "Hazard", Vector3.new(RoomBuilder.DOOR_WIDTH, 0.05, 1), CFrame.new(0, 0.025, -0.5), hazard)
	end

	local obstacles = {}
	for _, d in model:GetDescendants() do
		if d:IsA("BasePart") and not STRUCTURE[d.Name] and d.Transparency < 1 then
			local mn, mx = aabb(d)
			-- Keep clear of doorways and windows, not just touching them.
			if d.Name == "Door" or d.Name == "Window" or d.Name == "ExitLight" then
				mn -= Vector3.one * 1.5
				mx += Vector3.one * 1.5
			end
			table.insert(obstacles, { mn, mx })
		end
	end
	-- The entrance doorway has no parts in it, so block it off explicitly.
	table.insert(obstacles, { Vector3.new(-DOOR_CLEAR, 0, -1.5), Vector3.new(DOOR_CLEAR, RoomBuilder.DOOR_HEIGHT + 1, 1) })

	local function free(size: Vector3, cf: CFrame): boolean
		local h2 = size / 2 - Vector3.one * 0.01
		local mn, mx = cf.Position - h2, cf.Position + h2
		for _, o in obstacles do
			if mn.X < o[2].X and mx.X > o[1].X and mn.Y < o[2].Y and mx.Y > o[1].Y and mn.Z < o[2].Z and mx.Z > o[1].Z then
				return false
			end
		end
		return true
	end
	local function add(name: string, size: Vector3, cf: CFrame, props: { [string]: any }, axisAligned: boolean?): boolean
		if not free(size, cf) then
			return false
		end
		local p = part(model, name, size, cf, props)
		if p and axisAligned ~= false then
			local mn, mx = aabb(p)
			table.insert(obstacles, { mn, mx })
		end
		return true
	end

	local metal = { Color = trim, Material = Enum.Material.Metal }
	local dark = { Color = Color3.fromRGB(35, 37, 42), Material = Enum.Material.Metal }

	-- Frame rings: try every 2 studs, keep them at least 8 apart.
	local lastZ: number? = nil
	for z = -3, -L + 3, -2 do
		if lastZ == nil or lastZ - z >= 8 then
			if add("Beam", Vector3.new(w, 0.6, 0.8), CFrame.new(0, h - 0.3, z), metal) then
				lastZ = z
				for _, sx in { -1, 1 } do
					add("Rib", Vector3.new(0.4, h - 0.6, 0.8), CFrame.new(sx * (w / 2 - 0.2), (h - 0.6) / 2, z), metal)
				end
			end
		end
	end

	-- Conduit along the upper edges of the side walls (only where it fits the whole way).
	for _, sx in { -1, 1 } do
		add("Conduit", Vector3.new(0.5, 0.5, L), CFrame.new(sx * (w / 2 - 0.25), h - 1.6, -L / 2), dark)
	end

	-- Vents and guide lights along both side walls.
	local i = 0
	for z = -2, -L + 2, -3 do
		i += 1
		for _, sx in { -1, 1 } do
			add("GuideLight", Vector3.new(0.3, 0.12, 0.5), CFrame.new(sx * (w / 2 - 0.15), 0.06, z),
				{ Color = Color3.fromRGB(40, 110, 140), Material = Enum.Material.Neon, CanCollide = false, CastShadow = false })
			if i % 4 == 2 then
				add("Vent", Vector3.new(0.1, 1, 2), CFrame.new(sx * (w / 2 - 0.05), 1.4, z), dark)
			end
		end
	end
end

-- Baseboard trim along both side walls (don't use in rooms with a side exit).
function RoomBuilder.baseboards(model: Model, w: number, L: number, color: Color3)
	for _, sx in { -1, 1 } do
		part(model, "Baseboard", Vector3.new(0.2, 0.6, L), CFrame.new(sx * (w / 2 - 0.1), 0.3, -L / 2),
			{ Color = color })
	end
end

-- A flat decoration against a side wall (fake door, poster, board...).
-- side = -1 left wall, 1 right wall. Sits on the wall face, `depth` thick.
function RoomBuilder.onWall(model: Model, w: number, side: number, z: number, y: number, size: Vector2, depth: number,
	name: string, props: { [string]: any })
	return part(model, name, Vector3.new(depth, size.Y, size.X),
		CFrame.new(side * (w / 2 - depth / 2), y, z), props)
end

function RoomBuilder.newRoom(name: string, attrs: { [string]: any }?): Model
	local model = Instance.new("Model")
	model.Name = name
	for k, v in attrs or {} do
		model:SetAttribute(k, v)
	end
	return model
end

return RoomBuilder
