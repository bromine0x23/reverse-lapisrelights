-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageClassroom/UIBoardAlbum.lua

require("Util/Container")

UIBoardAlbum = class("UIBoardAlbum")

function UIBoardAlbum:OnLeave()
	self.page = nil
end

function UIBoardAlbum:Purge()
	self:OnLeave()
end

function UIBoardAlbum:Init(gPanel, page, startIndex, listAd)
	self.AdXPos = {
		0,
		480
	}
	self.page = page

	local count = self.page.adCount

	self.UISelector = GOUtil.AddComponent(gPanel, "UISelectorSpecialEdition")
	self.UISelector.selectedIdx = Mathf.Floor(count / 2)
	self.UISelector.isLerp = true

	if count > 2 then
		self.UISelector.isScale = true
	end

	local curAdIndex = startIndex
	local off = count - self.UISelector.selectedIdx + curAdIndex

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

	function self.UISelector.onChanged(go)
		self:OnSelectorChanged(go)
	end

	local temp = {}

	for i = 0, count - 1 do
		local go = listAd[i + 1]
		local sign = 1

		if i < self.UISelector.selectedIdx then
			sign = -1
		end

		local xPos
		local posIdx = Mathf.Abs(self.UISelector.selectedIdx - i) + 1
		local configNum = #self.AdXPos

		if configNum < posIdx then
			xPos = self.AdXPos[configNum] * sign
		else
			xPos = self.AdXPos[posIdx] * sign
		end

		GOUtil.SetRectTransformAnchoredPosition(go, xPos, 0)

		local uiSelectObj = GOUtil.AddComponent(go, "UISelectorObject")

		uiSelectObj.Alpha = 1

		uiSelectObj:SetAngleY(0)
		table.insert(temp, uiSelectObj)
	end

	self.UISelector:SetObjects(temp)

	self.curAdIdx = self.UISelector.selectedIdx

	if self.page then
		self.page:UpdateAdBoard(self:GetIndex(self.curAdIdx))
	end
end

function UIBoardAlbum:GetIndex(index)
	return self.listIndex[index + 1]
end

function UIBoardAlbum:OnSelectorChanged(go)
	if go == nil then
		return
	end

	if self.curAdIdx == self.UISelector.Selected.Index then
		return
	end

	self.curAdIdx = self.UISelector.Selected.Index

	if self.page then
		self.page:UpdateAdBoard(self:GetIndex(self.curAdIdx))
	end
end
