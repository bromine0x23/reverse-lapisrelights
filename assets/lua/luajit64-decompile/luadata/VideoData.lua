-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/VideoData.lua

local VideoDataInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	ImagePath = {
		type = "text"
	},
	Path = {
		type = "text"
	},
	UnlockStageId = {
		type = "integer"
	},
	BundleName = {
		type = "text"
	},
	Award = {
		default = "[]",
		type = "array"
	}
}
local VideoDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local VideoData = {}

function VideoData:GetAllSync()
	if VideoDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("VideoData", "select * from VideoData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, VideoDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(VideoDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	VideoDataCtrl.hasCached = true
	VideoData.GetAllSync = nil
	VideoData.GetAllASync = nil
end

function VideoData:GetAllASync()
	if VideoDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("VideoData", "select * from VideoData", function()
		local rowsList = SqlLiteSupport.GetCacheData("VideoData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, VideoDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(VideoDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		VideoDataCtrl.hasCached = true
		VideoData.GetAllSync = nil
		VideoData.GetAllASync = nil
	end)
end

setmetatable(VideoData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("VideoData", SqlLiteTransfer.GenSql("VideoData", VideoDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, VideoDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
VideoData:GetAllSync()

return VideoData
