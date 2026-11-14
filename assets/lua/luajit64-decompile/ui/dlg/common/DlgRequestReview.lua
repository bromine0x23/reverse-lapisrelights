-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgRequestReview.lua

DlgRequestReview = class("DlgRequestReview", UIPanel)
DlgRequestReview.ButtonType = {
	YES_NO = 2,
	YES_ONLY = 1,
	NONE = 0
}
DlgRequestReview.EventType = {
	CLICKED_NO = 2,
	CLICKED_YES = 1,
	NONE = 0
}

function DlgRequestReview:ctor()
	DlgRequestReview.base.ctor(self, "UI/Common/DlgRequestReview/DlgRequestReview")
end

function DlgRequestReview:PreLoad()
	return
end

function DlgRequestReview:Purge()
	DlgRequestReview.base.Purge(self)
end

function DlgRequestReview:OnRegisterEvent()
	self:AddClick(self.BtnOK1, self.OnClickedBtnOK)
	self:AddClick(self.BtnOK2, self.OnClickedBtnOK)
	self:AddClick(self.BtnCancel2, self.OnClickedBtnCancel)
end

function DlgRequestReview:OnUnRegisterEvent()
	self:RemoveClick(self.BtnOK1, self.OnClickedBtnOK)
	self:RemoveClick(self.BtnOK2, self.OnClickedBtnOK)
	self:RemoveClick(self.BtnCancel2, self.OnClickedBtnCancel)
end

function DlgRequestReview:OnEnter(vParam)
	self.Panel1 = self:GetChildGameObject("Panel1")
	self.BtnOK1 = self:GetChildGameObject("Panel1/Bg/Buttons/BtnOK")
	self.Panel2 = self:GetChildGameObject("Panel2")
	self.BtnOK2 = self:GetChildGameObject("Panel2/Bg/Buttons/BtnOK")
	self.BtnCancel2 = self:GetChildGameObject("Panel2/Bg/Buttons/BtnCancel")

	self.Panel1:SetActive(false)
	self.Panel2:SetActive(false)

	self:GetChildComponent("Panel1/Bg/Buttons/BtnOK/Text", "Text").text = _("PageRequestReview_OK")
	self:GetChildComponent("Panel2/Bg/Buttons/BtnOK/Text", "Text").text = _("PageRequestReview_Review")
	self:GetChildComponent("Panel2/Bg/Buttons/BtnCancel/Text", "Text").text = _("PageRequestReview_Cancel")

	if vParam then
		if vParam.type == DlgRequestReview.ButtonType.YES_ONLY then
			self.Panel1:SetActive(true)
		else
			self.Panel2:SetActive(true)
		end

		self.Callback = vParam.callback
	end
end

function DlgRequestReview:OnClickedBtnOK()
	DlgRequestReview.base.Close(self)

	if self.Callback ~= nil then
		self.Callback(DlgRequestReview.EventType.CLICKED_YES)

		self.Callback = nil
	end
end

function DlgRequestReview:OnClickedBtnCancel()
	DlgRequestReview.base.Close(self)

	if self.Callback ~= nil then
		self.Callback(DlgRequestReview.EventType.CLICKED_NO)

		self.Callback = nil
	end
end

function DlgRequestReview:OnBackAndroid()
	self:OnClickedBtnCancel()
end
