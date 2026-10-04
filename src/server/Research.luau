--[[
	Spawns collectible research items and tracks how many the team has found.

	Items go in random spots each run: the room's floors are sampled at random
	points, a ray finds the surface actually there (floor, desk, counter...),
	and the spot is kept only if nothing solid is in the way.
	ResearchSpawn parts in a preset are added as extra candidate spots.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Research = {}

local SAMPLES = 24 -- random points tried per room
local MIN_SPACING = 6 -- studs between two items in the same room
local EDGE_MARGIN = 2 -- keep away from walls

ReplicatedStorage:SetAttribute("ResearchCollected", 0)

local function createItem(cframe: CFrame): BasePart
	local item = Instance.new("Part")
	item.Name = "Research"
	item.Size = Vector3.new(1.2, 0.2, 1.6)
	item.CFrame = cframe
	item.Anchored = true
	item.CanCollide = false
	item.Material = Enum.Material.Neon
	item.Color = Color3.fromRGB(170, 200, 255)

	local glow = Instance.new("PointLight")
	glow.Color = item.Color
	glow.Range = 6
	glow.Brightness = 0.8
	glow.Parent = item

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Collect"
	prompt.ObjectText = "Research"
	prompt.HoldDuration = 0 -- instant grab
	prompt.RequiresLineOfSight = false
	prompt.Parent = item
	prompt.Triggered:Connect(function()
		item:Destroy()
		local count = ReplicatedStorage:GetAttribute("ResearchCollected") + 1
		ReplicatedStorage:SetAttribute("ResearchCollected", count)
	end)
	return item
end

-- Finds the surface below `origin` inside the room and checks there's room for an item.
local function trySpot(room: Model, origin: Vector3, rayParams: RaycastParams, overlapParams: OverlapParams): CFrame?
	local hit = workspace:Raycast(origin, Vector3.new(0, -8, 0), rayParams)
	if not hit or hit.Normal.Y < 0.9 then
		return nil
	end
	-- Space above the surface must be empty (catches spots inside shelves, pillars, etc.).
	local clearance = CFrame.new(hit.Position + Vector3.new(0, 1.1, 0))
	for _, p in workspace:GetPartBoundsInBox(clearance, Vector3.new(1.8, 2, 1.8), overlapParams) do
		if p.CanCollide then
			return nil
		end
	end
	return CFrame.new(hit.Position + Vector3.new(0, 0.1, 0))
end

function Research.PopulateRoom(room: Model, rng: Random)
	if (room:GetAttribute("RoomNumber") or 0) <= 1 then
		return
	end
	local count = rng:NextInteger(Config.RESEARCH_MIN, Config.RESEARCH_MAX)
	if count <= 0 then
		return
	end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Include
	rayParams.FilterDescendantsInstances = { room }
	rayParams.RespectCanCollide = true
	local overlapParams = OverlapParams.new()
	overlapParams.FilterType = Enum.RaycastFilterType.Include
	overlapParams.FilterDescendantsInstances = { room }

	local floors, candidates = {}, {}
	for _, d in room:GetDescendants() do
		if d:IsA("BasePart") then
			if d.Name == "Floor" or d.Name == "Landing" then
				table.insert(floors, d)
			elseif d.Name == "ResearchSpawn" then
				table.insert(candidates, d.Position + Vector3.new(0, 2, 0))
			end
		end
	end
	for _ = 1, SAMPLES do
		local floor = floors[rng:NextInteger(1, math.max(#floors, 1))]
		if floor then
			local half = floor.Size / 2 - Vector3.new(EDGE_MARGIN, 0, EDGE_MARGIN)
			local offset = Vector3.new(rng:NextNumber(-half.X, half.X), half.Y + 6, rng:NextNumber(-half.Z, half.Z))
			table.insert(candidates, floor.CFrame:PointToWorldSpace(offset))
		end
	end

	-- Shuffle so marker spots aren't always picked first.
	for i = #candidates, 2, -1 do
		local j = rng:NextInteger(1, i)
		candidates[i], candidates[j] = candidates[j], candidates[i]
	end

	local placed = {}
	for _, origin in candidates do
		if #placed >= count then
			break
		end
		local spot = trySpot(room, origin, rayParams, overlapParams)
		if spot then
			local tooClose = false
			for _, other in placed do
				if (other.Position - spot.Position).Magnitude < MIN_SPACING then
					tooClose = true
					break
				end
			end
			if not tooClose then
				local angle = rng:NextNumber(0, math.pi * 2)
				createItem(spot * CFrame.Angles(0, angle, 0)).Parent = room
				table.insert(placed, spot)
			end
		end
	end
end

return Research
