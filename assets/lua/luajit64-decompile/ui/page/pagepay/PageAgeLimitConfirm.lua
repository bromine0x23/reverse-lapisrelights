-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePay/PageAgeLimitConfirm.lua

PageAgeLimitConfirm = class("PageAgeLimitConfirm", UIPanel)

function PageAgeLimitConfirm:ctor()
	PageAgeLimitConfirm.base.ctor(self, "UI/PanelPay/PanelAgeLimitConfirm")
end

function PageAgeLimitConfirm:Purge()
	PageAgeLimitConfirm.base.Purge(self)
	self:OnLeave()
end

function PageAgeLimitConfirm:OnLeave()
	self.btnSure = nil
	self.btnCancel = nil
	self.desc1 = nil
	self.desc3 = nil
	self.cb = nil
end

function PageAgeLimitConfirm:OnRegisterEvent()
	self:AddClick(self.btnSure.gameObject, self.OnSure)
	self:AddClick(self.btnCancel.gameObject, self.OnCanel)
end

function PageAgeLimitConfirm:OnUnRegisterEvent()
	self:RemoveClick(self.btnSure.gameObject, self.OnSure)
	self:RemoveClick(self.btnCancel.gameObject, self.OnCanel)
end

function PageAgeLimitConfirm:OnCanel()
	self.cb(-1)
	self:Close()
end

function PageAgeLimitConfirm:OnSure()
	self.cb(1)
	self:Close()
end

function PageAgeLimitConfirm:OnEnter(vParam)
	self.title_txt = self:GetChildComponent("bg/title/Text", "Text")
	self.btnSure = self:GetChildComponent("bg/grid/sureBtn", "Button")
	self.btnCancel = self:GetChildComponent("bg/grid/cancelBtn", "Button")
	self.desc1 = self:GetChildComponent("bg/content/desc1", "Text")
	self.desc3 = self:GetChildComponent("bg/content/desc3", "Text")
	self.every_txt = self:GetChildComponent("bg/content/eve_month/txt", "Text")
	self.curr_txt = self:GetChildComponent("bg/content/curr_month/txt", "Text")
	self:GetChildComponent("bg/grid/sureBtn/Text", "Text").text = _("PageAgeSetting_ok")
	self:GetChildComponent("bg/grid/cancelBtn/Text", "Text").text = _("PageAgeSetting_cancel")
	self.desc1.text = _("PageAgeSetting_description2")
	self.desc3.text = _("PageAgeSetting_description3")
	self.title_txt.text = _("PageAgeSetting_titel2")
	self.every_txt.text = string.format(_("PageAgeSetting_description10"), BillingManager:GetLimitPrice())
	self.curr_txt.text = string.format(_("PageAgeSetting_description11"), PlayerInst.InfoPlayer.billingState.currentMonthPurchasePrice)

	if vParam.is_limited then
		self.desc1.text = _("PageAgeSetting_description8")

		self.desc3.gameObject:SetActive(false)
		self.btnCancel.gameObject:SetActive(false)
	else
		self.desc1.text = _("PageAgeSetting_description5")
		self.desc3.text = _("PageAgeSetting_description6")
	end

	self.cb = vParam.callback
end
