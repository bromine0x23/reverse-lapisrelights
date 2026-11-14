-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ClubType.lua

local ClubTypeInfo = {
	ID = {
		type = "integer"
	},
	TypeIcon = {
		type = "text"
	},
	GroupId = {
		default = "0",
		type = "integer"
	},
	GroupName = {
		type = "integer"
	},
	GroupBG = {
		type = "text"
	},
	GroupBG2 = {
		type = "text"
	},
	GroupIcon = {
		type = "text"
	},
	CharacterId = {
		default = "0",
		type = "integer"
	}
}
local ClubTypeCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ClubType = {}

function ClubType:GetAllSync()
	if ClubTypeCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ClubType", "select * from ClubType")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ClubTypeInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ClubTypeCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ClubTypeCtrl.hasCached = true
	ClubType.GetAllSync = nil
	ClubType.GetAllASync = nil
end

function ClubType:GetAllASync()
	if ClubTypeCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ClubType", "select * from ClubType", function()
		local rowsList = SqlLiteSupport.GetCacheData("ClubType")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ClubTypeInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ClubTypeCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ClubTypeCtrl.hasCached = true
		ClubType.GetAllSync = nil
		ClubType.GetAllASync = nil
	end)
end

setmetatable(ClubType, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ClubType", SqlLiteTransfer.GenSql("ClubType", ClubTypeCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ClubTypeInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ClubType:GetAllSync()

return ClubType
