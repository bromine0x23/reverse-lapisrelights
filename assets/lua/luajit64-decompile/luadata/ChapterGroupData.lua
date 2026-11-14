-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ChapterGroupData.lua

local ChapterGroupDataInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	Chapter = {
		default = "[]",
		type = "array"
	},
	Position = {
		default = "[]",
		type = "array"
	},
	MainDrop = {
		default = "[]",
		type = "array"
	},
	Type = {
		type = "integer"
	}
}
local ChapterGroupDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ChapterGroupData = {}

function ChapterGroupData:GetAllSync()
	if ChapterGroupDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ChapterGroupData", "select * from ChapterGroupData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ChapterGroupDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ChapterGroupDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ChapterGroupDataCtrl.hasCached = true
	ChapterGroupData.GetAllSync = nil
	ChapterGroupData.GetAllASync = nil
end

function ChapterGroupData:GetAllASync()
	if ChapterGroupDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ChapterGroupData", "select * from ChapterGroupData", function()
		local rowsList = SqlLiteSupport.GetCacheData("ChapterGroupData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ChapterGroupDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ChapterGroupDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ChapterGroupDataCtrl.hasCached = true
		ChapterGroupData.GetAllSync = nil
		ChapterGroupData.GetAllASync = nil
	end)
end

setmetatable(ChapterGroupData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ChapterGroupData", SqlLiteTransfer.GenSql("ChapterGroupData", ChapterGroupDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ChapterGroupDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ChapterGroupData:GetAllSync()

return ChapterGroupData
