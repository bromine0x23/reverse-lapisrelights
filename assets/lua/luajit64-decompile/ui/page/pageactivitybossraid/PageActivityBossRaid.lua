-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivityBossRaid/PageActivityBossRaid.lua

local InfoTeam = require("Info/InfoTeam")

require("UI/Page/PageActivityBossRaid/CellBossRaidInfo")

local RaidBossUIData = require("luaData/RaidBossUIData")

PageActivityBossRaid = class("PageActivityBossRaid", UIPanel)

function PageActivityBossRaid:ctor()
	self.UIPrefabPath = "UI/PanelActivityBossRaid/PageActivityBossRaid"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_BossRaid"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PageActivityBossRaid:OnBack()
	UIMgr.PopPanel()
end

function PageActivityBossRaid:PreLoad()
	self:LoadResAsync("UI/PanelActivityBossRaid/CellBossRaidInfo", "PrefabCellBossRaidInfo")
end

function PageActivityBossRaid:Purge()
	PageActivityBossRaid.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellBossRaidInfo)
	UnloadAllImageSprite(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function PageActivityBossRaid:OnRegisterEvent()
	self:AddClick(self.Record, self.OnRecordBtnClick)
	self:AddClick(self.Shop, self.OnShopBtn)
	self:AddClick(self.Rank, self.OnClickRank)
	self:AddClick(self.Task, self.OnTaskBtnClick)
	self:AddClick(self.hardLock, self.OnhardLockBtnClick)

	for i = 1, 4 do
		self:AddClick(self.typeBtn[i], self.OnSortTypeBtnClick)
	end

	for i = 1, 2 do
		self:AddClick(self.funcBtn[i], self.OnSortFuncBtnClick)
	end

	self:AddClick(self.SortTypeBtn, self.OnOpenSortTypeBtnClick)
	self:AddClick(self.FreshBotton, self.OnFreshBtnClick)
	self:AddClick(self.AddButton, self.OnClickAddPlayNum)
	self:AddClick(self.AnimMaskClick, self.BossDeadCallBack)
	Event.Instance:Add("RefreshBossRaidDate", self.RefreshBossRaidDate, self)
end

function PageActivityBossRaid:OnUnRegisterEvent()
	self:RemoveClick(self.Record, self.OnRecordBtnClick)
	self:RemoveClick(self.Shop, self.OnShopBtn)
	self:RemoveClick(self.Rank, self.OnClickRank)
	self:RemoveClick(self.Task, self.OnTaskBtnClick)
	self:RemoveClick(self.hardLock, self.OnhardLockBtnClick)

	for i = 1, 4 do
		self:RemoveClick(self.typeBtn[i], self.OnSortTypeBtnClick)
	end

	for i = 1, 2 do
		self:RemoveClick(self.funcBtn[i], self.OnSortFuncBtnClick)
	end

	self:RemoveClick(self.SortTypeBtn, self.OnOpenSortTypeBtnClick)
	self:RemoveClick(self.FreshBotton, self.OnFreshBtnClick)
	self:RemoveClick(self.AddButton, self.OnClickAddPlayNum)
	self:RemoveClick(self.AnimMaskClick, self.BossDeadCallBack)
	Event.Instance:Remove("RefreshBossRaidDate", self.RefreshBossRaidDate, self)
end

function PageActivityBossRaid:OnEnter(vParam)
	self.lastBattleId = ActivityBossRaidMgr.curBossRaidId
	ActivityBossRaidMgr.curBossRaidId = nil

	if not GuideMgr:IsGuided(GuideFunctionType.BossRaid) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.BossRaid)
	end

	self.TimeText = self:GetChildComponent("Panel/Time/TimeText", "Text")
	self.DayTime1 = self:GetChildComponent("Panel/Time/DayTime1/Text", "Text")
	self.DayTime2 = self:GetChildComponent("Panel/Time/DayTime2/Text", "Text")
	self.TimeImage = self:GetChildComponent("Panel/Time", "Image")
	self.DayTime1Image = self:GetChildComponent("Panel/Time/DayTime1", "Image")
	self.DayTime2Image = self:GetChildComponent("Panel/Time/DayTime2", "Image")
	self.ItemIcon = self:GetChildComponent("Panel/ItemIcon", "Image")
	self.AnimMask = self:GetChildComponent("Panel/AnimMask", "Image")
	self.AnimMaskClick = self:GetChildGameObject("Panel/AnimMask/click")
	self.Count = self:GetChildComponent("Panel/FunInfo/LastCountBg/Count", "Text")
	self.LastCountBg = self:GetChildGameObject("Panel/FunInfo/LastCountBg")
	self.SortTypeBtn = self:GetChildGameObject("Panel/FunInfo/SortTypeBtn")
	self.SortTypeObj = self:GetChildGameObject("Panel/FunInfo/SortType")
	self.typeBtn = {}

	for i = 1, 4 do
		self.typeBtn[i] = self:GetChildGameObject("Panel/FunInfo/SortType/" .. i)
	end

	self.funcBtn = {}

	for i = 1, 2 do
		self.funcBtn[i] = self:GetChildGameObject("Panel/FunInfo/SortBtn/" .. i)
	end

	self.SortBtn = self:GetChildGameObject("Panel/FunInfo/SortBtn")
	self.Rank = self:GetChildGameObject("Panel/FunInfo/Rank")
	self.Shop = self:GetChildGameObject("Panel/FunInfo/Shop")
	self.Task = self:GetChildGameObject("Panel/FunInfo/Task")
	self.Record = self:GetChildGameObject("Panel/FunInfo/Record")
	self.FreshBotton = self:GetChildGameObject("Panel/FunInfo/FreshBotton")
	self.TitalImage = self:GetChildComponent("Panel/TitalImage", "Image")
	self.SubTitalImage = self:GetChildComponent("Panel/SubTital", "Image")
	self.SubTitalText = self:GetChildComponent("Panel/SubTital/Text", "Text")
	self.Desc1Image = self:GetChildComponent("Panel/Desc1", "Image")
	self.Desc2Image = self:GetChildComponent("Panel/Desc2", "Image")
	self.SortTypeText = self:GetChildComponent("Panel/FunInfo/SortTypeBtn/Text", "Text")
	self.AddButton = self:GetChildGameObject("Panel/FunInfo/LastCountBg/Button")
	self.BG = self:GetChildComponent("BG", "RawImage")
	self.tabGo = self:GetChildGameObject("Panel/BossType")
	self.hardLock = self:GetChildGameObject("Panel/BossType/Image")
	self.CloseTip = self:GetChildGameObject("Panel/CloseTip")
	self.CloseTipMask = self:GetChildGameObject("Panel/CloseTip/CloseTipMask")
	self.CloseTipBg = self:GetChildGameObject("Panel/CloseTip/CloseTipBg")
	self.CloseTipContent = self:GetChildComponent("Panel/CloseTip/CloseTipBg/Content", "Text")
	self.DayCloseTipBg = self:GetChildGameObject("Panel/CloseTip/DayCloseTipBg")
	self.DayCloseTime = self:GetChildComponent("Panel/CloseTip/DayCloseTipBg/Time", "Text")
	self.EmptyTipBg = self:GetChildGameObject("Panel/CloseTip/EmptyTipBg")
	self.EmptyTipContent = self:GetChildComponent("Panel/CloseTip/EmptyTipBg/Content", "Text")
	self.sortFunc = true
	self.sortType = 5

	self:InitScroll()
	self:Localization()

	self.isEnd = self:UpdateBossRaidClose()

	self:UpdateDayCloseTime()
	self:UpdateBossRaidUI()
	self:UpdateTime()
	self:RequestBossRaidData(function()
		self:UpdatePanel()
	end, 0)
	self:RequestBossRaidRecord()

	if ActivityBossRaidMgr.isAdd == true then
		ActivityBossRaidMgr.isAdd = false

		self:OnClickAddPlayNum()
	end
end

function PageActivityBossRaid:UpdateBossRaidUI()
	local UIData = RaidBossUIData[ActivityBossRaidMgr.bossRaidTimeData.data.ID]

	UIUtil.SetRawImageTexture(self.BG, UIData.BGImage, self, true)
	UIUtil.SetImageSprite(self.TitalImage, UIData.TitalImage, self, true)
	GOUtil.SetRectTransformSizeDeltaHeight(self.TitalImage.gameObject, 250)
	GOUtil.SetRectTransformAnchoredPosition(self.TitalImage.gameObject, UIData.TitalPos[1], UIData.TitalPos[2])
	UIUtil.SetImageSprite(self.SubTitalImage, UIData.SubTitalImage, self, true)
	GOUtil.SetRectTransformAnchoredPosition(self.SubTitalImage.gameObject, UIData.SubTitalPos[1], UIData.SubTitalPos[2])
	GOUtil.SetRectTransformAnchoredPosition(self.SubTitalText.gameObject, UIData.SubTitalTextPos[1], UIData.SubTitalTextPos[2])
	GOUtil.SetRectTransformSizeDelta(self.SubTitalImage.gameObject, UIData.SubTitalDescLength[1], UIData.SubTitalDescLength[2])

	self.SubTitalText.text = Lang(UIData.SubTitalDesc)
	self.SubTitalText.color = getColorFromString(UIData.SubTitalPos[3])
	self.TimeText.color = getColorFromString(UIData.TimeColor[1][1])
	self.DayTime1.color = getColorFromString(UIData.TimeColor[2][1])
	self.DayTime2.color = getColorFromString(UIData.TimeColor[2][1])
	self.TimeImage.color = getColorFromString(UIData.TimeColor[1][2])
	self.DayTime1Image.color = getColorFromString(UIData.TimeColor[2][2])
	self.DayTime2Image.color = getColorFromString(UIData.TimeColor[2][2])
	self.Desc1Image.color = getColorFromString(UIData.Desc1[3], UIData.Desc1[4])
	self.Desc2Image.color = getColorFromString(UIData.Desc2[3], UIData.Desc1[4])

	local Text1 = self:GetChildComponent("Panel/Desc1/Text", "Text")

	Text1.text = Lang(UIData.Desc1[1])
	Text1.color = getColorFromString(UIData.Desc1[2])

	local Text2 = self:GetChildComponent("Panel/Desc2/Text", "Text")

	Text2.text = Lang(UIData.Desc2[1])
	Text2.color = getColorFromString(UIData.Desc2[2])
	Text1.fontSize = 24
	Text2.fontSize = 24

	UIUtil.SetImageSprite(self.ItemIcon, UIData.AwardItem, self, true)
	GOUtil.SetRectTransformAnchoredPosition(self.ItemIcon.gameObject, UIData.AwardItemPos[1], UIData.AwardItemPos[2])
	GOUtil.SetTransformLocalScale(self.ItemIcon.gameObject, UIData.AwardItemScale)
end

function PageActivityBossRaid:RequestBossRaidData(callback, type)
	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestBossRaidData(type, function(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Sucess then
			callback()
		else
			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end)
end

function PageActivityBossRaid:Localization()
	local TextAuto

	TextAuto = self:GetChildComponent("Panel/BossType/Btn1/Btn/Text", "Text")
	TextAuto.text = _("RaidBoss_Com")
	TextAuto = self:GetChildComponent("Panel/BossType/Btn1/Select/Text", "Text")
	TextAuto.text = _("RaidBoss_Com")
	TextAuto = self:GetChildComponent("Panel/BossType/Btn2/Btn/Text", "Text")
	TextAuto.text = _("RaidBoss_Hard")
	TextAuto = self:GetChildComponent("Panel/BossType/Btn2/Select/Text", "Text")
	TextAuto.text = _("RaidBoss_Hard")
	TextAuto = self:GetChildComponent("Panel/FunInfo/SortBtn/1/UpTxt", "Text")
	TextAuto.text = _("Desc_SortUp")
	TextAuto = self:GetChildComponent("Panel/FunInfo/SortBtn/2/DownTxt", "Text")
	TextAuto.text = _("Desc_SortDown")
	TextAuto = self:GetChildComponent("Panel/FunInfo/SortTypeBtn/Text", "Text")
	TextAuto.text = _("RaidBoss_DefaultSort")
	TextAuto = self:GetChildComponent("Panel/FunInfo/SortType/1/Text", "Text")
	TextAuto.text = Lang(5000036)
	TextAuto = self:GetChildComponent("Panel/FunInfo/SortType/2/Text", "Text")
	TextAuto.text = _("Desc_BossRaidTime")
	TextAuto = self:GetChildComponent("Panel/FunInfo/SortType/3/Text", "Text")
	TextAuto.text = _("RaidBoss_Num")
	TextAuto = self:GetChildComponent("Panel/FunInfo/SortType/4/Text", "Text")
	TextAuto.text = _("RaidBoss_Level")
	TextAuto = self:GetChildComponent("Panel/FunInfo/Record/Text", "Text")
	TextAuto.text = _("RaidBoss_Notes")
	TextAuto = self:GetChildComponent("Panel/FunInfo/Task/Text", "Text")
	TextAuto.text = _("eReturn_Task")
	TextAuto = self:GetChildComponent("Panel/FunInfo/Shop/Text", "Text")
	TextAuto.text = _("Desc_Store")
	TextAuto = self:GetChildComponent("Panel/FunInfo/LastCountBg/Text", "Text")
	TextAuto.text = _("RaidBoss_Battle_Count")
	TextAuto = self:GetChildComponent("Panel/CloseTip/DayCloseTipBg/Content", "Text")
	TextAuto.text = _("RaidBoss_Rest")
end

function PageActivityBossRaid:InitScroll()
	local function ListUpdate(item, index)
		local data = {}

		data.type = 0
		data.info = self.listBossRaid[index]

		item:UpdateData(data, index == 1 and self.haveLastBattle, index == 1 and self.bossDead, self.Record.transform.position)
	end

	self.ScrollArea = self:GetChildGameObject("Panel/BossList/ScrollArea")

	local content = self:GetChildComponent("Panel/BossList/ScrollArea/Content", "Transform")
	local count = 0

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.ScrollArea, content, count, self.PrefabCellBossRaidInfo, CellBossRaidInfo, self, false, nil, ListUpdate)
end

function PageActivityBossRaid:TabClick(index, isFresh)
	if self.uiTab.index == 1 then
		ActivityBossRaidMgr.selectTab = 1

		SetActiveFunc(self.typeBtn[4], true)
	else
		ActivityBossRaidMgr.selectTab = 2

		SetActiveFunc(self.typeBtn[4], false)
	end

	self.listBossRaid = ActivityBossRaidMgr:GetCanPlayBossRaid(self.uiTab.index)

	local finishList = ActivityBossRaidMgr:GetFinishedBossRaid()

	if isFresh then
		self.NewList = {}

		for i = #self.listBossRaid, 1, -1 do
			if not table.contains(self.beforeIdList, self.listBossRaid[i].id) then
				table.insert(self.NewList, self.listBossRaid[i])
				table.remove(self.listBossRaid, i)
			end
		end
	end

	if self.lastBattleId then
		for i, v in ipairs(finishList) do
			if tonumber(v.id) == self.lastBattleId then
				self.lastBattleInfo = v
				self.bossDead = true

				break
			end
		end

		if not self.lastBattleInfo then
			for i = #self.listBossRaid, 1, -1 do
				if tonumber(self.listBossRaid[i].id) == self.lastBattleId then
					self.lastBattleInfo = self.listBossRaid[i]

					table.remove(self.listBossRaid, i)
				end
			end
		end

		self.lastBattleId = nil
	end

	if self.sortType == 4 then
		self.sortType = 1
		self.SortTypeText.text = Lang(5000036)
	end

	self:SortBossRaidList(self.listBossRaid)

	if isFresh then
		for i = 1, #self.NewList do
			table.insert(self.listBossRaid, 1, self.NewList[i])
		end
	end

	if self.lastBattleInfo then
		table.insert(self.listBossRaid, 1, self.lastBattleInfo)

		self.lastBattleInfo = nil

		if self.bossDead then
			self.IsPlayDead = true

			SetActiveFunc(self.AnimMask.gameObject, true)
			TimerMgr.AddTimer(eTimerType.ScaleTime, 1.2, function()
				self.canPlay = true
			end, nil)
		else
			self.haveLastBattle = true
		end
	end

	if not self.isEnd and self.nextCloseTime then
		local notEmpty = false

		for i, v in ipairs(self.listBossRaid) do
			if not v.isEmpty then
				notEmpty = true

				break
			end
		end

		if notEmpty then
			self:SetActiveNotEmptyUI()

			while #self.listBossRaid < 6 do
				table.insert(self.listBossRaid, {
					isEmpty = true
				})
			end

			local needAddSelf = true

			for i, v in ipairs(self.listBossRaid) do
				if v.isEmpty or v.fromType == 0 then
					needAddSelf = false

					break
				end
			end

			if needAddSelf then
				table.insert(self.listBossRaid, {
					isEmpty = true
				})
			end

			self.UIScrollTool:UpdateListData(self.listBossRaid)
		else
			self:SetActiveEmptyUI()

			self.EmptyTipContent.text = _("Bossraid_List_Empty")

			table.clear(self.listBossRaid)
			self.UIScrollTool:UpdateListData(self.listBossRaid)
		end
	end

	self.haveLastBattle = false
	self.bossDead = false
	self.NewList = nil
	self.refresh = false
end

function PageActivityBossRaid:BossDeadCallBack()
	if self.IsClick or not self.canPlay then
		return
	end

	self.IsClick = true
	self.canPlay = false
	self.AnimMask.color = Color.New(0, 0, 0, 0)

	Event.Instance:Fire("BossDeadCallBack")

	self.timer = TimerMgr.AddTimer(eTimerType.ScaleTime, 2.6, function()
		self.IsPlayDead = false
		self.IsClick = false

		if IsNil(self.AnimMask) or IsNil(self.AnimMask.gameObject) then
			return
		end

		self.AnimMask.color = Color.New(1, 1, 1, 1)

		SetActiveFunc(self.AnimMask.gameObject)
		table.remove(self.listBossRaid, 1)

		if not self.isEnd and self.nextCloseTime then
			local notEmpty = false

			for i, v in ipairs(self.listBossRaid) do
				if not v.isEmpty then
					notEmpty = true

					break
				end
			end

			if notEmpty then
				self:SetActiveNotEmptyUI()

				while #self.listBossRaid < 6 do
					table.insert(self.listBossRaid, {
						isEmpty = true
					})
				end

				local needAddSelf = true

				for i, v in ipairs(self.listBossRaid) do
					if v.isEmpty or v.fromType == 0 then
						needAddSelf = false

						break
					end
				end

				if needAddSelf then
					table.insert(self.listBossRaid, {
						isEmpty = true
					})
				end

				self.UIScrollTool:UpdateListData(self.listBossRaid)
			else
				self:SetActiveEmptyUI()

				self.EmptyTipContent.text = _("Bossraid_List_Empty")

				table.clear(self.listBossRaid)
				self.UIScrollTool:UpdateListData(self.listBossRaid)
			end
		end
	end, nil)
end

function PageActivityBossRaid:UpdateTime()
	self.TimeText.text = self:GetOpenTime(ActivityBossRaidMgr.bossRaidTimeData.data.StartTime) .. "~" .. self:GetOpenTime(ActivityBossRaidMgr.bossRaidTimeData.data.EndTime)

	local dayData = ActivityBossRaidMgr.bossRaidTimeData.data.DailyTime

	self.DayTime1.text = dayData[1][1] .. ":00-" .. dayData[1][2] .. ":00"
	self.DayTime2.text = dayData[2][1] .. ":00-" .. dayData[2][2] .. ":00"
end

function PageActivityBossRaid:UpdatePanel()
	self:UpdateTime()

	local countNum = ActivityBossRaidMgr.playNum

	if countNum > 0 then
		self.Count.text = countNum .. "/" .. ActivityBossRaidMgr:GetPlayMaxNum()
	else
		self.Count.text = "<color=#ea5d63>" .. countNum .. "</color>/" .. ActivityBossRaidMgr:GetPlayMaxNum()
	end

	self.bossLevel = ActivityBossRaidMgr.boosLevel
	self.listBossRaid = {}

	if self.bossLevel < GetConfigArgInt("RailBossActiveHardUnlockLevel") then
		self.hardLock:SetActive(true)

		self.uiTab = UITab(self.tabGo, 2, self.TabClick, self, 1)

		self:TabClick()
	else
		self.hardLock:SetActive(false)

		self.uiTab = UITab(self.tabGo, 2, self.TabClick, self, ActivityBossRaidMgr.selectTab or 2)

		self:TabClick()
	end
end

function PageActivityBossRaid:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCellBossData)
end

function PageActivityBossRaid:OnUpdateSecond()
	if self.nextCloseTime then
		local time = self.nextCloseTime * DateUtil.MillsPerSecond - NetData:GetCurServerTime()

		if time < 0 then
			self:UpdateDayCloseTime()
			self:RefreshBossRaidDate()
		end
	end

	if self.nextOpenTime then
		local time = self.nextOpenTime * DateUtil.MillsPerSecond - NetData:GetCurServerTime()

		if time > 0 then
			self.DayCloseTime.text = string.format(_("RaidBoss_Next_Open_Time"), DateUtil.GetMomentHour00(time / DateUtil.MillsPerSecond))
		else
			self:UpdateDayCloseTime()
			self:RefreshBossRaidDate()
		end
	end

	if not self.UIScrollTool then
		return
	end

	if not self.UIScrollTool.ItemRoot2ItemDict then
		return
	end

	for _, v in self.UIScrollTool.ItemRoot2ItemDict:Enumerator() do
		v.Item:UpdateTime(second)
	end
end

function PageActivityBossRaid:OnFreshBtnClick()
	if self.freshTime and self.freshTime + GetConfigArgInt("RailBossActiveFreshTime") * 1000 < NetData:GetCurServerTime() or not self.freshTime then
		self.freshTime = NetData:GetCurServerTime()
		self.beforeList = self.listBossRaid
		self.beforeIdList = {}

		for i, v in ipairs(self.beforeList) do
			table.insert(self.beforeIdList, v.id)
		end

		self:RequestBossRaidData(function(...)
			self:TabClick(_, true)
		end, self.uiTab.index)
	else
		UIMgr.ShowMsg(_("RaidBoss_Fresh_Time_Tip"))
	end
end

function PageActivityBossRaid:OnRecordBtnClick()
	require("UI/Page/PageActivityBossRaid/DlgBossRaidRecord")
	UIMgr.AddPanel(DlgBossRaidRecord())
end

function PageActivityBossRaid:OnTaskBtnClick()
	if not ActivityBossRaidMgr.bossRaidTimeData:IsPlayOpen() then
		UIMgr.ShowMsg(_("Msg_Active_Over"))

		return
	end

	require("UI/Page/PageActivityBossRaid/DlgBossRaidTask")
	UIMgr.AddPanel(DlgBossRaidTask())
end

function PageActivityBossRaid:OnSortFuncBtnClick(data)
	local funcName = data.pointerPress.gameObject.name

	if funcName == "1" then
		self.sortFunc = false

		self.funcBtn[1]:SetActive(false)
		self.funcBtn[2]:SetActive(true)
	else
		self.sortFunc = true

		self.funcBtn[1]:SetActive(true)
		self.funcBtn[2]:SetActive(false)
	end

	self:SetSortListData()
end

function PageActivityBossRaid:OnSortTypeBtnClick(data)
	local typeName = data.pointerPress.gameObject.name
	local text = GOUtil.FindChildComponent(data.pointerPress.gameObject, "Text", "Text").text

	self.sortType = tonumber(typeName)
	self.SortTypeText.text = text

	self.SortTypeObj:SetActive(false)
	SetActiveFunc(self.SortBtn, true)
	self:SetSortListData()
end

function PageActivityBossRaid:OnOpenSortTypeBtnClick(data)
	self.SortTypeObj:SetActive(not self.SortTypeObj.activeSelf)
end

function PageActivityBossRaid:SetSortListData()
	self:SortBossRaidList(self.listBossRaid)

	while #self.listBossRaid < 6 do
		table.insert(self.listBossRaid, {
			isEmpty = true
		})
	end

	local needAddSelf = true

	for i, v in ipairs(self.listBossRaid) do
		if v.isEmpty or v.fromType == 0 then
			needAddSelf = false

			break
		end
	end

	if needAddSelf then
		table.insert(self.listBossRaid, {
			isEmpty = true
		})
	end

	self.UIScrollTool:UpdateListData(self.listBossRaid)
end

function PageActivityBossRaid:SortBossRaidList(list)
	for i = #list, 1, -1 do
		if list[i].isEmpty then
			table.remove(list, i)
		end
	end

	local function getType(a, type)
		if type == 1 then
			return a.curProgress
		elseif type == 2 then
			return a.overTime
		elseif type == 3 then
			return a.member
		elseif type == 4 then
			return a.bossLevel
		end
	end

	if self.sortType == 5 then
		-- block empty
	else
		table.sort(list, function(a, b)
			if getType(a, self.sortType) < getType(b, self.sortType) then
				return self.sortFunc
			elseif getType(a, self.sortType) == getType(b, self.sortType) then
				return false
			else
				return not self.sortFunc
			end
		end)
	end
end

function PageActivityBossRaid:OnClickedCellBossData(data)
	if self.IsPlayDead then
		return
	end

	local go = data.pointerPressRaycast.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index

	if self.listBossRaid[index].isEmpty then
		return
	end

	local raidBossId = self.listBossRaid[index].id
	local raidBossInfo = self.listBossRaid[index]

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestBossRaidDamage(tonumber(raidBossId), function(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Sucess then
			local stageId = self.listBossRaid[index].stageId

			ChapterMgr.PageCombatReadinessType = 1

			local totalHarm = 0

			for i = 1, #pb.harms do
				totalHarm = totalHarm + pb.harms[i].harm
			end

			UIMgr.AddPanel(PageCombatReadiness(), {
				stageId = stageId,
				Damage = pb.harms,
				totalHarm = totalHarm,
				raidBossInfo = raidBossInfo
			})
		else
			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end)
end

function PageActivityBossRaid:GetOpenTime(strTime)
	local str = ""
	local a = string.split(strTime, " ")

	if #a > 0 then
		local date = string.split(a[1], "-")

		str = date[2] .. "/" .. date[3]
	end

	return str
end

function PageActivityBossRaid:RefreshBossRaidDate()
	if self.refresh then
		return
	end

	self.refresh = true

	self:TabClick()
end

function PageActivityBossRaid:OnClickAddPlayNum()
	if self.isEnd then
		UIMgr.ShowMsg(_("RaidBoss_Battle_Count_isEnd"))

		return
	end

	if self.nextOpenTime then
		UIMgr.ShowMsg(_("RaidBoss_Battle_Count_isRest"))

		return
	end

	if GetConfigArgInt("RailBossActiveDailyNumBuyCost") > 0 and ActivityBossRaidMgr.buyNum == GetConfigArgInt("RailBossActiveDailyNumBuyCost") then
		UIMgr.ShowMsg(_("Buy_Battle_Count_Limit"))

		return
	end

	local function responseCb()
		self.Count.text = ActivityBossRaidMgr.playNum .. "/" .. ActivityBossRaidMgr:GetPlayMaxNum()
	end

	self.GoBuyTimes(responseCb)
end

function PageActivityBossRaid.GoBuyTimes(responseCb)
	local costList = GetConfigArgJson("RailBossActiveDailyNumBuyCost")
	local buyCount = GetConfigArgFloat("RailBossActiveDailyNumBuyCost")
	local costItemId = costList[1][2]
	local costItemCount = costList[1][3]

	for i = 1, #costList do
		if ActivityBossRaidMgr.buyNum + 1 >= costList[i][1] then
			costItemId = costList[i][2]
			costItemCount = costList[i][3]
		end
	end

	local str = string.format(_("RaidBoss_Buy_Battle_Count"), costItemCount, buyCount)

	local function vCallBack(index)
		if index == 1 then
			NetManager:RequestBossRaidPlayNum(function(pb)
				LoadingMgr.Hide(eLoadingType.Repeat)

				if pb.result.code == NetManager.Result_Sucess then
					if responseCb then
						responseCb()
					end
				else
					UIMgr.ShowMsg(pb.result.desc, pb)
				end
			end)
			LoadingMgr.Show(eLoadingType.Repeat)
		end
	end

	local function showTip()
		UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("BossRaid_Alert"), {
			isDiamond = true,
			text = str
		}, vCallBack, _("BossRaid_OK"), _("BossRaid_Cancel"))
	end

	CheckPayDiamond(costItemCount, str, vCallBack, showTip)
end

function PageActivityBossRaid:UpdateDot()
	local taskHas = TaskManager:HasBossRaidTaskDot()

	if taskHas then
		self.TaskDot:SetActive(true)
	else
		self.TaskDot:SetActive(false)
	end

	local has = DotMgr:HasDot(ePSKey.Dot_BossRaid)

	if has then
		self.RewardDot:SetActive(true)
	else
		self.RewardDot:SetActive(false)
	end
end

function PageActivityBossRaid:OnShopBtn()
	require("UI/Page/PageActivityBossRaid/PageBossRaidShop")
	PageBossRaidShop.InitNetData()
end

function PageActivityBossRaid:OnClickRank()
	require("UI/Page/PageRank/PageRank")

	RankMgr.CurIndex = 6

	if not TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PageRank) then
		return
	end

	if not ActivityBossRaidMgr.bossRaidTimeData:IsShowOpen() then
		UIMgr.ShowMsg(_("Msg_Active_Over"))

		return
	end

	UIMgr.SwitchPanel(PageRank, {})
end

function PageActivityBossRaid:OnhardLockBtnClick()
	UIMgr.ShowMsg(string.format(_("RaidBoss_Hard_Unlock_Level"), GetConfigArgInt("RailBossActiveHardUnlockLevel")))
end

function PageActivityBossRaid:UpdateBossRaidClose()
	if ActivityBossRaidMgr.bossRaidTimeData ~= nil then
		if not ActivityBossRaidMgr.bossRaidTimeData:IsPlayOpen() and ActivityBossRaidMgr.bossRaidTimeData:IsShowOpen() then
			self:SetActiveEndUI()
		end

		return not ActivityBossRaidMgr.bossRaidTimeData:IsPlayOpen() and ActivityBossRaidMgr.bossRaidTimeData:IsShowOpen()
	end

	return false
end

function PageActivityBossRaid:UpdateDayCloseTime()
	if self.isEnd then
		return
	end

	self.nextCloseTime = nil

	if ActivityBossRaidMgr.bossRaidTimeData ~= nil then
		local DailyTime = ActivityBossRaidMgr.bossRaidTimeData.data.DailyTime
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
		local curServerData = os.date("*t", curServerTime)
		local endTime = GetTimeTampByString(ActivityBossRaidMgr.bossRaidTimeData.data.EndTime)

		for i, v in ipairs(DailyTime) do
			if curServerData.hour < v[2] and curServerData.hour >= v[1] then
				self.nextCloseTime = os.time({
					second = 0,
					minute = 0,
					day = curServerData.day,
					month = curServerData.month,
					year = curServerData.year,
					hour = v[2]
				})

				if endTime > self.nextCloseTime then
					self:SetActiveOpenUI()

					return
				elseif curServerTime < endTime then
					self.nextCloseTime = endTime

					self:SetActiveOpenUI()

					return
				end
			end
		end

		self.nextOpenTime = nil

		for i, v in ipairs(DailyTime) do
			local Time1 = os.time({
				second = 0,
				minute = 0,
				day = curServerData.day,
				month = curServerData.month,
				year = curServerData.year,
				hour = v[1]
			})

			if Time1 - curServerTime > 0 and Time1 - endTime < 0 then
				if self.nextOpenTime and self.nextOpenTime - curServerTime > Time1 - curServerTime then
					self.nextOpenTime = Time1
				elseif self.nextOpenTime == nil then
					self.nextOpenTime = Time1
				end
			end

			local Time2 = os.time({
				second = 0,
				minute = 0,
				day = curServerData.day + 1,
				month = curServerData.month,
				year = curServerData.year,
				hour = v[1]
			})

			if Time2 - curServerTime > 0 and Time2 - endTime < 0 then
				if self.nextOpenTime and self.nextOpenTime - curServerTime > Time2 - curServerTime then
					self.nextOpenTime = Time2
				elseif self.nextOpenTime == nil then
					self.nextOpenTime = Time2
				end
			end
		end

		if self.nextOpenTime then
			self:SetActiveRestUI()

			self.DayCloseTime.text = string.format(_("RaidBoss_Next_Open_Time"), DateUtil.GetMomentHour00(self.nextOpenTime - NetData:GetCurServerTime() / DateUtil.MillsPerSecond))
		else
			self.isEnd = true

			self:SetActiveEndUI()
		end
	end
end

function PageActivityBossRaid:OnClickedGuideBtn()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.BossRaid)
end

function PageActivityBossRaid:SetActiveEndUI()
	self.FreshBotton:SetActive(false)
	self.CloseTip:SetActive(true)
	self.CloseTipMask:SetActive(true)
	self.CloseTipBg:SetActive(true)
	self.EmptyTipBg:SetActive(false)
	self.DayCloseTipBg:SetActive(false)
	self.ScrollArea:SetActive(false)
	self.SortBtn:SetActive(false)
	self.SortTypeBtn:SetActive(false)
	self.SortTypeObj:SetActive(false)
	self.LastCountBg:SetActive(false)

	self.CloseTipContent.text = _("RaidBoss_Close_Tip_Tital")
end

function PageActivityBossRaid:SetActiveRestUI()
	self.CloseTip:SetActive(true)
	self.CloseTipMask:SetActive(true)
	self.CloseTipBg:SetActive(false)
	self.DayCloseTipBg:SetActive(true)
	self.EmptyTipBg:SetActive(false)
	self.SortBtn:SetActive(false)
	self.SortTypeBtn:SetActive(false)
	self.SortTypeObj:SetActive(false)
	self.ScrollArea:SetActive(false)
	self.LastCountBg:SetActive(true)
end

function PageActivityBossRaid:SetActiveOpenUI()
	self.CloseTip:SetActive(false)
	self.CloseTipMask:SetActive(false)
	self.EmptyTipBg:SetActive(false)
	self.DayCloseTipBg:SetActive(false)
	self.CloseTipBg:SetActive(false)
	self.SortBtn:SetActive(self.sortType ~= 5)
	self.SortTypeBtn:SetActive(true)
	self.SortTypeObj:SetActive(false)
	self.FreshBotton:SetActive(true)
	self.ScrollArea:SetActive(true)
	self.LastCountBg:SetActive(true)
end

function PageActivityBossRaid:SetActiveEmptyUI()
	self.CloseTip:SetActive(true)
	self.CloseTipBg:SetActive(false)
	self.EmptyTipBg:SetActive(true)
	self.SortBtn:SetActive(false)
	self.SortTypeBtn:SetActive(false)
	self.SortTypeObj:SetActive(false)
	self.LastCountBg:SetActive(true)
end

function PageActivityBossRaid:SetActiveNotEmptyUI()
	self.CloseTip:SetActive(false)
	self.SortBtn:SetActive(self.sortType ~= 5)
	self.SortTypeBtn:SetActive(true)
	self.SortTypeObj:SetActive(false)
	self.EmptyTipBg:SetActive(false)
	self.LastCountBg:SetActive(true)
end

function PageActivityBossRaid:RequestBossRaidRecord()
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)
	end

	NetManager:RequestBossRaidRecord(wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end
