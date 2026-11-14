-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/m_billing_product_type_pack.lua

local m_billing_product_type_packInfo = {
	id = {
		type = "integer"
	},
	display_order = {
		type = "integer"
	}
}
local m_billing_product_type_packCtrl = {
	keyWord = "id",
	keyWordNum = 1,
	hasCached = false
}
local m_billing_product_type_pack = {}

function m_billing_product_type_pack:GetAllSync()
	if m_billing_product_type_packCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("m_billing_product_type_pack", "select * from m_billing_product_type_pack")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_billing_product_type_packInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(m_billing_product_type_packCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	m_billing_product_type_packCtrl.hasCached = true
	m_billing_product_type_pack.GetAllSync = nil
	m_billing_product_type_pack.GetAllASync = nil
end

function m_billing_product_type_pack:GetAllASync()
	if m_billing_product_type_packCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("m_billing_product_type_pack", "select * from m_billing_product_type_pack", function()
		local rowsList = SqlLiteSupport.GetCacheData("m_billing_product_type_pack")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_billing_product_type_packInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(m_billing_product_type_packCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		m_billing_product_type_packCtrl.hasCached = true
		m_billing_product_type_pack.GetAllSync = nil
		m_billing_product_type_pack.GetAllASync = nil
	end)
end

setmetatable(m_billing_product_type_pack, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("m_billing_product_type_pack", SqlLiteTransfer.GenSql("m_billing_product_type_pack", m_billing_product_type_packCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, m_billing_product_type_packInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
m_billing_product_type_pack:GetAllSync()

return m_billing_product_type_pack
