-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/NormalBattle/NormalBattleAction.lua

NormalBattleAction = class("NormalBattleAction")

local ra_interval = 0.5

function NormalBattleAction:ctor(GP, parent)
	self.GP = GP
	self.attacks = {}
	self.startMsgs = {}
	self.parent = parent
	self.actionIdx, self.maxActionIdx = 0, 0
end

function NormalBattleAction:Create(data)
	self.groupData = table.remove(data, 1)

	local attackData

	self.lastMelee = nil

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

	if self.lastMelee ~= nil then
		self.lastMelee.isLastMelee = true
	end

	self.attackCount = #self.attacks

	if self.attacks[1] and self.attacks[1].attackUnitActor then
		self.camp = self.attacks[1].attackUnitActor.Camp
	end
end

function NormalBattleAction:SetActionIdx(idx, maxIdx)
	self.actionIdx, self.maxActionIdx = idx, maxIdx
end

function NormalBattleAction:CreateAttackNode(attackData)
	if attackData ~= nil then
		local attackNode = NormalBattleAttack(self.GP, self)

		attackNode:Create(attackData, self.groupData.sessionType)
		table.insert(self.attacks, attackNode)

		attackNode.attackIndex = #self.attacks
		attackNode.groupIndex = self.groupData.groupIdx

		if not attackNode.isRemoteAttack then
			if self.lastMelee == nil then
				attackNode.isFirstMelee = true
			end

			self.lastMelee = attackNode
		end
	end
end

function NormalBattleAction:Play(complete)
	self.complete = complete

	self.GP.GameMsg:DoMsgAction(self.groupData.eventId, self.groupData)

	for _, msg in ipairs(self.startMsgs) do
		self.GP.GameMsg:DoMsgAction(msg.eventId, msg)
	end

	if self.attackCount == 0 then
		self:End()

		return
	end

	local count = #self.groupData.uniqueIds

	if count > 1 and self.groupData.sessionType ~= 0 then
		self:PlaySessionAnim()
	elseif self.GP.PVPMode == true and count == 1 and self.camp == EnumFight.Camp.ENEMY then
		self:PlaySessionAnim()
	else
		Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator", false)

		if self.GP.PVPMode == true then
			self.GP.Team:SetActive(self.camp, false)
		end

		self:PlayAttack()
	end
end

function NormalBattleAction:PlaySessionAnim()
	if self.attacks[1].attackUnitActor.Camp == EnumFight.Camp.ENEMY then
		self.GP.UI.DlgUIPVPSession:Open(self.groupData, function()
			if self.GP.PVPMode == true then
				self.GP.Team:SetActive(self.camp, false)
			end

			BattleConfig.Delay(0.5, function()
				for i, uid in ipairs(self.groupData.uniqueIds) do
					Event.Instance:Fire("PvpSessionPlay", uid)
				end
			end)
			self:PlayAttack()
		end)
	else
		self.GP.UI.DlgUICutInSession:Open(self.groupData)

		local type = self.groupData.sessionType
		local uniqueIds = self.groupData.uniqueIds

		self.GP.TimeLine:PlayCutIn(type, uniqueIds, function()
			self:PlayAttack()
		end)
	end
end

function NormalBattleAction:PlayAttack()
	if self.GP.PVPMode == true then
		self.GP.Team:SetActive(BattleConfig.OtherCamp(self.camp), true)
		self.GP.Team:SetActive(self.camp, false)
	end

	self:NextAttack()
end

function NormalBattleAction:NextAttack()
	if #self.attacks > 0 then
		local attack = self.attacks[1]

		if attack.isSpecialBall and attack.attackIndex == 1 then
			attack = table.remove(self.attacks, 1)

			attack:Play(function()
				self:UnitComplete()
			end)

			if #self.attacks > 0 then
				local nextTime = attack.skillTime

				if attack.skillCfg.TimeLineID ~= 0 and attack.skillCfg.TimeLine_S > 0 then
					nextTime = attack.skillCfg.TimeLine_S
				end

				BattleConfig.Delay(nextTime, function()
					self:NextAttack()
				end)
			end
		elseif attack.isRemoteAttack then
			local lastRemoteTime = -1000
			local lastMeleeTime = 0

			while #self.attacks > 0 do
				attack = self.attacks[1]

				if attack.isRemoteAttack then
					attack = table.remove(self.attacks, 1)

					local firstTime = attack:FirstSufferTime()
					local delay = lastRemoteTime - firstTime + ra_interval

					if delay < 0 then
						delay = 0
					end

					local passives = {
						EnumFight.SkillType.Passive,
						EnumFight.SkillType.Link,
						EnumFight.SkillType.Union,
						EnumFight.SkillType.Center
					}

					for i, _skillType in ipairs(passives) do
						if attack.allSkillCfg.BattleSkillType == _skillType then
							delay = 0
						end
					end

					local attackNode = attack

					BattleConfig.Delay(delay, function()
						attackNode:Play(function()
							self:UnitComplete()
						end)
					end)

					lastRemoteTime = attack:LastSufferTime() + delay
					lastMeleeTime = attack.skillTime + delay
				else
					BattleConfig.Delay(lastMeleeTime, function()
						self:NextAttack()
					end)

					return
				end
			end
		else
			attack = table.remove(self.attacks, 1)

			attack:Play(function()
				self:UnitComplete(attack)
			end)

			if #self.attacks > 0 then
				if self.attacks[1].isRemoteAttack then
					BattleConfig.Delay(attack.backTime, function()
						self:NextAttack()
					end)
				else
					BattleConfig.Delay(attack.backTime - 0.5, function()
						self:NextAttack()
					end)
				end
			end
		end
	end
end

function NormalBattleAction:UnitComplete()
	self.attackCount = self.attackCount - 1

	if self.attackCount == 0 then
		self:End()
	end
end

function NormalBattleAction:End()
	local dieTime = 0

	for i, msg in ipairs(self.ends) do
		if msg.eventId == "单位-死亡" then
			local curDieTime = self.GP.GameMsg:DoMsgAction(msg.eventId, msg)

			if dieTime < curDieTime then
				dieTime = curDieTime
			end
		else
			self.GP.GameMsg:DoMsgAction(msg.eventId, msg)
		end
	end

	if dieTime > 0 then
		BattleConfig.Delay(dieTime, function()
			self.complete()
		end)
	else
		self.complete()
	end
end

function NormalBattleAction:Dispose()
	for i, v in ipairs(self.attacks) do
		v:Dispose()
	end
end
