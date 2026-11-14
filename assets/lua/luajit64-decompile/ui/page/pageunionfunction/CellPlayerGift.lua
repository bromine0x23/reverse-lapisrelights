-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionFunction/CellPlayerGift.lua

require("UI/Item/UIItemBase")

CellPlayerGift = class("CellPlayerGift", UIItemBase)

function CellPlayerGift:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellPlayerGift:OnEnter(vParam)
	local g = self.UIRootObject

	self:DealWithLocalization(g)

	self.ImgPlayerAvatar = GOUtil.FindChildComponent(g, "Panel/Avatar/Icon", "Image")
	self.TxtPlayerLevel = GOUtil.FindChildComponent(g, "Panel/Level/TxtLevel", "Text")
	self.TxtPlayerName = GOUtil.FindChildComponent(g, "Panel/TxtName", "Text")
	self.TxtGiftTime = GOUtil.FindChildComponent(g, "Panel/TxtTime", "Text")
end

function CellPlayerGift:DealWithLocalization(g)
	local Text

	Text = GOUtil.FindChildComponent(g, "Panel/Level/Text", "Text")
	Text.text = _("CellRoleCard_Level")
	Text = GOUtil.FindChildComponent(g, "Panel/TxtPrompt", "Text")
	Text.text = _("Desc_Received_Player_Send")
	Text = GOUtil.FindChildComponent(g, "Panel/GoThanked/Text", "Text")
	Text.text = _("Desc_Thanks")
end

function CellPlayerGift:UpdateData(infoPlayerGift)
	self.info = infoPlayerGift

	SetImageSprite(self.ImgPlayerAvatar, infoPlayerGift:GetTitleIcon(1), self)

	self.TxtPlayerName.text = infoPlayerGift.name
	self.TxtPlayerLevel.text = infoPlayerGift.curLevel
	self.TxtGiftTime.text = UnionWishRecvMgr:GetGiftMeTime(self.info.pid)
end

function CellPlayerGift:OnLeave()
	UnloadAllImageSprite(self)
end
