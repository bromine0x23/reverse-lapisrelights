-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/TeamFetterCost.lua

local TeamFetterCostInfo = {
	ID = {
		type = "integer"
	},
	SkillID = {
		type = "integer"
	},
	Level = {
		type = "integer"
	},
	Cost = {
		default = "[]",
		type = "array"
	}
}
local TeamFetterCostCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local TeamFetterCost = {}

function TeamFetterCost:GetAllSync()
	if TeamFetterCostCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("TeamFetterCost", "select * from TeamFetterCost")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, TeamFetterCostInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(TeamFetterCostCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	TeamFetterCostCtrl.hasCached = true
	TeamFetterCost.GetAllSync = nil
	TeamFetterCost.GetAllASync = nil
end

function TeamFetterCost:GetAllASync()
	if TeamFetterCostCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("TeamFetterCost", "select * from TeamFetterCost", function()
		local rowsList = SqlLiteSupport.GetCacheData("TeamFetterCost")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, TeamFetterCostInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(TeamFetterCostCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		TeamFetterCostCtrl.hasCached = true
		TeamFetterCost.GetAllSync = nil
		TeamFetterCost.GetAllASync = nil
	end)
end

setmetatable(TeamFetterCost, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("TeamFetterCost", SqlLiteTransfer.GenSql("TeamFetterCost", TeamFetterCostCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, TeamFetterCostInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
TeamFetterCost:GetAllSync()

return TeamFetterCost
