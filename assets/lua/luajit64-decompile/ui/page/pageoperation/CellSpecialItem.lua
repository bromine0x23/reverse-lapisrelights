-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/CellSpecialItem.lua

require("UI/Item/UIItemBase")

CellSpecialItem = class("CellSpecialItem", UIItemBase)

function CellSpecialItem:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellSpecialItem:OnEnter()
	local g = self.UIRootObject

	self.GoTxt = self:GetChildGameObject("BgTxt")
	self.ItemIcon = GOUtil.FindChildComponent(g, "Icon", "Image")
	self.ItemCount = GOUtil.FindChildComponent(g, "BgTxt/Text", "Text")
	self.ItemRank1 = GOUtil.FindChildComponent(g, "Rank1", "Image")
	self.ItemRank2 = GOUtil.FindChildComponent(g, "Rank2", "Image")
	self.GoGeted = GOUtil.FindChildGameObject(g, "Geted")
end

function CellSpecialItem:OnLeave()
	UnloadAllImageSprite(self)
end

function CellSpecialItem:UpdateData(index, info)
	self:UpdateWithNumType(info)
end

function CellSpecialItem:UpdateNoNumType(info)
	self.info = nil

	if info == nil or info.data == nil then
		return
	end

	self.info = info

	self:SetItemData(info)
	SetActiveFunc(self.GoTxt, false)
end

function CellSpecialItem:UpdateWithNumType(info)
	self.info = nil

	if info == nil or info.data == nil then
		return
	end

	self.info = info

	self:SetItemData(info)

	self.ItemCount.text = info:GetNum()

	if info:GetType() == eItemType.RC_RECEIVE or info:GetType() == eItemType.R_AVATAR then
		SetActiveFunc(self.ItemCount.gameObject, false)
	else
		SetActiveFunc(self.ItemCount.gameObject, true)
	end
end

function CellSpecialItem:SetItemData(info)
	ItemManager:SetItemInfo(info, self.ItemIcon, self.ItemRank1, self.ItemRank2, self)
end

function CellSpecialItem:SetReceived(isRecv)
	SetActiveFunc(self.GoGeted, isRecv)
end

function CellSpecialItem:SetGray(isGray)
	local gray = TenaryOp(isGray, 1, 0)

	DealWithListRef(self, UIUtil.SetImageGray(self.ItemIcon, gray))
	DealWithListRef(self, UIUtil.SetImageGray(self.ItemRank1, gray))
	DealWithListRef(self, UIUtil.SetImageGray(self.ItemRank2, gray))
end
