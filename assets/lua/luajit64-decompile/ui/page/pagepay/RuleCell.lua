-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePay/RuleCell.lua

require("UI/Item/UIItemBase")

RuleCell = class("RuleCell", UIItemBase)

function RuleCell:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function RuleCell:Create(vParam)
	RuleCell.base.Create(self, vParam)
end

function RuleCell:OnEnter()
	local g = self.UIRootObject

	self.content = GOUtil.FindChildComponent(g, "text", "Text")
end

function RuleCell:UpdateData(info)
	self.content.text = info
end
