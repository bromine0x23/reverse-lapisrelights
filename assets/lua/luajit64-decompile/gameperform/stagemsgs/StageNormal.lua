-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/StageNormal.lua

StageNormal = class("StageNormal", StageRecordBase)

function StageNormal:ctor(GP)
	StageNormal.base.ctor(self, GP)
end

function StageNormal:Excute()
	for i, unit in ipairs(self.GP.Team.EnemyTeam) do
		if unit.HeadTipUI then
			unit.HeadTipUI:ShowTargetEffect(true)
		end
	end

	for i, unit in ipairs(self.GP.Team.PlayerTeam) do
		if unit.HeadTipUI then
			unit.HeadTipUI:ShowTargetEffect(true)
		end
	end

	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator")
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", true, function()
		self:_Excute()
	end)
end

function StageNormal:_Excute()
	self.OtherMsgs = {}
	self.BuffSufferNodes = nil

	local curUnitInfo
	local isDot = false

	for i, msg in ipairs(self.MsgList) do
		if msg.eventId == "阶段-改变" then
			-- block empty
		elseif msg.eventId == "单位-buff即将生效" then
			if not self.BuffSufferNodes then
				self.BuffSufferNodes = {}
			end

			local uniqueId = msg.uniqueId

			if not self.BuffSufferNodes[uniqueId] then
				self.BuffSufferNodes[uniqueId] = {}
			end

			local curIndex = #self.BuffSufferNodes[uniqueId]

			self.BuffSufferNodes[uniqueId][curIndex + 1] = {}
			curUnitInfo = self.BuffSufferNodes[uniqueId][curIndex + 1]
		elseif not curUnitInfo then
			self.GP.GameMsg:DoMsgAction(msg.eventId, msg)
		else
			table.insert(curUnitInfo, msg)
		end
	end

	if self.BuffSufferNodes == nil then
		self:Leave()
	else
		self:Enter()
	end
end

function StageNormal:Enter()
	local waitTime = 0
	local delayStep = 0.5
	local temp = {}

	for uniqueId, unitInfos in pairs(self.BuffSufferNodes) do
		table.insert(temp, {
			uid = uniqueId,
			data = unitInfos
		})
	end

	table.sort(temp, function(a, b)
		return tonumber(a.uid) < tonumber(b.uid)
	end)

	for unitIdx, unitInfos in pairs(temp) do
		for i, unitInfo in ipairs(unitInfos.data) do
			for _, msg in ipairs(unitInfo) do
				if waitTime < i * delayStep then
					waitTime = i * delayStep
				end

				if msg.eventId == "单位-死亡" then
					print(msg.eventId .. i * delayStep)
					BattleConfig.Delay(i * delayStep + 0.2, function()
						self.GP.GameMsg:DoMsgAction(msg.eventId, msg)
					end)

					waitTime = waitTime + 0.2
				else
					BattleConfig.Delay(i * delayStep, function()
						self.GP.GameMsg:DoMsgAction(msg.eventId, msg)
					end)
				end
			end
		end
	end

	BattleConfig.Delay(waitTime, function()
		self:Leave()
	end)
end

function StageNormal:Leave()
	self.GP.GameMsg:ExcuteEnd()
end
