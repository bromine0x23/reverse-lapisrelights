-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/m_gift_box_content.lua

local m_gift_box_contentInfo = {
	id = {
		type = "integer"
	},
	gift_box_m_id = {
		type = "integer"
	},
	day = {
		type = "integer"
	},
	content_type = {
		type = "text"
	},
	content_id = {
		type = "text"
	},
	amount = {
		type = "integer"
	},
	_publish_name = {
		type = "text"
	}
}
local m_gift_box_contentCtrl = {
	keyWord = "id",
	keyWordNum = 1,
	hasCached = false
}
local m_gift_box_content = {}

function m_gift_box_content:GetAllSync()
	if m_gift_box_contentCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("m_gift_box_content", "select * from m_gift_box_content")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_gift_box_contentInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(m_gift_box_contentCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	m_gift_box_contentCtrl.hasCached = true
	m_gift_box_content.GetAllSync = nil
	m_gift_box_content.GetAllASync = nil
end

function m_gift_box_content:GetAllASync()
	if m_gift_box_contentCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("m_gift_box_content", "select * from m_gift_box_content", function()
		local rowsList = SqlLiteSupport.GetCacheData("m_gift_box_content")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_gift_box_contentInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(m_gift_box_contentCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		m_gift_box_contentCtrl.hasCached = true
		m_gift_box_content.GetAllSync = nil
		m_gift_box_content.GetAllASync = nil
	end)
end

setmetatable(m_gift_box_content, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("m_gift_box_content", SqlLiteTransfer.GenSql("m_gift_box_content", m_gift_box_contentCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, m_gift_box_contentInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
m_gift_box_content:GetAllSync()

return m_gift_box_content
