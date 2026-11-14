-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoUnion.lua

require("Info.gvg.InfoGvg")

local unionTypeData = require("luaData/ClubType")
local unionJobData = require("luaData/ClubJob")
local unionPermissionData = require("luaData/ClubPermission")

InfoUnion = class("InfoUnion", InfoBase)

function InfoUnion:ctor(pb)
	self.id = pb.id
	self.pb = {}
	self.curLevel = 1
	self.maxLevel = GetConfigArgInt("ClubMaxLevel")
	self.curLiveness = 0
	self.nextLiveness = 0
	self.joinType = 1
	self.joinLevel = 0
	self.notice = ""
	self.curMemberNum = 0
	self.maxMemberNum = 0
	self.applys = {}
	self.members = {}

	self:SetData(pb)
end

function InfoUnion:SetData(pb)
	if not pb or pb.id == 0 then
		return
	end

	self.pb.type = pb.type
	self.pb.name = pb.name
	self.pb.liveness = pb.liveness
	self.pb.notice = pb.notice
	self.pb.coin = pb.coin
	self.pb.owner = pb.owner
	self.pb.ownerName = pb.ownerName
	self.curLevel = pb.level
	self.joinType = pb.joinType
	self.joinLevel = pb.joinLevel
	self.notice = pb.notice
	self.applys = pb.applys
	self.members = pb.members

	self:UpdateAll()
end

function InfoUnion:UpdateAll()
	self.curMemberNum = table.getn(self.members)
	self.maxMemberNum = LevelManager:GetClubLevelMaxMembers(self.curLevel)

	local data = self:UpdateLiveness(self.pb.liveness)

	self.curLiveness = data.curLiveness
	self.nextLiveness = data.nextLiveness
end

function InfoUnion:UpdateLiveness(liveness)
	local data = {}

	if self.curLevel >= self.maxLevel then
		data.curLiveness = LevelManager:GetClubNeedLiveness(self.curLevel - 1)
		data.nextLiveness = data.curLiveness
	else
		local curLiveness = liveness - LevelManager:GetClubLiveness(self.curLevel - 1)

		data.curLiveness = curLiveness
		data.nextLiveness = LevelManager:GetClubNeedLiveness(self.curLevel)
	end

	return data
end

function InfoUnion:ChangeUnionLiveness(changeValue)
	self.pb.liveness = self.pb.liveness + changeValue

	self:UpdateAll()
end

function InfoUnion:ChangeCoin(v)
	self.pb.coin = self.pb.coin + v
end

function InfoUnion:GetName()
	return self.pb.name
end

function InfoUnion:GetNotice()
	if self.notice == "" then
		return Lang(1)
	end

	return self.notice
end

function InfoUnion:ChangeOwnerName(owerName)
	self.pb.ownerName = owerName
end

function InfoUnion:GetOwnerName()
	return self.pb.ownerName
end

function InfoUnion:ChangeJoinType(changeType)
	self.joinType = changeType
end

function InfoUnion:ChangeJoinLevel(changeLv)
	self.joinLevel = changeLv
end

function InfoUnion:ChangeNotice(strNotice)
	self.notice = strNotice
end

function InfoUnion:IsAuto()
	return self.joinType == 2
end

function InfoUnion:IsClose()
	return self.joinType == 3
end

function InfoUnion:AddMember(member)
	for i = 1, #self.members do
		if self.members[i].playerId == member.playerId then
			return
		end
	end

	table.insert(self.members, member)
	self:UpdateAll()
end

function InfoUnion:RemoveMember(memberId)
	for i = 1, #self.members do
		if self.members[i].playerId == memberId then
			table.remove(self.members, i)

			break
		end
	end

	self:UpdateAll()
end

function InfoUnion:HaveApplied(playerId)
	for i = 1, #self.applys do
		if self.applys[i] == playerId then
			return true
		end
	end

	return false
end

function InfoUnion:AddApply(applyId)
	for _, v in ipairs(self.applys) do
		if applyId == v then
			return
		end
	end

	table.insert(self.applys, applyId)
end

function InfoUnion:RemoveApply(applyId)
	for k, v in ipairs(self.applys) do
		if applyId == v then
			table.remove(self.applys, k)
		end
	end
end

function InfoUnion:HaveMember(memberId)
	for i = 1, #self.members do
		if self.members[i].playerId == memberId then
			return true
		end
	end

	return false
end

function InfoUnion:GetMemberJob(memberId)
	for i = 1, #self.members do
		if self.members[i].playerId == memberId then
			return self.members[i].jobId
		end
	end

	return UnionJobType.intern
end

UnionMgr = {}
UnionMgr.releUnion = nil
UnionMgr.UNION_EXIST = false
UnionOperateType = {
	agree = 1,
	tranUnion = 4,
	upLevel = 8,
	kick = 3,
	disband = 6,
	recruit = 0,
	transfer = 5,
	refuse = 2,
	keep = 7
}
UnionJoinType = {
	auto = 2,
	manual = 1,
	close = 3
}

function UnionMgr.InitUnion(pbUnion)
	UnionMgr:SetData(pbUnion)
	UnionRaidMgr.InitRaid()
end

function UnionMgr.HasUnion(needMsg)
	if not UnionMgr.UNION_EXIST then
		if needMsg then
			UIMgr.ShowMsg(_("Desc_Union_None_Temp"))
		end

		return false
	end

	return true
end

function UnionMgr:SetData(pbUnion)
	if not pbUnion or pbUnion.id == 0 then
		return
	end

	if not self.UNION_EXIST then
		self:ClearData()
	end

	self.releUnion = InfoUnion(pbUnion)

	UnionRaidMgr.SetOpenTime(pbUnion.clubMirrorOpenTime)

	if not self.UNION_EXIST then
		self.UNION_EXIST = true

		UnionRDL.Init()
		UnionRDL.ResetRDAfterJoinUnion()
	end
end

function UnionMgr:QuitUnion()
	self.UNION_EXIST = false

	UnionRDL.ResetRDAfterLeaveUnion()
end

function UnionMgr:DisbandUnion()
	self.UNION_EXIST = false

	UnionRDL.ResetRDAfterLeaveUnion()
end

function UnionMgr:KickedUnion()
	self.UNION_EXIST = false

	UnionRDL.ResetRDAfterLeaveUnion()
end

function UnionMgr:TranUnion(pbUnion)
	if self.releUnion then
		self.releUnion:SetData(pbUnion)
	end
end

function UnionMgr:ChangeJoinType(changeType)
	if self.releUnion then
		self.releUnion:ChangeJoinType(changeType)
	end
end

function UnionMgr:ChangeJoinLevel(changeLv)
	if self.releUnion then
		self.releUnion:ChangeJoinLevel(changeLv)
	end
end

function UnionMgr:ChangeNotice(notice)
	if self.releUnion then
		self.releUnion:ChangeNotice(notice)
	end
end

function UnionMgr:UpdateLevel()
	if self.releUnion then
		self.releUnion:UpdateAll()
	end
end

function UnionMgr:ChangeCoin(changeV)
	if self.releUnion then
		self.releUnion.pb.coin = self.releUnion.pb.coin - changeV
	end
end

function UnionMgr:SetCoin(val)
	if self.releUnion then
		self.releUnion.pb.coin = val
	end
end

function UnionMgr:AddMember(member)
	if self.releUnion then
		self.releUnion:AddMember(member)
	end
end

function UnionMgr:RemoveMember(memberId)
	if self.releUnion then
		self.releUnion:RemoveMember(memberId)
	end
end

function UnionMgr:ClearData()
	UnionLogMgr:ClearLog()
	UnionMemberMgr:ClearMember()
end

UnionTypeMgr = {}

function UnionTypeMgr:GetAllTypeData()
	local listTypeData = {}
	local temp = {}

	for _, v in pairsByKeys(unionTypeData) do
		local groupId = v.GroupId
		local isHave = false

		for i = 1, #temp do
			if temp[i] == groupId then
				isHave = true
			end
		end

		if not isHave then
			for _, n in pairsByKeys(unionTypeData) do
				if groupId == n.GroupId then
					table.insert(listTypeData, n)
				end
			end

			table.insert(temp, groupId)
		end
	end

	return listTypeData
end

function UnionTypeMgr:GetUnionTypData(typeId)
	local data = unionTypeData[typeId]

	if not data then
		return unionTypeData[1]
	end

	return data
end

function UnionTypeMgr:GetUnionTypeCharacter(typeId)
	return self:GetUnionTypData(typeId).CharacterId
end

function UnionTypeMgr:GetUnionTypeRole(typeId)
	local roleId = self:GetUnionTypData(typeId).CharacterId

	return RoleMgr:GetRole(roleId)
end

function UnionTypeMgr:GetUnionTypeAvatarPath(typeId)
	local infoRole = self:GetUnionTypeRole(typeId)

	return infoRole.actorData.CharacterIcon
end

function UnionTypeMgr:GetUnionTypeName(typeId)
	local infoRole = self:GetUnionTypeRole(typeId)

	return Lang(infoRole.data.Name)
end

function UnionTypeMgr:GetUnionTypeBgIcon(typeId)
	return self:GetUnionTypData(typeId).GroupBG
end

function UnionTypeMgr:GetUnionTypeBg(typeId)
	return self:GetUnionTypData(typeId).GroupBG2
end

UnionListMgr = {}
UnionListMgr.lastPullTime = 0
UnionListMgr.listUnion = {}
UnionListMgr.listSearchUnion = {}
UnionListMgr.UnionListType = {
	Common = 1,
	Search = 2
}

function UnionListMgr:SetUnionList(pbUnions, _type)
	self:ClearUnionList(_type)

	for i = 1, #pbUnions do
		local pbUnion = pbUnions[i]
		local infoUnion = InfoUnion(pbUnion)

		if _type == self.UnionListType.Common then
			table.insert(self.listUnion, infoUnion)
		else
			table.insert(self.listSearchUnion, infoUnion)
		end
	end
end

function UnionListMgr:CoverUnionList(pbUnions, _type)
	local function Cover(list)
		for _, v in ipairs(list) do
			for _, pbUnion in ipairs(pbUnions) do
				if v.id == pbUnion.id then
					v:SetData(pbUnion)
				end
			end
		end
	end

	if _type == self.UnionListType.Common then
		Cover(self.listUnion)
	else
		Cover(self.listSearchUnion)

		for _, pbUnion in ipairs(pbUnions) do
			for _, union in ipairs(self.listUnion) do
				if pbUnion.id == union.id then
					union:SetData(pbUnion)
				end
			end
		end
	end
end

function UnionListMgr:ClearUnionList(_type)
	if _type == 1 then
		self.listUnion = {}
	else
		self.listSearchUnion = {}
	end
end

function UnionListMgr:SetLastPullTime()
	self.lastPullTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
end

function UnionListMgr:IsCanPullUnions()
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local disSecond = curServerTime - self.lastPullTime

	if disSecond >= 60 then
		return true
	end

	return false, math.floor(60 - disSecond + 0.5)
end

UnionMemberMgr = {}
UnionMemberMgr.listMember = {}

function UnionMemberMgr:GetMember(memberId)
	for _, v in pairs(self.listMember) do
		if v.pid == memberId then
			return v
		end
	end

	return nil
end

function UnionMemberMgr:SetData(pbMembers)
	self.listMember = {}

	for _, v in ipairs(pbMembers) do
		local info = InfoPlayer()

		info:SetData(v)
		table.insert(self.listMember, info)
	end

	self:SetMemberExtraData()
end

function UnionMemberMgr:SetMemberExtraData()
	for _, v in pairs(self.listMember) do
		for _, n in pairs(UnionMgr.releUnion.members) do
			if v.pid == n.playerId then
				v.jobId = n.jobId or UnionJobType.intern
				v.liveness = n.liveness or 0
			end
		end
	end
end

function UnionMemberMgr:ResetMembers()
	local isExist

	for i = #self.listMember, 1, -1 do
		isExist = false

		for _, n in pairs(UnionMgr.releUnion.members) do
			if self.listMember[i].pid == n.playerId then
				isExist = true

				break
			end
		end

		if not isExist then
			table.remove(self.listMember, i)
		end
	end
end

function UnionMemberMgr:AddMember(pbMember)
	for i = 1, #self.listMember do
		if self.listMember[i].pid == pbMember.pid then
			return
		end
	end

	table.insert(self.listMember, pbMember)
end

function UnionMemberMgr:ClearMember()
	self.listMember = {}
end

function UnionMemberMgr:KickMember(memberId)
	for i = #self.listMember, 1, -1 do
		if self.listMember[i].pid == memberId then
			table.remove(self.listMember, i)
		end
	end

	UnionMgr:RemoveMember(memberId)
end

function UnionMemberMgr:GetMemberJob(memberId)
	local members = UnionMgr.releUnion.members

	for _, v in ipairs(members) do
		if v.playerId == memberId then
			return v.jobId
		end
	end

	return UnionJobType.intern
end

function UnionMemberMgr:ModifyMemberPosition(memberId, jobId)
	for i = 1, #self.listMember do
		if self.listMember[i].pid == memberId then
			self.listMember[i].jobId = jobId
		end
	end
end

function UnionMemberMgr:SortMembers(listMember)
	local listOnLine = {}
	local listOffline = {}

	for _, v in ipairs(listMember) do
		if v.isOnline then
			table.insert(listOnLine, v)
		else
			table.insert(listOffline, v)
		end
	end

	local function func(a, b)
		if a.jobId == b.jobId then
			return a.liveness > b.liveness
		else
			return a.jobId < b.jobId
		end
	end

	table.sort(listOnLine, func)
	table.sort(listOffline, func)

	local list = {}

	for i = 1, #listOnLine do
		table.insert(list, listOnLine[i])
	end

	for j = 1, #listOffline do
		table.insert(list, listOffline[j])
	end

	return list
end

function UnionMemberMgr:CanRecvUnion(memberId)
	return self:GetMemberJob(memberId) == UnionJobType.vice
end

function UnionMemberMgr:ChangeMemberLiveness(memberId, changeValue)
	local info = self:GetMember(memberId)

	if info then
		info.liveness = info.liveness + changeValue
	end

	for _, v in pairs(UnionMgr.releUnion.members) do
		if v.playerId == memberId then
			v.liveness = v.liveness + changeValue
		end
	end
end

function UnionMemberMgr:GetListMemberNoMine()
	local list = {}

	for _, v in pairs(self.listMember) do
		if v.pid ~= PlayerInst.InfoPlayer.pid then
			table.insert(list, v)
		end
	end

	return list
end

UnionApplyMgr = {}
UnionApplyMgr.listApply = {}

function UnionApplyMgr:SetData(pbPlayers)
	self.listApply = {}

	for _, v in ipairs(pbPlayers) do
		local info = InfoPlayer()

		info:SetData(v)

		info.jobId = UnionJobType.intern
		info.liveness = 0

		table.insert(self.listApply, info)
		UnionMgr.releUnion:AddApply(v.playerId)
	end
end

function UnionApplyMgr:DealWithApplyPlayer(listPlayerId, goType)
	for i = 1, #listPlayerId do
		for _, v in pairs(self.listApply) do
			if v.pid == listPlayerId[i] and goType == 1 then
				UnionMemberMgr:AddMember(v)
			end
		end

		for j = #self.listApply, 1, -1 do
			if self.listApply[j].pid == listPlayerId[i] then
				table.remove(self.listApply, j)
				UnionMgr.releUnion:RemoveApply(listPlayerId[i])
				UnionRDL.MemberRDL.RemoveApply(listPlayerId[i])
			end
		end
	end
end

UnionLogMgr = {}
UnionLogMgr.listLog = {}
UnionLogMgr.maxLogNum = GetConfigArgInt("ClubLogsMaxNum")

local eLogType = {
	transPos = 5,
	join = 1,
	transfer = 4,
	kick = 3,
	quit = 7
}

function UnionLogMgr:SetData(pbLogs)
	if not pbLogs or #pbLogs == 0 then
		return
	end

	self.listLog = {}

	for i = 1, #pbLogs do
		self:AddLog(pbLogs[i], true)
	end
end

function UnionLogMgr:SetLogInfo(pbLog)
	local _type = pbLog.type
	local _name = pbLog.playerName
	local _time = pbLog.time
	local info = ""

	if _type == eLogType.join then
		info = string.format(_("Desc_Union_Log_Join"), _name)
	elseif _type == eLogType.transfer then
		info = string.format(_("Desc_Union_Log_Transfer"), _name)
	elseif _type == eLogType.transPos then
		local position = pbLog.position or UnionJobType.intern

		info = string.format(_("Desc_Union_Log_Position"), _name, UnionJobMgr:GetUnionJobName(position))
	elseif _type == eLogType.quit or _type == eLogType.kick then
		info = string.format(_("Desc_Union_Log_Quit"), _name)
	end

	local time = os.date("%m-%d %H:%M", tonumber(_time))
	local log = {
		info = info,
		time = time
	}

	return log
end

function UnionLogMgr:AddLog(pbLog, notToFirst)
	if pbLog.type == eLogType.join or pbLog.type == eLogType.kick or pbLog.type == eLogType.quit or pbLog.type == eLogType.transPos or pbLog.type == eLogType.transfer then
		local log = self:SetLogInfo(pbLog)

		if notToFirst then
			table.insert(self.listLog, log)
		else
			table.insert(self.listLog, 1, log)
		end
	end

	self:RemoveLog()
end

function UnionLogMgr:RemoveLog()
	local num = table.getn(self.listLog)

	if num > self.maxLogNum then
		print("maxLogNum: " .. self.maxLogNum .. " curLogNum: " .. num)

		for i = num, self.maxLogNum + 1, -1 do
			table.remove(self.listLog, i)
		end
	end
end

function UnionLogMgr:ClearLog()
	self.listLog = {}
end

UnionJobMgr = {}
UnionJobType = {
	head = 1,
	vice = 2,
	general = 4,
	intern = 5,
	elite = 3
}
UnionJobPremissionType = {
	achWish = 9,
	apply = 4,
	upLevel = 6,
	kick = 12,
	disband = 2,
	recruit = 3,
	openRail = 11,
	tranUnion = 5,
	transfer = 1,
	upSkill = 7,
	changeNotice = 15,
	gvgStore = 14,
	enterRail = 10,
	addWish = 8,
	setting = 13
}

function UnionJobMgr:GetAllJob()
	local list = {}

	for _, v in pairsByKeys(unionJobData) do
		table.insert(list, v)
	end

	return list
end

function UnionJobMgr:GetTransfersByJobType(jobId)
	local transfer = {}

	for _, v in pairs(unionPermissionData) do
		if v.JobType == jobId and v.Func == UnionJobPremissionType.transfer then
			transfer = v.JobLimit
		end
	end

	return transfer
end

function UnionJobMgr:GetUnionJobName(jobType)
	return Lang(unionJobData[jobType].Name)
end

function UnionJobMgr:CanTransfer(jobType)
	local listLimit = GetConfigArgJson("ClubJobLimitMember")
	local limitNum = listLimit[jobType]
	local sum = 0
	local listMember = UnionMemberMgr.listMember

	for _, v in pairs(listMember) do
		if v.jobId == jobType then
			sum = sum + 1
		end
	end

	if limitNum ~= 0 and limitNum <= sum then
		local msg = _("Msg_Union_Position_Full")

		return false, msg
	end

	return true
end

function UnionJobMgr:HavePremission(jobType, premissionType)
	for _, v in pairs(unionPermissionData) do
		if v.JobType == jobType and v.Func == premissionType then
			return true
		end
	end

	return false
end
