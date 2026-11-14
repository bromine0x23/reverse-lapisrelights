-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/Language.lua

local LanguageInfo = {
	ID = {
		type = "integer"
	},
	Key = {
		type = "text"
	},
	Value = {
		type = "text"
	}
}
local LanguageCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local Language = {}

function Language:GetAllSync()
	if LanguageCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("Language", "select * from Language")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, LanguageInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(LanguageCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	LanguageCtrl.hasCached = true
	Language.GetAllSync = nil
	Language.GetAllASync = nil
end

function Language:GetAllASync()
	if LanguageCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("Language", "select * from Language", function()
		local rowsList = SqlLiteSupport.GetCacheData("Language")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, LanguageInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(LanguageCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		LanguageCtrl.hasCached = true
		Language.GetAllSync = nil
		Language.GetAllASync = nil
	end)
end

setmetatable(Language, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("Language", SqlLiteTransfer.GenSql("Language", LanguageCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, LanguageInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
Language:GetAllSync()

return Language
