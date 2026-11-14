-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Cell/CellCardSkill.lua

require("UI/Item/UIItemBase")
require("UI/Dlg/Common/SkillTip")

CellCardSkill = class("CellCardSkill", UIItemBase)
CELL_CARD_SKILL_TYPE = {
	Ability = 3,
	Skill = 1,
	Ball = 2
}

function CellCardSkill:ctor(itemPrefabCache, parent, ownerUI, showTipsOnDown)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = ownerUI
	self.showTipsOnDown = showTipsOnDown
end

function CellCardSkill:Create(vParam)
	CellCardSkill.base.Create(self, vParam)
end

function CellCardSkill:OnEnter()
	local g = self.UIRootObject

	self.GoSkill = GOUtil.FindChildGameObject(g, "Skill")
	self.GoBall = GOUtil.FindChildGameObject(g, "Ball")
	self.GoAbility = GOUtil.FindChildGameObject(g, "Ability")
	self.ImgSkillIcon = GOUtil.FindChildComponent(self.GoSkill, "Icon", "Image")
	self.TxtSkillLevel = GOUtil.FindChildComponent(self.GoSkill, "Level/Text", "Text")
	self.GoLvMax = GOUtil.FindChildGameObject(self.GoSkill, "LvMax")
	self.GoP = GOUtil.FindChildGameObject(self.GoSkill, "ImgP")
	self.GoC = GOUtil.FindChildGameObject(self.GoSkill, "ImgC")
	self.GoLock = GOUtil.FindChildGameObject(self.GoSkill, "Lock")
	self.GoLevel = GOUtil.FindChildGameObject(self.GoSkill, "Level")
	self.GoCaptain = GOUtil.FindChildGameObject(self.GoSkill, "Captain")
	self.ImgBallIcon = GOUtil.FindChildComponent(self.GoBall, "Icon", "Image")
	self.TxtBallName = GOUtil.FindChildComponent(self.GoBall, "Name/Text", "Text")
	self.GoLockBall = GOUtil.FindChildGameObject(self.GoBall, "Lock")
	self.GoS = GOUtil.FindChildGameObject(self.GoBall, "ImgS")
	self.ImgS = GOUtil.FindChildComponent(self.GoBall, "ImgS", "Image")
	self.ImgAbilityIcon = GOUtil.FindChildComponent(g, "Ability/Icon", "Image")

	self:AddListener(g, self.OnPointerDown, EventTriggerType.PointerDown)
	self:AddListener(g, self.OnPointerUp, EventTriggerType.PointerUp)
end

function CellCardSkill:OnLeave()
	UnloadAllImageSprite(self)
	self:RemoveListener(self.UIRootObject, self.OnPointerDown, EventTriggerType.PointerDown)
	self:RemoveListener(self.UIRootObject, self.OnPointerUp, EventTriggerType.PointerUp)
end

function CellCardSkill:OnPointerDown(data)
	if self.showType == CELL_CARD_SKILL_TYPE.Skill and self.cardOverview and self.page then
		local temp = {}

		temp.infoRoleCard = self.infoRoleCard
		temp.infoSkill = self.info
		temp.scenePos = data.position
		temp.onlyShow = self.page.onlyShow

		self.page.CardSkillTip:Show(temp)

		return
	end

	local tipData = {}

	if self.info then
		if self.showType == CELL_CARD_SKILL_TYPE.Skill then
			tipData = SkillTip.GetHeroData(data.position, self.info.id, self.level, 0, self.showTipsOnDown)
		elseif self.showType == CELL_CARD_SKILL_TYPE.Ball then
			tipData = SkillTip.GetBallData(data.position, self.info.id, self.ballType, self.showTipsOnDown, 0, not self.isUnLockBall)
		elseif self.showType == CELL_CARD_SKILL_TYPE.Ability then
			tipData = SkillTip.GetWorkCondData(data.position, self.info)
		end
	end

	UIMgr.ShowSkillTip(tipData)
end

function CellCardSkill:OnPointerUp()
	return
end

function CellCardSkill:UpdateData(data)
	self.showTipsOnDown = data.showTipsOnDown

	UnloadAllImageSprite(self)

	self.info = data.info
	self.infoRoleCard = data.infoRoleCard
	self.showType = Tenary(data.infoType, CELL_CARD_SKILL_TYPE.Skill)
	self.cardOverview = data.cardOverview
	self.onlyShow = data.onlyShow

	if data.showNameOrLevel == false then
		GOUtil.SetActive(self.GoLevel, false)
	end

	self.GoBall:SetActive(self.showType == CELL_CARD_SKILL_TYPE.Ball)
	self.GoSkill:SetActive(self.showType == CELL_CARD_SKILL_TYPE.Skill)
	self.GoAbility:SetActive(self.showType == CELL_CARD_SKILL_TYPE.Ability)

	local infoRoleCard = data.infoRoleCard

	if self.showType == CELL_CARD_SKILL_TYPE.Skill then
		local battleType = self.info.data.BattleSkillType

		self.GoP:SetActive(battleType == eBattleTalentType.Passive)
		self.GoC:SetActive(battleType == eBattleTalentType.Center)
		self.GoCaptain:SetActive(false)
		SetImageSprite(self.ImgSkillIcon, "UIDyAtlas/Skill/" .. self.info.data.Icon, self)
		self:UpdateSkillUnlock()
		self:UpdateSkillLevel()
	end

	if self.showType == CELL_CARD_SKILL_TYPE.Ball then
		local _, ballType = RoleCardMgr:GetRoleCardSpecialBall(infoRoleCard)

		self.ballType = ballType

		SetImageSprite(self.ImgBallIcon, "UIDyAtlas/Skill/" .. self.info.data.Icon, self)
		self:UpdateBallUnlock()
	end

	if self.showType == CELL_CARD_SKILL_TYPE.Ability then
		UIUtil.SetImageSprite(self.ImgAbilityIcon, self.info.Icon, self)
	end
end

function CellCardSkill:UpdateBallUnlock()
	local isUnlock, unlockLevel = self.infoRoleCard:TalentIsUnLock(self.info.id)

	isUnlock = isUnlock or self.onlyShow
	self.isUnLockBall = isUnlock

	if not isUnlock then
		self.TxtBallName.text = string.format(_("PageRoleCard_UnLockText"), _("ecNum_" .. unlockLevel))
	else
		self.TxtBallName.text = Lang(self.info.data.Name)
	end

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgBallIcon, TenaryOp(isUnlock, 0, 1)))
	DealWithListRef(self, UIUtil.SetImageGray(self.ImgS, TenaryOp(isUnlock, 0, 1)))
	self.GoLockBall:SetActive(not isUnlock)
end

function CellCardSkill:UpdateSkillUnlock()
	if not self.info then
		return
	end

	local isUnLock = self.infoRoleCard:TalentIsUnLock(self.info.id) or self.onlyShow

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgSkillIcon, TenaryOp(isUnLock, 0, 1)))
	self.GoLock:SetActive(not isUnLock)
end

function CellCardSkill:UpdateSkillLevel()
	if not self.info then
		return
	end

	local isUnLock, unlockStar = self.infoRoleCard:TalentIsUnLock(self.info.id)

	isUnLock = isUnLock or self.onlyShow

	if self.onlyShow then
		self.level = Tenary(self.info.data.HighestLevel, 1)
	else
		self.level = self.infoRoleCard:GetTalentLevel(self.info.id)
		self.level = TenaryOp(self.level == 0, 1, self.level)
	end

	local battleType = self.info.data.BattleSkillType

	if isUnLock then
		if battleType ~= eBattleTalentType.Center then
			self.TxtSkillLevel.text = Lang(12004) .. tostring(self.level)
		else
			self.TxtSkillLevel.text = Lang(self.info.data.Name)
		end

		self.GoLvMax:SetActive(battleType ~= eBattleTalentType.Center and self.level == self.info.data.HighestLevel)
	else
		self.TxtSkillLevel.text = string.format(Lang(12067), _("ecNum_" .. unlockStar))

		if battleType == eBattleTalentType.Center then
			GOUtil.SetTransformAnchoredPosition(self.GoLock, 0, 0)
		end

		self.GoLvMax:SetActive(false)
	end
end
