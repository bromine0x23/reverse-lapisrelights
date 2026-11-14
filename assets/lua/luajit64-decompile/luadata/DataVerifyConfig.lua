-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/DataVerifyConfig.lua

local DataVerifyConfigInfo = {
	ID = {
		type = "integer"
	},
	StageAndCount1 = {
		default = "[]",
		type = "array"
	},
	StageAndCount2 = {
		default = "[]",
		type = "array"
	}
}
local DataVerifyConfigCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local DataVerifyConfig = {}

function DataVerifyConfig:GetAllSync()
	if DataVerifyConfigCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("DataVerifyConfig", "select * from DataVerifyConfig")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, DataVerifyConfigInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(DataVerifyConfigCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	DataVerifyConfigCtrl.hasCached = true
	DataVerifyConfig.GetAllSync = nil
	DataVerifyConfig.GetAllASync = nil
end

function DataVerifyConfig:GetAllASync()
	if DataVerifyConfigCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("DataVerifyConfig", "select * from DataVerifyConfig", function()
		local rowsList = SqlLiteSupport.GetCacheData("DataVerifyConfig")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, DataVerifyConfigInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(DataVerifyConfigCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		DataVerifyConfigCtrl.hasCached = true
		DataVerifyConfig.GetAllSync = nil
		DataVerifyConfig.GetAllASync = nil
	end)
end

setmetatable(DataVerifyConfig, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("DataVerifyConfig", SqlLiteTransfer.GenSql("DataVerifyConfig", DataVerifyConfigCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, DataVerifyConfigInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
DataVerifyConfig:GetAllSync()

return DataVerifyConfig
