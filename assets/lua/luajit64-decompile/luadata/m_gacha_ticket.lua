-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/m_gacha_ticket.lua

local m_gacha_ticketInfo = {
	id = {
		type = "integer"
	},
	oz_id = {
		type = "integer"
	},
	ticket_type = {
		type = "text"
	}
}
local m_gacha_ticketCtrl = {
	keyWord = "id",
	keyWordNum = 1,
	hasCached = false
}
local m_gacha_ticket = {}

function m_gacha_ticket:GetAllSync()
	if m_gacha_ticketCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("m_gacha_ticket", "select * from m_gacha_ticket")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_gacha_ticketInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(m_gacha_ticketCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	m_gacha_ticketCtrl.hasCached = true
	m_gacha_ticket.GetAllSync = nil
	m_gacha_ticket.GetAllASync = nil
end

function m_gacha_ticket:GetAllASync()
	if m_gacha_ticketCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("m_gacha_ticket", "select * from m_gacha_ticket", function()
		local rowsList = SqlLiteSupport.GetCacheData("m_gacha_ticket")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_gacha_ticketInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(m_gacha_ticketCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		m_gacha_ticketCtrl.hasCached = true
		m_gacha_ticket.GetAllSync = nil
		m_gacha_ticket.GetAllASync = nil
	end)
end

setmetatable(m_gacha_ticket, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("m_gacha_ticket", SqlLiteTransfer.GenSql("m_gacha_ticket", m_gacha_ticketCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, m_gacha_ticketInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
m_gacha_ticket:GetAllSync()

return m_gacha_ticket
