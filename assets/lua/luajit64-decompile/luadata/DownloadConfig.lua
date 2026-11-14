-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/DownloadConfig.lua

local DownloadConfigInfo = {
	ID = {
		type = "integer"
	},
	StageId = {
		default = "0",
		type = "integer"
	},
	TopicId = {
		type = "integer"
	},
	BundleName = {
		default = "[]",
		type = "array"
	},
	SoundBankName = {
		default = "[]",
		type = "array"
	}
}
local DownloadConfigCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local DownloadConfig = {}

function DownloadConfig:GetAllSync()
	if DownloadConfigCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("DownloadConfig", "select * from DownloadConfig")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, DownloadConfigInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(DownloadConfigCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	DownloadConfigCtrl.hasCached = true
	DownloadConfig.GetAllSync = nil
	DownloadConfig.GetAllASync = nil
end

function DownloadConfig:GetAllASync()
	if DownloadConfigCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("DownloadConfig", "select * from DownloadConfig", function()
		local rowsList = SqlLiteSupport.GetCacheData("DownloadConfig")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, DownloadConfigInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(DownloadConfigCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		DownloadConfigCtrl.hasCached = true
		DownloadConfig.GetAllSync = nil
		DownloadConfig.GetAllASync = nil
	end)
end

setmetatable(DownloadConfig, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("DownloadConfig", SqlLiteTransfer.GenSql("DownloadConfig", DownloadConfigCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, DownloadConfigInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
DownloadConfig:GetAllSync()

return DownloadConfig
