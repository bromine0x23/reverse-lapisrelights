-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageShop/DlgShopProductDetailJP.lua

local billingProductAssetInfo = require("luaData/m_billing_product_asset")

require("Util/BaseDataUtil")

DlgShopProductDetailJP = class("DlgShopProductDetailJP", UIPanel)

function DlgShopProductDetailJP:ctor()
	self.UIPrefabPath = "UI/PageShop/DlgShopProductDetailJP"
end

function DlgShopProductDetailJP:PreLoad()
	return
end

function DlgShopProductDetailJP:Purge()
	DlgShopProductDetailJP.base.Purge(self)
end

function DlgShopProductDetailJP:OnRegisterEvent()
	self:AddClick(self.ButtonExit, self.OnClickedButtonQuit, PATH_SFX_UI_CANCEL)
	self:AddClick(self.ButtonBuy, self.OnClickedButtonBuy)
end

function DlgShopProductDetailJP:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonExit, self.OnClickedButtonQuit)
	self:RemoveClick(self.ButtonBuy, self.OnClickedButtonBuy)
end

function DlgShopProductDetailJP:OnEnter(vParam)
	self.cb = vParam.cb
	self.infoProduct = vParam
	self.ButtonExit = self:GetChildGameObject("Main/ButtonExit")
	self.ButtonBuy = self:GetChildGameObject("Main/Button")
	self.ImgBuy = self:GetChildComponent("Main/Button", "Image")
	self.TextName = self:GetChildComponent("Main/bg_title/Text", "Text")
	self:GetChildComponent("Main/bg_title/Text (1)", "Text").text = _("Desc_GoodsInfo")
	self:GetChildComponent("Main/Button/Text", "Text").text = _("UI_Buy")

	local info = self.infoProduct

	self.Icon = self:GetChildComponent("Main/Panel/Icon", "Image")

	UIUtil.SetImageOverrideSprite(self.Icon, BaseDataUtil.GetItemIcon(info.product.shopProductMasterId, info.product.billingProductType), self)

	self.ImageNum = self:GetChildGameObject("Main/ImageNum")
	self.TextGoodNum = self:GetChildComponent("Main/ImageNum/TextNum", "Text")

	local Text1 = self:GetChildComponent("Main/Panel/Text1", "Text")
	local Text2 = self:GetChildComponent("Main/Panel/Text2", "Text")
	local vos = BaseDataUtil.GetContentVo(info.product.shopProductMasterId, info.product.billingProductType)
	local count = 0

	for k, v in pairs(vos) do
		if v.is_paid then
			count = count + v.num
		end
	end

	self.TextGoodNum.text = "x" .. count
	Text1.text = string.format(_("PageShop_billing_itemlist_format"), count)
	Text2.text = BaseDataUtil.GetItemDescrption(info.product.shopProductMasterId, info.product.billingProductType)
	self.TextName.text = Text1.text
	self.TextCost = self:GetChildComponent("Main/TextCost", "Text")
	self.ImageCost = self:GetChildComponent("Main/TextCost/ImageIcon", "Image")
	self.TextCostNoImg = self:GetChildComponent("Main/TextCost2", "Text")
	self.GoDisCost = self:GetChildGameObject("Main/DisCost")
	self.TextCost1 = self:GetChildComponent("Main/DisCost/TextCost1", "Text")
	self.ImgCost1 = self:GetChildComponent("Main/DisCost/TextCost1/ImageIcon", "Image")
	self.ImgCost2 = self:GetChildComponent("Main/DisCost/TextCost1/ImageIcon2", "Image")
	self.bg_Cost = self:GetChildGameObject("Main/bg_Cost")
	self.TextCostNoImg.text = info.FormattedPrice

	local Text = self:GetChildComponent("Main/Button/Text", "Text")

	Text.text = "購入"
end

function DlgShopProductDetailJP:OnClickedButtonQuit()
	self:Close()
end

function DlgShopProductDetailJP:OnClickedButtonBuy()
	if self.fobiden then
		return
	end

	self.fobiden = true

	if self.cb then
		self.cb()
	end

	self:Close()
end
