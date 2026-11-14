-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/m_gift_box.lua

local m_gift_boxInfo = {
	id = {
		type = "integer"
	},
	total_day = {
		type = "integer"
	},
	receivable_day = {
		type = "integer"
	},
	notice_master_id = {
		type = "integer"
	},
	_publish_name = {
		type = "text"
	}
}
local m_gift_boxCtrl = {
	keyWord = "id",
	keyWordNum = 1,
	hasCached = false
}
local m_gift_box = {}

function m_gift_box:GetAllSync()
	if m_gift_boxCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("m_gift_box", "select * from m_gift_box")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_gift_boxInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(m_gift_boxCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	m_gift_boxCtrl.hasCached = true
	m_gift_box.GetAllSync = nil
	m_gift_box.GetAllASync = nil
end

function m_gift_box:GetAllASync()
	if m_gift_boxCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("m_gift_box", "select * from m_gift_box", function()
		local rowsList = SqlLiteSupport.GetCacheData("m_gift_box")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_gift_boxInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(m_gift_boxCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		m_gift_boxCtrl.hasCached = true
		m_gift_box.GetAllSync = nil
		m_gift_box.GetAllASync = nil
	end)
end

setmetatable(m_gift_box, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("m_gift_box", SqlLiteTransfer.GenSql("m_gift_box", m_gift_boxCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, m_gift_boxInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
m_gift_box:GetAllSync()

return m_gift_box
