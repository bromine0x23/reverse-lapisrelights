-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/ReTimeMgr.lua

require("UI/Page/PageClassroom/PageMainStage")

local InfoTitle = require("Info/InfoTitle")

ReTimeMgr = {
	init = false
}

function ReTimeMgr:Init()
	self:UpdateNextRefreshTime()

	self.init = true

	self:GetPartyActiveRefreshTime()
	self:GetHourActiveNextRefreshTime()
	AvatarManager.InitRefreshAvatar()
end

function ReTimeMgr:GetNextRefreshTime(pHour)
	local time = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local dataTable = os.date("*t", time)

	if pHour <= dataTable.hour then
		time = time + 1 * DateUtil.SecsPerDay
		dataTable = os.date("*t", time)
	end

	return os.time({
		second = 0,
		minute = 0,
		day = dataTable.day,
		month = dataTable.month,
		year = dataTable.year,
		hour = pHour
	})
end

function ReTimeMgr:GetNextWeekRefreshTime(pWDay, pHour)
	local time = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local dataTable = os.date("*t", time)
	local wDay = WhichDayOfWeek()

	if pWDay <= wDay then
		if pWDay < wDay or wDay == pWDay and pHour <= dataTable.hour then
			time = time + (DateUtil.DayPerWeek + pWDay - wDay) * DateUtil.SecsPerDay
		end
	else
		time = time + (pWDay - wDay) * DateUtil.SecsPerDay
	end

	dataTable = os.date("*t", time)

	return os.time({
		second = 0,
		minute = 0,
		day = dataTable.day,
		month = dataTable.month,
		year = dataTable.year,
		hour = pHour
	})
end

function ReTimeMgr:UpdateNextRefreshTime()
	self.nextRefreshTime = self:GetNextRefreshTime(4)
	self.nextWeekRefreshTime = self:GetNextWeekRefreshTime(1, 4)
	self.nextRefreshZeroTime = self:GetNextRefreshTime(0)

	local activityList = OperationActiveMgr:GetAllTypeList(11)

	for i, v in ipairs(activityList) do
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
		local beginTime = GetTimeTampByString(v.data.ShowStartTime)

		if curServerTime < beginTime then
			self.bossRaidOpenTime = GetTimeTampByString(v.data.ShowStartTime)
		end
	end
end

function ReTimeMgr:UpdateSecond()
	if not self.init then
		return
	end

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local needUpdateNextRefreshTime = false

	if curServerTime >= self.nextWeekRefreshTime then
		needUpdateNextRefreshTime = true

		local function callback(vPBMessage)
			self:RefreshWeek()
		end

		NetManager:RequestRefreshData(0, callback)
	end

	if curServerTime >= self.nextRefreshTime then
		needUpdateNextRefreshTime = true

		local function callback(vPBMessage)
			self:RefreshDay()
		end

		NetManager:RequestRefreshData(0, callback)

		if UnionRaidMgr.RaidBeginTime ~= 0 and UnionRaidMgr.RaidBeginTime < self.nextRefreshTime then
			UnionRaidMgr.NotChangeCardHp = true
			UnionRaidMgr.RaidBeginTime = 0
		end
	end

	if self.HourActiveNextRefreshTime and self.HourActiveNextRefreshTime ~= 0 and curServerTime >= self.HourActiveNextRefreshTime then
		if self.nextRefreshTime ~= self.HourActiveNextRefreshTime then
			Event.Instance:Fire("UpdateOperationActive")
			InfoTitle:UpdateItemLock()
		end

		OperationRDL.RunHourlyGift()

		self.HourActiveNextRefreshTime = 0

		self:GetHourActiveNextRefreshTime()
	end

	if self.bossRaidOpenTime and curServerTime >= self.bossRaidOpenTime and not self.bossRaidOpen then
		Event.Instance:Fire("UpdateBossRaidOpen")

		self.bossRaidOpen = true
	end

	OperationActiveMgr.OnLineTime = curServerTime - OperationActiveMgr.OnLineLoginTime

	if self.workNextRefreshTime ~= nil and self.workNextRefreshTime ~= 0 and curServerTime >= self.workNextRefreshTime then
		WorkRDL.AddCanReceive(self.nextRefreshWorkId)
		self:GetWorkNextRefreshTime()
	end

	if not self.bossRaidItemNextRefreshTime then
		self:GetBossRaidItemNextRefreshTime()
	end

	if self.bossRaidItemNextRefreshTime ~= 0 and curServerTime >= self.bossRaidItemNextRefreshTime then
		for i, v in ipairs(self.bossRaidItemList) do
			ItemManager:Get(v).pb.num = 0
		end

		Event.Instance:Fire("UpdateBag")
		self:GetBossRaidItemNextRefreshTime()
	end

	if not self.activeItemNextRefreshTime then
		self:GetActiveItemNextRefreshTime()
	end

	if self.activeItemNextRefreshTime ~= 0 and curServerTime >= self.activeItemNextRefreshTime then
		for i, v in ipairs(self.activeItemList) do
			ItemManager:Get(v).pb.num = 0
		end

		Event.Instance:Fire("UpdateBag")
		self:GetActiveItemNextRefreshTime()
	end

	if not self.cardPoolItemNextRefreshTime then
		self:GetCardPoolItemNextRefreshTime()
	end

	if self.cardPoolItemNextRefreshTime ~= 0 and curServerTime >= self.cardPoolItemNextRefreshTime then
		for i, v in ipairs(self.cardPoolItemList) do
			if curServerTime >= v.time then
				ItemManager:Get(v.itemId).pb.num = 0
			end
		end

		Event.Instance:Fire("UpdateBag")
		self:GetCardPoolItemNextRefreshTime()
	end

	if not self.nextUnionRaidRefreshTime then
		self:RefreshUnionRaidTime()
	elseif curServerTime >= self.nextUnionRaidRefreshTime then
		UnionRaidMgr.SetLastRefreshTime(curServerTime)
		self:RefreshUnionRaidTime()

		local function cb()
			Event.Instance:Fire("UpdateRaidSystem", eRefreshType.Weekly)
		end

		require("UI/Page/PageUnionRaid/PageUnionRaid")
		PageUnionRaid.RequestData(cb)
		UnionRaidMgr:ResetData(eRefreshType.Weekly)
	end

	if self.activeBeginTime and self.activeBeginTime ~= 0 and curServerTime >= self.activeBeginTime then
		ChapterRDL.PartyRDL.UpdateBegin()

		self.activeBeginTime = 0
	elseif self.activeEndTime and self.activeEndTime ~= 0 and curServerTime >= self.activeEndTime then
		ChapterRDL.PartyRDL.UpdateEnd()

		self.activeEndTime = 0
	end

	if AvatarManager.NextRefreshTime ~= 0 and curServerTime >= AvatarManager.NextRefreshTime then
		AvatarManager.ResetNextRefreshTime()
		Event.Instance:Fire("AvatarShelfRefresh")
	end

	if needUpdateNextRefreshTime then
		self:UpdateNextRefreshTime()
	end
end

function ReTimeMgr:RefreshWeek()
	Event.Instance:Fire("UpdateServerRefresh")
	TaskManager:ResetTask(eRefreshType.Weekly)
	require("UI/Page/PageTask/PageTask")
	PageTask.RequestTaskList()
end

function ReTimeMgr:RefreshDay()
	RedDotSystemMgr.Refresh()
	Event.Instance:Fire("UpdateServerRefresh")
	ChapterMgr:ResetPlayNum()
	Event.Instance:Fire("UpdateStageNum")

	InfoGameInst.todayRecvFriendCoinNum = 0
	InfoGameInst.todayRequestFriendNum = 0

	FriendMgr:ResetSendCoin()
	Event.Instance:Fire("RefreshFriendPanel")

	WorkMgr.Requested = false

	require("UI/Page/PageWork/PageWork")
	PageWork.RequestGetWorks()
	Event.Instance:Fire("ResetWorks")
	TaskManager:ResetTask(eRefreshType.Daily)
	require("UI/Page/PageTask/PageTask")
	PageTask.RequestTaskList()

	if UnionMgr.HasUnion() then
		UnionWishMgr:Clear()
		Event.Instance:Fire("UpdateUnionWish")
		NetManager:RequestUnionMembersAndLogs(function()
			return
		end)
	end

	if UnionMgr.HasUnion() then
		local function cb()
			Event.Instance:Fire("UpdateRaidSystem", eRefreshType.Daily)
		end

		require("UI/Page/PageUnionRaid/PageUnionRaid")
		PageUnionRaid.RequestData(cb)
		UnionRaidMgr:ResetData(eRefreshType.Daily)

		local roleCards = RoleCardMgr:GetAllHoldCard()

		for _, v in pairs(roleCards) do
			v:ResetCardHpPercent()
			v:ResetGvgCardHpPercent()
			v:ResetGvgTimes()
		end

		Event.Instance:Fire(EventEnum.ResetCardHpPercent)
		Event.Instance:Fire("UpdateRaidSystem", eRefreshType.Daily)
		Infogvg:Refresh()
	end

	PersistentStoreUtil.SetBool("NotRemindToday", false)
	require("Info/InfoActivityBossRaid")
	ActivityBossRaidMgr:DailyUpdate()
	require("Info/InfoCardPool")
	CardPoolManager:DailyUpdate()
	InfoGameInst:SetWhipAwardBoxNum(0)

	OperationActiveMgr.OnLineLoginTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	local onLineInfo = OperationActiveMgr:Get(OperationActiveMgr:GetTotalOnlineInfo().ID)

	if onLineInfo and onLineInfo.pb then
		onLineInfo.pb.record = 0
	end

	RoleCardMgr:SetTipWindowPatFaceState("1")
	RoleCardMgr:SetTipWindowOnGameState("1")
	InfoGameInst:TipWindowAdsListSort()
	RoleCardMgr:SetTipWindowState("1")

	OperationActiveMgr.BossActivityPopupIndex = 1
	OperationActiveMgr.RoleBirthdayPopupIndex = 1
	PageMainStage.entered = true
	InfoGameInst.gameInfo.touchDailyNum = 0
	InfoGameInst.shareNum = 0

	InfoGameInst:ResetPowerBoughtTimes()
	Event.Instance:Fire("UpdatePowerBuyTimes")

	if InstructionMgr:IsInGuide() then
		return
	end

	local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PatFace)

	if not isOpen then
		return
	end

	OperationActiveMgr.UpdateOperationFlag = true

	CalendarRDL.Reset()
	ChapterRDL.TowerRDL.Reset()
	ChapterRDL.PartyRDL.Reset()
	InfoTitle:UpdateItemLock()
	NetManager:RequestActiveOperates(nil, function(vPBMessage)
		if vPBMessage.result.code == 0 then
			OperationActiveMgr:SetData(vPBMessage.activeOperates)
			Event.Instance:Fire("UpdateOperationActive")
		end
	end)
end

function ReTimeMgr:GetWorkNextRefreshTime()
	self.workNextRefreshTime = 0
	self.nextRefreshWorkId = 0

	local list = WorkMgr:GetWorkListByState(eWorkStateType.Picked)

	if next(list) ~= nil then
		table.sort(list, function(a, b)
			return tonumber(a.pb.endTime) < tonumber(b.pb.endTime)
		end)

		for _, v in ipairs(list) do
			if not v:IsComplete() then
				self.workNextRefreshTime = v.pb.endTime
				self.nextRefreshWorkId = v.pb.id

				break
			end
		end
	end
end

function ReTimeMgr:GetActiveItemNextRefreshTime()
	self.activeItemNextRefreshTime = 0
	self.activeItemList = {}

	local listActive = ActiveMgr:GetOpenActiveByType(eActiveType.boss)

	if next(listActive) ~= nil then
		self.activeItemNextRefreshTime = GetTimeTampByString(listActive[1].data.CloseTime)
		self.activeItemList = listActive[1].data.LimitItems
	end
end

function ReTimeMgr:GetBossRaidItemNextRefreshTime()
	self.bossRaidItemNextRefreshTime = 0
	self.bossRaidItemList = {}

	local listBossraid = ActiveMgr:GetOpenActiveByType(eActiveType.bossraid)

	if next(listBossraid) ~= nil then
		self.bossRaidItemNextRefreshTime = GetTimeTampByString(listBossraid[1].data.CloseTime)
		self.bossRaidItemList = listBossraid[1].data.LimitItems
	end
end

function ReTimeMgr:GetCardPoolItemNextRefreshTime()
	require("Info/InfoCardPool")

	self.cardPoolItemNextRefreshTime = 0
	self.cardPoolItemList = {}

	local list = CardPoolManager:GetLimitTimeItemPoolList()

	if next(list) ~= nil then
		self.cardPoolItemNextRefreshTime = list[1].time
		self.cardPoolItemList = list
	end
end

function ReTimeMgr:RefreshUnionRaidTime()
	self.nextUnionRaidRefreshTime = UnionRaidMgr.GetNextRefreshTime()
end

function ReTimeMgr:GetHourActiveNextRefreshTime()
	if self.HourActiveNextRefreshTime and self.HourActiveNextRefreshTime ~= 0 then
		return
	end

	if self.listHour and self.hourIdx then
		self.hourIdx = self.hourIdx + 1

		if self.hourIdx > #self.listHour then
			self.hourIdx = 1
		end

		self.HourActiveNextRefreshTime = self:GetNextRefreshTime(self.listHour[self.hourIdx])

		return
	end

	self.hourIdx = 0
	self.listHour = {}

	local active = OperationActiveMgr:GetAllTypeList(eOperationActiveType.Hour)[1]

	if active then
		local t = active.data.DailyTime

		for i = 1, #t do
			for k, v in ipairs(t[i]) do
				if k <= 2 and not table.contains(self.listHour, v) then
					table.insert(self.listHour, v)
				end
			end
		end

		table.sort(self.listHour)
	end

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local second, curDis, preDis = 0, 0, 0

	for k, v in ipairs(self.listHour) do
		second = self:GetNextRefreshTime(v)
		curDis = second - curServerTime

		if curDis > 0 and (preDis == 0 or curDis < preDis) then
			self.hourIdx = k
			self.HourActiveNextRefreshTime = second
			preDis = curDis
		end
	end
end

function ReTimeMgr:GetPartyActiveRefreshTime()
	self.activeBeginTime = 0
	self.activeEndTime = 0

	local active = ActiveMgr:GetOpenActiveByType(eActiveType.boss)[1]

	if active then
		self.activeEndTime = GetTimeTampByString(active.data.EndTime)
	else
		active = ActiveMgr:GetNextOpenActiveByType(eActiveType.boss)

		if active then
			self.activeBeginTime = GetTimeTampByString(active.data.StartTime)
			self.activeEndTime = GetTimeTampByString(active.data.EndTime)
		end
	end
end
