-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCardShop/CellChooseTab.lua

require("UI/Item/UIItemBase")

CellChooseTab = class("CellChooseTab", UIItemBase)

function CellChooseTab:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellChooseTab:Purge()
	return
end

function CellChooseTab:OnEnter(vParam)
	local g = self.UIRootObject

	self.Select = self:GetChildGameObject("Select")
	self.Icon = self:GetChildComponent("Bg/Icon", "Image")
	self.Bg = self:GetChildComponent("Bg", "Image")
end

function CellChooseTab:UpdateData(info, isSelect)
	self.info = info

	GOUtil.SetTransformLocalScale(self.Bg.gameObject, isSelect and 1 or 0.9)

	self.Bg.color = Color.New(1, 1, 1, isSelect and 1 or 0.7)
	self.Icon.color = Color.New(1, 1, 1, isSelect and 1 or 0.7)

	UIUtil.SetImageSprite(self.Icon, info.data.StepUpBoard[1], self.page)
	GOUtil.SetTransformLocalScale(self.Icon.gameObject, info.data.StepUpBoard[3])
end

function CellChooseTab:UpdateSelect(isSelect)
	GOUtil.SetTransformLocalScale(self.Bg.gameObject, isSelect and 1 or 0.9)
end
