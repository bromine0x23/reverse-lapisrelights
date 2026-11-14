-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/CallTopicAward.lua

local CallTopicAwardInfo = {
	ID = {
		type = "integer"
	},
	StageID = {
		type = "integer"
	},
	GroupId = {
		type = "text"
	},
	AwardId = {
		default = "[]",
		type = "array"
	}
}
local CallTopicAwardCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local CallTopicAward = {}

function CallTopicAward:GetAllSync()
	if CallTopicAwardCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("CallTopicAward", "select * from CallTopicAward")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, CallTopicAwardInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(CallTopicAwardCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	CallTopicAwardCtrl.hasCached = true
	CallTopicAward.GetAllSync = nil
	CallTopicAward.GetAllASync = nil
end

function CallTopicAward:GetAllASync()
	if CallTopicAwardCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("CallTopicAward", "select * from CallTopicAward", function()
		local rowsList = SqlLiteSupport.GetCacheData("CallTopicAward")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, CallTopicAwardInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(CallTopicAwardCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		CallTopicAwardCtrl.hasCached = true
		CallTopicAward.GetAllSync = nil
		CallTopicAward.GetAllASync = nil
	end)
end

setmetatable(CallTopicAward, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("CallTopicAward", SqlLiteTransfer.GenSql("CallTopicAward", CallTopicAwardCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, CallTopicAwardInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
CallTopicAward:GetAllSync()

return CallTopicAward
