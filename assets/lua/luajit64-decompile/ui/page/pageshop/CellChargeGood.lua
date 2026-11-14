-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageShop/CellChargeGood.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageShop/DlgShopChargeProductDetail")

CellChargeGood = class("CellChargeGood", UIItemBase)

function CellChargeGood:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.OwnerUI = ownerUI
end

function CellChargeGood:Create(vParam)
	CellChargeGood.base.Create(self, vParam)
end

function CellChargeGood:OnLeave()
	self:OnUnRegisterEvent()

	self.TextRemain = nil
	self.BackgroundImage = nil
end

function CellChargeGood:OnEnter()
	local g = self.UIRootObject

	self.imgBtn = self:GetChildGameObject("Image")
	self.TextRemain = GOUtil.FindChildComponent(g, "Image/TextRemain", "Text")
	self.BackgroundImage = GOUtil.FindChildComponent(g, "Image", "Image")

	self:OnRegisterEvent()
end

function CellChargeGood:UpdateData(info)
	self.data = info
	self.TextRemain.text = string.format("%s: %d", _("PageShop_last_times"), info.product.shopBillingLimitedProductDetail.limitedRemainingAmount)

	UIUtil.SetImageSprite(self.BackgroundImage, BaseDataUtil.GetItemIcon(info.product.shopProductMasterId, info.product.billingProductType))
end

function CellChargeGood:OnRegisterEvent()
	self:AddClick(self.imgBtn, self.OnBuy)
end

function CellChargeGood:OnUnRegisterEvent()
	self:RemoveClick(self.imgBtn, self.OnBuy)
end

function CellChargeGood:OnBuy()
	UIMgr.AddPanel(DlgShopChargeProductDetail(), self.data, PageShop:Instance())
end
