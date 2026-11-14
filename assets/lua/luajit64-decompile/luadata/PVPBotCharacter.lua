-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/PVPBotCharacter.lua

local PVPBotCharacterInfo = {
	ID = {
		type = "integer"
	},
	CharacterID = {
		type = "integer"
	},
	CharacterAttr = {
		default = "[]",
		type = "array"
	}
}
local PVPBotCharacterCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local PVPBotCharacter = {}

function PVPBotCharacter:GetAllSync()
	if PVPBotCharacterCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("PVPBotCharacter", "select * from PVPBotCharacter")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, PVPBotCharacterInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(PVPBotCharacterCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	PVPBotCharacterCtrl.hasCached = true
	PVPBotCharacter.GetAllSync = nil
	PVPBotCharacter.GetAllASync = nil
end

function PVPBotCharacter:GetAllASync()
	if PVPBotCharacterCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("PVPBotCharacter", "select * from PVPBotCharacter", function()
		local rowsList = SqlLiteSupport.GetCacheData("PVPBotCharacter")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, PVPBotCharacterInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(PVPBotCharacterCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		PVPBotCharacterCtrl.hasCached = true
		PVPBotCharacter.GetAllSync = nil
		PVPBotCharacter.GetAllASync = nil
	end)
end

setmetatable(PVPBotCharacter, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("PVPBotCharacter", SqlLiteTransfer.GenSql("PVPBotCharacter", PVPBotCharacterCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, PVPBotCharacterInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
PVPBotCharacter:GetAllSync()

return PVPBotCharacter
