-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgOperationActiveSamllClass.lua

require("UI/Item/UIItemBase")
require("Info/InfoTask")
require("UI/Page/PageTask/CellTask")

DlgOperationActiveSamllClass = class("DlgOperationActiveSamllClass", UIItemBase)

function DlgOperationActiveSamllClass:ctor()
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function DlgOperationActiveSamllClass:Purge()
	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	self:UnloadRef()
	UIMgr.RemoveUpdatePanel(self)
end

function DlgOperationActiveSamllClass:UnloadRef()
	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end

	self.infoActive:ClearOperationSpine()
	self:RemoveClick(self.BtnSel, self.OnClickSelAward)
	UnloadAllImageSprite(self)
end

function DlgOperationActiveSamllClass:OnRegisterEvent()
	return
end

function DlgOperationActiveSamllClass:OnUnRegisterEvent()
	return
end

function DlgOperationActiveSamllClass:OnEnter(vParam)
	self.PrefabCell = vParam.PrefabCell

	local g = self.UIRootObject

	self.scrollArea = GOUtil.FindChildGameObject(g, "Panel/BgAward/ScrollArea")
	self.content = GOUtil.FindChildComponent(self.scrollArea, "Content", "RectTransform")
	self.BtnSel = GOUtil.FindChildGameObject(g, "Panel/Model/Pic/Pic3/Btn_Sel")
	self.img_sel = GOUtil.FindChildGameObject(g, "Panel/Model/Pic/Pic3/Btn_Sel/img_sel")
	self.RawImage = GOUtil.FindChildGameObject(g, "Panel/Model/Pic/Pic3/RawImage")

	self:AddClick(self.BtnSel, self.OnClickSelAward)

	self.FX_UI_Welfare = GOUtil.FindChildGameObject(g, "Panel/Model/Fx/FX_UI_Welfare")

	GOUtil.SetGameObjectLayer(self.FX_UI_Welfare, LayerMask.NameToLayer("RT"))
	UIMgr.SetUpdatePanel(self)
end

function DlgOperationActiveSamllClass:DealWithLocalization(ActiveID)
	self.infoActive:SetOperationUIModel(ActiveID, self.BGRaw, self.UIRootObject)
end

function DlgOperationActiveSamllClass:Init(infoActive, BGRaw)
	self.BGRaw = BGRaw
	self.infoActiveID = infoActive.id
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder
	self.infoActive = infoActive

	self:DealWithLocalization(self.ActiveID)

	self.taskId = TaskManager:GetTaskListData(eTaskListType.samllClass).ID
	self.taskValue = TaskManager:GetTaskListScore(self.taskId)
	self.samllClassTaskList = TaskManager:GetSmallClassTask()

	local TaskListData = require("luaData/TaskListData")
	local award = BattlePassTaskMgr:GetSmallClassAwardList().ScoreSectionReward[1][1]
	local infoItem = ItemManager:GetValueItem(award[1], award[2])
	local gItem = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/Model/Pic/Pic3/CellItem")

	self.listItem = {}

	local item = CellItem(gItem)

	item:InitItemByRoot(gItem)
	item:UpdateWithNumType(infoItem)
	table.insert(self.listItem, item)

	local texTask = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Text/Text" .. 1, "Text")

	texTask.text = string.format(_("Desc_TaskFinish_1") .. ":%s", "<color=#ea5d63>" .. self.taskValue .. "</color>/" .. #self.samllClassTaskList)
	self.endTimeTex = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Text/Text", "Text")
	self.endTimeTex.text = OperationActiveMgr:GetOpenTime(infoActive.data.ShowEndTime)

	local isRecv = TaskManager:IsRecvedScoreAward(BattlePassTaskMgr:GetSmallClassTaskID(), 0)

	SetActiveFunc(self.img_sel, isRecv)
	SetActiveFunc(self.RawImage, not isRecv and #self.samllClassTaskList == self.taskValue)

	count = #self.samllClassTaskList

	local function addCallback(item)
		self:AddClick(item.BtnGet, nil)
	end

	local function updateCallback(item, index)
		local curList = self.samllClassTaskList
		local infoTask = curList[index]

		local function callback(...)
			OperationActiveMgr.Tag = eOperationActive.SmallClass
		end

		item:UpdateData(infoTask, nil, 104, callback)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.scrollArea, self.content, count, self.PrefabCell, CellTask, self, false, addCallback, updateCallback)
end

function DlgOperationActiveSamllClass:OnClickSelAward()
	Event.Instance:Fire("ReceiveOperationActiveAward", 1, true, self.type == 2)
end

function DlgOperationActiveSamllClass:UpdateData(infoActive)
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder

	self:DealWithLocalization(self.ActiveID)

	self.samllClassTaskList = TaskManager:GetSmallClassTask()

	self.UIScrollTool:UpdateListDataKeepPos(self.samllClassTaskList)

	self.taskValue = TaskManager:GetTaskListScore(self.taskId)

	local isRecv = TaskManager:IsRecvedScoreAward(BattlePassTaskMgr:GetSmallClassTaskID(), 0)

	SetActiveFunc(self.img_sel, isRecv)
	SetActiveFunc(self.RawImage, not isRecv and #self.samllClassTaskList == self.taskValue)

	local texTask = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Text/Text" .. 1, "Text")

	texTask.text = string.format(_("Desc_TaskFinish") .. ":%s", "<color=#ea5d63>" .. self.taskValue .. "</color>/" .. #self.samllClassTaskList)

	local uiInfo = InfoOperationActive:GetOperationUIInfo(self.ActiveID)

	self.endTimeTex.text = OperationActiveMgr:GetOpenTime(infoActive.data.ShowEndTime)

	for i = 1, 3 do
		local Text = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Text/Text" .. i, "Text")

		if uiInfo and uiInfo.Text and uiInfo.Text[i] and uiInfo.Text[i][1] and Text then
			Text.text = Lang(uiInfo.Text[i][1])

			Text.gameObject.transform:SetSiblingIndex(uiInfo.Text[i][2])
		end
	end
end

function DlgOperationActiveSamllClass:OnUpdateSecond()
	if self.infoActive then
		self.endTimeTex.text = OperationActiveMgr:GetOpenTime(self.infoActive.data.ShowEndTime)
	end
end
