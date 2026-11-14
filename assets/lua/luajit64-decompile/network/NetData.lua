-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Network/NetData.lua

NetData = {}
NetData.LocalStartTime = 0
NetData.ServerTime = 0
NetData.ServerName = ""
NetData.ServerID = "1"

function NetData:GetCurServerTime()
	local localTimeElapse = Time.realtimeSinceStartup * DateUtil.MillsPerSecond - self.LocalStartTime

	return self.ServerTime + localTimeElapse
end

function NetData:SetServerTime(serverTime, offsetTime)
	self.ServerTime = serverTime
	self.LocalStartTime = Time.realtimeSinceStartup * DateUtil.MillsPerSecond
	self.ServerTimeOffset = offsetTime
end

function NetData:GetCurTimeMillis()
	return DateTimeUtil.GetCurrentTime() * DateUtil.MillsPerSecond
end

function NetData:GetServerDayOfWeek()
	return DateUtil.GetDayOfWeekIntegerByEnum(self:GetServerDateTime().DayOfWeek)
end

function NetData:IsBegin(startTime)
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

function NetData:IsExpire(endTime)
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
