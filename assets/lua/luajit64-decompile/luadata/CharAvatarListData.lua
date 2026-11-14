-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/CharAvatarListData.lua

local CharAvatarListDataInfo = {
	ID = {
		type = "integer"
	},
	Avatar = {
		default = "[]",
		type = "array"
	}
}
local CharAvatarListDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local CharAvatarListData = {}

function CharAvatarListData:GetAllSync()
	if CharAvatarListDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("CharAvatarListData", "select * from CharAvatarListData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, CharAvatarListDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(CharAvatarListDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	CharAvatarListDataCtrl.hasCached = true
	CharAvatarListData.GetAllSync = nil
	CharAvatarListData.GetAllASync = nil
end

function CharAvatarListData:GetAllASync()
	if CharAvatarListDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("CharAvatarListData", "select * from CharAvatarListData", function()
		local rowsList = SqlLiteSupport.GetCacheData("CharAvatarListData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, CharAvatarListDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(CharAvatarListDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		CharAvatarListDataCtrl.hasCached = true
		CharAvatarListData.GetAllSync = nil
		CharAvatarListData.GetAllASync = nil
	end)
end

setmetatable(CharAvatarListData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("CharAvatarListData", SqlLiteTransfer.GenSql("CharAvatarListData", CharAvatarListDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, CharAvatarListDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
CharAvatarListData:GetAllSync()

return CharAvatarListData
