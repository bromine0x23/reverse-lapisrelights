-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoShop.lua

local ShopData = require("luaData/ShopData")
local GoodsData = require("luaData/GoodsData")

eShopRefreshType = {
	Weekly = 2,
	Monthly = 3,
	Daily = 1,
	Termination = 4,
	None = 0
}
InfoProduct = class("InfoProduct", InfoBase)

function InfoProduct:ctor(id)
	self.id = id
	self.data = GoodsData[id]
	self.pb = {}
	self.endAt = 0
	self.awardAt = 0

	ShopManager.dictProduct:Set(self.id, self)
end

function InfoProduct:CanGetAward()
	if self.data.RewardRefreshType == 2 then
		local nowMonday = GetNowMondyTime()

		if nowMonday > tonumber(self.awardAt) then
			return true
		else
			return false
		end
	end

	return not TimeIsToday(self.awardAt, 4)
end

function InfoProduct:SetData(pbProduct)
	self.pb.id = pbProduct.id
	self.pb.myCount = pbProduct.myCount
	self.pb.firsted = pbProduct.firsted
end

function InfoProduct:GetCost()
	local value = 0

	if self.data.CostType == 1 then
		value = self.data.CostValue[1]
	else
		value = self.data.CostValue[2]
	end

	return value * (self.data.Discount / 100)
end

InfoShop = class("InfoShop", InfoBase)

function InfoShop:ctor(id)
	self.id = id
	self.data = ShopData[id]
	self.pb = {}
	self.listGood = {}

	ShopManager.dict:Set(self.id, self)
end

function InfoShop:SetData(pbShop)
	self.listGood = {}
	self.pb.shopId = pbShop.shopId
	self.pb.freshAt = tonumber(pbShop.freshAt)
	self.pb.goods = pbShop.goods

	for i = 1, #self.pb.goods do
		local pbProduct = self.pb.goods[i]
		local infoProduct = ShopManager:GetProduct(pbProduct.id)

		infoProduct:SetData(pbProduct)
		table.insert(self.listGood, infoProduct)
	end
end

ShopManager = {}
ShopManager.dict = ShopManager.dict or Record()
ShopManager.dictProduct = ShopManager.dictProduct or Record()
ShopManager.listAll = {}
ShopManager.listAllMonth = {}
ShopManager.listAllHoldMonth = {}
ShopManager.MonthPrivilegeFunc = {
	Func13 = 13,
	Func5 = 5,
	Func7 = 7,
	Func9 = 9,
	Func17 = 17,
	Func4 = 4,
	Func12 = 12,
	Func18 = 18,
	Func8 = 8,
	Func3 = 3,
	Func14 = 14,
	Func19 = 19,
	Func6 = 6,
	Func20 = 20,
	Func1 = 1,
	Func15 = 15,
	Func10 = 10,
	Func2 = 2,
	Func11 = 11,
	Func16 = 16
}
ShopManager.needAccDot = true

function ShopManager:Get(id)
	local ret = self.dict:GetValue(id)

	ret = ret or InfoShop(id)

	return ret
end

function ShopManager:GetProduct(id)
	local ret = self.dictProduct:GetValue(id)

	ret = ret or InfoProduct(id)

	return ret
end

tabMainType = {
	mark = 5,
	month = 4,
	charge = 1,
	item = 2,
	exchange = 3,
	package = 6
}

function ShopManager:GetList(tabMainType)
	return
end

function ShopManager:UpdateDot()
	local isNew = false

	for i = 1, #self.listAll do
		local listType = self.listAll[i]

		if listType == nil then
			break
		end

		local hasSecondTag = 0

		for j = 1, #listType do
			local infoShop = listType[j]
			local listGood = infoShop.listGood

			for n = 1, #listGood do
				local info = listGood[n]

				if info == nil then
					break
				end

				if info.data == nil then
					break
				end

				local discount = info.data.Discount
				local costValue = info.data.CostValue
				local isFree = false

				if info.data.Discount == 100 then
					if info.data.CostType == 1 then
						if costValue[1] == 0 then
							isFree = true
						end
					elseif costValue[2] == 0 then
						isFree = true
					end
				elseif info.data.CostType == 1 then
					local cost2 = math.floor(costValue[1] * (discount / 100))

					if tonumber(cost2) == 0 then
						isFree = true
					end
				else
					local cost2 = math.floor(costValue[2] * (discount / 100))

					if tonumber(cost2) == 0 then
						isFree = true
					end
				end

				if isFree and info.pb.myCount <= 0 then
					isNew = true
					hasSecondTag = i
				end
			end
		end

		if i == tabMainType.month and self:HasDotInTabMain(tabMainType.month) then
			isNew = true
			hasSecondTag = i
		end

		DotMgr:Update(ePSKey.Dot_SHOP, {
			isShow = hasSecondTag ~= 0,
			secondTag = i
		})
	end

	if self:CheckAccDot() then
		isNew = true
	end

	DotMgr:Update(ePSKey.Dot_SHOP, {
		isNew = isNew
	})
end

function ShopManager:SetData(pb)
	self.listAll = {}
	self.listAllIndex = {}
	self.listAllType = {}

	for i = 1, #pb.shopTab do
		local pbShop = pb.shopTab[i]
		local shopId = pbShop.shopId
		local infoShop = ShopManager:Get(shopId)

		infoShop:SetData(pbShop)

		if infoShop.data then
			local type = infoShop.data.Type

			if infoShop.data.ShopCloseType == 1 then
				local isEmpty = true

				for k, v in pairs(infoShop.listGood) do
					if v.data.StoreNumber == -1 or v.pb.myCount < v.data.StoreNumber then
						isEmpty = false

						break
					end
				end

				if not isEmpty then
					self.listAll[type] = self.listAll[type] or {}

					table.insert(self.listAll[type], infoShop)

					self.listAllIndex[infoShop.data.TabIndex] = type
					self.listAllType[type] = infoShop.data.TabIndex
				end
			else
				self.listAll[type] = self.listAll[type] or {}

				table.insert(self.listAll[type], infoShop)

				self.listAllIndex[infoShop.data.TabIndex] = type
				self.listAllType[type] = infoShop.data.TabIndex
			end
		end
	end

	self.listAllMonth = {}

	for i = 1, #self.listAll[tabMainType.month] do
		table.insert(self.listAllMonth, self.listAll[tabMainType.month][i].listGood[1])
	end

	for i = 1, #pb.months do
		ShopManager:SetMonthData(pb.months[i])

		local pbMonth = pb.months[i]
		local info = ShopManager:GetProduct(pbMonth.goodsId)

		info.endAt = tonumber(pbMonth.endAt)
		info.awardAt = tonumber(pbMonth.awardAt)
	end

	local function sort(a, b)
		return a.data.SubTabIndex < b.data.SubTabIndex
	end

	for key, value in pairs(self.listAll) do
		table.sort(value, sort)
	end

	ShopRDL.Init()
end

function ShopManager:SetMonthDatas(listPbMonthCard)
	for i = 1, #listPbMonthCard do
		ShopManager:SetMonthData(listPbMonthCard[i])

		local pbMonth = listPbMonthCard[i]
		local info = ShopManager:GetProduct(pbMonth.goodsId)

		info.endAt = tonumber(pbMonth.endAt)
		info.awardAt = tonumber(pbMonth.awardAt)
	end
end

function ShopManager:SetMonthData(pbMonthCard)
	self.listAllMonth = self.listAllMonth or {}

	for i = 1, #self.listAllMonth do
		if self.listAllMonth[i].id == pbMonthCard.goodsId then
			self.listAllMonth[i].endAt = tonumber(pbMonthCard.endAt)
			self.listAllMonth[i].awardAt = tonumber(pbMonthCard.awardAt)
		end
	end

	local info = ShopManager:GetProduct(pbMonthCard.goodsId)

	info.endAt = tonumber(pbMonthCard.endAt)
	info.awardAt = tonumber(pbMonthCard.awardAt)
end

MONTH_CARD_S_ID = 40001
MONTH_CARD_B_ID = 40002

function ShopManager:IsGetMonthCard(goodsId)
	self.listAllMonth = self.listAllMonth or {}

	for i = 1, #self.listAllMonth do
		local info = self.listAllMonth[i]

		if info.endAt > 0 and not goodsId then
			return true
		end

		if info.endAt > 0 and info.id == goodsId then
			return true
		end

		if goodsId then
			local infoProduct = ShopManager:GetProduct(goodsId)

			for n = 1, #infoProduct.data.CombinationGoods do
				if info.endAt > 0 and info.id == infoProduct.data.CombinationGoods[n] then
					return true
				end
			end
		end
	end

	return false
end

function ShopManager:IsGetAnyMonthCard()
	if self:IsGetMonthCard(MONTH_CARD_S_ID) then
		return true
	end

	if self:IsGetMonthCard(MONTH_CARD_B_ID) then
		return true
	end

	return false
end

function ShopManager:CheckMonthBuff()
	self.listAllMonth = self.listAllMonth or {}

	for i = 1, #self.listAllMonth do
		local info = self.listAllMonth[i]

		if info.id == MONTH_CARD_B_ID and info.endAt > 0 then
			return true
		end
	end

	return false
end

function ShopManager:GetMonthCardMinTime()
	self.listAllMonth = self.listAllMonth or {}

	for i = 1, #self.listAllMonth do
		local info = self.listAllMonth[i]

		if info.id == MONTH_CARD_B_ID then
			return info.endAt
		end
	end

	return 0
end

function ShopManager:GetGrowthFund()
	for i = 1, #ShopManager.listAllHoldMonth do
		local info = ShopManager.listAllHoldMonth[i]

		if info.goodsId == 40005 then
			return true
		end
	end

	return false
end

function ShopManager:GetMonthIdState(monthID)
	local curTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	for i = 1, #ShopManager.listAllHoldMonth do
		if ShopManager.listAllHoldMonth[i] and ShopManager.listAllHoldMonth[i].goodsId == monthID and curTime < tonumber(ShopManager.listAllHoldMonth[i].endAt) then
			return true
		end
	end

	return false
end

function ShopManager:GetGoodsMonthPrivilegeFuncInfo(funcID)
	local GoodsMonthPrivilegeData = require("luaData/GoodsMonthPrivilege")
	local awardList = {}

	for _, v in pairs(GoodsMonthPrivilegeData) do
		if v and v.Func == funcID then
			table.insert(awardList, v)
		end
	end

	local info = {}

	for i = 1, #awardList do
		if awardList[i].GoodsId == MONTH_CARD_S_ID and ShopManager:GetMonthIdState(MONTH_CARD_S_ID) then
			table.insert(info, awardList[i])
		elseif awardList[i].GoodsId == MONTH_CARD_B_ID and ShopManager:GetMonthIdState(MONTH_CARD_B_ID) then
			table.insert(info, awardList[i])
		end
	end

	local IntValue = 0

	for i = 1, #info do
		IntValue = IntValue + info[i].IntValue
	end

	return info, IntValue
end

function ShopManager:GetMonthDataByFunc(funcID)
	local GoodsMonthPrivilegeData = require("luaData/GoodsMonthPrivilege")
	local awardList = {}

	for _, v in pairs(GoodsMonthPrivilegeData) do
		if v.Func == funcID then
			awardList[v.GoodsId] = v
		end
	end

	return awardList
end

function ShopManager:GetMonthDataByGoodsID(goodsID)
	local GoodsMonthPrivilegeData = require("luaData/GoodsMonthPrivilege")
	local awardList = {}

	for _, v in pairs(GoodsMonthPrivilegeData) do
		if v.GoodsId == goodsID then
			table.insert(awardList, v)
		end
	end

	return awardList
end

function ShopManager:GetCanBuyShopGood(itemId)
	if self.listAll == nil or self.listAll[tabMainType.item] == nil or self.listAll[tabMainType.item][1] == nil then
		return nil
	end

	local infoShop = self.listAll[tabMainType.item][1]
	local list = {}
	local listGood = infoShop.listGood

	for _, v in pairs(listGood) do
		if #v.data.GoodsItemList <= 1 then
			local id = v.data.GoodsItemList[1][1]

			if id == itemId then
				local limitNum = v.data.StoreNumber

				if limitNum ~= -1 then
					local buyNum = v.pb.myCount

					if buyNum < limitNum then
						table.insert(list, v)
					end
				else
					table.insert(list, v)
				end
			end
		end
	end

	local function funSort(a, b)
		if a.data.CostValue[2] == b.data.CostValue[2] then
			return a.data.ID < b.data.ID
		else
			return a.data.CostValue[2] < b.data.CostValue[2]
		end
	end

	table.sort(list, funSort)

	return list[1]
end

function ShopManager:HasDotInTabMain(index)
	local listShop = ShopManager.listAll[index]

	if listShop and index == tabMainType.month then
		for i = 1, #listShop do
			local infoShop = listShop[i]
			local infoProduct = ShopManager:GetProduct(infoShop.listGood[1].id)

			if infoProduct.id == 40005 and ShopManager:GetGrowthFund() and infoProduct:CanGetAward() then
				return true
			end

			if infoProduct.endAt > 0 and #infoProduct.data.RefreshAward > 0 and infoProduct:CanGetAward() then
				return true
			end
		end

		return false
	end
end

function ShopManager:CheckAccDot()
	local data = OperationActiveMgr.GetAccumulatedRechargeData()

	if data ~= nil then
		local infoOperationActive = OperationActiveMgr:Get(data.ID)

		if infoOperationActive ~= nil then
			local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
			local startTime = GetTimeTampByString(data.StartTime)
			local endTime = GetTimeTampByString(data.EndTime)

			if startTime <= curServerTime and curServerTime < endTime then
				local AllRecharge = Mathf.Floor(infoOperationActive.pb.record / 100)
				local RestNum = infoOperationActive.pb.resetTimes

				self.GetList = infoOperationActive.pb.awardRecords

				local data = infoOperationActive.data
				local NowGear = data.Params[RestNum + 1]
				local NowRecharge = AllRecharge

				for i = RestNum, 1, -1 do
					NowRecharge = NowRecharge - data.Params[RestNum][#data.Params[RestNum]]
				end

				for i = 1, #NowGear do
					if NowRecharge >= NowGear[i] and not self:IsGetReward(RestNum * #NowGear + i) then
						return true
					end
				end

				if ShopManager.needAccDot then
					if #data.Params - 1 - RestNum == 0 then
						return false
					end

					for i = 1, #NowGear do
						if not self:IsGetReward(RestNum * #NowGear + i) then
							return false
						end
					end

					return true
				end
			end
		end
	end

	return false
end

function ShopManager:IsGetReward(index)
	for key, value in pairs(self.GetList) do
		if value == index - 1 then
			return true
		end
	end

	return false
end

function ShopManager:FindTabIndexByType(type)
	local tabIndex = self.listAllType[type]

	if tabIndex ~= nil and tabIndex > 0 then
		return tabIndex
	else
		return 1
	end
end

function ShopManager:FindTypeByTabIndex(tabIndex)
	local type = self.listAllIndex[tabIndex]

	if type ~= nil and type > 0 then
		return type
	else
		return 1
	end
end
