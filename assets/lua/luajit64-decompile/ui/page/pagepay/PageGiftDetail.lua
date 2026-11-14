-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePay/PageGiftDetail.lua

PageGiftDetail = class("PageGiftDeatil", UIPanel)

require("Util/BaseDataUtil")

function PageGiftDetail:ctor()
	PageGiftDetail.base.ctor(self, "UI/PanelPay/PanelGiftDetail")
end

function PageGiftDetail:Purge()
	PageGiftDetail.base.Purge(self)
	self:OnLeave()
end

function PageGiftDetail:OnLeave()
	self.BtnAsc = nil
	self.BtnDesc = nil
	self.BtnClose = nil
	self.BtnFilter = nil
	self.TxtFilter = nil
	self.BtnRece = nil
	self.listMail = nil
	self.listState = nil
end

function PageGiftDetail:OnRegisterEvent()
	self:AddClick(self.btnClose, self.Close)
	self:AddClick(self.btnBuy, self.OnBuy)
	Event.Instance:Add(BillingManager.OnPaySuceed, self.OnPurchased, self)
end

function PageGiftDetail:OnUnRegisterEvent()
	self:RemoveClick(self.btnClose, self.Close)
	self:RemoveClick(self.btnBuy, self.OnBuy)
	Event.Instance:Remove(BillingManager.OnPaySuceed, self.OnPurchased, self)
end

function PageGiftDetail:OnPurchased(item)
	self:Close()
end

function PageGiftDetail:OnBuy()
	BillingManager:CheckPayStateAndPurchase(self.productID, self.platformId, self.price, protocol_pb.pack, self.baseParent)
end

function PageGiftDetail:OnEnter(vParam)
	self.btnClose = self:GetChildGameObject("Panel/bottom/cancel")
	self.btnBuy = self:GetChildGameObject("Panel/bottom/sure")
	self.show_img = self:GetChildComponent("Panel/show_img", "Image")

	local title_txt = BaseDataUtil.GetHistoryBalanceTitle(vParam.product.shopProductMasterId, vParam.product.billingProductType)

	self:GetChildComponent("Panel/title/text", "Text").text = title_txt
	self:GetChildComponent("Panel/desc/txt_time", "Text").text = DateUtil.GetDateFormat(vParam.product.shopBillingLimitedProductDetail.saleEndAt)
	self:GetChildComponent("Panel/desc/txt_price", "Text").text = vParam.FormattedPrice
	self:GetChildComponent("Panel/desc/txt_tips", "Text").text = "tips"
	self:GetChildComponent("Panel/txt_desc1", "Text").text = BaseDataUtil.GetItemDescrption(vParam.product.shopProductMasterId, vParam.product.billingProductType)

	local descrip = title_txt .. _("PageShop_set_name_description1")
	local vos = BaseDataUtil.GetContentVo(vParam.product.shopProductMasterId, vParam.product.billingProductType)

	for k, v in pairs(vos) do
		local showName

		if v.asset == protocol_pb.P_DIAMOND then
			local itemVO = ItemManager:GetValueItem(502, v.num)

			showName = Lang(itemVO.data.Name)
		else
			showName = Lang(v.name)
		end

		descrip = descrip .. "\n" .. (v.is_paid and _("PageShop_set_name_description2") or "") .. showName .. v.num .. "個"
	end

	self:GetChildComponent("Panel/txt_desc2", "Text").text = descrip
	self.productID = vParam.product.shopProductMasterId
	self.platformId = vParam.product.platformProductId
	self.price = vParam.Price

	print("detail")
	print(vParam.FormattedPrice)
	print(vParam.Price)
	UIUtil.SetImageSprite(self.show_img, BaseDataUtil.GetItemIcon(self.productID, vParam.product.billingProductType))
end
