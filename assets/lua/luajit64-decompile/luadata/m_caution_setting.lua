-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/m_caution_setting.lua

local m_caution_settingInfo = {
	id = {
		type = "integer"
	},
	scene = {
		type = "text"
	},
	method = {
		type = "text"
	},
	is_once = {
		type = "text"
	},
	default_title = {
		type = "text"
	},
	default_message = {
		type = "text"
	},
	mail_subject = {
		type = "text"
	},
	mail_body = {
		type = "text"
	}
}
local m_caution_settingCtrl = {
	keyWord = "scene",
	keyWord2 = "method",
	keyWordNum = 2,
	hasCached = false
}
local m_caution_setting = {}

function m_caution_setting:GetAllSync()
	if m_caution_settingCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("m_caution_setting", "select * from m_caution_setting")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_caution_settingInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(m_caution_settingCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	m_caution_settingCtrl.hasCached = true
	m_caution_setting.GetAllSync = nil
	m_caution_setting.GetAllASync = nil
end

function m_caution_setting:GetAllASync()
	if m_caution_settingCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("m_caution_setting", "select * from m_caution_setting", function()
		local rowsList = SqlLiteSupport.GetCacheData("m_caution_setting")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_caution_settingInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(m_caution_settingCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		m_caution_settingCtrl.hasCached = true
		m_caution_setting.GetAllSync = nil
		m_caution_setting.GetAllASync = nil
	end)
end

setmetatable(m_caution_setting, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("m_caution_setting", SqlLiteTransfer.GenSql("m_caution_setting", m_caution_settingCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, m_caution_settingInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
m_caution_setting:GetAllSync()

return m_caution_setting
