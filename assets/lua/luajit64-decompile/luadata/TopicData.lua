-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/TopicData.lua

local TopicDataInfo = {
	ID = {
		type = "integer"
	},
	RoleId = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Path = {
		type = "text"
	},
	LanguragePath = {
		type = "text"
	},
	Award = {
		default = "[]",
		type = "array"
	},
	StageID = {
		default = "0",
		type = "integer"
	},
	FavorUnlockLevel = {
		type = "integer"
	}
}
local TopicDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local TopicData = {}

function TopicData:GetAllSync()
	if TopicDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("TopicData", "select * from TopicData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, TopicDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(TopicDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	TopicDataCtrl.hasCached = true
	TopicData.GetAllSync = nil
	TopicData.GetAllASync = nil
end

function TopicData:GetAllASync()
	if TopicDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("TopicData", "select * from TopicData", function()
		local rowsList = SqlLiteSupport.GetCacheData("TopicData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, TopicDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(TopicDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		TopicDataCtrl.hasCached = true
		TopicData.GetAllSync = nil
		TopicData.GetAllASync = nil
	end)
end

setmetatable(TopicData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("TopicData", SqlLiteTransfer.GenSql("TopicData", TopicDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, TopicDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
TopicData:GetAllSync()

return TopicData
