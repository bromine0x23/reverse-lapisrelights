-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageShop/PageShop.lua

local ShopData = require("luaData/ShopData")

require("Info/InfoShop")
require("UI/Page/PageShop/CellGood")
require("UI/Page/PageShop/CellChargeGood")
require("UI/Page/PageShop/CellChargeDiamond")
require("UI/Page/PageShop/DlgShopProductDetail")
require("UI/Page/PageShop/DlgShopProductDetailJP")
require("UI/Page/PageShop/DlgChangeStar")
require("UI/Page/PageShop/DlgShopChargeProductDetail")
require("UI/Page/PageShop/JPShopManager")

local listLimitedProducts = require("luaData/m_billing_limited_product")
local billingProductAssetInfo = require("luaData/m_billing_product_asset")
local billingContentInfo = require("luaData/m_billing_product_content")
local itemData = require("luaData/ItemData")
local isPGuidePopped = false

PageShop = class("PageShop", UIPanel)

local firstRechargeId = 19

function PageShop:Instance()
	return GameObject.Find("PageShop(Clone)")
end

function PageShop:ctor()
	self.UIPrefabPath = "UI/PageShop/PageShop"
	self.DlgExit = DlgExit()

	self:AddChildPanel(self.DlgExit, {
		title = _("Shop_Title"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo(), {
		type = 1,
		x = -700,
		y = -42
	})

	self.ChargeFunction = {
		[protocol_pb.normal] = {
			ScrollArea = "SafeArea/Main/ScrollAreaJP1",
			CellPrefab = ResourceMgr.LoadSync("UI/PageShop/CellProductJP1"),
			CellLua = CellChargeDiamond,
			ProductType = protocol_pb.normal
		},
		[protocol_pb.pack] = {
			ScrollArea = "SafeArea/Main/ScrollAreaJP1",
			CellPrefab = ResourceMgr.LoadSync("UI/PageShop/CellProductJP1"),
			CellLua = CellChargeDiamond,
			ProductType = protocol_pb.pack
		}
	}
	self.jpShopManager = JPShopManager(self)
end

function PageShop:OnBack()
	local function wrap_cb(vMsg)
		if vMsg.result.code == NetManager.Result_Sucess and vMsg.activeOperates and vMsg.activeOperates[1] then
			local infoOperationActive = OperationActiveMgr:Get(firstRechargeId)

			infoOperationActive:SetData(vMsg.activeOperates[1])
		end
	end

	NetManager:RequestActiveOperates({
		firstRechargeId
	}, wrap_cb)
	Event.Instance:Fire("ShowEffect")
	Event.Instance:Fire(EventEnum.UpdateItemDataNotify)
	Event.Instance:Fire("UpdateCardPool")
	Event.Instance:Fire("UpdateMonthCard")
	Event.Instance:Fire("UpdateStageNum")
	Event.Instance:Fire("UpdateFirstCharge")
	Event.Instance:Fire("UpdateBag")
	Event.Instance:Fire("DealWithUIAnim", false)
	Event.Instance:Fire("DealWithPreviewActorRandomIdle", false)
	BillingManager.Resume()
	self:Close()
end

function PageShop:Purge()
	PageShop.base.Purge(self)

	if self.timer ~= nil then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end

	if self.content then
		UITweenUtil.RemoveTween(self.tagGroup.transform)
		UITweenUtil.RemoveTween(self.content)
	end

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	if self.UIScrollToolMonth then
		self.UIScrollToolMonth:Purge()
	end

	if self.UIScrollToolList then
		self.UIScrollToolList:Purge()
	end

	for k, v in pairs(self.ChargeFunction) do
		if v.UIScrollTool then
			v.UIScrollTool:Purge()
		end
	end

	ResourceMgr.Unload(self.PrefabCell)
	ResourceMgr.Unload(self.PrefabCellMonth)
	ResourceMgr.Unload(self.PrefabCellList)
	ResourceMgr.Unload(self.PrefabCellItem)
	UnloadAllImageSprite(self)

	if self.BtnGroupRes then
		for _, v in pairs(self.BtnGroupRes) do
			self:RemoveClick(v, self.OnClickedBtnGroupRes)
		end
	end

	Event.Instance:Fire("OpenShopPanel", false)
	Event.Instance:Fire("OnAddRandomIdle")
end

function PageShop:PreLoad()
	self:LoadResAsync("UI/PageShop/CellProduct", "PrefabCell")
	self:LoadResAsync("UI/PageShop/CellProductMonth", "PrefabCellMonth")
	self:LoadResAsync("UI/PageShop/CellProductList", "PrefabCellList")
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
end

function PageShop:NotifyPanelLoaded(panelName)
	local panelList = {
		"PageFittingroom",
		"PageInteraction",
		"PageAddressBookNew",
		"PageBondage",
		"PageManualMain",
		"PageWork",
		"PageFriendMain",
		"PageBag",
		"PageTheme",
		"PageMainStage",
		"PageUnion",
		"PageUnionJoin",
		"PageRole",
		"PageRoleCardList",
		"PageCardShop",
		"PageChapter",
		"PageActivityBossRaid",
		"PageUnionTask",
		"PageUnionRaid",
		"PageOperationActiveNew",
		"PagePVPMain",
		"PageTimeSpace"
	}

	for index, value in ipairs(panelList) do
		if value == panelName then
			self:OnBack()

			return
		end
	end
end

function PageShop.InitNetData(data, notOpen)
	NetManager:ReadCaution(-1, function(pb)
		if pb.cautions ~= nil then
			PlayerInst.InfoPlayer.cautions = pb.cautions
		end

		local function callback(vPBMessage)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vPBMessage.result.code == NetManager.Result_Sucess then
				if not notOpen then
					UIMgr.AddPanel(PageShop(), data)
				end
			else
				UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
			end
		end

		NetManager:RequestGetPurchaseList(callback)
	end)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageShop:UpdateNetData()
	local function callback(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			self:OnEnter(data)
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetManager:RequestGetPurchaseList(callback)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageShop:OnEnter(vParam)
	Event.Instance:Fire("OnRemoveRandomIdle")
	Event.Instance:Fire("OpenShopPanel", true)
	Event.Instance:Fire("DealWithPreviewActorRandomIdle", true)
	Event.Instance:Fire("UpdateSceneDisplay", false)
	Event.Instance:Fire("DealWithUIAnim", true)
	UIMgr.SetUpdatePanel(self)

	self.vParam = vParam

	Event.Instance:Fire("ShowEffect", false)
	BillingManager.Resume()

	self.tagGroup = self:GetChildGameObject("SafeArea/TabGroup")
	self.GoTime = self:GetChildGameObject("SafeArea/Main/GoTime")
	self.TextRefreshTime = self:GetChildComponent("SafeArea/Main/GoTime/TextLeft", "Text")
	self.PanelMonth = self:GetChildGameObject("SafeArea/Main/DlgMonth")

	local text = self:GetChildComponent("SafeArea/Main/DlgMonth/TextTip", "Text")

	text.text = Lang(43253)
	self.GrowthFund = self:GetChildGameObject("SafeArea/Main/GrowthFund")
	self.GrowthFundState1 = self:GetChildGameObject("SafeArea/Main/GrowthFund/State1")
	self.GrowthFundState2 = self:GetChildGameObject("SafeArea/Main/GrowthFund/State2")
	self.GrowthFundGo = self:GetChildGameObject("SafeArea/Main/GrowthFund/Go")
	self.GrowthFundBuyButton = self:GetChildGameObject("SafeArea/Main/GrowthFund/State1/ButtonBuy")
	self.GrowthFundAwardButton = self:GetChildGameObject("SafeArea/Main/GrowthFund/State2/GetAwardButton")
	self.TextGrowthFundBuy = self:GetChildComponent("SafeArea/Main/GrowthFund/State1/ButtonBuy/Text", "Text")
	self.TexGrowthFundTitle = self:GetChildComponent("SafeArea/Main/GrowthFund/TexTitle", "Text")
	self.TexGrowthFundDes = self:GetChildComponent("SafeArea/Main/GrowthFund/TexDes", "Text")
	self.BuffTips = self:GetChildGameObject("SafeArea/Main/GrowthFund/BuffTips")
	self.ImgIsGet = self:GetChildGameObject("SafeArea/Main/GrowthFund/ImgIsGet")
	self.CellBuffTips = self:GetChildGameObject("SafeArea/Main/GrowthFund/cellBuff")

	local gitem = self:GetChildGameObject("SafeArea/Main/GrowthFund/State1/Award1/CellItem")

	self.GrowthAward1 = CellItem(gitem)

	self.GrowthAward1:InitItemByRoot(gitem)

	gitem = self:GetChildGameObject("SafeArea/Main/GrowthFund/State1/Award2/CellItem")
	self.GrowthAward2 = CellItem(gitem)

	self.GrowthAward2:InitItemByRoot(gitem)

	gitem = self:GetChildGameObject("SafeArea/Main/GrowthFund/State2/CellItem")
	self.GrowthAward3 = CellItem(gitem)

	self.GrowthAward3:InitItemByRoot(gitem)

	self.PanelMain = self:GetChildGameObject("SafeArea/Main")
	self.GroupRes = self:GetChildGameObject("SafeArea/Main/GroupRes")
	self.ScrollAreaCharge = self:GetChildGameObject("SafeArea/Main/ScrollAreaCharge")
	self.ScrollAreaJP1 = self:GetChildGameObject("SafeArea/Main/ScrollAreaJP1")
	self.ScrollAreaGrid = self:GetChildGameObject("SafeArea/Main/ScrollArea")
	self.ButtonRule = self:GetChildGameObject("SafeArea/Main/Button")
	self.ScrollAreaMain = self:GetChildGameObject("SafeArea/Main/ScrollArea")
	self.ScrollAreaMonth = self:GetChildGameObject("SafeArea/Main/DlgMonth/ScrollAreaMonth")
	self.ScrollAreaList = self:GetChildGameObject("SafeArea/Main/ScrollAreaList")
	self.ButtonMonthBuy = self:GetChildGameObject("SafeArea/Main/DlgMonth/ButtonBuy")
	self.ButtonMonthAward = self:GetChildGameObject("SafeArea/Main/DlgMonth/ButtonAward")
	self.MonthAwardEveryDay = self:GetChildGameObject("SafeArea/Main/DlgMonth/ButtonAward/1")
	self.MonthAwardToday = self:GetChildGameObject("SafeArea/Main/DlgMonth/ButtonAward/2")
	self.MonthAwardTomorrow = self:GetChildGameObject("SafeArea/Main/DlgMonth/ButtonAward/3")
	self.MonthDot = self:GetChildGameObject("SafeArea/Main/DlgMonth/ButtonAward/ImageDot")
	self.TextMonthBuy = self:GetChildComponent("SafeArea/Main/DlgMonth/ButtonBuy/Text", "Text")
	self.TextMonthInfo = self:GetChildComponent("SafeArea/Main/DlgMonth/TextInfo", "Text")
	self.TextMonthTip = self:GetChildComponent("SafeArea/Main/DlgMonth/TextTip", "Text")
	self.TextMonthSign = self:GetChildComponent("SafeArea/Main/DlgMonth/Text", "Text")
	self.GoImageLeft = self:GetChildGameObject("SafeArea/Main/DlgMonth/ImageLeft")
	self.TextMonthLeft = self:GetChildComponent("SafeArea/Main/DlgMonth/ImageLeft/TextLeft", "Text")
	self.GoMonthDisCost = self:GetChildGameObject("SafeArea/Main/DlgMonth/ButtonBuy/ImageDisCost")
	self.GoMonthRate = self:GetChildGameObject("SafeArea/Main/DlgMonth/ImageRate")
	self.ImgMonth = self:GetChildComponent("SafeArea/Main/DlgMonth/ImgMonth", "Image")
	self.ImgDays = self:GetChildGameObject("SafeArea/Main/DlgMonth/ImgDays")
	self.BtnAccumulate = self:GetChildGameObject("SafeArea/AccumulateRecharge")
	self.TextAccumulate = self:GetChildComponent("SafeArea/AccumulateRecharge/Text", "Text")
	self.GoTag = self:GetChildGameObject("SafeArea/Main/ScrollTag/Viewport/Tag")
	self:GetChildComponent("SafeArea/Main/Button/Text", "Text").text = _("PageShop_description_3")
	self.cellBuff = self:GetChildGameObject("SafeArea/Main/DlgMonth/cellBuff")
	self.ScrollAreaBuffTips = self:GetChildGameObject("SafeArea/Main/DlgMonth/ScrollAreaBuffTips")

	UIUtil.ForceRebuildLayoutImmediate(self.ScrollAreaBuffTips)

	local orginScrollAreaRectHeight = GOUtil.GetRectTransformHeight(self.ScrollAreaBuffTips)
	local gridLayout = GOUtil.GetComponent(self.ScrollAreaBuffTips, "GridLayoutGroup")

	self.maxNum = math.floor((orginScrollAreaRectHeight + gridLayout.spacing.y) / (gridLayout.cellSize.y + gridLayout.spacing.y)) * 2
	self.GoArrow = self:GetChildGameObject("SafeArea/Main/DlgMonth/ScrollAreaBuffTips/GoArrow")
	self.TexRate = self:GetChildComponent("SafeArea/Main/DlgMonth/TexRate", "Text")

	local strList = {}

	for _, type in ipairs(ShopManager.listAllIndex) do
		for _, value in pairs(GetConfigArgJson("ShopTypeEnum")) do
			if type == value[2] then
				table.insert(strList, Lang(value[1]))

				break
			end
		end
	end

	self.tabMainCount = #strList

	for i = 1, 6 do
		local go = self:GetChildGameObject("SafeArea/TabGroup/" .. i)

		if i > #strList then
			go:SetActive(false)
		else
			self["TabMain" .. i] = self:GetChildGameObject("SafeArea/TabGroup/" .. i .. "/Button")
			self["TabMainSel" .. i] = self:GetChildGameObject("SafeArea/TabGroup/" .. i .. "/Sel")

			local Text = self:GetChildComponent("SafeArea/TabGroup/" .. i .. "/Button/Text", "Text")

			Text.text = strList[i]
			Text = self:GetChildComponent("SafeArea/TabGroup/" .. i .. "/Sel/Text", "Text")
			Text.text = strList[i]

			RedDotSystemMgr.SetUIRedDot(go, "Shop/" .. i)
		end
	end

	self.tabSubCount = 10

	for i = 1, self.tabSubCount do
		self["GoTag" .. i] = self:GetChildGameObject("SafeArea/Main/ScrollTag/Viewport/Tag/" .. i)
		self["ImgTagBtn" .. i] = self:GetChildComponent("SafeArea/Main/ScrollTag/Viewport/Tag/" .. i .. "/Button", "Image")
		self["ImgTagSel" .. i] = self:GetChildComponent("SafeArea/Main/ScrollTag/Viewport/Tag/" .. i .. "/ImageSel", "Image")
		self["GoTagDot" .. i] = self:GetChildGameObject("SafeArea/Main/ScrollTag/Viewport/Tag/" .. i .. "/Dot")
	end

	self.tabMainIndex = 1

	ShopManager:FindTabIndexByType(tabMainType.package)

	local listShop, tabindex

	if vParam and vParam.tabMainIndex then
		self.tabMainIndex = ShopManager:FindTabIndexByType(vParam.tabMainIndex)
		listShop = ShopManager.listAll[vParam.tabMainIndex]
		tabindex = self:SetTagIndex(listShop, vParam.tagIndex)
	else
		local config = GetConfigArgJson("ShopFirstLook")

		self.tabMainIndex = ShopManager:FindTabIndexByType(config[1])
		listShop = ShopManager.listAll[config[1]]
		tabindex = self:SetTagIndex(listShop, config[2])
	end

	if NoPay then
		local type = ShopManager:FindTypeByTabIndex(self.tabMainIndex)

		if type == tabMainType.charge or type == tabMainType.package or type == tabMainType.month then
			self.tabMainIndex = ShopManager:FindTabIndexByType(tabMainType.item)

			local listShop = ShopManager.listAll[tabMainType.item]

			if listShop and listShop[1] and listShop[1].data.SubTabIndex then
				self.tagIndex = listShop[1].data.SubTabIndex
			end
		end
	end

	self.listShop = {}
	self.listAllIndex = {}
	self.listGood = {}
	self.listPackGood = {}

	self:UpdateTabMain()
	self:UpdateTag()
	self:InitScrollView()
	self:InitScrollViewMonth()
	self:InitScrollViewList()

	if self.content then
		UITweenUtil.CommonTweenRight(self.tagGroup.transform, 40, 0.14)
		UITweenUtil.SetGroupAlpha(self.content, 0)

		if self.timer ~= nil then
			TimerMgr.RemoveTimer(self.timer)

			self.timer = nil
		end

		self.timer = TimerMgr.AddTimer(eTimerType.RealTime, 0.3, function()
			UITweenUtil.OrderAlphaAnim(self.content, 0.3)
		end, nil)
	end

	self:CheckAcc()

	if vParam and vParam.tabMainIndex and tabindex ~= nil and tabindex > 4 then
		GOUtil.SetRectTransformAnchoredPosition(self.GoTag, -600 - 270 * (tabindex - 4), 0)
	end

	if vParam and vParam.openRecharge then
		self:OnOpenAccumulate()
	end

	TaskManager.battlePassPayList = {}
end

function PageShop:OnRegisterEvent()
	SceneMainStage.Instance.inInteraction = true

	for i = 1, self.tabMainCount do
		self:AddClick(self["TabMain" .. i], self.OnButtonTabMain)
	end

	for i = 1, self.tabSubCount do
		self:AddClick(self["ImgTagBtn" .. i].gameObject, self.OnButtonTag)
	end

	self:AddClick(self.GrowthFundGo, self.OnGrowthFundGo)
	self:AddClick(self.GrowthFundAwardButton, self.GetGrowthFundAward)
	self:AddClick(self.GrowthFundBuyButton, self.OnButtonMonthBuy)
	self:AddClick(self.ButtonMonthBuy, self.OnButtonMonthBuy)
	self:AddClick(self.ButtonMonthAward, self.OnButtonMonthAward)
	self:AddClick(self.ButtonRule, self.OnClickedRule)
	self:AddClick(self.BtnAccumulate, self.OnOpenAccumulate)
	Event.Instance:Add("UpdateShop", self.UpdateShop, self)
	Event.Instance:Add("UpdateMonth", self.UpdateMonth, self)
	Event.Instance:Add(BillingManager.OnPaySuceed, self.OnPurchased, self)
	Event.Instance:Add("UpdateNetData", self.UpdateNetData, self)
	Event.Instance:Add("UpdateServerRefresh", self.UpdateServerRefresh, self)
	Event.Instance:Add("UpdateMonthOrder", self.UpdateMonthOrder, self)
	Event.Instance:Add("UpdateShopTab", self.UpdateShopTab, self)
	Event.Instance:Add("NotifyPanelLoaded", self.NotifyPanelLoaded, self)
	Event.Instance:Add("PageShopCloseEvent", self.OnBack, self)
	self:AddClick(self.GoArrow, self.OnClickedGoArrow)
end

function PageShop:OnUnRegisterEvent()
	SceneMainStage.Instance.inInteraction = false

	for i = 1, self.tabMainCount do
		self:RemoveClick(self["TabMain" .. i], self.OnButtonTabMain)
	end

	for i = 1, self.tabSubCount do
		self:RemoveClick(self["ImgTagBtn" .. i].gameObject, self.OnButtonTag)
	end

	self:RemoveClick(self.GrowthFundGo, self.OnGrowthFundGo)
	self:RemoveClick(self.GrowthFundAwardButton, self.GetGrowthFundAward)
	self:RemoveClick(self.GrowthFundBuyButton, self.OnButtonMonthBuy)
	self:RemoveClick(self.ButtonMonthBuy, self.OnButtonMonthBuy)
	self:RemoveClick(self.ButtonMonthAward, self.OnButtonMonthAward)
	self:RemoveClick(self.ButtonRule, self.OnClickedRule)
	self:RemoveClick(self.BtnAccumulate, self.OnOpenAccumulate)
	Event.Instance:Remove("UpdateShop", self.UpdateShop, self)
	Event.Instance:Remove("UpdateMonth", self.UpdateMonth, self)
	Event.Instance:Remove(BillingManager.OnPaySuceed, self.OnPurchased, self)
	Event.Instance:Remove("UpdateNetData", self.UpdateNetData, self)
	Event.Instance:Remove("UpdateServerRefresh", self.UpdateServerRefresh, self)
	Event.Instance:Remove("UpdateMonthOrder", self.UpdateMonthOrder, self)
	Event.Instance:Remove("UpdateShopTab", self.UpdateShopTab, self)
	Event.Instance:Remove("NotifyPanelLoaded", self.NotifyPanelLoaded, self)
	Event.Instance:Remove("PageShopCloseEvent", self.OnBack, self)

	if UIMgr.GetCurPanel() and UIMgr.GetCurPanel().className == "PageMainStage" then
		Event.Instance:Fire("OpenSceneCamera")
		Event.Instance:Fire("UpdateSceneDisplay", true)
	end

	self:RemoveClick(self.GoArrow, self.OnClickedGoArrow)
	UIMgr.RemoveUpdatePanel(self)
end

function PageShop:OnPurchased(item)
	if self.jpShopManager:OnPurchased(item) then
		return
	end

	if item.type == protocol_pb.pack then
		local info = self.ChargeFunction[protocol_pb.pack]

		local function wrap_cb(res)
			LoadingMgr.Hide(eLoadingType.Repeat)

			local productIds = {}
			local isDel = true

			for k, v in pairs(res.productList) do
				if tostring(item.id) == v.shopProductMasterId then
					isDel = false

					break
				end
			end

			local currentItem

			for k, v in pairs(info.DataList) do
				if tostring(item.id) == v.product.shopProductMasterId then
					currentItem = v

					break
				end
			end

			if isDel then
				table.removeByValue(info.DataList, currentItem)
			else
				currentItem.product.shopBillingLimitedProductDetail.limitedRemainingAmount = currentItem.product.shopBillingLimitedProductDetail.limitedRemainingAmount - 1
			end

			info.UIScrollTool:UpdateListDataKeepPos(info.DataList)
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestShopPack(wrap_cb)
	else
		NetManager:RequestShopSnsCoin(function(res)
			return
		end)
	end
end

function PageShop:ShowProductError()
	return
end

function PageShop:OnClickedRule()
	UIMgr.AddPanel(PagePayRule(), {
		curIndex = 4,
		mode = 2
	}, self.UIRootObject)
end

function PageShop:InitScrollViewMonth()
	local ScrollArea = self:GetChildGameObject("SafeArea/Main/DlgMonth/ScrollAreaMonth")
	local content = self:GetChildComponent("SafeArea/Main/DlgMonth/ScrollAreaMonth/Content", "Transform")
	local count = #self.listGood

	self.UIScrollToolMonth = UIScrollTool()

	self.UIScrollToolMonth:InitList(ScrollArea, content, count, self.PrefabCellMonth, CellGood, self, false)
end

function PageShop:InitScrollView()
	local ScrollArea = self:GetChildGameObject("SafeArea/Main/ScrollArea")
	local content = self:GetChildComponent("SafeArea/Main/ScrollArea/Content", "Transform")
	local count = #self.listGood

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.ScrollAreaGrid, content, count, self.PrefabCell, CellGood, self, false)
end

function PageShop:InitScrollViewList()
	if self.jpShopManager:InitScrollViewList() then
		return
	end

	local ScrollArea = self:GetChildGameObject("SafeArea/Main/ScrollAreaList")

	self.content = self:GetChildComponent("SafeArea/Main/ScrollAreaList/Content", "Transform")

	local count = #self.listGood

	self.UIScrollToolList = UIScrollTool()

	self.UIScrollToolList:InitList(ScrollArea, self.content, count, self.PrefabCellList, CellGood, self, true)

	self.ScrollAreaList = self:GetChildGameObject("SafeArea/Main/ScrollAreaList")
end

function PageShop:UpdateCell(item, index)
	item.Index = index

	local info
	local chargeType = self.jpShopManager:GetChargeType()

	if self.tabMainType == JPShopManager.MainTab01 then
		info = self.ChargeFunction[protocol_pb.normal].DataList[index]
	else
		info = self.listGood[index]
	end

	if self.tabMainType == tabMainType.package then
		-- block empty
	elseif self.tabMainType == tabMainType.month then
		-- block empty
	else
		info.isTextLimitWrap = true
	end

	item:UpdateData(info)
	item:UpdateBase(index)

	if self.tabMainType == tabMainType.package then
		item:UpdateItemList(info, self.PrefabCellItem, self.ScrollAreaList)
	elseif self.tabMainType == tabMainType.month then
		item.TextNum.gameObject:SetActive(false)
		item.GoLockMonth:SetActive(not ShopManager:IsGetAnyMonthCard())
	end
end

function PageShop:AddCellClick(item)
	if self.tabMainType == tabMainType.package then
		local g = GOUtil.FindChildGameObject(item.UIRootObject, "Button")

		self:AddClick(g, self.OnClickedCell)

		local isbuy = GOUtil.FindChildGameObject(item.UIRootObject, "IsBuy")

		if isbuy ~= nil then
			local function fun()
				UIMgr.ShowMsg(_("Desc_BuyGood_Limit"))
			end

			self:AddClick(isbuy, fun)
		end
	else
		self:AddClick(item.UIRootObject, self.OnClickedCell)
	end
end

function PageShop:OnClickedCell(data)
	local go = data.pointerPress
	local chargeType = self.jpShopManager:GetChargeType()
	local info

	if self.tabMainType == JPShopManager.MainTab01 then
		local chargeFunction = self.ChargeFunction[protocol_pb.normal]

		info = chargeFunction.UIScrollTool.ItemRoot2ItemDict:GetValue(go)

		local infoProduct = chargeFunction.DataList[info.Item.Index]

		function infoProduct.cb()
			BillingManager:CheckPayStateAndPurchase(infoProduct.product.shopProductMasterId, infoProduct.product.platformProductId, infoProduct.Price, protocol_pb.normal, self:Instance())
		end

		UIMgr.AddPanel(DlgShopProductDetailJP(), infoProduct, self.UIRootObject)

		return
	elseif self.tabMainType == tabMainType.month then
		info = self.UIScrollToolMonth.ItemRoot2ItemDict:GetValue(go)
	elseif self.tabMainType == tabMainType.package then
		info = self.UIScrollToolList.ItemRoot2ItemDict:GetValue(go.transform.parent.gameObject)
	else
		info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	end

	local infoProduct = self.listGood[info.Item.Index]
	local id = infoProduct.data.GoodsItemList[1][1]
	local infoItem = ItemManager:Get(id)
	local lock = GOUtil.FindChildGameObject(go, "ImageLock")

	if lock and lock.activeSelf then
		UIMgr.ShowMsg(_("Desc_BuyGood_Limit"))

		return
	end

	if infoProduct.data.CostType == 3 then
		UIMgr.AddPanel(DlgChangeStar(), infoProduct, self.UIRootObject)
	else
		infoProduct.shopType = self.tabMainType
		infoProduct.isMonThCard = self.tabMainType == tabMainType.month

		UIMgr.AddPanel(DlgShopProductDetail(), infoProduct, self.UIRootObject)
	end
end

function PageShop:UpdateShopTab(data)
	local index = ShopManager:FindTabIndexByType(data.tabMainIndex)

	if self.tabMainIndex == index then
		return
	end

	self.tabMainIndex = index

	local listShop = ShopManager.listAll[data.tabMainIndex]

	self:SetTagIndex(listShop, data.tagIndex)
	self:UpdateTabMain()
	self:UpdateTag(true)
	GOUtil.SetRectTransformAnchoredPosition(self.GoTag, 0, 0)
end

function PageShop:UpdateTabMain()
	self.jpShopManager:UpdateTabMain()

	for i = 1, self.tabMainCount do
		self["TabMainSel" .. i]:SetActive(false)
	end

	self["TabMainSel" .. self.tabMainIndex]:SetActive(true)

	self.listAllIndex = ShopManager.listAllIndex
	self.tabMainType = self.listAllIndex[self.tabMainIndex]
	self.listShop = ShopManager.listAll[self.tabMainType]

	for i = 1, self.tabSubCount do
		self["GoTag" .. i]:SetActive(false)
	end

	for i = 1, #self.listShop do
		local infoShop = self.listShop[i]

		if i > self.tabSubCount then
			self:CreateTabSub()
		end

		self["GoTag" .. i]:SetActive(true)

		local g = self["GoTag" .. i]
		local t1 = GOUtil.FindChildComponent(g, "Button/Text", "Text")
		local t2 = GOUtil.FindChildComponent(g, "ImageSel/Text", "Text")

		t1.text = LocalizeIdThenKey(infoShop.data.Subpic)
		t2.text = LocalizeIdThenKey(infoShop.data.Subpic)

		local hasDot = ShopRDL.HasDotSecondTab(self.tabMainIndex, infoShop.id)

		GOUtil.SetActive(self["GoTagDot" .. i], hasDot)
	end
end

function PageShop:OnButtonTabMain(data)
	if data ~= nil then
		local go = data.pointerPress.transform.parent.gameObject
		local index = tonumber(go.name)

		if self.tabMainIndex == index then
			return
		end

		self.tabMainIndex = index
	end

	local listShop = ShopManager.listAll[ShopManager:FindTypeByTabIndex(self.tabMainIndex)]

	self:SetTagIndex(listShop)
	self:UpdateTabMain()
	self:UpdateTag(true)
	GOUtil.SetRectTransformAnchoredPosition(self.GoTag, 0, 0)

	if self.timer ~= nil then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end

	if self.content then
		UITweenUtil.RemoveTween(self.content)
		UITweenUtil.SetGroupAlpha(self.content, 1)
	end
end

function PageShop:OnButtonTag(data)
	local go = data.pointerPress.transform.parent.gameObject
	local index = self.listShop[tonumber(go.name)].data.SubTabIndex

	if self.tagIndex == index then
		return
	end

	self.tagIndex = index

	self:UpdateTag(true)
end

function PageShop:UpdateTag(isNoKeep)
	print("updatetag")

	if self.jpShopManager:UpdateTag(isNoKeep) then
		return
	end

	local index = 1

	for i = 1, #self.listShop do
		if i > self.tabSubCount then
			self:CreateTabSub()
		end

		if self.listShop[i].data.SubTabIndex == self.tagIndex then
			index = i

			break
		end
	end

	self:CheckTagDot()

	for i = 1, self.tabSubCount do
		self["ImgTagBtn" .. i].gameObject:SetActive(true)
		self["ImgTagSel" .. i].gameObject:SetActive(false)
	end

	self["ImgTagBtn" .. index].gameObject:SetActive(false)
	self["ImgTagSel" .. index].gameObject:SetActive(true)

	local chargeType = self.jpShopManager:GetChargeType()

	if self.tabMainType == tabMainType.month then
		if ShopData[21] and self.tagIndex == ShopData[21].SubTabIndex then
			self.GrowthFund:SetActive(true)
			self.PanelMonth:SetActive(false)
		else
			self.GrowthFund:SetActive(false)
			self.PanelMonth:SetActive(true)
		end

		self.ScrollAreaMain:SetActive(false)
		self.ScrollAreaList:SetActive(false)
		self.ScrollAreaCharge:SetActive(false)
		self.ScrollAreaJP1:SetActive(false)
		self:UpdateTagMonthPanel(isNoKeep)
		self.DlgExit:HideHelpBtn()
		self:UpdateMonth()
	elseif self.tabMainType == tabMainType.package then
		self.GrowthFund:SetActive(false)
		self.PanelMonth:SetActive(false)
		self.ScrollAreaCharge:SetActive(false)
		self.ScrollAreaJP1:SetActive(false)
		self.ScrollAreaMain:SetActive(false)
		self.ScrollAreaList:SetActive(true)
		self.DlgExit:HideHelpBtn()
		self:UpdateTagPanel(isNoKeep)
	elseif self.tabMainType == tabMainType.exchange then
		if not GuideMgr:IsGuided(GuideFunctionType.Shop) and not isPGuidePopped then
			isPGuidePopped = true

			UIMgr.AddPanel(PGuide(), GuideFunctionType.Shop)
		end

		self.DlgExit:ShowHelpBtn()
		self.GrowthFund:SetActive(false)
		self.PanelMonth:SetActive(false)
		self.ScrollAreaCharge:SetActive(false)
		self.ScrollAreaJP1:SetActive(false)
		self.ScrollAreaList:SetActive(false)
		self.ScrollAreaMain:SetActive(true)
		self:UpdateTagPanel(isNoKeep)
	elseif self.tabMainType == JPShopManager.MainTab01 then
		self.GrowthFund:SetActive(false)
		self.ScrollAreaCharge:SetActive(false)
		self.ScrollAreaGrid:SetActive(false)
		self.ScrollAreaJP1:SetActive(true)
		self.ScrollAreaMain:SetActive(false)
		self.PanelMonth:SetActive(false)
		self.ScrollAreaList:SetActive(false)
		self:UpdateTagPanel(isNoKeep)
	else
		self.ScrollAreaCharge:SetActive(false)

		if chargeType == protocol_pb.normal then
			self.ScrollAreaGrid:SetActive(false)
			self.ScrollAreaJP1:SetActive(true)
			self.ScrollAreaMain:SetActive(false)
		else
			self.GrowthFund:SetActive(false)
			self.ScrollAreaGrid:SetActive(true)
			self.ScrollAreaJP1:SetActive(false)
			self.ScrollAreaMain:SetActive(true)
		end

		self.PanelMonth:SetActive(false)
		self.ScrollAreaList:SetActive(false)
		self.DlgExit:HideHelpBtn()
		self:UpdateTagPanel(isNoKeep)
	end

	if self.closed then
		return
	end

	local resCount = #self.infoShop.data.ResList

	if not self.BtnGroupRes then
		self.BtnGroupRes = {}
	elseif self.BtnGroupRes then
		for _, v in pairs(self.BtnGroupRes) do
			self:RemoveClick(v, self.OnClickedBtnGroupRes)
		end
	end

	if resCount > 0 then
		self.GroupRes:SetActive(true)

		for i = 1, 4 do
			local g = self:GetChildGameObject("SafeArea/Main/GroupRes/" .. i)

			if resCount < i then
				g:SetActive(false)
			else
				g:SetActive(true)

				local itemId = self.infoShop.data.ResList[i]
				local infoItem = ItemManager:Get(itemId)
				local Image = self:GetChildComponent("SafeArea/Main/GroupRes/" .. i .. "/Image", "Image")

				self["BtnGroupRes" .. i] = table.insert(self.BtnGroupRes, Image.gameObject)

				self:AddClick(Image.gameObject, self.OnClickedBtnGroupRes)

				local pathIcon = GetItemIcon(infoItem:GetType(), infoItem.id)

				UIUtil.SetImageOverrideSprite(Image, pathIcon .. "_S", self)

				local TextNum = self:GetChildComponent("SafeArea/Main/GroupRes/" .. i .. "/TextNum", "Text")

				TextNum.text = infoItem:GetCurResNum()
			end
		end
	else
		self.GroupRes:SetActive(false)
	end
end

function PageShop:OnClickedBtnGroupRes(data)
	local go = data.pointerPress.transform.parent.gameObject
	local index = tonumber(go.name)

	if index then
		local itemId = self.infoShop.data.ResList[index]
		local infoItem = ItemManager:Get(itemId)

		if infoItem:GetType() == eItemType.I_PACK_CARD then
			UIMgr.AddPanel(DlgRoleCardChange(), {
				info = infoItem
			})
		else
			UIMgr.ShowItemTip(infoItem, 3, true, true)
		end
	end
end

function PageShop:UpdateTagMonthPanel(isNoKeep)
	self:UpdateInfoShop()

	self.listGood = {}

	for i = 2, #self.infoShop.listGood do
		table.insert(self.listGood, self.infoShop.listGood[i])
	end

	self.ScrollAreaMonth:SetActive(true)

	if #self.listGood < 1 then
		self.ScrollAreaMonth:SetActive(false)
	end

	if self.UIScrollToolMonth then
		if isNoKeep then
			self.UIScrollToolMonth:UpdateListData(self.listGood)
		else
			self.UIScrollToolMonth:UpdateListDataKeepPos(self.listGood)
		end
	end

	self.showLeftTime = self.infoShop.pb.freshAt ~= 0

	self:OnUpdateSecond()
	GOUtil.SetActive(self.GoTime, self.showLeftTime)
end

function PageShop:UpdateTagPanel(isNoKeep)
	self:UpdateInfoShop()

	self.listGood = self.infoShop.listGood
	self.listPackGood = {}

	local productPackType = BaseDataUtil.GetShopType(protocol_pb.pack)

	for k, v in pairs(listLimitedProducts) do
		if v.product_type == productPackType then
			table.insert(self.listPackGood, v)
		end
	end

	self:SortList()

	if not self.jpShopManager:UpdateTagPanel() and self.UIScrollTool then
		if self.tabMainType == tabMainType.package then
			if self.UIScrollToolList then
				if isNoKeep then
					self.UIScrollToolList:UpdateListData(self.listGood)
				else
					self.UIScrollToolList:UpdateListDataKeepPos(self.listGood)
				end
			end
		elseif self.UIScrollTool then
			if isNoKeep then
				self.UIScrollTool:UpdateListData(self.listGood)
			else
				self.UIScrollTool:UpdateListDataKeepPos(self.listGood)
			end
		end
	end

	if self:IsTimeSpaceShop() then
		self.infoShop.pb.freshAt = TimeSpaceChapterMgr.EndTime * DateUtil.MillsPerSecond
	end

	self.showLeftTime = self.infoShop.pb.freshAt ~= 0

	self:OnUpdateSecond()
	GOUtil.SetActive(self.GoTime, self.showLeftTime)
end

function PageShop:IsTimeSpaceShop()
	return self.infoShop.data.SubTabIndex == 35
end

function PageShop:OnUpdateSecond()
	local t = NetData:GetCurServerTime()

	if self.showLeftTime then
		local t2 = self.infoShop.pb.freshAt - t

		if t2 <= 0 then
			if self:IsTimeSpaceShop() then
				LoadingMgr.Show(eLoadingType.Repeat)
				NetManager:GetTimeSpaceData(function(msg)
					TimeSpaceChapterMgr:Refresh()
					LoadingMgr.Hide(eLoadingType.Repeat)
				end)
			end

			Event.Instance:Fire("CloseRecharge")
			self:OnBack()
			PageShop.InitNetData()

			return
		else
			t2 = Mathf.Max(0, t2)

			if self.infoShop.data.ShopTimeShow == eShopRefreshType.Termination then
				self.TextRefreshTime.text = _("Shop_End_leftTime") .. "\n" .. DateUtil.GetOneMomentByMillis(t2)
			else
				self.TextRefreshTime.text = _("Shop_leftTime") .. "\n" .. DateUtil.GetOneMomentByMillis(t2)
			end
		end
	end

	for _, main in pairs(ShopManager.listAll) do
		local endNum = 0

		for _, sub in pairs(main) do
			if sub.data.EndTime and sub.data.EndTime ~= "" then
				local curServerTime = t
				local overTime = GetTimeTampByString(sub.data.EndTime) * DateUtil.MillsPerSecond

				if curServerTime > overTime + 3000 then
					endNum = endNum + 1
				end
			else
				break
			end
		end

		if endNum == #main then
			Event.Instance:Fire("CloseRecharge")
			self:OnBack()
			PageShop.InitNetData()

			return
		end
	end

	if self.accumulateTime and t / DateUtil.MillsPerSecond > self.accumulateTime then
		self.accumulateTime = nil

		self.BtnAccumulate:SetActive(false)
		Event.Instance:Fire("CloseRecharge")
	end
end

function PageShop:UpdateServerRefresh()
	self:OnBack()
	PageShop.InitNetData()
end

function PageShop:OnButtonMonthAward()
	self:UpdateInfoShop()

	local infoProduct = self.infoShop.listGood[1]

	if self:CheckInDay(infoProduct) and infoProduct:CanGetAward() then
		local function callback(vPBMessage)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vPBMessage.result.code == NetManager.Result_Sucess then
				infoProduct.awardAt = vPBMessage.awardAt

				ShopRDL.RemoveGood(infoProduct.id)
				self:UpdateTag()
			else
				UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
			end
		end

		NetManager:RequestGetPurchaseReward(infoProduct.id, callback)
		LoadingMgr.Show(eLoadingType.Repeat)
	end
end

function PageShop:OnGrowthFundGo()
	local panel = UIMgr.GetCurPanel()

	if panel and panel.className == "PageOperationActiveNew" then
		Event.Instance:Fire("OperationActiveJump", eOperationActive.GrowthFund)
		self:OnBack()

		return
	end

	UIMgr.ClearAndSavePageMainStage()
	DlgItemTip.GoToFrom({
		16,
		eOperationActive.GrowthFund
	})
end

function PageShop:GetGrowthFundAward()
	self:UpdateInfoShop()

	local infoProduct = self.infoShop.listGood[1]

	local function callback(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			infoProduct.awardAt = vPBMessage.awardAt

			OperationRDL.RunGrowthFund()
			ShopRDL.RemoveGood(infoProduct.id)
			self:UpdateTag()
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetManager:RequestGetPurchaseReward(infoProduct.id, callback)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageShop:OnButtonMonthBuy()
	return
end

function PageShop:RequestBuyMonthCard(infoProduct)
	if self.jpShopManager:RequestBuyMonthCard(infoProduct) then
		return
	end

	print("in pageshop")

	local function callback(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			SoundMgr.Play(PATH_SFX_UI_SHOP_BUYSUCCESS)
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetEncapManager:RequestPurchasePruduct(infoProduct.id, 1, "", {}, callback)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageShop:OnMonthOperate()
	self:UpdateInfoShop()

	local function wrap_cb(index3)
		if index3 == 1 then
			local infoProduct = self.infoShop.listGood[1]

			self:RequestBuyMonthCard(infoProduct)
		end
	end

	local strMsgList = {
		"Desc_Month_Buy_Msg3",
		"Desc_Month_Buy_Msg1",
		"Desc_Month_Buy_Msg2",
		"Desc_Month_Buy_Msg4"
	}
	local infoProduct = ShopManager:GetProduct(self.infoShop.listGood[1].id)
	local strCostValue = "￥" .. tonumber(infoProduct.data.CostValue[1]) / 100
	local strTitle = Lang(42624)
	local strOkText = _("UI_OK")
	local strCancelText = _("Quite_Cancel")
	local msg = string.format(_(strMsgList[self.tagIndex]), strCostValue)

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, strTitle, {
		isDiamond = true,
		text = msg
	}, wrap_cb, strOkText, strCancelText)
end

function PageShop:UpdateShop(vPBMessage)
	self.jpShopManager:UpdateShop(vPBMessage)
	self:SortList()
	self:UpdateTag()
end

function PageShop:SortList()
	local list1 = {}
	local list2 = {}
	local list3 = {}
	local list4 = {}

	for i = 1, #self.listGood do
		local info = self.listGood[i]
		local limitBuyTime = info.data.StoreNumber
		local usedBuyTime = info.pb.myCount

		if limitBuyTime ~= -1 and limitBuyTime <= usedBuyTime then
			table.insert(list4, info)
		elseif info.data.SignBG ~= "" then
			table.insert(list1, info)
		elseif info.data.Discount ~= 100 then
			table.insert(list2, info)
		else
			table.insert(list3, info)
		end
	end

	table.merge(list1, list2)
	table.merge(list1, list3)
	table.merge(list1, list4)

	self.listGood = {}

	for i = 1, #list1 do
		local info = list1[i]
		local PreGoodsID = info.data.PreGoodsID
		local needAdd = true

		if info.data.HideAfterOutStore == 1 and info.data.StoreNumber ~= -1 and info.pb.myCount >= info.data.StoreNumber then
			needAdd = false
		end

		if PreGoodsID > 0 then
			local infoPre = ShopManager:GetProduct(PreGoodsID)

			if info.data.StoreNumber ~= -1 and infoPre.pb.myCount < infoPre.data.StoreNumber then
				needAdd = false
			end
		end

		if needAdd then
			table.insert(self.listGood, info)
		end
	end
end

function PageShop:UpdateMonthOrder()
	self:UpdateTagMonthPanel(false)
	self:UpdateMonth()
end

function PageShop:UpdateInfoShop()
	for i = 1, #self.listShop do
		if i > self.tabSubCount then
			self:CreateTabSub()
		end

		if self.listShop[i].data.SubTabIndex == self.tagIndex then
			self.infoShop = self.listShop[i]

			break
		end
	end
end

function PageShop:UpdateMonth()
	self:UpdateInfoShop()

	local infoProduct = ShopManager:GetProduct(self.infoShop.listGood[1].id)

	if infoProduct.id == 40005 then
		SetActiveFunc(self.CellBuffTips, false)
		GOUtil.DestroyAllChildren(self.BuffTips)

		local buffTips = Lang(infoProduct.data.Info)

		if buffTips then
			local buffTipsList = string.split(buffTips, "_")

			for i = 1, #buffTipsList do
				if buffTipsList[i] then
					local goCell = GOUtil.Instantiate(self.CellBuffTips, self.BuffTips)

					SetActiveFunc(goCell, true)

					local gTxt = GOUtil.GetComponentInChildren(goCell, "Text")

					gTxt.text = buffTipsList[i]
				end
			end
		end

		self.TexGrowthFundDes.text = _("GrowthFund_Des")

		if ShopManager:GetGrowthFund() then
			self.ImgIsGet:SetActive(true)

			local infoItem = ItemManager:GetValueItem(infoProduct.data.RefreshAward[1][1], infoProduct.data.RefreshAward[1][2])

			self.GrowthAward3:UpdateWithNumType(infoItem)

			local TexAward = self:GetChildComponent("SafeArea/Main/GrowthFund/State2/TextWeekGet", "Text")
			local nowMonday = GetNowMondyTime()
			local fx = self:GetChildGameObject("SafeArea/Main/GrowthFund/State2/CellItem/FX_UI_Welfare01")
			local dot = self:GetChildGameObject("SafeArea/Main/GrowthFund/State2/CellItem/Dot")

			self.TexGrowthFundTitle.text = _("Permanent_Benefits")

			if nowMonday > tonumber(infoProduct.awardAt) then
				TexAward.text = _("EveryWeek_Get")

				self.GrowthFundAwardButton:SetActive(true)
				self.GrowthAward3:SetGeted(false)
				fx:SetActive(true)
				dot:SetActive(true)
			else
				self.GrowthFundAwardButton:SetActive(false)
				self.GrowthAward3:SetGeted(true)
				fx:SetActive(false)
				dot:SetActive(false)

				TexAward.text = GetNexMondyDay() .. _("GrowthFund_CanGetTime")
			end

			self.GrowthFundState1:SetActive(false)
			self.GrowthFundState2:SetActive(true)
		else
			self.ImgIsGet:SetActive(false)

			self.TexGrowthFundTitle.text = _("GrowthFund_Bug_Get")

			local infoItem = ItemManager:GetValueItem(infoProduct.data.GoodsItemList[1][1], infoProduct.data.GoodsItemList[1][2])

			self.GrowthAward1:UpdateWithNumType(infoItem)

			local TexAward = self:GetChildComponent("SafeArea/Main/GrowthFund/State1/Award1/TexGet", "Text")

			TexAward.text = _("BuyAndGet_Now")
			infoItem = ItemManager:GetValueItem(infoProduct.data.RefreshAward[1][1], infoProduct.data.RefreshAward[1][2])

			self.GrowthAward2:UpdateWithNumType(infoItem)

			TexAward = self:GetChildComponent("SafeArea/Main/GrowthFund/State1/Award2/TexWeekGet", "Text")
			TexAward.text = _("EveryWeek_Get")
			self.TextMonthBuy = self:GetChildComponent("SafeArea/Main/DlgMonth/ButtonBuy/Text", "Text")
			self.TextGrowthFundBuy.text = "￥" .. tonumber(infoProduct.data.CostValue[1]) / 100 .. _("UI_Buy")

			self.GrowthFundState1:SetActive(true)
			self.GrowthFundState2:SetActive(false)
		end

		return
	end

	self.GoMonthDisCost:SetActive(false)
	self.GoMonthRate:SetActive(false)
	SetActiveFunc(self.TexRate.gameObject, false)
	GOUtil.SetRectTransformAnchoredPosition(self.ButtonMonthBuy, -264, -180)
	self.ButtonMonthAward.gameObject:SetActive(false)
	self.MonthAwardEveryDay:SetActive(false)
	self.MonthAwardToday:SetActive(false)
	self.MonthAwardTomorrow:SetActive(false)

	if self:CheckInDay(infoProduct) then
		self.ImgDays:SetActive(false)

		self.TextMonthBuy.text = _("Shop_continue")

		self.GoImageLeft:SetActive(true)

		self.TextMonthLeft.text = _("Shop_leftDay") .. DateUtil.GetDayMomentByMillis(infoProduct.endAt - NetData:GetCurServerTime())

		if infoProduct:CanGetAward() then
			self.MonthAwardToday:SetActive(true)
			self.MonthDot:SetActive(true)
		else
			self.MonthAwardTomorrow:SetActive(true)
		end

		if #infoProduct.data.RefreshAward > 0 then
			self.ButtonMonthAward.gameObject:SetActive(true)
			self.TextMonthSign.gameObject:SetActive(true)

			if infoProduct:CanGetAward() then
				self.TextMonthSign.text = _("Desc_Get")
			else
				self.TextMonthSign.text = _("Desc_Has_Get")
			end
		else
			self.TextMonthSign.gameObject:SetActive(false)
		end
	else
		self.ImgDays:SetActive(true)
		self.TextMonthSign.gameObject:SetActive(false)
		self.GoImageLeft:SetActive(false)

		self.TextMonthBuy.text = "￥" .. tonumber(infoProduct.data.CostValue[1]) / 100

		if infoProduct.data.ProductType == 6 then
			GOUtil.SetRectTransformAnchoredPosition(self.ButtonMonthBuy, -264, -290)

			local t = GOUtil.FindChildComponent(self.GoMonthDisCost, "Text", "Text")

			t.text = infoProduct.data.GoodsPrice[1]
			t = GOUtil.FindChildComponent(self.GoMonthRate, "Text", "Text")
			t.text = infoProduct.data.Discount / 10
			self.TexRate.text = infoProduct.data.Discount / 10

			self.ButtonMonthAward.gameObject:SetActive(false)
		else
			self.MonthAwardEveryDay:SetActive(true)

			if MONTH_CARD_S_ID == infoProduct.id then
				self.ButtonMonthAward.gameObject:SetActive(true)
			end
		end
	end

	self.TextMonthTip.gameObject:SetActive(infoProduct.data.ProductType == 6)

	self.TextMonthTip.text = _("Desc_BuyDoubleMonthCard")
	self.TextMonthInfo.text = Lang(infoProduct.data.Info)

	UIUtil.SetImageOverrideSprite(self.ImgMonth, infoProduct.data.Icon, self)
	SetActiveFunc(self.cellBuff, false)
	self.jpShopManager:UpdateMonthCard(infoProduct)

	self.showNum = 0
	self.listCellBuff = self.listCellBuff or {}

	for _, cell in ipairs(self.listCellBuff) do
		GOUtil.SetActive(cell, false)
	end

	local buffTips = Lang(infoProduct.data.Info)

	if buffTips then
		local buffTipsList = string.split(buffTips, "_")

		for i = 1, #buffTipsList do
			if buffTipsList[i] then
				local goCell

				if self.showNum + 1 > #self.listCellBuff then
					goCell = GOUtil.Instantiate(self.cellBuff, self.ScrollAreaBuffTips)

					table.insert(self.listCellBuff, goCell)
				else
					goCell = self.listCellBuff[self.showNum + 1]
				end

				SetActiveFunc(goCell, true)

				local gTxt = GOUtil.GetComponentInChildren(goCell, "Text")

				gTxt.text = buffTipsList[i]
				self.showNum = self.showNum + 1
			end
		end
	end

	self.scale = -1

	GOUtil.SetActive(self.GoArrow, self.maxNum < self.showNum)

	if self.maxNum < self.showNum then
		self:UpdateMonthCardBuff()
	end
end

function PageShop:OnClickedGoArrow()
	self.scale = self.scale * -1

	self:UpdateMonthCardBuff()
end

function PageShop:UpdateMonthCardBuff()
	for i = self.maxNum + 1, self.showNum do
		GOUtil.SetActive(self.listCellBuff[i], self.scale == 1)
	end

	GOUtil.SetTransformLocalScale(self.GoArrow, 1, self.scale, 1)
end

function PageShop:CheckInDay(infoProduct)
	return infoProduct.endAt > 0 and NetData:GetCurServerTime() < infoProduct.endAt
end

function PageShop:CheckTagDot()
	local index = 1

	for i = 1, #self.listShop do
		if self.listShop[i].data.SubTabIndex == self.tagIndex then
			index = i

			break
		end
	end

	local hasDot = ShopRDL.HasDotSecondTab(self.tabMainIndex, self.listShop[index].id)

	GOUtil.SetActive(self["GoTagDot" .. index], hasDot)

	if self.tabMainType == tabMainType.month then
		GOUtil.SetActive(self.MonthDot, hasDot)
	end
end

function PageShop:OnClickedGuideBtn()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.Shop)
end

function PageShop:OnOpenAccumulate()
	require("UI/Page/PageAccumulatedRecharge/PageAccumulatedRecharge")

	if self.AccumulateID ~= nil then
		local function wrap_cb(vMsg)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vMsg.result.code == NetManager.Result_Sucess then
				local infoOperationActive = OperationActiveMgr:Get(self.AccumulateID)

				infoOperationActive:SetData(vMsg.activeOperates[1])
				UIMgr.AddPanel(PageAccumulatedRecharge(), infoOperationActive)
			else
				UIMgr.ShowMsg(vMsg.result.desc, vMsg)
			end
		end

		NetManager:RequestActiveOperates({
			self.AccumulateID
		}, wrap_cb)
		LoadingMgr.Show(eLoadingType.Repeat)
	else
		print("イベントIDは見つかりませんでした")
	end
end

function PageShop:CheckAcc()
	self.BtnAccumulate:SetActive(false)

	local data = OperationActiveMgr.GetAccumulatedRechargeData()

	if data ~= nil then
		local infoOperationActive = OperationActiveMgr:Get(data.ID)

		self.AccumulateID = data.ID

		if infoOperationActive ~= nil then
			local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
			local startTime = GetTimeTampByString(data.StartTime)
			local endTime = GetTimeTampByString(data.EndTime)

			self.accumulateTime = endTime

			if startTime <= curServerTime and curServerTime < endTime then
				self.TextAccumulate.text = _("Desc_PayReward")

				self.BtnAccumulate:SetActive(true)
			end
		end
	end

	self.BtnAccumulate:SetActive(false)
end

function PageShop:UpdateAccDot()
	return
end

function PageShop:SetTagIndex(listShop, SubType)
	if listShop == nil then
		return
	end

	local function func(a, b)
		return a.data.SubTabIndex < b.data.SubTabIndex
	end

	table.sort(listShop, func)

	if SubType == -1 then
		self.tagIndex = listShop[#listShop].data.SubTabIndex

		return #listShop
	elseif SubType then
		for index, value in pairs(listShop) do
			if value.data.SubType == SubType then
				self.tagIndex = value.data.SubTabIndex

				return index
			end
		end
	end

	if listShop and listShop[1] and listShop[1].data.SubTabIndex then
		self.tagIndex = listShop[1].data.SubTabIndex
	end
end

function PageShop:CreateTabSub()
	local TagGroup = self:GetChildGameObject("SafeArea/Main/ScrollTag/Viewport/Tag")
	local newTab = GOUtil.Instantiate(self["GoTag" .. self.tabSubCount], TagGroup)

	self.tabSubCount = self.tabSubCount + 1
	newTab.name = self.tabSubCount
	self["GoTag" .. self.tabSubCount] = self:GetChildGameObject("SafeArea/Main/ScrollTag/Viewport/Tag/" .. self.tabSubCount)
	self["ImgTagBtn" .. self.tabSubCount] = self:GetChildComponent("SafeArea/Main/ScrollTag/Viewport/Tag/" .. self.tabSubCount .. "/Button", "Image")
	self["ImgTagSel" .. self.tabSubCount] = self:GetChildComponent("SafeArea/Main/ScrollTag/Viewport/Tag/" .. self.tabSubCount .. "/ImageSel", "Image")
	self["GoTagDot" .. self.tabSubCount] = self:GetChildGameObject("SafeArea/Main/ScrollTag/Viewport/Tag/" .. self.tabSubCount .. "/Dot")

	self:AddClick(self["ImgTagBtn" .. self.tabSubCount].gameObject, self.OnButtonTag)
end

function PageShop:OnBackAndroid()
	if self.DlgExit then
		self.DlgExit:OnClickedBtnReturn()
	else
		self:OnBack()
	end
end
