-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/Monster.lua

local MonsterInfo = {
	ID = {
		type = "integer"
	},
	Level = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	CardID = {
		default = "0",
		type = "integer"
	},
	PlayType = {
		type = "integer"
	},
	Job = {
		type = "text"
	},
	OverDropPR = {
		type = "float"
	},
	OverDropGroupList = {
		default = "[]",
		type = "array"
	},
	DropGroupList = {
		default = "[]",
		type = "array"
	},
	DropItemList = {
		default = "[]",
		type = "array"
	},
	CriticalRatio = {
		type = "float"
	},
	AntiCritical = {
		type = "float"
	},
	CriticalMul = {
		type = "float"
	},
	ReduceInjuryRatio = {
		type = "float"
	},
	AddDamageRatio = {
		type = "float"
	},
	AntiAttr = {
		default = "[]",
		type = "array"
	},
	ActorID = {
		type = "integer"
	},
	Size = {
		default = "1",
		type = "float"
	},
	WeaponID = {
		default = "-1",
		type = "integer"
	},
	MonsterSeries = {
		type = "integer"
	},
	Radius = {
		type = "integer"
	},
	Boss = {
		type = "integer"
	},
	AppearTimeLine = {
		type = "integer"
	},
	NameIcon = {
		type = "text"
	},
	HeadIcon = {
		type = "text"
	},
	CombatReadinessHeadIcon = {
		type = "text"
	},
	ActiveHeadIcon = {
		type = "text"
	},
	ItemTipIcon = {
		type = "text"
	},
	AppearFx = {
		type = "integer"
	},
	AttackId = {
		type = "integer"
	},
	CastFx = {
		type = "integer"
	},
	LaunchFx = {
		type = "integer"
	},
	DamageFx = {
		default = "0",
		type = "integer"
	},
	DieFx = {
		type = "integer"
	},
	DieFxs = {
		default = "[]",
		type = "array"
	},
	DieFxTimes = {
		default = "[]",
		type = "array"
	},
	DieMaterialAnimTime = {
		type = "float"
	},
	DieHideTime = {
		type = "float"
	},
	DieTotalTime = {
		type = "float"
	},
	AttriList = {
		default = "[]",
		type = "array"
	},
	HpAdd = {
		default = "1",
		type = "float"
	},
	PhyAtkAdd = {
		default = "1",
		type = "float"
	},
	MagAtkAdd = {
		default = "1",
		type = "float"
	},
	DefAdd = {
		default = "1",
		type = "float"
	},
	AntiDotBleeding = {
		default = "0",
		type = "float"
	},
	StageOfAngry = {
		default = "[]",
		type = "array"
	},
	StageOfAngryBuff = {
		default = "[]",
		type = "array"
	},
	StageSkillId = {
		default = "[]",
		type = "array"
	},
	StageSkillIdWeight = {
		default = "[]",
		type = "array"
	},
	StageSkillIdDisplay = {
		default = "[]",
		type = "array"
	},
	AllowSkills = {
		default = "0",
		type = "integer"
	},
	Skills = {
		default = "[]",
		type = "array"
	},
	AppearSkills = {
		default = "[]",
		type = "array"
	},
	OthersSkills = {
		default = "[]",
		type = "array"
	},
	PrimaryAngry = {
		type = "integer"
	},
	AngryPerHP = {
		type = "float"
	},
	AttackDecAngry = {
		type = "integer"
	},
	SkillDecAngry = {
		type = "integer"
	},
	BaseAttackRound = {
		type = "integer"
	}
}
local MonsterCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local Monster = {}

function Monster:GetAllSync()
	if MonsterCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("Monster", "select * from Monster")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, MonsterInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(MonsterCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	MonsterCtrl.hasCached = true
	Monster.GetAllSync = nil
	Monster.GetAllASync = nil
end

function Monster:GetAllASync()
	if MonsterCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("Monster", "select * from Monster", function()
		local rowsList = SqlLiteSupport.GetCacheData("Monster")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, MonsterInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(MonsterCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		MonsterCtrl.hasCached = true
		Monster.GetAllSync = nil
		Monster.GetAllASync = nil
	end)
end

setmetatable(Monster, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("Monster", SqlLiteTransfer.GenSql("Monster", MonsterCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, MonsterInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
Monster:GetAllSync()

return Monster
