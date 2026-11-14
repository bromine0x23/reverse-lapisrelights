-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Cells/UISkillCard.lua

UISkillCard = class("UISkillCard", UIPanel_sync)

require("UI/Dlg/Common/SkillTip")

local lightBGUpTime = 0.36666666666666664

function UISkillCard:ctor(parentDlg)
	UISkillCard.base.ctor(self, "UI/PageFight/Cells/UISkillCard")

	self.parentDlg = parentDlg
end

function UISkillCard:OnEnter(vParam)
	self:Show(false)

	self.select = false
	self.lanText = self:GetChildComponent("card/txt_lan", "Text")
	self.jobImg = self:GetChildComponent("card/jobIcon", "Image")
	self.roleImg = self:GetChildComponent("card/roleMask/roleImg", "Image")
	self.skillImg = self:GetChildComponent("card/skillIcon", "Image")
	self.card = self:GetChildGameObject("card")
	self.gou = self:GetChildGameObject("card/gou")
	self.lightBG = self:GetChildGameObject("card/light")
	self.mask = self:GetChildGameObject("card/mask")
	self.cardAnimator = GOUtil.GetComponent(self.card, "Animator")
end

function UISkillCard:OnRegisterEvent()
	self:AddClick(self.card, self.OnCardClick)
	self:AddListener(self.card, self.OnPointerDown, EventTriggerType.PointerLongPress)
end

function UISkillCard:OnUnRegisterEvent()
	self:RemoveClick(self.card, self.OnCardClick)
	self:RemoveListener(self.card, self.OnPointerDown, EventTriggerType.PointerLongPress)
end

function UISkillCard:OnPointerDown(data)
	if data.clickCount == 1 then
		local tipData = SkillTip.GetHeroData(data.position, self.unitSkill.AllSkillId, self.unitSkill.AllSkillLv, 0)

		UIMgr.ShowSkillTip(tipData)

		if InstructionMgr:IsInGuide() and UIMgr.DlgGuide.isKeepTalk and UIMgr.DlgGuide.callbackClick then
			UIMgr.DlgGuide.callbackClick()
		end
	elseif InstructionMgr:IsInGuide() then
		if UIMgr.DlgGuide.IsLongPress == nil then
			UIMgr.HideSkillTip()
		end
	else
		UIMgr.HideSkillTip()
	end
end

function UISkillCard:Init(unitSkill)
	self:Show(true)

	self.unitSkill = unitSkill

	local jobpath = "UIDyAtlas/RoleJob/ICO_" .. unitSkill.Owner.UnitData.data.Job .. "_01"

	GP.SpriteUtil:SetSprite(self.jobImg, jobpath)

	self.lanText.text = unitSkill.Cost

	local rolepath = unitSkill.Owner.InfoRoleCard.data.MidIcon

	GP.SpriteUtil:SetSprite(self.roleImg, rolepath)
	unitSkill:SetIcon(self.skillImg)
	self:UpdateSelect(true)
	self.cardAnimator:Play("Enter")
end

function UISkillCard:OnCardClick()
	if self.select then
		self.select = false

		self:UpdateSelect()
	elseif not self.parentDlg:IsMaxCount() then
		self.select = true

		self:UpdateSelect()
	end
end

function UISkillCard:Purge()
	UISkillCard.base.Purge(self)

	if self.lightBGTimerId ~= nil then
		TimerMgr.RemoveTimer(self.lightBGTimerId)
	end
end

function UISkillCard:UpdateSelect(init)
	if self.select then
		self.gou:SetActive(true)
		self.mask:SetActive(true)

		if not init then
			self.cardAnimator:CrossFade("Up", 0.1)

			self.lightBGTimerId = BattleConfig.Delay(lightBGUpTime, function()
				self.lightBG:SetActive(false)
			end)
		end
	else
		self.gou:SetActive(false)
		self.mask:SetActive(false)
		self.lightBG:SetActive(true)

		if not init then
			self.cardAnimator:CrossFade("Down", 0.1)

			if self.lightBGTimerId ~= nil then
				TimerMgr.RemoveTimer(self.lightBGTimerId)
			end
		end
	end

	self.parentDlg:UpdateSelect()
end
