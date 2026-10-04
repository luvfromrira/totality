--[[
	Sprinting: hold Shift to run while you have stamina. Run out and you're
	winded: you walk a little slower than normal until your stamina has fully
	refilled. Stamina starts refilling a moment after you stop sprinting.
	Tune it in Config (SPRINT_*).
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local Sprint = {}

local player = Players.LocalPlayer
local stamina = Config.SPRINT_MAX_STAMINA
local winded = false
local holding = false
local sinceSprint = math.huge

local function makeBar(): (Frame, Frame)
	local gui = Instance.new("ScreenGui")
	gui.Name = "Stamina"
	gui.ResetOnSpawn = false
	local back = Instance.new("Frame")
	back.AnchorPoint = Vector2.new(0.5, 1)
	back.Position = UDim2.new(0.5, 0, 1, -28)
	back.Size = UDim2.fromOffset(220, 6)
	back.BackgroundColor3 = Color3.fromRGB(20, 22, 26)
	back.BackgroundTransparency = 0.3
	back.BorderSizePixel = 0
	back.Parent = gui
	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = Color3.fromRGB(190, 200, 215)
	fill.BorderSizePixel = 0
	fill.Parent = back
	gui.Parent = player:WaitForChild("PlayerGui")
	return back, fill
end

function Sprint.Start()
	local back, fill = makeBar()
	local barVisible = true

	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and (input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift) then
			holding = true
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
			holding = false
		end
	end)

	RunService.Heartbeat:Connect(function(dt)
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then
			return
		end
		local moving = humanoid.MoveDirection.Magnitude > 0.1
		local sprinting = holding and moving and not winded and stamina > 0

		if sprinting then
			stamina = math.max(0, stamina - Config.SPRINT_DRAIN * dt)
			sinceSprint = 0
			if stamina <= 0 then
				winded = true
			end
		else
			sinceSprint += dt
			if sinceSprint >= Config.SPRINT_REGEN_DELAY then
				stamina = math.min(Config.SPRINT_MAX_STAMINA, stamina + Config.SPRINT_REGEN * dt)
				if winded and stamina >= Config.SPRINT_MAX_STAMINA then
					winded = false
				end
			end
		end

		humanoid.WalkSpeed = if sprinting then Config.SPRINT_SPEED
			elseif winded then Config.WINDED_SPEED
			else Config.WALK_SPEED

		-- Bar: hidden when full, reddish while winded.
		local ratio = stamina / Config.SPRINT_MAX_STAMINA
		fill.Size = UDim2.fromScale(ratio, 1)
		fill.BackgroundColor3 = if winded then Color3.fromRGB(170, 70, 60) else Color3.fromRGB(190, 200, 215)
		local shouldShow = ratio < 1 or winded
		if shouldShow ~= barVisible then
			barVisible = shouldShow
			local t = if shouldShow then 0.3 else 1
			TweenService:Create(back, TweenInfo.new(0.4), { BackgroundTransparency = t }):Play()
			TweenService:Create(fill, TweenInfo.new(0.4), { BackgroundTransparency = if shouldShow then 0 else 1 }):Play()
		end
	end)
end

return Sprint
