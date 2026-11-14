-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/GameRunTime/GameRoundData.lua

local print = function(...)
	if GameRunTime.print_enable == true then
		print(...)
	end
end
local OperatorItemData = GLClass("GameRoundData_OperatorItemData")

function OperatorItemData:ctor(GL)
	self.GL = GL

	self:Reset()
end

function OperatorItemData:Reset()
	self.PlayerUniqueId = 0
	self.UsedTypeMap = {}
	self.SessionType = EnumFight.SessionType.none
	self.Index = 0
	self.IsAction = false
	self.SessionWeight = {}
	self.IsPower = false
	self.IsNew = false

	function self.SessionCastFunction()
		return
	end

	self.SessionCastOrder = 1
end

function OperatorItemData:ResetSessionWeight()
	local unit = self.GL.UnitMgr:FindUnitById(self.PlayerUniqueId)

	self.SessionWeight = {}

	for i, weight in ipairs(self.GL.GameBaseData.CharacterCard[unit.CardId].SessionWeight) do
		self.SessionWeight[i] = weight
	end

	if not self.SessionWeight then
		self.SessionWeight = {
			1,
			1,
			1,
			1,
			1,
			1
		}
	end

	if not self.SkillMap[tostring(EnumFight.SkillType.SpecialAction)] then
		self.SessionWeight[4] = 0
		self.SessionWeight[5] = 0
		self.SessionWeight[6] = 0
	end
end

function OperatorItemData:SetUniqueId(uniqueId)
	self.PlayerUniqueId = uniqueId

	local unit = self.GL.UnitMgr:FindUnitById(uniqueId)

	self.SkillMap = {}

	for i, skill in ipairs(unit.Skills) do
		if skill.Type == EnumFight.SkillType.SpecialAction or skill.Type == EnumFight.SkillType.AttackAction or skill.Type == EnumFight.SkillType.ThumpAction then
			local key = tostring(skill.Type)

			self.SkillMap[key] = skill
		end
	end

	self:ResetSessionWeight()
end

function OperatorItemData:GetSessionSkill()
	local skill
	local sessionType = self.SessionType
	local isPower = self.IsPower
	local key = ""

	if isPower == true then
		key = EnumFight.SkillType.SpecialAction
	else
		local temp = {
			EnumFight.SkillType.ThumpAction,
			EnumFight.SkillType.AttackAction,
			EnumFight.SkillType.AttackAction
		}

		key = temp[sessionType]
	end

	key = tostring(key)
	skill = self.SkillMap[key]

	if not skill then
		local unit = self.GL.UnitMgr:FindUnitById(self.PlayerUniqueId)

		print("Session技能配置错误！  unit:" .. unit.UnitTitle)

		skill = self.SkillMap[tostring(EnumFight.SkillType.AttackAction)]
	end

	if not skill then
		local unit = self.GL.UnitMgr:FindUnitById(self.PlayerUniqueId)

		skill = unit.Skills[1]
	end

	return skill
end

function OperatorItemData:SetSessionCastFunction(func)
	self.SessionCastFunction = func
end

function OperatorItemData:SetIndex(index)
	self.Index = index
end

function OperatorItemData:SetAction(val)
	self.IsAction = val
end

function OperatorItemData:SetSessionType(type)
	self.SessionType = type
end

function OperatorItemData:ResetUsedTypeMap()
	self.UsedTypeMap = {}

	self:ResetSessionWeight()
end

function OperatorItemData:RandomSessionType()
	local type = -1
	local data = self.GL.GameBaseData.StageData.FirstSessionLimit

	if data then
		for roundIdx, limitTypes in ipairs(data) do
			for i, limitType in ipairs(limitTypes) do
				if i == self.Index and self.GL.RunTime.CurRound == roundIdx then
					type = limitType

					break
				end
			end
		end
	end

	if type == -1 then
		for usedType, _ in pairs(self.UsedTypeMap) do
			if self.SessionWeight[usedType] then
				self.SessionWeight[usedType] = 0
			end
		end

		local allUsed = true

		for i, weight in ipairs(self.SessionWeight) do
			if weight > 0 then
				allUsed = false

				break
			end
		end

		if allUsed == true then
			self:ResetUsedTypeMap()
		end

		type = WeightRandom({
			1,
			2,
			3,
			4,
			5,
			6
		}, self.SessionWeight)
		self.UsedTypeMap[type] = {}
	end

	if type > 3 then
		self.SessionType = type - 3
		self.IsPower = true
	else
		self.SessionType = type
		self.IsPower = false
	end
end

function OperatorItemData:___RandomSessionType()
	local type = -1
	local data = self.GL.GameBaseData.StageData.FirstSessionLimit

	if data then
		for roundIdx, limitTypes in ipairs(data) do
			for i, limitType in ipairs(limitTypes) do
				if i == self.Index and self.GL.RunTime.CurRound == roundIdx then
					type = limitType

					break
				end
			end
		end
	end

	if type == -1 then
		local data = {}

		data.SessionWeight = self.SessionWeight

		self.GL:Fire("即将更新回合Session", data, self.PlayerUniqueId)

		type = WeightRandom({
			1,
			2,
			3,
			4,
			5,
			6
		}, data.SessionWeight)
	end

	if type > 3 then
		self.SessionType = type - 3
		self.IsPower = true
	else
		self.SessionType = type
		self.IsPower = false
	end
end

function OperatorItemData:SetPowerType()
	local cmdWeight = {}

	for i = 4, #self.SessionWeight do
		table.insert(cmdWeight, self.SessionWeight[i])
	end

	local type = WeightRandom({
		4,
		5,
		6
	}, cmdWeight)

	if type then
		self.SessionType = type - 3
		self.IsPower = true
	end
end

local CardItemData = GLClass("GameRoundData_CardItemData")

function CardItemData:ctor(GL)
	self.GL = GL

	self:Reset()
end

function CardItemData:Reset()
	self.Skill = nil
	self.SkillId = nil
	self.PlayerUniqueId = ""
end

function CardItemData:SetUniqueId(uniqueId)
	self.PlayerUniqueId = uniqueId
end

function CardItemData:SetSkill(skill)
	self.Skill = skill
	self.SkillId = skill.SkillId
end

local MAX_OPERATOR_COUNT = 4
local MAX_CARD_COUNT = 3

GameRoundData = GLClass("GameRoundData")

function GameRoundData:ctor(GL)
	self.GL = GL

	self:Reset()
end

function GameRoundData:Reset()
	self.CardPool = {}
	self.CurCardList = {}
	self.PickCardList = {}
	self.OperatorItemDatas = {}
	self.PopSessionData = {}
	self.DoSessionData = {}
	self.CurDoSessionIndex = 1
	self.EnemyActionData = {}
	self.CurEnemyActionIndex = 1
	self.ComboCount = 0
	self.CurDoCardData = nil
	self.AutoOperatorState = EnumFight.AutoModeState.None
end

function GameRoundData:Start(_team)
	self.Team = _team

	if self.Team.UnitClass == EnumFight.UnitClass.ENEMY then
		return
	end

	for i, uniqueId in ipairs(self.Team.UniqueIds) do
		local item = OperatorItemData(self.GL)

		item:SetUniqueId(uniqueId)
		item:SetIndex(i)
		item:SetAction(true)
		table.insert(self.OperatorItemDatas, item)

		local unit = self.GL.UnitMgr:FindUnitById(uniqueId)

		for i, skill in ipairs(unit.Skills) do
			if skill.Type == EnumFight.SkillType.Active then
				local item = CardItemData(self.GL)

				item:SetSkill(skill)
				item:SetUniqueId(uniqueId)
				table.insert(self.CardPool, item)
			end
		end
	end
end

function GameRoundData:Refresh()
	self:RandomCard()
	self:RefreshCurCardSkill()
	self:RandomSession()

	self.CurEnemyActionIndex = 1
	self.EnemyActionData = {}
	self.AutoOperatorState = EnumFight.AutoModeState.None
end

function GameRoundData:PickCard(pickCardIds)
	for i, pickCardId in ipairs(pickCardIds) do
		for __, card in ipairs(self.CardPool) do
			if pickCardId == card.Skill.SkillId then
				table.insert(self.PickCardList, card)

				break
			end
		end
	end
end

function GameRoundData:RefreshCurCardSkill()
	for i, card in ipairs(self.CardPool) do
		card.Skill:RoundActive(false)
	end

	for i, card in ipairs(self.CurCardList) do
		card.Skill:RoundActive(true)
	end
end

function GameRoundData:RandomCard()
	if #self.PickCardList > 0 then
		for i, pickCard in ipairs(self.PickCardList) do
			table.insert(self.CurCardList, pickCard)
			self.GL:Fire("更新回合Card", pickCard)
		end

		self.PickCardList = {}
	end

	local maxCount = MAX_CARD_COUNT

	for i = #self.CurCardList, 1, -1 do
		local item = self.CurCardList[i]
		local unit = self.GL.UnitMgr:FindUnitById(item.PlayerUniqueId)

		if unit.IsDead == true then
			self.GL:Fire("卡牌清除", item.SkillId, item.PlayerUniqueId)
			item.Skill:UseStackPower()
			table.remove(self.CurCardList, i)
		end
	end

	local addCount = maxCount - #self.CurCardList

	if addCount == 0 then
		return
	end

	local cards = {}

	for _, card in ipairs(self.CardPool) do
		local uid = card.Skill.UID
		local owned = false

		for __, ownedSkill in ipairs(self.CurCardList) do
			local owneSkillUID = ownedSkill.Skill.UID

			if uid == owneSkillUID then
				owned = true

				break
			end
		end

		if owned == false then
			table.insert(cards, card)
		end
	end

	local high = {}
	local low = {}

	for i, card in ipairs(cards) do
		local unit = self.GL.UnitMgr:FindUnitById(card.PlayerUniqueId)

		if unit.IsDead == false then
			table.insert(high, card)
		else
			table.insert(low, card)
		end
	end

	for i = 1, math.min(addCount, #high) do
		local j = GameLogic.RandomToolInt(#high)
		local randomCard = high[j]

		if randomCard then
			self.GL:Fire("更新回合Card", randomCard)
			table.insert(self.CurCardList, randomCard)
			table.remove(high, j)

			addCount = addCount - 1
		end
	end

	for i = 1, addCount do
		local j = GameLogic.RandomToolInt(#low)
		local randomCard = low[j]

		if randomCard then
			self.GL:Fire("更新回合Card", randomCard)
			table.insert(self.CurCardList, randomCard)
			table.remove(low, j)
		end
	end
end

function GameRoundData:RandomSession()
	self.CurDoSessionIndex = 1
	self.DoSessionData = {}
	self.PopSessionData = {}

	for i, item in ipairs(self.OperatorItemDatas) do
		if item.IsAction == true then
			item:RandomSessionType()
		end

		item.IsNew = item.IsAction

		self.GL:Fire("更新回合Session", item)
		item:SetAction(false)
	end

	for i, item in ipairs(self.OperatorItemDatas) do
		local isPower = ""

		if item.IsPower == true then
			isPower = "*"
		end
	end
end

function GameRoundData:ChangeSession(targetType)
	for i, item in ipairs(self.OperatorItemDatas) do
		if item.IsPower == false then
			item:ResetUsedTypeMap()

			item.IsNew = item.SessionType ~= targetType

			item:SetSessionType(targetType)
			self.GL:Fire("更新回合Session", item)
		end
	end
end

function GameRoundData:ChangeSessionEx(targetType, index)
	for i, item in ipairs(self.OperatorItemDatas) do
		if index and index == i or index == nil then
			if targetType > 3 then
				item:ResetUsedTypeMap()

				item.IsNew = true

				item:SetPowerType()
			else
				item:ResetUsedTypeMap()

				item.IsNew = item.SessionType ~= targetType

				item:SetSessionType(targetType)

				item.IsPower = false
			end

			self.GL:Fire("更新回合Session", item)
		end
	end
end

function GameRoundData:ResetCombo()
	self.ComboCount = 0
end

function GameRoundData:UpdateCombo()
	self.ComboCount = self.ComboCount + 1

	return self.ComboCount
end

function GameRoundData:GetCurDoSessionData()
	local sessionGroupData = self.DoSessionData[self.CurDoSessionIndex]

	return sessionGroupData, self.CurDoSessionIndex
end

function GameRoundData:AddCurDoSessionDataIndex()
	self.CurDoSessionIndex = self.CurDoSessionIndex + 1
end

function GameRoundData:GetCurActionEnemy()
	if #self.EnemyActionData == 0 then
		for i, unit in self.GL.UnitMgr:Selector():Camp(2):Alive():Ipairs() do
			table.insert(self.EnemyActionData, unit)
		end
	end

	local cur = self.EnemyActionData[self.CurEnemyActionIndex]

	self.CurEnemyActionIndex = self.CurEnemyActionIndex + 1

	return cur, self.CurEnemyActionIndex - 1
end

function GameRoundData:AutoSetOperatorData()
	local outData = {}
	local typeMap = {}
	local aliveList = {}

	for i, item in ipairs(self.OperatorItemDatas) do
		local unit = self.GL.UnitMgr:FindUnitById(item.PlayerUniqueId)

		if unit.IsDead == false and unit.NotAction == false then
			table.insert(aliveList, item)
		end
	end

	local tempList = {}

	for i, item in ipairs(aliveList) do
		if item.IsPower == true then
			item.SessionCastOrder = i
		else
			item.SessionCastOrder = 100 + i
		end

		table.insert(tempList, item)
	end

	table.sort(tempList, function(a, b)
		return a.SessionCastOrder < b.SessionCastOrder
	end)

	for i, item in ipairs(tempList) do
		if not typeMap[item.SessionType] then
			typeMap[item.SessionType] = {}
		end

		table.insert(typeMap[item.SessionType], item)
	end

	local list = {}

	for type, items in pairs(typeMap) do
		table.insert(list, items)
	end

	table.sort(list, function(a, b)
		return #a > #b
	end)

	if self.Team.UnitClass == EnumFight.UnitClass.PVPPLAYER or self.Team.UnitClass == EnumFight.UnitClass.PLAYER then
		for i, items in ipairs(list) do
			for _, item in ipairs(items) do
				if #outData < MAX_OPERATOR_COUNT then
					table.insert(outData, item.Index)
				else
					break
				end
			end
		end

		if #outData == 0 and #aliveList > 0 then
			table.insert(outData, aliveList[1].Index)
		end

		return outData
	end

	for i, items in ipairs(list) do
		if #items > 1 then
			if #items == 5 then
				for j = 1, 4 do
					table.insert(outData, items[j].Index)
				end

				break
			end

			if #outData + #items <= MAX_OPERATOR_COUNT then
				for _, item in ipairs(items) do
					table.insert(outData, item.Index)
				end
			end
		end
	end

	if #outData == 0 and #aliveList > 0 then
		table.insert(outData, aliveList[1].Index)
	end

	return outData
end

function GameRoundData:TrySetOperatorData(operatorData)
	local playerChooseItems = {}

	for i, val in ipairs(operatorData) do
		table.insert(playerChooseItems, self.OperatorItemDatas[val])
	end

	self.DoSessionData, self.PopSessionData = SessionCheckingUtil:GetDoSessionList(playerChooseItems)

	if #self.PopSessionData == 0 then
		return true
	else
		return true
	end
end

function GameRoundData:NotifyDoSessionData()
	local uniqueIds = {}
	local sessionTypes = {}

	for groupIdx, groupData in ipairs(self.DoSessionData) do
		for i, data in ipairs(groupData) do
			table.insert(uniqueIds, data.PlayerUniqueId)
			table.insert(sessionTypes, data.SessionType)
		end
	end

	self.GL:Fire("选球", uniqueIds, sessionTypes)
end

function GameRoundData:TryDoCard(data)
	for i, item in ipairs(self.CurCardList) do
		if data.skillId == item.SkillId then
			table.remove(self.CurCardList, i)

			break
		end
	end

	self.CurDoCardData = data

	return true
end

function GameRoundData:GetMaxMpCard()
	local maxMp = 0
	local outCard

	for _, card in ipairs(self.CurCardList) do
		local unit = self.GL.UnitMgr:FindUnitById(card.PlayerUniqueId)

		if unit.IsDead == false and unit.NotAction == false and card.Skill.Cost <= self.Team:Get("魔力") and maxMp < card.Skill.Cost and unit.DisableCardSkill == false then
			maxMp = card.Skill.Cost
			outCard = card
		end
	end

	return outCard
end

function GameRoundData:GetMinOrderCard()
	local minOrder = 9999
	local outCard

	for _, card in ipairs(self.CurCardList) do
		local unit = self.GL.UnitMgr:FindUnitById(card.PlayerUniqueId)

		if unit.IsDead == false and unit.NotAction == false and card.Skill.Cost <= self.Team:Get("魔力") and minOrder > unit.Order and unit.DisableCardSkill == false then
			minOrder = unit.Order
			outCard = card
		end
	end

	return outCard
end

function GameRoundData:AutoOperator()
	if self.AutoOperatorState == EnumFight.AutoModeState.Session then
		return
	end

	local max = self.Team:Get("最大魔力")
	local cur = self.Team:Get("魔力")

	if cur >= max * 0.5 or self.AutoOperatorState == EnumFight.AutoModeState.Card then
		local card = self:GetMaxMpCard()

		if card then
			self.AutoOperatorState = EnumFight.AutoModeState.Card

			local data = {}

			data.uniqueId = card.PlayerUniqueId
			data.skillId = card.SkillId

			self.GL.RunTime:PlayerCard(data)

			return
		end
	end

	self.AutoOperatorState = EnumFight.AutoModeState.Session

	local operatorData = self:AutoSetOperatorData()

	self.GL.RunTime:PlayerOperator(operatorData)
end
