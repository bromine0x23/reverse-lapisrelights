-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Public/DlgSout.lua

eWebviewShowType = {
	EveryLogin = 1,
	None = 0
}
DlgSout = class("DlgSout", UIPanel)

function DlgSout:ctor()
	self.UIPrefabPath = "UI/PanelLogin/DlgSout"
end

function DlgSout.hex_to_char(x)
	return string.char(tonumber(x, 16))
end

function DlgSout.Unescape(url_path)
	return url_path:gsub("%%(%x%x)", DlgSout.hex_to_char)
end

function DlgSout:OnNetBack(url)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if url then
		self.webView:Load(url)
	end
end

function DlgSout:OnEnter(vParam)
	self.ActionButton = self:GetChildGameObject("webView/ActBtn")
	self.webView = self:GetChildComponent("webView/UniWebView", "UniWebView")

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
		elseif message.Path == "getToken" then
			if self.isTokenRequest then
				return
			end

			self.isTokenRequest = true

			local preUserId = PlayerPrefs.GetString("PRE_USER_ID", "")
			local longId = preUserId == "" and 0 or tonumber(preUserId)

			LoadingMgr.Show(eLoadingType.Repeat)
			NetworkManager.ConnectorGate:FetchSoutToken(longId, wrapedCb(self.OnNetBack, self))
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

	self.webView:LoadHTMLString(vParam.content, "https://www.lapis.com")
	self.webView:Show()
end

function DlgSout:OnBackAndroid()
	return
end
