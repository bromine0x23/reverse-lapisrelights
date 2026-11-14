-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/BossBattle/BossBattleHeroAction.lua

local effectCfg = require("luaData/EffectData")

BossBattleHeroAction = class("BossBattleHeroAction")

function BossBattleHeroAction:ctor(GP)
	self.GP = GP
	self.attacks = {}
	self.startMsgs = {}
end

function BossBattleHeroAction:Create(data)
	self.groupData = table.remove(data, 1)
	self.isSingle = #self.groupData.uniqueIds == 1

	local attackData

	for i, msg in ipairs(data) do
		if msg.eventId == "技能-释放出手" then
			self:CreateAttackNode(attackData)

			attackData = {}

			table.insert(attackData, msg)
		elseif msg.eventId == "行动结束" then
			self.ends = {}

			self:CreateAttackNode(attackData)
		elseif self.ends ~= nil then
			table.insert(self.ends, msg)
		elseif attackData ~= nil then
			table.insert(attackData, msg)
		else
			table.insert(self.startMsgs, msg)
		end
	end

	if self.ends == nil then
		self:CreateAttackNode(attackData)
	end

	self.isCard = self.attacks[1].isCard
end

function BossBattleHeroAction:CreateAttackNode(attackData)
	if attackData ~= nil then
		local count = #self.groupData.uniqueIds
		local isSession = count > 1 and self.groupData.sessionType ~= 0
		local attackNode = BossBattleHeroAttack(self.GP, isSession, self.groupData.sessionType, #self.groupData.uniqueIds)

		attackNode:Create(attackData)
		table.insert(self.attacks, attackNode)
	end
end

function BossBattleHeroAction:Play(complete)
	self.GP.GameMsg:DoMsgAction(self.groupData.eventId, self.groupData)

	for _, msg in ipairs(self.startMsgs) do
		self.GP.GameMsg:DoMsgAction(msg.eventId, msg)
	end

	local count = #self.groupData.uniqueIds

	if count > 1 and self.groupData.sessionType ~= 0 then
		self:PlaySessionAnim(complete)
	else
		self:PlayAttack(function()
			self:End(complete)
		end)
	end
end

function BossBattleHeroAction:PlaySessionAnim(complete)
	self.GP.UI.DlgUICutInSession:Open(self.groupData, function()
		self.GP.Live:PauseLive()

		local sessionCfg = require("luaData/SessionData")
		local keys = {
			"Session1P",
			"Session2P",
			"Session3P",
			"Session4P"
		}
		local key = keys[#self.groupData.uniqueIds]
		local timeLineIds = sessionCfg[self.groupData.sessionType][key]
		local radmonIdx = math.random(1, #timeLineIds)
		local timeLineId = timeLineIds[radmonIdx]
		local Fxkeys = {
			"Session1PFx",
			"Session2PFx",
			"Session3PFx",
			"Session4PFx"
		}
		local FxKey = Fxkeys[#self.groupData.uniqueIds]
		local fxId = sessionCfg[self.groupData.sessionType][FxKey][radmonIdx]

		fxId = fxId or 0

		self.GP.TimeLine:PlaySession(timeLineId, self.groupData.sessionType, self.groupData.uniqueIds, function()
			Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator")
			Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", true)
			BattleConfig.Delay(BattleConst.bossViewDelay, function()
				local effId = fxId

				BattleConfig.FxAlloc(effId, self.attacks[1].unitBoss)

				local effTime = 0

				if effectCfg[effId] and effectCfg[effId].Life then
					effTime = effectCfg[effId].Life
				end

				local hitCount = self:GetSufferCount()

				BossBattleSufferMgr.SessionSufferInterval = effTime / hitCount

				BattleConfig.Delay(effTime, function()
					self:End(complete)
				end)
				self:PlayAttack()
			end)
		end)
	end)
	BattleConfig.Delay(1.4, function()
		self.GP.TimeLine:CamFlash()
	end)
end

function BossBattleHeroAction:GetSufferCount()
	local sufferCount = 0

	for i, v in ipairs(self.attacks) do
		sufferCount = sufferCount + v:GetSufferCount()
	end

	return sufferCount
end

function BossBattleHeroAction:PlayAttack(complete)
	if #self.attacks > 0 then
		local attack = table.remove(self.attacks, 1)

		attack:Play(function()
			self:PlayAttack(complete)
		end)
	elseif complete ~= nil then
		complete()
	end
end

function BossBattleHeroAction:End(complete)
	local dieTime = 0

	for i, msg in ipairs(self.ends) do
		if msg.eventId == "单位-死亡" then
			dieTime = self.GP.GameMsg:DoMsgAction(msg.eventId, msg)
		else
			self.GP.GameMsg:DoMsgAction(msg.eventId, msg)
		end
	end

	if dieTime > 0 then
		BattleConfig.Delay(dieTime, complete)
	else
		complete()
	end
end

function BossBattleHeroAction:Dispose()
	for i, v in ipairs(self.attacks) do
		v:Dispose()
	end
end
