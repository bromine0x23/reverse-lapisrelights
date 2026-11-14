-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageShop/DlgShopChargeProductDetail.lua

DlgShopChargeProductDetail = class("DlgShopChargeProductDetail", UIPanel)

function DlgShopChargeProductDetail:ctor()
	self.UIPrefabPath = "UI/PageShop/DlgShopChargeProductDetail"
end

function DlgShopChargeProductDetail:PreLoad()
	return
end

function DlgShopChargeProductDetail:Purge()
	DlgShopChargeProductDetail.base.Purge(self)
end

function DlgShopChargeProductDetail:OnRegisterEvent()
	self:AddClick(self.ButtonExit, self.OnClickedButtonQuit, PATH_SFX_UI_CANCEL)
	self:AddClick(self.ButtonBuy, self.OnClickedButtonBuy)
end

function DlgShopChargeProductDetail:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonExit, self.OnClickedButtonQuit)
	self:RemoveClick(self.ButtonBuy, self.OnClickedButtonBuy)
end

function DlgShopChargeProductDetail:OnEnter(vParam)
	self.infoProduct = vParam
	self.ButtonExit = self:GetChildGameObject("Main/ButtonExit")
	self.ButtonBuy = self:GetChildGameObject("Main/ButtonBuy")

	local info = self.infoProduct

	self.Info1 = self:GetChildGameObject("Main/Panel/Info1")
	self.Info2 = self:GetChildGameObject("Main/Panel/Info2")
	self:GetChildComponent("Main/title/Text", "Text").text = _("PageShop_set_content")
	self:GetChildComponent("Main/ButtonBuy/Text", "Text").text = _("UI_Buy")
	self:GetChildComponent("Main/Panel/Scroll/Viewport/Content/ImageAd/TextRemain", "Text").text = string.format("%s: %d", _("PageShop_last_times"), vParam.product.shopBillingLimitedProductDetail.limitedRemainingAmount)
	self:GetChildComponent("Main/Panel/Scroll/Viewport/Content/Image/ProductName", "Text").text = BaseDataUtil.GetHistoryBalanceTitle(vParam.product.shopProductMasterId, vParam.product.billingProductType)
	self:GetChildComponent("Main/Panel/Scroll/Viewport/Content/Image/ProductBuyLimit", "Text").text = string.format(_("PageShop_set_limit"), vParam.product.shopBillingLimitedProductDetail.limitAmount)
	self:GetChildComponent("Main/Panel/Scroll/Viewport/Content/Info1/CostName", "Text").text = _("PageShop_set_price")
	self:GetChildComponent("Main/Panel/Scroll/Viewport/Content/Info1/CostNum", "Text").text = vParam.FormattedPrice
	self:GetChildComponent("Main/Panel/Scroll/Viewport/Content/Info1/EndDatetime", "Text").text = DateUtil.GetDateFormat(vParam.product.shopBillingLimitedProductDetail.saleEndAt) .. "  " .. _("PageShop_set_timeout")

	local descrip = BaseDataUtil.GetItemDescrption(vParam.product.shopProductMasterId, vParam.product.billingProductType)

	descrip = descrip .. "\n" .. BaseDataUtil.GetHistoryBalanceTitle(vParam.product.shopProductMasterId, vParam.product.billingProductType) .. _("PageShop_set_name_description1")

	local vos = BaseDataUtil.GetContentVo(vParam.product.shopProductMasterId, vParam.product.billingProductType)

	for k, v in pairs(vos) do
		local showName

		if v.asset == protocol_pb.P_DIAMOND then
			local itemVO = ItemManager:GetValueItem(502, v.num)

			showName = Lang(itemVO.data.Name)
		else
			showName = Lang(v.name)
		end

		descrip = descrip .. "\n" .. string.format(_("PageShop_set_itemlist_format"), showName, v.num, v.is_paid and "" or _("PageShop_set_name_description2"))
	end

	local info2 = self:GetChildGameObject("Main/Panel/Scroll/Viewport/Content/Info2")
	local desText = self:GetChildComponent("Main/Panel/Scroll/Viewport/Content/Info2/ProductDescription", "Text")

	desText.text = descrip

	GOUtil.SetRectTransformSizeDelta(info2, desText.preferredWidth, desText.preferredHeight)

	self.productID = vParam.product.shopProductMasterId
	self.platformId = vParam.product.platformProductId
	self.price = vParam.Price

	UIUtil.SetImageSprite(self:GetChildComponent("Main/Panel/Scroll/Viewport/Content/ImageAd", "Image"), BaseDataUtil.GetItemIcon(self.productID, vParam.product.billingProductType))
end

function DlgShopChargeProductDetail:OnClickedButtonQuit()
	self:Close()
end

function DlgShopChargeProductDetail:UpdateCell(item, index)
	return
end

function DlgShopChargeProductDetail:AddCellClick(item)
	return
end

function DlgShopChargeProductDetail:OnClickedButtonBuy()
	self:Close()
	BillingManager:CheckPayStateAndPurchase(self.productID, self.platformId, self.price, protocol_pb.pack, self.baseParent)
end
