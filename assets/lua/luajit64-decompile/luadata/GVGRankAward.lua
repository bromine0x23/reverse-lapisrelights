-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/GVGRankAward.lua

local GVGRankAwardInfo = {
	ID = {
		type = "integer"
	},
	ActiveID = {
		type = "integer"
	},
	Rank = {
		default = "[]",
		type = "array"
	},
	Award = {
		default = "[]",
		type = "array"
	}
}
local GVGRankAwardCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local GVGRankAward = {}

function GVGRankAward:GetAllSync()
	if GVGRankAwardCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("GVGRankAward", "select * from GVGRankAward")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, GVGRankAwardInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(GVGRankAwardCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	GVGRankAwardCtrl.hasCached = true
	GVGRankAward.GetAllSync = nil
	GVGRankAward.GetAllASync = nil
end

function GVGRankAward:GetAllASync()
	if GVGRankAwardCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("GVGRankAward", "select * from GVGRankAward", function()
		local rowsList = SqlLiteSupport.GetCacheData("GVGRankAward")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, GVGRankAwardInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(GVGRankAwardCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		GVGRankAwardCtrl.hasCached = true
		GVGRankAward.GetAllSync = nil
		GVGRankAward.GetAllASync = nil
	end)
end

setmetatable(GVGRankAward, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("GVGRankAward", SqlLiteTransfer.GenSql("GVGRankAward", GVGRankAwardCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, GVGRankAwardInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
GVGRankAward:GetAllSync()

return GVGRankAward
