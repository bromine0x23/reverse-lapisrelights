-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCaution/PageCaution.lua

PageCaution = class("PageCaution", UIPanel)

function PageCaution:ctor()
	PageCaution.base.ctor(self, "UI/Common/DlgCommon/DlgCautionTip")
end

function PageCaution:Purge()
	PageCaution.base.Purge(self)
	self:OnLeave()
end

function PageCaution:OnLeave()
	self.btnSure = nil
	self.txt_year = nil
	self.txt_month = nil
	self.cb = nil
end

function PageCaution:OnRegisterEvent()
	self:AddClick(self.btnSure.gameObject, self.OnSure)
	self:AddClick(self.btnNotify.gameObject, self.OnNotify)
end

function PageCaution:OnUnRegisterEvent()
	self:RemoveClick(self.btnSure.gameObject, self.OnSure)
	self:RemoveClick(self.btnNotify.gameObject, self.OnNotify)
end

function PageCaution:OnNotify()
	UIMgr.AddPanel(PageUserSupport(), nil, self.UIRootObject)
end

function PageCaution:OnSure()
	if self.canSubmit then
		self:Close()

		if self.call_back then
			self.call_back()
		end
	end
end

function PageCaution:OnEnter(vParam)
	self.btnSure = self:GetChildComponent("TweenRoot/SecondBig/Grid/Button_OK", "Button")
	self.btnNotify = self:GetChildComponent("TweenRoot/SecondBig/Grid/Button_Cancel", "Button")
	self.txt_title = self:GetChildComponent("TweenRoot/SecondBig/bg_title/Text", "Text")
	self.txt_content = self:GetChildComponent("TweenRoot/SecondBig/PanelMsg2/Text1", "Text")
	self.check_box = self:GetChildComponent("TweenRoot/SecondBig/CheckBox", "Toggle")
	self:GetChildComponent("TweenRoot/SecondBig/CheckBox/Label", "Text").text = _("m_caution_setting_caution_check")
	self:GetChildComponent("TweenRoot/SecondBig/Grid/Button_Cancel/Label_Cancel", "Text").text = _("m_caution_setting_caution_support")
	self:GetChildComponent("TweenRoot/SecondBig/Grid/Button_OK/Label_OK", "Text").text = _("m_caution_setting_caution_ok")
	self.call_back = vParam.callback

	if vParam.banForever then
		self.canSubmit = true

		self.check_box.gameObject:SetActive(false)

		self.txt_title.text = "不正行為確認"
		self.txt_content.text = vParam.content
	else
		self.cautionInfo = vParam.caution_info

		print(vParam.useCheckBox)

		if not vParam.useCheckBox then
			self.canSubmit = true
		end

		self.check_box.gameObject:SetActive(vParam.useCheckBox)
		printTable(vParam)

		local cautionInfo = self.cautionInfo

		self.txt_title.text = "不正行為警告"
		self.txt_content.text = cautionInfo.message == "" and _(self.cautionInfo.default_message) or _(cautionInfo.message)

		self.check_box.onValueChanged:AddListener(function(...)
			self:onToggleValueChanged(...)
		end)
	end
end

function PageCaution:onToggleValueChanged(v)
	self.canSubmit = v
end
