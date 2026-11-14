-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/DataAttrVerify.lua

local DataAttrVerifyInfo = {
	ID = {
		type = "integer"
	},
	CardLevel = {
		default = "[]",
		type = "array"
	},
	Talent = {
		default = "[]",
		type = "array"
	},
	EquipmentLevel = {
		default = "[]",
		type = "array"
	},
	EquipmentQuality = {
		default = "[]",
		type = "array"
	},
	Star = {
		default = "[]",
		type = "array"
	}
}
local DataAttrVerifyCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local DataAttrVerify = {}

function DataAttrVerify:GetAllSync()
	if DataAttrVerifyCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("DataAttrVerify", "select * from DataAttrVerify")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, DataAttrVerifyInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(DataAttrVerifyCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	DataAttrVerifyCtrl.hasCached = true
	DataAttrVerify.GetAllSync = nil
	DataAttrVerify.GetAllASync = nil
end

function DataAttrVerify:GetAllASync()
	if DataAttrVerifyCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("DataAttrVerify", "select * from DataAttrVerify", function()
		local rowsList = SqlLiteSupport.GetCacheData("DataAttrVerify")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, DataAttrVerifyInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(DataAttrVerifyCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		DataAttrVerifyCtrl.hasCached = true
		DataAttrVerify.GetAllSync = nil
		DataAttrVerify.GetAllASync = nil
	end)
end

setmetatable(DataAttrVerify, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("DataAttrVerify", SqlLiteTransfer.GenSql("DataAttrVerify", DataAttrVerifyCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, DataAttrVerifyInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
DataAttrVerify:GetAllSync()

return DataAttrVerify
