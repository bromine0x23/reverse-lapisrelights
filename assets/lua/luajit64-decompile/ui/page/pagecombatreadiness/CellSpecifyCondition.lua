-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCombatReadiness/CellSpecifyCondition.lua

require("UI/Item/UIItemBase")

local CharacterTeam = require("luaData.CharacterTeam")

CellSpecifyCondition = class("CellSpecifyCondition", UIItemBase)

function CellSpecifyCondition:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellSpecifyCondition:OnEnter(vParam)
	local g = self.UIRootObject

	self.roleIcon = GOUtil.FindChildComponent(g, "CharIcon", "Image")
	self.Icon = GOUtil.FindChildComponent(g, "Icon", "Image")
	self.add = GOUtil.FindChildGameObject(g, "Down_Add")
	self.specify = GOUtil.FindChildGameObject(g, "Down_Specify")
end

function CellSpecifyCondition:OnLeave()
	UnloadAllImageSprite(self)
end

function CellSpecifyCondition:UpdateData(data, index)
	self.specify:SetActive(true)

	self.limitType = data[1]
	self.limitId = data[2]

	if not self.limitType then
		self.UIRootObject.gameObject:SetActive(false)

		return
	end

	local isChar = self.limitType == 1 or self.limitType == 2

	GOUtil.SetActive(self.roleIcon, isChar)
	GOUtil.SetActive(self.Icon, not isChar)

	if self.limitType == 1 then
		local infoRole = RoleMgr:GetRole(self.limitId)

		UIUtil.SetImageSprite(self.roleIcon, infoRole.actorData.CharacterIcon, self)
	elseif self.limitType == 2 then
		if self.limitId then
			local roleInfo = RoleCardMgr:GetRole(self.limitId)

			UIUtil.SetImageSprite(self.roleIcon, roleInfo.actorData.CharacterIcon, self)
		end
	elseif self.limitType == 3 then
		UIUtil.SetImageSprite(self.Icon, "UIDyAtlas/RoleJob/ICO_" .. GetConfigArgJson("JobNumber")[self.limitId] .. "_01", self)
	elseif self.limitType == 4 then
		local teamCfg = CharacterTeam[self.limitId]

		UIUtil.SetImageSprite(self.Icon, "UIDyAtlas/Team/IC_IDH_" .. self.limitId .. "00_02", self)
	end
end
