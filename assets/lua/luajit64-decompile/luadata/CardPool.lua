-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/CardPool.lua

local CardPoolInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	TabOrder = {
		type = "integer"
	},
	PoolType = {
		type = "integer"
	},
	ResetType = {
		type = "integer"
	},
	ActiveID = {
		type = "integer"
	},
	ActiveType = {
		type = "integer"
	},
	StepUpOrder = {
		type = "integer"
	},
	StepUpTurn = {
		type = "integer"
	},
	BtnText = {
		default = "[]",
		type = "array"
	},
	BtnTip = {
		default = "[]",
		type = "array"
	},
	StepUpBoard = {
		default = "[]",
		type = "array"
	},
	TimeShow = {
		type = "integer"
	},
	CreateAccountPoolTime = {
		type = "integer"
	},
	OpenTime = {
		type = "text"
	},
	EndTime = {
		type = "text"
	},
	ShopOpenTime = {
		type = "text"
	},
	ShopEndTime = {
		type = "text"
	},
	ShopCloseTime = {
		type = "text"
	},
	ShopJump = {
		default = "[]",
		type = "array"
	},
	ScoreNum = {
		default = "[]",
		type = "array"
	},
	ScoreExpireReturn = {
		default = "[]",
		type = "array"
	},
	ShopId = {
		type = "integer"
	},
	ExtraReward = {
		type = "integer"
	},
	OneCost = {
		default = "[]",
		type = "array"
	},
	TenCost = {
		default = "[]",
		type = "array"
	},
	OneDiscount = {
		default = "[]",
		type = "array"
	},
	PriceOff = {
		default = "[]",
		type = "array"
	},
	BtnPic = {
		default = "[]",
		type = "array"
	},
	MonthCardKey = {
		default = "[]",
		type = "array"
	},
	DayMaxNum = {
		type = "integer"
	},
	DropGroupList = {
		default = "[]",
		type = "array"
	},
	UrRate = {
		type = "integer"
	},
	TenDrawLimitRank = {
		type = "text"
	},
	CardQualityLight = {
		type = "integer"
	},
	TenDrawLimitDrop = {
		default = "[]",
		type = "array"
	},
	TipIcon = {
		type = "text"
	},
	PoolInfo = {
		type = "integer"
	},
	PoolDesc = {
		type = "integer"
	},
	CardIconList = {
		default = "[]",
		type = "array"
	},
	SpineSetPos = {
		default = "[]",
		type = "array"
	},
	CardSitList = {
		default = "[]",
		type = "array"
	},
	InfoSetPos = {
		default = "[]",
		type = "array"
	},
	AnimationName = {
		type = "text"
	}
}
local CardPoolCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local CardPool = {}

function CardPool:GetAllSync()
	if CardPoolCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("CardPool", "select * from CardPool")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, CardPoolInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(CardPoolCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	CardPoolCtrl.hasCached = true
	CardPool.GetAllSync = nil
	CardPool.GetAllASync = nil
end

function CardPool:GetAllASync()
	if CardPoolCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("CardPool", "select * from CardPool", function()
		local rowsList = SqlLiteSupport.GetCacheData("CardPool")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, CardPoolInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(CardPoolCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		CardPoolCtrl.hasCached = true
		CardPool.GetAllSync = nil
		CardPool.GetAllASync = nil
	end)
end

setmetatable(CardPool, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("CardPool", SqlLiteTransfer.GenSql("CardPool", CardPoolCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, CardPoolInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
CardPool:GetAllSync()

return CardPool
