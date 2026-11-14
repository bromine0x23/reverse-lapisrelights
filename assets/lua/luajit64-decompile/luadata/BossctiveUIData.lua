-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/BossctiveUIData.lua

local BossctiveUIDataInfo = {
	ID = {
		type = "integer"
	},
	BgImage = {
		type = "text"
	},
	TitalImage = {
		type = "text"
	},
	TitalPos = {
		default = "[]",
		type = "array"
	},
	SignName = {
		type = "text"
	},
	NamePos = {
		default = "[]",
		type = "array"
	},
	TimePos = {
		default = "[]",
		type = "array"
	},
	SubTitalImage = {
		type = "text"
	},
	SubTitalDesc = {
		type = "integer"
	},
	SubTitalDescPos = {
		default = "[]",
		type = "array"
	},
	SubTitalDescLength = {
		default = "[]",
		type = "array"
	},
	BattleTipDesc = {
		type = "integer"
	},
	BattleColor = {
		type = "text"
	},
	BattleImage = {
		type = "text"
	},
	BossImage = {
		type = "text"
	},
	BossLineImage = {
		type = "text"
	},
	ShopImage = {
		type = "text"
	},
	StoryImage = {
		type = "text"
	},
	StageTital = {
		type = "text"
	},
	StageTitalPos = {
		default = "[]",
		type = "array"
	},
	HighPrizePos = {
		default = "[]",
		type = "array"
	},
	StageSubTitalImage = {
		type = "text"
	},
	StageSubTitalDesc = {
		type = "integer"
	},
	StageSubTitalDescPos = {
		default = "[]",
		type = "array"
	},
	StageSubTitalDescLength = {
		default = "[]",
		type = "array"
	},
	StoryTital = {
		type = "text"
	},
	StoryTitalPos = {
		default = "[]",
		type = "array"
	},
	StorySignPos = {
		default = "[]",
		type = "array"
	},
	StorySubTitalImage = {
		type = "text"
	},
	StorySubTitalDesc = {
		type = "integer"
	},
	StorySubTitalDescPos = {
		default = "[]",
		type = "array"
	},
	StorySubTitalDescLength = {
		default = "[]",
		type = "array"
	},
	SpinePath = {
		default = "[]",
		type = "array"
	},
	SpinePos = {
		default = "[]",
		type = "array"
	},
	SpineRoa = {
		default = "[]",
		type = "array"
	},
	SpineScale = {
		default = "[]",
		type = "array"
	},
	BossUnlockColor = {
		default = "[]",
		type = "array"
	}
}
local BossctiveUIDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local BossctiveUIData = {}

function BossctiveUIData:GetAllSync()
	if BossctiveUIDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("BossctiveUIData", "select * from BossctiveUIData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, BossctiveUIDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(BossctiveUIDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	BossctiveUIDataCtrl.hasCached = true
	BossctiveUIData.GetAllSync = nil
	BossctiveUIData.GetAllASync = nil
end

function BossctiveUIData:GetAllASync()
	if BossctiveUIDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("BossctiveUIData", "select * from BossctiveUIData", function()
		local rowsList = SqlLiteSupport.GetCacheData("BossctiveUIData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, BossctiveUIDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(BossctiveUIDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		BossctiveUIDataCtrl.hasCached = true
		BossctiveUIData.GetAllSync = nil
		BossctiveUIData.GetAllASync = nil
	end)
end

setmetatable(BossctiveUIData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("BossctiveUIData", SqlLiteTransfer.GenSql("BossctiveUIData", BossctiveUIDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, BossctiveUIDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
BossctiveUIData:GetAllSync()

return BossctiveUIData
