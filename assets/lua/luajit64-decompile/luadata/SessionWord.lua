-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/SessionWord.lua

local SessionWordInfo = {
	ID = {
		type = "integer"
	},
	CharacterID = {
		type = "integer"
	},
	VocalCutin = {
		type = "integer"
	},
	VocalCutin2 = {
		type = "integer"
	},
	VocalCutin3 = {
		type = "integer"
	},
	VocalCutin4 = {
		type = "integer"
	},
	VocalCutin5 = {
		type = "integer"
	},
	VocalStart = {
		type = "integer"
	},
	VocalStart2 = {
		type = "integer"
	},
	VocalStart3 = {
		type = "integer"
	},
	VocalStart4 = {
		type = "integer"
	},
	VocalHit = {
		type = "integer"
	},
	VocalHitMid = {
		type = "integer"
	},
	VocalHitMax = {
		type = "integer"
	},
	VocalRecover = {
		type = "integer"
	},
	VocalRecover2 = {
		type = "integer"
	},
	VocalDebuff = {
		type = "integer"
	},
	VocalAtkRandom1 = {
		type = "integer"
	},
	VocalAtkRandom2 = {
		type = "integer"
	},
	VocalAtkRandom3 = {
		type = "integer"
	}
}
local SessionWordCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local SessionWord = {}

function SessionWord:GetAllSync()
	if SessionWordCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("SessionWord", "select * from SessionWord")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, SessionWordInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(SessionWordCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	SessionWordCtrl.hasCached = true
	SessionWord.GetAllSync = nil
	SessionWord.GetAllASync = nil
end

function SessionWord:GetAllASync()
	if SessionWordCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("SessionWord", "select * from SessionWord", function()
		local rowsList = SqlLiteSupport.GetCacheData("SessionWord")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, SessionWordInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(SessionWordCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		SessionWordCtrl.hasCached = true
		SessionWord.GetAllSync = nil
		SessionWord.GetAllASync = nil
	end)
end

setmetatable(SessionWord, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("SessionWord", SqlLiteTransfer.GenSql("SessionWord", SessionWordCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, SessionWordInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
SessionWord:GetAllSync()

return SessionWord
