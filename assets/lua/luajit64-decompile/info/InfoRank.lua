-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoRank.lua

InfoRank = class("InfoRank", InfoBase)

function InfoRank:ctor(pb)
	self.pb = {}
end

local recommendWaitTime = GetConfigArgInt("FriendRecommendWait")
local lastChangeRecommendTime = 0

RankMgr = {}
RankMgr.recommendWaitTime = GetConfigArgInt("FriendRecommendWait")
RankMgr.recommendWaitTime = 900
RankMgr.CurIndex = 3
RankMgr.lastRankViewPosY = 0

function RankMgr:SetData(pb)
	self.listRanks = {}
	self.listPvpRanks = {}
	self.listClubsRanks = {}

	for i = 1, #pb.ranks do
		local pbPlayer = {}

		pbPlayer.pb = pb.ranks[i]

		table.insert(self.listRanks, pbPlayer)
	end

	for i = 1, #pb.pvpRanks do
		local pbPlayer = {}

		pbPlayer.pb = pb.pvpRanks[i]

		table.insert(self.listPvpRanks, pbPlayer)
	end

	if pb.clubs then
		for i = 1, #pb.clubs do
			local pbClub = {}

			pbClub.pb = pb.clubs[i]

			table.insert(self.listClubsRanks, pbClub)
		end
	end

	self.playerRank = pb.playerRank
	self.playerScore = pb.playerScore
	self.ownerClub = pb.ownerClub
end

function RankMgr:GetRankList()
	return self.listRanks
end

function RankMgr:GetPvpRankList()
	return self.listPvpRanks
end

function RankMgr:GetUnionRankList()
	local function func(a, b)
		if a.pb.score == b.pb.score then
			if a.pb.level == b.pb.level then
				return a.pb.id > b.pb.id
			else
				return a.pb.level > b.pb.level
			end
		else
			return a.pb.score > b.pb.score
		end
	end

	table.sort(self.listClubsRanks, func)

	return self.listClubsRanks
end

function RankMgr:GetPlayerRank()
	return self.playerRank
end

function RankMgr:GetOwnerClub()
	return self.ownerClub
end

function RankMgr:GetClimbTowerLevel(stageID)
	local level = stageID % 600000

	return level
end

function RankMgr:GetPlayerScore()
	return self.playerScore or 0
end

function RankMgr:GetRankListSortValue(rankList, curIndex, name)
	local sortListValue = {}
	local value = 1
	local tempValue = 1
	local myScoreLevel

	for i = 1, #rankList do
		table.insert(sortListValue, i)
	end

	return sortListValue, RankMgr:GetPlayerRank()
end

function RankMgr:GetMyUnionRankListValue(clubName)
	local list = RankMgr:GetUnionRankList()

	local function func(a, b)
		if a.pb.score == b.pb.score then
			if a.pb.level == b.pb.level then
				return a.pb.id > b.pb.id
			else
				return a.pb.level > b.pb.level
			end
		else
			return a.pb.score > b.pb.score
		end
	end

	table.sort(list, func)

	for i = 1, #list do
		if list[i].pb.name == clubName then
			return i
		end
	end

	return 0
end

function RankMgr:SetLastChangeRecommendTime()
	lastChangeRecommendTime = NetData:GetCurServerTime()
end

function RankMgr:RefreshRecoverTime()
	local curServerTime = NetData:GetCurServerTime()
	local leftTime = RankMgr.recommendWaitTime - math.floor((curServerTime - lastChangeRecommendTime) / DateUtil.MillsPerSecond)

	if leftTime <= 0 then
		leftTime = 0
	end

	return leftTime
end

function RankMgr:ResetRankViewPosY()
	RankMgr.lastRankViewPosY = 0
end

function RankMgr:SetRankViewPosY(posY)
	RankMgr.lastRankViewPosY = posY
end

function RankMgr:GetRankViewPosY()
	return RankMgr.lastRankViewPosY
end

function RankMgr:GetRankDotStateList()
	if not self.rankDotStateList then
		if #PersistentStoreUtil.GetList(PersistentStoreUtil.KEY_RANK_DOT_STATE) == 0 then
			local list = {}
			local data = require("luaData/Newbie")

			list[1] = tonumber(data[TutorialFunctionType.BossRaid].Stage) .. "_0"
			list[2] = tonumber(data[TutorialFunctionType.PVP].Stage) .. "_0"
			list[3] = tonumber(data[TutorialFunctionType.Union].Stage) .. "_0"

			PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_RANK_DOT_STATE, list)
		end

		self.rankDotStateList = PersistentStoreUtil.GetList(PersistentStoreUtil.KEY_RANK_DOT_STATE)
	end

	return self.rankDotStateList
end

function RankMgr:SetRankDotStateList(stage)
	local list = RankMgr:GetRankDotStateList()
	local isHave = false

	if stage then
		for i = 1, #list do
			if stage > tonumber(string.split(list[i], "_")[1]) and tonumber(string.split(list[i], "_")[2]) == 0 then
				list[i] = string.split(list[i], "_")[1] .. "_1"
			end
		end
	end

	if not stage then
		for i = 1, #list do
			if tonumber(string.split(list[i], "_")[2]) == 1 then
				list[i] = string.split(list[i], "_")[1] .. "_2"
			end
		end
	end

	PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_RANK_DOT_STATE, list)

	self.rankDotState = list
end

function RankMgr:IsRankDotState()
	local list = RankMgr:GetRankDotStateList()
	local isDot = false

	for i = 1, #list do
		if tonumber(string.split(list[i], "_")[2]) == 1 then
			isDot = true
		end
	end

	return isDot
end
