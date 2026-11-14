-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoGameExtra.lua

require("Info/InfoTopic")
require("Info/InfoPhoneCall")
require("Info/CardFilterMgr")
require("Info/InfoGoodsInfoList")

local InfoTeam = require("Info/InfoTeam")
local InfoTeamgGroup = require("Info/InfoTeamgGroup")
local InfoTitle = require("Info/InfoTitle")

InfoGameExtra = class("InfoGameExtra", InfoBase)

function InfoGameExtra:ctor()
	self.gameInfo = nil
	self.gameRefresh = nil
	self.lastSelectChapter = 0
	self.lastSelectStageOffy = 0
	self.lastSelectLive = 0
	self.lastSelectLiveRank = 1
	self.whipAwardBoxNum = 0
	self.friendHelpTimes = 0
	self.openServerTime = 0
	self.currentTheme = 0
	self.TipWindowAdsList = {}
	self.ChapterTimes = {}
	self.onlineTime = 0
	self.todayRecvFriendCoinNum = 0
	self.maxRecvFriendCoinNum = GetConfigArgInt("FriendGiftMax")
	self.todayRequestFriendNum = 0
	self.maxRequestFriendNum = GetConfigArgInt("FriendsApplyMax")
	self.maxPowerBuyTimesDay = GetConfigArgInt("PowerBuyCost")
	self.powerBoughtTimesToday = 0
	self.RefreshTime = 4
end

function InfoGameExtra:SetData(pbGameinfo)
	self.gameInfo = pbGameinfo
	self.powerBoughtTimesToday = math.min(math.max(pbGameinfo.powerBuyTimes, 0), self.maxPowerBuyTimesDay)

	FavorMgr.Instance:SetPowerTime(pbGameinfo.touchTime)

	if pbGameinfo.touchCnt ~= nil and tonumber(pbGameinfo.touchCnt) then
		self.gameInfo.touchCnt = tonumber(pbGameinfo.touchCnt)
	end

	TopicManager:SetData(pbGameinfo.messages)
	PhoneCallManager:SetData(pbGameinfo.voices)
	CommunicationRDL.InitRD()
	ChapterMgr:InitStoryAwardList()

	self.listGettedScenarioAward = pbGameinfo.messGroupId

	CollectionManager:SetData(pbGameinfo.figureId, pbGameinfo.figureAward)
	InfoTeam:SetData(pbGameinfo.chapterTeams)
	InfoTeamgGroup:SetData(pbGameinfo.chapterTeams)

	ActivityBossRaidMgr.selfBossEndTime = pbGameinfo.dropRaidBossTime

	UnionMgr.InitUnion(pbGameinfo.club)
	CombBondageMgr:SetData(pbGameinfo.fetterSkills)
	InfoTitle:SetData(pbGameinfo.heads, pbGameinfo.headFrameList, pbGameinfo.medals)
	GoodsInfoListMgr:SetData(pbGameinfo.activeGoods)

	self.whipAwardBoxNum = pbGameinfo.whipAwardBoxNum
	self.friendHelpTimes = self.gameInfo.friendHelpTimes
	self.currentTheme = pbGameinfo.currentTheme

	if ThemeManager.isFirstEnterGame == 1 then
		PersistentStoreUtil.SetInt(ePSKey.SceneId, self.currentTheme)

		ThemeManager.isFirstEnterGame = 0
	end

	for i = 1, 4 do
		self.ChapterTimes[i] = {}
		self.ChapterTimes[i].type = i
		self.ChapterTimes[i].buyTimes = 0
	end

	if pbGameinfo.chapterBuyTimes then
		for i = 1, #pbGameinfo.chapterBuyTimes do
			self.ChapterTimes[pbGameinfo.chapterBuyTimes[i].type].type = pbGameinfo.chapterBuyTimes[i].type
			self.ChapterTimes[pbGameinfo.chapterBuyTimes[i].type].buyTimes = pbGameinfo.chapterBuyTimes[i].buyTimes
		end
	end

	local noticesCount = #pbGameinfo.notices

	for i, v in ipairs(pbGameinfo.notices) do
		Event.Instance:Fire(EventEnum.AddRollingNoticeTime, v)
	end

	RoleCardMgr:SetBossLiveCurIndexState("1_1")

	if RoleCardMgr:GetTipWindowPatFaceState() == "1" then
		RoleCardMgr:SetTipWindowAwardState("1")
	else
		RoleCardMgr:SetTipWindowAwardState("0")
	end

	RoleCardMgr:SetTipWindowOnGameState("1")

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	OperationActiveMgr.OnLineLoginTime = curServerTime

	local time = os.date("%y.%m.%d", curServerTime)

	if time ~= RoleCardMgr:GetDayTimeRefresh() then
		RoleCardMgr:SetDayTimeRefresh(time)
		RoleCardMgr:SetTipWindowState("1")
		RoleCardMgr:SetTipWindowAwardSignState("1")
	end

	function self.mainSceneCallBack()
		self.requestCount = 0

		CardFilterMgr:Init()
		NetManager:RequestActiveOperates(nil, function(vPBMessage)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vPBMessage.result.code == 0 then
				OperationActiveMgr:SetData(vPBMessage.activeOperates)
				OperationRDL.Init()
				CalendarRDL.Init()
				self:CountAndDispatch()
			end
		end)
		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestGetPurchaseList(function(vPBMessage)
			LoadingMgr.Hide(eLoadingType.Repeat)
			ChapterRDL.TowerRDL.Init()
			self:CountAndDispatch()
		end)
		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestTaskList(function()
			LoadingMgr.Hide(eLoadingType.Repeat)
			self:TipWindowAdsListSort()
			self:CountAndDispatch()
		end)
		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:GetSyncResource(function()
			LoadingMgr.Hide(eLoadingType.Repeat)
			self:CountAndDispatch()
		end)
		LoadingMgr.Show(eLoadingType.Repeat)
	end

	InfoGameInst.gameInfo.webType = GetConfigArgInt("AnnouncementConfig")

	UIMgr.SetFocusChange()
end

function InfoGameExtra:CountAndDispatch()
	self.requestCount = self.requestCount + 1

	if self.requestCount >= 4 then
		Event.Instance:Fire("OnInfoGameReqComplete")
		Event.Instance:Fire("OnInfoGameReqCompleteMgr")
	end
end

function InfoGameExtra:TriggerEnterEvent()
	if self.mainSceneCallBack then
		self.mainSceneCallBack()

		self.mainSceneCallBack = nil
	else
		self.requestCount = 4
	end
end

function InfoGameExtra:IsRequestOk()
	return self.requestCount == 4
end

function InfoGameExtra:ChangeQuestionAwardState(nState)
	self.gameInfo.questionAward = nState
end

function InfoGameExtra:SetRefreshData(pbGameRefresh)
	self.gameRefresh = pbGameRefresh
	self.friendHelpTimes = pbGameRefresh.friendHelpTimes
	self.whipAwardBoxNum = pbGameRefresh.whipAwardBoxNum
	TowerChapterMgr.dailyTimes = pbGameRefresh.towerDailyTimes

	for i = 1, 4 do
		self.ChapterTimes[i] = {}
		self.ChapterTimes[i].type = i
		self.ChapterTimes[i].buyTimes = 0
	end

	if pbGameRefresh.chapterBuyTimes then
		for i = 1, #pbGameRefresh.chapterBuyTimes do
			self.ChapterTimes[pbGameRefresh.chapterBuyTimes[i].type].type = pbGameRefresh.chapterBuyTimes[i].type
			self.ChapterTimes[pbGameRefresh.chapterBuyTimes[i].type].buyTimes = pbGameRefresh.chapterBuyTimes[i].buyTimes
		end
	end

	self.gameInfo.touchDailyNum = pbGameRefresh.touchDailyNum
	self.shareNum = pbGameRefresh.shareNum

	ChapterMgr:SetData(pbGameRefresh.chapters)
end

function InfoGameExtra:ChangeRenameNum(v)
	self.gameInfo.changeNameNum = (self.gameInfo.changeNameNum or 0) + v
end

function InfoGameExtra:GetRenameNum()
	return self.gameInfo.changeNameNum or 0
end

function InfoGameExtra:ChangeTodayRecvFriendCoinNum(v)
	self.todayRecvFriendCoinNum = self.todayRecvFriendCoinNum + v
end

function InfoGameExtra:IsOverRecvFriendCoinNumToday()
	return self.todayRecvFriendCoinNum >= self.maxRecvFriendCoinNum
end

function InfoGameExtra:ChangeTodayRequestFriendNum(v)
	self.todayRequestFriendNum = self.todayRequestFriendNum + v
end

function InfoGameExtra:IsOverRequestFriendNumToday()
	return self.todayRequestFriendNum >= self.maxRequestFriendNum
end

function InfoGameExtra:IsGetScenarioReward(gId)
	if not self.listGettedScenarioAward then
		return false
	end

	for _, v in pairs(self.listGettedScenarioAward) do
		if gId == v then
			return true
		end
	end

	return false
end

function InfoGameExtra:SetScenarioReward(gId)
	if self.listGettedScenarioAward then
		table.insert(self.listGettedScenarioAward, gId)
	end
end

function InfoGameExtra:IsGetRechargeReward(ID)
	local lists = InfoGameInst.gameInfo.rechargeMark

	for i = 1, #lists do
		if ID == lists[i] then
			return true
		end
	end

	return false
end

function InfoGameExtra:IsGetVipPowerReward(vipValue)
	if self.gameInfo.vipLevelMark ~= nil then
		local lists = self.gameInfo.vipLevelMark

		for i = 1, #lists do
			if lists[i] == vipValue then
				return true
			end
		end
	end

	return false
end

function InfoGameExtra:GetMonthCardType()
	local curT = NetData:GetCurServerTime()

	if not TimeIsNotToday(self.gameInfo.monthCardTime) or curT >= self.gameInfo.monthCardTime then
		self.gameInfo.monthCardType = 0
	end

	return self.gameInfo.monthCardType
end

function InfoGameExtra:GetPowerBoughtTimes()
	return self.powerBoughtTimesToday
end

function InfoGameExtra:ChangePowerBoughtTimes()
	local num = self.powerBoughtTimesToday + 1

	self.powerBoughtTimesToday = math.min(math.max(num, 0), self.maxPowerBuyTimesDay)
end

function InfoGameExtra:ResetPowerBoughtTimes()
	self.powerBoughtTimesToday = 0
end

function InfoGameExtra:GetStageResetTime()
	if TimeIsNotToday(self.gameInfo.stageResetPlayCountAt) then
		self.gameInfo.stageResetPlayCount = 0
		self.gameInfo.stageResetPlayCountAt = NetData:GetCurServerTime()
	end

	return self.gameInfo.stageResetPlayCount
end

function InfoGameExtra:AddReputationId(id)
	if self.gameInfo.reputations == nil then
		self.gameInfo.reputations = {}
	end

	table.insert(self.gameInfo.reputations, id)
end

function InfoGameExtra:GetPbEntry(keyP)
	for i = 1, #self.gameInfo.entrys do
		local entry = self.gameInfo.entrys[i]

		if entry.key == keyP then
			return entry
		end
	end

	return nil
end

function InfoGameExtra:SetPbEntry(pbEntryP)
	if pbEntryP == nil or #pbEntryP <= 0 then
		return
	end

	for i = 1, #self.gameInfo.entrys do
		local entry = self.gameInfo.entrys[i]

		if entry.key == pbEntryP.key then
			self.gameInfo.entrys[i].value = entry.value
			self.gameInfo.entrys[i].extra = entry.extra

			return
		end
	end

	table.insert(self.gameInfo.entrys, pbEntryP)
end

function InfoGameExtra:SetTouchData()
	self.svTouchTime = TimerMgr.GetCurrentTime()
end

function InfoGameExtra:GetData()
	return self.gameInfo
end

function InfoGameExtra:GetRoleIdList()
	local roleCardTeams = InfoGameInst.gameInfo.roleCardTeams

	if self.roleTeams == nil then
		self.roleTeams = {}

		for i = 1, #roleCardTeams do
			local cId = roleCardTeams[i]
			local roleId = 0

			if cId ~= 0 then
				roleId = RoleCardMgr:GetRoleId(cId)
			end

			table.insert(self.roleTeams, roleId)
		end
	end

	return self.roleTeams
end

function InfoGameExtra:GetRoleCardIdList()
	return InfoGameInst.gameInfo.roleCardTeams
end

function InfoGameExtra:SetRoleIdList(list)
	for i = 1, #self.roleTeams do
		self.roleTeams[i] = list[i]
	end
end

function InfoGameExtra:SetTouchCnt(count)
	if count ~= nil and tonumber(count) then
		self.gameInfo.touchCnt = count
		self.gameInfo.touchDailyNum = self.gameInfo.touchDailyNum + 1
	end
end

function InfoGameExtra:SetTouchTimeStep(step)
	if step ~= nil then
		self.gameInfo.touchTime = step
	end
end

function InfoGameExtra:GetRoleVolume()
	if self.gameInfo == nil then
		return 0
	end

	return self.gameInfo.roleVolume
end

function InfoGameExtra:SetRoleVolume(curVolume)
	if self.gameInfo == nil then
		return
	end

	self.gameInfo.roleVolume = curVolume
end

function InfoGameExtra:AddFriendGetPower(value, max)
	self.gameInfo.giftPowerNum = self.gameInfo.giftPowerNum + value

	if max < self.gameInfo.giftPowerNum then
		self.gameInfo.giftPowerNum = max
	end
end

function InfoGameExtra:GetTodayFriendPower()
	if TimeIsNotToday(self.gameInfo.giftGetRewardTime) then
		self.gameInfo.giftPowerNum = 0
		self.gameInfo.giftGetRewardTime = NetData:GetCurServerTime()
	end

	return self.gameInfo.giftPowerNum
end

function InfoGameExtra:AddGetFriendCoin(value, max)
	self.gameInfo.giftFriendCoinNum = self.gameInfo.giftFriendCoinNum + value

	if max < self.gameInfo.giftFriendCoinNum then
		self.gameInfo.giftFriendCoinNum = max
	end
end

function InfoGameExtra:GetTodayFriendCoin()
	if TimeIsNotToday(self.gameInfo.giftGetRewardTime) then
		self.gameInfo.giftFriendCoinNum = 0
		self.gameInfo.giftGetRewardTime = NetData:GetCurServerTime()
	end

	return self.gameInfo.giftFriendCoinNum
end

function InfoGameExtra:SetWhipAwardBoxNum(whipAwardBoxNum)
	self.whipAwardBoxNum = whipAwardBoxNum
end

function InfoGameExtra:GetWhipAwardBoxNum()
	return self.whipAwardBoxNum
end

function InfoGameExtra:SetFriendHelpTimes(friendHelpTimes)
	self.friendHelpTimes = friendHelpTimes
end

function InfoGameExtra:GetFriendHelpTimes()
	return self.friendHelpTimes
end

function InfoGameExtra:SetOpenServerTime(openServerTime)
	self.openServerTime = openServerTime
end

function InfoGameExtra:GetOpenServerTime()
	return self.openServerTime or 0
end

function InfoGameExtra:SetOnlineTime(onlineTime)
	self.onlineTime = onlineTime
end

function InfoGameExtra:GetOnlineTime()
	return self.onlineTime or 0
end

function InfoGameExtra:TipWindowAdsListSort()
	local LoginPageManage = require("luaData/LoginPageManage")
	local list = {}
	local temp = {}
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	for k, v in pairsByKeys(LoginPageManage) do
		temp = {}

		if v.StartTime == "" then
			local CloseTime

			temp.StartTime, CloseTime, temp.EndTime = OperationActiveMgr.GetRelevanceActiveID(v.RelevanceActive[1], v.RelevanceActive[2])

			if temp.StartTime then
				temp.StartTime, temp.EndTime = GetTimeTampByString(temp.StartTime), GetTimeTampByString(temp.EndTime)

				if curServerTime >= temp.StartTime and curServerTime <= temp.EndTime then
					temp.data = v

					table.insert(list, temp)
				end
			end
		else
			temp.StartTime, temp.EndTime = v.StartTime, v.EndTime
			temp.StartTime, temp.EndTime = GetTimeTampByString(temp.StartTime), GetTimeTampByString(temp.EndTime)

			if curServerTime >= temp.StartTime and curServerTime <= temp.EndTime then
				temp.data = v

				table.insert(list, temp)
			end
		end
	end

	local function func(a, b)
		if a.StartTime == b.StartTime then
			return a.data.ID < b.data.ID
		else
			return a.StartTime < b.StartTime
		end
	end

	table.sort(list, func)

	local adsList = {}

	for i, v in ipairs(list) do
		if v.data.RelevanceActive[1] == "ActiveManage" then
			local info = OperationActiveMgr:Get(v.data.RelevanceActive[2])

			if info and info.data.UIType == eOperationActive.URCardPool and not info:IsHaveCanRec() and not SystemMaintainMgr:Deal(SystemMaintainType.task) then
				-- block empty
			else
				table.insert(adsList, v.data)
			end
		else
			table.insert(adsList, v.data)
		end
	end

	self.TipWindowAdsList = adsList
end

function InfoGameExtra:GetTipWindowAdsList()
	return self.TipWindowAdsList
end

function InfoGameExtra:SetChapterTimesList(type, num)
	for i = 1, #self.ChapterTimes do
		if type == i then
			self.ChapterTimes[i].type = i
			self.ChapterTimes[i].buyTimes = self.ChapterTimes[i].buyTimes + num
		end
	end
end

function InfoGameExtra:GetChapterTimesList()
	return self.ChapterTimes
end

function InfoGameExtra:GetCurrentTheme()
	return self.currentTheme
end

function InfoGameExtra:SetCurrentTheme(currentTheme)
	self.currentTheme = currentTheme
end

InfoGameInst = InfoGameInst or InfoGameExtra()
