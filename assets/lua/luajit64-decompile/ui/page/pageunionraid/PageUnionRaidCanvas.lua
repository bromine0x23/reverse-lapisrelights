-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionRaid/PageUnionRaidCanvas.lua

require("UI/Item/UIItemBase")

PageUnionRaidCanvas = class("PageUnionRaidCanvas", UIItemBase)

function PageUnionRaidCanvas:ctor(itemPrefabCache, parent, owerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function PageUnionRaidCanvas:OnEnter()
	local g = self.UIRootObject
	local launcher = GameObject.Find("Launcher")
	local camera = GOUtil.GetComponent(launcher, "UIManager").UICamera
	local canvas = GOUtil.GetComponent(g, "Canvas")

	canvas.worldCamera = camera

	for i = 1, 5 do
		self["CommPoint" .. i] = GOUtil.FindChildGameObject(g, "RaidGroup/" .. i)
	end

	self.GoBoss = GOUtil.FindChildGameObject(g, "RaidGroup/Boss")
	self.GoBossAward = GOUtil.FindChildGameObject(g, "RaidGroup/BossAward")
end
