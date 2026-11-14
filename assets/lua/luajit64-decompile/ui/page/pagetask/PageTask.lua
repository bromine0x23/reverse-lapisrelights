-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTask/PageTask.lua

require("UI.Item.UITab")
require("UI/Page/PageTask/CellTask")
require("UI/Item/CellScoreItem")

local TaskListData = require("luaData.TaskListData")

PageTask = class("PageTask", UIPanel)

local taskTabType = {
	eTaskListType.main,
	eTaskListType.daily,
	eTaskListType.weekly,
	eTaskListType.achievement
}
local taskRoleID = {
	702,
	601,
	102,
	501
}

function PageTask:ctor()
	self.UIPrefabPath = "UI/PanelTask/PageTask"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_Task"),
		callback = self.OnBack,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo(), {
		x = -600,
		y = -42
	})
end

function PageTask:PreLoad()
	self:LoadResAsync("UI/PanelTask/CellTask", "PrefabCell", GameObject)
	self:LoadResAsync("UI/Item/CellScoreItem", "PrefabCellScoreItem", GameObject)
end

function PageTask:OnBack()
	TaskManager.tabIndex = 0

	UIMgr.PopPanel()
end

function PageTask:Purge()
	PageTask.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCell)
	ResourceMgr.Unload(self.PrefabCellScoreItem)
	UnloadAllImageSprite(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.listScoreItem then
		for _, cell in ipairs(self.listScoreItem) do
			if cell.OnLeave then
				cell:OnLeave()
			end
		end

		self.listScoreItem = nil
	end

	if self.timer ~= nil then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end

	if self.uiTab then
		self.uiTab:Dispose()
	end

	UITweenUtil.RemoveTween(self.content)
	UITweenUtil.RemoveTween(self.tabGo.transform)
	InfoSoundEventMgr:OnBack()
end

function PageTask:OnRegisterEvent()
	self:AddClick(self.BtnOneKey, self.OnClickedBtnOneKey)
	Event.Instance:Add("TaskResetUpdate", self.InitData, self)
	Event.Instance:Add("DealWithCompleteTask", self.RequestReceiveTaskAward, self)
	Event.Instance:Add("RequestScoreAward", self.RequestScoreAward, self)
	Event.Instance:Add("UpdateNetData", self.UpdateNetData, self)
	Event.Instance:Add(EventEnum.UpdatePlayerInfo, self.NotifyUpdate, self)
end

function PageTask:OnUnRegisterEvent()
	self:RemoveClick(self.BtnOneKey, self.OnClickedBtnOneKey)
	Event.Instance:Remove("TaskResetUpdate", self.InitData, self)
	Event.Instance:Remove("DealWithCompleteTask", self.RequestReceiveTaskAward, self)
	Event.Instance:Remove("RequestScoreAward", self.RequestScoreAward, self)
	Event.Instance:Remove("UpdateNetData", self.UpdateNetData, self)
	Event.Instance:Remove(EventEnum.UpdatePlayerInfo, self.NotifyUpdate, self)
end

function PageTask:NotifyUpdate()
	NetManager:GetSpeicalTaskInfo(function()
		self:UpdatePanelAfterTaskComplete()
	end)
end

function PageTask:OnEnter()
	self:DealWithLocalization()

	local tasks = TaskManager:GetList(eTaskListType.cosume)
	local newBtn = self:GetChildGameObject("SafeArea/TagGroup/Btn5")

	if #tasks > 0 then
		taskTabType[5] = eTaskListType.cosume
		taskRoleID[5] = 702

		newBtn:SetActive(true)
	else
		newBtn:SetActive(false)
	end

	self.tabGo = self:GetChildGameObject("SafeArea/TagGroup")

	if TaskManager.tabIndex ~= 0 then
		self.uiTab = UITab(self.tabGo, #taskTabType, self.OnClickedTabGroup, self, TaskManager.tabIndex)
	else
		self.uiTab = UITab(self.tabGo, #taskTabType, self.OnClickedTabGroup, self, 1)
	end

	self.TaskIcon = self:GetChildComponent("SafeArea/Panel/TaskIcon", "Image")
	self.GoScore = self:GetChildGameObject("SafeArea/Panel/Score")
	self.GoScoreGroup = self:GetChildGameObject("SafeArea/Panel/Score/Group")
	self.GoTaskNone = self:GetChildGameObject("SafeArea/Panel/GoTaskNone")
	self.lineScoreText = self:GetChildComponent("SafeArea/Panel/Score/BgValue/TxtValue", "Text")
	self.lineScoreBar = self:GetChildGameObject("SafeArea/Panel/Score/BarBack/Bar")
	self.BtnOneKey = self:GetChildGameObject("SafeArea/Panel/BtnOneKey")
	self.ImgOneKey = self:GetChildComponent("SafeArea/Panel/BtnOneKey", "Image")
	self.Fx_UI_009_2 = self:GetChildGameObject("SafeArea/Panel/BtnOneKey/Fx_UI_009_2")

	self:InitData()
	UITweenUtil.CommonTweenRight(self.tabGo.transform, 40, 0.14)

	local width = GOUtil.GetRectTransformWidth(self.UIRootObject)
	local size = Screen.safeArea.size

	self:SetSafeArea(self:GetChildGameObject("SafeArea"))
	NetManager:GetSpeicalTaskInfo(function()
		return
	end)
end

function PageTask:DealWithLocalization()
	local txt = self:GetChildComponent("SafeArea/TagGroup/Btn1/Btn/Text", "Text")

	txt.text = _("PageTask_Main")
	txt = self:GetChildComponent("SafeArea/TagGroup/Btn1/Select/Text", "Text")
	txt.text = _("PageTask_Main")
	txt = self:GetChildComponent("SafeArea/TagGroup/Btn2/Btn/Text", "Text")
	txt.text = _("PageTask_Daily")
	txt = self:GetChildComponent("SafeArea/TagGroup/Btn2/Select/Text", "Text")
	txt.text = _("PageTask_Daily")
	txt = self:GetChildComponent("SafeArea/TagGroup/Btn3/Btn/Text", "Text")
	txt.text = _("PageTask_Week")
	txt = self:GetChildComponent("SafeArea/TagGroup/Btn3/Select/Text", "Text")
	txt.text = _("PageTask_Week")
	txt = self:GetChildComponent("SafeArea/TagGroup/Btn4/Btn/Text", "Text")
	txt.text = _("PageTask_Achievement")
	txt = self:GetChildComponent("SafeArea/TagGroup/Btn4/Select/Text", "Text")
	txt.text = _("PageTask_Achievement")
	txt = self:GetChildComponent("SafeArea/TagGroup/Btn5/Btn/Text", "Text")
	txt.text = _("PageTask_Cosume")
	txt = self:GetChildComponent("SafeArea/TagGroup/Btn5/Select/Text", "Text")
	txt.text = _("PageTask_Cosume")
	txt = self:GetChildComponent("SafeArea/Panel/Score/BgValue/Text", "Text")
	txt.text = _("PageTask_CurrentLiveness")
	txt = self:GetChildComponent("SafeArea/Panel/BtnOneKey/Text", "Text")
	txt.text = _("Desc_OneKeyRec")
end

function PageTask.RequestTaskList(cb)
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			Event.Instance:Fire("TaskResetUpdate")
			Event.Instance:Fire("UpdateOperationActive")
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestTaskList(wrap_cb)
end

function PageTask:InitData()
	self.listAllTask = {}

	for _, v in pairsByKeys(taskTabType) do
		table.insert(self.listAllTask, TaskManager:SortTaskList(TaskManager:GetList(v)))
	end

	self:UpdateScorePanel()
	self:UpdateTaskListPanel()
	self:UpdateUIShowOrHide()
end

function PageTask:UpdateTab()
	return
end

local function GetTaskListData(index)
	if not taskTabType[index] then
		return nil
	end

	local taskListData = TaskManager:GetTaskListData(taskTabType[index])

	return taskListData
end

function PageTask:UpdateScorePanel()
	UIUtil.SetImageSprite(self.TaskIcon, "UI/PanelTask/AtlasTask/BG_activity_frame_0" .. self.uiTab.index, self)

	if not TaskManager:IsHaveTaskListScore(taskTabType[self.uiTab.index]) then
		return
	end

	self.listScoreItem = self.listScoreItem or {}

	local taskListData = GetTaskListData(self.uiTab.index)

	if not taskListData then
		return
	end

	local maxScore = taskListData.ScoreSection[#taskListData.ScoreSection][2]
	local count = #taskListData.ScoreSection
	local width = GOUtil.GetRectTransformSizeDeltaWidth(self.GoScoreGroup)

	local function FunUpdate(index, cell)
		local id = taskListData.ScoreSectionReward[index][1][1]
		local num = taskListData.ScoreSectionReward[index][1][2]
		local infoItem = ItemManager:GetValueItem(id, num)
		local data = {
			infoItem = infoItem,
			index = index,
			strValue = string.format(_("X_Score"), taskListData.ScoreSection[index][2]),
			path = GetTaskScoreBranchPath(taskListData.Type, index)
		}

		cell:UpdateData(data)
	end

	local function FunCreate(index)
		local cell = CellScoreItem(self.PrefabCellScoreItem, self.GoScoreGroup, self)

		cell:Create()

		cell.name = index

		GOUtil.SetRectTransformOffsetType(cell.UIRootObject, 3, taskListData.ScoreSection[index][2] / maxScore * width, 0)
		FunUpdate(index, cell)
		table.insert(self.listScoreItem, cell)
	end

	if count > #self.listScoreItem then
		for i = 1, count do
			if i <= #self.listScoreItem then
				local cell = self.listScoreItem[i]

				GOUtil.SetActive(cell.UIRootObject, true)
				FunUpdate(i, cell)
			else
				FunCreate(i)
			end
		end
	else
		for k, cell in ipairs(self.listScoreItem) do
			if k <= count then
				GOUtil.SetActive(cell.UIRootObject, true)
				FunUpdate(k, cell)
			else
				GOUtil.SetActive(cell.UIRootObject, false)
			end
		end
	end

	self:UpdateScoreReward()
end

function PageTask:UpdateScoreReward()
	if not TaskManager:IsHaveTaskListScore(taskTabType[self.uiTab.index]) then
		return
	end

	local taskListData = GetTaskListData(self.uiTab.index)

	if not taskListData then
		return
	end

	local curScore = TaskManager:GetTaskListScore(taskListData.ID)
	local maxScore = taskListData.ScoreSection[#taskListData.ScoreSection][2]

	self.lineScoreText.text = curScore
	self.lineScoreBar.transform.localScale = Vector3(TenaryOp(curScore / maxScore > 1, 1, curScore / maxScore), 1, 1)

	if self.listScoreItem then
		for k, cell in ipairs(self.listScoreItem) do
			local isReced = TaskManager:IsRecvedScoreAward(taskListData.ID, k - 1)
			local targetScore = taskListData.ScoreSection[k][2]

			cell:UpdateState(isReced, targetScore <= curScore)
		end
	end
end

function PageTask:UpdateTaskListPanel()
	if self.inited then
		self.UIScrollTool:UpdateListDataKeepPos(self.listAllTask[self.uiTab.index] or {})

		return
	end

	self.inited = true
	self.ScrollArea = self:GetChildGameObject("SafeArea/Panel/ScrollArea")
	self.content = self:GetChildComponent("SafeArea/Panel/ScrollArea/Content", "RectTransform")

	local count = #self.listAllTask[self.uiTab.index]

	local function addCallback(item)
		self:AddClick(item.UIRootObject, nil)
	end

	local function updateCallback(item, index)
		local curList = self.listAllTask[self.uiTab.index]
		local infoTask = curList[index]

		item:UpdateData(infoTask, nil, taskRoleID[self.uiTab.index])
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.ScrollArea, self.content, count, self.PrefabCell, CellTask, self, false, addCallback, updateCallback)
	UITweenUtil.DoListAnimationUp(self.content, 300, 0.3, nil, nil)
end

function PageTask:OnClickedTabGroup()
	self:UpdateScorePanel()
	self.UIScrollTool:SetContentPosImmediate(Vector2.zero, self.listAllTask[self.uiTab.index] or {})
	self:UpdateTaskListPanel()
	self:UpdateUIShowOrHide()

	TaskManager.tabIndex = self.uiTab.index

	UITweenUtil.RemoveTween(self.content)

	if self.timer ~= nil then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end

	GOUtil.SetActive(self.content, false)

	self.timer = TimerMgr.AddTimer(eTimerType.FrameCount, 2, function()
		GOUtil.SetActive(self.content, true)
		UITweenUtil.DoListAnimationUp(self.content, 300, 0.3, nil, nil)
	end, nil)
end

function PageTask:UpdateUIShowOrHide()
	local tasks = self.listAllTask[self.uiTab.index] or {}
	local hasTask = next(tasks) ~= nil

	GOUtil.SetActive(self.GoTaskNone, not hasTask)
	GOUtil.SetActive(self.GoScore, hasTask and TaskManager:IsHaveTaskListScore(taskTabType[self.uiTab.index]))
	GOUtil.SetActive(self.TaskIcon, hasTask)

	if not hasTask then
		return
	end

	local listCanRecv = {}

	for _, task in ipairs(tasks) do
		if task:IsComplete() and not task:IsGetAward() then
			table.insert(listCanRecv, task)
		end
	end

	local hasCanRecvScore = false

	if TaskManager:IsHaveTaskListScore(taskTabType[self.uiTab.index]) then
		local taskListData = GetTaskListData(self.uiTab.index)
		local sumScore = TaskManager.listTaskLineScore[taskListData.ID].score

		for i = 1, #taskListData.ScoreSection do
			if not TaskManager:IsRecvedScoreAward(taskListData.ID, i - 1) and sumScore >= taskListData.ScoreSection[i][2] then
				hasCanRecvScore = true

				break
			end
		end
	end

	if next(listCanRecv) ~= nil or hasCanRecvScore then
		GOUtil.SetActive(self.Fx_UI_009_2, true)
		UIUtil.SetImageSprite(self.ImgOneKey, "UI/PanelTask/AtlasTask/BTN_square_pink_01", self)
	else
		GOUtil.SetActive(self.Fx_UI_009_2, false)
		UIUtil.SetImageSprite(self.ImgOneKey, "UI/PanelTask/AtlasTask/BTN_square_pink_02", self)
	end

	GOUtil.SetActive(self.BtnOneKey, self.uiTab.index ~= 5)
end

function PageTask:UpdatePanelAfterTaskComplete()
	self:UpdateTab()
	self:UpdateScoreReward()

	self.listAllTask[self.uiTab.index] = TaskManager:SortTaskList(TaskManager:GetList(taskTabType[self.uiTab.index]))

	self:UpdateTaskListPanel()
	self:UpdateUIShowOrHide()
end

function PageTask:PlayVoice()
	local role = RoleMgr:GetRole(taskRoleID[self.uiTab.index])

	if not role then
		return
	end

	InfoSoundEventMgr:LoadBank(role.data.VocalBank)

	local num = math.random(3)

	if num == 1 then
		InfoSoundEventMgr:Play("VocalCommon10", role.data.VocalCommon10)
	elseif num == 2 then
		InfoSoundEventMgr:Play("VocalCommon6", role.data.VocalCommon6)
	elseif num == 3 then
		InfoSoundEventMgr:Play("VocalCustomsclearance3", role.data.VocalCustomsclearance3)
	end
end

function PageTask:RequestScoreAward(data)
	local index = data.index
	local cb = data.callback
	local rewardIndex = index - 1
	local taskListData = GetTaskListData(self.uiTab.index)

	self:RequestTaskLineScore(taskListData.ID, rewardIndex)
end

function PageTask:RequestTaskLineScore(taskListId, rewardIndex)
	local function cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self:UpdateTab()
			self:UpdateScoreReward()
			self:PlayVoice()
			self:UpdateUIShowOrHide()
		elseif vMsg.result.code == NetManager.Result_Timeout then
			self.DealTimeOut()
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestTaskLineScoreReward(taskListId, rewardIndex, cb)
end

function PageTask:RequestReceiveTaskAward(listCompTask)
	local listCompId = {}

	TaskManager.integralList = {}

	for _, v in pairs(listCompTask) do
		table.insert(listCompId, v.pb.id)

		if v.data and v.data.Reward and v.data.Reward[1] and (v.data.Reward[1][1] == 514 or v.data.Reward[1][1] == 515) then
			table.insert(TaskManager.integralList, v.data.Reward[1])
		end
	end

	if #listCompTask == 1 and listCompTask[1]:GetTaskType() == eTaskType.Cosume then
		local function wrap_cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vMsg.result.code == NetManager.Result_Sucess then
				self:UpdatePanelAfterTaskComplete()
				self:PlayVoice()
			elseif vMsg.result.code == NetManager.Result_Timeout then
				self.DealTimeOut()
			else
				TaskManager.integralList = {}

				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestSpeicalTaskAward(listCompId, wrap_cb)

		return
	end

	local function fun()
		if self.isOneKey then
			self:OneKeyReceiveScoreReward()

			self.isOneKey = false
		end
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self:UpdatePanelAfterTaskComplete()
			self:PlayVoice()
		elseif vMsg.result.code == NetManager.Result_Timeout then
			self.DealTimeOut()
		else
			TaskManager.integralList = {}

			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestTaskChange(listCompId, wrap_cb, fun)
end

function PageTask:OneKeyReceiveScoreReward()
	local taskListData = GetTaskListData(self.uiTab.index)

	if not TaskManager.listTaskLineScore[taskListData.ID] then
		return
	end

	local sumScore = TaskManager.listTaskLineScore[taskListData.ID].score
	local isHave = false

	for i = 1, #taskListData.ScoreSection do
		if not TaskManager:IsRecvedScoreAward(taskListData.ID, i - 1) and sumScore >= taskListData.ScoreSection[i][2] then
			isHave = true

			break
		end
	end

	if isHave then
		self:RequestTaskLineScore(taskListData.ID, -1)
	elseif not self.haveCompTask then
		UIMgr.ShowMsg(_("Msg_Award_Can_Receive_None"))
	end
end

function PageTask:OnClickedBtnOneKey()
	TaskManager.integralList = {}

	local list = self.listAllTask[self.uiTab.index]
	local listCanRecv = {}

	for _, v in pairs(list) do
		if v:IsComplete() and not v:IsGetAward() then
			table.insert(listCanRecv, v.id)

			if v.data and v.data.Reward and v.data.Reward[1] and (v.data.Reward[1][1] == 514 or v.data.Reward[1][1] == 515) then
				table.insert(TaskManager.integralList, v.data.Reward[1])
			end
		end
	end

	local function CheckScore()
		local taskListData = GetTaskListData(self.uiTab.index)

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
			self:UpdatePanelAfterTaskComplete()
			self:PlayVoice()
		elseif pb.result.code == NetManager.Result_Timeout then
			self.DealTimeOut()
		else
			TaskManager.integralList = {}

			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end

	local taskLineData = GetTaskListData(self.uiTab.index)

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestReceiveCompleteTasksOneKey(taskLineData.ID, listCanRecv, wrap_cb)
end

function PageTask:UpdateNetData()
	self:UpdatePanelAfterTaskComplete()
end

function PageTask.DealTimeOut()
	local strContent = _("Desc_NoNetwork")

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), strContent, function()
		Restart()
	end, _("UI_OK"), nil, false)
end
