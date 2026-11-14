-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnion/CellUnionLog.lua

require("UI/Item/UIItemBase")

CellUnionLog = class("CellUnionLog", UIItemBase)

function CellUnionLog:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellUnionLog:OnEnter(vParam)
	local g = self.UIRootObject

	self.TxtInfo = GOUtil.FindChildComponent(g, "TxtInfo", "Text")
	self.TxtTime = GOUtil.FindChildComponent(g, "TxtTime", "Text")
	self.Animator = GOUtil.GetComponent(g, "Animator")
end

function CellUnionLog:UpdateData(infoLog)
	self.TxtInfo.text = infoLog.info
	self.TxtTime.text = infoLog.time
end
