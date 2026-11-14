-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/PVPSubSeasonAward.lua

local PVPSubSeasonAwardInfo = {
	ID = {
		type = "integer"
	},
	SubSeasonAwardID = {
		type = "integer"
	},
	RankingNoFrom = {
		type = "integer"
	},
	RankingNoTo = {
		type = "integer"
	},
	RankingAwardList = {
		default = "[]",
		type = "array"
	},
	RankingMail = {
		type = "integer"
	}
}
local PVPSubSeasonAwardCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local PVPSubSeasonAward = {}

function PVPSubSeasonAward:GetAllSync()
	if PVPSubSeasonAwardCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("PVPSubSeasonAward", "select * from PVPSubSeasonAward")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, PVPSubSeasonAwardInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(PVPSubSeasonAwardCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	PVPSubSeasonAwardCtrl.hasCached = true
	PVPSubSeasonAward.GetAllSync = nil
	PVPSubSeasonAward.GetAllASync = nil
end

function PVPSubSeasonAward:GetAllASync()
	if PVPSubSeasonAwardCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("PVPSubSeasonAward", "select * from PVPSubSeasonAward", function()
		local rowsList = SqlLiteSupport.GetCacheData("PVPSubSeasonAward")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, PVPSubSeasonAwardInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(PVPSubSeasonAwardCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		PVPSubSeasonAwardCtrl.hasCached = true
		PVPSubSeasonAward.GetAllSync = nil
		PVPSubSeasonAward.GetAllASync = nil
	end)
end

setmetatable(PVPSubSeasonAward, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("PVPSubSeasonAward", SqlLiteTransfer.GenSql("PVPSubSeasonAward", PVPSubSeasonAwardCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, PVPSubSeasonAwardInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
PVPSubSeasonAward:GetAllSync()

return PVPSubSeasonAward
