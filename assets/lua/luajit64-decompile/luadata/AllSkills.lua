-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/AllSkills.lua

local AllSkillsInfo = {
	ID = {
		type = "integer"
	},
	Type = {
		type = "integer"
	},
	BattleSkillID = {
		default = "[]",
		type = "array"
	},
	BattleSkillType = {
		type = "integer"
	},
	PassiveType = {
		default = "0",
		type = "integer"
	},
	UpConsumeType = {
		type = "integer"
	},
	Icon = {
		type = "text"
	},
	Name = {
		default = "0",
		type = "integer"
	},
	Description = {
		default = "[]",
		type = "array"
	},
	Argus = {
		default = "[]",
		type = "array"
	},
	Argus1 = {
		default = "[]",
		type = "array"
	},
	Argus2 = {
		default = "[]",
		type = "array"
	},
	Argus3 = {
		default = "[]",
		type = "array"
	},
	HighestLevel = {
		default = "1",
		type = "integer"
	},
	SkillStageBonus = {
		default = "[]",
		type = "array"
	},
	ExpAdd = {
		default = "[]",
		type = "array"
	},
	CostAdd = {
		default = "[]",
		type = "array"
	},
	ItemExtraGroup = {
		default = "[]",
		type = "array"
	},
	ItemTypeExtraGroup = {
		default = "[]",
		type = "array"
	}
}
local AllSkillsCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local AllSkills = {}

function AllSkills:GetAllSync()
	if AllSkillsCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("AllSkills", "select * from AllSkills")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, AllSkillsInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(AllSkillsCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	AllSkillsCtrl.hasCached = true
	AllSkills.GetAllSync = nil
	AllSkills.GetAllASync = nil
end

function AllSkills:GetAllASync()
	if AllSkillsCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("AllSkills", "select * from AllSkills", function()
		local rowsList = SqlLiteSupport.GetCacheData("AllSkills")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, AllSkillsInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(AllSkillsCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		AllSkillsCtrl.hasCached = true
		AllSkills.GetAllSync = nil
		AllSkills.GetAllASync = nil
	end)
end

setmetatable(AllSkills, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("AllSkills", SqlLiteTransfer.GenSql("AllSkills", AllSkillsCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, AllSkillsInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
AllSkills:GetAllSync()

return AllSkills
