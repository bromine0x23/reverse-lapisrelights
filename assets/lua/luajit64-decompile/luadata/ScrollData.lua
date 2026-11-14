-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ScrollData.lua

local ScrollDataInfo = {
	ID = {
		type = "integer"
	},
	ScrollID = {
		type = "integer"
	},
	Slot = {
		type = "integer"
	},
	WeightList = {
		default = "[]",
		type = "array"
	},
	ValueList = {
		default = "[]",
		type = "array"
	},
	AttrType = {
		default = "[]",
		type = "array"
	}
}
local ScrollDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ScrollData = {}

function ScrollData:GetAllSync()
	if ScrollDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ScrollData", "select * from ScrollData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ScrollDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ScrollDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ScrollDataCtrl.hasCached = true
	ScrollData.GetAllSync = nil
	ScrollData.GetAllASync = nil
end

function ScrollData:GetAllASync()
	if ScrollDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ScrollData", "select * from ScrollData", function()
		local rowsList = SqlLiteSupport.GetCacheData("ScrollData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ScrollDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ScrollDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ScrollDataCtrl.hasCached = true
		ScrollData.GetAllSync = nil
		ScrollData.GetAllASync = nil
	end)
end

setmetatable(ScrollData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ScrollData", SqlLiteTransfer.GenSql("ScrollData", ScrollDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ScrollDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ScrollData:GetAllSync()

return ScrollData
