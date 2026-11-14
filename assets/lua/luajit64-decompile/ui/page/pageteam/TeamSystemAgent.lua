-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTeam/TeamSystemAgent.lua

local RoleCardData = require("luaData/CharacterCard")
local LevelData = require("luaData/LevelConfig")

TeamSystemAgent = class("TeamSystemAgent")

function TeamSystemAgent:ctor(data)
	self.slotSpacing = data.slotSpacing
	self.teamCount = data.teamCount
	self.teamIndex = data.teamIndex
	self.teamList = data.teamList
	self.recommendJob = data.recommendJob
	self.monsterJob = data.monsterJob
	self.battleCost = data.battleCost
	self.battleCall = data.battleCall
	self.teamChangeCall = data.teamChangeCall
	self.teamNameChangeCall = data.teamNameChangeCall
	self.teamBondageChangeCall = data.teamBondageChangeCall
	self.teamFullReturnCall = data.teamFullReturnCall
	self.noSupCard = data.noSupCard
	self.noLevelUnlockSup = data.noLevelUnlockSup
	self.isRaid = data.isRaid
	self.isBossRaid = data.isBossRaid
	self.isPvp = data.isPvp
	self.isPvpAtk = data.isPvpAtk
	self.isTeamGroup = data.isTeamGroup
	self.isTimespace = data.isTimespace
	self.noCombatPower = data.noCombatPower
	self.noTeamSumCost = data.noTeamSumCost
	self.noCombBondage = data.noCombBondage
	self.noSwitchTeam = data.noSwitchTeam
	self.noExpressTeamBtn = data.noExpressTeamBtn
	self.noFittingRoomBtn = data.noFittingRoomBtn
	self.noBattleBeginBtn = data.noBattleBeginBtn
	self.localBattleTeam = data.localBattleTeam

	self:ResetScreenState()
end

TeamAgent = class("TeamAgent")

function TeamAgent:ctor(data)
	self.slotList = data.slotList
	self.slotCount = data.slotCount
	self.name = data.name
	self.fetterTeamId = data.fetterTeamId
end

TeamSlotAgent = class("TeamSlotAgent")

function TeamSlotAgent:ctor(data)
	self.upInfoRoleCard = data.upInfoRoleCard
	self.upInfoRole = data.upInfoRole
	self.addInfoRoleCard = data.addInfoRoleCard
	self.addInfoRole = data.addInfoRole
	self.isHelperCard = data.isHelperCard
	self.isHelperSlot = data.isHelperSlot
	self.limit = data.limit
	self.index = data.index
end

function TeamSlotAgent:GetCardInfo()
	return {
		upInfoRoleCard = self.upInfoRoleCard,
		upInfoRole = self.upInfoRole,
		addInfoRoleCard = self.addInfoRoleCard,
		addInfoRole = self.addInfoRole,
		isHelperCard = self.isHelperCard
	}
end

function TeamSlotAgent:SetCardInfo(data)
	self.upInfoRoleCard = data.upInfoRoleCard
	self.upInfoRole = data.upInfoRole
	self.isHelperCard = data.isHelperCard
end

function TeamSlotAgent:GetCost()
	local costValue = 0

	if self.upInfoRoleCard ~= nil then
		costValue = costValue + RoleCardMgr:GetCardCost(self.upInfoRoleCard, self.upInfoRole, 1)
	end

	if self.addInfoRoleCard ~= nil then
		costValue = costValue + RoleCardMgr:GetCardCost(self.addInfoRoleCard, self.addInfoRole, 2)
	end

	return costValue
end

function TeamSlotAgent:GetAddAttri()
	local attr = {}

	for i = 1, 4 do
		attr[i] = 0
	end

	if self.upInfoRoleCard ~= nil and self.addInfoRoleCard ~= nil then
		local mul = GetConfigArgJson("JoinAttCombat")[1] * 0.01

		for i = 1, 4 do
			attr[i] = math.floor(self.addInfoRoleCard:GetAtt(i) * mul + 0.5)
		end
	end

	return attr
end

function TeamSlotAgent:GetSlotAttr()
	local attCnt = 4
	local sumAttr = {
		0,
		0,
		0,
		0
	}
	local upAttr = {
		0,
		0,
		0,
		0
	}
	local addAttr = {
		0,
		0,
		0,
		0
	}

	if self.upInfoRoleCard then
		for i = 1, attCnt do
			upAttr[i] = self.upInfoRole:GetAttWithCard(i, self.upInfoRoleCard)
			sumAttr[i] = sumAttr[i] + upAttr[i]
		end
	end

	if self.addInfoRoleCard then
		for i = 1, attCnt do
			local percent = GetConfigArgJson("JoinAttCombat")[1] / 100

			addAttr[i] = self.addInfoRoleCard:GetAtt(i) * percent
			sumAttr[i] = sumAttr[i] + addAttr[i]
		end
	end

	return sumAttr, upAttr, addAttr
end

function TeamSlotAgent:GetSlotCP()
	local sumPower = 0
	local addPower = 0

	sumPower = RoleCardMgr:GetFightValue(self.upInfoRole, self.upInfoRoleCard, self.addInfoRoleCard)
	addPower = sumPower - RoleCardMgr:GetFightValue(self.upInfoRole, self.upInfoRoleCard)

	return sumPower, addPower
end

function TeamSlotAgent:LimitCheck(infoRoleCard)
	if self.limit then
		local limitType = self.limit[1]
		local limitId = self.limit[2]

		if limitType ~= -1 then
			if limitType == 1 then
				return infoRoleCard.data.CharacterID == limitId
			elseif limitType == 2 then
				return limitId == infoRoleCard.id
			elseif limitType == 3 then
				local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)

				return infoRole.data.Job == GetConfigArgJson("JobNumber")[limitId]
			elseif limitType == 4 then
				local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)

				return infoRole.data.Team == limitId
			end
		end
	end

	return true
end

function TeamSlotAgent:ReplaceUpCard(infoRoleCard, infoRole, isHelperCard)
	self.upInfoRoleCard = infoRoleCard
	self.upInfoRole = infoRole
	self.isHelperCard = isHelperCard
end

function TeamSlotAgent:ReplaceAddCard(infoRoleCard, infoRole)
	self.addInfoRoleCard = infoRoleCard
	self.addInfoRole = infoRole
end

function TeamAgent:GetUpCardIdx(cardId)
	for i, v in ipairs(self.slotList) do
		if v.upInfoRoleCard ~= nil then
			local id = v.upInfoRoleCard.id

			if id == cardId then
				return i
			end
		end
	end

	return -1
end

function TeamAgent:GetAddCardIdx(cardId)
	for i, v in ipairs(self.slotList) do
		if v.addInfoRoleCard ~= nil then
			local id = v.addInfoRoleCard.id

			if id == cardId then
				return i
			end
		end
	end

	return -1
end

function TeamAgent:FindSameRoleCard(cardId)
	for i, v in ipairs(self.slotList) do
		if v.upInfoRoleCard ~= nil then
			local id = v.upInfoRoleCard.id

			if TeamSystemAgent.SameRole(id, cardId) then
				return i
			end
		end
	end

	return -1
end

function TeamAgent:GetTeamCost()
	local costValue = 0

	for i, v in ipairs(self.slotList) do
		costValue = costValue + math.ceil(v:GetCost())
	end

	return costValue
end

function TeamAgent:ChangePos(index1, index2, notLimit)
	local slot1 = self.slotList[index1]
	local slot2 = self.slotList[index2]

	if slot1.isHelperCard and not slot2.isHelperSlot then
		return 1
	end

	if slot2.isHelperCard and not slot1.isHelperSlot then
		return 1
	end

	local limit1OK = false
	local limit2OK = false

	if slot1.upInfoRoleCard ~= nil then
		if slot2:LimitCheck(slot1.upInfoRoleCard) then
			limit1OK = true
		end
	else
		limit1OK = true
	end

	if slot2.upInfoRoleCard ~= nil then
		if slot1:LimitCheck(slot2.upInfoRoleCard) then
			limit2OK = true
		end
	else
		limit2OK = true
	end

	if limit1OK and limit2OK then
		local data1 = slot1:GetCardInfo()
		local data2 = slot2:GetCardInfo()

		slot1:SetCardInfo(data2)
		slot2:SetCardInfo(data1)

		return 0
	else
		return 2
	end
end

function TeamAgent:FullUpCard()
	for i, v in ipairs(self.slotList) do
		if v.upInfoRoleCard == nil then
			return false
		end
	end

	return true
end

function TeamAgent:GetTeamCP()
	local cp = 0

	for k, v in ipairs(self.slotList) do
		cp = cp + v:GetSlotCP()
	end

	return cp
end

function TeamSystemAgent:ResetScreenState()
	self.screenListState = {
		{
			0,
			0,
			0,
			0,
			0
		},
		{
			0,
			0,
			0,
			0
		},
		{
			0,
			0,
			0,
			0,
			0
		},
		{
			0,
			0,
			0,
			0
		}
	}
	self.screenCurSequence = 1
	self.screenCurSortType = 0
end

function TeamSystemAgent.SameRole(id1, id2)
	if id1 == 0 or id2 == 0 then
		return false
	end

	local card1 = RoleCardMgr:GetRoleCard(id1)
	local card2 = RoleCardMgr:GetRoleCard(id2)

	return card1.data.CharacterID == card2.data.CharacterID
end

function TeamSystemAgent.GetAddCardType(upCardId, addCardId)
	local list = JoinMgr:GetJoinAttachCardIds(upCardId)

	for i, v1 in ipairs(list) do
		for j, v2 in ipairs(v1[2]) do
			if v2 == addCardId then
				local type = v1[1]

				if type == 1 then
					return 3
				else
					return 2
				end
			end
		end
	end

	return 1
end

TeamSystemAgentMgr = {}
TeamSystemAgentMgr.helpInfoRoleList = {}
TeamSystemAgentMgr.helpInfoRoleCardList = {}
TeamSystemAgentMgr.helpInfoRole = {}
TeamSystemAgentMgr.helpInfoRoleCard = {}

local mineMaxCombatPower = 0
local helpFightTime = 0

function TeamSystemAgentMgr:UpdateHelpData(helpers)
	if not helpers then
		return
	end

	self.helpInfoRoleList = {}
	self.helpInfoRoleCardList = {}

	local listRoleFriend = {}
	local listRoleUnFriend = {}
	local listRoleCardFriend = {}
	local listRoleCardUnFriend = {}

	for _, helpData in ipairs(helpers) do
		local infoRole = self:GetHelpInfoRole(helpData)
		local infoRoleCard = self:GetHelpInfoRoleCard(helpData)
		local power = math.ceil(RoleCardMgr:GetFightValue(infoRole, infoRoleCard))

		infoRole.power = power
		infoRoleCard.power = power

		local isFriend = FriendMgr:IsGameFriend(infoRoleCard.pbPlayer.playerId)

		if isFriend then
			table.insert(listRoleFriend, infoRole)
			table.insert(listRoleCardFriend, infoRoleCard)
		else
			table.insert(listRoleUnFriend, infoRole)
			table.insert(listRoleCardUnFriend, infoRoleCard)
		end
	end

	local function func(a, b)
		return a.power > b.power
	end

	table.sort(listRoleFriend, func)
	table.sort(listRoleUnFriend, func)
	table.sort(listRoleCardFriend, func)
	table.sort(listRoleCardUnFriend, func)

	for i, v in ipairs(listRoleFriend) do
		table.insert(self.helpInfoRoleList, v)
	end

	for i, v in ipairs(listRoleUnFriend) do
		table.insert(self.helpInfoRoleList, v)
	end

	for i, v in ipairs(listRoleCardFriend) do
		table.insert(self.helpInfoRoleCardList, v)
	end

	for i, v in ipairs(listRoleCardUnFriend) do
		table.insert(self.helpInfoRoleCardList, v)
	end
end

function TeamSystemAgentMgr:UpdateGvgHelpData(helpers)
	if not helpers then
		return
	end

	self.helpInfoRoleList = {}
	self.helpInfoRoleCardList = {}

	local listRoleFriend = {}
	local listRoleUnFriend = {}
	local listRoleCardFriend = {}
	local listRoleCardUnFriend = {}

	for _, helpData in ipairs(helpers) do
		local infoRole = self:GetHelpInfoRole(helpData)
		local infoRoleCard = self:GetHelpInfoRoleCard(helpData)
		local power = math.ceil(RoleCardMgr:GetFightValue(infoRole, infoRoleCard))

		infoRole.power = power
		infoRoleCard.power = power

		local canUse = infoRoleCard:GvgHelpVaild()

		if canUse then
			table.insert(listRoleFriend, infoRole)
			table.insert(listRoleCardFriend, infoRoleCard)
		else
			table.insert(listRoleUnFriend, infoRole)
			table.insert(listRoleCardUnFriend, infoRoleCard)
		end
	end

	local function func(a, b)
		return a.power > b.power
	end

	table.sort(listRoleFriend, func)
	table.sort(listRoleCardFriend, func)
	table.sort(listRoleUnFriend, func)
	table.sort(listRoleCardUnFriend, func)

	for i, v in ipairs(listRoleFriend) do
		table.insert(self.helpInfoRoleList, v)
	end

	for i, v in ipairs(listRoleUnFriend) do
		table.insert(self.helpInfoRoleList, v)
	end

	for i, v in ipairs(listRoleCardFriend) do
		table.insert(self.helpInfoRoleCardList, v)
	end

	for i, v in ipairs(listRoleCardUnFriend) do
		table.insert(self.helpInfoRoleCardList, v)
	end
end

function TeamSystemAgentMgr:GetHelpInfoRoleCard(helpData)
	local infoRoleCard = self.helpInfoRoleCard[helpData.playerId]

	local function func(data)
		local infoCard = InfoRoleCard(data.mainCard.id)

		infoCard:SetPBPlayer(data)
		infoCard:SetData(data.mainCard)

		self.helpInfoRoleCard[data.playerId] = infoCard

		return infoCard
	end

	if infoRoleCard ~= nil then
		if infoRoleCard.id ~= helpData.mainCard.id then
			infoRoleCard = func(helpData)
		end
	else
		infoRoleCard = func(helpData)
	end

	local gvgHelpTimes = helpData.extras[1]

	if gvgHelpTimes and type(gvgHelpTimes) == "number" then
		infoRoleCard:SetGvgHelpTimes(gvgHelpTimes)
	end

	return infoRoleCard
end

function TeamSystemAgentMgr:GetHelpInfoRole(helpData)
	local infoRole = self.helpInfoRole[helpData.playerId]
	local roleId = RoleCardData[helpData.mainCard.id].CharacterID

	local function func(data, roleId)
		local infoRole = InfoRole(roleId)

		infoRole:SetPBPlayer(data)
		infoRole:SetData(data.leader)

		self.helpInfoRole[data.playerId] = infoRole

		return infoRole
	end

	if infoRole ~= nil then
		if infoRole.id ~= roleId then
			infoRole = func(helpData, roleId)
		else
			infoRole:SetReduceMul(0)
			infoRole:SetReduceAdd(0)
		end
	else
		infoRole = func(helpData, roleId)
	end

	return infoRole
end

function TeamSystemAgentMgr.UpdateMineMaxCombatPower(maxCombatPower)
	mineMaxCombatPower = maxCombatPower
end

function TeamSystemAgentMgr:UpdateHelperAttr(helpRole, helpCard)
	self:HelperAttriModify(helpCard, helpRole)
end

function TeamSystemAgentMgr:HelperAttriModify(helpCard, helpRole)
	if not helpCard or not helpRole then
		return
	end

	local selfMaxPower = mineMaxCombatPower
	local helpPower = RoleCardMgr:GetFightValue(helpRole, helpCard)
	local _config = GetConfigArgJson("SupportCardRatio")
	local x, y = _config[1], _config[2]
	local bp, BP = selfMaxPower, helpPower

	if x >= BP / bp then
		return
	end

	local _mul = bp * x / BP + (1 - bp * x / BP) * y

	helpRole:SetReduceMul(_mul - 1)
end

function TeamSystemAgentMgr:RequestHelperData(call, noMsg)
	local function func()
		local function wrap_cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat, 47)

			if vMsg.result.code == NetManager.Result_Sucess then
				mineMaxCombatPower = 0

				self:UpdateHelpData(vMsg.helpers)

				if call then
					call()
				end
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		end

		LoadingMgr.Show(eLoadingType.Repeat, 47)
		NetManager:RequestHelpFight(wrap_cb)
	end

	if helpFightTime and helpFightTime ~= 0 then
		local time = NetData:GetCurServerTime() / DateUtil.MillsPerSecond - helpFightTime

		if math.ceil(time) < 10 then
			local str = string.format(_("Msg_AssistRefreshCD"), math.floor(10 - time))

			if not noMsg then
				UIMgr.ShowMsg(str)
			elseif call then
				call()
			end
		else
			helpFightTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

			func()
		end
	else
		helpFightTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

		func()
	end
end

function TeamSystemAgentMgr:RequestGvgHelperData(call, noMsg)
	local function func()
		local function wrap_cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat, 50)

			if vMsg.result.code == NetManager.Result_Sucess then
				self:UpdateGvgHelpData(vMsg.helpers)

				if call then
					call()
				end
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		end

		LoadingMgr.Show(eLoadingType.Repeat, 50)
		NetManager:RequestGvgHelpFight(wrap_cb)
	end

	func()
end
