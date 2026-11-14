-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoActivityBossRaid.lua

local RaidBossData = require("luaData/RaidBoss")

InfoActivityBossRaid = class("InfoActivityBossRaid", InfoBase)

function InfoActivityBossRaid:ctor(id)
	self.id = id
end

function InfoActivityBossRaid:SetData(pb)
	self.id = pb.id
	self.curProgress = tonumber(pb.process)
	self.bossLevel = pb.bossLevel
	self.member = pb.member
	self.stageId = tonumber(pb.stageId)
	self.finder = pb.finder
	self.overTime = tonumber(pb.overTime)
	self.playCount = pb.playCount
	self.selfPlayNum = pb.selfPlayNum
	self.selfStatus = pb.selfStatus
	self.selfShared = pb.selfShared

	if pb.randomAward then
		self.randomAward = pb.randomAward
	end

	if pb.rank then
		self.rank = pb.rank
	end

	self.MaxPlayers = GetConfigArgInt("RailBossPlayerNum")
	self.raidBossData = ActivityBossRaidMgr.BossraidData[self.bossLevel]

	if PlayerInst.InfoPlayer.pid == pb.finder_id then
		self.fromType = 0
	elseif FriendMgr:IsGameFriend(pb.finder_id) then
		self.fromType = 1
	elseif UnionMgr.releUnion and UnionMgr.releUnion:HaveMember(pb.finder_id) then
		self.fromType = 2
	else
		self.fromType = 4
	end
end

function InfoActivityBossRaid:IsFinished()
	if self.curProgress == 0 then
		return true
	end

	local curtime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	if curtime > self.overTime then
		return true
	end

	if self.playCount == (self.MaxPlayers - 1) * GetConfigArgInt("RailBossActivePartnerNum") + GetConfigArgInt("RailBossActiveFinderNum") then
		return true
	end

	return false
end

ActivityBossRaidMgr = {}
ActivityBossRaidMgr.listRaid = {}
ActivityBossRaidMgr.listRaidHard = {}
ActivityBossRaidMgr.listRaidRecord = {}
ActivityBossRaidMgr.constHpPrecision = 10000000
ActivityBossRaidMgr.boosLevel = 40
ActivityBossRaidMgr.playNum = 0
ActivityBossRaidMgr.buyNum = 0
ActivityBossRaidMgr.curBossRaidId = 0
ActivityBossRaidMgr.Requested = false
ActivityBossRaidMgr.selfBossEndTime = 0
ActivityBossRaidMgr.ActiveID = 0
ActivityBossRaidMgr.isAdd = false

function ActivityBossRaidMgr:Get(bossRaidId)
	for i, v in ipairs(ActivityBossRaidMgr.listRaid) do
		if tonumber(v.id) == bossRaidId then
			return v
		end
	end

	for i, v in ipairs(ActivityBossRaidMgr.listRaidHard) do
		if tonumber(v.id) == bossRaidId then
			return v
		end
	end

	return nil
end

function ActivityBossRaidMgr:SetData(PB, inRecord, type)
	local function GetListInfo(pbStages)
		local list = {}

		for i = 1, #pbStages do
			local pbBoss = pbStages[i]
			local InfoActivityBossRaid = InfoActivityBossRaid(pbBoss.id)

			InfoActivityBossRaid:SetData(pbBoss)
			table.insert(list, InfoActivityBossRaid)
		end

		return list
	end

	ActivityBossRaidMgr.ActiveID = PB.activeId

	if ActivityBossRaidMgr.BossraidData == nil or not next(ActivityBossRaidMgr.BossraidData) then
		ActivityBossRaidMgr.BossraidData = {}

		for k, v in pairs(RaidBossData) do
			if ActivityBossRaidMgr.ActiveID == v.ActiveId then
				ActivityBossRaidMgr.BossraidData[v.Level] = v
			end
		end
	end

	if not inRecord then
		ActivityBossRaidMgr.boosLevel = PB.boosLevel
		ActivityBossRaidMgr.playNum = PB.playNum
		ActivityBossRaidMgr.assistNum = PB.assistNum
		ActivityBossRaidMgr.buyNum = PB.buyNum
		ActivityBossRaidMgr.listRaid = GetListInfo(PB.stages)
		ActivityBossRaidMgr.listRaidHard = GetListInfo(PB.highStages)
	else
		ActivityBossRaidMgr.listRaidRecord = GetListInfo(PB.stages)
	end
end

function ActivityBossRaidMgr:DailyUpdate()
	ActivityBossRaidMgr.playNum = TenaryOp(ActivityBossRaidMgr.playNum > ActivityBossRaidMgr:GetPlayMaxNum(), ActivityBossRaidMgr.playNum, ActivityBossRaidMgr:GetPlayMaxNum())
	ActivityBossRaidMgr.buyNum = 0
	ActivityBossRaidMgr.assistNum = 0
end

function ActivityBossRaidMgr:GetFinishedBossRaid()
	local listFinishBossRaid = {}

	for _, v in pairs(ActivityBossRaidMgr.listRaidRecord) do
		table.insert(listFinishBossRaid, v)
	end

	table.sort(listFinishBossRaid, function(a, b)
		if a.curProgress == 0 and b.curProgress ~= 0 then
			return true
		elseif a.curProgress ~= 0 and b.curProgress == 0 then
			return false
		elseif a.curProgress == 0 and b.curProgress == 0 then
			if a.selfStatus == 0 and b.selfStatus == 1 then
				return true
			elseif a.selfStatus == 1 and b.selfStatus == 0 then
				return false
			else
				return a.overTime > b.overTime
			end
		end
	end)

	while #listFinishBossRaid > 99 do
		table.remove(listFinishBossRaid)
	end

	print(#listFinishBossRaid)

	return listFinishBossRaid
end

function ActivityBossRaidMgr:ResetPlayNum()
	ActivityBossRaidMgr.playNum = ActivityBossRaidMgr.playNum + GetConfigArgFloat("RailBossActiveDailyNumBuyCost")
	ActivityBossRaidMgr.buyNum = ActivityBossRaidMgr.buyNum + 1
end

function ActivityBossRaidMgr:GetCanPlayBossRaid(type)
	local listBossRaid = {}

	if type == 1 then
		for _, v in ipairs(ActivityBossRaidMgr.listRaid) do
			if not v:IsFinished() then
				table.insert(listBossRaid, v)
			end
		end
	elseif type == 2 then
		for _, v in ipairs(ActivityBossRaidMgr.listRaidHard) do
			if not v:IsFinished() then
				table.insert(listBossRaid, v)
			end
		end
	end

	return listBossRaid
end

function ActivityBossRaidMgr:GetPlayMaxNum()
	local baseNum = GetConfigArgInt("RailBossActiveDailyNum")
	local _, num = ShopManager:GetGoodsMonthPrivilegeFuncInfo(ShopManager.MonthPrivilegeFunc.Func2)

	return baseNum + num
end

function ActivityBossRaidMgr:GetAssistRewardMaxNum()
	local baseNum = 0

	for _, v in ipairs(GetConfigArgJson("JPRaidBossSetting")) do
		if v[1] == "MaxAssistRewardCount" then
			baseNum = v[2]

			break
		end
	end

	return baseNum
end

function ActivityBossRaidMgr:GetBossRaidBox()
	local infoList = {}
	local data = ActivityBossRaidMgr.BossraidData[1]

	for i = 1, 3 do
		local boxData = {}

		boxData.rewardPacketId = data.FinishReward[i][1]
		boxData.itemId = data.ShowItem[i]
		boxData.BeginLevel = 99
		boxData.EndLevel = 0
		infoList[i] = boxData
	end

	for i, v in ipairs(ActivityBossRaidMgr.BossraidData) do
		for i = 1, 3 do
			if v.FinishReward[i][2] ~= 0 then
				if infoList[i].BeginLevel > v.Level then
					infoList[i].BeginLevel = v.Level
				end

				if infoList[i].EndLevel < v.Level then
					infoList[i].EndLevel = v.Level
				end
			end
		end
	end

	return infoList
end

function ActivityBossRaidMgr.IsSetData()
	return ActivityBossRaidMgr.playNum ~= 0
end

function ActivityBossRaidMgr.IsBreak()
	local DailyTime = ActivityBossRaidMgr.bossRaidTimeData.data.DailyTime
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local curServerData = os.date("*t", curServerTime)
	local isBreak = true

	for i, v in ipairs(DailyTime) do
		if curServerData.hour < v[2] and curServerData.hour >= v[1] then
			isBreak = false

			break
		end
	end

	return isBreak
end
