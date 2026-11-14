-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/gvg/InfoGvg_Rank.lua

local rank = class("InfoGvg_Rank")

function rank:ctor()
	self.billboard_rank = {}
	self.own_rank = {}
	self.billboard_contribution = {}
	self.own_contribution = {}
	self.gvglog = {}
end

function rank:Purge()
	self.billboard_rank = {}
	self.own_rank = {}
	self.billboard_contribution = {}
	self.own_contribution = {}
	self.gvglog = {}
end

function rank:SetRankPb(pb)
	self.billboard_rank = {}

	for i, PBClub in ipairs(pb.clubs) do
		local data = {}

		data.name = PBClub.name
		data.score = PBClub.score
		data.level = PBClub.level
		data.id = PBClub.id
		data.type = PBClub.type
		data.order = i
		data.info = PBClub

		table.insert(self.billboard_rank, data)
	end

	Infogvg:Log("rankPb-rank list len:" .. #self.billboard_rank)

	self.own_rank = table.remove(self.billboard_rank, #self.billboard_rank)

	if self.own_rank then
		self.own_rank.order = pb.playerRank
	end

	Event.Instance:Fire("EVENT_GVG_RANK")
end

function rank:SetContributionPb(pb)
	self.billboard_contribution = {}
	self.own_contribution = {}
	self.contributionPlayerMap = {}

	for i, p in ipairs(pb.members) do
		local data = {}

		data.order = i
		data.playerId = p.playerId
		data.nickname = p.nickname
		data.headId = p.headId
		data.headFrame = p.headFrame
		data.levelExp = p.levelExp
		data.clubName = p.clubName
		data.contribution = p.extras[1]

		table.insert(self.billboard_contribution, data)

		self.contributionPlayerMap[p.playerId] = p
	end

	Infogvg:Log("rankPb-contribution list len:" .. #self.billboard_contribution)

	self.own_contribution = table.remove(self.billboard_contribution, #self.billboard_contribution)

	if self.own_contribution then
		self.own_contribution.order = pb.playerRank
	end

	Event.Instance:Fire("EVENT_GVG_CONTRIBUTION")
end

function rank:FindPBPlayer(playerId)
	return self.contributionPlayerMap[playerId]
end

function rank:SetGvgLogPb(pb)
	self.gvglog = {}

	for i, p in ipairs(pb.gvgLogs) do
		local data = {}

		data.name = p.playerName
		data.stageId = tonumber(p.stageId)
		data.battleTime = p.battleTime
		data.costBlood = p.costBlood
		data.headFrame = p.headFrame
		data.headId = p.headId
		data.stage = p.stage

		table.insert(self.gvglog, data)
	end

	Infogvg:Log("rankPb-gvgLogs list len:" .. #self.gvglog)
	Event.Instance:Fire("EVENT_GVG_SCORE")
end

return rank
