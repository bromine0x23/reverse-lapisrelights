-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/PageConnectLogic.lua

require("Network/NetManager")
require("Info/Player")
require("Util/Util")
require("UI/Page/PagePay/PagePayRule")
require("Info/CautionMgr")
require("UI/Page/PageCaution/CautionBuilder")

PageConnectLogic = {}

function PageConnectLogic.StartProcessUserInfo()
	PageConnectLogic.isLoading = true

	LoadingMgr.Show(eLoadingType.Repeat)
	PageConnectLogic.StartConnect()
end

function PageConnectLogic.StartConnect()
	if GateServer.IsConnect then
		PageConnectLogic.OnHandleNetworkConnected(PageConnectLogic, true)
	else
		Event.Instance:AddExclude(EventId.Network.Connected, PageConnectLogic.OnHandleNetworkConnected, PageConnectLogic)
		print("Start Coneect " .. NetManager.Host .. " " .. NetManager.Port)
		GateServer:Connect(NetManager.Host, NetManager.Port)
	end
end

function PageConnectLogic.OnEnd()
	if PageConnectLogic.isLoading then
		LoadingMgr.Hide(eLoadingType.Repeat)
		Event.Instance:RemoveExclude(EventId.Network.Connected, PageConnectLogic.OnHandleNetworkConnected)

		PageConnectLogic.isLoading = false
	end
end

function PageConnectLogic:OnHandleNetworkConnected(vIsSuccess)
	Event.Instance:RemoveExclude(EventId.Network.Connected, PageConnectLogic.OnHandleNetworkConnected)
	print("PageConnectJp Connect: ", vIsSuccess)

	if vIsSuccess then
		if NetManager.DebugLoginID and NetManager.DebugLoginID ~= "" then
			local function wrap_cb(...)
				LoadingMgr.Hide(eLoadingType.Repeat)

				local vMsg, r = ...

				PlayerPrefs.SetString(PersistentStoreUtil.KEY_AUTHORIZE_ID, vMsg.authToken)
				NetworkManager.ConnectorGate:SaveSessionKey(vMsg.authKey, r, true)
				PageConnectLogic.StartLogin()
			end

			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:DebugLogin(NetManager.DebugLoginID, wrap_cb)
		else
			local authToken = PlayerPrefs.GetString(PersistentStoreUtil.KEY_AUTHORIZE_ID, "")

			print("auth token" .. authToken)

			if authToken and authToken ~= "" then
				PageConnectLogic.StartLogin()
			else
				PageConnectLogic.DoAutoRecover(function()
					local function wrap_cb(...)
						LoadingMgr.Hide(eLoadingType.Repeat)
						PageConnectLogic.OnStartUpRecv(...)
					end

					LoadingMgr.Show(eLoadingType.Repeat)
					NetManager:RequestStartUp(wrap_cb)
				end)
			end
		end
	end
end

function PageConnectLogic.DoAutoRecover(onRecoverCancel)
	GameServiceSupport.GetInstance():GetState(function(state)
		if state == PlatfromLinkState.NotConnected or state == PlatfromLinkState.ApiError then
			onRecoverCancel()
		else
			print("[Auto Recover]" .. GameServiceSupport.GetInstance().AccessToken)

			local currentType = Application.platform:ToInt() == RuntimePlatform.IPhonePlayer and protocol_pb.game_center or protocol_pb.google_play

			local function wrap_cb(...)
				LoadingMgr.Hide(eLoadingType.Repeat)

				local msg, rkey = ...

				PageConnectLogic.OnCheckPlatormRecover(msg, rkey, currentType, onRecoverCancel)
			end

			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:PlatfromDataRecover(GameServiceSupport.GetInstance().AccessToken, currentType, nil, nil, nil, nil, wrap_cb)
		end
	end, nil, true)
end

function PageConnectLogic.OnCheckPlatormRecover(vMsg, r, currType, cancelCallback)
	print(vMsg)
	print(r)
	print(currType)
	print(cancelCallback)

	if not vMsg.linkedUserInfo or vMsg.linkedUserInfo.user_id == "" then
		cancelCallback()
	else
		LoadingMgr.Hide(eLoadingType.Repeat)

		local userData = {}

		userData.role1 = vMsg.linkedUserInfo

		UIMgr.AddPanel(PageChooseAccount(), {
			useForLogin = true,
			data = userData,
			call_back = function()
				PlayerPrefs.SetString(PersistentStoreUtil.KEY_AUTHORIZE_ID, vMsg.authToken)
				NetworkManager.ConnectorGate:SaveSessionKey(vMsg.authKey, r, true)
				GuidePassCheck(function()
					LoadingMgr.Show(eLoadingType.Repeat)
					PageConnectLogic.StartLogin()
				end)
			end,
			call_back_cancel = cancelCallback
		})
	end
end

function PageConnectLogic.OnStartUpRecv(vPBMessage, r)
	if vPBMessage.result.code == NetManager.Result_Sucess then
		PlayerPrefs.SetString(PersistentStoreUtil.KEY_AUTHORIZE_ID, vPBMessage.authToken)
		print("on recieve")
		print(r)
		print(vPBMessage.authKey)
		NetworkManager.ConnectorGate:SaveSessionKey(vPBMessage.authKey, r, true)
		AppsFlyerService.TrackStartUpComplete()
		PageConnectLogic.StartLogin()
	elseif vPBMessage.result.code == 1 then
		UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, "login error", "Login Error Please try reboot", nil)
	else
		PageConnectLogic.OnHandleNetworkConnected(PageConnectLogic, true)
	end
end

function PageConnectLogic.StartLogin()
	local function wrap_cb(...)
		LoadingMgr.Hide(eLoadingType.Repeat)
		PageConnectLogic.OnLogin(...)
	end

	local preId = PlayerPrefs.GetString(PersistentStoreUtil.KEY_AUTHORIZE_ID, "")
	local pushToken = PlayerPrefs.GetString(PersistentStoreUtil.PUSH_TOKEN, "")

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:StartLogin(preId, pushToken, wrap_cb)
end

function PageConnectLogic.OnLogin(vPBMessage)
	if PageConnectLogic.timerLogin ~= nil then
		TimerMgr.RemoveTimer(PageConnectLogic.timerLogin)
	end

	if vPBMessage.result.code == NetManager.Result_Sucess then
		local info = CautionMgr:GetCautionPopInfo(protocol_pb.home)
		local infoShop = CautionMgr:GetCautionPopInfo(protocol_pb.shop)

		if info then
			LoadingMgr.Hide(eLoadingType.Repeat)
			CautionBuilder.OpenCautionPopupOpt(info, function()
				LoadingMgr.Show(eLoadingType.Repeat)

				if info.cautionType == protocol_pb.cautionBilling or info.cautionType == protocol_pb.cautionRestrictionBilling then
					CautionBuilder.ReadCaution(info)
				end

				PageConnectLogic.RequestGetPlayer()
			end)
		elseif infoShop and not infoShop.lookAt then
			LoadingMgr.Hide(eLoadingType.Repeat)
			CautionBuilder.OpenCautionPopupOpt(infoShop, function()
				LoadingMgr.Show(eLoadingType.Repeat)

				if infoShop.cautionType == protocol_pb.cautionBilling then
					CautionBuilder.ReadCaution(infoShop)
				end

				PageConnectLogic.RequestGetPlayer()
			end)
		else
			PageConnectLogic.RequestGetPlayer()
		end
	elseif vPBMessage.result.code == NetManager.Result_Timeout then
		TimerMgr.AddTimer(eTimerType.RealTime, 10, function()
			PageConnectLogic.StartLogin()
		end, {
			1
		})
	elseif vPBMessage.result.code == 3 then
		UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("PagePlatform_login_fail"), _("PagePlatform_login_again_reason"), nil, _("UI_OK"))
		PlayerPrefs.DeleteKey(NetworkManager.COMMON_KEY)
		PlayerPrefs.DeleteKey(PersistentStoreUtil.KEY_AUTHORIZE_ID)
		PageConnectLogic.OnEnd()
	end
end

function PageConnectLogic.RequestGetPlayer()
	local function wrap_cb(...)
		LoadingMgr.Hide(eLoadingType.Repeat)
		PageConnectLogic.OnGetPlayerInfo(...)
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestGetPlayerInfo(wrap_cb)
end

function PageConnectLogic.DoAutoLink(callback)
	print("start auto link")

	if not PlayerInst.InfoPlayer.isPlatformServiceLinked then
		GameServiceSupport.GetInstance():GetState(function(state)
			if state == PlatfromLinkState.NotConnected or state == PlatfromLinkState.ApiError then
				callback()
			else
				print("[Auto Link]" .. GameServiceSupport.GetInstance().AccessToken)

				local currentType = Application.platform:ToInt() == RuntimePlatform.IPhonePlayer and protocol_pb.game_center or protocol_pb.google_play

				local function wrap_cb(...)
					LoadingMgr.Hide(eLoadingType.Repeat)
					PageConnectLogic.OnCheckPlatormLink(..., currentType, callback)
				end

				LoadingMgr.Show(eLoadingType.Repeat)
				NetManager:GetPlatformUserData(GameServiceSupport.GetInstance().AccessToken, currentType, nil, nil, nil, wrap_cb)
			end
		end, nil, true)
	else
		callback()
	end
end

function PageConnectLogic.OnCheckPlatormLink(vMsg, currType, callback)
	if vMsg.user_id ~= nil and vMsg.user_id ~= "" then
		callback()
	else
		local function wrap_cb(...)
			LoadingMgr.Hide(eLoadingType.Repeat)
			callback()
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:StartLink(GameServiceSupport.GetInstance(), currType, wrap_cb)
	end
end

function PageConnectLogic.OnGetPlayerInfo(vPBMessage)
	local code = vPBMessage.result.code

	print("OnGetPlayerInfo: " .. code)

	PageConnectLogic.GetPlayerInfoResultCode = code

	if code == NetManager.Result_Sucess then
		PageConnectLogic.CheckTermsVersion()
	elseif code == 1 then
		PageConnectLogic.CheckTermsVersion()
	elseif code == 2 then
		PageConnectLogic.CheckTermsVersion()
	else
		print("OnGetPlayerInfo err: " .. vPBMessage.result.desc)
		PageConnectLogic.RequestGetPlayer()
	end
end

function PageConnectLogic.CheckTermsVersion()
	if PlayerInst.InfoPlayer.termsOfUseVersion ~= GetConfigArgInt("TermsOfUseVersion") then
		local function wrap_cb(...)
			PageConnectLogic.OnGetTermsVersion(...)
		end

		UIMgr.AddPanel(PagePayRule(), {
			mode = 1,
			curIndex = 1,
			cb = wrap_cb
		})
	else
		PageConnectLogic.GotoMainStage()
	end

	PageConnectLogic.OnEnd()
end

function PageConnectLogic.OnGetTermsVersion(vPBMessage)
	local code = vPBMessage.result.code

	print("OnGetTermsVersion: " .. code)

	if code == NetManager.Result_Sucess then
		PageConnectLogic.GotoMainStage()
	else
		print("OnGetTermsVersion err: " .. vPBMessage.result.desc)
		PageConnectLogic.CheckTermsVersion()
	end
end

function PageConnectLogic.GotoMainStage()
	local function cb()
		PageConnectLogic.DealWithSpot()
	end

	if PageConnectLogic.GetPlayerInfoResultCode == NetManager.Result_Sucess then
		InstructionMgr:End()
		PageConnectLogic.DoAutoLink(cb)
	elseif PageConnectLogic.GetPlayerInfoResultCode == 1 and not InstructionMgr.isOpen then
		UIMgr.SwitchPanel(PageGenName, {
			callback = function()
				PageConnectLogic.DoAutoLink(cb)
			end
		})
	elseif PageConnectLogic.GetPlayerInfoResultCode == 2 then
		PageConnectLogic.DoAutoLink(cb)
	else
		print("OnGetPlayerInfo err: " .. PageConnectLogic.GetPlayerInfoResultCode)

		local function wrap_cb(vPBMessage)
			LoadingMgr.Hide(eLoadingType.Repeat)

			local code = vPBMessage.result.code

			PageConnectLogic.GetPlayerInfoResultCode = code

			PageConnectLogic.GotoMainStage()
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestGetPlayerInfo(wrap_cb)
	end
end

function PageConnectLogic.DealWithSpot()
	if not InstructionMgr.isOpen or PlayerInst.InfoPlayer.newbieProgress == 1 then
		SceneMgr.LoadScene("MainStage", {
			from = 0,
			FirstInto = true
		})
	else
		InstructionMgr:Start()
		GuideFlow.Start()
	end
end

function PageConnectLogic:DealWithSpotIOS()
	local guidePassed = PlayerPrefs.GetInt("GuidePassed", 0)

	print("guidePassed:" .. tostring(guidePassed))

	if not InstructionMgr.isOpen or PlayerInst.InfoPlayer.newbieProgress == 1 then
		if AppConst.AssetBundleMode and guidePassed == 0 then
			InstructionMgr.UpdateAfterGuide()

			return
		end

		SceneMgr.LoadScene("MainStage", nil)

		return
	end

	InstructionMgr:Start()
	print("DealWithSpot~~~~~~~~~~~~~~~~~")
	print(InstructionMgr.getSpot)

	if InstructionMgr.getSpot then
		print("AppConst.AssetBundleMode" .. tostring(AppConst.AssetBundleMode))

		if AppConst.AssetBundleMode and guidePassed == 0 then
			InstructionMgr.UpdateAfterGuide()

			return
		end
	end

	GuideFlow.Start()
end
