--[[
	Spawns collectible research items and tracks how many the team has found.

	Items go in random spots each run: the room's floors are sampled at random
	points, a ray finds the surface actually there (floor, desk, counter...),
	and the spot is kept only if nothing solid is in the way.
	ResearchSpawn parts in a preset are added as extra candidate spots.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Research = {}

local SAMPLES = 24 -- random points tried per room
local MIN_SPACING = 6 -- studs between two items in the same room
local EDGE_MARGIN = 2 -- keep away from walls

ReplicatedStorage:SetAttribute("ResearchCollected", 0)

local MANILA = Color3.fromRGB(196, 168, 112)
local PAPER = Color3.fromRGB(232, 228, 214)

local function piece(model: Model, name: string, size: Vector3, cframe: CFrame, color: Color3): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cframe
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CastShadow = false
	p.Material = Enum.Material.SmoothPlastic
	p.Color = color
	p.Parent = model
	return p
end

-- A manila research folder with papers poking out, lying on the surface at `cframe`.
local function buildFolder(cframe: CFrame, rng: Random): Model
	local model = Instance.new("Model")
	model.Name = "Research"

	local back = piece(model, "Cover", Vector3.new(1.6, 0.03, 2.1), cframe * CFrame.new(0, 0.015, 0), MANILA)
	piece(model, "Tab", Vector3.new(0.6, 0.03, 0.18), cframe * CFrame.new(-0.35, 0.015, -1.13), MANILA)
	-- Loose sheets, each slightly skewed so they stick out past the cover.
	for i = 1, 4 do
		local skew = CFrame.Angles(0, math.rad(rng:NextNumber(-7, 7)), 0)
		local shift = CFrame.new(rng:NextNumber(-0.12, 0.12), 0.03 + i * 0.012, rng:NextNumber(-0.15, 0.1))
		local sheet = piece(model, "Paper", Vector3.new(1.45, 0.01, 1.95), cframe * shift * skew, PAPER)
		-- A few dark lines of "text" on the top sheet.
		if i == 4 then
			for line = 0, 5 do
				local w = if line == 0 then 0.7 else rng:NextNumber(0.8, 1.15)
				piece(model, "Text", Vector3.new(w, 0.004, 0.05),
					sheet.CFrame * CFrame.new(-0.55 + w / 2, 0.007, -0.7 + line * 0.2), Color3.fromRGB(60, 60, 66))
			end
		end
	end
	-- Front cover lies open a little, hinged at the left edge.
	local hinge = cframe * CFrame.new(-0.8, 0.1, 0) * CFrame.Angles(0, math.rad(rng:NextNumber(-6, 6)), math.rad(rng:NextNumber(3, 9)))
	local front = piece(model, "Cover", Vector3.new(1.6, 0.03, 2.1), hinge * CFrame.new(0.8, 0, 0), MANILA)
	-- Solstice Solutions stamp and a classification strip on the cover.
	piece(model, "Stamp", Vector3.new(0.4, 0.004, 0.4), front.CFrame * CFrame.new(0.35, 0.017, -0.5), Color3.fromRGB(220, 120, 40))
	piece(model, "Strip", Vector3.new(1.6, 0.004, 0.16), front.CFrame * CFrame.new(0, 0.017, 0.75), Color3.fromRGB(150, 30, 30))
	model.PrimaryPart = back
	return model
end

-- Copy of ServerStorage.ResearchModel (e.g. a Toolbox model) resting on the surface at `cframe`.
local function cloneCustom(template: Model, cframe: CFrame): Model
	local model = template:Clone()
	for _, d in model:GetDescendants() do
		if d:IsA("BaseScript") or d:IsA("ModuleScript") then
			d:Destroy() -- Toolbox scripts can be malicious; never run them.
		elseif d:IsA("BasePart") then
			d.Anchored = true
			d.CanCollide = false
			d.CanQuery = false
		end
	end
	model:PivotTo(cframe)
	-- Lift it so the bottom of its bounding box sits on the surface.
	local box, size = model:GetBoundingBox()
	local lift = cframe.Position.Y - (box.Position.Y - size.Y / 2)
	model:PivotTo(cframe + Vector3.new(0, lift, 0))
	if not model.PrimaryPart then
		model.PrimaryPart = model:FindFirstChildWhichIsA("BasePart", true)
	end
	return model
end

local function createItem(cframe: CFrame, rng: Random): Model
	local template = ServerStorage:FindFirstChild("ResearchModel")
	local model = if template and template:IsA("Model") and template:FindFirstChildWhichIsA("BasePart", true)
		then cloneCustom(template, cframe)
		else buildFolder(cframe, rng)
	model.Name = "Research"
	local back = model.PrimaryPart :: BasePart

	-- Faint glow so it can still be spotted in dark rooms.
	local glow = Instance.new("PointLight")
	glow.Color = Color3.fromRGB(255, 225, 170)
	glow.Range = 5
	glow.Brightness = 0.5
	glow.Parent = back

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Collect"
	prompt.ObjectText = "Research"
	prompt.HoldDuration = 0 -- instant grab
	prompt.RequiresLineOfSight = false
	prompt.Parent = back
	prompt.Triggered:Connect(function()
		if not model.Parent then
			return
		end
		model:Destroy()
		local count = ReplicatedStorage:GetAttribute("ResearchCollected") + 1
		ReplicatedStorage:SetAttribute("ResearchCollected", count)
	end)
	return model
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
	return CFrame.new(hit.Position)
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
				createItem(spot * CFrame.Angles(0, angle, 0), rng).Parent = room
				table.insert(placed, spot)
			end
		end
	end
end

return Research
