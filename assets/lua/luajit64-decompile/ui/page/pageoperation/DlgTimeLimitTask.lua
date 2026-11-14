-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgTimeLimitTask.lua

require("UI/Page/PageOperation/CellSpecialItem")
require("UI/Page/PageOperation/CellTimeLimitTask")
require("UI/Page/PageCardShop/CellRoleSign")
require("UI/Page/PageRoleCard/Page/PageRoleCard")

DlgTimeLimitTask = class("DlgTimeLimitTask", UIPanel)

function DlgTimeLimitTask:ctor()
	self.UIPrefabPath = "UI/PanelOperation/PanelTimeLimitTask"

	self:AddChildPanel(DlgExit(), {
		title = Lang(512),
		callback = self.OnBack,
		panel = self
	})
end

function DlgTimeLimitTask:Cache()
	DlgTimeLimitTask.base.Cache(self)
end

function DlgTimeLimitTask:PreLoad()
	DlgTimeLimitTask.base.PreLoad(self)
	self:LoadResAsync("UI/PanelOperation/CellTimeLimitTask", "PrefabCell")
	self:LoadResAsync("UI/PageCardShop/CellRoleSign", "PrefabCellRoleSign")
end

function DlgTimeLimitTask:OnBack()
	UIMgr.RemoveUpdatePanel(self)
	UIMgr.PopPanel()
end

function DlgTimeLimitTask:Purge()
	UIMgr.RemoveUpdatePanel(self)
	self.base.Purge(self)
	self:OnLeave()
end

function DlgTimeLimitTask:OnLeave()
	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.PrefabCellRoleSign then
		ResourceMgr.Unload(self.PrefabCellRoleSign)

		self.PrefabCellRoleSign = nil
	end

	if self.PrefabCell then
		ResourceMgr.Unload(self.PrefabCell)

		self.PrefabCell = nil
	end

	if self.timer ~= nil then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end

	UnloadAllImageSprite(self)

	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end

		self.listItem = nil
	end

	Event.Instance:Fire("PageMainStageUpdatePanel")
end

function DlgTimeLimitTask:OnRegisterEvent()
	for i = 1, 5 do
		self:AddClick(self["BtnRel" .. i], self.OnClickedBtnRel)
	end

	Event.Instance:Add("UpdateLimitTaskPanel", self.UpdateTaskList, self)
	Event.Instance:Add("UpdateIntegral", self.UpdateIntegral, self)
	Event.Instance:Add("UpdateNetData", self.UpdateNetData, self)
end

function DlgTimeLimitTask:OnUnRegisterEvent()
	for i = 1, 5 do
		self:RemoveClick(self["BtnRel" .. i], self.OnClickedBtnRel)
	end

	self:RemoveClick(self.btn_jump, self.OnClickedCellDetail)
	self:RemoveClick(self.BtnOneKey, self.OnClickedBtnOneKey)
	Event.Instance:Remove("UpdateLimitTaskPanel", self.UpdateTaskList, self)
	Event.Instance:Remove("UpdateIntegral", self.UpdateIntegral, self)
	Event.Instance:Remove("UpdateNetData", self.UpdateNetData, self)

	if self.listItem then
		for i = 1, #self.listItem do
			self:RemoveClick(self.listItem[i].UIRootObject, self.OnClickedIntegralAward)
		end
	end
end

function DlgTimeLimitTask:OnEnter(vParam)
	if vParam and vParam.callback then
		vParam.callback()
	end

	Event.Instance:Fire("UpdateSceneDisplay", false)
	FingerGesturesUtil.Disable()

	for i = 1, 5 do
		self["GoBtn" .. i] = self:GetChildGameObject("Panel/tab/Content/" .. i)
		self["GoLock" .. i] = self:GetChildGameObject("Panel/tab/Content/" .. i .. "/Lock")
		self["BtnRel" .. i] = self:GetChildGameObject("Panel/tab/Content/" .. i .. "/Button")
		self["SelRel" .. i] = self:GetChildGameObject("Panel/tab/Content/" .. i .. "/Select")
		self["TxtBtnRel" .. i] = self:GetChildComponent("Panel/tab/Content/" .. i .. "/Button/tex_name", "Text")
		self["TxtSelRel" .. i] = self:GetChildComponent("Panel/tab/Content/" .. i .. "/Select/tex_name", "Text")
	end

	self.btn_jump = self:GetChildGameObject("Panel/Image1/mask/btn_jump")
	self.content = self:GetChildComponent("Panel/ScrollArea/Content", "RectTransform")
	self.canvasGroup = self:GetChildComponent("Panel/ScrollArea/Content", "CanvasGroup")

	self:AddClick(self.btn_jump, self.OnClickedCellDetail)
	GOUtil.UpdateSpineSkeleton(self.UIRootObject.gameObject)

	self.BtnOneKey = self:GetChildGameObject("Panel/BtnOneKey")
	self.ImgOneKey = self:GetChildComponent("Panel/BtnOneKey", "Image")
	self.Fx_UI_009_2 = self:GetChildGameObject("Panel/BtnOneKey/Fx_UI_009_2")

	self:AddClick(self.BtnOneKey, self.OnClickedBtnOneKey)
	self:Init()
end

function DlgTimeLimitTask:OnClickedCellDetail(data)
	local go = data.pointerPress
	local cardId = 105301
	local data = {
		onlyShow = true,
		isOpenDlgTimeLimitTask = true,
		cardId = cardId
	}

	UIMgr.SwitchPanel(PageRoleCard, data)
end

function DlgTimeLimitTask:OnClickedBtnOneKey()
	TaskManager.integralList = {}

	local listCanRecv = {}

	for i = 1, #self.listTask do
		local v = TaskManager:Get(self.listTask[i])

		if v:IsComplete() and not v:IsGetAward() then
			table.insert(listCanRecv, v.id)

			if v.data and v.data.Reward and v.data.Reward[1] and v.data.Reward[1][1] == 518 then
				table.insert(TaskManager.integralList, v.data.Reward[1])
			end
		end
	end

	local function CheckScore()
		local taskListData = TaskLimitMgr:GetListLimitHourTask()[1]

		if not TaskManager.listTaskLineScore[taskListData.ID] then
			return false
		end

		local sumScore = TaskManager.listTaskLineScore[taskListData.ID].score
		local isHave = false

		for i = 1, #taskListData.ScoreSection do
			if not TaskManager:IsRecvedScoreAward(taskListData.ID, i - 1) and sumScore >= taskListData.ScoreSection[i][2] then
				isHave = true

				break
			end
		end

		return isHave
	end

	if #listCanRecv == 0 and not CheckScore() then
		UIMgr.ShowMsg(_("Msg_Award_Can_Receive_None"))

		return
	end

	local function wrap_cb(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Sucess then
			self:UpdateIntegral()
			self:UpdateTaskList()
		else
			TaskManager.integralList = {}

			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end

	local taskLineData = TaskLimitMgr:GetListLimitHourTask()[1]

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestReceiveCompleteTasksOneKey(taskLineData.ID, listCanRecv, wrap_cb)
end

function DlgTimeLimitTask:Request()
	self:UpdateIntegral()
	self:UpdateLimitTaskPanel()
end

function DlgTimeLimitTask:Init()
	self.list = TaskLimitMgr:GetListLimitHourTask()
	self.taskListId = self.list[1].ID
	self.listSection = self.list[1].TaskSection
	self.listSectionName = self.list[1].SectionlName

	self:InitPrompt()
	self:InitIntegralAward()
	self:InitTaskListPanel()
	self:Request()
	UITweenUtil.SetGroupAlpha(self.group.transform, 0)

	self.timer = TimerMgr.AddTimer(eTimerType.RealTime, 0.3, function()
		UITweenUtil.GroupAlphaAnim(self.group.transform, 0.2)
	end, nil)

	for i = 1, 5 do
		RedDotSystemMgr.SetUIRedDot(self["GoBtn" .. i], string.format("TaskLimitTime/%d/%d", self.taskListId, i))
	end
end

function DlgTimeLimitTask:OnUpdateSecond()
	if not IsNil(self.UIRootObject) and not self.txtTime then
		self.txtTime = self:GetChildComponent("Panel/Time/tex_time", "Text")
	end

	if self.txtTime and self.list then
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
		local registerTime = PlayerInst.InfoPlayer:GetRegisterTime()
		local endTime = registerTime + 3600 * self.list[1].LastTime

		endTime = endTime - curServerTime

		if endTime < 0 then
			self:OnBack()
			Event.Instance:Fire("HideTimeLimitTaskBtnEvent")

			return
		end

		self.txtTime.text = _("Desc_ActivityRemain") .. GetTimeFormatBySecond(endTime, "day")
	end
end

function DlgTimeLimitTask:InitPrompt()
	UIMgr.SetUpdatePanel(self)

	local txtTime = self:GetChildComponent("Panel/Time/tex_time", "Text")
	local registerTime = PlayerInst.InfoPlayer:GetRegisterTime()
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local endTime = registerTime + 3600 * self.list[1].LastTime

	endTime = endTime - curServerTime
	txtTime.text = _("Desc_ActivityRemain") .. GetTimeFormatBySecond(endTime, "day")
end

function DlgTimeLimitTask:InitIntegralAward()
	local list = TaskLimitMgr:GetListLimitHourTask()

	self.listScoreSection = list[1].ScoreSection
	self.scoreCnt = #self.listScoreSection
	self.listScoreAward = list[1].ScoreSectionReward
	self.maxScore = self.listScoreSection[self.scoreCnt][2]
	self.group = self:GetChildGameObject("Panel/AwardRate/Group")

	local cell = self:GetChildGameObject("Panel/AwardRate/Award")

	SetActiveFunc(self:GetChildGameObject("Panel/AwardRate/Award"), false)

	self.listItem = {}
	self.txtIntegralList = {}

	for i = 1, self.scoreCnt do
		local goCell = GOUtil.Instantiate(cell, self.group)

		SetActiveFunc(goCell, true)
		GOUtil.SetTransformRotation(goCell, 0, 0, 0)

		GOUtil.FindChildGameObject(goCell, "Cell").transform.localScale = Vector3(0.7, 0.7, 1)

		if i == 5 then
			GOUtil.FindChildGameObject(goCell, "Cell").transform.localScale = Vector3(0.9, 0.9, 1)

			GOUtil.SetRectTransformAnchoredPosition(GOUtil.FindChildGameObject(goCell, "Cell"), -45, -50)
			GOUtil.SetRectTransformAnchoredPosition(GOUtil.FindChildGameObject(goCell, "Image"), 15, -35)
		end

		local curScore = TaskManager:GetTaskListScore(self.taskListId)
		local txtIntegral = GOUtil.FindChildComponent(goCell, "Image/Text", "Text")

		table.insert(self.txtIntegralList, txtIntegral)

		txtIntegral.text = curScore .. "/" .. self.listScoreSection[i][2]

		local gItem = GOUtil.FindChildGameObject(goCell, "Cell")
		local item = CellSpecialItem(gItem)

		item:InitItemByRoot(gItem)

		gItem.name = i

		self:AddClick(item.UIRootObject, self.OnClickedIntegralAward)

		local award = self.listScoreAward[i][1]
		local infoItem = ItemManager:GetValueItem(award[1], award[2])

		if i ~= 5 then
			item:UpdateWithNumType(infoItem)
		else
			item:UpdateNoNumType(infoItem)
		end

		table.insert(self.listItem, item)

		local score = self.listScoreSection[i][2]
		local rate = score / self.maxScore
		local x = 650 * rate

		GOUtil.SetRectTransformAnchoredPosition(goCell, -43 + x, -15)
	end

	SetActiveFunc(cell, false)
end

function DlgTimeLimitTask:UpdateIntegral()
	local curScore = TaskManager:GetTaskListScore(self.taskListId)
	local text = self:GetChildComponent("Panel/AwardRate/Bar/Text", "Text")

	text.text = curScore .. "/" .. self.maxScore

	local image = self:GetChildComponent("Panel/AwardRate/Bar/Image", "Image")
	local rate = curScore / self.maxScore

	if rate > 1 then
		rate = 1
	end

	self.listTask = self.listSection[self.curRelIdx]

	self:UpdateTaskPanel()

	local txtTask = self:GetChildComponent("Panel/tab/Content/" .. self.curRelIdx .. "/Button/tex_num", "Text")

	txtTask.text = #self.listGeted .. "/" .. #self.listSection[self.curRelIdx]
	txtTask = self:GetChildComponent("Panel/tab/Content/" .. self.curRelIdx .. "/Select/tex_num", "Text")
	txtTask.text = #self.listGeted .. "/" .. #self.listSection[self.curRelIdx]
	image.fillAmount = rate

	for i = 1, #self.listItem do
		local item = self.listItem[i]
		local isRecv = TaskManager:IsRecvedScoreAward(self.list[1].ID, i - 1)

		if self.txtIntegralList[i] then
			self.txtIntegralList[i].text = curScore .. "/" .. self.listScoreSection[i][2]
		end

		item:SetGray(curScore < self.listScoreSection[i][2])
		item:SetReceived(isRecv)
	end
end

function DlgTimeLimitTask:OnClickedIntegralAward(data)
	local go = data.pointerPress
	local index = tonumber(go.name)
	local rewardIndex = index - 1
	local isRecv = TaskManager:IsRecvedScoreAward(self.taskListId, rewardIndex)

	if isRecv then
		UIMgr.ShowMsg(_("Desc_Has_Get"))

		return
	end

	local targetScore = self.listScoreSection[index][2]
	local curScore = TaskManager:GetTaskListScore(self.taskListId)

	if curScore < targetScore then
		UIMgr.ShowMsg(_("Msg_PointNotEnough"))

		return
	end

	local function cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == 0 then
			self:UpdateIntegral()
			InfoSoundEventMgr:LoadBank(RoleMgr:GetRole(105).data.VocalBank)

			local num = math.random(1, 3)

			if num == 1 then
				InfoSoundEventMgr:Play("VocalCommon10", RoleMgr:GetRole(105).data.VocalCommon10)
			elseif num == 2 then
				InfoSoundEventMgr:Play("VocalCommon6", RoleMgr:GetRole(105).data.VocalCommon6)
			elseif num == 3 then
				InfoSoundEventMgr:Play("VocalCustomsclearance3", RoleMgr:GetRole(105).data.VocalCustomsclearance3)
			end
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestTaskLineScoreReward(self.taskListId, rewardIndex, cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgTimeLimitTask:InitTaskListPanel()
	for i = 1, 5 do
		SetActiveFunc(self["GoBtn" .. i], i <= #self.listSection)

		if i <= #self.listSection then
			self["TxtBtnRel" .. i].text = Lang(self.listSectionName[i][1])
			self["TxtSelRel" .. i].text = Lang(self.listSectionName[i][1])
		end
	end

	self.curRelIdx = TaskLimitMgr:GetCompleteLimitTaskTabIndex()
end

function DlgTimeLimitTask:OnClickedBtnRel(data)
	local go = data.pointerPress.transform.parent.gameObject
	local index = tonumber(go.name)
	local isOpen = TaskLimitMgr:IsUnLockSingleList(index)

	if not isOpen then
		local list = self.list[1].SectionOpenNeed

		UIMgr.ShowMsg(string.format(_("Desc_Limit_Task_UnLock"), list[index]))

		return
	end

	if self.curRelIdx ~= index then
		self.curRelIdx = index

		self:UpdateLimitTaskPanel()
	end

	if self.UIScrollTool then
		self.listTask = self.listSection[self.curRelIdx]

		self.UIScrollTool:UpdateListData(self.listTask)
	end
end

function DlgTimeLimitTask:UpdateLimitTaskPanel()
	for i = 1, #self.listSection do
		SetActiveFunc(self["BtnRel" .. i], i ~= self.curRelIdx)
		SetActiveFunc(self["SelRel" .. i], i == self.curRelIdx)
	end

	self.listTask = self.listSection[self.curRelIdx]

	self:UpdateTaskPanel()

	local txtTask = self:GetChildComponent("Panel/tab/Content/" .. self.curRelIdx .. "/Button/tex_num", "Text")

	txtTask.text = #self.listGeted .. "/" .. #self.listSection[self.curRelIdx]
	txtTask = self:GetChildComponent("Panel/tab/Content/" .. self.curRelIdx .. "/Select/tex_num", "Text")
	txtTask.text = #self.listGeted .. "/" .. #self.listSection[self.curRelIdx]

	self:InitLimitTaskList()
	self:UpdateNewCompleteTask()
end

function DlgTimeLimitTask:UpdateTaskPanel()
	local listComplete = {}

	self.listGeted = {}

	for i = #self.listTask, 1, -1 do
		local info = TaskManager:Get(self.listTask[i])
		local isComple = info:IsComplete()
		local isGeted = info:IsGetAward()

		if isComple and isGeted then
			table.insert(self.listGeted, self.listTask[i])
			table.remove(self.listTask, i)
		elseif isComple and not isGeted then
			table.insert(listComplete, self.listTask[i])
			table.remove(self.listTask, i)
		end
	end

	local function func(a, b)
		return a < b
	end

	table.sort(listComplete, func)

	for i = #listComplete, 1, -1 do
		table.insert(self.listTask, 1, listComplete[i])
	end

	table.sort(self.listGeted, func)

	for i = 1, #self.listGeted do
		table.insert(self.listTask, self.listGeted[i])
	end

	local taskListData = TaskManager:GetTaskListData(eTaskListType.limitTime)
	local sumScore = TaskManager.listTaskLineScore[taskListData.ID].score
	local isHave = false

	for i = 1, #taskListData.ScoreSection do
		if not TaskManager:IsRecvedScoreAward(taskListData.ID, i - 1) and sumScore >= taskListData.ScoreSection[i][2] then
			isHave = true

			break
		end
	end

	if #listComplete ~= 0 or isHave then
		GOUtil.SetActive(self.Fx_UI_009_2, true)
		UIUtil.SetImageSprite(self.ImgOneKey, "UI/PanelOperation/AtlasTimeLimitTask/BTN_square_pink_01", self)
	else
		GOUtil.SetActive(self.Fx_UI_009_2, false)
		UIUtil.SetImageSprite(self.ImgOneKey, "UI/PanelOperation/AtlasTimeLimitTask/BTN_square_pink_02", self)
	end
end

function DlgTimeLimitTask:InitLimitTaskList()
	local scrollArea = self:GetChildGameObject("Panel/ScrollArea", "RectTransform")
	local count = #self.listTask

	for n = 1, count do
		local listGeted = {}

		if self.listSection[n] then
			for i = #self.listSection[n], 1, -1 do
				local info = TaskManager:Get(self.listSection[n][i])
				local isComple = info:IsComplete()
				local isGeted = info:IsGetAward()

				if isComple and isGeted then
					table.insert(listGeted, i)
				end
			end

			local txtTask = self:GetChildComponent("Panel/tab/Content/" .. n .. "/Button/tex_num", "Text")

			txtTask.text = #listGeted .. "/" .. #self.listSection[n]
			txtTask = self:GetChildComponent("Panel/tab/Content/" .. n .. "/Select/tex_num", "Text")
			txtTask.text = #listGeted .. "/" .. #self.listSection[n]
		end
	end

	UITweenUtil.RemoveTween(self.content)

	if not self.UIScrollTool then
		self.UIScrollTool = UIScrollTool()

		self.UIScrollTool:InitList(scrollArea, self.content, count, self.PrefabCell, CellTimeLimitTask, self, false)
		UITweenUtil.DoListAnimationUp(self.content, 300, 0.3, nil, nil)
	else
		if self.timer ~= nil then
			TimerMgr.RemoveTimer(self.timer)

			self.timer = nil
		end

		self.canvasGroup.alpha = 0
		self.timer = TimerMgr.AddTimer(eTimerType.FrameCount, 2, function()
			self.canvasGroup.alpha = 1

			UITweenUtil.DoListAnimationUp(self.content, 300, 0.3, nil, nil)
		end, nil)
	end
end

function DlgTimeLimitTask:UpdateCell(item, index)
	local taskId = self.listTask[index]

	item:UpdateData(taskId, index)
end

function DlgTimeLimitTask:AddCellClick(item)
	return
end

function DlgTimeLimitTask:UpdateNewCompleteTask()
	for i = 1, #self.listSection do
		local isOpen = TaskLimitMgr:IsUnLockSingleList(i)

		SetActiveFunc(self["GoLock" .. i], not isOpen)
		RedDotSystemMgr.SetNodeLockState(GetTaskBranchPath(eTaskListType.limitTime, i), not isOpen)
	end
end

function DlgTimeLimitTask:UpdateTaskList()
	self:UpdateNewCompleteTask()
	self.UIScrollTool:UpdateListDataKeepPos(self.listTask)
end

function DlgTimeLimitTask:GetOpenTime(strTime)
	local str = ""
	local a = string.split(strTime, " ")

	if #a > 0 then
		local date = string.split(a[1], "-")
		local yearT = tonumber(date[1])
		local monthT = tonumber(date[2])
		local dayT = tonumber(date[3])

		str = string.format(_("Desc_TimeType"), yearT, monthT, dayT)
	end

	return str
end

function DlgTimeLimitTask:UpdateNetData()
	self:UpdateTaskList()
	self:UpdateIntegral()
end
