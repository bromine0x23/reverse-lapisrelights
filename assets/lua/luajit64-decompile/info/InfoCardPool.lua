-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoCardPool.lua

local data = require("luaData/CardPool")
local m_block_cardpool = require("luaData/m_block_cardpool")

InfoCardPool = class("InfoCardPool", InfoBase)

function InfoCardPool:ctor(id)
	self.id = id
	self.data = data[id]
	self.usedTime = 0
	self.isFirst = 0

	local poolCheapCount = 1
	local monthData = ShopManager:GetMonthDataByFunc(ShopManager.MonthPrivilegeFunc.Func18)

	if self.data then
		for i, monthCardId in ipairs(self.data.MonthCardKey) do
			if ShopManager:GetMonthIdState(monthCardId) and monthData[monthCardId] then
				poolCheapCount = poolCheapCount + monthData[monthCardId].IntValue
			end
		end
	end

	self.lastCheap = poolCheapCount

	CardPoolManager.dict:Set(self.id, self)
end

function InfoCardPool:SetData(pb)
	self.usedTime = pb.times
	self.isFirst = pb.isFirst
	self.lastCheap = self.lastCheap - self.isFirst
end

function InfoCardPool:UpdateMonthCard()
	local poolCheapCount = 1
	local monthData = ShopManager:GetMonthDataByFunc(ShopManager.MonthPrivilegeFunc.Func18)

	if self.data then
		for i, monthCardId in ipairs(self.data.MonthCardKey) do
			if ShopManager:GetMonthIdState(monthCardId) and monthData[monthCardId] then
				poolCheapCount = poolCheapCount + monthData[monthCardId].IntValue
			end
		end
	end

	self.lastCheap = poolCheapCount - self.isFirst
end

eCardPoolActiveType = {
	ChoosePool = 2,
	StepUpPool = 1,
	ChooseCardPool = 3
}
CardPoolManager = {}
CardPoolManager.dict = CardPoolManager.dict or Record()
CardPoolManager.infoCardPool = nil
CardPoolManager.init = false

function CardPoolManager:Get(id)
	local ret = self.dict:GetValue(id)

	ret = ret or InfoCardPool(id)

	return ret
end

function CardPoolManager:GetAll()
	local list = {}
	local listActivePool = {}

	for k, v in pairs(data) do
		local id = v.ID
		local info = CardPoolManager:Get(id)
		local openTime, endTime

		if info.data.CreateAccountPoolTime ~= 0 then
			openTime = tonumber(PlayerInst.InfoPlayer:GetRegisterTime())
			endTime = tonumber(PlayerInst.InfoPlayer:GetRegisterTime()) + info.data.CreateAccountPoolTime * 3600
		else
			openTime = GetTimeTampByString(info.data.OpenTime)
			endTime = GetTimeTampByString(info.data.EndTime)
		end

		local curTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

		if info.data.PoolType == 2 and info.usedTime > 0 then
			-- block empty
		elseif self:CheckItemHaveSkip(info, curTime) then
			-- block empty
		elseif openTime <= curTime and curTime <= endTime or self:CheckItemHaveOpen(info) then
			if info.data.ActiveType ~= 0 then
				if info.data.ActiveType == eCardPoolActiveType.StepUpPool then
					if info.usedTime < info.data.DayMaxNum or info.needShow then
						if listActivePool[info.data.ActiveID] == nil then
							listActivePool[info.data.ActiveID] = info
						elseif listActivePool[info.data.ActiveID].data.StepUpOrder > info.data.StepUpOrder and info.usedTime < info.data.DayMaxNum and not info.needShow then
							listActivePool[info.data.ActiveID] = info
						elseif listActivePool[info.data.ActiveID].data.StepUpOrder < info.data.StepUpOrder and listActivePool[info.data.ActiveID].needShow then
							listActivePool[info.data.ActiveID] = info
						end
					end
				elseif info.data.ActiveType == eCardPoolActiveType.ChoosePool or info.data.ActiveType == eCardPoolActiveType.ChooseCardPool then
					if info.usedTime < info.data.DayMaxNum or info.needShow == true then
						if listActivePool[info.data.ActiveID] == nil then
							listActivePool[info.data.ActiveID] = info
						end
					else
						listActivePool[info.data.ActiveID] = {}
					end
				end
			elseif info.data.ResetType == 0 and info.usedTime >= info.data.DayMaxNum then
				if info.needShow == true then
					table.insert(list, info)
				end
			else
				table.insert(list, info)
			end
		end
	end

	for k, v in pairs(listActivePool) do
		if v.data then
			table.insert(list, v)
		end
	end

	table.sort(list, function(a, b)
		if a.data.TabOrder == b.data.TabOrder then
			return a.data.ID < b.data.ID
		end

		return a.data.TabOrder < b.data.TabOrder
	end)

	return list
end

function CardPoolManager:CheckItemHaveOpen(info)
	if info.data.ActiveType == eCardPoolActiveType.ChooseCardPool then
		if info.data.OneCost[1] and ItemManager:GetItemCount(info.data.OneCost[1]) >= info.data.OneCost[2] or info.data.TenCost[1] and ItemManager:GetItemCount(info.data.TenCost[1]) >= info.data.TenCost[2] or info.needShow then
			return true
		else
			return false
		end
	end

	return false
end

function CardPoolManager:CheckItemHaveSkip(info, curTime)
	local needSkip = false

	for _, v in pairs(m_block_cardpool) do
		if curTime >= GetTimeTampByString(v.start_time) and curTime <= GetTimeTampByString(v.end_time) and table.contains(v.block_card_pool_id, info.data.ID) then
			needSkip = ItemManager:GetItemCount(v.item_id) == v.number

			printTable({
				"-------",
				needSkip,
				curTime,
				{
					GetTimeTampByString(v.start_time),
					GetTimeTampByString(v.end_time)
				},
				v
			})

			if needSkip then
				break
			end
		end
	end

	return needSkip
end

function CardPoolManager:GetRateBuff(id, times)
	local result = 0
	local data = require("luaData/CardPoolBuff")

	if data[id] == nil then
		return result
	end

	local list = data[id].Param
	local index = 0

	for i = 1, #list do
		local d = list[i]

		if d and times + 1 >= d[1] then
			index = index + 1
		end
	end

	if index > 0 then
		for i = 1, index do
			local list2 = list[i]
			local r1 = list2[1]
			local r2 = list2[2]
			local add = list2[3]

			if r2 > times + 1 then
				r2 = times + 1
			end

			local r = r2 - r1 + 1

			for n = 1, r do
				result = result + add
			end
		end
	end

	return result
end

function CardPoolManager:GetRateBuffAdd(id, times)
	local result = 0
	local data = require("luaData/CardPoolBuff")

	if data[id] == nil then
		return result
	end

	local list = data[id].Param
	local index = 0

	for i = 1, #list do
		local d = list[i]

		if d and times + 1 >= d[1] then
			index = index + 1
		end
	end

	if index > 0 then
		return list[index][3]
	end

	return 0
end

function CardPoolManager:GetRateBuffMinNeedTimes(id)
	local data = require("luaData/CardPoolBuff")

	if data[id] == nil then
		return result
	end

	local list = data[id].Param

	return list[1][1]
end

function CardPoolManager:DailyUpdate()
	self.dict:Clear()

	self.init = false
end

function CardPoolManager:GetActivePoolList(activeID)
	local list = {}

	for k, v in pairs(data) do
		local id = v.ID
		local info = CardPoolManager:Get(id)

		if info.data.ActiveID == activeID then
			table.insert(list, info)
		end
	end

	table.sort(list, function(a, b)
		return a.data.StepUpOrder < b.data.StepUpOrder
	end)

	return list
end

function CardPoolManager:SortStepUpList(tmpList)
	local list = {}

	for k, v in pairs(tmpList) do
		if list[v.data.StepUpTurn] then
			table.insert(list[v.data.StepUpTurn], v)
		else
			list[v.data.StepUpTurn] = {}

			table.insert(list[v.data.StepUpTurn], v)
		end
	end

	for i, v in ipairs(list) do
		table.sort(v, function(a, b)
			return a.data.StepUpOrder < b.data.StepUpOrder
		end)
	end

	return list
end

function CardPoolManager:ResetNeedShow()
	for k, v in pairs(data) do
		local id = v.ID
		local info = CardPoolManager:Get(id)

		info.needShow = false
	end
end

function CardPoolManager:GetLimitTimeItemPoolList()
	local list = {}

	for k, v in pairs(data) do
		local poolData = v

		if poolData.ShopOpenTime ~= "" and poolData.ShopCloseTime ~= "" then
			local shopOpenTime = GetTimeTampByString(poolData.ShopOpenTime)
			local shopCloseTime = GetTimeTampByString(poolData.ShopCloseTime)
			local curTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

			if shopOpenTime <= curTime and curTime <= shopCloseTime and poolData.ScoreNum[1] then
				table.insert(list, {
					itemId = poolData.ScoreNum[1],
					time = shopCloseTime
				})
			end
		end
	end

	table.sort(list, function(a, b)
		return a.time < b.time
	end)

	return list
end

function CardPoolManager:SetTimeLimitItemData()
	for k, v in pairs(data) do
		if v.ShopOpenTime ~= "" and v.ShopCloseTime ~= "" then
			local itemData = ItemManager:Get(v.ScoreNum[1])

			itemData.clearTime = GetTimeTampByString(v.ShopCloseTime)
		end
	end
end
