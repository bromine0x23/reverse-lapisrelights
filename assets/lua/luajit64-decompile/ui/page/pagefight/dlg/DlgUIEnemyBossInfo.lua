-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUIEnemyBossInfo.lua

DlgUIEnemyBossInfo = class("DlgUIEnemyBossInfo", DlgUIEnemyInfo)

require("UI/Page/PageFight/Cells/CellHpBar")

local _BattleSkillData = require("Info.InfoBattleSkillData")
local SHIELD_HIT_EFF_DELAY = 0.5

function DlgUIEnemyBossInfo:ctor()
	DlgUIEnemyBossInfo.base.base.ctor(self, "UI/PageFight/Dlg/DlgUIEnemyBossInfo")

	self.cellBuffIcons = CellBuffIcons("boss")

	self:AddChildPanel(self.cellBuffIcons)
end

function DlgUIEnemyBossInfo:Cache()
	DlgUIEnemyBossInfo.base.Cache(self)
	EffectMgr:Cache("Fx/UI/Eff_Ui_Battle_BeHitMonster_01/Eff_Ui_Battle_BeHitMonster_01", 1)
end

function DlgUIEnemyBossInfo:Close(tParam)
	DlgUIEnemyBossInfo.base.Close(self, tParam)
end

function DlgUIEnemyBossInfo:Purge()
	DlgUIEnemyBossInfo.base.Purge(self)
end

function DlgUIEnemyBossInfo:OnRegisterEvent()
	DlgUIEnemyBossInfo.base.OnRegisterEvent(self)
	self:AddListener(self.bk, self.OnPointerDown_Skill, EventTriggerType.PointerLongPress)
end

function DlgUIEnemyBossInfo:OnUnRegisterEvent()
	DlgUIEnemyBossInfo.base.OnUnRegisterEvent(self)
	self:RemoveListener(self.bk, self.OnPointerDown_Skill, EventTriggerType.PointerLongPress)
end

function DlgUIEnemyBossInfo:OnEnter(vParam)
	DlgUIEnemyBossInfo.base.OnEnter(self, vParam)

	self.bk = self:GetChildGameObject("panel/bg_enemyIcon/bk")
	self.hpFxPath = "Fx/UI/Eff_Ui_Battle_BeHitMonster_01/Eff_Ui_Battle_BeHitMonster_01"
	self.angryFxPath = "Fx/UI/Eff_Ui_Battle_BeHitMonster_01/Eff_Ui_Battle_BeHitMonster_01"

	self:Show(false)
end

function DlgUIEnemyBossInfo:OnUnitCreate(msg)
	if msg.camp == EnumBattle.UnitClass.PLAYER or msg.order ~= self.index then
		return
	end

	local unit = UnitActor.FindUnitById(msg.uniqueId)

	if unit.IsBoss == false then
		return
	end

	self.uniqueId = msg.uniqueId

	self:RefreshUnit(unit)

	local sliders = {
		self.slider_icon1,
		self.slider_icon2,
		self.slider_icon3
	}

	for i, val in ipairs(unit.UnitData.data.StageOfAngry) do
		sliders[i].value = val * 0.01
	end

	self.cellBuffIcons:Bind(self.uniqueId, self.obj_buffRoot, EnumFight.ShowIcon.Unit)
	self:Show(true)
end
