-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageManual/CellPicTab.lua

require("UI/Item/UIItemBase")

CellPicTab = class("CellPicTab", UIItemBase)

function CellPicTab:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellPicTab:OnLeave()
	self:OnUnRegisterEvent()
end

function CellPicTab:OnEnter(vParam)
	local g = self.UIRootObject

	self.Button = GOUtil.FindChildGameObject(g, "Button")
	self.ImgBtn = GOUtil.FindChildComponent(g, "Button", "Image")
	self.ImgSelect = GOUtil.FindChildGameObject(g, "Select")
	self.TextBtn1 = GOUtil.FindChildComponent(g, "Name", "Text")
	self.TextBtn2 = GOUtil.FindChildComponent(g, "Select/Name", "Text")
	self.Icon1 = self:GetChildComponent("Icon", "Image")
	self.Icon2 = self:GetChildComponent("Select/Icon", "Image")
end

function CellPicTab:OnRegisterEvent()
	self:AddClick(self.Button, self.OnClicked)
end

function CellPicTab:OnUnRegisterEvent()
	self:RemoveClick(self.Button, self.OnClicked)
end

function CellPicTab:OnClicked()
	Event.Instance:Fire("ClickPoolTab", self.Index)
end

function CellPicTab:UpdateData(info, selectIndex, _type)
	if selectIndex == self.Index then
		self.ImgSelect.gameObject:SetActive(true)
	else
		self.ImgSelect.gameObject:SetActive(false)
	end

	SetActiveFunc(self.Icon1.gameObject, false)
	SetActiveFunc(self.Icon2.gameObject, false)

	self.TextBtn1.text = info.tabName
	self.TextBtn2.text = info.tabName
end

function CellPicTab:UpdateImage(info, selectIndex, dotActive)
	if selectIndex == self.Index then
		self.ImgSelect.gameObject:SetActive(true)
	else
		self.ImgSelect.gameObject:SetActive(false)
	end

	SetActiveFunc(self.TextBtn1.gameObject, false)
	SetActiveFunc(self.TextBtn2.gameObject, false)
	UIUtil.SetImageSprite(self.Icon1, info.Path .. "b", self, true)
	UIUtil.SetImageSprite(self.Icon2, info.Path, self, true)
end

function CellPicTab:SetDot(path)
	RedDotSystemMgr.SetUIRedDot(self.UIRootObject, path)
end
