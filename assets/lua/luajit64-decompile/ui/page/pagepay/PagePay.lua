-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePay/PagePay.lua

require("UI/Page/PagePay/GiftCell")
require("UI/Page/PagePay/DiamondCell")
require("UI/Page/PagePay/PagePayRule")
require("luaData/m_billing_age_limit")

PagePay = class("PagePay", UIPanel)

function PagePay:ctor()
	PagePay.base.ctor(self, "UI/PanelPay/PanelPay")
	self:AddChildPanel(DlgExit(), {
		title = _("PageShop_name"),
		callback = self.OnBack,
		panel = self
	})
end

function PagePay:PreLoad()
	self.CellSet = ResourceMgr.LoadSync("UI/PanelPay/PayCellSet")
	self.CellSingle = ResourceMgr.LoadSync("UI/PanelPay/PayCellItem")
end

function PagePay:Cache()
	PagePay.base.Cache(self)
end

function PagePay:Purge()
	PagePay.base.Purge(self)

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

	self:OnLeave()
end

function PagePay:OnPageLoaded()
	return
end

function PagePay:AddCellClick(item)
	if self.curTabIndex == 2 then
		-- block empty
	end
end

function PagePay:OnEnter(vParam)
	self.btnRule = self:GetChildGameObject("tips")
	self.Panel1 = self:GetChildGameObject("Panel/Panel1")
	self.Panel2 = self:GetChildGameObject("Panel/Panel2")
	self:GetChildComponent("Panel/BtnGroup/Btn1/Text", "Text").text = _("PageShop_set_name")
	self:GetChildComponent("Panel/BtnGroup/Btn2/Text", "Text").text = _("PageShop_coin_name")
	self:GetChildComponent("Panel/BtnGroup/Select1/Text", "Text").text = _("PageShop_set_name")
	self:GetChildComponent("Panel/BtnGroup/Select2/Text", "Text").text = _("PageShop_coin_name")
	self:GetChildComponent("tips/Text", "Text").text = _("PageShop_description_3")

	for i = 1, 2 do
		self["Btn" .. i] = self:GetChildGameObject("Panel/BtnGroup/Btn" .. i)
		self["Select" .. i] = self:GetChildGameObject("Panel/BtnGroup/Select" .. i)
		self["Btn" .. i].name = i
	end

	local info = CautionMgr:GetCautionPopInfo(protocol_pb.shop)

	if info then
		local isCallReadApi = info.cautionType == protocol_pb.cautionBilling or info.cautionType == protocol_pb.cautionRestrictionBilling and not info.lookAt

		CautionBuilder.OpenCautionPopupOpt(info, function()
			self:UpdateGroupTab(vParam and vParam.type or 1)
		end, isCallReadApi)
	else
		self:UpdateGroupTab(vParam and vParam.type or 1)
	end
end

function PagePay:UpdateItem(dic)
	for i = 1, #dic do
		local gobj = self["ShopItem" .. i]
		local shopname = GOUtil.FindChildComponent(gobj, "shop_name", "Text")
		local shopPrice = GOUtil.FindChildComponent(gobj, "shop_price", "Text")

		shopname.text = dic[i].key
		shopPrice.text = dic[i].value
	end
end

function PagePay:OnLeave()
	for i = 1, 4 do
		self["Btn" .. i] = nil
		self["Select" .. i] = nil
	end
end

function PagePay:OnRegisterEvent()
	for i = 1, 2 do
		self:AddClick(self["Btn" .. i], self.OnClickedBtn)
	end

	self:AddClick(self.btnRule, self.OnClickRule, PATH_SFX_UI_Click)
	Event.Instance:Add(BillingManager.OnPaySuceed, self.OnPurchased, self)
end

function PagePay:OnUnRegisterEvent()
	for i = 1, 2 do
		self:RemoveClick(self["Btn" .. i], self.OnClickedBtn)
	end

	self:RemoveClick(self.btnRule, self.OnClickRule)
	Event.Instance:Remove(BillingManager.OnPaySuceed, self.OnPurchased, self)
end

function PagePay:OnPurchased(item)
	if item.type == protocol_pb.pack and self.UIScrollTool then
		local function wrap_cb(res)
			local productIds = {}
			local isDel = true

			for k, v in pairs(res.productList) do
				if item.id == v.shopProductMasterId then
					isDel = false

					break
				end
			end

			if isDel then
				for k, v in pairs(self.dataFirst) do
					if item.id == v.product.shopProductMasterId then
						table.removeByValue(self.dataFirst, v)

						break
					end
				end

				self.UIScrollTool:UpdateListDataKeepPos(self.dataFirst)
			end
		end

		NetManager:RequestShopPack(wrap_cb)
	else
		NetManager:RequestShopSnsCoin(function(res)
			return
		end)
	end
end

function PagePay:OnClickRule()
	UIMgr.AddPanel(PagePayRule(), {
		curIndex = 4,
		mode = 2
	})
end

function PagePay:UpdateGroupTab(index)
	self.curTabIndex = index

	for i = 1, 2 do
		if i == index then
			self["Btn" .. index]:SetActive(false)
			self["Select" .. index]:SetActive(true)
		else
			self["Btn" .. i]:SetActive(true)
			self["Select" .. i]:SetActive(false)
		end
	end

	if index == 1 then
		self.Panel2:SetActive(false)
		self.Panel1:SetActive(true)
		self:OnFirstIndex()
	elseif index == 2 then
		self.Panel1:SetActive(false)
		self.Panel2:SetActive(true)
		self:OnSecondIndex()
	end
end

function PagePay:OnFirstIndex()
	if not self.isInitFirst then
		local function wrap_cb(res)
			local productIds = {}

			for k, v in pairs(res.productList) do
				table.insert(productIds, v.platformProductId)
			end

			BillingManager.GetProductList(productIds, function(dic)
				print("suceed")
				LoadingMgr.Hide(eLoadingType.Repeat)

				local itemDic = {}
				local iter = dic:GetEnumerator()

				while iter:MoveNext() do
					print(iter.Current.Key)
					print(iter.Current.Value)

					local tmp_t = {}

					tmp_t.key = iter.Current.Key
					tmp_t.value = iter.Current.Value
					itemDic[tmp_t.key] = {}

					local priceList = string.split(tmp_t.value, "|")

					itemDic[tmp_t.key].Price = priceList[1]
					itemDic[tmp_t.key].FormattedPrice = priceList[2]
				end

				self.dataFirst = {}

				for i = 1, #res.productList do
					local item = {}
					local v = res.productList[i]

					item.product = v
					item.Price = itemDic[v.platformProductId].Price
					item.FormattedPrice = itemDic[v.platformProductId].FormattedPrice

					table.insert(self.dataFirst, item)
				end

				local scrollArea = self:GetChildGameObject("Panel/Panel1/ScrollArea")
				local content = self:GetChildComponent("Panel/Panel1/ScrollArea/Content", "Transform")

				self.UIScrollTool = UIScrollTool()

				self.UIScrollTool:InitList(scrollArea, content, #self.dataFirst, self.CellSet, GiftCell, self, false)

				self.UIScrollTool.ScrollView.verticalScrollbar = self:GetChildComponent("Panel/Panel1/Scrollbar", "Scrollbar")
				self.isInitFirst = true
			end, function(err)
				print("failed")
				LoadingMgr.Hide(eLoadingType.Repeat)
				print(err.Message)
				print(err:ToString())
				self:ShowProductError()
			end)
		end

		NetManager:RequestShopPack(wrap_cb)
	end
end

function PagePay:UpdateCell(item, index)
	local data

	if self.curTabIndex == 1 then
		data = self.dataFirst[index]
	elseif self.curTabIndex == 2 then
		data = self.dataSec[index]
	end

	item:UpdateData(data)
end

function PagePay:OnSecondIndex()
	if not self.isInitSec then
		local function wrap_cb(res)
			local productIds = {}

			for k, v in pairs(res.productList) do
				table.insert(productIds, v.platformProductId)
			end

			BillingManager.GetProductList(productIds, function(dic)
				print("suceed")
				LoadingMgr.Hide(eLoadingType.Repeat)

				local itemDic = {}
				local iter = dic:GetEnumerator()

				while iter:MoveNext() do
					print(iter.Current.Key)
					print(iter.Current.Value)

					local tmp_t = {}

					tmp_t.key = iter.Current.Key
					tmp_t.value = iter.Current.Value
					itemDic[tmp_t.key] = {}

					local priceList = string.split(tmp_t.value, "|")

					itemDic[tmp_t.key].Price = priceList[1]
					itemDic[tmp_t.key].FormattedPrice = priceList[2]
				end

				self.dataSec = {}

				for i = 1, #res.productList do
					local item = {}
					local v = res.productList[i]

					item.product = v
					item.Price = itemDic[v.platformProductId].Price
					item.FormattedPrice = itemDic[v.platformProductId].FormattedPrice

					table.insert(self.dataSec, item)
				end

				local scrollArea = self:GetChildGameObject("Panel/Panel2/ScrollArea")
				local content = self:GetChildComponent("Panel/Panel2/ScrollArea/Content", "Transform")

				self.UIScrollToolSec = UIScrollTool()

				self.UIScrollToolSec:InitList(scrollArea, content, #self.dataSec, self.CellSingle, DiamondCell, self, false)

				self.UIScrollToolSec.ScrollView.verticalScrollbar = self:GetChildComponent("Panel/Panel2/Scrollbar", "Scrollbar")
				self.isInitSec = true
			end, function(err)
				print("failed")
				LoadingMgr.Hide(eLoadingType.Repeat)
				print(err.Message)
				print(err:ToString())
				self:ShowProductError()
			end)
		end

		NetManager:RequestShopSnsCoin(wrap_cb)
	end
end

function PagePay:ShowProductError()
	UIMgr.ShowCommon(DlgCommonEvent.Type.Large, _("PageShop_error_titel"), _("PageShop_error_description"), function(index)
		return
	end, "OK")
end

function PagePay:OnBack()
	UIMgr.PopPanel()
end

function PagePay:OnClickedBtn(data)
	local go = data.pointerPress
	local index = tonumber(go.name)

	self:UpdateGroupTab(index)
end
