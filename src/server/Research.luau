-- Spawns collectible research items and tracks how many the team has found.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Research = {}

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

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Collect"
	prompt.ObjectText = "Research"
	prompt.HoldDuration = 0.5
	prompt.Parent = item
	prompt.Triggered:Connect(function()
		item:Destroy()
		local count = ReplicatedStorage:GetAttribute("ResearchCollected") + 1
		ReplicatedStorage:SetAttribute("ResearchCollected", count)
	end)
	return item
end

function Research.PopulateRoom(room: Model, rng: Random)
	for _, spawnPoint in room:GetDescendants() do
		if spawnPoint.Name == "ResearchSpawn" and spawnPoint:IsA("BasePart") then
			if rng:NextNumber() < Config.RESEARCH_CHANCE then
				createItem(spawnPoint.CFrame).Parent = room
			end
		end
	end
end

return Research
