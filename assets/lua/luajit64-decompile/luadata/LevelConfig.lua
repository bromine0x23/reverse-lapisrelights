-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/LevelConfig.lua

local LevelConfigInfo = {
	ID = {
		type = "integer"
	},
	PlayerExperience = {
		type = "integer"
	},
	PlayerExperienceAdd = {
		type = "integer"
	},
	PlayerLevelAward = {
		default = "[]",
		type = "array"
	},
	RoleCardExperience = {
		type = "integer"
	},
	RoleCardExperienceAdd = {
		type = "integer"
	},
	PlayerStamina = {
		type = "integer"
	},
	MaxStamina = {
		type = "integer"
	},
	TeamPosition = {
		default = "[]",
		type = "array"
	},
	EventLevelReward = {
		default = "[]",
		type = "array"
	},
	VipExperience = {
		type = "integer"
	},
	VipLevelReward = {
		default = "[]",
		type = "array"
	},
	StarSoul = {
		type = "integer"
	},
	StarSoulAdd = {
		type = "integer"
	},
	MaxMP = {
		type = "integer"
	},
	MaxCost = {
		type = "integer"
	},
	NextUp = {
		default = "[]",
		type = "array"
	}
}
local LevelConfigCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local LevelConfig = {}

function LevelConfig:GetAllSync()
	if LevelConfigCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("LevelConfig", "select * from LevelConfig")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, LevelConfigInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(LevelConfigCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	LevelConfigCtrl.hasCached = true
	LevelConfig.GetAllSync = nil
	LevelConfig.GetAllASync = nil
end

function LevelConfig:GetAllASync()
	if LevelConfigCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("LevelConfig", "select * from LevelConfig", function()
		local rowsList = SqlLiteSupport.GetCacheData("LevelConfig")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, LevelConfigInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(LevelConfigCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		LevelConfigCtrl.hasCached = true
		LevelConfig.GetAllSync = nil
		LevelConfig.GetAllASync = nil
	end)
end

setmetatable(LevelConfig, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("LevelConfig", SqlLiteTransfer.GenSql("LevelConfig", LevelConfigCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, LevelConfigInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
LevelConfig:GetAllSync()

return LevelConfig
