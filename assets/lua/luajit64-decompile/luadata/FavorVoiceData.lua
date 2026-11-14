-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/FavorVoiceData.lua

local FavorVoiceDataInfo = {
	ID = {
		type = "integer"
	},
	CharacterId = {
		type = "integer"
	},
	MotionList = {
		default = "[]",
		type = "array"
	},
	VoiceTitle = {
		default = "[]",
		type = "array"
	}
}
local FavorVoiceDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local FavorVoiceData = {}

function FavorVoiceData:GetAllSync()
	if FavorVoiceDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("FavorVoiceData", "select * from FavorVoiceData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, FavorVoiceDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(FavorVoiceDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	FavorVoiceDataCtrl.hasCached = true
	FavorVoiceData.GetAllSync = nil
	FavorVoiceData.GetAllASync = nil
end

function FavorVoiceData:GetAllASync()
	if FavorVoiceDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("FavorVoiceData", "select * from FavorVoiceData", function()
		local rowsList = SqlLiteSupport.GetCacheData("FavorVoiceData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, FavorVoiceDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(FavorVoiceDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		FavorVoiceDataCtrl.hasCached = true
		FavorVoiceData.GetAllSync = nil
		FavorVoiceData.GetAllASync = nil
	end)
end

setmetatable(FavorVoiceData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("FavorVoiceData", SqlLiteTransfer.GenSql("FavorVoiceData", FavorVoiceDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, FavorVoiceDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
FavorVoiceData:GetAllSync()

return FavorVoiceData
