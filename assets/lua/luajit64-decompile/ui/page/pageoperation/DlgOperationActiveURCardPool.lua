-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgOperationActiveURCardPool.lua

require("UI/Item/UIItemBase")
require("Info/InfoTask")
require("UI/Page/PageOperation/CellURCardPool")

DlgOperationActiveURCardPool = class("DlgOperationActiveURCardPool", UIItemBase)

function DlgOperationActiveURCardPool:ctor()
	return
end

function DlgOperationActiveURCardPool:Purge()
	self:UnloadRef()
end

function DlgOperationActiveURCardPool:UnloadRef()
	if self.taskCells then
		for i = 1, #self.taskCells do
			self.taskCells[i]:OnLeave()
		end
	end

	self.infoActive:ClearOperationSpine()
	self:RemoveClick(self.BtnGet, self.OnClickGoFrom)
	Event.Instance:Remove("DealWithCompleteURCardPoolTask", self.RequestURCardPoolTaskAward, self)
	UnloadAllImageSprite(self)
end

function DlgOperationActiveURCardPool:OnRegisterEvent()
	return
end

function DlgOperationActiveURCardPool:OnUnRegisterEvent()
	return
end

function DlgOperationActiveURCardPool:OnEnter(vParam)
	local g = self.UIRootObject

	self.PrefabCellItem = vParam.PrefabCell
	self.scrollArea = GOUtil.FindChildGameObject(g, "Panel/BgAward/ScrollArea")
	self.content = GOUtil.FindChildComponent(self.scrollArea, "Content", "RectTransform")
	self.BtnGet = GOUtil.FindChildGameObject(g, "Panel/BgAward/Button")
	self.Line = GOUtil.FindChildGameObject(g, "Panel/BgAward/Line")
	self.Fill = GOUtil.FindChildComponent(g, "Panel/BgAward/Line/Fill", "Image")

	self:AddClick(self.BtnGet, self.OnClickGoFrom)
	Event.Instance:Add("DealWithCompleteURCardPoolTask", self.RequestURCardPoolTaskAward, self)
end

function DlgOperationActiveURCardPool:DealWithLocalization(ActiveID)
	self.infoActive:SetOperationUIModel(ActiveID, self.BGRaw, self.UIRootObject)
end

function DlgOperationActiveURCardPool:Init(infoActive, BGRaw)
	self.BGRaw = BGRaw
	self.infoActive = infoActive
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder

	self:DealWithLocalization(self.ActiveID)

	self.list = TaskManager:GetTaskListDataByID(infoActive.data.DailyTime[1][1]).List
	self.taskCells = {}
	self.getDot = {}

	local fillIndex = 0
	local finishIndex = 0

	for i, v in pairs(self.list) do
		local info = TaskManager:Get(v)
		local taskCell = CellURCardPool(self.PrefabCellItem, self.content.gameObject, self)

		taskCell:Create()
		taskCell:UpdateData(info)

		local Get = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/BgAward/Line/Point" .. i .. "/Get")

		table.insert(self.getDot, Get)

		if Get then
			SetActiveFunc(Get, info:IsGetAward() or info:IsComplete())
		end

		if info:IsComplete() then
			fillIndex = fillIndex + 1
		end

		if info:IsGetAward() then
			finishIndex = finishIndex + 1
		end

		table.insert(self.taskCells, taskCell)
	end

	if finishIndex == #self.list then
		SetActiveFunc(self.Line, false)
		SetActiveFunc(self.BtnGet, true)
	else
		SetActiveFunc(self.Line, true)
		SetActiveFunc(self.BtnGet, false)

		self.Fill.fillAmount = (fillIndex - 1) / (#self.list - 1)
	end
end

function DlgOperationActiveURCardPool:OnClickGoFrom()
	UIMgr.ClearAndSavePageMainStage()
	DlgItemTip.GoToFrom(self.infoActive.data.BuffType[1], nil)
end

function DlgOperationActiveURCardPool:UpdateData(infoActive)
	self:DealWithLocalization(self.ActiveID)

	self.list = TaskManager:GetTaskListDataByID(infoActive.data.DailyTime[1][1]).List

	local fillIndex = 0
	local finishIndex = 0

	for i, v in ipairs(self.list) do
		local info = TaskManager:Get(v)

		self.taskCells[i]:UpdateData(info)

		local Get = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/BgAward/Line/Point" .. i .. "/Get")

		if Get then
			SetActiveFunc(Get, info:IsGetAward() or info:IsComplete())
		end

		if info:IsComplete() then
			fillIndex = fillIndex + 1
		end

		if info:IsGetAward() then
			finishIndex = finishIndex + 1
		end
	end

	if finishIndex == #self.list then
		SetActiveFunc(self.Line, false)
		SetActiveFunc(self.BtnGet, true)
	else
		SetActiveFunc(self.Line, true)
		SetActiveFunc(self.BtnGet, false)

		self.Fill.fillAmount = (fillIndex - 1) / (#self.list - 1)
	end
end

function DlgOperationActiveURCardPool:RequestURCardPoolTaskAward(listCompTask)
	for i = 1, #self.list do
		if self.list[i] == listCompTask.data.ID then
			if i == 1 then
				break
			else
				local taskInfo = TaskManager:Get(self.list[i - 1])

				if not taskInfo:IsGetAward() then
					UIMgr.ShowMsg(_("Desc_PleaseGetPre"))

					return
				end
			end
		end
	end

	local listCompId = {}

	table.insert(listCompId, listCompTask.pb.id)

	if listCompTask.data and listCompTask.data.Reward and listCompTask.data.Reward[1] and (listCompTask.data.Reward[1][1] == 514 or listCompTask.data.Reward[1][1] == 515) then
		table.insert(TaskManager.integralList, listCompTask.data.Reward[1])
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat, 61)

		if vMsg.result.code == NetManager.Result_Sucess then
			Event.Instance:Fire("TaskCompleteUpdate")
		else
			TaskManager.integralList = {}

			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestTaskChange(listCompId, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat, 61)
end
