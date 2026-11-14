-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageChapter/CellSweep.lua

require("UI/Item/UIItemBase")

CellSweep = class("CellSweep", UIItemBase)

function CellSweep:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellSweep:Create(vParam)
	CellSweep.base.Create(self, vParam)
end

function CellSweep:OnEnter()
	local g = self.UIRootObject

	self.TextTitle = GOUtil.FindChildComponent(g, "Title/Text", "Text")
	self.TextExp = GOUtil.FindChildComponent(g, "GoExp/Text", "Text")

	local Text = GOUtil.FindChildComponent(g, "Text", "Text")

	Text.text = Lang(9009)
end

function CellSweep:OnLeave()
	self.TextTitle = nil

	for i = 1, #self.listCellItem do
		self.listCellItem[i]:OnLeave()
	end
end

function CellSweep:UpdateData(data)
	local g = self.UIRootObject

	self.TextTitle.text = string.format(_("Sweep_award"), data.index)

	local infoStage = data.infoStage
	local rewardCnt = #infoStage.data.ItemList

	self.TextExp.text = 0

	local listItem = data.listItem
	local listHigh = data.listHigh
	local listExtraItem = data.listExtraItem
	local listActiveAward = data.listActiveAward
	local ScrollArea = GOUtil.FindChildGameObject(g, "ScrollArea")
	local ScrollView = GOUtil.AddMissingComponent(ScrollArea, "UIScrollView")

	ScrollView.horizontal = true
	ScrollView.content = GOUtil.FindChildComponent(g, "ScrollArea/Content", "Transform")
	self.listCellItem = {}

	for i = 1, #listItem do
		local s = listItem[i]

		if s.id == 504 then
			self.TextExp.text = s.num
		else
			local infoItem = SetterData.GetItemFromAsset(s)

			if infoItem ~= nil then
				local item = CellItem(data.PrefabCellItem, ScrollView.content.gameObject, self)

				item:Create()
				item:UpdateData(data.index + i, infoItem)

				local scrollViewContent = GOUtil.AddMissingComponent(item.UIRootObject, "UIScrollViewContent")

				scrollViewContent.scrollView = ScrollView

				table.insert(self.listCellItem, item)
			end
		end
	end

	for i = 1, #listHigh do
		local s = listHigh[i]

		if s.id == 504 then
			self.TextExp.text = s.num
		else
			local infoItem = SetterData.GetItemFromAsset(s)

			if infoItem ~= nil then
				local item = CellItem(data.PrefabCellItem, ScrollView.content.gameObject, self)

				item:Create()
				item:SetHigh(true)
				item:UpdateData(data.index + i, infoItem)

				local scrollViewContent = GOUtil.AddMissingComponent(item.UIRootObject, "UIScrollViewContent")

				scrollViewContent.scrollView = ScrollView

				table.insert(self.listCellItem, item)
			end
		end
	end

	for i = 1, #listExtraItem do
		local s = listExtraItem[i]

		if s.id == 504 then
			self.TextExp.text = s.num
		else
			local infoItem = SetterData.GetItemFromAsset(s)

			if infoItem ~= nil then
				local item = CellItem(data.PrefabCellItem, ScrollView.content.gameObject, self)

				item:Create()
				item:UpdateData(data.index + i, infoItem)
				item:SetExtra(true)

				local scrollViewContent = GOUtil.AddMissingComponent(item.UIRootObject, "UIScrollViewContent")

				scrollViewContent.scrollView = ScrollView

				table.insert(self.listCellItem, item)
			end
		end
	end

	for i = 1, #listActiveAward do
		local s = listActiveAward[i]

		if s.id == 504 then
			self.TextExp.text = s.num
		else
			local infoItem = SetterData.GetItemFromAsset(s)

			if infoItem ~= nil then
				local item = CellItem(data.PrefabCellItem, ScrollView.content.gameObject, self)

				item:Create()
				item:UpdateData(data.index + i, infoItem)
				item:SetActiveAward(true)

				local scrollViewContent = GOUtil.AddMissingComponent(item.UIRootObject, "UIScrollViewContent")

				scrollViewContent.scrollView = ScrollView

				table.insert(self.listCellItem, item)
			end
		end
	end
end
