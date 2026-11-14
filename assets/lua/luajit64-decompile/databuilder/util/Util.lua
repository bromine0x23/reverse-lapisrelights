-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/DataBuilder/Util/Util.lua

local config = ConfigTable.Config

function GetConfigArgInt(key)
	if not config[key] then
		return 0
	end

	return config[key].ArgInt
end

function GetConfigArgFloat(key)
	if not config[key] then
		return 0
	end

	return config[key].ArgFloat
end

function GetConfigArgJson(key)
	if not config[key] then
		return 0
	end

	return config[key].ArgJson
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

function Tenary(val1, val2)
	if val1 then
		return val1
	else
		return val2
	end
end

function TenaryOp(condition, val1, val2)
	if condition then
		return val1
	else
		return val2
	end
end
