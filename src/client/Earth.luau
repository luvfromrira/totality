--[[
	Earth, seen through the ship's windows. It's a local-only sphere kept at a
	fixed offset from the camera, so like a skybox it never gets closer no matter
	where the ship's rooms lead. It sits off to the +X side and below, where most
	rooms' right-hand windows face.
]]
local RunService = game:GetService("RunService")

local Earth = {}

local DIRECTION = Vector3.new(1, -0.55, -0.35).Unit
local DISTANCE = 2600

local function ball(name: string, size: number, color: Color3, transparency: number, material: Enum.Material): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Shape = Enum.PartType.Ball
	p.Size = Vector3.new(size, size, size)
	p.Anchored = true
	p.CanCollide = false
	p.CanQuery = false
	p.CanTouch = false
	p.CastShadow = false
	p.Material = material
	p.Color = color
	p.Transparency = transparency
	return p
end

function Earth.Start()
	local camera = workspace.CurrentCamera
	local folder = Instance.new("Folder")
	folder.Name = "Earth"
	local planet = ball("Planet", 1950, Color3.fromRGB(30, 75, 150), 0, Enum.Material.SmoothPlastic)
	local glow = ball("Atmosphere", 2048, Color3.fromRGB(120, 180, 255), 0.82, Enum.Material.Neon)
	planet.Parent = folder
	glow.Parent = folder
	folder.Parent = camera

	RunService.RenderStepped:Connect(function()
		local cf = CFrame.new(camera.CFrame.Position + DIRECTION * DISTANCE)
		planet.CFrame = cf
		glow.CFrame = cf
	end)
end

return Earth
