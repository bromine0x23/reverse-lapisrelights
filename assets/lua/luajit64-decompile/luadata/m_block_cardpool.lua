-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/m_block_cardpool.lua

local m_block_cardpoolInfo = {
	id = {
		type = "integer"
	},
	item_id = {
		type = "integer"
	},
	number = {
		type = "integer"
	},
	block_card_pool_id = {
		type = "array"
	},
	start_time = {
		type = "text"
	},
	end_time = {
		type = "text"
	}
}
local m_block_cardpoolCtrl = {
	keyWord = "id",
	keyWordNum = 1,
	hasCached = false
}
local m_block_cardpool = {}

function m_block_cardpool:GetAllSync()
	if m_block_cardpoolCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("m_block_cardpool", "select * from m_block_cardpool")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_block_cardpoolInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(m_block_cardpoolCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	m_block_cardpoolCtrl.hasCached = true
	m_block_cardpool.GetAllSync = nil
	m_block_cardpool.GetAllASync = nil
end

function m_block_cardpool:GetAllASync()
	if m_block_cardpoolCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("m_block_cardpool", "select * from m_block_cardpool", function()
		local rowsList = SqlLiteSupport.GetCacheData("m_block_cardpool")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_block_cardpoolInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(m_block_cardpoolCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		m_block_cardpoolCtrl.hasCached = true
		m_block_cardpool.GetAllSync = nil
		m_block_cardpool.GetAllASync = nil
	end)
end

setmetatable(m_block_cardpool, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("m_block_cardpool", SqlLiteTransfer.GenSql("m_block_cardpool", m_block_cardpoolCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, m_block_cardpoolInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
m_block_cardpool:GetAllSync()

return m_block_cardpool
