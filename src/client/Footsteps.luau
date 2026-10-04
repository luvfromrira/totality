--[[
	Custom footsteps (Config.FOOTSTEP_SOUND_ID) for every character, played
	locally. A step plays every STRIDE studs walked on the ground, with a
	little pitch variation so it doesn't sound robotic.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local Footsteps = {}

local STRIDE = 4.5 -- studs per step
local VOLUME = 0.5

local function track(character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
	local root = character:WaitForChild("HumanoidRootPart", 10) :: BasePart?
	if not humanoid or not root then
		return
	end
	local step = Instance.new("Sound")
	step.Name = "Footstep"
	step.SoundId = `rbxassetid://{Config.FOOTSTEP_SOUND_ID}`
	step.Volume = VOLUME
	step.RollOffMaxDistance = 60
	step.Parent = root

	local rand = Random.new()
	local walked = 0
	local connection
	connection = RunService.Heartbeat:Connect(function(dt)
		if not character.Parent then
			connection:Disconnect()
			return
		end
		local velocity = root.AssemblyLinearVelocity
		local speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
		if humanoid.FloorMaterial == Enum.Material.Air or speed < 1 then
			walked = STRIDE * 0.6 -- first step lands quickly after you start moving
			return
		end
		walked += speed * dt
		if walked >= STRIDE then
			walked = 0
			step.PlaybackSpeed = rand:NextNumber(0.9, 1.1)
			step:Play()
		end
	end)
end

function Footsteps.Start()
	if not Config.FOOTSTEP_SOUND_ID then
		return
	end
	local function onPlayer(player: Player)
		player.CharacterAdded:Connect(track)
		if player.Character then
			task.spawn(track, player.Character)
		end
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, player in Players:GetPlayers() do
		onPlayer(player)
	end
end

return Footsteps
