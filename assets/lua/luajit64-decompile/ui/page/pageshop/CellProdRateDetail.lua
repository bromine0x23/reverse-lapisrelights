-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageShop/CellProdRateDetail.lua

require("UI/Item/UIItemBase")

CellProdRateDetail = class("CellProdRateDetail", UIItemBase)

function CellProdRateDetail:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.ownerUI = ownerUI
end

function CellProdRateDetail:OnEnter(vParam)
	local g = self.UIRootObject

	self.ImageRank = GOUtil.FindChildComponent(g, "Image/Image", "Image")
	self.TextMainRate = GOUtil.FindChildComponent(g, "Image/Text", "Text")
	self.TextGroupRate = GOUtil.FindChildComponent(g, "Image/TextGroupRate", "Text")
	self.GroupPanel = GOUtil.FindChildGameObject(g, "Group")
end

function CellProdRateDetail:UpdateData(id, num, rateString)
	local info = ItemManager:GetValueItem(id, num)

	self.TextMainRate.text = Lang(info.data.Name) .. " (数量:" .. num .. ")"
	self.TextGroupRate.text = rateString
end
