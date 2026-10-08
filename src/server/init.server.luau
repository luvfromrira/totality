-- Server entry point.
local Players = game:GetService("Players")

local LightingSetup = require(script.LightingSetup)
local RoomGenerator = require(script.RoomGenerator)
local Showcase = require(script.Showcase)
local CrewNPC = require(script.CrewNPC)
local Config = require(game:GetService("ReplicatedStorage").Shared.Config)

LightingSetup.Apply()

-- The ship floats in space: remove the default baseplate so it isn't visible through windows.
local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate then
	baseplate:Destroy()
end
local showcaseSpawn: CFrame? = nil
if Config.SHOWCASE then
	showcaseSpawn = Showcase.Build()
else
	RoomGenerator.Start(Config.SEED)
	-- Characters already placed in the Workspace by hand are skipped.
	if Config.PREVIEW_NPC then
		-- They stand side by side a few studs in front of where players spawn, facing them.
		task.spawn(function()
			local room1 = workspace:WaitForChild("GeneratedRooms"):WaitForChild("Room1", 10)
			local spawnPoint = room1 and room1:FindFirstChild("PlayerSpawn", true)
			if spawnPoint then
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Include
				params.FilterDescendantsInstances = { room1 }
				for i, name in CrewNPC.Names do
					if not workspace:FindFirstChild(name) then
						local side = (i - (#CrewNPC.Names + 1) / 2) * 3.5
						local at = spawnPoint.CFrame * CFrame.new(side, 0, -8)
						local hit = workspace:Raycast(at.Position, Vector3.new(0, -10, 0), params)
						local ground = if hit then hit.Position else at.Position - Vector3.new(0, 3, 0)
						local facing = ground - spawnPoint.CFrame.LookVector
						local ok, err = pcall(CrewNPC.Spawn, name, CFrame.lookAt(ground, facing), room1)
						if not ok then
							warn(`[Totality] Couldn't spawn preview {name}: {err}`)
						end
					end
				end
			end
		end)
	end
end

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
	if showcaseSpawn then
		character:WaitForChild("HumanoidRootPart")
		character:PivotTo(showcaseSpawn)
		return
	end
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
