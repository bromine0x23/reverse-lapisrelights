-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/m_copyright.lua

local m_copyrightInfo = {
	id = {
		type = "integer"
	},
	type = {
		type = "text"
	},
	value = {
		type = "text"
	}
}
local m_copyrightCtrl = {
	keyWord = "id",
	keyWordNum = 1,
	hasCached = false
}
local m_copyright = {}

function m_copyright:GetAllSync()
	if m_copyrightCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("m_copyright", "select * from m_copyright")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_copyrightInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(m_copyrightCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	m_copyrightCtrl.hasCached = true
	m_copyright.GetAllSync = nil
	m_copyright.GetAllASync = nil
end

function m_copyright:GetAllASync()
	if m_copyrightCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("m_copyright", "select * from m_copyright", function()
		local rowsList = SqlLiteSupport.GetCacheData("m_copyright")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_copyrightInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(m_copyrightCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		m_copyrightCtrl.hasCached = true
		m_copyright.GetAllSync = nil
		m_copyright.GetAllASync = nil
	end)
end

setmetatable(m_copyright, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("m_copyright", SqlLiteTransfer.GenSql("m_copyright", m_copyrightCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, m_copyrightInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
m_copyright:GetAllSync()

return m_copyright
