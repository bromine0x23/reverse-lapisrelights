-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePlayerInfo/CellTeamRole.lua

require("UI/Item/UIItemBase")

CellTeamRole = class("CellTeamRole", UIItemBase)

function CellTeamRole:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellTeamRole:OnEnter(vParam)
	local g = self.UIRootObject

	self.TeamIcon = GOUtil.FindChildComponent(g, "TeamIcon", "Image")

	for i = 1, 5 do
		self["GoRole" .. i] = GOUtil.FindChildGameObject(g, "RoleGroup/" .. i)
		self["GoSel" .. i] = GOUtil.FindChildGameObject(g, "RoleGroup/" .. i .. "/ImgSel")
		self["Team" .. i] = GOUtil.FindChildComponent(g, "RoleGroup/" .. i .. "/Team", "Image")
		self["Role" .. i] = GOUtil.FindChildComponent(g, "RoleGroup/" .. i .. "/Role", "Image")

		self:AddClick(self["GoRole" .. i], self.OnClickRole)
	end
end

function CellTeamRole:OnLeave()
	for i = 1, 5 do
		self:RemoveClick(self["GoRole" .. i], self.OnClickRole)
	end

	UnloadAllImageSprite(self)
end

function CellTeamRole:UpdateData(info, teamIdx, roleIdx)
	local listRoleId = info.data.MemberList

	UIUtil.SetImageSprite(self.TeamIcon, "UIDyAtlas/Team/" .. info.data.Icon, self)

	for i = 1, 5 do
		SetActiveFunc(self["GoSel" .. i], self.Index == teamIdx and i == roleIdx)

		if i <= #listRoleId then
			SetActiveFunc(self["GoRole" .. i], true)

			local infoRole = RoleMgr:GetRole(listRoleId[i])

			UIUtil.SetImageSprite(self["Role" .. i], infoRole.actorData.CharacterIcon, self)
			UIUtil.SetImageSprite(self["Team" .. i], "UIDyAtlas/Team/IC_BG_" .. info.id .. "00_01", self)

			local num = TenaryOp(infoRole.hold, 0, 1)

			DealWithListRef(self, UIUtil.SetImageGray(self["Role" .. i], num))
		else
			SetActiveFunc(self["GoRole" .. i], false)
		end
	end
end

function CellTeamRole:OnClickRole(data)
	local go = data.pointerPress.gameObject
	local index = tonumber(go.name)
	local teamIdx = self.Index
	local roleIdx = index
	local data = {
		teamIdx = teamIdx,
		roleIdx = roleIdx
	}

	Event.Instance:Fire("UpdateSelectRole", data)
end
