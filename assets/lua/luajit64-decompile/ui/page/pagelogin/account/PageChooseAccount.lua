-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/Account/PageChooseAccount.lua

PageChooseAccount = class("PageChooseAccount", UIPanel)

function PageChooseAccount:ctor()
	PageChooseAccount.base.ctor(self, "UI/PanelLogin/PanelPlayerSelect")
end

function PageChooseAccount:Cache()
	PageChooseAccount.base.Cache(self)
end

function PageChooseAccount:Purge()
	PageChooseAccount.base.Purge(self)
	self:OnLeave()
end

function PageChooseAccount:OnPageLoaded()
	return
end

function PageChooseAccount:OnEnter(vParam)
	self.panelRoleChange = self:GetChildGameObject("PanelServers/panel1")
	self.panelRoleSure = self:GetChildGameObject("PanelServers/panel2")
	self:GetChildComponent("PanelServers/btnGroup/sure/Text", "Text").text = Localization("PagePlatform__ok")
	self:GetChildComponent("PanelServers/btnGroup/cancel/Text", "Text").text = Localization("PagePlatform__cancel")
	self.outerParm = vParam
	self.btnSure = self:GetChildGameObject("PanelServers/btnGroup/sure")
	self.btnCancel = self:GetChildGameObject("PanelServers/btnGroup/cancel")

	if vParam.data.role2 then
		self.panelRoleChange:SetActive(true)
		self.panelRoleSure:SetActive(false)

		if self.outerParm.useForLogin then
			self:GetChildComponent("PanelServers/panel1/tip_txt1", "Text").text = Localization("PagePlatform_description_6")
			self:GetChildComponent("PanelServers/panel1/tip_txt2", "Text").text = Localization("PagePlatform_description_7")
		else
			self:GetChildComponent("PanelServers/panel1/tip_txt1", "Text").text = Localization("PagePlatform_description_4")
			self:GetChildComponent("PanelServers/panel1/tip_txt2", "Text").text = Localization("PagePlatform_description_5")
		end

		self:GetChildComponent("PanelServers/panel1/frame1/title/txt", "Text").text = Localization("PagePlatform_before_change")
		self:GetChildComponent("PanelServers/panel1/frame2/title/txt", "Text").text = Localization("PagePlatform_after_change")
		self.panel1_role1_playerid_val = self:GetChildComponent("PanelServers/panel1/frame1/content_player/content", "Text")
		self.panel1_role1_nick_val = self:GetChildComponent("PanelServers/panel1/frame1/content_name/content", "Text")
		self.panel1_role1_level_val = self:GetChildComponent("PanelServers/panel1/frame1/content_rank/content", "Text")
		self.panel1_role1_paid_val = self:GetChildComponent("PanelServers/panel1/frame1/content_nofree/content", "Text")
		self.panel1_role1_free_val = self:GetChildComponent("PanelServers/panel1/frame1/content_free/content", "Text")
		self.panel1_role2_playerid_val = self:GetChildComponent("PanelServers/panel1/frame2/content_player/content", "Text")
		self.panel1_role2_nick_val = self:GetChildComponent("PanelServers/panel1/frame2/content_name/content", "Text")
		self.panel1_role2_level_val = self:GetChildComponent("PanelServers/panel1/frame2/content_rank/content", "Text")
		self.panel1_role2_paid_val = self:GetChildComponent("PanelServers/panel1/frame2/content_nofree/content", "Text")
		self.panel1_role2_free_val = self:GetChildComponent("PanelServers/panel1/frame2/content_free/content", "Text")

		if self.outerParm.useForLogin then
			self.panel1_role1_playerid_val.text = self.outerParm.data.role1.user_id
			self.panel1_role1_nick_val.text = self.outerParm.data.role1.name == "" and _("PagePlatform_nick_no_set") or self.outerParm.data.role1.name
			self.panel1_role1_level_val.text = self.outerParm.data.role1.rank
			self.panel1_role1_paid_val.text = self.outerParm.data.role1.payment_sns_coin
			self.panel1_role1_free_val.text = self.outerParm.data.role1.free_sns_coin
			self.panel1_role2_playerid_val.text = self.outerParm.data.role2.user_id
			self.panel1_role2_nick_val.text = self.outerParm.data.role2.name
			self.panel1_role2_level_val.text = self.outerParm.data.role2.rank
			self.panel1_role2_paid_val.text = self.outerParm.data.role2.payment_sns_coin
			self.panel1_role2_free_val.text = self.outerParm.data.role2.free_sns_coin
		else
			self.panel1_role1_playerid_val.text = self.outerParm.data.role2.user_id
			self.panel1_role1_nick_val.text = self.outerParm.data.role2.name
			self.panel1_role1_level_val.text = self.outerParm.data.role2.rank
			self.panel1_role1_paid_val.text = self.outerParm.data.role2.payment_sns_coin
			self.panel1_role1_free_val.text = self.outerParm.data.role2.free_sns_coin
			self.panel1_role2_playerid_val.text = self.outerParm.data.role1.user_id
			self.panel1_role2_nick_val.text = self.outerParm.data.role1.name
			self.panel1_role2_level_val.text = self.outerParm.data.role1.rank
			self.panel1_role2_paid_val.text = self.outerParm.data.role1.payment_sns_coin
			self.panel1_role2_free_val.text = self.outerParm.data.role1.free_sns_coin
		end

		self:GetChildComponent("PanelServers/panel1/frame1/content_player/Image/title", "Text").text = Localization("PagePlatform_account_id")
		self:GetChildComponent("PanelServers/panel1/frame1/content_name/Image/title", "Text").text = Localization("PagePlatform_user_name")
		self:GetChildComponent("PanelServers/panel1/frame1/content_rank/Image/title", "Text").text = Localization("PagePlatform__lv")
		self:GetChildComponent("PanelServers/panel1/frame1/content_nofree/Image/title", "Text").text = Localization("PagePlatform_pay_money")
		self:GetChildComponent("PanelServers/panel1/frame1/content_free/Image/title", "Text").text = Localization("PagePlatform_free_money")
		self:GetChildComponent("PanelServers/panel1/frame2/content_player/Image/title", "Text").text = Localization("PagePlatform_account_id")
		self:GetChildComponent("PanelServers/panel1/frame2/content_name/Image/title", "Text").text = Localization("PagePlatform_user_name")
		self:GetChildComponent("PanelServers/panel1/frame2/content_rank/Image/title", "Text").text = Localization("PagePlatform__lv")
		self:GetChildComponent("PanelServers/panel1/frame2/content_nofree/Image/title", "Text").text = Localization("PagePlatform_pay_money")
		self:GetChildComponent("PanelServers/panel1/frame2/content_free/Image/title", "Text").text = Localization("PagePlatform_free_money")
	else
		self.panelRoleChange:SetActive(false)
		self.panelRoleSure:SetActive(true)

		if self.outerParm.useForLogin then
			self:GetChildComponent("PanelServers/panel2/tip_txt1", "Text").text = Localization("PagePlatform_description_11")
		else
			self:GetChildComponent("PanelServers/panel2/tip_txt1", "Text").text = Localization("PagePlatform_description_3")
		end

		self.panel2_role_playerid_val = self:GetChildComponent("PanelServers/panel2/frame1/content_player/content", "Text")
		self.panel2_role_nick_val = self:GetChildComponent("PanelServers/panel2/frame1/content_name/content", "Text")
		self.panel2_role_level_val = self:GetChildComponent("PanelServers/panel2/frame1/content_rank/content", "Text")
		self.panel2_role_paid_val = self:GetChildComponent("PanelServers/panel2/frame1/content_nofree/content", "Text")
		self.panel2_role_free_val = self:GetChildComponent("PanelServers/panel2/frame1/content_free/content", "Text")
		self:GetChildComponent("PanelServers/panel2/frame1/content_player/Image/title", "Text").text = Localization("PagePlatform_account_id")
		self:GetChildComponent("PanelServers/panel2/frame1/content_name/Image/title", "Text").text = Localization("PagePlatform_user_name")
		self:GetChildComponent("PanelServers/panel2/frame1/content_rank/Image/title", "Text").text = Localization("PagePlatform__lv")
		self:GetChildComponent("PanelServers/panel2/frame1/content_nofree/Image/title", "Text").text = Localization("PagePlatform_pay_money")
		self:GetChildComponent("PanelServers/panel2/frame1/content_free/Image/title", "Text").text = Localization("PagePlatform_free_money")
		self.panel2_role_playerid_val.text = self.outerParm.data.role1.user_id
		self.panel2_role_nick_val.text = self.outerParm.data.role1.name
		self.panel2_role_level_val.text = self.outerParm.data.role1.rank
		self.panel2_role_paid_val.text = self.outerParm.data.role1.payment_sns_coin
		self.panel2_role_free_val.text = self.outerParm.data.role1.free_sns_coin
	end

	if self.outerParm.useForLogin then
		self:GetChildComponent("PanelServers/title/text", "Text").text = Localization("PagePlatform_account_login_choice_or_no_2")
	else
		self:GetChildComponent("PanelServers/title/text", "Text").text = Localization("PagePlatform_account_choice_or_no")
	end
end

function PageChooseAccount:OnLeave()
	return
end

function PageChooseAccount:OnRegisterEvent()
	self:AddClick(self.btnCancel, self.OnCancel, PATH_SFX_Cancle)
	self:AddClick(self.btnSure, self.OnSure)
end

function PageChooseAccount:OnUnRegisterEvent()
	self:RemoveClick(self.btnCancel, self.OnCancel)
	self:RemoveClick(self.btnSure, self.OnSure)
end

function PageChooseAccount:OnSure()
	if self.outerParm.useForLogin then
		self.outerParm.call_back()
		self:Close()
	else
		local function wrap_cb(...)
			LoadingMgr.Hide(eLoadingType.Repeat)
			self:OnResLink(...)
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:StartLink(self.outerParm.data.ctrl, self.outerParm.data.type, wrap_cb)
	end
end

function PageChooseAccount:OnResLink(vMsg)
	self:Close()

	if vMsg.result.code == NetManager.Result_Sucess then
		UIMgr.ShowMsg("連携に成功しました")
		self.outerParm.call_back(self.outerParm.data.type)
	else
		UIMgr.ShowMsg("連携に失敗しました")
	end
end

function PageChooseAccount:OnCancel()
	if self.outerParm and self.outerParm.call_back_cancel then
		self.outerParm.call_back_cancel()
	end

	self:Close()
end

function PageChooseAccount:OnBackAndroid()
	self:OnCancel()
end
