-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/Nickname.lua

local NicknameInfo = {
	ID = {
		type = "integer"
	},
	PrefixName = {
		type = "integer"
	},
	SuffixName = {
		type = "integer"
	}
}
local NicknameCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local Nickname = {}

function Nickname:GetAllSync()
	if NicknameCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("Nickname", "select * from Nickname")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, NicknameInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(NicknameCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	NicknameCtrl.hasCached = true
	Nickname.GetAllSync = nil
	Nickname.GetAllASync = nil
end

function Nickname:GetAllASync()
	if NicknameCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("Nickname", "select * from Nickname", function()
		local rowsList = SqlLiteSupport.GetCacheData("Nickname")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, NicknameInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(NicknameCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		NicknameCtrl.hasCached = true
		Nickname.GetAllSync = nil
		Nickname.GetAllASync = nil
	end)
end

setmetatable(Nickname, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("Nickname", SqlLiteTransfer.GenSql("Nickname", NicknameCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, NicknameInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
Nickname:GetAllSync()

return Nickname
