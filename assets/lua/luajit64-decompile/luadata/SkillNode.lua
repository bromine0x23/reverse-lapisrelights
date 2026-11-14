-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/SkillNode.lua

local SkillNodeInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Info = {
		type = "integer"
	},
	Level = {
		type = "integer"
	},
	Favor = {
		type = "integer"
	},
	CostGem = {
		default = "[]",
		type = "array"
	},
	RewardType = {
		type = "integer"
	},
	UpgradeChance = {
		default = "[]",
		type = "array"
	},
	AttributeType = {
		type = "integer"
	},
	Attribute = {
		default = "[]",
		type = "array"
	},
	FightValue = {
		default = "[]",
		type = "array"
	},
	Item = {
		default = "[]",
		type = "array"
	},
	Avatar = {
		type = "integer"
	},
	RoleQuality = {
		type = "integer"
	},
	Skill = {
		type = "integer"
	}
}
local SkillNodeCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local SkillNode = {}

function SkillNode:GetAllSync()
	if SkillNodeCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("SkillNode", "select * from SkillNode")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, SkillNodeInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(SkillNodeCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	SkillNodeCtrl.hasCached = true
	SkillNode.GetAllSync = nil
	SkillNode.GetAllASync = nil
end

function SkillNode:GetAllASync()
	if SkillNodeCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("SkillNode", "select * from SkillNode", function()
		local rowsList = SqlLiteSupport.GetCacheData("SkillNode")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, SkillNodeInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(SkillNodeCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		SkillNodeCtrl.hasCached = true
		SkillNode.GetAllSync = nil
		SkillNode.GetAllASync = nil
	end)
end

setmetatable(SkillNode, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("SkillNode", SqlLiteTransfer.GenSql("SkillNode", SkillNodeCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, SkillNodeInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
SkillNode:GetAllSync()

return SkillNode
