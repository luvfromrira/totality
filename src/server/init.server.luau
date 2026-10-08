-- Server entry point.
local Players = game:GetService("Players")

local LightingSetup = require(script.LightingSetup)
local RoomGenerator = require(script.RoomGenerator)
local Showcase = require(script.Showcase)
local CrewNPC = require(script.CrewNPC)
local Lobby = require(script.Lobby)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

LightingSetup.Apply()

-- The ship floats in space: remove the default baseplate so it isn't visible through windows.
local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate then
	baseplate:Destroy()
end
-- Stands the cutscene characters side by side a few studs in front of where
-- players spawn in room 1, facing them. Ones placed in the Workspace by hand are skipped.
local function previewCharacters()
	task.spawn(function()
		local room1 = workspace:WaitForChild("GeneratedRooms"):WaitForChild("Room1", 10)
		local spawnPoint = room1 and room1:FindFirstChild("PlayerSpawn", true)
		if not spawnPoint then
			return
		end
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
	end)
end

-- Starts the 100-room run (once per server).
local function startRun()
	if ReplicatedStorage:GetAttribute("RunStarted") then
		return
	end
	ReplicatedStorage:SetAttribute("RunStarted", true)
	RoomGenerator.Start(Config.SEED)
	if Config.PREVIEW_NPC then
		previewCharacters()
	end
end

local function room1Spawn(): CFrame?
	local rooms = workspace:WaitForChild("GeneratedRooms")
	local room1 = rooms:WaitForChild("Room1", 10)
	local spawnPoint = room1 and room1:FindFirstChild("PlayerSpawn", true)
	return spawnPoint and spawnPoint.CFrame
end

-- Third person in the lobby, locked first person on the ship.
local function setLobbyCamera(player: Player, inLobby: boolean)
	if inLobby then
		player.CameraMode = Enum.CameraMode.Classic
		player.CameraMinZoomDistance = 6
		player.CameraMaxZoomDistance = 24
	else
		player.CameraMinZoomDistance = 0.5
		player.CameraMaxZoomDistance = 0.5
		player.CameraMode = Enum.CameraMode.LockFirstPerson
	end
end

local showcaseSpawn: CFrame? = nil
local lobbySpawn: CFrame? = nil
if Config.SHOWCASE then
	showcaseSpawn = Showcase.Build()
elseif Config.LOBBY then
	lobbySpawn = Lobby.Build()
	-- A pod launched: start the run and send its crew up to room 1.
	Lobby.OnLaunch = function(crew: { Player })
		startRun()
		local target = room1Spawn()
		for _, player in crew do
			player:SetAttribute("InLobby", false)
			setLobbyCamera(player, false)
			local character = player.Character
			if target and character then
				character:PivotTo(target)
			end
		end
		return true
	end
else
	startRun()
end

-- Spawn players in the lobby, or inside the Start room once their pod has launched.
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
	local player = Players:GetPlayerFromCharacter(character)
	if lobbySpawn and player and player:GetAttribute("InLobby") ~= false then
		character:WaitForChild("HumanoidRootPart")
		character:PivotTo(lobbySpawn)
		return
	end
	local target = room1Spawn()
	if target then
		character:WaitForChild("HumanoidRootPart")
		character:PivotTo(target)
	end
end

local function onPlayer(player: Player)
	player.CameraMode = Enum.CameraMode.LockFirstPerson
	if lobbySpawn then
		player:SetAttribute("InLobby", true)
		setLobbyCamera(player, true)
	end
	player.CharacterAdded:Connect(onCharacter)
	if player.Character then
		onCharacter(player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayer, player)
end
