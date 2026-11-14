-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/BattleStage.lua

local BattleStageInfo = {
	ID = {
		type = "integer"
	},
	BattleType = {
		type = "text"
	},
	MaxRound = {
		type = "integer"
	},
	Enemy = {
		default = "[]",
		type = "array"
	},
	MonsterLv = {
		default = "[]",
		type = "array"
	},
	EnemyLocation = {
		default = "[]",
		type = "array"
	},
	Attribute = {
		type = "json"
	},
	OverDropPR = {
		type = "float"
	},
	OverDropGroupList = {
		default = "[]",
		type = "array"
	},
	OverDropGroupPR = {
		default = "[]",
		type = "array"
	},
	SceneScript = {
		type = "text"
	},
	SessionSceneId = {
		type = "integer"
	},
	MainSceneId = {
		type = "integer"
	},
	BossSceneId = {
		type = "integer"
	},
	LiveSoundBank = {
		type = "text"
	},
	LiveSoundEvent = {
		type = "text"
	},
	LiveSoundBankBoss = {
		type = "text"
	},
	LiveSoundEventBoss = {
		type = "text"
	},
	SoundBanks = {
		default = "[]",
		type = "array"
	},
	LiveTimeLine = {
		type = "integer"
	},
	Opening = {
		type = "integer"
	},
	Win = {
		type = "integer"
	},
	Lose = {
		type = "integer"
	},
	CamFlash = {
		type = "integer"
	},
	MonsterShow = {
		type = "integer"
	},
	MonsterAtk = {
		type = "integer"
	},
	MonsterHurt = {
		type = "integer"
	},
	MonsterDie = {
		type = "integer"
	},
	BossShow = {
		type = "integer"
	},
	Session1P = {
		default = "[]",
		type = "array"
	},
	Session2P = {
		default = "[]",
		type = "array"
	},
	Session3P = {
		default = "[]",
		type = "array"
	},
	Session4P = {
		default = "[]",
		type = "array"
	},
	HackerCheck = {
		type = "integer"
	}
}
local BattleStageCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local BattleStage = {}

function BattleStage:GetAllSync()
	if BattleStageCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("BattleStage", "select * from BattleStage")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, BattleStageInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(BattleStageCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	BattleStageCtrl.hasCached = true
	BattleStage.GetAllSync = nil
	BattleStage.GetAllASync = nil
end

function BattleStage:GetAllASync()
	if BattleStageCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("BattleStage", "select * from BattleStage", function()
		local rowsList = SqlLiteSupport.GetCacheData("BattleStage")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, BattleStageInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(BattleStageCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		BattleStageCtrl.hasCached = true
		BattleStage.GetAllSync = nil
		BattleStage.GetAllASync = nil
	end)
end

setmetatable(BattleStage, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("BattleStage", SqlLiteTransfer.GenSql("BattleStage", BattleStageCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, BattleStageInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
BattleStage:GetAllSync()

return BattleStage
