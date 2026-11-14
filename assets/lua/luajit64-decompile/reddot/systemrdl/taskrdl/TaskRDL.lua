-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/TaskRDL/TaskRDL.lua

local TaskListData = require("luaData/TaskListData")

TaskRDL = {}

local RD_Task_List_Type = {
	main = 1,
	samllClass = 10,
	union = 6,
	bossRaid = 9,
	battlePass = 8,
	daily = 2,
	limitTime = 4,
	achievement = 7,
	urCardPool = 13,
	timespace = 15,
	cosume = 14,
	weekly = 3
}
local Source_Type = {
	Score = 2,
	Task = 1
}
local RD_Task_Branch_Path = {
	LimitTime = "TaskLimitTime/%d/%d",
	Cosume = "Task/Cosume",
	SmallClass_Score = "Operation/SmallClass/%d",
	BossRaid = "Chapter/BossRaid/Task",
	Jigsaw = "Operation/Jigsaw/Task",
	BattlePass = "Operation/BattlePass/Task",
	Timespace = "Kc/Timespace",
	URCardPool = "Operation/URCardPool",
	Achieve = "Task/Achieve",
	BattlePass_Score = "Operation/BattlePass/Score/Commn/%d",
	Weekly_Score = "Task/Weekly/%d",
	Main = "Task/Main",
	Daily_Score = "Task/Daily/%d",
	Daily = "Task/Daily",
	SmallClass = "Operation/SmallClass/Task",
	Weekly = "Task/Weekly"
}

function GetTaskBranchPath(_type, _idx, _extra)
	if _type == RD_Task_List_Type.main then
		return RD_Task_Branch_Path.Main
	elseif _type == RD_Task_List_Type.daily then
		return RD_Task_Branch_Path.Daily
	elseif _type == RD_Task_List_Type.weekly then
		return RD_Task_Branch_Path.Weekly
	elseif _type == RD_Task_List_Type.limitTime then
		return string.format(RD_Task_Branch_Path.LimitTime, _idx or 1, _extra or 1)
	elseif _type == RD_Task_List_Type.union then
		return RD_Task_Branch_Path.Union
	elseif _type == RD_Task_List_Type.achievement then
		return RD_Task_Branch_Path.Achieve
	elseif _type == RD_Task_List_Type.battlePass then
		return RD_Task_Branch_Path.BattlePass
	elseif _type == RD_Task_List_Type.bossRaid then
		return RD_Task_Branch_Path.BossRaid
	elseif _type == RD_Task_List_Type.samllClass then
		return RD_Task_Branch_Path.SmallClass
	elseif _type == RD_Task_List_Type.urCardPool then
		return RD_Task_Branch_Path.URCardPool
	elseif _type == RD_Task_List_Type.cosume then
		return RD_Task_Branch_Path.Cosume
	elseif _type == RD_Task_List_Type.timespace then
		return RD_Task_Branch_Path.Timespace
	end

	return ""
end

function GetTaskScoreBranchPath(_type, _idx)
	if _type == RD_Task_List_Type.daily then
		return string.format(RD_Task_Branch_Path.Daily_Score, _idx)
	elseif _type == RD_Task_List_Type.weekly then
		return string.format(RD_Task_Branch_Path.Weekly_Score, _idx)
	elseif _type == RD_Task_List_Type.union then
		return string.format(RD_Task_Branch_Path.Union_Score, _idx)
	elseif _type == RD_Task_List_Type.battlePass then
		return string.format(RD_Task_Branch_Path.BattlePass_Score, _idx)
	elseif _type == RD_Task_List_Type.samllClass then
		return string.format(RD_Task_Branch_Path.SmallClass_Score, _idx)
	end

	return ""
end

local CAN_RECEIVE_TASK = {}
local CAN_RECEIVE_SCORE = {}

local function GetTaskListDataByTaskId(taskId)
	for _, v in pairs(TaskListData) do
		if table.contains(v.List, taskId) then
			return v
		end
	end

	return nil
end

local function GetBelong(taskId)
	local taskListData = GetTaskListDataByTaskId(taskId)

	if taskListData then
		for k, v in pairs(taskListData.TaskSection) do
			if table.contains(v, taskId) then
				return taskListData.ID, k
			end
		end
	end

	return nil, nil
end

local function IsUnLockSingleList(taskListData, index)
	local function funcTaskNum()
		if index == 1 then
			return true
		end

		local listCon = taskListData.SectionOpenNeed
		local count = 0
		local listTagTask = taskListData.TaskSection
		local listSingle = {}

		if listTagTask and #listTagTask >= index - 1 then
			listSingle = listTagTask[index - 1]
		end

		for i = 1, #listSingle do
			local info = TaskManager:Get(listSingle[i])

			if info:IsGetAward() then
				count = count + 1
			end
		end

		if count >= listCon[index] then
			return true
		end

		return false
	end

	local function funcTime()
		if index == 1 then
			return true
		end

		local infoActive
		local list = OperationActiveMgr:GetLimitActivityList()

		for _, v in ipairs(list) do
			if v.data.DailyTime[1][1] == taskListData.ID then
				infoActive = v

				break
			end
		end

		if infoActive ~= nil then
			local openTime = GetTimeTampByString(infoActive.data.ShowStartTime) + (taskListData.SectionOpenNeed[index] - 1) * 86400
			local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

			if openTime <= curServerTime then
				return true
			else
				return false
			end
		end

		return false
	end

	if taskListData.ID == 6 then
		return funcTaskNum()
	elseif taskListData.TipsType == 0 then
		return funcTaskNum()
	elseif taskListData.TipsType == 2 then
		return funcTime()
	end

	return false
end

local function CommFunc(_type, _idx, fun, sourceType)
	local formatPath

	if sourceType == Source_Type.Task then
		formatPath = GetTaskBranchPath(_type, _idx)
	else
		formatPath = GetTaskScoreBranchPath(_type, _idx)
	end

	if not string.isNullOrEmpty(formatPath) then
		fun(formatPath)
	end

	OperationRDL.RunBattlePass()
end

function TaskRDL.Reset()
	CAN_RECEIVE_TASK = {}

	for k, v in pairs(CAN_RECEIVE_SCORE) do
		if k ~= RD_Task_List_Type.union then
			for _, idx in ipairs(v) do
				CommFunc(k, idx, function(path)
					RedDotSystemMgr.SetNodeValueByFormatPath(path, 0)
				end, Source_Type.Score)
			end
		end
	end

	CAN_RECEIVE_SCORE = {}
end

function TaskRDL.Init()
	TaskRDL.Reset()

	for _, task in TaskManager.dict:Enumerator() do
		local _type = TaskManager:GetTaskListType(task.id)

		if _type ~= nil then
			CAN_RECEIVE_TASK[_type] = CAN_RECEIVE_TASK[_type] or {}

			if task:IsBeing() and (task:GetTaskType() == eTaskType.Cosume or task:IsComplete()) and not task:IsGetAward() then
				if _type == RD_Task_List_Type.limitTime then
					local taskListId, _idx = GetBelong(task.id)

					if _idx ~= nil then
						CAN_RECEIVE_TASK[_type][taskListId] = CAN_RECEIVE_TASK[_type][taskListId] or {}
						CAN_RECEIVE_TASK[_type][taskListId][_idx] = CAN_RECEIVE_TASK[_type][taskListId][_idx] or {}

						table.insert(CAN_RECEIVE_TASK[_type][taskListId][_idx], task.id)
					end
				else
					table.insert(CAN_RECEIVE_TASK[_type], task.id)
				end
			end
		end
	end

	for id, v in pairs(TaskManager.listTaskLineScore) do
		local data = TaskListData[id]

		if data then
			CAN_RECEIVE_SCORE[data.Type] = CAN_RECEIVE_SCORE[data.Type] or {}

			for i, j in ipairs(data.ScoreSection) do
				if not table.contains(v.rewardRecords, i - 1) and v.score >= j[2] and table.existElement(data.ScoreSectionReward[i]) then
					table.insert(CAN_RECEIVE_SCORE[data.Type], i)
				end
			end
		end
	end

	OperationRDL.RunJigsaw()
	OperationRDL.RunGrowthFund()
	OperationRDL.RunSmallClass()
	UnionRDL.TaskRDL.Init(CAN_RECEIVE_TASK[RD_Task_List_Type.union], CAN_RECEIVE_SCORE[RD_Task_List_Type.union])
	TaskRDL.InitRD()
	OperationRDL.RunBattlePass()
end

function TaskRDL.InitRD()
	for k, v in pairs(CAN_RECEIVE_TASK) do
		if k == RD_Task_List_Type.limitTime then
			for i, j in pairs(v) do
				for x, y in pairs(j) do
					local path = GetTaskBranchPath(k, i, x)

					RedDotSystemMgr.SetNodeValueByFormatPath(path, #y)

					local isUnlock = IsUnLockSingleList(TaskListData[i], x)

					RedDotSystemMgr.SetNodeLockState(path, not isUnlock)
				end
			end
		elseif k == RD_Task_List_Type.union then
			-- block empty
		else
			CommFunc(k, nil, function(path)
				RedDotSystemMgr.SetNodeValueByFormatPath(path, #v)
			end, Source_Type.Task)
		end
	end

	for k, v in pairs(CAN_RECEIVE_SCORE) do
		if k == RD_Task_List_Type.union then
			-- block empty
		else
			for _, idx in ipairs(v) do
				CommFunc(k, idx, function(path)
					RedDotSystemMgr.SetNodeValueByFormatPath(path, 1)
				end, Source_Type.Score)
			end
		end
	end
end

local function ChangeCommFunc(ids, func)
	ids = ids or {}

	local temp = {}

	for _, id in pairs(ids) do
		local _type = TaskManager:GetTaskListType(id)

		if _type ~= nil then
			CAN_RECEIVE_TASK[_type] = CAN_RECEIVE_TASK[_type] or {}

			if _type == RD_Task_List_Type.limitTime then
				local taskListId, _idx = GetBelong(id)

				if _idx ~= nil then
					CAN_RECEIVE_TASK[_type][taskListId] = CAN_RECEIVE_TASK[_type][taskListId] or {}
					CAN_RECEIVE_TASK[_type][taskListId][_idx] = CAN_RECEIVE_TASK[_type][taskListId][_idx] or {}
					temp[_type] = temp[_type] or {}
					temp[_type][taskListId] = temp[_type][taskListId] or {}
					temp[_type][taskListId][_idx] = (temp[_type][taskListId][_idx] or 0) + func(CAN_RECEIVE_TASK[_type][taskListId][_idx], id)
				end
			elseif _type == RD_Task_List_Type.union then
				UnionRDL.TaskRDL.DealTask(id, func(CAN_RECEIVE_TASK[_type], id))
			else
				temp[_type] = (temp[_type] or 0) + func(CAN_RECEIVE_TASK[_type], id)
			end
		end
	end

	for k, v in pairs(temp) do
		if k == RD_Task_List_Type.limitTime then
			for i, j in pairs(v) do
				for x, y in pairs(j) do
					local path = GetTaskBranchPath(k, i, x)

					RedDotSystemMgr.ChangeNodeValueByFormatPath(path, y)

					if y > 0 then
						if x > 1 then
							local isUnlock = IsUnLockSingleList(TaskListData[i], x)

							RedDotSystemMgr.SetNodeLockState(path, not isUnlock)
						end
					elseif x < #TaskListData[i].TaskSection then
						local isUnlock = IsUnLockSingleList(TaskListData[i], x + 1)

						RedDotSystemMgr.SetNodeLockState(GetTaskBranchPath(k, i, x + 1), not isUnlock)
					end
				end
			end
		elseif k == RD_Task_List_Type.union then
			-- block empty
		else
			CommFunc(k, nil, function(path)
				RedDotSystemMgr.ChangeNodeValueByFormatPath(path, v)
			end, Source_Type.Task)
		end
	end

	OperationRDL.RunBattlePass()
end

function TaskRDL.RemoveReceivedTask(taskIds)
	taskIds = taskIds or {}

	ChangeCommFunc(taskIds, function(tab, id)
		if table.contains(tab, id) then
			table.removeByValue(tab, id)

			return -1
		end

		return 0
	end)
end

function TaskRDL.AddCanReceiveTask(pbTasks)
	local taskIds = {}

	for _, pbTask in ipairs(pbTasks) do
		local task = TaskManager:Get(pbTask.id)

		if task and task:IsBeing() and (task:GetTaskType() == eTaskType.Cosume or task:IsComplete()) and not task:IsGetAward() then
			table.insert(taskIds, task.id)
		end
	end

	ChangeCommFunc(taskIds, function(tab, id)
		if not table.contains(tab, id) then
			table.insert(tab, id)

			return 1
		end

		return 0
	end)
	OperationRDL.RunJigsaw()
	OperationRDL.RunBattlePass()
end

function TaskRDL.RemoveReceivedTaskScore(id, _idx)
	local data = TaskManager.listTaskLineScore[id].data

	CAN_RECEIVE_SCORE[data.Type] = CAN_RECEIVE_SCORE[data.Type] or {}

	if _idx == 0 then
		if data.Type == RD_Task_List_Type.union then
			UnionRDL.TaskRDL.SubScore()
		else
			for _, idx in pairs(CAN_RECEIVE_SCORE[data.Type]) do
				CommFunc(data.Type, idx, function(path)
					RedDotSystemMgr.SetNodeValueByFormatPath(path, 0)
				end, Source_Type.Score)
			end
		end

		CAN_RECEIVE_SCORE[data.Type] = {}
	elseif table.contains(CAN_RECEIVE_SCORE[data.Type], _idx) then
		table.removeByValue(CAN_RECEIVE_SCORE[data.Type], _idx)

		if data.Type == RD_Task_List_Type.union then
			UnionRDL.TaskRDL.SubScore(_idx)
		else
			CommFunc(data.Type, _idx, function(path)
				RedDotSystemMgr.SetNodeValueByFormatPath(path, 0)
			end, Source_Type.Score)
		end
	end
end

function TaskRDL.AddCanReceiveTaskScore(id, _idx)
	local data = TaskManager.listTaskLineScore[id].data

	CAN_RECEIVE_SCORE[data.Type] = CAN_RECEIVE_SCORE[data.Type] or {}

	if not table.contains(CAN_RECEIVE_SCORE[data.Type], _idx) then
		table.insert(CAN_RECEIVE_SCORE[data.Type], _idx)

		if data.Type == RD_Task_List_Type.union then
			UnionRDL.TaskRDL.AddScore(_idx)
		else
			CommFunc(data.Type, _idx, function(path)
				RedDotSystemMgr.SetNodeValueByFormatPath(path, 1)
			end, Source_Type.Score)
		end
	end
end

function TaskRDL.DealTaskScore(pbScores)
	for _, pbScore in ipairs(pbScores) do
		local data = TaskManager.listTaskLineScore[pbScore.taskListId].data

		CAN_RECEIVE_SCORE[data.Type] = CAN_RECEIVE_SCORE[data.Type] or {}

		for _, v in ipairs(pbScore.rewardRecords) do
			TaskRDL.RemoveReceivedTaskScore(pbScore.taskListId, v + 1)
		end

		for k, v in ipairs(data.ScoreSection) do
			if not table.contains(pbScore.rewardRecords, k - 1) and pbScore.score >= v[2] and table.existElement(data.ScoreSectionReward[k]) then
				TaskRDL.AddCanReceiveTaskScore(pbScore.taskListId, k)
			end
		end

		if data.Type == RD_Task_List_Type.battlePass then
			OperationRDL.RunBattlePass()
		end
	end
end

return TaskRDL
