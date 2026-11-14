-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/PVPBotPlayer.lua

local PVPBotPlayerInfo = {
	ID = {
		type = "integer"
	},
	FromFightValue = {
		type = "integer"
	},
	ToFightValue = {
		type = "integer"
	},
	FromExp = {
		type = "integer"
	},
	ToExp = {
		type = "integer"
	},
	BotNum = {
		type = "integer"
	},
	FromPVPRankPoint = {
		type = "integer"
	},
	ToPVPRankPoint = {
		type = "integer"
	}
}
local PVPBotPlayerCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local PVPBotPlayer = {}

function PVPBotPlayer:GetAllSync()
	if PVPBotPlayerCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("PVPBotPlayer", "select * from PVPBotPlayer")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, PVPBotPlayerInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(PVPBotPlayerCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	PVPBotPlayerCtrl.hasCached = true
	PVPBotPlayer.GetAllSync = nil
	PVPBotPlayer.GetAllASync = nil
end

function PVPBotPlayer:GetAllASync()
	if PVPBotPlayerCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("PVPBotPlayer", "select * from PVPBotPlayer", function()
		local rowsList = SqlLiteSupport.GetCacheData("PVPBotPlayer")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, PVPBotPlayerInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(PVPBotPlayerCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		PVPBotPlayerCtrl.hasCached = true
		PVPBotPlayer.GetAllSync = nil
		PVPBotPlayer.GetAllASync = nil
	end)
end

setmetatable(PVPBotPlayer, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("PVPBotPlayer", SqlLiteTransfer.GenSql("PVPBotPlayer", PVPBotPlayerCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, PVPBotPlayerInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
PVPBotPlayer:GetAllSync()

return PVPBotPlayer
