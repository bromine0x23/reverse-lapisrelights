-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePay/GiftCell.lua

require("UI/Item/UIItemBase")
require("UI/Page/PagePay/PageGiftDetail")
require("Util/BaseDataUtil")

GiftCell = class("GiftCell", UIItemBase)

function GiftCell:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function GiftCell:Create(vParam)
	GiftCell.base.Create(self, vParam)
end

function GiftCell:OnLeave()
	print("on leave")
	self:OnUnRegisterEvent()

	self.content = nil
	self.imgBtn = nil
	self.img = nil
end

function GiftCell:OnEnter()
	local g = self.UIRootObject

	self.imgBtn = self:GetChildGameObject("content")
	self.img = GOUtil.FindChildComponent(g, "content", "Image")
	self.content = GOUtil.FindChildComponent(g, "content/Image/Text", "Text")

	self:OnRegisterEvent()
end

function GiftCell:OnRegisterEvent()
	self:AddClick(self.imgBtn, self.OnBuy)
end

function GiftCell:OnUnRegisterEvent()
	self:RemoveClick(self.imgBtn, self.OnBuy)
end

function GiftCell:OnBuy()
	UIMgr.AddPanel(PageGiftDetail(), self.data)
end

function GiftCell:UpdateData(info)
	self.data = info
	self.content.text = info.product.shopBillingLimitedProductDetail.limitedRemainingAmount

	UIUtil.SetImageSprite(self.img, BaseDataUtil.GetItemIcon(info.product.shopProductMasterId, info.product.billingProductType))
end
