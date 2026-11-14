-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/DataBuilder/BuilderMgr.lua

require("DataBuilder/Util/Class")
require("GameLogic/ConfigTable")
require("DataBuilder/Util/Util")
require("DataBuilder/Util/Enum")
require("GameLogic/Fight/EnumFight")
require("DataBuilder/Attribute")
require("DataBuilder/LevelMgr")
require("DataBuilder/BondageMgr")
require("DataBuilder/CombatPowerMgr")
require("DataBuilder/Builder/RoleBuilder")
require("DataBuilder/Builder/CardBuilder")
require("DataBuilder/Builder/EquipmentBuilder")
require("DataBuilder/Builder/AvatarBuilder")
require("DataBuilder/Builder/SkillBuilder")
require("DataBuilder/Builder/TalentBuilder")

local function GetAttribute(role_data)
	local role = role_data.role

	Attribute:Init()

	for _, v in pairs(ATTRIBUTE_NAME) do
		Attribute:ModifyAbsValue(v, ExchangeAttrValue(v, role_data.role.attrs[v]))
		Attribute:ModifyAbsValue(v, ExchangeAttrValue(v, role_data.role.equipAttrs[v]))
		Attribute:ModifyAbsValue(v, ExchangeAttrValue(v, role_data.role.talentAttrs[v]))
		Attribute:ModifyAbsValue(v, ExchangeAttrValue(v, role_data.card.attrs[v]))

		for _, n in pairs(role.listSkillNode) do
			Attribute:ModifyPerValue(v, n.attrs[v])
		end

		if role_data.supCard then
			Attribute:ModeExtraValue(v, ExchangeAttrValue(v, role_data.supCard.attrs[v] * GetConfigArgJson("JoinAttCombat")[1] * 0.01))
		end
	end

	local att = Attribute:GetAttr()

	for _, v in pairs(ATTRIBUTE_NAME) do
		att[v] = ExchangeAttrValue(v, att[v])
	end

	return att
end

local function GetBattleSkill(role_data)
	local listSkill = {}

	local function fun(skills)
		for _, v in pairs(skills) do
			if v.data.Type == eAllSkillType.battle then
				table.insert(listSkill, {
					v.skillId,
					v.skillLevel
				})
			end
		end
	end

	fun(role_data.card.listSkill)
	fun(role_data.role.listBattleSkill)

	local weapon = ConfigTable.Equipment[role_data.role.weaponId]

	if weapon then
		if weapon.WeaponThumpSkillID ~= 0 then
			table.insert(listSkill, {
				weapon.WeaponThumpSkillID,
				1
			})
		end

		if weapon.WeaponAttackSkillID ~= 0 then
			table.insert(listSkill, {
				weapon.WeaponAttackSkillID,
				1
			})
		end
	end

	if role_data.card.specialAtkSkill and role_data.card.specialAtkSkill ~= 0 then
		table.insert(listSkill, {
			role_data.card.specialAtkSkill,
			1
		})
	end

	local hasActiveSkill = false

	for _, skill in ipairs(listSkill) do
		local cfg = ConfigTable.AllSkills[skill[1]]

		if cfg.BattleSkillType == eBattleSkillType.active then
			hasActiveSkill = true

			break
		end
	end

	if not hasActiveSkill then
		local skillId = role_data.card.data.StarTalent[1][1]

		table.insert(listSkill, {
			skillId,
			1
		})
	end

	return listSkill
end

function BuildRoleData(data)
	local roleBuilder = data.role
	local cardBuilder = data.card
	local _unitData = {}

	_unitData.unitId = roleBuilder.id
	_unitData.cardId = cardBuilder.id
	_unitData.listAvatarID = {}

	if roleBuilder.pb and roleBuilder.pb.clothes then
		for i = 1, #roleBuilder.pb.clothes do
			table.insert(_unitData.listAvatarID, roleBuilder.pb.clothes[i])
		end
	end

	_unitData.weaponId = roleBuilder.weaponId
	_unitData.weaponAvatar = nil

	if roleBuilder.pb and roleBuilder.pb.weaponAvatar then
		_unitData.weaponAvatar = roleBuilder.pb.weaponAvatar
	end

	_unitData.attributes = GetAttribute(data)
	_unitData.skills = GetBattleSkill(data)
	_unitData.hpRate = 1

	local stageData = ConfigTable.StageData[data.stageId or 0]

	if stageData then
		if stageData.Type == eStageType.unionCommon then
			_unitData.hpRate = cardBuilder.curCommRaidHpPer
		elseif stageData.Type == eStageType.unionBoss then
			_unitData.hpRate = cardBuilder.curBossRaidHpPer
		end
	end

	_unitData.order = data.order
	_unitData.isCenter = data.isCenter
	_unitData.camp = data.camp
	_unitData.wave = 1
	_unitData.level = 1

	if data.camp == 1 then
		_unitData.unitClass = EnumFight.UnitClass.PLAYER
	elseif data.camp == 2 then
		if data.pvp == EnumFight.Pvp.NORMAL then
			_unitData.unitClass = EnumFight.UnitClass.PVPPLAYER
		else
			_unitData.unitClass = EnumFight.UnitClass.ENEMY
		end
	end

	return _unitData
end

function BuildTeam(data)
	if not data or not data.team then
		return {}
	end

	local team_data = {}
	local team_game_data = {}

	team_game_data[1] = {}

	for k, v in ipairs(data.team.slot) do
		local role = RoleBuilder(v.pbRole)
		local card = CardBuilder(v.pbCard, data.team.pbPlayers[v.playerIdx or 1])
		local supCard

		if v.pbSupCard ~= nil then
			supCard = CardBuilder(v.pbSupCard, data.team.pbPlayers[1])
		end

		local temp = {
			role = role,
			card = card,
			supCard = supCard,
			order = k,
			isCenter = k == math.ceil(#data.team.slot / 2),
			satgeId = data.stageId,
			camp = data.camp,
			pvp = data.fightType
		}

		table.insert(team_data, temp)
		table.insert(team_game_data[1], BuildRoleData(temp))
	end

	return team_game_data, team_data
end

function BuildEnemyData(data)
	local _unitData = {}

	_unitData.unitId = data.unitId
	_unitData.cardId = 0
	_unitData.camp = data.camp
	_unitData.wave = data.wave or 1
	_unitData.level = data.level or 1
	_unitData.hpRate = data.hpRate or 1
	_unitData.order = data.order or 1
	_unitData.skills = {}
	_unitData.isCenter = data.isCenter or false
	_unitData.unitClass = data.unitClass or EnumFight.UnitClass.ENEMY
	_unitData.attributes = {}
	_unitData.isSummon = data.isSummon or false

	local UnitData = ConfigTable.Monster[data.unitId]
	local skillIds = {}

	if UnitData.AllowSkills and UnitData.AllowSkills == 1 then
		for i, _skillIds in ipairs(UnitData.Skills) do
			for _, skillId in ipairs(_skillIds) do
				if skillId ~= 0 then
					table.insert(_unitData.skills, {
						skillId,
						1
					})
				end
			end
		end
	else
		skillIds = UnitData.StageSkillId

		for i, skillId in ipairs(skillIds) do
			if skillId ~= 0 then
				table.insert(_unitData.skills, {
					skillId,
					1
				})
			end
		end
	end

	skillIds = UnitData.StageOfAngryBuff

	for i, skillId in ipairs(skillIds) do
		if skillId ~= 0 then
			table.insert(_unitData.skills, {
				skillId,
				1
			})
		end
	end

	if UnitData.AppearSkills then
		skillIds = UnitData.AppearSkills

		for i, skillId in ipairs(skillIds) do
			if skillId ~= 0 then
				table.insert(_unitData.skills, {
					skillId,
					1
				})
			end
		end
	end

	if UnitData.OthersSkills then
		skillIds = UnitData.OthersSkills

		for i, skillId in ipairs(skillIds) do
			if skillId ~= 0 then
				table.insert(_unitData.skills, {
					skillId,
					1
				})
			end
		end
	end

	return _unitData
end

function BuildEnemyTeam(data)
	if not data.stageId then
		return {}
	end

	local stageData = ConfigTable.StageData[data.stageId or 0]
	local battleStageData = {}

	if stageData then
		battleStageData = ConfigTable.BattleStage[stageData.BattleStageID]
	end

	local enemy_data = {}
	local monsterIdx = 0

	for _, waveEnemys in ipairs(battleStageData.Enemy or {}) do
		enemy_data[_] = {}

		for i, UnitId in ipairs(waveEnemys) do
			monsterIdx = monsterIdx + 1

			local _level = battleStageData.MonsterLv[monsterIdx]

			if not _level or type(_level) ~= "number" then
				_level = 1
			end

			_hpRate = 1

			if stageData then
				if stageData.ChapterType == eChapterType.bossRaid then
					_hpRate = data.raidBoss and data.raidBoss.process or 1
				elseif stageData.Type == eStageType.unionBoss then
					_hpRate = data.clubMirror and data.clubMirror.progress or 1
				end
			end

			local _unitData = BuildEnemyData({
				isSummon = false,
				isCenter = false,
				unitId = UnitId,
				level = _level,
				hpRate = _hpRate,
				unitClass = EnumFight.UnitClass.ENEMY,
				camp = data.camp,
				infoRole = infoRole,
				infoCard = infoCard,
				attri = attri,
				order = i,
				wave = _
			})

			table.insert(enemy_data[_], _unitData)
		end
	end

	return enemy_data
end

BuilderMgr = {}

function BuilderMgr:BuildGameData(data)
	local _gameData = {}

	_gameData.gameId = Tenary(data.gameId, "no_game_id")
	_gameData.stageId = data.stageId
	_gameData.boutId = Tenary(data.boutId, -1)
	_gameData.pvp = Tenary(data.pvp, EnumFight.Pvp.NONE)
	_gameData.playMode = Tenary(data.playMode, EnumFight.PlayMode.Std)
	_gameData.operators = Tenary(data.operators, {})
	_gameData.randomSeed = Tenary(data.randomSeed, 666)
	_gameData.randomSeedForReward = Tenary(data.randomSeedForReward, 666)
	_gameData.whipMaxNum = GetConfigArgInt("StageWhipAwardBoxMaxNum") - Tenary(data.whipNum, 0)

	local battleData = ConfigTable.BattleStage[ConfigTable.StageData[data.stageId].BattleStageID]

	if battleData.BattleType == "Normal" then
		_gameData.fightMode = EnumFight.BattleType.NORMAL
	elseif battleData.BattleType == "Boss" then
		_gameData.fightMode = EnumFight.BattleType.BOSS
	end

	_gameData.teams = {}

	local function ExchangeBondageSkill(list, pbTeamFetter, teamData)
		local bondage = BondageMgr:GetBondageSkill(pbTeamFetter, teamData)

		for _, skill in pairs(bondage.skills) do
			if skill.canUse then
				table.insert(list, {
					skill.skillId,
					skill.skillLevel
				})
			end
		end
	end

	local function ExchangeClubSkill(list, pbClubSkills)
		for _, skill in ipairs(pbClubSkills) do
			local skillData = ConfigTable.AllSkills[skill.skillId]

			if skillData and skillData.Type == eAllSkillType.battle then
				table.insert(list, {
					skill.skillId,
					skill.skillLevel
				})
			end
		end
	end

	do
		local team1_data = {}

		_gameData.teams[1], team1_data = BuildTeam({
			camp = 1,
			team = data.player1,
			stageId = _gameData.stageId,
			fightType = EnumFight.PLAYER
		})
		_gameData.myName = Tenary(data.player1.pbPlayers[1].nickname, "myName")
		_gameData.myPower = CombatPowerMgr:GetTeamCombatPower(_gameData.teams[1][1], team1_data)
		_gameData.skills = {}

		if data.player1 and data.player1.pbTeamFetter then
			ExchangeBondageSkill(_gameData.skills, data.player1.pbTeamFetter, team1_data)
		end

		if data.player1.pbClubSkills then
			ExchangeClubSkill(_gameData.skills, data.player1.pbClubSkills)
		end
	end

	if _gameData.pvp == EnumFight.Pvp.NORMAL then
		local team2_data = {}

		_gameData.teams[2], team2_data = BuildTeam({
			camp = 2,
			team = data.player2,
			stageId = _gameData.stageId,
			fightType = EnumFight.Pvp.NORMAL
		})
		_gameData.otherName = Tenary(data.player2.pbPlayers[1].nickname, "otherName")
		_gameData.otherPower = CombatPowerMgr:GetTeamCombatPower(_gameData.teams[2][1], team2_data)
		_gameData.otherBondage = Tenary(data.player2.pbTeamFetter, nil)
		_gameData.otherSkills = {}

		if data.player2 and data.player2.teamFetter then
			ExchangeBondageSkill(_gameData.otherSkills, data.player2.pbTeamFetter, team2_data)
		end

		if data.player2.pbClubSkills then
			ExchangeClubSkill(_gameData.otherSkills, data.player2.pbClubSkills)
		end
	end

	if _gameData.pvp == EnumFight.Pvp.NONE then
		_gameData.teams[2] = BuildEnemyTeam({
			camp = 2,
			stageId = _gameData.stageId,
			clubMirror = data.pbClubMirror,
			raidBoss = data.pbRaidBoss
		})
	end

	_gameData.callBack = Tenary(data.callBack, nil)

	if data.teams then
		_gameData.teams = data.teams

		return _gameData
	end

	return _gameData
end

return BuilderMgr
