-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/m_activity_free_ten_draw.lua

local m_activity_free_ten_drawInfo = {
	id = {
		type = "integer"
	},
	card_pool_id = {
		type = "array"
	},
	active_start_at = {
		type = "text"
	},
	active_close_at = {
		type = "text"
	},
	free_times = {
		type = "integer"
	},
	cumulate_or_not = {
		type = "integer"
	}
}
local m_activity_free_ten_drawCtrl = {
	keyWord = "id",
	keyWordNum = 1,
	hasCached = false
}
local m_activity_free_ten_draw = {}

function m_activity_free_ten_draw:GetAllSync()
	if m_activity_free_ten_drawCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("m_activity_free_ten_draw", "select * from m_activity_free_ten_draw")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_activity_free_ten_drawInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(m_activity_free_ten_drawCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	m_activity_free_ten_drawCtrl.hasCached = true
	m_activity_free_ten_draw.GetAllSync = nil
	m_activity_free_ten_draw.GetAllASync = nil
end

function m_activity_free_ten_draw:GetAllASync()
	if m_activity_free_ten_drawCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("m_activity_free_ten_draw", "select * from m_activity_free_ten_draw", function()
		local rowsList = SqlLiteSupport.GetCacheData("m_activity_free_ten_draw")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_activity_free_ten_drawInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(m_activity_free_ten_drawCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		m_activity_free_ten_drawCtrl.hasCached = true
		m_activity_free_ten_draw.GetAllSync = nil
		m_activity_free_ten_draw.GetAllASync = nil
	end)
end

setmetatable(m_activity_free_ten_draw, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("m_activity_free_ten_draw", SqlLiteTransfer.GenSql("m_activity_free_ten_draw", m_activity_free_ten_drawCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, m_activity_free_ten_drawInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
m_activity_free_ten_draw:GetAllSync()

return m_activity_free_ten_draw
