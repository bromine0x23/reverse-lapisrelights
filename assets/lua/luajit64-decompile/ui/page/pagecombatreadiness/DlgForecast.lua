-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCombatReadiness/DlgForecast.lua

require("UI/Page/PageTeam/TeamSystemAgent")

local InfoTeam = require("Info/InfoTeam")

DlgForecast = class("DlgForecast", UIPanel)

function DlgForecast:ctor()
	self.UIPrefabPath = "UI/PanelCombatReadiness/DlgForecast"
end

function DlgForecast:PreLoad()
	return
end

function DlgForecast:Purge()
	if self.closeFunc then
		self.closeFunc()
	end

	self.base.Purge(self)
	ResourceMgr.Unload(self.UIPrefabCache)
end

function DlgForecast:OnEnter(vParam)
	self:DealWithLocalization()

	self.infoStage = vParam.infoStage
	self.listRoleCardId = vParam.listRoleCardId
	self.listAddCardId = vParam.listAddCardId
	self.teamCE = vParam.teamCE
	self.forecastImagePath = vParam.forecastImagePath
	self.closeFunc = vParam.closeFunc
	self.btnClose = GOUtil.FindChildGameObject(self.UIRootObject, "Btnclose")
	self.forecastImage = GOUtil.FindChildComponent(self.UIRootObject, "bg1/Imagetitle", "Image")
	self.stageSafeCE = GOUtil.FindChildComponent(self.UIRootObject, "bg1/TextLevel", "Text")
	self.selfCE = GOUtil.FindChildComponent(self.UIRootObject, "bg1/TextCurrent", "Text")
	self.card = {}
	self.equipment = {}
	self.potential = {}
	self.card.root = GOUtil.FindChildGameObject(self.UIRootObject, "ScrollView/Viewport/Content/Card")
	self.card.childRoot = GOUtil.FindChildGameObject(self.UIRootObject, "ScrollView/Viewport/Content/CardChild")
	self.equipment.root = GOUtil.FindChildGameObject(self.UIRootObject, "ScrollView/Viewport/Content/Equipment")
	self.equipment.childRoot = GOUtil.FindChildGameObject(self.UIRootObject, "ScrollView/Viewport/Content/EquipmentChild")
	self.potential.root = GOUtil.FindChildGameObject(self.UIRootObject, "ScrollView/Viewport/Content/Potential")
	self.card.foldBtn = GOUtil.FindChildGameObject(self.card.root, "Fold")
	self.card.unfoldBtn = GOUtil.FindChildGameObject(self.card.root, "Unfold")
	self.equipment.foldBtn = GOUtil.FindChildGameObject(self.equipment.root, "Fold")
	self.equipment.unfoldBtn = GOUtil.FindChildGameObject(self.equipment.root, "Unfold")
	self.card.score = GOUtil.FindChildComponent(self.card.root, "Score", "Text")
	self.equipment.score = GOUtil.FindChildComponent(self.equipment.root, "Score", "Text")
	self.potential.score = GOUtil.FindChildComponent(self.potential.root, "Score", "Text")
	self.card.slider = GOUtil.FindChildComponent(self.card.root, "Slider", "Image")
	self.equipment.slider = GOUtil.FindChildComponent(self.equipment.root, "Slider", "Image")
	self.potential.slider = GOUtil.FindChildComponent(self.potential.root, "Slider", "Image")
	self.card.forecastImage = GOUtil.FindChildComponent(self.card.root, "Forecast", "Image")
	self.equipment.forecastImage = GOUtil.FindChildComponent(self.equipment.root, "Forecast", "Image")
	self.potential.forecastImage = GOUtil.FindChildComponent(self.potential.root, "Forecast", "Image")
	self.card.btnJump = GOUtil.FindChildGameObject(self.card.root, "Btn")
	self.equipment.btnJump = GOUtil.FindChildGameObject(self.equipment.root, "Btn")
	self.potential.btnJump = GOUtil.FindChildGameObject(self.potential.root, "Btn")
	self.card.Image = GOUtil.FindChildComponent(self.card.root, "Btn", "Image")
	self.equipment.Image = GOUtil.FindChildComponent(self.equipment.root, "Btn", "Image")
	self.potential.Image = GOUtil.FindChildComponent(self.potential.root, "Btn", "Image")

	local isOpen = true

	isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Card)

	local gray = TenaryOp(isOpen, 0, 1)

	UIUtil.SetImageGray(self.card.Image, gray)

	isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Equipment)

	local gray = TenaryOp(isOpen, 0, 1)

	UIUtil.SetImageGray(self.equipment.Image, gray)

	isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Talent)

	local gray = TenaryOp(isOpen, 0, 1)

	UIUtil.SetImageGray(self.potential.Image, gray)

	self.card.childs = {}

	for i = 1, 5 do
		self.card.childs[i] = {}

		local parent = GOUtil.FindChildGameObject(self.card.childRoot, "Group" .. i)

		self.card.childs[i].slider = GOUtil.FindChildComponent(parent, "slider", "Image")
		self.card.childs[i].score = GOUtil.FindChildComponent(parent, "TextNum", "Text")
	end

	self.equipment.childs = {}

	for i = 1, 3 do
		self.equipment.childs[i] = {}

		local parent = GOUtil.FindChildGameObject(self.equipment.childRoot, "Group" .. i)

		self.equipment.childs[i].slider = GOUtil.FindChildComponent(parent, "slider", "Image")
		self.equipment.childs[i].score = GOUtil.FindChildComponent(parent, "TextNum", "Text")
	end

	self.GoBuffGroup = self:GetChildGameObject("bg1/SkillBuffGroup")
	self.tex_unskill = self:GetChildComponent("bg1/tex_unskill", "Text")

	self:InitAll()
end

function DlgForecast:DealWithLocalization()
	local Text

	Text = self:GetChildComponent("bg1/Text", "Text")
	Text.text = Lang(42009)
	Text = self:GetChildComponent("ScrollView/Viewport/Content/Card/Text", "Text")
	Text.text = Lang(12219)
	Text = self:GetChildComponent("ScrollView/Viewport/Content/Card/Btn/Text", "Text")
	Text.text = _("UI_Goto_Develop")
	Text = self:GetChildComponent("ScrollView/Viewport/Content/CardChild/Group1", "Text")
	Text.text = Lang(2002)
	Text = self:GetChildComponent("ScrollView/Viewport/Content/CardChild/Group2", "Text")
	Text.text = Lang(2003)
	Text = self:GetChildComponent("ScrollView/Viewport/Content/CardChild/Group3", "Text")
	Text.text = Lang(2004)
	Text = self:GetChildComponent("ScrollView/Viewport/Content/CardChild/Group4", "Text")
	Text.text = _("Card_Rank")
	Text = self:GetChildComponent("ScrollView/Viewport/Content/CardChild/Group5", "Text")
	Text.text = _("Support_Card")
	Text = self:GetChildComponent("ScrollView/Viewport/Content/Equipment/Text", "Text")
	Text.text = _("Desc_EquipmentIntensify")
	Text = self:GetChildComponent("ScrollView/Viewport/Content/Equipment/Btn/Text", "Text")
	Text.text = _("UI_Goto_Develop")
	Text = self:GetChildComponent("ScrollView/Viewport/Content/EquipmentChild/Group1", "Text")
	Text.text = _("Equip_Level")
	Text = self:GetChildComponent("ScrollView/Viewport/Content/EquipmentChild/Group2", "Text")
	Text.text = _("Equip_Qulity")
	Text = self:GetChildComponent("ScrollView/Viewport/Content/EquipmentChild/Group3", "Text")
	Text.text = _("Equip_Enchant")
	Text = self:GetChildComponent("ScrollView/Viewport/Content/Potential/Text", "Text")
	Text.text = _("Support_Talent")
	Text = self:GetChildComponent("ScrollView/Viewport/Content/Potential/Btn/Text", "Text")
	Text.text = _("UI_Goto_Develop")
	Text = self:GetChildComponent("bg1/tex_unskill", "Text")
	Text.text = _("Desc_NoAddition")
end

function DlgForecast:OnLeave()
	return
end

function DlgForecast:OnRegisterEvent()
	self:AddClick(self.btnClose, self.OnClickClose)
	self:AddClick(self.card.foldBtn, self.OnClickFoldCard)
	self:AddClick(self.card.unfoldBtn, self.OnClickFoldCard)
	self:AddClick(self.equipment.foldBtn, self.OnClickFoldEquipment)
	self:AddClick(self.equipment.unfoldBtn, self.OnClickFoldEquipment)
	self:AddClick(self.card.btnJump, self.OnClickCardBtnJump)
	self:AddClick(self.equipment.btnJump, self.OnClickEquipmentBtnJump)
	self:AddClick(self.potential.btnJump, self.OnClickPotentialBtnJump)
	Event.Instance:Add("UpdateRaidSystem", self.UpdateRaidSystem, self)
end

function DlgForecast:OnUnRegisterEvent()
	self:RemoveClick(self.btnClose, self.OnClickClose)
	self:RemoveClick(self.card.foldBtn, self.OnClickFoldCard)
	self:RemoveClick(self.card.unfoldBtn, self.OnClickFoldCard)
	self:RemoveClick(self.equipment.foldBtn, self.OnClickFoldEquipment)
	self:RemoveClick(self.equipment.unfoldBtn, self.OnClickFoldEquipment)
	self:RemoveClick(self.card.btnJump, self.OnClickCardBtnJump)
	self:RemoveClick(self.equipment.btnJump, self.OnClickEquipmentBtnJump)
	self:RemoveClick(self.potential.btnJump, self.OnClickPotentialBtnJump)

	if self.listGoSkill then
		for i = 1, #self.listGoSkill do
			self:RemoveClick(self.listGoSkill[i], self.OnPressStageSkillClick)
		end
	end

	Event.Instance:Remove("UpdateRaidSystem", self.UpdateRaidSystem, self)
end

function DlgForecast:OnClickClose()
	self:Close()
end

function DlgForecast:OnClickFoldCard()
	self.cardOpen = not self.cardOpen

	self.card.childRoot:SetActive(self.cardOpen)
	self.card.foldBtn:SetActive(self.cardOpen)
	self.card.unfoldBtn:SetActive(not self.cardOpen)
end

function DlgForecast:OnClickFoldEquipment()
	self.equipmentOpen = not self.equipmentOpen

	self.equipment.childRoot:SetActive(self.equipmentOpen)
	self.equipment.foldBtn:SetActive(self.equipmentOpen)
	self.equipment.unfoldBtn:SetActive(not self.equipmentOpen)
end

function DlgForecast:InitAll()
	self.cardOpen = false
	self.equipmentOpen = false

	self.card.childRoot:SetActive(self.cardOpen)
	self.equipment.childRoot:SetActive(self.equipmentOpen)
	self.card.foldBtn:SetActive(self.cardOpen)
	self.card.unfoldBtn:SetActive(not self.cardOpen)
	self.equipment.foldBtn:SetActive(self.equipmentOpen)
	self.equipment.unfoldBtn:SetActive(not self.equipmentOpen)
	UIUtil.SetImageSprite(self.forecastImage, self.forecastImagePath, self)

	if self.infoStage.data.SafeCE and #self.infoStage.data.SafeCE > 0 then
		self.stageSafeCE.text = string.format(Lang(42008), "：" .. self.infoStage.data.SafeCE[1][1])
	end

	local str = "<size=50><color=#29C4C4>" .. math.floor(self.teamCE) .. "</color></size>"

	self.selfCE.text = string.format(_("Desc_Team_Current_Combat"), "：" .. str)

	self.card.forecastImage.gameObject:SetActive(false)
	self.equipment.forecastImage.gameObject:SetActive(false)
	self.potential.forecastImage.gameObject:SetActive(false)
	self:ComputeAllData(self.listRoleCardId, self.listAddCardId)
	self:InitCard()
	self:InitEquipment()
	self:InitPotential()
	self:UpdateStageSkillPanel()
end

function DlgForecast:UpdateStageSkillPanel()
	local list = OperationActiveMgr:GetAllSkillDataInside(self.infoStage.id)

	self.GoBuffGroup:SetActive(#list ~= 0)
	self.tex_unskill.gameObject:SetActive(#list == 0)

	self.Group = self:GetChildComponent("bg1/SkillBuffGroup/Group", "RectTransform")

	local group = self:GetChildGameObject("bg1/SkillBuffGroup/Group")

	GOUtil.DestroyAllChildren(group)

	local groupLayout = self:GetChildComponent("bg1/SkillBuffGroup/Group", "LayoutGroup")
	local goSkill = self:GetChildGameObject("bg1/SkillBuffGroup/Skill")

	self.listGoSkill = {}

	for i = 1, #list do
		local cell = GOUtil.Instantiate(goSkill, group)
		local icon = GOUtil.GetComponent(cell, "Image")
		local txt = GOUtil.FindChildComponent(cell, "Image/Text", "Text")
		local skillId = list[i].SkillId
		local info = TalentManager:Get(skillId)

		SetImageSprite(icon, "UIDyAtlas/Skill/" .. info.data.Icon, self)

		txt.text = OperationActiveMgr:GetStrLeftDay(list[i].ID)
		cell.name = i

		self:AddClick(cell, self.OnPressStageSkillClick)
		table.insert(self.listGoSkill, cell)
	end

	goSkill:SetActive(false)
end

function DlgForecast:OnPressStageSkillClick(data)
	local go = data.pointerPress.gameObject
	local index = tonumber(go.name)
	local list = OperationActiveMgr:GetAllSkillDataInside(self.infoStage.id)
	local skillId = list[index].SkillId
	local limitData = OperationActiveMgr:GetStrSkillTipDesc(list[index].Params)
	local timeData = OperationActiveMgr:GetStrLeftHour(list[index].ID)
	local tipData = SkillTip.GetStageSkillBuffData(data.position, skillId, true, timeData, limitData)

	UIMgr.ShowSkillTip(tipData)
end

function DlgForecast:OnPressStageSkillDown(data)
	local go = data.pointerPressRaycast.gameObject
	local index = tonumber(go.name)
	local list = OperationActiveMgr:GetAllSkillDataOutside(self.infoStage.id)
	local skillId = list[index].SkillId
	local limitData = OperationActiveMgr:GetStrSkillTipDesc(list[index].Params)
	local timeData = OperationActiveMgr:GetStrLeftHour(list[index].ID)
	local tipData = SkillTip.GetStageSkillBuffData(data.position, skillId, true, timeData, limitData)

	UIMgr.ShowSkillTip(tipData)
end

function DlgForecast:InitCard()
	self:SetScore(self.card.score, self.card.slider, self.scoreData.card, self.infoStage.data.SafeCE[2][1])
	self:SetScore(self.card.childs[1].score, self.card.childs[1].slider, self.scoreData.card_level, self.scoreData.card_level_max)
	self:SetScore(self.card.childs[2].score, self.card.childs[2].slider, self.scoreData.card_star, self.scoreData.card_star_max)
	self:SetScore(self.card.childs[3].score, self.card.childs[3].slider, self.scoreData.card_petal, self.scoreData.card_petal_max)
	self:SetScore(self.card.childs[4].score, self.card.childs[4].slider, self.scoreData.card_rarity, self.scoreData.card_rarity_max)
	self:SetScore(self.card.childs[5].score, self.card.childs[5].slider, self.scoreData.card_support, self.scoreData.card_support_max)
end

function DlgForecast:InitEquipment()
	self:SetScore(self.equipment.score, self.equipment.slider, self.scoreData.equipment, self.infoStage.data.SafeCE[3][1])
	self:SetScore(self.equipment.childs[1].score, self.equipment.childs[1].slider, self.scoreData.equipment_level, self.scoreData.equipment_level_max)
	self:SetScore(self.equipment.childs[2].score, self.equipment.childs[2].slider, self.scoreData.equipment_breakthrough, self.scoreData.equipment_breakthrough_max)
	self:SetScore(self.equipment.childs[3].score, self.equipment.childs[3].slider, self.scoreData.equipment_enchant, self.scoreData.equipment_enchant_max)
end

function DlgForecast:InitPotential()
	self:SetScore(self.potential.score, self.potential.slider, self.scoreData.potential, self.infoStage.data.SafeCE[4][1])
end

function DlgForecast:SetScore(txt, slider, cur, total)
	txt.text = math.floor(cur) .. "/" .. total
	slider.fillAmount = math.min(1, cur / total)
end

function DlgForecast:ComputeAllData(listRoleCardId, listAddCardId)
	self.scoreData = {
		equipment = 0,
		card_level = 0,
		potential = 0,
		equipment_enchant = 0,
		equipment_level = 0,
		equipment_breakthrough = 0,
		card_rarity = 0,
		card_support = 0,
		card_petal = 0,
		card_star = 0,
		card = 0,
		card_level_max = self.infoStage.data.SafeCE[2][2],
		card_star_max = self.infoStage.data.SafeCE[2][3],
		card_petal_max = self.infoStage.data.SafeCE[2][4],
		card_rarity_max = self.infoStage.data.SafeCE[2][5],
		card_support_max = self.infoStage.data.SafeCE[2][6],
		equipment_level_max = self.infoStage.data.SafeCE[3][2],
		equipment_breakthrough_max = self.infoStage.data.SafeCE[3][3],
		equipment_enchant_max = self.infoStage.data.SafeCE[3][4]
	}

	for i = 1, #listRoleCardId do
		if listRoleCardId[i] ~= 0 then
			local roleCard = RoleCardMgr:GetRoleCard(listRoleCardId[i])
			local role = RoleMgr:GetRole(roleCard.data.CharacterID)
			local cardArr = RoleCardMgr:GetFightValueByAtt(roleCard.attrs)

			self.scoreData.card = self.scoreData.card + cardArr
			self.scoreData.card_level = self.scoreData.card_level + roleCard.curLevel
			self.scoreData.card_star = self.scoreData.card_star + roleCard.curStarLevel
			self.scoreData.card_petal = self.scoreData.card_petal + roleCard.curPetal
			self.scoreData.card_rarity = self.scoreData.card_rarity + roleCard.cardRank

			local addCardId = listAddCardId[i]
			local addRoleCard

			if addCardId ~= 0 then
				addRoleCard = RoleCardMgr:GetRoleCard(addCardId)

				local _type = TeamSystemAgent.GetAddCardType(roleCard.id, addRoleCard.id)
				local addNum = RoleCardMgr:GetCardFightValue(roleCard, addRoleCard)

				self.scoreData.card_support = self.scoreData.card_support + addNum
			end

			local equipNum = 0
			local levelNum = 0
			local qualityNum = 0
			local enchantNum = 0

			for j = 1, 6 do
				local isUnlock = role:IsEquipSlotUnlocked(j)
				local slotFight = 0

				if isUnlock then
					local equipId = role:GetEquipId(j)
					local infoEquip = EquipmentManager:GetEquip(equipId)
					local infoSlot = role:GetEquipSlot(j)

					levelNum = levelNum + infoSlot.level
					qualityNum = qualityNum + EquipmentManager:GetBreakNum(infoSlot)
				end
			end

			local attrEquip = AttributeOwner()
			local attrEnchant = AttributeOwner()

			for _, v in pairs(ATTRIBUTE_NAME) do
				attrEnchant:SetBase(v, role.equipBaseAtt:Get(v))
				attrEnchant:ModMul(v, role.equipEnchantAtt:GetExtraMul(v))
				attrEnchant:ModAdd(v, role.equipEnchantAtt:GetExtraAdd(v))
				attrEquip:SetBase(v, attrEnchant.attcomponent:CalculateLevelGain(v, 1))
			end

			equipNum = equipNum + RoleCardMgr:GetFightValueByAtt(role.equipAtt)
			enchantNum = enchantNum + RoleCardMgr:GetFightValueByAtt(attrEquip)
			self.scoreData.equipment = self.scoreData.equipment + equipNum
			self.scoreData.equipment_level = self.scoreData.equipment_level + levelNum
			self.scoreData.equipment_breakthrough = self.scoreData.equipment_breakthrough + qualityNum
			self.scoreData.equipment_enchant = self.scoreData.equipment_enchant + enchantNum

			local talentAtt = role.talentAtt
			local talentNum = RoleCardMgr:GetFightValueByAtt(talentAtt)

			self.scoreData.potential = self.scoreData.potential + talentNum
		end
	end
end

function DlgForecast:OnClickCardBtnJump()
	if self.teamCE == 0 then
		UIMgr.ShowMsg(_("Desc_Team_None"))

		return
	end

	local isOpen = true

	isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Card)

	if not isOpen then
		return
	end

	UIMgr.ClearChildAndSavePageMainStage()
	require("UI/Page/PageRoleCard/Page/PageRoleCardList")
	UIMgr.SwitchPanel(PageRoleCardList, {
		entType = 1
	})
end

function DlgForecast:OnClickEquipmentBtnJump()
	if self.teamCE == 0 then
		UIMgr.ShowMsg(_("Desc_Team_None"))

		return
	end

	local isOpen = true

	isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Equipment)

	if not isOpen then
		return
	end

	UIMgr.ClearChildAndSavePageMainStage()
	require("UI/Page/PageEquipment/PageEquip")
	CharacterThinMgr.DoResetOperate(CharacterThinMgr.ResetType.STAGE, self.infoStage.data.ID)
	UIMgr.SwitchPanel(PageEquip)
end

function DlgForecast:OnClickPotentialBtnJump()
	if self.teamCE == 0 then
		UIMgr.ShowMsg(_("Desc_Team_None"))

		return
	end

	local isOpen = true

	isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Talent)

	if not isOpen then
		return
	end

	UIMgr.ClearChildAndSavePageMainStage()
	require("UI/Page/PageRole/PageTalentTree")
	CharacterThinMgr.DoResetOperate(CharacterThinMgr.ResetType.STAGE, self.infoStage.data.ID)
	UIMgr.SwitchPanel(PageTalentTree)
end

function DlgForecast:UpdateRaidSystem()
	if self.infoStage and self.infoStage.data.ChapterType == ChapterFromType.union then
		self:Close()
	end
end
