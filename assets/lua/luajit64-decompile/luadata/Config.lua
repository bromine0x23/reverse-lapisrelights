-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/Config.lua

local ConfigInfo = {
	ID = {
		type = "integer"
	},
	Key = {
		type = "text"
	},
	ArgInt = {
		type = "integer"
	},
	ArgFloat = {
		default = "1",
		type = "float"
	},
	ArgString = {
		type = "text"
	},
	ArgJson = {
		default = "[]",
		type = "array"
	}
}
local ConfigCtrl = {
	keyWord = "Key",
	keyWordNum = 1,
	hasCached = false
}
local Config = {}

function Config:GetAllSync()
	if ConfigCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("Config", "select * from Config")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ConfigInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ConfigCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ConfigCtrl.hasCached = true
	Config.GetAllSync = nil
	Config.GetAllASync = nil
end

function Config:GetAllASync()
	if ConfigCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("Config", "select * from Config", function()
		local rowsList = SqlLiteSupport.GetCacheData("Config")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ConfigInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ConfigCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ConfigCtrl.hasCached = true
		Config.GetAllSync = nil
		Config.GetAllASync = nil
	end)
end

setmetatable(Config, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("Config", "select * from Config where Key = '" .. key .. "'")

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ConfigInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
Config:GetAllSync()

return Config
