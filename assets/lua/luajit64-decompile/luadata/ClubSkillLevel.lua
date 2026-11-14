-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ClubSkillLevel.lua

local ClubSkillLevelInfo = {
	ID = {
		type = "integer"
	},
	SkillId = {
		type = "integer"
	},
	Level = {
		type = "integer"
	},
	LevelPoint = {
		type = "integer"
	},
	LevelPointAdd = {
		type = "integer"
	},
	UpClubCoin = {
		type = "integer"
	}
}
local ClubSkillLevelCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ClubSkillLevel = {}

function ClubSkillLevel:GetAllSync()
	if ClubSkillLevelCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ClubSkillLevel", "select * from ClubSkillLevel")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ClubSkillLevelInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ClubSkillLevelCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ClubSkillLevelCtrl.hasCached = true
	ClubSkillLevel.GetAllSync = nil
	ClubSkillLevel.GetAllASync = nil
end

function ClubSkillLevel:GetAllASync()
	if ClubSkillLevelCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ClubSkillLevel", "select * from ClubSkillLevel", function()
		local rowsList = SqlLiteSupport.GetCacheData("ClubSkillLevel")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ClubSkillLevelInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ClubSkillLevelCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ClubSkillLevelCtrl.hasCached = true
		ClubSkillLevel.GetAllSync = nil
		ClubSkillLevel.GetAllASync = nil
	end)
end

setmetatable(ClubSkillLevel, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ClubSkillLevel", SqlLiteTransfer.GenSql("ClubSkillLevel", ClubSkillLevelCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ClubSkillLevelInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ClubSkillLevel:GetAllSync()

return ClubSkillLevel
