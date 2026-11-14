-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOperation/DlgOperationActiveBirthday.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageOperation/CellModelType2")

DlgOperationActiveBirthday = class("DlgOperationActiveBirthday", UIItemBase)

function DlgOperationActiveBirthday:ctor()
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function DlgOperationActiveBirthday:Purge()
	self:UnloadRef()
end

function DlgOperationActiveBirthday:UnloadRef()
	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.cell1 then
		self.cell1:OnLeave()
	end

	self:RemoveClick(self.btn_extra, self.OnClickedExtraAward)
	Event.Instance:Remove("ShowOperationActive", self.RebuildText, self)
	UnloadAllImageSprite(self)

	if not IsNil(self.btn_mask) then
		self:RemoveClick(self.btn_mask, self.BtnMaskOnClicked)

		self.btn_mask = nil
	end

	UIMgr.RemoveUpdatePanel(self)
end

function DlgOperationActiveBirthday:OnRegisterEvent()
	return
end

function DlgOperationActiveBirthday:OnUnRegisterEvent()
	return
end

function DlgOperationActiveBirthday:OnEnter(vParam)
	self.PrefabCell = vParam.PrefabCell

	local g = self.UIRootObject

	UIMgr.SetUpdatePanel(self)

	self.scrollArea = GOUtil.FindChildGameObject(g, "Panel/BgAward/ScrollArea")
	self.content = GOUtil.FindChildComponent(self.scrollArea, "Content", "RectTransform")
	self.FX_UI_Activity = GOUtil.FindChildGameObject(g, "Panel/Model/Fx/FX_UI_Activity")

	GOUtil.SetGameObjectLayer(self.FX_UI_Activity, LayerMask.NameToLayer("RT"))

	self.FX_UI_Welfare = GOUtil.FindChildGameObject(g, "Panel/Model/Fx/FX_UI_Welfare")

	GOUtil.SetGameObjectLayer(self.FX_UI_Welfare, LayerMask.NameToLayer("RT"))

	self.cell = GOUtil.FindChildGameObject(g, "Panel/go_extra/Cell")
	self.img_pic1 = GOUtil.FindChildComponent(g, "Panel/Model/Pic/Pic1", "Image")
	self.pic2 = GOUtil.FindChildComponent(g, "Panel/Model/Pic/Pic2", "RectTransform")
	self.gCellItem = GOUtil.FindChildGameObject(g, "Panel/go_extra/Cell/CellItem")
	self.btn_extra = GOUtil.FindChildGameObject(g, "Panel/go_extra/Cell/btn_extra")
	self.img_extra = GOUtil.FindChildComponent(g, "Panel/go_extra/Cell/img_extra", "Image")
	self.get_recv = GOUtil.FindChildGameObject(g, "Panel/go_extra/Cell/get_recv")
	self.tex_des = GOUtil.FindChildComponent(g, "Panel/Model/Text/Text1", "RectTransform")

	Event.Instance:Add("ShowOperationActive", self.RebuildText, self)
	self:AddClick(self.btn_extra, self.OnClickedExtraAward)

	self.recvGetAwardList = {}
	self.btn_mask = GOUtil.FindChildGameObject(self.UIRootObject, "Panel/btn_mask")

	if not IsNil(self.btn_mask) then
		self:AddClick(self.btn_mask, self.BtnMaskOnClicked)
	end
end

function DlgOperationActiveBirthday:RebuildText()
	LayoutRebuilder.ForceRebuildLayoutImmediate(self.tex_des)

	local width = 650

	if self.tex_des.sizeDelta.x ~= 0 then
		width = self.tex_des.sizeDelta.x
	end

	local y = self.tex_des.localPosition.y
	local x = self.tex_des.localPosition.x + width / 2 + 64

	self.img_pic1:SetNativeSize()

	self.pic2.sizeDelta.x = Vector2(width + 240, self.pic2.sizeDelta.y)

	GOUtil.SetRectTransformAnchoredPosition(self.cell, x, y)
end

function DlgOperationActiveBirthday:BtnMaskOnClicked()
	if self.recvGetAwardList and self.recvGetAwardList[1] then
		if #self.recvGetAwardList == 1 then
			Event.Instance:Fire("ReceiveOperationActiveAward", self.recvGetAwardList[1], nil, nil, self.btn_mask)
		else
			Event.Instance:Fire("ReceiveOperationActiveAwardList", self.recvGetAwardList, self.btn_mask)
		end
	end

	self.BtnMaskEvent = true
end

function DlgOperationActiveBirthday:DealWithLocalization(ActiveID)
	local uiInfo = InfoOperationActive:GetOperationUIInfo(ActiveID)

	if uiInfo then
		for i = 1, #uiInfo.Bg do
			local Rmg = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Bg/Bg" .. i, "Image")

			if IsNil(Rmg) then
				Rmg = self.BGRaw
			end

			if uiInfo and uiInfo.Bg and uiInfo.Bg[i] and uiInfo.Bg[i][1] and Rmg then
				UIUtil.SetImageSprite(Rmg, uiInfo.Bg[i][1], self, true)
			end
		end

		for i = 1, #uiInfo.Pic do
			local Img = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Pic/Pic" .. i, "Image")

			if uiInfo and uiInfo.Pic and uiInfo.Pic[i] and uiInfo.Pic[i][1] and Img then
				UIUtil.SetImageSprite(Img, uiInfo.Pic[i][1], self, true)
			end

			if uiInfo.Pic[i][3] and uiInfo.Pic[i][4] then
				GOUtil.SetRectTransformAnchoredPosition(Img.gameObject, uiInfo.Pic[i][3], uiInfo.Pic[i][4])
			end
		end

		for i = 1, #uiInfo.SpineStatic do
			local Spine = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Spine/Spine" .. i, "Image")

			if uiInfo and uiInfo.SpineStatic and uiInfo.SpineStatic[i] and uiInfo.SpineStatic[i][1] and Spine then
				UIUtil.SetImageSprite(Spine, uiInfo.SpineStatic[i][1], self, true)
			end

			if uiInfo.SpineStatic[i][3] and uiInfo.SpineStatic[i][4] then
				GOUtil.SetRectTransformAnchoredPosition(Spine.gameObject, uiInfo.SpineStatic[i][3], uiInfo.SpineStatic[i][4])
			end
		end

		for i = 1, #uiInfo.Text do
			if uiInfo and uiInfo.Text and uiInfo.Text[i] and uiInfo.Text[i][1] then
				local Text = GOUtil.FindChildComponent(self.UIRootObject, "Panel/Model/Text/Text" .. i, "Text")

				if IsNil(Text) then
					return
				end

				Text.text = Lang(uiInfo.Text[i][1])

				Text.gameObject.transform:SetSiblingIndex(uiInfo.Text[i][2])

				if uiInfo.Text[i][3] and uiInfo.Text[i][4] then
					GOUtil.SetRectTransformAnchoredPosition(Text.gameObject, uiInfo.Text[i][3], uiInfo.Text[i][4])
				end
			end
		end
	end

	LayoutRebuilder.ForceRebuildLayoutImmediate(self.tex_des)

	local width = 650

	if self.tex_des.sizeDelta.x ~= 0 then
		width = self.tex_des.sizeDelta.x
	end

	local y = self.tex_des.localPosition.y
	local x = self.tex_des.localPosition.x + width / 2 + 64

	self.img_pic1:SetNativeSize()

	self.pic2.sizeDelta.x = Vector2(width + 240, self.pic2.sizeDelta.y)

	GOUtil.SetRectTransformAnchoredPosition(self.cell, x, y)
end

function DlgOperationActiveBirthday:OnClickedExtraAward()
	local infoOperationActive = OperationActiveMgr:Get(self.curindex)
	local canRecv = OperationActiveMgr:GetBirthdayDay(self.infoActive) >= infoOperationActive.data.DailyTime[1][1]
	local isRecv = infoOperationActive:IsGetIndexAward(#self.listBirthdayAward.award + 1)

	if not isRecv and not canRecv then
		UIMgr.ShowMsg(_("Desc_Waiting"))

		return
	end

	Event.Instance:Fire("ReceiveOperationActiveAward", #self.listBirthdayAward.award + 1)
end

function DlgOperationActiveBirthday:Init(infoActive, BGRaw, ParentUIRootObject)
	self.BGRaw = BGRaw
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder

	self:DealWithLocalization(self.ActiveID)

	self.infoActive = infoActive
	self.curindex = infoActive.id
	self.ParentUIRootObject = ParentUIRootObject
	self.listBirthdayAward = OperationActiveMgr:GetActiveRewardItems(infoActive.id)

	local count = #self.listBirthdayAward.award

	local function addCallback(item)
		self:AddClick(item.UIRootObject, nil)
	end

	local function updateCallback(item, index)
		local data = self.listBirthdayAward.award[index]

		item:UpdateData(data, infoActive)
	end

	self.UIScrollTool = UIScrollTool()
	self.isShow = false

	self.UIScrollTool:InitList(self.scrollArea, self.content, count, self.PrefabCell, CellModelType2, self, true, addCallback, updateCallback)

	local canRecv = infoActive:IsGetIndexAward(#self.listBirthdayAward.award + 1)

	SetActiveFunc(self.btn_extra, self.listBirthdayAward.extraAward[1].extraIndex == OperationActiveMgr:GetBirthdayDay(self.infoActive) and not canRecv)
	SetActiveFunc(self.get_recv, canRecv)

	local gray = TenaryOp(not canRecv, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.img_extra, gray))

	local award = self.listBirthdayAward.extraAward[1].extraAward[1]

	if award then
		local infoItem = ItemManager:GetValueItem(award[1], award[2])

		self.cell1 = CellItem(self.gCellItem)

		self.cell1:InitItemByRoot(self.gCellItem)

		if award[2] == 0 then
			self.cell1:UpdateNoNumType(infoItem)
		else
			self.cell1:UpdateWithNumType(infoItem)
		end

		self.cell1:SetGray(canRecv)
	end

	self:GetAwardList()
end

function DlgOperationActiveBirthday:GetAwardList()
	if self.listBirthdayAward.award then
		for i = 1, #self.listBirthdayAward.award do
			local Day = OperationActiveMgr:GetBirthdayDay(self.infoActive)
			local data = self.listBirthdayAward.award[i]
			local isGeted = self.infoActive:IsGetIndexAward(data.index)
			local canRecv = Day == data.index
			local isTimeOut = Day > data.index
			local isRecv = self.infoActive:IsGetIndexAward(data.index)

			if canRecv and not isRecv then
				table.insert(self.recvGetAwardList, data.index)
			end
		end
	end

	local canRecv = self.infoActive:IsGetIndexAward(#self.listBirthdayAward.award + 1)

	if self.listBirthdayAward.extraAward[1].extraIndex == OperationActiveMgr:GetBirthdayDay(self.infoActive) and not canRecv then
		table.insert(self.recvGetAwardList, #self.listBirthdayAward.award + 1)
	end
end

function DlgOperationActiveBirthday:OnUpdate()
	if not IsNil(self.ParentUIRootObject) and self.ParentUIRootObject.activeSelf and #self.recvGetAwardList ~= 0 and not self.BtnMaskEvent and OperationActiveMgr.PageOperationActiveType == 2 then
		OperationActiveMgr.isAuto = true

		self:BtnMaskOnClicked()
	end
end

function DlgOperationActiveBirthday:UpdateData(infoActive)
	self.ActiveID = infoActive.data.UIType .. "_" .. infoActive.data.PageOrder

	self:DealWithLocalization(self.ActiveID)

	self.infoActive = infoActive
	self.listBirthdayAward = OperationActiveMgr:GetActiveRewardItems(infoActive.id)
	self.curindex = infoActive.id

	self.UIScrollTool:UpdateListDataKeepPos(self.listBirthdayAward.award)

	local canRecv = infoActive:IsGetIndexAward(#self.listBirthdayAward.award + 1)

	SetActiveFunc(self.btn_extra, self.listBirthdayAward.extraAward[1].extraIndex == OperationActiveMgr:GetBirthdayDay(self.infoActive) and not canRecv)
	SetActiveFunc(self.get_recv, canRecv)

	local gray = TenaryOp(not canRecv, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.img_extra, gray))

	local award = self.listBirthdayAward.extraAward[1].extraAward[1]

	if award then
		local infoItem = ItemManager:GetValueItem(award[1], award[2])

		if not self.cell1 then
			self.cell1 = CellItem(self.gCellItem)

			self.cell1:InitItemByRoot(self.gCellItem)
		end

		if award[2] == 0 then
			self.cell1:UpdateNoNumType(infoItem)
		else
			self.cell1:UpdateWithNumType(infoItem)
		end

		self.cell1:SetGray(canRecv)
	end

	self:GetAwardList()
end
