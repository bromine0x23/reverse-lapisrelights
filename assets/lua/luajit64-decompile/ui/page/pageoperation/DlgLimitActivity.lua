-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgLimitActivity.lua

local OperationUIData = require("luaData/ActiveUiManage")

require("UI/Page/PageOperation/CellSpecialItem")
require("UI/Page/PageOperation/CellLimitTaskActivity")

local eUnLockType = {
	Time = 2,
	TaskNum = 0
}

DlgLimitActivity = class("DlgLimitActivity", UIPanel)

function DlgLimitActivity:ctor()
	self.UIPrefabPath = "UI/PanelOperation/PanelLimitActivity"
	self.DlgExit = DlgExit()

	self:AddChildPanel(self.DlgExit, {
		title = "",
		callback = self.OnBack,
		panel = self
	})
end

function DlgLimitActivity:Cache()
	DlgLimitActivity.base.Cache(self)
end

function DlgLimitActivity:PreLoad()
	DlgLimitActivity.base.PreLoad(self)
	self:LoadResAsync("UI/PanelOperation/CellTimeLimitTask", "PrefabCell")
end

function DlgLimitActivity:OnBack()
	UIMgr.PopPanel()
end

function DlgLimitActivity:Purge()
	self.base.Purge(self)
	self:OnLeave()
end

function DlgLimitActivity:OnLeave()
	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.PrefabCell then
		ResourceMgr.Unload(self.PrefabCell)

		self.PrefabCell = nil
	end

	if self.timer1 ~= nil then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end

	if self.timer2 ~= nil then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end

	UnloadAllImageSprite(self)

	if self.awardList then
		for i = 1, #self.awardList do
			self.awardList[i].item:OnLeave()
		end

		self.awardList = nil
	end

	UITweenUtil.RemoveTween(self.content)
	UITweenUtil.RemoveTween(self.group.transform)
end

function DlgLimitActivity:OnRegisterEvent()
	self:AddClick(self.btn_jump, self.OnClickJump)
	self:AddClick(self.BtnOneKey, self.OnClickedBtnOneKey)
	Event.Instance:Add("UpdateTaskAndAward", self.UpdateTaskAndAward, self)
	Event.Instance:Add("UpdateNetData", self.UpdateNetData, self)
	self.scrollRect.onValueChanged:AddListener(self.SetArrow)
end

function DlgLimitActivity:OnUnRegisterEvent()
	self:RemoveClick(self.btn_jump, self.OnClickJump)
	self:RemoveClick(self.BtnOneKey, self.OnClickedBtnOneKey)
	Event.Instance:Remove("UpdateTaskAndAward", self.UpdateTaskAndAward, self)
	Event.Instance:Remove("UpdateNetData", self.UpdateNetData, self)
	self.scrollRect.onValueChanged:RemoveListener(self.SetArrow)

	if self.awardList then
		for i = 1, #self.awardList do
			self:RemoveClick(self.awardList[i].gItem, self.awardList[i].fun)
		end
	end
end

function DlgLimitActivity:OnEnter(vParam)
	self.infoActive = vParam
	self.DlgExit.TxtExit.text = Lang(self.infoActive.data.Name)

	Event.Instance:Fire("UpdateSceneDisplay", false)
	FingerGesturesUtil.Disable()

	self.btn_jump = self:GetChildGameObject("Panel/Icon/Jump")
	self.BtnOneKey = self:GetChildGameObject("Panel/BtnOneKey")
	self.Fx_UI_009_2 = self:GetChildGameObject("Panel/BtnOneKey/Fx_UI_009_2")
	self.EndText = self:GetChildComponent("Panel/Time/tex_time", "Text")
	self.ImgOneKey = self:GetChildComponent("Panel/BtnOneKey", "Image")
	self.content = self:GetChildComponent("Panel/ScrollArea/Content", "RectTransform")
	self.canvasGroup = self:GetChildComponent("Panel/ScrollArea/Content", "CanvasGroup")
	self.progress = self:GetChildComponent("Panel/AwardRate/Bar/Image", "RectTransform")
	self.tabContent = self:GetChildComponent("Panel/tab/Content", "RectTransform")
	self.scrollRect = self:GetChildComponent("Panel/tab", "ScrollRect")
	self.ArrowUp = self:GetChildGameObject("Panel/ArrowUp")
	self.ArrowDown = self:GetChildGameObject("Panel/ArrowDown")

	self:Init()
end

function DlgLimitActivity:Init()
	self.TaskList = TaskManager:GetTaskListDataByID(self.infoActive.data.DailyTime[1][1])

	self:SetUIModel()
	self:UpdateTimeText()
	self:InitAward()
	self:InitTaskList()
	self:PlayAlphaAnim()
end

function DlgLimitActivity:SetUIModel()
	local ActiveID = self.infoActive.data.UIType .. "_" .. self.infoActive.data.PageOrder
	local ui

	for k, v in pairsByKeys(OperationUIData) do
		if v.ActiveID == ActiveID then
			ui = v

			break
		end
	end

	local bg = self:GetChildComponent("Bg", "RawImage")
	local back = self:GetChildComponent("Panel/Image/Back", "Image")
	local icon = self:GetChildComponent("Panel/Icon", "Image")
	local jump = self:GetChildComponent("Panel/Icon/Jump", "Image")
	local scoreIcon = self:GetChildComponent("Panel/AwardRate/Bar/icon", "Image")

	UIUtil.SetRawImageTexture(bg, ui.Bg[1][1], self)

	if ui.Bg[1][3] and ui.Bg[1][4] then
		GOUtil.SetRectTransformAnchoredPosition(bg.gameObject, ui.Bg[1][3], ui.Bg[1][4])
	end

	UIUtil.SetImageSprite(icon, ui.SpineStatic[1][1], self)

	if ui.SpineStatic[1][3] and ui.SpineStatic[1][4] then
		GOUtil.SetRectTransformAnchoredPosition(icon.gameObject, ui.SpineStatic[1][3], ui.SpineStatic[1][4])
	end

	UIUtil.SetImageSprite(back, ui.Pic[1][1], self)

	if ui.Pic[1][3] and ui.Pic[1][4] then
		GOUtil.SetRectTransformAnchoredPosition(back.gameObject, ui.Pic[1][3], ui.Pic[1][4])
	end

	UIUtil.SetImageSprite(jump, ui.Pic[2][1], self)

	if ui.Pic[2][3] and ui.Pic[2][4] then
		GOUtil.SetRectTransformAnchoredPosition(jump.gameObject, ui.Pic[2][3], ui.Pic[2][4])
	end

	icon:SetNativeSize()
	jump:SetNativeSize()

	local v = TaskManager:Get(self.TaskList.List[1])

	if v.data and v.data.Reward and v.data.Reward[1] and v.data.Reward[1][1] then
		UIUtil.SetImageSprite(scoreIcon, ItemManager:GetIcon(v.data.Reward[1][1]), self)
	end
end

function DlgLimitActivity:InitAward()
	self.maxValue = self.progress.sizeDelta.x
	self.listScoreSection = self.TaskList.ScoreSection
	self.listScoreAward = self.TaskList.ScoreSectionReward
	self.group = self:GetChildGameObject("Panel/AwardRate/Group")

	local cell = self:GetChildGameObject("Panel/AwardRate/Group/Award")

	self.curScore = TaskManager:GetTaskListScore(self.TaskList.ID)
	self.awardList = {}

	local count = #self.listScoreAward

	for i = 1, count do
		local data = {}
		local award = self.listScoreAward[i][1]
		local infoItem = ItemManager:GetValueItem(award[1], award[2])
		local gItem, item, goCell, value

		if i ~= count then
			value = self.maxValue * i / count - 10
			goCell = GOUtil.Instantiate(cell, self.group)
			gItem = GOUtil.FindChildGameObject(goCell, "Cell")

			GOUtil.SetRectTransformAnchoredPosition(goCell, value, -10)

			GOUtil.FindChildGameObject(goCell, "Cell").transform.localScale = Vector3(0.7, 0.7, 1)
		else
			value = self.maxValue
			goCell = cell
			gItem = GOUtil.FindChildGameObject(cell, "Cell")
		end

		item = CellSpecialItem(gItem)

		item:InitItemByRoot(gItem)

		if award[2] > 1 then
			item:UpdateWithNumType(infoItem)
		else
			item:UpdateNoNumType(infoItem)
		end

		local text = GOUtil.FindChildComponent(goCell, "Image/Text", "Text")

		local function fun()
			self:OnClickedAward(i)
		end

		self:AddClick(gItem, fun)

		data.id = award[1]
		data.item = item
		data.value = value
		data.text = text
		data.fun = fun
		data.gItem = gItem

		table.insert(self.awardList, data)
	end

	self:UpdateAwardAndProgress()
end

function DlgLimitActivity:UpdateAwardAndProgress()
	self.curScore = TaskManager:GetTaskListScore(self.TaskList.ID)

	local scoreIndex = #self.listScoreSection + 1

	for key, value in pairs(self.listScoreSection) do
		if self.curScore >= value[1] and self.curScore <= value[2] then
			scoreIndex = key

			break
		end
	end

	if scoreIndex > #self.listScoreSection then
		self.progress.sizeDelta = Vector2(self.maxValue, self.progress.sizeDelta.y)
	else
		local value = 0
		local minValue = 0
		local maxValue = self.awardList[scoreIndex].value
		local nowDis = self.curScore
		local maxDis = self.listScoreSection[1][2]

		if scoreIndex ~= 1 then
			minValue = self.awardList[scoreIndex - 1].value
			nowDis = self.curScore - self.listScoreSection[scoreIndex - 1][2]
			maxDis = self.listScoreSection[scoreIndex][2] - self.listScoreSection[scoreIndex - 1][2]
		end

		value = minValue + (maxValue - minValue) * (nowDis / maxDis)
		self.progress.sizeDelta = Vector2(value, self.progress.sizeDelta.y)
	end

	for index, value in ipairs(self.awardList) do
		local maxScore = self.listScoreSection[index][2]
		local myScore = self.curScore

		if maxScore < myScore then
			myScore = maxScore
		end

		local isGeted = TaskManager:IsRecvedScoreAward(self.TaskList.ID, index - 1)
		local isGray = scoreIndex <= index and self.curScore ~= maxScore

		value.item:SetReceived(isGeted)
		value.item:SetGray(isGray)

		value.canGet = not isGeted and not isGray
		value.text.text = myScore .. "/" .. maxScore
	end
end

function DlgLimitActivity:InitTaskList()
	self.tabList = {}

	local listSection = self.TaskList.TaskSection
	local listSectionName = self.TaskList.SectionlName
	local template = self:GetChildGameObject("Panel/tab/Content/1")

	for i = 1, #listSection do
		self["GoBtn" .. i] = template

		if i > 1 then
			self["GoBtn" .. i] = GOUtil.Instantiate(template, self.tabContent.gameObject)
			self["GoBtn" .. i].name = i
		end

		self["GoLock" .. i] = self:GetChildGameObject("Panel/tab/Content/" .. i .. "/Lock")
		self["BtnRel" .. i] = self:GetChildGameObject("Panel/tab/Content/" .. i .. "/Button")
		self["SelRel" .. i] = self:GetChildGameObject("Panel/tab/Content/" .. i .. "/Select")
		self["TxtBtnRel" .. i] = self:GetChildComponent("Panel/tab/Content/" .. i .. "/Button/tex_name", "Text")
		self["TxtSelRel" .. i] = self:GetChildComponent("Panel/tab/Content/" .. i .. "/Select/tex_name", "Text")
		self["TxtBtnValue" .. i] = self:GetChildComponent("Panel/tab/Content/" .. i .. "/Button/tex_num", "Text")
		self["TxtSelValue" .. i] = self:GetChildComponent("Panel/tab/Content/" .. i .. "/Select/tex_num", "Text")
		self["TxtBtnRel" .. i].text = Lang(listSectionName[i])
		self["TxtSelRel" .. i].text = Lang(listSectionName[i])

		SetActiveFunc(self["BtnRel" .. i], true)
		SetActiveFunc(self["SelRel" .. i], false)

		local function fun()
			self:OnClickTab(i)
		end

		self:AddClick(self["BtnRel" .. i], fun)

		local data = {}

		data.fun = fun

		if self.TaskList.TipsType == eUnLockType.Time then
			data.openTime = GetTimeTampByString(self.infoActive.data.ShowStartTime) + (self.TaskList.SectionOpenNeed[i] - 1) * 86400
		end

		table.insert(self.tabList, data)
		RedDotSystemMgr.SetUIRedDot(self["GoBtn" .. i], string.format("TaskLimitTime/%d/%d", self.infoActive.data.DailyTime[1][1], i))
	end

	for index, list in ipairs(listSection) do
		if self.curSectionIndex == nil then
			for i = #list, 1, -1 do
				local task = TaskManager:Get(list[i])
				local isComple = task:IsComplete()
				local isGeted = task:IsGetAward()

				if not isComple or not isGeted then
					self.curSectionIndex = index

					break
				end
			end
		else
			break
		end
	end

	if self.curSectionIndex == nil then
		self.curSectionIndex = #listSection
	end

	for i = self.curSectionIndex, 1, -1 do
		if self:IsTabUnlock(i) then
			self.curSectionIndex = i

			break
		end
	end

	self:UpdateTaskList()
	self:UpdateTab()
	LayoutRebuilder.ForceRebuildLayoutImmediate(self.tabContent)
	self:GetContentPos(self.curSectionIndex, true)
	self:SetArrow()
end

function DlgLimitActivity:UpdateTaskList()
	UITweenUtil.RemoveTween(self.content)

	self.taskList = self.TaskList.TaskSection[self.curSectionIndex]

	local count = #self.taskList

	table.sort(self.taskList, function(a, b)
		local taskA = TaskManager:Get(a)
		local taskB = TaskManager:Get(b)
		local IsGetAwardA = taskA:IsGetAward()
		local IsGetAwardB = taskB:IsGetAward()

		if IsGetAwardA == IsGetAwardB then
			local IsCompleteA = taskA:IsComplete()
			local IsCompleteB = taskB:IsComplete()

			if IsCompleteA == IsCompleteB then
				return a < b
			elseif IsCompleteA then
				return true
			else
				return false
			end
		elseif IsGetAwardA then
			return false
		else
			return true
		end
	end)

	if not self.UIScrollTool then
		local scrollArea = self:GetChildGameObject("Panel/ScrollArea")

		local function AddClick(item)
			return
		end

		local function CellUpdate(item, index)
			item:UpdateData(self.taskList[index])
		end

		self.UIScrollTool = UIScrollTool()

		self.UIScrollTool:InitList(scrollArea, self.content, count, self.PrefabCell, CellLimitTaskActivity, self, false, AddClick, CellUpdate)
		UITweenUtil.DoListAnimationUp(self.content, 300, 0.3, nil, nil)
	else
		self.UIScrollTool:UpdateListData(self.taskList)
		self:PlayTaskListAnim()
	end

	self:UpdateBtnOneKey()
end

function DlgLimitActivity:OnClickTab(index)
	if not self.tabList[index].unLock then
		if self.TaskList.TipsType == eUnLockType.TaskNum then
			UIMgr.ShowMsg(string.format(_("Desc_Limit_Task_UnLock"), self.TaskList.SectionOpenNeed[index]))
		elseif self.TaskList.TipsType == eUnLockType.Time then
			UIMgr.ShowMsg(string.format(_("Desc_LimitDay_Acvity_UnLock"), self:FormatUnixTime2Date(self.tabList[index].openTime)))
		end

		return
	end

	self.curSectionIndex = index

	for index, value in ipairs(self.tabList) do
		SetActiveFunc(self["SelRel" .. index], index == self.curSectionIndex)
	end

	self:UpdateTaskList()
end

function DlgLimitActivity:UpdateTab()
	for index, value in ipairs(self.tabList) do
		local num = 0

		for _, taskID in pairs(self.TaskList.TaskSection[index]) do
			local task = TaskManager:Get(taskID)

			if task:IsComplete() then
				num = num + 1
			end
		end

		value.num = num
	end

	for index, value in ipairs(self.tabList) do
		value.unLock = self:IsTabUnlock(index)

		if index == self.curSectionIndex then
			SetActiveFunc(self["SelRel" .. index], true)
		end

		SetActiveFunc(self["GoLock" .. index], not value.unLock)

		self["TxtBtnValue" .. index].text = value.num .. "/" .. #self.TaskList.TaskSection[index]
		self["TxtSelValue" .. index].text = value.num .. "/" .. #self.TaskList.TaskSection[index]
	end
end

function DlgLimitActivity:IsTabUnlock(index)
	if index == 1 then
		return true
	end

	if self.TaskList.TipsType == eUnLockType.TaskNum then
		for i = 2, index do
			if self.tabList[i - 1].num < self.TaskList.SectionOpenNeed[i] then
				return false
			end
		end

		return true
	elseif self.TaskList.TipsType == eUnLockType.Time then
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

		if curServerTime >= self.tabList[index].openTime then
			return true
		else
			return false
		end
	end
end

function DlgLimitActivity:OnClickJump()
	if #self.infoActive.data.Params > 0 then
		DlgItemTip.GoToFrom(self.infoActive.data.Params[1])
	end
end

function DlgLimitActivity:UpdateBtnOneKey()
	local listCanRecv = {}

	for key, value in pairs(self.taskList) do
		local v = TaskManager:Get(value)

		if v:IsComplete() and not v:IsGetAward() then
			table.insert(listCanRecv, v.id)
		end
	end

	local canGet = false

	for key, value in pairs(self.awardList) do
		if value.canGet then
			canGet = true

			break
		end
	end

	if #listCanRecv ~= 0 or canGet then
		GOUtil.SetActive(self.Fx_UI_009_2, true)
		UIUtil.SetImageSprite(self.ImgOneKey, "UI/PanelOperation/AtlasTimeLimitTask/BTN_square_pink_01", self)
	else
		GOUtil.SetActive(self.Fx_UI_009_2, false)
		UIUtil.SetImageSprite(self.ImgOneKey, "UI/PanelOperation/AtlasTimeLimitTask/BTN_square_pink_02", self)
	end
end

function DlgLimitActivity:OnClickedBtnOneKey()
	local listCanRecv = {}

	TaskManager.integralList = {}

	for i = 1, #self.taskList do
		local v = TaskManager:Get(self.taskList[i])

		if v:IsComplete() and not v:IsGetAward() then
			table.insert(listCanRecv, v.id)

			if v.data and v.data.Reward and v.data.Reward[1] and v.data.Reward[1][1] then
				table.insert(TaskManager.integralList, v.data.Reward[1])
			end
		end
	end

	local canGet = false

	for key, value in pairs(self.awardList) do
		if value.canGet then
			canGet = true

			break
		end
	end

	if #listCanRecv == 0 and not canGet then
		TaskManager.integralList = {}

		UIMgr.ShowMsg(_("Msg_Award_Can_Receive_None"))

		return
	end

	local function wrap_cb(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Sucess then
			self:UpdateAwardAndProgress()
			self:UpdateTaskList()
		else
			TaskManager.integralList = {}

			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestReceiveCompleteTasksOneKey(self.TaskList.ID, listCanRecv, wrap_cb)
end

function DlgLimitActivity:OnClickedAward(index)
	local item = self.awardList[index]

	if item.canGet then
		local rewardIndex = index - 1
		local isRecv = TaskManager:IsRecvedScoreAward(self.TaskList.ID, rewardIndex)

		if isRecv then
			UIMgr.ShowMsg(_("Desc_Has_Get"))

			return
		end

		local targetScore = self.TaskList.ScoreSection[index][2]

		if targetScore > self.curScore then
			UIMgr.ShowMsg(_("Msg_PointNotEnough"))

			return
		end

		local function cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vMsg.result.code == 0 then
				self:UpdateAwardAndProgress()
				self:UpdateBtnOneKey()
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		end

		NetManager:RequestTaskLineScoreReward(self.TaskList.ID, rewardIndex, cb)
		LoadingMgr.Show(eLoadingType.Repeat)
	else
		local data = ItemManager:Get(item.id)

		UIMgr.ShowItemTip(data)
	end
end

function DlgLimitActivity:UpdateNewCompleteTask()
	for i = 1, #self.listSection do
		local isOpen = TaskLimitMgr:IsUnLockSingleList(i)

		SetActiveFunc(self["GoLock" .. i], not isOpen)
		RedDotSystemMgr.SetNodeLockState(GetTaskBranchPath(eTaskListType.limitTime, i), not isOpen)
	end
end

function DlgLimitActivity:OnUpdateSecond()
	self:UpdateTimeText()

	if self.TaskList and self.TaskList.TipsType == eUnLockType.Time then
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

		for index, value in ipairs(self.tabList) do
			if value.openTime == Mathf.Floor(curServerTime) then
				self:UpdateTab()

				break
			end
		end
	end
end

function DlgLimitActivity:UpdateTimeText()
	if self.infoActive then
		local playEndTime = GetTimeTampByString(self.infoActive.data.ShowEndTime)
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

		playEndTime = playEndTime - curServerTime

		if playEndTime <= 0 then
			self:OnBack()

			return
		end

		local d, h, m, s = GetTimeFormatBySec(playEndTime)

		self.EndText.text = _("Desc_ActivityRemain") .. self:JPGetEndTime(d, h, m, s)
	end
end

function DlgLimitActivity:JPGetEndTime(d, h, m, s)
	local str = ""

	if d == 0 and h == 0 then
		if m == 0 then
			return m .. _("Desc_minute") .. s .. _("Desc_second")
		end

		return h .. _("Desc_hour") .. m .. _("Desc_minute")
	end

	return d .. _("Desc_day") .. h .. _("Desc_hour")
end

function DlgLimitActivity:UpdateNetData()
	self:UpdateAwardAndProgress()
	self:UpdateTaskList()
	self:UpdateTab()
end

function DlgLimitActivity:UpdateTaskAndAward()
	self:UpdateAwardAndProgress()
	self:UpdateTaskList()
end

function DlgLimitActivity:PlayAlphaAnim()
	UITweenUtil.SetGroupAlpha(self.group.transform, 0)

	self.timer1 = TimerMgr.AddTimer(eTimerType.RealTime, 0.3, function()
		UITweenUtil.GroupAlphaAnim(self.group.transform, 0.2)
	end, nil)
end

function DlgLimitActivity:PlayTaskListAnim()
	if self.timer2 ~= nil then
		TimerMgr.RemoveTimer(self.timer2)

		self.timer2 = nil
	end

	self.canvasGroup.alpha = 0
	self.timer2 = TimerMgr.AddTimer(eTimerType.FrameCount, 2, function()
		self.canvasGroup.alpha = 1

		UITweenUtil.DoListAnimationUp(self.content, 300, 0.3, nil, nil)
	end, nil)
end

function DlgLimitActivity:SetArrow(value)
	local this = UIMgr.GetCurPanel()
	local offset = 5

	local function isNear(now, target)
		return math.abs(now - target) < offset
	end

	if this.tabContent then
		SetActiveFunc(this.ArrowUp, not isNear(this.tabContent.anchoredPosition.y, 0))
		SetActiveFunc(this.ArrowDown, not isNear(this.tabContent.anchoredPosition.y, this.tabContent.sizeDelta.y))
	end
end

function DlgLimitActivity:GetContentPos(index)
	local size = 152
	local count = #self.TaskList.TaskSection
	local csize = size * count
	local cp = size * index - size / 2

	self.tabContent.anchoredPosition = Vector2(0, cp - csize / 2)
end

function DlgLimitActivity:FormatUnixTime2Date(unixTime)
	if unixTime and unixTime >= 0 then
		return os.date("%Y-%m-%d ", unixTime) .. tonumber(os.date("%H", unixTime)) .. ":00"
	end
end
