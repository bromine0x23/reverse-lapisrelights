-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/TaskData.lua

local TaskDataInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Info = {
		type = "integer"
	},
	Title = {
		type = "integer"
	},
	TitleIcon = {
		type = "text"
	},
	Type = {
		type = "text"
	},
	ArgInt = {
		type = "integer"
	},
	ArgJson = {
		default = "[]",
		type = "array"
	},
	Reward = {
		default = "[]",
		type = "array"
	},
	ExtraReward = {
		default = "[]",
		type = "array"
	},
	Mail = {
		type = "integer"
	},
	ClubSelfPoint = {
		type = "integer"
	},
	ClubPoint = {
		type = "integer"
	},
	ScorePoint = {
		type = "integer"
	},
	DropGroup = {
		type = "integer"
	},
	TaskTips = {
		default = "[]",
		type = "array"
	},
	FromWhere = {
		default = "[]",
		type = "array"
	}
}
local TaskDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local TaskData = {}

function TaskData:GetAllSync()
	if TaskDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("TaskData", "select * from TaskData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, TaskDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(TaskDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	TaskDataCtrl.hasCached = true
	TaskData.GetAllSync = nil
	TaskData.GetAllASync = nil
end

function TaskData:GetAllASync()
	if TaskDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("TaskData", "select * from TaskData", function()
		local rowsList = SqlLiteSupport.GetCacheData("TaskData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, TaskDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(TaskDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		TaskDataCtrl.hasCached = true
		TaskData.GetAllSync = nil
		TaskData.GetAllASync = nil
	end)
end

setmetatable(TaskData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("TaskData", SqlLiteTransfer.GenSql("TaskData", TaskDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, TaskDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
TaskData:GetAllSync()

return TaskData
