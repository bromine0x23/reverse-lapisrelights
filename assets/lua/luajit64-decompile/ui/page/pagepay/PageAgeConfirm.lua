-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePay/PageAgeConfirm.lua

PageAgeConfirm = class("PageAgeConfirm", UIPanel)

function PageAgeConfirm:ctor()
	PageAgeConfirm.base.ctor(self, "UI/PanelPay/PanelAgeConfirm")
end

function PageAgeConfirm:Purge()
	PageAgeConfirm.base.Purge(self)
	self:OnLeave()
end

function PageAgeConfirm:OnLeave()
	self.btnSure = nil
	self.txt_year = nil
	self.txt_month = nil
	self.cb = nil
end

function PageAgeConfirm:OnRegisterEvent()
	self:AddClick(self.btnSure.gameObject, self.OnSure)
	self:AddClick(self.btnCancel.gameObject, self.OnCanel)
end

function PageAgeConfirm:OnUnRegisterEvent()
	self:RemoveClick(self.btnSure.gameObject, self.OnSure)
	self:RemoveClick(self.btnCancel.gameObject, self.OnCanel)
end

function PageAgeConfirm:OnCanel()
	self:Close()
end

function PageAgeConfirm:OnSure()
	function callback()
		LoadingMgr.Hide(eLoadingType.Repeat)
		UIMgr.ShowDialogWithTitle(_("PageAgeSetting_titel_description"), _("PageAgeSetting_description4"), function()
			self.cb()
			self:Close()
		end)
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestOldSetter(self.year, self.month, callback)
end

function PageAgeConfirm:OnEnter(vParam)
	self.title_txt = self:GetChildComponent("bg/title/Text", "Text")
	self.btnSure = self:GetChildComponent("bg/sureBtn", "Button")
	self.btnCancel = self:GetChildComponent("bg/cancelBtn", "Button")
	self.desc1 = self:GetChildComponent("bg/content/desc1", "Text")
	self.desc2 = self:GetChildComponent("bg/content/desc2", "Text")
	self.desc3 = self:GetChildComponent("bg/content/desc3", "Text")
	self:GetChildComponent("bg/sureBtn/Text", "Text").text = _("PageAgeSetting_ok")
	self:GetChildComponent("bg/cancelBtn/Text", "Text").text = _("PageAgeSetting_cancel")
	self.desc3.text = _("PageAgeSetting_description3")
	self.desc1.text = _("PageAgeSetting_description2")
	self.desc2.text = string.format(_("PageAgeSetting_description9"), vParam.year, vParam.month, DateUtil.GetYearsOld(NetData:GetCurServerTime(), vParam.year, vParam.month))
	self.cb = vParam.callback
	self.year = vParam.year
	self.month = vParam.month
	self.title_txt.text = _("PageAgeSetting_titel1")
end
