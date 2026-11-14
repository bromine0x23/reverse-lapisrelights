-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/Mail.lua

local MailInfo = {
	ID = {
		type = "integer"
	},
	SendType = {
		type = "integer"
	},
	Sender = {
		type = "integer"
	},
	Title = {
		type = "integer"
	},
	InfoStart = {
		type = "integer"
	},
	Info = {
		type = "integer"
	},
	InfoEnd = {
		type = "integer"
	},
	Reward = {
		default = "[]",
		type = "array"
	}
}
local MailCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local Mail = {}

function Mail:GetAllSync()
	if MailCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("Mail", "select * from Mail")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, MailInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(MailCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	MailCtrl.hasCached = true
	Mail.GetAllSync = nil
	Mail.GetAllASync = nil
end

function Mail:GetAllASync()
	if MailCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("Mail", "select * from Mail", function()
		local rowsList = SqlLiteSupport.GetCacheData("Mail")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, MailInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(MailCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		MailCtrl.hasCached = true
		Mail.GetAllSync = nil
		Mail.GetAllASync = nil
	end)
end

setmetatable(Mail, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("Mail", SqlLiteTransfer.GenSql("Mail", MailCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, MailInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
Mail:GetAllSync()

return Mail
