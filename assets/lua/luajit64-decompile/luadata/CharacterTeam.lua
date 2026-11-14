-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/CharacterTeam.lua

local CharacterTeamInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Version = {
		type = "integer"
	},
	TeamOrder = {
		type = "integer"
	},
	FetterVersion = {
		type = "integer"
	},
	StageVersion = {
		type = "integer"
	},
	ManualVersion = {
		type = "integer"
	},
	Description = {
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	BGIcon = {
		type = "text"
	},
	MemberList = {
		default = "[]",
		type = "array"
	},
	UnSkillCondition = {
		default = "[]",
		type = "array"
	},
	ActivatedRole = {
		default = "[]",
		type = "array"
	},
	Color = {
		type = "text"
	},
	SkillBgColor = {
		type = "text"
	},
	CharacterTColor = {
		type = "text"
	},
	CharacterBColor = {
		type = "text"
	},
	ManualIcon = {
		type = "text"
	},
	SkillList = {
		default = "[]",
		type = "array"
	},
	SkillCost1 = {
		default = "[]",
		type = "array"
	},
	SkillCost2 = {
		default = "[]",
		type = "array"
	},
	SkillCost3 = {
		default = "[]",
		type = "array"
	}
}
local CharacterTeamCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local CharacterTeam = {}

function CharacterTeam:GetAllSync()
	if CharacterTeamCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("CharacterTeam", "select * from CharacterTeam")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, CharacterTeamInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(CharacterTeamCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	CharacterTeamCtrl.hasCached = true
	CharacterTeam.GetAllSync = nil
	CharacterTeam.GetAllASync = nil
end

function CharacterTeam:GetAllASync()
	if CharacterTeamCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("CharacterTeam", "select * from CharacterTeam", function()
		local rowsList = SqlLiteSupport.GetCacheData("CharacterTeam")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, CharacterTeamInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(CharacterTeamCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		CharacterTeamCtrl.hasCached = true
		CharacterTeam.GetAllSync = nil
		CharacterTeam.GetAllASync = nil
	end)
end

setmetatable(CharacterTeam, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("CharacterTeam", SqlLiteTransfer.GenSql("CharacterTeam", CharacterTeamCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, CharacterTeamInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
CharacterTeam:GetAllSync()

return CharacterTeam
