-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/DlgCharacterThin/CharacterThinMgr.lua

local InfoTeam = require("Info/InfoTeam")
local InfoTeamComb = require("Info/InfoTeamgGroup")
local InfoTeamRaid = require("Info/InfoTeamRaid")
local InfoTeamBossRaid = require("Info/InfoTeamBossRaid")
local InfoTeamPVP = require("Info/InfoPVP")

THIN_SYSTEM_TYPE = {
	Card = "Card",
	Role = "Role"
}
THIN_PAGE_TYPE = {
	Role = 1,
	Equip = 2,
	Fitting = 4,
	Interac = 3
}
THIN_FILTER_NUM_TYPE = {
	All = 1,
	Comb = 2,
	Union_Team = 6,
	Job = 3,
	Main_Team = 4,
	PVP_Team = 7,
	Comb_Team = 5
}
THIN_FILTER_STR_TYPE = {
	"All",
	"Comb",
	"Job",
	"Main_Team",
	"Comb_Team",
	"Union_Team",
	"PVP_Team"
}
THIN_FILTER_SHOW_TYPE = {
	All = 1,
	Comb = 1,
	Union_Team = 0,
	Job = 1,
	Main_Team = 1,
	PVP_Team = 0,
	Comb_Team = 0
}

function GetThinShowClauses()
	local t = {}

	for _, v in ipairs(THIN_FILTER_STR_TYPE) do
		if THIN_FILTER_SHOW_TYPE[v] == 1 and THIN_FILTER_NUM_TYPE[v] then
			table.insert(t, THIN_FILTER_NUM_TYPE[v])
		end
	end

	return t
end

function GetThinClauseWord(_clause)
	if _clause == THIN_FILTER_NUM_TYPE.All then
		return Lang(5000031)
	elseif _clause == THIN_FILTER_NUM_TYPE.Comb then
		return Lang(5000022)
	elseif _clause == THIN_FILTER_NUM_TYPE.Job then
		return Lang(5000021)
	elseif _clause == THIN_FILTER_NUM_TYPE.Main_Team then
		return Lang(12079)
	elseif _clause == THIN_FILTER_NUM_TYPE.Comb_Team then
		return "チーム編成"
	elseif _clause == THIN_FILTER_NUM_TYPE.Union_Team then
		return "幻境チーム"
	elseif _clause == THIN_FILTER_NUM_TYPE.PVP_Team then
		return "PVP"
	end

	return Lang(5000031)
end

function GetThinSubclauses(_clause)
	local tbl = {}

	if _clause == THIN_FILTER_NUM_TYPE.Comb then
		tbl = CombinationMgr:GetCombinationSortByTeamOder()
	elseif _clause == THIN_FILTER_NUM_TYPE.Job then
		for k, v in pairs(eJobType) do
			table.insert(tbl, {
				k,
				v
			})
		end

		table.sort(tbl, function(a, b)
			return a[2] < b[2]
		end)
	elseif _clause == THIN_FILTER_NUM_TYPE.Main_Team then
		for k, v in ipairs(InfoTeam.stageTeams) do
			if k <= InfoTeam.teamCnt then
				for _, n in ipairs(v.roleCardTeams) do
					if n ~= 0 then
						table.insert(tbl, {
							k,
							v.name
						})

						break
					end
				end
			end
		end
	elseif _clause == THIN_FILTER_NUM_TYPE.Comb_Team then
		for k, v in ipairs(InfoTeamComb.stageTeams) do
			for _, n in ipairs(v.roleCardTeams) do
				if n ~= 0 then
					local name = CombinationMgr:Get(k):GetName()

					table.insert(tbl, {
						k,
						name
					})

					break
				end
			end
		end
	elseif _clause == THIN_FILTER_NUM_TYPE.Union_Team then
		for i = 1, 2 do
			local name

			if i == 1 then
				name = "ノーマル幻境"

				table.insert(tbl, {
					i,
					name
				})
			else
				name = "ボス幻境"

				table.insert(tbl, {
					i,
					name
				})
			end
		end
	elseif _clause == THIN_FILTER_NUM_TYPE.PVP_Team then
		local name = "進攻チーム"

		if InfoTeamPVP.attackingRoleCards then
			for k, v in pairs(InfoTeamPVP.attackingRoleCards) do
				if k <= 5 and v.id ~= 0 then
					table.insert(tbl, {
						1,
						name
					})

					break
				end
			end
		end

		name = "防御チーム"

		if InfoTeamPVP.defensiveRoleCards then
			for k, v in pairs(InfoTeamPVP.defensiveRoleCards) do
				if k <= 5 and v.id ~= 0 then
					table.insert(tbl, {
						2,
						name
					})

					break
				end
			end
		end
	end

	return tbl
end

CharacterThinMgr = CharacterThinMgr or {}
CharacterThinMgr.roleID = -1
CharacterThinMgr.needReset = false

local KEY_THIN = {
	Card = "KEY_THIN_CARD_SYSTEM",
	Role = "KEY_THIN_ROLE_SYSTEM"
}
local Last_Rule = {
	Card = {},
	Role = {}
}
local Last_Data = {
	Card = {},
	Role = {}
}
local Switch_Data = {
	Card = {},
	Role = {}
}

local function DefaultSelId()
	return 105
end

local function DefaultRule()
	return THIN_FILTER_NUM_TYPE.All, 0
end

function CharacterThinMgr.LastRule(_thin_system)
	return Last_Rule[_thin_system]
end

function CharacterThinMgr.LastData(_thin_system)
	return Last_Data[_thin_system]
end

function CharacterThinMgr.SwitchData(_thin_system)
	return Switch_Data[_thin_system]
end

function CharacterThinMgr.CurSwitchRole(_thin_system)
	_thin_system = _thin_system or THIN_SYSTEM_TYPE.Role

	local data = Switch_Data[_thin_system]
	local lastData = Last_Data[_thin_system]

	if lastData and data.idx <= #lastData.roles then
		return lastData.roles[data.idx].id
	end

	return DefaultSelId()
end

local function ResetRule(_thin_system, _clause, _subclause)
	local clause, subclause = DefaultRule()

	Last_Rule[_thin_system].clause = _clause or clause
	Last_Rule[_thin_system].subclause = _subclause or subclause
end

local function SetDataRoles(_thin_system)
	local clause, subclause = Last_Rule[_thin_system].clause, Last_Rule[_thin_system].subclause

	Last_Data[_thin_system].roles = CharacterThinMgr.GetRolesByRule(clause, subclause)
end

local function SetDataSelID(_thin_system, _id)
	if _id == nil then
		if not Last_Data[_thin_system].roles then
			return
		end

		local role = Last_Data[_thin_system].roles[1]

		if role == nil then
			return
		end

		_id = role.id
	end

	Last_Data[_thin_system].id = _id
end

local function ResetData(_thin_system, _id)
	SetDataRoles(_thin_system)
	SetDataSelID(_thin_system, _id)
end

local function SetSwitchRoles(_thin_system)
	Switch_Data[_thin_system].roles = {}

	if Last_Data[_thin_system] and Last_Data[_thin_system].roles then
		for _, role in ipairs(Last_Data[_thin_system].roles) do
			if role.hold then
				table.insert(Switch_Data[_thin_system].roles, role)
			end
		end
	end
end

local function SetSwitchIndex(_thin_system, _idx)
	if _idx == nil then
		for k, v in ipairs(Switch_Data[_thin_system].roles) do
			if Last_Data[_thin_system].id == v.id then
				_idx = k

				break
			end
		end
	end

	Switch_Data[_thin_system].idx = _idx or 1
end

local function ResetSwitchData(_thin_system, _idx)
	SetSwitchRoles(_thin_system)
	SetSwitchIndex(_thin_system, _idx)
end

function CharacterThinMgr.Init(_thin_system)
	ResetRule(_thin_system)
	ResetData(_thin_system)
	ResetSwitchData(_thin_system)
end

function CharacterThinMgr.ResetInterface(_thin_system, _clause, _subclause, _id, _idx, _resort)
	if not _resort then
		if _clause and _subclause and (Last_Rule[_thin_system].clause ~= _clause or Last_Rule[_thin_system].subclause ~= _subclause) then
			ResetRule(_thin_system, _clause, _subclause)
			ResetData(_thin_system, _id)
			ResetSwitchData(_thin_system, _idx)
		elseif _id ~= nil then
			SetDataSelID(_thin_system, _id)
			SetSwitchIndex(_thin_system, _idx)
		elseif _idx ~= nil then
			SetSwitchIndex(_thin_system, _idx)
			SetDataSelID(_thin_system, Switch_Data[_thin_system].roles[_idx].id)
		else
			SetDataRoles(_thin_system)
			ResetSwitchData(_thin_system)
		end
	else
		if CharacterThinMgr.IsTempData then
			return
		end

		SetDataRoles(_thin_system)
		ResetSwitchData(_thin_system)
	end
end

function CharacterThinMgr.DOSwitch(_thin_system, _dir_type)
	local idx = Switch_Data[_thin_system].idx
	local roles = Switch_Data[_thin_system].roles

	if _dir_type == eDirectionType.R then
		idx = TenaryOp(idx + 1 > #roles, 1, idx + 1)
	else
		idx = TenaryOp(idx - 1 < 1, #roles, idx - 1)
	end

	CharacterThinMgr.ResetInterface(_thin_system, nil, nil, nil, idx)
	Event.Instance:Fire("UpdateShowCharacter", roles[idx])
end

function CharacterThinMgr.SortRoles(_roles)
	_roles = _roles or {}

	local notHoldRole = {}

	for i = #_roles, 1, -1 do
		if not _roles[i].hold then
			table.insert(notHoldRole, _roles[i])
			table.remove(_roles, i)
		end
	end

	table.sort(notHoldRole, function(a, b)
		return a.id < b.id
	end)

	local fightValue = {}

	table.sort(_roles, function(a, b)
		local aValue, bValue

		if fightValue[a.id] ~= nil then
			aValue = fightValue[a.id]
		else
			aValue = RoleCardMgr:GetFightValue(a, RoleCardMgr:GetRoleCard(a.pb.roleCardId))
			fightValue[a.id] = aValue
		end

		if fightValue[b.id] ~= nil then
			bValue = fightValue[b.id]
		else
			bValue = RoleCardMgr:GetFightValue(b, RoleCardMgr:GetRoleCard(b.pb.roleCardId))
			fightValue[b.id] = bValue
		end

		if aValue == bValue then
			return a.id < b.id
		else
			return bValue < aValue
		end
	end)

	for _, v in ipairs(notHoldRole) do
		table.insert(_roles, v)
	end
end

function CharacterThinMgr.GetRolesByRule(_clause, _subclause)
	local allRole = RoleMgr:GetAllRole()
	local tmp = {}
	local needSort = true

	if _clause == THIN_FILTER_NUM_TYPE.All then
		tmp = allRole
	elseif _clause == THIN_FILTER_NUM_TYPE.Comb then
		local listComb = CombinationMgr:GetCombinationSortByTeamOder()

		needSort = false

		for k, MemberID in pairsByKeys(listComb[_subclause].data.MemberList) do
			for k2, infoRole in pairsByKeys(allRole) do
				if infoRole.data.ID == MemberID then
					table.insert(tmp, infoRole)

					break
				end
			end
		end

		table.sort(tmp, function(a, b)
			return a.data.StandOrder < b.data.StandOrder
		end)
	elseif _clause == THIN_FILTER_NUM_TYPE.Job then
		for _, v in ipairs(allRole) do
			if v.job == _subclause then
				table.insert(tmp, v)
			end
		end
	else
		local function GetCard(teamCardIds)
			for i = 1, 5 do
				if teamCardIds[i] and teamCardIds[i] ~= 0 then
					local infoRole = RoleCardMgr:GetRole(teamCardIds[i])

					if infoRole ~= nil then
						table.insert(tmp, infoRole)
					end
				end
			end
		end

		local subclauses = GetThinSubclauses(_clause)
		local temp = subclauses[_subclause]

		if not temp then
			return
		end

		if _clause == THIN_FILTER_NUM_TYPE.Main_Team then
			local team = InfoTeam.stageTeams[temp[1]].roleCardTeams

			GetCard(team)
		elseif _clause == THIN_FILTER_NUM_TYPE.Comb_Team then
			local team = InfoTeamComb.stageTeams[temp[1]].roleCardTeams

			GetCard(team)
		elseif _clause == THIN_FILTER_NUM_TYPE.Union_Team then
			local team

			if temp[1] == 1 then
				team = InfoTeamRaid.stageTeams[1].roleCardTeams
			else
				team = InfoTeamBossRaid.stageTeams[1].roleCardTeams
			end

			GetCard(team)
		elseif _clause == THIN_FILTER_NUM_TYPE.PVP_Team then
			local team = {}

			if temp[1] == 1 then
				for _, v in ipairs(InfoTeamPVP.attackingRoleCards) do
					if v.id ~= 0 then
						table.insert(team, v.id)
					end
				end
			else
				for _, v in ipairs(InfoTeamPVP.defensiveRoleCards) do
					if v.id ~= 0 then
						table.insert(team, v.id)
					end
				end
			end
		end

		needSort = false
	end

	if needSort then
		CharacterThinMgr.SortRoles(tmp)
	end

	return tmp
end

CharacterThinMgr.ResetType = {
	STAGE = "STAGE",
	SKIP = "SKIP",
	TEAM = "TEAM"
}

function CharacterThinMgr.DoResetOperate(_rType, _extra)
	if _rType == CharacterThinMgr.ResetType.SKIP then
		CharacterThinMgr.ResetInterface(THIN_SYSTEM_TYPE.Role, THIN_FILTER_NUM_TYPE.All, 0, _extra)

		return
	elseif _rType == CharacterThinMgr.ResetType.STAGE then
		local infoStage = ChapterMgr:GetStage(_extra)
		local stype = infoStage.data.Type
		local ctype = infoStage.data.ChapterType

		if ctype == ChapterFromType.comb then
			if not InfoTeamComb.teamSystemAgent then
				InfoTeamComb:EnterStage(infoStage)
			end

			local subclause = InfoTeamComb.teamSystemAgent.teamIndex

			roles = CharacterThinMgr.GetRolesByRule(THIN_FILTER_NUM_TYPE.Comb_Team, subclause)

			CharacterThinMgr.TempResetData(THIN_SYSTEM_TYPE.Role, roles, roles[1].id)
		elseif ctype == ChapterFromType.union then
			local roles = {}

			if stype == StageFromType.unionCommon then
				if not InfoTeamRaid.teamSystemAgent then
					InfoTeamRaid:EnterStage(infoStage)
				end

				roles = CharacterThinMgr.GetRolesByRule(THIN_FILTER_NUM_TYPE.Union_Team, 1)
			else
				if not InfoTeamBossRaid.teamSystemAgent then
					InfoTeamBossRaid:EnterStage(infoStage)
				end

				roles = CharacterThinMgr.GetRolesByRule(THIN_FILTER_NUM_TYPE.Union_Team, 2)
			end

			CharacterThinMgr.TempResetData(THIN_SYSTEM_TYPE.Role, roles, roles[1].id)
		else
			if not InfoTeam.teamSystemAgent then
				InfoTeam:EnterStage(infoStage)
			end

			local clause = THIN_FILTER_NUM_TYPE.Main_Team
			local subclause = InfoTeam.teamSystemAgent.teamIndex

			CharacterThinMgr.ResetInterface(THIN_SYSTEM_TYPE.Role, clause, subclause)
		end

		return
	elseif _rType == CharacterThinMgr.ResetType.TEAM then
		CharacterThinMgr.ResetInterface(THIN_SYSTEM_TYPE.Role, _extra.filter, _extra.option, _extra.roleId)

		return
	end

	CharacterThinMgr.ResetInterface(THIN_SYSTEM_TYPE.Role, THIN_FILTER_NUM_TYPE.All, 0)
end

CharacterThinMgr.IsTempData = false

function CharacterThinMgr.TempResetData(_thin_system, _roles, _id)
	if _roles and #_roles > 0 then
		Last_Data[_thin_system].roles = _roles
		Last_Data[_thin_system].id = _id

		ResetSwitchData(_thin_system)
	end

	CharacterThinMgr.IsTempData = true
end

function CharacterThinMgr.TempResetPreData(_thin_system, _id)
	ResetData(_thin_system, _id)
	ResetSwitchData(_thin_system)

	CharacterThinMgr.IsTempData = false
end

return CharacterThinMgr
