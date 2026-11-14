-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ResourceBanner.lua

local ResourceBannerInfo = {
	ID = {
		type = "integer"
	},
	Banner = {
		default = "[]",
		type = "array"
	},
	FromWhere = {
		default = "[]",
		type = "array"
	}
}
local ResourceBannerCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ResourceBanner = {}

function ResourceBanner:GetAllSync()
	if ResourceBannerCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ResourceBanner", "select * from ResourceBanner")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ResourceBannerInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ResourceBannerCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ResourceBannerCtrl.hasCached = true
	ResourceBanner.GetAllSync = nil
	ResourceBanner.GetAllASync = nil
end

function ResourceBanner:GetAllASync()
	if ResourceBannerCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ResourceBanner", "select * from ResourceBanner", function()
		local rowsList = SqlLiteSupport.GetCacheData("ResourceBanner")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ResourceBannerInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ResourceBannerCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ResourceBannerCtrl.hasCached = true
		ResourceBanner.GetAllSync = nil
		ResourceBanner.GetAllASync = nil
	end)
end

setmetatable(ResourceBanner, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ResourceBanner", SqlLiteTransfer.GenSql("ResourceBanner", ResourceBannerCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ResourceBannerInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ResourceBanner:GetAllSync()

return ResourceBanner
