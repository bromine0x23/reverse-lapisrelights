-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageShop/JPShopManager.lua

require("Info/InfoShop")
require("UI/Page/PageShop/CellChargeDiamond")

local shopGoods = require("luaData/ShopGoods")
local listLimitedProducts = require("luaData/m_billing_limited_product")
local billingProductAssetInfo = require("luaData/m_billing_product_asset")
local billingContentInfo = require("luaData/m_billing_product_content")

JPShopManager = class("JPShopManager")
JPShopManager.MainTab01 = 101
JPShopManager.MainTab02 = "JPMainTab02"
JPShopManager.MainTab03 = "JPMainTab03"
JPShopManager.MainTab04 = "JPMainTab04"
JPShopManager.MainTab05 = "JPMainTab05"

function JPShopManager:ctor(commonShop)
	self.commonShop = commonShop
	self.snsCoinProductList = nil
	self.packProductList = nil
	self.listAll = {}

	local listShop = {}
	local subTagCount = 0

	for i = 1, #billingContentInfo do
		if billingContentInfo[i].order_type2 ~= nil and subTagCount < billingContentInfo[i].order_type2 then
			subTagCount = billingContentInfo[i].order_type2

			table.insert(listShop, {
				data = {
					Subpic = _("PageShop_billing_snscoin_format_" .. subTagCount),
					SubTabIndex = subTagCount,
					SubType = subTagCount,
					ResList = {}
				},
				listGood = {},
				pb = {
					freshAt = 0
				}
			})
		end
	end

	self.listAll[JPShopManager.MainTab01] = listShop

	local config = require("luaData/Config")

	self.monthCardMaxDay = config.MonthCardMaxDay.ArgInt
end

function JPShopManager:InitScrollViewList()
	local commonShop = self.commonShop
	local ScrollArea = commonShop:GetChildGameObject("SafeArea/Main/ScrollAreaList")
	local content = commonShop:GetChildComponent("SafeArea/Main/ScrollAreaList/Content", "Transform")
	local count = #commonShop.listGood

	commonShop.UIScrollToolList = UIScrollTool()

	commonShop.UIScrollToolList:InitList(ScrollArea, content, count, commonShop.PrefabCellList, CellGood, commonShop, true)

	return true
end

function JPShopManager:GetProductFromShop(product_id)
	return self.snsCoinProductList[tostring(product_id)]
end

function JPShopManager:UpdateMonthCard(infoProduct)
	return
end

function JPShopManager:GetChargeType()
	if self.commonShop.tabMainIndex ~= tabMainType.charge then
		return -1
	end

	if self.commonShop.tagIndex == 1 then
		return protocol_pb.normal
	end
end

function JPShopManager:UpdateTabMain()
	self:UpdateRuleButton()

	if self.commonShop.tabMainIndex == 1 then
		local listShop = {}

		self:RefreshSnsCoinProductList(nil, protocol_pb.normal)

		ShopManager.listAllIndex[1] = JPShopManager.MainTab01
		ShopManager.listAll[JPShopManager.MainTab01] = self.listAll[JPShopManager.MainTab01]
	end
end

function JPShopManager:UpdateRuleButton()
	local btnRule = self.commonShop:GetChildGameObject("SafeArea/Main/Button")
	local imgLamp = self.commonShop:GetChildGameObject("SafeArea/Main/GoTime")
	local tabMainIndex = self.commonShop.tabMainIndex

	if tabMainIndex == 1 or tabMainIndex == 2 or tabMainIndex == 3 then
		btnRule:SetActive(true)
	else
		btnRule:SetActive(false)
	end

	if tabMainIndex == 1 or tabMainIndex == 2 or tabMainIndex == 3 or tabMainIndex == 5 or tabMainIndex == 4 and self.commonShop.tagIndex == 2 then
		imgLamp:SetActive(false)
	else
		imgLamp:SetActive(true)
	end
end

function JPShopManager:UpdateDataList(data, goodsIds)
	data.DataList = {}

	local productList = {}

	goodsIds = {}

	if data.ProductType == protocol_pb.pack then
		productList = self.packProductList
	else
		productList = self.snsCoinProductList
	end

	for i = 1, #goodsIds do
		table.insert(data.DataList, productList[goodsIds[i]])
	end

	local scrollArea = self.commonShop:GetChildGameObject(data.ScrollArea)
	local content = self.commonShop:GetChildComponent(data.ScrollArea .. "/Content", "Transform")
	local noText = self.commonShop:GetChildGameObject(data.ScrollArea .. "/no_text")

	noText:SetActive(#data.DataList <= 0)
	GOUtil.SetRectTransformSizeDeltaWidth(noText.gameObject, 600)

	if not data.UIScrollTool then
		data.UIScrollTool = UIScrollTool()

		data.UIScrollTool:InitList(scrollArea, content, #data.DataList, data.CellPrefab, data.CellLua, self.commonShop, false)
	else
		data.UIScrollTool:UpdateListData(data.DataList)
	end
end

function JPShopManager:RefreshSnsCoinProductList(cb, pType)
	self.handingSnsCoinList = true

	local function wrap_cb(res)
		LoadingMgr.Hide(eLoadingType.Repeat)

		local productIds = {}
		local uniqueKeys = {}

		for k, v in pairs(res.productList) do
			if v.platformProductId and not uniqueKeys[v.platformProductId] then
				uniqueKeys[v.platformProductId] = true
				productIds[#productIds + 1] = v.platformProductId
			end
		end

		local storeTimer = TimerMgr.AddTimer(eTimerType.RealTime, 12, function()
			LoadingMgr.Hide(eLoadingType.Repeat)
			self.commonShop:ShowProductError()

			self.handingSnsCoinList = false
		end, nil)

		BillingManager.GetProductList(productIds, function(dic)
			print("suceed")
			TimerMgr.RemoveTimer(storeTimer)
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

			local productDic

			if pType == protocol_pb.normal then
				self.snsCoinProductList = {}
				productDic = self.snsCoinProductList
			else
				self.packProductList = {}
				productDic = self.packProductList
			end

			if cb ~= nil then
				cb()
			end

			if self.snsHandlingCallback ~= nil then
				self.snsHandlingCallback()

				self.snsHandlingCallback = nil
			end

			self.handingSnsCoinList = false
		end, function(err)
			print("failed")
			LoadingMgr.Hide(eLoadingType.Repeat)
			TimerMgr.RemoveTimer(storeTimer)
			print(err.Message)
			print(err:ToString())
			self.commonShop:ShowProductError()

			self.handingSnsCoinList = false
		end)
	end

	LoadingMgr.Show(eLoadingType.Repeat)

	if pType == protocol_pb.normal then
		NetManager:RequestShopSnsCoin(wrap_cb)
	else
		NetManager:RequestShopPack(wrap_cb)
	end
end

function JPShopManager:OnInitJPShopDataList()
	local chargeType = self:GetChargeType()
	local data

	print("---< OnInitJPShopDataList >---")

	local tabMainIndex = self.commonShop.tabMainIndex
	local tagIndex = self.commonShop.tagIndex

	if tabMainIndex == 1 or self.snsCoinProductList == nil then
		local pt = protocol_pb.normal

		data = self.commonShop.ChargeFunction[pt]

		local shop = self.commonShop.listShop[tagIndex]
		local goodsIds = {}

		local function cb(left, right)
			return left.order_type1 * 10000 + left.order_type2 * 100 + left.order_type3 < right.order_type1 * 10000 + right.order_type2 * 100 + right.order_type3
		end

		table.sort(billingContentInfo, function(a, b)
			return cb(a, b)
		end)

		for i = 1, #billingContentInfo do
			local item = billingContentInfo[i]

			if item.order_type1 == tabMainIndex and item.order_type2 == tagIndex then
				goodsIds[#goodsIds + 1] = tostring(item.product_id)
			end
		end

		local productDics = pt == protocol_pb.normal and self.snsCoinProductList or self.packProductList

		if self.snsCoinProductList and pt == protocol_pb.normal or self.packProductList and pt == protocol_pb.pack then
			self:UpdateDataList(data, goodsIds)
		else
			data.DataList = nil

			if not self.handingSnsCoinList then
				self:RefreshSnsCoinProductList(function()
					self:UpdateDataList(data, goodsIds)
				end, data.ProductType)
			else
				function self.snsHandlingCallback()
					self:UpdateDataList(data, goodsIds)
				end
			end
		end

		return true
	elseif tabMainIndex == 2 then
		return false
	elseif tabMainIndex == 5 then
		return false
	else
		return false
	end
end

function JPShopManager:CheckCaution()
	local info = CautionMgr:GetCautionPopInfo(protocol_pb.shop)

	if info then
		local isCallReadApi = info.cautionType == protocol_pb.cautionBilling or info.cautionType == protocol_pb.cautionRestrictionBilling and not info.lookAt

		CautionBuilder.OpenCautionPopupOpt(info, function()
			if info.cautionType == protocol_pb.cautionRestrictionBilling then
				self.commonShop.tabMainIndex = 2

				self.commonShop:OnButtonTabMain()
			else
				self.commonShop:OnBack()
			end
		end, isCallReadApi)

		return true
	end
end

function JPShopManager:UpdateTag(isNoKeep)
	if self.commonShop.tabMainIndex == tabMainType.charge then
		self:CheckCaution()
	elseif self.commonShop.tabMainIndex == 2 then
		self:CheckCaution()

		local commonShop = self.commonShop

		self:OnInitJPShopDataList()

		return false
	end

	return false
end

function JPShopManager:UpdateTagPanel()
	local commonShop = self.commonShop

	if commonShop.tabMainIndex == 1 then
		self:OnInitJPShopDataList()

		return true
	end

	return false
end

function JPShopManager:OnPurchased(item)
	local commonShop = self.commonShop

	if commonShop.tabMainIndex == 1 then
		local function wrap_cb(res)
			LoadingMgr.Hide(eLoadingType.Repeat)

			self.snsCoinProductList = nil
			self.packProductList = nil

			self:OnInitJPShopDataList()
		end

		LoadingMgr.Show(eLoadingType.Repeat)

		local tagIndex = self.commonShop.tagIndex

		if tagIndex == 1 then
			NetManager:RequestShopSnsCoin(wrap_cb)
		else
			NetManager:RequestShopSnsCoin(wrap_cb)
		end

		return true
	end

	return false
end

function JPShopManager:UpdateShop(vPBMessage)
	return
end

function JPShopManager:updateListShop()
	local commonShop = self.commonShop
	local tabMainIndex = self.commonShop.tabMainIndex

	if tabMainIndex == 1 then
		commonShop.tabMainType = self.commonShop.listAllIndex[tabMainIndex]
		commonShop.listShop = ShopManager.listAll[self.commonShop.tabMainType]
	elseif tabMainIndex == 2 then
		-- block empty
	end
end

function JPShopManager:RequestBuyMonthCard(infoProduct)
	local commonShop = self.commonShop

	print("in jpshopmanager")

	local endAt = 0
	local goods = commonShop.infoShop.listGood[1]

	if #goods.data.CombinationGoods > 0 then
		for i = 1, #commonShop.listShop do
			local combinationGoodsId = commonShop.listShop[i].listGood[1].id

			for j = 1, #goods.data.CombinationGoods do
				if combinationGoodsId == goods.data.CombinationGoods[j] then
					if endAt < commonShop.listShop[i].listGood[1].endAt then
						endAt = commonShop.listShop[i].listGood[1].endAt
					end

					break
				end
			end
		end
	else
		endAt = goods.endAt
	end

	local remainDays = math.modf((endAt - NetData:GetCurServerTime()) / (DateUtil.SecsPerDay * DateUtil.MillsPerSecond))

	if remainDays >= self.monthCardMaxDay then
		UIMgr.ShowMsg(_("PageShop_month_card_error_1"))
	else
		if not self.snsCoinProductList then
			self.commonShop:ShowProductError()

			return true
		end

		local goodsData = BaseDataUtil.GetContentVoFromGoodsData(commonShop.infoShop.listGood[1].id)[1]
		local product = self:GetProductFromShop(goodsData.product_id)

		BillingManager:CheckPayStateAndPurchase(goodsData.product_id, product.product.platformProductId, product.Price, protocol_pb.normal, commonShop:Instance())
	end

	return true
end
