-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/GameRecord/GameRecordProto.lua

local GameRecordProto = {
	RecordItem = {
		eventId = "eventId"
	},
	CreateFight = {
		stageId = "stageId",
		boutId = "boutId",
		playMode = "playMode",
		fightMode = "fightMode",
		gameId = "gameId"
	},
	ChangeStage = {
		lastStage = "lastStage",
		stage = "stage"
	},
	UnitReady = {
		cardId = "cardId",
		camp = "camp",
		skills = "skills",
		unitId = "unitId",
		wave = "wave",
		order = "order"
	},
	UnitCreate = {
		unitId = "unitId",
		camp = "camp",
		uniqueId = "uniqueId",
		wave = "wave",
		order = "order"
	},
	UnitDie = {
		uniqueId = "uniqueId"
	},
	PlayerDie = {},
	UnitDestroy = {
		uniqueId = "uniqueId"
	},
	UnitAddSkill = {
		skillId = "skillId",
		skillLv = "skillLv",
		uniqueId = "uniqueId"
	},
	UpdateCombo = {
		camp = "camp",
		count = "count",
		ownerUniqueId = "ownerUniqueId"
	},
	DamageSkillTarget = {
		targets = "targets",
		uniqueId = "uniqueId"
	},
	UnitDealDamageBefore = {},
	UnitDealDamage = {
		minusHp = "minusHp",
		mutIdx = "mutIdx",
		dmgType = "dmgType",
		uniqueId = "uniqueId",
		remainHp = "remainHp"
	},
	UnitHealHp = {
		healHp = "healHp",
		remainHp = "remainHp",
		uniqueId = "uniqueId"
	},
	UnitMinusShield = {
		minusShield = "minusShield",
		remainShield = "remainShield",
		dmgType = "dmgType",
		uniqueId = "uniqueId"
	},
	UnitUpdateHp = {
		maxHp = "maxHp",
		hp = "hp",
		uniqueId = "uniqueId"
	},
	TeamUpdateHp = {
		hp = "hp",
		maxHp = "maxHp"
	},
	UnitUpdateAttri = {
		cur = "cur",
		attriName = "attriName",
		uniqueId = "uniqueId"
	},
	TeamUpdateAttri = {
		cur = "cur",
		camp = "camp",
		attriName = "attriName"
	},
	SkillCastShot = {
		isCard = "isCard",
		isRange = "isRange",
		skillId = "skillId",
		uniqueId = "uniqueId"
	},
	SkillCastResult = {
		skillId = "skillId",
		result = "result",
		uniqueId = "uniqueId",
		comboCount = "comboCount",
		isRange = "isRange"
	},
	GameOver = {
		winner = "winner"
	},
	PlayerSession = {
		groupIdx = "groupIdx",
		uniqueIds = "uniqueIds",
		sessionType = "sessionType"
	},
	RefreshRound = {
		curRound = "curRound",
		maxRound = "maxRound"
	},
	RefreshWave = {
		curWave = "curWave",
		maxWave = "maxWave"
	},
	RefreshRoundSession = {
		uniqueId = "uniqueId",
		index = "index",
		sessionType = "sessionType",
		isPower = "isPower",
		isNew = "isNew"
	},
	RefreshRoundCard = {
		skillId = "skillId",
		uniqueId = "uniqueId"
	},
	DoCard = {
		skillId = "skillId",
		uniqueId = "uniqueId"
	},
	UnitMoveTo = {
		targetUniqueId = "targetUniqueId",
		uniqueId = "uniqueId"
	},
	UnityDie = {
		uniqueId = "uniqueId"
	},
	TeamDie = {
		camp = "camp"
	},
	UnitAddBuff = {
		buffUid = "buffUid",
		buffId = "buffId",
		uniqueId = "uniqueId"
	},
	UnitRemoveBuff = {
		buffUid = "buffUid",
		buffId = "buffId",
		uniqueId = "uniqueId"
	},
	UnitUpdateBuff = {
		remainRound = "remainRound",
		buffUid = "buffUid",
		buffId = "buffId",
		uniqueId = "uniqueId"
	},
	UnitAngryBuffSkill = {
		skillId = "skillId",
		uniqueId = "uniqueId"
	}
}

return GameRecordProto
