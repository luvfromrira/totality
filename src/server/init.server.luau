-- Server entry point.
local Players = game:GetService("Players")

local LightingSetup = require(script.LightingSetup)
local RoomGenerator = require(script.RoomGenerator)

LightingSetup.Apply()

-- The ship floats in space: remove the default baseplate so it isn't visible through windows.
local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate then
	baseplate:Destroy()
end
RoomGenerator.Start()

-- Spawn players inside the Start room instead of on the baseplate.
local function onCharacter(character: Model)
	local rooms = workspace:WaitForChild("GeneratedRooms")
	local room1 = rooms:WaitForChild("Room1", 10)
	local spawnPoint = room1 and room1:FindFirstChild("PlayerSpawn", true)
	if spawnPoint then
		character:WaitForChild("HumanoidRootPart")
		character:PivotTo(spawnPoint.CFrame)
	end
end

local function onPlayer(player: Player)
	player.CharacterAdded:Connect(onCharacter)
	if player.Character then
		onCharacter(player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayer, player)
end
