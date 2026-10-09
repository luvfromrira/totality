-- Turns models with a "Spin" attribute (degrees per second) around their
-- pivot, like the sun and planets of the orrery in the lobby. Client-side so
-- it's smooth.
local RunService = game:GetService("RunService")

local Spin = {}

function Spin.Start()
	local spinning: { [Model]: CFrame } = {}
	local function watch(d: Instance)
		if d:IsA("Model") and d:GetAttribute("Spin") and not spinning[d] then
			spinning[d] = d:GetPivot()
		end
	end
	for _, d in workspace:GetDescendants() do
		watch(d)
	end
	workspace.DescendantAdded:Connect(function(d)
		-- Models arrive before their parts finish replicating.
		task.defer(watch, d)
	end)
	local angle = 0
	RunService.RenderStepped:Connect(function(dt)
		angle += dt
		for model, start in spinning do
			if not model.Parent then
				spinning[model] = nil
			else
				local speed = math.rad(model:GetAttribute("Spin") or 0)
				model:PivotTo(start * CFrame.Angles(0, angle * speed, 0))
			end
		end
	end)
end

return Spin
