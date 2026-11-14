-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePay/PagePayRule.lua

require("UI/UIScrollTool")
require("UI/Page/PagePay/RuleCell")

PagePayRule = class("PagePayRule", UIPanel)

function PagePayRule:ctor()
	PagePayRule.base.ctor(self, "UI/PanelPay/PanelShopRule")

	self.suffixes = {
		"terms_of_use",
		"privacy_policy",
		"act_on_specified_commercial_transactions",
		"payment_services_act"
	}
end

function PagePayRule:PreLoad()
	self.ruleCell = ResourceMgr.LoadSync("UI/PanelPay/RuleCell")
end

function PagePayRule:Cache()
	PagePayRule.base.Cache(self)
end

function PagePayRule:Purge()
	PagePayRule.base.Purge(self)
	self:OnLeave()
end

function PagePayRule:OnPageLoaded()
	return
end

function PagePayRule:OnEnter(vParam)
	self.mode = vParam.mode
	self.cb = vParam.cb
	self.cb_param = vParam.cb_param
	self.curIndex = vParam.curIndex
	self.showOrder = vParam.showOrder
	self.useForFirstLogin = vParam.mode == 1

	if self.useForFirstLogin then
		GOUtil.SetRectTransformSizeDeltaHeight(self:GetChildGameObject("Panel/Bg"), 637)

		local go_mode = self:GetChildGameObject("Panel/mode_1")

		GOUtil.SetActive(go_mode, true)

		self.btnClose = self:GetChildGameObject("Panel/mode_1/close")
		self:GetChildComponent("Panel/mode_1/close/text", "Text").text = _("PageOtherMenu_rule_false")
		self.btnAgree = self:GetChildGameObject("Panel/mode_1/agree")
		self:GetChildComponent("Panel/mode_1/agree/text", "Text").text = _("PageOtherMenu_rule_ture")
	else
		GOUtil.SetRectTransformSizeDeltaHeight(self:GetChildGameObject("Panel/Bg"), 750)

		local go_mode = self:GetChildGameObject("Panel/mode_2")

		GOUtil.SetActive(go_mode, true)

		self.btnClose = self:GetChildGameObject("Panel/mode_2/close")
	end

	self.btnBack = self:GetChildGameObject("Panel/Bg/content/btn_back")

	local scrollArea = self:GetChildGameObject("Panel/Bg/content/ScrollArea")

	self.content_scollrect = self:GetChildGameObject("Panel/Bg/content/ScrollArea")
	self.content_go = self:GetChildGameObject("Panel/Bg/content/ScrollArea/Content/Text")
	self.content_txt = self:GetChildComponent("Panel/Bg/content/ScrollArea/Viewport/Content", "UILongScrollItem")
	self.webview = self:GetChildComponent("Panel/WebView", "UniWebView")
	self:GetChildComponent("Panel/BtnGroup/Btn1/Text", "Text").text = _("PageShop_description_titel_1")
	self:GetChildComponent("Panel/BtnGroup/Btn2/Text", "Text").text = _("PageShop_description_titel_2")
	self:GetChildComponent("Panel/BtnGroup/Btn3/Text", "Text").text = _("PageShop_description_titel_3")
	self:GetChildComponent("Panel/BtnGroup/Btn4/Text", "Text").text = _("PageShop_description_3")
	self:GetChildComponent("Panel/BtnGroup/Select1/Text", "Text").text = _("PageShop_description_titel_1")
	self:GetChildComponent("Panel/BtnGroup/Select2/Text", "Text").text = _("PageShop_description_titel_2")
	self:GetChildComponent("Panel/BtnGroup/Select3/Text", "Text").text = _("PageShop_description_titel_3")
	self:GetChildComponent("Panel/BtnGroup/Select4/Text", "Text").text = _("PageShop_description_3")
	self:GetChildComponent("Panel/title/text", "Text").text = _("PageOtherMenu_rule2")

	if self.showOrder then
		local rootCanvas = GOUtil.FindChildComponent(self.UIRootObject, "", "Canvas")

		rootCanvas.sortingOrder = self.showOrder
	end

	for i = 1, 4 do
		self["Btn" .. i] = self:GetChildGameObject("Panel/BtnGroup/Btn" .. i)
		self["Select" .. i] = self:GetChildGameObject("Panel/BtnGroup/Select" .. i)
		self["Btn" .. i].name = i
	end

	self:UpdateGroupTab(self.curIndex)
end

function PagePayRule:OnLeave()
	for i = 1, 4 do
		self["Btn" .. i] = nil
		self["Select" .. i] = nil
	end
end

function PagePayRule:OnClickTop()
	GOUtil.SetScrollPosInt(self.content_scollrect)
end

function PagePayRule:OnRegisterEvent()
	for i = 1, 4 do
		self:AddClick(self["Btn" .. i], self.OnClickedBtn)
	end

	self:AddClick(self.btnRule, self.OnClickRule, PATH_SFX_UI_Click)
	self:AddClick(self.btnClose, self.CloseByBtn, PATH_SFX_UI_Click)
	self:AddClick(self.btnAgree, self.OnClickAgree, PATH_SFX_UI_Click)
	self:AddClick(self.btnBack, self.OnClickTop, PATH_SFX_UI_Click)
end

function PagePayRule:OnUnRegisterEvent()
	for i = 1, 4 do
		self:RemoveClick(self["Btn" .. i], self.OnClickedBtn)
	end

	self:RemoveClick(self.btnRule, self.OnClickRule)
	self:RemoveClick(self.btnClose, self.CloseByBtn)
	self:RemoveClick(self.btnAgree, self.OnClickAgree)
	self:RemoveClick(self.btnBack, self.OnClickTop)
end

function PagePayRule:CloseByBtn()
	if self.useForFirstLogin then
		PlayerPrefs.DeleteKey(PersistentStoreUtil.KEY_AUTHORIZE_ID)
	end

	self:Close()
end

function PagePayRule:Close()
	PagePayRule.base.Close(self)
end

function PagePayRule:OnRefreshText()
	InitTermsData()
	self.content_txt:Init()

	local prefix

	prefix = Application.platform:ToInt() == RuntimePlatform.Android and "google_" or "apple_"

	local key = prefix .. self.suffixes[self.curTabIndex]

	self.content_txt:AddDescription(tostring(GetTermsText(key)))
	GOUtil.SetScrollPosInt(self.content_scollrect)
end

function PagePayRule:UpdateGroupTab(index)
	self.curTabIndex = index

	for i = 1, 4 do
		if i == index then
			self["Btn" .. index]:SetActive(false)
			self["Select" .. index]:SetActive(true)
		else
			self["Btn" .. i]:SetActive(true)
			self["Select" .. i]:SetActive(false)
		end
	end

	if self.useForFirstLogin then
		for i = 3, 4 do
			self["Btn" .. i]:SetActive(false)
			self["Select" .. i]:SetActive(false)

			local j = i - 2

			GOUtil.SetRectTransformSizeDeltaWidth(self["Btn" .. j], 800)
			GOUtil.SetRectTransformSizeDeltaWidth(self["Select" .. j], 800)
			GOUtil.SetTransformLocalPosition(self["Btn" .. j], j * 800 - 1200, 0, 0)
			GOUtil.SetTransformLocalPosition(self["Select" .. j], j * 800 - 1200, 0, 0)
		end
	end

	self:OnRefreshText()
end

function PagePayRule:OnBack()
	UIMgr.PopPanel()
end

function PagePayRule:OnClickedBtn(data)
	local go = data.pointerPress
	local index = tonumber(go.name)

	self:UpdateGroupTab(index)
end

function PagePayRule:OnClickAgree()
	local function wrap_cb(res)
		LoadingMgr.Hide(eLoadingType.Repeat)
		self:Close()
		self.cb(res)
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:SendTermsVersion(wrap_cb)
end

function PagePayRule:OnBackAndroid()
	self:CloseByBtn()
end
