-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Util/Tool.lua

function DefineClass(anyTableOrNil)
	anyTableOrNil = anyTableOrNil or {}
	anyTableOrNil.__index = anyTableOrNil

	return anyTableOrNil
end

function InvokeBase(instObj, funcName, ...)
	local f = instObj._Base[funcName]

	if f then
		return f(instObj, unpack({
			...
		}))
	else
		return nil
	end
end

function DeriveClass(BaseClass, SubClass)
	SubClass = SubClass or {}

	setmetatable(SubClass, BaseClass)

	SubClass.__index = SubClass
	SubClass._Base = BaseClass
	SubClass._InvokeBase = InvokeBase

	return SubClass
end

function New(Class, t)
	t = t or {}

	setmetatable(t, Class)

	return t
end

function Sleep(timePar)
	local t0 = timePar
	local t1 = os.time()

	while true do
		local t2 = os.time()

		if t0 <= t2 - t1 then
			break
		end
	end
end

function GLLang(id)
	local _LocaleText = ConfigTable.Language

	if _LocaleText[id] == nil then
		return ""
	end

	return _LocaleText[id].Value
end

function WeightRandom(t, weights)
	local sum = 0

	for i = 1, #weights do
		sum = sum + weights[i]
	end

	local compareWeight = GameLogic.RandomTool(1, sum)
	local weightIndex = 1

	while sum > 0 do
		sum = sum - weights[weightIndex]

		if sum < compareWeight then
			return t[weightIndex]
		end

		weightIndex = weightIndex + 1
	end

	print("compare error, return nil")

	return nil
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

local ConfigData = ConfigTable.Config

local function InitConfig()
	local list = {}

	for k, v in pairs(ConfigData) do
		list[v.Key] = v
	end

	ConfigData = list
end

InitConfig()

function GLGetConfigArgInt(key)
	if not ConfigData[key] then
		print("<color=red>not find config key:</color>" .. key)

		return 0
	end

	return ConfigData[key].ArgInt
end

function GLGetConfigArgFloat(key)
	if not ConfigData[key] then
		print("<color=red>not find config key:</color>" .. key)

		return 0
	end

	return ConfigData[key].ArgFloat
end

function GLGetConfigArgJson(key)
	if not ConfigData[key] then
		print("<color=red>not find config key:</color>" .. key)

		return 0
	end

	return ConfigData[key].ArgJson
end
