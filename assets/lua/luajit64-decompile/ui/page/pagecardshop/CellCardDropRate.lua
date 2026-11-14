-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCardShop/CellCardDropRate.lua

require("UI/Item/UIItemBase")

CellCardDropRate = class("CellCardDropRate", UIItemBase)

function CellCardDropRate:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellCardDropRate:OnEnter(vParam)
	local g = self.UIRootObject

	self.GoImage = GOUtil.FindChildGameObject(g, "Image")
	self.GoImageUp = GOUtil.FindChildGameObject(g, "ImageUp")
	self.TextName = GOUtil.FindChildComponent(g, "TextName", "Text")
	self.TextRate = GOUtil.FindChildComponent(g, "TextRate", "Text")
end

function CellCardDropRate:UpdateData(rateData, index)
	local id = rateData[1]
	local rate = rateData[2]
	local isUp = rateData[3] == 1
	local info = RoleCardMgr:GetRoleCard(id)
	local infoRole = RoleMgr:GetRole(info.data.CharacterID)

	self.TextName.text = (info.cardRank == 1 and _("CardShop_card_common_name") or info:GetName()) .. " - " .. infoRole:GetName()
	self.TextRate.text = rate

	self.GoImageUp:SetActive(isUp)

	local isShow = index % 2 == 1

	self.GoImage:SetActive(isShow)
end
