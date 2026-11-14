-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/UIScrollTool.lua

UIScrollTool = class("UIScrollTool")

function UIScrollTool:ctor()
	return
end

function UIScrollTool:InitList(ScrollArea, content, count, prefabCell, CellClass, page, ishorizontal, addCellCallback, updateCellCallback, initPos)
	self.page = page
	self.CellClass = CellClass
	self.ScrollArea = ScrollArea
	self.ScrollView = GOUtil.AddMissingComponent(self.ScrollArea, "UIScrollView")
	self.ScrollView.content = content

	if initPos then
		self:SetInitPos(initPos)
	end

	self.addCellCallback = addCellCallback
	self.updateCellCallback = updateCellCallback

	local function wrap_cb(visibleList, bInit)
		self:OnVisibleEntriesChanged(visibleList, bInit)
	end

	self.ScrollView.OnVisibleEntriesChanged:AddListener(wrap_cb)

	self.CurSelectedCharIdx = -1

	self.ScrollView:Initialize(count, self.ScrollView.content, ishorizontal, true, prefabCell, 0)
end

function UIScrollTool:UpdateListData(listData)
	self.ScrollView:ResetScrollView(#listData, false)
end

function UIScrollTool:UpdateListDataKeepPos(listData)
	self.ScrollView:ResetScrollView(#listData, true)
end

function UIScrollTool:SetContentPosImmediate(v, listData)
	TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
		if not IsNil(self.ScrollView) then
			self.ScrollView:SetContentPosImmediate(v)
			self.ScrollView:ResetScrollView(#listData, true)
		end
	end, nil)
end

function UIScrollTool:SetContentPos(pos, smoothTime)
	if not IsNil(self.ScrollView) then
		self.ScrollView:SetContentPos(pos, smoothTime)
	end
end

function UIScrollTool:SetInitPos(pos)
	if not IsNil(self.ScrollView) then
		self.ScrollView.ScrollViewInitPos = pos
	end
end

function UIScrollTool:SetFinalPos()
	if not IsNil(self.ScrollView) then
		self.ScrollView:SetFinalPos()
	end
end

function UIScrollTool:OnLeave()
	self.page = nil

	if not IsNil(self.ScrollView) then
		self.ScrollView.content = nil
	end

	self.CellClass = nil
	self.ScrollArea = nil
	self.ScrollView = nil
end

function UIScrollTool:OnUnRegisterEvent()
	if self.ItemRoot2ItemDict then
		for _, v in self.ItemRoot2ItemDict:Enumerator() do
			EventListenerMgr.RemoveUIListener(v.Item.UIRootObject, self.page.OnClickedCell, self.page, EventTriggerType.PointerClick)
			EventListenerMgr.RemoveUIListener(v.Item.UIRootObject, self.page.OnLongPressCell, self.page, EventTriggerType.PointerLongPress)

			if v.Item.OnLeave ~= nil then
				v.Item:OnLeave()
			end
		end
	end
end

function UIScrollTool:Purge()
	self:OnUnRegisterEvent()
	self:OnLeave()
end

function UIScrollTool:OnVisibleEntriesChanged(visibleList, bInit)
	if bInit then
		self:InitCachedItemContainer()
	end

	self:RefreshScrollView(visibleList)
end

function UIScrollTool:RefreshAllCell()
	if self.ItemRoot2ItemDict then
		for _, v in self.ItemRoot2ItemDict:Enumerator() do
			if self.updateCellCallback ~= nil then
				self.updateCellCallback(v.Item, v.Item.Index)
			else
				self.page:UpdateCell(v.Item, v.Item.Index)
			end
		end
	end
end

function UIScrollTool:InitCachedItemContainer()
	self.ItemRoot2ItemDict = self.ItemRoot2ItemDict or Record()

	local cachedEntryObjs = self.ScrollView.CachedEntryObjects
	local cachedCount = cachedEntryObjs.Count

	for i = 0, cachedCount - 1 do
		local go = cachedEntryObjs:get_Item(i)
		local item = self.ItemRoot2ItemDict:GetValue(go)

		if item == nil then
			self:CreateCellItem(go)
		end
	end
end

function UIScrollTool:CreateCellItem(itemRoot)
	local item = self.CellClass(self.PrefabCell, self.ScrollView.content.gameObject, self, self.page)

	item:InitItemByRoot(itemRoot)

	local info = {
		Item = item,
		Influence = {},
		Progress = {}
	}

	self.ItemRoot2ItemDict:Set(itemRoot, info)

	if self.addCellCallback ~= nil then
		self.addCellCallback(item)
	else
		self.page:AddCellClick(item)
	end

	return info
end

function UIScrollTool:RefreshScrollView(visibleList)
	local entriesRoots = self.ScrollView.EntryRoots

	if entriesRoots == nil then
		return
	end

	self.ItemRoot2ItemDict = self.ItemRoot2ItemDict or Record()

	local realIdx = 0
	local itemInfo = 0
	local itemRoot, entryRoot
	local visibleCount = visibleList.Count

	for i = 0, visibleCount - 1 do
		realIdx = visibleList:get_Item(i) + 1

		if realIdx - 1 < entriesRoots.Count then
			entryRoot = entriesRoots:get_Item(realIdx - 1)
			itemRoot = entryRoot:GetChild(0).gameObject
			itemInfo = self.ItemRoot2ItemDict:GetValue(itemRoot)

			if itemInfo == nil then
				itemInfo = self:CreateCellItem(itemRoot)
			end

			itemInfo.Item.Index = realIdx

			if self.updateCellCallback ~= nil then
				self.updateCellCallback(itemInfo.Item, realIdx)
			else
				self.page:UpdateCell(itemInfo.Item, realIdx)
			end
		end
	end
end

function UIScrollTool:GetItem(index)
	local cachedEntryObjs = self.ScrollView.CachedEntryObjects
	local go = cachedEntryObjs:get_Item(index - 1)
	local info = self.ItemRoot2ItemDict:GetValue(go)

	return info.Item
end

function UIScrollTool:GetLastItem()
	local cachedEntryObjs = self.ScrollView.CachedEntryObjects
	local go = cachedEntryObjs:get_Item(cachedEntryObjs.Count - 1)
	local info = self.ItemRoot2ItemDict:GetValue(go)

	return info.Item
end

function UIScrollTool:UpdateCellSelect(hideIdx, showIdx)
	if self.ItemRoot2ItemDict then
		for _, v in self.ItemRoot2ItemDict:Enumerator() do
			if v.Item.Index == showIdx then
				v.Item:UpdateSelectState(true)
			end

			if v.Item.Index == hideIdx then
				v.Item:UpdateSelectState(false)
			end
		end
	end
end

function UIScrollTool:SetScrollDirection(isHorizontal, isVertical)
	self.ScrollView.horizontal = isHorizontal
	self.ScrollView.vertical = isVertical
end
