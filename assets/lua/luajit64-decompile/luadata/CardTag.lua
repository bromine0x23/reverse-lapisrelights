-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/CardTag.lua

local CardTagInfo = {
	ID = {
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	Type = {
		type = "integer"
	}
}
local CardTagCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local CardTag = {}

function CardTag:GetAllSync()
	if CardTagCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("CardTag", "select * from CardTag")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, CardTagInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(CardTagCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	CardTagCtrl.hasCached = true
	CardTag.GetAllSync = nil
	CardTag.GetAllASync = nil
end

function CardTag:GetAllASync()
	if CardTagCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("CardTag", "select * from CardTag", function()
		local rowsList = SqlLiteSupport.GetCacheData("CardTag")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, CardTagInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(CardTagCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		CardTagCtrl.hasCached = true
		CardTag.GetAllSync = nil
		CardTag.GetAllASync = nil
	end)
end

setmetatable(CardTag, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("CardTag", SqlLiteTransfer.GenSql("CardTag", CardTagCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, CardTagInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
CardTag:GetAllSync()

return CardTag
