-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCardShop/CellRoleSign.lua

require("UI/Item/UIItemBase")

CellRoleSign = class("CellRoleSign", UIItemBase)

function CellRoleSign:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = ownerUI
end

function CellRoleSign:OnEnter(vParam)
	local g = self.UIRootObject

	self.Image = GOUtil.GetComponent(g, "Image")
	self.ImageRank = GOUtil.FindChildComponent(g, "ImageRank", "Image")
	self.CardName = GOUtil.FindChildComponent(g, "CardName", "Text")
	self.CVName = GOUtil.FindChildComponent(g, "CVName", "Text")
	self.Btn = GOUtil.FindChildGameObject(g, "CVName/Btn")
	self.TypeName = GOUtil.FindChildComponent(g, "TypeName", "Text")
	self.TypeImage = GOUtil.FindChildComponent(g, "TypeImage", "Image")
	self.Animator = GOUtil.GetComponent(g, "Animator")
end

function CellRoleSign:UpdateData(id)
	local infoRoleCard = RoleCardMgr:GetRoleCard(id)
	local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)
	local rank = infoRoleCard.data.Rank

	self.CardName.text = infoRoleCard:GetName()
	self.CVName.text = Lang(infoRole.data.CvName)
	self.TypeName.text = Lang(infoRoleCard.data.Location[2])
	self.TypeImage.color = getColorFromString(infoRoleCard.data.Location[1])

	UIUtil.SetImageOverrideSprite(self.ImageRank, "UIDyAtlas/RoleCardRank/IC_card_logo_" .. rank .. "_01", self.page)
end

function CellRoleSign:OnLeave()
	UnloadAllImageSprite(self)
end
