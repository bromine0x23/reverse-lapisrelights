-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/ActiveManage.lua

local ActiveManageInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		default = "0",
		type = "integer"
	},
	Type = {
		default = "0",
		type = "integer"
	},
	Reset = {
		type = "integer"
	},
	UIType = {
		type = "integer"
	},
	PageOrder = {
		type = "integer"
	},
	Popup = {
		type = "integer"
	},
	PageSort = {
		type = "integer"
	},
	UITypeSort = {
		type = "integer"
	},
	OpenStage = {
		type = "integer"
	},
	Label = {
		type = "integer"
	},
	ActiveType = {
		default = "[]",
		type = "array"
	},
	BuffShowType = {
		type = "integer"
	},
	Description = {
		default = "0",
		type = "integer"
	},
	ActiveIcon = {
		type = "text"
	},
	StartTime = {
		type = "text"
	},
	EndTime = {
		type = "text"
	},
	ShowStartTime = {
		type = "text"
	},
	ShowEndTime = {
		type = "text"
	},
	BuffType = {
		default = "[]",
		type = "array"
	},
	BuffSkillID = {
		default = "[]",
		type = "array"
	},
	Params = {
		default = "[]",
		type = "array"
	},
	DailyTime = {
		default = "[]",
		type = "array"
	},
	TypeReward = {
		default = "[]",
		type = "array"
	},
	RuleWord = {
		type = "integer"
	},
	CharacterRole = {
		type = "integer"
	}
}
local ActiveManageCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local ActiveManage = {}

function ActiveManage:GetAllSync()
	if ActiveManageCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("ActiveManage", "select * from ActiveManage")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, ActiveManageInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(ActiveManageCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	ActiveManageCtrl.hasCached = true
	ActiveManage.GetAllSync = nil
	ActiveManage.GetAllASync = nil
end

function ActiveManage:GetAllASync()
	if ActiveManageCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("ActiveManage", "select * from ActiveManage", function()
		local rowsList = SqlLiteSupport.GetCacheData("ActiveManage")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, ActiveManageInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(ActiveManageCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		ActiveManageCtrl.hasCached = true
		ActiveManage.GetAllSync = nil
		ActiveManage.GetAllASync = nil
	end)
end

setmetatable(ActiveManage, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("ActiveManage", SqlLiteTransfer.GenSql("ActiveManage", ActiveManageCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, ActiveManageInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
ActiveManage:GetAllSync()

return ActiveManage
