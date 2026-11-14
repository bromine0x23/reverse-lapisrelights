-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageStory/DlgStoryEditorSelectActor.lua

require("UI/Dlg/DlgBase")

DlgStoryEditorSelectActor = class("DlgStoryEditorSelectActor", DlgBase)

function DlgStoryEditorSelectActor:ctor()
	return
end

function DlgStoryEditorSelectActor:Cache()
	self:SubmitUIPrefabCacheLua("UI/PageStoryEditor/DlgStoryEditorSelectActor")
end

function DlgStoryEditorSelectActor:Purge()
	DlgStoryEditorSelectActor.base.Purge(self)
end

function DlgStoryEditorSelectActor:OnEnter(vParam)
	self.BtnNext = self:GetChildComponent("BtnNext", "Image")
end

function DlgStoryEditorSelectActor:OnLeave()
	return
end

function DlgStoryEditorSelectActor:OnRegisterEvent()
	self:AddClick(self.BtnNext.gameObject, self.OnBtnNext)
end

function DlgStoryEditorSelectActor:OnUnRegisterEvent()
	self:RemoveClick(self.BtnNext.gameObject, self.OnBtnNext)
end

function DlgStoryEditorSelectActor:OnBtnNext()
	self.Parent:OnBtnNext()
end
