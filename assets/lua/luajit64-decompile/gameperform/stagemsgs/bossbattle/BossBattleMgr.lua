-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/BossBattle/BossBattleMgr.lua

BossBattleMgr = class("BossBattleMgr")

function BossBattleMgr:ctor(GP)
	self.GP = GP
	self.heroActions = {}
	self.bossActions = {}
end

function BossBattleMgr:Create(data)
	local actionData
	local lastRoleIsBoss = false

	for i, msg in ipairs(data) do
		if msg.eventId == "阶段-改变" then
			-- block empty
		elseif msg.eventId == "选球" then
			self.selectBallMsg = msg
		elseif msg.eventId == "行动开始" then
			self:CreateAction(actionData, lastRoleIsBoss)

			actionData = {}

			table.insert(actionData, msg)

			lastRoleIsBoss = self:IsEnemy(msg.uniqueIds[1])
		elseif actionData ~= nil then
			table.insert(actionData, msg)
		else
			self.GP.GameMsg:DoMsgAction(msg.eventId, msg)
		end
	end

	self:CreateAction(actionData, lastRoleIsBoss)

	if self.selectBallMsg ~= nil then
		local data = self:CreateCutInData()

		self:InsertCutIn(data)
	end
end

function BossBattleMgr:CreateCutInData()
	local lastSessionType = -1

	for i, sessionType in ipairs(self.selectBallMsg.sessionTypes) do
		if sessionType == lastSessionType then
			self.selectBallMsg.sessionTypes[i - 1] = "s"
			self.selectBallMsg.sessionTypes[i] = "s"
		end

		lastSessionType = sessionType
	end

	local cutinData = {}
	local data

	for i, sessionType in ipairs(self.selectBallMsg.sessionTypes) do
		if sessionType ~= "s" then
			if data == nil then
				data = {}

				table.insert(cutinData, data)
			end

			table.insert(data, self.selectBallMsg.uniqueIds[i])
		else
			data = nil
		end
	end

	return cutinData
end

function BossBattleMgr:InsertCutIn(cutinData)
	local newHeroActions = {}
	local lastActionIsSingle = false

	for i, action in ipairs(self.heroActions) do
		if action.isSingle and not action.isCard then
			if not lastActionIsSingle then
				local uids = table.remove(cutinData, 1)
				local nsCutIn = BossBattleNSCutIn(self.GP, uids)

				table.insert(newHeroActions, nsCutIn)
			end

			lastActionIsSingle = true
		else
			lastActionIsSingle = false
		end

		table.insert(newHeroActions, action)
	end

	self.heroActions = newHeroActions
end

function BossBattleMgr:CreateAction(actionData, isBoss)
	if actionData ~= nil then
		if isBoss then
			local actionNode = BossBattleBossAction(self.GP)

			actionNode:Create(actionData)

			if not actionNode:IsEmpty() then
				table.insert(self.bossActions, actionNode)
			end
		else
			local actionNode = BossBattleHeroAction(self.GP)

			actionNode:Create(actionData)
			table.insert(self.heroActions, actionNode)
		end
	end
end

function BossBattleMgr:IsEnemy(id)
	local unit = UnitActor.FindUnitById(id)

	return unit.Camp == EnumFight.Camp.ENEMY
end

function BossBattleMgr:Play(complete)
	self:HeroPlay(function()
		if #self.bossActions > 0 then
			if self.GP.GameStage == EnumFight.GameState.APPEAR_SKILL then
				self:BossPlay(complete)
			else
				BattleConfig.Delay(BattleConst.bossViewDelay, function()
					self:BossPlay(complete)
				end)
			end
		else
			local unit = self.GP.Team.EnemyTeam[1]
			local bossActive = unit:IsActive()

			if bossActive then
				self:BossToLive(complete)
			else
				self.GP.Live:ResumeLive()
				complete()
			end
		end
	end, true)
end

function BossBattleMgr:HeroPlay(complete, firstAction)
	if #self.heroActions > 0 then
		local actionNode = table.remove(self.heroActions, 1)

		if firstAction then
			actionNode:Play(function()
				self:HeroPlay(complete, false)
			end)
		elseif actionNode.className == "BossBattleNSCutIn" or not actionNode.isSingle then
			BattleConfig.Delay(BattleConst.bossViewDelay, function()
				actionNode:Play(function()
					self:HeroPlay(complete, false)
				end)
			end)
		else
			actionNode:Play(function()
				self:HeroPlay(complete, false)
			end)
		end
	else
		complete()
	end
end

function BossBattleMgr:BossPlay(complete)
	if #self.bossActions > 0 then
		local actionNode = table.remove(self.bossActions, 1)

		actionNode:Play(function()
			self:BossPlay(complete)
		end)
	elseif self.GP.GameStage == EnumFight.GameState.APPEAR_SKILL then
		self.GP.Live:ResumeLive()
		complete()
	else
		self:BossToLive(complete)
	end
end

function BossBattleMgr:BossToLive(complete)
	BattleConfig.Delay(BattleConst.bossViewDelay, function()
		self.GP.TimeLine:CamFlash(function()
			self.GP.Live:ResumeLive()
			complete()
		end)
	end)
end

function BossBattleMgr:Dispose()
	for i, v in ipairs(self.heroActions) do
		v:Dispose()
	end

	if self.bossAction ~= nil then
		self.bossAction:Dispose()
	end
end
