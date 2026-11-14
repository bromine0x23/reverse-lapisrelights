-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/AREmotions.lua

local AREmotionsInfo = {
	ID = {
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	Character = {
		type = "integer"
	},
	Emotion = {
		type = "integer"
	}
}
local AREmotionsCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local AREmotions = {}

function AREmotions:GetAllSync()
	if AREmotionsCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("AREmotions", "select * from AREmotions")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, AREmotionsInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(AREmotionsCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	AREmotionsCtrl.hasCached = true
	AREmotions.GetAllSync = nil
	AREmotions.GetAllASync = nil
end

function AREmotions:GetAllASync()
	if AREmotionsCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("AREmotions", "select * from AREmotions", function()
		local rowsList = SqlLiteSupport.GetCacheData("AREmotions")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, AREmotionsInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(AREmotionsCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		AREmotionsCtrl.hasCached = true
		AREmotions.GetAllSync = nil
		AREmotions.GetAllASync = nil
	end)
end

setmetatable(AREmotions, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("AREmotions", SqlLiteTransfer.GenSql("AREmotions", AREmotionsCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, AREmotionsInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
AREmotions:GetAllSync()

return AREmotions
