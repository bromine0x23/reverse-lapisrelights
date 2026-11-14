-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/SceneData.lua

local SceneDataInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Info = {
		type = "text"
	},
	Title = {
		type = "text"
	},
	Resource = {
		type = "text"
	},
	SweepPic = {
		type = "text"
	},
	Picture = {
		type = "text"
	},
	Bank = {
		type = "text"
	},
	BGM = {
		type = "text"
	},
	P1 = {
		default = "[]",
		type = "array"
	},
	P2 = {
		default = "[]",
		type = "array"
	},
	P3 = {
		default = "[]",
		type = "array"
	},
	P4 = {
		default = "[]",
		type = "array"
	},
	P5 = {
		default = "[]",
		type = "array"
	},
	BattleUIicon = {
		type = "text"
	},
	BattleSceneicon = {
		type = "text"
	}
}
local SceneDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local SceneData = {}

function SceneData:GetAllSync()
	if SceneDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("SceneData", "select * from SceneData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, SceneDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(SceneDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	SceneDataCtrl.hasCached = true
	SceneData.GetAllSync = nil
	SceneData.GetAllASync = nil
end

function SceneData:GetAllASync()
	if SceneDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("SceneData", "select * from SceneData", function()
		local rowsList = SqlLiteSupport.GetCacheData("SceneData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, SceneDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(SceneDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		SceneDataCtrl.hasCached = true
		SceneData.GetAllSync = nil
		SceneData.GetAllASync = nil
	end)
end

setmetatable(SceneData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("SceneData", SqlLiteTransfer.GenSql("SceneData", SceneDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, SceneDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
SceneData:GetAllSync()

return SceneData
