-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ShopGoods.lua

local ShopGoodsInfo = {
	ID = {
		type = "integer"
	},
	ShopID = {
		type = "integer"
	},
	DayNum = {
		type = "integer"
	},
	GoodsList = {
		default = "[]",
		type = "array"
	}
}
local ShopGoodsCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ShopGoods = {}

function ShopGoods:GetAllSync()
	if ShopGoodsCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ShopGoods", "select * from ShopGoods")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ShopGoodsInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ShopGoodsCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ShopGoodsCtrl.hasCached = true
	ShopGoods.GetAllSync = nil
	ShopGoods.GetAllASync = nil
end

function ShopGoods:GetAllASync()
	if ShopGoodsCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ShopGoods", "select * from ShopGoods", function()
		local rowsList = SqlLiteSupport.GetCacheData("ShopGoods")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ShopGoodsInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ShopGoodsCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ShopGoodsCtrl.hasCached = true
		ShopGoods.GetAllSync = nil
		ShopGoods.GetAllASync = nil
	end)
end

setmetatable(ShopGoods, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ShopGoods", SqlLiteTransfer.GenSql("ShopGoods", ShopGoodsCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ShopGoodsInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ShopGoods:GetAllSync()

return ShopGoods
