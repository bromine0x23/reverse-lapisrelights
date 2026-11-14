-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/EasyFilter.lua

local table = table
local table_insert = table.insert
local table_sort = table.sort
local math = math
local math_random = math.random
local ipairs = ipairs

EasyFilter = class("EasyFilter")

function EasyFilter:ctor(list)
	self.filters = {}
	self.sorter = {}
	self.src = list
end

function EasyFilter:Purge()
	self.filters = nil
	self.sorter = nil
	self.src = nil
end

function EasyFilter:Reset(f)
	self.filters = {}
	self.sorter = {}

	return self
end

function EasyFilter:AddFilter(f)
	table_insert(self.filters, f)

	return self
end

function EasyFilter:do_filter(u)
	for i = 1, #self.filters do
		local filter = self.filters[i]

		if not filter(u) then
			return false
		end
	end

	return true
end

function EasyFilter:Equal(argName, filterVal)
	return self:AddFilter(function(dest)
		return dest[argName] == filterVal
	end)
end

function EasyFilter:NotEqual(argName, filterVal)
	return self:AddFilter(function(dest)
		return dest[argName] ~= filterVal
	end)
end

function EasyFilter:AddSorter(f)
	table_insert(self.sorter, f)

	return self
end

function EasyFilter:do_sorter(_list)
	for i = 1, #self.sorter do
		local sorter = self.sorter[i]

		table_sort(_list, sorter)
	end

	return _list
end

function EasyFilter:SortMax(argName)
	return self:AddSorter(function(a, b)
		return a[argName] > b[argName]
	end)
end

function EasyFilter:SortMin(argName)
	return self:AddSorter(function(a, b)
		return a[argName] < b[argName]
	end)
end

function EasyFilter:Get()
	local units = {}

	for i, u in ipairs(self.src) do
		if self:do_filter(u) then
			table.insert(units, u)
		end
	end

	self:do_sorter(units)

	return units
end

function EasyFilter:Random()
	local g = self:Get()

	if #g > 0 then
		return g[math_random(1, #g)]
	end
end

function EasyFilter:Ipairs()
	return ipairs(self:Get())
end

return EasyFilter
