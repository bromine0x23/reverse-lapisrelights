-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/WorkRDL.lua

WorkRDL = {}

local RD_Work_Branch_Path = {
	Work = "Arrow/Work/Pick/%d"
}
local CAN_RECEIVE_WORK = {}

function WorkRDL.Init()
	local t = WorkMgr:GetWorkListByState(eWorkStateType.Picked)

	for _, v in pairs(t) do
		if v:IsComplete() and not table.contains(CAN_RECEIVE_WORK, tonumber(v.pb.id)) then
			table.insert(CAN_RECEIVE_WORK, tonumber(v.pb.id))
		end
	end

	WorkRDL.InitRD()
end

function WorkRDL.InitRD()
	for _, v in pairs(CAN_RECEIVE_WORK) do
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Work_Branch_Path.Work, 1, v)
	end
end

function WorkRDL.AddCanReceive(_id)
	if table.contains(CAN_RECEIVE_WORK, tonumber(_id)) then
		return
	end

	table.insert(CAN_RECEIVE_WORK, tonumber(_id))
	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Work_Branch_Path.Work, 1, _id)
end

function WorkRDL.RemoveReceived(_id)
	if not table.contains(CAN_RECEIVE_WORK, tonumber(_id)) then
		return
	end

	table.removeByValue(CAN_RECEIVE_WORK, tonumber(_id))
	RedDotSystemMgr.RemoveNode(RD_Work_Branch_Path.Work, _id)
end

function WorkRDL.IsComplete(_id)
	return table.contains(CAN_RECEIVE_WORK, tonumber(_id))
end

function WorkRDL.HasComplete()
	return #CAN_RECEIVE_WORK > 0
end

return WorkRDL
