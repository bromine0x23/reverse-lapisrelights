-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFittingroom/CellAvatarGotoBar.lua

require("UI/Item/UIItemBase")

CellAvatarGotoBar = class("CellAvatarGotoBar", UIItemBase)

function CellAvatarGotoBar:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellAvatarGotoBar:Create(vParam)
	CellAvatarGotoBar.base.Create(self, vParam)
end

function CellAvatarGotoBar:OnEnter(vParam)
	local g = self.UIRootObject
	local Text = GOUtil.FindChildComponent(g, "Button/Text", "Text")

	Text.text = _("UI_Go")
	self.TextName = GOUtil.FindChildComponent(g, "TextName", "Text")
	self.TextContent = GOUtil.FindChildComponent(g, "TextContent", "Text")
	self.AvatarIcon = GOUtil.FindChildComponent(g, "Icon", "MaskableImage")
	self.GoToGet = GOUtil.FindChildGameObject(g, "Button")
end

function CellAvatarGotoBar:OnLeave()
	UnloadAllImageSprite(self)
end

function CellAvatarGotoBar:UpdateData(avatarData, index)
	local infoAvatar = avatarData.InfoAvatar

	self.TextName.text = Lang(infoAvatar.data.Name)

	SetImageSprite(self.AvatarIcon, infoAvatar.data.Icon, self)

	local fromWhere = avatarData.InfoAvatar.data.FromWhere
	local str = ""

	if fromWhere == eAvatarFrom.card or fromWhere == eAvatarFrom.petal then
		local infoRoleCard = RoleCardMgr:GetRoleCard(avatarData.InfoAvatar.data.FromRoleCardID)

		str = string.format(_("Avatar_From_" .. fromWhere), "【" .. infoRoleCard:GetName() .. "】")
	else
		str = _("Avatar_From_" .. fromWhere)
	end

	self.TextContent.text = str

	if avatarData.IsCanGotoGet then
		if not self.GoBtnState then
			self.GoToGet:SetActive(true)

			self.GoBtnState = true
		end
	elseif self.GoBtnState then
		self.GoToGet:SetActive(false)

		self.GoBtnState = false
	end
end
