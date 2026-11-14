-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoTeamgGroup.lua

require("UI/Page/PageTeam/TeamSystemAgent")

local StageData = require("luaData/StageData")
local battleStageData = require("luaData/BattleStage")
local TimelineData = require("luaData/TimelineData")
local RoleCardData = require("luaData/CharacterCard")
local InfoTeamgGroup = {}

function InfoTeamgGroup:SetData(stageTeams)
	table.sort(stageTeams, function(a, b)
		return a.id < b.id
	end)

	self.stageTeams = {}

	for i = 6, #stageTeams do
		table.insert(self.stageTeams, stageTeams[i])
	end
end

function InfoTeamgGroup:EnterStage(infoStage, callback)
	self.infoStage = infoStage
	self.stageId = self.infoStage.data.ID
	self.groupId = ChapterMgr:GetChapterByStage(self.stageId).data.Team
	self.isLimit = self.infoStage:IsLimit()

	self:CreateTeamSystemAgent()
end

function InfoTeamgGroup:CreateTeamSystemAgent()
	local data = {}

	data.teamCount = 1
	data.teamList = {}
	data.teamIndex = 1

	self:SetBattleTeamInfo(data)

	data.isTeamGroup = true
	data.noSwitchTeam = true
	data.monsterJob = self:GetStageRecommendJob() ~= "" and self:GetStageRecommendJob() or nil

	JobCheckingUtil.Init()

	data.recommendJob = JobCheckingUtil.GetStrong(self:GetStageRecommendJob()) ~= "" and JobCheckingUtil.GetStrong(self:GetStageRecommendJob()) or nil
	data.battleCost = ChapterMgr:GetStageBattleCost(self.infoStage)

	function data.battleCall()
		self:BattleCall()
	end

	function data.teamChangeCall(...)
		self:TeamChangeCall(...)
	end

	function data.teamBondageChangeCall(...)
		self:TeamBondageChangeCall(...)
	end

	self.teamSystemAgent = TeamSystemAgent(data)
end

function InfoTeamgGroup:GetStageRecommendJob()
	if self.infoStage then
		local listEnemy = {}
		local isboss = false
		local BattleStageData = require("luaData/BattleStage")
		local infoEnemy = BattleStageData[self.infoStage.data.BattleStageID].Enemy

		for i = 1, #infoEnemy do
			for n = 1, #infoEnemy[i] do
				local enemyId = infoEnemy[i][n]
				local enemy = EnemyManager:Get(enemyId).data
				local job = enemy.Job

				if enemy.Boss ~= 0 then
					isboss = true

					return job
				end

				if #listEnemy == 0 then
					local temp = {}

					temp.enemyId = enemyId
					temp.num = 1
					temp.job = job

					table.insert(listEnemy, temp)
				else
					local idx

					for j = 1, #listEnemy do
						if enemyId == listEnemy[j].enemyId then
							idx = j

							break
						end
					end

					if idx ~= nil then
						listEnemy[idx].num = listEnemy[idx].num + 1
					else
						local temp = {}

						temp.enemyId = enemyId
						temp.job = job
						temp.num = 1

						table.insert(listEnemy, temp)
					end
				end
			end
		end

		local function func(a, b)
			if tonumber(a.num) == tonumber(b.num) then
				return tonumber(a.enemyId) < tonumber(b.enemyId)
			else
				return tonumber(a.num) > tonumber(b.num)
			end
		end

		table.sort(listEnemy, func)

		for m = 1, #listEnemy do
			if GetJobType(listEnemy[m].job) ~= 5 then
				return listEnemy[m].job
			end
		end

		return "Assistance"
	end
end

local function GetUseCardId(cardId)
	local id = cardId

	if cardId ~= 0 then
		local infoCard = RoleCardMgr:GetRoleCard(cardId)

		if not infoCard.isHold then
			local listCard = RoleCardMgr:GetRoleHoldCard(infoCard.data.CharacterID)

			id = listCard[1].id
		end
	end

	return id
end

function InfoTeamgGroup:SetBattleTeamInfo(teamSystemAgentData)
	local stageTeam = self.stageTeams[self.groupId]
	local teamData = {}

	teamData.slotCount = 5
	teamData.name = stageTeam.name
	teamData.slotList = {}

	for j = 1, teamData.slotCount do
		local slotData = {}

		if self.isLimit then
			slotData.limit = StageData[self.stageId].LimitList[j]

			local upCardId = stageTeam.roleCardTeams[j]
			local addCardId = stageTeam.roleCardTeams[j + 5]

			if upCardId ~= 0 then
				slotData.upInfoRoleCard = RoleCardMgr:GetRoleCard(upCardId)
				slotData.upInfoRole = RoleCardMgr:GetRole(upCardId)
			end

			if addCardId ~= 0 then
				slotData.addInfoRoleCard = RoleCardMgr:GetRoleCard(addCardId)
				slotData.addInfoRole = RoleCardMgr:GetRole(addCardId)
			end
		end

		teamSystemAgentData.needBondage = true
		teamData.fetterTeamId = stageTeam.fetterTeamId
		slotData.isHelperSlot = j == 5 and self.infoStage.data.EnSupport == 1
		slotData.isHelperCard = false
		slotData.index = j

		local slotAgent = TeamSlotAgent(slotData)

		table.insert(teamData.slotList, slotAgent)
	end

	local teamAgent = TeamAgent(teamData)

	table.insert(teamSystemAgentData.teamList, teamAgent)
end

function InfoTeamgGroup:BattleCall()
	LoadingMgr.Show(eLoadingType.Repeat, 42)

	local chapterTeam = {}

	chapterTeam.roleCardTeams = {}

	local team = InfoTeamgGroup.stageTeams[self.groupId]

	chapterTeam.id = team.id
	chapterTeam.fetterTeamId = team.fetterTeamId

	for _, v in ipairs(team.roleCardTeams) do
		table.insert(chapterTeam.roleCardTeams, v or 0)
	end

	local helperId
	local teamAgent = self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex]
	local slotList = teamAgent.slotList
	local listRole = {}
	local listRoleCard = {}
	local listAddRoleCard = {}

	for i, slot in ipairs(slotList) do
		slot.upInfoRoleCard:SetCardHpPercentBeforeBattle()

		if slot.isHelperCard then
			helperId = slot.upInfoRoleCard.pb.playerId
		end

		table.insert(listRole, slot.upInfoRole)
		table.insert(listRoleCard, slot.upInfoRoleCard)

		listAddRoleCard[i] = slot.addInfoRoleCard
		chapterTeam.roleCardTeams[i] = slot.upInfoRoleCard.id
		chapterTeam.roleCardTeams[i + teamAgent.slotCount] = slot.addInfoRoleCard and slot.addInfoRoleCard.id or 0
	end

	if helperId ~= nil then
		chapterTeam.id = nil
	end

	local skillBuffList = OperationActiveMgr:GetUsefulSkillByStageId(self.stageId)

	if #skillBuffList > 0 then
		for i = 1, #listRoleCard do
			local cardBufflist = {}

			for _, skillInfo in ipairs(skillBuffList) do
				if OperationActiveMgr:CheakIsActiveByCardId(listRoleCard[i].id, skillInfo) then
					for _, BuffSkillID in ipairs(skillInfo.BuffSkillID) do
						table.insert(cardBufflist, BuffSkillID)
					end
				end
			end

			listRole[i]:UpdateSkillBuffAttr(cardBufflist)
		end
	else
		for i = 1, #listRoleCard do
			listRole[i]:UpdateSkillBuffAttr({})
		end
	end

	local function wrap_cb(pb)
		LoadingMgr.Hide(eLoadingType.Repeat, 42)

		if pb.result.code == NetManager.Result_Sucess then
			local vParam = {}

			vParam.stageId = self.stageId
			vParam.chapterTeam = chapterTeam
			vParam.boutId = pb.boutId

			if helperId ~= nil then
				TeamSystemAgentMgr.UpdateMineMaxCombatPower(pb.maxAttribute or 0)
				TeamSystemAgentMgr:HelperAttriModify(listRoleCard[#listRoleCard], listRole[#listRole])
			end

			vParam.player1 = {
				listRole,
				listRoleCard,
				listAddRoleCard
			}
			vParam.randomSeed = pb.boutSeed[1]
			vParam.randomSeedForReward = pb.boutSeed[2]
			vParam.chaos = {
				norce = pb.chaos.norce,
				ut = pb.chaos.ut,
				signature = pb.chaos.signature
			}

			local max = GetConfigArgInt("StageWhipAwardBoxMaxNum")

			vParam.whipMaxNum = max - InfoGameInst:GetWhipAwardBoxNum()

			if chapterTeam.fetterTeamId and chapterTeam.fetterTeamId ~= 0 then
				vParam.bondage = CombBondageMgr.DealWithBattleBondage(chapterTeam.roleCardTeams, CombinationMgr:Get(chapterTeam.fetterTeamId).pbTeamFetter)
			end

			if UnionMgr.HasUnion() then
				vParam.unionSkills = UnionSkillMgr:GetUnionSkill(eTalentType.Battle)
			end

			local game = require("GameLogic/RunGame")

			game:Run(vParam)
		else
			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end

	NetManager:RequestStartStage(self.stageId, chapterTeam, false, wrap_cb, helperId)
end

function InfoTeamgGroup:TeamChangeCall(callback)
	LoadingMgr.Show(eLoadingType.Repeat, 41)

	local chapterTeam = InfoTeamgGroup.stageTeams[self.groupId]
	local id = self.groupId + 5
	local name = chapterTeam.name
	local teamAgent = self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex]
	local slotList = teamAgent.slotList
	local ids = {}

	for i, slot in ipairs(slotList) do
		if slot.isHelperCard then
			ids[i] = 0
			ids[i + 5] = 0
		else
			if slot.upInfoRoleCard ~= nil then
				ids[i] = slot.upInfoRoleCard.id
			else
				ids[i] = 0
			end

			if slot.addInfoRoleCard ~= nil then
				ids[i + 5] = slot.addInfoRoleCard.id
			else
				ids[i + 5] = 0
			end
		end
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat, 41)

		if callback then
			callback()
		end

		if vMsg.result.code == NetManager.Result_Sucess then
			chapterTeam.name = name

			for i, v in ipairs(ids) do
				chapterTeam.roleCardTeams[i] = v
			end
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestSetFormation(id, name, ids, 0, wrap_cb)
end

function InfoTeamgGroup:TeamBondageChangeCall(bondageId, callback)
	local chapterTeam = self.stageTeams[self.groupId]
	local option = -1

	if bondageId ~= nil and bondageId ~= 0 then
		option = bondageId
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat, 41)

		if vMsg.result.code == NetManager.Result_Sucess then
			self.stageTeams[self.groupId].fetterTeamId = bondageId
			self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex].fetterTeamId = bondageId

			if callback then
				callback()
			end
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestSetFormation(self.groupId + 5, chapterTeam.name, chapterTeam.roleCardTeams, option, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat, 41)
end

function InfoTeamgGroup:GetUpRoleCardList(teamId)
	local ids = {}
	local chapterTeam = InfoTeamgGroup.stageTeams[teamId]

	if chapterTeam.roleCardTeams == nil then
		ids = {
			0,
			0,
			0,
			0,
			0
		}
	else
		for i = 1, 5 do
			table.insert(ids, chapterTeam.roleCardTeams[i])
		end
	end

	return ids
end

function InfoTeamgGroup:GetAddRoleCardList(teamId)
	local ids = {}
	local chapterTeam = InfoTeamgGroup.stageTeams[teamId]

	if chapterTeam.roleCardTeams == nil then
		ids = {
			0,
			0,
			0,
			0,
			0
		}
	else
		for i = 6, 10 do
			table.insert(ids, chapterTeam.roleCardTeams[i])
		end
	end

	return ids
end

function InfoTeamgGroup:GetUpRoleList()
	local ids = {}
	local chapterTeam = InfoTeam.stageTeams[1]

	if chapterTeam.roleCardTeams == nil then
		ids = {
			0,
			0,
			0,
			0,
			0
		}
	else
		for i = 1, 5 do
			local infoRoleCardId = chapterTeam.roleCardTeams[i]

			if infoRoleCardId == 0 then
				table.insert(ids, 0)
			else
				local infoRoleCard = RoleCardMgr:GetRoleCard(infoRoleCardId)

				table.insert(ids, infoRoleCard.data.CharacterID)
			end
		end
	end

	return ids
end

function InfoTeamgGroup:GetTimelineDataDanceNum()
	if self.infoStage then
		local BattleStageID = StageData[self.infoStage.data.ID].BattleStageID
		local LiveTimeLine = battleStageData[BattleStageID].LiveTimeLine

		if TimelineData[LiveTimeLine] then
			return TimelineData[LiveTimeLine].DanceNum
		end
	end

	return false
end

return InfoTeamgGroup
