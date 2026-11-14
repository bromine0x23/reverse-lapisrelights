-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/DlgCommon.lua

require("UI/UIPanel")

DlgCommon = class("DlgCommon", UIPanel)
DlgCommon.ButtonType = {
	Other = 3,
	OK = 1,
	Adjust = 5,
	Mask = 0,
	Cancel = 2,
	Info = 4
}
DlgCommon.CallBack = nil
DlgCommon.Label_Title = nil
DlgCommon.Label_Message = nil
DlgCommon.Button_OK = nil
DlgCommon.Button_Cancel = nil
DlgCommon.Button_Mask = nil
DlgCommon.Button_Info = nil
DlgCommon.Button_Adjuest = nil

function DlgCommon:ctor()
	self.UIPrefabPath = "UI/CommonTip/CommonTip/CommonTip"
end

function DlgCommon:OnEnter(vParam)
	self.UIRootObject:SetActive(false)

	self.Label_Title = self:GetChildComponent("TweenRoot/Label_Title", "Text")
	self.Label_Message = self:GetChildComponent("TweenRoot/Label_Message", "Text")
	self.Label_OK = self:GetChildComponent("TweenRoot/Grid/Button_OK/Label_OK", "Text")
	self.Label_Cancel = self:GetChildComponent("TweenRoot/Grid/Button_Cancel/Label_Cancel", "Text")
	self.Label_Other = self:GetChildComponent("TweenRoot/Grid/Button_Other/Label_Other", "Text")
	self.Label_OK.text = Localization("UI_OK")
	self.Label_Cancel.text = Localization("Desc_Sure")
	self.Button_OK = self:GetChildGameObject("TweenRoot/Grid/Button_OK")
	self.Button_Cancel = self:GetChildGameObject("TweenRoot/Grid/Button_Cancel")
	self.Button_OK.name = DlgCommon.ButtonType.OK
	self.Button_Cancel.name = DlgCommon.ButtonType.Cancel
end

function DlgCommon:OnRegisterEvent()
	self:AddClick(self.Button_OK, self.OnButtonClick)
	self:AddClick(self.Button_Cancel, self.OnButtonClick)
end

function DlgCommon:OnUnRegisterEvent()
	self:RemoveClick(self.Button_OK, self.OnButtonClick)
	self:RemoveClick(self.Button_Cancel, self.OnButtonClick)
end

function DlgCommon:OnButtonClick(data)
	local go = data.pointerPress
	local index = tonumber(go.name)

	if self.CallBack ~= nil then
		self.CallBack(index)
	end

	self.UIRootObject:SetActive(false)
end

function DlgCommon:Hide()
	self.UIRootObject:SetActive(false)
end

function DlgCommon:Show(strMsg, vCallBack)
	self.UIRootObject:SetActive(true)

	self.Label_Message.text = strMsg
	self.CallBack = vCallBack
end

function DlgCommon:ShowWithText(vCallBack, vMsg, vTitle, vOkBtn)
	self.UIRootObject:SetActive(true)

	self.Label_Message.text = vMsg
	self.Label_OK.text = vOkBtn
	self.Label_Title.text = vTitle
	self.CallBack = vCallBack
end
