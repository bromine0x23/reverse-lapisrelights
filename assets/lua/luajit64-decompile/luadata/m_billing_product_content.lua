-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/m_billing_product_content.lua

local m_billing_product_contentInfo = {
	id = {
		type = "integer"
	},
	product_type = {
		type = "text"
	},
	product_id = {
		type = "integer"
	},
	content_type = {
		type = "text"
	},
	content_id = {
		type = "text"
	},
	is_paid = {
		type = "text"
	},
	amount = {
		type = "integer"
	},
	yen_price = {
		type = "integer"
	},
	display_order = {
		type = "integer"
	},
	order_type1 = {
		type = "integer"
	},
	order_type2 = {
		type = "integer"
	},
	order_type3 = {
		type = "integer"
	}
}
local m_billing_product_contentCtrl = {
	keyWord = "id",
	keyWordNum = 1,
	hasCached = false
}
local m_billing_product_content = {}

function m_billing_product_content:GetAllSync()
	if m_billing_product_contentCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("m_billing_product_content", "select * from m_billing_product_content")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_billing_product_contentInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(m_billing_product_contentCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	m_billing_product_contentCtrl.hasCached = true
	m_billing_product_content.GetAllSync = nil
	m_billing_product_content.GetAllASync = nil
end

function m_billing_product_content:GetAllASync()
	if m_billing_product_contentCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("m_billing_product_content", "select * from m_billing_product_content", function()
		local rowsList = SqlLiteSupport.GetCacheData("m_billing_product_content")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_billing_product_contentInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(m_billing_product_contentCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		m_billing_product_contentCtrl.hasCached = true
		m_billing_product_content.GetAllSync = nil
		m_billing_product_content.GetAllASync = nil
	end)
end

setmetatable(m_billing_product_content, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("m_billing_product_content", SqlLiteTransfer.GenSql("m_billing_product_content", m_billing_product_contentCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, m_billing_product_contentInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
m_billing_product_content:GetAllSync()

return m_billing_product_content
