-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ClubMirror.lua

local ClubMirrorInfo = {
	ID = {
		type = "integer"
	},
	Type = {
		type = "integer"
	},
	BossLevel = {
		type = "integer"
	},
	BossStage = {
		default = "0",
		type = "integer"
	},
	Name = {
		default = "[]",
		type = "array"
	},
	Desc = {
		type = "integer"
	},
	RoundEvent = {
		default = "[]",
		type = "array"
	},
	Icon = {
		type = "text"
	},
	Round = {
		type = "integer"
	},
	BattleRound = {
		type = "integer"
	},
	LevelLimit = {
		type = "integer"
	},
	FinishPoint = {
		type = "integer"
	},
	Award = {
		default = "[]",
		type = "array"
	},
	ContributionOfBattle = {
		default = "0",
		type = "integer"
	},
	ContributionOfKill = {
		default = "0",
		type = "integer"
	},
	Difficulty = {
		type = "integer"
	}
}
local ClubMirrorCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ClubMirror = {}

function ClubMirror:GetAllSync()
	if ClubMirrorCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ClubMirror", "select * from ClubMirror")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ClubMirrorInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ClubMirrorCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ClubMirrorCtrl.hasCached = true
	ClubMirror.GetAllSync = nil
	ClubMirror.GetAllASync = nil
end

function ClubMirror:GetAllASync()
	if ClubMirrorCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ClubMirror", "select * from ClubMirror", function()
		local rowsList = SqlLiteSupport.GetCacheData("ClubMirror")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ClubMirrorInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ClubMirrorCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ClubMirrorCtrl.hasCached = true
		ClubMirror.GetAllSync = nil
		ClubMirror.GetAllASync = nil
	end)
end

setmetatable(ClubMirror, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ClubMirror", SqlLiteTransfer.GenSql("ClubMirror", ClubMirrorCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ClubMirrorInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ClubMirror:GetAllSync()

return ClubMirror
