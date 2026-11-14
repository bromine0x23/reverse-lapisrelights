-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoPVP.lua

local pvprangkdata = require("luaData/PVPRankingList")
local pvpseasondata = require("luaData/PVPSeason")
local pvpseasonrewarddata = require("luaData/PVPSeasonRankingAward")
local pvpsubseasonrankdata = require("luaData/PVPSubSeasonAward")
local InfoTeam = require("Info/InfoTeam")

require("Info/InfoPvPPlayer")
require("Info/InfoRoleCard")

local InfoPVP = {}

InfoPVP.const_num_of_team = 5
InfoPVP.const_help_num_of_team = 5

local CONST_NUM_OF_TEAM = InfoPVP.const_num_of_team
local CONST_HELP_NUM_OF_TEAM = InfoPVP.const_help_num_of_team

function InfoPVP:RequestSeasonData()
	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestSeasonData(0, 0, 1, function()
		self:ReceveSeasonData(pb)
	end)
end

function InfoPVP:ReceveSeasonData(pb)
	LoadingMgr.Hide(eLoadingType.Repeat)
	self:SetData(pb)

	local curtime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local endtime = GetConfigArgInt("PVPSettleSeconds")
	local time = self.PBPVPSeason.subSeasonEndTime - NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	if pb.season.seasonStatus ~= 1 then
		UIMgr.ShowMsg(_("PvPSeason"))
	elseif time < 0 then
		UIMgr.ShowMsg(_("PvPSeason"))
	elseif time <= endtime or tonumber(curtime) < tonumber(self.PBPVPSeason.subSeasonBeginTime) then
		UIMgr.ShowMsg(_("PvPSeason"))
	else
		require("UI/Page/pagePVP/PagePVPMain")
		UIMgr.SwitchPanel(PagePVPMain, pb)
	end
end

function InfoPVP:GetTeamCost(teamType)
	local costValue = 0

	if teamType == 1 then
		for i = 1, #self.rocardtable do
			if i <= CONST_NUM_OF_TEAM then
				costValue = costValue + self:GetCardCose(self.rocardtable[i].id, 1)
			else
				costValue = costValue + self:GetCardCose(self.rocardtable[i].id, 2)
			end
		end
	else
		for i = 1, #self.attackrolecardtable do
			if i <= CONST_NUM_OF_TEAM then
				costValue = costValue + self:GetCardCose(self.attackrolecardtable[i].id, 1)
			else
				costValue = costValue + self:GetCardCose(self.attackrolecardtable[i].id, 2)
			end
		end
	end

	return costValue
end

function InfoPVP:GetCardCose(cardId, type)
	if cardId ~= 0 then
		local infoRoleCard = RoleCardMgr:GetRoleCard(cardId)
		local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)

		return RoleCardMgr:GetCardCost(infoRoleCard, infoRole, type)
	end

	return 0
end

function InfoPVP:GetInitTeam()
	local listAllCard = RoleCardMgr:GetAllHoldCard()

	self:SortByFightValue(listAllCard)

	local maxCost = LevelManager:GetMaxCost(PlayerInst:GetCurLv())
	local pickCardList = {}
	local pickRoleMap = {}
	local pickCount = 0
	local curCost = 0

	for i, card in ipairs(listAllCard) do
		local roleId = card.data.CharacterID
		local cost = self:GetCardCose(card.id, 1)

		if pickRoleMap[roleId] == nil then
			pickRoleMap[roleId] = card
			pickCount = pickCount + 1
			curCost = curCost + cost

			table.insert(pickCardList, {
				id = card.id
			})
		end

		if pickCount >= CONST_NUM_OF_TEAM then
			break
		end
	end

	if #pickCardList ~= CONST_NUM_OF_TEAM then
		print("ERROR,pvpデフォルト設定人数エラー  編成人数設定：" .. #pickCardList)
	end

	for i = 1, CONST_HELP_NUM_OF_TEAM do
		table.insert(pickCardList, {
			id = 0
		})
	end

	return pickCardList
end

function InfoPVP:GetFetterTeamId()
	local id = self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex].fetterTeamId

	return id
end

function InfoPVP:SortByFightValue(listAllCard)
	local cardFightValue = {}

	table.sort(listAllCard, function(card1, card2)
		local fightValue1, fightValue2

		if cardFightValue[card1.data.ID] then
			fightValue1 = cardFightValue[card1.data.ID]
		else
			local role1 = RoleMgr:GetRole(card1.data.CharacterID)

			fightValue1 = RoleCardMgr:GetFightValue(role1, card1)
			cardFightValue[card1.data.ID] = fightValue1
		end

		if cardFightValue[card2.data.ID] then
			fightValue2 = cardFightValue[card2.data.ID]
		else
			local role2 = RoleMgr:GetRole(card2.data.CharacterID)

			fightValue2 = RoleCardMgr:GetFightValue(role2, card2)
			cardFightValue[card2.data.ID] = fightValue2
		end

		return fightValue2 < fightValue1
	end)
end

function InfoPVP:RequestBattleStart()
	local listUpRoleCard = self:GetUpRoleCardList(2)

	for k, infoRoleCard in ipairs(listUpRoleCard) do
		if k <= CONST_NUM_OF_TEAM then
			infoRoleCard:SetCardHpPercentBeforeBattle()
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestBeginBattle(self.PBPVPSeason.seasonId, self.PBPVPSeason.subSeasonNum, self.BattlerPlayer.playerinfo.pid, self:GetFetterTeamId(), function(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Sucess then
			local vParam = {}

			vParam.stageId = self:GetStageid()
			vParam.boutId = pb.battleId
			vParam.pvp = 1
			vParam.myName = self.SelfPVPPlayerinfo.playerinfo.name
			vParam.otherName = self.BattlerPlayer.playerinfo.name
			vParam.myPower = self:GetMyAddRoleCard(self.SelfPVPPlayerinfo.defensiveRoleCards)
			vParam.otherPower = self:GetAddRoleCard(self.BattlerPlayer)
			vParam.player1 = {
				self:GetUpRoleList(2),
				listUpRoleCard,
				self:GetAddRoleCardList(2)
			}
			vParam.player2 = {
				self:GetOtherPlayerListRole(),
				self:GetOtherPlayerListRoleCard(),
				self:GetOtherPlayerAddRoleCardList()
			}
			vParam.randomSeed = pb.battleSeeds[1]
			vParam.randomSeedForReward = pb.battleSeeds[2]

			local idtable2 = {}

			for i = 1, #self.attackrolecardtable do
				table.insert(idtable2, self.attackrolecardtable[i].id)
			end

			local fetterId = self:GetFetterTeamId()

			if fetterId == 0 then
				vParam.bondage = nil
			else
				vParam.bondage = CombBondageMgr.DealWithBattleBondage(idtable2, CombinationMgr:Get(fetterId).pbTeamFetter)
			end

			local idtable2_battlerplayer = {}

			for i, card in ipairs(self:GetOtherPlayerListRoleCard()) do
				table.insert(idtable2_battlerplayer, card.id)
			end

			InfoPVP:SetPVPBattleNum(pb.pvpBattleNum)
			InfoBGMEventMgr:Clear()

			vParam.otherBondage = CombBondageMgr.DealWithBattleBondage(idtable2_battlerplayer, self.BattlerPlayer.defensivePbTeamFetter)

			local game = require("GameLogic/RunGame")

			game:Run(vParam)
		else
			UIMgr.ShowMsg(pb.result.desc, pb)
			UIMgr.GetCurPanel():OnBack()
		end
	end)
end

function InfoPVP:RequestBattleEnd(battleid, battleWin, battleSeconds, battleRandoms, battleLogsLite, battlelogs, endBattleCB)
	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestBattleEnd(self.PBPVPSeason.seasonId, self.PBPVPSeason.subSeasonNum, battleid, battleWin, battleSeconds, battleRandoms, battleLogsLite, battlelogs, function(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Sucess then
			local overdata = {}

			overdata.battleoverdata = pb
			overdata.callBack = endBattleCB

			if pb.bestRankingUp and pb.bestRankingUp > 0 then
				self:SetRankUpReward(pb)
			end

			require("UI/Page/pagePVP/PagePVPOver")
			UIMgr.AddPanel(PagePVPOver(), overdata)
		else
			local data = {}

			data.pvp = 0

			endBattleCB(data)
		end
	end)
end

function InfoPVP:GetBattleAddAttr(teamtype, roleType)
	local attrtable = {}

	if roleType == 1 then
		for i = 1, CONST_NUM_OF_TEAM do
			local data = self.teamSystemAgent.teamList[1].slotList[i]:GetAddAttri()

			table.insert(attrtable, data)
		end
	else
		for i = 1, CONST_NUM_OF_TEAM do
			local datatable = {
				upInfoRoleCard = self:GetOtherPlayerListRoleCard()[i],
				addInfoRoleCard = self:GetOtherPlayerListRoleCard()[i + CONST_NUM_OF_TEAM]
			}
			local data = TeamSlotAgent(datatable)

			table.insert(attrtable, data:GetAddAttri())
		end
	end

	return attrtable
end

function InfoPVP:GetAddRoleCard(playerdata)
	local num = 0
	local cardlist = playerdata.defensiveRoleCards
	local card = InfoRoleCard(101101)
	local role = InfoRole(101)

	for i = 1, #cardlist do
		if i <= CONST_NUM_OF_TEAM then
			local addcard = InfoRoleCard(101101)

			if cardlist[i].id ~= 0 then
				card:ctor(cardlist[i].id)
				card:SetPBPlayer(playerdata.playerinfo.pb)
				card:SetData(cardlist[i])

				for i = 1, #playerdata.roles do
					if card.data.CharacterID == playerdata.roles[i].id then
						role:ctor(playerdata.roles[i].id)
						role:SetPBPlayer(playerdata.playerinfo.pb)
						role:SetData(playerdata.roles[i])

						break
					end
				end

				if cardlist[i + CONST_NUM_OF_TEAM] and cardlist[i + CONST_NUM_OF_TEAM].id ~= 0 then
					addcard:ctor(cardlist[i + CONST_NUM_OF_TEAM].id)
					addcard:SetPBPlayer(playerdata.playerinfo.pb)
					addcard:SetData(cardlist[i + CONST_NUM_OF_TEAM])
				else
					addcard = nil
				end

				num = num + RoleCardMgr:GetFightValue(role, card, addcard)
			end
		end
	end

	return math.floor(num)
end

function InfoPVP:GetMyAddRoleCard(playerdata)
	local num = 0
	local cardlist = playerdata

	for i = 1, #cardlist do
		if i <= CONST_NUM_OF_TEAM and cardlist[i].id ~= 0 then
			local card = RoleCardMgr:GetRoleCard(cardlist[i].id)
			local role = RoleCardMgr:GetRole(card.id)
			local addcard

			if cardlist[i + CONST_NUM_OF_TEAM] and cardlist[i + CONST_NUM_OF_TEAM].id ~= 0 then
				addcard = RoleCardMgr:GetRoleCard(cardlist[i + CONST_NUM_OF_TEAM].id)
			end

			num = num + RoleCardMgr:GetFightValue(role, card, addcard)
		end
	end

	return math.floor(num)
end

function InfoPVP:GetBattle(attr)
	local stamina = attr[1]
	local defend = attr[2]
	local song = attr[3]
	local will = attr[4]
	local atk = (will + song) * GetConfigArgInt("FightValueAtkRatio")
	local def = defend * GetConfigArgInt("FightValueDefRatio")
	local hp = stamina * GetConfigArgInt("FightValueHPRatio")

	return (atk + def + hp) * (1 + GetConfigArgFloat("FightValueSkillAddPer"))
end

function InfoPVP:GetUpRoleCardList(teamType)
	local rolecardidtable = {}

	if teamType == 1 then
		for i = 1, #self.rocardtable do
			table.insert(rolecardidtable, self.rocardtable[i])
		end
	else
		for i = 1, #self.attackrolecardtable do
			table.insert(rolecardidtable, self.attackrolecardtable[i])
		end
	end

	return rolecardidtable
end

function InfoPVP:GetUpRoleList(teamType)
	local roleidtable = {}

	if teamType == 1 then
		for i = 1, #self.rocardtable do
			if i <= CONST_NUM_OF_TEAM then
				local infoRole = RoleMgr:GetRole(self.rocardtable[i].data.CharacterID)

				table.insert(roleidtable, infoRole)
			end
		end
	else
		for i = 1, #self.attackrolecardtable do
			if i <= CONST_NUM_OF_TEAM then
				local infoRole = RoleMgr:GetRole(self.attackrolecardtable[i].data.CharacterID)

				table.insert(roleidtable, infoRole)
			end
		end
	end

	return roleidtable
end

function InfoPVP:GetAddCardList(teamType)
	local rolecardidtable = {}

	if teamType == 1 then
		for i = 1, #self.rocardtable do
			if i > CONST_NUM_OF_TEAM then
				local id = self.rocardtable[i].id

				table.insert(rolecardidtable, id)
			end
		end
	else
		for i = 1, #self.attackrolecardtable do
			if i > CONST_NUM_OF_TEAM then
				local id = self.attackrolecardtable[i].id

				table.insert(rolecardidtable, id)
			end
		end
	end

	return rolecardidtable
end

function InfoPVP:GetAddRoleCardList(teamType)
	local rolecardidtable = {}

	if teamType == 1 then
		for i = 1, #self.rocardtable do
			if i > CONST_NUM_OF_TEAM then
				local card = self.rocardtable[i]

				if card.id ~= 0 then
					rolecardidtable[i - CONST_NUM_OF_TEAM] = card
				end
			end
		end
	else
		for i = 1, #self.attackrolecardtable do
			if i > CONST_NUM_OF_TEAM then
				local card = self.attackrolecardtable[i]

				if card.id ~= 0 then
					rolecardidtable[i - CONST_NUM_OF_TEAM] = card
				end
			end
		end
	end

	return rolecardidtable
end

function InfoPVP:GetAddAttri(characterId, teamType, roleType)
	local attr = {
		0,
		0,
		0,
		0
	}
	local idx = -1

	for i, id in ipairs(self:GetUpRoleList(teamType, roleType)) do
		if id == characterId then
			idx = i

			break
		end
	end

	if idx == -1 then
		return attr
	end

	local addCardId = self:GetAddCardList(teamType, roleType)[idx]

	if addCardId == 0 then
		return attr
	end

	local upCardId = self:GetUpRoleCardList(teamType, roleType)[idx]
	local configIdx = self.teamSystemAgent

	InfoTeam:GetAddCardType(upCardId, addCardId)

	local mul = GetConfigArgJson("JoinAttCombat")[configIdx] * 0.01
	local card = RoleCardMgr:GetRoleCard(addCardId.id)

	for i = 1, 4 do
		attr[i] = card:GetAtt(i) * mul
	end

	return attr
end

function InfoPVP:RequestSetFormation(teamType, idtable, callBack)
	local attackingFetterTeamId, defensiveFetterTeamId

	if self.NumType == 2 then
		attackingFetterTeamId = self:GetFetterTeamId()
	elseif self.NumType == 1 then
		defensiveFetterTeamId = self:GetFetterTeamId()
	end

	LoadingMgr.Show(eLoadingType.Repeat)

	if teamType == 1 then
		NetManager:RequestSetTeam(self.PBPVPSeason.seasonId, self.PBPVPSeason.subSeasonNum, nil, idtable, attackingFetterTeamId, defensiveFetterTeamId, function(pb)
			LoadingMgr.Hide(eLoadingType.Repeat)
			self:TeamSucess(callBack)
		end)
	else
		NetManager:RequestSetTeam(self.PBPVPSeason.seasonId, self.PBPVPSeason.subSeasonNum, idtable, nil, attackingFetterTeamId, defensiveFetterTeamId, function(pb)
			LoadingMgr.Hide(eLoadingType.Repeat)
			self:TeamSucess(callBack)
		end)
	end
end

function InfoPVP:SetTeamType(value)
	self.NumType = value
end

function InfoPVP:RequestSetFormationBegin()
	local idtable = {}
	local idtable2 = {}
	local attackingFetterTeamId, defensiveFetterTeamId

	if self.NumType == 1 then
		attackingFetterTeamId = self:GetFetterTeamId()
	elseif self.NumType == 2 then
		defensiveFetterTeamId = self:GetFetterTeamId()
	end

	for i = 1, #self.rocardtable do
		table.insert(idtable, self.rocardtable[i].id)
	end

	for i = 1, #self.attackrolecardtable do
		table.insert(idtable2, self.attackrolecardtable[i].id)
	end

	NetManager:RequestSetTeam(self.PBPVPSeason.seasonId, self.PBPVPSeason.subSeasonNum, idtable2, idtable, attackingFetterTeamId, defensiveFetterTeamId, function(pb)
		if pb.result.code == 0 then
			self.initTeamSuccess = true
		end

		LoadingMgr.Hide(eLoadingType.Repeat)
	end)
end

function InfoPVP:SetData(pb)
	if not pb.season then
		return
	end

	self.PBPVPSeason = pb.season
	self.pb = pb
	self.defensiveRoleCards = nil
	self.attackingRoleCards = nil
	self.SelfPVPPlayerinfo = InfoPvPPlayer()

	self.SelfPVPPlayerinfo:SetData(self.PBPVPSeason.player)

	if self.SelfPVPPlayerinfo.attackingFetterTeamId ~= 0 then
		self.SelfPVPPlayerinfo.attackingPBTeamFetter = CombinationMgr:Get(self.SelfPVPPlayerinfo.attackingFetterTeamId).pbTeamFetter
	end

	self.defensiveRoleCards = self.PBPVPSeason.player.defensiveRoleCards
	self.attackingRoleCards = self.PBPVPSeason.player.attackingRoleCards
	self.opponents = self.pb.season.opponents

	if self.befScoreSeasonId == pb.season.seasonId then
		self.befScore = self.curScore
	else
		self.befScore = nil
		self.befScoreSeasonId = pb.season.seasonId
	end

	self.curScore = self.PBPVPSeason.player.seasonRankingScore

	self:MyRocard(self.PBPVPSeason)
	self:OtherRolecard(self.PBPVPSeason)
	self:GetAllSeasonRankRewarddata()
	PVPRDL.RunPVPRankAward(self.rewardRankawardtable)

	self.setedDot = true
end

function InfoPVP:SetInitTeam()
	local initTeam

	if #self.defensiveRoleCards <= 0 then
		initTeam = self:GetInitTeam()
		self.defensiveRoleCards = initTeam

		self.SelfPVPPlayerinfo:SetDefensCards(initTeam)
	end

	if #self.attackingRoleCards <= 0 then
		initTeam = initTeam or self:GetInitTeam()
		self.attackingRoleCards = initTeam

		self.SelfPVPPlayerinfo:SetAttackCards(initTeam)
	end

	self:MyRocard(self.PBPVPSeason)
	self:OtherRolecard(self.PBPVPSeason)

	if #self.PBPVPSeason.player.defensiveRoleCards <= 0 and not self.initTeamSuccess then
		print("初期編成を設定")
		self:RequestSetFormationBegin()
	end
end

function InfoPVP:SetRecordData(pb)
	if pb ~= nil then
		self.Recorddata = pb
	end
end

function InfoPVP:GetRecordData()
	return self.Recorddata
end

function InfoPVP:SetCurrentBatllePlayer(player)
	self.BattlerPlayer = player
end

function InfoPVP:SetPVPRefashNum(num)
	self.PBPVPSeason.player.opponentsRefreshNumber = num
end

function InfoPVP:SetPVPBattleNum(num)
	self.PBPVPSeason.player.opponentsRefreshNumber = num
end

function InfoPVP:GetCurrentBatllePlayer()
	return self.BattlerPlayer
end

function InfoPVP:GetOtherPlayerListRole()
	local roletable = {}

	for i = 1, #self.BattlerPlayer.defensiveRoleCards do
		if i <= CONST_NUM_OF_TEAM and self.BattlerPlayer.defensiveRoleCards[i].id ~= 0 then
			local card = InfoRoleCard(self.BattlerPlayer.defensiveRoleCards[i].id)
			local roleid = card.data.CharacterID
			local data

			for i = 1, #self.BattlerPlayer.roles do
				if roleid == self.BattlerPlayer.roles[i].id then
					data = self.BattlerPlayer.roles[i]
				end
			end

			if data ~= nil then
				local role = InfoRole(roleid)

				role:SetPBPlayer(self.BattlerPlayer.playerinfo.pb)
				role:SetData(data)
				table.insert(roletable, role)
			end
		end
	end

	return roletable
end

function InfoPVP:GetOtherPlayerListRoleCard()
	local rolecard = {}

	for i = 1, #self.BattlerPlayer.defensiveRoleCards do
		if self.BattlerPlayer.defensiveRoleCards[i].id ~= 0 then
			local card = InfoRoleCard(self.BattlerPlayer.defensiveRoleCards[i].id)

			card:SetPBPlayer(self.BattlerPlayer.playerinfo.pb)
			card:SetData(self.BattlerPlayer.defensiveRoleCards[i])
			table.insert(rolecard, card)
		end
	end

	return rolecard
end

function InfoPVP:GetOtherPlayerAddRoleCardList()
	local tbl = {}

	for i = CONST_NUM_OF_TEAM + 1, #self.BattlerPlayer.defensiveRoleCards do
		if self.BattlerPlayer.defensiveRoleCards[i].id ~= 0 then
			local card = InfoRoleCard(self.BattlerPlayer.defensiveRoleCards[i].id)

			card:SetPBPlayer(self.BattlerPlayer.playerinfo.pb)
			card:SetData(self.BattlerPlayer.defensiveRoleCards[i])

			tbl[i - CONST_NUM_OF_TEAM] = card
		end
	end

	return tbl
end

function InfoPVP:MyRocard(pb)
	self.rocardtable = {}

	for i = 1, #self.defensiveRoleCards do
		if self.defensiveRoleCards[i].id ~= 0 then
			local ro = RoleCardMgr:GetRoleCard(self.defensiveRoleCards[i].id)

			table.insert(self.rocardtable, ro)
		else
			local ro = {}

			ro.id = 0

			table.insert(self.rocardtable, ro)
		end
	end
end

function InfoPVP:OtherRolecard(pb)
	self.attackrolecardtable = {}

	for i = 1, #self.attackingRoleCards do
		if self.attackingRoleCards[i].id ~= 0 then
			local ro = RoleCardMgr:GetRoleCard(self.attackingRoleCards[i].id)

			table.insert(self.attackrolecardtable, ro)
		else
			local ro = {}

			ro.id = 0

			table.insert(self.attackrolecardtable, ro)
		end
	end
end

function InfoPVP:GetRocardtable(i)
	if self.rocardtable then
		return self.rocardtable[i]
	else
		return false
	end
end

function InfoPVP:GetotherRolecard(i)
	if not self.BattlerPlayer.defensiveRoleCards[i] then
		print("error  idx = " .. tostring(i) .. "存在しない")

		return self.BattlerPlayer.defensiveRoleCards[#self.BattlerPlayer.defensiveRoleCards]
	end

	local card = InfoRoleCard(self.BattlerPlayer.defensiveRoleCards[i].id)

	card:SetPBPlayer(self.BattlerPlayer.playerinfo.pb)
	card:SetData(self.BattlerPlayer.defensiveRoleCards[i])

	return card
end

function InfoPVP:GetSeasondata()
	return self.PBPVPSeason
end

function InfoPVP:GetOtherPVPPlayerinfo(pbpvpplayer)
	local info = InfoPvPPlayer()

	info:SetData(pbpvpplayer, 1)

	return info
end

function InfoPVP:GetNamebyscore(score)
	local name

	for i = 1, #pvprangkdata do
		if score >= pvprangkdata[i].RankingScoreFrom and score <= pvprangkdata[i].RankingScoreTo then
			name = Lang(pvprangkdata[i].RankingTitle)
		end
	end

	if name == nil then
		if score > pvprangkdata[#pvprangkdata].RankingScoreTo then
			name = Lang(pvprangkdata[#pvprangkdata].RankingTitle)
		elseif score < pvprangkdata[1].RankingScoreFrom then
			name = Lang(pvprangkdata[1].RankingTitle)
		end
	end

	return name
end

function InfoPVP:GetIconNamebyscore(score)
	local name

	for i = 1, #pvprangkdata do
		if score >= pvprangkdata[i].RankingScoreFrom and score <= pvprangkdata[i].RankingScoreTo then
			name = pvprangkdata[i].RankingIcon
		end
	end

	if name == nil then
		name = pvprangkdata[#pvprangkdata].RankingIcon
	end

	return name
end

function InfoPVP:IsRankLevelUp()
	if not self.befScore then
		return false
	end

	local function func(score)
		local name

		for i = 1, #pvprangkdata do
			if score >= pvprangkdata[i].RankingScoreFrom and score < pvprangkdata[i].RankingScoreTo then
				name = pvprangkdata[i].RankingId
			end
		end

		if score > 0 and name == nil then
			name = pvprangkdata[#pvprangkdata].RankingId
		end

		return name
	end

	local beforeRankId = func(self.befScore)
	local curRankId = func(self.curScore)

	if beforeRankId ~= curRankId then
		return true
	end

	return false
end

function InfoPVP:GetIdbyscore()
	local name
	local score = self:GetSeasondata().player.seasonRankingScore

	for i = 1, #pvprangkdata do
		if score >= pvprangkdata[i].RankingScoreFrom and score < pvprangkdata[i].RankingScoreTo then
			name = pvprangkdata[i].RankingId
		end
	end

	if score > 0 and name == nil then
		name = pvprangkdata[#pvprangkdata].RankingId
	end

	return name
end

function InfoPVP:GetCurrentRankId()
	return self.SelfPVPPlayerinfo.seasonRankingAward
end

function InfoPVP:SetCurrentRankId(num)
	self.SelfPVPPlayerinfo.seasonRankingAward = num
end

function InfoPVP:GetStageid()
	local name
	local score = self:GetSeasondata().player.seasonRankingScore

	for i = 1, #pvprangkdata do
		if score >= pvprangkdata[i].RankingScoreFrom and score < pvprangkdata[i].RankingScoreTo then
			name = pvprangkdata[i].StageId
		end
	end

	if name == nil then
		name = pvprangkdata[#pvprangkdata].StageId
	end

	return name
end

function InfoPVP:GetCurrentvaluebyscore(score)
	local max = 0

	for i = 1, #pvprangkdata do
		if score >= pvprangkdata[i].RankingScoreFrom and score <= pvprangkdata[i].RankingScoreTo then
			max = pvprangkdata[i].RankingScoreTo
		end
	end

	max = score > pvprangkdata[#pvprangkdata].RankingScoreTo and 1 or score / max

	return max
end

function InfoPVP:GetNextRankScorebyscore(score)
	local max = 0

	for i = 1, #pvprangkdata do
		if score >= pvprangkdata[i].RankingScoreFrom and score <= pvprangkdata[i].RankingScoreTo then
			max = pvprangkdata[i].RankingScoreTo
		end
	end

	if score > pvprangkdata[#pvprangkdata].RankingScoreTo then
		max = "-"
	end

	return max
end

function InfoPVP:GetNextIconbyscore(score)
	local name
	local index = 0

	for i = 1, #pvprangkdata do
		if score >= pvprangkdata[i].RankingScoreFrom and score <= pvprangkdata[i].RankingScoreTo then
			index = i
		end
	end

	name = pvprangkdata[#pvprangkdata].RankingIcon

	if index ~= 0 then
		index = index + 1

		if index <= #pvprangkdata then
			name = pvprangkdata[index].RankingIcon
		end
	end

	return name
end

function InfoPVP:GetNextNamebyscore(score)
	local data = {}
	local name
	local index = 0

	for i = 1, #pvprangkdata do
		if score >= pvprangkdata[i].RankingScoreFrom and score <= pvprangkdata[i].RankingScoreTo then
			index = i
		end
	end

	data.max = 0

	if index ~= 0 then
		index = index + 1

		if index <= #pvprangkdata then
			name = Lang(pvprangkdata[index].RankingTitle)
		else
			name = _("Desc_PVPGradeMax")
			data.max = 1
		end
	else
		name = _("Desc_PVPGradeMax")
		data.max = 1
	end

	data.name = name

	return data
end

function InfoPVP:GetOpponentsList(opplist)
	local opponentsList = {}

	for i = 1, 4 do
		local info = self:GetOtherPVPPlayerinfo(opplist[i])

		table.insert(opponentsList, info)
	end

	return opponentsList
end

function InfoPVP:GetSeasonConfigdata(id)
	return pvpseasondata[id]
end

function InfoPVP:GetSubSeasonRankRewarddata()
	local rank = self.SelfPVPPlayerinfo.subSeasonRankingNo
	local rewardtable = {}

	for i = 1, #pvpsubseasonrankdata do
		if rank >= pvpsubseasonrankdata[i].RankingNoFrom and rank < pvpsubseasonrankdata[i].RankingNoTo then
			rewardtable = pvpsubseasonrankdata[i].RankingAwardList
		end
	end

	return rewardtable
end

function InfoPVP:GetAllSubSeasonRankRewarddata()
	local rewardtable = {}

	for i = 1, #pvpsubseasonrankdata do
		local info = {}

		info.reward = pvpsubseasonrankdata[i].RankingAwardList
		info.RankingId = pvpsubseasonrankdata[i].RankingId
		info.RankingNoFrom = pvpsubseasonrankdata[i].RankingNoFrom
		info.RankingNoTo = pvpsubseasonrankdata[i].RankingNoTo

		table.insert(rewardtable, info)
	end

	return rewardtable
end

function InfoPVP:GetAllSeasonRankRewarddata()
	self.rewardRankawardtable = {}

	local isNew = false

	for i = 1, #pvpseasonrewarddata do
		local info = {}

		info.reward = pvpseasonrewarddata[i].RankingAwardList
		info.RankingId = pvpseasonrewarddata[i].RankingId
		info.icon = pvprangkdata[info.RankingId].RankingIcon
		info.RankingTitle = pvprangkdata[info.RankingId].RankingTitle

		if pvpseasonrewarddata[i].RankingId <= self.SelfPVPPlayerinfo.seasonRankingAward then
			info.rewardtype = 1
		elseif pvpseasonrewarddata[i].RankingId > self.SelfPVPPlayerinfo.seasonRankingAward then
			info.rewardtype = 2
		end

		if self:GetIdbyscore() < pvpseasonrewarddata[i].RankingId or self.PBPVPSeason.player.seasonRankingScore == 0 then
			info.rewardtype = 3
		end

		if info.rewardtype == 2 then
			isNew = true
		end

		table.insert(self.rewardRankawardtable, info)
	end

	table.sort(self.rewardRankawardtable, function(a, b)
		return a.RankingId > b.RankingId
	end)

	return self.rewardRankawardtable
end

function InfoPVP:SetSeasonRankRewarddata(index)
	self.rewardRankawardtable[index].rewardtype = 1

	PVPRDL.SubPVPRankAward(index)
end

function InfoPVP:GetSeasonRewarddata()
	return pvpseasonrewarddata
end

function InfoPVP:CreateAgent(teamType)
	local data = {}

	data.isPvp = true
	data.isPvpAtk = false

	if teamType == 2 then
		data.isPvpAtk = true
	end

	data.slotSpacing = 14

	function data.battleCall()
		self:BattleCall()
	end

	function data.teamFullReturnCall(...)
		self:RequestChange(...)
	end

	function data.teamBondageChangeCall(...)
		self:RequestBondageChange(...)
	end

	data.noLevelUnlockSup = true
	data.noBattleBeginBtn = teamType == 1 and true or false
	data.noSwitchTeam = true
	data.noTeamSumCost = true
	data.teamCount = 1
	data.teamIndex = 1
	data.teamList = {}

	for j = 1, data.teamCount do
		local teamData = {}

		teamData.slotCount = CONST_NUM_OF_TEAM
		teamData.slotList = {}

		for i = 1, teamData.slotCount do
			local slotData = {}

			slotData.index = i

			local upCardId = 0
			local addCardId = 0

			if teamType == 1 then
				upCardId = self.rocardtable[i].id
				addCardId = self.rocardtable[i + teamData.slotCount].id
			else
				upCardId = self.attackrolecardtable[i].id
				addCardId = self.attackrolecardtable[i + teamData.slotCount].id
			end

			if upCardId ~= 0 then
				slotData.upInfoRoleCard = RoleCardMgr:GetRoleCard(upCardId)
				slotData.upInfoRole = RoleCardMgr:GetRole(upCardId)
			end

			if addCardId ~= 0 then
				slotData.addInfoRoleCard = RoleCardMgr:GetRoleCard(addCardId)
				slotData.addInfoRole = RoleCardMgr:GetRole(addCardId)
			end

			local teamSlotAgent = TeamSlotAgent(slotData)

			table.insert(teamData.slotList, teamSlotAgent)
		end

		if teamType == 2 then
			teamData.fetterTeamId = self.SelfPVPPlayerinfo.attackingFetterTeamId or 0
		else
			teamData.fetterTeamId = self.SelfPVPPlayerinfo.defensiveFetterTeamId or 0
		end

		local teamAgent = TeamAgent(teamData)

		table.insert(data.teamList, teamAgent)
	end

	self.teamSystemAgent = TeamSystemAgent(data)

	return self.teamSystemAgent
end

function InfoPVP:RequestChange(callback)
	local idtable = {}

	for i = 1, CONST_NUM_OF_TEAM do
		local id = self.teamSystemAgent.teamList[1].slotList[i].upInfoRoleCard.id

		table.insert(idtable, id)
	end

	for i = 1, CONST_NUM_OF_TEAM do
		if self.teamSystemAgent.teamList[1].slotList[i].addInfoRoleCard then
			local addid = self.teamSystemAgent.teamList[1].slotList[i].addInfoRoleCard.id

			table.insert(idtable, addid)
		else
			table.insert(idtable, 0)
		end
	end

	self:RequestSetFormation(self.NumType, idtable, callback)
end

function InfoPVP:RequestBondageChange(bondageId, callback)
	local idtable = {}

	for i = 1, CONST_NUM_OF_TEAM do
		local id = self.teamSystemAgent.teamList[1].slotList[i].upInfoRoleCard.id

		table.insert(idtable, id)
	end

	for i = 1, CONST_NUM_OF_TEAM do
		if self.teamSystemAgent.teamList[1].slotList[i].addInfoRoleCard then
			local addid = self.teamSystemAgent.teamList[1].slotList[i].addInfoRoleCard.id

			table.insert(idtable, addid)
		else
			table.insert(idtable, 0)
		end
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			if self.NumType == 1 then
				self.SelfPVPPlayerinfo.defensiveFetterTeamId = bondageId
			else
				self.SelfPVPPlayerinfo.attackingFetterTeamId = bondageId
			end

			self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex].fetterTeamId = bondageId

			if callback then
				callback()
			end
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	if self.NumType == 2 then
		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestSetTeam(self.PBPVPSeason.seasonId, self.PBPVPSeason.subSeasonNum, idtable, nil, bondageId, nil, wrap_cb)
	elseif self.NumType == 1 then
		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestSetTeam(self.PBPVPSeason.seasonId, self.PBPVPSeason.subSeasonNum, nil, idtable, nil, bondageId, wrap_cb)
	end
end

function InfoPVP:TeamSucess(callBack)
	if self.NumType == 1 then
		self.SelfPVPPlayerinfo.defensiveFetterTeamId = self:GetFetterTeamId()
		self.rocardtable = {}
		self.defensiveRoleCards = {}

		for i = 1, CONST_NUM_OF_TEAM do
			local uprole = self.teamSystemAgent.teamList[1].slotList[i].upInfoRoleCard

			table.insert(self.rocardtable, uprole)
			table.insert(self.defensiveRoleCards, {
				id = uprole.id
			})
		end

		for i = 1, CONST_NUM_OF_TEAM do
			if self.teamSystemAgent.teamList[1].slotList[i].addInfoRoleCard then
				local addrole = self.teamSystemAgent.teamList[1].slotList[i].addInfoRoleCard

				table.insert(self.rocardtable, addrole)
				table.insert(self.defensiveRoleCards, {
					id = addrole.id
				})
			else
				local ro = {}

				ro.id = 0

				table.insert(self.rocardtable, ro)
				table.insert(self.defensiveRoleCards, {
					id = 0
				})
			end
		end
	else
		self.SelfPVPPlayerinfo.attackingFetterTeamId = self:GetFetterTeamId()
		self.attackrolecardtable = {}

		for i = 1, CONST_NUM_OF_TEAM do
			local uprole = self.teamSystemAgent.teamList[1].slotList[i].upInfoRoleCard

			table.insert(self.attackrolecardtable, uprole)
		end

		for i = 1, CONST_NUM_OF_TEAM do
			if self.teamSystemAgent.teamList[1].slotList[i].addInfoRoleCard then
				local addrole = self.teamSystemAgent.teamList[1].slotList[i].addInfoRoleCard

				table.insert(self.attackrolecardtable, addrole)
			else
				local ro = {}

				ro.id = 0

				table.insert(self.attackrolecardtable, ro)
			end
		end
	end

	if callBack ~= nil then
		callBack()
	end

	Event.Instance:Fire("setTeamover", self)
end

function InfoPVP:BattleCall()
	local function callback()
		self:RequestBattleStart()
	end

	self:RequestChange(callback)
end

function InfoPVP:SetOtherPlayerData(opponents)
	self.opponents = opponents
end

function InfoPVP:SetRankUpReward(pb)
	self.newHigherRank = true
	self.bestRankingUp = pb.bestRankingUp
	self.bestRankingAward = pb.bestRankingAward
end

function InfoPVP:GetDailyBattleNum(seasonId)
	local baseNum = InfoPVP:GetSeasonConfigdata(seasonId).DailyBattleNum
	local _, num = ShopManager:GetGoodsMonthPrivilegeFuncInfo(ShopManager.MonthPrivilegeFunc.Func1)

	return baseNum + num
end

function InfoPVP:RequestBuyBattleNum(callback)
	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestBuyPVPBattleNum(function(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Sucess then
			self.SelfPVPPlayerinfo:BuyBattleNum()
			callback()
		else
			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end)
end

return InfoPVP
