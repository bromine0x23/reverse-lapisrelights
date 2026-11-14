-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/Util.lua

Util = {}
Util.PATH_FX = "Fx/"

function ternary(condition, expressionA, expressionB)
	return (condition and {
		expressionA
	} or {
		expressionB
	})[1]
end

function io.write_text(filename, text)
	local f = io.open(filename, "w")

	f:write(text)
	f:close()
end

function printTableToJson(tab, singleLine)
	local print_enable = Application.isEditor == true
	local print = function(...)
		if print_enable == true then
			print(...)
		end
	end
	local json = require("GameLogic/Util/json4lua")
	local ret = json.encode(tab)

	if singleLine then
		ret = string.gsub(ret, "{", "\n{")
	end

	print(ret)
end

function printTable(tab, depth)
	depth = depth or 9999

	local info = debug.getinfo(2, "Sl")
	local source = info and info.source

	print("<color=cyan>(" .. source .. ":" .. info.currentline .. ")</color>\n<color=red>" .. tostring(tab) .. "</color>\n" .. tostring(_stringTable(tab, "", depth, 1)))
end

function getTableKeyString(tab, depth)
	depth = depth or 9999

	return _stringKeyTable(tab, "", depth, 1)
end

function _stringKeyTable(tab, pre, depth, curt_depth)
	if depth < curt_depth then
		return ""
	end

	local pre = pre or ""
	local text = pre .. "{\n"

	for i, v in pairs(tab) do
		text = text .. pre .. string.format("    %s\n", i)

		if type(v) == "table" and i ~= "_G" then
			text = text .. _stringKeyTable(v, pre .. "    ", depth, curt_depth + 1)
		end
	end

	text = text .. pre .. "}\n"

	return text
end

function getTableString(tab, depth)
	depth = depth or 9999

	return tostring(tab) .. "\n" .. _stringTable(tab, "", depth, 1)
end

function _stringTable(tab, pre, depth, curt_depth, checked)
	if depth < curt_depth then
		return ""
	end

	checked = checked or {}

	if checked[tab] then
		return ""
	else
		checked[tab] = true
	end

	local pre = pre or ""
	local text = pre .. "{\n"

	for i, v in pairs(tab) do
		text = text .. pre .. string.format("    %s = %s\n", tostring(i), tostring(v))

		if type(v) == "table" then
			text = text .. _stringTable(v, pre .. "    ", depth, curt_depth + 1, checked)
		elseif type(v) == "function" then
			text = text .. _stringTableFunc(v, pre .. "    ", depth, curt_depth + 1, checked)
		end
	end

	text = text .. pre .. "}\n"

	return text
end

function _stringTableFunc(func, pre, depth, curt_depth, checked)
	local pre = pre or ""
	local text = pre .. "{\n"
	local upv_idx = 1

	while true do
		local upn, upv = debug.getupvalue(func, upv_idx)

		if upv == nil then
			break
		end

		text = text .. pre .. string.format("    %s=%s\n", tostring(upv_idx), tostring(upv))

		if type(upv) == "table" then
			text = text .. _stringTable(upv, pre .. "    ", depth, curt_depth + 1, checked)
		end

		upv_idx = upv_idx + 1
	end

	text = text .. pre .. "}\n"

	return text
end

function findReference(target)
	local results = {}
	local checked = {}

	_findReference(target, checked, results, _G)
	_findReference(target, checked, results, debug.getregistry())

	return results
end

function _findReference(target, checked, results, curent, trace)
	if checked[curent] then
		return
	else
		checked[curent] = true
	end

	local trace = trace or ""

	for i, v in pairs(curent) do
		if v == target then
			curent._______TRACE = curent._______TRACE or {}
			curent._______TRACE[#curent._______TRACE + 1] = trace .. "." .. i
			results[#results + 1] = curent

			return
		elseif type(v) == "table" then
			_findReference(target, checked, results, v, trace .. "." .. tostring(i))
		elseif type(v) == "function" then
			_findReferenceForFunc(target, checked, results, curent, v, trace .. "." .. tostring(i))
		end
	end
end

function _findReferenceForFunc(target, checked, results, table, func, trace)
	local upv_idx = 1

	while true do
		local upn, upv = debug.getupvalue(func, upv_idx)

		if upv == nil then
			break
		end

		if upv == target then
			table._______TRACE = table._______TRACE or {}
			table._______TRACE[#table._______TRACE + 1] = trace .. ".[func]" .. upn .. "(" .. tostring(upv) .. ")"
			results[#results + 1] = table

			return
		elseif type(upv) == "table" then
			_findReference(target, checked, results, upv, trace .. ".[func]" .. upn .. "(" .. tostring(upv) .. ")")
		end

		upv_idx = upv_idx + 1
	end
end

function table.removeByValue(vTable, vValue)
	if vTable == nil then
		return
	end

	local removeIdx = -1

	for i = 1, #vTable do
		local value = vTable[i]

		if value == vValue then
			removeIdx = i

			table.remove(vTable, removeIdx)

			return
		end
	end

	if removeIdx == -1 then
		return
	end
end

function table.getItemCount(tb)
	local count = 0

	for k, v in pairs(tb) do
		count = count + 1
	end

	return count
end

function table.getIndex(vTable, vValue)
	for i = 1, #vTable do
		if vTable[i] == vValue then
			return i
		end
	end

	return -1
end

function table.getKeyByValue(vTable, vValue)
	for k, v in pairs(vTable) do
		if v == vValue then
			return k
		end
	end
end

function table.getValueByKey(table, key)
	if table == nil then
		return nil
	end

	for k, v in pairs(table) do
		if k == key then
			return v
		end
	end

	return nil
end

function table.clear(vTable)
	if vTable == nil then
		return
	end

	for k, v in pairs(vTable) do
		vTable[k] = nil
	end
end

function table.isEqual(t1, t2)
	for k, v in pairs(t1) do
		for k2, v2 in pairs(t2) do
			if v ~= v2 then
				return false
			end
		end
	end

	return true
end

function table.merge(t1, t2)
	if t2 == nil then
		return
	end

	for k, v in pairs(t2) do
		if v then
			table.insert(t1, v)
		end
	end
end

function table.existElement(tbl)
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			if table.existElement(v) then
				return true
			end
		elseif v ~= nil then
			return true
		end
	end

	return false
end

function table.deduplication(tbl)
	local t = {}

	for _, v in pairs(tbl) do
		if not table.contains(t, v) then
			table.insert(t, v)
		end
	end

	return t
end

function pairsByKeys(t)
	local a = {}

	for n in pairs(t) do
		a[#a + 1] = n
	end

	table.sort(a)

	local i = 0

	return function()
		i = i + 1

		return a[i], t[a[i]]
	end
end

function string.split(str, reps)
	local idx_array = 1
	local ret = {}
	local i = 0
	local s, e = string.find(str, reps, 1)

	while s ~= nil do
		if s - i > 0 then
			ret[idx_array] = string.sub(str, i, s - 1)
		else
			ret[idx_array] = ""
		end

		idx_array = idx_array + 1
		i = e + 1
		s, e = string.find(str, reps, e + 1)
	end

	if i <= string.len(str) then
		ret[idx_array] = string.sub(str, i, string.len(str))
	end

	return ret
end

function string.splitEx(str, reps)
	local idx_array = 1
	local ret = {}
	local i = 0
	local s, e = string.find(str, reps, 1)

	while s ~= nil do
		if s - i > 0 then
			ret[idx_array] = string.sub(str, i, s - 1)
		else
			ret[idx_array] = ""
		end

		idx_array = idx_array + 1
		i = e + 1
		s, e = string.find(str, reps, e + 1)
	end

	if i <= string.len(str) then
		ret[idx_array] = string.sub(str, i, string.len(str))
	end

	return ret
end

function string.Replace(baseStr, findStr, replaceStr)
	local replace = System.String(baseStr)

	replace = replace.Replace(replace, findStr, replaceStr)

	return replace
end

TimeUtils = TimeUtils or {}
TimeUtils.DeltaTime = 0

function TimeUtils.Init(vSocketTime)
	TimeUtils.DeltaTime = MxTimeUtil.GetCurrentTime() - vSocketTime
end

function TimeUtils.GetSocketCurrentTime()
	return MxTimeUtil.GetCurrentTime() - TimeUtils.DeltaTime
end

function string.isNullOrEmpty(text)
	return text == nil or string.len(text) == 0
end

function string.formatAsHEX(vNum)
	return string.format("%X", vNum)
end

function string.ToLanguage(vID)
	return SqliteUtil.Instance:GetLanguage(vID)
end

function string.ToBool(str)
	return string.lower(str) == "true" and true or false
end

NumberUtil = NumberUtil or {
	PrefixHex = "0x"
}

function NumberUtil.numberByHexString(vHexString)
	if string.find(vHexString, NumberUtil.PrefixHex) then
		return tonumber(vHexString)
	else
		return tonumber(NumberUtil.PrefixHex .. vHexString)
	end
end

function printStringAsBytes(str)
	local ret = ""

	for i = 1, string.len(str) do
		ret = ret .. " " .. tostring(string.byte(str, i))
	end

	print(ret)
end

function callTableFuncs(tb, ...)
	if tb ~= nil then
		for k, v in pairs(tb) do
			v(k, ...)
		end
	end
end

function getNumberIntegralPlaces(number)
	if type(number) ~= "number" then
		return 0
	end

	local rstCount = 0
	local i, f = 1, 0

	while i >= 1 do
		i, f = math.modf(number / math.pow(10, rstCount))

		if i > 0 then
			rstCount = rstCount + 1
		end
	end

	return rstCount
end

function PrintTableWithColor(tbl, strColor)
	if type(tbl) ~= "table" then
		return
	end

	local str = "\n" .. "<color=" .. strColor .. ">" .. tostring(tbl) .. "</color>"

	print(str)
end

function PrintWithColor(strFormat, strColor, ...)
	if not strColor then
		UIUtil.PrintDebugError(strFormat)

		return
	end

	local info = debug.getinfo(2, "Sl")
	local source = info and info.source

	print("<color=cyan>(" .. source .. ":" .. info.currentline .. ")</color>\n" .. "<color=" .. strColor .. ">" .. tostring(strFormat) .. "</color>\n" .. string.format("<color=#00ff00>%s</color>", debug.traceback("")))
end

function table.GetKeyByPredicate(table, predicate)
	if table == nil then
		return nil
	end

	for k, v in pairs(table) do
		if predicate(v) then
			return k
		end
	end

	return nil
end

function chsize(char)
	if not char then
		print("not char")

		return 0
	elseif char > 240 then
		return 4
	elseif char > 225 then
		return 3
	elseif char > 192 then
		return 2
	else
		return 1
	end
end

function utf8len(str)
	local len = 0
	local currentIndex = 1

	while currentIndex <= #str do
		local char = string.byte(str, currentIndex)

		currentIndex = currentIndex + chsize(char)
		len = len + 1
	end

	return len
end

function utf8sub(str, startChar, numChars)
	local startIndex = 1

	while startChar > 1 do
		local char = string.byte(str, startIndex)

		startIndex = startIndex + chsize(char)
		startChar = startChar - 1
	end

	local currentIndex = startIndex

	while numChars > 0 and currentIndex <= #str do
		local char = string.byte(str, currentIndex)

		currentIndex = currentIndex + chsize(char)
		numChars = numChars - 1
	end

	return str:sub(startIndex, currentIndex - 1)
end

function test()
	assert(utf8len("你好1世界哈哈") == 7)
	assert(utf8len("你好世界1哈哈 ") == 8)
	assert(utf8len(" 你好世 界1哈哈") == 9)
	assert(utf8len("12345678") == 8)
	assert(utf8len("øpø你好pix") == 8)
	assert(utf8sub("你好1世界哈哈", 2, 5) == "好1世界哈")
	assert(utf8sub("1你好1世界哈哈", 2, 5) == "你好1世界")
	assert(utf8sub(" 你好1世界 哈哈", 2, 6) == "你好1世界 ")
	assert(utf8sub("你好世界1哈哈", 1, 5) == "你好世界1")
	assert(utf8sub("12345678", 3, 5) == "34567")
	assert(utf8sub("øpø你好pix", 2, 5) == "pø你好p")
	print("all test succ")
end

function GetNexMondyDay()
	local startTime = Mathf.Round(NetData:GetCurServerTime() / 1000)
	local startData = os.date("*t", startTime)
	local nowWeek = startData.wday - 1

	if nowWeek == 0 then
		nowWeek = 7
	end

	local apart = 8 - nowWeek

	return apart
end

function GetNowMondyTime()
	local startTime = Mathf.Round(NetData:GetCurServerTime() / 1000)
	local startData = os.date("*t", startTime)
	local nowWeek = startData.wday - 1

	if nowWeek == 0 then
		nowWeek = 7
	end

	local apart = nowWeek - 1
	local dayTimestamp = 86400
	local newTime = startTime - dayTimestamp * apart
	local newDate = os.date("*t", newTime)

	return os.time({
		hour = 4,
		second = 0,
		minute = 0,
		year = newDate.year,
		month = newDate.month,
		day = newDate.day
	}) * 1000
end

function TimeIsNotToday(time)
	if time ~= nil then
		local startTime = Mathf.Round(time / 1000)
		local startData = os.date("*t", startTime)
		local curTimeStamp = Mathf.Round(NetData:GetCurServerTime() / 1000)
		local today = os.date("*t", curTimeStamp)

		if startData.year ~= today.year or startData.month ~= today.month or startData.day ~= today.day then
			return true
		else
			return false
		end
	end

	print("error:input Time is nil!!!!!")

	return true
end

function TimeIsToday(time, baseHour)
	baseHour = baseHour or 4

	if time ~= nil then
		local curTimeStamp = Mathf.Round(NetData:GetCurServerTime() / 1000)
		local today = os.date("*t", curTimeStamp)

		time = tonumber(time) / 1000

		local st, et = 0, 0

		if today.hour >= 4 then
			st = os.time({
				second = 0,
				minute = 0,
				day = today.day,
				month = today.month,
				year = today.year,
				hour = baseHour
			})
			et = os.time({
				second = 0,
				minute = 0,
				day = today.day,
				month = today.month,
				year = today.year,
				hour = baseHour + 24
			})
		else
			st = os.time({
				second = 0,
				minute = 0,
				day = today.day,
				month = today.month,
				year = today.year,
				hour = baseHour - 24
			})
			et = os.time({
				second = 0,
				minute = 0,
				day = today.day,
				month = today.month,
				year = today.year,
				hour = baseHour
			})
		end

		return st <= time and time < et
	end

	return false
end

function TimeIsTodayKc(time)
	if time ~= nil then
		local curTimeStamp = Mathf.Round(NetData:GetCurServerTime() / 1000)
		local today = os.date("*t", curTimeStamp)

		time = tonumber(time) / 1000

		local st, et = 0, 0

		st = os.time({
			hour = 0,
			second = 0,
			minute = 0,
			day = today.day,
			month = today.month,
			year = today.year
		})
		et = os.time({
			hour = 24,
			second = 0,
			minute = 0,
			day = today.day,
			month = today.month,
			year = today.year
		})

		return st <= time and time < et
	end

	return false
end

function WhichDayFromStartTime(startTime, endTime)
	local startDate = os.date("*t", startTime)
	local startDateTime = os.time({
		hour = 0,
		second = 0,
		minute = 0,
		day = startDate.day,
		month = startDate.month,
		year = startDate.year
	})
	local endDate = os.date("*t", endTime)
	local endDateTime = os.time({
		hour = 24,
		second = 0,
		minute = 0,
		day = endDate.day,
		month = endDate.month,
		year = endDate.year
	})

	return (endDateTime - startDateTime) / 86400
end

function WhichDayOfWeek()
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local day = tonumber(os.date("%w", curServerTime))

	day = TenaryOp(day == 0, 7, day)

	return day
end

function WhichDayOfWeekWithRefresh()
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local day = tonumber(os.date("%w", curServerTime))

	day = TenaryOp(day == 0, 7, day)

	local hour = tonumber(os.date("%H", curServerTime))

	if hour < 4 then
		day = day - 1
		day = TenaryOp(day == 0, 7, day)
	end

	return day
end

function GetTimeFormatBySec(second)
	local d, v = math.modf(second / 86400)
	local h, v = math.modf(second / 3600)

	h = h - d * 24

	local y = second % 3600
	local m, v = math.modf(Mathf.Round(y) / 60)
	local s = second % 60

	s = Mathf.Round(s)
	s = s % 60

	return d, h, m, s
end

function LuaGC()
	local c = collectgarbage("count")

	collectgarbage("collect")

	c = collectgarbage("count")
end

function RemoveTableItem(list, item, removeAll)
	local rmCount = 0

	for i = 1, #list do
		if list[i - rmCount] == item then
			table.remove(list, i - rmCount)

			if removeAll then
				rmCount = rmCount + 1
			else
				break
			end
		end
	end
end

function IsNil(uobj)
	return uobj == nil or uobj:Equals(nil)
end

function GetListObjByIndex(arr, index)
	if index <= #arr then
		return arr[index]
	end

	return arr[1]
end

function isnan(number)
	return number ~= number
end

function string:split(sep)
	local sep, fields = sep or ",", {}
	local pattern = string.format("([^%s]+)", sep)

	if not self then
		return fields
	end

	self:gsub(pattern, function(c)
		table.insert(fields, c)
	end)

	return fields
end

function StringToTable(s)
	local tb = {}

	for utfChar in string.gmatch(s, "[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*") do
		table.insert(tb, utfChar)
	end

	return tb
end

function GetDir(path)
	return string.match(fullpath, ".*/")
end

function GetFileName(path)
	return string.match(fullpath, ".*/(.*)")
end

function table.contains(table, element)
	if table == nil then
		return false
	end

	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end

	return false
end

function table:getCount()
	local count = 0

	for k, v in pairs(self) do
		count = count + 1
	end

	return count
end

function DumpTable(t)
	for k, v in pairs(t) do
		if v ~= nil then
			Debugger.Log("Key: {0}, Value: {1}", tostring(k), tostring(v))
		else
			Debugger.Log("Key: {0}, Value nil", tostring(k))
		end
	end
end

function PrintTable(tab)
	local str = {}

	local function internal(tab, str, indent)
		for k, v in pairs(tab) do
			if type(v) == "table" then
				table.insert(str, indent .. tostring(k) .. ":\n")
				internal(v, str, indent .. " ")
			else
				table.insert(str, indent .. tostring(k) .. ": " .. tostring(v) .. "\n")
			end
		end
	end

	internal(tab, str, "")

	return table.concat(str, "")
end

function PrintLua(name, lib)
	local m

	lib = lib or _G

	for w in string.gmatch(name, "%w+") do
		lib = lib[w]
	end

	m = lib

	if m == nil then
		Debugger.Log("Lua Module {0} not exists", name)

		return
	end

	Debugger.Log("-----------------Dump Table {0}-----------------", name)

	if type(m) == "table" then
		for k, v in pairs(m) do
			Debugger.Log("Key: {0}, Value: {1}", k, tostring(v))
		end
	end

	local meta = getmetatable(m)

	Debugger.Log("-----------------Dump meta {0}-----------------", name)

	while meta ~= nil and meta ~= m do
		for k, v in pairs(meta) do
			if k ~= nil then
				Debugger.Log("Key: {0}, Value: {1}", tostring(k), tostring(v))
			end
		end

		meta = getmetatable(meta)
	end

	Debugger.Log("-----------------Dump meta Over-----------------")
	Debugger.Log("-----------------Dump Table Over-----------------")
end

function trim(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function IndexOf(pT, pV)
	for k, v in pairs(pT) do
		if v == pV then
			return k
		end
	end
end

function IndexAndKeyOf(pT, pKey, pV)
	for k, v in pairs(pT) do
		if v[pKey] == pV then
			return k
		end
	end
end

COUNTY_CODE = AppConst.Language

local _LocaleText = require("luaData/Language")

function Lang(id)
	local strVal = LanguageMgr.GetText(id)

	if strVal then
		strVal = string.gsub(strVal, "\\n", "\n")

		return strVal
	else
		return id
	end
end

function Localization(key)
	local strVal = LanguageMgr.Localization(key)

	if strVal then
		strVal = string.gsub(strVal, "\\n", "\n")

		return strVal
	else
		return key
	end

	return strVal
end

function LocalizeIdThenKey(keyOrId)
	if tonumber(keyOrId) ~= nil and _LocaleText[keyOrId] ~= nil then
		return Lang(keyOrId)
	else
		return _(keyOrId)
	end
end

local _TermsData = {}

function InitTermsData()
	_TermsData = require("luaData/Terms")

	for _, v in pairs(_TermsData) do
		print("TermsData" .. v.Key)

		if v.Key ~= "" then
			_TermsData[v.Key] = v
		end
	end
end

function GetTermsText(key)
	if not _TermsData[key] then
		print("<color=red>not find terms key:</color>" .. key)

		return 0
	end

	local strVal = _TermsData[key].Value

	return string.gsub(strVal, "\\n", "\n")
end

local ConfigData = require("luaData/Config")

function InitConfig()
	local list = {}

	for k, v in pairs(ConfigData) do
		list[v.Key] = v
	end

	ConfigData = list
end

InitConfig()

function GetConfigArgInt(key)
	if not ConfigData[key] then
		print("<color=red>not find config key:</color>" .. key)

		return 0
	end

	return ConfigData[key].ArgInt
end

function GetConfigArgFloat(key)
	if not ConfigData[key] then
		print("<color=red>not find config key:</color>" .. key)

		return 0
	end

	return ConfigData[key].ArgFloat
end

function GetConfigArgString(key)
	if not ConfigData[key] then
		print("<color=red>not find config key:</color>" .. key)

		return 0
	end

	return ConfigData[key].ArgString
end

function GetConfigArgJson(key)
	if not ConfigData[key] then
		print("<color=red>not find config key:</color>" .. key)

		return 0
	end

	return ConfigData[key].ArgJson
end

function DeepCopy(object)
	local lookup_table = {}

	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end

		local new_table = {}

		lookup_table[object] = new_table

		for index, value in pairs(object) do
			new_table[_copy(index)] = _copy(value)
		end

		return setmetatable(new_table, getmetatable(object))
	end

	return _copy(object)
end

function TableClone(object)
	local function copy(org, res)
		for k, v in pairs(org) do
			if type(v) ~= "table" then
				res[k] = v
			else
				res[k] = {}

				copy(v, res[k])
			end
		end
	end

	local res = {}

	copy(object, res)

	return res
end

function TenaryOp(condition, val1, val2)
	if condition then
		return val1
	else
		return val2
	end
end

function Tenary(val1, val2)
	if val1 then
		return val1
	else
		return val2
	end
end

function CompareBool(a, b)
	if a and not b then
		return true
	else
		return false
	end
end

function Shuffle(t)
	if type(t) ~= "table" then
		return
	end

	local tab = {}
	local index = 1

	while #t ~= 0 do
		local n = math.random(0, #t)

		if t[n] ~= nil then
			tab[index] = t[n]

			table.remove(t, n)

			index = index + 1
		end
	end

	return tab
end

function TableConcat(...)
	local t = {}

	for _, tab in ipairs({
		...
	}) do
		if type(tab) == "table" then
			for _, element in ipairs(tab) do
				t[#t + 1] = element
			end
		end
	end

	return t
end

function ListToTable(CSharpList)
	local list = {}

	if CSharpList then
		local index = 1
		local iter = CSharpList:GetEnumerator()

		while iter:MoveNext() do
			local v = iter.Current

			list[index] = v
			index = index + 1
		end
	else
		logError("Error,CSharpList is null")
	end

	return list
end

function ChangeBoolToNumber(bool)
	if bool then
		return 1
	end

	return 0
end

function GetPreciseDecimal(num, n)
	if type(num) ~= "number" then
		return num
	end

	n = math.floor(n or 0)
	n = TenaryOp(n < 0, 0, n)

	local decimal = 10^n
	local temp = math.floor(num * decimal)

	return temp / decimal
end

function SafeExecute(callback, onError)
	print(type(onError))

	if type(onError) == "function" then
		xpcall(callback, onError)
	elseif onError == 1 then
		xpcall(callback, function(err)
			Launcher.Instance:Restart()
		end)
	elseif onError == 2 then
		print(222)
		xpcall(callback, function(err)
			print(err)
			Launcher.Instance:DataRepairLight()
		end)
	end
end
