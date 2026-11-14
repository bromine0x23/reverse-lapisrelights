-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTheme/CellSeatRole.lua

require("UI/Item/UIItemBase")

CellSeatRole = class("CellSeatRole", UIItemBase)

function CellSeatRole:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellSeatRole:OnEnter(vParam)
	local g = self.UIRootObject

	self.Icon = GOUtil.FindChildComponent(g, "Icon", "Image")
	self.Text = GOUtil.FindChildComponent(g, "Image/Text", "Text")
	self.gIn = GOUtil.FindChildGameObject(g, "ImageIn")
	self.gSel = GOUtil.FindChildGameObject(g, "ImageSel")
	self.gMask = GOUtil.FindChildGameObject(g, "Image/Image")
end

function CellSeatRole:OnLeave()
	UnloadAllImageSprite(self)
end

function CellSeatRole:UpdateData(infoRole, inSeat)
	self.infoRole = infoRole
	self.inSeat = inSeat

	SetImageSprite(self.Icon, infoRole.actorData.ThemeIcon, self)

	self.Text.text = infoRole:GetName()

	SetActiveFunc(self.gIn, inSeat)
	SetActiveFunc(self.gSel, false)
	SetActiveFunc(self.gMask, inSeat)

	if inSeat then
		UIUtil.SetImageGray(self.Icon, 1)
	else
		UIUtil.SetImageGray(self.Icon, 0)
	end

	self:UpdateHasRole(infoRole)
end

function CellSeatRole:UpdateHasRole(infoRole)
	if not infoRole.hold then
		UIUtil.SetImageGray(self.Icon, 1)
	else
		UIUtil.SetImageGray(self.Icon, 0)
	end

	local gDrag = GOUtil.GetComponent(self.UIRootObject, "UIDraggableObject")

	if gDrag then
		gDrag.enabled = infoRole.hold
	end
end
