-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageStory/DlgStoryEditorMenu.lua

require("UI/Dlg/DlgBase")

DlgStoryEditorMenu = class("DlgStoryEditorMenu", DlgBase)

function DlgStoryEditorMenu:ctor()
	return
end

function DlgStoryEditorMenu:Cache()
	self:SubmitUIPrefabCacheLua("UI/PageStoryEditor/DlgStoryEditorMenu")
end

function DlgStoryEditorMenu:Purge()
	DlgStoryEditorMenu.base.Purge(self)
end

function DlgStoryEditorMenu:OnEnter(vParam)
	self.BtnNew = self:GetChildComponent("BtnNew", "Image")
	self.BtnLoad = self:GetChildComponent("BtnLoad", "Image")
end

function DlgStoryEditorMenu:OnLeave()
	self.BtnNew = nil
	self.BtnLoad = nil
end

function DlgStoryEditorMenu:OnRegisterEvent()
	self:AddClick(self.BtnNew.gameObject, self.OnBtnNew)
	self:AddClick(self.BtnLoad.gameObject, self.OnBtnLoad)
end

function DlgStoryEditorMenu:OnUnRegisterEvent()
	self:RemoveClick(self.BtnNew.gameObject, self.OnBtnNew)
	self:RemoveClick(self.BtnLoad.gameObject, self.OnBtnLoad)
end

function DlgStoryEditorMenu:OnBtnNew()
	self.Parent:OnBtnNew()
end

function DlgStoryEditorMenu:OnBtnLoad()
	self.Parent:OnBtnLoad()
end
