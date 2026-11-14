-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ActiveCondition.lua

local ActiveConditionInfo = {
	ID = {
		type = "integer"
	},
	Type = {
		type = "integer"
	},
	CycleType = {
		type = "integer"
	},
	Condition = {
		default = "[]",
		type = "array"
	},
	Period = {
		type = "integer"
	},
	Times = {
		type = "integer"
	},
	GoodsID = {
		type = "integer"
	}
}
local ActiveConditionCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ActiveCondition = {}

function ActiveCondition:GetAllSync()
	if ActiveConditionCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ActiveCondition", "select * from ActiveCondition")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ActiveConditionInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ActiveConditionCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ActiveConditionCtrl.hasCached = true
	ActiveCondition.GetAllSync = nil
	ActiveCondition.GetAllASync = nil
end

function ActiveCondition:GetAllASync()
	if ActiveConditionCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ActiveCondition", "select * from ActiveCondition", function()
		local rowsList = SqlLiteSupport.GetCacheData("ActiveCondition")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ActiveConditionInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ActiveConditionCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ActiveConditionCtrl.hasCached = true
		ActiveCondition.GetAllSync = nil
		ActiveCondition.GetAllASync = nil
	end)
end

setmetatable(ActiveCondition, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ActiveCondition", SqlLiteTransfer.GenSql("ActiveCondition", ActiveConditionCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ActiveConditionInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ActiveCondition:GetAllSync()

return ActiveCondition
