-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/PageTitleMenuTop.lua

require("UI/Page/PageOtherMenu/PageUserSupport")

PageTitleMenuTop = class("PageTitleMenuTop", UIPanel)

function PageTitleMenuTop:ctor()
	PageTitleMenuTop.base.ctor(self, "UI/PanelLogin/PageTitleMenuTop")
end

function PageTitleMenuTop:OnPageLoaded()
	return
end

function PageTitleMenuTop:OnEnter(vParms)
	self:GetChildComponent("title/text", "Text").text = Localization("PageTitleMenu_title")
	self.btnClose = self:GetChildComponent("close", "Button")
	self:GetChildComponent("PanelMenu/data_repair/tit_text", "Text").text = Localization("PageTitleMenu_data_repair")
	self.btnRepair = self:GetChildComponent("PanelMenu/data_repair", "Button")
	self:GetChildComponent("PanelMenu/account_login/tit_text", "Text").text = Localization("PageTitleMenu_account_login")
	self.btnLogin = self:GetChildComponent("PanelMenu/account_login", "Button")
	self:GetChildComponent("PanelMenu/support/tit_text", "Text").text = Localization("PageTitleMenu_user_support")
	self.btnSupport = self:GetChildComponent("PanelMenu/support", "Button")
end

function PageTitleMenuTop:OnLeave()
	self.btnRepair = nil
	self.btnLogin = nil
	self.btnSupport = nil
	self.btnClose = nil
end

function PageTitleMenuTop:OnRegisterEvent()
	self:AddClick(self.btnRepair.gameObject, self.OnClickedRepair)
	self:AddClick(self.btnLogin.gameObject, self.OnClickedLogin)
	self:AddClick(self.btnSupport.gameObject, self.OnClickedSupport)
	self:AddClick(self.btnClose.gameObject, self.OnClickedBack)
end

function PageTitleMenuTop:OnUnRegisterEvent()
	self:RemoveClick(self.btnRepair.gameObject, self.OnClickedRepair)
	self:RemoveClick(self.btnLogin.gameObject, self.OnClickedLogin)
	self:RemoveClick(self.btnSupport.gameObject, self.OnClickedSupport)
	self:RemoveClick(self.btnClose.gameObject, self.OnClickedBack)
end

function PageTitleMenuTop:OnClickedRepair()
	local function wrap_cb(index)
		if index == 1 then
			Launcher.Instance:DataRepair()
		end
	end

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("PageTitleMenu_data_repair_title"), _("PageTitleMenu_data_repair_desc"), wrap_cb, _("UI_confirm"), _("Quite_Cancel"), true)
	self:Close()
end

function PageTitleMenuTop:OnClickedLogin()
	UIMgr.AddPanel(PagePlatformSelect(), {
		useForLogin = true
	})
	self:Close()
end

function PageTitleMenuTop:OnClickedSupport()
	UIMgr.AddPanel(PageUserSupport(), {})
	self:Close()
end

function PageTitleMenuTop:Purge()
	PageTitleMenuTop.base.Purge(self)
	self:OnLeave()
end

function PageTitleMenuTop:OnClickedBack()
	self:Close()
end
