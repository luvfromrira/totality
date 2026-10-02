-- Global lighting: a dark, starless sky outside so the rooms' own lamps do
-- the work, with enough ambient that corners never go pitch black.
local Lighting = game:GetService("Lighting")

local LightingSetup = {}

function LightingSetup.Apply()
	Lighting.ClockTime = 0
	Lighting.Brightness = 1
	Lighting.Ambient = Color3.fromRGB(70, 68, 80)
	Lighting.OutdoorAmbient = Color3.fromRGB(40, 38, 50)
	Lighting.EnvironmentDiffuseScale = 0.4
	Lighting.EnvironmentSpecularScale = 0.4
	Lighting.GlobalShadows = true
	Lighting.ExposureCompensation = 0.3

	local function ensure(className: string, name: string)
		local obj = Lighting:FindFirstChild(name) or Instance.new(className)
		obj.Name = name
		obj.Parent = Lighting
		return obj
	end

	local cc = ensure("ColorCorrectionEffect", "TotalityColor")
	cc.Contrast = 0.1
	cc.Saturation = -0.15
	cc.TintColor = Color3.fromRGB(235, 235, 255)

	local bloom = ensure("BloomEffect", "TotalityBloom")
	bloom.Intensity = 0.6
	bloom.Size = 24
	bloom.Threshold = 1.6
end

return LightingSetup
