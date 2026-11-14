-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUICardCutIn.lua

DlgUICardCutIn = class("DlgUICardCutIn", UIPanel_sync)

local BattleSkillData = require("info.InfoBattleSkillData")

local function getEff(cardid)
	if cardid == 1 then
		return "Fx/Skill/Prefabs/Eff_UI_Card_10001"
	elseif cardid == 2 then
		return "Fx/Skill/Prefabs/Eff_UI_Card_10002"
	elseif cardid == 3 then
		return "Fx/Skill/Prefabs/Eff_UI_Card_10003"
	elseif cardid == 4 then
		return "Fx/Skill/Prefabs/Eff_UI_Card_10004"
	elseif cardid == 5 then
		return "Fx/Skill/Prefabs/Eff_UI_Card_10005"
	end
end

function DlgUICardCutIn:ctor()
	DlgUICardCutIn.base.ctor(self, "UI/PageFight/Dlg/DlgUICardCutIn")

	self.item_card = CellCardIcon(false)

	self:AddChildPanel(self.item_card)
end

function DlgUICardCutIn:Cache()
	DlgUICardCutIn.base.Cache(self)
end

function DlgUICardCutIn:Purge()
	self.OnComplete = nil

	if self.timer ~= nil then
		TimerMgr.RemoveTimer(self.timer)
	end

	DlgUICardCutIn.base.Purge(self)
	UIMgr:RemoveSafeArea(self)
end

function DlgUICardCutIn:Close()
	if self.timer ~= nil then
		TimerMgr.RemoveTimer(self.timer)
	end

	DlgUICardCutIn.base.Close(self)
end

function DlgUICardCutIn:OnEnter()
	UIMgr:SetSafeArea(self, self.UIRootObject)
	self:Hide()

	self.roleCardRoot = self:GetChildGameObject("RoleCardRoot")
	self.txt_name = self:GetChildComponent("obj_Desc/item/Image/txt_name", "Text")
	self.txt_desc = self:GetChildComponent("obj_Desc/item/Show/txt_desc", "Text")
	self.trans_effRoot = self:GetChildGameObject("root/effRoot").transform
	self.root_cards = {}
	self.root_cards[1] = self:GetChildGameObject("root/UIRoot1")
	self.root_cards[2] = self:GetChildGameObject("root/UIRoot2")
	self.root_cards[3] = self:GetChildGameObject("root/UIRoot3")
	self.obj_spineRoot = self:GetChildGameObject("Role/Root")
	self.effId = nil
	self.RootAnimator = GOUtil.GetComponent(self.UIRootObject, "Animator")
	self.SkillEffIndex = 1
	self.obj_BoardSkillEffs = {}

	local contents = self:GetChildGameObject("obj_Board").transform

	for i = 1, contents.childCount do
		local obj = contents:GetChild(i - 1).gameObject

		table.insert(self.obj_BoardSkillEffs, obj)
	end
end

function DlgUICardCutIn:Hide()
	self.UIRootObject:SetActive(false)
	Event.Instance:Fire("HideAllSpines")

	if self.effId then
		EffectMgr:Free(self.effId)

		self.effId = nil
	end
end

function DlgUICardCutIn:Refresh(ownSkill, onComplete)
	local unit = UnitOwnSkill.Get(ownSkill.Id).Owner

	Event.Instance:Fire("UnitVocalEvent", UnitVocal.enType.Atk, unit)
	BattleConfig.Delay(0.3, function()
		Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator", false)
		Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", false)
	end)

	self.OnComplete = onComplete

	self.UIRootObject:SetActive(true)

	index = 1

	self.item_card:SetParent(self.root_cards[index].gameObject)
	self.RootAnimator:Play("DlgBattleCardCutIn_Ain0" .. index)
	self.item_card:RefreshById(ownSkill.Id)
	ownSkill:SetName(self.txt_name)
	ownSkill:SetDesc(self.txt_desc)

	for _, obj in ipairs(self.obj_BoardSkillEffs) do
		GOUtil.SetActive(obj, false)
	end

	local effIndex = BattleSkillData:GetData(ownSkill.Id).SkillShowOff

	if self.obj_BoardSkillEffs[effIndex] then
		GOUtil.SetActive(self.obj_BoardSkillEffs[effIndex], true)
	else
		print("<color=red>BattleSkillData配置表SkillShowOff字段不对 skillId = " .. ownSkill.Id .. " </color>")
	end

	TimerMgr.AddTimer(eTimerType.ScaleTime, 1, function()
		local uniqueId = UnitOwnSkill.Get(ownSkill.Id).Owner.UniqueId

		Event.Instance:Fire("PlaySpine", uniqueId, self.obj_spineRoot)
	end, nil)

	if self.timer ~= nil then
		TimerMgr.RemoveTimer(self.timer)
	end
end

function DlgUICardCutIn:OnRegisterEvent()
	EventListenerMgr.AddAnimListener(self.UIRootObject, self.OnAnimBack, self, eAnimEventType.OnAnimationEnd)
end

function DlgUICardCutIn:OnUnRegisterEvent()
	EventListenerMgr.RemoveAnimListener(self.UIRootObject, self.OnAnimBack, self, eAnimEventType.OnAnimationEnd)
end

function DlgUICardCutIn:OnAnimBack()
	if self.OnComplete then
		self.OnComplete()

		self.OnComplete = nil
	end

	self:Hide()
end
