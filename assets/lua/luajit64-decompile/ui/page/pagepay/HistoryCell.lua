-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePay/HistoryCell.lua

require("UI/Item/UIItemBase")
require("Util/BaseDataUtil")

HistoryCell = class("HistoryCell", UIItemBase)

function HistoryCell:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function HistoryCell:Create(vParam)
	CellMail.base.Create(self, vParam)
end

function HistoryCell:OnEnter()
	local g = self.UIRootObject

	self.bgs = self:GetChildGameObject("img1")
	self.bgd = self:GetChildGameObject("img2")
	self.TxtName = GOUtil.FindChildComponent(g, "txt_title", "Text")
	self.TxtSource = GOUtil.FindChildComponent(g, "txt_date", "Text")
end

function HistoryCell:UpdateData(data, idex, tabIdx)
	self.bgs:SetActive(false)
	self.bgd:SetActive(false)

	if idex % 2 == 0 then
		self.bgs:SetActive(true)
	else
		self.bgd:SetActive(true)
	end

	if tabIdx == 1 then
		self.TxtName.text = data.name
		self.TxtSource.text = data.amount
	elseif tabIdx == 2 then
		self.TxtName.text = BaseDataUtil.GetHistoryDeposit(data.shopProductId, data.billingProductType, data.price)
		self.TxtSource.text = DateUtil.GetDateFormat(data.executed_at)
	else
		self.TxtName.text = BaseDataUtil.GetHistoryConsume(data)
		self.TxtSource.text = DateUtil.GetDateFormat(data.executed_at)
	end
end
