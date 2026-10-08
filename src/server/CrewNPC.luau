--[[
	Builds the cutscene characters (Aphe, Peri...) from marketplace items.

	Each character in CHARACTERS lists item IDs (shirts, pants, faces, hair,
	accessories, layered clothing...) and bundle IDs (heads, animation packs).
	Each ID's type is looked up from the marketplace when the game starts, so
	the lists don't need labels. Items don't need to be owned.

	If a Model with the character's name is in ServerStorage (e.g. one copied
	out of a play test and edited by hand), that model is used instead.
]]

local AssetService = game:GetService("AssetService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local CrewNPC = {}

-- Same body part meshes for every character (0 = default). Applied after the
-- outfit and bundles, so these win.
local BODY_PARTS = {
	Torso = 86499666,
	LeftArm = 86499716,
	RightArm = 86499698,
	LeftLeg = 0,
	RightLeg = 0,
}

--[[
	One entry per character:
	  outfit   item IDs (clothes, faces, hair, accessories...)
	  bundles  bundle IDs (heads, animation packs...)
	  skin     skin colour
	  arms     optional arm colour (defaults to skin)
]]
local CHARACTERS = {
	Aphe = {
		outfit = { 5872051960, 109186498, 81189970542394, 127809511173598 },
		bundles = {
			3209000400683, -- animation pack
			37662765657058, -- head
		},
		skin = Color3.fromRGB(206, 171, 236),
		arms = Color3.fromRGB(0, 0, 0),
	},
	Peri = {
		outfit = {
			16463892433, 18320597179, -- hair (both worn)
			14217638297, 93743599009564, -- face
			13518201885, -- shirt
			13518205713, -- pants
		},
		bundles = {
			110997625219077, -- head
		},
		skin = Color3.fromRGB(189, 154, 121),
	},
}
CrewNPC.Names = { "Aphe", "Peri" }

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

local cached: { [string]: HumanoidDescription } = {}

local function addAsset(desc: HumanoidDescription, layered: { any }, id: number, typeId: number?)
	if not typeId then
		local ok, info = pcall(MarketplaceService.GetProductInfo, MarketplaceService, id, Enum.InfoType.Asset)
		if not ok then
			warn(`[Totality] Character: couldn't look up item {id}: {info}`)
			return
		end
		typeId = info.AssetTypeId
	end
	local prop, acc, layer = PROPERTY[typeId], ACCESSORY[typeId], LAYERED[typeId]
	if prop then
		if prop == "Face" and desc.Face ~= 0 then
			warn(`[Totality] Character: two classic faces ({desc.Face} and {id}); only {id} can show`)
		end
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

function CrewNPC.GetDescription(name: string): HumanoidDescription
	if cached[name] then
		return cached[name]:Clone()
	end
	local def = assert(CHARACTERS[name], `No character named {name}`)
	local desc = Instance.new("HumanoidDescription")
	local layered = {}
	for _, id in def.outfit do
		addAsset(desc, layered, id)
	end
	for _, bundleId in def.bundles do
		local ok, details = pcall(AssetService.GetBundleDetailsAsync, AssetService, bundleId)
		if ok then
			for _, item in details.Items do
				if item.Type == "Asset" then
					addAsset(desc, layered, item.Id)
				end
			end
		else
			warn(`[Totality] {name}: couldn't load bundle {bundleId}: {details}`)
		end
	end
	for part, id in BODY_PARTS do
		(desc :: any)[part] = id
	end
	for _, prop in { "HeadColor", "TorsoColor", "LeftLegColor", "RightLegColor" } do
		(desc :: any)[prop] = def.skin
	end
	desc.LeftArmColor = def.arms or def.skin
	desc.RightArmColor = def.arms or def.skin
	if #layered > 0 then
		desc:SetAccessories(layered, true)
	end
	cached[name] = desc
	return desc:Clone()
end

-- Creates a dressed, anchored character standing at `cframe` (feet on the ground).
-- A Model with the same name in ServerStorage is used instead when there is one.
function CrewNPC.Spawn(name: string, cframe: CFrame, parent: Instance?): Model
	local saved = ServerStorage:FindFirstChild(name)
	local npc = if saved and saved:IsA("Model") then saved:Clone()
		else Players:CreateHumanoidModelFromDescription(CrewNPC.GetDescription(name), Enum.HumanoidRigType.R15)
	npc.Name = name
	if saved then
		-- Accessories you repositioned by hand (welded with a WeldConstraint)
		-- keep their spot: drop their attachment points so the Humanoid
		-- doesn't snap them back to the default place when the copy spawns.
		for _, acc in npc:GetDescendants() do
			local handle = acc:IsA("Accessory") and acc:FindFirstChild("Handle")
			if handle and handle:FindFirstChildOfClass("WeldConstraint") then
				for _, d in handle:GetChildren() do
					if d:IsA("Attachment") or d.Name == "AccessoryWeld" or d:IsA("RigidConstraint") then
						d:Destroy()
					end
				end
			end
		end
	else
		print(`[Totality] No {name} in ServerStorage, so {name} was built from the item IDs in CrewNPC.`)
	end
	local humanoid = npc:FindFirstChildOfClass("Humanoid") :: Humanoid
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	local root = npc:FindFirstChild("HumanoidRootPart") :: BasePart
	-- Only the root is anchored, so the joints can still move (idle animations).
	for _, d in npc:GetDescendants() do
		if d:IsA("BasePart") and d ~= root then
			d.Anchored = false
		end
	end
	root.Anchored = true
	local _, size = npc:GetBoundingBox()
	npc:PivotTo(cframe + Vector3.new(0, size.Y / 2, 0))
	npc.Parent = parent or workspace
	return npc
end

return CrewNPC
