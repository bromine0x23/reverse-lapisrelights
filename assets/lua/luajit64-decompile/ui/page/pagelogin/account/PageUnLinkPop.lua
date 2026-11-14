-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/Account/PageUnLinkPop.lua

PageUnLinkPop = class("PageUnLinkPop", UIPanel)

function PageUnLinkPop:ctor()
	PageUnLinkPop.base.ctor(self, "UI/PanelLogin/PanelUnLinkPop")
end

function PageUnLinkPop:Cache()
	PageUnLinkPop.base.Cache(self)
end

function PageUnLinkPop:Purge()
	PageUnLinkPop.base.Purge(self)
	self:OnLeave()
end

function PageUnLinkPop:OnPageLoaded()
	return
end

function PageUnLinkPop:OnEnter(vParam)
	self:GetChildComponent("PanelServers/btnGroup/sure/Text", "Text").text = Localization("PagePlatform__ok")
	self:GetChildComponent("PanelServers/btnGroup/cancel/Text", "Text").text = Localization("PagePlatform__cancel")
	self.outerParm = vParam
	self.btnSure = self:GetChildGameObject("PanelServers/btnGroup/sure")
	self.btnCancel = self:GetChildGameObject("PanelServers/btnGroup/cancel")
	self:GetChildComponent("PanelServers/panel2/tip_txt1", "Text").text = _("PagePlatform_account_binding_description_1")
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
	self.panel2_role_playerid_val.text = self.outerParm.data.user_id
	self.panel2_role_nick_val.text = self.outerParm.data.name
	self.panel2_role_level_val.text = self.outerParm.data.rank
	self.panel2_role_paid_val.text = self.outerParm.data.payment_sns_coin
	self.panel2_role_free_val.text = self.outerParm.data.free_sns_coin
	self:GetChildComponent("PanelServers/title/text", "Text").text = _("PagePlatform_account_binding_false_choice_or_no")
end

function PageUnLinkPop:OnLeave()
	return
end

function PageUnLinkPop:OnRegisterEvent()
	self:AddClick(self.btnCancel, self.OnCancel, PATH_SFX_Cancle)
	self:AddClick(self.btnSure, self.OnSure)
end

function PageUnLinkPop:OnUnRegisterEvent()
	self:RemoveClick(self.btnCancel, self.OnCancel)
	self:RemoveClick(self.btnSure, self.OnSure)
end

function PageUnLinkPop:OnSure()
	if self.outerParm.cb then
		self.outerParm.cb()
		self:Close()
	end
end

function PageUnLinkPop:OnCancel()
	self:Close()
end
