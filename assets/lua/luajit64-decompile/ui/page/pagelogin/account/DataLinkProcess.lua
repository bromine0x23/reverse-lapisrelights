-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/Account/DataLinkProcess.lua

require("UI/Page/PageLogin/Account/PageChooseAccount")

DataLinkProcess = {}

function DataLinkProcess.FetchLinkedData(accessToken, fbSerId, twId, twSer, currType, currCtrl, call_back)
	local function wrap_cb(...)
		LoadingMgr.Hide(eLoadingType.Repeat)
		DataLinkProcess.OnGetLinkedData(...)
	end

	local playerAuthToken = PlayerPrefs.GetString(PersistentStoreUtil.KEY_AUTHORIZE_ID, nil)

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:PlatfromDataRecover(accessToken, currType, fbSerId, twId, twSer, playerAuthToken, wrap_cb)

	DataLinkProcess.requestParms = {
		platformToken = accessToken,
		fbSerId = fbSerId,
		twitterId = twId,
		twSecret = twSer,
		ptype = currType,
		pCtrl = currCtrl,
		cb = call_back,
		playerToken = playerAuthToken
	}
end

function DataLinkProcess.OnGetLinkedData(vMsg, r)
	local userData = {}

	if not vMsg.linkedUserInfo or vMsg.linkedUserInfo.user_id == "" then
		DataLinkProcess.ShowError("アカウントが存在しません")

		return
	end

	if vMsg.currentUserInfo and vMsg.currentUserInfo.user_id ~= "" then
		if vMsg.currentUserInfo.user_id == vMsg.linkedUserInfo.user_id then
			PlayerPrefs.SetString(PersistentStoreUtil.KEY_AUTHORIZE_ID, vMsg.authToken)
			DataLinkProcess.ShowError(_("PagePlatform_login_same"))

			return
		end

		print("vMsg.currentUserInfo ")
		print(vMsg.currentUserInfo.user_id)

		userData.role1 = vMsg.currentUserInfo
		userData.role2 = vMsg.linkedUserInfo
	else
		userData.role1 = vMsg.linkedUserInfo
	end

	UIMgr.AddPanel(PageChooseAccount(), {
		useForLogin = true,
		data = userData,
		call_back = function()
			DataLinkProcess.DoRecover(vMsg.authToken, vMsg.authKey, r)
		end,
		call_back_cancel = function()
			DataLinkProcess.Logout()
		end
	})
end

function DataLinkProcess.DoRecover(authToken, authKey, randKey)
	if DataLinkProcess.requestParms.cb then
		DataLinkProcess.requestParms.cb()
	end

	DataLinkProcess.requestParms = nil

	require("UI/Page/PageLogin/Account/PagePlatformPopup")
	UIMgr.AddPanel(PagePlatformPopup(), {
		call_back = function()
			PlayerPrefs.SetString(PersistentStoreUtil.KEY_AUTHORIZE_ID, authToken)
			NetworkManager.ConnectorGate:SaveSessionKey(authKey, randKey, true)
			GuidePassCheck(function()
				PageConnectLogic.StartProcessUserInfo()
			end)
		end,
		title = _("PagePlatform_account_login_choice_or_no"),
		content = _("PagePlatform_account_login_choice_success")
	})
end

function DataLinkProcess.ShowError(msg)
	UIMgr.ShowMsg(msg)
	DataLinkProcess.Logout()

	DataLinkProcess.requestParms = nil
end

function DataLinkProcess.Logout()
	if type(DataLinkProcess.requestParms.pCtrl.Logout) == "function" then
		DataLinkProcess.requestParms.pCtrl:Logout()
	end
end
