-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoOperationActive.lua

local OperationData = require("luaData/ActiveManage")
local OperationUIData = require("luaData/ActiveUiManage")
local RewardData = require("luaData/RewardPack")
local CharacterTeam = require("luaData/CharacterTeam")
local ActiveConditionData = require("luaData/ActiveCondition")

InfoOperationActive = class("InfoOperationActive", InfoBase)
eOperationActiveType = {
	RefreshOnLine = 15,
	Hour = 3,
	Login = 1,
	URCardPool = 24,
	OpenService = 5,
	LimitTime = 17,
	SmallClass = 14,
	ExtraDrop = 9,
	PlayerBirthday = 19,
	LimitActivity = 25,
	RoleBirthdayAward = 22,
	GrowthFund = 23,
	AssignLogin = 18,
	Level = 2,
	SingleOnLine = 7,
	CumulationOnline = 8,
	Jigsaw = 21,
	Sign = 4,
	RechargeRebate = 13,
	BossRaid = 11,
	Registered = 6,
	BattlePass = 10,
	FirstCharge = 12,
	Buff = 16,
	Accumulate = 20
}
eOperationActive = {
	Birthday = 9,
	BossActivity = 11,
	Login = 1,
	URCardPool = 21,
	CommonOne = 14,
	Hour = 3,
	GrowthFund = 13,
	PlayerBirthday = 10,
	Jigsaw = 12,
	AccumulatedRecharge = 20,
	SmallClass = 7,
	OnLine = 64,
	Card = 61,
	Level = 2,
	OpenService = 62,
	Register = 63,
	Addition = 66,
	Sign = 4,
	RechargeRebate = 8,
	CommonThree = 16,
	TotalOnLine = 65,
	BattlePass = 5,
	BattlePass2 = 22,
	RoleBirthdayAward = 17,
	CommonTwo = 15,
	CommonFour = 18
}

function InfoOperationActive:ctor(id)
	self.id = id
	self.data = OperationData[id]
	self.lastRecvTime = 0
	self.pb = {}
	self.pb.awardRecords = {}
	self.pb.recordInfos = {}
	self.pb.record = 0
	self.pb.resetTimes = 0
end

function InfoOperationActive:GetOperationUIInfo(ActiveID)
	for k, v in pairsByKeys(OperationUIData) do
		if v.ActiveID == ActiveID and OperationActiveMgr.PageOperationActiveType == tonumber(v.Type) then
			return v
		end
	end

	return nil
end

function InfoOperationActive:GetOperationGiftBagTypeUIInfo(GiftBagType)
	for k, v in pairsByKeys(OperationUIData) do
		if v.GiftBagType and v.GiftBagType[1] and v.GiftBagType[1] == GiftBagType then
			return v
		end
	end

	return nil
end

function InfoOperationActive:ClearOperationSpine()
	if self.spineGroupHandle then
		for _, v in pairs(self.spineGroupHandle) do
			ResourceMgr.Cancel(v)
		end

		self.spineGroupHandle = nil
	end

	if self.listRef then
		for _, v in pairs(self.listRef) do
			ResourceMgr.Unload(v)
		end

		self.listRef = nil
	end

	UnloadAllImageSprite(self)

	self.BGRaw = nil
	self.UIRootObject = nil
end

function InfoOperationActive:SetOperationBg(ActiveID, BGRaw, UIRootObject)
	self.BGRaw = BGRaw

	local uiInfo = InfoOperationActive:GetOperationUIInfo(ActiveID)

	if not uiInfo then
		return
	end

	local RmgList = {}

	for i = 1, 2 do
		local Rmg = self.BGRaw

		RmgList[i] = Rmg

		if uiInfo and uiInfo.Bg and uiInfo.Bg[i] and uiInfo.Bg[i][1] and Rmg then
			if not self.spineGroupHandle then
				self.spineGroupHandle = {}
			end

			self.spineGroupHandle[i] = ResourceMgr.BeginSubmit(function()
				if self["BG" .. i] then
					if not self.listRef then
						self.listRef = {}
					end

					if RmgList[i] and not IsNil(RmgList[i]) then
						table.insert(self.listRef, self["BG" .. i])
						UIUtil.SetImageSprite(RmgList[i], self["BG" .. i], self)
						RmgList[i].gameObject.transform:SetSiblingIndex(uiInfo.Bg[i][2])
					else
						ResourceMgr.Unload(self["BG" .. i])
					end
				end
			end)

			ResourceMgr.SubmitCache(uiInfo.Bg[i][1], self, "BG" .. i, Sprite)
			ResourceMgr.EndSubmit()
		end
	end
end

function InfoOperationActive:SetOperationUIModel(ActiveID, BGRaw, UIRootObject, existTextView)
	self.BGRaw = BGRaw
	self.UIRootObject = UIRootObject

	local uiInfo = InfoOperationActive:GetOperationUIInfo(ActiveID)

	if not uiInfo then
		return
	end

	local RmgList = {}

	for i = 1, #uiInfo.Bg do
		local Rmg = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Bg/Bg" .. i, "Image")

		if not IsNil(self.BGRaw) then
			Rmg = self.BGRaw
		end

		RmgList[i] = Rmg

		if uiInfo and uiInfo.Bg and uiInfo.Bg[i] and uiInfo.Bg[i][1] and Rmg and RmgList[i] and not IsNil(RmgList[i]) then
			UIUtil.SetImageSprite(RmgList[i], uiInfo.Bg[i][1], self)
			RmgList[i].gameObject.transform:SetSiblingIndex(uiInfo.Bg[i][2])

			if uiInfo.Bg[i][3] and uiInfo.Bg[i][4] then
				GOUtil.SetRectTransformAnchoredPosition(RmgList[i].gameObject, uiInfo.Bg[i][3], uiInfo.Bg[i][4])
			end
		end
	end

	for i = 1, #uiInfo.SpineStatic do
		local goSpine = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Spine/Spine" .. i, "Image")

		if uiInfo.SpineStatic[i][1] and goSpine then
			if uiInfo.SpineStatic[i][1] == "" then
				goSpine.enabled = false
			else
				UIUtil.SetImageSprite(goSpine, uiInfo.SpineStatic[i][1], self, true)
				goSpine.gameObject.transform:SetSiblingIndex(uiInfo.SpineStatic[i][2])

				if uiInfo.SpineStatic[i][3] and uiInfo.SpineStatic[i][4] then
					GOUtil.SetRectTransformAnchoredPosition(goSpine.gameObject, uiInfo.SpineStatic[i][3], uiInfo.SpineStatic[i][4])
				end

				goSpine.enabled = true
			end
		end
	end

	local goSpineList = {}

	for i = 1, #uiInfo.Spine do
		local goSpine = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/Model/Spine/Spine" .. i)

		goSpineList[i] = goSpine

		if uiInfo and uiInfo.Spine and uiInfo.Spine[i] and uiInfo.Spine[i][1] and goSpine and goSpine.transform.childCount == 0 then
			if not self.spineGroupHandle then
				self.spineGroupHandle = {}
			end

			self.spineGroupHandle[i] = ResourceMgr.BeginSubmit(function()
				if goSpineList[i] and self["Spine" .. i] and not IsNil(goSpineList[i]) then
					if not self.listRef then
						self.listRef = {}
					end

					table.insert(self.listRef, self["Spine" .. i])
					GOUtil.InstantiateUIPrefab(self["Spine" .. i], goSpineList[i])

					goSpineList[i].transform.localScale = Vector3(uiInfo.Spine[i][3] or 0.75, uiInfo.Spine[i][3] or 0.75, 1)

					goSpineList[i].transform:SetSiblingIndex(uiInfo.Spine[i][2])

					if uiInfo.Spine[i][4] then
						goSpineList[i].transform.localEulerAngles = Vector3.New(0, 0, uiInfo.Spine[i][4])
					end

					GOUtil.UpdateSpineSkeleton(goSpineList[i])

					GOUtil.GetComponent(goSpineList[i], "Image").enabled = false

					if uiInfo.Spine[i][5] and uiInfo.Spine[i][6] then
						GOUtil.SetRectTransformAnchoredPosition(goSpineList[i].gameObject, uiInfo.Spine[i][5], uiInfo.Spine[i][6])
					end
				end
			end)

			ResourceMgr.SubmitCache(uiInfo.Spine[i][1], self, "Spine" .. i, GameObject)
			ResourceMgr.EndSubmit()
		end
	end

	for i = 1, #uiInfo.Fx do
		local Fx = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/Model/Fx")

		if uiInfo and uiInfo.Fx and uiInfo.Fx[i] and uiInfo.Fx[i][1] and Fx then
			EffectMgr:Alloc(uiInfo.Fx[i][1], Fx, true)
			Fx.gameObject.transform:SetSiblingIndex(uiInfo.Fx[i][2])
		end
	end

	for i = 1, #uiInfo.Pic do
		local Img = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Pic/Pic" .. i, "Image")

		if uiInfo and uiInfo.Pic and uiInfo.Pic[i] and uiInfo.Pic[i][1] and Img then
			if uiInfo.Pic[i][1] == "" then
				Img.enabled = false
			else
				UIUtil.SetImageSprite(Img, uiInfo.Pic[i][1], self, true)
				Img.gameObject.transform:SetSiblingIndex(uiInfo.Pic[i][2])

				if uiInfo.Pic[i][3] and uiInfo.Pic[i][4] then
					GOUtil.SetRectTransformAnchoredPosition(Img.gameObject, uiInfo.Pic[i][3], uiInfo.Pic[i][4])
				end

				Img.enabled = true
			end
		end
	end

	for i = 1, #uiInfo.Text do
		if uiInfo and uiInfo.Text and uiInfo.Text[i] and uiInfo.Text[i][1] then
			local Text

			if existTextView and i == 2 then
				Text = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Text/Text" .. i, "TextView")
			else
				Text = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Text/Text" .. i, "Text")
			end

			if IsNil(Text) then
				return
			end

			if existTextView and i == 2 then
				Text.Text = Lang(uiInfo.Text[i][1])
			else
				Text.text = Lang(uiInfo.Text[i][1])
			end

			Text.gameObject.transform:SetSiblingIndex(uiInfo.Text[i][2])

			if uiInfo.Text[i][3] and uiInfo.Text[i][4] then
				GOUtil.SetRectTransformAnchoredPosition(Text.gameObject, uiInfo.Text[i][3], uiInfo.Text[i][4])
			end

			if uiInfo.Text[i][5] then
				local distance = 1

				if uiInfo.Text[i][6] then
					distance = uiInfo.Text[i][6]
				end

				GOUtil.SetOutLineColor(Text.gameObject, uiInfo.Text[i][5], distance)
			end
		end
	end
end

function InfoOperationActive:GetOperationGiftBagTypeInfo(type, itemID)
	for i = 1, #OperationUIData do
		if OperationUIData[i].GiftBagType and OperationUIData[i].GiftBagType[1] and OperationUIData[i].GiftBagType[1] == type and OperationUIData[i].GiftBagType[3] == itemID then
			return OperationUIData[i]
		end
	end

	return nil
end

function InfoOperationActive:SetData(pbActiveOperate)
	if pbActiveOperate.awardRecords ~= nil then
		self.pb.awardRecords = pbActiveOperate.awardRecords
	end

	if pbActiveOperate.record ~= nil then
		self.pb.record = pbActiveOperate.record < 0 and 0 or pbActiveOperate.record
	end

	if pbActiveOperate.recordInfos ~= nil then
		self.pb.recordInfos = pbActiveOperate.recordInfos
	end

	if pbActiveOperate.resetTimes ~= nil then
		self.pb.resetTimes = pbActiveOperate.resetTimes
	end

	if pbActiveOperate.loginTime ~= nil and pbActiveOperate.loginTime ~= 0 then
		self.pb.loginTime = pbActiveOperate.loginTime
		OperationActiveMgr.OnLineLoginTime = pbActiveOperate.loginTime

		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

		OperationActiveMgr.OnLineTime = curServerTime - OperationActiveMgr.OnLineLoginTime

		Event.Instance:Fire("UpdateCalendar")
		CalendarRDL.Init()
	end
end

function InfoOperationActive:ChangeAwardRecords(index)
	table.insert(self.pb.awardRecords, index)
end

function InfoOperationActive:IsGetIndexAward(awardIndex)
	local index = awardIndex - 1

	for k, v in pairs(self.pb.awardRecords) do
		if v == index then
			return true
		end
	end

	return false
end

function InfoOperationActive:IsHaveCanRec()
	if self.data.UIType == eOperationActive.Login or self.data.UIType == eOperationActive.Card then
		local index = math.min(self.pb.record, 7)

		for i = 1, index do
			if not self:IsGetIndexAward(i) then
				return true, i
			end
		end

		return false, index
	elseif self.data.UIType == eOperationActive.CommonOne or self.data.UIType == eOperationActive.CommonTwo or self.data.UIType == eOperationActive.CommonThree or self.data.UIType == eOperationActive.CommonFour then
		if self.data.Type == 1 then
			local index = math.min(self.pb.record, #self.data.TypeReward)

			for i = 1, index do
				if not self:IsGetIndexAward(i) then
					return true, i
				end
			end

			return false, index
		elseif self.data.Type == eOperationActiveType.Sign then
			local day = OperationActiveMgr:GetLoginSignDay(self.data.UIType)
			local isGeted = self:IsGetIndexAward(day)

			return not isGeted
		end
	elseif self.data.UIType == eOperationActive.OpenService then
		local index = OperationActiveMgr:GetOpenServiceDay()

		if not self:IsGetIndexAward(index) then
			return true, index
		end
	elseif self.data.UIType == eOperationActive.Register then
		local index = OperationActiveMgr:GetRegisterDay()

		if not self:IsGetIndexAward(index) then
			return true, index
		end
	elseif self.data.UIType == eOperationActive.Level then
		local list = self.data.TypeReward
		local playerLv = PlayerInst:GetCurLv()

		for i = 1, #list do
			if list[i] > 0 and i <= playerLv and not self:IsGetIndexAward(i) then
				return true
			end
		end
	elseif self.data.UIType == eOperationActive.Hour then
		local list = self.data.DailyTime

		for i = 1, #list do
			local startHour = list[i][1]
			local endHour = list[i][2]

			if OperationActiveMgr:IsInTheTime(startHour, endHour) and not self:IsGetIndexAward(i) then
				return true
			end
		end
	elseif self.data.UIType == eOperationActive.Sign then
		local day = OperationActiveMgr:GetLoginSignDay(self.data.UIType)
		local isGeted = self:IsGetIndexAward(day)

		return not isGeted
	elseif self.data.UIType == eOperationActive.OnLine then
		local list = self.data.DailyTime

		for i = 1, #list do
			local sec = list[i][1]
			local isTime = OperationActiveMgr:IsGoAssignOnlineSec(sec)
			local infoOperationActive = OperationActiveMgr:Get(self.data.ID)
			local isGeted = infoOperationActive:IsGetIndexAward(i)

			if isTime and not isGeted then
				return true
			end
		end
	elseif self.data.UIType == eOperationActive.TotalOnLine then
		local list = self.data.DailyTime

		for i = 1, #list do
			local sec = list[i][1]
			local isTime = OperationActiveMgr:IsGoAssignTotalOnlineSec(sec)
			local infoOperationActive = OperationActiveMgr:Get(self.data.ID)
			local isGeted = infoOperationActive:IsGetIndexAward(i)

			if isTime and not isGeted then
				return true
			end
		end
	elseif self.data.UIType == eOperationActive.BattlePass or self.data.UIType == eOperationActive.BattlePass2 then
		local isFlag, index, index2 = self:IsBattlePassAwardDot()

		if isFlag then
			return isFlag, index, index2
		else
			return TaskManager:IsBattlePassTaskDot(), BattlePassTaskMgr:GetBattlePassLevel(), BattlePassTaskMgr:GetBattlePassLevel()
		end
	elseif self.data.UIType == eOperationActive.SmallClass then
		return TaskManager:IsSamllTaskTaskDot()
	elseif self.data.UIType == eOperationActive.RechargeRebate then
		return false
	elseif self.data.UIType == eOperationActive.Birthday then
		local index = OperationActiveMgr:GetBirthdayDay(self)

		if not self:IsGetIndexAward(index) then
			return true, index
		end

		if self.data.DailyTime and self.data.DailyTime[1][1] == index and not self:IsGetIndexAward(#self.data.Params + 1) then
			return true, index
		end
	elseif self.data.UIType == eOperationActive.PlayerBirthday then
		for i = 1, 7 do
			if self:IsGetIndexAward(i) then
				return true
			end
		end

		return false
	elseif self.data.UIType == eOperationActive.BossActivity then
		return false
	elseif self.data.UIType == eOperationActive.RoleBirthdayAward then
		return false
	elseif self.data.UIType == eOperationActive.Jigsaw then
		local list = TaskManager:GetTaskListDataByID(self.data.DailyTime[1][1]).List
		local taskSign = {
			{
				1,
				2,
				3
			},
			{
				4,
				5,
				6
			},
			{
				7,
				8,
				9
			},
			{
				1,
				4,
				7
			},
			{
				2,
				5,
				8
			},
			{
				3,
				6,
				9
			},
			{
				1,
				2,
				3,
				4,
				5,
				6,
				7,
				8,
				9
			}
		}

		local function IsGet(index)
			for _, value in pairs(self.pb.awardRecords) do
				if value == index - 1 then
					return true
				end
			end

			return false
		end

		local function CanGet(index)
			local target = #taskSign[index]
			local num = 0

			for key, value in pairs(taskSign[index]) do
				local task = TaskManager:Get(list[value])

				if task:IsComplete() then
					num = num + 1
				else
					return false
				end
			end

			return num == target
		end

		for key, value in pairs(taskSign) do
			if CanGet(key) and not IsGet(key) then
				return true
			end
		end
	elseif self.data.UIType == eOperationActive.URCardPool then
		local hasCanRec = false
		local list = TaskManager:GetTaskListDataByID(self.data.DailyTime[1][1]).List

		for k, v in pairs(list) do
			local info = TaskManager:Get(v)

			if not info:IsGetAward() then
				hasCanRec = true

				break
			end
		end

		return hasCanRec
	end

	return false
end

function InfoOperationActive:IsBattlePassAwardDot()
	local taskListData = TaskManager:GetTaskListData(eTaskListType.battlePass)
	local index = BattlePassTaskMgr:GetBattlePassLevel()
	local index2 = index
	local isFlag = false
	local list = BattlePassTaskMgr:GetBattlePassAwardList()

	for i = 1, index do
		if TaskManager:IsRecvedScoreAward(taskListData.ID, i - 1) == false then
			index = i
			isFlag = true

			if list.ScoreSectionReward and list.ScoreSectionReward[i] and list.ScoreSectionReward[i][1] and list.ScoreSectionReward[i][1][1] then
				-- block empty
			else
				isFlag = false
			end

			if isFlag then
				break
			end
		end
	end

	for i = 1, index2 do
		if TaskManager:IsRecvedPayScoreAward(taskListData.ID, i - 1) == false and ShopManager:GetMonthIdState(taskListData.ActivePayId) then
			index2 = i
			isFlag = true

			break
		end
	end

	return isFlag, index, index2
end

function InfoOperationActive:IsCanGet(awardIndex, type)
	if type == eOperationActive.OpenService then
		if awardIndex <= OperationActiveMgr:GetOpenServiceDay() and not self:IsGetIndexAward(awardIndex) then
			return true
		end
	elseif type == eOperationActive.Register then
		if awardIndex <= OperationActiveMgr:GetRegisterDay() and not self:IsGetIndexAward(awardIndex) then
			return true
		end
	elseif awardIndex <= self.pb.record and not self:IsGetIndexAward(awardIndex) then
		return true
	end

	return false
end

function InfoOperationActive:IsBegin()
	local startTime = self.data.StartTime

	if startTime == "" then
		return true
	end

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local beginTime = GetTimeTampByString(startTime)

	if curServerTime < beginTime then
		return false
	end

	return true
end

function InfoOperationActive:IsExpire()
	local endTime = self.data.EndTime

	if endTime == "" then
		return false
	end

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local overTime = GetTimeTampByString(endTime)

	if overTime < curServerTime then
		return true
	end

	return false
end

function InfoOperationActive:IsOpening(uiType)
	if uiType == eOperationActive.Birthday or uiType == eOperationActive.RoleBirthdayAward then
		return self:OnMonthAndDay()
	end

	return self:IsBegin() and not self:IsExpire()
end

function InfoOperationActive:OnMonthAndDay()
	local startTime = self.data.StartTime

	if startTime == "" then
		return false
	end

	local endTime = self.data.EndTime

	if endTime == "" then
		return false
	end

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local curYear = os.date("%Y", curServerTime)
	local timeStr = os.date("%Y-%m-%d %H:%M:%S", curServerTime)
	local startA = string.split(startTime, " ")
	local endA = string.split(endTime, " ")

	if #startA == 2 and #endA then
		local startDay = string.split(startA[1], "-")
		local startTime = string.split(startA[2], ":")
		local endDay = string.split(endA[1], "-")
		local endTime = string.split(endA[2], ":")

		if #startDay == 3 and #startTime == 3 and #endDay == 3 and #endTime == 3 then
			local startMonthT = tonumber(startDay[2])
			local startDayT = tonumber(startDay[3])
			local endMonthT = tonumber(endDay[2])
			local endDayT = tonumber(endDay[3])
			local beginTime = GetTimeTampByString(curYear .. "-" .. startMonthT .. "-" .. startDayT .. " " .. startA[2])
			local overTime = GetTimeTampByString(curYear .. "-" .. endMonthT .. "-" .. endDayT .. " " .. endA[2])
			local listBirthdayAward = OperationActiveMgr:GetActiveRewardItems(self.data.ID)

			if listBirthdayAward.award then
				local count = #listBirthdayAward.award

				overTime = beginTime + count * 86400
			end

			local isBegin = false

			if beginTime <= curServerTime and curServerTime <= overTime then
				isBegin = true
			elseif os.date("%Y", beginTime) < os.date("%Y", overTime) then
				local str = os.date("%Y-%m-%d %H:%M:%S", curServerTime)
				local strA = string.split(str, " ")
				local strDay = string.split(strA[1], "-")

				str = string.format("%s-%s-%s %s", curYear + 1, strDay[2], strDay[3], strA[2])
				curServerTime = GetTimeTampByString(str)

				if beginTime <= curServerTime and curServerTime <= overTime then
					isBegin = true
				end
			end

			return isBegin, curServerTime, beginTime, overTime
		end
	end

	return false
end

function InfoOperationActive:IsBeginShow()
	local showStartTime = self.data.ShowStartTime

	if showStartTime == "" then
		return true
	end

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local beginTime = GetTimeTampByString(showStartTime)

	if curServerTime < beginTime then
		return false
	end

	return true
end

function InfoOperationActive:IsEndShow()
	local showEndTime = self.data.ShowEndTime

	if showEndTime == "" then
		return false
	end

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local overTime = GetTimeTampByString(showEndTime)

	if overTime < curServerTime then
		return true
	end

	return false
end

function InfoOperationActive:IsShowing()
	return self:IsBeginShow() and not self:IsEndShow()
end

function InfoOperationActive:GetName()
	return Lang(self.data.Name)
end

OperationActiveMgr = {}

local dictActive = {}

OperationActiveMgr.OnLineTime = 0
OperationActiveMgr.OnLineLoginTime = 0
OperationActiveMgr.Tag = 1
OperationActiveMgr.BattlePassTag = "Tab1"
OperationActiveMgr.needTips = true
OperationActiveMgr.PageOperationActiveType = 1
OperationActiveMgr.PagRechargeRebateType = 1
OperationActiveMgr.firstChargeType = 2
OperationActiveMgr.UpdateOperationFlag = false
OperationActiveMgr.BossActivityPopupIndex = 1
OperationActiveMgr.PageMainShowGroup2ListState = true
OperationActiveMgr.PlayerBirthdayEnterPace = false
OperationActiveMgr.RoleBirthdayVideoClip = nil
OperationActiveMgr.RoleBirthdayPopupIndex = 1
OperationActiveMgr.isShowWebView = false
OperationActiveMgr.isAuto = false

function OperationActiveMgr:Get(id)
	local ret = dictActive[id]

	if not ret then
		ret = InfoOperationActive(id)
		dictActive[id] = ret
	end

	if ret.data == nil then
		PrintWithColor(string.format("Active [%d] is not exist!", tostring(id)), "yellow")
	end

	return ret
end

function OperationActiveMgr:RefreshRecord()
	for _, v in pairs(dictActive) do
		v.pb.record = v.pb.record + 1

		if v.id == 3 then
			v.pb.awardRecords = {}
		end
	end
end

function OperationActiveMgr:SetData(pbActiveOperates)
	for i = 1, #pbActiveOperates do
		local v = pbActiveOperates[i]
		local activeId = v.id
		local info = self:Get(activeId)

		info:SetData(v)
	end
end

function OperationActiveMgr.GetPlayerBirthdayActiveID()
	for _, activeData in pairs(OperationData) do
		if activeData.UIType == eOperationActive.PlayerBirthday then
			return activeData.ID
		end
	end

	return 0
end

function OperationActiveMgr:GetListOpenActive()
	local list = {}
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	for k in pairs(OperationData) do
		local infoOperationActive = self:Get(k)

		if infoOperationActive.data.Type == eOperationActiveType.OpenService then
			local _, isOpen = OperationActiveMgr:GetOpenServiceDay()

			if isOpen then
				table.insert(list, infoOperationActive)
			end
		elseif infoOperationActive.data.Type == eOperationActiveType.Registered then
			local _, isOpen = OperationActiveMgr:GetRegisterDay()

			if isOpen then
				table.insert(list, infoOperationActive)
			end
		elseif not infoOperationActive:IsOpening(infoOperationActive.data.UIType) or infoOperationActive.data.UIType == 0 or infoOperationActive.data.UIType == eOperationActive.RechargeRebate and NoPay then
			-- block empty
		elseif infoOperationActive.data.UIType == eOperationActive.PlayerBirthday and self:IsPlayerBirthday() and not infoOperationActive:IsHaveCanRec() then
			table.insert(list, infoOperationActive)
		elseif infoOperationActive.data.UIType == eOperationActive.RoleBirthdayAward then
			table.insert(list, infoOperationActive)
		elseif infoOperationActive.data.UIType == eOperationActive.URCardPool then
			if infoOperationActive:IsHaveCanRec() then
				table.insert(list, infoOperationActive.data.ID, infoOperationActive)
			end
		elseif infoOperationActive.data.UIType ~= eOperationActive.PlayerBirthday then
			if (infoOperationActive.data.UIType == eOperationActive.BattlePass or infoOperationActive.data.UIType == eOperationActive.BattlePass2) and TutorialMgr:IsOpenNoMsg(TutorialFunctionType.OperationActive_BattlePass) then
				table.insert(list, infoOperationActive)
			elseif infoOperationActive.data.UIType ~= eOperationActive.BattlePass and infoOperationActive.data.UIType ~= eOperationActive.BattlePass2 then
				table.insert(list, infoOperationActive)
			end
		end
	end

	local function func(a, b)
		if a.data.PageSort == b.data.PageSort then
			return a.data.ID < b.data.ID
		else
			return a.data.PageSort < b.data.PageSort
		end
	end

	table.sort(list, func)

	return list
end

function OperationActiveMgr:GetActiveRewardItems(activeId)
	local info = self:Get(activeId)
	local list = {}

	if info.data.Type == 7 or info.data.Type == 8 then
		for k, v in pairs(info.data.DailyTime) do
			local temp = {}

			temp.index = k
			temp.online = v[1]
			temp.award = RewardData[v[2]].ItemList

			table.insert(list, temp)
		end
	elseif info.data.Type == 3 then
		for k, v in pairs(info.data.DailyTime) do
			local temp = {}

			temp.index = k
			temp.hour = {
				v[1],
				v[2]
			}
			temp.award = RewardData[v[3]].ItemList

			table.insert(list, temp)
		end
	elseif info.data.Type == eOperationActiveType.AssignLogin then
		list.award = {}

		for k, v in pairs(info.data.Params) do
			if v[2] ~= 0 then
				local temp = {}

				temp.index = v[1]
				temp.award = RewardData[v[2]].ItemList
				temp.isExtra = v[3]

				table.insert(list.award, temp)
			end
		end

		for k, v in pairs(info.data.DailyTime) do
			list.extraAward = {}

			if v[2] ~= 0 then
				local temp = {}

				temp.extraIndex = v[1]
				temp.extraAward = RewardData[v[2]].ItemList

				table.insert(list.extraAward, temp)
			end
		end
	elseif info.data.Type == 19 then
		for k, v in pairs(info.data.Params) do
			if v[2] ~= 0 then
				local temp = {}

				temp.index = v[1]
				temp.award = RewardData[v[2]].ItemList

				table.insert(list, temp)
			end
		end
	elseif info.data.Type == 10 then
		list.ScoreSectionReward = {}
		list.PayScoreSectionReward = {}

		local award = BattlePassTaskMgr:GetBattlePassAwardList()

		if award and award.ScoreSectionReward then
			for k, v in pairs(award.ScoreSectionReward) do
				local temp = {}

				temp.index = k
				temp.award = {}

				for i = 1, #v do
					if v[i][1] then
						temp.isCard = TenaryOp(v[i][1] == 10100, 2, 1)

						table.insert(temp.award, v[i])
					end
				end

				table.insert(list.ScoreSectionReward, temp)
			end
		end

		if award and award.PayScoreSectionReward then
			for k, v in pairs(award.PayScoreSectionReward) do
				local temp = {}

				temp.index = k
				temp.award = {}

				for i = 1, #v do
					if v[i][1] then
						temp.isCard = TenaryOp(v[i][1] == 10100, 2, 1)

						table.insert(temp.award, v[i])
					end
				end

				table.insert(list.PayScoreSectionReward, temp)
			end
		end
	elseif info.data.Type == 4 then
		for k, v in pairs(info.data.TypeReward) do
			if v ~= 0 and not self:JPHideExpiredDay(info, k) then
				local temp = {}

				temp.index = k
				temp.award = RewardData[v].ItemList
				temp.isCard = TenaryOp(RewardData[v].ItemList[1][1] == 10100, 2, 1)
				temp.extraReward = RewardData[v].ExtraReward

				table.insert(list, temp)
			end
		end
	else
		for k, v in pairs(info.data.TypeReward) do
			if v ~= 0 then
				local temp = {}

				temp.index = k
				temp.award = RewardData[v].ItemList
				temp.isCard = TenaryOp(RewardData[v].ItemList[1][1] == 10100, 2, 1)
				temp.extraReward = RewardData[v].ExtraReward

				table.insert(list, temp)
			end
		end
	end

	return list
end

function OperationActiveMgr:JPHideExpiredDay(info, day)
	local expired = false
	local currY, currM, currD = DateUtil.GetYearsMonthAndDay(NetData:GetCurServerTime())
	local getConfigServerTimeStr = GetConfigArgString("GameServerStartTime")

	if getConfigServerTimeStr == 0 then
		return expired
	end

	local confY, confM, confD = GetTimeByString(getConfigServerTimeStr)

	if currY == confY and currM == confM and day < confD then
		expired = true
	end

	return expired
end

function OperationActiveMgr:IsInTheTime(startHour, endHour)
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local hour = tonumber(os.date("%H", curServerTime))

	if startHour <= hour and hour < endHour then
		return true
	end

	return false
end

function OperationActiveMgr:IsInTheOnLine(online, pbOnLine)
	if pbOnLine <= online then
		return true
	end

	return false
end

function OperationActiveMgr:GetListLevelAward(id)
	local list = self:GetActiveRewardItems(id)
	local listGeted = {}

	for i = #list, 1, -1 do
		local isGet = infoActive:IsGetIndexAward(list[i].index)

		if isGet then
			table.insert(listGeted, list[i])
			table.remove(list, i)
		end
	end

	local function func(a, b)
		return a.index < b.index
	end

	table.sort(listGeted, func)

	for i = 1, #listGeted do
		table.insert(list, listGeted[i])
	end

	return list
end

function OperationActiveMgr:AllHaveCanRecvAward()
	local listActive = self:GetListOpenActive()

	for k, v in pairs(listActive) do
		if v and v:IsHaveCanRec() then
			return true
		end
	end

	return false
end

function OperationActiveMgr:AllLoginPopupList()
	if SystemMaintainMgr:Deal(SystemMaintainType.operation) then
		return {}
	end

	local listActive = self:GetListOpenActive()
	local PoPupList = {}
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	for k, v in pairs(listActive) do
		if v then
			if v.data.Popup == 1 and v:IsHaveCanRec() then
				if v.data.Popup == 1 and v.data.UIType ~= eOperationActive.BossActivity or v.data.UIType ~= eOperationActive.RoleBirthdayAward then
					table.insert(PoPupList, v)
				end
			elseif v.data.Popup == 1 and v.data.UIType == eOperationActive.RechargeRebate then
				table.insert(PoPupList, v)
			elseif v.data.Popup == 1 and v.data.UIType == eOperationActive.PlayerBirthday and self:IsPlayerBirthday() and not OperationActiveMgr.PlayerBirthdayEnterPace then
				table.insert(PoPupList, v)
			elseif v.data.Popup == 1 and v.data.UIType == eOperationActive.BossActivity and OperationActiveMgr.BossActivityPopupIndex == 1 then
				table.insert(PoPupList, v)
			elseif v.data.Popup == 1 and v.data.UIType == eOperationActive.RoleBirthdayAward and v.data.DailyTime[1] and OperationActiveMgr.RoleBirthdayPopupIndex == 1 and not self:IsBuyRoleBirthdayAward(v) then
				table.insert(PoPupList, v)
			end
		end
	end

	local luckyBackList = GoodsInfoListMgr:GetLuckyList()
	local v = OperationData[26]

	for key, value in pairs(luckyBackList) do
		if value.isShow == false then
			for m = 1, #v.Params[1] do
				if v.Params[1][m] == value.data.ID then
					local info = OperationActiveMgr:Get(v.ID)
					local copy = {}

					copy.data = info.data
					copy.pb = info.pb
					copy.CycleType = key
					copy.id = info.id
					copy.isClass = info.isClass
					copy.lastRecvTime = info.lastRecvTime

					table.insert(PoPupList, copy)
				end
			end
		end
	end

	local function func(a, b)
		if a.data.UITypeSort == b.data.UITypeSort then
			return a.data.ID < b.data.ID
		else
			return a.data.UITypeSort < b.data.UITypeSort
		end
	end

	table.sort(PoPupList, func)

	return PoPupList
end

function OperationActiveMgr:GetRoleBirthdayAwardList()
	if SystemMaintainMgr:Deal(SystemMaintainType.operation) then
		return {}
	end

	local listActive = self:GetListOpenActive()
	local PoPupList = {}

	for k, v in pairs(listActive) do
		if v and v.data.Popup == 1 and v.data.UIType == eOperationActive.RoleBirthdayAward and not self:IsBuyRoleBirthdayAward(v) then
			table.insert(PoPupList, v)
		end
	end

	return PoPupList
end

function OperationActiveMgr:IsBuyRoleBirthdayAward(infoActive)
	local goodsID = infoActive.data.DailyTime[1][1]
	local itemInfo = ShopManager:GetProduct(goodsID)
	local curTimeStamp = Mathf.Round(NetData:GetCurServerTime() / DateUtil.MillsPerSecond)
	local today = os.date("*t", curTimeStamp)

	if itemInfo.data.CostType == 1 then
		for index, value in ipairs(InfoGameInst.gameInfo.birthdayGoods) do
			if value.id == goodsID then
				local year = os.date("*t", tonumber(value.buyTimes)).year

				if today.year == year then
					return true
				end
			end
		end
	else
		for index, value in ipairs(ItemManager.GoodIdList) do
			if value.id == goodsID then
				local year = os.date("*t", tonumber(value.updateTime)).year

				if today.year == year then
					return true
				end
			end
		end
	end

	return false
end

function OperationActiveMgr:GetLoginSignDay(UIType)
	do return self:JPGetLoginSignDay(UIType) end

	local listActive = self:GetListOpenActive()
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	for k, v in pairs(listActive) do
		if v and v.data.Type == 4 and v.data.UIType == UIType and v.data.Popup == 1 then
			local ShowStartTime = GetTimeTampByString(v.data.ShowStartTime)
			local ShowEndTime = GetTimeTampByString(v.data.ShowEndTime)

			if ShowStartTime < curServerTime and curServerTime < ShowEndTime then
				local ShowStartTime = GetTimeTampByString(v.data.ShowStartTime)
				local day = math.ceil((curServerTime - ShowStartTime) / 86400)

				return tonumber(day)
			end
		end
	end

	return 0
end

function OperationActiveMgr:JPGetLoginSignDay(UIType)
	local currY, currM, currD = DateUtil.GetYearsMonthAndDay(NetData:GetCurServerTime())
	local getConfigServerTimeStr = GetConfigArgString("GameServerStartTime")
	local confY, confM, confD = GetTimeByString(getConfigServerTimeStr)
	local listActive = self:GetListOpenActive()
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	for k, v in pairs(listActive) do
		if v and v.data.Type == 4 and v.data.UIType == UIType and v.data.Popup == 1 then
			local ShowStartTime = GetTimeTampByString(v.data.ShowStartTime)
			local ShowEndTime = GetTimeTampByString(v.data.ShowEndTime)
			local GameServerStartTime = GetTimeTampAccurateToDay(getConfigServerTimeStr)

			if ShowStartTime < curServerTime and curServerTime < ShowEndTime then
				local ShowStartTime = GetTimeTampByString(v.data.ShowStartTime)
				local day = 0

				if currY == confY and currM == confM then
					day = math.floor((curServerTime - GameServerStartTime) / 86400) + confD
				else
					day = math.ceil((curServerTime - ShowStartTime) / 86400)
				end

				return tonumber(day)
			end
		end
	end

	return 0
end

function OperationActiveMgr:GetLoginSignRetroactiveDay(infoActive)
	for i = 1, self:GetLoginSignDay(infoActive.data.UIType) do
		local isGeted = infoActive:IsGetIndexAward(i)

		if not isGeted then
			return i
		end
	end

	return 0
end

function OperationActiveMgr:JPGetLoginSignRetroactiveDay(infoActive)
	local currY, currM, currD = DateUtil.GetYearsMonthAndDay(NetData:GetCurServerTime())
	local getConfigServerTimeStr = GetConfigArgString("GameServerStartTime")
	local confY, confM, confD = GetTimeByString(getConfigServerTimeStr)

	local function fun(infoActive, isGameServerStartTime, currD)
		for i = 1, self:GetLoginSignDay(infoActive.data.UIType) do
			local isGeted = infoActive:IsGetIndexAward(i)

			if isGameServerStartTime then
				if not isGeted and i >= confD then
					return i
				end
			elseif not isGeted then
				return i
			end
		end

		return 0
	end

	if currY == confY and currM == confM then
		return fun(infoActive, true, currD)
	else
		return fun(infoActive, false, currD)
	end
end

function OperationActiveMgr:JPIsCurrDaySmallThanGameStartDay()
	local currY, currM, currD = DateUtil.GetYearsMonthAndDay(NetData:GetCurServerTime())
	local getConfigServerTimeStr = GetConfigArgString("GameServerStartTime")
	local confY, confM, confD = GetTimeByString(getConfigServerTimeStr)
	local result = false

	if currY == confY and currM == confM and currD < confD then
		result = true
	end

	return result
end

function OperationActiveMgr:GetOpenServiceDay()
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local openServerTime = InfoGameInst:GetOpenServerTime() + 31536000

	openServerTime = "20" .. os.date("%y-%m-%d ", openServerTime) .. "04:00:00"
	openServerTime = GetTimeTampByString(openServerTime)

	local isOpen = false

	if openServerTime < curServerTime and curServerTime < openServerTime + 31536000 then
		isOpen = true
	end

	local day = math.ceil((curServerTime - openServerTime) / 86400)

	if day > 7 then
		day = 7
	end

	return tonumber(day), isOpen
end

function OperationActiveMgr:GetRegisterDay()
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local registerTime = PlayerInst.InfoPlayer:GetRegisterTime()

	registerTime = "20" .. os.date("%y-%m-%d ", registerTime) .. "04:00:00"
	registerTime = GetTimeTampByString(registerTime)

	local isOpen = false

	if registerTime < curServerTime and curServerTime < registerTime + 31536000 then
		isOpen = true
	end

	local day = math.ceil((curServerTime - registerTime) / 86400)

	if day > 7 then
		day = 7
	end

	return tonumber(day), isOpen
end

function OperationActiveMgr:IsAutoShowWebView()
	if OperationActiveMgr.isShowWebView then
		return false
	end

	if not TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Webview) then
		return false
	end

	if InfoGameInst.gameInfo.webType == eWebviewShowType.None then
		return false
	end

	if InstructionMgr:IsInGuide() then
		return false
	end

	local time = PersistentStoreUtil.GetInt("DlgWebIsNotAagin", 0)

	if not TimeIsNotToday(time * 1000) then
		return false
	end

	return true
end

function OperationActiveMgr:GetOpenTime(strTime)
	local str = ""
	local playEndTime = GetTimeTampByString(strTime)
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	playEndTime = playEndTime - curServerTime

	local d, h, m, s = GetTimeFormatBySec(playEndTime)

	if d == 0 and h == 0 then
		if m == 0 then
			return _("Desc_ActivityRemain") .. m .. _("Desc_minute") .. s .. _("Desc_second")
		end

		return _("Desc_ActivityRemain") .. h .. _("Desc_hour") .. m .. _("Desc_minute")
	end

	return _("Desc_ActivityRemain") .. d .. _("Desc_day") .. h .. _("Desc_hour")
end

function OperationActiveMgr:GetEndTime(strTime)
	local str = ""
	local playEndTime = GetTimeTampByString(strTime)
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	playEndTime = playEndTime - curServerTime

	local d, h, m, s = GetTimeFormatBySec(playEndTime)

	if d == 0 and h == 0 then
		if m == 0 then
			return m .. _("Desc_minute") .. s .. _("Desc_second")
		end

		return h .. _("Desc_hour") .. m .. _("Desc_minute")
	end

	return d .. _("Desc_day") .. h .. _("Desc_hour")
end

function OperationActiveMgr:GetDayHourTime(strTime)
	local str = ""
	local playEndTime = GetTimeTampByString(strTime)
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	playEndTime = playEndTime - curServerTime

	local d, h, m, s = GetTimeFormatBySec(playEndTime)

	return d .. _("Desc_day") .. h .. _("Desc_hour")
end

function OperationActiveMgr:GetRemainTime(strTime)
	local str = ""
	local playEndTime = strTime
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	playEndTime = playEndTime - curServerTime

	local d, h, m, s = GetTimeFormatBySec(playEndTime)

	if d ~= 0 then
		return d .. _("Desc_day")
	else
		return h .. _("Desc_hour")
	end
end

function OperationActiveMgr:JPGetRemainTime(strTime)
	local str = ""
	local playEndTime = strTime
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	playEndTime = playEndTime - curServerTime

	local d, h, m, s = GetTimeFormatBySec(playEndTime)

	if d ~= 0 then
		return d .. _("Desc_day")
	elseif h ~= 0 then
		return h .. _("Desc_hour")
	elseif m > 1 then
		return m .. _("Desc_minute")
	else
		return _("Remain_One_Minute")
	end
end

function OperationActiveMgr:GetRemainTimeNew(strTime)
	local str = ""
	local playEndTime = strTime
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	playEndTime = playEndTime - curServerTime

	local d, h, m, s = GetTimeFormatBySec(playEndTime)

	if d ~= 0 then
		return d .. _("Desc_day")
	elseif d == 0 and h ~= 0 then
		return h .. _("Desc_hour")
	elseif d == 0 and h == 0 and m ~= 0 then
		return m .. _("Desc_minute")
	else
		return s .. _("Desc_second")
	end
end

function OperationActiveMgr:IsGoAssignOnlineSec(sec)
	local onlineSec = math.floor(OperationActiveMgr.OnLineTime / 60)

	if sec <= onlineSec then
		return true
	else
		return false
	end
end

function OperationActiveMgr:IsGoAssignTotalOnlineSec(sec)
	local onlineSec = math.floor((OperationActiveMgr.OnLineTime + InfoGameInst:GetOnlineTime()) / 60)

	if sec <= onlineSec then
		return true
	else
		return false
	end
end

function OperationActiveMgr:GetTotalOnlineInfo()
	for k, v in ipairs(OperationData) do
		local infoOperationActive = self:Get(k)

		if infoOperationActive.data.Type == 15 then
			return v
		end
	end

	return false
end

function OperationActiveMgr:GetBirthdayDay(info)
	local isBegin, curServerTime, beginTime = info:OnMonthAndDay()
	local day = math.ceil((curServerTime - beginTime) / 86400)

	return tonumber(day)
end

function OperationActiveMgr:GetBirthdayDayTime(info, day)
	local isBegin, curServerTime, beginTime = info:OnMonthAndDay()
	local ShowStartTime = beginTime

	ShowStartTime = ShowStartTime + (day - 1) * 86400

	return os.date("%m/%d", ShowStartTime)
end

function OperationActiveMgr:GetTotalOnlineSec()
	if not self.onLineInfo then
		self.dailyTimeValue = 0
		self.onLineInfo = OperationActiveMgr:Get(self:GetTotalOnlineInfo().ID)
		self.DailyTime = self.onLineInfo.data.DailyTime

		for i = 1, #self.DailyTime do
			local isGeted = self.onLineInfo:IsGetIndexAward(i)

			if isGeted then
				self.dailyTimeValue = i
			end
		end
	end

	local nextTime

	if self.onLineInfo then
		nextTime = self.DailyTime[self.dailyTimeValue + 1]
	end

	if self.dailyTimeValue == #self.DailyTime then
		return "00:00", nil, self.DailyTime[self.dailyTimeValue][1], self.onLineInfo
	else
		local onlineSec = math.floor(nextTime[1] * 60 - (OperationActiveMgr.OnLineTime + self.onLineInfo.pb.record))
		local onlineMin = math.floor((OperationActiveMgr.OnLineTime + self.onLineInfo.pb.record) / 60)

		if onlineSec < 0 then
			return "00:00", false, onlineMin, self.onLineInfo
		else
			local time = DateUtil.GetMoment00(onlineSec)

			return time, true, onlineMin, self.onLineInfo
		end
	end
end

function OperationActiveMgr:GetOnlineMin()
	if not self.onLineInfo then
		self.dailyTimeValue = 0
		self.onLineInfo = OperationActiveMgr:Get(self:GetTotalOnlineInfo().ID)
		self.DailyTime = self.onLineInfo.data.DailyTime

		for i = 1, #self.DailyTime do
			local isGeted = self.onLineInfo:IsGetIndexAward(i)

			if isGeted then
				self.dailyTimeValue = i
			end
		end
	end

	local onlineMin = math.floor((OperationActiveMgr.OnLineTime + self.onLineInfo.pb.record) / 60)

	return onlineMin, self.onLineInfo
end

function OperationActiveMgr:SetTotalOnlineInfoState()
	self.onLineInfo = nil
end

function OperationActiveMgr:GetRewardPackData(packId)
	return RewardData[packId]
end

function OperationActiveMgr:GetAllTypeList(type)
	local list = {}

	for k, _ in pairs(OperationData) do
		local infoOperationActive = self:Get(k)

		if infoOperationActive.data.Type == type then
			table.insert(list, infoOperationActive)
		end
	end

	return list
end

function OperationActiveMgr:CheckFirstRechargeExist()
	local listFirstInfo = OperationActiveMgr:GetAllTypeList(12)

	for i, v in ipairs(listFirstInfo) do
		if v:IsOpening() then
			local chargeStage = v.data.DailyTime[1]

			if #v.pb.awardRecords ~= #chargeStage then
				return true, v
			end
		end
	end

	return false
end

function OperationActiveMgr:RequestChargeActiveData(infoProduct)
	if infoProduct.data.ProductType > 0 then
		local exist, firstInfo = OperationActiveMgr:CheckFirstRechargeExist()

		if exist then
			local needProductType = firstInfo.data.DailyTime[2]

			if table.contains(needProductType, 0) or table.contains(needProductType, infoProduct.data.ProductType) then
				firstInfo.pb.record = firstInfo.pb.record + infoProduct.data.CostValue[1]
			end
		end

		local rebateInfo = OperationActiveMgr:GetRechargeRebate()

		if rebateInfo then
			rebateInfo.pb.record = rebateInfo.pb.record + infoProduct.data.CostValue[1]
		end
	end

	if infoProduct.data.CostType == 1 then
		local data = OperationActiveMgr.GetAccumulatedRechargeData()
		local info = OperationActiveMgr:Get(data.ID)

		info.pb.record = info.pb.record + infoProduct:GetCost()

		ShopRDL.RunAccRD()
	end
end

function OperationActiveMgr:GetRechargeRebate()
	local listFirstInfo = OperationActiveMgr:GetAllTypeList(13)

	for i, v in ipairs(listFirstInfo) do
		if v:IsOpening() then
			return v
		end
	end

	return nil
end

local ActiveShowType = {
	inside = 2,
	outside = 1
}

local function CanUse(id)
	local info = OperationActiveMgr:Get(id)

	return info:IsOpening()
end

function OperationActiveMgr:GetSkillData(id)
	return OperationData[id]
end

function OperationActiveMgr:GetUsefulSkill()
	local list = {}

	for k, v in pairsByKeys(OperationData) do
		if v.Type == 16 and CanUse(v.ID) then
			table.insert(list, v)
		end
	end

	return list
end

function OperationActiveMgr:GetStrLeftDay(id)
	local data = self:GetSkillData(id)
	local curServerTime = NetData:GetCurServerTime()
	local str = _("Desc_Forever")

	if data.EndTime ~= "0" then
		local endTime = GetTimeTampByString(data.EndTime) * DateUtil.MillsPerSecond
		local val = DateUtil.GetDayMomentByMillis(endTime - curServerTime)

		if val == "" then
			local second = (endTime - curServerTime) / DateUtil.MillsPerSecond
			local hour = math.floor(second / 3600)

			if hour >= 1 then
				val = hour .. _("Desc_hour")
			else
				local minute = math.floor(second / 60 + 0.5)

				val = minute .. _("Desc_minute")
			end
		end

		str = _("Desc_RemainingTime") .. val
	end

	return str
end

function OperationActiveMgr:GetStrLeftHour(id)
	local data = self:GetSkillData(id)
	local curServerTime = NetData:GetCurServerTime()
	local str = _("Desc_Forever")

	if data.EndTime ~= "0" then
		local endTime = GetTimeTampByString(data.EndTime) * DateUtil.MillsPerSecond
		local val = DateUtil.GetTwoMomentByMillis(endTime - curServerTime)

		str = _("Desc_RemainingTime") .. val
	end

	return str
end

function OperationActiveMgr:GetUsefulSkillByStageId(stageId)
	local infoStage = ChapterMgr:GetStage(stageId)
	local actType = infoStage.data.ActType
	local chapterId = infoStage.data.ChapterID
	local temp = {}
	local list = self:GetUsefulSkill()

	for i = 1, #list do
		local Acting = list[i].BuffType

		for j = 1, #Acting do
			if Acting[j][1] == 0 then
				table.insert(temp, list[i])

				break
			elseif Acting[j][1] == 1 and Acting[j][2] == actType then
				table.insert(temp, list[i])

				break
			elseif Acting[j][1] == 2 and Acting[j][2] == chapterId then
				table.insert(temp, list[i])

				break
			elseif Acting[j][1] == 3 and Acting[j][2] == stageId then
				table.insert(temp, list[i])

				break
			end
		end
	end

	return temp
end

function OperationActiveMgr:CheakIsActiveByCardId(cardId, info)
	local infoRole = RoleCardMgr:GetRole(cardId)

	for i, v in ipairs(info.Params) do
		if v[1] == 0 or v[1] == 1 and v[2] == infoRole.job or v[1] == 2 and v[2] == infoRole.data.Team or v[1] == 3 and v[2] == infoRole.data.ID or v[1] == 4 and v[2] == cardId then
			return true
		end
	end

	return false
end

function OperationActiveMgr:GetAllSkillDataInside(stageId)
	return OperationActiveMgr:GetAllSkillData(stageId, ActiveShowType.inside)
end

function OperationActiveMgr:GetAllSkillDataOutside(stageId)
	return OperationActiveMgr:GetAllSkillData(stageId, ActiveShowType.outside)
end

function OperationActiveMgr:GetAllSkillData(stageId, type)
	local skillUsefulList = OperationActiveMgr:GetUsefulSkillByStageId(stageId)
	local AllSkillData = {}

	for _, v in ipairs(skillUsefulList) do
		for _, ActiveObject in ipairs(v.Params) do
			if v.BuffShowType == type then
				for _, skillId in ipairs(v.BuffSkillID) do
					local data = {}

					data.Params = ActiveObject
					data.SkillId = skillId
					data.ID = v.ID

					table.insert(AllSkillData, data)
				end
			end
		end
	end

	return AllSkillData
end

function OperationActiveMgr:GetStrSkillTipDesc(Params)
	if Params[1] == 0 then
		return ""
	elseif Params[1] == 1 then
		return string.format(_("Desc_BattleEffectiveOccupation"), _("eJobWord_" .. GetConfigArgJson("JobNumber")[Params[2]]))
	elseif Params[1] == 2 then
		return string.format(_("Desc_BattleEffectiveTeam"), Lang(CharacterTeam[Params[2]].Name))
	elseif Params[1] == 3 then
		return string.format(_("Desc_BattleEffectiveIdol"), RoleMgr:GetRole(Params[2]):GetName())
	elseif Params[1] == 4 then
		return string.format(_("Desc_BattleEffectiveCard"), RoleCardMgr:GetRoleCard(Params[2]):GetName())
	end
end

function OperationActiveMgr:GetBattlePassMonthIdState()
	local tasklist = TaskManager:GetTaskListData(eTaskListType.battlePass)

	if tasklist == nil then
		return nil, nil
	end

	local GoodsId = tasklist.ActivePayId
	local State

	if GoodsId then
		State = ShopManager:GetMonthIdState(GoodsId)
	end

	return GoodsId, State
end

function OperationActiveMgr:GetPlayerBirthdayState()
	local str = PersistentStoreUtil.GetString(PersistentStoreUtil.KEY_PLAYER_BIRTHDAY_STATE)

	if str == "" then
		str = "1_0"

		return str
	else
		return str
	end
end

function OperationActiveMgr:SetPlayerBirthdayState(time, state)
	time = os.date("%y/%m/%d", NetData:GetCurServerTime() / DateUtil.MillsPerSecond)
	str = time .. "_" .. state

	local bornTime = PlayerInst:GetBirthday()

	PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_PLAYER_BIRTHDAY_STATE, str)

	state = OperationActiveMgr:GetPlayerBirthdayState()
end

function OperationActiveMgr:IsPlayerLoginBirthday()
	local state = OperationActiveMgr:GetPlayerBirthdayState()
	local bornTime = PlayerInst:GetBirthday()
	local month = math.floor(bornTime / 100)
	local day = bornTime % 100
	local birthdayStr = string.format("%02d/%02d/%02d", 0, month, day)
	local curTimeStr = os.date("%y/%m/%d", NetData:GetCurServerTime() / DateUtil.MillsPerSecond)

	if string.split(curTimeStr, "/")[2] == string.split(birthdayStr, "/")[2] and string.split(curTimeStr, "/")[3] == string.split(birthdayStr, "/")[3] and string.split(state, "_")[2] == "1" then
		return true
	end

	return false
end

function OperationActiveMgr:IsPlayerBirthday()
	local state = OperationActiveMgr:GetPlayerBirthdayState()
	local bornTime = PlayerInst:GetBirthday()
	local month = math.floor(bornTime / 100)
	local day = bornTime % 100
	local birthdayStr = string.format("%02d/%02d/%02d", 0, month, day)
	local curTimeStr = os.date("%y/%m/%d", NetData:GetCurServerTime() / DateUtil.MillsPerSecond)

	if string.split(curTimeStr, "/")[2] == string.split(birthdayStr, "/")[2] and string.split(curTimeStr, "/")[3] == string.split(birthdayStr, "/")[3] then
		return true
	end

	return false
end

function OperationActiveMgr:IsPlayerBirthdayForesee()
	local state = OperationActiveMgr:GetPlayerBirthdayState()
	local bornTime = PlayerInst:GetBirthday()
	local month = math.floor(bornTime / 100)
	local day = bornTime % 100
	local birthdayStr = string.format("%02d/%02d/%02d", 0, month, day)
	local curTimeStr = os.date("%y/%m/%d", NetData:GetCurServerTime() / DateUtil.MillsPerSecond)

	if string.split(curTimeStr, "/")[2] == string.split(birthdayStr, "/")[2] and tonumber(string.split(birthdayStr, "/")[3]) - tonumber(string.split(curTimeStr, "/")[3]) <= GetConfigArgInt("PlayBrith") and tonumber(string.split(birthdayStr, "/")[3]) - tonumber(string.split(curTimeStr, "/")[3]) > 0 then
		if tonumber(string.split(birthdayStr, "/")[2]) == 2 and tonumber(string.split(birthdayStr, "/")[3]) == 29 then
			local year = tonumber(string.split(curTimeStr, "/")[1])

			if year % 4 == 0 and year % 100 ~= 0 or year % 400 == 0 then
				return true
			else
				return false
			end
		else
			return true
		end
	end

	return false
end

function OperationActiveMgr:GetPlayerBirthdayInfo()
	local listOpenActive = OperationActiveMgr:GetListOpenActive()

	for k, v in pairs(listOpenActive) do
		if v.data.UIType == eOperationActive.PlayerBirthday then
			return OperationActiveMgr:Get(v.data.ID)
		end
	end

	return false
end

function OperationActiveMgr:SetBossActivityDotState(str)
	local str2 = PersistentStoreUtil.GetString(PersistentStoreUtil.KEY_BOSSACTIVITY_DOT_STATE)

	str2 = str .. "_" .. string.split(str2, "_")[2]

	PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_BOSSACTIVITY_DOT_STATE, str2)
end

function OperationActiveMgr:GetBossActivityDotState()
	local str = PersistentStoreUtil.GetString(PersistentStoreUtil.KEY_BOSSACTIVITY_DOT_STATE)

	if str == "" then
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond - 14400
		local time = os.date("%m:%d", curServerTime)

		str = "1_" .. time

		PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_BOSSACTIVITY_DOT_STATE, str)

		return string.split(str, "_")[1]
	else
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond - 14400
		local time = os.date("%m:%d", curServerTime)

		if time ~= string.split(str, "_")[2] then
			str = "1_" .. time
		end

		PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_BOSSACTIVITY_DOT_STATE, str)

		return string.split(str, "_")[1]
	end
end

function OperationActiveMgr.GetAccumulatedRechargeData()
	for _, activeData in pairs(OperationData) do
		if activeData.Type == eOperationActive.AccumulatedRecharge then
			return activeData
		end
	end

	return nil
end

function OperationActiveMgr.TimeLimitLastTime()
	local list = TaskLimitMgr:GetListLimitHourTask()
	local registerTime = PlayerInst.InfoPlayer:GetRegisterTime()
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local endTime = registerTime + 3600 * list[1].LastTime

	endTime = endTime - curServerTime

	if endTime > 0 then
		return endTime
	else
		return false
	end
end

function OperationActiveMgr.GetRelevanceActiveID(luaDataName, ID)
	if not luaDataName then
		return false
	end

	local luaData = require("luaData/" .. luaDataName)

	if luaDataName == "m_activity_free_ten_draw" then
		for i, v in pairs(luaData) do
			if v and v.id == ID then
				return v.active_start_at, v.active_close_at, v.active_close_at
			end
		end
	else
		for i, v in pairs(luaData) do
			if v and v.ID == ID then
				if v.StartTime and v.CloseTime and v.EndTime then
					return v.StartTime, v.CloseTime, v.EndTime
				elseif v.OpenTime and v.EndTime then
					return v.OpenTime, v.EndTime, v.EndTime
				elseif v.StartTime and v.EndTime and v.ShowEndTime then
					return v.StartTime, v.EndTime, v.ShowEndTime
				elseif v.BeginTime and v.EndTime then
					return v.BeginTime, v.EndTime
				end
			end
		end
	end

	return false
end

function OperationActiveMgr:CheckReGetOperation()
	local listActive = self:GetListOpenActive()
	local resultList = {}

	for k, v in pairs(listActive) do
		if v.data.Type == eOperationActiveType.Login then
			local isPass = PersistentStoreUtil.GetBool("ActiveManageOpen_ID_" .. v.data.ID, false)

			if not isPass and ChapterMgr:GetStage(v.data.OpenStage):IsPass() then
				PersistentStoreUtil.SetBool("ActiveManageOpen_ID_" .. v.data.ID, true)
				table.insert(resultList, v.data.ID)
			end
		end
	end

	if #resultList > 0 then
		local function wrap_cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vMsg.result.code == NetManager.Result_Sucess then
				OperationActiveMgr:SetData(vMsg.activeOperates)
			elseif pb.result.code == NetManager.Result_Maintain then
				-- block empty
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		end

		NetManager:RequestActiveOperates(resultList, wrap_cb)
		LoadingMgr.Show(eLoadingType.Repeat)
	end
end

function OperationActiveMgr:GetLimitActivityList()
	local list = {}

	for key, value in pairs(OperationData) do
		local isOpen = true

		if Application.isEditor == false then
			isOpen = ChapterMgr:GetStage(value.OpenStage):IsPass()
		end

		if value.Type == eOperationActiveType.LimitActivity and isOpen then
			local infoOperationActive = self:Get(value.ID)

			if infoOperationActive:IsBegin() and not infoOperationActive:IsExpire() then
				table.insert(list, infoOperationActive)
			end
		end
	end

	return list
end
