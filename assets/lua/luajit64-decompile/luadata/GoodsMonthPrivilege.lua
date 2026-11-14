-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/GoodsMonthPrivilege.lua

local GoodsMonthPrivilegeInfo = {
	ID = {
		type = "integer"
	},
	GoodsId = {
		type = "integer"
	},
	Func = {
		type = "integer"
	},
	IntValue = {
		type = "integer"
	},
	IntShow = {
		default = "[]",
		type = "array"
	},
	JsonValue = {
		default = "[]",
		type = "array"
	},
	StrValue = {
		type = "text"
	},
	Name = {
		type = "integer"
	},
	Info = {
		type = "integer"
	},
	BuffInfo = {
		type = "integer"
	},
	BuffIcon = {
		type = "text"
	}
}
local GoodsMonthPrivilegeCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local GoodsMonthPrivilege = {}

function GoodsMonthPrivilege:GetAllSync()
	if GoodsMonthPrivilegeCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("GoodsMonthPrivilege", "select * from GoodsMonthPrivilege")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, GoodsMonthPrivilegeInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(GoodsMonthPrivilegeCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	GoodsMonthPrivilegeCtrl.hasCached = true
	GoodsMonthPrivilege.GetAllSync = nil
	GoodsMonthPrivilege.GetAllASync = nil
end

function GoodsMonthPrivilege:GetAllASync()
	if GoodsMonthPrivilegeCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("GoodsMonthPrivilege", "select * from GoodsMonthPrivilege", function()
		local rowsList = SqlLiteSupport.GetCacheData("GoodsMonthPrivilege")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, GoodsMonthPrivilegeInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(GoodsMonthPrivilegeCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		GoodsMonthPrivilegeCtrl.hasCached = true
		GoodsMonthPrivilege.GetAllSync = nil
		GoodsMonthPrivilege.GetAllASync = nil
	end)
end

setmetatable(GoodsMonthPrivilege, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("GoodsMonthPrivilege", SqlLiteTransfer.GenSql("GoodsMonthPrivilege", GoodsMonthPrivilegeCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, GoodsMonthPrivilegeInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
GoodsMonthPrivilege:GetAllSync()

return GoodsMonthPrivilege
