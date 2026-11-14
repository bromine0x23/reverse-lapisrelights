-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/PVPRankingList.lua

local PVPRankingListInfo = {
	ID = {
		type = "integer"
	},
	RankingListID = {
		type = "integer"
	},
	RankingId = {
		type = "integer"
	},
	RankingTitle = {
		type = "integer"
	},
	RankingScoreFrom = {
		type = "integer"
	},
	RankingScoreTo = {
		type = "integer"
	},
	StageId = {
		type = "integer"
	},
	RankingIcon = {
		type = "text"
	}
}
local PVPRankingListCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local PVPRankingList = {}

function PVPRankingList:GetAllSync()
	if PVPRankingListCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("PVPRankingList", "select * from PVPRankingList")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, PVPRankingListInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(PVPRankingListCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	PVPRankingListCtrl.hasCached = true
	PVPRankingList.GetAllSync = nil
	PVPRankingList.GetAllASync = nil
end

function PVPRankingList:GetAllASync()
	if PVPRankingListCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("PVPRankingList", "select * from PVPRankingList", function()
		local rowsList = SqlLiteSupport.GetCacheData("PVPRankingList")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, PVPRankingListInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(PVPRankingListCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		PVPRankingListCtrl.hasCached = true
		PVPRankingList.GetAllSync = nil
		PVPRankingList.GetAllASync = nil
	end)
end

setmetatable(PVPRankingList, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("PVPRankingList", SqlLiteTransfer.GenSql("PVPRankingList", PVPRankingListCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, PVPRankingListInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
PVPRankingList:GetAllSync()

return PVPRankingList
