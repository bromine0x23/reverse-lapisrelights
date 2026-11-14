-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ItemData.lua

local ItemDataInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Info = {
		type = "integer"
	},
	Compose = {
		default = "[]",
		type = "array"
	},
	UseId = {
		type = "integer"
	},
	UseInfo = {
		type = "integer"
	},
	Level = {
		type = "integer"
	},
	BagPage = {
		type = "integer"
	},
	Priority = {
		type = "integer"
	},
	Type = {
		type = "text"
	},
	SubType = {
		type = "text"
	},
	ShowNum = {
		default = "0",
		type = "integer"
	},
	Quality = {
		type = "integer"
	},
	MaxNum = {
		type = "integer"
	},
	MailNum = {
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	Value = {
		type = "integer"
	},
	ItemShowTime = {
		type = "text"
	},
	Time = {
		type = "text"
	},
	LastTime = {
		type = "integer"
	},
	BackId = {
		type = "integer"
	},
	FromWhere = {
		default = "[]",
		type = "array"
	}
}
local ItemDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ItemData = {}

function ItemData:GetAllSync()
	if ItemDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ItemData", "select * from ItemData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ItemDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ItemDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ItemDataCtrl.hasCached = true
	ItemData.GetAllSync = nil
	ItemData.GetAllASync = nil
end

function ItemData:GetAllASync()
	if ItemDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ItemData", "select * from ItemData", function()
		local rowsList = SqlLiteSupport.GetCacheData("ItemData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ItemDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ItemDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ItemDataCtrl.hasCached = true
		ItemData.GetAllSync = nil
		ItemData.GetAllASync = nil
	end)
end

setmetatable(ItemData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ItemData", SqlLiteTransfer.GenSql("ItemData", ItemDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ItemDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ItemData:GetAllSync()

return ItemData
