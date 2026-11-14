-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ShopData.lua

local ShopDataInfo = {
	ID = {
		type = "integer"
	},
	TabIndex = {
		type = "integer"
	},
	Type = {
		type = "integer"
	},
	SubTabIndex = {
		type = "integer"
	},
	SubType = {
		type = "integer"
	},
	OpenType = {
		type = "integer"
	},
	ShopCloseType = {
		type = "integer"
	},
	Subpic = {
		type = "integer"
	},
	UpdateType = {
		type = "integer"
	},
	ShopTimeShow = {
		type = "integer"
	},
	CreateAccountShopTime = {
		type = "integer"
	},
	BeginTime = {
		type = "text"
	},
	EndTime = {
		type = "text"
	},
	ResList = {
		default = "[]",
		type = "array"
	}
}
local ShopDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ShopData = {}

function ShopData:GetAllSync()
	if ShopDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ShopData", "select * from ShopData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ShopDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ShopDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ShopDataCtrl.hasCached = true
	ShopData.GetAllSync = nil
	ShopData.GetAllASync = nil
end

function ShopData:GetAllASync()
	if ShopDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ShopData", "select * from ShopData", function()
		local rowsList = SqlLiteSupport.GetCacheData("ShopData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ShopDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ShopDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ShopDataCtrl.hasCached = true
		ShopData.GetAllSync = nil
		ShopData.GetAllASync = nil
	end)
end

setmetatable(ShopData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ShopData", SqlLiteTransfer.GenSql("ShopData", ShopDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ShopDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ShopData:GetAllSync()

return ShopData
