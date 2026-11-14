-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageChapter/PageChapterCanvas.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageChapter/CellChapter")

PageChapterCanvas = class("PageChapterCanvas", UIItemBase)

function PageChapterCanvas:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function PageChapterCanvas:OnEnter()
	local g = self.UIRootObject

	self.Canvas = GOUtil.GetComponent(g, "Canvas")

	local LauncherGo = GameObject.Find("Launcher")
	local gg = GOUtil.FindChildComponent(LauncherGo, "UICamera", "Camera")

	self.Canvas.worldCamera = gg
	self.Image = GOUtil.FindChildGameObject(g, "BG/Image")
	self.PanelCellCanvas = GOUtil.FindChildGameObject(g, "PanelCell")
	self.Btn_bg = GOUtil.FindChildGameObject(g, "BG")
	self.ChapterCanvasBG = GOUtil.FindChildComponent(g, "BG", "Image")

	self:OnRegisterEvent()
end

function PageChapterCanvas:UpdateData(PrefabCellChapter)
	return
end

function PageChapterCanvas:Purge()
	return
end

function PageChapterCanvas:OnLeave()
	self:OnUnRegisterEvent()
end

function PageChapterCanvas:OnRegisterEvent()
	Event.Instance:Add("PageChapterCanvasEvent", self.PageChapterCanvasEvent, self)
	self:AddClick(self.Btn_bg, self.OnClickedBg)
end

function PageChapterCanvas:OnUnRegisterEvent()
	Event.Instance:Remove("PageChapterCanvasEvent", self.PageChapterCanvasEvent, self)
	self:RemoveClick(self.Btn_bg, self.OnClickedBg)
end

function PageChapterCanvas:OnClickedBg()
	Event.Instance:Fire("PageChapterEventNode")
end

function PageChapterCanvas:PageChapterCanvasEvent()
	local LauncherGo = GameObject.Find("Launcher")

	GOUtil.FindChildGameObject(LauncherGo, "PageChapterCanvas(Clone)"):Destroy()
	self:OnUnRegisterEvent()
end
