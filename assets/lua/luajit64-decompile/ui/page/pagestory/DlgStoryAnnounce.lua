-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageStory/DlgStoryAnnounce.lua

DlgStoryAnnounce = class("DlgStoryAnnounce", UIPanel)

function DlgStoryAnnounce:ctor()
	DlgStoryAnnounce.base.ctor(self, "UI/PageStory/DlgStoryAnnounce")
end

function DlgStoryAnnounce:Purge()
	DlgStoryAnnounce.base.Purge(self)
end

function DlgStoryAnnounce:OnEnter(vParam)
	self.TxtLocale = self:GetChildComponent("ImgBackground/TxtLocale", "Text")
	self.TxtLocale.text = vParam
end

function DlgStoryAnnounce:Close()
	self:Purge()
end

function DlgStoryAnnounce:IsShow()
	return self.UIRootObject ~= nil
end

function DlgStoryAnnounce:OnLeave()
	return
end

function DlgStoryAnnounce:OnRegisterEvent()
	return
end

function DlgStoryAnnounce:OnUnRegisterEvent()
	return
end

function DlgStoryAnnounce:SetTitle(title)
	return
end

function DlgStoryAnnounce:SetLocale(locale)
	self.TxtLocale.text = locale
end

function DlgStoryAnnounce.GetInstance()
	DlgStoryAnnounce.Instance = DlgStoryAnnounce.Instance or DlgStoryAnnounce()

	return DlgStoryAnnounce.Instance
end
