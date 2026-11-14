-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoPvPPlayer.lua

InfoPvPPlayer = class("InfoPvPPlayer")

function InfoPvPPlayer:ctor()
	return
end

function InfoPvPPlayer:SetData(pvppbPlayer, playertype)
	self.seasonId = pvppbPlayer.seasonId
	self.subSeasonNum = pvppbPlayer.subSeasonNum
	self.dailyBattleTotal = pvppbPlayer.dailyBattleTotal
	self.dailyBattleNumber = pvppbPlayer.dailyBattleNumber
	self.dailyBuyNumber = pvppbPlayer.dailyBuyNumber
	self.dailyBattleTime = pvppbPlayer.dailyBattleTime
	self.opponentsRefreshTotal = pvppbPlayer.opponentsRefreshTotal
	self.opponentsRefreshNumber = pvppbPlayer.opponentsRefreshNumber
	self.seasonRankingScore = pvppbPlayer.seasonRankingScore
	self.seasonRankingAward = pvppbPlayer.seasonRankingAward
	self.subSeasonScore = pvppbPlayer.subSeasonScore
	self.subSeasonRankingNo = pvppbPlayer.subSeasonRankingNo
	self.attackingRoleCards = pvppbPlayer.attackingRoleCards
	self.defensiveRoleCards = pvppbPlayer.defensiveRoleCards
	self.attackingPBTeamFetter = pvppbPlayer.attackingTeamFetter
	self.defensivePbTeamFetter = pvppbPlayer.defensiveTeamFetter
	self.attackingFetterTeamId = self.attackingPBTeamFetter.id
	self.defensiveFetterTeamId = self.defensivePbTeamFetter.id
	self.roles = pvppbPlayer.roles

	self:ChosePlayerinfo(pvppbPlayer.player, playertype)
end

function InfoPvPPlayer:ChosePlayerinfo(pbplayer, playertype)
	if playertype == 1 then
		self.playerinfo = InfoPlayer()

		self.playerinfo:SetData(pbplayer)
	else
		self.playerinfo = PlayerInst.InfoPlayer
	end
end

function InfoPvPPlayer:SetAttackCards(cardtable)
	self.attackingRoleCards = {}

	for i, v in ipairs(cardtable) do
		table.insert(self.attackingRoleCards, v)
	end
end

function InfoPvPPlayer:SetDefensCards(cardtable)
	self.defensiveRoleCards = {}

	for i, v in ipairs(cardtable) do
		table.insert(self.defensiveRoleCards, v)
	end
end

function InfoPvPPlayer:BuyBattleNum()
	self.dailyBattleNumber = self.dailyBattleNumber - 1
	self.dailyBuyNumber = self.dailyBuyNumber + 1
end
