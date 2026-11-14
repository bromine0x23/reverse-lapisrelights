-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/ObjectPool/Unit/UnitSelector.lua

local table = table
local table_insert = table.insert
local table_sort = table.sort
local math = math
local ipairs = ipairs
local mt = {}
local api = {}

mt.__index = api

function mt:__tostring()
	return "table: selector"
end

api.type = "selector"
api.filters = nil
api.is_allow_god = false
api.is_allow_dead = false
api.is_allow_guard = false

function api:add_filter(f)
	table_insert(self.filters, f)

	return self
end

function api:is_not(u)
	return self:add_filter(function(dest)
		return dest ~= u
	end)
end

function api:is_enemy(u)
	return self:add_filter(function(dest)
		return dest:is_enemy(u)
	end)
end

function api:is_ally(u)
	return self:add_filter(function(dest)
		return dest:is_ally(u)
	end)
end

function api:of_add(type_name)
	self.type_of[type_name] = true

	return self
end

function api:of_remove(type_name)
	self.type_of[type_name] = nil

	return self
end

function api:of_type(data)
	for i = 1, #data do
		data[data[i]] = true
	end

	self.type_of = data

	return self
end

function api:of_not(u)
	return self:add_filter(function(dest)
		return dest ~= u
	end)
end

function api:allow_dead()
	self.is_allow_dead = true

	return self
end

function api:do_filter(u)
	for i = 1, #self.filters do
		local filter = self.filters[i]

		if not filter(u) then
			return false
		end
	end

	return true
end

function api:set_sorter(f)
	self.sorter = f

	return self
end

function api:sort_weakest_hero()
	return self:set_sorter(function(u1, u2)
		if u1:get_type() == "英雄" and u2:get_type() ~= "英雄" then
			return true
		end

		if u1:get_type() ~= "英雄" and u2:get_type() == "英雄" then
			return false
		end

		if u1:hp_rate() < u2:hp_rate() then
			return true
		elseif u1:hp_rate() == u2:hp_rate() then
			return u1:hp() < u2:hp()
		else
			return false
		end
	end)
end

function api:get()
	local units = {}

	if self.group then
		for _, u in ipairs(self.group) do
			if self.type_of[u.UnitClass] and self:do_filter(u) then
				table_insert(units, u)
			end
		end
	end

	if self.sorter then
		table_sort(units, self.sorter)
	end

	return units
end

function api:random()
	local g = self:get()

	if #g > 0 then
		return g[GameLogic.RandomTool(1, #g)]
	end
end

function api:Get()
	local units = self:get()

	return units[1]
end

function api:GetRandom(num)
	if not num then
		return self:random()
	end

	local randmonUnits = self:get()
	local outs = {}

	for i = 1, num do
		local j = GameLogic.RandomToolInt(#randmonUnits)
		local random = randmonUnits[j]

		table.remove(randmonUnits, j)
		table.insert(outs, random)
	end

	return outs
end

function api:GetArray(num)
	if not num then
		return self:get()
	end

	local outs = {}

	for i, unit in ipairs(self:get()) do
		if i <= num then
			table.insert(outs, unit)
		end
	end

	return outs
end

function api:Ipairs()
	return ipairs(self:get())
end

function api:SetSortFun(fun)
	return self:set_sorter(fun)
end

function api:Alive()
	return self:add_filter(function(dest)
		return dest.IsDead == false
	end)
end

function api:NotZeroHp()
	return self:add_filter(function(dest)
		return dest:Get("生命") > 0
	end)
end

function api:NotStun()
	return self:add_filter(function(dest)
		return dest.IsStun == false
	end)
end

function api:Die()
	return self:add_filter(function(dest)
		return dest.IsDead == true
	end)
end

function api:Wave(wave)
	return self:add_filter(function(dest)
		return dest.Wave == wave
	end)
end

function api:Camp(camp)
	return self:add_filter(function(dest)
		return dest.Camp == camp
	end)
end

function api:NotCamp(camp)
	return self:add_filter(function(dest)
		return dest.Camp ~= camp
	end)
end

function api:Order(order)
	return self:add_filter(function(dest)
		return dest.Order == order
	end)
end

function api:IsUniqueId(uniqueId)
	return self:add_filter(function(dest)
		return dest.UniqueId == uniqueId
	end)
end

function api:IsNotUniqueId(uniqueId)
	return self:add_filter(function(dest)
		return dest.UniqueId ~= uniqueId
	end)
end

function api:HasBuff(types)
	return self:add_filter(function(dest)
		local hasBuff = false

		for i, buff in ipairs(dest.Buffs) do
			if hasBuff == true then
				break
			end

			for _, type in ipairs(types) do
				if buff.Type == type or buff.TypeOrder == type then
					hasBuff = true

					break
				end
			end
		end

		return hasBuff
	end)
end

function api:HasNotBuff(types)
	return self:add_filter(function(dest)
		local hasBuff = false

		for i, buff in ipairs(dest.Buffs) do
			if hasBuff == true then
				break
			end

			for _, type in ipairs(types) do
				if buff.Type == type or buff.TypeOrder == type then
					hasBuff = true

					break
				end
			end
		end

		return not hasBuff
	end)
end

function api:SortMin(attri)
	return self:set_sorter(function(a, b)
		return a:Get(attri) < b:Get(attri)
	end)
end

function api:SortMinSum(attri1, attri2)
	return self:set_sorter(function(a, b)
		return a:Get(attri1) + a:Get(attri2) < b:Get(attri1) + b:Get(attri2)
	end)
end

function api:SortMax(attri)
	return self:set_sorter(function(a, b)
		return a:Get(attri) > b:Get(attri)
	end)
end

function api:SortMaxSum(attri1, attri2)
	return self:set_sorter(function(a, b)
		return a:Get(attri1) + a:Get(attri2) > b:Get(attri1) + b:Get(attri2)
	end)
end

UnitSelector = GLClass("UnitSelector")

function UnitSelector:ctor(GL, m_SrcItems)
	self.GL = GL
	self.SrcItems = m_SrcItems
	self.SelectorType = {
		EnumFight.UnitClass.PLAYER,
		EnumFight.UnitClass.ENEMY,
		EnumFight.UnitClass.PVPPLAYER
	}
end

function UnitSelector:Start()
	local type = self.SelectorType
	local _api = {
		filters = {},
		type_of = {},
		group = self.SrcItems,
		GL = self.GL
	}

	if type then
		for i = 1, #type do
			_api.type_of[type[i]] = true
		end
	end

	return setmetatable(_api, mt)
end
