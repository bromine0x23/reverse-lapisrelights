-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/RaidBoss.lua

local RaidBossInfo = {
	ID = {
		type = "integer"
	},
	Stage = {
		default = "[]",
		type = "array"
	},
	Level = {
		type = "integer"
	},
	ActiveId = {
		type = "integer"
	},
	StageWeight = {
		default = "[]",
		type = "array"
	},
	FinishSec = {
		type = "integer"
	},
	FindFirstPassReward = {
		default = "[]",
		type = "array"
	},
	BossKillReward = {
		default = "[]",
		type = "array"
	},
	FindReward = {
		default = "[]",
		type = "array"
	},
	HarmBaseRewardPack = {
		default = "[]",
		type = "array"
	},
	HarmGradeRewardPack = {
		default = "[]",
		type = "array"
	},
	PercentHarmReward = {
		default = "[]",
		type = "array"
	},
	FinishReward = {
		default = "[]",
		type = "array"
	},
	ShowItem = {
		default = "[]",
		type = "array"
	}
}
local RaidBossCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local RaidBoss = {}

function RaidBoss:GetAllSync()
	if RaidBossCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("RaidBoss", "select * from RaidBoss")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, RaidBossInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(RaidBossCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	RaidBossCtrl.hasCached = true
	RaidBoss.GetAllSync = nil
	RaidBoss.GetAllASync = nil
end

function RaidBoss:GetAllASync()
	if RaidBossCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("RaidBoss", "select * from RaidBoss", function()
		local rowsList = SqlLiteSupport.GetCacheData("RaidBoss")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, RaidBossInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(RaidBossCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		RaidBossCtrl.hasCached = true
		RaidBoss.GetAllSync = nil
		RaidBoss.GetAllASync = nil
	end)
end

setmetatable(RaidBoss, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("RaidBoss", SqlLiteTransfer.GenSql("RaidBoss", RaidBossCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, RaidBossInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
RaidBoss:GetAllSync()

return RaidBoss
