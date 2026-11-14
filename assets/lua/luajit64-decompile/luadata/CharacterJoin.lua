-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/CharacterJoin.lua

local CharacterJoinInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Info = {
		type = "integer"
	},
	JoinType = {
		type = "integer"
	},
	CharacterID = {
		type = "integer"
	},
	CardList = {
		default = "[]",
		type = "array"
	},
	AttList = {
		default = "[]",
		type = "array"
	}
}
local CharacterJoinCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local CharacterJoin = {}

function CharacterJoin:GetAllSync()
	if CharacterJoinCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("CharacterJoin", "select * from CharacterJoin")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, CharacterJoinInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(CharacterJoinCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	CharacterJoinCtrl.hasCached = true
	CharacterJoin.GetAllSync = nil
	CharacterJoin.GetAllASync = nil
end

function CharacterJoin:GetAllASync()
	if CharacterJoinCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("CharacterJoin", "select * from CharacterJoin", function()
		local rowsList = SqlLiteSupport.GetCacheData("CharacterJoin")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, CharacterJoinInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(CharacterJoinCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		CharacterJoinCtrl.hasCached = true
		CharacterJoin.GetAllSync = nil
		CharacterJoin.GetAllASync = nil
	end)
end

setmetatable(CharacterJoin, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("CharacterJoin", SqlLiteTransfer.GenSql("CharacterJoin", CharacterJoinCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, CharacterJoinInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
CharacterJoin:GetAllSync()

return CharacterJoin
