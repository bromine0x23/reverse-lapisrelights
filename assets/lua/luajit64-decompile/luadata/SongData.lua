-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/SongData.lua

local SongDataInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	SongName = {
		type = "text"
	},
	Rank = {
		type = "integer"
	},
	Dance = {
		type = "text"
	},
	Camera = {
		type = "text"
	},
	Gesture = {
		type = "text"
	},
	SpotCount = {
		type = "integer"
	}
}
local SongDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local SongData = {}

function SongData:GetAllSync()
	if SongDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("SongData", "select * from SongData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, SongDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(SongDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	SongDataCtrl.hasCached = true
	SongData.GetAllSync = nil
	SongData.GetAllASync = nil
end

function SongData:GetAllASync()
	if SongDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("SongData", "select * from SongData", function()
		local rowsList = SqlLiteSupport.GetCacheData("SongData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, SongDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(SongDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		SongDataCtrl.hasCached = true
		SongData.GetAllSync = nil
		SongData.GetAllASync = nil
	end)
end

setmetatable(SongData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("SongData", SqlLiteTransfer.GenSql("SongData", SongDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, SongDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
SongData:GetAllSync()

return SongData
