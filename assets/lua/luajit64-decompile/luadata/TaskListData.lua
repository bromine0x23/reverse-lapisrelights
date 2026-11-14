-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/luaData/TaskListData.lua

local TaskListDataInfo = {
	ID = {
		type = "integer"
	},
	Name = {
		type = "integer"
	},
	Info = {
		type = "integer"
	},
	Type = {
		type = "integer"
	},
	Requirement = {
		default = "[]",
		type = "array"
	},
	TipsType = {
		type = "integer"
	},
	LastTime = {
		type = "integer"
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
	List = {
		default = "[]",
		type = "array"
	},
	ListWeight = {
		default = "[]",
		type = "array"
	},
	RecommendTask = {
		default = "[]",
		type = "array"
	},
	TaskSection = {
		default = "[]",
		type = "array"
	},
	SectionOpenNeed = {
		default = "[]",
		type = "array"
	},
	SectionlName = {
		default = "[]",
		type = "array"
	},
	ScoreSection = {
		default = "[]",
		type = "array"
	},
	ScoreSectionReward = {
		default = "[]",
		type = "array"
	},
	PayScoreSectionReward = {
		default = "[]",
		type = "array"
	},
	ActivePayId = {
		type = "integer"
	}
}
local TaskListDataCtrl = {
	keyWord = "ID",
	keyWordNum = 1,
	hasCached = false
}
local TaskListData = {}

function TaskListData:GetAllSync()
	if TaskListDataCtrl.hasCached then
		return
	end

	local rowsList = SqlLiteSupport.ExecuteQuery("TaskListData", "select * from TaskListData")

	rowsList:ForEach(function(v)
		local jsonTb = SqlLiteTransfer.TransferFromJson(v, TaskListDataInfo)
		local keyWord = SqlLiteTransfer.GetKeyWord(TaskListDataCtrl, jsonTb)

		self[keyWord] = jsonTb
	end)

	TaskListDataCtrl.hasCached = true
	TaskListData.GetAllSync = nil
	TaskListData.GetAllASync = nil
end

function TaskListData:GetAllASync()
	if TaskListDataCtrl.hasCached then
		return
	end

	SqlLiteSupport.LazyCacheData("TaskListData", "select * from TaskListData", function()
		local rowsList = SqlLiteSupport.GetCacheData("TaskListData")

		rowsList:ForEach(function(v)
			local jsonTb = SqlLiteTransfer.TransferFromJson(v, TaskListDataInfo)
			local keyWord = SqlLiteTransfer.GetKeyWord(TaskListDataCtrl, jsonTb)

			self[keyWord] = jsonTb
		end)

		TaskListDataCtrl.hasCached = true
		TaskListData.GetAllSync = nil
		TaskListData.GetAllASync = nil
	end)
end

setmetatable(TaskListData, {
	__index = function(tb, key)
		if not key or key == "" or key == 0 then
			return nil
		end

		if key == "GetAllASync" or key == "GetAllSync" then
			return function()
				print(key .. " could be called only once")
			end
		end

		local dicRow = SqlLiteSupport.ExecuteQueryOne("TaskListData", SqlLiteTransfer.GenSql("TaskListData", TaskListDataCtrl, key))

		if dicRow then
			local jsonTb = SqlLiteTransfer.TransferFromJson(dicRow, TaskListDataInfo)

			tb[key] = jsonTb

			return jsonTb
		else
			return nil
		end
	end
})
TaskListData:GetAllSync()

return TaskListData
