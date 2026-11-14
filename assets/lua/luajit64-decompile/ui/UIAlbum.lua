-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/UIAlbum.lua

require("Util/Container")

UIAlbum = class("UIAlbum")

function UIAlbum:OnLeave()
	self.page = nil
end

function UIAlbum:Purge()
	self:OnLeave()

	local list = self.IdxToThemeIcon:GetValues()

	for i = 1, #list do
		local item = list[i]

		item:OnLeave()
	end

	self.IdxToThemeIcon = nil
end

function UIAlbum:Init(gPanel, listData, prefabCell, CellClass, page, startIndex)
	self.ThemeIconScaleDecFactor = 0.05
	self.ThemeIconPos = {
		0,
		218,
		382,
		472
	}
	self.IdxToThemeIcon = Record()
	self.page = page

	local themeCount = #listData

	self.UISelector = GOUtil.AddComponent(gPanel, "UISelector")
	self.UISelector.selectedIdx = Mathf.Floor(themeCount / 2)

	local curThemeIdx = startIndex
	local off = themeCount - self.UISelector.selectedIdx + curThemeIdx

	self.listIndex = {}

	for i = 1, themeCount do
		local index = i + off

		if themeCount < index then
			index = index % themeCount
		end

		if index == 0 then
			index = themeCount
		end

		table.insert(self.listIndex, index)
	end

	local function wrap_cb(go)
		self:OnSelectorChanged(go)
	end

	self.UISelector.onChanged = wrap_cb

	local uisos = {}

	for i = 0, themeCount - 1 do
		local item = CellClass(prefabCell, gPanel, self)

		item:Create()

		local sign = 1

		if i < self.UISelector.selectedIdx then
			sign = -1
		end

		local xPos
		local posIdx = Mathf.Abs(self.UISelector.selectedIdx - i) + 1
		local configNum = #self.ThemeIconPos

		if configNum < posIdx then
			xPos = (self.ThemeIconPos[configNum] + (posIdx - configNum) * 90) * sign
		else
			xPos = self.ThemeIconPos[posIdx] * sign
		end

		GOUtil.SetRectTransformAnchoredPosition(item.UIRootObject, xPos, 0)

		if i > self.UISelector.selectedIdx then
			item.UIRootObject.transform:SetAsFirstSibling()
		end

		local uiSelectorObj = GOUtil.AddComponent(item.UIRootObject, "UISelectorObject")

		uiSelectorObj.Alpha = 1

		local offA = 20 + i

		if i < self.UISelector.selectedIdx then
			uiSelectorObj:SetAngleY(-offA)
		elseif i > self.UISelector.selectedIdx then
			uiSelectorObj:SetAngleY(offA)
		else
			uiSelectorObj:SetAngleY(0)
		end

		table.insert(uisos, uiSelectorObj)

		if i == self.UISelector.selectedIdx then
			uiSelectorObj:SetAlpha(1)

			uiSelectorObj.Scale = 1
		else
			uiSelectorObj.Scale = 0.8
		end

		self.page:UpdateCell(item, self:GetIndex(i), i == self.UISelector.selectedIdx)
		self.IdxToThemeIcon:Set(i, item)
	end

	self.UISelector:SetObjects(uisos)

	self.CurSelectedIdx = self.UISelector.selectedIdx

	self.page:UpdateInfo(self:GetIndex(self.CurSelectedIdx), true)
end

function UIAlbum:GetIndex(index)
	return self.listIndex[index + 1]
end

function UIAlbum:GetIdxToThemeIcon()
	return self.IdxToThemeIcon:GetValues()
end

function UIAlbum:OnSelectorChanged(go)
	if go == nil then
		return
	end

	if self.CurSelectedIdx == self.UISelector.Selected.Index then
		return
	end

	local item = self.IdxToThemeIcon:GetValue(self.CurSelectedIdx)

	if item ~= nil then
		self.page:UpdateCell(item, self:GetIndex(self.CurSelectedIdx), false)
	end

	self.CurSelectedIdx = self.UISelector.Selected.Index
	item = self.IdxToThemeIcon:GetValue(self.CurSelectedIdx)

	if item ~= nil then
		self.page:UpdateCell(item, self:GetIndex(self.CurSelectedIdx), true)
	end

	ThemeManager.SelectedID = self.listIndex[self.CurSelectedIdx + 1] - 1

	self.page:UpdateInfo(self:GetIndex(self.CurSelectedIdx), true)
end
