-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/CalendarRDL.lua

CalendarRDL = {}

local RD_Calendar_Branch_Path = {
	Calendar = "Calendar/%d"
}
local CAN_RECEIVE_ONLINE = {}
local info
local nextUpdateIndex = 0
local nextUpdateMinute = 0
local onLineMinute = 0

function CalendarRDL.Reset()
	onLineMinute = 0

	CalendarRDL.Init()
end

local function GetNextUpdate()
	nextUpdateIndex = 0
	nextUpdateMinute = 0

	if info ~= nil then
		for k, v in ipairs(info.data.DailyTime) do
			if onLineMinute + OperationActiveMgr.OnLineTime / 60 < v[1] and k > nextUpdateIndex then
				nextUpdateMinute = v[1]
				nextUpdateIndex = k

				break
			end
		end
	end
end

function CalendarRDL.Init()
	if info == nil then
		info = OperationActiveMgr:Get(OperationActiveMgr:GetTotalOnlineInfo().ID)

		if info == nil then
			return
		end

		onLineMinute = tonumber(info.pb.record) / 60
	end

	CalendarRDL.InitRD()
	GetNextUpdate()
end

function CalendarRDL.InitRD()
	CAN_RECEIVE_ONLINE = {}

	for k, v in ipairs(info.data.DailyTime) do
		local value = 0

		if not info:IsGetIndexAward(k) and onLineMinute + OperationActiveMgr.OnLineTime / 60 >= v[1] and not table.contains(CAN_RECEIVE_ONLINE, k) then
			table.insert(CAN_RECEIVE_ONLINE, k)

			value = 1
		end

		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Calendar_Branch_Path.Calendar, value, k)
	end
end

function CalendarRDL.AddOnLine(_idx)
	if not table.contains(CAN_RECEIVE_ONLINE, _idx) then
		table.insert(CAN_RECEIVE_ONLINE, _idx)
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Calendar_Branch_Path.Calendar, 1, _idx)
	end
end

function CalendarRDL.RemoveOnLine(_idx)
	if table.contains(CAN_RECEIVE_ONLINE, _idx) then
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Calendar_Branch_Path.Calendar, 0, _idx)
		table.removeByValue(CAN_RECEIVE_ONLINE, _idx)
	end
end

function CalendarRDL.RemoveAllOnLine()
	for i = #CAN_RECEIVE_ONLINE, 1, -1 do
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Calendar_Branch_Path.Calendar, 0, CAN_RECEIVE_ONLINE[i])
	end

	CAN_RECEIVE_ONLINE = {}
end

function CalendarRDL.DealRemove(_id, _idx)
	if info and _idx and info.id == _id then
		if type(_idx) == "table" then
			CalendarRDL.RemoveAllOnLine()
		else
			CalendarRDL.RemoveOnLine(_idx)
		end
	end
end

function CalendarRDL.Update()
	if nextUpdateIndex == 0 or nextUpdateMinute == 0 then
		return
	end

	if onLineMinute + OperationActiveMgr.OnLineTime / 60 >= nextUpdateMinute then
		CalendarRDL.AddOnLine(nextUpdateIndex)
		GetNextUpdate()
	end
end

return CalendarRDL
