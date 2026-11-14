-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/StoryAward.lua

local StoryAwardInfo = {
	ID = {
		type = "integer"
	},
	AwardList = {
		default = "[]",
		type = "array"
	},
	Chapter = {
		type = "integer"
	},
	Rank = {
		type = "integer"
	},
	Comment = {
		type = "text"
	}
}
local StoryAwardCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local StoryAward = {}

function StoryAward:GetAllSync()
	if StoryAwardCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("StoryAward", "select * from StoryAward")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, StoryAwardInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(StoryAwardCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	StoryAwardCtrl.hasCached = true
	StoryAward.GetAllSync = nil
	StoryAward.GetAllASync = nil
end

function StoryAward:GetAllASync()
	if StoryAwardCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("StoryAward", "select * from StoryAward", function()
		local rowsList = SqlLiteSupport.GetCacheData("StoryAward")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, StoryAwardInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(StoryAwardCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		StoryAwardCtrl.hasCached = true
		StoryAward.GetAllSync = nil
		StoryAward.GetAllASync = nil
	end)
end

setmetatable(StoryAward, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("StoryAward", SqlLiteTransfer.GenSql("StoryAward", StoryAwardCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, StoryAwardInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
StoryAward:GetAllSync()

return StoryAward
