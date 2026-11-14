-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/PVPSeasonRankingAward.lua

local PVPSeasonRankingAwardInfo = {
	ID = {
		type = "integer"
	},
	SeasonRankingAwardID = {
		type = "integer"
	},
	RankingId = {
		type = "integer"
	},
	RankingAwardList = {
		default = "[]",
		type = "array"
	},
	Stage = {
		default = "0",
		type = "integer"
	}
}
local PVPSeasonRankingAwardCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local PVPSeasonRankingAward = {}

function PVPSeasonRankingAward:GetAllSync()
	if PVPSeasonRankingAwardCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("PVPSeasonRankingAward", "select * from PVPSeasonRankingAward")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, PVPSeasonRankingAwardInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(PVPSeasonRankingAwardCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	PVPSeasonRankingAwardCtrl.hasCached = true
	PVPSeasonRankingAward.GetAllSync = nil
	PVPSeasonRankingAward.GetAllASync = nil
end

function PVPSeasonRankingAward:GetAllASync()
	if PVPSeasonRankingAwardCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("PVPSeasonRankingAward", "select * from PVPSeasonRankingAward", function()
		local rowsList = SqlLiteSupport.GetCacheData("PVPSeasonRankingAward")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, PVPSeasonRankingAwardInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(PVPSeasonRankingAwardCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		PVPSeasonRankingAwardCtrl.hasCached = true
		PVPSeasonRankingAward.GetAllSync = nil
		PVPSeasonRankingAward.GetAllASync = nil
	end)
end

setmetatable(PVPSeasonRankingAward, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("PVPSeasonRankingAward", SqlLiteTransfer.GenSql("PVPSeasonRankingAward", PVPSeasonRankingAwardCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, PVPSeasonRankingAwardInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
PVPSeasonRankingAward:GetAllSync()

return PVPSeasonRankingAward
