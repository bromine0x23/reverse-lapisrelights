-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/Object/Unit/UnitOwnBuff.lua

local _BuffData = require("luaData/BattleBuffData")

UnitOwnBuff = class("UnitOwnBuff")

function UnitOwnBuff:ctor(unit, buffId, buffUid, skillPower, stack, logicData)
	self.GP = unit.GP
	self.UID = buffUid
	self.BuffId = buffId
	self.skillPower = skillPower
	self.Owner = unit
	self.Level = level
	self.remainRound = -1

	local infoSkill = _BuffData[buffId]

	self.Cfg = infoSkill
	self.Name = Lang(infoSkill.ShowName)
	self.Description = Lang(infoSkill.Description)
	self.IconPath = infoSkill.Icon
	self.ShowIcon = infoSkill.ShowIcon
	self.AnimState = infoSkill.AnimState
	self.TypeOrderf = infoSkill.TypeOrder
	self.IsTeam = infoSkill.IsTeam
	self.Fx = infoSkill.Fx
	self.RemoveFx = infoSkill.RemoveFx
	self.ExeFx = infoSkill.ExeFx
	self.RoundFx = infoSkill.RoundFx
	self.UIFxs = infoSkill.UIFxs
	self.UIFxsOnIcon = infoSkill.UIFxsOnIcon
	self.UIExeFxs = infoSkill.UIExeFxs
	self.UIExeFxsOnIcon = infoSkill.UIExeFxsOnIcon
	self.UIFxHandles = {}
	self.UIExeFxHandles = {}
	self.MaxStack = infoSkill.MaxStack
	self.Stack = stack
	self.LogicData = logicData

	if self.Owner.UnitClass == EnumFight.UnitClass.ENEMY and self.Owner.UnitData.Boss == 1 then
		self.Fx = infoSkill.FxBoss
		self.RemoveFx = infoSkill.RemoveFxBoss
		self.ExeFx = infoSkill.ExeFxBoss
	end
end

function UnitOwnBuff:Purge()
	self:Remove()

	self.GP = nil
	self.Owner = nil
	self.FxHandle = nil
	self.UIFxHandles = {}
	self.UIExeFxHandles = {}
	self.remainRound = -1
	self.LogicData = nil
end

function UnitOwnBuff:Add()
	self.FxHandle = BattleConfig.FxAlloc(self.Fx, self.Owner)

	if self.Owner.HeadTipUI then
		local uiRoot = self.Owner.HeadTipUI.roleIconEffRoot

		for i, fx in ipairs(self.UIFxs) do
			self.UIFxHandles[tostring(self.UID)] = EffectMgr:AllocById(fx, uiRoot)
		end
	end

	if self.AnimState ~= "" then
		self.Owner:SetBool(self.AnimState, true)
	end

	if self.TypeOrderf == "frozen" then
		local delay = 0
		local stateEnum = {
			"AttackAction",
			"ThumpAction",
			"SpecialAction01"
		}

		for _, state in ipairs(stateEnum) do
			if self.Owner:IsState(state) then
				delay = self.Owner.Actor.MotionSystem:GetAnimLength(state)

				break
			end
		end

		BattleConfig.Delay(delay, function()
			self.Owner:PauseAnim()
		end)
	end

	if self.Cfg.ClearType ~= 0 then
		local VocalDeBuff = {
			UnitVocal.enType.VocalBuff,
			UnitVocal.enType.VocalDeBuff,
			UnitVocal.enType.VocalBuff,
			UnitVocal.enType.VocalDeBuff,
			UnitVocal.enType.VocalDeBuff
		}
		local enType = VocalDeBuff[self.Cfg.ClearType]

		if enType then
			Event.Instance:Fire("UnitVocalEvent", enType, self.Owner)
		end
	end
end

function UnitOwnBuff:RecoveryAnimStatus()
	if self.AnimState ~= "" then
		self.Owner:SetBool(self.AnimState, true)
		self.Owner:Play(self.AnimState)
	end
end

function UnitOwnBuff:HideFx()
	if self.FxHandle then
		EffectMgr:Free(self.FxHandle)

		self.FxHandle = nil
	end
end

local _effectCfg = require("luaData/EffectData")

function UnitOwnBuff:ShowFx()
	if self.FxHandle == nil then
		local effCfgData = _effectCfg[self.Fx]

		if effCfgData and effCfgData.Life == -1 then
			self.FxHandle = BattleConfig.FxAlloc(self.Fx, self.Owner)
		end
	end
end

function UnitOwnBuff:Exe()
	if self.Owner.HeadTipUI then
		local uiRoot = self.Owner.HeadTipUI.roleIconEffRoot

		if uiRoot then
			for i, fx in ipairs(self.UIExeFxs) do
				self.UIFxHandles[tostring(self.UID)] = EffectMgr:AllocById(fx, uiRoot)
			end
		end
	end

	BattleConfig.FxAlloc(self.ExeFx, self.Owner)
end

function UnitOwnBuff:Update(remainRound)
	if self.RoundFx ~= nil then
		if self.RoundFxHandle ~= nil then
			EffectMgr:Free(self.RoundFxHandle)

			self.RoundFxHandle = nil
		end

		local effId = self.RoundFx[remainRound]

		if effId ~= nil then
			self.RoundFxHandle = BattleConfig.FxAlloc(effId, self.Owner)
		end
	end

	self.remainRound = remainRound
end

function UnitOwnBuff:SetStack(stack)
	self.Stack = stack
end

function UnitOwnBuff:SetLogicData(data)
	self.LogicData = data
end

function UnitOwnBuff:Remove()
	if self.TypeOrderf == "frozen" then
		local canResumeAnim = true

		for _, buff in ipairs(self.Owner.Buffs) do
			if buff ~= nil and buff.TypeOrderf == "frozen" then
				canResumeAnim = false

				break
			end
		end

		if canResumeAnim then
			self.Owner:ResumeAnim()
		end
	end

	if self.AnimState ~= "" then
		local stateBool = false

		for _, buff in ipairs(self.Owner.Buffs) do
			if buff ~= nil and buff.AnimState == self.AnimState then
				stateBool = true

				break
			end
		end

		self.Owner:SetBool(self.AnimState, stateBool)
	end

	if self.FxHandle then
		EffectMgr:Free(self.FxHandle)

		self.FxHandle = nil
	end

	if self.RoundFxHandle ~= nil then
		EffectMgr:Free(self.RoundFxHandle)

		self.RoundFxHandle = nil
	end

	for k, v in pairs(self.UIFxHandles) do
		EffectMgr:Free(v)

		self.UIFxHandles[k] = nil
	end

	if self.GP.GameStage ~= EnumFight.GameState.GAMEOVER then
		BattleConfig.FxAlloc(self.RemoveFx, self.Owner)
	end
end
