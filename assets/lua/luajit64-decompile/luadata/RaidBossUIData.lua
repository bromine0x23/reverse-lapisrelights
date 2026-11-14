-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/RaidBossUIData.lua

local RaidBossUIDataInfo = {
	ID = {
		type = "integer"
	},
	BGImage = {
		type = "text"
	},
	TitalImage = {
		type = "text"
	},
	TitalPos = {
		default = "[]",
		type = "array"
	},
	SubTitalImage = {
		type = "text"
	},
	SubTitalPos = {
		default = "[]",
		type = "array"
	},
	SubTitalTextPos = {
		default = "[]",
		type = "array"
	},
	SubTitalDescLength = {
		default = "[]",
		type = "array"
	},
	SubTitalDesc = {
		type = "integer"
	},
	AwardItem = {
		type = "text"
	},
	AwardItemPos = {
		default = "[]",
		type = "array"
	},
	AwardItemScale = {
		default = "0",
		type = "float"
	},
	TimeColor = {
		default = "[]",
		type = "array"
	},
	Desc1 = {
		default = "[]",
		type = "array"
	},
	Desc2 = {
		default = "[]",
		type = "array"
	},
	ShopBgImage = {
		type = "text"
	},
	ShopTitalImage = {
		type = "text"
	},
	ShopTimePos = {
		default = "[]",
		type = "array"
	},
	ShopTitalPos = {
		default = "[]",
		type = "array"
	},
	ShopSubTitalImage = {
		type = "text"
	},
	ShopSubTitalDesc = {
		type = "integer"
	},
	ShopSubTitalDescPos = {
		default = "[]",
		type = "array"
	},
	ShopSubTitalDescLength = {
		default = "[]",
		type = "array"
	},
	ShopSpinePath = {
		default = "[]",
		type = "array"
	},
	ShopSpinePos = {
		default = "[]",
		type = "array"
	},
	ShopSpineRoa = {
		default = "[]",
		type = "array"
	},
	ShopSpineScale = {
		default = "[]",
		type = "array"
	}
}
local RaidBossUIDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local RaidBossUIData = {}

function RaidBossUIData:GetAllSync()
	if RaidBossUIDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("RaidBossUIData", "select * from RaidBossUIData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, RaidBossUIDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(RaidBossUIDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	RaidBossUIDataCtrl.hasCached = true
	RaidBossUIData.GetAllSync = nil
	RaidBossUIData.GetAllASync = nil
end

function RaidBossUIData:GetAllASync()
	if RaidBossUIDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("RaidBossUIData", "select * from RaidBossUIData", function()
		local rowsList = SqlLiteSupport.GetCacheData("RaidBossUIData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, RaidBossUIDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(RaidBossUIDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		RaidBossUIDataCtrl.hasCached = true
		RaidBossUIData.GetAllSync = nil
		RaidBossUIData.GetAllASync = nil
	end)
end

setmetatable(RaidBossUIData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("RaidBossUIData", SqlLiteTransfer.GenSql("RaidBossUIData", RaidBossUIDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, RaidBossUIDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
RaidBossUIData:GetAllSync()

return RaidBossUIData
