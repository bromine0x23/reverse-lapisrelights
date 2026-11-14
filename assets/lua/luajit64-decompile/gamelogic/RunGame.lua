-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/RunGame.lua

local roleTestSkill = {}

require("GameLogic/ConfigTable")
require("GameLogic/Fight/GameLogic")

local _data_character = ConfigTable.Character
local _data_characterCard = ConfigTable.CharacterCard
local _data_monster = ConfigTable.Monster
local _data_allSkills = ConfigTable.AllSkills
local _data_battleSkillData = ConfigTable.BattleSkillData
local _data_battleBuffData = ConfigTable.BattleBuffData
local _data_jobCheckingData = ConfigTable.JobCheckingData
local _data_battleStage = ConfigTable.BattleStage
local _data_stageData = ConfigTable.StageData
local m = {}

function m:RunByJson(vParamJson)
	local json = require("GameLogic.Util.json4lua")
	local luaTable = json.decode(vParamJson)

	self:Run(luaTable)
end

function m:Run(vParam)
	local success = InfoBattleStage:InitByStageId(vParam.stageId)

	if success == false then
		print("stageId ERROR !!!! , vParam.stageId = " .. vParam.stageId)

		return nil
	end

	if GP then
		GP:PurgeAll()
	end

	local gameBaseData = New(GameBaseData)

	gameBaseData.Character = _data_character
	gameBaseData.CharacterCard = _data_characterCard
	gameBaseData.Monster = _data_monster
	gameBaseData.AllSkills = _data_allSkills
	gameBaseData.BattleSkillData = _data_battleSkillData
	gameBaseData.BattleBuffData = _data_battleBuffData
	gameBaseData.StageData = _data_stageData[vParam.stageId]

	local _battleStageId = _data_stageData[vParam.stageId].BattleStageID

	gameBaseData.BattleStageData = _data_battleStage[_battleStageId]

	local jobData = _data_jobCheckingData

	JobCheckingHelp.Init(jobData)

	local gameStartData = self:GetStartData(vParam)

	if gameStartData == nil then
		return
	end

	require("GamePerform.GamePerform")

	local gp = GamePerform()

	gp:Start()
	gp:SetInfoRole(vParam)

	gp.StageId = vParam.stageId
	gp.ChapterTeam = self.chapterTeam
	gp.PlayerUnitIds = {}
	gp.PlayerCardIds = {}
	gp.EnemyUnitIds = {}
	gp.exitCall = vParam.exitCall
	gp.callBack = vParam.callBack

	for campIdx, waveDatas in ipairs(gameStartData.teams) do
		for waveIdx, waveData in ipairs(waveDatas) do
			for i, unitStartData in ipairs(waveData) do
				if campIdx == 1 then
					table.insert(gp.PlayerUnitIds, unitStartData.unitId)
					table.insert(gp.PlayerCardIds, unitStartData.cardId)
				elseif campIdx == 2 then
					table.insert(gp.EnemyUnitIds, unitStartData.unitId)
				end
			end
		end
	end

	local gl = GameLogic()

	gl:SetGameStartData(gameStartData)
	gl:PrintStartData()
	gl:SetGameBaseData(gameBaseData)
	gl:SetEvent(Event.Instance)
	gl:Start()
end

function m:GetStartData(vParam)
	local gameStartData = FightDataUtil.GetStartData(vParam)

	if #gameStartData.teams ~= 0 and #gameStartData.teams[1] ~= 0 and #gameStartData.teams[2] ~= 0 then
		return gameStartData
	end

	print("vParam.stageId = " .. vParam.stageId)

	self.battleData = InfoBattleStage:GetData()
	self.pvp = EnumFight.Pvp.NONE

	if vParam.pvp then
		self.pvp = vParam.pvp
	end

	self.enemyUnitIds = self.battleData.Enemy
	self.chapterTeam = vParam.chapterTeam
	self.infoRoleList = vParam.player1 and vParam.player1[1] or {}
	self.infoRoleCardList = vParam.player1 and vParam.player1[2] or {}
	self.infoAddRoleCardList = vParam.player1 and vParam.player1[3] or {}
	self.infoRoleList2 = vParam.player2 and vParam.player2[1] or {}
	self.infoRoleCardList2 = vParam.player2 and vParam.player2[2] or {}
	self.infoAddRoleCardList2 = vParam.player2 and vParam.player2[3] or {}
	self.monsterHpRates = vParam.monsterHpRates or {}
	self.skills = vParam.skills or {}
	self.deSkills = vParam.deSkills or {}
	self.monsterBlood = vParam.monsterBlood or {}
	self.monsterMaxHp = vParam.monsterMaxHp or {}
	self.playerUnitIds = {}
	self.playerCardIds = {}

	for i, infoRole in ipairs(self.infoRoleList) do
		table.insert(self.playerUnitIds, infoRole.id)
	end

	for i, infoRoleCard in ipairs(self.infoRoleCardList) do
		table.insert(self.playerCardIds, infoRoleCard.id)
	end

	if #self.playerUnitIds == 0 then
		self.playerUnitIds = GLGetConfigArgJson("GuideFlow.ListRoleID")

		if vParam.listRoleId then
			self.playerUnitIds = vParam.listRoleId
		end

		self.infoRoleList = {}

		for i, unitId in ipairs(self.playerUnitIds) do
			table.insert(self.infoRoleList, RoleMgr:GetRole(unitId))
		end

		if self.pvp ~= EnumFight.Pvp.NONE then
			self.infoRoleList2 = self.infoRoleList
		end
	end

	if #self.playerCardIds == 0 then
		self.playerCardIds = GLGetConfigArgJson("GuideFlow.ListRoleCardID")

		if vParam.listRoleCardId then
			self.playerCardIds = vParam.listRoleCardId
		end

		self.infoRoleCardList = {}

		for i, id in ipairs(self.playerCardIds) do
			table.insert(self.infoRoleCardList, RoleCardMgr:GetRoleCard(id))
		end

		if self.pvp ~= EnumFight.Pvp.NONE then
			self.infoRoleCardList2 = self.infoRoleCardList
		end
	end

	gameStartData.teams[1][1] = {}

	for i, infoRole in ipairs(self.infoRoleList) do
		local infoCard = self.infoRoleCardList[i]
		local infoAddCard = self.infoAddRoleCardList[i]
		local _unitData = FightDataUtil.GetPlayerStartData({
			level = 1,
			camp = 1,
			hpRate = 1,
			wave = 1,
			unitClass = EnumFight.UnitClass.PLAYER,
			infoRole = infoRole,
			infoCard = infoCard,
			addCard = infoAddCard,
			order = i,
			isCenter = i == math.ceil(#self.infoRoleList * 0.5),
			skills = self.skills
		})

		table.insert(gameStartData.teams[1][1], _unitData)

		if i == 3 then
			for _, skillId in ipairs(roleTestSkill) do
				table.insert(_unitData.skills, {
					skillId,
					1
				})
			end
		end
	end

	gameStartData.teams[2][1] = {}

	if self.pvp ~= EnumFight.Pvp.NONE then
		for i, infoRole in ipairs(self.infoRoleList2) do
			local infoCard = self.infoRoleCardList2[i]
			local infoAddCard = self.infoAddRoleCardList2[i]
			local _unitData = FightDataUtil.GetPlayerStartData({
				level = 1,
				camp = 2,
				hpRate = 1,
				wave = 1,
				unitClass = EnumFight.UnitClass.PVPPLAYER,
				infoRole = infoRole,
				infoCard = infoCard,
				addCard = infoAddCard,
				order = i,
				isCenter = i == math.ceil(#self.infoRoleList2 * 0.5),
				skills = self.deSkills
			})

			table.insert(gameStartData.teams[2][1], _unitData)
		end

		return gameStartData
	end

	local monsterLvList = InfoBattleStage:GetDataByKey("MonsterLv")
	local monsterIdx = 0

	for _, waveEnemys in ipairs(self.enemyUnitIds) do
		gameStartData.teams[2][_] = {}

		for i, UnitId in ipairs(waveEnemys) do
			monsterIdx = monsterIdx + 1

			local _level = monsterLvList[monsterIdx]

			if not _level or type(_level) ~= "number" then
				_level = 1
			end

			local _hpRate = self.monsterHpRates[monsterIdx]

			if not _hpRate or type(_hpRate) ~= "number" then
				_hpRate = 1
			end

			local hp = self.monsterBlood[monsterIdx]
			local maxhp = self.monsterMaxHp[monsterIdx]
			local _unitData = FightDataUtil.GetEnemyStartData({
				isSummon = false,
				camp = 2,
				isCenter = false,
				unitId = UnitId,
				level = _level,
				unitClass = EnumFight.UnitClass.ENEMY,
				infoRole = infoRole,
				infoCard = infoCard,
				addCard = infoAddCard,
				order = i,
				wave = _,
				hpRate = _hpRate,
				skills = self.deSkills,
				hp = hp,
				maxhp = maxhp
			})

			table.insert(gameStartData.teams[2][_], _unitData)
		end
	end

	return gameStartData
end

function m:ServerRun(vParam)
	local success = InfoBattleStage:InitByStageId(vParam.stageId)

	if success == false then
		print("stageId ERROR !!!! , vParam.stageId = " .. vParam.stageId)

		return nil
	end

	vParam.playMode = EnumFight.PlayMode.Replay

	local gameBaseData = New(GameBaseData)

	gameBaseData.Character = _data_character
	gameBaseData.CharacterCard = _data_characterCard
	gameBaseData.Monster = _data_monster
	gameBaseData.AllSkills = _data_allSkills
	gameBaseData.BattleSkillData = _data_battleSkillData
	gameBaseData.BattleBuffData = _data_battleBuffData
	gameBaseData.StageData = _data_stageData[vParam.stageId]

	local _battleStageId = _data_stageData[vParam.stageId].BattleStageID

	gameBaseData.BattleStageData = _data_battleStage[_battleStageId]

	local jobData = _data_jobCheckingData

	JobCheckingHelp.Init(jobData)

	local gameStartData = FightDataUtil.GetStartData(vParam)
	local gl = GameLogic()

	gl:SetGameStartData(gameStartData)
	gl:PrintStartData()
	gl:SetGameBaseData(gameBaseData)
	gl:SetEvent(Event.Instance)
	gl:Start()

	return gl:GetServerRet(), gl:Purge()
end

function m:ServerRunJson(vParamJson)
	local json = require("GameLogic.Util.json4lua")
	local vRequest = json.decode(vParamJson)

	vParam = json.decode(vRequest.battleLogs)
	vParam.randomSeed = vRequest.battleSeeds[0]
	vParam.randomSeedForReward = vRequest.battleSeeds[1]

	local success = InfoBattleStage:InitByStageId(vParam.stageId)

	if success == false then
		print("stageId ERROR !!!! , vParam.stageId = " .. vParam.stageId)

		return nil
	end

	local gameBaseData = New(GameBaseData)

	gameBaseData.Character = _data_character
	gameBaseData.CharacterCard = _data_characterCard
	gameBaseData.Monster = _data_monster
	gameBaseData.AllSkills = _data_allSkills
	gameBaseData.BattleSkillData = _data_battleSkillData
	gameBaseData.BattleBuffData = _data_battleBuffData
	gameBaseData.StageData = _data_stageData[vParam.stageId]

	local _battleStageId = _data_stageData[vParam.stageId].BattleStageID

	gameBaseData.BattleStageData = _data_battleStage[_battleStageId]

	local jobData = _data_jobCheckingData

	JobCheckingHelp.Init(jobData)

	local gameStartData = FightDataUtil.GetStartData(vParam)
	local gl = GameLogic()

	gl:SetGameStartData(gameStartData)
	gl:SetGameBaseData(gameBaseData)
	gl:SetEvent(Event.Instance)
	gl:Start()

	return gl:GetResponse()
end

function m:TestRun(vParamJson)
	local json = require("GameLogic.Util.json4lua")
	local vParam = json.decode(vParamJson)

	vParam.operators = {}
	vParam.playMode = EnumFight.PlayMode.Std

	local success = InfoBattleStage:InitByStageId(vParam.stageId)

	if success == false then
		print("stageId ERROR !!!! , vParam.stageId = " .. vParam.stageId)

		return nil
	end

	local gameBaseData = New(GameBaseData)

	gameBaseData.Character = _data_character
	gameBaseData.CharacterCard = _data_characterCard
	gameBaseData.Monster = _data_monster
	gameBaseData.AllSkills = _data_allSkills
	gameBaseData.BattleSkillData = _data_battleSkillData
	gameBaseData.BattleBuffData = _data_battleBuffData
	gameBaseData.StageData = _data_stageData[vParam.stageId]

	local _battleStageId = _data_stageData[vParam.stageId].BattleStageID

	gameBaseData.BattleStageData = _data_battleStage[_battleStageId]

	local jobData = _data_jobCheckingData

	JobCheckingHelp.Init(jobData)

	local gameStartData = FightDataUtil.GetStartData(vParam)
	local gl = GameLogic()

	gl.TestMode = true

	gl:SetGameStartData(gameStartData)
	gl:SetGameBaseData(gameBaseData)
	gl:SetEvent(Event.Instance)
	gl:Start()

	return gl
end

return m
