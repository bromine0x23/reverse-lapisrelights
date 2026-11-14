-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTheme/CellThemeSel.lua

require("UI/Item/UIItemBase")

CellThemeSel = class("CellThemeSel", UIItemBase)

function CellThemeSel:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellThemeSel:OnEnter(vParam)
	local g = self.UIRootObject

	self.panel = GOUtil.FindChildGameObject(g, "ImageBg")
	self.Icon = GOUtil.FindChildComponent(g, "ImageBg/ImageIcon", "Image")
	self.ImageBg = GOUtil.FindChildComponent(g, "ImageBg/ImageBg", "Image")
	self.Text = GOUtil.FindChildComponent(g, "ImageBg/ImageName/Text", "Text")
end

function CellThemeSel:OnLeave()
	UnloadAllImageSprite(self)
end

function CellThemeSel:UpdateData(id)
	self.id = id

	if id == 0 then
		SetActiveFunc(self.panel, false)
	else
		SetActiveFunc(self.panel, true)

		local infoRole = RoleMgr:GetRole(id)
		local listTeamData = RoleMgr:GetTeamList()
		local teamId = infoRole.data.Team
		local teamBgPath = listTeamData[teamId].BGIcon

		UIUtil.SetImageSprite(self.Icon, infoRole.actorData.CharacterIcon, self)
		UIUtil.SetImageSprite(self.ImageBg, teamBgPath, self)

		self.Text.text = infoRole:GetName()
	end
end
