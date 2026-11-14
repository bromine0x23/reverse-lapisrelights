-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/FromWhere.lua

local FromWhereInfo = {
	ID = {
		type = "integer"
	},
	Function = {
		type = "integer"
	}
}
local FromWhereCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local FromWhere = {}

function FromWhere:GetAllSync()
	if FromWhereCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("FromWhere", "select * from FromWhere")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, FromWhereInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(FromWhereCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	FromWhereCtrl.hasCached = true
	FromWhere.GetAllSync = nil
	FromWhere.GetAllASync = nil
end

function FromWhere:GetAllASync()
	if FromWhereCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("FromWhere", "select * from FromWhere", function()
		local rowsList = SqlLiteSupport.GetCacheData("FromWhere")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, FromWhereInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(FromWhereCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		FromWhereCtrl.hasCached = true
		FromWhere.GetAllSync = nil
		FromWhere.GetAllASync = nil
	end)
end

setmetatable(FromWhere, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("FromWhere", SqlLiteTransfer.GenSql("FromWhere", FromWhereCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, FromWhereInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
FromWhere:GetAllSync()

return FromWhere
