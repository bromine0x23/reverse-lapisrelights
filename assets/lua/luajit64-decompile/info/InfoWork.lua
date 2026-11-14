-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoWork.lua

local WorkData = require("luaData/Work")
local AbilityData = require("luaData/WorkAbility")
local RequireData = require("luaData/WorkRequire")
local RewardPack = require("luaData/RewardPack")

InfoWork = class("InfoWork", InfoBase)
InfoWork.workId = 1
InfoWork.data = nil
eWorkType = {
	Common = 2,
	Daily = 1,
	Paid = 3
}
eWorkStateType = {
	Picked = 1,
	Completed = 2,
	Unbuyed = 3,
	Normal = 0
}
eWorkTypeColor = {
	{
		Color1 = "D1DCE1",
		Color2 = "619DB1"
	},
	{
		Color1 = "D8D9E7",
		Color2 = "9B9BCD"
	},
	{
		Color1 = "E1DAE3",
		Color2 = "AA96CD"
	}
}

function InfoWork:ctor(pb)
	self.workId = pb.workId
	self.data = WorkData[self.workId] or WorkData[1001]
	self.baseReward = RewardPack[self.data.BaseReward].PackItem
	self.extraReward = RewardPack[self.data.SuccessReward].PackItem

	local function fun(award)
		if next(award) == nil then
			award = {
				{
					501,
					0
				}
			}
		end

		return award
	end

	self.baseReward = fun(self.baseReward)
	self.extraReward = fun(self.extraReward)
	self.tempData = {}

	self:ResetTempData()
	self:UpdateWorkAllCondition()

	self.pb = {}

	self:SetData(pb)
end

function InfoWork:SetData(pb)
	self.pb.id = tonumber(pb.id)
	self.pb.state = pb.state
	self.pb.successRatio = pb.successRatio
	self.pb.awardMultiple = pb.awardMultiple
	self.pb.endTime = tonumber(pb.endAt)
	self.pb.roleCardIds = pb.roleCardIds
	self.pb.beginTime = tonumber(pb.beginAt)
end

function InfoWork:GetName()
	return Lang(self.data.Name)
end

function InfoWork:GetDesc()
	return Lang(self.data.Info)
end

function InfoWork:UpdateWorkAllCondition()
	self.listSpecial = {}

	local function func(list)
		for _, v in ipairs(list) do
			table.insert(self.listSpecial, v)
		end
	end

	self:UpdateWorkAbility()
	func(self.listCardAbility)
	self:UpdateWorkRequire()
	func(self.listCardRequire)
end

function InfoWork:UpdateWorkAbility()
	self.listCardAbility = {}

	local function func(list)
		for _, v in ipairs(list) do
			local infoSpe = AbilityData[v[1]]
			local temp = {
				need = 1,
				info = infoSpe,
				rate = v[2]
			}

			table.insert(self.listCardAbility, temp)
		end
	end

	func(self.data.GroupLimit)
	func(self.data.GroupLimit2)
end

function InfoWork:UpdateWorkRequire()
	self.listCardRequire = {}

	for i = 1, 5 do
		local listSingle = self:GetTypeCondition(i)

		for _, v in ipairs(listSingle) do
			table.insert(self.listCardRequire, v)
		end
	end
end

function InfoWork:GetCardPropertyData(proType)
	if proType == 1 then
		return self.data.JobLimit
	elseif proType == 2 then
		return self.data.RoleLimit
	elseif proType == 3 then
		return self.data.CardLevelLimit
	elseif proType == 4 then
		return self.data.CardStarLimit
	elseif proType == 5 then
		return self.data.CardRankLimit
	end

	return nil
end

function InfoWork:GetTypeCondition(proType)
	local list = {}
	local limit = self:GetCardPropertyData(proType)

	if #limit > 0 then
		local function func(id, rate)
			local info = RequireData[id]

			if info then
				local temp = {
					info = info,
					rate = rate,
					need = proType == 2 and 1 or info.Value[1]
				}

				table.insert(list, temp)
			end
		end

		if proType == 1 or proType == 2 then
			for i = 1, #limit do
				func(limit[i][1], limit[i][2])
			end
		else
			func(limit[1], limit[2])
		end
	end

	return list
end

function InfoWork:IsComplete()
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local endTime = self.pb.endTime

	if curServerTime >= tonumber(endTime) then
		return true
	end

	return false
end

function InfoWork:IsBelongToday()
	if self.pb.state == eWorkStateType.Picked then
		local duration = self.data.WorkTime * DateUtil.SecsPerMinute
		local endTime = self.pb.endTime
		local startTime = endTime - duration

		return TimeIsToday(startTime)
	end

	return true
end

function InfoWork:ResetTempData()
	self.tempData.cardIds = {}

	for i = 1, self.data.PlayerNumber do
		self.tempData.cardIds[i] = 0
	end

	self.tempData.double = false
end

function InfoWork:SetTempData(cardIds, double)
	if cardIds ~= nil then
		self.tempData.cardIds = cardIds
	end

	if double ~= nil then
		self.tempData.double = double
	end
end

function InfoWork:IsTempChange()
	local changeCard = false

	for _, v in ipairs(self.tempData.cardIds) do
		if v ~= 0 then
			changeCard = true

			break
		end
	end

	return changeCard or self.tempData.double
end

WorkMgr = {}
WorkMgr.listWork = {}
WorkMgr.Requested = false
WorkMgr.WorkIdx = 0

local limitComNum = GetConfigArgJson("WorkTaskAmount")[1]
local limitDayNum = GetConfigArgJson("WorkTaskAmount")[2]
local limitPayNum = GetConfigArgJson("WorkTaskAmount")[3]

WorkMgr.dailyCommonNum = 0
WorkMgr.dailyPayNum = 0

function WorkMgr:Clear()
	self.listWork = {}
end

function WorkMgr:SetData(pb)
	if #pb.works > 0 then
		self:Clear()
	end

	for i = 1, #pb.works do
		self:AddWork(pb.works[i])
	end

	self.dailyCommonNum = pb.dailyCommonNum
	self.dailyPayNum = pb.dailyPayNum

	WorkRDL.Init()
	ReTimeMgr:GetWorkNextRefreshTime()
end

function WorkMgr:AddWork(pbWork)
	local infoWork = InfoWork(pbWork)

	if infoWork.data ~= nil then
		table.insert(self.listWork, infoWork)
	end
end

function WorkMgr:RemoveWork(id)
	id = tonumber(id or 0)

	for k, v in ipairs(self.listWork) do
		if v.pb.id == id then
			table.remove(self.listWork, k)

			return
		end
	end
end

function WorkMgr:ConverWork(pbWork)
	local infoWork = self:GetWorkBySerialId(tonumber(pbWork.id))

	infoWork:ResetTempData()
	infoWork:SetData(pbWork)
end

function WorkMgr:GetWorkBySerialId(serialId)
	serialId = tonumber(serialId or 0)

	for _, v in pairs(self.listWork) do
		if v.pb.id == serialId then
			return v
		end
	end

	return nil
end

function WorkMgr:GetWorkListByState(state)
	local list = {}

	for _, v in ipairs(self.listWork) do
		if v.pb.state == state then
			table.insert(list, v)
		end
	end

	table.sort(list, function(a, b)
		return a.data.Type < b.data.Type
	end)

	return list
end

function WorkMgr:GroupingPaidToday()
	local listPaid = {}

	for _, v in ipairs(self.listWork) do
		if v.data.Type == eWorkType.Paid and v:IsBelongToday() then
			table.insert(listPaid, v)
		end
	end

	table.sort(listPaid, function(a, b)
		return a.pb.id < b.pb.id
	end)

	local groupCnt = math.ceil(#listPaid / 3)
	local temp = {}

	for i = 1, groupCnt do
		temp[i] = {}

		for k, v in ipairs(listPaid) do
			if k <= i * 3 then
				table.insert(temp[i], v)
			end
		end
	end

	return temp
end

function WorkMgr:GetPaidWorksToday()
	local groups = self:GroupingPaidToday()

	for _, v in ipairs(groups) do
		for _, n in ipairs(v) do
			if n.pb.state == eWorkStateType.Unbuyed then
				return v
			end
		end
	end

	return {}
end

function WorkMgr:ChangeComWorkNum(num)
	self.dailyCommonNum = self.dailyPayNum + num
end

function WorkMgr:ChangePayWorkNum(num)
	self.dailyPayNum = self.dailyPayNum + num
end

function WorkMgr:ChangeWorkState(serialId, state)
	serialId = tonumber(serialId or 0)

	local infoWork = self:GetWorkBySerialId(serialId)

	if infoWork then
		infoWork.pb.state = state
	end
end

function WorkMgr.ChangeWorkCreateTime(serialId, _time)
	serialId = tonumber(serialId or 0)

	local infoWork = WorkMgr:GetWorkBySerialId(serialId)

	if infoWork then
		infoWork.pb.beginTime = _time
	end
end

function WorkMgr:CanBuyWork()
	local isHavePay = false

	for _, v in pairs(self.listWork) do
		if v.data.Type == eWorkType.Paid and (v.pb.state == eWorkStateType.Normal or v.pb.state == eWorkStateType.Picked) then
			return false
		end
	end

	local list = self:GetPaidWorksToday()

	for _, v in pairs(list) do
		if v.pb.state == eWorkStateType.Unbuyed then
			return true
		end
	end

	return false
end

function WorkMgr:GetListCanWorkCard()
	local listWorkingCard = {}
	local listWorking = self:GetWorkListByState(eWorkStateType.Picked)

	for _, v in pairs(listWorking) do
		for _, n in pairs(v.pb.roleCardIds) do
			table.insert(listWorkingCard, n)
		end
	end

	local list = {}
	local allHoldCard = RoleCardMgr:GetAllHoldCard()

	for _, v in ipairs(allHoldCard) do
		local isHave = false

		for _, n in pairs(listWorkingCard) do
			if v.id == n then
				isHave = true

				break
			end
		end

		if not isHave then
			table.insert(list, v)
		end
	end

	return list
end

function WorkMgr:GetSumRate(infoWork, listCardId)
	local rate, sumRate = 0, 0
	local listSpe = infoWork.listSpecial

	for i = 1, #listCardId do
		rate = TenaryOp(listCardId[i] ~= 0, rate + infoWork.data.RoleAdd, rate)
	end

	local sumRate = infoWork.data.BaseRate + rate

	for i = 1, #listSpe do
		local flag = self:GetConditionIsMet(listSpe[i].info, listCardId)

		sumRate = TenaryOp(flag, sumRate + listSpe[i].rate, sumRate)
	end

	sumRate = TenaryOp(sumRate > 100, 100, TenaryOp(sumRate < 0, 0, sumRate))

	return sumRate
end

function WorkMgr:SortCard(infoWork)
	local listCon = infoWork.listSpecial
	local rate = 0

	for _, v in pairs(listCon) do
		rate = rate + v.rate
	end

	local listAbiCon = infoWork.listCardAbility
	local listReqCon = infoWork.listCardRequire
	local listCard = self:GetListCanWorkCard()
	local list = {}

	for _, v in pairs(listCard) do
		local temp = {
			num = 0,
			wei = 0,
			cardId = v.id,
			info = {}
		}

		for _, i in pairs(listAbiCon) do
			local abi = v.data.AbilityList

			for _, id in pairs(abi) do
				if i.info.ID == id then
					temp.wei = temp.wei + i.rate / rate * 100
					temp.num = temp.num + 1

					table.insert(temp.info, i.info)
				end
			end
		end

		for _, j in pairs(listReqCon) do
			if j.info.Type == 2 then
				local roleId = v.data.CharacterID

				if j.info.Value[1] == roleId then
					temp.wei = temp.wei + j.rate / rate * 100
					temp.num = temp.num + 1

					table.insert(temp.info, j.info)
				end
			else
				local extra, isFull

				if j.info.Type == 1 then
					isFull = j.info.Value[2] == GetJobType(RoleCardMgr:GetRole(v.id).data.Job)
				elseif j.info.Type == 3 then
					isFull = j.info.Value[2] <= v.curLevel
				elseif j.info.Type == 4 then
					isFull = j.info.Value[2] <= v.curStarLevel
				elseif j.info.Type == 5 then
					isFull = j.info.Value[2] == v.cardRank
				end

				if isFull then
					temp.wei = temp.wei + j.rate / rate * 100 / j.info.Value[1]
					temp.num = temp.num + 1

					table.insert(temp.info, j.info)
				end
			end
		end

		table.insert(list, temp)
	end

	local function fun(a, b)
		if a.wei == b.wei then
			return a.num < b.num
		else
			return a.wei > b.wei
		end
	end

	table.sort(list, fun)

	return list
end

function WorkMgr:GetConditionIsMet(infoSpe, listCardId)
	if #listCardId == 0 then
		return false, 0
	end

	local proType = 0
	local num = 0
	local value = 0

	if infoSpe.Type then
		proType = infoSpe.Type

		if proType == 2 then
			value = infoSpe.Value[1]
		else
			num = infoSpe.Value[1]
			value = infoSpe.Value[2]
		end
	end

	local sum = 0

	for i = 1, #listCardId do
		if listCardId[i] ~= 0 then
			local infoRoleCard = RoleCardMgr:GetRoleCard(listCardId[i])
			local roleId = RoleCardMgr:GetRoleId(listCardId[i])
			local infoRole = RoleMgr:GetRole(roleId)

			if proType == 0 then
				for j = 1, #infoRoleCard.data.AbilityList do
					if infoSpe.ID == infoRoleCard.data.AbilityList[j] then
						return true
					end
				end
			elseif proType == 1 then
				if infoRole.job == value then
					sum = sum + 1
				end
			elseif proType == 2 then
				if roleId == value then
					return true
				end
			elseif proType == 3 then
				if value <= infoRoleCard.curLevel then
					sum = sum + 1
				end
			elseif proType == 4 then
				if value <= infoRoleCard.curStarLevel then
					sum = sum + 1
				end
			elseif proType == 5 and infoRoleCard.cardRank == value then
				sum = sum + 1
			end
		end
	end

	if num <= sum and proType ~= 2 and proType ~= 0 then
		return true
	end

	return false, sum
end

function WorkMgr:HavePickedWork()
	local list = self:GetWorkListByState(1)

	return #list > 0
end

function WorkMgr:HaveCompletedWork()
	local list = self:GetWorkListByState(1)

	for _, v in pairs(list) do
		if v:IsComplete() then
			return true
		end
	end

	return false
end

function WorkMgr:UpdateWorkDot()
	local hasDot = DotMgr:HasDot(ePSKey.Dot_WORK)

	if not hasDot then
		if self:HaveCompletedWork() then
			DotMgr:Update(ePSKey.Dot_WORK, {
				isShow = true
			})
		end
	elseif not self:HaveCompletedWork() then
		DotMgr:Update(ePSKey.Dot_WORK, {
			isShow = false
		})
	end
end

function WorkMgr:GetWorkTimes()
	local now = 0
	local all = 0

	for key, value in pairs(GetConfigArgJson("WorkTaskAmount")) do
		all = all + value
	end

	for key, value in pairs(self.listWork) do
		if value.pb.state ~= 2 and value.pb.state ~= 1 then
			now = now + 1
		end
	end

	return now, all
end
