-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Item/UIItemBase.lua

UIItemBase = class("UIItemBase", UIPanel)

function UIItemBase:ctor(itemPrefabCache, parent)
	self.ItemPrefabCache = itemPrefabCache
	self.baseParent = parent
	self.Parent = parent
	self.Index = 1
	self.ParentItemIdx = 1
end

function UIItemBase:Create(vParam)
	if self.UIRootObject ~= nil then
		return
	end

	if not self.ItemPrefabCache then
		error("self.ItemPrefabCache is nil")

		return
	end

	self.UIRootObject = GOUtil.InstantiateUIPrefab(self.ItemPrefabCache, self.Parent)

	self:OnEnter(vParam)

	self.ItemPrefabCache = nil
	self.Parent = nil
end

function UIItemBase:InitItemByRoot(rootObject, vParam)
	if rootObject == nil then
		error("UIItemBase:InitItemByRoot param rootObject is nil")

		return
	end

	GOUtil.SetGameObjectLayer(rootObject, eLayer.UI)

	self.UIRootObject = rootObject

	self:OnEnter(vParam)
end
