-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageShop/CellChargeDiamond.lua

require("UI/Item/UIItemBase")

local billingContentInfo = require("luaData/m_billing_product_content")
local listLimitedProducts = require("luaData/m_billing_limited_product")
local productInAppStore

if Application.platform:ToInt() == RuntimePlatform.Android then
	productInAppStore = require("luaData/m_billing_apple_product")
else
	productInAppStore = require("luaData/m_billing_google_product")
end

CellChargeDiamond = class("CellChargeDiamond", UIItemBase)

function CellChargeDiamond:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellChargeDiamond:OnEnter(vParam)
	local g = self.UIRootObject

	self.ImageF1 = GOUtil.FindChildGameObject(g, "ImageF1")
	self.ImageF2 = GOUtil.FindChildGameObject(g, "ImageF2")
	self.Icon = GOUtil.FindChildComponent(g, "Icon", "Image")
	self.ImgSign = GOUtil.FindChildGameObject(g, "Sign")
	self.TextSign = GOUtil.FindChildComponent(g, "Sign/Text", "Text")
	self.TextNumImage = GOUtil.FindChildGameObject(g, "Image")
	self.TextNum = GOUtil.FindChildComponent(g, "Image/TextNum", "Text")
	self.TextName = GOUtil.FindChildComponent(g, "TextName", "Text")
	self.TextCost = GOUtil.FindChildComponent(g, "TextCost", "Text")
	self.ImageCost = GOUtil.FindChildComponent(g, "TextCost/ImageIcon", "Image")
	self.ImgDownTime = GOUtil.FindChildGameObject(g, "ImgDownTime")
	self.TextDownTime = GOUtil.FindChildComponent(g, "ImgDownTime/TextDownTime", "Text")
	self.GoTimeLimit = GOUtil.FindChildGameObject(g, "ImageLimit")
	self.TextLimit = GOUtil.FindChildComponent(g, "ImageLimit/TextLimit", "Text")
	self.GoDisCost = GOUtil.FindChildGameObject(g, "DisCost")
	self.TextCost1 = GOUtil.FindChildComponent(g, "DisCost/TextCost1", "Text")
	self.ImgCost1 = GOUtil.FindChildComponent(g, "DisCost/TextCost1/ImageIcon", "Image")
	self.TextCost2 = GOUtil.FindChildComponent(g, "DisCost/TextCost", "Text")
	self.GoLock = GOUtil.FindChildGameObject(g, "ImageLock")
	self.GoSign2 = GOUtil.FindChildGameObject(g, "ImageLock/Sign2")
	self.TextSign2 = GOUtil.FindChildComponent(g, "ImageLock/Sign2/Text", "Text")
	self.GoNew = GOUtil.FindChildGameObject(g, "ImageNew")

	for i = 1, 4 do
		self["GoBase" .. i] = GOUtil.FindChildGameObject(g, "base/" .. i)
	end
end

function CellChargeDiamond:UpdateBase(index)
	for i = 1, 4 do
		if self["GoBase" .. i] then
			self["GoBase" .. i]:SetActive(false)
		end
	end

	local i = math.fmod(index, 4)

	if i == 0 then
		i = 4
	end

	if self["GoBase" .. i] then
		self["GoBase" .. i]:SetActive(true)
	end
end

function CellChargeDiamond:UpdateData(info)
	self.data = info

	if not info then
		return
	end

	UIUtil.SetImageOverrideSprite(self.Icon, BaseDataUtil.GetItemIcon(info.product.shopProductMasterId, info.product.billingProductType))
	self.ImgSign:SetActive(false)
	self.TextSign.gameObject:SetActive(false)

	local vos = BaseDataUtil.GetContentVo(info.product.shopProductMasterId, info.product.billingProductType)

	self.TextName.text = _("PageShop_coin_name")

	local count = 0

	for k, v in pairs(vos) do
		if v.is_paid then
			count = count + v.num
		end
	end

	self.TextNum.text = ""

	self.TextNum.gameObject:SetActive(false)

	local product = info.product
	local isLimitedAmount = false

	for k, v in pairs(listLimitedProducts) do
		if product.shopProductMasterId == v.product_id and v.product_type == "normal" and v.limited_amount > 0 then
			isLimitedAmount = true

			break
		end
	end

	local idToSeek = tonumber(product.shopProductMasterId)

	if product.shopBillingLimitedProductDetail.freeTypeLimitedRemain ~= 0 or not isLimitedAmount then
		for k, v in pairs(billingContentInfo) do
			if v.product_id == idToSeek and v.is_paid ~= "TRUE" then
				self.TextNum.gameObject:SetActive(true)

				self.TextNum.text = string.format(_("PageShop_billing_free_format"), v.amount)

				break
			end
		end
	end

	self.TextName.text = string.format(_("PageShop_billing_itemlist_format"), count)
	self.TextCost.text = info.FormattedPrice

	self.ImgSign.gameObject:SetActive(false)
	self.GoTimeLimit.gameObject:SetActive(false)
	CellChargeDiamond.SetLimitBuyTime(self.GoTimeLimit, info)
	self:SetDownTime(info)

	for k, v in pairs(productInAppStore) do
		if v.product_id == idToSeek and v.product_type == "normal" and v.yen_price < v.org_yen_price then
			self.ImgSign:SetActive(true)
			self.TextSign.gameObject:SetActive(true)

			self.TextSign.text = string.format("%.0f", (v.org_yen_price - v.yen_price) * 100 / v.org_yen_price)
		end
	end

	self.GoLock:SetActive(false)
end

function CellChargeDiamond.SetLock(gLock, info)
	local a = table.maxn(info.product.shopBillingLimitedProductDetail)
	local isLock = false

	if a == 0 then
		isLock = true

		local GoSign2 = GOUtil.FindChildGameObject(gLock, "Sign2")

		GoSign2:SetActive(false)
	end

	gLock:SetActive(isLock)
end

local curCount, maxCount

function CellChargeDiamond.SetLimitBuyTime(gTxt, info)
	local limitInfo = info.product.shopBillingLimitedProductDetail

	if limitInfo.limitAmount ~= nil and limitInfo.limitAmount > 0 then
		local limitBuyTime = limitInfo.limitAmount
		local limitedRemainingAmount = limitInfo.limitedRemainingAmount

		gTxt.gameObject:SetActive(true)

		local TextLimit = GOUtil.FindChildComponent(gTxt.gameObject, "TextLimit", "Text")
		local str = _("Shop_limit_day")

		if info.data.StoreType == 0 then
			str = limitInfo.billingSaleType == "weekly_limit" and _("PageShop_purchase_onetime_weekly") or limitInfo.billingSaleType == "monthly_limit" and _("PageShop_purchase_onetime_daily") or _("PageShop_purchase_onetime_only")
		elseif info.data.StoreType == 2 then
			str = _("Shop_limit_week")
		elseif info.data.StoreType == 3 then
			str = _("Shop_limit_month")
		end

		TextLimit.text = str .. "\n" .. limitedRemainingAmount .. "/" .. limitBuyTime
	else
		gTxt.gameObject:SetActive(false)
	end
end

function CellChargeDiamond:SetDownTime(info)
	local limitInfo = info.product.shopBillingLimitedProductDetail

	if limitInfo.billingSaleType ~= nil and string.len(limitInfo.billingSaleType) > 0 or not limitInfo.saleEndAt or limitInfo.saleEndAt == 0 then
		self.ImgDownTime:SetActive(false)
		self.TextDownTime.gameObject:SetActive(false)
	else
		self.ImgDownTime:SetActive(true)
		self.TextDownTime.gameObject:SetActive(true)

		self.TextDownTime.text = string.format(_("PageShop_billing_time_limit"), DateUtil.GetTwoMomentByMillis(tonumber(limitInfo.saleEndAt)))
	end
end
