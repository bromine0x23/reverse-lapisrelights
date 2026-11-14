-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/OperationRDL/OperationRDL.lua

OperationRDL = {}
OperationRDL.FirstRechargeRDL = require("RedDot/SystemRDL/OperationRDL/FirstRechargeRDL")

local RD_Operation_Branch_Path = {
	BattlePass_Pay_Score = "Operation/BattlePass/Score/Pay/%d",
	Active = "Operation/%d"
}
local ALL_OPEN_OPERATION = {}

local function GetOperationActive(_type)
	ALL_OPEN_OPERATION = OperationActiveMgr:GetListOpenActive()

	for _, v in pairs(ALL_OPEN_OPERATION) do
		if v.data.Type == _type then
			return v
		end
	end

	return nil
end

function OperationRDL.Init()
	ALL_OPEN_OPERATION = OperationActiveMgr:GetListOpenActive()

	OperationRDL.RunHourlyGift()
	OperationRDL.FirstRechargeRDL.Init()
end

function OperationRDL.RunHourlyGift()
	local active = GetOperationActive(eOperationActiveType.Hour)

	if active == nil then
		return
	end

	local value = 0

	for k, v in ipairs(active.data.DailyTime) do
		local isGeted = active:IsGetIndexAward(k)
		local isTime = OperationActiveMgr:IsInTheTime(v[1], v[2])

		if not isGeted and isTime then
			value = value + 1
		end
	end

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Operation_Branch_Path.Active, value, active.id)
end

local TaskSign = {
	{
		1,
		2,
		3
	},
	{
		4,
		5,
		6
	},
	{
		7,
		8,
		9
	},
	{
		1,
		4,
		7
	},
	{
		2,
		5,
		8
	},
	{
		3,
		6,
		9
	},
	{
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9
	}
}
local JiasawData = {}

function OperationRDL.GetRewardProgress(_idx)
	local num = 0

	for k, v in pairs(TaskSign[_idx]) do
		if JiasawData[v] and JiasawData[v].complete then
			num = num + 1
		end
	end

	return num, #TaskSign[_idx]
end

function OperationRDL.RunJigsaw()
	local active = GetOperationActive(eOperationActiveType.Jigsaw)

	if active == nil then
		return
	end

	local taskList = TaskManager:GetTaskListDataByID(active.data.DailyTime[1][1])

	for k, v in ipairs(taskList.List) do
		local data = {}
		local task = TaskManager:Get(v)

		data.complete = task:IsComplete()
		JiasawData[k] = data
	end

	local value = 0

	for k, v in pairs(active.data.Params) do
		local num, target = OperationRDL.GetRewardProgress(k)

		if num == target and not active:IsGetIndexAward(k) then
			value = value + 1
		end
	end

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Operation_Branch_Path.Active, value, active.id)
end

local BattlePassRedDotValue = {}

function OperationRDL.RunBattlePass()
	local active = GetOperationActive(eOperationActiveType.BattlePass)

	if active == nil then
		RedDotSystemMgr.SetNodeLockState("Operation/BattlePass", true)

		return
	end

	local listBattlePassAward = OperationActiveMgr:GetActiveRewardItems(active.id)

	if #listBattlePassAward.ScoreSectionReward == BattlePassTaskMgr:GetBattlePassLevel() then
		RedDotSystemMgr.RemoveNode("Operation/BattlePass/Task")
		RedDotSystemMgr.SetNodeLockState("Operation/BattlePass/Task", true)
	end

	local taskList = TaskManager.listTaskLineScore[active.data.DailyTime[1][1]]
	local data = taskList.data

	if not ShopManager:GetMonthIdState(data.ActivePayId) then
		return
	end

	if taskList ~= nil then
		for i, j in ipairs(data.ScoreSection) do
			local value = 0

			if j[2] <= taskList.score and not table.contains(taskList.payRecords, i - 1) and table.existElement(data.PayScoreSectionReward[i]) then
				value = 1
			end

			if BattlePassRedDotValue[i] ~= value then
				BattlePassRedDotValue[i] = value

				RedDotSystemMgr.SetNodeValueByFormatPath(RD_Operation_Branch_Path.BattlePass_Pay_Score, value, i)
			end
		end
	end
end

function OperationRDL.RunSmallClass()
	local active = GetOperationActive(eOperationActiveType.SmallClass)

	if active == nil then
		RedDotSystemMgr.SetNodeLockState("Operation/SmallClass", true)

		return
	end
end

function OperationRDL.RunGrowthFund()
	local active = GetOperationActive(eOperationActiveType.GrowthFund)

	if active == nil then
		return
	end

	local list = TaskManager:GetTaskListDataByID(active.data.DailyTime[1][1])
	local value = 0

	for _, valueID in pairs(list.List) do
		local task = TaskManager:Get(valueID)

		if task:IsComplete() then
			if ShopManager:GetGrowthFund() then
				if task.pb.status <= 2 then
					value = value + 1
				end
			elseif task.pb.status < 2 then
				value = value + 1
			end
		end
	end

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Operation_Branch_Path.Active, value, active.id)
end

function OperationRDL.DealOperationPath(_id)
	local active = OperationActiveMgr:Get(_id)

	if active == nil then
		return ""
	end

	local _type = active.data.Type

	if _type == eOperationActiveType.Hour or _type == eOperationActiveType.Jigsaw or _type == eOperationActiveType.GrowthFund then
		return string.format(RD_Operation_Branch_Path.Active, _id)
	elseif active.data.Type == eOperationActiveType.BattlePass then
		return "Operation/BattlePass"
	elseif active.data.Type == eOperationActiveType.SmallClass then
		return "Operation/SmallClass"
	elseif active.data.Type == eOperationActiveType.URCardPool then
		return "Operation/URCardPool"
	end

	return ""
end

function OperationRDL.DealNodeDot(_id, _idx)
	local active = OperationActiveMgr:Get(_id)

	if active == nil then
		return
	end

	local _type = active.data.Type

	if _type == eOperationActiveType.Hour then
		OperationRDL.RunHourlyGift()
	elseif _type == eOperationActiveType.Jigsaw then
		OperationRDL.RunJigsaw()
	elseif active.data.Type == eOperationActiveType.BattlePass then
		-- block empty
	elseif active.data.Type == eOperationActiveType.SmallClass then
		-- block empty
	elseif active.data.Type == eOperationActiveType.FirstCharge then
		OperationRDL.FirstRechargeRDL.SubFirstRechargeAward()
	elseif active.data.Type == eOperationActiveType.GrowthFund then
		OperationRDL.RunGrowthFund()
	end
end

return OperationRDL
