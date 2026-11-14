-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgYesNo.lua

DlgYesNo = class("DlgYesNo", UIPanel)
DlgYesNo.ButtonType = {
	YES_NO = 2,
	YES_ONLY = 1,
	NONE = 0
}
DlgYesNo.EventType = {
	CLICKED_NO = 2,
	CLICKED_YES = 1,
	NONE = 0
}

function DlgYesNo:ctor()
	DlgYesNo.base.ctor(self, "UI/Common/DlgCommon/DlgYesNo")
end

function DlgYesNo:PreLoad()
	return
end

function DlgYesNo:Purge()
	DlgYesNo.base.Purge(self)
end

function DlgYesNo:OnRegisterEvent()
	self:AddClick(self.BtnYes, self.OnClickedBtnYes)
	self:AddClick(self.BtnNo, self.OnClickedBtnNo)
end

function DlgYesNo:OnUnRegisterEvent()
	self:RemoveClick(self.BtnYes, self.OnClickedBtnYes)
	self:RemoveClick(self.BtnNo, self.OnClickedBtnNo)
end

function DlgYesNo:OnEnter(vParam)
	self.BtnYes = self:GetChildGameObject("Panel/Commands/BtnYes")
	self.BtnNo = self:GetChildGameObject("Panel/Commands/BtnNo")

	self.BtnYes:SetActive(false)
	self.BtnNo:SetActive(false)

	self:GetChildComponent("Panel/Commands/BtnYes/Text", "Text").text = _("UI_Yes")
	self:GetChildComponent("Panel/Commands/BtnNo/Text", "Text").text = _("UI_No")

	if vParam then
		if vParam.type == DlgYesNo.ButtonType.YES_ONLY then
			self.BtnYes:SetActive(true)
		else
			self.BtnYes:SetActive(true)
			self.BtnNo:SetActive(true)
		end

		self.Callback = vParam.callback

		if vParam.title then
			self:GetChildComponent("Panel/Title/Text", "Text").text = vParam.title
		end

		if vParam.message then
			self:GetChildComponent("Panel/Group/Text", "Text").text = vParam.message
		end

		if vParam.yes_text then
			self:GetChildComponent("Panel/Commands/BtnYes/Text", "Text").text = vParam.yes_text
		end

		if vParam.no_text then
			self:GetChildComponent("Panel/Commands/BtnNo/Text", "Text").text = vParam.no_text
		end
	end
end

function DlgYesNo:OnClickedBtnYes()
	DlgYesNo.base.Close(self)

	if self.Callback ~= nil then
		self.Callback(DlgYesNo.EventType.CLICKED_YES)

		self.Callback = nil
	end
end

function DlgYesNo:OnClickedBtnNo()
	DlgYesNo.base.Close(self)

	if self.Callback ~= nil then
		self.Callback(DlgYesNo.EventType.CLICKED_NO)

		self.Callback = nil
	end
end
