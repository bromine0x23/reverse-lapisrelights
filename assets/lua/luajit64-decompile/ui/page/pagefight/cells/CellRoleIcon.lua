-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Cells/CellRoleIcon.lua

require("UI/Dlg/Common/SkillTip")

local const_hp_red_pct = 0.3
local IMG_JOB_IMG = {
	"UI/PageFight/AtlasPageBattle/ui_hd_icon_up_02",
	"UI/PageFight/AtlasPageBattle/ui_hd_icon_down_02"
}
local RoleTeamData = require("luaData/CharacterTeam")

CellRoleIcon = class("CellRoleIcon", UIPanel_sync, true)
CellRoleIcon.delayTime = 0

function CellRoleIcon:ctor()
	CellRoleIcon.base.ctor(self, "UI/PageFight/Cells/DyCellRoleIcon")

	self.cellBuffIcons = CellBuffIcons()

	self:AddChildPanel(self.cellBuffIcons)

	self.cellHeadTip = CellHeadTipOnIcon()
end

function CellRoleIcon:Cache()
	CellRoleIcon.base.Cache(self)
	EffectMgr:Cache("Fx/UI/Eff_CellRoleIconClick/Eff_CellRoleIconClick", 1)
	EffectMgr:Cache("Fx/UI/Eff_CellRoleIconClick/Eff_CellRoleIconClick_bao", 1)
	EffectMgr:Cache("Fx/UI/Eff_Ui_Battle_Ball_01/Eff_Ui_Battle_Ball_01", 1)
end

function CellRoleIcon:SetParent(dyRoot, staticRoot)
	GOUtil.AttachGameObject(self.UIRootObject, dyRoot, true)
	GOUtil.AttachGameObject(self.obj_dyPart, staticRoot, true)
end

function CellRoleIcon:OnEnter(vParam)
	self.img_headIcon = self:GetChildComponent("img_headIcon", "Image")
	self.img_center = self:GetChildComponent("img_center", "Image")
	self.obj_stun = self:GetChildGameObject("obj_stun")
	self.obj_die = self:GetChildGameObject("obj_die")
	self.attrRoot = self:GetChildGameObject("attrRoot")
	self.img_job = self:GetChildComponent("img_job", "Image")
	self.img_jobChecking = self:GetChildComponent("Dy/img_jobChecking", "Image")
	self.obj_jobCheckingBg = self:GetChildGameObject("Dy/img_jobChecking (1)")
	self.obj_dyPart = self:GetChildGameObject("Dy")
	self.img_sessionIcon = self:GetChildComponent("session/img_sessionIcon", "Image")
	self.img_sessionBG1 = self:GetChildComponent("session/bg1", "Image")
	self.obj_sessionBG1 = self:GetChildGameObject("session/bg1")
	self.obj_sessionBG2 = self:GetChildGameObject("session/bg2")
	self.obj_clickArea = self:GetChildGameObject("obj_clickArea")
	self.index = vParam.index
	self.cRole = vParam.cRole
	self.unitId = vParam.unitId
	self.isPower = false
	self.obj_sessionEffPower = self:GetChildGameObject("session/Eff_Ui_Specialball/advanced")
	self.obj_specialballEff = self:GetChildGameObject("session/Eff_Ui_Specialball")

	GOUtil.SetActive(self.obj_sessionEffPower, false)

	self.hpBar = self:GetChildComponent("hp/hpBar", "Image")
	self.hpBar_red = self:GetChildComponent("hp/hpBar_red", "Image")
	self.hpBar_red.enabled = false
	self.hpText = self:GetChildComponent("hp/hpText", "Text")
	self.obj_buffRoot = self:GetChildGameObject("obj_buffsRoot")

	self:ClearAllState()
end

function CellRoleIcon:ShowJobCheck(val)
	GOUtil.SetActive(self.img_jobChecking.gameObject, val)
	GOUtil.SetActive(self.obj_jobCheckingBg, val)
end

function CellRoleIcon:InitData(msg)
	self.unitBase = UnitActor.FindUnitById(msg.uniqueId)
	self.uniqueId = msg.uniqueId
	self.seccionVaild = true
	self.img_center.enabled = false

	self.cellBuffIcons:Bind(self.uniqueId, self.obj_buffRoot, EnumFight.ShowIcon.Unit)
	self.cellHeadTip:Bind(self.uniqueId, self.attrRoot)

	local cardId = self.unitBase.CardId
	local card = self.unitBase.InfoRoleCard

	if card then
		SceneMgr.GetCurrentScene().GP.SpriteUtil:SetSprite(self.img_headIcon, card.data.HitIcon)

		local jobpath = "UI/PageFight/AtlasPageBattle/ICO_" .. self.unitBase.UnitData.data.Job .. "_01_S2"

		SceneMgr.GetCurrentScene().GP.SpriteUtil:SetSprite(self.img_job, jobpath)
	else
		print("unitId:" .. self.unitId .. " 找不到对应卡片")
	end

	local selectUnits = SceneMgr.GetCurrentScene().GP.SelectUnits

	if selectUnits[1] then
		local arg = {}

		arg.uniqueId = selectUnits[1].UniqueId

		self:SelectTarget(arg)
	end

	self.SessionSkillIdMap = {}

	for i, skill in ipairs(self.unitBase.OwnSkills) do
		if skill.BattleSkillType == EnumFight.SkillType.SpecialAction then
			self.SessionSkillIdMap[tostring(EnumFight.SkillType.SpecialAction)] = skill
		elseif skill.BattleSkillType == EnumFight.SkillType.ThumpAction then
			self.SessionSkillIdMap[tostring(EnumFight.SkillType.ThumpAction)] = skill
		elseif skill.BattleSkillType == EnumFight.SkillType.AttackAction then
			self.SessionSkillIdMap[tostring(EnumFight.SkillType.AttackAction)] = skill
		end
	end
end

function CellRoleIcon:UpdateHp()
	local max = self.unitBase:GetAttri("最大生命")
	local cur = self.unitBase:GetAttri("生命")

	if max and cur then
		self.hpBar.fillAmount = cur / max
		self.hpBar_red.fillAmount = self.hpBar.fillAmount
		self.hpBar_red.enabled = self.hpBar_red.fillAmount <= const_hp_red_pct

		local str = math.ceil(cur)

		self.hpText.text = str
	end
end

function CellRoleIcon:OnUnitUpdateAttri(msg)
	if self.uniqueId ~= msg.uniqueId then
		return
	end

	if msg.attriName == "生命" or msg.attriName == "最大生命" then
		self:UpdateHp()
	end
end

function CellRoleIcon:OnUnitCreate(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	if unit.Camp ~= EnumFight.Camp.PLAYER then
		return
	end

	if self.unitId == unit.UnitId then
		self:InitData(msg)
	end
end

function CellRoleIcon:OnRefreshRoundSession(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	if unit.Camp ~= EnumFight.Camp.PLAYER then
		return
	end

	if msg.index ~= self.index then
		return
	end

	if msg.uniqueId ~= self.uniqueId then
		return
	end

	self.seccionType = msg.sessionType
	self.isPower = msg.isPower

	if msg.isNew == true then
		BattleConfig.Delay(1, function()
			self:PlayEffect()
		end)
	end

	self:SetVaild(true)

	local path = EnumBattle.GetSecctionShowIcon(self.seccionType, self.isPower)

	SceneMgr.GetCurrentScene().GP.SpriteUtil:SetSprite(self.img_sessionIcon, path)

	local sessionCfg = require("luaData/SessionData")
	local pathBG = sessionCfg[self.seccionType].BGIcon

	SceneMgr.GetCurrentScene().GP.SpriteUtil:SetSprite(self.img_sessionBG1, pathBG)
	GOUtil.SetActive(self.obj_sessionEffPower, self.isPower == true)

	local vaildSkillType = EnumFight.SkillType.None

	if self.isPower == false then
		local temp = {
			EnumFight.SkillType.ThumpAction,
			EnumFight.SkillType.AttackAction,
			EnumFight.SkillType.AttackAction
		}

		vaildSkillType = temp[self.seccionType]
	else
		vaildSkillType = EnumFight.SkillType.SpecialAction
	end

	self.curOwnSkill = self.SessionSkillIdMap[tostring(vaildSkillType)]
end

function CellRoleIcon:AttachHeadAttribute()
	self.unitBase.HeadAttribute:AttachToRoleIcon(self.UIRootObject)
end

function CellRoleIcon:Purge()
	CellRoleIcon.base.Purge(self)

	if self.cellHeadTip then
		self.cellHeadTip:Purge()
	end
end

function CellRoleIcon:Close()
	CellRoleIcon.base.Close(self)
	self.moveEffComponent:SetComplete(nil)

	if self.moveEff then
		EffectMgr:Free(self.moveEff)
	end

	EffectMgr:UnLoadEffect("Fx/UI/Eff_CellRoleIconClick/Eff_CellRoleIconClick")
	EffectMgr:UnLoadEffect("Fx/UI/Eff_Ui_Battle_Ball_01/Eff_Ui_Battle_Ball_01")
	EffectMgr:UnLoadEffect("Fx/UI/Eff_CellRoleIconClick/Eff_CellRoleIconClick_bao")

	self.obj_stun = nil
	self.img_headIcon = nil
	self.img_job = nil
	self.img_sessionIcon = nil
	self.img_sessionBG1 = nil
	self.img_sessionBG2 = nil
	self.obj_sessionBG1 = nil
	self.obj_sessionBG2 = nil
	self.hpBar = nil
	self.hpText = nil
	self.obj_clickArea = nil
	self.img_jobChecking = nil
	self.obj_jobCheckingBg = nil
	self.img_center = nil
	self.moveEffComponent = nil
	self.moveEff = nil
	self.index = nil
	self.cRole = nil
	self.isPower = false
	self.obj_sessionEffPower = nil
	self.seccionType = -1
	self.unitBase = nil
	self.uniqueId = ""
	self.unitId = -1
	self.seccionVaild = true
	self.obj_die = nil
	self.attrRoot = nil
end

function CellRoleIcon:OnRegisterEvent()
	Event.Instance:Add("UnitCreate", self.OnUnitCreate, self)
	Event.Instance:Add("RefreshRoundSession", self.OnRefreshRoundSession, self)
	self:AddClick(self.obj_clickArea, self.OnCellClick, "mute")
	self:AddListener(self.obj_clickArea, self.OnPointerDown, EventTriggerType.PointerLongPress)
	Event.Instance:Add("OnSelectorTarget", self.SelectTarget, self)
	Event.Instance:Add("UnitNotAction", self.OnUnitNotAction, self)
	Event.Instance:Add("UnitUpdateAttri", self.OnUnitUpdateAttri, self)
	Event.Instance:Add("UnitDie", self.OnUnitDie, self)
end

function CellRoleIcon:OnUnRegisterEvent()
	Event.Instance:Remove("UnitCreate", self.OnUnitCreate, self)
	Event.Instance:Remove("RefreshRoundSession", self.OnRefreshRoundSession, self)
	self:RemoveClick(self.obj_clickArea, self.OnCellClick)
	self:RemoveListener(self.obj_clickArea, self.OnPointerDown, EventTriggerType.PointerLongPress)
	Event.Instance:Remove("OnSelectorTarget", self.SelectTarget, self)
	Event.Instance:Remove("UnitNotAction", self.OnUnitNotAction, self)
	Event.Instance:Remove("UnitUpdateAttri", self.OnUnitUpdateAttri, self)
	Event.Instance:Remove("UnitDie", self.OnUnitDie, self)
end

function CellRoleIcon:ClearAllState()
	UIUtil.SetImageGray(self.img_headIcon, 0)

	self.img_sessionIcon.color = BattleConfig.ColorWhite
	self.img_headIcon.color = BattleConfig.ColorWhite

	GOUtil.SetActive(self.obj_sessionBG1, true)
	GOUtil.SetActive(self.obj_sessionBG2, false)
	GOUtil.SetActive(self.obj_stun, false)
	GOUtil.SetActive(self.obj_die, false)

	self.img_sessionIcon.enabled = true

	GOUtil.SetActive(self.obj_specialballEff, true)
end

function CellRoleIcon:OnPointerDown(data)
	if data.clickCount == 1 then
		local power = self.isPower and 3 or 0
		local ballType = power + self.seccionType
		local tipData = SkillTip.GetBallData(data.position, self.curOwnSkill.AllSkillId, ballType)

		UIMgr.ShowSkillTip(tipData)
	else
		UIMgr.HideSkillTip()
	end
end

function CellRoleIcon:SetClickEffect(moveEffobj)
	self.moveEffComponent = GOUtil.GetComponent(moveEffobj, "MoveSpline")
end

function CellRoleIcon:PlayEffect()
	if not self.unitBase.IsDead then
		if self.isPower == false then
			EffectMgr:Alloc("Fx/UI/Eff_Ui_Battle_Ball_01/Eff_Ui_Battle_Ball_01", self.img_sessionIcon.transform, true, 1)
		else
			EffectMgr:Alloc("Fx/UI/Eff_Ui_Battle_Ball_01/Eff_Ui_Battle_SpeBall_01", self.img_sessionIcon.transform, true, 1)
		end
	end
end

function CellRoleIcon:Refresh()
	return
end

function CellRoleIcon:OnCellClick()
	if not self.seccionType or not self.unitId then
		print("ERROR, unitId:" .. tostring(self.unitId) .. " seccionType:" .. tostring(self.seccionType))

		return
	end

	Event.Instance:Fire("RefreshSessionMode", self)

	if self.seccionVaild == false then
		self.moveEff = EffectMgr:Alloc("Fx/UI/Eff_CellRoleIconClick/Eff_CellRoleIconClick", self.moveEffComponent.gameObject, true, 1)

		self.moveEffComponent:SetComplete(function()
			BattleConfig.PlaySound("Play_SE_020_0023")
			EffectMgr:Alloc("Fx/UI/Eff_CellRoleIconClick/Eff_CellRoleIconClick_bao", self.moveEffComponent.gameObject, true, 1)
		end)
		self.moveEffComponent:StartMove()
	elseif self.moveEff then
		self.moveEffComponent:SetComplete(nil)
		EffectMgr:Free(self.moveEff)
	end
end

function CellRoleIcon:SetVaild(val)
	if not self.unitBase or self.unitBase.NotAction then
		return
	end

	self.seccionVaild = val

	if val then
		self.img_sessionIcon.color = BattleConfig.ColorWhite

		GOUtil.SetActive(self.obj_sessionBG1, true)
		GOUtil.SetActive(self.obj_sessionBG2, false)
	else
		self.img_sessionIcon.color = BattleConfig.ColorGary

		GOUtil.SetActive(self.obj_sessionBG1, false)
		GOUtil.SetActive(self.obj_sessionBG2, true)
	end
end

function CellRoleIcon:DisableState()
	self.img_sessionIcon.color = BattleConfig.ColorGary

	GOUtil.SetActive(self.obj_sessionBG1, false)
	GOUtil.SetActive(self.obj_sessionBG2, true)
end

function CellRoleIcon:SelectTarget(msg)
	if not self.unitBase then
		return
	end

	local target = UnitActor.FindUnitById(msg.uniqueId)
	local jobMul = JobCheckingUtil.GetMul(self.unitBase.UnitData.data.Job, target.UnitData.data.Job)

	if jobMul > 1 then
		local path = IMG_JOB_IMG[1]

		SceneMgr.GetCurrentScene().GP.SpriteUtil:SetSprite(self.img_jobChecking, path)

		self.img_jobChecking.enabled = true

		self:ShowJobCheck(true)
	elseif jobMul == 1 then
		self.img_jobChecking.enabled = false

		self:ShowJobCheck(false)
	elseif jobMul < 1 then
		local path = IMG_JOB_IMG[2]

		SceneMgr.GetCurrentScene().GP.SpriteUtil:SetSprite(self.img_jobChecking, path)

		self.img_jobChecking.enabled = true

		self:ShowJobCheck(true)
	end
end

function CellRoleIcon:OnUnitNotAction(uniqueId, val)
	if uniqueId ~= self.uniqueId then
		return
	end

	if self.obj_stun then
		if val then
			if not self.unitBase.IsDead then
				self:ClearAllState()
				GOUtil.SetActive(self.obj_stun, true)

				self.img_headIcon.color = BattleConfig.ColorGary2
			end
		else
			self:ClearAllState()
		end
	end
end

function CellRoleIcon:OnUnitDie(uniqueId)
	if uniqueId ~= self.uniqueId then
		return
	end

	self:ClearAllState()
	UIUtil.SetImageGray(self.img_headIcon, 1)
	GOUtil.SetActive(self.obj_sessionBG1, false)
	GOUtil.SetActive(self.obj_sessionBG2, true)

	self.img_sessionIcon.enabled = false

	GOUtil.SetActive(self.obj_specialballEff, false)
	GOUtil.SetActive(self.obj_die, true)
end
