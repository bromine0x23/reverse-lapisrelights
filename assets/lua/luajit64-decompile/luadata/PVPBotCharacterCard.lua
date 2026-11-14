-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/PVPBotCharacterCard.lua

local PVPBotCharacterCardInfo = {
	ID = {
		type = "integer"
	},
	CharacterID = {
		type = "integer"
	},
	CardID = {
		type = "integer"
	},
	CardExp = {
		type = "integer"
	},
	Star = {
		type = "integer"
	},
	CardFlower = {
		type = "integer"
	},
	CardAttr = {
		default = "[]",
		type = "array"
	},
	DefaultActorID = {
		type = "integer"
	}
}
local PVPBotCharacterCardCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local PVPBotCharacterCard = {}

function PVPBotCharacterCard:GetAllSync()
	if PVPBotCharacterCardCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("PVPBotCharacterCard", "select * from PVPBotCharacterCard")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, PVPBotCharacterCardInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(PVPBotCharacterCardCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	PVPBotCharacterCardCtrl.hasCached = true
	PVPBotCharacterCard.GetAllSync = nil
	PVPBotCharacterCard.GetAllASync = nil
end

function PVPBotCharacterCard:GetAllASync()
	if PVPBotCharacterCardCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("PVPBotCharacterCard", "select * from PVPBotCharacterCard", function()
		local rowsList = SqlLiteSupport.GetCacheData("PVPBotCharacterCard")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, PVPBotCharacterCardInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(PVPBotCharacterCardCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		PVPBotCharacterCardCtrl.hasCached = true
		PVPBotCharacterCard.GetAllSync = nil
		PVPBotCharacterCard.GetAllASync = nil
	end)
end

setmetatable(PVPBotCharacterCard, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("PVPBotCharacterCard", SqlLiteTransfer.GenSql("PVPBotCharacterCard", PVPBotCharacterCardCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, PVPBotCharacterCardInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
PVPBotCharacterCard:GetAllSync()

return PVPBotCharacterCard
