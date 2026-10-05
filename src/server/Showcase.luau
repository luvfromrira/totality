--[[
	Showcase mode (Config.SHOWCASE = true): instead of starting a run, every
	room preset is laid out in rows on one big platform, undamaged, each with a
	name tag over its entrance. Walk in through the open entrance to look around.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local RoomPresets = require(script.Parent.RoomPresets)

local Showcase = {}

local PER_ROW = 8
local GAP = 14 -- between rooms in a row
local AISLE = 30 -- walkway between rows

local function tag(folder: Instance, cf: CFrame, room: Model)
	local anchor = Instance.new("Part")
	anchor.Name = "Tag"
	anchor.Size = Vector3.new(1, 1, 1)
	anchor.Transparency = 1
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CFrame = cf
	anchor.Parent = folder

	local light = Instance.new("PointLight")
	light.Range = 24
	light.Brightness = 0.8
	light.Color = Color3.fromRGB(200, 210, 230)
	light.Parent = anchor

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(260, 60)
	gui.MaxDistance = 150
	gui.Parent = anchor
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.Code
	text.TextScaled = true
	text.TextColor3 = Color3.fromRGB(230, 235, 245)
	text.TextStrokeTransparency = 0.4
	local min = room:GetAttribute("MinRoom") or 1
	local weight = room:GetAttribute("Weight")
	text.Text = if weight then `{room.Name}\nfrom room {min} · weight {weight}` else `{room.Name}\nfixed room`
	text.Parent = gui
end

-- Builds the showcase and returns where players should spawn.
function Showcase.Build(): CFrame
	local rooms = RoomPresets.BuildNormal()
	local special = RoomPresets.BuildSpecial()
	for _, name in { "Start", "MemorialRoom", "Midpoint", "Final" } do
		table.insert(rooms, special[name])
	end

	-- Named GeneratedRooms so client effects (flickering lamps) work here too.
	local folder = Instance.new("Folder")
	folder.Name = "GeneratedRooms"
	local base = Config.START_CFRAME.Position
	local x, z, rowDepth, maxX = 0, 0, 0, 0
	for i, room in rooms do
		local size = room:GetExtentsSize()
		if i > 1 and (i - 1) % PER_ROW == 0 then
			z -= rowDepth + AISLE
			x, rowDepth = 0, 0
		end
		-- The pivot is the room's Entrance, centred on its width.
		local entrance = base + Vector3.new(x + size.X / 2, 0, z)
		room:PivotTo(CFrame.new(entrance))
		room.Parent = folder
		tag(folder, CFrame.new(entrance + Vector3.new(0, (room:GetAttribute("H") or 10) + 4, 3)), room)
		x += size.X + GAP
		maxX = math.max(maxX, x)
		rowDepth = math.max(rowDepth, size.Z)
	end

	-- One platform under everything, its top level with the rooms' floor bottoms.
	local depth = -z + rowDepth + AISLE * 2
	local platform = Instance.new("Part")
	platform.Name = "ShowcaseFloor"
	platform.Anchored = true
	platform.Size = Vector3.new(math.min(maxX + AISLE * 2, 2048), 1, math.min(depth, 2048))
	platform.CFrame = CFrame.new(base + Vector3.new(maxX / 2, -1.5, z / 2 - rowDepth / 2 + AISLE / 2))
	platform.Color = Color3.fromRGB(40, 42, 48)
	platform.Material = Enum.Material.DiamondPlate
	platform.Parent = folder

	folder.Parent = workspace
	print(`[Totality] Showcase mode: {#rooms} rooms laid out. Set Config.SHOWCASE = false to play normally.`)
	-- On the walkway in front of the first row, facing the rooms.
	return CFrame.new(base + Vector3.new(6, 3, AISLE / 2))
end

return Showcase
