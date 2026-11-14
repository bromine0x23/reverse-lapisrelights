-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgOperationActiveCommonOne.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageOperation/CellCommon1")

DlgOperationActiveCommonOne = class("DlgOperationActiveCommonOne", UIItemBase)

function DlgOperationActiveCommonOne:ctor()
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function DlgOperationActiveCommonOne:Purge()
	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	UIMgr.RemoveUpdatePanel(self)
	self.infoActive:ClearOperationSpine()
	UnloadAllImageSprite(self)

	if not IsNil(self.btn_mask) then
		self:RemoveClick(self.btn_mask, self.BtnMaskOnClicked)

		self.btn_mask = nil
	end

	if self.timer then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end

	Event.Instance:Remove("DlgOperationActiveCommonOneCloseEvent", self.DlgOperationActiveCommonOneCloseEvent, self)
end

function DlgOperationActiveCommonOne:DlgOperationActiveCommonOneCloseEvent()
	SetActiveFunc(self.btn_mask, false)
end

function DlgOperationActiveCommonOne:BtnMaskOnClicked()
	if self.recvGetAwardList and self.recvGetAwardList[1] and not self.timer then
		self.timer = TimerMgr.AddTimer(eTimerType.RealTime, 0, function()
			if #self.recvGetAwardList == 1 then
				TaskManager.commonAwardTomorrowList = {}

				if self.infoActive.data.TypeReward[self.recvGetAwardList[1] + 1] then
					local pack = OperationActiveMgr:GetRewardPackData(self.infoActive.data.TypeReward[self.recvGetAwardList[1] + 1]).PackItem

					for i = 1, 1 do
						local award = pack[i]

						if award then
							table.insert(TaskManager.commonAwardTomorrowList, award)
						end
					end
				end

				OperationActiveMgr.IsActiveCommon = true

				Event.Instance:Fire("ReceiveOperationActiveAward", self.recvGetAwardList[1], nil, nil)
			else
				OperationActiveMgr.IsActiveCommon = true

				Event.Instance:Fire("ReceiveOperationActiveAwardList", self.recvGetAwardList)
			end

			self.BtnMaskEvent = true
		end, nil)
	end
end

function DlgOperationActiveCommonOne:OnEnter(vParam)
	self.PrefabCell = vParam.PrefabCell

	local g = self.UIRootObject

	UIMgr.SetUpdatePanel(self)

	self.scrollArea = GOUtil.FindChildGameObject(g, "Panel/BgAward/ScrollArea")
	self.content = GOUtil.FindChildComponent(self.scrollArea, "Content", "RectTransform")
	self.contentGo = GOUtil.FindChildGameObject(g, "Panel/BgAward/ScrollArea/Content")
	self.gridLayout = GOUtil.GetComponent(self.contentGo, "GridLayoutGroup")
	self.endTimeTex = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Text/Text" .. 1, "Text")
	self.endTimeTex.text = "イベント期間：%s"
	self.recvGetAwardList = {}
	self.FX_UI_Welfare = GOUtil.FindChildGameObject(g, "Panel/Model/Fx/FX_UI_Welfare")

	GOUtil.SetGameObjectLayer(self.FX_UI_Welfare, LayerMask.NameToLayer("RT"))

	self.btn_mask = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/btn_mask")

	if not IsNil(self.btn_mask) then
		self:AddClick(self.btn_mask, self.BtnMaskOnClicked)
	end

	Event.Instance:Add("DlgOperationActiveCommonOneCloseEvent", self.DlgOperationActiveCommonOneCloseEvent, self)
end

function DlgOperationActiveCommonOne:DealWithLocalization(ActiveID)
	self.infoActive:SetOperationUIModel(ActiveID, self.BGRaw, self.UIRootObject)
end

function DlgOperationActiveCommonOne:Init(infoActive, BGRaw, ParentUIRootObject)
	self.BGRaw = BGRaw
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder
	self.infoActive = infoActive
	self.ParentUIRootObject = ParentUIRootObject

	self:DealWithLocalization(self.ActiveID)

	self.listCommonAward = OperationActiveMgr:GetActiveRewardItems(infoActive.id)

	if infoActive.data.Type == eOperationActiveType.Sign then
		self.Day = OperationActiveMgr:GetLoginSignDay(infoActive.data.UIType)
	end

	self.count = #self.listCommonAward

	local function addCallback(item)
		self:AddClick(item.UIRootObject, nil)
	end

	local function updateCallback(item, index)
		local data = self.listCommonAward[index]

		item:UpdateData(data, infoActive, self.Day, self.count, self.recvGetAwardList)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.scrollArea, self.content, self.count, self.PrefabCell, CellCommon1, self, true, addCallback, updateCallback)
	self.UIScrollTool:SetScrollDirection(false, false)
	self:GetAwardList()

	self.remanText = self.endTimeTex.text
	self.endTimeTex.text = string.format(self.remanText, OperationActiveMgr:GetEndTime(infoActive.data.ShowEndTime))
end

function DlgOperationActiveCommonOne:GetAwardList()
	if self.listCommonAward then
		if self.infoActive.data.Type == eOperationActiveType.Sign then
			local Day = self.Day

			for i = 1, #self.listCommonAward do
				local data = self.listCommonAward[i]
				local isGeted = self.infoActive:IsGetIndexAward(data.index)

				if data.index == Day and not isGeted then
					table.insert(self.recvGetAwardList, data.index)
				end
			end
		else
			for i = 1, #self.listCommonAward do
				local Day = self.infoActive.pb.record
				local data = self.listCommonAward[i]
				local canRecv = Day >= data.index
				local isRecv = self.infoActive:IsGetIndexAward(data.index)

				if canRecv and not isRecv then
					table.insert(self.recvGetAwardList, data.index)
				end
			end
		end
	end

	if self.infoActive.data.UIType == eOperationActive.CommonOne then
		if OperationActiveMgr.PageOperationActiveType == 2 then
			self.gridLayout.spacing = Vector2.New(TenaryOp(#self.listCommonAward == 7, 20, 40), 0)
		else
			self.gridLayout.spacing = Vector2.New(TenaryOp(#self.listCommonAward == 7, 10, TenaryOp(#self.listCommonAward == 6, 40, 50)), 0)
		end
	end
end

function DlgOperationActiveCommonOne:UpdateData(infoActive)
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder
	self.infoActive = infoActive

	self:DealWithLocalization(self.ActiveID)

	self.listCommonAward = OperationActiveMgr:GetActiveRewardItems(infoActive.id)

	if infoActive.data.Type == eOperationActiveType.Sign then
		self.Day = OperationActiveMgr:GetLoginSignDay(infoActive.data.UIType)
	end

	self.count = #self.listCommonAward

	self.UIScrollTool:UpdateListDataKeepPos(self.listCommonAward)

	self.recvGetAwardList = {}

	self:GetAwardList()

	self.endTimeTex.text = string.format(self.remanText, OperationActiveMgr:GetEndTime(infoActive.data.ShowEndTime))
end

function DlgOperationActiveCommonOne:OnUpdate()
	if not IsNil(self.ParentUIRootObject) and self.ParentUIRootObject.activeSelf and #self.recvGetAwardList ~= 0 and not self.BtnMaskEvent and OperationActiveMgr.PageOperationActiveType == 2 then
		OperationActiveMgr.isAuto = true

		self:BtnMaskOnClicked()
	end
end

function DlgOperationActiveCommonOne:OnUpdateSecond()
	if not IsNil(self.endTimeTex) and self.infoActive then
		self.endTimeTex.text = string.format(self.remanText, OperationActiveMgr:GetEndTime(self.infoActive.data.ShowEndTime))
	end
end
