-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageShop/CellProductDropRate.lua

require("UI/Item/UIItemBase")

CellProductDropRate = class("CellProductDropRate", UIItemBase)

function CellProductDropRate:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellProductDropRate:OnEnter(vParam)
	local g = self.UIRootObject

	self.GoImage = GOUtil.FindChildGameObject(g, "Image")
	self.TextName = GOUtil.FindChildComponent(g, "TextName", "Text")
	self.TextRate = GOUtil.FindChildComponent(g, "TextRate", "Text")
end

function CellProductDropRate:UpdateData(rateData, index)
	local itemInfo = ItemManager:GetValueItem(rateData.itemId)

	self.TextName.text = Lang(itemInfo.data.Name)
	self.TextRate.text = rateData.probability .. "%"

	local isShow = index % 2 == 1

	self.GoImage:SetActive(isShow)
end
