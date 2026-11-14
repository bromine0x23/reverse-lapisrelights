-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageChapter/CellChapterNode.lua

require("UI/Item/UIItemBase")

CellChapterNode = class("CellChapterNode", UIItemBase)

function CellChapterNode:ctor(itemPrefabCache, parent)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellChapterNode:Create(vParam)
	CellChapterNode.base.Create(self, vParam)
end

function CellChapterNode:OnEnter()
	local g = self.UIRootObject

	self.Lock = self:GetChildGameObject("Lock")
	self.UnLock = self:GetChildGameObject("UnLock")
	self.tex_level = GOUtil.FindChildComponent(g, "Lock/Lock1/tex_level", "Text")

	self:OnRegisterEvent()
end

function CellChapterNode:UpdateData(data, index)
	local infoChapter = data.info
	local chapterIndex = data.info.data.ID
	local listChapter = data.listChapter
	local listStage = infoChapter.data.StageID
	local stageCnt = #listStage
	local chapNum = ChapterMgr:GetChapterIdx(infoChapter.data.ID)

	if type(chapNum) ~= "number" then
		chapNum = 0
	end

	local isUnLock = infoChapter:IsOpen() and chapNum < 10
	local isNew = infoChapter:IsNew()

	self:UpdateState(isUnLock, chapterIndex)
end

function CellChapterNode:UpdateState(isUnLock, index)
	SetActiveFunc(self.UnLock, not isUnLock)
	SetActiveFunc(self.Lock, isUnLock)

	if isUnLock then
		if index == 100 then
			self.tex_level.text = Lang(13100)
		else
			self.tex_level.text = string.format(Lang(12070), tostring(tonumber(index) % 100))
		end
	end
end

function CellChapterNode:OnRegisterEvent()
	return
end

function CellChapterNode:OnUnRegisterEvent()
	return
end

function CellChapterNode:OnLeave()
	self:OnUnRegisterEvent()
end
