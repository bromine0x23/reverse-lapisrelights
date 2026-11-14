-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/m_virtual_money_history_reason_setting.lua

local m_virtual_money_history_reason_settingInfo = {
	id = {
		type = "integer"
	},
	reason = {
		type = "text"
	},
	text = {
		type = "text"
	}
}
local m_virtual_money_history_reason_settingCtrl = {
	keyWord = "id",
	keyWordNum = 1,
	hasCached = false
}
local m_virtual_money_history_reason_setting = {}

function m_virtual_money_history_reason_setting:GetAllSync()
	if m_virtual_money_history_reason_settingCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("m_virtual_money_history_reason_setting", "select * from m_virtual_money_history_reason_setting")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_virtual_money_history_reason_settingInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(m_virtual_money_history_reason_settingCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	m_virtual_money_history_reason_settingCtrl.hasCached = true
	m_virtual_money_history_reason_setting.GetAllSync = nil
	m_virtual_money_history_reason_setting.GetAllASync = nil
end

function m_virtual_money_history_reason_setting:GetAllASync()
	if m_virtual_money_history_reason_settingCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("m_virtual_money_history_reason_setting", "select * from m_virtual_money_history_reason_setting", function()
		local rowsList = SqlLiteSupport.GetCacheData("m_virtual_money_history_reason_setting")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_virtual_money_history_reason_settingInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(m_virtual_money_history_reason_settingCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		m_virtual_money_history_reason_settingCtrl.hasCached = true
		m_virtual_money_history_reason_setting.GetAllSync = nil
		m_virtual_money_history_reason_setting.GetAllASync = nil
	end)
end

setmetatable(m_virtual_money_history_reason_setting, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("m_virtual_money_history_reason_setting", SqlLiteTransfer.GenSql("m_virtual_money_history_reason_setting", m_virtual_money_history_reason_settingCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, m_virtual_money_history_reason_settingInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
m_virtual_money_history_reason_setting:GetAllSync()

return m_virtual_money_history_reason_setting
