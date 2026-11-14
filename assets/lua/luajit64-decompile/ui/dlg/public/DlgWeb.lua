-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Public/DlgWeb.lua

eWebviewShowType = {
	EveryLogin = 1,
	None = 0
}
DlgWeb = class("DlgWeb", UIPanel)

function DlgWeb:ctor()
	self.UIPrefabPath = "UI/Public/DlgWebView"
end

function DlgWeb:OnRegisterEvent()
	Event.Instance:Add("DisconnectEvent", self.OnClickedButton, self)
	self:AddClick(self.Button, self.OnClickedButton)
	self:AddClick(self.ButtonBg, self.OnClickedButton)
	self:AddClick(self.NotAgainBtn, self.OnNotAgainBtn)
end

function DlgWeb:OnUnRegisterEvent()
	Event.Instance:Remove("DisconnectEvent", self.OnClickedButton, self)
	self:RemoveClick(self.Button, self.OnClickedButton)
	self:RemoveClick(self.ButtonBg, self.OnClickedButton)
	self:RemoveClick(self.NotAgainBtn, self.OnNotAgainBtn)
end

function DlgWeb:OnClickedButton()
	Event.Instance:Fire("DealWithUIAnim", false)
	Object.Destroy(self.webView)

	self.webView = nil

	self:Close()

	if self.callback then
		self.callback()

		self.callback = nil
	end
end

function DlgWeb:OnNotAgainBtn()
	if self.Toggol.activeSelf then
		PersistentStoreUtil.SetInt("DlgWebIsNotAagin", 0)
		self.Toggol:SetActive(false)
	else
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

		PersistentStoreUtil.SetInt("DlgWebIsNotAagin", curServerTime)
		self.Toggol:SetActive(true)
	end
end

function DlgWeb.hex_to_char(x)
	return string.char(tonumber(x, 16))
end

function DlgWeb.Unescape(url_path)
	return url_path:gsub("%%(%x%x)", DlgWeb.hex_to_char)
end

function DlgWeb:OnEnter(vParam)
	self.Button = self:GetChildGameObject("webView/Button")
	self.ButtonBg = self:GetChildGameObject("webView/ButtonBg")
	self.Position = self:GetChildGameObject("webView/Position")
	self.NotAgainBtn = self:GetChildGameObject("webView/NotAgainBtn")
	self.Toggol = self:GetChildGameObject("webView/NotAgainBtn/Toggol")
	self.webView = self:GetChildComponent("webView/UniWebView", "UniWebView")
	self.loadingText = self:GetChildGameObject("webView/loading_txt")
	self:GetChildComponent("webView/NotAgainBtn/Text", "Text").text = _("Desc_ToDay_No_Tips")
	OperationActiveMgr.isShowWebView = true

	local time = PersistentStoreUtil.GetInt("DlgWebIsNotAagin", 0)

	if time <= 0 or TimeIsNotToday(time * 1000) then
		self.Toggol:SetActive(false)
	else
		self.Toggol:SetActive(true)
	end

	self.NotAgainBtn:SetActive(vParam.isAuto)

	if vParam then
		self.callback = vParam.callback
	end

	local playerId = PlayerInst.InfoPlayer.pid

	local function OnShouldClose(view)
		return false
	end

	self.webView.OnShouldClose = self.webView.OnShouldClose + OnShouldClose

	local function hex_to_char(x)
		return string.char(tonumber(x, 16))
	end

	local function unescape(url)
		return url:gsub("%%(%x%x)", hex_to_char)
	end

	local function OnMessageReceived(view, message)
		if message.Path == "getReward" then
			local rewardId = message.Args:get_Item("id")

			if rewardId == nil then
				return
			end

			self:RequestReward(tonumber(rewardId))
		elseif message.Path == "pageFinish" then
			self:OnPageFinished()
		elseif message.Path == "setRead" then
			local noticeId = message.Args:get_Item("id")
			local noticeBegin = message.Args:get_Item("begin")

			WebNoticeRDL.SetRead(noticeId, noticeBegin)
		elseif message.Path == "openUrl" then
			local urlPath = message.Args:get_Item("path")
			local unDecodePath, n = unescape(urlPath)

			Application.OpenURL(unDecodePath)
		end
	end

	self.webView.OnMessageReceived = self.webView.OnMessageReceived + OnMessageReceived

	local function OnPageLoaded(view, code, url)
		self.loadingText:SetActive(false)
	end

	self.webView.OnPageFinished = self.webView.OnPageFinished + OnPageLoaded

	self.webView:Load(InfoGameInst.gameInfo.webUrl .. "&tips=" .. _("Msg_GetRewardSuccess") .. "&inLapisGame=true")
end

function DlgWeb:OnPageFinished()
	self.webView:Show()
end

function DlgWeb:RequestReward(id)
	local function callback(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			local function backhandle(payload)
				return
			end

			self.webView:EvaluateJavaScript("receiveUnityMessage('success');", backhandle)
		end
	end

	NetManager:RequestWebviewReward(id, callback)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgWeb:OnBackAndroid()
	self:OnClickedButton()
end
