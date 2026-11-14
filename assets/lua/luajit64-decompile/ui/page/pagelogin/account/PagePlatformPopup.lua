-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/Account/PagePlatformPopup.lua

PagePlatformPopup = class("PagePlatformPopup", UIPanel)

function PagePlatformPopup:ctor()
	PagePlatformPopup.base.ctor(self, "UI/PanelLogin/PlatformLinkPopup")
end

function PagePlatformPopup:OnEnter(vParms)
	self.contText = self:GetChildComponent("PanelServers/maskround/bg/content", "Text")
	self.btnClose = self:GetChildComponent("close", "Button")
	self.viewTitle = self:GetChildComponent("PanelServers/text", "Text")
	self.contText.text = vParms.content
	self.viewTitle.text = vParms.title
	self.callback = vParms.call_back

	GOUtil.SetFont(self.viewTitle, UIMgr.JPFonts.YukiB)
	GOUtil.SetFont(self.contText, UIMgr.JPFonts.W5)
end

function PagePlatformPopup:Purge()
	PagePlatformPopup.base.Purge(self)
	self:OnLeave()
end

function PagePlatformPopup:OnLeave()
	self.viewTitle = nil
	self.contText = nil
	self.btnClose = nil
	self.callback = nil
end

function PagePlatformPopup:OnRegisterEvent()
	self:AddClick(self.btnClose.gameObject, self.OnClickedBack)
end

function PagePlatformPopup:OnUnRegisterEvent()
	self:RemoveClick(self.btnClose.gameObject, self.OnClickedBack)
end

function PagePlatformPopup:OnClickedBack()
	self.callback()
	self:Close()
end

function PagePlatformPopup:OnBackAndroid()
	self:OnClickedBack()
end
