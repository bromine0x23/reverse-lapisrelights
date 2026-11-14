-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/Enum.lua

function enum(tbl)
	local ret = {}

	for i, v in ipairs(tbl) do
		ret[v] = v
	end

	setmetatable(ret, ret)

	function ret.safeindex(t, k)
		t.__index = nil

		local tmp = t[k]

		t.__index = t.safeindex

		assert(tmp)

		return tmp
	end

	ret.__index = ret.safeindex

	return ret
end

function numEnumWithStartNum(tbl, startNum)
	local ret = {}

	for i, v in ipairs(tbl) do
		ret[v] = i + startNum - 1
		i = i + 1
	end

	setmetatable(ret, ret)

	function ret.safeindex(t, k)
		t.__index = nil

		local tmp = t[k]

		t.__index = t.safeindex

		assert(tmp)

		return tmp
	end

	ret.__index = ret.safeindex

	return ret
end

function numEnum(tbl)
	return numEnumWithStartNum(tbl, 0)
end

function printTable(tbl)
	for k, v in pairs(tbl) do
		print(k, v)
	end
end

function iff(c, a, b)
	if c == true then
		return a
	else
		return b
	end
end
