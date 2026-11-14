-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/CharacterCardSet.lua

local CharacterCardSetInfo = {
	ID = {
		type = "integer"
	},
	CardSet = {
		type = "integer"
	},
	Name = {
		type = "integer"
	}
}
local CharacterCardSetCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local CharacterCardSet = {}

function CharacterCardSet:GetAllSync()
	if CharacterCardSetCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("CharacterCardSet", "select * from CharacterCardSet")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, CharacterCardSetInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(CharacterCardSetCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	CharacterCardSetCtrl.hasCached = true
	CharacterCardSet.GetAllSync = nil
	CharacterCardSet.GetAllASync = nil
end

function CharacterCardSet:GetAllASync()
	if CharacterCardSetCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("CharacterCardSet", "select * from CharacterCardSet", function()
		local rowsList = SqlLiteSupport.GetCacheData("CharacterCardSet")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, CharacterCardSetInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(CharacterCardSetCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		CharacterCardSetCtrl.hasCached = true
		CharacterCardSet.GetAllSync = nil
		CharacterCardSet.GetAllASync = nil
	end)
end

setmetatable(CharacterCardSet, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("CharacterCardSet", SqlLiteTransfer.GenSql("CharacterCardSet", CharacterCardSetCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, CharacterCardSetInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
CharacterCardSet:GetAllSync()

return CharacterCardSet
