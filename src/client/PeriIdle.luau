--[[
	Peri's idle in the lobby office, animated in code by turning his joints
	(Motor6D.Transform) every frame. Runs on the client, so it's smooth and
	costs the server nothing.

	Always on: breathing, and a slow weight shift from foot to foot (the
	resting leg bends at the knee and steps slightly forward).
	On a loop of about 26 seconds:
	  - looks out of the window, glancing left and right
	  - reaches down to the credenza on his left and picks up the research file
	  - holds it up and reads it
	  - puts it back and goes back to looking out
]]

local RunService = game:GetService("RunService")

local PeriIdle = {}

type Pose = { [string]: { number } } -- joint name -> { x, y, z } rotation in degrees

-- Poses (degrees). Joints not listed stay at rest.
local LOOK = {
	Neck = { 2, 0, 0 },
}
local LOOK_LEFT = {
	Neck = { 0, 22, 0 },
	Waist = { 0, 6, 0 },
}
local LOOK_RIGHT = {
	Neck = { 4, -18, 0 },
	Waist = { 0, -4, 0 },
}
local REACH = {
	Waist = { -8, 18, 10 },
	Neck = { -25, 25, 0 },
	LeftShoulder = { 20, 0, -18 },
	LeftElbow = { 15, 0, 0 },
	RightShoulder = { 0, 0, 6 },
}
local HOLD = {
	Waist = { -4, 0, 0 },
	Neck = { -28, 4, 0 },
	LeftShoulder = { 62, 0, 18 },
	LeftElbow = { 72, 0, 0 },
	LeftWrist = { -10, 0, 0 },
	RightShoulder = { 34, 0, -14 },
	RightElbow = { 58, 0, 0 },
}
local READ = {
	Waist = { -4, 0, 0 },
	Neck = { -34, -6, 3 },
	LeftShoulder = { 64, 0, 18 },
	LeftElbow = { 74, 0, 0 },
	LeftWrist = { -10, 0, 0 },
	RightShoulder = { 36, 0, -14 },
	RightElbow = { 62, 0, 0 },
}

-- Timeline: { time, pose, holdingFile }. Loops back to the start.
local TIMELINE: { { any } } = {
	{ 0, LOOK, false },
	{ 3, LOOK_LEFT, false },
	{ 6, LOOK_LEFT, false },
	{ 8, LOOK, false },
	{ 10, LOOK_RIGHT, false },
	{ 12.5, LOOK_RIGHT, false },
	{ 14, LOOK, false },
	{ 15.5, REACH, false },
	{ 16.2, REACH, true }, -- picks it up
	{ 17.4, HOLD, true },
	{ 19, READ, true },
	{ 21.5, HOLD, true },
	{ 23, REACH, true },
	{ 23.6, REACH, false }, -- puts it down
	{ 25, LOOK, false },
	{ 26, LOOK, false },
}
local LENGTH = 26

local function smooth(t: number): number
	return t * t * (3 - 2 * t)
end

local function rotation(pose: Pose, name: string): Vector3
	local r = pose[name]
	return if r then Vector3.new(r[1], r[2], r[3]) else Vector3.zero
end

-- Pose at time t (blended between keyframes) and whether the file is in hand.
local function sample(t: number): ((string) -> Vector3, boolean)
	for i = 1, #TIMELINE - 1 do
		local a, b = TIMELINE[i], TIMELINE[i + 1]
		if t >= a[1] and t < b[1] then
			local k = smooth((t - a[1]) / (b[1] - a[1]))
			return function(name)
				return rotation(a[2], name):Lerp(rotation(b[2], name), k)
			end, a[3]
		end
	end
	local last = TIMELINE[#TIMELINE]
	return function(name)
		return rotation(last[2], name)
	end, last[3]
end

local function animate(peri: Model, file: Model?)
	-- Joints are Motor6Ds on older rigs and AnimationConstraints on newer ones;
	-- both are driven through their Transform.
	local joints: { [string]: any } = {}
	local function adopt(d: Instance)
		if d:IsA("Motor6D") then
			joints[d.Name] = d
		elseif d:IsA("AnimationConstraint") then
			d.IsKinematic = true -- follow Transform exactly instead of physics
			joints[d.Name] = d
		elseif d:IsA("BasePart") and d.Name ~= "HumanoidRootPart" then
			-- Joints can't move anchored parts; only the root holds him in place.
			d.Anchored = false
		elseif d:IsA("Animator") then
			-- An Animator resets joints every frame; he plays no animations, so
			-- drop it on this client so it doesn't undo the movement.
			d:Destroy()
		end
	end
	-- His parts can reach this client a little after the model itself (and
	-- stream in and out), so keep picking joints up as they arrive.
	for _, d in peri:GetDescendants() do
		adopt(d)
	end
	peri.DescendantAdded:Connect(adopt)
	local waited = 0
	while next(joints) == nil and waited < 20 and peri.Parent do
		waited += task.wait(0.5)
	end
	if next(joints) == nil then
		if peri.Parent then
			warn("[Totality] Peri has no joints (Motor6D or AnimationConstraint), so he can't be animated")
		end
		return -- (or this was an old copy the server swapped out)
	end
	local count = 0
	for _ in joints do
		count += 1
	end
	print(`[Totality] Animating Peri ({count} joints)`)
	local chest = peri:FindFirstChild("UpperTorso", true) :: BasePart?
	local fileRest = file and file:GetPivot()
	local clock = math.random() * LENGTH
	local connection
	connection = RunService.Stepped:Connect(function(_, dt)
		if not peri.Parent then
			connection:Disconnect()
			return
		end
		clock = (clock + dt) % LENGTH
		local pose, holding = sample(clock)
		local now = os.clock()
		local breath = math.sin(now * 1.6)
		local sway = math.sin(now * 0.35)
		for name, motor in joints do
			if not motor.Parent then
				continue
			end
			local r = pose(name)
			local extra = CFrame.identity
			if name == "Waist" then
				extra = CFrame.Angles(math.rad(breath * 1.2), 0, 0)
			elseif name == "Neck" then
				extra = CFrame.Angles(math.rad(-breath * 0.8), 0, 0)
			elseif name == "Root" then
				-- Weight shift: hips slide and tilt toward one foot, then the other.
				extra = CFrame.new(sway * 0.12, -math.abs(sway) * 0.03, 0) * CFrame.Angles(0, 0, math.rad(-sway * 2.5))
			elseif name == "LeftHip" or name == "RightHip" then
				-- The leg taking less weight steps slightly forward and relaxes.
				local relaxed = if name == "LeftHip" then math.max(sway, 0) else math.max(-sway, 0)
				extra = CFrame.Angles(math.rad(relaxed * 9), 0, math.rad(sway * 2.5))
			elseif name == "LeftKnee" or name == "RightKnee" then
				local relaxed = if name == "LeftKnee" then math.max(sway, 0) else math.max(-sway, 0)
				extra = CFrame.Angles(math.rad(-relaxed * 14), 0, 0)
			elseif name == "LeftAnkle" or name == "RightAnkle" then
				local relaxed = if name == "LeftAnkle" then math.max(sway, 0) else math.max(-sway, 0)
				extra = CFrame.Angles(math.rad(relaxed * 6), 0, 0)
			elseif name == "LeftShoulder" or name == "RightShoulder" then
				extra = CFrame.Angles(0, 0, math.rad(breath * (if name == "LeftShoulder" then -0.6 else 0.6)))
			end
			motor.Transform = CFrame.Angles(math.rad(r.X), math.rad(r.Y), math.rad(r.Z)) * extra
		end
		if file and fileRest then
			if holding and chest then
				-- Held out in front of his chest, tilted up toward his face.
				file:PivotTo(chest.CFrame * CFrame.new(-0.15, 0.05, -1.25) * CFrame.Angles(math.rad(55), 0, 0))
			else
				file:PivotTo(fileRest)
			end
		end
	end)
end

function PeriIdle.Start()
	local lobby = workspace:WaitForChild("Lobby", 60)
	if not lobby then
		return
	end
	local function try(d: Instance)
		if d:IsA("Model") and d.Name == "Peri" and not d:GetAttribute("Animating") then
			d:SetAttribute("Animating", true)
			task.wait(0.5) -- let the rest of his parts arrive
			local file = lobby:FindFirstChild("PeriFile", true) :: Model?
			animate(d, file)
		end
	end
	for _, d in lobby:GetDescendants() do
		task.spawn(try, d)
	end
	lobby.DescendantAdded:Connect(function(d)
		task.spawn(try, d)
	end)
end

return PeriIdle
