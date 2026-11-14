-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/SensitiveWord.lua

local SensitiveWordInfo = {
	ID = {
		type = "integer"
	},
	Word = {
		type = "base64"
	}
}
local SensitiveWordCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local SensitiveWord = {}

function SensitiveWord:GetAllSync()
	if SensitiveWordCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("SensitiveWord", "select * from SensitiveWord")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, SensitiveWordInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(SensitiveWordCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	SensitiveWordCtrl.hasCached = true
	SensitiveWord.GetAllSync = nil
	SensitiveWord.GetAllASync = nil
end

function SensitiveWord:GetAllASync()
	if SensitiveWordCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("SensitiveWord", "select * from SensitiveWord", function()
		local rowsList = SqlLiteSupport.GetCacheData("SensitiveWord")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, SensitiveWordInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(SensitiveWordCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		SensitiveWordCtrl.hasCached = true
		SensitiveWord.GetAllSync = nil
		SensitiveWord.GetAllASync = nil
	end)
end

setmetatable(SensitiveWord, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("SensitiveWord", SqlLiteTransfer.GenSql("SensitiveWord", SensitiveWordCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, SensitiveWordInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
SensitiveWord:GetAllSync()

return SensitiveWord
