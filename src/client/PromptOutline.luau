--[[
	Custom-style prompts (research) show no popup. Instead the object they
	belong to gets a white outline while it's in range, and pressing the
	prompt's key still collects it.
]]

local ProximityPromptService = game:GetService("ProximityPromptService")
local UserInputService = game:GetService("UserInputService")

local TAP_RADIUS = 90 -- pixels around the object that count as tapping it

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
	-- Tapping (or clicking) an outlined object triggers its prompt. Research parts
	-- aren't raycastable, so compare the tap to each object's position on screen.
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed or (input.UserInputType ~= Enum.UserInputType.Touch
			and input.UserInputType ~= Enum.UserInputType.MouseButton1) then
			return
		end
		local camera = workspace.CurrentCamera
		local tap = Vector2.new(input.Position.X, input.Position.Y)
		local best, bestDist = nil, TAP_RADIUS
		for prompt in outlines do
			local part = prompt.Parent
			if part and part:IsA("BasePart") then
				local point, onScreen = camera:WorldToViewportPoint(part.Position)
				local dist = (Vector2.new(point.X, point.Y) - tap).Magnitude
				if onScreen and dist < bestDist then
					best, bestDist = prompt, dist
				end
			end
		end
		if best then
			best:InputHoldBegin()
			best:InputHoldEnd()
		end
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
