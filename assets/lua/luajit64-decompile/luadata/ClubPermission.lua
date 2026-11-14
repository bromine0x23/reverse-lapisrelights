-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ClubPermission.lua

local ClubPermissionInfo = {
	ID = {
		type = "integer"
	},
	JobType = {
		type = "integer"
	},
	Func = {
		type = "integer"
	},
	JobLimit = {
		default = "[]",
		type = "array"
	}
}
local ClubPermissionCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ClubPermission = {}

function ClubPermission:GetAllSync()
	if ClubPermissionCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ClubPermission", "select * from ClubPermission")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ClubPermissionInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ClubPermissionCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ClubPermissionCtrl.hasCached = true
	ClubPermission.GetAllSync = nil
	ClubPermission.GetAllASync = nil
end

function ClubPermission:GetAllASync()
	if ClubPermissionCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ClubPermission", "select * from ClubPermission", function()
		local rowsList = SqlLiteSupport.GetCacheData("ClubPermission")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ClubPermissionInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ClubPermissionCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ClubPermissionCtrl.hasCached = true
		ClubPermission.GetAllSync = nil
		ClubPermission.GetAllASync = nil
	end)
end

setmetatable(ClubPermission, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ClubPermission", SqlLiteTransfer.GenSql("ClubPermission", ClubPermissionCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ClubPermissionInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ClubPermission:GetAllSync()

return ClubPermission
