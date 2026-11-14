-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ClubLevel.lua

local ClubLevelInfo = {
	ID = {
		type = "integer"
	},
	LevelPoint = {
		type = "integer"
	},
	LevelPointAdd = {
		type = "integer"
	},
	Member = {
		type = "integer"
	}
}
local ClubLevelCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ClubLevel = {}

function ClubLevel:GetAllSync()
	if ClubLevelCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ClubLevel", "select * from ClubLevel")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ClubLevelInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ClubLevelCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ClubLevelCtrl.hasCached = true
	ClubLevel.GetAllSync = nil
	ClubLevel.GetAllASync = nil
end

function ClubLevel:GetAllASync()
	if ClubLevelCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ClubLevel", "select * from ClubLevel", function()
		local rowsList = SqlLiteSupport.GetCacheData("ClubLevel")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ClubLevelInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ClubLevelCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ClubLevelCtrl.hasCached = true
		ClubLevel.GetAllSync = nil
		ClubLevel.GetAllASync = nil
	end)
end

setmetatable(ClubLevel, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ClubLevel", SqlLiteTransfer.GenSql("ClubLevel", ClubLevelCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ClubLevelInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ClubLevel:GetAllSync()

return ClubLevel
