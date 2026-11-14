-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionFunction/CellWish.lua

require("UI/Item/UIItemBase")

CellWish = class("CellWish", UIItemBase)

function CellWish:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellWish:OnEnter(vParam)
	local g = self.UIRootObject

	self.ImgSoulIcon = GOUtil.FindChildComponent(g, "Icon", "Image")
	self.TxtSoulName = GOUtil.FindChildComponent(g, "TxtName", "Text")
	self.TxtSoulHold = GOUtil.FindChildComponent(g, "TxtHold", "Text")
	self.GoSelect = GOUtil.FindChildGameObject(g, "Select")
end

function CellWish:UpdateData(infoWish, index)
	local soul = infoWish.info
	local hold = RoleCardMgr:GetRoleCard(soul.data.Value).pb.soul

	SetImageSprite(self.ImgSoulIcon, soul:GetIcon(), self)

	self.TxtSoulName.text = Lang(soul.data.Name)
	self.TxtSoulHold.text = "x" .. hold

	SetActiveFunc(self.GoSelect, self.Index == index)
end

function CellWish:OnLeave()
	UnloadAllImageSprite(self)
end
