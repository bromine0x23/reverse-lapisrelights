-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/SkillTip.lua

local _BattleSkillData = require("GamePerform.Object.InfoBattleSkillData")
local BuffData = require("luaData/BattleBuffData")
local SkillDesc = require("UI/Dlg/Common/SkillTipDesc")

SkillTip = class("SkillTip", UIPanel)

local BallIconPath = {
	"UIDyAtlas/Skill/IC_SKI_Act_Red",
	"UIDyAtlas/Skill/IC_SKI_Act_Blu",
	"UIDyAtlas/Skill/IC_SKI_Act_Yel",
	"UIDyAtlas/Skill/IC_SKI_Act_Spe_Red",
	"UIDyAtlas/Skill/IC_SKI_Act_Spe_Blu",
	"UIDyAtlas/Skill/IC_SKI_Act_Spe_Yel"
}

function SkillTip.GetHeroData(scenePos, skillId, skillLevel, powerLevel, showOnDown)
	local data = {}

	data.scenePos = scenePos
	data.skillId = skillId
	data.skillLevel = skillLevel > 0 and skillLevel or 1
	data.locked = skillLevel <= 0
	data.powerLevel = powerLevel
	data.showOnDown = showOnDown
	data.isHeroSkill = true

	return data
end

function SkillTip.GetMonsterData(scenePos, skillId, monsterState, showOnDown)
	local data = {}

	data.scenePos = scenePos
	data.skillId = skillId
	data.skillLevel = 1
	data.monsterState = monsterState
	data.showOnDown = showOnDown
	data.isHeroSkill = false

	return data
end

function SkillTip.GetBallData(scenePos, skillId, ballType, showOnDown, offSetX, isGray)
	local data = {}

	data.scenePos = scenePos
	data.skillId = skillId
	data.skillLevel = 1
	data.showOnDown = showOnDown
	data.isHeroSkill = true
	data.ballType = ballType
	data.offSetX = offSetX
	data.isGray = isGray

	return data
end

function SkillTip.GetWorkCondData(scenePos, infoWorkCond, showOnDown)
	local data = {}

	data.scenePos = scenePos
	data.infoWorkCond = infoWorkCond
	data.showOnDown = showOnDown
	data.isWorkCond = true

	return data
end

function SkillTip.GetStageSkillBuffData(scenePos, skillId, showOnDown, timeData, limitData)
	local data = {}

	data.scenePos = scenePos
	data.skillId = skillId
	data.skillLevel = 1
	data.showOnDown = showOnDown
	data.isHeroSkill = true
	data.limitData = limitData
	data.timeData = timeData

	return data
end

function SkillTip:ctor()
	SkillTip.base.ctor(self, "UI/CommonTip/SkillTip/SkillTip")

	self.tipData = {}
	self.closed = true
end

function SkillTip:OnEnter(vParam)
	local TextAuto

	TextAuto = self:GetChildComponent("Panel/PowerLevel/Txt/", "Text")
	TextAuto.text = Lang(5000046)
	self.PanelObj = self:GetChildGameObject("Panel")
	self.BgBtn = self:GetChildGameObject("Bg")
	self.heroIconObj = self:GetChildGameObject("Panel/Skill/HeroIcon")
	self.heroIcon = self:GetChildComponent("Panel/Skill/HeroIcon", "Image")
	self.goBgC = self:GetChildGameObject("Panel/Skill/HeroIcon/BgC")
	self.goBgA = self:GetChildGameObject("Panel/Skill/HeroIcon/BgA")
	self.goBgP = self:GetChildGameObject("Panel/Skill/HeroIcon/BgP")
	self.goBgSp = self:GetChildGameObject("Panel/Skill/HeroIcon/BgSp")
	self.imgBgSp = self:GetChildComponent("Panel/Skill/HeroIcon/BgSp", "Image")
	self.Lock = self:GetChildGameObject("Panel/Skill/HeroIcon/Lock")
	self.monsterIconObj = self:GetChildGameObject("Panel/Skill/MonsterIcon")
	self.monsterIcon = self:GetChildComponent("Panel/Skill/MonsterIcon", "Image")
	self.nameText = self:GetChildComponent("Panel/TxtName", "Text")
	self.nameWorkText = self:GetChildComponent("Panel/TxtWorkName", "Text")
	self.descText = self:GetChildComponent("Panel/TxtDesc", "Text")
	self.descTextObj = self:GetChildGameObject("Panel/TxtDesc")
	self.levelText = self:GetChildComponent("Panel/TxtLevel", "Text")
	self.timeText = self:GetChildComponent("Panel/TxtTime", "Text")
	self.state1 = self:GetChildGameObject("Panel/MonsterState/State1")
	self.state2 = self:GetChildGameObject("Panel/MonsterState/State2")
	self.state3 = self:GetChildGameObject("Panel/MonsterState/State3")
	self.powerLevelObj = self:GetChildGameObject("Panel/PowerLevel")
	self.powerLevel = self:GetChildComponent("Panel/PowerLevel/Level", "Text")
	self.workCondIconObj = self:GetChildGameObject("Panel/Skill/WorkCondIcon")
	self.workCondIcon = self:GetChildComponent("Panel/Skill/WorkCondIcon", "Image")

	GOUtil.SetFont(self.descText, UIMgr.JPFonts.W5)
	self:AddClick(self.BgBtn, self.Hide)

	if vParam then
		self:Open(vParam)
	end
end

function SkillTip:SetData(data)
	self.tipData = {}
	self.tipData.scenePos = data.scenePos
	self.tipData.isHeroSkill = data.isHeroSkill
	self.tipData.skillId = data.skillId
	self.tipData.skillLevel = data.skillLevel
	self.tipData.locked = data.locked
	self.tipData.powerLevel = data.powerLevel
	self.tipData.showOnDown = data.showOnDown
	self.tipData.monsterState = data.monsterState
	self.tipData.ballType = data.ballType
	self.tipData.isWorkCond = data.isWorkCond
	self.tipData.infoWorkCond = data.infoWorkCond
	self.tipData.timeData = data.timeData
	self.tipData.limitData = data.limitData
end

function SkillTip:Open(data)
	self:SetData(data)

	local infoSkill, infoBattleSkill
	local name = ""
	local iconPath = ""

	GOUtil.SetActive(self.nameText, self.tipData.isWorkCond ~= true)
	GOUtil.SetActive(self.nameWorkText, self.tipData.isWorkCond == true)

	if not self.tipData.isWorkCond then
		infoSkill = _BattleSkillData:GetAllSkillData(self.tipData.skillId)
		infoBattleSkill = _BattleSkillData:GetData(infoSkill.BattleSkillID[self.tipData.skillLevel])
		name = Lang(infoSkill.Name)

		if infoSkill.Icon ~= "" then
			iconPath = "UIDyAtlas/Skill/" .. infoSkill.Icon
		end

		self.nameText.text = name
	else
		name = Lang(self.tipData.infoWorkCond.Name)
		iconPath = self.tipData.infoWorkCond.Icon
		self.nameWorkText.text = name
	end

	local icon

	self.heroIconObj:SetActive(self.tipData.isHeroSkill)

	self.levelText.text = ""

	self.goBgC:SetActive(false)
	self.goBgA:SetActive(false)
	self.goBgP:SetActive(false)
	self.goBgSp:SetActive(false)
	self.powerLevelObj:SetActive(false)
	self.monsterIconObj:SetActive(not self.tipData.isHeroSkill and self.tipData.isWorkCond ~= true)
	self.state1:SetActive(false)
	self.state2:SetActive(false)
	self.state3:SetActive(false)
	self.workCondIconObj:SetActive(self.tipData.isWorkCond == true)

	if self.tipData.isHeroSkill then
		if self.tipData.ballType == nil then
			UIUtil.SetImageSprite(self.heroIcon, iconPath, self)
		else
			UIUtil.SetImageSprite(self.heroIcon, iconPath, self)

			if self.tipData.ballType > 3 then
				self.goBgSp:SetActive(true)
			end
		end

		if self.tipData.ballType ~= nil or infoSkill.BattleSkillType == 1 then
			self.goBgA:SetActive(true)
		elseif infoSkill.BattleSkillType == 2 then
			self.goBgP:SetActive(true)
		else
			self.goBgC:SetActive(true)
		end

		if self.tipData.locked then
			self.levelText.text = _("PageTalentTree_Locked")
		else
			self.levelText.text = _("Player_Level") .. self.tipData.skillLevel
		end

		if self.tipData.timeData then
			self.timeText.gameObject:SetActive(true)
			self.levelText.gameObject:SetActive(false)

			self.timeText.text = self.tipData.timeData
		else
			self.timeText.gameObject:SetActive(false)
			self.levelText.gameObject:SetActive(true)
		end

		if infoBattleSkill ~= nil and infoBattleSkill.IsStackPower == 1 and self.tipData.powerLevel > 0 then
			self.powerLevelObj:SetActive(true)

			self.powerLevel.text = self.tipData.powerLevel
		end
	else
		self.timeText.gameObject:SetActive(false)

		if not self.tipData.isWorkCond then
			UIUtil.SetImageSprite(self.monsterIcon, iconPath, self)

			if self.tipData.monsterState == 1 then
				self.state1:SetActive(true)
			elseif self.tipData.monsterState == 2 then
				self.state2:SetActive(true)
			elseif self.tipData.monsterState == 3 then
				self.state3:SetActive(true)
			end
		else
			UIUtil.SetImageSprite(self.workCondIcon, iconPath, self)
		end
	end

	if not self.tipData.isWorkCond then
		if self.tipData.limitData then
			self.descText.text = self.tipData.limitData .. Lang(_BattleSkillData:GetAllSkillData(self.tipData.skillId).Description[1])
		else
			self.descText.text = SkillTip.GetDesc(self.tipData.skillId, self.tipData.skillLevel, self.tipData.powerLevel, self.tipData.ballType)
		end
	else
		self.descText.text = Lang(self.tipData.infoWorkCond.Info)
	end

	UIUtil.ForceRebuildLayoutImmediate(self.descTextObj)

	local textHeight = GOUtil.GetRectTransformSizeDeltaHeight(self.descTextObj)
	local offset = textHeight - 123

	if offset < 0 then
		offset = 0
	end

	GOUtil.SetRectTransformSizeDeltaHeight(self.PanelObj, 218 + offset)

	local parentGo = self.PanelObj.transform.parent.gameObject

	if self.tipData.showOnDown then
		self.PanelObj.transform.localPosition = UIUtil.GetTipsPos(parentGo, self.tipData.scenePos, self.PanelObj, -100)
	else
		local tipOffset = GOUtil.GetRectTransformSizeDeltaHeight(self.PanelObj) + 100

		self.PanelObj.transform.localPosition = UIUtil.GetTipsPos(parentGo, self.tipData.scenePos, self.PanelObj, tipOffset)

		if data.offSetX then
			self.PanelObj.transform.localPosition = Vector3.New(self.PanelObj.transform.localPosition.x + data.offSetX, self.PanelObj.transform.localPosition.y, 0)
		end
	end

	DealWithListRef(self, UIUtil.SetImageGray(self.heroIcon, TenaryOp(data.isGray, 1, 0)))
	DealWithListRef(self, UIUtil.SetImageGray(self.imgBgSp, TenaryOp(data.isGray, 1, 0)))

	if self.Lock then
		self.Lock:SetActive(data.isGray)
	end
end

function SkillTip.GetDesc(skillId, skillLevel, powerLevel, ballType)
	local desc = ""

	xpcall(function()
		desc = SkillDesc.GetDesc(skillId, skillLevel, powerLevel, ballType)
	end, function(err)
		print(err)
		print(debug.traceback())
	end)

	return desc
end

function SkillTip:Hide()
	UnloadAllImageSprite(self)
	self:RemoveClick(self.BgBtn, self.Hide)
	self:Close()
end
