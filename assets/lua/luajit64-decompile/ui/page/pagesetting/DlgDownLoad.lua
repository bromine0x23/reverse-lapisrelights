-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageSetting/DlgDownLoad.lua

DlgDownLoad = class("DlgDownLoad", UIPanel)

function DlgDownLoad:ctor()
	DlgDownLoad.base.ctor(self, "UI/PanelSetting/DlgDownLoad")
end

function DlgDownLoad:Purge()
	DlgDownLoad.base.Purge(self)
	self:OnLeave()
end

function DlgDownLoad:OnLeave()
	return
end

function DlgDownLoad:OnRegisterEvent()
	self:AddClick(self.digdownloadbtn, self.OnClickBtnDown)
	self:AddClick(self.btnclose, self.OnClickBtnQuit, PATH_SFX_UI_CANCEL)
	self:AddClick(self.btnincludevoice, self.OnClickBtnAddvoice)
	self:AddClick(self.btndown, self.OnClickCurrentBtnDown)
	self:AddClick(self.group4btndown, self.OnClickGroup4BtnDown)
	self:AddClick(self.group4btnnotdown, self.OnClickGroup4BtnnotDown)
end

function DlgDownLoad:OnUnRegisterEvent()
	self:RemoveClick(self.digdownloadbtn, self.OnClickBtnDown)
	self:RemoveClick(self.btnclose, self.OnClickBtnQuit, PATH_SFX_UI_CANCEL)
	self:RemoveClick(self.btnincludevoice, self.OnClickBtnAddvoice)
	self:RemoveClick(self.btndown, self.OnClickCurrentBtnDown)
	self:RemoveClick(self.group4btndown, self.OnClickGroup4BtnDown)
	self:RemoveClick(self.group4btnnotdown, self.OnClickGroup4BtnnotDown)
end

function DlgDownLoad:OnEnter(vParam)
	self.bundleinfo = vParam
	self.cb = vParam.callback
	self.digdownloadbtn = GOUtil.FindChildGameObject(self.UIRootObject, "Group1/BtnDownAll")
	self.digdes = GOUtil.FindChildComponent(self.UIRootObject, "TextDes", "Text")
	self.diggroup1 = GOUtil.FindChildGameObject(self.UIRootObject, "Group1")
	self.diggroup2 = GOUtil.FindChildGameObject(self.UIRootObject, "Group2")
	self.diggroup3 = GOUtil.FindChildGameObject(self.UIRootObject, "Group3")
	self.diggroup4 = GOUtil.FindChildGameObject(self.UIRootObject, "Group4")
	self.grou1text = GOUtil.FindChildComponent(self.UIRootObject, "Group1/AllText", "Text")
	self.grou4text = GOUtil.FindChildComponent(self.UIRootObject, "Group4/AllText", "Text")
	self.IncludeVoiceText = GOUtil.FindChildComponent(self.UIRootObject, "Group2/IncludeVoiceText", "Text")
	self.DownText = GOUtil.FindChildComponent(self.UIRootObject, "Group2/AddVoiceText", "Text")
	self.btndown = GOUtil.FindChildGameObject(self.UIRootObject, "Group2/BtnAddVoice")
	self.group4btndown = GOUtil.FindChildGameObject(self.UIRootObject, "Group4/BtnDown")
	self.group4btnnotdown = GOUtil.FindChildGameObject(self.UIRootObject, "Group4/BtnNotDown")
	self.btnincludevoice = GOUtil.FindChildGameObject(self.UIRootObject, "Group2/BtnincludeVoice")
	self.sliderimage = GOUtil.FindChildComponent(self.UIRootObject, "Group3/Slider", "Image")
	self.slidertext = GOUtil.FindChildComponent(self.UIRootObject, "Group3/Text", "Text")
	self.btnclose = GOUtil.FindChildGameObject(self.UIRootObject, "BtnClose")

	self:InitData()
	self:InitText()
end

function DlgDownLoad:InitData()
	if self.bundleinfo.opentype == 1 then
		self.digdes.text = self.bundleinfo.name

		self.diggroup1.gameObject:SetActive(true)
		self.diggroup2.gameObject:SetActive(false)
		self.diggroup3.gameObject:SetActive(false)
		self.diggroup4.gameObject:SetActive(false)

		self.grou1text.text = string.format(_("PageDownloadSize"), tostring(string.format("%.2f", self.bundleinfo.info.BundleSize)))
	elseif self.bundleinfo.opentype == 2 then
		self.digdes.text = self.bundleinfo.name

		self.diggroup1.gameObject:SetActive(false)
		self.diggroup2.gameObject:SetActive(true)
		self.diggroup3.gameObject:SetActive(false)
		self.diggroup4.gameObject:SetActive(false)

		self.DownText.text = string.format(_("PageDownloadSize"), tostring(string.format("%.2f", self.bundleinfo.item.BundleSize)))
		self.IncludeVoiceText.text = string.format(_("PageDownloadSize"), tostring(string.format("%.2f", self.bundleinfo.item.BundleSize + self.bundleinfo.additeminfo.BundleSize)))
	elseif self.bundleinfo.opentype == 4 then
		self.digdes.text = self.bundleinfo.name

		self.diggroup1.gameObject:SetActive(false)
		self.diggroup2.gameObject:SetActive(false)
		self.diggroup3.gameObject:SetActive(false)
		self.diggroup4.gameObject:SetActive(true)

		self.grou4text.text = string.format(_("PageDownloadSize"), tostring(string.format("%.2f", self.bundleinfo.item.BundleSize)))
	end
end

function DlgDownLoad:OnClickGroup4BtnDown()
	self.diggroup1.gameObject:SetActive(false)
	self.diggroup2.gameObject:SetActive(false)
	self.diggroup4.gameObject:SetActive(false)
	self.diggroup3.gameObject:SetActive(true)

	local downtable = {}

	downtable[1] = self.bundleinfo.item.Name
	self.downHandler = DownloadOptionManager.Instance:DownloadOptionnal(downtable, self.DownloadFinsh, self.OnProgressChange, self)
end

function DlgDownLoad:DownloadFinsh()
	self:Close()
	self:Close()

	if self.cb then
		self.cb()

		self.cb = nil
	end
end

function DlgDownLoad:OnClickGroup4BtnnotDown()
	self:Close()

	if self.cb then
		self.cb()

		self.cb = nil
	end
end

function DlgDownLoad:OnClickBtnDown()
	self:Close()
	Event.Instance:Fire("DigDownLoadClick", self)
end

function DlgDownLoad:OnClickCurrentBtnDown()
	if self.opentype == 1 then
		self:Close()
		Event.Instance:Fire("DigDownLoadClick", self)
	else
		self.diggroup1.gameObject:SetActive(false)
		self.diggroup2.gameObject:SetActive(false)
		self.diggroup3.gameObject:SetActive(true)
		self.diggroup4.gameObject:SetActive(false)

		local downtable = {}

		downtable[1] = self.bundleinfo.item.Name
		self.downHandler = DownloadOptionManager.Instance:DownloadOptionnal(downtable, self.DownloadFinsh, self.OnProgressChange, self)
	end
end

function DlgDownLoad:OnClickBtnAddvoice()
	self.diggroup1.gameObject:SetActive(false)
	self.diggroup2.gameObject:SetActive(false)
	self.diggroup3.gameObject:SetActive(true)
	self.diggroup4.gameObject:SetActive(false)

	local downtable = {}

	downtable[1] = self.bundleinfo.item.Name
	downtable[2] = self.bundleinfo.additeminfo.Name
	self.downHandler = DownloadOptionManager.Instance:DownloadOptionnal(downtable, self.DownloadFinsh, self.OnProgressChange, self)
end

function DlgDownLoad:OnProgressChange(va)
	self.sliderimage.fillAmount = va
	self.slidertext.text = math.floor(va * 100) .. "%"
end

function DlgDownLoad:OnClickBtnQuit()
	self:Close()

	if self.downHandler ~= nil then
		DownloadManager.Cancel(self.downHandler)
	end
end

function DlgDownLoad:InitText()
	local TextAuto

	TextAuto = self:GetChildComponent("Text/", "Text")
	TextAuto.text = Lang(5000098)
	TextAuto = self:GetChildComponent("Text (1)/", "Text")
	TextAuto.text = Lang(5000099)
	TextAuto = self:GetChildComponent("Text (3)/", "Text")
	TextAuto.text = Lang(5000100)
	TextAuto = self:GetChildComponent("Group1/BtnDownAll/Text/", "Text")
	TextAuto.text = Lang(5000101)
	TextAuto = self:GetChildComponent("Group2/BtnincludeVoice/Text/", "Text")
	TextAuto.text = Lang(5000102)
	TextAuto = self:GetChildComponent("Group2/BtnAddVoice/Text/", "Text")
	TextAuto.text = Lang(5000103)
	TextAuto = self:GetChildComponent("Group3/Text/", "Text")
	TextAuto.text = Lang(5000104)
end
