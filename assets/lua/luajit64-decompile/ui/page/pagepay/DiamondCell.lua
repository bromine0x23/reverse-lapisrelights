-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePay/DiamondCell.lua

require("UI/Item/UIItemBase")
require("Util/BaseDataUtil")

DiamondCell = class("DiamondCell", UIItemBase)

function DiamondCell:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function DiamondCell:Create(vParam)
	DiamondCell.base.Create(self, vParam)
end

function DiamondCell:OnLeave()
	self:OnUnRegisterEvent()

	self.title_txt = nil
	self.num_txt = nil
	self.item_img = nil
	self.price_txt = nil
	self.btn_buy = nil
end

function DiamondCell:OnEnter()
	local g = self.UIRootObject

	self.title_txt = GOUtil.FindChildComponent(g, "bg/title/tit_txt", "Text")
	self.num_txt = GOUtil.FindChildComponent(g, "bg/title/num_txt", "Text")
	self.item_img = GOUtil.FindChildComponent(g, "bg/item", "Image")
	self.price_txt = GOUtil.FindChildComponent(g, "bg/price/text", "Text")
	self.btn_buy = GOUtil.FindChildComponent(g, "bg/btnbuy", "Button")

	self:OnRegisterEvent()
end

function DiamondCell:OnRegisterEvent()
	self:AddClick(self.btn_buy.gameObject, self.OnBuy)
end

function DiamondCell:OnUnRegisterEvent()
	self:RemoveClick(self.btn_buy.gameObject, self.OnBuy)
end

function DiamondCell:OnBuy()
	BillingManager:CheckPayStateAndPurchase(self.data.product.shopProductMasterId, self.data.product.platformProductId, self.data.Price, protocol_pb.normal)
end

function DiamondCell:UpdateData(info)
	self.data = info
	self.title_txt.text = BaseDataUtil.GetHistoryBalanceTitle(info.product.shopProductMasterId, info.product.billingProductType)
	self.num_txt.text = info.product.shopBillingProductContent.amount
	self.price_txt.text = info.FormattedPrice

	local icon_path = BaseDataUtil.GetItemIcon(info.product.shopProductMasterId, info.product.billingProductType)

	UIUtil.SetImageSprite(self.item_img, icon_path)
end
