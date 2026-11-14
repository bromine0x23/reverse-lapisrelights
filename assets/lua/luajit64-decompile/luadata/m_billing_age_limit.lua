-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/m_billing_age_limit.lua

local m_billing_age_limitInfo = {
	id = {
		type = "integer"
	},
	age = {
		type = "integer"
	},
	limit_price = {
		type = "integer"
	}
}
local m_billing_age_limitCtrl = {
	keyWord = "id",
	keyWordNum = 1,
	hasCached = false
}
local m_billing_age_limit = {}

function m_billing_age_limit:GetAllSync()
	if m_billing_age_limitCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("m_billing_age_limit", "select * from m_billing_age_limit")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_billing_age_limitInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(m_billing_age_limitCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	m_billing_age_limitCtrl.hasCached = true
	m_billing_age_limit.GetAllSync = nil
	m_billing_age_limit.GetAllASync = nil
end

function m_billing_age_limit:GetAllASync()
	if m_billing_age_limitCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("m_billing_age_limit", "select * from m_billing_age_limit", function()
		local rowsList = SqlLiteSupport.GetCacheData("m_billing_age_limit")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_billing_age_limitInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(m_billing_age_limitCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		m_billing_age_limitCtrl.hasCached = true
		m_billing_age_limit.GetAllSync = nil
		m_billing_age_limit.GetAllASync = nil
	end)
end

setmetatable(m_billing_age_limit, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("m_billing_age_limit", SqlLiteTransfer.GenSql("m_billing_age_limit", m_billing_age_limitCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, m_billing_age_limitInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
m_billing_age_limit:GetAllSync()

return m_billing_age_limit
