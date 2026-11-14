-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCardShop/CellCardPool.lua

require("UI/Item/UIItemBase")

CellCardPool = class("CellCardPool", UIItemBase)

function CellCardPool:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellCardPool:OnEnter(vParam)
	local g = self.UIRootObject

	self.ImageIcon1 = GOUtil.FindChildComponent(g, "Image", "Image")
	self.ImageIcon2 = GOUtil.FindChildComponent(g, "Image/ImageMask", "Image")
	self.ImageMask = GOUtil.FindChildGameObject(g, "Image/ImageMask")
	self.objFree = GOUtil.FindChildGameObject(g, "free_tag")
	self.imgFree = GOUtil.FindChildComponent(g, "free_tag", "Image")
	self.TextLeft = GOUtil.FindChildComponent(g, "Image/count", "Text")

	local text = GOUtil.FindChildComponent(g, "Image/Text", "Text")

	text.text = Lang(5000009)
	self.GoSel = GOUtil.FindChildGameObject(g, "ImageSel")
end

function CellCardPool:UpdateData(infoCardPool, index)
	local isSelect = self.Index == index

	self.GoSel:SetActive(isSelect)
	UIUtil.SetImageOverrideSprite(self.ImageIcon1, infoCardPool.data.TipIcon, self.page)
	UIUtil.SetImageOverrideSprite(self.ImageIcon2, infoCardPool.data.TipIcon, self.page)

	local usedTime = infoCardPool.usedTime

	self.TextLeft.text = infoCardPool.data.DayMaxNum - usedTime

	self.ImageMask:SetActive(not isSelect)

	local isFreeDraw = PlayerInst.InfoPlayer:CanFreeDrawPool(infoCardPool.id)

	if isFreeDraw then
		UIUtil.SetImageSprite(self.imgFree, PlayerInst.InfoPlayer.freeDrawInfo.drawType == 0 and "UI/PageCardShop/AtlasCardShop/IC_free_jp_02" or "UI/PageCardShop/AtlasCardShop/IC_free_jp_03", self)
		self.imgFree:SetNativeSize()
	end

	self.objFree:SetActive(isFreeDraw)
end

function CellCardPool:UpdateDataSelect(index)
	local isSelect = self.Index == index

	self.ImageMask:SetActive(not isSelect)
end
