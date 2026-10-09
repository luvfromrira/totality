-- Turns models with a "Spin" attribute (degrees per second) around their
-- pivot, like the sun and planets of the orrery in the lobby. Client-side so
-- it's smooth.
local RunService = game:GetService("RunService")

local Spin = {}

function Spin.Start()
	-- model -> { centre it turns around, where its parts started relative to that }
	local spinning: { [Model]: { centre: CFrame, parts: { [BasePart]: CFrame } } } = {}
	local function track(model: Model, part: Instance)
		local info = spinning[model]
		if info and part:IsA("BasePart") and not info.parts[part] then
			info.parts[part] = info.centre:ToObjectSpace(part.CFrame)
		end
	end
	local function watch(d: Instance)
		if d:IsA("Model") and d:GetAttribute("Spin") and not spinning[d] then
			-- The centre comes from the SpinPivot attribute when there is one: a
			-- model's own pivot can read as the world origin on the client before
			-- it finishes arriving, which sent things spinning into the floor.
			local centre = d:GetAttribute("SpinPivot")
			if typeof(centre) ~= "CFrame" then
				centre = d:GetPivot()
			end
			spinning[d] = { centre = centre, parts = {} }
			for _, p in d:GetDescendants() do
				track(d, p)
			end
			-- Parts that stream in later join in where they belong.
			d.DescendantAdded:Connect(function(p)
				track(d, p)
			end)
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
		for model, info in spinning do
			if not model.Parent then
				spinning[model] = nil
			else
				local speed = math.rad(model:GetAttribute("Spin") or 0)
				local turned = info.centre * CFrame.Angles(0, angle * speed, 0)
				for part, offset in info.parts do
					if part.Parent then
						part.CFrame = turned * offset
					else
						info.parts[part] = nil
					end
				end
			end
		end
	end)
end

return Spin
