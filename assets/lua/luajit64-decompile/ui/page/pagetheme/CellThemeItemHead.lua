-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTheme/CellThemeItemHead.lua

require("UI/Item/UIItemBase")

CellThemeItemHead = class("CellThemeItemHead", UIItemBase)

function CellThemeItemHead:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellThemeItemHead:OnEnter(vParam)
	local g = self.UIRootObject

	self.Icon = GOUtil.FindChildComponent(g, "show/ImageBg/ImageIcon", "Image")
	self.iconbg = GOUtil.FindChildComponent(g, "show/ImageBg/iconbg", "Image")
	self.Text = GOUtil.FindChildComponent(g, "show/ImageName/Text", "Text")
	self.gIn = GOUtil.FindChildGameObject(g, "show/ImageIn")
	self.gSel = GOUtil.FindChildGameObject(g, "show/ImageSel")
	self.text_heart = self:GetChildComponent("show/ImageHeart/text_heart", "Text")
	self.ImageHeart = self:GetChildComponent("show/ImageHeart", "Image")
	self.BG = GOUtil.GetComponent(g, "Image")
	self.go_unlock = GOUtil.FindChildGameObject(g, "show/go_unlock")
	self.Tex_unlock = GOUtil.FindChildComponent(g, "show/go_unlock/Text", "Text")
	self.Tex_unlock.text = _("Filter_NotGet")
end

function CellThemeItemHead:OnLeave()
	UnloadAllImageSprite(self)
end

function CellThemeItemHead:UpdateData(infoRole, inSeat, goParent)
	self.infoRole = infoRole
	self.inSeat = inSeat

	SetImageSprite(self.Icon, infoRole.actorData.ThemeIcon, self)

	self.Text.text = infoRole:GetName()
	self.text_heart.text = self.infoRole.curFavorLevel

	SetActiveFunc(self.gIn, inSeat)
	SetActiveFunc(self.gSel, false)

	if inSeat then
		DealWithListRef(self, UIUtil.SetImageMaskGray(self.Icon, 1))
	else
		DealWithListRef(self, UIUtil.SetImageMaskGray(self.Icon, 0))
	end

	self:UpdateHasRole(infoRole, goParent)
end

function CellThemeItemHead:UpdateHasRole(infoRole, goParent)
	if not infoRole.hold then
		DealWithListRef(self, UIUtil.SetImageMaskGray(self.Icon, 1))
		DealWithListRef(self, UIUtil.SetImageGray(self.iconbg, 1))
		DealWithListRef(self, UIUtil.SetImageGray(self.ImageHeart, 1))
	else
		DealWithListRef(self, UIUtil.SetImageMaskGray(self.Icon, 0))
		DealWithListRef(self, UIUtil.SetImageGray(self.iconbg, 0))
		DealWithListRef(self, UIUtil.SetImageGray(self.ImageHeart, 0))
	end

	SetActiveFunc(self.go_unlock, not infoRole.hold)

	local gDrag = GOUtil.GetComponent(self.UIRootObject, "UIDraggableObject")

	if gDrag then
		gDrag.enabled = infoRole.hold

		if gDrag.enabled then
			gDrag:SetParentDragTarget(goParent)
		end
	end
end

function CellThemeItemHead:HideBG(ishide)
	if ishide then
		self.BG.color = Color.New(1, 1, 1, 0)
	else
		self.BG.color = Color.New(1, 1, 1, 1)
	end
end
