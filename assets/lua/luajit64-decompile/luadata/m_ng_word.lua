-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/m_ng_word.lua

local m_ng_wordInfo = {
	id = {
		type = "integer"
	},
	judge_type = {
		type = "integer"
	},
	ng_word = {
		type = "text"
	}
}
local m_ng_wordCtrl = {
	keyWord = "id",
	keyWordNum = 1,
	hasCached = false
}
local m_ng_word = {}

function m_ng_word:GetAllSync()
	if m_ng_wordCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("m_ng_word", "select * from m_ng_word")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_ng_wordInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(m_ng_wordCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	m_ng_wordCtrl.hasCached = true
	m_ng_word.GetAllSync = nil
	m_ng_word.GetAllASync = nil
end

function m_ng_word:GetAllASync()
	if m_ng_wordCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("m_ng_word", "select * from m_ng_word", function()
		local rowsList = SqlLiteSupport.GetCacheData("m_ng_word")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, m_ng_wordInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(m_ng_wordCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		m_ng_wordCtrl.hasCached = true
		m_ng_word.GetAllSync = nil
		m_ng_word.GetAllASync = nil
	end)
end

setmetatable(m_ng_word, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("m_ng_word", SqlLiteTransfer.GenSql("m_ng_word", m_ng_wordCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, m_ng_wordInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
m_ng_word:GetAllSync()

return m_ng_word
