-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/SongSubtitleData.lua

local SongSubtitleDataInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Team = {
		type = "integer"
	},
	Subtitle = {
		default = "[]",
		type = "array"
	},
	Length = {
		type = "integer"
	},
	VoiceEvent = {
		type = "text"
	},
	Bank = {
		type = "text"
	},
	DiscPath = {
		type = "text"
	},
	ImagePath = {
		type = "text"
	},
	UnlockStageId = {
		type = "integer"
	},
	Award = {
		default = "[]",
		type = "array"
	}
}
local SongSubtitleDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local SongSubtitleData = {}

function SongSubtitleData:GetAllSync()
	if SongSubtitleDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("SongSubtitleData", "select * from SongSubtitleData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, SongSubtitleDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(SongSubtitleDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	SongSubtitleDataCtrl.hasCached = true
	SongSubtitleData.GetAllSync = nil
	SongSubtitleData.GetAllASync = nil
end

function SongSubtitleData:GetAllASync()
	if SongSubtitleDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("SongSubtitleData", "select * from SongSubtitleData", function()
		local rowsList = SqlLiteSupport.GetCacheData("SongSubtitleData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, SongSubtitleDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(SongSubtitleDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		SongSubtitleDataCtrl.hasCached = true
		SongSubtitleData.GetAllSync = nil
		SongSubtitleData.GetAllASync = nil
	end)
end

setmetatable(SongSubtitleData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("SongSubtitleData", SqlLiteTransfer.GenSql("SongSubtitleData", SongSubtitleDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, SongSubtitleDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
SongSubtitleData:GetAllSync()

return SongSubtitleData
