-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageSkillViewer/Dlg/DlgNpcSkill.lua

DlgNpcSkill = class("DlgNpcSkill", UIPanel)

function DlgNpcSkill:ctor()
	DlgNpcSkill.base.ctor(self, "UI/PageSkillViewer/Dlg/DlgNpcSkill")
end

function DlgNpcSkill:Cache()
	DlgNpcSkill.base.Cache(self)
end

function DlgNpcSkill:Close(tParam)
	DlgNpcSkill.base.Close(self, tParam)
end

function DlgNpcSkill:Purge()
	DlgNpcSkill.base.Purge(self)

	self.list = {}
	self.list_player = {}
end

function DlgNpcSkill:OnRegisterEvent()
	self:AddClick(self.btn_close, self.OnBtnClose, PATH_SFX_UI_CANCEL)
	self:AddClick(self.touch_close, self.OnBtnClose, PATH_SFX_UI_CANCEL)
end

function DlgNpcSkill:OnUnRegisterEvent()
	self:RemoveClick(self.touch_close, self.OnBtnClose)
	self:RemoveClick(self.btn_close, self.OnBtnClose)

	for i, cell in ipairs(self.list) do
		self:RemoveClick(cell.gameObject, cell.onClick)
	end
end

function DlgNpcSkill:OnBtnClose()
	self:Show(false)
end

function DlgNpcSkill:OnEnter(vParam)
	self.list = {}
	self.touch_close = self:GetChildGameObject("panel")
	self.btn_close = self:GetChildGameObject("panel/btn_close")

	self:Show(false)
end

function DlgNpcSkill:Open()
	self:Show(true)
	self:Refresh()
end

local idx = 1

function DlgNpcSkill:Refresh()
	if SV.Npc == nil then
		self:Show(false)

		return
	end

	local itemT = self:GetChildGameObject("panel/skills/ItemT")
	local itemRoot = itemT.transform.parent.gameObject
	local skills = SV.Npc.NpcSkills

	for i, cell in ipairs(self.list) do
		GOUtil.SetActive(cell.gameObject, false)
	end

	for k, npcSkill in pairs(skills) do
		local cell = {}

		if self.list[idx] then
			cell = self.list[idx]
		end

		local skillId = npcSkill.Id
		local battleSkillId = npcSkill.BattleSkillId

		if not cell.gameObject then
			cell.gameObject = GOUtil.InstantiateUI(itemT, itemRoot)

			local labelObj = GOUtil.FindGameObjectByName("txt_info", cell.gameObject)
			local imgObj = GOUtil.FindGameObjectByName("img_icon", cell.gameObject)

			cell.txt = GOUtil.GetComponent(labelObj, "Text")
			cell.img = GOUtil.GetComponent(imgObj, "Image")

			table.insert(self.list, cell)

			idx = idx + 1
		end

		cell.skillId = skillId

		function cell.onClick()
			npcSkill:Cast()
		end

		cell.txt.text = tostring(skillId) .. "\n" .. npcSkill.Name

		cell.img.gameObject:SetActive(true)
		npcSkill:SetIcon(cell.img)
		GOUtil.SetActive(cell.gameObject, true)
		self:AddClick(cell.gameObject, cell.onClick)
	end

	GOUtil.SetActive(itemT, false)
end

function DlgNpcSkill:_EnemySkills()
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

function DlgNpcSkill:_PlayerSkills()
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
