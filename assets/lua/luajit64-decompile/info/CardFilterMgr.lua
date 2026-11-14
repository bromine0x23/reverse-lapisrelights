-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/CardFilterMgr.lua

local InfoTeam = require("Info/InfoTeam")
local InfoTeamgGroup = require("Info/InfoTeamgGroup")
local InfoTeamRaid = require("Info/InfoTeamRaid")
local InfoTeamBossRaid = require("Info/InfoTeamBossRaid")

CardFilterMgr = {}
eFilterSystemType = {
	Develop = "Develop",
	Intance = "Intance",
	Battle = "Battle"
}

local eFilterType = {
	Role = "Role",
	Comb = "Comb",
	Job = "Job",
	Team = "Team",
	Prop = "Prop"
}
local ePropType = {
	"LEVEL",
	"RANK",
	"STAR",
	"POWER",
	"SOUL"
}

local function GetFilterTypeNum(filterType)
	if filterType == eFilterType.Job then
		return 5
	elseif filterType == eFilterType.Comb then
		return #CombinationMgr:GetAllCombination()
	elseif filterType == eFilterType.Team then
		return 5
	elseif filterType == eFilterType.Prop then
		return 4
	elseif filterType == eFilterType.Role then
		return #RoleMgr:GetAllRole()
	end

	return 0
end

eChoiceType = {
	Multiple = 2,
	Single = 1
}
FilterRules = {
	Develop = {
		"Job",
		"Comb",
		"Team",
		"Prop"
	},
	Intance = {
		"Job",
		"Comb",
		"Team",
		"Prop"
	},
	Battle = {
		"Job",
		"Comb",
		"Prop"
	},
	Soul = {
		"Job",
		"Comb",
		"Role"
	}
}
CardFilterMgr.FilterListRule = {}
CardFilterMgr.FilterRoleListRule = {
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
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0
	}
}
CardFilterMgr.FilterSoulRule = {}
CardFilterMgr.FilterDictRule = {}
CardFilterMgr.FilterStruct = {}
CardFilterMgr.FilterSortRule = {}
CardFilterMgr.FilterSortSoul = true

function CardFilterMgr:Init()
	for _, systemType in pairs(eFilterSystemType) do
		CardFilterMgr.FilterListRule[systemType] = self.BuildFilterList(systemType)
		CardFilterMgr.FilterDictRule[systemType] = self.BuildFilterDict(systemType)
		CardFilterMgr.FilterStruct[systemType] = self.BuildFilterStruct(systemType)
		CardFilterMgr.FilterSortRule[systemType] = eSortType.Desce
	end

	CardFilterMgr.FilterSoulRule = self.BuildFilterSoulList()
	CardFilterMgr.FilterSoulStruct = self.BuildFilterStruct("Soul")
end

function CardFilterMgr.BuildFilterSoulList()
	local function fun(varRules)
		local tList = {}

		for k, v in pairsByKeys(varRules) do
			local rule = {}

			for i = 1, GetFilterTypeNum(v) do
				rule[i] = 0
			end

			tList[k] = rule
		end

		return tList
	end

	return fun(FilterRules.Soul)
end

function CardFilterMgr.GetFilterSoulRuleNameList()
	local listJob = GetConfigArgJson("JobName")
	local listComb = CombinationMgr:GetCombinationSortByTeamOder()
	local jobName = {}
	local listName = {}
	local comName = {}

	for _, value in pairs(listJob) do
		table.insert(jobName, Lang(value))
	end

	for index, value in ipairs(listComb) do
		table.insert(comName, Lang(listComb[index].data.Name))
	end

	for i = 1, #RoleMgr:GetAllRole() do
		table.insert(listName, RoleMgr:GetAllRole()[i]:GetName())
	end

	local list = {}

	list[1] = jobName
	list[2] = comName
	list[3] = listName

	local rule = CardFilterMgr.FilterSoulRule
	local name = ""
	local count = 0

	for i = 1, #rule do
		for j = 1, #rule[i] do
			if rule[i][j] ~= 0 then
				count = count + 1
				name = list[i][j]
			end
		end
	end

	if count == 1 then
		return name, count
	else
		return name, count
	end
end

function CardFilterMgr.BuildFilterList(systemType)
	local function fun(varRules)
		local tList = {}

		for k, v in pairsByKeys(varRules) do
			local rule = {}

			for i = 1, GetFilterTypeNum(v) do
				rule[i] = 0
			end

			tList[k] = rule
		end

		return tList
	end

	return fun(FilterRules[systemType])
end

function CardFilterMgr.BuildFilterDict(systemType)
	local function func(varRules, ruleList)
		local ruleDict = {}

		for k, v in ipairs(varRules) do
			ruleDict[v] = ruleList[k]
		end

		return ruleDict
	end

	return func(FilterRules[systemType], CardFilterMgr.FilterListRule[systemType])
end

function CardFilterMgr.BuildFilterStruct(systemType)
	local function GetJobName()
		local t = {}
		local jList = GetConfigArgJson("JobName")

		for _, v in ipairs(jList) do
			table.insert(t, Lang(v))
		end

		return t
	end

	local function GetCombName()
		local t = {}
		local cList = CombinationMgr:GetCombinationSortByTeamOder()

		for _, info in ipairs(cList) do
			table.insert(t, Lang(info.data.Name))
		end

		return t
	end

	local function GetTeamName()
		local t = {}

		for k, v in ipairs(InfoTeam.stageTeams) do
			if k > 5 then
				break
			end

			local str = v.name ~= "" and v.name or Lang(12079) .. k

			table.insert(t, str)
		end

		return t
	end

	local function GetPropName()
		return {
			Lang(12224),
			Lang(12223),
			Lang(12226),
			Lang(42175)
		}
	end

	local function GetRoleName()
		local listname = {}

		for i = 1, #RoleMgr:GetAllRole() do
			table.insert(listname, RoleMgr:GetAllRole()[i]:GetName())
		end

		return listname
	end

	local function fun1(var)
		if var == eFilterType.Prop then
			return eChoiceType.Single
		end

		return eChoiceType.Multiple
	end

	local function fun2(var, type)
		local title, list = "", {}

		if var == eFilterType.Job then
			title = Lang(12020)
			list = GetJobName()
		elseif var == eFilterType.Comb then
			title = Lang(12076)
			list = GetCombName()
		elseif var == eFilterType.Team then
			title = Lang(12079)
			list = GetTeamName()
		elseif var == eFilterType.Prop then
			title = Lang(12164)
			list = GetPropName()
		elseif var == eFilterType.Role then
			title = _("IRole")
			list = GetRoleName()
		end

		return type == 1 and title or list
	end

	local struct = {}

	for _, v in ipairs(FilterRules[systemType]) do
		local temp = {
			filterType = fun1(v),
			title = fun2(v, 1),
			list = fun2(v, 2)
		}

		table.insert(struct, temp)
	end

	return struct
end

function CardFilterMgr.ResetTeamName(systemType)
	local struct = CardFilterMgr.FilterStruct[systemType][3]

	local function GetTeamName()
		local t = {}

		for k, v in ipairs(InfoTeam.stageTeams) do
			if k > 5 then
				break
			end

			local str = v.name ~= "" and v.name or Lang(12079) .. k

			table.insert(t, str)
		end

		return t
	end

	struct.list = GetTeamName()
end

function CardFilterMgr.ResetFilterRule(systemType, ruleList)
	if not ruleList or next(ruleList) == nil then
		return
	end

	CardFilterMgr.FilterListRule[systemType] = ruleList
	CardFilterMgr.FilterDictRule[systemType] = CardFilterMgr.BuildFilterDict(systemType)
end

function CardFilterMgr.ResetSortRule(systemType, sortType)
	if not sortType then
		return
	end

	CardFilterMgr.FilterSortRule[systemType] = sortType
end

function CardFilterMgr.GetFilterRuleNameList(systemType)
	local function fun(idx, fType, sType)
		local dict = CardFilterMgr.FilterDictRule[sType]
		local rule = dict[fType] and dict[fType] or {}
		local t = {}

		for k, v in ipairs(rule) do
			if v > 0 then
				table.insert(t, CardFilterMgr.FilterStruct[sType][idx].list[k])
			end
		end

		return t
	end

	local list = {}

	for k, v in ipairs(FilterRules[systemType]) do
		for _, n in ipairs(fun(k, v, systemType)) do
			table.insert(list, n)
		end

		if #list > 1 then
			break
		end
	end

	return list
end

function CardFilterMgr:GetSameJobRoleCard(listJobName, listCard)
	local sameJobList = {}

	for _, card in ipairs(listCard) do
		if table.contains(listJobName, card.JobStr) then
			table.insert(sameJobList, card)
		end
	end

	return sameJobList
end

function CardFilterMgr:GetSameCombRoleCard(listCombId, listCard)
	local sameCombList = {}

	for _, card in ipairs(listCard) do
		if card.id ~= 0 then
			local role = RoleCardMgr:GetRole(card.id)

			if table.contains(listCombId, role.data.Team) then
				table.insert(sameCombList, card)
			end
		end
	end

	return sameCombList
end

function CardFilterMgr:GetSameTeamRoleCard(listCardId, listCard)
	local sameTeamList = {}

	for _, card in ipairs(listCard) do
		if card.id ~= 0 and table.contains(listCardId, card.id) then
			table.insert(sameTeamList, card)
		end
	end

	return sameTeamList
end

function CardFilterMgr.GetFilterCards(systemType, withNotHold)
	local rule = CardFilterMgr.FilterDictRule[systemType]
	local sortType = CardFilterMgr.FilterSortRule[systemType]
	local listCard = {}

	if withNotHold then
		listCard = RoleCardMgr:GetAllCard()
	else
		listCard = RoleCardMgr:GetAllHoldCard()
	end

	local list

	if table.getn(rule.Job) ~= 0 then
		list = {}

		local jobs = GetConfigArgJson("JobNumber")

		for k, v in pairsByKeys(rule.Job) do
			if v > 0 then
				table.insert(list, jobs[k] or "")
			end
		end

		if #list > 0 then
			listCard = CardFilterMgr:GetSameJobRoleCard(list, listCard)
		end
	end

	if table.getn(rule.Comb) ~= 0 then
		list = {}

		local listComb = CombinationMgr:GetCombinationSortByTeamOder()

		for k, v in pairsByKeys(rule.Comb) do
			if v > 0 then
				table.insert(list, listComb[k].id)
			end
		end

		if #list > 0 then
			listCard = CardFilterMgr:GetSameCombRoleCard(list, listCard)
		end
	end

	if table.getn(rule.Team) ~= 0 then
		list = {}

		local sameList = {}
		local teams = InfoTeam.stageTeams

		for k, v in pairsByKeys(rule.Team) do
			if v > 0 then
				local teamCardIds = teams[k].roleCardTeams

				for _, cardId in ipairs(teamCardIds) do
					if not table.contains(list, cardId) then
						table.insert(list, cardId)
					end
				end
			end
		end

		if #list > 0 then
			listCard = CardFilterMgr:GetSameTeamRoleCard(list, listCard)
		end
	end

	local listNewCard = {}

	if withNew and RoleCardMgr:PlayerHaveNewCard() then
		for n = #listCard, 1, -1 do
			if RoleCardMgr.IsNewCard(listCard[n].id) then
				table.insert(listNewCard, listCard[n])
				table.remove(listCard, n)
			end
		end
	end

	local propType = ePropType[4]

	for k, v in pairs(rule.Prop) do
		if v > 0 then
			propType = ePropType[k]
		end
	end

	CardSortMgr.CardFilterSort(propType, listCard)

	if systemType == eFilterSystemType.Develop then
		CardSortMgr.CardFilterSort(propType, listNewCard)
	end

	if sortType == eSortType.Asce then
		listCard = CardSortMgr.Lift(listCard)

		if systemType == eFilterSystemType.Develop then
			listNewCard = CardSortMgr.Lift(listNewCard)
		end
	end

	local listResult = TableConcat(listNewCard, listCard) or {}

	return listResult, rule
end

function CardFilterMgr.GetComnposeCards()
	local rule = CardFilterMgr.FilterSoulRule
	local listCard = {}

	listCard = RoleCardMgr:GetAllNotHoldCard()

	local list

	if table.getn(rule[1]) ~= 0 then
		list = {}

		local jobs = GetConfigArgJson("JobNumber")

		for k, v in pairsByKeys(rule[1]) do
			if v > 0 then
				table.insert(list, jobs[k] or "")
			end
		end

		if #list > 0 then
			listCard = CardFilterMgr:GetSameJobRoleCard(list, listCard)
		end
	end

	if table.getn(rule[2]) ~= 0 then
		list = {}

		local listComb = CombinationMgr:GetCombinationSortByTeamOder()

		for k, v in pairsByKeys(rule[2]) do
			if v > 0 then
				table.insert(list, listComb[k].id)
			end
		end

		if #list > 0 then
			listCard = CardFilterMgr:GetSameCombRoleCard(list, listCard)
		end
	end

	if table.getn(rule[3]) ~= 0 then
		list = {}

		local listHoldRole = RoleMgr:GetAllRole()

		for k, v in pairsByKeys(rule[3]) do
			if v > 0 then
				local roleId = listHoldRole[k].id

				table.insert(list, roleId)
			end
		end

		if #list > 0 then
			listCard = CardFilterMgr:GetCardByRole(list, listCard)
		end
	end

	local propType = ePropType[5]
	local sorterList = {
		"SOUL",
		"RANK"
	}

	CardSortMgr.Sort(sorterList, listCard)

	return listCard, rule
end

function CardFilterMgr.GetFilterRoleRuleNameList()
	local listJob = GetConfigArgJson("JobName")
	local listComb = CombinationMgr:GetCombinationSortByTeamOder()
	local teams = InfoTeam.stageTeams
	local listTeam = {}

	for i = 1, 5 do
		if teams[i].name ~= "" then
			table.insert(listTeam, teams[i].name)
		else
			table.insert(listTeam, _("PageBattleTeam_TeamNum") .. teams[i].id)
		end
	end

	local listName = {}

	for i = 1, #RoleMgr:GetAllRole() do
		table.insert(listName, RoleMgr:GetAllRole()[i]:GetName())
	end

	local jobName = {}
	local comName = {}

	for _, value in pairs(listJob) do
		table.insert(jobName, Lang(value))
	end

	for index, value in ipairs(listComb) do
		table.insert(comName, Lang(listComb[index].data.Name))
	end

	local list = {}

	list[1] = jobName
	list[2] = comName
	list[3] = listTeam
	list[4] = listName

	local rule = CardFilterMgr.FilterRoleListRule
	local name = ""
	local count = 0

	for i = 1, #rule do
		for j = 1, #rule[i] do
			if rule[i][j] ~= 0 then
				count = count + 1
				name = list[i][j]
			end
		end
	end

	if count == 1 then
		return name, count
	else
		return name, count
	end
end

function CardFilterMgr:GetSameJobRole(listJobName, listRole)
	local sameJobList = {}

	for _, role in ipairs(listRole) do
		if table.contains(listJobName, role.data.Job) then
			table.insert(sameJobList, role)
		end
	end

	return sameJobList
end

function CardFilterMgr:GetSameCombRole(listCombId, listRole)
	local sameCombList = {}

	for _, role in ipairs(listRole) do
		if table.contains(listCombId, role.data.Team) then
			table.insert(sameCombList, role)
		end
	end

	return sameCombList
end

function CardFilterMgr:GetSameTeamRole(listCardId, listRole)
	local sameTeamlist = {}

	for _, role in ipairs(listRole) do
		for _, cardId in ipairs(listCardId) do
			if cardId ~= 0 then
				local card = RoleCardMgr:GetRoleCard(cardId)

				if card and card.data.CharacterID == role.id then
					for k, infoRole in pairs(sameTeamlist) do
						if infoRole.id == role.id then
							table.remove(sameTeamlist, k)
						end
					end

					table.insert(sameTeamlist, role)
				end
			end
		end
	end

	return sameTeamlist
end

function CardFilterMgr:GetCardByRole(listCardId, listRole)
	local cardlist = {}

	for _, role in ipairs(listRole) do
		for _, cardId in ipairs(listCardId) do
			if cardId ~= 0 and cardId == role.data.CharacterID then
				table.insert(cardlist, role)
			end
		end
	end

	return cardlist
end

function CardFilterMgr:GetAllSameHoldRole(listHoldId, listRole)
	local list = {}

	for i = 1, #listRole do
		local infoRole = listRole[i]

		for j = 1, #listHoldId do
			local holdId = listHoldId[j]

			if holdId == infoRole.id then
				table.insert(list, listRole[i])
			end
		end
	end

	return list
end

function CardFilterMgr:GetFilterRoles(rule, sortType)
	sortType = sortType == 1 and 1 or 2

	local list
	local listRole = RoleMgr:GetAllHoldRoleSort(sortType)

	if rule then
		CardFilterMgr.FilterRoleListRule = rule
	else
		rule = CardFilterMgr.FilterRoleListRule
	end

	if not rule[1] then
		return listRole, rule
	end

	if table.getn(rule[1]) ~= 0 then
		list = {}

		local jobs = GetConfigArgJson("JobNumber")

		for k, v in pairsByKeys(rule[1]) do
			if v > 0 then
				local name = jobs[k]

				table.insert(list, name)
			end
		end

		if #list > 0 then
			listRole = CardFilterMgr:GetSameJobRole(list, listRole)
		end
	end

	if table.getn(rule[2]) ~= 0 then
		list = {}

		local listComb = CombinationMgr:GetCombinationSortByTeamOder()

		for k, v in pairsByKeys(rule[2]) do
			if v > 0 then
				local combId = listComb[k].data.ID

				table.insert(list, combId)
			end
		end

		if #list > 0 then
			listRole = CardFilterMgr:GetSameCombRole(list, listRole)
		end
	end

	if table.getn(rule[3]) ~= 0 then
		list = {}

		local sameList = {}
		local teams = InfoTeam.stageTeams

		for k, v in pairsByKeys(rule[3]) do
			if v > 0 then
				local teamCardIds = teams[k].roleCardTeams

				for _, cardId in ipairs(teamCardIds) do
					if not table.contains(list, cardId) then
						table.insert(list, cardId)
					end
				end
			end
		end

		if #list > 0 then
			listRole = CardFilterMgr:GetSameTeamRole(list, listRole)
		end
	end

	if table.getn(rule[4]) ~= 0 then
		list = {}

		local listHoldRole = RoleMgr:GetAllRole()

		for k, v in pairsByKeys(rule[4]) do
			if v > 0 then
				local roleId = listHoldRole[k].id

				table.insert(list, roleId)
			end
		end

		if #list > 0 then
			listRole = CardFilterMgr:GetAllSameHoldRole(list, listRole)
		end
	end

	return listRole, rule
end

CardSwitchMgr = {}
CardSwitchMgr.listCardId = {}

function CardSwitchMgr:Reset(listCardId)
	self:Clear()

	self.listCardId = listCardId
end

function CardSwitchMgr:Clear()
	self.listCardId = {}
end

function CardSwitchMgr:ResetCardIdsByRole(roleId)
	local cardIds = {}
	local listCard = RoleCardMgr:GetRoleHoldCard(roleId)

	CardSortMgr.CardFilterSort(CardSortMgr.SORT_TYPES.POWER, listCard)

	for _, v in pairs(listCard) do
		table.insert(cardIds, v.id)
	end

	self:Reset(cardIds)
end

eBattleTeamType = {
	BossRaid = 4,
	Comb = 2,
	Main = 1,
	Raid = 3,
	None = 5
}

function CardSwitchMgr:ResetCardIdsByTeam(teamType, extra)
	local teamIdx, team

	if teamType == eBattleTeamType.Main then
		teamIdx = RoleCardMgr:GetTeamListIndex()
		team = InfoTeam.stageTeams[teamIdx] or {}
	elseif teamType == eBattleTeamType.Comb then
		teamIdx = extra or 1
		team = InfoTeamgGroup.stageTeams[teamIdx] or {}
	elseif teamType == eBattleTeamType.Raid then
		teamIdx = 1
		team = InfoTeamRaid.stageTeams[teamIdx] or {}
	elseif teamType == eBattleTeamType.BossRaid then
		teamIdx = 1
		team = InfoTeamBossRaid.stageTeams[teamIdx] or {}
	elseif teamType == eBattleTeamType.None then
		team = {
			roleCardTeams = extra
		}
	end

	local cardIds = {}

	if team and team.roleCardTeams then
		for k, cardId in ipairs(team.roleCardTeams) do
			if k < 6 and cardId ~= 0 then
				table.insert(cardIds, cardId)
			end
		end
	end

	self:Reset(cardIds)
end

function CardSwitchMgr:ResetCardIdsByFilter(systemType)
	local cards = CardFilterMgr.GetFilterCards(systemType)
	local cardIds = {}

	for i = 1, #cards do
		table.insert(cardIds, cards[i].id)
	end

	self:Reset(cardIds)
end

function CardSwitchMgr:ResetCardIdsByBattle(cards)
	local cardIds = {}

	for i = 1, #cards do
		table.insert(cardIds, cards[i].id)
	end

	self:Reset(cardIds)
end

CardSortMgr = {}

local STR_SORT_TYPES = {
	"BASE",
	"LEVEL",
	"RANK",
	"STAR",
	"POWER",
	"SOUL"
}

CardSortMgr.SORT_TYPES = {
	RANK = "RANK",
	LEVEL = "LEVEL",
	POWER = "POWER",
	BASE = "BASE",
	STAR = "STAR",
	SOUL = "SOUL"
}

local function GetEmptyResult()
	return {
		greater = false,
		skip = false,
		equal = false
	}
end

local SORTERS = {}

function SORTERS.BASE(a, b)
	local result = GetEmptyResult()
	local va = a:GetCardHoldState()
	local vb = b:GetCardHoldState()

	if va == vb then
		if va == 0 and vb == 0 then
			result.skip = true
			result.greater = a.id > b.id
		end

		result.equal = true
	else
		result.greater = vb < va
	end

	return result
end

function SORTERS.LEVEL(a, b)
	local result = GetEmptyResult()

	if a.curLevel == b.curLevel then
		result.equal = true
	end

	result.greater = a.curLevel > b.curLevel

	return result
end

function SORTERS.RANK(a, b)
	local result = GetEmptyResult()

	if a.cardRank == b.cardRank then
		result.equal = true
	end

	result.greater = a.cardRank > b.cardRank

	return result
end

function SORTERS.STAR(a, b)
	local result = GetEmptyResult()

	if a.curStarLevel == b.curStarLevel then
		result.equal = true
	end

	result.greater = a.curStarLevel > b.curStarLevel

	return result
end

function SORTERS.POWER(a, b)
	local result = GetEmptyResult()
	local va = a.fightValue
	local vb = b.fightValue

	if va == vb then
		result.equal = true
	end

	result.greater = vb < va

	return result
end

function SORTERS.SOUL(a, b)
	local result = GetEmptyResult()

	if a.pb.soul == b.pb.soul then
		result.equal = true
	end

	result.greater = a.pb.soul > b.pb.soul

	return result
end

function CardSortMgr.BuildSorterList(prioritySorterName)
	local sorterList = {}

	for _, v in ipairs(STR_SORT_TYPES) do
		table.insert(sorterList, v)
	end

	local index = 1

	for k, v in ipairs(STR_SORT_TYPES) do
		if v == prioritySorterName then
			index = k

			break
		end
	end

	local temp = sorterList[2]

	sorterList[2] = sorterList[index]
	sorterList[index] = temp

	return sorterList
end

function CardSortMgr.BuildNotHoldSorterList(prioritySorterName)
	local sorterList = {}

	for _, v in ipairs(STR_SORT_TYPES) do
		table.insert(sorterList, v)
	end

	local index = 1

	for k, v in ipairs(STR_SORT_TYPES) do
		if v == prioritySorterName then
			index = k

			break
		end
	end

	local temp = sorterList[1]

	sorterList[1] = sorterList[index]
	sorterList[index] = temp

	return sorterList
end

function CardSortMgr.BuilderSpecificSorterList(...)
	local sortList = {}

	table.insert(sortList, CardSortMgr.SORT_TYPES.BASE)

	for _, v in ipairs({
		...
	}) do
		if type(v) == "string" then
			table.insert(sortList, v)
		end
	end

	return sortList
end

function CardSortMgr.Sort(sorterList, list)
	sorterList = sorterList or STR_SORT_TYPES

	local function funSort(a, b)
		local index = 1

		local function sort(a, b)
			local sorterName = sorterList[index]

			if sorterName and SORTERS[sorterName] then
				local result = SORTERS[sorterList[index]](a, b)

				if result.equal and not result.skip then
					index = index + 1

					return sort(a, b)
				else
					return result.greater
				end
			else
				return a.id > b.id
			end
		end

		return sort(a, b)
	end

	table.sort(list, funSort)
end

function CardSortMgr.Lift(listRoleCard, withNew)
	local function funReplace(t)
		local half = math.ceil(#t / 2)

		for i = 1, half do
			local temp = t[i]

			t[i] = t[#t - (i - 1)]
			t[#t - (i - 1)] = temp
		end
	end

	local tabHold = {}
	local tabNotHold = {}
	local tabNewHold = {}

	for _, card in ipairs(listRoleCard) do
		if card:IsHold() then
			if withNew and RoleCardMgr.IsNewCard(card.id) then
				table.insert(tabNewHold, card)
			else
				table.insert(tabHold, card)
			end
		else
			table.insert(tabNotHold, card)
		end
	end

	funReplace(tabHold)
	funReplace(tabNewHold)

	return TableConcat(tabNewHold, tabHold, tabNotHold)
end

function CardSortMgr.CardFilterSort(sorterName, listRoleCard)
	local sorterList = CardSortMgr.BuildSorterList(sorterName)

	CardSortMgr.Sort(sorterList, listRoleCard)
end

function CardSortMgr.CardOtherSort(...)
	local arg = {
		...
	}
	local listRoleCard = arg[#arg] or {}

	table.remove(arg)

	local sorterList = CardSortMgr.BuilderSpecificSorterList(unpack(arg))

	CardSortMgr.Sort(sorterList, listRoleCard)
end

function CardSortMgr:GetCompareBase(a, b)
	local result = {}

	result.isEqual = false
	result.isGreater = false

	local s1 = a:GetCardHoldState()
	local s2 = b:GetCardHoldState()

	if s1 == s2 then
		result.isEqual = true
	else
		result.isEqual = false
		result.isGreater = s2 < s1
	end

	return result
end

function CardSortMgr:GetCompareRank(a, b, style)
	local result = self:GetCompareBase(a, b)

	if result.isEqual then
		if style == 1 then
			return a.rank > b.rank
		else
			return a.rank < b.rank
		end
	else
		return result.isGreater
	end
end

function CardSortMgr:GetCompareRankAndLevel(a, b, style)
	local result = self:GetCompareBase(a, b)

	if result.isEqual then
		if a.rank == b.rank then
			if style == 1 then
				return a.curLevel > b.curLevel
			else
				return a.curLevel < b.curLevel
			end
		elseif style == 1 then
			return a.rank > b.rank
		else
			return a.rank < b.rank
		end
	else
		return result.isGreater
	end
end

function CardSortMgr:GetCompare1(a, b, style)
	if a.curLevel == b.curLevel then
		if RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(a.id), a) == RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(b.id), b) then
			if a.rank == b.rank then
				if style == 1 then
					if a.curStarLevel == b.curStarLevel then
						return a.id > b.id
					else
						return a.curStarLevel > b.curStarLevel
					end
				elseif a.curStarLevel == b.curStarLevel then
					return a.id < b.id
				else
					return a.curStarLevel < b.curStarLevel
				end
			elseif style == 1 then
				return a.rank > b.rank
			else
				return a.rank < b.rank
			end
		elseif style == 1 then
			return RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(a.id), a) > RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(b.id), b)
		else
			return RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(a.id), a) < RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(b.id), b)
		end
	elseif style == 1 then
		return a.curLevel > b.curLevel
	else
		return a.curLevel < b.curLevel
	end
end

function CardSortMgr:GetCompare2(a, b, style)
	if a.rank == b.rank then
		if RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(a.id), a) == RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(b.id), b) then
			if a.curLevel == b.curLevel then
				if style == 1 then
					if a.curStarLevel == b.curStarLevel then
						return a.id > b.id
					else
						return a.curStarLevel > b.curStarLevel
					end
				elseif a.curStarLevel == b.curStarLevel then
					return a.id < b.id
				else
					return a.curStarLevel < b.curStarLevel
				end
			elseif style == 1 then
				return a.curLevel > b.curLevel
			else
				return a.curLevel < b.curLevel
			end
		elseif style == 1 then
			return RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(a.id), a) > RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(b.id), b)
		else
			return RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(a.id), a) < RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(b.id), b)
		end
	elseif style == 1 then
		return a.rank > b.rank
	else
		return a.rank < b.rank
	end
end

function CardSortMgr:GetCompare3(a, b, style)
	if a.curStarLevel == b.curStarLevel then
		if RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(a.id), a) == RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(b.id), b) then
			if a.curLevel == b.curLevel then
				if style == 1 then
					if a.rank == b.rank then
						return a.id > b.id
					else
						return a.rank > b.rank
					end
				elseif a.rank == b.rank then
					return a.id < b.id
				else
					return a.rank < b.rank
				end
			elseif style == 1 then
				return a.curLevel > b.curLevel
			else
				return a.curLevel < b.curLevel
			end
		elseif style == 1 then
			return RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(a.id), a) > RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(b.id), b)
		else
			return RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(a.id), a) < RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(b.id), b)
		end
	elseif style == 1 then
		return a.curStarLevel > b.curStarLevel
	else
		return a.curStarLevel < b.curStarLevel
	end
end

function CardSortMgr:GetCompare4(a, b, style)
	if RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(a.id), a) == RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(b.id), b) then
		if a.curLevel == b.curLevel then
			if style == 1 then
				return a.rank > b.rank
			else
				return a.rank < b.rank
			end
		elseif style == 1 then
			return a.curLevel > b.curLevel
		else
			return a.curLevel < b.curLevel
		end
	elseif style == 1 then
		return RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(a.id), a) > RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(b.id), b)
	else
		return RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(a.id), a) < RoleCardMgr:GetFightValue(RoleCardMgr:GetRole(b.id), b)
	end
end

CardExtraMgr = {}
eEnterType = {
	cardMain = 1,
	cardCompose = 4,
	cardShow = 3,
	cardPass = 2
}
CardExtraMgr.enterType = eEnterType.cardMain
CardExtraMgr.tabIndex = 0

local lastCardViewPosY = 0
local lastCardStagePosX = 0

CardExtraMgr.LastCardStageCardId = 0
CardExtraMgr.uiTabType = 2
CardExtraMgr.detailsLookInfo = true

function CardExtraMgr:SetEnterType(_type)
	self.enterType = _type
end

function CardExtraMgr:ResetCardViewPosY()
	lastCardViewPosY = 0
end

function CardExtraMgr:SetCardViewPosY(posY)
	lastCardViewPosY = posY
end

function CardExtraMgr:GetCardViewPosY()
	return lastCardViewPosY
end

function CardExtraMgr:SetCardStagePosX(posX)
	lastCardStagePosX = posX
end

function CardExtraMgr:GetCardStagePosX()
	return lastCardStagePosX
end
