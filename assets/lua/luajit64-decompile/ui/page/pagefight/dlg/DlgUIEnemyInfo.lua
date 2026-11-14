-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUIEnemyInfo.lua

require("UI/Dlg/Common/SkillTip")

DlgUIEnemyInfo = class("DlgUIEnemyInfo", UIPanel_sync)

require("UI/Page/PageFight/Cells/CellHpBar")

local _BattleSkillData = require("Info.InfoBattleSkillData")
local SHIELD_HIT_EFF_DELAY = 0.5

function DlgUIEnemyInfo:ctor()
	DlgUIEnemyInfo.base.ctor(self, "UI/PageFight/Dlg/DlgUIEnemyInfo")

	self.uniqueId = -1
	self.cellBuffIcons = CellBuffIcons()

	self:AddChildPanel(self.cellBuffIcons)

	self.cellHeadTip = CellHeadTipOnIcon()
end

function DlgUIEnemyInfo:Cache()
	DlgUIEnemyInfo.base.Cache(self)
	EffectMgr:Cache("Fx/UI/Eff_Ui_Battle_BeHitMonster_01/Eff_Ui_Battle_BeHitMonster_02", 1)
	EffectMgr:Cache("Fx/UI/eff_ui_Broken/eff_ui_Broken", 1)
	EffectMgr:Cache("Fx/UI/eff_ui_Boss_Power/eff_ui_Boss_Power", 1)
end

function DlgUIEnemyInfo:Show(isShow)
	if isShow == false then
		UIMgr.HideSkillTip()
		UIMgr.HideBuffTip()
	end

	DlgUIEnemyInfo.base.Show(self, isShow)
end

function DlgUIEnemyInfo:Close(tParam)
	DlgUIEnemyInfo.base.Close(self, tParam)
end

function DlgUIEnemyInfo:Purge()
	if self.cellHeadTip then
		self.cellHeadTip:Purge()
	end

	self.hpbar_enemy:Reset()
	self.angrybar_enemy:Reset()
	DlgUIEnemyInfo.base.Purge(self)
	EffectMgr:UnLoadEffect("Fx/UI/eff_ui_Boss_Power/eff_ui_Boss_Power")
end

function DlgUIEnemyInfo:OnRegisterEvent()
	Event.Instance:Add("OnSelectorTarget", self.SelectTarget, self)
	Event.Instance:Add("OnUnitRandomSkill", self.OnUnitRandomSkill, self)
	Event.Instance:Add("UnitCreate", self.OnUnitCreate, self)
	Event.Instance:Add("UnitUpdateAttri", self.OnUnitUpdateAttri, self)
	Event.Instance:Add("UnitDestroy", self.OnUnitDestroy, self)
	Event.Instance:Add("PlayDie", self.OnPlayDie, self)
	Event.Instance:Add("UnitNotAction", self.OnUnitNotAction, self)
	Event.Instance:Add("AddBuff", self.OnBuffChange, self)
	Event.Instance:Add("RemoveBuff", self.OnBuffChange, self)
	Event.Instance:Add("UpdateBuff", self.OnBuffChange, self)
	Event.Instance:Add("BuffStack", self.OnBuffChange, self)
	Event.Instance:Add("RefreshRoundCard", self.OnRefreshRoundCard, self)
	Event.Instance:Add("RefreshRoundSession", self.OnRefreshRoundSession, self)
	Event.Instance:Add("PvpSessionPlay", self.OnPvpSessionPlay, self)
	self:AddListener(self.area_longpresssobj, self.OnPointerDown_Skill, EventTriggerType.PointerLongPress)
	self:AddListener(self.buffTipsArea, self.OnPointerDown_Buff, EventTriggerType.PointerLongPress)
	self:AddClick(self.btn_click, self.OnBtnClick)
	self:AddListener(self.area_longpresssobj, self.OnBtnClick, EventTriggerType.PointerClick)
	self:AddListener(self.buffTipsArea, self.OnBtnClick, EventTriggerType.PointerClick)
end

function DlgUIEnemyInfo:OnUnRegisterEvent()
	Event.Instance:Remove("OnSelectorTarget", self.SelectTarget, self)
	Event.Instance:Remove("OnUnitRandomSkill", self.OnUnitRandomSkill, self)
	Event.Instance:Remove("UnitCreate", self.OnUnitCreate, self)
	Event.Instance:Remove("UnitUpdateAttri", self.OnUnitUpdateAttri, self)
	Event.Instance:Remove("UnitDestroy", self.OnUnitDestroy, self)
	Event.Instance:Remove("PlayDie", self.OnPlayDie, self)
	Event.Instance:Remove("UnitNotAction", self.OnUnitNotAction, self)
	Event.Instance:Remove("AddBuff", self.OnBuffChange, self)
	Event.Instance:Remove("RemoveBuff", self.OnBuffChange, self)
	Event.Instance:Remove("UpdateBuff", self.OnBuffChange, self)
	Event.Instance:Remove("BuffStack", self.OnBuffChange, self)
	Event.Instance:Remove("RefreshRoundCard", self.OnRefreshRoundCard, self)
	Event.Instance:Remove("RefreshRoundSession", self.OnRefreshRoundSession, self)
	Event.Instance:Remove("PvpSessionPlay", self.OnPvpSessionPlay, self)
	self:RemoveClick(self.btn_click, self.OnBtnClick, self)
	self:RemoveListener(self.area_longpresssobj, self.OnPointerDown_Skill, EventTriggerType.PointerLongPress)
	self:RemoveListener(self.buffTipsArea, self.OnPointerDown_Buff, EventTriggerType.PointerLongPress)
	self:RemoveListener(self.area_longpresssobj, self.OnBtnClick, EventTriggerType.PointerClick)
	self:RemoveListener(self.buffTipsArea, self.OnBtnClick, EventTriggerType.PointerClick)
end

local function FixScreenPos(screenClickPoint)
	local offset = UIMgr.RootCanvas.pixelRect.width * 0.2

	if screenClickPoint.x > UIMgr.RootCanvas.pixelRect.width / 2 then
		screenClickPoint.x = screenClickPoint.x - offset
	else
		screenClickPoint.x = screenClickPoint.x + offset
	end

	return Vector2.New(screenClickPoint.x, screenClickPoint.y)
end

function DlgUIEnemyInfo:OnPointerDown_Skill(data)
	if data.clickCount == 1 then
		local unit = UnitActor.FindUnitById(self.uniqueId)
		local angryState = 0

		if unit.UnitData.data.Boss == 1 then
			angryState = unit:GetAttri("怒气阶段")
		end

		local fixPos = FixScreenPos(data.position)
		local allskill = _BattleSkillData:GetAllSkillByBattleSkillId(unit.NextCastSkill)
		local tipData = SkillTip.GetMonsterData(fixPos, allskill.ID, angryState, true)

		UIMgr.ShowSkillTip(tipData)
	else
		UIMgr.HideSkillTip()
	end
end

function DlgUIEnemyInfo:OnPointerDown_Buff(data)
	if data.clickCount == 1 then
		local unit = UnitActor.FindUnitById(self.uniqueId)

		if #unit.Buffs >= 1 then
			local offset = 200 + (#unit.Buffs - 1) * 102.94 / 2

			if #unit.Buffs > 8 then
				offset = offset - 200
			elseif #unit.Buffs > 5 then
				offset = offset - 200
			end

			offset = offset * -1

			local fixPos = FixScreenPos(data.position)

			UIMgr.ShowBuffTip(unit.Buffs, fixPos, offset)
		end
	else
		UIMgr.HideBuffTip()
	end
end

function DlgUIEnemyInfo:OnUnitNotAction(uniqueId, val)
	if self.uniqueId ~= uniqueId then
		return
	end

	self.stun:SetActive(val)
end

function DlgUIEnemyInfo:OnBuffChange(uniqueId)
	if self.uniqueId ~= uniqueId then
		return
	end

	local unit = UnitActor.FindUnitById(uniqueId)

	if unit == nil then
		return
	end

	for i, img in ipairs(self.buffIcons) do
		local buff = unit.Buffs[i]
		local iconObj = self.buffObjs[i]

		if buff ~= nil then
			iconObj:SetActive(true)
			GP.SpriteUtil:SetSprite(img, buff.IconPath)

			local rounds = self.buffRounds[i]

			rounds.text = buff.Stack == 0 and "" or buff.Stack
		else
			iconObj:SetActive(false)
		end
	end
end

function DlgUIEnemyInfo:OnPointerUp()
	TimerMgr.RemoveTimer(self.Timer)
	self.panel_skill:SetActive(false)
end

function DlgUIEnemyInfo:OnEnter(vParam)
	self.index = vParam.index
	self.txt_name = self:GetChildComponent("panel/txt_name", "Text")
	self.txt_enemyAtkRound = self:GetChildComponent("panel/bg_countdown/txt_num", "Text")
	self.img_selectTarget = self:GetChildComponent("panel/bg_enemyIcon/eff_img_head", "Image")
	self.img_selectTarget.enabled = false
	self.img_enemyIcon = self:GetChildComponent("panel/bg_enemyIcon/img_headIcon", "Image")
	self.img_enemyJob = self:GetChildComponent("panel/img_enemyJob", "Image")
	self.hpbar_enemy = CellHpBar(self:GetChildGameObject("panel/hpbar_enemy"))
	self.hpFxPath = "Fx/UI/Eff_Ui_Battle_BeHitMonster_01/Eff_Ui_Battle_BeHitMonster_02"
	self.angrybar_enemy = CellHpBar(self:GetChildGameObject("panel/angryBar_enemy"))
	self.angryFxPath = ""
	self.img_enemyAngeySkillIcon = {}
	self.img_enemyAngeySkillIcon[1] = self:GetChildComponent("panel/angryBar_enemy/slider_icon1/bg_icon1/img_headIcon", "Image")
	self.img_enemyAngeySkillIcon[2] = self:GetChildComponent("panel/angryBar_enemy/slider_icon2/bg_icon2/img_headIcon", "Image")
	self.img_enemyAngeySkillIcon[3] = self:GetChildComponent("panel/angryBar_enemy/slider_icon3/bg_icon3/img_headIcon", "Image")

	for i, img in ipairs(self.img_enemyAngeySkillIcon) do
		UIUtil.SetImageGray(img, 1)
	end

	self.img_enemyAngeySkillIcon2 = {}
	self.img_enemyAngeySkillIcon2[1] = self:GetChildComponent("panel/angryBar_enemy/slider_icon1/bg_icon1/img_angryState", "Image")
	self.img_enemyAngeySkillIcon2[2] = self:GetChildComponent("panel/angryBar_enemy/slider_icon2/bg_icon2/img_angryState", "Image")
	self.img_enemyAngeySkillIcon2[3] = self:GetChildComponent("panel/angryBar_enemy/slider_icon3/bg_icon3/img_angryState", "Image")

	for i, img in ipairs(self.img_enemyAngeySkillIcon2) do
		UIUtil.SetImageGray(img, 1)
	end

	self.slider_icon1 = self:GetChildComponent("panel/angryBar_enemy/slider_icon1", "UnityEngine.UI.Slider")
	self.slider_icon2 = self:GetChildComponent("panel/angryBar_enemy/slider_icon2", "UnityEngine.UI.Slider")
	self.slider_icon3 = self:GetChildComponent("panel/angryBar_enemy/slider_icon3", "UnityEngine.UI.Slider")
	self.panel_skill = self:GetChildGameObject("panel/panel_skill")
	self.txt_skillName = self:GetChildComponent("panel/panel_skill/txt_skillName", "Text")
	self.txt_nextActionSkill = self:GetChildComponent("panel/bg_countdown/txt_prompt", "Text")
	self.txt_content = self:GetChildComponent("panel/panel_skill/txt_content", "Text")
	self.bg = self:GetChildGameObject("panel/hpbar_enemy/bg")
	self.area_longpresssobj = self:GetChildGameObject("panel/hpbar_enemy/longpress")
	self.stun = self:GetChildGameObject("panel/obj_stun")

	self.stun:SetActive(false)

	self.img_sessionIcon = self:GetChildComponent("panel/img_sessionIcon", "Image")
	self.eff_session = self:GetChildGameObject("panel/img_sessionIcon/FX_sessionIcon")
	self.obj_buffRoot = self:GetChildGameObject("panel/obj_buffRoot")
	self.buffTipsArea = self:GetChildGameObject("panel/buffTipsArea")
	self.buffRoot = self:GetChildGameObject("panel/buffIcons")
	self.buffIcons = {}
	self.buffObjs = {}
	self.buffRounds = {}
	self.buffIconIndex = 0
	self.buffIconMaxIndex = self.buffRoot.transform.childCount

	for i = 1, self.buffRoot.transform.childCount do
		local obj = self.buffRoot.transform:GetChild(i - 1).gameObject
		local img = GOUtil.GetComponent(obj, "Image")
		local roundsObj = obj.transform:Find("rounds").gameObject
		local rounds = GOUtil.GetComponent(roundsObj, "Text")

		table.insert(self.buffIcons, img)
		table.insert(self.buffObjs, obj)
		table.insert(self.buffRounds, rounds)
		obj:SetActive(false)
	end

	self.btn_click = self:GetChildGameObject("panel/obj_click")

	self:Show(false)
end

function DlgUIEnemyInfo:SetParent(root)
	self.parent = root

	GOUtil.AttachGameObject(self.UIRootObject, root)
end

function DlgUIEnemyInfo:OnUnitCreate(msg)
	if msg.camp == EnumBattle.UnitClass.PLAYER then
		return
	end

	local unit = UnitActor.FindUnitById(msg.uniqueId)

	if unit.IsBoss == true then
		return
	end

	unit = nil

	local enemys = {}

	for i, unitEnemy in ipairs(GP.Team.EnemyTeam) do
		if unitEnemy.IsDelete == false then
			table.insert(enemys, unitEnemy)
		end
	end

	table.sort(enemys, function(a, b)
		return a.TeamIndex < b.TeamIndex
	end)

	for i, enemy in ipairs(enemys) do
		if i == self.index then
			unit = enemy
		end
	end

	if unit == nil or unit.UniqueId == "" then
		return
	end

	self.uniqueId = unit.UniqueId

	if unit.IsBoss == false then
		self.hpbar_enemy:CurOnly(true)
	end

	self:RefreshUnit(unit)

	local arg = {}

	arg.uniqueId = unit.UniqueId

	self:OnUnitRandomSkill(arg)
	self:Show(true)
	self.parent:SetActive(true)
	self.cellBuffIcons:Bind(self.uniqueId, self.obj_buffRoot, EnumFight.ShowIcon.Unit)
	self.cellHeadTip:Bind(self.uniqueId, self.img_enemyIcon.gameObject)
end

function DlgUIEnemyInfo:OnUnitUpdateAttri(msg)
	if self.uniqueId ~= msg.uniqueId then
		return
	end

	if msg.attriName == "生命" then
		self.hpbar_enemy:SetCur(msg.cur)
		self.hpbar_enemy:PlayEffect(self.hpFxPath)
	elseif msg.attriName == "最大生命" then
		self.hpbar_enemy:SetMax(msg.cur)
	elseif msg.attriName == "怒气" then
		self.angrybar_enemy:SetCur(msg.cur)
		self.angrybar_enemy:PlayEffect(self.angryFxPath)
	elseif msg.attriName == "最大怒气" then
		self.angrybar_enemy:SetMax(msg.cur)
	elseif msg.attriName == "等待回合" then
		UIUtil.SetTextString(self.txt_enemyAtkRound, tostring(msg.cur))
	elseif msg.attriName == "怒气阶段" then
		for i, img in ipairs(self.img_enemyAngeySkillIcon) do
			local arg = TenaryOp(i ~= msg.cur, 1, 0)

			UIUtil.SetImageGray(img, arg)
		end

		for i, img in ipairs(self.img_enemyAngeySkillIcon2) do
			local arg = TenaryOp(i ~= msg.cur, 1, 0)

			UIUtil.SetImageGray(img, arg)
		end

		if self.img_enemyAngeySkillIcon[msg.cur] then
			EffectMgr:Alloc("Fx/UI/eff_ui_Boss_Power/eff_ui_Boss_Power", self.img_enemyAngeySkillIcon[msg.cur].gameObject.transform, true, 1)
		end
	end
end

function DlgUIEnemyInfo:UpdateAttri(unitBase)
	local val = unitBase:GetAttri("生命")

	if val then
		self.hpbar_enemy:SetCur(val)
	end

	val = unitBase:GetAttri("最大生命")

	if val then
		self.hpbar_enemy:SetMax(val)
	end

	val = unitBase:GetAttri("怒气")

	if val then
		self.angrybar_enemy:SetCur(val)
	end

	val = unitBase:GetAttri("最大怒气")

	if val then
		self.angrybar_enemy:SetMax(val)
	end

	val = unitBase:GetAttri("等待回合")

	if val then
		UIUtil.SetTextString(self.txt_enemyAtkRound, val)
	end

	val = unitBase:GetAttri("怒气阶段")

	if val then
		for i, img in ipairs(self.img_enemyAngeySkillIcon) do
			local arg = TenaryOp(i ~= val, 1, 0)

			UIUtil.SetImageGray(img, arg)
		end

		for i, img in ipairs(self.img_enemyAngeySkillIcon2) do
			local arg = TenaryOp(i ~= val, 1, 0)

			UIUtil.SetImageGray(img, arg)
		end
	end
end

function DlgUIEnemyInfo:OnUnitDestroy(msg)
	if self.uniqueId ~= msg.uniqueId then
		return
	end

	self:Show(false)
end

function DlgUIEnemyInfo:OnPlayDie(uniqueId)
	if self.uniqueId ~= uniqueId then
		return
	end

	self:Show(false)
end

function DlgUIEnemyInfo:RefreshUnit(unitBase)
	self.uniqueId = unitBase.UniqueId

	local unitId = unitBase.UnitId
	local headIconPath, jobpath = "", ""

	if unitBase.UnitClass == EnumFight.UnitClass.PVPPLAYER then
		headIconPath = unitBase.InfoRoleCard.data.HeadIcon
		jobpath = "UI/PageFight/AtlasPageBattle/ICO_" .. unitBase.UnitData.data.Job .. "_01_S2"
	else
		headIconPath = EnemyManager:Get(unitId).data.HeadIcon
		jobpath = "UI/PageFight/AtlasPageBattle/ICO_" .. unitBase.UnitData.data.Job .. "_01_S"
	end

	if unitBase.IsBoss == false then
		GOUtil.SetActive(self.txt_nextActionSkill.transform.parent.gameObject, false)
		GOUtil.SetActive(self.img_sessionIcon.gameObject, true)
	end

	GP.SpriteUtil:SetSprite(self.img_enemyIcon, headIconPath)
	GP.SpriteUtil:SetSprite(self.img_enemyJob, jobpath)
	UIUtil.SetTextString(self.txt_name, Lang(unitBase.UnitData.data.Name))
	self.stun:SetActive(false)
	self:UpdateAttri(unitBase)
	self:OnBuffChange(self.uniqueId)
end

function DlgUIEnemyInfo:SelectTarget(msg)
	self.img_selectTarget.enabled = self.uniqueId == msg.uniqueId
end

function DlgUIEnemyInfo:OnUnitRandomSkill(msg)
	if self.uniqueId ~= msg.uniqueId then
		return
	end

	local unit = UnitActor.FindUnitById(msg.uniqueId)

	if unit.NextCastSkill and unit.NextCastSkill ~= 0 then
		local str = Lang(_BattleSkillData:GetAllSkillByBattleSkillId(unit.NextCastSkill).Name)

		if str == "" then
			str = "Name没配置" .. unit.NextCastSkill
		end

		UIUtil.SetTextString(self.txt_nextActionSkill, str)

		if self.img_sessionIcon then
			UnitOwnSkill.Get(unit.NextCastSkill):SetIcon(self.img_sessionIcon)
		end
	end
end

function DlgUIEnemyInfo:OnRefreshRoundCard(msg)
	return
end

function DlgUIEnemyInfo:OnRefreshRoundSession(msg)
	if self.uniqueId ~= msg.uniqueId then
		return
	end

	local path = EnumBattle.GetSecctionShowIcon(msg.sessionType, msg.isPower)

	SceneMgr.GetCurrentScene().GP.SpriteUtil:SetSprite(self.img_sessionIcon, path)
end

function DlgUIEnemyInfo:OnPvpSessionPlay(uniqueId)
	if self.uniqueId ~= uniqueId then
		return
	end

	GOUtil.SetActive(self.eff_session, false)
	GOUtil.SetActive(self.eff_session, true)
end

function DlgUIEnemyInfo:OnBtnClick()
	if GP.GameStage ~= EnumFight.GameState.OPERATOR_WAIT then
		return
	end

	Event.Instance:Fire("ReqTargetChange", self.uniqueId)
end
