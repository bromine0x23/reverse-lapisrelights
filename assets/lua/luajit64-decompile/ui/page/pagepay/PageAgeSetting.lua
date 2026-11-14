-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePay/PageAgeSetting.lua

PageAgeSetting = class("PageAgeSetting", UIPanel)

require("UI/Page/PagePay/PageAgeConfirm")

function PageAgeSetting:ctor()
	PageAgeSetting.base.ctor(self, "UI/PanelPay/PanelAgeSetting")
end

function PageAgeSetting:Purge()
	PageAgeSetting.base.Purge(self)
	self:OnLeave()
end

function PageAgeSetting:OnLeave()
	self.btnSure = nil
	self.txt_year = nil
	self.txt_month = nil
	self.cb = nil
end

function PageAgeSetting:OnRegisterEvent()
	self:AddClick(self.btnSure.gameObject, self.OnSure)
	self:AddClick(self.btnCancel.gameObject, self.OnCanel)
end

function PageAgeSetting:OnUnRegisterEvent()
	self:RemoveClick(self.btnSure.gameObject, self.OnSure)
	self:RemoveClick(self.btnCancel.gameObject, self.OnCanel)
end

function PageAgeSetting:OnCanel()
	self:Close()
end

function PageAgeSetting:OnSure()
	local serverTick = Mathf.Round(NetData:GetCurServerTime() / 1000)
	local userTick = DateUtil.OriginTime({
		hour = 0,
		second = 0,
		minute = 0,
		day = 1,
		month = self:getMonth(),
		year = self:getYear()
	})

	print("1:", serverTick)
	print("2:", userTick)

	if self:getYear() < 1900 or self:getMonth() <= 0 or self:getMonth() > 12 or serverTick < userTick then
		UIMgr.ShowDialogWithTitle(_("PageAgeSetting_titel1"), "正しい生年月を入力してください")

		return
	end

	local function wrap_cb()
		self.cb()
		self:Close()
	end

	UIMgr.AddPanel(PageAgeConfirm(), {
		callback = wrap_cb,
		year = self:getYear(),
		month = self:getMonth()
	}, self.UIRootObject)
end

function PageAgeSetting:OnEnter(vParam)
	self.title_txt = self:GetChildComponent("bg/title/Text", "Text")
	self.btnSure = self:GetChildComponent("bg/sureBtn", "Button")
	self.btnCancel = self:GetChildComponent("bg/cancelBtn", "Button")
	self.txt_year = self:GetChildComponent("bg/content/yearInput", "InputField")
	self.txt_month = self:GetChildComponent("bg/content/monthInput", "InputField")
	self.txt_desc = self:GetChildComponent("bg/content/destription/desc1", "Text")
	self:GetChildComponent("bg/sureBtn/Text", "Text").text = _("PageAgeSetting_ok")
	self:GetChildComponent("bg/cancelBtn/Text", "Text").text = _("PageAgeSetting_cancel")

	self.txt_year.onValueChanged:AddListener(function(...)
		self:onInputValueChanged(...)
	end)
	self.txt_year.onValueChanged:AddListener(function(...)
		self:onInputValueChanged(...)
	end)

	self.txt_desc.text = _("PageAgeSetting_description1")
	self.title_txt.text = _("PageAgeSetting_titel1")
	self.cb = vParam.callback
end

function PageAgeSetting:getYear()
	local year = tonumber(self.txt_year.text)

	year = year == nil and 0 or year

	local serverTick = Mathf.Round(NetData:GetCurServerTime() / 1000)
	local serverDateTime = os.date("*t", serverTick)

	if year < 0 or year > serverDateTime.year then
		return 0
	else
		return year
	end
end

function PageAgeSetting:getMonth()
	local month = tonumber(self.txt_month.text)

	month = month == nil and 0 or month

	if not month or month < 0 or month > 12 then
		return 0
	else
		return month
	end
end

function PageAgeSetting:onInputValueChanged(str)
	self:UpdateOkButton()
end

function PageAgeSetting:UpdateOkButton()
	local serverTick = Mathf.Round(NetData:GetCurServerTime() / 1000)
	local serverDateTime = os.date("*t", serverTick)

	print(serverDateTime.year)
	print(serverDateTime.month)

	if self:getYear() == 0 or self:getMonth() == 0 or self:getYear() == serverDateTime.year and self:getMonth() > serverDateTime.month then
		self.btnSure.enabled = false

		return
	end

	self.btnSure.enabled = self:getYear() >= 1900
end
