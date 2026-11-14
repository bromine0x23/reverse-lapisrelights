-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/BossBattle/BossBattleSufferMgr.lua

BossBattleSufferMgr = class("BossBattleSufferMgr")
BossBattleSufferMgr.SessionSufferInterval = BattleConst.sufferInterval
BossBattleSufferType = {
	Interval = 1,
	Timing = 0
}

function BossBattleSufferMgr:ctor(GP, isSession, sessionType, sessionCount, skillCfg, skillLevel, skillTime, isCard)
	self.GP = GP
	self.isSession = isSession
	self.sessionType = sessionType
	self.sessionCount = sessionCount
	self.skillCfg = skillCfg
	self.skillLevel = skillLevel
	self.skillTime = skillTime
	self.sufferData = {}
	self.isCard = isCard
end

function BossBattleSufferMgr:AddData(pMsgs, pActionKeyIdx, pMutIdx)
	local unitData = {
		msgs = pMsgs,
		actionKeyIdx = pActionKeyIdx,
		mutIdx = pMutIdx
	}

	table.insert(self.sufferData, unitData)
end

function BossBattleSufferMgr:Play(sufferType, complete)
	if sufferType == BossBattleSufferType.Interval then
		if self.skillCfg.TotalTime > 0 and self.isCard == true then
			self:PlaySkillSuffer(complete)
		else
			self:NextIntervalSuffer(complete)
		end
	else
		self:PlayTimingSuffer()
	end
end

function BossBattleSufferMgr:PlayTimingSuffer()
	for i, data in ipairs(self.sufferData) do
		local custom = self.skillCfg.Custom[data.actionKeyIdx]
		local time = custom.Hit_f[data.mutIdx] * self.skillTime

		BattleConfig.Delay(time, function()
			for j, msg in ipairs(data.msgs) do
				self.GP.GameMsg:DoMsgAction(msg.eventId, msg)
			end
		end)
	end
end

function BossBattleSufferMgr:GetSufferCount()
	return #self.sufferData
end

function BossBattleSufferMgr:NextIntervalSuffer(complete)
	if #self.sufferData > 0 then
		self:PlayIntervalSuffer()

		local interval = self.isSession and BossBattleSufferMgr.SessionSufferInterval or BattleConst.sufferInterval

		BattleConfig.Delay(interval, function()
			self:NextIntervalSuffer(complete)
		end)
	else
		complete()
	end
end

function BossBattleSufferMgr:PlaySkillSuffer(complete)
	for i, data in ipairs(self.sufferData) do
		local custom = self.skillCfg.Custom[data.actionKeyIdx]
		local time = custom.Hit_f[data.mutIdx] * self.skillTime

		BattleConfig.Delay(time, function()
			local sufferUnitActor

			for j, msg in ipairs(data.msgs) do
				if sufferUnitActor == nil and msg.eventId == "单位-受到伤害" then
					sufferUnitActor = UnitActor.FindUnitById(msg.uniqueId)
				end

				self.GP.GameMsg:DoMsgAction(msg.eventId, msg)
			end

			if sufferUnitActor ~= nil then
				local action = self.skillCfg.Custom[data.actionKeyIdx]

				if action.Hit_eff ~= nil and #action.Hit_eff > 0 then
					local effId = GetListObjByIndex(action.Hit_eff, self.skillLevel)[data.mutIdx]

					if sufferUnitActor.IsBoss and action.Hit_eff_Boss ~= nil then
						effId = GetListObjByIndex(action.Hit_eff_Boss, self.skillLevel)[data.mutIdx]
					end

					BattleConfig.FxAlloc(effId, sufferUnitActor)
				end
			end
		end)
	end

	BattleConfig.Delay(self.skillTime, function()
		if complete then
			complete()
		end
	end)
end

function BossBattleSufferMgr:PlayIntervalSuffer()
	local data = table.remove(self.sufferData, 1)
	local sufferUnitActor

	for _, msg in ipairs(data.msgs) do
		if sufferUnitActor == nil and msg.eventId == "单位-受到伤害" then
			sufferUnitActor = UnitActor.FindUnitById(msg.uniqueId)
		end

		self.GP.GameMsg:DoMsgAction(msg.eventId, msg)
	end

	if sufferUnitActor == nil or self.isSession then
		-- block empty
	else
		local action = self.skillCfg.Custom[data.actionKeyIdx]

		if action.Hit_eff ~= nil and #action.Hit_eff > 0 then
			local effId = GetListObjByIndex(action.Hit_eff, self.skillLevel)[data.mutIdx]

			if sufferUnitActor.IsBoss and action.Hit_eff_Boss ~= nil then
				effId = GetListObjByIndex(action.Hit_eff_Boss, self.skillLevel)[data.mutIdx]
			end

			BattleConfig.FxAlloc(effId, sufferUnitActor)
		end
	end
end

function BossBattleSufferMgr:Dispose()
	return
end
