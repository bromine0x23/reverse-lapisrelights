-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/TimelineData.lua

local TimelineDataInfo = {
	ID = {
		type = "integer"
	},
	Path = {
		type = "text"
	},
	PlayablePath = {
		type = "text"
	},
	IsLive = {
		type = "integer"
	},
	DisableSkip = {
		default = "0",
		type = "integer"
	},
	DisableTimeScale = {
		default = "1",
		type = "integer"
	},
	DanceNum = {
		default = "[]",
		type = "array"
	},
	SoundEvent = {
		type = "text"
	},
	SoundBank = {
		type = "text"
	}
}
local TimelineDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local TimelineData = {}

function TimelineData:GetAllSync()
	if TimelineDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("TimelineData", "select * from TimelineData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, TimelineDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(TimelineDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	TimelineDataCtrl.hasCached = true
	TimelineData.GetAllSync = nil
	TimelineData.GetAllASync = nil
end

function TimelineData:GetAllASync()
	if TimelineDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("TimelineData", "select * from TimelineData", function()
		local rowsList = SqlLiteSupport.GetCacheData("TimelineData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, TimelineDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(TimelineDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		TimelineDataCtrl.hasCached = true
		TimelineData.GetAllSync = nil
		TimelineData.GetAllASync = nil
	end)
end

setmetatable(TimelineData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("TimelineData", SqlLiteTransfer.GenSql("TimelineData", TimelineDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, TimelineDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
TimelineData:GetAllSync()

return TimelineData
