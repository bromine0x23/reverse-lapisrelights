-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCalendar/PageCalendar.lua

local RewardData = require("luaData/RewardPack")
local NewbieData = require("luaData/Newbie")

require("UI/Page/PageCalendar/CellCalendarAward")
require("UI/Page/PageCalendar/CellCalendarItem")

PageCalendar = class("PageCalendar", UIPanel)

function PageCalendar:ctor()
	self.UIPrefabPath = "UI/PanelCalendar/PageCalendar"
end

function PageCalendar:OnRegisterEvent()
	self:AddClick(self.btn_close, self.OnClickBtnClose)
	self:AddClick(self.BtnOneKey, self.OnClickedOneKey)
	Event.Instance:Add("GetCalendarAward", self.ReceiveOperationActiveAward, self)
	Event.Instance:Add("ClosePageCalendar", self.OnClickBtnClose, self)
	Event.Instance:Add("UpdateCalendar", self.OnUpdateSecond, self)
	UIMgr.SetFocusChange(self)
end

function PageCalendar:OnUnRegisterEvent()
	self:RemoveClick(self.btn_close, self.OnClickBtnClose)
	self:RemoveClick(self.BtnOneKey, self.OnClickedOneKey)
	Event.Instance:Remove("GetCalendarAward", self.ReceiveOperationActiveAward, self)
	Event.Instance:Remove("ClosePageCalendar", self.OnClickBtnClose, self)
	Event.Instance:Remove("UpdateCalendar", self.OnUpdateSecond, self)
	UIMgr.RemoveFocusChange(self)
end

function PageCalendar:OnApplicationFocus(isFocus)
	if isFocus then
		self:OnClickBtnClose()
	end
end

function PageCalendar.RefreshAndShow(cb)
	local time2, info = OperationActiveMgr:GetOnlineMin()

	if info then
		NetManager:RequestActiveOperates({
			info.data.ID
		}, function(vPBMessage)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vPBMessage.result.code == 0 then
				OperationActiveMgr:SetData(vPBMessage.activeOperates)

				local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

				OperationActiveMgr.OnLineLoginTime = curServerTime
				OperationActiveMgr.OnLineTime = 0
			end

			cb()
		end)
		LoadingMgr.Show(eLoadingType.Repeat)
	else
		cb()
	end
end

function PageCalendar:OnFocusAction()
	self:OnClickBtnClose()
end

function PageCalendar:OnClickBtnClose()
	self:Close()
end

function PageCalendar:PreLoad(vParam)
	self:LoadResAsync("UI/PanelCalendar/CellCalendarAward", "rewardPrefab")
	self:LoadResAsync("UI/PanelCalendar/CellCalendarItem", "itemPrefab")
end

function PageCalendar:Purge()
	PageCalendar.base.Purge(self)

	for key, value in pairs(self.itemList) do
		value:OnLeave()
	end

	self.itemList = nil

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	UIMgr.RemoveUpdatePanel(self)
	ResourceMgr.Unload(self.rewardPrefab)
	ResourceMgr.Unload(self.itemPrefab)
end

function PageCalendar:OnEnter(vParam)
	self.pvpOpen = vParam.PvPOpen
	self.btn_close = self:GetChildGameObject("Panel/btn_close")
	self.RewardGroup = self:GetChildGameObject("Panel/RewardGroup")
	self.BtnOneKey = self:GetChildGameObject("Panel/BtnOneKey")
	self.tex_online_time = self:GetChildComponent("Panel/tex_online_time", "Text")
	self.ImgOneKey = self:GetChildComponent("Panel/BtnOneKey", "Image")
	self.Fx_UI_009_2 = self:GetChildGameObject("Panel/BtnOneKey/Fx_UI_009_2")
	self.img_progress = self:GetChildGameObject("Panel/img_progress")
	self.tex_title = self:GetChildComponent("Panel/tex_title", "Text")
	self.tex_cout_time = self:GetChildComponent("Panel/tex_cout_time", "Text")
	self.tex_cout_reward = self:GetChildComponent("Panel/tex_cout_reward", "Text")
	self.tex_get = self:GetChildComponent("Panel/tex_get", "Text")

	self:InitScrollViewPanel()
	self:Init()
	UIMgr.SetUpdatePanel(self)
end

function PageCalendar:Init()
	self.tex_title.text = _("Desc_Schedule")
	self.tex_cout_time.text = _("Desc_Online")
	self.tex_cout_reward.text = _("Desc_OnlineReward")
	self.tex_get.text = _("Desc_OneKeyRec")
	self.itemList = {}

	self:OnUpdateSecond()

	for i = 1, #self.awardList do
		local item = CellCalendarAward(self.rewardPrefab, self.RewardGroup, self)

		item:Create()
		item:UpdateData(self.awardList[i])

		self.itemList[i] = item
	end
end

function PageCalendar:InitScrollViewPanel()
	local ScrollArea = self:GetChildGameObject("Panel/ScrollArea")
	local content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")

	self:FilterNewbie()

	local count = #self.ItemData

	local function AddClick(item)
		return
	end

	local function CellUpdate(item, index)
		item:UpdateData(self.ItemData[index])
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.itemPrefab, CellCalendarItem, self, false, AddClick, CellUpdate)
end

function PageCalendar:ParseBarData(value)
	for _, bar in pairs(value.NavigationBar) do
		if bar[1] == 4 then
			local list = string.split(bar[2][1], "_")
			local config = "luaData/" .. list[1]
			local data = require(config)
			local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

			for _, info in pairs(data) do
				if info.Type == tonumber(list[3]) then
					local startTime = GetTimeTampByString(info.StartTime)
					local endTime = GetTimeTampByString(info.EndTime)

					if startTime <= curServerTime and curServerTime < endTime then
						self:CreatItemData(value)

						self.ItemData[#self.ItemData].EndText = OperationActiveMgr:GetOpenTime(info.EndTime)

						if #info.MainRewardShow > 0 then
							self.ItemData[#self.ItemData].MainRewardShow = info.MainRewardShow
						end

						return
					end
				end
			end
		end
	end
end

function PageCalendar:FilterNewbie()
	self.ItemData = {}

	for key, value in pairs(NewbieData) do
		if value.NavigationType == 1 then
			self:CreatItemData(value)
		elseif value.NavigationType == 2 then
			self:ParseBarData(value)
		end
	end

	self:SortItemData()
end

function PageCalendar:CreatItemData(value)
	local index = table.insert(self.ItemData, {
		data = value
	})

	self:CheckCondition(value)

	self.ItemData[#self.ItemData].isGift = self:CheckIsGift(value)
	self.ItemData[#self.ItemData].isComplete = self:CheckIsComplete(value)
end

function PageCalendar:CheckIsGift(value)
	if value.NavigationGift ~= 1 then
		return false
	end

	if value.ID == ePageType.PageTower then
		local normal = 0
		local normalList = TowerChapterMgr:GetTowerList(ChapterFromType.tower)
		local hardList = TowerChapterMgr:GetTowerList(ChapterFromType.towerhard)

		if TowerChapterMgr.dailyTimes >= TowerChapterMgr:GetDailyAwardCount() then
			return false
		end

		if normalList[1].listStage[1]:IsPass() then
			return true
		end

		if hardList[1].listStage[1]:IsPass() then
			return true
		end

		return false
	elseif value.ID == ePageType.PageTeam then
		local listComb = {}
		local list = GetConfigArgJson("TeamChapterUnlock")

		for _, v in ipairs(list) do
			if v and v[1] then
				local info = CombinationMgr:Get(v[1])

				table.insert(listComb, info)
			end
		end

		for _, comb in pairs(listComb) do
			local isUnLock = CombChapterMgr.CombChapterIsUnLock(comb.data.ID)

			if isUnLock then
				local listChapter = CombChapterMgr.GetCombChapters(comb.data.ID)

				for _, chapter in pairs(listChapter) do
					if ChapterMgr.ChapterHasStarAward(chapter) then
						return true
					end
				end
			end
		end
	elseif value.ID == ePageType.PagePVP then
		if not self.pvpOpen then
			return false
		end

		local isGift = DotMgr:HasDot(ePSKey.Dot_PVP)

		return isGift
	end

	return false
end

function PageCalendar:CheckCondition(value)
	local itemData = self.ItemData[#self.ItemData]

	if value.ID == ePageType.PageAsset then
		local assetPass = 3
		local listActive = PassMgr:GetBranchActiveList(assetPass, PassMgr:GetListAssetBranchId(assetPass)[1])
		local allLeftNum = 0
		local allMaxNum = 0
		local allHightNum = 0
		local allHightMaxNum = 0

		for key, value in pairs(listActive) do
			local activeId = value.ID
			local infoActive = ActiveMgr:GetActive(activeId)
			local info, hignCount = ShopManager:GetGoodsMonthPrivilegeFuncInfo(ShopManager.MonthPrivilegeFunc.Func15)

			if infoActive:HaveDailyReward() then
				local chapterId = ActiveMgr:GetActiveChapter(activeId)
				local infoChapter = ChapterMgr:GetChapter(chapterId)
				local highNum = hignCount + 1 - infoChapter.pb.highAwardNum

				allHightNum = allHightNum + highNum
			end

			allHightMaxNum = allHightMaxNum + 1 + hignCount

			local singleMaxNum = infoActive:GetMaxArgJson(nil, key)
			local singlePlayNum = ActiveMgr:GetActivePlayNum(activeId)
			local leftNum = singleMaxNum - singlePlayNum
			local max = infoActive:GetMaxArgJsonValue(nil, key)

			allLeftNum = allLeftNum + leftNum
			allMaxNum = allMaxNum + max
		end

		itemData.Condition1 = allLeftNum
		itemData.Max1 = allMaxNum
		itemData.Condition2 = allHightNum
		itemData.Max2 = allHightMaxNum
	elseif value.ID == ePageType.PageCard then
		itemData.Condition1 = CardChapterMgr.GetTotalRemainingChallengeNum()
		itemData.Max1 = CardChapterMgr.GetTotalLimitChallengeNum()
	elseif value.ID == ePageType.PagePVP then
		local InfoPVPData = require("Info/InfoPVP")

		if self.pvpOpen then
			itemData.Condition1 = InfoPVPData:GetDailyBattleNum(InfoPVPData.pb.season.seasonId) - InfoPVPData.SelfPVPPlayerinfo.dailyBattleNumber
			itemData.Max1 = InfoPVPData:GetDailyBattleNum(InfoPVPData.pb.season.seasonId)
		else
			itemData.Condition1 = 0
			itemData.Max1 = 0
		end
	elseif value.ID == ePageType.PageBossLive then
		itemData.Condition1 = BossliveChapterMgr.GetBossliveRemainingChallengeNum()
		itemData.Max1 = BossliveChapterMgr.GetTotalLimitNum()
	elseif value.ID == ePageType.PageWork then
		itemData.Condition1, itemData.Max1 = WorkMgr:GetWorkTimes()
	elseif value.ID == ePageType.PageUnionWish then
		itemData.Max1 = GetConfigArgInt("ClubWishDailyCount")

		if UnionWishMgr:CanReleaseWish() then
			itemData.Condition1 = 1
		else
			itemData.Condition1 = 0
		end
	elseif value.ID == ePageType.PageUnionRaid then
		itemData.Max1 = GetConfigArgInt("ClubMirrorDailyRound")
		itemData.Max2 = GetConfigArgInt("ClubMirrorBossWeekPlay") * #UnionRaidMgr.listBossRaid
		itemData.Condition1 = itemData.Max1 - UnionRaidMgr.GetPlayNum(eRaidType.Common)

		local playNum = 0

		for _, v in ipairs(UnionRaidMgr.listBossRaid) do
			playNum = playNum + UnionRaidMgr.GetPlayNum(eRaidType.Boss, v.id)
		end

		itemData.Condition2 = itemData.Max2 - playNum
	elseif value.ID == ePageType.PageBossRaid then
		itemData.Max1 = ActivityBossRaidMgr:GetPlayMaxNum()
		itemData.Condition1 = ActivityBossRaidMgr.playNum
	end
end

function PageCalendar:CheckIsComplete(value)
	if #value.NavigationFinish == 0 then
		return 0
	end

	local itemData = self.ItemData[#self.ItemData]

	if itemData.Condition1 == 0 or itemData.Condition2 == 0 then
		return 1
	end

	return 0
end

function PageCalendar:SortItemData()
	table.sort(self.ItemData, function(a, b)
		if a.isComplete > b.isComplete then
			return false
		elseif a.isComplete == b.isComplete then
			return a.data.NavigationPriority < b.data.NavigationPriority
		else
			return true
		end
	end)
end

function PageCalendar:OnUpdateSecond()
	local isupdate = false
	local time2, info = OperationActiveMgr:GetOnlineMin()

	if self.listOpenActive == nil then
		self.listOpenActive = info
	end

	local canGet = false

	if self.tex_online_time and self.isOnEnter then
		self.tex_online_time.text = time2 .. _("Desc_minute")
	end

	if self.min ~= time2 then
		self.min = time2

		if self.tex_online_time and self.isOnEnter then
			self.tex_online_time.text = time2 .. _("Desc_minute")
		end

		self.awardList = {}

		for k, v in pairs(info.data.DailyTime) do
			local isGeted = info:IsGetIndexAward(k)

			self.awardList[k] = {}
			self.awardList[k].isGeted = isGeted
			self.awardList[k].min = time2
			self.awardList[k].dataTime = v[1]
			self.awardList[k].data = RewardData[v[2]].ItemList
			self.awardList[k].index = k

			if not isupdate and tonumber(time2) < tonumber(v[1]) then
				isupdate = true

				self:UpdateProgress(k)
			end

			if tonumber(time2) >= tonumber(info.data.DailyTime[#info.data.DailyTime][1]) then
				self:UpdateProgress(7)
			end

			if not isGeted and tonumber(time2) >= tonumber(v[1]) then
				canGet = true
			end

			if self.itemList ~= nil and self.itemList[k] then
				self.itemList[k]:UpdateData(self.awardList[k])
			end
		end

		self:SetOneKeyActive(canGet)
	end
end

function PageCalendar:SetOneKeyActive(active)
	if active ~= self.OneKeyActive then
		if active then
			UIUtil.SetImageSprite(self.ImgOneKey, "UI/PanelCalendar/AtlasCalendar/BTN_square_pink_01", self)
		else
			UIUtil.SetImageSprite(self.ImgOneKey, "UI/PanelCalendar/AtlasCalendar/BTN_square_pink_02", self)
		end

		self.OneKeyActive = active

		self.Fx_UI_009_2:SetActive(active)
	end
end

function PageCalendar:UpdateProgress(index)
	local value = {
		0,
		100,
		244,
		394,
		544,
		690,
		844
	}

	if index > #self.awardList then
		self.img_progress.transform.sizeDelta = Vector2(value[#value], self.img_progress.transform.sizeDelta.y)

		return
	end

	local lastTime

	lastTime = index == 1 and 0 or self.awardList[index - 1].dataTime

	local nowTime = self.awardList[index].dataTime

	self.img_progress.transform.sizeDelta = Vector2(value[index] + (self.awardList[index].min - lastTime) / (nowTime - lastTime) * (value[index + 1] - value[index]), self.img_progress.transform.sizeDelta.y)
end

function PageCalendar:OnClickedOneKey()
	local time2, info = OperationActiveMgr:GetOnlineMin()
	local arardIdList = {}

	for k, v in pairs(info.data.DailyTime) do
		local isGeted = info:IsGetIndexAward(k)

		if tonumber(v[1]) <= tonumber(time2) and not isGeted then
			table.insert(arardIdList, k - 1)
		end
	end

	self:ReceiveOperationActiveAward(arardIdList)
end

function PageCalendar:ReceiveOperationActiveAward(index)
	local infoOperationActive = OperationActiveMgr:Get(self.listOpenActive.data.ID)
	local activeIndexList = {}

	if type(index) ~= "table" then
		table.insert(activeIndexList, index - 1)
	else
		activeIndexList = index
	end

	if #activeIndexList == 0 then
		UIMgr.ShowMsg(_("Msg_Award_Can_Receive_None"))

		return
	end

	local function wrap_cb(vMsg)
		local canGet = false

		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self.awardList = {}

			local time2, info = OperationActiveMgr:GetOnlineMin()

			for i = 1, #activeIndexList do
				info:ChangeAwardRecords(activeIndexList[i])
			end

			OperationActiveMgr:SetTotalOnlineInfoState()

			for k, v in pairs(info.data.DailyTime) do
				local isGeted = info:IsGetIndexAward(k)

				self.awardList[k] = {}
				self.awardList[k].isGeted = isGeted
				self.awardList[k].min = time2
				self.awardList[k].dataTime = v[1]
				self.awardList[k].data = RewardData[v[2]].ItemList
				self.awardList[k].index = k

				self.itemList[k]:UpdateData(self.awardList[k])

				if not isGeted and tonumber(time2) >= tonumber(v[1]) then
					canGet = true
				end
			end

			self:SetOneKeyActive(canGet)
			CalendarRDL.DealRemove(infoOperationActive.data.ID, index)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestOperationActiveAward(infoOperationActive.data.ID, index, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end
