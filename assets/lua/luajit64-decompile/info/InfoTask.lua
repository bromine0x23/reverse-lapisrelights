-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoTask.lua

local TaskData = require("luaData/TaskData")
local TaskListData = require("luaData/TaskListData")

InfoTask = class("InfoTask", InfoBase)
eTaskListType = {
	main = 1,
	samllClass = 10,
	union = 6,
	bossRaid = 9,
	battlePass = 8,
	daily = 2,
	limitTime = 4,
	achievement = 7,
	timespace = 15,
	cosume = 14,
	weekly = 3
}
eTaskSystemType = {
	weekly = 3,
	daily = 2,
	achievement = 4,
	main = 1
}
eTaskType = {
	Flower = 12,
	BuyAvatar = 3,
	UseItemExp = 11,
	Cosume = 22,
	FavorLevel = 2,
	TouchHead = 21,
	StagePass = 1,
	SendGift = 10,
	PlayerLevel = 4
}

function GetTaskType(str)
	if str == "StagePass" then
		return eTaskType.StagePass
	elseif str == "FavorLevel" then
		return eTaskType.FavorLevel
	elseif str == "BuyAvatar" then
		return eTaskType.BuyAvatar
	elseif str == "PlayerLevel" then
		return eTaskType.PlayerLevel
	elseif str == "SendGift" then
		return eTaskType.SendGift
	elseif str == "UseItemExp" then
		return eTaskType.UseItemExp
	elseif str == "Flower" then
		return eTaskType.Flower
	elseif str == "TouchHead" then
		return eTaskType.TouchHead
	elseif str == "KCTimingSpecificItemCostNum" then
		return eTaskType.Cosume
	end

	return 0
end

local function GetRefreshType(_type)
	if _type == eTaskListType.daily then
		return eRefreshType.Daily, eRefreshType.Daily
	elseif _type == eTaskListType.weekly then
		return eRefreshType.Weekly, eRefreshType.Weekly
	elseif _type == eTaskListType.union then
		return eRefreshType.Daily, eRefreshType.Weekly
	elseif _type == eTaskListType.samllClass then
		return eRefreshType.Daily, eRefreshType.Daily
	end

	return 0, 0
end

local eTaskStatusType = {
	default = 0,
	being = 1,
	complete = 2
}

function InfoTask:ctor(id)
	self.data = TaskData[id]
	self.pb = {}
	self.pb.id = id
	self.pb.status = eTaskStatusType.default
	self.pb.num = 0
end

function InfoTask:SetData(pbTask)
	self.pb = pbTask
end

function InfoTask:IsComplete()
	local eType = GetTaskType(self.data.Type)

	if eType == eTaskType.Cosume then
		return false
	elseif self.pb.num >= self.data.ArgInt then
		return true
	end

	return false
end

function InfoTask:GetTaskType()
	local eType = GetTaskType(self.data.Type)

	return eType
end

function InfoTask:IsGetAward()
	local eType = GetTaskType(self.data.Type)

	if eType == eTaskType.Cosume then
		return self:GetSpeicalData().total < (self:GetSpeicalData().num + 1) * self.data.ArgInt
	elseif self.pb.status == eTaskStatusType.complete then
		return true
	end

	return false
end

function InfoTask:IsBeing()
	local eType = GetTaskType(self.data.Type)

	return self.pb.status == eTaskStatusType.being or eType == eTaskType.Cosume
end

function InfoTask:UpdateNum()
	local eType = GetTaskType(self.data.Type)
	local argInt = self.data.ArgInt

	if self.pb.status == eTaskStatusType.complete then
		return
	end

	self.pb.num = self.pb.num + 1

	if argInt <= self.pb.num then
		self.pb.num = argInt
	end
end

function InfoTask:GetCurNum()
	if self:GetTaskType() == eTaskType.Cosume then
		return self:GetSpeicalData().total
	else
		return self.pb.num
	end
end

function InfoTask:GetSpeicalData()
	if self.speicalData then
		return self.speicalData
	else
		self.speicalData = {
			total = 0,
			num = 0
		}

		return self.speicalData
	end
end

function InfoTask:GetNeedNum()
	if self:GetTaskType() == eTaskType.Cosume then
		return self.data.ArgInt * (self:GetSpeicalData().num + 1)
	else
		return self.data.ArgInt
	end
end

TaskManager = {}
TaskManager.dict = TaskManager.dict or Record()
TaskManager.Requested = false
TaskManager.tabIndex = 0
TaskManager.integralList = {}
TaskManager.battlePassPayList = {}
TaskManager.signAwardDouble = false
TaskManager.commonAwardTomorrowList = {}

function TaskManager:Get(id)
	local ret = self.dict:GetValue(id)

	if not ret then
		ret = InfoTask(id)

		self.dict:Set(id, ret)
	end

	if ret.data == nil then
		print("请检查TaskData表!!!!!!!!" .. id)
	end

	return ret
end

function TaskManager:Init()
	self.isFirst = true
	self.jigsawCompleteList = {}
	self.isTempTips = false
	self.canShowTips = false
	self.isShowTips = false
	self.listTask = {}
	self.TaskNear = {}
	self.listTaskLineScore = {}
	self.tipsType = {}
	self.tipsQueue = {}
	self.tempQueue = {}

	for _, v in pairs(TaskListData) do
		if self.listTask[v.Type] == nil then
			self.listTask[v.Type] = {}
		end

		table.insert(self.listTask[v.Type], v)

		if table.getn(v.ScoreSection) ~= 0 and self.listTaskLineScore[v.ID] == nil then
			self.listTaskLineScore[v.ID] = {}
			self.listTaskLineScore[v.ID].score = 0
			self.listTaskLineScore[v.ID].rewardRecords = {}
			self.listTaskLineScore[v.ID].payRecords = {}
			self.listTaskLineScore[v.ID].pay = 0
			self.listTaskLineScore[v.ID].data = v
		end

		for _, id in pairs(v.List) do
			local data = {}

			data.TipsType = v.TipsType
			data.Type = v.Type
			self.tipsType[id] = data
		end
	end

	TaskListData = nil
end

function TaskManager:SetData(pb)
	self.tasks = pb.tasks

	for i = 1, #pb.tasks do
		local pbTask = pb.tasks[i]
		local info = TaskManager:Get(pbTask.id)

		info:SetData(pbTask)
	end

	if self.isFirst then
		self.isFirst = false

		self:CheckJigsaw()
	end

	self:SetScoreData(pb.scores)
	TaskRDL.Init()
end

function TaskManager:SetScoreData(pbScores)
	for i = 1, #pbScores do
		local taskLineId = pbScores[i].taskListId

		if not self.listTaskLineScore[taskLineId] then
			self.listTaskLineScore[taskLineId] = {}
		end

		self.listTaskLineScore[taskLineId].score = pbScores[i].score
		self.listTaskLineScore[taskLineId].rewardRecords = pbScores[i].rewardRecords
		self.listTaskLineScore[taskLineId].payRecords = pbScores[i].payRecords
		self.listTaskLineScore[taskLineId].pay = pbScores[i].pay
	end
end

function TaskManager:CoverTaskData(pbTasks)
	for i = 1, #pbTasks do
		local pbTask = pbTasks[i]
		local info = TaskManager:Get(pbTask.id)

		if info then
			info:SetData(pbTask)
			TaskManager:CheckTips(info)
		end
	end
end

function TaskManager:ResetTask(reType)
	for _, info in pairs(TaskManager.dict:GetValues()) do
		local tlType = self:GetTaskListType(info.pb.id)

		if tlType ~= nil then
			local rType = GetRefreshType(tlType)

			if rType == reType then
				info.pb.num = 0
				info.pb.status = eTaskStatusType.default
			end
		end
	end

	for k, v in pairs(self.listTaskLineScore) do
		local tlType = self:GetTaskListType(nil, k)

		if tlType ~= nil then
			local _, rType = GetRefreshType(tlType)

			if rType == reType then
				v.score = 0
				v.rewardRecords = {}
				v.payRecords = {}
			end
		end
	end
end

function TaskManager:GetSmallClassTask()
	local task = TaskManager:SortTaskList(TaskManager:GetList(eTaskListType.samllClass))
	local list = {}

	for _, v in ipairs(self.tasks) do
		for _, v2 in pairs(task) do
			if tonumber(v.id) == tonumber(v2.id) then
				table.insert(list, v2)
			end
		end
	end

	return TaskManager:SortTaskList(list)
end

function TaskManager:IsOpening(info)
	return self:IsBegin(info) and not self:IsExpire(info)
end

function TaskManager:IsBegin(info)
	local startTime = info.StartTime

	if startTime == "" then
		return true
	end

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local beginTime = GetTimeTampByString(startTime)

	if curServerTime < beginTime then
		return false
	end

	return true
end

function TaskManager:IsExpire(info)
	local endTime = info.EndTime

	if endTime == "" then
		return false
	end

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local overTime = GetTimeTampByString(endTime)

	if overTime < curServerTime then
		return true
	end

	return false
end

function TaskManager:GetList(_type)
	local listAll = self.listTask[_type]

	if _type == eTaskListType.battlePass or _type == eTaskListType.bossRaid or _type == eTaskListType.union or _type == eTaskListType.cosume then
		local list = {}

		for i = 1, #listAll do
			if self:IsOpening(listAll[i]) then
				table.insert(list, listAll[i])
			end
		end

		listAll = list
	end

	local listResult = {}

	for i = 1, #listAll do
		local data = listAll[i]
		local requireType = data.Requirement[1]

		if requireType == 0 then
			self:GetTaskInProcess(data.List, listResult, _type, data.TaskSection)
		elseif requireType == 1 then
			local limitLevel = data.Requirement[2]

			if limitLevel <= PlayerInst:GetCurLv() then
				self:GetTaskInProcess(data.List, listResult, _type)
			end
		elseif requireType == 2 then
			local limitStageId = data.Requirement[2]
			local infoStage = ChapterMgr:GetStage(limitStageId)

			if infoStage.pb.isPass then
				self:GetTaskInProcess(data.List, listResult, _type)
			end
		elseif requireType == 3 then
			local roleId = data.Requirement[2]
			local faverLv = data.Requirement[3]
			local info = RoleMgr:GetRole(roleId)

			if faverLv <= info.curFavorLevel then
				self:GetTaskInProcess(data.List, listResult, _type)
			end
		end
	end

	return listResult
end

function TaskManager:GetTaskInProcess(list, listResult, _type, taskSection)
	local isHaveGroup = false

	if _type and _type == eTaskListType.battlePass and taskSection then
		for i, _ in ipairs(taskSection) do
			for _, id in ipairs(taskSection[i]) do
				local info = self:Get(id)

				if info ~= nil and info.data ~= nil then
					info.sectionType = i

					table.insert(listResult, info)
				end
			end
		end

		return
	end

	if _type and _type == eTaskListType.bossRaid and taskSection then
		for i, _ in ipairs(taskSection) do
			for _, id in ipairs(taskSection[i]) do
				local info = self:Get(id)

				if info ~= nil and info.data ~= nil then
					info.sectionType = i

					table.insert(listResult, info)
				end
			end
		end

		return
	end

	for _, id in ipairs(list) do
		local info = self:Get(id)

		if info ~= nil then
			if _type and (_type == eTaskListType.main or _type == eTaskListType.achievement) then
				if info.pb.status ~= eTaskStatusType.complete then
					isHaveGroup = true

					table.insert(listResult, info)
				end

				if isHaveGroup then
					return
				end
			elseif _type and (_type == eTaskListType.daily or _type == eTaskListType.union) then
				if info.pb.status ~= eTaskStatusType.default then
					table.insert(listResult, info)
				end
			else
				table.insert(listResult, info)
			end
		end
	end
end

function TaskManager:UpdateScoreAwardData(taskLineId, awardIndex, ispay)
	if self.listTaskLineScore[taskLineId] == nil then
		return
	end

	if awardIndex == -1 then
		local taskLineData = self:GetTaskListDataByID(taskLineId)

		if not taskLineData then
			return
		end

		local score = self.listTaskLineScore[taskLineId].score

		for i = 1, #taskLineData.ScoreSection do
			local targetScore = taskLineData.ScoreSection[i][2]

			if targetScore <= score and not self:IsRecvedScoreAward(taskLineId, i - 1) then
				table.insert(self.listTaskLineScore[taskLineId].rewardRecords, i - 1)
			end

			if targetScore <= score and not self:IsRecvedPayScoreAward(taskLineId, i - 1) and ispay then
				table.insert(self.listTaskLineScore[taskLineId].payRecords, i - 1)
			end
		end

		return
	end

	if not ispay then
		local rewardRecords = self.listTaskLineScore[taskLineId].rewardRecords
		local isHave = false

		for i = 1, #rewardRecords do
			if awardIndex == rewardRecords[i] then
				isHave = true

				break
			end
		end

		if not isHave then
			table.insert(self.listTaskLineScore[taskLineId].rewardRecords, awardIndex)
		end
	else
		local payRecords = self.listTaskLineScore[taskLineId].payRecords
		local isHave = false

		for i = 1, #payRecords do
			if awardIndex == payRecords[i] then
				isHave = true

				break
			end
		end

		if not isHave then
			table.insert(self.listTaskLineScore[taskLineId].payRecords, awardIndex)
		end
	end
end

function TaskManager:GetTaskListScore(taskLineId)
	if self.listTaskLineScore[taskLineId] == nil then
		return 0
	end

	return self.listTaskLineScore[taskLineId].score
end

function TaskManager:SetTaskListScore(taskLineId, score)
	if self.listTaskLineScore[taskLineId] == nil then
		return 0
	end

	self.listTaskLineScore[taskLineId].score = self.listTaskLineScore[taskLineId].score + score
end

function TaskManager:GetTaskListPay(taskLineId)
	if self.listTaskLineScore[taskLineId] == nil then
		return 0
	end

	return self.listTaskLineScore[taskLineId].pay
end

function TaskManager:IsRecvedScoreAward(taskLineId, awardIndex)
	if self.listTaskLineScore[taskLineId] == nil then
		return nil
	end

	local scoreData = self.listTaskLineScore[taskLineId]
	local record = scoreData.rewardRecords

	for i = 1, #record do
		if record[i] == awardIndex then
			return true
		end
	end

	return false
end

function TaskManager:IsRecvedPayScoreAward(taskLineId, awardIndex)
	if self.listTaskLineScore[taskLineId] == nil then
		return nil
	end

	local scoreData = self.listTaskLineScore[taskLineId]
	local record = scoreData.payRecords
	local tasklist = TaskManager:GetTaskListDataByID(taskLineId)

	if not ShopManager:GetMonthIdState(tasklist.ActivePayId) then
		return false
	end

	for i = 1, #record do
		if record[i] == awardIndex then
			return true
		end
	end

	return false
end

function TaskManager:IsHaveTaskListScore(_type)
	local taskListData = self:GetTaskListData(_type)

	if taskListData ~= nil and table.getn(taskListData.ScoreSection) ~= 0 then
		return true
	end

	return false
end

function TaskManager:SortTaskList(list)
	local listComp = {}
	local listGet = {}

	for i = #list, 1, -1 do
		local info = list[i]
		local isComp = info:IsComplete()
		local isGet = info:IsGetAward()

		if isComp and not isGet then
			table.insert(listComp, info)
			table.remove(list, i)
		elseif isGet then
			table.insert(listGet, info)
			table.remove(list, i)
		end
	end

	for i = #listComp, 1, -1 do
		table.insert(list, 1, listComp[i])
	end

	for i = #listGet, 1, -1 do
		table.insert(list, listGet[i])
	end

	return list
end

function TaskManager:GetTaskListType(taskId, taskListId)
	for k, v in pairs(self.listTask) do
		for i = 1, #v do
			local data = v[i]

			if taskId then
				for j = 1, #data.List do
					if taskId == data.List[j] then
						return k
					end
				end
			elseif taskListId and taskListId == data.ID then
				return k
			end
		end
	end

	return nil
end

function TaskManager:GetTaskListData(_type)
	local lineData = self.listTask[_type]

	if not lineData then
		PrintWithColor("TaskListDataType[%d] not exit!", "red", _type)

		return nil
	end

	if _type == eTaskListType.union or _type == eTaskListType.battlePass or _type == eTaskListType.samllClass then
		local list = {}

		for i = 1, #lineData do
			if self:IsOpening(lineData[i]) then
				table.insert(list, lineData[i])
			end
		end

		lineData = list
	end

	return lineData[1]
end

function TaskManager:GetTaskListDataByID(taskListId)
	for _, v in pairs(self.listTask) do
		for _, taskList in pairs(v) do
			if taskListId == taskList.ID then
				return taskList
			end
		end
	end

	return nil
end

function TaskManager:HaveDotByType(_type)
	local hasTaskDot = false
	local hasScoreDot = false

	_type = TenaryOp(_type == eTaskListType.limitTime, eTaskListType.achievement, _type)

	local list = self:GetList(_type) or {}

	for _, v in pairs(list) do
		if v:IsComplete() and not v:IsGetAward() then
			hasTaskDot = true
		end
	end

	local taskListData

	if _type == 2 then
		taskListData = TaskManager:GetTaskListData(eTaskListType.daily)
	elseif _type == 3 then
		taskListData = TaskManager:GetTaskListData(eTaskListType.weekly)
	elseif _type == 4 then
		taskListData = TaskManager:GetTaskListData(eTaskListType.limitTime)
	end

	if taskListData then
		local holdScore = self:GetTaskListScore(taskListData.ID)
		local cnt = #taskListData.ScoreSection

		for i = 1, cnt do
			local needScore = taskListData.ScoreSection[i][2] or 0
			local canRecv = needScore <= holdScore
			local isRecvd = TaskManager:IsRecvedScoreAward(taskListData.ID, i - 1)

			if canRecv and not isRecvd then
				hasScoreDot = true

				break
			end
		end
	end

	return hasTaskDot or hasScoreDot
end

function TaskManager:IsBattlePassTaskDot()
	local hasTaskDot = false
	local index = BattlePassTaskMgr:GetBattlePassLevel()
	local list = self:GetList(eTaskListType.battlePass) or {}

	for k, v in pairs(list) do
		if v:IsComplete() and not v:IsGetAward() then
			hasTaskDot = true
			index = k
		end
	end

	return hasTaskDot
end

function TaskManager:IsSamllTaskTaskDot()
	local hasTaskDot = false
	local list = self:GetList(eTaskListType.samllClass) or {}

	for k, v in pairs(list) do
		if v:IsComplete() and not v:IsGetAward() then
			hasTaskDot = true
		end
	end

	return hasTaskDot
end

function TaskManager:UpdateDot()
	local hasDot = false

	for i = 1, 4 do
		local has = self:HaveDotByType(i)

		if has then
			hasDot = true
		end

		DotMgr:Update(ePSKey.Dot_TASK, {
			secondTabId = i,
			isSecondShow = has
		})
	end

	DotMgr:Update(ePSKey.Dot_TASK, {
		isShow = hasDot
	})
end

TaskLimitMgr = {}

local TaskLimitTimeList

function TaskLimitMgr:GetListLimitHourTask()
	if TaskLimitTimeList then
		return TaskLimitTimeList
	end

	for i = 1, #TaskManager.listTask[eTaskListType.limitTime] do
		if TaskManager.listTask[eTaskListType.limitTime][i].ID == 6 then
			TaskLimitTimeList = {
				TaskManager.listTask[eTaskListType.limitTime][i]
			}

			return TaskLimitTimeList
		end
	end

	return {}
end

function TaskLimitMgr:IsOpening()
	if TaskManager:IsOpening(TaskLimitMgr:GetListLimitHourTask()[1]) then
		return true
	else
		return false
	end
end

function TaskLimitMgr.GetBelongGroup(taskId)
	local temp = TaskLimitMgr:GetListLimitHourTask()[1].TaskSection

	for k, v in pairs(temp) do
		if table.contains(v, taskId) then
			return k
		end
	end

	return nil
end

function TaskLimitMgr:HaveCompleteLimitTask()
	local listAllTask = self:GetListLimitHourTask()[1].List
	local unOpenInfoIndex = 1
	local taskList = TaskLimitMgr:GetListLimitHourTask()[1].TaskSection

	for i = 1, 5 do
		local isOpen = TaskLimitMgr:IsUnLockSingleList(i)

		if isOpen then
			unOpenInfoIndex = i
		end
	end

	for j = 1, #listAllTask do
		local info = TaskManager:Get(listAllTask[j])

		for m = 1, unOpenInfoIndex do
			for n = 1, #taskList[m] do
				if taskList[m][n] == info.id and info:IsComplete() and not info:IsGetAward() then
					return true
				end
			end
		end
	end

	return false
end

function TaskLimitMgr:HaveCompleteLimitRecvedScoreAward()
	local list = TaskLimitMgr:GetListLimitHourTask()
	local curScore = TaskManager:GetTaskListScore(list[1].ID)

	for i = 1, 5 do
		local isRecv = TaskManager:IsRecvedScoreAward(list[1].ID, i - 1)

		if i <= curScore / 20 and not isRecv then
			return true
		end
	end

	return false
end

function TaskLimitMgr:GetCompleteLimitTaskTabIndex()
	local listSection = self:GetListLimitHourTask()[1].TaskSection
	local unOpenInfoIndex = 1

	for i = 1, #listSection do
		local listTask = listSection[i]
		local listGeted = {}

		for j = #listTask, 1, -1 do
			local info = TaskManager:Get(listTask[j])
			local isComple = info:IsComplete()
			local isGeted = info:IsGetAward()

			if isComple and isGeted then
				table.insert(listGeted, listTask[j])
			end
		end

		if #listGeted ~= #listTask then
			unOpenInfoIndex = i

			break
		end
	end

	return unOpenInfoIndex
end

function TaskLimitMgr:IsUnLockSingleList(index)
	local list = self:GetListLimitHourTask()
	local listCon = list[1].SectionOpenNeed

	if index == 1 then
		return true
	else
		local count = 0
		local listSingle = self:GetSingleTaskList(index - 1)

		for i = 1, #listSingle do
			local info = TaskManager:Get(listSingle[i])

			if info:IsGetAward() then
				count = count + 1
			end
		end

		if count >= listCon[index] then
			return true
		end
	end

	return false
end

function TaskLimitMgr:GetSingleTaskList(index)
	local list = self:GetListLimitHourTask()
	local listTagTask = list[1].TaskSection
	local listSingle = {}

	if listTagTask and index <= #listTagTask then
		listSingle = listTagTask[index]
	end

	return listSingle
end

function TaskLimitMgr:HaveCompleteTaskOfSingleList(index)
	local list = self:GetSingleTaskList(index)

	for i = 1, #list do
		local taskId = list[i]
		local infoTask = TaskManager:Get(taskId)

		if infoTask:IsComplete() and not infoTask:IsGetAward() and self:IsUnLockSingleList(index) then
			return true
		end
	end

	return false
end

UnionTaskMgr = {}

function UnionTaskMgr:GetUnionTaskListData()
	local lineData = TaskManager.listTask[eTaskListType.union]

	if not lineData then
		PrintWithColor("TaskListData[%d] not exit!", "red", eTaskListType.union)

		return nil
	end

	local data

	for _, v in ipairs(lineData) do
		if TaskManager:IsOpening(v) then
			data = v

			break
		end
	end

	return data
end

function UnionTaskMgr:HaveCompleteUnionTask()
	local unionTask = TaskManager:SortTaskList(TaskManager:GetList(eTaskListType.union))

	for i = 1, #unionTask do
		local info = unionTask[i]

		if info:IsComplete() and not info:IsGetAward() then
			return true
		end
	end

	local taskListData = TaskManager:GetTaskListData(eTaskListType.union)

	if not taskListData then
		return false
	end

	for i = 1, #taskListData.ScoreSectionReward do
		local haveRecv = TaskManager:IsRecvedScoreAward(taskListData.ID, i - 1)
		local targetScore = taskListData.ScoreSection[i][2]
		local curScore = TaskManager:GetTaskListScore(taskListData.ID)

		if targetScore <= curScore and not haveRecv then
			return true
		end
	end

	return false
end

BattlePassTaskMgr = {}

function BattlePassTaskMgr:GetBattlePassAwardList()
	local taskListData = TaskManager:GetTaskListData(eTaskListType.battlePass)

	if not taskListData then
		return false
	end

	local award = {}

	award.ScoreSectionReward = {}
	award.PayScoreSectionReward = {}

	for i = 1, #taskListData.ScoreSectionReward do
		table.insert(award.ScoreSectionReward, taskListData.ScoreSectionReward[i])
	end

	for i = 1, #taskListData.PayScoreSectionReward do
		table.insert(award.PayScoreSectionReward, taskListData.PayScoreSectionReward[i])
	end

	return award
end

function BattlePassTaskMgr:GetSmallClassAwardList()
	local taskListData = TaskManager:GetTaskListData(eTaskListType.samllClass)

	if not taskListData then
		return false
	end

	local award = {}

	award.ScoreSectionReward = {}
	award.PayScoreSectionReward = {}

	for i = 1, #taskListData.ScoreSectionReward do
		table.insert(award.ScoreSectionReward, taskListData.ScoreSectionReward[i])
	end

	for i = 1, #taskListData.PayScoreSectionReward do
		table.insert(award.PayScoreSectionReward, taskListData.PayScoreSectionReward[i])
	end

	return award
end

function BattlePassTaskMgr:GetBattlePassTaskID()
	local taskListData = TaskManager:GetTaskListData(eTaskListType.battlePass)

	if not taskListData then
		return false
	end

	return taskListData.ID
end

function BattlePassTaskMgr:GetSmallClassTaskID()
	local taskListData = TaskManager:GetTaskListData(eTaskListType.samllClass)

	if not taskListData then
		return false
	end

	return taskListData.ID
end

function BattlePassTaskMgr:GetBattlePassLevel()
	local taskListData = TaskManager:GetTaskListData(eTaskListType.battlePass)

	if not taskListData then
		return false
	end

	local score = TaskManager:GetTaskListScore(taskListData.ID)

	for i = 1, #taskListData.ScoreSection do
		if score > taskListData.ScoreSection[i][1] and score <= taskListData.ScoreSection[i][2] then
			if score == taskListData.ScoreSection[i][2] then
				return i
			end

			return i - 1
		end
	end

	if score == 0 then
		return 0
	end

	return #taskListData.ScoreSection
end

function BattlePassTaskMgr:SetBattlePassScore(score)
	local taskListData = TaskManager:GetTaskListData(eTaskListType.battlePass)

	if not taskListData then
		return false
	end

	local score = TaskManager:SetTaskListScore(BattlePassTaskMgr:GetBattlePassTaskID(), score)
end

function BattlePassTaskMgr:GetBattlePassScore()
	local taskListData = TaskManager:GetTaskListData(eTaskListType.battlePass)

	if not taskListData then
		return false
	end

	local score = tonumber(TaskManager:GetTaskListScore(BattlePassTaskMgr:GetBattlePassTaskID()))
	local fullScore = 0

	for i = 1, #taskListData.ScoreSection do
		if score > tonumber(taskListData.ScoreSection[i][1]) and score <= tonumber(taskListData.ScoreSection[i][2]) then
			fullScore = tonumber(taskListData.ScoreSection[i][2])

			if taskListData.ScoreSection[i - 1] then
				score = score - taskListData.ScoreSection[i - 1][2]
				fullScore = fullScore - taskListData.ScoreSection[i - 1][2]
			end

			if score == fullScore then
				return 0
			end

			return score / fullScore
		end
	end

	if score == 0 then
		return 0
	else
		return 1
	end
end

function BattlePassTaskMgr:GetBattlePassGrade()
	local taskListData = TaskManager:GetTaskListData(eTaskListType.battlePass)

	if not taskListData then
		return false
	end

	local score = tonumber(TaskManager:GetTaskListScore(BattlePassTaskMgr:GetBattlePassTaskID()))
	local fullScore = 0
	local preScore = 0

	for i = 1, #taskListData.ScoreSection do
		if score >= tonumber(taskListData.ScoreSection[i][1]) - 1 and score < tonumber(taskListData.ScoreSection[i][2]) then
			preScore = taskListData.ScoreSection[i][1] - 1
			fullScore = taskListData.ScoreSection[i][2]

			return score - preScore .. "/" .. fullScore - preScore
		end
	end

	if score == 0 then
		return 0 .. "/" .. taskListData.ScoreSection[1][2]
	else
		return score .. "/" .. taskListData.ScoreSection[#taskListData.ScoreSection][2]
	end
end

function TaskManager:GetTimespaceTask()
	local taskLists = TaskManager.listTask[eTaskListType.timespace]

	return taskLists[1]
end

function TaskManager:HasBossRaidTaskDot()
	local list = self:GetList(eTaskListType.bossRaid) or {}

	for _, v in pairs(list) do
		if v:IsComplete() and not v:IsGetAward() then
			return true
		end
	end
end

function TaskManager:CheckTips(info)
	if info.data and self.tipsType[info.data.ID].TipsType == 1 then
		info.Type = self.tipsType[info.data.ID].Type

		if info.pb.num >= info.data.ArgInt then
			self.TaskNear[info.data.ID] = nil

			TaskManager:AddTipsQueue(info)
		elseif self:IsNearAchievement(info) then
			TaskManager:AddTipsQueue(info)
		end
	end
end

function TaskManager:IsNearAchievement(info)
	local lastValue = self.TaskNear[info.data.ID]

	if lastValue == nil then
		lastValue = 0
	end

	for _, value in pairs(info.data.TaskTips) do
		if value <= info.pb.num and lastValue < value then
			self.TaskNear[info.data.ID] = info.pb.num

			return true
		end
	end

	return false
end

function TaskManager:AddTipsQueue(info)
	local tipsIndex = 0

	if not self.isTempTips then
		for index, value in pairs(self.tipsQueue) do
			if value.data.ID == info.data.ID then
				tipsIndex = index

				break
			end
		end

		if tipsIndex ~= 0 then
			self.tipsQueue[tipsIndex] = info
		else
			table.insert(self.tipsQueue, info)
		end

		table.sort(self.tipsQueue, function(a, b)
			if a.data.ID > b.data.ID then
				return false
			else
				return true
			end
		end)
	else
		for index, value in pairs(self.tempQueue) do
			if value.data.ID == info.data.ID then
				tipsIndex = index

				break
			end
		end

		if tipsIndex ~= 0 then
			self.tempQueue[tipsIndex] = info
		else
			table.insert(self.tempQueue, info)
		end

		table.sort(self.tempQueue, function(a, b)
			if a.data.ID > b.data.ID then
				return false
			else
				return true
			end
		end)
	end

	self:ShowTaskTips()
end

function TaskManager:ShowTaskTips()
	if self.canShowTips and not self.isShowTips then
		if self.isTempTips and #self.tipsQueue == 0 then
			return
		end

		if not self.isShowTips and #self.tempQueue ~= 0 then
			for key, value in pairs(self.tempQueue) do
				table.insert(self.tipsQueue, value)
			end

			self.tempQueue = {}
		end

		if #self.tipsQueue == 0 and #self.tempQueue == 0 then
			return
		end

		self.isShowTips = true

		require("UI/Page/PageTask/PageTaskTips")
		UIMgr.AddPanel(PageTaskTips(), nil, UIMgr.UIPopupObject)
	end
end

function TaskManager:ClearTips()
	if self.canShowTips then
		self.tipsQueue = {}
		self.tempQueue = {}

		Event.Instance:Fire("CloseTaskTips")
	end
end

function TaskManager:CheckJigsaw()
	local listOpenActive = OperationActiveMgr:GetListOpenActive()

	for _, value in pairs(listOpenActive) do
		if value.data.UIType == eOperationActive.Jigsaw then
			local list = TaskManager:GetTaskListDataByID(value.data.DailyTime[1][1])

			for key, id in pairs(list.List) do
				local task = TaskManager:Get(id)

				if task:IsComplete() then
					table.insert(self.jigsawCompleteList, key, task)
				end
			end

			return
		end
	end
end

function TaskManager:SetSpeicalData(tasks)
	for i = 1, #tasks do
		local pbTask = tasks[i]
		local info = TaskManager:Get(pbTask.id)

		info.speicalData = pbTask
	end
end
