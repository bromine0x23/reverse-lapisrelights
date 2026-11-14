-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoTeamRaid.lua

require("UI/Page/PageTeam/TeamSystemAgent")

local InfoTeamRaid = {}

function InfoTeamRaid:SetData(pbChapterTeam)
	if pbChapterTeam == nil then
		local chapterTeam = {
			fetterTeamId = 0,
			roleCardTeams = {
				0,
				0,
				0,
				0,
				0
			}
		}

		self.stageTeams = {
			chapterTeam
		}
	end

	self.stageTeams = {
		pbChapterTeam
	}
end

function InfoTeamRaid:EnterStage(infoStage)
	self.infoStage = infoStage
	self.stageId = infoStage.data.ID

	self:CreateTeamSystemAgent()
end

function InfoTeamRaid:CreateTeamSystemAgent()
	local data = {}

	data.teamCount = 1
	data.teamIndex = 1
	data.teamList = {}

	self:SetBattleTeamInfo(data)

	data.monsterJob = self:GetStageRecommendJob() ~= "" and self:GetStageRecommendJob() or nil

	JobCheckingUtil.Init()

	data.recommendJob = JobCheckingUtil.GetStrong(self:GetStageRecommendJob()) ~= "" and JobCheckingUtil.GetStrong(self:GetStageRecommendJob()) or nil
	data.battleCost = ChapterMgr:GetStageBattleCost(self.infoStage)

	function data.battleCall()
		self:RaidBattleCall()
	end

	function data.teamChangeCall(...)
		self:TeamRaidChangeCall(...)
	end

	function data.teamBondageChangeCall(...)
		self:TeamRaidBondageChangeCall(...)
	end

	data.isRaid = true
	data.noSupCard = true
	data.noLevelUnlockSup = true
	data.noSwitchTeam = true
	data.noFittingRoomBtn = false
	self.teamSystemAgent = TeamSystemAgent(data)
end

function InfoTeamRaid:GetStageRecommendJob()
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

function InfoTeamRaid:SetBattleTeamInfo(data)
	for i = 1, data.teamCount do
		local stageTeam = self.stageTeams[i]
		local teamData = {}

		teamData.slotCount = 5
		teamData.fetterTeamId = stageTeam.fetterTeamId or 0
		teamData.slotList = {}

		for j = 1, teamData.slotCount do
			local slotData = {}

			slotData.index = j

			local upCardId = stageTeam.roleCardTeams[j]

			if upCardId and upCardId ~= 0 then
				slotData.upInfoRole = RoleCardMgr:GetRole(upCardId)
				slotData.upInfoRoleCard = RoleCardMgr:GetRoleCard(upCardId)
			end

			local teamSlotAgent = TeamSlotAgent(slotData)

			table.insert(teamData.slotList, teamSlotAgent)
		end

		local teamAgent = TeamAgent(teamData)

		table.insert(data.teamList, teamAgent)
	end
end

function InfoTeamRaid:RaidBattleCall()
	LoadingMgr.Show(eLoadingType.Repeat, 42)

	local chapterTeam = self.stageTeams[self.teamSystemAgent.teamIndex]
	local teamAgent = self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex]
	local helperId
	local listRole = {}
	local listRoleCard = {}
	local listAddRoleCard = {}

	for k, slot in ipairs(teamAgent.slotList) do
		table.insert(listRole, slot.upInfoRole)
		slot.upInfoRoleCard:SetCardHpPercentBeforeBattle(true)
		table.insert(listRoleCard, slot.upInfoRoleCard)

		listAddRoleCard[k] = slot.addInfoRoleCard
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
			UnionRaidMgr.RaidBeginTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

			local vParam = {}

			vParam.stageId = self.stageId
			vParam.chapterTeam = chapterTeam
			vParam.boutId = pb.boutId
			vParam.player1 = {
				listRole,
				listRoleCard,
				listAddRoleCard
			}
			vParam.randomSeed = pb.boutSeed[1]
			vParam.randomSeedForReward = pb.boutSeed[2]

			local max = GetConfigArgInt("StageWhipAwardBoxMaxNum")

			vParam.whipMaxNum = max - InfoGameInst:GetWhipAwardBoxNum()
			vParam.chaos = {
				norce = pb.chaos.norce,
				ut = pb.chaos.ut,
				signature = pb.chaos.signature
			}

			if chapterTeam.fetterTeamId and chapterTeam.fetterTeamId ~= 0 then
				vParam.bondage = CombBondageMgr.DealWithBattleBondage(chapterTeam.roleCardTeams, CombinationMgr:Get(chapterTeam.fetterTeamId).pbTeamFetter)
			end

			vParam.unionSkills = UnionSkillMgr:GetUnionSkill(eTalentType.Battle)

			local list = UnionRaidMgr.GetBuffByType(eTalentType.Battle)

			for _, v in ipairs(list) do
				table.insert(vParam.unionSkills, v)
			end

			local game = require("GameLogic/RunGame")

			game:Run(vParam)
		else
			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end

	local raidId

	if UnionRaidMgr.beingCommRaid then
		raidId = UnionRaidMgr.beingCommRaid.id
	end

	NetManager:RequestStartStage(self.stageId, chapterTeam, false, wrap_cb, helperId, nil, raidId)
end

function InfoTeamRaid:TeamRaidChangeCall(callback)
	LoadingMgr.Show(eLoadingType.Repeat, 186)

	local teamAgent = self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex]
	local team = {}

	for i, slot in ipairs(teamAgent.slotList) do
		if slot.upInfoRoleCard ~= nil then
			team[i] = slot.upInfoRoleCard.id
		else
			team[i] = 0
		end
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat, 186)

		if callback then
			callback()
		end

		if vMsg.result.code == NetManager.Result_Sucess then
			for i, v in ipairs(team) do
				self.stageTeams[self.teamSystemAgent.teamIndex].roleCardTeams[i] = v
			end
		elseif vMsg.result.code == 2 then
			PageUnion.GoBackMainPage(vMsg)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestChangeMirrorTeam(team, {}, 0, 0, wrap_cb)
end

function InfoTeamRaid:TeamRaidBondageChangeCall(bondageId, callback)
	LoadingMgr.Show(eLoadingType.Repeat, 186)

	local teamRaid = self.stageTeams[self.teamSystemAgent.teamIndex].roleCardTeams
	local option = -1

	if bondageId ~= nil and bondageId ~= 0 then
		option = bondageId
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat, 186)

		if vMsg.result.code == NetManager.Result_Sucess then
			self.stageTeams[self.teamSystemAgent.teamIndex].fetterTeamId = bondageId
			self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex].fetterTeamId = bondageId

			if callback then
				callback()
			end
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestChangeMirrorTeam(teamRaid, {}, option, 0, wrap_cb)
end

function InfoTeamRaid:GetUpRoleCardList()
	local ids = {}
	local chapterTeam = self.stageTeams[self.teamSystemAgent and self.teamSystemAgent.teamIndex or 1]

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

function InfoTeamRaid:GetUpRoleList()
	local ids = {}
	local chapterTeam = self.stageTeams[self.teamSystemAgent and self.teamSystemAgent.teamIndex or 1]

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

return InfoTeamRaid
