-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePay/PageHistory.lua

require("UI/Page/PagePay/HistoryCell")
require("UI/Page/PagePay/PageHistoryPop")

PageHistory = class("PageHistory", UIPanel)

function PageHistory:ctor()
	PageHistory.base.ctor(self, "UI/PanelPay/PanelHistory")
end

function PageHistory:PreLoad()
	self.HistoryList1 = ResourceMgr.LoadSync("UI/PanelPay/HistoryList1")
	self.HistoryList2 = ResourceMgr.LoadSync("UI/PanelPay/HistoryList2")
	self.pageMain = 1
	self.pageSecond = 1
	self.pageThird = 1
end

function PageHistory:Purge()
	PageHistory.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool.ScrollView.onBottomReached = nil

		self.UIScrollTool:Purge()
	end

	self.UIScrollTool = nil

	if self.UIScrollToolSec then
		self.UIScrollToolSec.ScrollView.onBottomReached = nil

		self.UIScrollToolSec:Purge()
	end

	self.UIScrollToolSec = nil

	if self.UIScrollToolTrd then
		self.UIScrollToolTrd.ScrollView.onBottomReached = nil

		self.UIScrollToolTrd:Purge()
	end

	self.UIScrollToolTrd = nil

	self:OnLeave()
end

function PageHistory:OnLeave()
	self.BtnAsc = nil
	self.BtnDesc = nil
	self.BtnClose = nil
	self.BtnFilter = nil
	self.TxtFilter = nil
	self.BtnRece = nil
	self.listMail = nil
	self.listState = nil
end

function PageHistory:OnBack()
	UIMgr.PopPanel()
end

function PageHistory:OnRegisterEvent()
	for i = 1, 3 do
		self:AddClick(self["Btn" .. i], self.OnClickedBtn)
	end

	print(self.closeBtn)
	self:AddClick(self.closeBtn, self.OnClose)
end

function PageHistory:OnUnRegisterEvent()
	for i = 1, 3 do
		self:RemoveClick(self["Btn" .. i], self.OnClickedBtn)
	end

	self:RemoveClick(self.closeBtn, self.OnClose)
end

function PageHistory:OnClickTip()
	UIMgr.AddPanel(PageHistoryPop())
end

function PageHistory:OnClose()
	print(234)
	self:Close()
end

function PageHistory:OnClickedBtn(data)
	local go = data.pointerPress
	local index = tonumber(go.name)

	if self.curTabIndex == nil or index == self.curTabIndex then
		return
	end

	self:UpdateGroupTab(index)
end

function PageHistory:UpdateGroupTab(index)
	self.curTabIndex = index

	for i = 1, 3 do
		if i == index then
			self["Btn" .. index]:SetActive(false)
			self["Select" .. index]:SetActive(true)
		else
			self["Btn" .. i]:SetActive(true)
			self["Select" .. i]:SetActive(false)
		end
	end

	if index == 1 then
		self:OnSelfIndex()
	elseif index == 2 then
		self:OnSecondIndex()
	elseif index == 3 then
		self:OnThirdIndex()
	end
end

function PageHistory:OnSelfIndex()
	self.Panel2:SetActive(false)
	self.Panel3:SetActive(false)
	self.Panel1:SetActive(true)

	self:GetChildComponent("Panel/Panel1/Left/title/Text", "Text").text = _("PageHistory_remaining_money")
	self:GetChildComponent("Panel/Panel1/Right/title/Text", "Text").text = _("PageHistory_purchase_history_full")
	self:GetChildComponent("Panel/Panel1/Right/BgSub/Text", "Text").text = _("PageHistory_commodity_name")
	self:GetChildComponent("Panel/Panel1/Right/BgSub/Text2", "Text").text = _("PageHistory_last_money")

	print(_("PageHistory_time"))
	print(NetData:GetCurServerTime())

	self.NowTime.text = string.format(_("PageHistory_time"), DateUtil.GetDateFormatBySingle(NetData:GetCurServerTime() / DateUtil.MillsPerSecond))
	self.FreeDiamond.text = string.format(_("PageHistory_billing_format"), PlayerInst.InfoPlayer:GetDiamond())
	self.PayedDiamond.text = string.format(_("PageHistory_billing_format"), PlayerInst.InfoPlayer:GetDiamondPay())
	self.TotalDiamond.text = string.format(_("PageHistory_billing_format"), PlayerInst.InfoPlayer:GetDiamondAll())

	self:InitCellFirst()
end

function PageHistory:OnSecondIndex()
	self.Panel1:SetActive(false)
	self.Panel3:SetActive(false)
	self.Panel2:SetActive(true)
	self:InitCellSec()
end

function PageHistory:OnThirdIndex()
	self.Panel1:SetActive(false)
	self.Panel2:SetActive(false)
	self.Panel3:SetActive(true)
	self:InitCellThird()
end

function PageHistory:InitCellFirst()
	if not self.isInitFirst then
		local function res_cb(res)
			LoadingMgr.Hide(eLoadingType.Repeat)

			local scrollArea = self:GetChildGameObject("Panel/Panel1/Right/ScrollArea")
			local content = self:GetChildComponent("Panel/Panel1/Right/ScrollArea/Content", "Transform")

			self.dataFirst = BaseDataUtil.SortHistoryBalanceList(res.balanceHistories)
			self.UIScrollTool = UIScrollTool()

			self.UIScrollTool:InitList(scrollArea, content, #self.dataFirst, self.HistoryList1, HistoryCell, self, false)

			self.UIScrollTool.ScrollView.verticalScrollbar = self:GetChildComponent("Panel/Panel1/Right/Scrollbar", "Scrollbar")

			local function wrap_cb(...)
				self:OnGetBottom(...)
			end

			self.UIScrollTool.ScrollView.onBottomReached = wrap_cb
			self.isInitFirst = true

			self.Panel1_no_txt.gameObject:SetActive(#self.dataFirst <= 0)
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestBuyHistory(protocol_pb.billing_balance_grouped, 1, res_cb)
	end
end

function PageHistory:OnGetBottom()
	local function res_cb(res)
		LoadingMgr.Hide(eLoadingType.Repeat)

		local data, scrollTool, records

		if self.curTabIndex == 1 then
			data = self.dataFirst
			scrollTool = self.UIScrollTool
			records = res.balanceHistories

			if #records > 0 then
				self.pageMain = self.pageMain + 1
			end
		elseif self.curTabIndex == 2 then
			data = self.dataSec
			scrollTool = self.UIScrollToolSec
			records = res.depositHistories

			if #records > 0 then
				self.pageSecond = self.pageSecond + 1
			end
		elseif self.curTabIndex == 3 then
			data = self.dataTrd
			scrollTool = self.UIScrollToolTrd
			records = res.consumeHistories

			if #records > 0 then
				self.pageThird = self.pageThird + 1
			end
		end

		for i = 1, #records do
			table.insert(data, records[i])
		end

		scrollTool:UpdateListDataKeepPos(data)
	end

	local page = 1
	local updateType = 0

	if self.curTabIndex == 1 then
		page = self.pageMain + 1
		updateType = protocol_pb.billing_balance
	elseif self.curTabIndex == 2 then
		page = self.pageSecond + 1
		updateType = protocol_pb.billing_deposit
	elseif self.curTabIndex == 3 then
		page = self.pageThird + 1
		updateType = protocol_pb.billing_consume
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestBuyHistory(updateType, page, res_cb)
end

function PageHistory:InitCellSec()
	if not self.isInitSec then
		local function res_cb(res)
			LoadingMgr.Hide(eLoadingType.Repeat)

			local scrollArea = self:GetChildGameObject("Panel/Panel2/ScrollArea")
			local content = self:GetChildComponent("Panel/Panel2/ScrollArea/Content", "Transform")

			self.dataSec = res.depositHistories
			self.UIScrollToolSec = UIScrollTool()

			self.UIScrollToolSec:InitList(scrollArea, content, #res.depositHistories, self.HistoryList2, HistoryCell, self, false)

			self.UIScrollToolSec.ScrollView.verticalScrollbar = self:GetChildComponent("Panel/Panel2/Scrollbar", "Scrollbar")

			local function wrap_cb(...)
				self:OnGetBottom(...)
			end

			self.UIScrollToolSec.ScrollView.onBottomReached = wrap_cb
			self.isInitSec = true

			self.Panel2_no_txt.gameObject:SetActive(#res.depositHistories <= 0)
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestBuyHistory(protocol_pb.billing_deposit, 1, res_cb)
	end
end

function PageHistory:InitCellThird()
	if not self.isInitTrd then
		local function res_cb(res)
			LoadingMgr.Hide(eLoadingType.Repeat)

			local scrollArea = self:GetChildGameObject("Panel/Panel3/ScrollArea")
			local content = self:GetChildComponent("Panel/Panel3/ScrollArea/Content", "Transform")

			self.dataTrd = res.consumeHistories
			self.UIScrollToolTrd = UIScrollTool()

			self.UIScrollToolTrd:InitList(scrollArea, content, #res.consumeHistories, self.HistoryList2, HistoryCell, self, false)

			self.UIScrollToolTrd.ScrollView.verticalScrollbar = self:GetChildComponent("Panel/Panel3/Scrollbar", "Scrollbar")

			local function wrap_cb(...)
				self:OnGetBottom(...)
			end

			self.UIScrollToolTrd.ScrollView.onBottomReached = wrap_cb
			self.isInitTrd = true

			self.Panel3_no_txt.gameObject:SetActive(#res.consumeHistories <= 0)
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestBuyHistory(protocol_pb.billing_consume, 1, res_cb)
	end
end

function PageHistory:AddCellClick(item)
	return
end

function PageHistory:UpdateCell(item, index)
	local data

	if self.curTabIndex == 1 then
		data = self.dataFirst[index]
	elseif self.curTabIndex == 2 then
		data = self.dataSec[index]
	elseif self.curTabIndex == 3 then
		data = self.dataTrd[index]
	end

	print(index)
	print(data)
	item:UpdateData(data, index, self.curTabIndex)
end

function PageHistory:OnEnter(vParam)
	self:GetChildComponent("Panel/title/text", "Text").text = _("PageHistory_titel_content")
	self:GetChildComponent("Panel/Panel1/Left/wc/Tag/Text", "Text").text = _("PageHistory_free_money")
	self:GetChildComponent("Panel/Panel1/Left/yc/Tag/Text", "Text").text = _("PageHistory_pay_money")
	self:GetChildComponent("Panel/Panel1/Left/hj/Tag/Text", "Text").text = _("PageHistory_total_money_last")
	self.NowTime = self:GetChildComponent("Panel/Panel1/Right/title/Time", "Text")
	self.PayedDiamond = self:GetChildComponent("Panel/Panel1/Left/yc/TextVal", "Text")
	self.FreeDiamond = self:GetChildComponent("Panel/Panel1/Left/wc/TextVal", "Text")
	self.TotalDiamond = self:GetChildComponent("Panel/Panel1/Left/hj/TextVal", "Text")
	self:GetChildComponent("Panel/BtnGroup/Btn1/Text", "Text").text = _("PageHistory_remaining_money")
	self:GetChildComponent("Panel/BtnGroup/Btn2/Text", "Text").text = _("PageHistory_purchase_history")
	self:GetChildComponent("Panel/BtnGroup/Btn3/Text", "Text").text = _("PageHistory_expenses_history")
	self:GetChildComponent("Panel/BtnGroup/Select1/Text", "Text").text = _("PageHistory_remaining_money")
	self:GetChildComponent("Panel/BtnGroup/Select2/Text", "Text").text = _("PageHistory_purchase_history")
	self:GetChildComponent("Panel/BtnGroup/Select3/Text", "Text").text = _("PageHistory_expenses_history")
	self.Panel1_no_txt = self:GetChildComponent("Panel/Panel1/Right/Bg/no_record", "Text")
	self.Panel2_no_txt = self:GetChildComponent("Panel/Panel2/Bg/no_record", "Text")
	self.Panel3_no_txt = self:GetChildComponent("Panel/Panel3/Bg/no_record", "Text")
	self.Panel1_no_txt.text = _("PageHistory_no_purchase_history")
	self.Panel2_no_txt.text = _("PageHistory_no_purchase_history")
	self.Panel3_no_txt.text = _("PageHistory_no_purchase_history")

	for i = 1, 3 do
		self["Btn" .. i] = self:GetChildGameObject("Panel/BtnGroup/Btn" .. i)
		self["Select" .. i] = self:GetChildGameObject("Panel/BtnGroup/Select" .. i)
		self["Btn" .. i].name = i
	end

	self.closeBtn = self:GetChildGameObject("Panel/close")
	self.Panel1 = self:GetChildGameObject("Panel/Panel1")
	self.Panel2 = self:GetChildGameObject("Panel/Panel2")
	self.Panel3 = self:GetChildGameObject("Panel/Panel3")
	self.tip_txt = self:GetChildComponent("Panel/Panel1/Left/tip_txt", "Text")
	self.tip_txt.text = _("PageHistory_remaining_explain")

	self:UpdateGroupTab(1)
end

function PageHistory:OnBackAndroid()
	self:Close()
end
