--[[
	Custom-style prompts (research) show no popup. Instead the object they
	belong to gets a white outline while it's in range, and pressing the
	prompt's key still collects it.
]]

local ProximityPromptService = game:GetService("ProximityPromptService")

local PromptOutline = {}

local outlines: { [ProximityPrompt]: Highlight } = {}

function PromptOutline.Start()
	ProximityPromptService.PromptShown:Connect(function(prompt)
		if prompt.Style ~= Enum.ProximityPromptStyle.Custom or outlines[prompt] then
			return
		end
		local target = prompt:FindFirstAncestorWhichIsA("Model") or prompt.Parent
		local outline = Instance.new("Highlight")
		outline.Adornee = target
		outline.FillTransparency = 1
		outline.OutlineColor = Color3.new(1, 1, 1)
		outline.OutlineTransparency = 0
		outline.DepthMode = Enum.HighlightDepthMode.Occluded
		outline.Parent = target
		outlines[prompt] = outline
	end)
	ProximityPromptService.PromptHidden:Connect(function(prompt)
		local outline = outlines[prompt]
		if outline then
			outline:Destroy()
			outlines[prompt] = nil
		end
	end)
end

return PromptOutline
