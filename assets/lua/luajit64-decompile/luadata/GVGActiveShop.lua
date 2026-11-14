-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/GVGActiveShop.lua

local GVGActiveShopInfo = {
	ID = {
		type = "integer"
	},
	ActiveID = {
		type = "integer"
	},
	GoodsID = {
		default = "[]",
		type = "array"
	}
}
local GVGActiveShopCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local GVGActiveShop = {}

function GVGActiveShop:GetAllSync()
	if GVGActiveShopCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("GVGActiveShop", "select * from GVGActiveShop")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, GVGActiveShopInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(GVGActiveShopCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	GVGActiveShopCtrl.hasCached = true
	GVGActiveShop.GetAllSync = nil
	GVGActiveShop.GetAllASync = nil
end

function GVGActiveShop:GetAllASync()
	if GVGActiveShopCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("GVGActiveShop", "select * from GVGActiveShop", function()
		local rowsList = SqlLiteSupport.GetCacheData("GVGActiveShop")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, GVGActiveShopInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(GVGActiveShopCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		GVGActiveShopCtrl.hasCached = true
		GVGActiveShop.GetAllSync = nil
		GVGActiveShop.GetAllASync = nil
	end)
end

setmetatable(GVGActiveShop, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("GVGActiveShop", SqlLiteTransfer.GenSql("GVGActiveShop", GVGActiveShopCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, GVGActiveShopInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
GVGActiveShop:GetAllSync()

return GVGActiveShop
