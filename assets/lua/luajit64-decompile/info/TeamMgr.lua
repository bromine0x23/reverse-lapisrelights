-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/TeamMgr.lua

local teamData = require("luaData/CharacterTeam")

eTeamColor = {
	"#F7A2AD",
	"#96C9FF",
	"#D6BEEA",
	"#A1DAAD",
	"#FEC998",
	"#FDB5CF",
	"#D3EBD3"
}
TeamMgr = class("TeamMgr")

function TeamMgr:ctor()
	self.unLockTeamIdx = #teamData
	self.teamIndex = 1
	self.curTeamIndex = 1
	self.curRoleIndex = 1
	self.teamCnt = table.getn(teamData)
end

function TeamMgr:GetTeamData(id)
	if not teamData[id] then
		return teamData[1]
	end

	return teamData[id]
end

function TeamMgr:GetTeamList()
	local teamList = {}

	for i = 1, #teamData do
		teamList[teamData[i].TeamOrder] = teamData[i]
	end

	return teamList
end

function TeamMgr:IsGet(teamId)
	return TeamChapterMgr:TeamChapterIsUnLock(teamId)
end

function TeamMgr:GetRoleIdAndRole(teamID, roleIdx)
	local listRoleId = teamData[teamID].MemberList
	local roleId = listRoleId[roleIdx]
	local infoRole = RoleMgr:GetRole(roleId)

	return roleId, infoRole
end

function TeamMgr:GetInfoRoleList(teamID)
	local listRoleId = teamData[teamID].MemberList
	local list = {}

	for i, v in ipairs(listRoleId) do
		local roleId = v
		local infoRole = RoleMgr:GetRole(roleId)

		table.insert(list, infoRole)
	end

	table.sort(list, function(a, b)
		return a.data.StandOrder < b.data.StandOrder
	end)

	return list
end

function TeamMgr:GetTeamIdxAndRoleIdx(roleId)
	for k, v in pairs(teamData) do
		local listRoleId = v.MemberList

		for i = 1, #listRoleId do
			if roleId == listRoleId[i] then
				return k, i
			end
		end
	end

	return 0, 0
end

function TeamMgr:GetTeamIndex()
	return self.curTeamIndex
end

function TeamMgr:SetTeamIndex(index)
	self.curTeamIndex = index
end

TeamMgr.Instance = TeamMgr.Instance or TeamMgr()
