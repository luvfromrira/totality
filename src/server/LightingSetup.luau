--[[
	Global lighting for the S.S. Totality: black space outside, low ambient
	light inside, so the ship's own (dim) lamps do the work. Removes the
	default place's Atmosphere/Bloom/SunRays, which wash everything out white.
]]
local Lighting = game:GetService("Lighting")

local LightingSetup = {}

function LightingSetup.Apply()
	for _, child in Lighting:GetChildren() do
		if child:IsA("PostEffect") or child:IsA("Atmosphere") or child:IsA("Sky") or child:IsA("Clouds") then
			child:Destroy()
		end
	end

	Lighting.ClockTime = 0
	Lighting.Brightness = 0
	Lighting.Ambient = Color3.fromRGB(26, 26, 32)
	Lighting.OutdoorAmbient = Color3.fromRGB(18, 18, 24)
	Lighting.EnvironmentDiffuseScale = 0.15
	Lighting.EnvironmentSpecularScale = 0.3
	Lighting.GlobalShadows = true
	Lighting.ExposureCompensation = -0.2
	Lighting.FogEnd = 100000

	-- Starfield, no sun or moon.
	local sky = Instance.new("Sky")
	sky.Name = "TotalitySky"
	sky.StarCount = 5000
	sky.CelestialBodiesShown = false
	sky.Parent = Lighting

	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "TotalityColor"
	cc.Brightness = -0.03
	cc.Contrast = 0.12
	cc.Saturation = -0.2
	cc.TintColor = Color3.fromRGB(230, 235, 255)
	cc.Parent = Lighting

	-- Only the brightest things glow a little.
	local bloom = Instance.new("BloomEffect")
	bloom.Name = "TotalityBloom"
	bloom.Intensity = 0.25
	bloom.Size = 18
	bloom.Threshold = 2.4
	bloom.Parent = Lighting
end

return LightingSetup
