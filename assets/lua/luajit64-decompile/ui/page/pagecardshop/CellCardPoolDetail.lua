-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCardShop/CellCardPoolDetail.lua

require("UI/Item/UIItemBase")

CellCardPoolDetail = class("CellCardPoolDetail", UIItemBase)

function CellCardPoolDetail:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.ownerUI = ownerUI
end

function CellCardPoolDetail:OnEnter(vParam)
	local g = self.UIRootObject

	self.ImageRank = GOUtil.FindChildComponent(g, "Image/Image", "Image")
	self.TextMainRate = GOUtil.FindChildComponent(g, "Image/Text", "Text")

	local Text = GOUtil.FindChildComponent(g, "Image/TextName", "Text")

	Text.text = _("CardShop_Name")
	Text = GOUtil.FindChildComponent(g, "Image/TextRate", "Text")
	Text.text = _("CardShop_Rate")
	self.GroupPanel = GOUtil.FindChildGameObject(g, "Group")
end

function CellCardPoolDetail:UpdateData(rateGroupData, index)
	local rank = "R"

	if index == 4 then
		rank = "UR"
	elseif index == 3 then
		rank = "SSR"
	elseif index == 2 then
		rank = "SR"
	end

	UIUtil.SetImageSprite(self.ImageRank, "UIDyAtlas/RoleCardRank/IC_card_logo_" .. rank .. "_01", self.ownerUI)

	self.TextMainRate.text = _("CardShop_Title") .. " " .. rateGroupData
end
