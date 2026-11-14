-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/UnionRDL/UnionTaskRDL.lua

local UnionTaskRDL = {}
local KEY_RD_UNION_TASK = "KEY_RD_UNION_TASK"
local CAN_RECEIVE_UNION_TASK = {}
local CAN_RECEIVE_UNION_SCORE = {}

function UnionTaskRDL.Reset()
	CAN_RECEIVE_UNION_TASK = {}

	for _, idx in ipairs(CAN_RECEIVE_UNION_SCORE) do
		RedDotSystemMgr.SetNodeValueByFormatPath(string.format(RD_Union_Branch_Path.Union_Score, idx), 0)
	end

	CAN_RECEIVE_UNION_SCORE = {}
end

function UnionTaskRDL.Init(task_tbl, score_tbl)
	UnionTaskRDL.Reset()

	for _, v in pairs(task_tbl or {}) do
		table.insert(CAN_RECEIVE_UNION_TASK, v)
	end

	for _, v in pairs(score_tbl or {}) do
		table.insert(CAN_RECEIVE_UNION_SCORE, v)
	end

	UnionTaskRDL.InitRD()
end

function UnionTaskRDL.InitRD()
	if not UnionMgr.HasUnion() then
		return
	end

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Union_Branch_Path.Task, #CAN_RECEIVE_UNION_TASK)

	for _, idx in ipairs(CAN_RECEIVE_UNION_SCORE) do
		RedDotSystemMgr.SetNodeValueByFormatPath(string.format(RD_Union_Branch_Path.Union_Score, idx), 1)
	end
end

function UnionTaskRDL.DealTask(id, value)
	if not UnionMgr.HasUnion() then
		return
	end

	if value > 0 then
		if not table.contains(CAN_RECEIVE_UNION_TASK, id) then
			table.insert(CAN_RECEIVE_UNION_TASK, id)
		else
			value = 0
		end
	elseif table.contains(CAN_RECEIVE_UNION_TASK, id) then
		table.removeByValue(CAN_RECEIVE_UNION_TASK, id)
	else
		value = 0
	end

	if value ~= 0 then
		RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Union_Branch_Path.Task, value)
	end
end

function UnionTaskRDL.AddScore(_idx)
	if not UnionMgr.HasUnion() then
		return
	end

	if not table.contains(CAN_RECEIVE_UNION_SCORE, _idx) then
		table.insert(CAN_RECEIVE_UNION_SCORE, _idx)
		RedDotSystemMgr.SetNodeValueByFormatPath(string.format(RD_Union_Branch_Path.Union_Score, _idx), 1)
	end
end

function UnionTaskRDL.SubScore(_idx)
	if not UnionMgr.HasUnion() then
		return
	end

	if _idx then
		if table.contains(CAN_RECEIVE_UNION_SCORE, _idx) then
			table.removeByValue(CAN_RECEIVE_UNION_SCORE, _idx)
			RedDotSystemMgr.SetNodeValueByFormatPath(string.format(RD_Union_Branch_Path.Union_Score, _idx), 0)
		end
	else
		for _, idx in pairs(CAN_RECEIVE_UNION_SCORE) do
			RedDotSystemMgr.SetNodeValueByFormatPath(string.format(RD_Union_Branch_Path.Union_Score, idx), 0)
		end

		CAN_RECEIVE_UNION_SCORE = {}
	end
end

function UnionTaskRDL.ResetTaskRDAfterJoinUnion()
	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Union_Branch_Path.Task, 0)

	for _, idx in ipairs(CAN_RECEIVE_UNION_SCORE) do
		RedDotSystemMgr.SetNodeValueByFormatPath(string.format(RD_Union_Branch_Path.Union_Score, idx), 0)
	end
end

function UnionTaskRDL.ResetTaskRDAfterLeaveUnion()
	UnionTaskRDL.InitRD()
end

return UnionTaskRDL
