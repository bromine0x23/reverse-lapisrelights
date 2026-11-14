-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageBag/CellBagItem.lua

require("UI/Item/UIItemBase")

CellBagItem = class("CellBagItem", UIItemBase)

function CellBagItem:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellBagItem:OnEnter(vParam)
	local g = self.UIRootObject
	local gItem = GOUtil.FindChildGameObject(g, "CellItem")

	self.CellItem = CellItem(gItem)

	self.CellItem:InitItemByRoot(gItem)

	self.TxtItemName = GOUtil.FindChildComponent(g, "TxtName", "Text")
	self.TxtFull = GOUtil.FindChildComponent(g, "TxtFull", "Text")
	self.TxtFull.text = "満"
	self.GoImgDot = GOUtil.FindChildGameObject(g, "ImgDot")
	self.GoImgLimit = GOUtil.FindChildGameObject(g, "ImgLimit")
	self.GoClick = GOUtil.FindChildGameObject(g, "GoClick")
end

function CellBagItem:OnLeave()
	if self.CellItem.OnLeave ~= nil then
		self.CellItem:OnLeave()
	end
end

function CellBagItem:UpdateData(infoItem)
	self.info = infoItem

	self.CellItem:UpdateWithName(infoItem)

	self.TxtItemName.text = infoItem:GetNameAndDesc()

	local isLimit = infoItem.clearTime ~= 0

	SetActiveFunc(self.GoImgLimit, isLimit)

	local isFull = infoItem:GetCurResNum() >= infoItem.data.MaxNum and infoItem.data.MaxNum ~= 0

	SetActiveFunc(self.TxtFull.gameObject, isFull)

	self.CellItem.ItemCount.color = Color.New(0.10588235294117647, 0.4588235294117647, 0.5568627450980392, 1)

	if isFull then
		self.CellItem.ItemCount.color = Color.New(0.9725490196078431, 0.3176470588235294, 0.3137254901960784, 1)
	end

	self:UpdateDot()
end

function CellBagItem:UpdateDot()
	SetActiveFunc(self.GoImgDot, BagRDL.IsExist(self.info.id))
end
