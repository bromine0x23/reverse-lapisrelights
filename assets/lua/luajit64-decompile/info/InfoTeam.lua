-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoTeam.lua

require("UI/Page/PageTeam/TeamSystemAgent")

local StageData = require("luaData/StageData")
local battleStageData = require("luaData/BattleStage")
local TimelineData = require("luaData/TimelineData")
local RoleCardData = require("luaData/CharacterCard")
local InfoTeam = {}

function InfoTeam:SetData(stageTeams)
	self.teamCnt = 5
	self.slotCnt = 5

	table.sort(stageTeams, function(a, b)
		return a.id < b.id
	end)

	self.stageTeams = stageTeams

	for k, v in ipairs(self.stageTeams) do
		if k <= self.teamCnt and v.name == "" then
			v.name = Lang(12079) .. _("ecNum_" .. k)
		end
	end
end

function InfoTeam:EnterStage(infoStage, callback)
	self.infoStage = infoStage
	self.stageId = self.infoStage.data.ID
	self.isLimit = self.infoStage:IsLimit()
	self.teamListIndex = tonumber(RoleCardMgr:GetTeamListIndex())
	self.bossHp = nil
	self.raidBossId = nil

	if infoStage.raidBossId then
		self.raidBossId = infoStage.raidBossId
	end

	if infoStage.bossHp then
		self.bossHp = infoStage.bossHp
	end

	self:CreateTeamSystemAgent()
end

function InfoTeam:CreateTeamSystemAgent()
	local data = {}

	data.teamCount = 5
	data.teamList = {}
	data.teamIndex = 1

	if self.teamListIndex then
		data.teamIndex = self.teamListIndex
	end

	self:SetBattleTeamInfo(data)

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

	function data.teamNameChangeCall(...)
		self:TeamNameChangeCall(...)
	end

	function data.teamBondageChangeCall(...)
		self:TeamBondageChangeCall(...)
	end

	self.teamSystemAgent = TeamSystemAgent(data)
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

function InfoTeam:SetBattleTeamInfo(teamSystemAgentData)
	for i = 1, teamSystemAgentData.teamCount do
		local stageTeam = self.stageTeams[i]
		local teamData = {}

		teamData.slotCount = 5
		teamData.name = stageTeam.name
		teamData.slotList = {}

		for j = 1, teamData.slotCount do
			local slotData = {}

			if InstructionMgr.isOpen and self.stageId == GetConfigArgInt("GuideCard.StageID") and not self.infoStage:IsPass() then
				local listCardId = GetConfigArgJson("GuideFlow.ListRoleCardID2")
				local listAddCardId = {
					0,
					0,
					0,
					0,
					0
				}
				local upCardId = GetUseCardId(listCardId[j])
				local addCardId = GetUseCardId(listAddCardId[j])

				if upCardId ~= 0 then
					slotData.upInfoRoleCard = RoleCardMgr:GetRoleCard(upCardId)
					slotData.upInfoRole = RoleCardMgr:GetRole(upCardId)
				end

				if addCardId ~= 0 then
					slotData.addInfoRoleCard = RoleCardMgr:GetRoleCard(addCardId)
					slotData.addInfoRole = RoleCardMgr:GetRole(addCardId)
				end
			else
				if self.isLimit then
					slotData.limit = StageData[self.stageId].LimitList[j]

					if slotData.limit[1] == 2 then
						local upCardId = slotData.limit[2]

						if upCardId ~= 0 then
							slotData.upInfoRoleCard = RoleCardMgr:GetRoleCard(upCardId)
							slotData.upInfoRole = RoleCardMgr:GetRole(upCardId)
						end
					end
				else
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
				teamData.fetterTeamId = self.isLimit and 0 or stageTeam.fetterTeamId
			end

			slotData.isHelperSlot = j == 5 and self.infoStage.data.EnSupport == 1
			slotData.isHelperCard = false
			slotData.index = j

			local slotAgent = TeamSlotAgent(slotData)

			table.insert(teamData.slotList, slotAgent)
		end

		local teamAgent = TeamAgent(teamData)

		table.insert(teamSystemAgentData.teamList, teamAgent)
	end
end

function InfoTeam:BattleCall()
	LoadingMgr.Show(eLoadingType.Repeat, 42)

	local chapterTeam = {}

	chapterTeam.id = 0
	chapterTeam.name = ""
	chapterTeam.roleCardTeams = {}

	if InstructionMgr.isOpen and self.stageId == GetConfigArgInt("GuideCard.StageID") and not self.infoStage:IsPass() then
		self:SetBattleTeamInfo(self.teamSystemAgent)

		local listCardId = GetConfigArgJson("GuideFlow.ListRoleCardID2")
		local listAddCardId = {
			0,
			0,
			0,
			0,
			0
		}

		for _, v in pairs(listCardId) do
			table.insert(chapterTeam.roleCardTeams, GetUseCardId(v))
		end

		for _, n in pairs(listAddCardId) do
			table.insert(chapterTeam.roleCardTeams, GetUseCardId(n))
		end

		chapterTeam.fetterTeamId = 0
	else
		local team = InfoTeam.stageTeams[self.teamSystemAgent.teamIndex]

		chapterTeam.id = team.id
		chapterTeam.fetterTeamId = team.fetterTeamId

		for _, v in ipairs(team.roleCardTeams) do
			table.insert(chapterTeam.roleCardTeams, v or 0)
		end
	end

	local helperId
	local teamAgent = self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex]
	local slotList = teamAgent.slotList
	local listRole = {}
	local listRoleCard = {}
	local listAddRoleCard = {}
	local listAddAttributes = {}

	for i, slot in ipairs(slotList) do
		if slot.upInfoRoleCard ~= nil then
			slot.upInfoRoleCard:SetCardHpPercentBeforeBattle()
		end

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

	local defaultClothes

	if InstructionMgr.isOpen and self.stageId == GetConfigArgInt("GuideCard.StageID") and not self.infoStage:IsPass() then
		local listAvatarID = GetConfigArgJson("GuideFlow.ListAvatarID2")

		defaultClothes = {}

		for i = 1, #listRole do
			local infoRole = listRole[i]

			table.insert(defaultClothes, infoRole.pb.clothes)

			infoRole.pb.clothes = listAvatarID[i]
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

			if self.raidBossId then
				ActivityBossRaidMgr.curBossRaidId = tonumber(self.raidBossId)
				self.raidBossId = nil
			end

			if self.bossHp then
				self.bossHp = nil
			end

			if UnionMgr.HasUnion() then
				vParam.unionSkills = UnionSkillMgr:GetUnionSkill(eTalentType.Battle)
			end

			if InstructionMgr.isOpen and self.stageId == GetConfigArgInt("GuideCard.StageID") and not self.infoStage:IsPass() then
				function vParam.callBack()
					for i = 1, #listRole do
						local infoRole = listRole[i]

						infoRole.pb.clothes = defaultClothes[i]
					end
				end
			end

			if self.infoStage.data.ChapterType == ChapterFromType.bosslive then
				InfoBGMEventMgr:Clear()
			end

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

			if self.teamSystemAgent.isGvg then
				for i, upInfoRoleCard in ipairs(listRoleCard) do
					upInfoRoleCard:SetHpPercent(upInfoRoleCard.curGvgHpPer)
				end

				local stage = Infogvg.stage:Get(self.stageId)

				if stage then
					stage:SetBloodCost(vParam.monsterBlood)
				end

				Infogvg:Table(vParam.skills, "vParam.skills:")
				Infogvg:Table(vParam.deSkills, "vParam.deSkills:")
				Infogvg:Table(vParam.monsterBlood, "vParam.monsterBlood:")
				Infogvg:Table(vParam.monsterMaxHp, "vParam.monsterMaxHp:")
			end

			local game = require("GameLogic/RunGame")

			game:Run(vParam)
		else
			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end

	if self.infoStage.data.ChapterType == ChapterFromType.bosslive and BossliveChapterMgr.GetBossliveRemainingChallengeNum() == 0 then
		LoadingMgr.Hide(eLoadingType.Repeat, 42)

		local vParam = {}

		vParam.stageId = self.stageId
		vParam.chapterTeam = chapterTeam
		vParam.boutId = -1
		vParam.player1 = {
			listRole,
			listRoleCard,
			listAddAttributes
		}
		vParam.randomSeed = 3382
		vParam.randomSeedForReward = 2249

		local max = GetConfigArgInt("StageWhipAwardBoxMaxNum")

		vParam.whipMaxNum = max - InfoGameInst:GetWhipAwardBoxNum()

		if chapterTeam.fetterTeamId and chapterTeam.fetterTeamId ~= 0 then
			vParam.bondage = CombBondageMgr.DealWithBattleBondage(chapterTeam.roleCardTeams, CombinationMgr:Get(chapterTeam.fetterTeamId).pbTeamFetter)
		end

		if self.raidBossId then
			ActivityBossRaidMgr.curBossRaidId = tonumber(self.raidBossId)
			self.raidBossId = nil
		end

		if self.monsterHpRates then
			vParam.monsterHpRates = self.monsterHpRates
			self.monsterHpRates = nil
		end

		if InstructionMgr.isOpen and self.stageId == GetConfigArgInt("GuideCard.StageID") and not self.infoStage:IsPass() then
			function vParam.callBack()
				for i = 1, #listRole do
					local infoRole = listRole[i]

					infoRole.pb.clothes = defaultClothes[i]
				end
			end
		end

		local game = require("GameLogic/RunGame")

		game:Run(vParam)
		InfoBGMEventMgr:Clear()
	elseif Infogvg:Vaild(self.stageId) ~= nil then
		NetManager:RequestRepeatedBattle(tonumber(self.stageId), function(pb)
			if pb.result.code == NetManager.Result_Sucess then
				if pb.num == 0 then
					NetManager:RequestStartStage(self.stageId, chapterTeam, false, wrap_cb, helperId, self.raidBossId)
				else
					local function cb(_type)
						if _type == DlgCommonEvent.ButtonType.Ok then
							NetManager:RequestStartStage(self.stageId, chapterTeam, false, wrap_cb, helperId, self.raidBossId)
						else
							LoadingMgr.Hide(eLoadingType.Repeat, 42)
						end
					end

					UIMgr.ShowCommon(DlgCommonEvent.Type.Confirm, _("Desc_Alert"), _("Desc_GVG_tips_battle"), cb, _("UI_Yes"), _("UI_No"), false)
				end
			else
				LoadingMgr.Hide(eLoadingType.Repeat, 42)
				UIMgr.ShowMsg(pb.result.desc)
			end
		end)
	else
		NetManager:RequestStartStage(self.stageId, chapterTeam, false, wrap_cb, helperId, self.raidBossId)
	end
end

function InfoTeam:EnterNoAwardBosslive()
	return
end

function InfoTeam:TeamChangeCall(callback)
	if InstructionMgr.isOpen and self.stageId == GetConfigArgInt("GuideCard.StageID") and not self.infoStage:IsPass() then
		if callback then
			callback()
		end

		return
	end

	if not self.isLimit then
		LoadingMgr.Show(eLoadingType.Repeat, 41)

		local chapterTeam = InfoTeam.stageTeams[self.teamSystemAgent.teamIndex]
		local id = chapterTeam.id
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

			if vMsg.result.code == NetManager.Result_Sucess then
				chapterTeam.name = name

				for i, v in ipairs(ids) do
					chapterTeam.roleCardTeams[i] = v
				end
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end

			if callback then
				callback()
			end
		end

		NetManager:RequestSetFormation(id, name, ids, 0, wrap_cb)
	elseif callback then
		callback()
	end
end

function InfoTeam:TeamNameChangeCall(callback, name)
	if InstructionMgr.isOpen and self.stageId == GetConfigArgInt("GuideCard.StageID") and not self.infoStage:IsPass() then
		return
	end

	if not self.isLimit then
		local chapterTeam = self.stageTeams[self.teamSystemAgent.teamIndex]

		local function wrap_cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat, 41)

			if vMsg.result.code == NetManager.Result_Sucess then
				self.stageTeams[self.teamSystemAgent.teamIndex].name = name
				self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex].name = name

				if callback then
					callback()
				end
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		end

		NetManager:RequestSetFormation(chapterTeam.id, name, chapterTeam.roleCardTeams, chapterTeam.fetterTeamId, wrap_cb)
		LoadingMgr.Show(eLoadingType.Repeat, 41)
	elseif callback then
		callback()
	end
end

function InfoTeam:TeamBondageChangeCall(bondageId, callback)
	if InstructionMgr.isOpen and self.stageId == GetConfigArgInt("GuideCard.StageID") and not self.infoStage:IsPass() then
		return
	end

	if not self.isLimit then
		local chapterTeam = self.stageTeams[self.teamSystemAgent.teamIndex]
		local option = -1

		if bondageId ~= nil and bondageId ~= 0 then
			option = bondageId
		end

		local function wrap_cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat, 41)

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

		NetManager:RequestSetFormation(chapterTeam.id, chapterTeam.name, chapterTeam.roleCardTeams, option, wrap_cb)
		LoadingMgr.Show(eLoadingType.Repeat, 41)
	elseif callback then
		callback()
	end
end

function InfoTeam:GetUpRoleCardList()
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
			table.insert(ids, chapterTeam.roleCardTeams[i])
		end
	end

	return ids
end

function InfoTeam:GetAddRoleCardList()
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
		for i = 6, 10 do
			table.insert(ids, chapterTeam.roleCardTeams[i])
		end
	end

	return ids
end

function InfoTeam:GetUpRoleList()
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

function InfoTeam:GetTimelineDataDanceNum()
	if self.infoStage then
		local BattleStageID = StageData[self.infoStage.data.ID].BattleStageID
		local LiveTimeLine = battleStageData[BattleStageID].LiveTimeLine

		if TimelineData[LiveTimeLine] then
			return TimelineData[LiveTimeLine].DanceNum
		end
	end

	return false
end

function InfoTeam:GetStageRecommendJob()
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

return InfoTeam
