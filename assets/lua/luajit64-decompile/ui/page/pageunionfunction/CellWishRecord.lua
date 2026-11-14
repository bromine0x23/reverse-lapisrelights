-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionFunction/CellWishRecord.lua

require("UI/Item/UIItemBase")

CellWishRecord = class("CellWishRecord", UIItemBase)

function CellWishRecord:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellWishRecord:OnEnter(vParam)
	local g = self.UIRootObject

	self.ImgSoulIcon = GOUtil.FindChildComponent(g, "SoulIcon", "Image")
	self.TxtSoulName = GOUtil.FindChildComponent(g, "TxtName", "Text")
	self.TxtPrompt = GOUtil.FindChildComponent(g, "TxtPrompt", "Text")
	self.TxtTime = GOUtil.FindChildComponent(g, "TxtTime", "Text")
end

function CellWishRecord:UpdateData(infoRecord)
	if not infoRecord then
		return
	end

	local soul = infoRecord.soul

	SetImageSprite(self.ImgSoulIcon, soul:GetIcon(), self)

	self.TxtSoulName.text = Lang(soul.data.Name)
	self.TxtPrompt.text = infoRecord.info
	self.TxtTime.text = infoRecord.strTime
end

function CellWishRecord:OnLeave()
	UnloadAllImageSprite(self)
end
