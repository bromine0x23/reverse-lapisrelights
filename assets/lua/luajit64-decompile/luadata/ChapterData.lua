-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ChapterData.lua

local ChapterDataInfo = {
	ID = {
		type = "integer"
	},
	Type = {
		type = "integer"
	},
	Role = {
		type = "integer"
	},
	Team = {
		type = "integer"
	},
	Card = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Title = {
		type = "integer"
	},
	ProperCard = {
		default = "[]",
		type = "array"
	},
	TitleNumber = {
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	BackIcon = {
		type = "text"
	},
	NameIcon = {
		type = "text"
	},
	BackSpine = {
		type = "text"
	},
	Animation = {
		type = "text"
	},
	InitStage = {
		default = "[]",
		type = "array"
	},
	InitFinishStage = {
		default = "[]",
		type = "array"
	},
	StageID = {
		default = "[]",
		type = "array"
	},
	GoldStar = {
		type = "integer"
	},
	GoldAwardList = {
		default = "[]",
		type = "array"
	},
	SilverStar = {
		type = "integer"
	},
	SilverAwardList = {
		default = "[]",
		type = "array"
	},
	CopperStar = {
		type = "integer"
	},
	CopperAwardList = {
		default = "[]",
		type = "array"
	},
	GVGPhaseReward = {
		default = "[]",
		type = "array"
	},
	BossLiveBGMBank = {
		type = "text"
	},
	BossLiveBGMEvent = {
		type = "text"
	},
	AutoUnlock = {
		type = "integer"
	},
	ChapterShowIcon = {
		default = "[]",
		type = "array"
	}
}
local ChapterDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ChapterData = {}

function ChapterData:GetAllSync()
	if ChapterDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ChapterData", "select * from ChapterData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ChapterDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ChapterDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ChapterDataCtrl.hasCached = true
	ChapterData.GetAllSync = nil
	ChapterData.GetAllASync = nil
end

function ChapterData:GetAllASync()
	if ChapterDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ChapterData", "select * from ChapterData", function()
		local rowsList = SqlLiteSupport.GetCacheData("ChapterData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ChapterDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ChapterDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ChapterDataCtrl.hasCached = true
		ChapterData.GetAllSync = nil
		ChapterData.GetAllASync = nil
	end)
end

setmetatable(ChapterData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ChapterData", SqlLiteTransfer.GenSql("ChapterData", ChapterDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ChapterDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ChapterData:GetAllSync()

return ChapterData
