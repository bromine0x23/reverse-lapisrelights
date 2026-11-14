-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/Account/PagePlatformSelect.lua

require("UI/Page/PageLogin/Account/PageChooseAccount")
require("UI/Page/PageLogin/Account/DataLinkProcess")

PagePlatformSelect = class("PagePlatformSelect", UIPanel)

function PagePlatformSelect:ctor()
	PagePlatformSelect.base.ctor(self, "UI/PanelLogin/PlatformLink")
end

function PagePlatformSelect:OnPageLoaded()
	return
end

function PagePlatformSelect:OnLinkChange(go, isLink)
	local img1 = GOUtil.FindChildComponent(go, "", "Image")

	UIUtil.SetImageSprite(img1, isLink and "UI/PanelLogin/AtlasAccount/BTN_jp_001_selected" or "UI/PanelLogin/AtlasAccount/BTN_jp_001_normal")

	local sta_txt = GOUtil.FindChildComponent(go, "grid/sta_text", "Text")

	sta_txt.text = isLink and _("PagePlatform_account_binding_false") or _("PagePlatform_not_choice")
	sta_txt.color = isLink and Color.New(0.28627450980392155, 0.6352941176470588, 0.7647058823529411) or Color.New(0.5019607843137255, 0.5019607843137255, 0.5019607843137255)
end

function PagePlatformSelect:OnEnter(vParms)
	self.useForLogin = vParms.useForLogin
	self.btnFB = self:GetChildComponent("PanelServers/grid/fb", "Button")
	self.btnTwitter = self:GetChildComponent("PanelServers/grid/tw", "Button")
	self.btnKlabID = self:GetChildComponent("PanelServers/grid/klabid", "Button")
	self.btnGameCenter = self:GetChildComponent("PanelServers/grid/gc", "Button")
	self.btnGooglePlay = self:GetChildComponent("PanelServers/grid/gp", "Button")
	self.btnAppleId = self:GetChildComponent("PanelServers/grid/appleid", "Button")
	self.btnClose = self:GetChildComponent("PanelServers/close", "Button")
	self.viewTitle = self:GetChildComponent("PanelServers/title/text", "Text")

	self.btnGameCenter.gameObject:SetActive(false)
	self.btnGooglePlay.gameObject:SetActive(false)
	self.btnAppleId.gameObject:SetActive(false)

	self.btnFB_title = self:GetChildComponent("PanelServers/grid/fb/tit_text", "Text")
	self.btnTwitter_title = self:GetChildComponent("PanelServers/grid/tw/tit_text", "Text")
	self.btnKlabID_title = self:GetChildComponent("PanelServers/grid/klabid/tit_text", "Text")
	self.btnGameCenter_title = self:GetChildComponent("PanelServers/grid/gc/tit_text", "Text")
	self.btnGooglePlay_title = self:GetChildComponent("PanelServers/grid/gp/tit_text", "Text")
	self.btnAppleId_title = self:GetChildComponent("PanelServers/grid/appleid/tit_text", "Text")
	self.stateGooglePlay = self:GetChildComponent("PanelServers/grid/gp/grid/sta_text", "Text")
	self.stateGameCenter = self:GetChildComponent("PanelServers/grid/gc/grid/sta_text", "Text")
	self.stateKlabID = self:GetChildComponent("PanelServers/grid/klabid/grid/sta_text", "Text")
	self.stateTwitter = self:GetChildComponent("PanelServers/grid/tw/grid/sta_text", "Text")
	self.stateFB = self:GetChildComponent("PanelServers/grid/fb/grid/sta_text", "Text")
	self.stateAppleId = self:GetChildComponent("PanelServers/grid/appleid/grid/sta_text", "Text")
	self.stateGooglePlay.text = _("PagePlatform_not_choice")
	self.stateGameCenter.text = _("PagePlatform_not_choice")
	self.stateKlabID.text = _("PagePlatform_not_choice")
	self.stateTwitter.text = _("PagePlatform_not_choice")
	self.stateFB.text = _("PagePlatform_not_choice")
	self.stateAppleId.text = _("PagePlatform_not_choice")
	self.desc_txt1 = self:GetChildComponent("PanelServers/tip_text1", "Text")
	self.desc_txt2 = self:GetChildComponent("PanelServers/tip_text2", "Text")
	self.viewTitle.text = Localization(self.useForLogin and "PagePlatform_account_login" or "PagePlatform_1")
	self.btnFB_title.text = Localization("PagePlatform_Facebook")
	self.btnTwitter_title.text = Localization("PagePlatform_Twitter")
	self.btnKlabID_title.text = Localization("PagePlatform_Klabid")
	self.btnGameCenter_title.text = Localization("PagePlatform_GameCenter")
	self.btnGooglePlay_title.text = Localization("PagePlatform_GooglePlay")
	self.btnAppleId_title.text = "Apple ID"
	self.desc_txt1.text = Localization("PagePlatform_description_1")
	self.desc_txt2.text = Localization("PagePlatform_description_2")

	self:CheckPlatform(vParms.useForLogin)

	if self.useForLogin then
		if not GateServer.IsConnect then
			GateServer:Connect(NetManager.Host, NetManager.Port)
		end
	else
		self:Show(false)

		local function wrap_cb(res)
			LoadingMgr.Hide(eLoadingType.Repeat)
			self:onLinkStateGetted(res)
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:FetchLinkState(wrap_cb)
	end
end

function PagePlatformSelect:onLinkStateGetted(result)
	self.linkState = {}

	for k, v in pairs(result.services) do
		if v == protocol_pb.game_center then
			self:OnLinkChange(self.btnGameCenter.gameObject, true)
		elseif v == protocol_pb.google_play then
			self:OnLinkChange(self.btnGooglePlay.gameObject, true)
		elseif v == protocol_pb.twitter then
			self:OnLinkChange(self.btnTwitter.gameObject, true)
		elseif v == protocol_pb.facebook then
			self:OnLinkChange(self.btnFB.gameObject, true)
		elseif v == protocol_pb.klab_id then
			self:OnLinkChange(self.btnKlabID.gameObject, true)
		elseif v == protocol_pb.apple_id then
			self:OnLinkChange(self.btnAppleId.gameObject, true)
		end

		table.insert(self.linkState, v)
	end

	self:Show(true)
end

function PagePlatformSelect:CheckPlatform(isLogin)
	if isLogin then
		self.stateGooglePlay.gameObject:SetActive(false)
		self.stateGameCenter.gameObject:SetActive(false)
		self.stateKlabID.gameObject:SetActive(false)
		self.stateTwitter.gameObject:SetActive(false)
		self.stateFB.gameObject:SetActive(false)
		self.stateAppleId.gameObject:SetActive(false)
	end

	if Application.platform:ToInt() == RuntimePlatform.IPhonePlayer then
		if SystemUtil.IsIos13() then
			self.btnAppleId.gameObject:SetActive(true)
		end

		self.btnGameCenter.gameObject:SetActive(true)
	else
		self.btnGooglePlay.gameObject:SetActive(true)
	end
end

function PagePlatformSelect:OnHandleNetworkConnected(vIsSuccess)
	print("PageConnectJp Connect: ", vIsSuccess)

	self.isConnect = vIsSuccess
end

function PagePlatformSelect:OnLeave()
	self.btnFB = nil
	self.btnTwitter = nil
	self.btnKlabID = nil
	self.btnGameCenter = nil
	self.btnGooglePlay = nil
	self.btnClose = nil
	self.currentCtrl = nil
	self.currentType = nil
	self.btnFB_title = nil
	self.btnTwitter_title = nil
	self.btnKlabID_title = nil
	self.btnGameCenter_title = nil
	self.btnGooglePlay_title = nil
	self.stateGooglePlay = nil
	self.stateGameCenter = nil
	self.stateKlabID = nil
	self.stateTwitter = nil
	self.stateFB = nil
end

function PagePlatformSelect:OnRegisterEvent()
	self:AddClick(self.btnFB.gameObject, self.OnClickedFB)
	self:AddClick(self.btnTwitter.gameObject, self.OnClickedTwitter)
	self:AddClick(self.btnKlabID.gameObject, self.OnClickedKlabId)
	self:AddClick(self.btnGooglePlay.gameObject, self.OnClickedGs)
	self:AddClick(self.btnGameCenter.gameObject, self.OnClickedGs)
	self:AddClick(self.btnClose.gameObject, self.OnClickedBack)
	self:AddClick(self.btnAppleId.gameObject, self.OnClickAppleId)

	if self.useForLogin then
		Event.Instance:AddExclude(EventId.Network.Connected, self.OnHandleNetworkConnected, self)
	end
end

function PagePlatformSelect:OnUnRegisterEvent()
	self:RemoveClick(self.btnFB.gameObject, self.OnClickedFB)
	self:RemoveClick(self.btnTwitter.gameObject, self.OnClickedTwitter)
	self:RemoveClick(self.btnKlabID.gameObject, self.OnClickedKlabId)
	self:RemoveClick(self.btnGooglePlay.gameObject, self.OnClickedGs)
	self:RemoveClick(self.btnGameCenter.gameObject, self.OnClickedGs)
	self:RemoveClick(self.btnClose.gameObject, self.OnClickedBack)
	self:RemoveClick(self.btnAppleId.gameObject, self.OnClickAppleId)

	if self.useForLogin then
		Event.Instance:RemoveExclude(EventId.Network.Connected, self.OnHandleNetworkConnected)
	end
end

function PagePlatformSelect:CheckConfirm(platform, callback)
	if self.useForLogin or not self:isLinked(platform) then
		callback()

		return
	end

	require("UI/Page/PageLogin/Account/PageUnLinkPop")
	UIMgr.AddPanel(PageUnLinkPop(), {
		cb = callback,
		data = {
			user_id = PlayerInst.InfoPlayer.pid,
			rank = PlayerInst.InfoPlayer.curLevel,
			name = PlayerInst.InfoPlayer.name,
			free_sns_coin = PlayerInst.InfoPlayer:GetDiamond(),
			payment_sns_coin = PlayerInst.InfoPlayer:GetDiamondPay()
		}
	})
end

function PagePlatformSelect:GetLoginStrFailed()
	if self.useForLogin then
		return _("PagePlatform_login_fail")
	else
		return _("PagePlatform_information_error")
	end
end

function PagePlatformSelect:OnClickedFB()
	return
end

function PagePlatformSelect:OnClickedTwitter()
	local function check_cb()
		local function stateCallBack(state)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if state == PlatfromLinkState.NotConnected or state == PlatfromLinkState.ApiError then
				UIMgr.ShowCommonKc(DlgCommonEvent.Type.Msg, _("PagePlatform_binding_fail"), "Twitter " .. self:GetLoginStrFailed(), nil, _("PagePlatform_information_status_ok"))
			else
				print(TwitterSupport.GetInstance().AccessToken)

				self.currentCtrl = TwitterSupport.GetInstance()
				self.currentType = protocol_pb.twitter

				self:VerifyToken(TwitterSupport.GetInstance().AccessToken, nil, TwitterSupport.GetInstance().EncryptedTwitterId, TwitterSupport.GetInstance().EncryptedTwitterSecret)
			end
		end

		if self:isLinked(protocol_pb.twitter) then
			self.currentType = protocol_pb.twitter

			self:VerifyToken(TwitterSupport.GetInstance().AccessToken, nil, TwitterSupport.GetInstance().EncryptedTwitterId, TwitterSupport.GetInstance().EncryptedTwitterSecret)
		else
			LoadingMgr.Show(eLoadingType.Repeat)
			TwitterSupport.GetInstance():GetState(stateCallBack)
		end
	end

	self:CheckConfirm(protocol_pb.twitter, check_cb)
end

function PagePlatformSelect:Purge()
	PagePlatformSelect.base.Purge(self)
	self:OnLeave()
end

function PagePlatformSelect:OnGetUserData(vPb)
	local userData = {}

	userData.role1 = {
		user_id = PlayerInst.InfoPlayer.pid,
		rank = PlayerInst.InfoPlayer.curLevel,
		name = PlayerInst.InfoPlayer.name,
		free_sns_coin = PlayerInst.InfoPlayer:GetDiamond(),
		payment_sns_coin = PlayerInst.InfoPlayer:GetDiamondPay()
	}
	userData.type = self.currentType
	userData.ctrl = self.currentCtrl

	print("userid :" .. vPb.user_id)

	if vPb.result.code == NetManager.Result_Sucess then
		if vPb.user_id ~= nil and vPb.user_id ~= "" then
			if vPb.user_id == PlayerInst.InfoPlayer.pid then
				UIMgr.ShowCommonKc(DlgCommonEvent.Type.Msg, _("PagePlatform_information_status_error"), _("PagePlatform_login_same"), nil, _("PagePlatform_information_status_ok"))

				return
			else
				userData.role2 = vPb

				UIMgr.AddPanel(PageChooseAccount(), {
					data = userData,
					call_back = function(pt)
						self:OnLinked(pt)
					end
				})
			end
		else
			UIMgr.AddPanel(PageChooseAccount(), {
				data = userData,
				call_back = function(pt)
					self:OnLinked(pt)
				end
			})
		end
	else
		print("1005 verify failed need logout ")
		self.currentCtrl:Logout()
		UIMgr.ShowCommonKc(DlgCommonEvent.Type.Msg, _("PagePlatform_information_status_error"), _("PagePlatform_information_status1"), nil, _("PagePlatform_information_status_ok"))
	end
end

function PagePlatformSelect:OnLinked(platform)
	if platform == protocol_pb.game_center then
		self:OnLinkChange(self.btnGameCenter.gameObject, true)
	elseif platform == protocol_pb.google_play then
		self:OnLinkChange(self.btnGooglePlay.gameObject, true)
	elseif platform == protocol_pb.twitter then
		self:OnLinkChange(self.btnTwitter.gameObject, true)
	elseif platform == protocol_pb.facebook then
		self:OnLinkChange(self.btnFB.gameObject, true)
	elseif platform == protocol_pb.klab_id then
		self:OnLinkChange(self.btnKlabID.gameObject, true)
	elseif platform == protocol_pb.apple_id then
		self:OnLinkChange(self.btnAppleId.gameObject, true)
	end

	table.insert(self.linkState, platform)
end

function PagePlatformSelect:isLinked(platform)
	return table.contains(self.linkState, platform)
end

function PagePlatformSelect:OnClickedKlabId()
	local function check_cb()
		local function stateCallBack(state)
			UIMgr.HideCommon()

			if state == PlatfromLinkState.NotConnected or state == PlatfromLinkState.ApiError then
				UIMgr.ShowCommonKc(DlgCommonEvent.Type.Msg, _("PagePlatform_binding_fail"), _("PagePlatform_Klabid") .. self:GetLoginStrFailed(), nil, _("PagePlatform_information_status_ok"))
			else
				print(KlabIDSupport.GetInstance().AccessToken)

				self.currentCtrl = KlabIDSupport.GetInstance()
				self.currentType = protocol_pb.klab_id

				self:VerifyToken(KlabIDSupport.GetInstance().AccessToken)
			end
		end

		KlabIDSupport.GetInstance():GetState(stateCallBack, function()
			UIMgr.ShowCommonKc(DlgCommonEvent.Type.Msg, _("PagePlatform_klabid_titel"), _("PagePlatform_klabid_word"), function()
				KlabIDSupport.GetInstance():Abort()
				stateCallBack(PlatfromLinkState.NotConnected)
			end, _("PagePlatform_information_status_ng"), nil)
		end)
	end

	self:CheckConfirm(protocol_pb.klab_id, check_cb)
end

function PagePlatformSelect:OnClickAppleId()
	if self.useForLogin or not self:isLinked(protocol_pb.apple_id) then
		local function check_cb()
			local function stateCallBack(state)
				LoadingMgr.Hide(eLoadingType.Repeat)
				print("onrecieve")
				print(state)

				if state == PlatfromLinkState.NotConnected or state == PlatfromLinkState.ApiError then
					UIMgr.ShowCommonKc(DlgCommonEvent.Type.Msg, _("PagePlatform_binding_fail"), "Apple ID" .. self:GetLoginStrFailed(), nil, _("PagePlatform_information_status_ok"))
				else
					print(AppleIdSupport.GetInstance().AccessToken)

					self.currentCtrl = AppleIdSupport.GetInstance()
					self.currentType = protocol_pb.apple_id

					self:VerifyToken(AppleIdSupport.GetInstance().AccessToken)
				end
			end

			LoadingMgr.Show(eLoadingType.Repeat)
			AppleIdSupport.GetInstance():Login(stateCallBack)
		end

		self:CheckConfirm(protocol_pb.apple_id, check_cb)
	else
		local function unlinkCallBack()
			self.currentCtrl = AppleIdSupport.GetInstance()
			self.currentType = protocol_pb.apple_id

			self:VerifyToken()
		end

		self:CheckConfirm(protocol_pb.apple_id, unlinkCallBack)
	end
end

function PagePlatformSelect:OnClickedGs()
	local function check_cb()
		local function stateCallBack(state)
			UIMgr.HideCommon()

			if state == PlatfromLinkState.NotConnected or state == PlatfromLinkState.ApiError then
				UIMgr.ShowCommonKc(DlgCommonEvent.Type.Msg, _("PagePlatform_binding_fail"), "GameService" .. self:GetLoginStrFailed(), nil, _("PagePlatform_information_status_ok"))
			else
				print("[GameService]" .. GameServiceSupport.GetInstance().AccessToken)

				self.currentCtrl = GameServiceSupport.GetInstance()
				self.currentType = Application.platform:ToInt() == RuntimePlatform.IPhonePlayer and protocol_pb.game_center or protocol_pb.google_play

				self:VerifyToken(GameServiceSupport.GetInstance().AccessToken)
			end
		end

		local tmpType = Application.platform:ToInt() == RuntimePlatform.IPhonePlayer and protocol_pb.game_center or protocol_pb.google_play

		if self:isLinked(tmpType) then
			self.currentType = tmpType

			self:VerifyToken(GameServiceSupport.GetInstance().AccessToken)
		elseif GameServiceSupport.GetInstance():IsSignedIn() then
			GameServiceSupport.GetInstance():SignIn(function()
				GameServiceSupport.GetInstance():GetState(stateCallBack, function()
					UIMgr.ShowCommonKc(DlgCommonEvent.Type.Msg, "GameService" .. _("PagePlatform_login"), _("PagePlatform_login"), function()
						stateCallBack(PlatfromLinkState.NotConnected)
					end, _("PagePlatform_information_status_ng"), nil)
				end, false)
			end, function()
				UIMgr.ShowCommonKc(DlgCommonEvent.Type.Msg, _("PagePlatform_login_fail"), tmpType == protocol_pb.game_center and _("PagePlatform_binding_fail_description1") or _("PagePlatform_binding_fail_description2"), nil, _("PagePlatform_information_status_ok"))
			end)
		else
			UIMgr.ShowCommonKc(DlgCommonEvent.Type.Msg, _("PagePlatform_login_fail"), tmpType == protocol_pb.game_center and _("PagePlatform_binding_fail_description1") or _("PagePlatform_binding_fail_description2"), nil, _("PagePlatform_information_status_ok"))
		end
	end

	self:CheckConfirm(Application.platform:ToInt() == RuntimePlatform.IPhonePlayer and protocol_pb.game_center or protocol_pb.google_play, check_cb)
end

function PagePlatformSelect:OnClickedBack()
	self:Close()
end

function PagePlatformSelect:VerifyToken(accessToken, fbSerId, twId, twSer)
	if self.useForLogin then
		local function call_back()
			self:Close()
		end

		DataLinkProcess.FetchLinkedData(accessToken, fbSerId, twId, twSer, self.currentType, self.currentCtrl, call_back)
	elseif self:isLinked(self.currentType) then
		accessToken = accessToken == nil and "" or accessToken

		self:UnLink(accessToken, self.currentType)
	else
		local function wrap_cb(...)
			LoadingMgr.Hide(eLoadingType.Repeat)
			self:OnGetUserData(...)
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:GetPlatformUserData(accessToken, self.currentType, fbSerId, twId, twSer, wrap_cb)
	end
end

function PagePlatformSelect:UnLink(accessToken, platform)
	local function wrap_cb(...)
		LoadingMgr.Hide(eLoadingType.Repeat)
		self:OnUnLink(...)
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:UnLink(accessToken, platform, wrap_cb)
end

function PagePlatformSelect:OnUnLink(vMsg, platform)
	print("on unlink result")

	if platform == protocol_pb.game_center then
		self:OnLinkChange(self.btnGameCenter.gameObject, false)
	elseif platform == protocol_pb.google_play then
		self:OnLinkChange(self.btnGooglePlay.gameObject, false)
	elseif platform == protocol_pb.twitter then
		self:OnLinkChange(self.btnTwitter.gameObject, false)
	elseif platform == protocol_pb.facebook then
		self:OnLinkChange(self.btnFB.gameObject, false)
	elseif platform == protocol_pb.klab_id then
		self:OnLinkChange(self.btnKlabID.gameObject, false)
	elseif platform == protocol_pb.apple_id then
		self:OnLinkChange(self.btnAppleId.gameObject, false)
	end

	table.removeByValue(self.linkState, platform)
end
