-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DebugPanels/GMDlgMonsterSkill.lua

GMDlgMonsterSkill = class("GMDlgMonsterSkill", UIPanel_sync)

function GMDlgMonsterSkill:ctor()
	GMDlgMonsterSkill.base.ctor(self, "UI/PageFight/Dlg/GMDlgMonsterSkill")
end

function GMDlgMonsterSkill:Cache()
	GMDlgMonsterSkill.base.Cache(self)
end

function GMDlgMonsterSkill:Close(tParam)
	GMDlgMonsterSkill.base.Close(self, tParam)
end

function GMDlgMonsterSkill:Purge()
	GMDlgMonsterSkill.base.Purge(self)

	self.list = {}
	self.list_player = {}
end

function GMDlgMonsterSkill:OnRegisterEvent()
	self:AddClick(self.btn_close, self.OnBtnClose)
	self:AddClick(self.touch_close, self.OnBtnClose)
end

function GMDlgMonsterSkill:OnUnRegisterEvent()
	self:RemoveClick(self.touch_close, self.OnBtnClose)
	self:RemoveClick(self.btn_close, self.OnBtnClose)

	for i, cell in ipairs(self.list) do
		self:RemoveClick(cell.gameObject, cell.onClick)
	end
end

function GMDlgMonsterSkill:OnBtnClose()
	self:Close()
end

function GMDlgMonsterSkill:OnEnter(vParam)
	self.touch_close = self:GetChildGameObject("panel")
	self.btn_close = self:GetChildGameObject("panel/btn_close")

	self:_EnemySkills()
	self:_PlayerSkills()
end

function GMDlgMonsterSkill:_EnemySkills()
	self.list = {}

	local selectUnit = GP.SelectUnits[1]

	if not selectUnit then
		return
	end

	local itemT = self:GetChildGameObject("panel/skills/ItemT")
	local itemRoot = itemT.transform.parent.gameObject
	local monsters = require("luaData/Monster")
	local cfg = monsters[selectUnit.UnitId]

	if not cfg then
		return
	end

	local skillList = {}

	for i, skillId in ipairs(cfg.StageOfAngryBuff) do
		if i ~= 1 and skillId ~= 0 then
			table.insert(skillList, skillId)
		end
	end

	for i, skillId in ipairs(cfg.StageSkillId) do
		if skillId ~= 0 then
			table.insert(skillList, skillId)
		end
	end

	for i, skillId in ipairs(cfg.AppearSkills) do
		if skillId ~= 0 then
			table.insert(skillList, skillId)
		end
	end

	local skillDatas = require("luaData/AllSkills")

	for i, skillId in ipairs(skillList) do
		local cell = {}

		cell.gameObject = GOUtil.InstantiateUI(itemT, itemRoot)
		cell.skillId = skillId

		function cell.onClick()
			Event.Instance:Fire("CMD_Message", "eskill " .. cell.skillId)
			self:Close()
		end

		if skillDatas[skillId] then
			local skillName = Lang(skillDatas[skillId].Name)
			local txt = GOUtil.FindGameObjectByName("txt_info", cell.gameObject)

			txt = GOUtil.GetComponent(txt, "Text")
			txt.text = tostring(skillId) .. "\n" .. skillName
		end

		self:AddClick(cell.gameObject, cell.onClick)
		table.insert(self.list, cell)
	end

	GOUtil.SetActive(itemT, false)
end

function GMDlgMonsterSkill:_PlayerSkills()
	local itemT = self:GetChildGameObject("panel/skills_player/ItemT")
	local itemRoot = itemT.transform.parent.gameObject

	self.list_player = {}

	local skillList = {}

	for i, unit in ipairs(GP.Team.PlayerTeam) do
		for j, skill in ipairs(unit.OwnSkills) do
			if skill.BattleSkillType == EnumFight.SkillType.Active then
				table.insert(skillList, {
					skill.Owner.UniqueId,
					skill.Id
				})
			end
		end
	end

	local skillDatas = require("luaData/AllSkills")

	for i, data in ipairs(skillList) do
		local uniqueId = data[1]
		local skillId = data[2]
		local cell = {}

		cell.gameObject = GOUtil.InstantiateUI(itemT, itemRoot)
		cell.skillId = skillId
		cell.uniqueId = uniqueId

		function cell.onClick()
			Event.Instance:Fire("CMD_Message", "pskill " .. cell.skillId .. "," .. cell.uniqueId)
			self:Close()
		end

		local allSkillId = ConfigTable.BattleSkillData[skillId].AllSkillID

		if skillDatas[allSkillId] then
			local skillName = Lang(skillDatas[allSkillId].Name)
			local txt = GOUtil.FindGameObjectByName("txt_info", cell.gameObject)

			txt = GOUtil.GetComponent(txt, "Text")
			txt.text = tostring(allSkillId) .. "\n" .. skillName
		end

		self:AddClick(cell.gameObject, cell.onClick)
		table.insert(self.list, cell)
	end

	GOUtil.SetActive(itemT, false)
end
