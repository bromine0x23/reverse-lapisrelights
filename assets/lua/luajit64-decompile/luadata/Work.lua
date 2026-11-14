-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/Work.lua

local WorkInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Info = {
		type = "integer"
	},
	Type = {
		type = "integer"
	},
	GroupType = {
		type = "integer"
	},
	Quality = {
		type = "integer"
	},
	GroupLimit = {
		default = "[]",
		type = "array"
	},
	GroupLimit2 = {
		default = "[]",
		type = "array"
	},
	JobLimit = {
		default = "[]",
		type = "array"
	},
	RoleLimit = {
		default = "[]",
		type = "array"
	},
	CardLevelLimit = {
		default = "[]",
		type = "array"
	},
	CardStarLimit = {
		default = "[]",
		type = "array"
	},
	CardRankLimit = {
		default = "[]",
		type = "array"
	},
	DoubleRewordCost = {
		default = "[]",
		type = "array"
	},
	PlayerNumber = {
		type = "integer"
	},
	RoleAdd = {
		type = "integer"
	},
	WorkTime = {
		type = "integer"
	},
	BaseReward = {
		type = "integer"
	},
	SuccessReward = {
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	NPC = {
		type = "text"
	},
	BaseRate = {
		type = "integer"
	},
	FinishWhere = {
		default = "[]",
		type = "array"
	},
	BGIcon = {
		type = "text"
	}
}
local WorkCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local Work = {}

function Work:GetAllSync()
	if WorkCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("Work", "select * from Work")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, WorkInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(WorkCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	WorkCtrl.hasCached = true
	Work.GetAllSync = nil
	Work.GetAllASync = nil
end

function Work:GetAllASync()
	if WorkCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("Work", "select * from Work", function()
		local rowsList = SqlLiteSupport.GetCacheData("Work")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, WorkInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(WorkCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		WorkCtrl.hasCached = true
		Work.GetAllSync = nil
		Work.GetAllASync = nil
	end)
end

setmetatable(Work, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("Work", SqlLiteTransfer.GenSql("Work", WorkCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, WorkInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
Work:GetAllSync()

return Work
