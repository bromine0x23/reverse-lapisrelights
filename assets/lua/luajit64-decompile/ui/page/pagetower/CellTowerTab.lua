-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTower/CellTowerTab.lua

require("UI/Item/UIItemBase")

CellTowerTab = class("CellTowerTab", UIItemBase)

function CellTowerTab:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellTowerTab:OnLeave()
	self:OnUnRegisterEvent()
end

function CellTowerTab:OnEnter(vParam)
	local g = self.UIRootObject

	self.Button = GOUtil.FindChildGameObject(g, "Button")
	self.ImgBtn = GOUtil.FindChildComponent(g, "Button", "Image")
	self.ImgSelect = GOUtil.FindChildGameObject(g, "Select")
	self.Dot = GOUtil.FindChildGameObject(g, "PDot")
	self.Lock = GOUtil.FindChildGameObject(g, "Lock")
	self.TextBtn1 = GOUtil.FindChildComponent(g, "Name", "Text")
	self.TextBtn2 = GOUtil.FindChildComponent(g, "Select/Name", "Text")
end

function CellTowerTab:OnRegisterEvent()
	self:AddClick(self.Button, self.OnClicked)
end

function CellTowerTab:OnUnRegisterEvent()
	self:RemoveClick(self.Button, self.OnClicked)
end

function CellTowerTab:OnClicked()
	Event.Instance:Fire("ClickPoolTab", self.Index)
end

function CellTowerTab:UpdateData(info, selectIndex)
	if selectIndex == self.Index then
		SetActiveFunc(self.ImgSelect.gameObject, true)
	else
		SetActiveFunc(self.ImgSelect.gameObject, false)
	end

	self.TextBtn1.text = info.tabName
	self.TextBtn2.text = info.tabName

	SetActiveFunc(self.Lock, not info.unlock)
end
