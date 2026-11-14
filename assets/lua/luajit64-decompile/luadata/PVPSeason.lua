-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/PVPSeason.lua

local PVPSeasonInfo = {
	ID = {
		type = "integer"
	},
	SeasonStartDate = {
		type = "text"
	},
	SeasonRankingListID = {
		type = "integer"
	},
	SeasonRankingAwardID = {
		type = "integer"
	},
	SubSeasonNum = {
		type = "integer"
	},
	SubSeasonAwardID = {
		type = "integer"
	},
	DailyBattleDropId = {
		type = "integer"
	},
	DailyBattleNum = {
		type = "integer"
	},
	DailyOpponentRefreshNum = {
		type = "integer"
	}
}
local PVPSeasonCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local PVPSeason = {}

function PVPSeason:GetAllSync()
	if PVPSeasonCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("PVPSeason", "select * from PVPSeason")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, PVPSeasonInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(PVPSeasonCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	PVPSeasonCtrl.hasCached = true
	PVPSeason.GetAllSync = nil
	PVPSeason.GetAllASync = nil
end

function PVPSeason:GetAllASync()
	if PVPSeasonCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("PVPSeason", "select * from PVPSeason", function()
		local rowsList = SqlLiteSupport.GetCacheData("PVPSeason")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, PVPSeasonInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(PVPSeasonCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		PVPSeasonCtrl.hasCached = true
		PVPSeason.GetAllSync = nil
		PVPSeason.GetAllASync = nil
	end)
end

setmetatable(PVPSeason, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("PVPSeason", SqlLiteTransfer.GenSql("PVPSeason", PVPSeasonCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, PVPSeasonInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
PVPSeason:GetAllSync()

return PVPSeason
