--[[
	Room atmosphere, all on the client:
	  - dark haze (Atmosphere) so the far end of big rooms fades into gloom
	  - dust drifting in the air around you
	  - a dark vignette around the edges of the screen
	  - slight blur in the distance
	  - an optional looping ambient sound (set Config.AMBIENT_SOUND_ID)
	Everything gets heavier the deeper into the ship you are.
]]
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local Ambience = {}

local function lerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end

-- 0 at the start of the ship, 1 at the end.
local function depth(): number
	local room = ReplicatedStorage:GetAttribute("CurrentRoom") or 1
	return math.clamp((room - 1) / (Config.TOTAL_ROOMS - 1), 0, 1)
end

local function makeAtmosphere(): Atmosphere
	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "TotalityHaze"
	atmosphere.Color = Color3.fromRGB(22, 22, 28)
	atmosphere.Decay = Color3.fromRGB(10, 8, 14)
	atmosphere.Glare = 0
	atmosphere.Haze = 1
	atmosphere.Offset = 0
	atmosphere.Density = 0.3
	atmosphere.Parent = Lighting
	return atmosphere
end

-- Mars: low afternoon sun through butterscotch dust.
local MARS_LIGHTING = {
	ClockTime = 16.4,
	GeographicLatitude = 25,
	Brightness = 2.6,
	Ambient = Color3.fromRGB(88, 62, 52),
	OutdoorAmbient = Color3.fromRGB(150, 104, 82),
	ColorShift_Top = Color3.fromRGB(255, 205, 165),
	EnvironmentDiffuseScale = 0.5,
	EnvironmentSpecularScale = 0.5,
	ExposureCompensation = 0,
}

local function makeMarsAtmosphere(): Atmosphere
	local atmosphere = Instance.new("Atmosphere")
	atmosphere.Name = "MarsHaze"
	atmosphere.Color = Color3.fromRGB(206, 146, 106)
	atmosphere.Decay = Color3.fromRGB(128, 72, 46)
	atmosphere.Glare = 0.3
	atmosphere.Haze = 1.8
	atmosphere.Offset = 0.12
	atmosphere.Density = 0.34
	return atmosphere
end

local function makeBlur(): DepthOfFieldEffect
	local dof = Instance.new("DepthOfFieldEffect")
	dof.Name = "TotalityBlur"
	dof.FarIntensity = 0.15
	dof.NearIntensity = 0
	dof.FocusDistance = 25
	dof.InFocusRadius = 30
	dof.Parent = Lighting
	return dof
end

-- Dust: a particle box that follows the camera.
local function makeDust(): ParticleEmitter
	local box = Instance.new("Part")
	box.Name = "Dust"
	box.Size = Vector3.new(40, 16, 40)
	box.Transparency = 1
	box.Anchored = true
	box.CanCollide = false
	box.CanQuery = false
	box.CanTouch = false
	box.Parent = workspace.CurrentCamera

	local dust = Instance.new("ParticleEmitter")
	dust.Shape = Enum.ParticleEmitterShape.Box
	dust.ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume
	dust.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	dust.Color = ColorSequence.new(Color3.fromRGB(170, 165, 155))
	dust.LightInfluence = 1
	dust.LightEmission = 0
	dust.Size = NumberSequence.new(0.08)
	dust.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.3, 0.55),
		NumberSequenceKeypoint.new(0.7, 0.55),
		NumberSequenceKeypoint.new(1, 1),
	})
	dust.Lifetime = NumberRange.new(6, 10)
	dust.Speed = NumberRange.new(0.1, 0.4)
	dust.SpreadAngle = Vector2.new(180, 180)
	dust.Acceleration = Vector3.new(0, -0.05, 0)
	dust.RotSpeed = NumberRange.new(-20, 20)
	dust.Rate = 30
	dust.Parent = box

	RunService.RenderStepped:Connect(function()
		box.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position)
	end)
	return dust
end

-- Vignette: four edge gradients that darken the borders of the screen.
local function makeVignette(): { Frame }
	local gui = Instance.new("ScreenGui")
	gui.Name = "Vignette"
	gui.IgnoreGuiInset = true
	gui.ResetOnSpawn = false
	gui.DisplayOrder = -1
	local frames = {}
	local edges = {
		{ UDim2.fromScale(1, 0.35), UDim2.fromScale(0, 0), 90 }, -- top
		{ UDim2.fromScale(1, 0.35), UDim2.fromScale(0, 0.65), -90 }, -- bottom
		{ UDim2.fromScale(0.3, 1), UDim2.fromScale(0, 0), 0 }, -- left
		{ UDim2.fromScale(0.3, 1), UDim2.fromScale(0.7, 0), 180 }, -- right
	}
	for _, e in edges do
		local f = Instance.new("Frame")
		f.Size = e[1]
		f.Position = e[2]
		f.BackgroundColor3 = Color3.new(0, 0, 0)
		f.BorderSizePixel = 0
		local g = Instance.new("UIGradient")
		g.Rotation = e[3]
		g.Transparency = NumberSequence.new(0.35, 1)
		g.Parent = f
		f.Parent = gui
		table.insert(frames, f)
	end
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	return frames
end

local function startSound()
	local id = Config.AMBIENT_SOUND_ID
	if not id then
		print("[Totality] No ambient sound set (Config.AMBIENT_SOUND_ID is nil)")
		return
	end
	local sound = Instance.new("Sound")
	sound.Name = "Ambience"
	sound.SoundId = `rbxassetid://{id}`
	sound.Looped = true
	sound.Volume = 0.25
	sound.Parent = SoundService
	print(`[Totality] Loading ambient sound {id}...`)
	sound:Play()
	task.delay(8, function()
		if sound.IsLoaded then
			print(`[Totality] Ambient sound playing ({math.floor(sound.TimeLength)}s loop)`)
		else
			warn(`[Totality] Ambient sound {id} didn't load. It may not be allowed in this game; try another sound.`)
		end
	end)
end

-- Mute Roblox's default footstep sound ("Running") on every character.
local function muteFootsteps()
	local function onCharacter(character: Model)
		local root = character:WaitForChild("HumanoidRootPart", 10)
		if not root then
			return
		end
		local function mute(child: Instance)
			if child:IsA("Sound") and child.Name == "Running" then
				child.Volume = 0
			end
		end
		for _, child in root:GetChildren() do
			mute(child)
		end
		root.ChildAdded:Connect(mute)
	end
	local function onPlayer(player: Player)
		player.CharacterAdded:Connect(onCharacter)
		if player.Character then
			task.spawn(onCharacter, player.Character)
		end
	end
	Players.PlayerAdded:Connect(onPlayer)
	for _, player in Players:GetPlayers() do
		onPlayer(player)
	end
end

function Ambience.Start()
	muteFootsteps()
	local atmosphere = makeAtmosphere()
	local blur = makeBlur()
	local dust = makeDust()
	local vignette = makeVignette()
	startSound()

	local tweenInfo = TweenInfo.new(4, Enum.EasingStyle.Sine)
	local function update()
		local d = depth()
		TweenService:Create(atmosphere, tweenInfo, {
			Density = lerp(0.3, 0.5, d),
			Haze = lerp(1, 2.5, d),
			Color = Color3.fromRGB(22, 22, 28):Lerp(Color3.fromRGB(28, 16, 30), d),
		}):Play()
		TweenService:Create(blur, tweenInfo, { FarIntensity = lerp(0.15, 0.35, d), InFocusRadius = lerp(30, 18, d) }):Play()
		dust.Rate = lerp(30, 70, d)
		for _, f in vignette do
			TweenService:Create(f, tweenInfo, { BackgroundTransparency = lerp(0.25, 0, d) }):Play()
		end
	end
	ReplicatedStorage:GetAttributeChangedSignal("CurrentRoom"):Connect(update)
	update()

	-- In the Mars lobby: warm dusty daylight instead of the ship's gloom.
	local player = Players.LocalPlayer
	local mars = makeMarsAtmosphere()
	local saved = {}
	local function setLobby(inLobby: boolean)
		if inLobby then
			for prop, value in MARS_LIGHTING do
				if saved[prop] == nil then
					saved[prop] = (Lighting :: any)[prop]
				end
				(Lighting :: any)[prop] = value
			end
			atmosphere.Parent = nil
			mars.Parent = Lighting
			blur.Enabled = false
			dust.Color = ColorSequence.new(Color3.fromRGB(200, 130, 95))
			for _, f in vignette do
				f.Visible = false
			end
		else
			for prop, value in saved do
				(Lighting :: any)[prop] = value
			end
			table.clear(saved)
			mars.Parent = nil
			atmosphere.Parent = Lighting
			blur.Enabled = true
			dust.Color = ColorSequence.new(Color3.fromRGB(170, 165, 155))
			for _, f in vignette do
				f.Visible = true
			end
		end
		local color = Lighting:FindFirstChild("TotalityColor") :: ColorCorrectionEffect?
		if color then
			color.TintColor = if inLobby then Color3.fromRGB(255, 236, 222) else Color3.fromRGB(230, 235, 255)
			color.Saturation = if inLobby then 0.05 else -0.2
		end
	end
	player:GetAttributeChangedSignal("InLobby"):Connect(function()
		setLobby(player:GetAttribute("InLobby") == true)
	end)
	setLobby(player:GetAttribute("InLobby") == true)
end

return Ambience
