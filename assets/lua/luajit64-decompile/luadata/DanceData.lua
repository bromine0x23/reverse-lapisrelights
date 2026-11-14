-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/DanceData.lua

local DanceDataInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	DanceTimeLine = {
		type = "text"
	},
	Stage = {
		type = "integer"
	}
}
local DanceDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local DanceData = {}

function DanceData:GetAllSync()
	if DanceDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("DanceData", "select * from DanceData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, DanceDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(DanceDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	DanceDataCtrl.hasCached = true
	DanceData.GetAllSync = nil
	DanceData.GetAllASync = nil
end

function DanceData:GetAllASync()
	if DanceDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("DanceData", "select * from DanceData", function()
		local rowsList = SqlLiteSupport.GetCacheData("DanceData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, DanceDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(DanceDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		DanceDataCtrl.hasCached = true
		DanceData.GetAllSync = nil
		DanceData.GetAllASync = nil
	end)
end

setmetatable(DanceData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("DanceData", SqlLiteTransfer.GenSql("DanceData", DanceDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, DanceDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
DanceData:GetAllSync()

return DanceData
