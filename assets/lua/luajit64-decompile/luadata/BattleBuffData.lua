-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/BattleBuffData.lua

local BattleBuffDataInfo = {
	ID = {
		type = "integer"
	},
	Description = {
		default = "921011",
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	ShowName = {
		type = "text"
	},
	IsTeam = {
		default = "0",
		type = "integer"
	},
	ShowIcon = {
		default = "1",
		type = "integer"
	},
	IsAlive = {
		default = "0",
		type = "integer"
	},
	Round = {
		default = "-1",
		type = "integer"
	},
	Type = {
		type = "text"
	},
	TypeOrder = {
		type = "text"
	},
	ClearType = {
		default = "0",
		type = "integer"
	},
	Custom = {
		default = "[]",
		type = "array"
	},
	MaxStack = {
		default = "0",
		type = "integer"
	},
	Script = {
		type = "text"
	},
	ScriptArg = {
		default = "[]",
		type = "json"
	},
	Value = {
		default = "0",
		type = "float"
	},
	ValueType = {
		default = "0",
		type = "integer"
	},
	AnimState = {
		type = "text"
	},
	Fx = {
		default = "0",
		type = "integer"
	},
	RemoveFx = {
		default = "0",
		type = "integer"
	},
	ExeFx = {
		default = "0",
		type = "integer"
	},
	FxBoss = {
		default = "0",
		type = "integer"
	},
	RemoveFxBoss = {
		default = "0",
		type = "integer"
	},
	ExeFxBoss = {
		default = "0",
		type = "integer"
	},
	RoundFx = {
		default = "[]",
		type = "array"
	},
	UIExeFxsOnIcon = {
		default = "[]",
		type = "array"
	},
	UIExeFxs = {
		default = "[]",
		type = "array"
	},
	UIFxsOnIcon = {
		default = "[]",
		type = "array"
	},
	UIFxs = {
		default = "[]",
		type = "array"
	},
	Uniquely = {
		default = "0",
		type = "integer"
	}
}
local BattleBuffDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local BattleBuffData = {}

function BattleBuffData:GetAllSync()
	if BattleBuffDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("BattleBuffData", "select * from BattleBuffData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, BattleBuffDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(BattleBuffDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	BattleBuffDataCtrl.hasCached = true
	BattleBuffData.GetAllSync = nil
	BattleBuffData.GetAllASync = nil
end

function BattleBuffData:GetAllASync()
	if BattleBuffDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("BattleBuffData", "select * from BattleBuffData", function()
		local rowsList = SqlLiteSupport.GetCacheData("BattleBuffData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, BattleBuffDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(BattleBuffDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		BattleBuffDataCtrl.hasCached = true
		BattleBuffData.GetAllSync = nil
		BattleBuffData.GetAllASync = nil
	end)
end

setmetatable(BattleBuffData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("BattleBuffData", SqlLiteTransfer.GenSql("BattleBuffData", BattleBuffDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, BattleBuffDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
BattleBuffData:GetAllSync()

return BattleBuffData
