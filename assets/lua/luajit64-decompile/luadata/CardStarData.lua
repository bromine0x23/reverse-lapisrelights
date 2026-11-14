-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/CardStarData.lua

local CardStarDataInfo = {
	ID = {
		type = "integer"
	},
	Rank = {
		type = "integer"
	},
	Star = {
		type = "integer"
	},
	Cost = {
		default = "[]",
		type = "array"
	}
}
local CardStarDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local CardStarData = {}

function CardStarData:GetAllSync()
	if CardStarDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("CardStarData", "select * from CardStarData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, CardStarDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(CardStarDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	CardStarDataCtrl.hasCached = true
	CardStarData.GetAllSync = nil
	CardStarData.GetAllASync = nil
end

function CardStarData:GetAllASync()
	if CardStarDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("CardStarData", "select * from CardStarData", function()
		local rowsList = SqlLiteSupport.GetCacheData("CardStarData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, CardStarDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(CardStarDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		CardStarDataCtrl.hasCached = true
		CardStarData.GetAllSync = nil
		CardStarData.GetAllASync = nil
	end)
end

setmetatable(CardStarData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("CardStarData", SqlLiteTransfer.GenSql("CardStarData", CardStarDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, CardStarDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
CardStarData:GetAllSync()

return CardStarData
