-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCardShop/CellStep.lua

require("UI/Item/UIItemBase")

CellStep = class("CellStep", UIItemBase)

function CellStep:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellStep:OnEnter(vParam)
	local g = self.UIRootObject

	self.ImageBg = self:GetChildComponent("", "Image")
	self.CellItemObj = self:GetChildGameObject("CellItem")
	self.TipImage = self:GetChildComponent("TipImage", "Image")
	self.DrawCard = self:GetChildComponent("DrawCard", "Image")
	self.Select = self:GetChildGameObject("Select")
	self.lock = self:GetChildGameObject("Unlock")
	self.Finish = self:GetChildGameObject("Finish")
	self.Tip = self:GetChildComponent("Tip", "Text")
	self.Count = self:GetChildComponent("Count", "Text")
end

function CellStep:UpdateData(info, stepUpOrder, index, lock)
	self.DrawCard.gameObject:SetActive(info.data.StepUpBoard[1] == 2)
	self.Select:SetActive(info.data.StepUpOrder == stepUpOrder)
	self.lock:SetActive(lock or stepUpOrder > info.data.StepUpOrder or info.needShow)
	self.Finish:SetActive(stepUpOrder > info.data.StepUpOrder or info.needShow)

	local pathStr = "UI/PageCardShop/AtlasStepUp/"

	UIUtil.SetImageSprite(self.ImageBg, pathStr .. info.data.StepUpBoard[2], self.page)

	self.Tip.text = Lang(info.data.StepUpBoard[3])
	self.Count.text = string.format(_("StepUp_count_" .. info.data.StepUpTurn), index)

	self.TipImage.gameObject:SetActive(info.data.StepUpBoard[1] == 1)
	self.CellItemObj:SetActive(info.data.StepUpBoard[1] == 3)
	self.Select:SetActive(info.data.StepUpOrder == stepUpOrder)

	if info.data.StepUpBoard[1] == 3 then
		self.CellItem = CellItem(self.CellItemObj)

		self.CellItem:InitItemByRoot(self.CellItemObj)

		local item = ItemManager.GetRewardPackItems(info.data.ExtraReward)[1]
		local infoItem = ItemManager:GetValueItem(item[1], item[2])

		self.CellItem:UpdateWithNumType(infoItem)
	elseif info.data.StepUpBoard[1] == 1 then
		UIUtil.SetImageSprite(self.TipImage, pathStr .. info.data.StepUpBoard[4], self.page)
	end
end

function CellStep:OnLeave()
	self.CellItem:OnLeave()

	self.CellItem = nil

	UnloadAllImageSprite(self)
end
