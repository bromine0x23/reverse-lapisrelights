-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageInteraction/CellFavor.lua

require("UI/Item/UIItemBase")

CellFavor = class("CellFavor", UIItemBase)

function CellFavor:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellFavor:Create(vParam)
	CellFavor.base.Create(self, vParam)
end

function CellFavor:OnEnter()
	local g = self.UIRootObject

	self.TextScoreTo = GOUtil.FindChildComponent(g, "TextScoreTo", "Text")
	self.TextCondition = GOUtil.FindChildComponent(g, "TextCondition", "Text")
	self.TextFavor = GOUtil.FindChildComponent(g, "TextFavor", "Text")
	self.ImageIcon = GOUtil.FindChildComponent(g, "bg_heart", "Image")
end

function CellFavor:OnLeave()
	self.TextScoreTo = nil
	self.TextCondition = nil
	self.TextFavor = nil
end

function CellFavor:UpdateData(needLv, name, strPath)
	self.TextFavor.text = name
	self.TextCondition.text = _("PageInteraction_SectionNeed") .. " <color=#FFA836>" .. needLv .. "</color>"

	UIUtil.SetImageSprite(self.ImageIcon, strPath)
end
