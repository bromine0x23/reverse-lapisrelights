-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/SkillTree.lua

local SkillTreeInfo = {
	ID = {
		type = "integer"
	},
	CharacterID = {
		type = "integer"
	},
	Job = {
		type = "text"
	},
	Trunk = {
		default = "[]",
		type = "array"
	},
	Branch1 = {
		default = "[]",
		type = "array"
	},
	ParentID1 = {
		type = "integer"
	},
	Direction1 = {
		type = "text"
	},
	Branch2 = {
		default = "[]",
		type = "array"
	},
	ParentID2 = {
		type = "integer"
	},
	Direction2 = {
		type = "text"
	},
	Branch3 = {
		default = "[]",
		type = "array"
	},
	ParentID3 = {
		type = "integer"
	},
	Direction3 = {
		type = "text"
	},
	Branch4 = {
		default = "[]",
		type = "array"
	},
	ParentID4 = {
		type = "integer"
	},
	Direction4 = {
		type = "text"
	},
	Branch5 = {
		default = "[]",
		type = "array"
	},
	ParentID5 = {
		type = "integer"
	},
	Direction5 = {
		type = "text"
	},
	Branch6 = {
		default = "[]",
		type = "array"
	},
	ParentID6 = {
		type = "integer"
	},
	Direction6 = {
		type = "text"
	}
}
local SkillTreeCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local SkillTree = {}

function SkillTree:GetAllSync()
	if SkillTreeCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("SkillTree", "select * from SkillTree")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, SkillTreeInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(SkillTreeCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	SkillTreeCtrl.hasCached = true
	SkillTree.GetAllSync = nil
	SkillTree.GetAllASync = nil
end

function SkillTree:GetAllASync()
	if SkillTreeCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("SkillTree", "select * from SkillTree", function()
		local rowsList = SqlLiteSupport.GetCacheData("SkillTree")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, SkillTreeInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(SkillTreeCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		SkillTreeCtrl.hasCached = true
		SkillTree.GetAllSync = nil
		SkillTree.GetAllASync = nil
	end)
end

setmetatable(SkillTree, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("SkillTree", SqlLiteTransfer.GenSql("SkillTree", SkillTreeCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, SkillTreeInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
SkillTree:GetAllSync()

return SkillTree
