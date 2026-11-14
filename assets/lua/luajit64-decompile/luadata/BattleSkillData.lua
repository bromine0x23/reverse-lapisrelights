-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/BattleSkillData.lua

local BattleSkillDataInfo = {
	ID = {
		type = "integer"
	},
	AllSkillID = {
		type = "integer"
	},
	DescIconIdx = {
		default = "0",
		type = "integer"
	},
	IsRange = {
		default = "0",
		type = "integer"
	},
	SkillShowOff = {
		default = "0",
		type = "integer"
	},
	AffectType = {
		default = "None",
		type = "text"
	},
	IconPath = {
		type = "text"
	},
	Cost = {
		default = "0",
		type = "integer"
	},
	TimeLineID = {
		type = "integer"
	},
	TimeLine_BOSS_Cam = {
		type = "integer"
	},
	TimeLine_S = {
		default = "-1",
		type = "float"
	},
	SoundEvent = {
		type = "text"
	},
	SkillLips = {
		type = "text"
	},
	SoundDelay = {
		default = "0",
		type = "float"
	},
	AnimState = {
		type = "text"
	},
	CastTime = {
		default = "[]",
		type = "array"
	},
	CastFxs = {
		default = "[]",
		type = "array"
	},
	CampFxs = {
		default = "[]",
		type = "array"
	},
	CampFxTimes = {
		default = "[]",
		type = "array"
	},
	CampFxIdx = {
		default = "[]",
		type = "array"
	},
	CameraFxs = {
		default = "[]",
		type = "array"
	},
	CameraFxTimes = {
		default = "[]",
		type = "array"
	},
	Back_f = {
		default = "0",
		type = "float"
	},
	TotalTime = {
		default = "-1",
		type = "float"
	},
	IsStackPower = {
		default = "0",
		type = "integer"
	},
	Power = {
		default = "[]",
		type = "array"
	},
	LockTarget = {
		default = "None",
		type = "text"
	},
	ActionKey = {
		default = "[]",
		type = "array"
	},
	Custom = {
		default = "[]",
		type = "array"
	}
}
local BattleSkillDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local BattleSkillData = {}

function BattleSkillData:GetAllSync()
	if BattleSkillDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("BattleSkillData", "select * from BattleSkillData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, BattleSkillDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(BattleSkillDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	BattleSkillDataCtrl.hasCached = true
	BattleSkillData.GetAllSync = nil
	BattleSkillData.GetAllASync = nil
end

function BattleSkillData:GetAllASync()
	if BattleSkillDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("BattleSkillData", "select * from BattleSkillData", function()
		local rowsList = SqlLiteSupport.GetCacheData("BattleSkillData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, BattleSkillDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(BattleSkillDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		BattleSkillDataCtrl.hasCached = true
		BattleSkillData.GetAllSync = nil
		BattleSkillData.GetAllASync = nil
	end)
end

setmetatable(BattleSkillData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("BattleSkillData", SqlLiteTransfer.GenSql("BattleSkillData", BattleSkillDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, BattleSkillDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
BattleSkillData:GetAllSync()

return BattleSkillData
