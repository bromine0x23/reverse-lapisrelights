-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageStory/DlgStoryEditorSelectChapter.lua

require("UI/Dlg/DlgBase")

DlgStoryEditorSelectChapter = class("DlgStoryEditorSelectChapter", DlgBase)

function DlgStoryEditorSelectChapter:ctor()
	return
end

function DlgStoryEditorSelectChapter:Cache()
	self:SubmitUIPrefabCacheLua("UI/PageStoryEditor/DlgStoryEditorSelectChapter")
end

function DlgStoryEditorSelectChapter:Purge()
	DlgStoryEditorSelectChapter.base.Purge(self)
end

function DlgStoryEditorSelectChapter:OnEnter(vParam)
	self.BtnReturn = self:GetChildComponent("BtnReturn", "Image")
end

function DlgStoryEditorSelectChapter:OnLeave()
	self.BtnReturn = nil
end

function DlgStoryEditorSelectChapter:OnRegisterEvent()
	self:AddClick(self.BtnReturn.gameObject, self.OnBtnReturn)
end

function DlgStoryEditorSelectChapter:OnUnRegisterEvent()
	self:RemoveClick(self.BtnReturn.gameObject, self.OnBtnReturn)
end

function DlgStoryEditorSelectChapter:OnBtnReturn()
	self.Parent:OnBtnReturn()
end
