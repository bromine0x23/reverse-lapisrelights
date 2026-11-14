-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/m_billing_product_type_normal.lua

local m_billing_product_type_normalInfo = {
	id = {
		type = "integer"
	},
	display_order = {
		type = "integer"
	}
}
local m_billing_product_type_normalCtrl = {
	keyWord = "id",
	keyWordNum = 1,
	hasCached = false
}
local m_billing_product_type_normal = {}

function m_billing_product_type_normal:GetAllSync()
	if m_billing_product_type_normalCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("m_billing_product_type_normal", "select * from m_billing_product_type_normal")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_billing_product_type_normalInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(m_billing_product_type_normalCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	m_billing_product_type_normalCtrl.hasCached = true
	m_billing_product_type_normal.GetAllSync = nil
	m_billing_product_type_normal.GetAllASync = nil
end

function m_billing_product_type_normal:GetAllASync()
	if m_billing_product_type_normalCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("m_billing_product_type_normal", "select * from m_billing_product_type_normal", function()
		local rowsList = SqlLiteSupport.GetCacheData("m_billing_product_type_normal")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_billing_product_type_normalInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(m_billing_product_type_normalCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		m_billing_product_type_normalCtrl.hasCached = true
		m_billing_product_type_normal.GetAllSync = nil
		m_billing_product_type_normal.GetAllASync = nil
	end)
end

setmetatable(m_billing_product_type_normal, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("m_billing_product_type_normal", SqlLiteTransfer.GenSql("m_billing_product_type_normal", m_billing_product_type_normalCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, m_billing_product_type_normalInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
m_billing_product_type_normal:GetAllSync()

return m_billing_product_type_normal
