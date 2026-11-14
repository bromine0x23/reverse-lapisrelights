-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ActiveData.lua

local ActiveDataInfo = {
	ID = {
		type = "integer"
	},
	Type = {
		default = "0",
		type = "integer"
	},
	ActiveGroup = {
		default = "0",
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Label = {
		type = "integer"
	},
	LimitItems = {
		default = "[]",
		type = "array"
	},
	StartTime = {
		type = "text"
	},
	EndTime = {
		type = "text"
	},
	CloseTime = {
		type = "text"
	},
	TypeValue = {
		default = "[]",
		type = "array"
	},
	DailyTime = {
		default = "[]",
		type = "array"
	},
	ArgJson = {
		default = "[]",
		type = "array"
	},
	DailyRewardRate = {
		default = "[]",
		type = "array"
	},
	RechargeList = {
		default = "[]",
		type = "array"
	},
	RewardList = {
		default = "[]",
		type = "array"
	},
	MainRewardShow = {
		default = "[]",
		type = "array"
	},
	RuleWord = {
		type = "integer"
	},
	ShopId = {
		default = "0",
		type = "integer"
	}
}
local ActiveDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ActiveData = {}

function ActiveData:GetAllSync()
	if ActiveDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ActiveData", "select * from ActiveData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ActiveDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ActiveDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ActiveDataCtrl.hasCached = true
	ActiveData.GetAllSync = nil
	ActiveData.GetAllASync = nil
end

function ActiveData:GetAllASync()
	if ActiveDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ActiveData", "select * from ActiveData", function()
		local rowsList = SqlLiteSupport.GetCacheData("ActiveData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ActiveDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ActiveDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ActiveDataCtrl.hasCached = true
		ActiveData.GetAllSync = nil
		ActiveData.GetAllASync = nil
	end)
end

setmetatable(ActiveData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ActiveData", SqlLiteTransfer.GenSql("ActiveData", ActiveDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ActiveDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ActiveData:GetAllSync()

return ActiveData
