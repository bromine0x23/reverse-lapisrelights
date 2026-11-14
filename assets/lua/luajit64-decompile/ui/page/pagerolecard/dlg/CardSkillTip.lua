-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Dlg/CardSkillTip.lua

local skillTip = require("UI/Dlg/Common/SkillTipDesc")

CardSkillTip = class("CardSkillTip", UIPanel)

function CardSkillTip:ctor()
	self.base.ctor(self, "UI/PanelRoleCard/DlgCardSkill1")
end

function CardSkillTip:Purge()
	self.base.Purge(self)
	UnloadAllImageSprite(self)
end

function CardSkillTip:OnRegisterEvent()
	self:AddClick(self.ClickArea, self.Hide)
end

function CardSkillTip:OnUnRegisterEvent()
	self:RemoveClick(self.ClickArea, self.Hide)
end

function CardSkillTip:OnEnter()
	GOUtil.SetActive(self.UIRootObject, false)

	local txt = self:GetChildComponent("Panel/BgCost/Layout/Text", "Text")

	txt.text = Lang(5000010) .. "："
	self.ClickArea = self:GetChildGameObject("ClickArea")
	self.Panel = self:GetChildGameObject("Panel")
	self.PanelCanvas = self:GetChildComponent("Panel", "CanvasGroup")
	self.ImgSkillIcon = self:GetChildComponent("Panel/Icon", "Image")
	self.TxtSkillName = self:GetChildComponent("Panel/BgName/TxtName", "Text")
	self.TxtSkillCost = self:GetChildComponent("Panel/BgCost/Layout/TxtCost", "Text")
	self.TxtSkillLevel = self:GetChildComponent("Panel/BgLevel/TxtLevel", "Text")
	self.TxtUnlockLv = self:GetChildComponent("Panel/TxtUnlockLv", "Text")
	self.ScrollView = self:GetChildComponent("Panel/Scroll View", "ScrollRect")
	self.ScrollRT = self:GetChildComponent("Panel/Scroll View", "RectTransform")
	self.GroupRT = self:GetChildComponent("Panel/Scroll View/Viewport/Group/", "RectTransform")
	self.GoA = self:GetChildGameObject("Panel/ImgA")
	self.GoP = self:GetChildGameObject("Panel/ImgP")
	self.GoC = self:GetChildGameObject("Panel/ImgC")
	self.ImgP = GOUtil.GetComponent(self.GoP, "Image")
	self.ImgC = GOUtil.GetComponent(self.GoC, "Image")
	self.TxtDesc = self:GetChildComponent("Panel/Desc/TxtDesc", "TextView")

	for i = 1, 5 do
		self["GoLevel" .. i] = self:GetChildGameObject("Panel/Scroll View/Viewport/Group/" .. i)
		self["GoLock" .. i] = self:GetChildGameObject("Panel/Scroll View/Viewport/Group/" .. i .. "/Level/Lock")
		self["TxtLevel" .. i] = self:GetChildComponent("Panel/Scroll View/Viewport/Group/" .. i .. "/Level/Text", "Text")
		self["TxtDesc" .. i] = self:GetChildComponent("Panel/Scroll View/Viewport/Group/" .. i .. "/TxtDesc", "TextView")
	end

	self.GoCost = self:GetChildGameObject("Panel/BgCost")
	self.GoLock = self:GetChildGameObject("Panel/Lock")
	self.GoUnlock = self.TxtUnlockLv.gameObject
end

function CardSkillTip:Show(data)
	self:UpdateData(data)
	GOUtil.SetActive(self.UIRootObject, true)
end

function CardSkillTip:Hide()
	if self.PanelCanvas.alpha == 1 then
		GOUtil.SetActive(self.UIRootObject, false)
	end
end

function CardSkillTip:UpdateData(data)
	self.PanelCanvas.alpha = 0

	local infoRoleCard = data.infoRoleCard
	local infoSkill = data.infoSkill
	local scenePos = data.scenePos
	local onlyShow = data.onlyShow
	local maxLevel = infoSkill.data.HighestLevel
	local skillType = infoSkill.data.Type
	local battleType = infoSkill.data.BattleSkillType

	GOUtil.SetActive(self.GoP, battleType == 2)
	GOUtil.SetActive(self.GoC, battleType == 3)
	GOUtil.SetActive(self.GoCost, skillType == 1 and battleType == 1)

	if skillType == 1 and battleType == 1 then
		self.TxtSkillCost.text = infoSkill.battleData.Cost
	end

	self.TxtSkillName.text = Lang(infoSkill.data.Name)

	UIUtil.SetImageSprite(self.ImgSkillIcon, "UIDyAtlas/Skill/" .. infoSkill.data.Icon, self)

	local isUnlock, unLockLv, level = true, 1, 1

	if onlyShow then
		isUnlock = true
		level = maxLevel
	else
		isUnlock, unLockLv = infoRoleCard:TalentIsUnLock(infoSkill.id)
		level = infoRoleCard:GetTalentLevel(infoSkill.id)
	end

	local gray = TenaryOp(isUnlock, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgSkillIcon, gray))
	DealWithListRef(self, UIUtil.SetImageGray(self.ImgP, gray))
	DealWithListRef(self, UIUtil.SetImageGray(self.ImgC, gray))
	GOUtil.SetActive(self.GoLock, not isUnlock)
	GOUtil.SetActive(self.GoUnlock, not isUnlock)

	if not isUnlock then
		self.TxtUnlockLv.text = string.format(_("PageRoleCard_UnLockText"), _("ecNum_" .. unLockLv))
	end

	for i = 1, 5 do
		GOUtil.SetActive(self["GoLevel" .. i], i <= maxLevel)

		if i <= maxLevel then
			local alpha = TenaryOp(i <= level, 1, 0.5)

			self["TxtLevel" .. i].color = Color.New(1, 1, 1, alpha)
			self["TxtDesc" .. i].color = Color.New(1, 1, 1, alpha)
			self["TxtLevel" .. i].text = string.format(_("Desc_Level"), i)
			self["TxtDesc" .. i].Text = ModifyRichTextForTextView(skillTip.GetDesc(infoSkill.id, i, 0))

			GOUtil.SetActive(self["GoLock" .. i], level < i)

			if i <= level then
				GOUtil.SetTransformLocalPosition(self["TxtLevel" .. i].gameObject, 0, 0, 0)
			end
		end
	end

	TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
		self.GroupRT.localPosition = Vector2(self.GroupRT.localPosition.x, 0)

		if self.GroupRT.sizeDelta.y > 530 then
			self.Panel.transform.sizeDelta = Vector2(self.Panel.transform.sizeDelta.x, 750)
			self.ScrollRT.sizeDelta = Vector2(self.ScrollRT.sizeDelta.x, 530)
			self.ScrollView.vertical = true
		else
			self.ScrollView.vertical = false
			self.ScrollRT.sizeDelta = self.GroupRT.sizeDelta
			self.Panel.transform.sizeDelta = Vector2(self.Panel.transform.sizeDelta.x, 750 - (530 - self.GroupRT.sizeDelta.y))
		end

		local parentGo = self.Panel.transform.parent.gameObject

		self.Panel.transform.localPosition = UIUtil.GetTipsPos(parentGo, scenePos, self.Panel)
		self.PanelCanvas.alpha = 1
	end, nil)
end
