-- Server entry point.
local Players = game:GetService("Players")

local LightingSetup = require(script.LightingSetup)
local RoomGenerator = require(script.RoomGenerator)
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

LightingSetup.Apply()

-- The ship floats in space: remove the default baseplate so it isn't visible through windows.
local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate then
	baseplate:Destroy()
end
RoomGenerator.Start(Config.SEED)

-- Spawn players inside the Start room instead of on the baseplate.
-- No spawn forcefield: remove it as soon as it appears.
for _, d in workspace:GetDescendants() do
	if d:IsA("SpawnLocation") then
		d.Duration = 0
	end
end

local function onCharacter(character: Model)
	local existing = character:FindFirstChildOfClass("ForceField")
	if existing then
		existing:Destroy()
	end
	character.ChildAdded:Connect(function(child)
		if child:IsA("ForceField") then
			task.defer(child.Destroy, child)
		end
	end)
	local rooms = workspace:WaitForChild("GeneratedRooms")
	local room1 = rooms:WaitForChild("Room1", 10)
	local spawnPoint = room1 and room1:FindFirstChild("PlayerSpawn", true)
	if spawnPoint then
		character:WaitForChild("HumanoidRootPart")
		character:PivotTo(spawnPoint.CFrame)
	end
end

local function onPlayer(player: Player)
	player.CameraMode = Enum.CameraMode.LockFirstPerson
	player.CharacterAdded:Connect(onCharacter)
	if player.Character then
		onCharacter(player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayer, player)
end
