-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUICombinationSkill.lua

DlgUICombinationSkill = class("DlgUICombinationSkill", UIPanel_sync)

function DlgUICombinationSkill:ctor()
	DlgUICombinationSkill.base.ctor(self, "UI/PageFight/Dlg/DlgUICombinationSkill")

	if GP.GameStartData.bondage ~= nil and GP.GameStartData.bondage.combinationId ~= nil then
		local combinationId = GP.GameStartData.bondage.combinationId
		local teamIconPath = "UIDyAtlas/Team/IC_IDH_" .. combinationId .. "00"

		GP.PrewarmUtil:SpritePath(teamIconPath)
	end
end

function DlgUICombinationSkill:Cache()
	DlgUICombinationSkill.base.Cache(self)
end

function DlgUICombinationSkill:Close()
	DlgUICombinationSkill.base.Close(self)
end

function DlgUICombinationSkill:Purge()
	DlgUICombinationSkill.base.Purge(self)
end

function DlgUICombinationSkill:OnEnter()
	self:Show(false)

	self.txt_count = self:GetChildComponent("panel/img_count/txt_count", "Text")
	self.img_team = self:GetChildComponent("panel/img_team", "Image")
	self.skills = {}

	for i = 1, 3 do
		local skill = {}
		local obj = self:GetChildGameObject("panel/Skill/skillIcon" .. i)

		skill.icon = self:GetChildComponent("panel/Skill/skillIcon" .. i, "Image")
		skill.enableIcon = GOUtil.FindChildGameObject(obj, "enable")
		skill.disableIcon = GOUtil.FindChildGameObject(obj, "disable")

		table.insert(self.skills, skill)
	end
end

function DlgUICombinationSkill:Open()
	local vaild = false

	if GP.GameStartData.bondage then
		for k, skill in pairs(GP.GameStartData.bondage.skills) do
			if skill.canUse then
				vaild = true

				break
			end
		end
	end

	if vaild == false then
		self:Show(false)

		return
	end

	if GP.GameStartData.bondage then
		self:Show(true)

		local maxRole = GP.GameStartData.bondage.maxRole
		local battleRole = GP.GameStartData.bondage.battleRole
		local combinationId = GP.GameStartData.bondage.combinationId

		self.skillsInfo = GP.GameStartData.bondage.skills

		local teamIconPath = "UIDyAtlas/Team/IC_IDH_" .. combinationId .. "00"

		GP.SpriteUtil:SetSprite(self.img_team, teamIconPath)

		self.txt_count.text = string.format(_("LabelCombinationSkill"), battleRole, maxRole)

		local cfg = CombinationMgr:Get(combinationId)

		if not cfg then
			return
		end

		local _info = require("GamePerform.Object.InfoBattleSkillData")

		for i, id in ipairs(cfg.data.SkillList) do
			local skill = self.skillsInfo[i]

			if skill then
				local skillId = skill.skillId
				local level = skill.skillLevel
				local canUse = skill.canUse
				local skillIconPath = BattleConfig.SkillPath .. _info:GetAllSkillData(skillId).Icon

				GP.SpriteUtil:SetSprite(self.skills[i].icon, skillIconPath)
				self.skills[i].enableIcon:SetActive(canUse)
				self.skills[i].disableIcon:SetActive(not canUse)
			elseif self.skills[i] then
				local skillIconPath = BattleConfig.SkillPath .. _info:GetAllSkillData(id).Icon

				GP.SpriteUtil:SetSprite(self.skills[i].icon, skillIconPath)
				self.skills[i].enableIcon:SetActive(false)
				self.skills[i].disableIcon:SetActive(true)
			end
		end
	end

	BattleConfig.Delay(2, function()
		self:Show(false)
	end)
end

function DlgUICombinationSkill:OnRegisterEvent()
	return
end

function DlgUICombinationSkill:OnUnRegisterEvent()
	return
end

function DlgUICombinationSkill:OnPointerDown(data)
	local index = string.sub(data.pointerPress.gameObject.name, -1)

	print("111111111111")

	if data.clickCount == 1 then
		local tipData = SkillTip.GetHeroData(data.position, self.skillsInfo[tonumber(index)].skillId, self.skillsInfo[tonumber(index)].skillId, 0)

		UIMgr.ShowSkillTip(tipData)
	else
		UIMgr.HideSkillTip()
	end
end
