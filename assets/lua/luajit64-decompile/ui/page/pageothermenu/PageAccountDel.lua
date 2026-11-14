-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOtherMenu/PageAccountDel.lua

PageAccountDel = class("PageAccountDel", UIPanel)

function PageAccountDel:ctor()
	PageAccountDel.base.ctor(self, "UI/PanelSetting/DlgAccountDelete")
end

function PageAccountDel:PreLoad()
	return
end

function PageAccountDel:Cache()
	PageAccountDel.base.Cache(self)
end

function PageAccountDel:Purge()
	PageAccountDel.base.Purge(self)
end

function PageAccountDel:OnPageLoaded()
	return
end

function PageAccountDel:OnEnter(vParms)
	self.parms = vParms
	self.btnClose = self:GetChildGameObject("Group1/Cancel")
	self.btnSure = self:GetChildGameObject("Group1/Sure")
	self.imgSure = self:GetChildComponent("Group1/Sure", "Image")
	self.btnClose2 = self:GetChildGameObject("Main/BtnClose")
	self.CloseTxt = self:GetChildComponent("Group1/Cancel/Text", "Text")
	self.SureTxt = self:GetChildComponent("Group1/Sure/Text", "Text")
	self.titleText = self:GetChildComponent("Main/Title", "Text")
	self.contentText = self:GetChildComponent("Main/TextDes", "Text")

	if vParms.okText then
		self.SureTxt.text = vParms.okText
	end

	if vParms.canelText then
		self.CloseTxt.text = vParms.canelText
	else
		GOUtil.SetActive(self.btnClose, false)
	end

	self.titleText.text = vParms.title
	self.contentText.text = vParms.content

	if vParms.blockSure then
		DealWithListRef(self, UIUtil.SetImageGray(self.imgSure, 1))
		GOUtil.SetActive(self.btnClose2, false)
	end

	if vParms.noClose then
		GOUtil.SetActive(self.btnClose2, false)
	end
end

function PageAccountDel:OnRegisterEvent()
	self:AddClick(self.btnClose, self.Close, PATH_SFX_UI_Click)
	self:AddClick(self.btnClose2, self.Close, PATH_SFX_UI_Click)
	self:AddClick(self.btnSure, self.Sure, PATH_SFX_UI_Click)
end

function PageAccountDel:OnUnRegisterEvent()
	self:RemoveClick(self.btnClose, self.Close)
	self:RemoveClick(self.btnClose2, self.Close)
	self:RemoveClick(self.btnBack, self.OnClickTop)
end

function PageAccountDel:Sure()
	if self.parms.blockSure then
		return
	end

	if self.parms.cb then
		self.parms.cb()
	end

	PageAccountDel.base.Close(self)
end

function PageAccountDel:Close()
	PageAccountDel.base.Close(self)
end

function PageAccountDel:OnBackAndroid()
	self:Close()
end
