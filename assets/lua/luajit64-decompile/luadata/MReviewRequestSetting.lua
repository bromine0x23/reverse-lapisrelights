-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/MReviewRequestSetting.lua

local MReviewRequestSettingInfo = {
	ID = {
		type = "integer"
	},
	review_type = {
		type = "text"
	},
	review_params = {
		type = "text"
	},
	review_time = {
		type = "integer"
	},
	open = {
		type = "text"
	}
}
local MReviewRequestSettingCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local MReviewRequestSetting = {}

function MReviewRequestSetting:GetAllSync()
	if MReviewRequestSettingCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("MReviewRequestSetting", "select * from MReviewRequestSetting")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, MReviewRequestSettingInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(MReviewRequestSettingCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	MReviewRequestSettingCtrl.hasCached = true
	MReviewRequestSetting.GetAllSync = nil
	MReviewRequestSetting.GetAllASync = nil
end

function MReviewRequestSetting:GetAllASync()
	if MReviewRequestSettingCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("MReviewRequestSetting", "select * from MReviewRequestSetting", function()
		local rowsList = SqlLiteSupport.GetCacheData("MReviewRequestSetting")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, MReviewRequestSettingInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(MReviewRequestSettingCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		MReviewRequestSettingCtrl.hasCached = true
		MReviewRequestSetting.GetAllSync = nil
		MReviewRequestSetting.GetAllASync = nil
	end)
end

setmetatable(MReviewRequestSetting, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("MReviewRequestSetting", SqlLiteTransfer.GenSql("MReviewRequestSetting", MReviewRequestSettingCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, MReviewRequestSettingInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
MReviewRequestSetting:GetAllSync()

return MReviewRequestSetting
