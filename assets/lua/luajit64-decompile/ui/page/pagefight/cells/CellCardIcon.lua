-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Cells/CellCardIcon.lua

require("UI/Item/UIItemBase")

local _BattleSkillData = require("Info.InfoBattleSkillData")
local MAX_STACK = 5
local ImgPath = {
	"UIDyAtlas/Skill/IC_Skill_10001",
	"UIDyAtlas/Skill/IC_Skill_10002",
	"UIDyAtlas/Skill/IC_Skill_10003",
	"UIDyAtlas/Skill/IC_Skill_10004",
	"UIDyAtlas/Skill/IC_Skill_10005"
}

CellCardIcon = class("CellCardIcon", UIPanel_sync)

function CellCardIcon:ctor(isOperatorCard)
	self.isOperatorCard = isOperatorCard

	if isOperatorCard == true then
		CellCardIcon.base.ctor(self, "UI/PageFight/Cells/CellCardIcon")
	else
		CellCardIcon.base.ctor(self, "UI/PageFight/Cells/CellCutinCardIcon")
	end

	if isOperatorCard == true then
		self.bNeedGary = true
	else
		self.bNeedGary = false
	end
end

function CellCardIcon:Cache()
	CellCardIcon.base.Cache(self)

	for i = 1, 5 do
		ResourceMgr.SubmitCache(ImgPath[i], self, "CardIconSprite" .. i, Sprite)
	end
end

function CellCardIcon:SetParent(root)
	GOUtil.AttachGameObject(self.UIRootObject, root, true)
end

function CellCardIcon:OnEnter(vParam)
	self.bCast = true
	self.itemType = "CellCardIcon"
	self.obj_panel = self:GetChildGameObject("Panel")
	self.obj_clickArea = self:GetChildGameObject("Panel/obj_clickArea")
	self.img_cardIcon = self:GetChildComponent("Panel/mask/img_cardIcon", "Image")
	self.mat_cardIcon = Material(self.img_cardIcon.material)
	self.img_cardIcon.material = self.mat_cardIcon
	self.img_skillIcon = self:GetChildComponent("Panel/bg_skillIcon/img_skillIcon", "Image")
	self.img_cardRank = self:GetChildComponent("Panel/img_cardRank", "Image")
	self.img_descIcon = self:GetChildComponent("Panel/img_descIcon", "Image")
	self.obj_back = self:GetChildGameObject("Panel/obj_back")

	if self.obj_back then
		GOUtil.SetActive(self.obj_back, false)
	end

	self.txt_cardName = self:GetChildComponent("Panel/txt_cardName", "Text")
	self.txt_mp = self:GetChildComponent("Panel/txt_sp", "Text")
	self.obj_stackPower = self:GetChildGameObject("Panel/stackPower")
	self.stackPowerImgsObj = {}

	if self.isOperatorCard == true then
		local imgs = self:GetChildGameObject("Panel/stackPower/imgs/anim")

		for i = 1, imgs.transform.childCount do
			local go = imgs.transform:GetChild(i - 1).gameObject

			table.insert(self.stackPowerImgsObj, go)
			GOUtil.SetActive(go, false)
		end
	end

	self.txt_stackPower = self:GetChildComponent("Panel/obj_stackPower/txt_stackPower", "Text")
	self.obj_stackMax = self:GetChildGameObject("Panel/obj_stackPower/img_stackMax", "Image")
	self.obj_stackEff = self:GetChildGameObject("Panel/obj_stackPower/Eff_Ui_CellCardIcon/Eff_Ui_CellCardIcon_Com")
	self.obj_stackEffMax = self:GetChildGameObject("Panel/obj_stackPower/Eff_Ui_CellCardIcon/Eff_Ui_CellCardIcon_Max")
	self.animator = GOUtil.GetComponent(self.UIRootObject, "Animator")
	self.mp = 9999
	self.bSelected = false
	self.selectedImg = self:GetChildComponent("Panel/go_selected", "Image")
	self.obj_stun = self:GetChildGameObject("Panel/obj_stun")

	if self.obj_stun then
		GOUtil.SetActive(self.obj_stun, false)
	end

	if vParam then
		self.index = vParam.index
	end

	self.IsNewPowerStack = false
	self.anim_newStackAnim = self:GetChildComponent("Panel/newStackAnim", "Animator")
end

function CellCardIcon:Close()
	for i = 1, 5 do
		self["CardIconSprite" .. i] = nil
	end

	self.obj_clickArea = nil
	self.itemType = nil
	self.img_cardIcon = nil
	self.mat_cardIcon = nil
	self.img_skillIcon = nil
	self.img_cardRank = nil
	self.isShow = false
	self.txt_cardName = nil
	self.txt_mp = nil
	self.animator = nil
	self.mp = 9999
	self.bSelected = false
	self.selectedImg = nil
	self.showTip = nil
	self.bCast = true
	self.obj_stun = nil
	self.obj_back = nil
	self.obj_stackEff = nil
	self.obj_stackEffMax = nil
	self.obj_stackMax = nil
end

function CellCardIcon:OnRegisterEvent()
	self:AddClick(self.obj_clickArea, self.OnCardClick, "mute")
	Event.Instance:Add("VAL_POINT", self.ActionChangeValueMp, self)
	self:AddListener(self.obj_clickArea, self.OnPointerDown, EventTriggerType.PointerLongPress)
	Event.Instance:Add("UnitNotAction", self.OnUnitNotAction, self)
	Event.Instance:Add("UnitDisableCardSkill", self.OnUnitDisableCardSkill, self)
	Event.Instance:Add("SkillUpdateStackPower", self.OnSkillUpdateStackPower, self)
	Event.Instance:Add("TeamUpdateAttri", self.OnTeamUpdateAttri, self)
end

function CellCardIcon:OnUnRegisterEvent()
	self:RemoveClick(self.obj_clickArea, self.OnCardClick)
	Event.Instance:Remove("VAL_POINT", self.ActionChangeValueMp, self)
	self:RemoveListener(self.obj_clickArea, self.OnPointerDown, EventTriggerType.PointerLongPress)
	Event.Instance:Remove("UnitNotAction", self.OnUnitNotAction, self)
	Event.Instance:Remove("UnitDisableCardSkill", self.OnUnitDisableCardSkill, self)
	Event.Instance:Remove("SkillUpdateStackPower", self.OnSkillUpdateStackPower, self)
	Event.Instance:Remove("TeamUpdateAttri", self.OnTeamUpdateAttri, self)
end

function CellCardIcon:OnPointerDown(data)
	if data.clickCount == 1 then
		Event.Instance:Fire("ShowCardSkill", {
			flag = true,
			pos = data.position,
			cardId = self.cardId
		})
	else
		Event.Instance:Fire("ShowCardSkill", {
			flag = false,
			pos = data.position,
			cardId = self.cardId
		})
	end
end

function CellCardIcon:ActionChangeValueMp(type)
	if type ~= "FORCE" then
		return
	end

	if self.bNeedGary == false then
		return
	end

	if not self.UIRootObject or GOUtil.IsActiveSelf(self.UIRootObject) == false then
		return
	end

	local _color

	if SceneMgr.GetCurrentScene().GP.Team.PlayerMp < self.mp then
		_color = BattleConfig.ColorGary
	else
		_color = BattleConfig.ColorWhite
	end

	self.img_cardIcon.material.color = _color
	self.img_cardRank.color = _color
	self.img_skillIcon.color = _color
	self.img_descIcon.color = _color
end

function CellCardIcon:RefreshById(cardId)
	local config = _BattleSkillData:GetData(cardId)

	self.txt_cardName.text = UnitOwnSkill.GetName(cardId)
	self.txt_mp.text = tostring(config.Cost)
	self.mp = config.Cost

	self:Show(true)

	self.selectedImg.enabled = false

	if self.isOperatorCard == true then
		for i, obj in ipairs(self.stackPowerImgsObj) do
			GOUtil.SetActive(obj, false)
		end

		GOUtil.SetActive(self.stackPowerImgsObj[1], config.IsStackPower == 1)
	end

	self.txt_stackPower.text = ""

	GOUtil.SetActive(self.obj_stackMax, false)

	local ownSKill = UnitOwnSkill.Get(cardId)

	ownSKill:SetIcon(self.img_skillIcon)
	ownSKill:SetDescIcon(self.img_descIcon)

	local unitBase = UnitOwnSkill.Get(cardId).Owner
	local smallIcon = unitBase.InfoRoleCard.data.SmallIcon

	GP.SpriteUtil:SetSprite(self.img_cardIcon, smallIcon)

	if self.bNeedGary == false then
		return
	end

	local _color = BattleConfig.ColorWhite

	if SceneMgr.GetCurrentScene().GP.Team.PlayerMp < self.mp then
		_color = BattleConfig.ColorGary
	else
		_color = BattleConfig.ColorWhite
	end

	self.img_cardIcon.material.color = _color
	self.img_cardRank.color = _color
	self.img_skillIcon.color = _color
	self.img_descIcon.color = _color
end

function CellCardIcon:RefreshByMsg(msg)
	self.bCast = false
	self.cardId = msg.skillId

	local isNew = true

	self:SetCardBack(isNew)

	local config = _BattleSkillData:GetData(self.cardId)

	self.txt_cardName.text = UnitOwnSkill.GetName(self.cardId)
	self.txt_mp.text = tostring(config.Cost)
	self.mp = config.Cost

	self:Show(true)
	self.animator:Play("idle")

	self.selectedImg.enabled = false

	local ownSKill = UnitOwnSkill.Get(self.cardId)

	ownSKill:SetIcon(self.img_skillIcon)
	ownSKill:SetDescIcon(self.img_descIcon)

	self.uniqueId = msg.uniqueId

	local unitBase = UnitActor.FindUnitById(msg.uniqueId)
	local smallIcon = unitBase.InfoRoleCard.data.SmallIcon

	GP.SpriteUtil:SetSprite(self.img_cardIcon, smallIcon)
	self:PowerStackShow(msg.uniqueId)
	self:OnUnitNotAction(self.uniqueId, unitBase.NotAction)
	self:OnUnitDisableCardSkill(self.uniqueId, unitBase.DisableCardSkill)

	if self.bNeedGary == false then
		return
	end

	local _color

	if SceneMgr.GetCurrentScene().GP.Team.PlayerMp < self.mp then
		_color = BattleConfig.ColorGary
	else
		_color = BattleConfig.ColorWhite
	end

	self.img_cardIcon.material.color = _color
	self.img_cardRank.color = _color
	self.img_skillIcon.color = _color
	self.img_descIcon.color = _color
end

function CellCardIcon:OnCardClick()
	if SceneMgr.GetCurrentScene().GP.Team.PlayerMp < self.mp then
		return
	end

	Event.Instance:Fire("RefreshCardMode", self)
end

function CellCardIcon:SetSelected(val)
	self.bSelected = val
end

function CellCardIcon:PlayClickAnim()
	self.animator:CrossFade("Eff_Ui_Battle_Card_dx", 0.1)

	self.selectedImg.enabled = true
end

function CellCardIcon:PlayIdleAnim()
	local handle = TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
		self.animator:Play("idle")
	end, nil)

	self.selectedImg.enabled = false
end

function CellCardIcon:IdleAnim()
	self.animator:Play("idle")

	self.selectedImg.enabled = false
end

function CellCardIcon:Hide()
	self.bCast = true
	self.IsNewPowerStack = false

	self:Show(false)
end

function CellCardIcon:SetParent(root)
	GOUtil.AttachGameObject(self.UIRootObject, root)
end

function CellCardIcon:SetCardBack(isNew)
	if self.obj_back then
		GOUtil.SetActive(self.obj_back, isNew)
	end
end

function CellCardIcon:OnUnitNotAction(uniqueId, val)
	if uniqueId ~= self.uniqueId then
		return
	end

	if self.obj_stun then
		if val == false then
			val = UnitActor.FindUnitById(self.uniqueId).DisableCardSkill
		end

		GOUtil.SetActive(self.obj_stun, val)
	end
end

function CellCardIcon:OnUnitDisableCardSkill(uniqueId, val)
	if uniqueId ~= self.uniqueId then
		return
	end

	if self.obj_stun then
		if val == false then
			val = UnitActor.FindUnitById(self.uniqueId).NotAction
		end

		GOUtil.SetActive(self.obj_stun, val)
	end
end

function CellCardIcon:OnSkillUpdateStackPower(msg)
	if msg.uniqueId ~= self.uniqueId or self.cardId ~= msg.skillId then
		return
	end

	self:PowerStackShow(msg.uniqueId)

	self.IsNewPowerStack = true
end

function CellCardIcon:PlayNewPowerAnim()
	if self.IsNewPowerStack == false then
		return
	end

	self.IsNewPowerStack = false
	self.anim_newStackAnim.enabled = true

	self.anim_newStackAnim:Play("up")
end

function CellCardIcon:StopNewPowerAnim()
	self.anim_newStackAnim.enabled = false

	self.anim_newStackAnim.gameObject.transform:GetChild(0).gameObject:SetActive(false)
end

function CellCardIcon:PowerStackShow(uniqueId)
	local unitBase = UnitActor.FindUnitById(uniqueId)
	local stack = unitBase:GetOwnSkill(self.cardId).YellowBallStack

	GOUtil.SetActive(self.obj_stackMax, stack == MAX_STACK)
	GOUtil.SetActive(self.obj_stackEff, stack ~= MAX_STACK and stack > 0)
	GOUtil.SetActive(self.obj_stackEffMax, stack == MAX_STACK)

	if stack == 0 then
		self.txt_stackPower.text = ""

		if self.isOperatorCard == true then
			for i, obj in ipairs(self.stackPowerImgsObj) do
				GOUtil.SetActive(obj, false)
			end
		end

		local config = _BattleSkillData:GetData(self.cardId)

		GOUtil.SetActive(self.stackPowerImgsObj[1], config.IsStackPower == 1)
	elseif stack == MAX_STACK then
		for i, obj in ipairs(self.stackPowerImgsObj) do
			if i == 1 or i == #self.stackPowerImgsObj then
				GOUtil.SetActive(obj, true)
			else
				GOUtil.SetActive(obj, false)
			end
		end
	else
		for i, obj in ipairs(self.stackPowerImgsObj) do
			GOUtil.SetActive(obj, i <= stack + 1)
		end
	end
end

function CellCardIcon:OnTeamUpdateAttri(msg)
	if msg.attriName ~= "魔力" then
		return
	end

	if msg.camp ~= EnumFight.Camp.PLAYER then
		return
	end

	if self.bNeedGary == false then
		return
	end

	if not self.UIRootObject then
		return
	end

	local _color
	local sss = SceneMgr.GetCurrentScene().GP.FightMode

	if SceneMgr.GetCurrentScene().GP.Team.PlayerMp < self.mp then
		_color = BattleConfig.ColorGary
	else
		_color = BattleConfig.ColorWhite
	end

	self.img_cardIcon.material.color = _color
	self.img_cardRank.color = _color
	self.img_skillIcon.color = _color
	self.img_descIcon.color = _color
end
