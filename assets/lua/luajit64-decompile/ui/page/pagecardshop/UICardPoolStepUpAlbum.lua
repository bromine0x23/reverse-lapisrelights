-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCardShop/UICardPoolStepUpAlbum.lua

require("Util/Container")

UICardPoolStepUpAlbum = class("UICardPoolStepUpAlbum")

function UICardPoolStepUpAlbum:OnLeave()
	self.page = nil
end

function UICardPoolStepUpAlbum:Purge()
	self:OnLeave()
end

function UICardPoolStepUpAlbum:Init(gPanel, listData, prefabCell, CellClass, prefabSubCell, stepUpOrder, stepUpTurn, page, startIndex)
	self.cardPoolPos = {
		0,
		1055,
		2110,
		3165
	}
	self.page = page
	self.listData = listData

	local count = #listData

	self.UISelector = GOUtil.AddComponent(gPanel, "UISelector")
	self.UISelector.selectedIdx = Mathf.Floor(count / 2)
	self.UISelector.isLerp = true
	self.UISelector.isScale = false
	self.UISelector.dragEnable = false

	local curPoolIndex = startIndex
	local off = count - self.UISelector.selectedIdx + curPoolIndex

	self.listIndex = {}

	for i = 1, count do
		local index = i + off

		if count < index then
			index = index % count
		end

		if index == 0 then
			index = count
		end

		table.insert(self.listIndex, index)
	end

	local function wrap_cb(go)
		self:OnSelectorChanged(go)
	end

	self.UISelector.onChanged = wrap_cb

	local uisos = {}

	self.cells = {}

	for i = 0, count - 1 do
		local item = CellClass(prefabCell, gPanel, self)

		item:Create()
		table.insert(self.cells, item)

		local sign = 1

		if i < self.UISelector.selectedIdx then
			sign = -1
		end

		local xPos
		local posIdx = Mathf.Abs(self.UISelector.selectedIdx - i) + 1
		local configNum = #self.cardPoolPos

		if configNum < posIdx then
			xPos = self.cardPoolPos[configNum] * sign
		else
			xPos = self.cardPoolPos[posIdx] * sign
		end

		GOUtil.SetRectTransformAnchoredPosition(item.UIRootObject, xPos, 0)

		if i > self.UISelector.selectedIdx then
			item.UIRootObject.transform:SetAsFirstSibling()
		end

		local uiSelectorObj = GOUtil.AddMissingComponent(item.UIRootObject, "UISelectorObject")

		item.uiSelectorObj = uiSelectorObj

		table.insert(uisos, uiSelectorObj)
		item:UpdateData(self.listData[self:GetIndex(i)], prefabSubCell, stepUpOrder, stepUpTurn)
	end

	self.UISelector:SetObjects(uisos)

	self.CurSelectedIdx = self.UISelector.selectedIdx

	self.page:UpdateStepUpArrow(self:GetIndex(self.CurSelectedIdx))
end

function UICardPoolStepUpAlbum:GetIndex(index)
	return self.listIndex[index + 1]
end

function UICardPoolStepUpAlbum:OnSelectorChanged(go)
	if go == nil then
		return
	end

	if self.CurSelectedIdx == self.UISelector.Selected.Index then
		return
	end

	self.CurSelectedIdx = self.UISelector.Selected.Index

	self.page:UpdateStepUpArrow(self:GetIndex(self.CurSelectedIdx))
end

function UICardPoolStepUpAlbum:Next()
	self.UISelector:NextIgnoreDragEnable()
end

function UICardPoolStepUpAlbum:Previous()
	self.UISelector:PreviousIgnoreDragEnable()
end
