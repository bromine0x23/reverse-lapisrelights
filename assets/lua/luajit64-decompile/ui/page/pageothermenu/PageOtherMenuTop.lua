-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageOtherMenu/PageOtherMenuTop.lua

require("UI/Page/PagePay/PagePayRule")
require("UI/Page/PageOtherMenu/PageCopyright")
require("UI/Page/PageOtherMenu/PageUserSupport")
require("UI/Page/PagePay/PageHistory")
require("UI/Page/PagePay/PagePay")
require("UI/Page/PageLogin/Account/PagePlatformSelect")

PageOtherMenuTop = class("PageOtherMenuTop", UIPanel)

function PageOtherMenuTop:ctor()
	PageOtherMenuTop.base.ctor(self, "UI/PageOtherMenu/PageOtherMenuTop")
end

function PageOtherMenuTop:OnPageLoaded()
	return
end

function PageOtherMenuTop:OnEnter(vParms)
	local function wrap_cb(res)
		LoadingMgr.Hide(eLoadingType.Repeat)
		GameServiceSupport.GetInstance():ReportScore(res.cleared_ids)
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:GetClearedPlatformAchievement(wrap_cb)

	self:GetChildComponent("title/text", "Text").text = Localization("PageOtherMenu_title")
	self.btnClose = self:GetChildComponent("close", "Button")
	self:GetChildComponent("PanelMenu/achievement/tit_text", "Text").text = Localization("PageOtherMenu_achievement")
	self.btnAchievement = self:GetChildComponent("PanelMenu/achievement", "Button")
	self:GetChildComponent("PanelMenu/rule/tit_text", "Text").text = Localization("PageOtherMenu_rule")
	self.btnRule = self:GetChildComponent("PanelMenu/rule", "Button")
	self:GetChildComponent("PanelMenu/support/tit_text", "Text").text = Localization("PageOtherMenu_support")
	self.btnSupport = self:GetChildComponent("PanelMenu/support", "Button")
	self:GetChildComponent("PanelMenu/copyright/tit_text", "Text").text = Localization("PageOtherMenu_copyright")
	self.btnCopyright = self:GetChildComponent("PanelMenu/copyright", "Button")
	self:GetChildComponent("PanelMenu/pay_history/tit_text", "Text").text = Localization("PageOtherMenu_pay_history")
	self.btnPayHistory = self:GetChildComponent("PanelMenu/pay_history", "Button")
	self:GetChildComponent("PanelMenu/shop/tit_text", "Text").text = Localization("PageOtherMenu_shop")
	self.btnShop = self:GetChildComponent("PanelMenu/shop", "Button")
	self:GetChildComponent("PanelMenu/account_link/tit_text", "Text").text = Localization("PageOtherMenu_account_link")
	self.btnAccountLink = self:GetChildComponent("PanelMenu/account_link", "Button")
	self.btnReview = self:GetChildComponent("PanelMenu/review", "Button")
end

function PageOtherMenuTop:OnLeave()
	self.btnAchievement = nil
	self.btnRule = nil
	self.btnSupport = nil
	self.btnCopyright = nil
	self.btnPayHistory = nil
	self.btnShop = nil
	self.btnAccountLink = nil
	self.btnReview = nil
	self.btnClose = nil
end

function PageOtherMenuTop:OnRegisterEvent()
	self:AddClick(self.btnAchievement.gameObject, self.OnClickedAchievement)
	self:AddClick(self.btnRule.gameObject, self.OnClickedRule)
	self:AddClick(self.btnSupport.gameObject, self.OnClickedSupport)
	self:AddClick(self.btnCopyright.gameObject, self.OnClickedCopyright)
	self:AddClick(self.btnPayHistory.gameObject, self.OnClickedPayHistory)
	self:AddClick(self.btnShop.gameObject, self.OnClickedShop)
	self:AddClick(self.btnAccountLink.gameObject, self.OnClickedAccountLink)
	self:AddClick(self.btnReview.gameObject, self.OnClickedReview)
	self:AddClick(self.btnClose.gameObject, self.OnClickedBack)
end

function PageOtherMenuTop:OnUnRegisterEvent()
	self:RemoveClick(self.btnAchievement.gameObject, self.OnClickedAchievement)
	self:RemoveClick(self.btnRule.gameObject, self.OnClickedRule)
	self:RemoveClick(self.btnSupport.gameObject, self.OnClickedSupport)
	self:RemoveClick(self.btnCopyright.gameObject, self.OnClickedCopyright)
	self:RemoveClick(self.btnPayHistory.gameObject, self.OnClickedPayHistory)
	self:RemoveClick(self.btnShop.gameObject, self.OnClickedShop)
	self:RemoveClick(self.btnAccountLink.gameObject, self.OnClickedAccountLink)
	self:RemoveClick(self.btnReview.gameObject, self.OnClickedReview)
	self:RemoveClick(self.btnClose.gameObject, self.OnClickedBack)
end

function PageOtherMenuTop:OnClickedAchievement()
	local function wrap_cb()
		UIMgr.ShowDialog(Localization("PageOtherMenu_plz_signin_gc"), nil)
	end

	GameServiceSupport.GetInstance():ShowAchievements(wrap_cb)
end

function PageOtherMenuTop:OnClickedRule()
	UIMgr.AddPanel(PagePayRule(), {
		curIndex = 1,
		mode = 2
	})
end

function PageOtherMenuTop:OnClickedSupport()
	UIMgr.AddPanel(PageUserSupport(), {})
end

function PageOtherMenuTop:OnClickedCopyright()
	UIMgr.AddPanel(PageCopyright(), {})
end

function PageOtherMenuTop:OnClickedPayHistory()
	UIMgr.AddPanel(PageHistory(), {})
	self:Close()
end

function PageOtherMenuTop:OnClickedShop()
	UIMgr.SwitchPanel(PagePay)
	self:Close()
end

function PageOtherMenuTop:OnClickedAccountLink()
	UIMgr.AddPanel(PagePlatformSelect(), {
		useForLogin = false
	})
end

function PageOtherMenuTop:OnClickedReview()
	if Application.platform:ToInt() == RuntimePlatform.Android then
		-- block empty
	else
		Jackpot.Platform.StoreReview()
	end
end

function PageOtherMenuTop:Purge()
	PageOtherMenuTop.base.Purge(self)
	self:OnLeave()
end

function PageOtherMenuTop:OnClickedBack()
	self:Close()
end
