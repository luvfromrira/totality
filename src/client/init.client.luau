-- Client entry point: shows the current room number and research count.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))
local Flicker = require(script.Flicker)
local Ambience = require(script.Ambience)

task.spawn(Flicker.Start)
task.spawn(Ambience.Start)

local gui = Instance.new("ScreenGui")
gui.Name = "Hud"
gui.ResetOnSpawn = false

local label = Instance.new("TextLabel")
label.AnchorPoint = Vector2.new(0.5, 0)
label.Position = UDim2.new(0.5, 0, 0, 12)
label.Size = UDim2.fromOffset(300, 32)
label.BackgroundTransparency = 1
label.Font = Enum.Font.Code
label.TextSize = 22
label.TextColor3 = Color3.fromRGB(200, 210, 230)
label.Parent = gui

local function refresh()
	local room = ReplicatedStorage:GetAttribute("CurrentRoom") or 1
	local research = ReplicatedStorage:GetAttribute("ResearchCollected") or 0
	label.Text = `ROOM {string.format("%03d", room)}/{Config.TOTAL_ROOMS}  ·  RESEARCH {research}`
end

ReplicatedStorage:GetAttributeChangedSignal("CurrentRoom"):Connect(refresh)
ReplicatedStorage:GetAttributeChangedSignal("ResearchCollected"):Connect(refresh)
refresh()

gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
