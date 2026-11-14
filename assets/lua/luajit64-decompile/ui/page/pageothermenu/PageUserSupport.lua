-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOtherMenu/PageUserSupport.lua

require("Info/Player")

PageUserSupport = class("PageUserSupport", UIPanel)

function PageUserSupport:ctor()
	PageUserSupport.base.ctor(self, "UI/PageOtherMenu/PageUserSupport")
end

function PageUserSupport:PreLoad()
	return
end

function PageUserSupport:Cache()
	PageUserSupport.base.Cache(self)
end

function PageUserSupport:Purge()
	PageUserSupport.base.Purge(self)
	self:OnLeave()
end

function PageUserSupport:OnPageLoaded()
	return
end

function PageUserSupport:OnEnter()
	self:GetChildComponent("title/text", "Text").text = _("PageOtherMenu_Support_Title")
	self:GetChildComponent("PanelMenu/head_text", "Text").text = _("PageOtherMenu_Support_Head")
	self:GetChildComponent("PanelMenu/tpis_text", "Text").text = _("PageOtherMenu_Support_Tips")
	self:GetChildComponent("PanelMenu/BtnGroup/PurchaseError/text", "Text").text = _("PageOtherMenu_Support_PurchaseError")
	self:GetChildComponent("PanelMenu/BtnGroup/Request/text", "Text").text = _("PageOtherMenu_Support_Request")
	self:GetChildComponent("PanelMenu/BtnGroup/Flaw/text", "Text").text = _("PageOtherMenu_Support_Flaw")
	self:GetChildComponent("PanelMenu/BtnGroup/Etc/text", "Text").text = _("PageOtherMenu_Support_Etc")
	self:GetChildComponent("BtnFAQ/text", "Text").text = _("PageOtherMenu_Support_FAQ")
	self.btnClose = self:GetChildGameObject("BtnClose")
	self.btnPurchaseError = self:GetChildGameObject("PanelMenu/BtnGroup/PurchaseError")
	self.btnRequest = self:GetChildGameObject("PanelMenu/BtnGroup/Request")
	self.btnFlaw = self:GetChildGameObject("PanelMenu/BtnGroup/Flaw")
	self.btnEtc = self:GetChildGameObject("PanelMenu/BtnGroup/Etc")
	self.btnFaq = self:GetChildGameObject("BtnFAQ")
end

function PageUserSupport:OnLeave()
	return
end

function PageUserSupport:OnRegisterEvent()
	self:AddClick(self.btnClose, self.Close, PATH_SFX_UI_Click)
	self:AddClick(self.btnPurchaseError, self.OnClickPurchaseError, PATH_SFX_UI_Click)
	self:AddClick(self.btnRequest, self.OnClickRequest, PATH_SFX_UI_Click)
	self:AddClick(self.btnFlaw, self.OnClickFlaw, PATH_SFX_UI_Click)
	self:AddClick(self.btnEtc, self.OnClickEtc, PATH_SFX_UI_Click)
	self:AddClick(self.btnFaq, self.OnClickFaq, PATH_SFX_UI_Click)
end

function PageUserSupport:OnUnRegisterEvent()
	self:RemoveClick(self.btnClose, self.Close)
	self:RemoveClick(self.btnPurchaseError, self.OnClickPurchaseError)
	self:RemoveClick(self.btnRequest, self.OnClickRequest)
	self:RemoveClick(self.btnFlaw, self.OnClickFlaw)
	self:RemoveClick(self.btnEtc, self.OnClickEtc)
	self:RemoveClick(self.btnFaq, self.OnClickFaq)
end

function PageUserSupport:Close()
	PageUserSupport.base.Close(self)
end

function PageUserSupport:OnBack()
	self:Close()
end

function PageUserSupport:GetBodyText(body_text)
	if PlayerInst.InfoPlayer.pid ~= nil and PlayerInst.InfoPlayer.pid ~= 0 then
		body_text = string.gsub(body_text, "player_id", PlayerInst.InfoPlayer.pid)
		body_text = string.gsub(body_text, "player_name", PlayerInst.InfoPlayer.name)
	else
		local preUserId = PlayerPrefs.GetString("PRE_USER_ID", "")

		if preUserId ~= "" then
			body_text = string.gsub(body_text, "player_id", preUserId)
		else
			body_text = string.gsub(body_text, "player_id", "XXXXXXXXX")
		end

		body_text = string.gsub(body_text, "\n.*player_name", "")
	end

	body_text = string.gsub(body_text, "app_version", Application.version)
	body_text = string.gsub(body_text, "device_info", DeviceInfo.Device)
	body_text = string.gsub(body_text, "device_os", DeviceInfo.OS)
	body_text = string.gsub(body_text, "free_space", SupportMail.StrStorage)
	body_text = string.gsub(body_text, "memory_info", DeviceInfo.SystemMemorySize .. "MB")
	body_text = string.gsub(body_text, "screen_size", SeanLib.PostProcessV2.GlobleSetting.OriginResolution.width .. "x" .. SeanLib.PostProcessV2.GlobleSetting.OriginResolution.height)

	return body_text
end

function PageUserSupport:OnClickPurchaseError()
	local body_text = self:GetBodyText(_("PageOtherMenu_Support_PurchaseError_Body"))

	SupportMail.RunMail(_("PageOtherMenu_Support_Address"), _("PageOtherMenu_Support_PurchaseError_Subject"), body_text)
end

function PageUserSupport:OnClickRequest()
	local body_text = self:GetBodyText(_("PageOtherMenu_Support_Request_Body"))

	SupportMail.RunMail(_("PageOtherMenu_Support_Address"), _("PageOtherMenu_Support_Request_Subject"), body_text)
end

function PageUserSupport:OnClickFlaw()
	local body_text = self:GetBodyText(_("PageOtherMenu_Support_Flaw_Body"))

	SupportMail.RunMail(_("PageOtherMenu_Support_Address"), _("PageOtherMenu_Support_Flaw_Subject"), body_text)
end

function PageUserSupport:OnClickEtc()
	local body_text = self:GetBodyText(_("PageOtherMenu_Support_Etc_Body"))

	SupportMail.RunMail(_("PageOtherMenu_Support_Address"), _("PageOtherMenu_Support_Etc_Subject"), body_text)
end

function PageUserSupport:OnClickFaq()
	Application.OpenURL(_("PageOtherMenu_Support_FAQ_Link"))
end
