-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnion/CellUnionType.lua

require("UI/Item/UIItemBase")

CellUnionType = class("CellUnionType", UIItemBase)

function CellUnionType:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellUnionType:OnEnter(vParam)
	local g = self.UIRootObject

	self.ImgAvatarBg = GOUtil.FindChildComponent(g, "BgAvatar", "Image")
	self.ImgAvatarIcon = GOUtil.FindChildComponent(g, "Avatar", "Image")
	self.TxtName = GOUtil.FindChildComponent(g, "TxtName", "Text")
	self.TxtTeam = GOUtil.FindChildComponent(g, "TxtTeam", "Text")
	self.GoSelect = GOUtil.FindChildGameObject(g, "Select")
end

function CellUnionType:UpdateData(info, index)
	local unionType = info
	local infoRole = UnionTypeMgr:GetUnionTypeRole(unionType.ID)

	self.TxtName.text = infoRole:GetName()

	local strColor = eTeamColor[infoRole.data.Team]

	strColor = strColor or "yellow"

	if infoRole.data.Team == 5 then
		self.TxtTeam.text = "<color=" .. strColor .. ">" .. _("PocketSweet") .. "</color>"
	elseif infoRole.data.Team == 6 then
		self.TxtTeam.text = "<color=" .. strColor .. ">" .. _("SadisticCandy") .. "</color>"
	else
		self.TxtTeam.text = "<color=" .. strColor .. ">" .. Lang(TeamMgr.Instance:GetTeamData(infoRole.data.Team).Name) .. "</color>"
	end

	local avatarPath = UnionTypeMgr:GetUnionTypeAvatarPath(unionType.ID)

	SetImageSprite(self.ImgAvatarIcon, avatarPath, self)

	local bgPath = UnionTypeMgr:GetUnionTypeBg(unionType.ID)

	SetImageSprite(self.ImgAvatarBg, bgPath, self)
	self:UpdateSelectState(self.Index == index)
end

function CellUnionType:UpdateSelectState(active)
	GOUtil.SetActive(self.GoSelect, active)
end

function CellUnionType:OnLeave()
	UnloadAllImageSprite(self)
end
