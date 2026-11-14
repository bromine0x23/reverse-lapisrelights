-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoActive.lua

local ActiveData = require("luaData/ActiveData")

InfoActive = class("InfoActive", InfoBase)
eLoopType = {
	week = 2,
	day = 1
}
eActiveType = {
	boss = 3,
	timespace = 7,
	long = 1,
	asset = 2,
	unionRaid = 6,
	bossraid = 4
}
eActiveGroupType = {
	mate = 1,
	boss = 4,
	equip = 2,
	gift = 3
}

local eEquipActiveType = {
	breakOut = 2,
	intense = 1
}

eBossActiveType = {
	story = 2,
	boss = 3,
	normal = 1
}

function InfoActive:ctor(id)
	self.data = ActiveData[id]

	if self.data.Type == eActiveType.boss then
		self.normalChapterId = self.data.TypeValue[1][1]
		self.storyChapterId = self.data.TypeValue[2][1]
		self.bossChapterId = self.data.TypeValue[3][1]
	end
end

function InfoActive:GetMaxArgJson(index, type)
	index = index or 1

	local count = 0

	if InfoGameInst:GetChapterTimesList() then
		count = InfoGameInst:GetChapterTimesList()[type].buyTimes
	end

	return self.data.ArgJson[index] + count
end

function InfoActive:GetMaxArgJsonValue(index, type)
	index = index or 1

	local count = 0

	if InfoGameInst:GetChapterTimesList() then
		count = InfoGameInst:GetChapterTimesList()[type].buyTimes
	end

	return self.data.ArgJson[index]
end

function InfoActive:HaveDailyReward(bossAcType)
	if self.data.Type == eActiveType.boss then
		if bossAcType == eBossActiveType.normal then
			local rewardRate = self.data.DailyRewardRate[1]

			if rewardRate > 1 then
				local chapterId = self.data.TypeValue[1][1]
				local infoChapter = ChapterMgr:GetChapter(chapterId)
				local info, hignCount = ShopManager:GetGoodsMonthPrivilegeFuncInfo(ShopManager.MonthPrivilegeFunc.Func15)

				if infoChapter.pb.highAwardNum and infoChapter.pb.highAwardNum < hignCount + 1 then
					return true
				end
			end
		elseif bossAcType == eBossActiveType.boss then
			local rewardRate = self.data.DailyRewardRate[3]

			if rewardRate > 1 then
				local chapterId = self.data.TypeValue[3][1]
				local infoChapter = ChapterMgr:GetChapter(chapterId)
				local info, hignCount = ShopManager:GetGoodsMonthPrivilegeFuncInfo(ShopManager.MonthPrivilegeFunc.Func15)

				if infoChapter.pb.highAwardNum and infoChapter.pb.highAwardNum < hignCount + 1 then
					return true
				end
			end
		end

		return false
	else
		local index = WhichDayOfWeekWithRefresh()
		local rewardRate = self.data.DailyRewardRate[index]

		if rewardRate > 1 then
			local chapters = self.data.TypeValue[index]

			for i, chapterId in ipairs(chapters) do
				local infoChapter = ChapterMgr:GetChapter(chapterId)
				local info, hignCount = ShopManager:GetGoodsMonthPrivilegeFuncInfo(ShopManager.MonthPrivilegeFunc.Func15)

				if infoChapter.pb.highAwardNum and infoChapter.pb.highAwardNum < hignCount + 1 then
					return true
				end
			end
		end

		return false
	end
end

function InfoActive:GetOpenDay()
	local list = {}
	local listDay = self.data.TypeValue

	for i = 1, 7 do
		local day = listDay[i]

		if table.getn(day) ~= 0 then
			table.insert(list, i)
		end
	end

	return list
end

function InfoActive:TodayIsOpen()
	local day = WhichDayOfWeekWithRefresh()
	local list = self.data.TypeValue

	if table.getn(list[day]) == 0 then
		return false
	end

	return true
end

function InfoActive:GetOpenChapterToday()
	local day = WhichDayOfWeekWithRefresh()
	local listDayChapter = self.data.TypeValue
	local openChapter = listDayChapter[day]

	return openChapter
end

function InfoActive:IsShowOpen()
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local showStartTime = GetTimeTampByString(self.data.StartTime)
	local showEndTime = GetTimeTampByString(self.data.CloseTime)
	local msg
	local isShowStart = true

	if showStartTime ~= 0 and curServerTime < showStartTime then
		isShowStart = false
	end

	local isShowEnd = false

	if showEndTime ~= 0 and showEndTime <= curServerTime then
		isShowEnd = true
	end

	if not isShowStart or isShowEnd then
		msg = _("Msg_Active_UnLock")
	end

	return isShowStart and not isShowEnd, msg
end

function InfoActive:IsPlayOpen()
	local str
	local isStart, msgStart = self:IsStart()
	local isEnd, msgEnd = self:IsEnd()

	if isStart and not isEnd then
		return true
	else
		if not isStart then
			str = msgStart
		end

		if isEnd then
			str = msgEnd
		end
	end

	return false, str
end

function InfoActive:IsStart()
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local playStartTime = GetTimeTampByString(self.data.StartTime)

	if playStartTime ~= 0 and playStartTime <= curServerTime then
		return true
	end

	return false, self.data.StartTime
end

function InfoActive:IsEnd()
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local playEndTime = GetTimeTampByString(self.data.EndTime)
	local msg

	if playEndTime ~= 0 and playEndTime <= curServerTime then
		return true, _("Msg_Active_Over")
	end

	return false
end

function InfoActive:GetFirstStoryStage()
	self.infoActive = PageBossActivity.GetCurBossActive()

	local infoChapter = ChapterMgr:GetChapter(self.infoActive.storyChapterId)

	return infoChapter.data.InitStage[1]
end

ActiveMgr = {}
ActiveMgr.dict = ActiveMgr.dict or Record()
ActiveMgr.TabIndex = 1
ActiveMgr.branchId = 1
ActiveMgr.NewOpenBossStage = nil
ActiveMgr.NewOpenStory = nil

function ActiveMgr:GetActive(id)
	local ret = self.dict:GetValue(id)

	if not ret then
		ret = InfoActive(id)

		self.dict:Set(id, ret)
	end

	if ret.data == nil then
		print("请检查ActiveData表!" .. id)
	end

	return ret
end

function ActiveMgr:SetTimeLimitItemData()
	for k, v in pairs(ActiveData) do
		for i, itemId in ipairs(v.LimitItems) do
			local itemData = ItemManager:Get(itemId)

			itemData.clearTime = GetTimeTampByString(v.CloseTime)
		end
	end
end

function ActiveMgr:GetAllActive()
	local allActive = {}

	for k in pairsByKeys(ActiveData) do
		local infoActive = self:GetActive(k)

		if infoActive then
			table.insert(allActive, infoActive)
		end
	end

	return allActive
end

function ActiveMgr:GetActiveByType(_type)
	local allActive = {}

	for k, v in pairs(ActiveData) do
		local infoActive = self:GetActive(k)

		if infoActive.data.Type == _type then
			table.insert(allActive, infoActive)
		end
	end

	return allActive
end

function ActiveMgr:GetNextOpenActiveByType(_type)
	local serverTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	for k, v in pairs(ActiveData) do
		local infoActive = self:GetActive(k)

		if infoActive.data.Type == _type then
			local startTime = GetTimeTampByString(infoActive.data.StartTime)

			if serverTime < startTime then
				return infoActive
			end
		end
	end

	return nil
end

function ActiveMgr:GetOpenActiveByType(_type)
	local allActive = {}

	for k, v in pairs(ActiveData) do
		local infoActive = self:GetActive(k)

		if infoActive.data.Type == _type and infoActive:IsShowOpen() then
			table.insert(allActive, infoActive)
		end
	end

	return allActive
end

function ActiveMgr:GetActiveByActiveGroup(activeGroupType)
	local allActive = {}

	for k, v in pairsByKeys(ActiveData) do
		local infoActive = self:GetActive(k)

		if infoActive.data.ActiveGroup == activeGroupId then
			table.insert(allActive, infoActive)
		end
	end

	return allActive
end

function ActiveMgr:GetActiveChapter(activeId, index)
	local infoActive = self:GetActive(activeId)
	local chapterId = 0
	local day = WhichDayOfWeekWithRefresh()
	local list = infoActive.data.TypeValue
	local todayChapter = list[day]

	if not todayChapter or #todayChapter == 0 then
		for i = 1, #list do
			if #list[i] ~= 0 then
				todayChapter = list[i]

				break
			end
		end
	end

	if not index then
		chapterId = todayChapter[1]
	else
		chapterId = todayChapter[index]
	end

	return chapterId
end

function ActiveMgr:GetActivePlayNum(activeId)
	local playNum = 0
	local infoActive = self:GetActive(activeId)
	local list = infoActive:GetOpenChapterToday()

	for i = 1, #list do
		playNum = playNum + ChapterMgr:GetPlayNum(list[i])
	end

	return playNum
end

function ActiveMgr:GetActiveSumPlayNum(infoStage)
	local sumLeftNum = 0
	local infoActive = self:GetAllActive()
	local activeId = 0

	for i = 1, #infoActive do
		for n = 1, #infoActive[i].data.TypeValue do
			if infoActive[i].data.TypeValue[n][1] == infoStage.data.ChapterID then
				activeId = infoActive[i].data.ID

				break
			end
		end
	end

	if activeId ~= 0 then
		local infoActive = ActiveMgr:GetActive(activeId)
		local singleMaxNum = infoActive:GetMaxArgJson(nil, infoStage.data.ActType)
		local singlePlayNum = ActiveMgr:GetActivePlayNum(activeId)
		local leftNum = singleMaxNum - singlePlayNum

		sumLeftNum = leftNum
	end

	return sumLeftNum
end

function ActiveMgr:IsBossActiveOpen()
	local allOpenBossActive = self:GetOpenActiveByType(eActiveType.boss)

	if #allOpenBossActive > 0 then
		return true
	else
		return false, _("Msg_Active_UnLock")
	end
end

function ActiveMgr:HaveDailyRewardByType(activeType)
	local list = self:GetActiveByType(activeType)

	for i, activeInfo in ipairs(list) do
		if activeInfo:HaveDailyReward() then
			return true
		end
	end

	return false
end

function ActiveMgr:HaveDailyRewardByActiveGroup(activeGroupId)
	local list = self:GetActiveByActiveGroup(activeGroupId)

	for i, activeInfo in ipairs(list) do
		if activeInfo:HaveDailyReward() then
			return true
		end
	end

	return false
end

function ActiveMgr:GetActiveInfoByStageData(data)
	if data.ChapterType == 4 then
		local infoActiveList = self:GetAllActive()

		for _, infoActive in ipairs(infoActiveList) do
			for _, chapterIdList in ipairs(infoActive.data.TypeValue) do
				for _, chapterId in ipairs(chapterIdList) do
					if chapterId == data.ChapterID then
						return infoActive
					end
				end
			end
		end
	end

	return nil
end

function ActiveMgr:GetUnlockStoryStage(stageId)
	local listChapter = ChapterMgr.listAllChapter[ChapterType.event]

	for _, v in pairs(listChapter) do
		local listStage = v.listStage

		for _, z in pairs(listStage) do
			local unlockStages = z.data.AssignUnlock

			if #unlockStages > 0 then
				for i = 1, #unlockStages do
					if stageId == unlockStages[i] then
						return z
					end
				end
			end
		end
	end

	return nil
end

function ActiveMgr:GetUnlockStage(stageId)
	local listChapter = ChapterMgr.listAllChapter[ChapterType.main]

	for _, v in pairs(listChapter) do
		local listStage = v.listStage

		for _, z in pairs(listStage) do
			local unlockStages = z.data.AssignUnlock

			if #unlockStages > 0 then
				for i = 1, #unlockStages do
					if stageId == unlockStages[i] then
						return z
					end
				end
			end
		end
	end

	local listComb = {}
	local list = GetConfigArgJson("TeamChapterUnlock")

	for _, v in ipairs(list) do
		if v and v[1] then
			local info = CombinationMgr:Get(v[1])

			table.insert(listComb, info)
		end
	end

	for i = 1, 7 do
		listChapter = ChapterMgr:GetChapterList("comb", i) or {}

		for _, v in pairs(listChapter) do
			local listStage = v.listStage

			for _, z in pairs(listStage) do
				local unlockStages = z.data.AssignUnlock

				if #unlockStages > 0 then
					for j = 1, #unlockStages do
						if stageId == unlockStages[j] then
							return z
						end
					end
				end
			end
		end
	end

	return nil
end

function ActiveMgr:IsBossStageUnlock(stageId)
	local infoStage = self:GetUnlockStage(stageId)

	if not infoStage then
		return true
	end

	if infoStage:IsPass() then
		return true
	end

	local str = _("Prompt_TutorialLimitStage")
	local infoChapter, i, j = ChapterMgr:GetChapterByStageID(infoStage.id)

	if infoChapter ~= nil and infoChapter.data.Type == 1 and i ~= nil and j ~= nil then
		local strStage = "<color=yellow>" .. i .. "-" .. j .. "</color>"

		str = string.format(_("Msg_PassStageUnlock"), strStage .. Lang(infoStage.data.Name))
	elseif infoChapter ~= nil and infoChapter.data.Type ~= 1 and i ~= nil and j ~= nil then
		local strStage = "<color=yellow>" .. Lang(i) .. "-" .. Lang(j) .. "</color>"

		str = string.format(_("Msg_PassStageUnlock"), strStage .. Lang(infoStage.data.Name))
	end

	return false, str
end

function ActiveMgr:IsTeamStageUnlock(stageId)
	local infoStage = self:GetUnlockStage(stageId)

	if not infoStage then
		return true
	end

	if infoStage:IsPass() then
		return true
	end

	local str = _("Prompt_TutorialLimitStage")
	local infoChapter, i, j, k = ChapterMgr:GetChapterTeamByStageID(infoStage.id)

	if infoChapter ~= nil and infoChapter.data.Type == 1 and i ~= nil and j ~= nil then
		local strStage = "<color=yellow>" .. i .. "-" .. j .. "</color>"

		str = strStage .. Lang(infoStage.data.Name) .. " " .. _("Prompt_TutorialLimitStage")
	elseif infoChapter ~= nil and infoChapter.data.Type ~= 1 and i ~= nil and j ~= nil then
		local strStage = "<color=yellow>" .. Lang(i) .. "-" .. Lang(j) .. "</color>"

		str = strStage .. Lang(infoStage.data.Name) .. " " .. _("Prompt_TutorialLimitStage")
	end

	return false, str
end

local ActiveCardPoolData = require("luaData/ActiveCardPool")
local DropGroupData = require("luaData/DropGroup")

InfoActiveCardPool = class("InfoActiveCardPool", InfoBase)

function InfoActiveCardPool:ctor(id)
	self.id = id
	self.data = ActiveCardPoolData[self.id]
	self.listItem = {}

	for i = 1, #self.data.ItemList do
		local list = self.data.ItemList[i]
		local id = list[1]
		local buyNum = list[3]
		local catelog = list[4] + 1
		local dropItemData = self:GetDropItem(id)

		if dropItemData then
			local infoItem = ItemManager:GetValueItem(dropItemData.ItemID, dropItemData.NumMin)

			infoItem.dropId = id
			infoItem.maxBuyNum = buyNum
			infoItem.curBuyNum = 0
			infoItem.catelog = catelog
			self.listItem[catelog] = self.listItem[catelog] or {}

			table.insert(self.listItem[catelog], infoItem)
		end
	end

	self.status = 0
end

function InfoActiveCardPool:GetPoolNum(catelog)
	local data = {}

	data.maxBuyNum = 0
	data.curBuyNum = 0

	local list = self.listItem[catelog]

	for i = 1, #list do
		local info = list[i]

		data.maxBuyNum = data.maxBuyNum + info.maxBuyNum
		data.curBuyNum = data.curBuyNum + info.curBuyNum
	end

	if data.curBuyNum > data.maxBuyNum then
		data.curBuyNum = data.maxBuyNum
	end

	return data
end

function InfoActiveCardPool:IsDrawOut()
	return self.status == 3
end

function InfoActiveCardPool:IsCanOpen()
	return self.status == 1
end

function InfoActiveCardPool:IsLock()
	return self.status == 0
end

function InfoActiveCardPool:GetDropItem(id)
	for _, v in pairs(DropGroupData) do
		if v.GroupID == id then
			return v
		end
	end

	return nil
end

function InfoActiveCardPool:SetData(pBDropInfo)
	self.status = pBDropInfo.status

	local listPbDropInfo = pBDropInfo.drops

	for a, pBDropInfo in pairs(listPbDropInfo) do
		local dropId = tonumber(pBDropInfo.dropId)
		local times = pBDropInfo.times

		for _, list in pairs(self.listItem) do
			for k = 1, #list do
				local infoItem = list[k]

				if infoItem.dropId == dropId then
					list[k].curBuyNum = times
				end
			end
		end
	end
end

ActiveCardPoolMgr = {}
ActiveCardPoolMgr.dict = ActiveCardPoolMgr.dict or Record()
ActiveCardPoolMgr.infoActiveCardPool = nil
ActiveCardPoolMgr.poolListNormal = {}
ActiveCardPoolMgr.catelog = {
	rare = 2,
	normal = 1
}

function ActiveCardPoolMgr:Get(id)
	local ret = self.dict:GetValue(id)

	if not ret then
		ret = InfoActiveCardPool(id)

		self.dict:Set(id, ret)
	end

	if ret.data == nil then
		print("请检查ActiveCardPool表!" .. id)
	end

	return ret
end

function ActiveCardPoolMgr:GetAll(ActiveID)
	local list = {}

	for k, v in pairs(ActiveCardPoolData) do
		if v.ActiveID == ActiveID then
			local info = ActiveCardPoolMgr:Get(v.ID)

			table.insert(list, info)
		end
	end

	table.sort(list, function(a, b)
		return a.data.PoolIndex < b.data.PoolIndex
	end)

	return list
end
