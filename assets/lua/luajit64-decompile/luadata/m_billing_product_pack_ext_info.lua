-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/m_billing_product_pack_ext_info.lua

local m_billing_product_pack_ext_infoInfo = {
	id = {
		type = "integer"
	},
	goods_data_id = {
		type = "integer"
	},
	item_id = {
		type = "integer"
	},
	is_paid = {
		type = "text"
	}
}
local m_billing_product_pack_ext_infoCtrl = {
	keyWord = "id",
	keyWordNum = 1,
	hasCached = false
}
local m_billing_product_pack_ext_info = {}

function m_billing_product_pack_ext_info:GetAllSync()
	if m_billing_product_pack_ext_infoCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("m_billing_product_pack_ext_info", "select * from m_billing_product_pack_ext_info")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_billing_product_pack_ext_infoInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(m_billing_product_pack_ext_infoCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	m_billing_product_pack_ext_infoCtrl.hasCached = true
	m_billing_product_pack_ext_info.GetAllSync = nil
	m_billing_product_pack_ext_info.GetAllASync = nil
end

function m_billing_product_pack_ext_info:GetAllASync()
	if m_billing_product_pack_ext_infoCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("m_billing_product_pack_ext_info", "select * from m_billing_product_pack_ext_info", function()
		local rowsList = SqlLiteSupport.GetCacheData("m_billing_product_pack_ext_info")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_billing_product_pack_ext_infoInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(m_billing_product_pack_ext_infoCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		m_billing_product_pack_ext_infoCtrl.hasCached = true
		m_billing_product_pack_ext_info.GetAllSync = nil
		m_billing_product_pack_ext_info.GetAllASync = nil
	end)
end

setmetatable(m_billing_product_pack_ext_info, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("m_billing_product_pack_ext_info", SqlLiteTransfer.GenSql("m_billing_product_pack_ext_info", m_billing_product_pack_ext_infoCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, m_billing_product_pack_ext_infoInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
m_billing_product_pack_ext_info:GetAllSync()

return m_billing_product_pack_ext_info
