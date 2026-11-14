-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/PushConfig.lua

local PushConfigInfo = {
	ID = {
		type = "integer"
	},
	MobilePhoneType = {
		type = "integer"
	},
	Title = {
		type = "integer"
	},
	Content = {
		type = "integer"
	},
	StartTime = {
		type = "text"
	},
	EndTime = {
		type = "text"
	},
	PushType = {
		type = "integer"
	},
	PushCycle = {
		type = "text"
	},
	PushTime = {
		type = "text"
	},
	Daylimit = {
		type = "integer"
	},
	PushInterval = {
		type = "integer"
	},
	SpecifyTimePush = {
		type = "text"
	},
	MixPushTime = {
		type = "text"
	},
	MaxPushTime = {
		type = "text"
	},
	PushIcon = {
		type = "text"
	}
}
local PushConfigCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local PushConfig = {}

function PushConfig:GetAllSync()
	if PushConfigCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("PushConfig", "select * from PushConfig")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, PushConfigInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(PushConfigCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	PushConfigCtrl.hasCached = true
	PushConfig.GetAllSync = nil
	PushConfig.GetAllASync = nil
end

function PushConfig:GetAllASync()
	if PushConfigCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("PushConfig", "select * from PushConfig", function()
		local rowsList = SqlLiteSupport.GetCacheData("PushConfig")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, PushConfigInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(PushConfigCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		PushConfigCtrl.hasCached = true
		PushConfig.GetAllSync = nil
		PushConfig.GetAllASync = nil
	end)
end

setmetatable(PushConfig, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("PushConfig", SqlLiteTransfer.GenSql("PushConfig", PushConfigCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, PushConfigInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
PushConfig:GetAllSync()

return PushConfig
