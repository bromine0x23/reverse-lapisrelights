-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgOperationActiveLogin.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageOperation/CellModelType1")

DlgOperationActiveLogin = class("DlgOperationActiveLogin", UIItemBase)

function DlgOperationActiveLogin:ctor()
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function DlgOperationActiveLogin:Purge()
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
end

function DlgOperationActiveLogin:UnloadRef()
	return
end

function DlgOperationActiveLogin:BtnMaskOnClicked()
	if self.recvGetAwardList and self.recvGetAwardList[1] then
		if #self.recvGetAwardList == 1 then
			Event.Instance:Fire("ReceiveOperationActiveAward", self.recvGetAwardList[1], nil, nil, self.btn_mask)
		else
			Event.Instance:Fire("ReceiveOperationActiveAwardList", self.recvGetAwardList, self.btn_mask)
		end

		self.BtnMaskEvent = true
	end
end

function DlgOperationActiveLogin:OnRegisterEvent()
	return
end

function DlgOperationActiveLogin:OnUnRegisterEvent()
	return
end

function DlgOperationActiveLogin:OnEnter(vParam)
	self.PrefabCell = vParam.PrefabCell

	local g = self.UIRootObject

	UIMgr.SetUpdatePanel(self)

	self.scrollArea = GOUtil.FindChildGameObject(g, "Panel/BgAward/ScrollArea")
	self.content = GOUtil.FindChildComponent(self.scrollArea, "Content", "RectTransform")
	self.endTimeTex = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Text/Text" .. 1, "Text")
	self.recvGetAwardList = {}
	self.btn_mask = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/btn_mask")

	if not IsNil(self.btn_mask) then
		self:AddClick(self.btn_mask, self.BtnMaskOnClicked)
	end
end

function DlgOperationActiveLogin:DealWithLocalization(ActiveID)
	self.infoActive:SetOperationUIModel(ActiveID, self.BGRaw, self.UIRootObject)
end

function DlgOperationActiveLogin:Init(infoActive, BGRaw, ParentUIRootObject)
	self.BGRaw = BGRaw
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder
	self.infoActive = infoActive
	self.ParentUIRootObject = ParentUIRootObject

	self:DealWithLocalization(self.ActiveID)

	self.listLoginAward = OperationActiveMgr:GetActiveRewardItems(infoActive.id)

	local count = #self.listLoginAward

	local function addCallback(item)
		self:AddClick(item.UIRootObject, nil)
	end

	local function updateCallback(item, index)
		local data = self.listLoginAward[index]

		item:UpdateData(data, infoActive, 1, self.isShow)
	end

	self.UIScrollTool = UIScrollTool()
	self.isShow = false

	self.UIScrollTool:InitList(self.scrollArea, self.content, count, self.PrefabCell, CellModelType1, self, true, addCallback, updateCallback)
	self:SignCardAward(infoActive)
	self:GetAwardList()

	self.endTimeTex.text = OperationActiveMgr:GetOpenTime(infoActive.data.ShowEndTime)
end

function DlgOperationActiveLogin:GetAwardList()
	if self.listLoginAward then
		for i = 1, #self.listLoginAward do
			local Day = self.infoActive.pb.record
			local data = self.listLoginAward[i]
			local canRecv = Day >= data.index
			local isRecv = self.infoActive:IsGetIndexAward(data.index)

			if canRecv and not isRecv then
				table.insert(self.recvGetAwardList, data.index)
			end
		end
	end
end

function DlgOperationActiveLogin:UpdateData(infoActive)
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder
	self.infoActive = infoActive
	self.recvGetAwardList = {}

	self:DealWithLocalization(self.ActiveID)

	self.listLoginAward = OperationActiveMgr:GetActiveRewardItems(infoActive.id)

	self.UIScrollTool:UpdateListDataKeepPos(self.listLoginAward)
	self:SignCardAward(infoActive)

	self.endTimeTex.text = OperationActiveMgr:GetOpenTime(infoActive.data.ShowEndTime)

	self:GetAwardList()
end

function DlgOperationActiveLogin:OnUpdate()
	if not IsNil(self.ParentUIRootObject) and self.ParentUIRootObject.activeSelf and #self.recvGetAwardList ~= 0 and not self.BtnMaskEvent and OperationActiveMgr.PageOperationActiveType == 2 then
		OperationActiveMgr.isAuto = true

		self:BtnMaskOnClicked()
	end
end

function DlgOperationActiveLogin:OnUpdateSecond()
	if not IsNil(self.endTimeTex) and self.infoActive then
		self.endTimeTex.text = OperationActiveMgr:GetOpenTime(self.infoActive.data.ShowEndTime)
	end
end

function DlgOperationActiveLogin:SignCardAward(listOpenActive)
	local isHave, index = OperationActiveMgr:Get(listOpenActive.id):IsHaveCanRec()
	local pos = GetContentPosUGUIScroll(self.UIScrollTool.ScrollView, #self.listLoginAward, index, true)

	self.UIScrollTool:SetInitPos(Vector3(pos, 0, 0))
end
