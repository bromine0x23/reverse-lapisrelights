-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ActiveBanner.lua

local ActiveBannerInfo = {
	ID = {
		type = "integer"
	},
	Type = {
		type = "integer"
	},
	NewBieType = {
		type = "integer"
	},
	BannerIcon = {
		type = "text"
	},
	RelevanceActive = {
		default = "[]",
		type = "array"
	},
	FromWhere = {
		default = "[]",
		type = "array"
	}
}
local ActiveBannerCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ActiveBanner = {}

function ActiveBanner:GetAllSync()
	if ActiveBannerCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ActiveBanner", "select * from ActiveBanner")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ActiveBannerInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ActiveBannerCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ActiveBannerCtrl.hasCached = true
	ActiveBanner.GetAllSync = nil
	ActiveBanner.GetAllASync = nil
end

function ActiveBanner:GetAllASync()
	if ActiveBannerCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ActiveBanner", "select * from ActiveBanner", function()
		local rowsList = SqlLiteSupport.GetCacheData("ActiveBanner")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ActiveBannerInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ActiveBannerCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ActiveBannerCtrl.hasCached = true
		ActiveBanner.GetAllSync = nil
		ActiveBanner.GetAllASync = nil
	end)
end

setmetatable(ActiveBanner, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ActiveBanner", SqlLiteTransfer.GenSql("ActiveBanner", ActiveBannerCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ActiveBannerInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ActiveBanner:GetAllSync()

return ActiveBanner
