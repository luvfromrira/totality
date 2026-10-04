-- Makes lamps marked with the "Flicker" attribute stutter every few seconds.
-- Runs on the client so it's smooth and costs the server nothing.
local Flicker = {}

local function flickerLoop(lamp: BasePart)
	local light = lamp:FindFirstChildWhichIsA("Light")
	if not light then
		return
	end
	local material = lamp.Material
	local rand = Random.new()
	while lamp.Parent do
		task.wait(rand:NextNumber(2, 7))
		for _ = 1, rand:NextInteger(2, 6) do
			if not lamp.Parent then
				return
			end
			light.Enabled = false
			lamp.Material = Enum.Material.SmoothPlastic
			task.wait(rand:NextNumber(0.03, 0.12))
			light.Enabled = true
			lamp.Material = material
			task.wait(rand:NextNumber(0.03, 0.2))
		end
	end
end

local function watch(instance: Instance)
	if instance:IsA("BasePart") and instance.Name == "Lamp" and instance:GetAttribute("Flicker") then
		task.spawn(flickerLoop, instance)
	end
end

function Flicker.Start()
	local rooms = workspace:WaitForChild("GeneratedRooms")
	for _, d in rooms:GetDescendants() do
		watch(d)
	end
	rooms.DescendantAdded:Connect(watch)
end

return Flicker
