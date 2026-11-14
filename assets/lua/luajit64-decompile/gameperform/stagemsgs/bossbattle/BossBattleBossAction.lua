-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/BossBattle/BossBattleBossAction.lua

BossBattleBossAction = class("BossBattleBossAction")

function BossBattleBossAction:ctor(GP)
	self.GP = GP
	self.attacks = {}
	self.startMsgs = {}
end

function BossBattleBossAction:Create(data)
	self.groupData = table.remove(data, 1)

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
end

function BossBattleBossAction:IsEmpty()
	if #self.attacks == 0 and #self.startMsgs == 0 and #self.ends == 0 then
		return true
	end

	return false
end

function BossBattleBossAction:CreateAttackNode(attackData)
	if attackData ~= nil then
		local attackNode = BossBattleBossAttack(self.GP)

		attackNode:Create(attackData)
		table.insert(self.attacks, attackNode)
	end
end

function BossBattleBossAction:Play(complete)
	self.GP.GameMsg:DoMsgAction(self.groupData.eventId, self.groupData)

	for _, msg in ipairs(self.startMsgs) do
		self.GP.GameMsg:DoMsgAction(msg.eventId, msg)
	end

	self:PlayAttack(function()
		self:End(complete)
	end)
end

function BossBattleBossAction:PlayAttack(complete)
	if #self.attacks > 0 then
		local attackNode = table.remove(self.attacks, 1)

		attackNode:Play(function()
			self:PlayAttack(complete)
		end)
	else
		complete()
	end
end

function BossBattleBossAction:End(complete)
	for i, msg in ipairs(self.ends) do
		self.GP.GameMsg:DoMsgAction(msg.eventId, msg)
	end

	complete()
end

function BossBattleBossAction:Dispose()
	for i, v in ipairs(self.attacks) do
		v:Dispose()
	end
end
