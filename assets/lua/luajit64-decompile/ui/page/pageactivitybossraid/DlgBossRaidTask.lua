-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivityBossRaid/DlgBossRaidTask.lua

require("UI/Page/PageActivityBossRaid/CellBossRaidInfo")
require("UI/Page/PageActivityBossRaid/DlgBossRaidOver")
require("UI/Page/PageTask/CellTaskRaidboss")

DlgBossRaidTask = class("DlgBossRaidTask", UIPanel)

function DlgBossRaidTask:ctor()
	self.UIPrefabPath = "UI/PanelActivityBossRaid/DlgBossRaidTask"
end

function DlgBossRaidTask:Purge()
	DlgBossRaidTask.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCell)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end
end

function DlgBossRaidTask:OnRegisterEvent()
	Event.Instance:Add("TaskResetUpdate", self.RequestTaskList, self)
	Event.Instance:Add("UpdateNetData", self.UpdateNetData, self)
	self:AddClick(self.GetAll, self.OnClickedBtnOneKey)
	self:AddClick(self.CloseBtn, self.Close)
	Event.Instance:Add("DealWithCompleteTask", self.RequestReceiveTaskAward, self)
	Event.Instance:Add("CloseBossRaidTask", self.Close, self)
end

function DlgBossRaidTask:OnUnRegisterEvent()
	Event.Instance:Remove("TaskResetUpdate", self.RequestTaskList, self)
	Event.Instance:Remove("UpdateNetData", self.UpdateNetData, self)
	self:RemoveClick(self.GetAll, self.OnClickedBtnOneKey)
	self:RemoveClick(self.CloseBtn, self.Close)
	Event.Instance:Remove("DealWithCompleteTask", self.RequestReceiveTaskAward, self)
	Event.Instance:Remove("CloseBossRaidTask", self.Close, self)
end

function DlgBossRaidTask:PreLoad()
	self:LoadResAsync("UI/PanelActivityBossRaid/CellTaskJPRaidBoss", "PrefabCell")
end

function DlgBossRaidTask:OnEnter(vParam)
	self.GetAll = self:GetChildGameObject("GetAll")
	self.ImgOneKey = self:GetChildComponent("GetAll", "Image")
	self.CloseBtn = self:GetChildGameObject("Panel/Close")
	self.Fx_UI_009_2 = self:GetChildGameObject("GetAll/Fx_UI_009_2")

	self:InitData()
	UIMgr.SetUpdatePanel(self)
end

function DlgBossRaidTask:InitData()
	self.listTask = TaskManager:SortTaskList(TaskManager:GetList(eTaskListType.bossRaid))

	self:UpdateTaskListPanel()
	self:UpdateUIShowOrHide()
end

function DlgBossRaidTask:UpdateTaskListPanel()
	if self.inited then
		self.UIScrollTool:UpdateListDataKeepPos(self.listTask or {})

		return
	end

	self.inited = true
	self.ScrollArea = self:GetChildGameObject("Panel/ScrollArea")

	local content = self:GetChildComponent("Panel/ScrollArea/Content", "RectTransform")
	local count = #self.listTask

	local function addCallback(item)
		self:AddClick(item.UIRootObject, nil)
	end

	local function updateCallback(item, index)
		local curList = self.listTask
		local infoTask = curList[index]

		item:UpdateData(infoTask)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.ScrollArea, content, count, self.PrefabCell, CellTaskRaidboss, self, false, addCallback, updateCallback)
end

function DlgBossRaidTask:RequestTaskList()
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			self:InitData()
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetManager:RequestTaskList(wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgBossRaidTask:UpdatePanelAfterTaskComplete()
	self.listTask = TaskManager:SortTaskList(TaskManager:GetList(eTaskListType.bossRaid))

	self:UpdateTaskListPanel()
	self:UpdateUIShowOrHide()
end

function DlgBossRaidTask:OnClickedBtnOneKey()
	local list = self.listTask
	local listComp = {}

	for _, v in pairs(list) do
		if v:IsComplete() and not v:IsGetAward() then
			table.insert(listComp, v)
		end
	end

	if #listComp == 0 then
		self.haveCompTask = false

		UIMgr.ShowMsg(_("Msg_Award_Can_Receive_None"))
	else
		self.haveCompTask = true

		self:RequestReceiveTaskAward(listComp)
	end
end

function DlgBossRaidTask:UpdateUIShowOrHide()
	local tasks = self.listTask
	local hasTask = next(tasks) ~= nil

	if not hasTask then
		return
	end

	local listCanRecv = {}

	for _, task in ipairs(tasks) do
		if task:IsComplete() and not task:IsGetAward() then
			table.insert(listCanRecv, task)
		end
	end

	if next(listCanRecv) ~= nil then
		DealWithListRef(self, UIUtil.SetImageGray(self.ImgOneKey, 0))
		self.Fx_UI_009_2:SetActive(true)
	else
		DealWithListRef(self, UIUtil.SetImageGray(self.ImgOneKey, 1))
		self.Fx_UI_009_2:SetActive(false)
	end
end

function DlgBossRaidTask:RequestReceiveTaskAward(listCompTask)
	local listCompId = {}

	for _, v in pairs(listCompTask) do
		table.insert(listCompId, v.pb.id)

		if v.data and v.data.Reward and v.data.Reward[1] and (v.data.Reward[1][1] == 514 or v.data.Reward[1][1] == 515) then
			table.insert(TaskManager.integralList, v.data.Reward[1])
		end
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat, 61)

		if vMsg.result.code == NetManager.Result_Sucess then
			self:UpdatePanelAfterTaskComplete()
		else
			TaskManager.integralList = {}

			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestTaskChange(listCompId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat, 61)
end

function DlgBossRaidTask:UpdateNetData()
	self:UpdatePanelAfterTaskComplete()
end

function DlgBossRaidTask:GetShiftedServerTime()
	return NetData:GetCurServerTime() / DateUtil.MillsPerSecond - 14400
end

function DlgBossRaidTask:OnUpdateSecond()
	if self.nextRefreshTime ~= nil then
		if self.nextRefreshTime < self:GetShiftedServerTime() then
			UIMgr.RemoveUpdatePanel(self)
			Event.Instance:Fire("TaskResetUpdate")
		end
	else
		local shiftedTime = os.date("*t", self:GetShiftedServerTime())

		self.nextRefreshTime = os.time({
			hour = 24,
			second = 0,
			minute = 0,
			day = shiftedTime.day,
			month = shiftedTime.month,
			year = shiftedTime.year
		})
	end
end
