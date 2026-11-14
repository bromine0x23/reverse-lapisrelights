-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageSetting/DlgDownloadSetting.lua

DlgDownloadSetting = class("DlgDownloadSetting", UIPanel)

function DlgDownloadSetting:ctor()
	DlgDownloadSetting.base.ctor(self, "UI/PanelSetting/DlgDownloadSetting")
end

function DlgDownloadSetting:Purge()
	DlgDownloadSetting.base.Purge(self)
	self:OnLeave()
end

function DlgDownloadSetting:OnLeave()
	return
end

function DlgDownloadSetting:OnRegisterEvent()
	self:AddClick(self.Button_OK, self.OnButtonClick)
	self:AddClick(self.DelectBtn, self.OnSelfDelectClick)
	self.toggleAutoDelect.onValueChanged:AddListener(function(isOn)
		self:OnAutoDelect(isOn)
	end)
end

function DlgDownloadSetting:OnUnRegisterEvent()
	self:RemoveClick(self.Button_OK, self.OnButtonClick)
	self:RemoveClick(self.DelectBtn, self.OnSelfDelectClick)
	self.toggleAutoDelect.onValueChanged:RemoveListener(function(isOn)
		self:OnAutoDelect(isOn)
	end)
end

function DlgDownloadSetting:OnEnter(vParam)
	self.Button_OK = self:GetChildGameObject("TweenRoot/Main/Grid/Button_OK")
	self.DelectBtn = self:GetChildGameObject("TweenRoot/Main/Grid/DelectBtn")
	self.toggleAutoDelect = self:GetChildComponent("TweenRoot/Main/PanelSetting/Toggle", "Toggle")
	self.Label = self:GetChildComponent("TweenRoot/Main/PanelSetting/Toggle/Label", "Text")
	self.Text1 = self:GetChildComponent("TweenRoot/Main/PanelSetting/Text2", "TextView")
	self.AllSize = self:GetChildComponent("TweenRoot/Main/AllSize", "Text")
	self.toggleAutoDelect.isOn = PersistentStoreUtil.GetBool(PersistentStoreUtil.KEY_OPTIONAL_ASSET_AUTO_DELECT)
	self.Label_OK = self:GetChildComponent("TweenRoot/Main/Grid/Button_OK/Label_OK", "Text")
	self.Label_OK.text = _("UI_OK")
	self.Text = self:GetChildComponent("TweenRoot/Main/bg_title/Text", "Text")
	self.Text.text = _("Tip_ReserveSet")
	self.AllSize.text = OptionDownMgr:GetAllAlreadyDownSize()

	self:OnAutoDelect(self.toggleAutoDelect.isOn)
end

function DlgDownloadSetting:OnButtonClick()
	local isOn = self.toggleAutoDelect.isOn

	PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_OPTIONAL_ASSET_AUTO_DELECT, isOn)
	self:Close()
end

function DlgDownloadSetting:OnAutoDelect(isOn)
	self.Label.text = TenaryOp(isOn, _("Desc_OpenAutoDelect"), _("Desc_CloseAutoDelect"))
	self.Text1.Text = TenaryOp(isOn, _("Desc_OpenSave"), _("Desc_CloseNotSave"))
end

function DlgDownloadSetting:OnSelfDelectClick()
	self:OnButtonClick()
	UIMgr.ShowCommon(DlgCommonEvent.Type.Del, _("Desc_Alert"), _("Desc_SureDelectDown"), function(index)
		if index == 1 then
			local success = OptionDownMgr:DelectAlreadyDown()

			if success then
				UIMgr.ShowMsg(_("Desc_DelectFinish"))
			else
				UIMgr.ShowMsg(_("ダウンロード中　削除不可"))
			end
		end
	end, _("UI_OK"), _("Quite_Cancel"), false)
end

function DlgDownloadSetting:OnBackAndroid()
	self:OnButtonClick()
end
