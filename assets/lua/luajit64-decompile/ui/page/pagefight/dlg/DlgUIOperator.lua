-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUIOperator.lua

require("UI/Dlg/Common/SkillTip")
require("UI/Page/PageFight/Cells/CellRoleIcon")
require("UI/Page/PageFight/Cells/CellCardIcon")
require("UI/Page/PageFight/Cells/CellSlotIcon")

local _operatorData = class("operatorData")

function _operatorData:ctor()
	self.list = {}

	local _item = DefineClass({
		index = 0
	})

	for i = 1, 4 do
		local item = New(_item)

		table.insert(self.list, item)
	end
end

function _operatorData:Push(uniqueId, index)
	for i, item in ipairs(self.list) do
		if item.uniqueId == nil then
			item.uniqueId = uniqueId
			item.index = index

			break
		end
	end
end

function _operatorData:Remove(uniqueId)
	for i, item in ipairs(self.list) do
		if item.uniqueId == uniqueId then
			item.uniqueId = nil
			item.index = 0
		end
	end
end

function _operatorData:SelectCount()
	local count = 0

	for i, item in ipairs(self.list) do
		if item.uniqueId then
			count = count + 1
		end
	end

	return count
end

function _operatorData:Clear()
	for i, item in ipairs(self.list) do
		item.uniqueId = nil
		item.index = 0
	end
end

function _operatorData:GetData()
	local out = {}

	for i, item in ipairs(self.list) do
		table.insert(out, item.index)
	end

	return out
end

local _cardUtility = class("_cardUtility")

function _cardUtility:ctor(operator)
	self:Reset()

	self.operator = operator

	for i = 1, 3 do
		local item = CellCardIcon(true)
		local vParam = {}

		vParam.index = i

		self.operator:AddChildPanel(item, vParam)
		table.insert(self.cardIconCells, item)
	end
end

function _cardUtility:Reset()
	self.cardIconCells = {}
	self.operator = nil
end

function _cardUtility:Purge()
	for i, item in ipairs(self.cardIconCells) do
		item:Close()
	end

	EffectMgr:UnLoadEffect("Fx/UI/Eff_Ui_Battle_Action/Eff_Ui_Battle_Action")
	self:Reset()
end

function _cardUtility:OnRegisterEvent()
	Event.Instance:Add("RefreshRoundCard", self.OnRefreshRoundCard, self)
	Event.Instance:Add("DoCard", self.OnDoCard, self)
	Event.Instance:Add("ClearCard", self.OnClearCard, self)
	EventListenerMgr.AddAnimListenerEventID(self.operator.cardOpenRootsAnim.gameObject, self.OnCardBack, self, "OnCardBack")
end

function _cardUtility:OnUnRegisterEvent()
	Event.Instance:Remove("RefreshRoundCard", self.OnRefreshRoundCard, self)
	Event.Instance:Remove("DoCard", self.OnDoCard, self)
	Event.Instance:Remove("ClearCard", self.OnClearCard, self)
	EventListenerMgr.RemoveAnimListenerEventID(self.operator.cardOpenRootsAnim.gameObject, self.OnCardBack, self, "OnCardBack")
	self:Purge()
end

function _cardUtility:CreateCellCard()
	for i, item in ipairs(self.cardIconCells) do
		local cellRoot = self.operator:GetChildGameObject("cardMode/cardIconsRoot/root" .. i)

		item:SetParent(cellRoot)
	end
end

function _cardUtility:SetCardOpenParents()
	local roots = self.operator.cardOpenRoots

	for i, item in ipairs(self.cardIconCells) do
		local cellRoot = roots[i]

		if cellRoot then
			item:SetParent(cellRoot)

			item.txt_mp.name = "txt_sp" .. i
		end
	end
end

function _cardUtility:OnRefreshRoundCard(msg)
	if UnitActor.FindUnitById(msg.uniqueId).Camp == EnumFight.Camp.ENEMY then
		return
	end

	for i, item in ipairs(self.cardIconCells) do
		if item.bCast == true then
			item:RefreshByMsg(msg)

			break
		end
	end
end

function _cardUtility:OnCardBack()
	for i, item in ipairs(self.cardIconCells) do
		item:SetCardBack(false)
	end
end

function _cardUtility:OnClearCard(msg)
	if UnitActor.FindUnitById(msg.uniqueId).Camp == EnumFight.Camp.ENEMY then
		return
	end

	for i, item in ipairs(self.cardIconCells) do
		if item.cardId == msg.skillId then
			item:Hide()
		end
	end
end

function _cardUtility:OnDoCard(msg)
	if UnitActor.FindUnitById(msg.uniqueId).Camp == EnumFight.Camp.ENEMY then
		return
	end

	for i, item in ipairs(self.cardIconCells) do
		if item.cardId == msg.skillId then
			self.operator.castCardItem = item

			item:Hide()
		end
	end

	if not self.operator.castCardItem then
		return
	end

	GOUtil.SetActive(self.operator.cardIconsAnimRoot, false)
	GOUtil.SetActive(self.operator.cardIconsAnimRoot, true)
	self.operator.cardCastRootsAnim:Play("Start")

	local offset = -1

	for i, item in ipairs(self.cardIconCells) do
		if item.bCast == true then
			offset = offset + 1
		end

		if i > self.operator.castCardItem.index and item.bCast == false then
			item:SetParent(self.operator.cardCastRoots[i - offset])
		end
	end

	self.operator.castCardItem = nil
end

DlgUIOperator = class("DlgUIOperator", UIPanel_sync)

function DlgUIOperator:ctor()
	self.operatorSession = _operatorData()
	self.maxSession_const = BattleConfig.MaxSelectSessionCount
	self.maxCard_const = BattleConfig.RoundCardCount

	DlgUIOperator.base.ctor(self, "UI/PageFight/Dlg/DlgUIOperator")

	self.cardUtil = _cardUtility(self)
	self.slotIconCells = {}

	for i = 1, self.maxSession_const do
		local item = CellSlotIcon()
		local vParam = {}

		vParam.index = i

		self:AddChildPanel(item, vParam)
		table.insert(self.slotIconCells, item)
	end

	self.roleIconCells = {}

	for i = 1, #GP.PlayerUnitIds do
		local item = CellRoleIcon()
		local vParam = {}

		vParam.index = i
		vParam.unitId = GP.PlayerUnitIds[i]
		vParam.cRole = RoleMgr:GetRole(GP.PlayerUnitIds[3])

		self:AddChildPanel(item, vParam)
		table.insert(self.roleIconCells, item)
	end
end

function DlgUIOperator:Cache()
	DlgUIOperator.base.Cache(self)
	ResourceMgr.SubmitCache("UI/PageFight/Cells/CellRoleIcon", self, "PrefabCellRoleIcon")
	ResourceMgr.SubmitCache("UI/PageFight/Cells/CellCardIcon", self, "PrefabCellCardIcon")
	EffectMgr:Cache("Fx/UI/Eff_Ui_Battle_Action/Eff_Ui_Battle_Action", 1)
end

function DlgUIOperator:Close()
	DlgUIOperator.base.Close(self)
end

function DlgUIOperator:Purge()
	self:Clear()
	DlgUIOperator.base.Purge(self)

	self.operatorMode = "NONE"
	self.roleIconCells = {}
	self.slotIconCells = {}
	self.cardMode = nil
	self.obj_action = nil
	self.btn_action = nil
	self.obj_autoSelect = nil
	self.obj_mask = nil

	UIMgr:RemoveSafeArea(self)
end

function DlgUIOperator:Clear()
	for i, item in ipairs(self.roleIconCells) do
		item:Close()
	end

	for i, item in ipairs(self.slotIconCells) do
		item:Close()
	end

	self.roleIconCells = {}
	self.slotIconCells = {}
	self.castCardItem = nil
end

function DlgUIOperator:OnEnter(vParam)
	UIMgr:SetSafeArea(self, self.UIRootObject)

	self.operatorList = {
		0,
		0,
		0,
		0
	}
	self.castCardItem = nil
	self.operatorMode = "NONE"
	self.lastOperatorMode = ""
	self.cardMode = self:GetChildGameObject("cardMode")
	self.obj_action = self:GetChildGameObject("btn_action")
	self.obj_autoSelect = self:GetChildGameObject("autoSelect")
	self.img_autoSelect = self:GetChildComponent("autoSelect", "Image")

	local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.AutoSelectBtn)
	local gray = TenaryOp(isOpen, 0, 1)

	UIUtil.SetImageGray(self.img_autoSelect, gray)

	self.obj_wheel = self:GetChildGameObject("obj_wheel")
	self.obj_role = self:GetChildGameObject("roleIconsRoot")
	self.obj_dyRole = self:GetChildGameObject("dyRoleIconsRoot")
	self.btn_action = self:GetChildComponent("btn_action", "Button")
	self.obj_mpRoot = self:GetChildGameObject("obj_mpRoot")

	SceneMgr.GetCurrentScene().PageFight.DlgUIBattleInfo.mpbar_player:SetBarParent(self.obj_mpRoot)

	self.obj_mask = self:GetChildGameObject("obj_mask")
	self.obj_reset = self:GetChildGameObject("obj_wheel/btn_reset")
	self.obj_actionEnabled = self:GetChildGameObject("btn_action/Eff_Ui_Action_show")
	self.obj_sessionTip = self:GetChildGameObject("btn_action/obj_sessionTip")
	self.obj_cardTip = self:GetChildGameObject("btn_action/obj_cardTip")
	self.obj_cardIconsAnimRoot_Open = self:GetChildGameObject("cardMode/cardIconsAnimRoot_Open")
	self.cardOpenRootsAnim = self:GetChildComponent("cardMode/cardIconsAnimRoot_Open/op", "Animator")
	self.cardOpenRoots = {}

	for i = 1, self.obj_cardIconsAnimRoot_Open.transform:GetChild(0).childCount do
		table.insert(self.cardOpenRoots, self.obj_cardIconsAnimRoot_Open.transform:GetChild(0):GetChild(i - 1).gameObject)
	end

	self.cardIconsAnimRoot = self:GetChildGameObject("cardMode/cardIconsAnimRoot")
	self.cardCastRootsAnim = self:GetChildComponent("cardMode/cardIconsAnimRoot", "Animator")
	self.cardCastRoots = {}

	for i = 1, self.cardIconsAnimRoot.transform.childCount do
		table.insert(self.cardCastRoots, self.cardIconsAnimRoot.transform:GetChild(i - 1).gameObject)
	end

	self.cardSkillTip = self:GetChildGameObject("cardMode/cardSkillTip")
	self.img_icon = self:GetChildComponent("cardMode/cardSkillTip/bg_skill/img_icon", "Image")
	self.txt_name = self:GetChildComponent("cardMode/cardSkillTip/txt_name", "Text")
	self.txt_level = self:GetChildComponent("cardMode/cardSkillTip/txt_level", "Text")
	self.txt_desc = self:GetChildComponent("cardMode/cardSkillTip/txt_desc", "Text")

	self:CreateCellRole()
	self:CreateCellCard()
	self:CreateCellSlot()
	self:Show(false)

	self.animator = GOUtil.GetComponent(self.UIRootObject, "Animator")
end

function DlgUIOperator:CreateCellRole()
	for i, item in ipairs(self.roleIconCells) do
		item:SetParent(self.obj_dyRole, self.obj_role)

		item.UIRootObject.name = i

		item:SetClickEffect(self:GetChildGameObject("Splines/HermiteSpline" .. i))
	end

	local effectCellRoot = self:GetChildGameObject("roleIconsRoot2").transform

	for i = #self.roleIconCells + 1, effectCellRoot.childCount do
		GOUtil.SetActive(effectCellRoot:GetChild(i - 1).gameObject, false)
	end
end

function DlgUIOperator:CreateCellCard()
	self.cardUtil:CreateCellCard()
end

function DlgUIOperator:CreateCellSlot()
	for i, item in ipairs(self.slotIconCells) do
		local cellRoot = self:GetChildGameObject("obj_wheel/img_slot" .. i)

		item:SetParent(cellRoot)
	end
end

function DlgUIOperator:OnRegisterEvent()
	self:AddClick(self.obj_action, self.OnBtnActionClick)
	self:AddClick(self.obj_reset, self.OnBtnResetClick)
	self:AddClick(self.obj_autoSelect, self.OnBtnAutoSelectClick)
	self.cardUtil:OnRegisterEvent()
	Event.Instance:Add("ResetSessionSlot", self.ResetSessionSlot, self)
	Event.Instance:Add("RefreshSessionMode", self.RefreshSessionMode, self)
	Event.Instance:Add("RefreshCardMode", self.RefreshCardMode, self)
	Event.Instance:Add("GameChageStage", self.GameChageStage, self)
	Event.Instance:Add("WheelCardMoveAnim", self.CardMoveAnim, self)
	Event.Instance:Add("ShowCardSkill", self.ShowCardSkill, self)
	Event.Instance:Add("SuggestSession", self.SuggestSession, self)
	EventListenerMgr.AddAnimListener(self.cardOpenRootsAnim.gameObject, self.OnCardMoveBack, self, eAnimEventType.OnAnimationEnd)
	EventListenerMgr.AddAnimListener(self.cardCastRootsAnim.gameObject, self.OnCardMoveBack, self, eAnimEventType.OnAnimationEnd)
end

function DlgUIOperator:OnUnRegisterEvent()
	self:RemoveClick(self.obj_action, self.OnBtnActionClick)
	self:RemoveClick(self.obj_reset, self.OnBtnResetClick)
	self:RemoveClick(self.obj_autoSelect, self.OnBtnAutoSelectClick)
	self.cardUtil:OnUnRegisterEvent()
	Event.Instance:Remove("ResetSessionSlot", self.ResetSessionSlot, self)
	Event.Instance:Remove("RefreshSessionMode", self.RefreshSessionMode, self)
	Event.Instance:Remove("RefreshCardMode", self.RefreshCardMode, self)
	Event.Instance:Remove("GameChageStage", self.GameChageStage, self)
	Event.Instance:Remove("WheelCardMoveAnim", self.CardMoveAnim, self)
	Event.Instance:Remove("ShowCardSkill", self.ShowCardSkill, self)
	Event.Instance:Remove("SuggestSession", self.SuggestSession, self)
	EventListenerMgr.RemoveAnimListener(self.cardOpenRootsAnim.gameObject, self.OnCardMoveBack, self, eAnimEventType.OnAnimationEnd)
	EventListenerMgr.RemoveAnimListener(self.cardCastRootsAnim.gameObject, self.OnCardMoveBack, self, eAnimEventType.OnAnimationEnd)
end

function DlgUIOperator:Open()
	self:Show(true)
	InstructionMgr:TriggerWait("BattleShowUIOperator")
	self.animator:SetBool("isOpen", true)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIAuto")
end

function DlgUIOperator:Hide()
	self.animator:SetBool("isOpen", false)
end

function DlgUIOperator:RefreshRound()
	self:Show(true)
	self.operatorSession:Clear()

	self.operatorMode = "NONE"

	self:RefreshMode()
	GOUtil.SetActive(self.obj_cardIconsAnimRoot_Open, false)
	GOUtil.SetActive(self.obj_cardIconsAnimRoot_Open, true)
	self.cardUtil:SetCardOpenParents()
	self.cardOpenRootsAnim:Play("Open")

	for i, item in ipairs(self.cardUtil.cardIconCells) do
		item:StopNewPowerAnim()
	end

	for i, item in ipairs(self.cardUtil.cardIconCells) do
		item:SetSelected(false)
		item:IdleAnim()
	end
end

function DlgUIOperator:GameChageStage(stage)
	if stage == -1 then
		return
	end

	if stage == EnumFight.GameState.OPERATOR_WAIT then
		self:AllowUIOperator(true)
		BattleConfig.Delay(0.5, function()
			GP:KeepAutoMode()
		end)
	elseif stage == EnumFight.GameState.PLAYER_CARD then
		GOUtil.SetActive(self.obj_mask, true)

		if not GP.SelectUnits then
			return
		end

		for i, unit in ipairs(GP.SelectUnits) do
			if unit.HeadTipUI then
				unit.HeadTipUI:ShowTargetEffect(false)
			end
		end
	else
		self:AllowUIOperator(false)
	end
end

function DlgUIOperator:AllowUIOperator(val)
	GOUtil.SetActive(self.obj_mask, not val)

	if val == false then
		self.operatorMode = "DISABLED_MODE"

		self:RefreshMode()
	end

	if not GP.SelectUnits then
		return
	end

	for i, unit in ipairs(GP.SelectUnits) do
		if unit.HeadTipUI then
			unit.HeadTipUI:ShowTargetEffect(val)
		end
	end
end

function DlgUIOperator:RefreshMode()
	if self.lastOperatorMode == self.operatorMode then
		-- block empty
	else
		self.lastOperatorMode = self.operatorMode
	end

	local showSlot, showCard, showRole, showAction, showAutoSelect = false, true, true, true, true
	local interactable = false

	if self.operatorMode == "NONE" then
		-- block empty
	elseif self.operatorMode == "DISABLED_MODE" then
		showSlot = false
		showCard = false
		showRole = true
		showAction = false
		showAutoSelect = false

		for i = 1, #self.roleIconCells do
			self.roleIconCells[i]:DisableState()
		end
	elseif self.operatorMode == "SECCION_MODE" then
		showSlot = true
		showCard = false
		self.castCardItem = nil
	elseif self.operatorMode == "ENEMYACTION_MODE" then
		showSlot = false
		showCard = false
		showRole = true
		showAction = false
	elseif self.operatorMode == "CARD_MODE" then
		showSlot = false
		showCard = true
	end

	GOUtil.SetActive(self.obj_wheel, showSlot)
	GOUtil.SetActive(self.cardMode, showCard)
	GOUtil.SetActive(self.obj_mpRoot, showCard)
	GOUtil.SetActive(self.obj_role, showRole)
	GOUtil.SetActive(self.obj_dyRole, showRole)
	GOUtil.SetActive(self.obj_autoSelect, showAutoSelect)
	GOUtil.SetActive(self.obj_action, showAction)

	if self.operatorMode == "NONE" then
		self.castCardItem = nil

		for i, item in ipairs(self.cardUtil.cardIconCells) do
			item:SetSelected(false)
			item:IdleAnim()
		end

		for index, item in ipairs(self.slotIconCells) do
			item:Reset()
		end
	elseif self.operatorMode == "DISABLED_MODE" or self.operatorMode == "ENEMYACTION_MODE" then
		self.btn_action.interactable = false

		GOUtil.SetActive(self.obj_cardTip, false)
		GOUtil.SetActive(self.obj_sessionTip, false)

		return
	end

	if self.castCardItem then
		Event.Instance:Fire("ReqTargetsPreview", self.castCardItem.uniqueId, self.castCardItem.cardId)
	else
		Event.Instance:Fire("ReqTargetsPreview", nil, nil)
	end

	local selectedCount = self.operatorSession:SelectCount()

	if selectedCount > 0 then
		interactable = true
	elseif self.castCardItem then
		interactable = true
	end

	self.btn_action.interactable = interactable

	GOUtil.SetActive(self.obj_sessionTip, selectedCount > 0)
	GOUtil.SetActive(self.obj_cardTip, self.castCardItem ~= nil)
	GOUtil.SetActive(self.obj_actionEnabled, selectedCount > 0 or self.castCardItem ~= nil)

	if self.operatorMode == "NONE" then
		self.cardOpenRootsAnim:Play("Open", 0, 1)
		self.cardUtil:OnCardBack()

		for i, item in ipairs(self.cardUtil.cardIconCells) do
			item:StopNewPowerAnim()
		end
	end
end

function DlgUIOperator:OnBtnActionClick()
	if self.operatorMode == "SECCION_MODE" then
		local _data = self.operatorSession:GetData()

		Event.Instance:Fire("PlayerOperator", _data)
	elseif self.operatorMode == "CARD_MODE" then
		local _data = {}

		_data.uniqueId = self.castCardItem.uniqueId
		_data.skillId = self.castCardItem.cardId

		Event.Instance:Fire("PlayerCard", _data)
		EffectMgr:Alloc("Fx/UI/Eff_Ui_Battle_Action/Eff_Ui_Battle_Action", self.obj_action.transform, true, 1)

		self.operatorMode = "NONE"

		self:RefreshMode()
	else
		print("self.operatorMode = " .. self.operatorMode)

		return
	end
end

function DlgUIOperator:OnBtnAutoSelectClick()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.AutoSelectBtn) then
		return
	end

	Event.Instance:Fire("ReqSuggestSession")
end

function DlgUIOperator:OnBtnResetClick()
	self.operatorSession:Clear()

	self.operatorMode = "NONE"

	self:RefreshMode()

	for _, roleIcon in ipairs(self.roleIconCells) do
		roleIcon:SetVaild(true)
	end
end

function DlgUIOperator:OnCardMoveBack()
	for i, item in ipairs(self.cardUtil.cardIconCells) do
		item:PlayNewPowerAnim()
	end
end

function DlgUIOperator:CardMoveAnim()
	return
end

function DlgUIOperator:RefreshCardMode(clickitem)
	if self.castCardItem and self.castCardItem.cardId == clickitem.cardId then
		self.operatorMode = "NONE"

		self.castCardItem:SetSelected(false)
		self.castCardItem:PlayIdleAnim()

		self.castCardItem = nil

		self:RefreshMode()

		return
	end

	self.operatorMode = "CARD_MODE"

	for i, item in ipairs(self.cardUtil.cardIconCells) do
		if item.cardId == clickitem.cardId then
			item:PlayClickAnim()
			item:SetSelected(true)

			self.castCardItem = clickitem
		else
			item:SetSelected(false)
			item:PlayIdleAnim()
		end
	end

	self:RefreshMode()
end

function DlgUIOperator:ResetSessionSlot(unitId)
	for i, roleIcon in ipairs(self.roleIconCells) do
		if roleIcon.unitId == unitId then
			roleIcon:OnCellClick()

			break
		end
	end
end

function DlgUIOperator:RefreshSessionMode(clickitem)
	self.operatorMode = "SECCION_MODE"

	local val = not clickitem.seccionVaild

	if val == true then
		self.operatorSession:Remove(clickitem.uniqueId)

		for i, slot in ipairs(self.slotIconCells) do
			if slot.unitId == clickitem.unitId then
				BattleConfig.PostSoundEvent(PATH_BATTLE_UI_UNSELECT_BALL, self.UIRootObject)
				slot:Reset()

				break
			end
		end
	else
		local selectedCount = self.operatorSession:SelectCount()

		if selectedCount >= self.maxSession_const then
			return
		end

		self.operatorSession:Push(clickitem.uniqueId, clickitem.index)

		for i, slot in ipairs(self.slotIconCells) do
			if slot.unitId == nil then
				slot:Refresh(clickitem.unitId, clickitem.seccionType)
				BattleConfig.PostSoundEvent(PATH_BATTLE_UI_SELECT_BALL, self.UIRootObject)

				break
			end
		end
	end

	clickitem:SetVaild(val)

	local selectedCount = self.operatorSession:SelectCount()

	if selectedCount == 0 then
		self.operatorMode = "NONE"
	end

	self:RefreshSlotEffect()
	self:RefreshMode()
end

function DlgUIOperator:RefreshSlotEffect()
	for i = 1, #self.slotIconCells do
		local cur = self.slotIconCells[i]

		cur:RefreshEffect(false)
	end

	for i = 1, #self.slotIconCells do
		local cur = self.slotIconCells[i]
		local next = self.slotIconCells[i + 1]

		if cur and next and cur.sessionType and next.sessionType and cur.sessionType == next.sessionType then
			cur:RefreshEffect(true)
			next:RefreshEffect(true)
		end
	end
end

function DlgUIOperator:ShowCardSkill(data)
	local flag = data.flag
	local cardId = data.cardId

	if flag then
		local ownSkill = UnitOwnSkill.Get(cardId)
		local tipData = SkillTip.GetHeroData(data.pos, ownSkill.AllSkillId, ownSkill.AllSkillLv, ownSkill.YellowBallStack)

		UIMgr.ShowSkillTip(tipData)
	else
		UIMgr.HideSkillTip()
	end
end

function DlgUIOperator:SuggestSession(msg)
	self:OnBtnResetClick()

	for i, index in ipairs(msg.data) do
		local item = self.roleIconCells[index]

		if item then
			item:OnCellClick()
		end
	end
end

function DlgUIOperator:OnBackAndroid()
	if self.obj_wheel and GOUtil.IsActiveSelf(self.obj_wheel) then
		self:OnBtnResetClick()

		return true
	end

	return false
end
