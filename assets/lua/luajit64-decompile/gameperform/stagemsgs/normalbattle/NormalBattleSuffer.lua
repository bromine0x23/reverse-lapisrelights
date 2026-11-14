-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/NormalBattle/NormalBattleSuffer.lua

local BulletData = require("luaData.BulletData")

NormalBattleSuffer = class("NormalBattleSuffer")

function NormalBattleSuffer:ctor(GP, skillCfg, skillTime, skillLevel)
	self.GP = GP
	self.skillCfg = skillCfg
	self.skillTime = skillTime
	self.skillLevel = skillLevel
end

function NormalBattleSuffer:Create(data, actionKeyIdx, mutIdx)
	self.commands = data
	self.actionKeyIdx = actionKeyIdx
	self.mutIdx = mutIdx
	self.haveDamage = false

	for _, msg in ipairs(self.commands) do
		if msg.eventId == "单位-受到伤害" then
			self.haveDamage = true
		end
	end
end

function NormalBattleSuffer:SetBulletData(bulletId, attackUnitActor, sufferTarget)
	self.bulletId = bulletId
	self.attackUnitActor = attackUnitActor

	if self.bulletId ~= nil then
		self.bulletSufferUnitActor = UnitActor.FindUnitById(sufferTarget)
	end
end

function NormalBattleSuffer:Timing()
	BattleConfig.Delay(self:GetTime(), function()
		self:Execute()
	end)
end

function NormalBattleSuffer:Execute()
	for i, command in ipairs(self.commands) do
		if command.eventId == "单位-受到伤害" then
			self:PlaySufferEff(command)
			self.GP.GameMsg:DoMsgAction(command.eventId, command)
		elseif command.eventId == "技能-生效目标" then
			self:PlayHitEff(command)
		else
			self.GP.GameMsg:DoMsgAction(command.eventId, command)
		end
	end
end

function NormalBattleSuffer:PlaySufferEff(command)
	local sufferUnitActor = UnitActor.FindUnitById(command.uniqueId)

	if command.breakShieldState == EnumFight.BreakShieldState.BREAKING then
		BattleConfig.FxAlloc(BattleConfig.BreakShield.Fx[2], sufferUnitActor)
	elseif command.breakShieldState == EnumFight.BreakShieldState.DEFENSE then
		BattleConfig.FxAlloc(BattleConfig.BreakShield.Fx[1], sufferUnitActor)
	end
end

function NormalBattleSuffer:PlayHitEff(command)
	local sufferUnitActor = UnitActor.FindUnitById(command.uniqueId)
	local action = self.skillCfg.Custom[self.actionKeyIdx]

	if action.Hit_eff ~= nil and #action.Hit_eff > 0 then
		local effId = GetListObjByIndex(action.Hit_eff, self.skillLevel)[self.mutIdx]

		if sufferUnitActor.IsBoss and action.Hit_eff_Boss ~= nil then
			effId = GetListObjByIndex(action.Hit_eff_Boss, self.skillLevel)[self.mutIdx]
		end

		if effId then
			BattleConfig.FxAlloc(effId, sufferUnitActor)
		else
			print("配置不正确， skill:" .. self.skillCfg.ID)
			printTableToJson(action.Hit_eff)
			print("self.skillLevel  = " .. self.skillLevel .. " mutIdx = " .. self.mutIdx)
		end
	end
end

function NormalBattleSuffer:GetTime()
	local custom = self.skillCfg.Custom[self.actionKeyIdx]
	local time = custom.Hit_f[self.mutIdx] * self.skillTime

	if self.bulletId == nil then
		return time
	else
		local bulletCfg = BulletData[self.bulletId]
		local boomPos = Bullet.GetBoomPos(self.bulletSufferUnitActor, bulletCfg)
		local startPos = Bullet.GetStartPos(self.attackUnitActor, bulletCfg)
		local dist = (boomPos - startPos).magnitude

		return dist / (bulletCfg.Speed * 0.001 * 60) + time
	end
end

function NormalBattleSuffer:Dispose()
	return
end
