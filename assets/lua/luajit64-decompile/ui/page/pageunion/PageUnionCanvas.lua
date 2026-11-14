-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnion/PageUnionCanvas.lua

require("UI/Item/UIItemBase")

PageUnionCanvas = class("PageUnionCanvas", UIItemBase)

function PageUnionCanvas:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function PageUnionCanvas:OnEnter()
	local g = self.UIRootObject
	local launcher = GameObject.Find("Launcher")
	local camera = GOUtil.GetComponent(launcher, "UIManager").UICamera
	local canvas = GOUtil.GetComponent(g, "Canvas")

	canvas.worldCamera = camera
	self.Event = GOUtil.FindChildGameObject(g, "Event")
end
