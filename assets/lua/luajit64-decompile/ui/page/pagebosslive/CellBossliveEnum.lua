-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageBosslive/CellBossliveEnum.lua

require("UI/Item/UIItemBase")

CellBossliveEnum = class("CellBossliveEnum", UIItemBase)

function CellBossliveEnum:ctor(itemPrefabCache, parent)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellBossliveEnum:Create(vParam)
	CellBossliveEnum.base.Create(self, vParam)
end

function CellBossliveEnum:OnEnter()
	local g = self.UIRootObject

	self.bigbg = GOUtil.FindChildGameObject(g, "bigbg")
	self.smallbg = GOUtil.FindChildGameObject(g, "smallbg")
	self.upText1 = GOUtil.FindChildComponent(g, "bigbg/Text", "Text")
	self.upText2 = GOUtil.FindChildComponent(g, "smallbg/Text", "Text")
	self.bigImage = self:GetChildComponent("bigbg/Image", "RawImage")
	self.smallImage = self:GetChildComponent("smallbg/Image", "RawImage")
	self.lockbg = self:GetChildGameObject("lockbg")
	self.upText1.fontSize = 28
	self.upText2.fontSize = 28

	self:OnRegisterEvent()
end

function CellBossliveEnum:UpdateData(data, index, Index)
	SetActiveFunc(self.lockbg, not data.isUnLock)
	UIUtil.SetRawImageTexture(self.bigImage, data.info.data.BackIcon, self)
	UIUtil.SetRawImageTexture(self.smallImage, data.info.data.BackIcon, self)

	self.upText1.text = Lang(data.info.data.Name)
	self.upText2.text = Lang(data.info.data.Name)

	self:UpdateState(isUnLock, index)
end

function CellBossliveEnum:UpdateState(isUnLock, index)
	SetActiveFunc(self.bigbg, index == self.Index)
	SetActiveFunc(self.smallbg, index ~= self.Index)
end

function CellBossliveEnum:OnLeave()
	self:OnUnRegisterEvent()
	UnloadAllImageSprite(self)
end
