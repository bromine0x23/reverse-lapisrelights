-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/m_billing_google_product.lua

local m_billing_google_productInfo = {
	id = {
		type = "integer"
	},
	product_type = {
		type = "text"
	},
	product_id = {
		type = "integer"
	},
	platform_product_id = {
		type = "text"
	},
	retail_price_unit = {
		type = "text"
	},
	retail_price = {
		type = "integer"
	},
	yen_price = {
		type = "integer"
	},
	org_yen_price = {
		type = "integer"
	}
}
local m_billing_google_productCtrl = {
	keyWord = "id",
	keyWordNum = 1,
	hasCached = false
}
local m_billing_google_product = {}

function m_billing_google_product:GetAllSync()
	if m_billing_google_productCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("m_billing_google_product", "select * from m_billing_google_product")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_billing_google_productInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(m_billing_google_productCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	m_billing_google_productCtrl.hasCached = true
	m_billing_google_product.GetAllSync = nil
	m_billing_google_product.GetAllASync = nil
end

function m_billing_google_product:GetAllASync()
	if m_billing_google_productCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("m_billing_google_product", "select * from m_billing_google_product", function()
		local rowsList = SqlLiteSupport.GetCacheData("m_billing_google_product")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_billing_google_productInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(m_billing_google_productCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		m_billing_google_productCtrl.hasCached = true
		m_billing_google_product.GetAllSync = nil
		m_billing_google_product.GetAllASync = nil
	end)
end

setmetatable(m_billing_google_product, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("m_billing_google_product", SqlLiteTransfer.GenSql("m_billing_google_product", m_billing_google_productCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, m_billing_google_productInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
m_billing_google_product:GetAllSync()

return m_billing_google_product
