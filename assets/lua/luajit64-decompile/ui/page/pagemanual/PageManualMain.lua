-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageManual/PageManualMain.lua

PageManualMain = class("PageManualMain", UIPanel)

function PageManualMain:ctor()
	self.UIPrefabPath = "UI/PageManual/PageManualMain"

	self:AddChildPanel(DlgExit(), {
		title = _("Desc_Illustrated"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PageManualMain:OnBack()
	UIMgr.PopPanel()
end

function PageManualMain:PreLoad()
	return
end

function PageManualMain:Purge()
	self.base.Purge(self)
end

function PageManualMain:OnRegisterEvent()
	self:AddClick(self.AlbumBtn, self.OnClickAlbumBtn)
	self:AddClick(self.NoteBtn, self.OnClickNoteBtn)
	self:AddClick(self.StoryBtn, self.OnClickStoryBtn)
end

function PageManualMain:OnUnRegisterEvent()
	self:RemoveClick(self.AlbumBtn, self.OnClickAlbumBtn)
	self:RemoveClick(self.NoteBtn, self.OnClickNoteBtn)
	self:RemoveClick(self.StoryBtn, self.OnClickStoryBtn)
end

function PageManualMain:OnEnter(vParam)
	self:DealWithLocalization()

	self.AlbumBtn = self:GetChildGameObject("Panel/AlbumBtn")
	self.NoteBtn = self:GetChildGameObject("Panel/NoteBtn")
	self.StoryBtn = self:GetChildGameObject("Panel/StoryBtn")
	CollectionManager.curSelectTeam = nil
	CollectionManager.curSelectTaskId = nil
end

function PageManualMain:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/Story", "Text")
	txt.text = _("Desc_ManualStory")
	txt = self:GetChildComponent("Panel/Text", "Text")
	txt.text = _("Desc_ManualVideos")
	txt = self:GetChildComponent("Panel/Note", "Text")
	txt.text = _("Desc_ManualFigure")
end

function PageManualMain:OnClickAlbumBtn()
	require("UI/Page/PageManual/PageImpression")
	UIMgr.SwitchPanel(PageImpression())
end

function PageManualMain:OnClickNoteBtn()
	require("UI/Page/PageManual/PagePictureTeam")
	UIMgr.SwitchPanel(PagePictureTeam())
end

function PageManualMain:OnClickStoryBtn()
	require("UI/Page/PageManual/PageStoryVideo")
	UIMgr.SwitchPanel(PageStoryVideo())
end
