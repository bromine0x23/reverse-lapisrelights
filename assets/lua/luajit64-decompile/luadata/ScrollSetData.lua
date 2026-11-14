-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ScrollSetData.lua

local ScrollSetDataInfo = {
	ID = {
		type = "integer"
	},
	ScrollType = {
		type = "integer"
	},
	Number = {
		type = "integer"
	},
	Buff = {
		type = "integer"
	},
	Info = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Img = {
		type = "text"
	}
}
local ScrollSetDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ScrollSetData = {}

function ScrollSetData:GetAllSync()
	if ScrollSetDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ScrollSetData", "select * from ScrollSetData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ScrollSetDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ScrollSetDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ScrollSetDataCtrl.hasCached = true
	ScrollSetData.GetAllSync = nil
	ScrollSetData.GetAllASync = nil
end

function ScrollSetData:GetAllASync()
	if ScrollSetDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ScrollSetData", "select * from ScrollSetData", function()
		local rowsList = SqlLiteSupport.GetCacheData("ScrollSetData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ScrollSetDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ScrollSetDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ScrollSetDataCtrl.hasCached = true
		ScrollSetData.GetAllSync = nil
		ScrollSetData.GetAllASync = nil
	end)
end

setmetatable(ScrollSetData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ScrollSetData", SqlLiteTransfer.GenSql("ScrollSetData", ScrollSetDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ScrollSetDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ScrollSetData:GetAllSync()

return ScrollSetData
