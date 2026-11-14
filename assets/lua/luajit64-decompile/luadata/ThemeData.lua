-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ThemeData.lua

local ThemeDataInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Info = {
		type = "integer"
	},
	Minutes = {
		default = "[]",
		type = "array"
	},
	BaseReward = {
		default = "[]",
		type = "array"
	},
	SetPos = {
		default = "[]",
		type = "array"
	},
	SeatCount = {
		type = "integer"
	},
	UnlockLevel = {
		type = "integer"
	},
	UnlockStage = {
		type = "integer"
	},
	Cost = {
		default = "[]",
		type = "array"
	},
	Scene = {
		type = "integer"
	},
	BGM = {
		type = "text"
	},
	Icon = {
		type = "text"
	}
}
local ThemeDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ThemeData = {}

function ThemeData:GetAllSync()
	if ThemeDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ThemeData", "select * from ThemeData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ThemeDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ThemeDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ThemeDataCtrl.hasCached = true
	ThemeData.GetAllSync = nil
	ThemeData.GetAllASync = nil
end

function ThemeData:GetAllASync()
	if ThemeDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ThemeData", "select * from ThemeData", function()
		local rowsList = SqlLiteSupport.GetCacheData("ThemeData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ThemeDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ThemeDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ThemeDataCtrl.hasCached = true
		ThemeData.GetAllSync = nil
		ThemeData.GetAllASync = nil
	end)
end

setmetatable(ThemeData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ThemeData", SqlLiteTransfer.GenSql("ThemeData", ThemeDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ThemeDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ThemeData:GetAllSync()

return ThemeData
