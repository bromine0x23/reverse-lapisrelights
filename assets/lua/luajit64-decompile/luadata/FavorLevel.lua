-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/FavorLevel.lua

local FavorLevelInfo = {
	ID = {
		type = "integer"
	},
	FavorPoint = {
		type = "integer"
	},
	FavorPointAdd = {
		type = "integer"
	},
	FavorLevelTouchPoint = {
		type = "integer"
	},
	LevelAward = {
		default = "[]",
		type = "array"
	},
	CardCostRatio = {
		type = "integer"
	}
}
local FavorLevelCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local FavorLevel = {}

function FavorLevel:GetAllSync()
	if FavorLevelCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("FavorLevel", "select * from FavorLevel")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, FavorLevelInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(FavorLevelCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	FavorLevelCtrl.hasCached = true
	FavorLevel.GetAllSync = nil
	FavorLevel.GetAllASync = nil
end

function FavorLevel:GetAllASync()
	if FavorLevelCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("FavorLevel", "select * from FavorLevel", function()
		local rowsList = SqlLiteSupport.GetCacheData("FavorLevel")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, FavorLevelInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(FavorLevelCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		FavorLevelCtrl.hasCached = true
		FavorLevel.GetAllSync = nil
		FavorLevel.GetAllASync = nil
	end)
end

setmetatable(FavorLevel, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("FavorLevel", SqlLiteTransfer.GenSql("FavorLevel", FavorLevelCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, FavorLevelInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
FavorLevel:GetAllSync()

return FavorLevel
