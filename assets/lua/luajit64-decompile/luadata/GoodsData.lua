-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/GoodsData.lua

local GoodsDataInfo = {
	ID = {
		type = "integer"
	},
	Type = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	SignBG = {
		type = "text"
	},
	SignName = {
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	PreGoodsID = {
		type = "integer"
	},
	PreGoodsCount = {
		type = "integer"
	},
	HideAfterOutStore = {
		type = "integer"
	},
	ShowRank = {
		type = "integer"
	},
	Info = {
		type = "integer"
	},
	InfoSpe = {
		type = "integer"
	},
	InfoShow = {
		type = "integer"
	},
	InfoSpeShow = {
		type = "integer"
	},
	InfoPay = {
		type = "integer"
	},
	StoreType = {
		type = "integer"
	},
	StoreNumber = {
		type = "integer"
	},
	GoodsItemList = {
		default = "[]",
		type = "array"
	},
	UnlockLevel = {
		type = "integer"
	},
	Discount = {
		type = "integer"
	},
	CostType = {
		type = "integer"
	},
	GoodsPrice = {
		default = "[]",
		type = "array"
	},
	CostValue = {
		default = "[]",
		type = "array"
	},
	GoodsBeginTime = {
		type = "text"
	},
	GoodsEndTime = {
		type = "text"
	},
	GoodsEffectiveTime = {
		type = "text"
	},
	ProductID = {
		type = "text"
	},
	ProductType = {
		type = "integer"
	},
	Diamond = {
		type = "integer"
	},
	MonthDayNum = {
		type = "integer"
	},
	RefreshAward = {
		default = "[]",
		type = "array"
	},
	RewardRefreshType = {
		type = "integer"
	},
	CombinationGoods = {
		default = "[]",
		type = "array"
	},
	FirstDiamondRatio = {
		type = "integer"
	},
	ExtraDiamond = {
		type = "integer"
	},
	FirstRatioStartTime = {
		type = "text"
	},
	FirstRatioEndTime = {
		type = "text"
	}
}
local GoodsDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local GoodsData = {}

function GoodsData:GetAllSync()
	if GoodsDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("GoodsData", "select * from GoodsData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, GoodsDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(GoodsDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	GoodsDataCtrl.hasCached = true
	GoodsData.GetAllSync = nil
	GoodsData.GetAllASync = nil
end

function GoodsData:GetAllASync()
	if GoodsDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("GoodsData", "select * from GoodsData", function()
		local rowsList = SqlLiteSupport.GetCacheData("GoodsData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, GoodsDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(GoodsDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		GoodsDataCtrl.hasCached = true
		GoodsData.GetAllSync = nil
		GoodsData.GetAllASync = nil
	end)
end

setmetatable(GoodsData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("GoodsData", SqlLiteTransfer.GenSql("GoodsData", GoodsDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, GoodsDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
GoodsData:GetAllSync()

return GoodsData
