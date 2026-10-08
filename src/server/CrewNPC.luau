--[[
	Builds the cutscene crew NPC from marketplace items.

	Put item IDs in OUTFIT (shirts, pants, faces, hats, hair, layered clothing,
	body parts...) and bundle IDs in BUNDLES. Each ID's type is looked up from
	the marketplace when the game starts, so the list doesn't need labels.
	Items don't need to be owned.

	If a Model named CrewNPC is in ServerStorage (e.g. one copied out of a
	play test and edited by hand), that model is used instead.
]]

local AssetService = game:GetService("AssetService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local CrewNPC = {}

local OUTFIT = {
	5872051960,
	109186498,
	81189970542394,
	127809511173598,
}

-- Body parts set directly (0 = default). Applied after the outfit and bundles, so these win.
local BODY_PARTS = {
	Torso = 86499666,
	LeftArm = 86499716,
	RightArm = 86499698,
	LeftLeg = 0,
	RightLeg = 0,
}

local SKIN_COLOR = Color3.fromRGB(206, 171, 236)

local BUNDLES = {
	3209000400683, -- animation pack
	100303331884709, -- head: Purple Cute Demon Following Glowing Eyes
}

-- Marketplace AssetTypeId -> HumanoidDescription property.
local PROPERTY = {
	[2] = "GraphicTShirt", [11] = "Shirt", [12] = "Pants", [18] = "Face",
	[17] = "Head", [79] = "Head", [27] = "Torso",
	[28] = "RightArm", [29] = "LeftArm", [30] = "LeftLeg", [31] = "RightLeg",
	[48] = "ClimbAnimation", [50] = "FallAnimation", [51] = "IdleAnimation", [52] = "JumpAnimation",
	[53] = "RunAnimation", [54] = "SwimAnimation", [55] = "WalkAnimation", [78] = "MoodAnimation",
}

-- Rigid accessories (comma-separated ID lists on the description).
local ACCESSORY = {
	[8] = "HatAccessory", [41] = "HairAccessory", [42] = "FaceAccessory", [43] = "NeckAccessory",
	[44] = "ShouldersAccessory", [45] = "FrontAccessory", [46] = "BackAccessory", [47] = "WaistAccessory",
}

-- Layered clothing and other accessories that go through SetAccessories.
local LAYERED = {
	[64] = Enum.AccessoryType.TShirt, [65] = Enum.AccessoryType.Shirt, [66] = Enum.AccessoryType.Pants,
	[67] = Enum.AccessoryType.Jacket, [68] = Enum.AccessoryType.Sweater, [69] = Enum.AccessoryType.Shorts,
	[70] = Enum.AccessoryType.LeftShoe, [71] = Enum.AccessoryType.RightShoe,
	[72] = Enum.AccessoryType.DressSkirt, [76] = Enum.AccessoryType.Eyebrow, [77] = Enum.AccessoryType.Eyelash,
}

local cached: HumanoidDescription? = nil

local function addAsset(desc: HumanoidDescription, layered: { any }, id: number, typeId: number?)
	if not typeId then
		local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, id, Enum.InfoType.Asset)
		if not ok then
			warn(`[Totality] CrewNPC: couldn't look up item {id}: {info}`)
			return
		end
		typeId = info.AssetTypeId
	end
	local prop, acc, layer = PROPERTY[typeId], ACCESSORY[typeId], LAYERED[typeId]
	if prop then
		(desc :: any)[prop] = id
	elseif acc then
		local current = (desc :: any)[acc]
		;(desc :: any)[acc] = if current == "" then tostring(id) else `{current},{id}`
	elseif layer then
		table.insert(layered, { AssetId = id, AccessoryType = layer, IsLayered = true, Order = #layered + 1 })
	else
		warn(`[Totality] CrewNPC: item {id} has type {typeId}, which can't be worn; skipped`)
	end
end

function CrewNPC.GetDescription(): HumanoidDescription
	if cached then
		return cached:Clone()
	end
	local desc = Instance.new("HumanoidDescription")
	local layered = {}
	for _, id in OUTFIT do
		addAsset(desc, layered, id)
	end
	for _, bundleId in BUNDLES do
		local ok, details = pcall(AssetService.GetBundleDetailsAsync, AssetService, bundleId)
		if ok then
			for _, item in details.Items do
				if item.Type == "Asset" then
					addAsset(desc, layered, item.Id)
				end
			end
		else
			warn(`[Totality] CrewNPC: couldn't load bundle {bundleId}: {details}`)
		end
	end
	for part, id in BODY_PARTS do
		(desc :: any)[part] = id
	end
	for _, prop in { "HeadColor", "TorsoColor", "LeftArmColor", "RightArmColor", "LeftLegColor", "RightLegColor" } do
		(desc :: any)[prop] = SKIN_COLOR
	end
	if #layered > 0 then
		desc:SetAccessories(layered, true)
	end
	cached = desc
	return desc:Clone()
end

-- Creates a dressed, anchored NPC standing at `cframe` (feet on the ground).
function CrewNPC.Spawn(cframe: CFrame, parent: Instance?): Model
	local saved = ServerStorage:FindFirstChild("CrewNPC")
	local npc = if saved and saved:IsA("Model") then saved:Clone()
		else Players:CreateHumanoidModelFromDescription(CrewNPC.GetDescription(), Enum.HumanoidRigType.R15)
	npc.Name = "CrewNPC"
	local humanoid = npc:FindFirstChildOfClass("Humanoid") :: Humanoid
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	local root = npc:FindFirstChild("HumanoidRootPart") :: BasePart
	root.Anchored = true
	local _, size = npc:GetBoundingBox()
	npc:PivotTo(cframe + Vector3.new(0, size.Y / 2, 0))
	npc.Parent = parent or workspace
	return npc
end

return CrewNPC
