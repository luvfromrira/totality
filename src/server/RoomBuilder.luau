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
		Color = color,
		CanCollide = false,
	}) :: Part
	local light = Instance.new("SurfaceLight")
	light.Face = Enum.NormalId.Bottom
	light.Angle = 120
	light.Color = color
	light.Brightness = brightness or 1.4
	light.Range = range or 18
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
		Color = color,
		CanCollide = false,
	}) :: Part
	local light = Instance.new("PointLight")
	light.Color = color
	light.Range = range or 18
	light.Brightness = brightness or 1.3
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
	`opening` cuts a doorway: { x = offset along the wall, y = bottom, w, h }.
]]
function RoomBuilder.wall(parent: Instance, cf: CFrame, span: number, height: number, pal: Palette, opening: { [string]: number }?)
	local function piece(x0: number, x1: number, y0: number, y1: number)
		part(parent, "Wall", Vector3.new(x1 - x0, y1 - y0, 1),
			cf * CFrame.new((x0 + x1) / 2, (y0 + y1) / 2, -0.5),
			{ Color = pal.wall, Material = pal.wallMat })
	end
	local left, right = -span / 2, span / 2
	if not opening then
		piece(left, right, 0, height)
		return
	end
	local ox0, ox1 = opening.x - opening.w / 2, opening.x + opening.w / 2
	local oy0, oy1 = opening.y, math.min(opening.y + opening.h, height)
	piece(left, ox0, 0, height)
	piece(ox1, right, 0, height)
	piece(ox0, ox1, 0, oy0)
	piece(ox0, ox1, oy1, height)
end

-- Frame + Door filling an opening made by `wall` (same cf/opening).
local function doorway(parent: Instance, cf: CFrame, opening: { [string]: number }, pal: Palette)
	local x, y, w, h = opening.x, opening.y, opening.w, opening.h
	local jamb = 0.5
	local frameProps = { Color = pal.trim, Material = Enum.Material.Wood }
	part(parent, "Frame", Vector3.new(jamb, h, 1.2), cf * CFrame.new(x - w / 2 + jamb / 2, y + h / 2, -0.5), frameProps)
	part(parent, "Frame", Vector3.new(jamb, h, 1.2), cf * CFrame.new(x + w / 2 - jamb / 2, y + h / 2, -0.5), frameProps)
	part(parent, "Frame", Vector3.new(w - jamb * 2, jamb, 1.2), cf * CFrame.new(x, y + h - jamb / 2, -0.5), frameProps)
	part(parent, "Door", Vector3.new(w - jamb * 2, h - jamb, 0.4),
		cf * CFrame.new(x, y + (h - jamb) / 2, -0.5),
		{ Color = Color3.fromRGB(96, 74, 56), Material = Enum.Material.Wood })
	-- Light above every door so the exit is always easy to find.
	RoomBuilder.bulb(parent, (cf * CFrame.new(x, y + h + 0.6, 0.9)).Position, pal.light, 14, 1.1, 0.8)
end

--[[
	Builds floor, ceiling, all four walls, doorways and the Entrance/Exit markers.
	opts:
	  entrance  boolean, default true (false = solid back wall, e.g. the Start room)
	  exit      "front" | "left" | "right" | "none" (default "front")
	  exitY     height of the exit doorway's floor (default 0, used by stairs)
]]
function RoomBuilder.shell(model: Model, w: number, L: number, h: number, pal: Palette, opts: { [string]: any }?)
	local o = opts or {}
	local exit = o.exit or "front"
	local exitY = o.exitY or 0
	local footprint = Vector3.new(w + 2, 1, L + 2)

	part(model, "Floor", footprint, CFrame.new(0, -0.5, -L / 2), { Color = pal.floor, Material = pal.floorMat })
	part(model, "Ceiling", footprint, CFrame.new(0, h + 0.5, -L / 2), { Color = pal.ceiling, Material = pal.ceilingMat })

	local door = { x = 0, y = 0, w = RoomBuilder.DOOR_WIDTH, h = RoomBuilder.DOOR_HEIGHT }
	local exitDoor = { x = 0, y = exitY, w = RoomBuilder.DOOR_WIDTH, h = RoomBuilder.DOOR_HEIGHT }

	local walls = {
		back = CFrame.new(0, 0, 0) * CFrame.Angles(0, math.pi, 0),
		front = CFrame.new(0, 0, -L),
		left = CFrame.new(-w / 2, 0, -L / 2) * CFrame.Angles(0, math.rad(90), 0),
		right = CFrame.new(w / 2, 0, -L / 2) * CFrame.Angles(0, math.rad(-90), 0),
	}
	local spans = { back = w, front = w, left = L + 2, right = L + 2 }

	RoomBuilder.wall(model, walls.back, w, h, pal, if o.entrance ~= false then door else nil)
	for _, side in { "front", "left", "right" } do
		local isExit = side == exit
		RoomBuilder.wall(model, walls[side], spans[side], h, pal, if isExit then exitDoor else nil)
		if isExit then
			doorway(model, walls[side], exitDoor, pal)
			RoomBuilder.marker(model, "Exit", walls[side] * CFrame.new(0, exitY, -1))
		end
	end

	RoomBuilder.marker(model, "Entrance", CFrame.new(0, 0, 1))
	model.PrimaryPart = model:FindFirstChild("Entrance") :: BasePart
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
