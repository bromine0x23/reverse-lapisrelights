-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoTeamBossRaid.lua

require("UI/Page/PageTeam/TeamSystemAgent")

local InfoTeamBossRaid = {}

function InfoTeamBossRaid:SetData(pbChapterTeam)
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

function InfoTeamBossRaid:EnterStage(infoStage)
	self.infoStage = infoStage
	self.stageId = self.infoStage.data.ID

	self:CreateTeamSystemAgent()
end

function InfoTeamBossRaid:CreateTeamSystemAgent()
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
		self:BossRaidBattleCall()
	end

	function data.teamChangeCall(...)
		self:TeamBossRaidChangeCall(...)
	end

	function data.teamBondageChangeCall(...)
		self:TeamBossRaidBondageChangeCall(...)
	end

	data.isRaid = true
	data.isBossRaid = true
	data.noSupCard = true
	data.noLevelUnlockSup = true
	data.noSwitchTeam = true
	data.noFittingRoomBtn = false
	self.teamSystemAgent = TeamSystemAgent(data)
end

function InfoTeamBossRaid:GetStageRecommendJob()
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

function InfoTeamBossRaid:SetBattleTeamInfo(data)
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

function InfoTeamBossRaid:BossRaidBattleCall()
	LoadingMgr.Show(eLoadingType.Repeat, 42)

	local chapterTeam = self.stageTeams[self.teamSystemAgent.teamIndex]
	local slotList = self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex].slotList
	local helperId
	local listRole = {}
	local listRoleCard = {}
	local listAddRoleCard = {}

	for i, slot in ipairs(slotList) do
		table.insert(listRole, slot.upInfoRole)
		slot.upInfoRoleCard:SetCardHpPercentBeforeBattle(true, true)
		table.insert(listRoleCard, slot.upInfoRoleCard)

		listAddRoleCard[i] = slot.addInfoRoleCard
	end

	local monsterHpRates = {}
	local infoBattleStage = InfoBattleStage(self.infoStage.id)
	local enemy = {}

	if infoBattleStage then
		enemy = infoBattleStage.data.Enemy or {}
	end

	local infoRaid = UnionRaidMgr:GetBossRaidByStageId(self.infoStage.id)
	local hpPercent = infoRaid and infoRaid.progress or 1

	for _, waveEnemys in ipairs(enemy) do
		for i, UnitId in ipairs(waveEnemys) do
			table.insert(monsterHpRates, hpPercent)
		end
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
			vParam.monsterHpRates = monsterHpRates
			vParam.chaos = {
				norce = pb.chaos.norce,
				ut = pb.chaos.ut,
				signature = pb.chaos.signature
			}

			if chapterTeam.fetterTeamId and chapterTeam.fetterTeamId ~= 0 then
				vParam.bondage = CombBondageMgr.DealWithBattleBondage(chapterTeam.roleCardTeams, CombinationMgr:Get(chapterTeam.fetterTeamId).pbTeamFetter)
			end

			vParam.unionSkills = UnionSkillMgr:GetUnionSkill(eTalentType.Battle)
			vParam.skills = {}
			vParam.deSkills = {}
			vParam.monsterBlood = {}
			vParam.monsterMaxHp = {}

			if pb.skills then
				local temp = {}

				for i, val in ipairs(pb.skills) do
					if not temp[val.id] then
						temp[val.id] = {}

						table.insert(vParam.skills, {
							id = val.id,
							lv = val.level
						})
					end
				end
			end

			if pb.deSkills then
				local temp = {}

				for i, val in ipairs(pb.deSkills) do
					if not temp[val.id] then
						temp[val.id] = {}

						table.insert(vParam.deSkills, {
							id = val.id,
							lv = val.level
						})
					end
				end
			end

			if pb.monsterBlood then
				for i, val in ipairs(pb.monsterBlood) do
					table.insert(vParam.monsterBlood, tonumber(val))
				end
			end

			if pb.monsterTotalBlood then
				for i, val in ipairs(pb.monsterTotalBlood) do
					table.insert(vParam.monsterMaxHp, tonumber(val))
				end
			end

			local game = require("GameLogic/RunGame")

			game:Run(vParam)
		else
			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end

	NetManager:RequestStartStage(self.stageId, chapterTeam, false, wrap_cb, helperId)
end

function InfoTeamBossRaid:TeamBossRaidChangeCall(callback)
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

		if vMsg.result.code == NetManager.Result_Sucess then
			for i, v in ipairs(team) do
				self.stageTeams[self.teamSystemAgent.teamIndex].roleCardTeams[i] = v
			end
		elseif vMsg.result.code == 2 then
			PageUnion.GoBackMainPage(vMsg)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end

		if callback then
			callback()
		end
	end

	NetManager:RequestChangeMirrorTeam({}, team, 0, 0, wrap_cb)
end

function InfoTeamBossRaid:TeamBossRaidBondageChangeCall(bondageId, callback)
	LoadingMgr.Show(eLoadingType.Repeat, 186)

	local teamBossRaid = self.stageTeams[self.teamSystemAgent.teamIndex].roleCardTeams
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

	NetManager:RequestChangeMirrorTeam(teamBossRaid, {}, 0, option, wrap_cb)
end

function InfoTeamBossRaid:GetUpRoleCardList()
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

function InfoTeamBossRaid:GetUpRoleList()
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

return InfoTeamBossRaid
