-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/m_billing_product_asset.lua

local m_billing_product_assetInfo = {
	id = {
		type = "integer"
	},
	product_type = {
		type = "text"
	},
	product_id = {
		type = "integer"
	},
	name = {
		type = "text"
	},
	description = {
		type = "text"
	},
	image_asset_path = {
		type = "text"
	}
}
local m_billing_product_assetCtrl = {
	keyWord = "product_id",
	keyWord2 = "product_type",
	keyWordNum = 2,
	hasCached = false
}
local m_billing_product_asset = {}

function m_billing_product_asset:GetAllSync()
	if m_billing_product_assetCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("m_billing_product_asset", "select * from m_billing_product_asset")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_billing_product_assetInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(m_billing_product_assetCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	m_billing_product_assetCtrl.hasCached = true
	m_billing_product_asset.GetAllSync = nil
	m_billing_product_asset.GetAllASync = nil
end

function m_billing_product_asset:GetAllASync()
	if m_billing_product_assetCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("m_billing_product_asset", "select * from m_billing_product_asset", function()
		local rowsList = SqlLiteSupport.GetCacheData("m_billing_product_asset")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_billing_product_assetInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(m_billing_product_assetCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		m_billing_product_assetCtrl.hasCached = true
		m_billing_product_asset.GetAllSync = nil
		m_billing_product_asset.GetAllASync = nil
	end)
end

setmetatable(m_billing_product_asset, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("m_billing_product_asset", SqlLiteTransfer.GenSql("m_billing_product_asset", m_billing_product_assetCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, m_billing_product_assetInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
m_billing_product_asset:GetAllSync()

return m_billing_product_asset
