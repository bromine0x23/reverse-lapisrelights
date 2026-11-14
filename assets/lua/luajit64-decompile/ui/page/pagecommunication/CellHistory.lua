-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCommunication/CellHistory.lua

require("UI/Item/UIItemBase")

CellHistory = class("CellHistory", UIItemBase)

function CellHistory:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellHistory:OnEnter(vParam)
	local g = self.UIRootObject

	self.Text = GOUtil.FindChildComponent(g, "Text", "Text")
	self.Image = GOUtil.FindChildComponent(g, "Image", "Image")
end

function CellHistory:OnLeave()
	return
end

function CellHistory:OnClicked()
	return
end

function CellHistory:UpdateData(infoTopic)
	self.infoTopic = infoTopic
	self.Text.text = Lang(infoTopic.data.Name)
end
