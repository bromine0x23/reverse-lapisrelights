-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCommunication/CellTopic.lua

require("UI/Item/UIItemBase")

CellTopic = class("CellTopic", UIItemBase)

function CellTopic:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellTopic:OnEnter(vParam)
	local g = self.UIRootObject

	self.Text = GOUtil.FindChildComponent(g, "Text", "Text")
	self.Image = GOUtil.FindChildComponent(g, "Image", "Image")

	self:AddClick(g, self.OnClicked)
end

function CellTopic:OnLeave()
	self:RemoveClick(g, self.OnClicked)
end

function CellTopic:OnClicked()
	SceneCommunication.Instance:LoadStory(self.infoTopic.id)
end

function CellTopic:UpdateData(infoTopic)
	self.infoTopic = infoTopic
	self.Text.text = Lang(infoTopic.data.Name)
end
