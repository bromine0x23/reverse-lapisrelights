-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCombatReadiness/CellCardAddition.lua

require("UI/Item/UIItemBase")

local CharacterTeam = require("luaData.CharacterTeam")

CellCardAddition = class("CellCardAddition", UIItemBase)

function CellCardAddition:ctor(itemPrefabCache, parent)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellCardAddition:Create(vParam)
	CellCardAddition.base.Create(self, vParam)
end

function CellCardAddition:OnEnter()
	local g = self.UIRootObject

	self.Role = self:GetChildComponent("Role", "Image")
	self.Icon = self:GetChildComponent("Icon", "Image")
	self.Rank = self:GetChildComponent("Rank", "Image")
	self.Skill = self:GetChildComponent("Skill", "Image")
	self.Text1 = self:GetChildComponent("Text1", "Text")
	self.Text2 = self:GetChildComponent("Text2", "Text")

	self:OnRegisterEvent()
end

function CellCardAddition:UpdateData(data)
	if data.Params[1] == 1 then
		self.Rank.gameObject:SetActive(false)
		self.Icon.gameObject:SetActive(true)
		self.Role.gameObject:SetActive(false)
		UIUtil.SetImageSprite(self.Icon, "UIDyAtlas/RoleJob/IC_" .. GetConfigArgJson("JobNumber")[data.Params[2]] .. "_02_cn", self)
	elseif data.Params[1] == 2 then
		self.Role.gameObject:SetActive(false)
		self.Icon.gameObject:SetActive(true)
		self.Rank.gameObject:SetActive(false)

		local teamCfg = CharacterTeam[data.Params[2]]

		UIUtil.SetImageSprite(self.Icon, "UIDyAtlas/Team/" .. string.gsub(teamCfg.Icon, "_S", "_02"), self)
	elseif data.Params[1] == 3 then
		self.Icon.gameObject:SetActive(false)
		self.Role.gameObject:SetActive(true)
		self.Rank.gameObject:SetActive(false)

		local infoRole = RoleMgr:GetRole(data.Params[2])

		UIUtil.SetImageSprite(self.Role, infoRole.actorData.CharacterIcon)
	elseif data.Params[1] == 4 then
		local infoRoleCard = RoleCardMgr:GetRoleCard(data.Params[2])

		self.Icon.gameObject:SetActive(false)
		self.Role.gameObject:SetActive(true)
		self.Rank.gameObject:SetActive(true)
		UIUtil.SetImageSprite(self.Role, infoRoleCard.data.HeadIcon, self)
		UIUtil.SetImageSprite(self.Rank, "UIDyAtlas/RoleCardRank/ui_hd_card_back_" .. infoRoleCard.rank .. "_12", self)
	end

	UIUtil.SetImageSprite(self.Skill, "UIDyAtlas/Skill/" .. TalentManager:Get(data.SkillId).data.Icon, self)

	self.Text1.text = OperationActiveMgr:GetStrLeftDay(data.ID)
end

function CellCardAddition:OnRegisterEvent()
	return
end

function CellCardAddition:OnUnRegisterEvent()
	return
end

function CellCardAddition:OnClickedCell()
	return
end

function CellCardAddition:OnLeave()
	self:OnUnRegisterEvent()
	UnloadAllImageSprite(self)
end
