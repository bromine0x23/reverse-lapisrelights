-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/AvatarAsset.lua

local AvatarAssetInfo = {
	ID = {
		type = "integer"
	},
	AvatarID = {
		type = "integer"
	},
	AvatarPath = {
		default = "[]",
		type = "array"
	}
}
local AvatarAssetCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local AvatarAsset = {}

function AvatarAsset:GetAllSync()
	if AvatarAssetCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("AvatarAsset", "select * from AvatarAsset")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, AvatarAssetInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(AvatarAssetCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	AvatarAssetCtrl.hasCached = true
	AvatarAsset.GetAllSync = nil
	AvatarAsset.GetAllASync = nil
end

function AvatarAsset:GetAllASync()
	if AvatarAssetCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("AvatarAsset", "select * from AvatarAsset", function()
		local rowsList = SqlLiteSupport.GetCacheData("AvatarAsset")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, AvatarAssetInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(AvatarAssetCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		AvatarAssetCtrl.hasCached = true
		AvatarAsset.GetAllSync = nil
		AvatarAsset.GetAllASync = nil
	end)
end

setmetatable(AvatarAsset, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("AvatarAsset", SqlLiteTransfer.GenSql("AvatarAsset", AvatarAssetCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, AvatarAssetInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
AvatarAsset:GetAllSync()

return AvatarAsset
