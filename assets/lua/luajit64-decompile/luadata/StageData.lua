-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/StageData.lua

local StageDataInfo = {
	ID = {
		type = "integer"
	},
	ChapterID = {
		type = "integer"
	},
	BattleStageID = {
		default = "0",
		type = "integer"
	},
	Type = {
		type = "integer"
	},
	ChapterType = {
		type = "integer"
	},
	ActType = {
		default = "0",
		type = "integer"
	},
	StoryNum = {
		type = "integer"
	},
	LevelUnlock = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Info = {
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	IconBig = {
		type = "text"
	},
	StageBgImage = {
		type = "text"
	},
	MonsterJob = {
		type = "text"
	},
	FavorLevel = {
		type = "integer"
	},
	Rank = {
		default = "1",
		type = "integer"
	},
	SafeLevel = {
		default = "1",
		type = "integer"
	},
	SafeFightValue = {
		type = "integer"
	},
	Evaluate = {
		default = "[]",
		type = "array"
	},
	Grade = {
		type = "json"
	},
	ItemList = {
		default = "[]",
		type = "array"
	},
	SecurityItem = {
		default = "[]",
		type = "array"
	},
	ItemListFix = {
		default = "[]",
		type = "array"
	},
	CharacterCardExp = {
		type = "integer"
	},
	CharacterFavor = {
		type = "integer"
	},
	FavorStorySkill = {
		type = "integer"
	},
	FirstAward = {
		default = "[]",
		type = "array"
	},
	Star1Award = {
		default = "[]",
		type = "array"
	},
	Star2Award = {
		default = "[]",
		type = "array"
	},
	Star3Award = {
		default = "[]",
		type = "array"
	},
	PlayNum = {
		type = "integer"
	},
	PlayType = {
		default = "1",
		type = "integer"
	},
	DropgroupList = {
		default = "[]",
		type = "array"
	},
	DropChance = {
		default = "[]",
		type = "array"
	},
	RushExtraDropgroupList = {
		default = "[]",
		type = "array"
	},
	RushExtraChance = {
		default = "[]",
		type = "array"
	},
	MaxRound = {
		type = "integer"
	},
	CostItem = {
		default = "[]",
		type = "array"
	},
	Stamina = {
		type = "integer"
	},
	GVGStagePassBuff = {
		default = "[]",
		type = "array"
	},
	PersonalBasicReward = {
		default = "[]",
		type = "array"
	},
	PersonalMaxDamageReward = {
		default = "[]",
		type = "array"
	},
	PersonalStagePassReward = {
		default = "[]",
		type = "array"
	},
	GroupStagePassReward = {
		default = "[]",
		type = "array"
	},
	PosLimit = {
		type = "integer"
	},
	LimitList = {
		default = "[]",
		type = "array"
	},
	AdditionList = {
		default = "[]",
		type = "array"
	},
	StoryPrefabPath = {
		type = "text"
	},
	ResName = {
		type = "integer"
	},
	AddResName = {
		type = "integer"
	},
	ReLiveCost = {
		default = "[]",
		type = "array"
	},
	FirstCardLimit = {
		default = "[]",
		type = "array"
	},
	FirstSessionLimit = {
		default = "[]",
		type = "array"
	},
	Sweep = {
		type = "integer"
	},
	SweepCost = {
		default = "[]",
		type = "array"
	},
	EnSupport = {
		default = "1",
		type = "integer"
	},
	SafeCE = {
		default = "[]",
		type = "array"
	},
	DailyAward = {
		default = "[]",
		type = "array"
	},
	AssignUnlock = {
		default = "[]",
		type = "array"
	},
	MaxPlayers = {
		type = "integer"
	}
}
local StageDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local StageData = {}

function StageData:GetAllSync()
	if StageDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("StageData", "select * from StageData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, StageDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(StageDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	StageDataCtrl.hasCached = true
	StageData.GetAllSync = nil
	StageData.GetAllASync = nil
end

function StageData:GetAllASync()
	if StageDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("StageData", "select * from StageData", function()
		local rowsList = SqlLiteSupport.GetCacheData("StageData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, StageDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(StageDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		StageDataCtrl.hasCached = true
		StageData.GetAllSync = nil
		StageData.GetAllASync = nil
	end)
end

setmetatable(StageData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("StageData", SqlLiteTransfer.GenSql("StageData", StageDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, StageDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
StageData:GetAllSync()

return StageData
