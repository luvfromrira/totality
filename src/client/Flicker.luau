-- Makes lamps marked with the "Flicker" attribute stutter every few seconds,
-- and makes status LEDs (parts named "Led") blink.
-- Runs on the client so it's smooth and costs the server nothing.
local Flicker = {}

local function flickerLoop(lamp: BasePart)
	local light = lamp:FindFirstChildWhichIsA("Light")
	if not light then
		return
	end
	local material = lamp.Material
	local rand = Random.new()
	-- Sparks from torn wires crackle constantly; lamps stutter every few seconds.
	local spark = lamp:GetAttribute("Spark")
	while lamp.Parent do
		task.wait(if spark then rand:NextNumber(0.05, 0.8) else rand:NextNumber(2, 7))
		for _ = 1, rand:NextInteger(2, 6) do
			if not lamp.Parent then
				return
			end
			light.Enabled = false
			lamp.Material = Enum.Material.SmoothPlastic
			if spark then
				lamp.Transparency = 1
			end
			task.wait(rand:NextNumber(0.03, 0.12))
			light.Enabled = true
			lamp.Material = material
			lamp.Transparency = 0
			task.wait(rand:NextNumber(0.03, 0.2))
		end
	end
end

-- Server-rack status LEDs: each one blinks off now and then on its own rhythm.
local function blinkLoop(led: BasePart)
	local on = led.Color
	local off = on:Lerp(Color3.new(0, 0, 0), 0.85)
	local rand = Random.new()
	while led.Parent do
		task.wait(rand:NextNumber(0.4, 3))
		if not led.Parent then
			return
		end
		led.Color = off
		task.wait(rand:NextNumber(0.05, 0.4))
		led.Color = on
	end
end

local function watch(instance: Instance)
	if not instance:IsA("BasePart") then
		return
	end
	if instance.Name == "Lamp" and instance:GetAttribute("Flicker") then
		task.spawn(flickerLoop, instance)
	elseif instance.Name == "Led" then
		task.spawn(blinkLoop, instance)
	end
end

local function watchFolder(name: string)
	local root = workspace:WaitForChild(name)
	for _, d in root:GetDescendants() do
		watch(d)
	end
	root.DescendantAdded:Connect(watch)
end

function Flicker.Start()
	task.spawn(watchFolder, "Lobby")
	watchFolder("GeneratedRooms")
end

return Flicker
