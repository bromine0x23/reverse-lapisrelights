-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/PVPAchievement.lua

local PVPAchievementInfo = {
	ID = {
		type = "integer"
	},
	RankingFrom = {
		type = "integer"
	},
	RankingTo = {
		type = "integer"
	},
	Number = {
		type = "integer"
	},
	Award = {
		default = "[]",
		type = "array"
	}
}
local PVPAchievementCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local PVPAchievement = {}

function PVPAchievement:GetAllSync()
	if PVPAchievementCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("PVPAchievement", "select * from PVPAchievement")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, PVPAchievementInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(PVPAchievementCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	PVPAchievementCtrl.hasCached = true
	PVPAchievement.GetAllSync = nil
	PVPAchievement.GetAllASync = nil
end

function PVPAchievement:GetAllASync()
	if PVPAchievementCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("PVPAchievement", "select * from PVPAchievement", function()
		local rowsList = SqlLiteSupport.GetCacheData("PVPAchievement")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, PVPAchievementInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(PVPAchievementCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		PVPAchievementCtrl.hasCached = true
		PVPAchievement.GetAllSync = nil
		PVPAchievement.GetAllASync = nil
	end)
end

setmetatable(PVPAchievement, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("PVPAchievement", SqlLiteTransfer.GenSql("PVPAchievement", PVPAchievementCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, PVPAchievementInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
PVPAchievement:GetAllSync()

return PVPAchievement
