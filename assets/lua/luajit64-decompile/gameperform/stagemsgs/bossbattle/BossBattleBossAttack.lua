-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/BossBattle/BossBattleBossAttack.lua

local SkillCfgInfo = require("GamePerform.Object.InfoBattleSkillData")

BossBattleBossAttack = class("BossBattleBossAttack")

function BossBattleBossAttack:ctor(GP)
	self.GP = GP
end

function BossBattleBossAttack:Create(data)
	self.attackData = table.remove(data, 1)
	self.skillCfg = SkillCfgInfo:GetData(self.attackData.skillId)
	self.attackUnitActor = UnitActor.FindUnitById(self.attackData.uniqueId)
	self.skillLevel = self.attackUnitActor:GetOwnSkill(self.skillCfg.ID).Level
	self.skillTime = self.skillCfg.TotalTime ~= -1 and self.skillCfg.TotalTime or self.attackUnitActor.Actor.MotionSystem:GetAnimLength(self.skillCfg.AnimState)
	self.sufferController = BossBattleSufferMgr(self.GP, false, 0, 0, self.skillCfg, self.skillLevel, self.skillTime, false)

	local sufferData
	local actionKeyIdx = -1
	local mutIdx = -1

	for i, msg in ipairs(data) do
		if msg.eventId == "技能ActionKey发动" then
			self:CreateSuffer(sufferData, actionKeyIdx, mutIdx)

			actionKeyIdx = msg.actionKeyIdx
			sufferData = nil
		elseif msg.eventId == "伤害目标" then
			-- block empty
		elseif msg.eventId == "受击打包" then
			self:CreateSuffer(sufferData, actionKeyIdx, mutIdx)

			mutIdx = msg.mutIdx
			sufferData = {}
		else
			table.insert(sufferData, msg)
		end
	end

	self:CreateSuffer(sufferData, actionKeyIdx, mutIdx)
end

function BossBattleBossAttack:CreateSuffer(sufferData, actionKeyIdx, mutIdx)
	if sufferData ~= nil and #sufferData > 0 then
		self.sufferController:AddData(sufferData, actionKeyIdx, mutIdx)
	end
end

function BossBattleBossAttack:Play(complete)
	self:PlaySkill(function()
		self.sufferController:Play(BossBattleSufferType.Timing)
		BattleConfig.Delay(self.skillTime, complete)
	end)
end

function BossBattleBossAttack:PlaySkill(complete)
	if self.skillCfg.TimeLineID ~= 0 then
		self.GP.TimeLine:PlaySkill(self.skillCfg, self.attackUnitActor, function()
			self:PlayRoleBehavior()
			complete()
		end)
	else
		self:PlayRoleBehavior()
		complete()
	end
end

function BossBattleBossAttack:PlayRoleBehavior()
	if self.skillCfg.AnimState ~= "" then
		if self.attackUnitActor:IsState("SpeIdle") then
			self.attackUnitActor:CrossFade(self.skillCfg.AnimState, 0.1)
		else
			self.attackUnitActor:Play(self.skillCfg.AnimState)
		end
	end

	for i, v in ipairs(self.skillCfg.CastTime) do
		BattleConfig.Delay(self.skillTime * v, function()
			local effId = self.skillCfg.CastFxs[i]

			BattleConfig.FxAlloc(effId, self.attackUnitActor)
		end)
	end
end

function BossBattleBossAttack:Dispose()
	self.sufferController:Dispose()
end
