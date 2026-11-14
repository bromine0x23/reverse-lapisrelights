-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/DateUtil.lua

DateUtil = class("DateUtil")
DateUtil.MillsPerSecond = 1000
DateUtil.SecsPerDay = 86400
DateUtil.SecsPerHour = 3600
DateUtil.SecsPerMinute = 60
DateUtil.MinutesPerHour = 60
DateUtil.DayPerWeek = 7
DateUtil.SecsPerWeek = 604800
DateUtil.MillsPerMinute = 60000
DateUtil.ServerTimeZone = 32400

local fDate = os.date
local fTime = os.time

function DateUtil.GetLocalTimeZone()
	local now = fTime()
	local localTimeZone = os.difftime(now, fTime(fDate("!*t", now)))
	local isdst = fDate("*t", now).isdst

	if isdst then
		localTimeZone = localTimeZone + 3600
	end

	return localTimeZone
end

function DateUtil.Date(format, timestamp)
	if timestamp == nil then
		return fDate(format)
	end

	local timeZoneDiff = DateUtil.ServerTimeZone - DateUtil.GetLocalTimeZone()

	return fDate(format, timestamp + timeZoneDiff)
end

function DateUtil.Time(timedate)
	if timedate == nil then
		return fTime()
	end

	local timeZoneDiff = DateUtil.ServerTimeZone - DateUtil.GetLocalTimeZone()

	return fTime(timedate) - timeZoneDiff
end

function DateUtil.OriginTime(timedate)
	return fTime(timedate)
end

function DateUtil.GetOneMomentByMillis(millis)
	local m = millis
	local i, f = math.modf(m / (DateUtil.SecsPerDay * DateUtil.MillsPerSecond))
	local str = ""

	if i >= 1 then
		str = i .. _("Desc_day")
		m = m - Mathf.Floor(i * (DateUtil.SecsPerDay * DateUtil.MillsPerSecond))
	end

	i, f = math.modf(m / (DateUtil.SecsPerHour * DateUtil.MillsPerSecond))

	if i >= 1 then
		str = str .. i .. _("Desc_hour")
		m = m - Mathf.Floor(i * (DateUtil.SecsPerHour * DateUtil.MillsPerSecond))
	end

	i, f = math.modf(m / (DateUtil.SecsPerMinute * DateUtil.MillsPerSecond))

	if i < 1 then
		i = 1
	end

	return str .. i .. _("Desc_minute")
end

function DateUtil.GetTwoMomentByMillis(millis)
	local m = millis
	local i, f = math.modf(m / (DateUtil.SecsPerDay * DateUtil.MillsPerSecond))
	local dayStr = ""
	local hourStr = ""
	local str = ""
	local hasDay = false

	if i >= 1 then
		str = i .. _("Desc_day")
		dayStr = str
		hasDay = true
		m = m - Mathf.Floor(i * (DateUtil.SecsPerDay * DateUtil.MillsPerSecond))
	end

	i, f = math.modf(m / (DateUtil.SecsPerHour * DateUtil.MillsPerSecond))

	if i >= 1 then
		str = str .. i .. _("Desc_hour")
		hourStr = i .. _("Desc_hour")
		m = m - Mathf.Floor(i * (DateUtil.SecsPerHour * DateUtil.MillsPerSecond))
	end

	i, f = math.modf(m / (DateUtil.SecsPerMinute * DateUtil.MillsPerSecond))

	if i < 1 then
		i = 1
	end

	local minuteStr = i .. _("Desc_minute")

	if hasDay then
		return dayStr .. hourStr
	else
		return hourStr .. minuteStr
	end
end

function DateUtil.GetDayMomentByMillis(millis)
	local m = millis
	local i, f = math.modf(m / (DateUtil.SecsPerDay * DateUtil.MillsPerSecond))
	local str = ""

	if i >= 1 then
		str = i .. _("Desc_day")
	else
		i, f = math.modf(m / (DateUtil.SecsPerHour * DateUtil.MillsPerSecond))

		if i >= 1 then
			str = str .. i .. _("Desc_hour")
			hourStr = i .. _("Desc_hour")
			m = m - Mathf.Floor(i * (DateUtil.SecsPerHour * DateUtil.MillsPerSecond))

			return hourStr
		else
			i, f = math.modf(m / (DateUtil.SecsPerMinute * DateUtil.MillsPerSecond))

			if i < 1 then
				i = 1
			end

			local minuteStr = i .. _("Desc_minute")

			return minuteStr
		end
	end

	return str
end

function DateUtil.GetDayOfWeekIntegerByEnum(dayOfWeekEnum)
	local rst = dayOfWeekEnum:GetHashCode()

	if rst == 0 then
		rst = 7
	end

	return rst
end

function DateUtil.GetMoment(second)
	local i = Mathf.Floor(second / DateUtil.SecsPerMinute)

	if i < 1 then
		i = 1
	end

	local left = second - i * DateUtil.SecsPerMinute

	if left < 10 then
		left = "0" .. left
	end

	return i .. ":" .. left
end

function DateUtil.GetDateFormat(tick)
	return os.date("%Y/%m/%d %X", tick)
end

function DateUtil.GetDateFormatBySingle(tick)
	local ttt = os.date("%Y/%m/%d %H:%M:%S", tick)

	print(ttt)

	local years = string.split(string.split(ttt, " ")[1], "/")
	local times = string.split(string.split(ttt, " ")[2], ":")

	return years[1], years[2], years[3], times[1], times[2]
end

function DateUtil.GetMoment00(second)
	local d, h, m, s = GetTimeFormatBySec(second)

	m = m < 10 and "0" .. m or m
	s = s < 10 and "0" .. s or s

	return m .. ":" .. s
end

function DateUtil.GetYearsOld(serverTick, year, month)
	serverTick = Mathf.Round(serverTick / 1000)

	local date = os.date("*t", serverTick)
	local currY = tonumber(date.year)
	local currM = tonumber(date.month)

	age = currY - year

	if currM <= month then
		age = age - 1
	end

	return math.max(age, 0)
end

function DateUtil.GetYearsMonthAndDay(serverTick)
	serverTick = Mathf.Round(serverTick / 1000)

	local date = os.date("*t", serverTick)
	local currY = tonumber(date.year)
	local currM = tonumber(date.month)
	local currD = tonumber(date.day)

	return currY, currM, currD
end

function DateUtil.GetMomentHour00(second)
	local d, h, m, s = GetTimeFormatBySec(second)

	h = h < 10 and "0" .. h or h
	m = m < 10 and "0" .. m or m
	s = s < 10 and "0" .. s or s

	return h .. ":" .. m .. ":" .. s
end

function DateUtil.isMorning()
	local curTimeStamp = Mathf.Round(NetData:GetCurServerTime() / 1000)
	local today = os.date("*t", curTimeStamp)

	return today.hour >= 6 and today.hour <= 20
end

function DateUtil.getDateSection()
	local curTimeStamp = Mathf.Round(NetData:GetCurServerTime() / 1000)
	local today = os.date("*t", curTimeStamp)

	if today.hour >= 0 and today.hour <= 6 then
		return 1
	elseif today.hour > 6 and today.hour <= 12 then
		return 2
	elseif today.hour > 12 and today.hour <= 18 then
		return 3
	else
		return 4
	end
end
