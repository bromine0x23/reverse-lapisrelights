-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/PageLogin.lua

require("UI/Page/PageLogin/PageDistrict")
require("UI/Page/PageLogin/PageConnect")
require("UI/Page/PageLogin/PageConnectLogic")
require("UI/Page/PageLogin/Account/PagePlatformSelect")
require("UI/Page/PageLogin/PageTitleMenuTop")
require("UI/Page/PageOtherMenu/PageUserSupport")
require("UI/Dlg/Public/DlgSout")
require("Manager/NotificationMgr")

PageLogin = class("PageLogin", UIPanel, true)
FirstLogin = true
FirstSevenDay = true
AniMationArr = {
	0.34,
	0.74,
	1
}

function GuidePassCheck(onNoNewUser)
	local guidePass = PlayerPrefs.GetInt("GuidePassed", 0)

	print(guidePass)

	if guidePass == 1 or Application.platform:ToInt() == RuntimePlatform.Android then
		if onNoNewUser then
			onNoNewUser()
		end
	else
		PlayerPrefs.SetInt("GuidePassed", 1)

		local function wrap_cb()
			Launcher.Instance:Restart()
		end

		UIMgr.ShowDialog("更新の必要なデータを確認しました\nダウンロード後、タイトル画面に戻ります", wrap_cb)
	end
end

function PageLogin:ctor()
	PageLogin.base.ctor(self, "UI/PanelLogin/PanelLogin")
end

function PageLogin:Purge()
	PageLogin.base.Purge(self)
	UnloadAllImageSprite(self)

	if self.videoRes then
		ResourceMgr.Unload(self.videoRes)

		self.videoRes = nil
	end
end

function PageLogin:OnEnter()
	self.needGetSerNotice = true

	print("start login page!")

	self.Bg = self:GetChildGameObject("Bg")

	self.Bg:SetActive(false)

	self.Ani = GOUtil.GetComponent(self.UIRootObject, "Animator")
	self.GoClickArea = self:GetChildGameObject("Panel1/ClickArea")
	self.InputField = self:GetChildComponent("Panel1/PanelInput/InputField", "InputField")
	self.PanelInput = self:GetChildGameObject("Panel1/PanelInput")
	self.InputFieldTime = self:GetChildComponent("Panel1/PanelInputDebugTime/InputField", "InputField")
	self.InputFieldTime.text = PlayerPrefs.GetInt("DebugSysTime", 0)
	self.PanelInputDebugTime = self:GetChildGameObject("Panel1/PanelInputDebugTime")
	self.BtnChange = self:GetChildComponent("Panel1/BtnChange", "Button")
	self.BtnOffLine = self:GetChildComponent("Panel1/BtnOffLine", "Button")
	self.BtnFight = self:GetChildComponent("Panel1/BtnFight", "Button")
	self.BtnDataRec = self:GetChildComponent("Panel1/BtnDataRecovery", "Button")
	self.BtnDataRepair = self:GetChildComponent("Panel1/BtnDataRepair", "Button")
	self.BtnKeFu = self:GetChildComponent("Panel1/BtnKeFu", "Button")
	self.BtnSkillOut = self:GetChildComponent("Panel1/BtnSkillOut", "Button")
	self.BtnLogOut = self:GetChildGameObject("Panel2/BtnLogOut")
	self.BtnGuide = self:GetChildGameObject("Panel1/BtnGuide")
	self.BtnFuncLock = self:GetChildGameObject("Panel1/BtnFuncLock")
	self.BtnMv = self:GetChildGameObject("Panel1/BtnMv")
	self.BtnVerify = self:GetChildGameObject("Panel2/BtnVerify")
	self.DlgSetting = self:GetChildGameObject("DlgSetting")
	self.BtnSetting = self:GetChildGameObject("Panel1/BtnSetting")
	self.ButtonSettingClose = self:GetChildGameObject("DlgSetting/Main/ButtonClose")
	self.BtnCheck = self:GetChildGameObject("DlgSetting/Main/BtnCheck")
	self.BtnClear = self:GetChildGameObject("DlgSetting/Main/BtnClear")
	self.BtnVideoBG = self:GetChildGameObject("VideoBG")
	self.VideoPlayer = self:GetChildComponent("VideoBG/Video", "VideoPlayer")
	self.RawImageVideo = self:GetChildComponent("VideoBG/Video", "RawImage")
	self.VideoPlayer.loopPointReached = self.VideoPlayer.loopPointReached + function()
		self:OnSkipVideo()
	end
	self.versionTxt = self:GetChildComponent("AgeSafeArea/Txt_Version", "Text")
	self.versionTxt.text = Launcher.Instance:GetVer()

	GOUtil.SetRectTransformRectHeight(self.versionTxt.gameObject, 100)

	self.idTxt = self:GetChildComponent("AgeSafeArea/Txt_ID", "Text")

	local preUserId = PlayerPrefs.GetString("PRE_USER_ID", "")

	if preUserId ~= "" then
		self.idTxt.text = _("DESC_USERID") .. preUserId
	else
		self.idTxt.text = ""
	end

	if Kc.Config.KcAppSetting.EnabledDebugMenu then
		self.Bg:SetActive(true)
		self.PanelInput:SetActive(true)
		self.PanelInputDebugTime:SetActive(true)

		NetManager.IsUseInterServer = true

		self.BtnVideoBG:SetActive(false)

		self.Ani.enabled = true

		self.BtnGuide:SetActive(true)
		self.BtnFuncLock:SetActive(true)

		OpenAllLock = false

		self:OnSwitchGuide()
		self:OnSwitchBtnFuncLock()
		GateServer:Connect(NetManager.Host, NetManager.Port)
	else
		self.BtnVideoBG:SetActive(true)
		self.BtnChange.gameObject:SetActive(false)
		self.PanelInput:SetActive(false)
		self.PanelInputDebugTime:SetActive(false)

		NetManager.IsUseInterServer = false

		if tonumber(preId) == 1 or tonumber(preId) == 0 then
			local str = NetData:GetCurTimeMillis()

			self.InputField.text = str .. Mathf.Random(1, 999999)
		end

		self.BtnFight.gameObject:SetActive(false)
		self.BtnSkillOut.gameObject:SetActive(false)
		self.BtnOffLine.gameObject:SetActive(false)

		self.Ani.enabled = true

		self.BtnGuide:SetActive(false)
		self.BtnFuncLock:SetActive(false)
		self.BtnVerify:SetActive(false)
	end

	local TextOffline = self:GetChildComponent("Panel1/BtnOffLine/Text", "Text")

	TextOffline.text = _("Server_Offline")

	local Text = self:GetChildComponent("Panel1/BtnChange/Text", "Text")

	Text.text = _("Server_Internal")

	if not Kc.Config.KcAppSetting.EnabledDebugMenu then
		NetManager.IsUseInterServer = false
		Text.text = _("Server_External")
		OpenAllLock = false
		InstructionMgr.isOpen = true
	end

	self:OnEnterPageDistrict()

	if Application.platform:ToInt() == RuntimePlatform.Android then
		if GameServiceSupport.IsAutoGPGSSignIn() then
			GameServiceSupport.GetInstance():SignIn(nil, nil)
		end
	else
		GameServiceSupport.GetInstance():SignIn(nil, nil)
	end

	local availMemeory = OzSDKManager.GetMemeryInfo()

	self.BtnAni = self:GetChildGameObject("Anim", "Button")
	self.ani_ctrl = self:GetChildComponent("", "Animator")

	print("availMemeory:" .. availMemeory)

	if AppConst.LRUEnable then
		ResourceManager.SetLRUCacher(1, 20)
	end

	NotificationSender.isInitialized = false

	self:OnPrepareCompletedVideo()
	LoadingMgr.Show(eLoadingType.Repeat)

	local preUserId = PlayerPrefs.GetString("PRE_USER_ID", "")

	self.longId = preUserId == "" and 0 or tonumber(preUserId)

	NetworkManager.ConnectorGate:FetchSout(self.longId, wrapedCb(self.OnNetBack, self))
end

function PageLogin:OnNetBack(code, body, url)
	if code == 0 then
		LoadingMgr.Hide(eLoadingType.Repeat)

		if PlayerPrefs.GetInt(PersistentStoreUtil.KEY_ACCOUNT_DELETED) == 1 then
			self:OnLoginClicked()
		end
	elseif code == -1 then
		TimerMgr.AddTimer(eTimerType.RealTime, 5, function()
			NetworkManager.ConnectorGate:FetchSout(self.longId, wrapedCb(self.OnNetBack, self))
		end, {})
	else
		LoadingMgr.Hide(eLoadingType.Repeat)
		UIMgr.AddPanel(DlgSout(), {
			content = body,
			urlPath = url
		})
		self.ani_ctrl:Play("Login", 0, 1)
	end
end

function PageLogin:OnInputFieldChange(strP)
	return
end

function PageLogin:OnLeave()
	self.Bg = nil
	self.GoClickArea = nil
	self.InputField = nil
	self.PanelInput = nil
	self.BtnChange = nil
	self.BtnTut = nil
	self.BtnTakeAPhoto = nil
	self.BtnDataRec = nil
	self.BtnDataRepair = nil
	self.BtnKeFu = nil
	self.peopleImg = nil
	self.LogoImg = nil
	self.Button_SwitchPage = nil
	self.Texture = nil
	self.FxComp = nil
	self.ani_ctrl = nil
	self.BtnAni = nil
end

function PageLogin:RequestLoginInfo()
	local wrap = wrapedCb(self.OnGetLoginInfo, self)

	SDKMgr.GetInstance():Login(wrap)
end

function PageLogin:OnGetLoginInfo(strToken)
	print("OnGetLoginInfo~~~~~~~~~~~")
	LoadingMgr.Hide(eLoadingType.Repeat)

	if string.isNullOrEmpty(strToken) then
		self:RequestLoginInfo()
	else
		local json = require("GameLogic/Util/json4lua")
		local dict = json.decode(strToken)
		local code = dict.code
		local callbackType = dict.callbackType
		local userid = dict.userid
		local ticket = dict.ticket

		if ticket then
			NetManager.SDKToken = ticket
		end

		if tonumber(code) == 1 then
			NetManager.authorizeId = userid

			PlayerPrefs.SetString("PRE_USER_ID", tostring(userid))
			self:ChangePageDistrict()
		else
			self:RequestLoginInfo()
		end
	end
end

function PageLogin:RequestUserInfo()
	local wrap = wrapedCb(self.OnGetUserInfo, self)

	SDKMgr.GetInstance():GetUserInfo(wrap)
end

function PageLogin:OnGetUserInfo(str)
	print("PageLogin:GetUserInfo")

	local json = require("GameLogic/Util/json4lua")
	local dict = json.decode(str)
	local code = dict.code
	local callbackType = dict.callbackType

	if callbackType == "GetUserInfo" and tonumber(code) == 1 then
		local uid = dict.uid
		local username = dict.username

		print("uid:" .. uid)
		print("username:" .. username)

		OzSDKManager.Instance.uid = uid
		OzSDKManager.Instance.username = username
	else
		self:RequestUserInfo()
	end
end

function PageLogin:OnGetLogout(str)
	NetManager.SDKToken = nil

	LoadingMgr.Hide(eLoadingType.Repeat)
	self.Panel1:SetActive(true)
	self.Panel2:SetActive(false)
end

function PageLogin:OnGetLogin(obj, strPrompt)
	LoadingMgr.Hide(eLoadingType.Repeat)

	self.sdkData = obj

	if obj.ret == 0 then
		NetManager.access_token = obj.access_token
		NetManager.authorizeId = obj.pf_id

		SwitchToPage(SceneLogin.Instance.PageDistrict)
	else
		self:RequestLoginInfo()
	end

	if not string.isNullOrEmpty(strPrompt) then
		UIMgr.ShowMsg(strPrompt)
	end
end

function PageLogin:OnPerformSceneLoadClicked()
	SceneMgr.LoadScene("Classroom", nil)
end

function PageLogin:OnRegisterEvent()
	self:AddClick(self.GoClickArea, self.OnLoginClicked, PATH_SFX_UI_LOGIN)
	self:AddClick(self.BtnChange.gameObject, self.OnChangeServer)
	self:AddClick(self.BtnOffLine.gameObject, self.OnBtnOffLine)
	self:AddClick(self.BtnDataRec.gameObject, self.OnDataRec)
	self:AddClick(self.BtnDataRepair.gameObject, self.OnDataRepair)
	self:AddClick(self.BtnKeFu.gameObject, self.OnKefu)
	self:AddClick(self.BtnFight.gameObject, self.OnBtnFight)
	self:AddClick(self.BtnSkillOut.gameObject, self.OnBtnSkillTipOut)
	self:AddClick(self.BtnLogOut, self.OnBtnLogOut, PATH_SFX_UI_CANCEL)
	self:AddClick(self.BtnAni.gameObject, self.OnAniClick)
	self:AddClick(self.BtnVideoBG, self.OnSkipVideo)
	self:AddClick(self.BtnGuide, self.OnSwitchGuide)
	self:AddClick(self.BtnFuncLock, self.OnSwitchBtnFuncLock)
	self:AddClick(self.BtnMv, self.OnBtnMv)
	self:AddClick(self.BtnVerify, self.OnBtnVerify)
	self:AddClick(self.BtnSetting, self.OnBtnSetting)
	self:AddClick(self.ButtonSettingClose, self.OnBtnSettingClose)
	self:AddClick(self.BtnCheck, self.OnBtnCheckAsset)
	self:AddClick(self.BtnClear, self.OnBtnDelectAsset)
	EventListenerMgr.AddAnimListenerEventID(self.Ani.gameObject, self.PlaySoundKlab, self, "OnKlabGames")
	EventListenerMgr.AddAnimListenerEventID(self.Ani.gameObject, self.PlaySoundKadokawa, self, "OnKadokawa")
	self:OnRegisterEventPageDistrict()
end

function PageLogin:OnUnRegisterEvent()
	self:RemoveClick(self.GoClickArea, self.OnLoginClicked)
	self:RemoveClick(self.BtnChange.gameObject, self.OnChangeServer)
	self:RemoveClick(self.BtnOffLine.gameObject, self.OnBtnOffLine)
	self:RemoveClick(self.BtnDataRec.gameObject, self.OnDataRec)
	self:RemoveClick(self.BtnDataRepair.gameObject, self.OnDataRepair)
	self:RemoveClick(self.BtnKeFu.gameObject, self.OnKefu)
	self:RemoveClick(self.BtnFight.gameObject, self.OnBtnFight)
	self:RemoveClick(self.BtnSkillOut.gameObject, self.OnBtnSkillTipOut)
	self:RemoveClick(self.BtnLogOut, self.OnBtnLogOut)
	self:RemoveClick(self.BtnAni.gameObject, self.OnAniClick)
	self:RemoveClick(self.BtnVideoBG, self.OnSkipVideo)
	self:RemoveClick(self.BtnGuide, self.OnSwitchGuide)
	self:RemoveClick(self.BtnFuncLock, self.OnSwitchBtnFuncLock)
	self:RemoveClick(self.BtnMv, self.OnBtnMv)
	self:RemoveClick(self.BtnVerify, self.OnBtnVerify)
	self:RemoveClick(self.BtnSetting, self.OnBtnSetting)
	self:RemoveClick(self.ButtonSettingClose, self.OnBtnSettingClose)
	self:RemoveClick(self.BtnCheck, self.OnBtnCheckAsset)
	self:RemoveClick(self.BtnClear, self.OnBtnDelectAsset)
	EventListenerMgr.RemoveAnimListenerEventID(self.Ani.gameObject, self.PlaySoundKlab, self, "OnKlabGames")
	EventListenerMgr.RemoveAnimListenerEventID(self.Ani.gameObject, self.PlaySoundKadokawa, self, "OnKadokawa")
	self:OnUnRegisterEventPageDistrict()
end

function PageLogin:OnBtnVerify()
	self.serDis = self.serData.list:get_Item(self.serData.selfArea)
	self.serList = self.serDis:GetSerList(self.serData.self)
	NetManager.Host = self.serList.host
	NetManager.Port = self.serList.port
	NetData.ServerName = self.serList.name
	NetData.ServerID = self.serData.self

	local DataTestMgr = require("DataVerify")

	DataTestMgr:StartVerify()
end

function PageLogin:OnBtnReset()
	LoadingMgr.Hide(eLoadingType.Repeat)

	local function wrap_cb(index)
		if index == 1 then
			PlayerPrefs.DeleteAll()
		end
	end

	UIMgr.ShowDialog(_("ゲームデータのリセットをおこないますか？"), wrap_cb)
end

function PageLogin:OnBtnSetting()
	self.DlgSetting:SetActive(true)
end

function PageLogin:OnBtnSettingClose()
	self.DlgSetting:SetActive(false)
end

function PageLogin:OnBtnCheckAsset()
	if not AppConst.AssetBundleMode then
		return
	end

	local function wrap_cb(index)
		if index == 1 then
			require("UI/Page/PageSetting/PageCheckAsset")
			UIMgr.SwitchPanel(PageCheckAsset)
		end
	end

	UIMgr.ShowDialog(_("本端末のファイルを修復しますか"), wrap_cb)
end

function PageLogin:OnBtnDelectAsset()
	local function wrap_cb(index)
		if index == 1 then
			AssetHashCheck.DelectAll()
			UIMgr.ShowDialog(_("Desc_DelectFinish"), function(...)
				Restart()
			end)
		end
	end

	UIMgr.ShowDialog(_("Desc_SureDelectDown"), wrap_cb)
end

function PageLogin:OnBtnMv()
	print(234234)

	local data = require("luaData/LoginPageManage")
	local path = "Videos/Opening/AJ_PARA_OP"

	self.videoRes = UIUtil.SetVideoPlayerClip(self.VideoPlayer, path)

	require("Manager/TimerMgr")

	if self.titleTimer then
		TimerMgr.RemoveTimer(self.titleTimer)
	end

	SoundMgr.Stop(SceneLogin.Instance.BGM)
	GOUtil.SetActive(self.BtnVideoBG, true)
	GOUtil.SetActive(self.Bg, false)
end

local rndSoundId = 1

function PageLogin:OnPrepareCompletedVideo()
	rndSoundId = math.random(1, 24)

	if rndSoundId < 10 then
		SoundMgr.LoadBank("VOX_SYS_00" .. rndSoundId .. "0", false, false)
	else
		SoundMgr.LoadBank("VOX_SYS_0" .. rndSoundId .. "0", false, false)
	end
end

function PageLogin:PlaySoundKlab()
	if rndSoundId < 10 then
		SoundMgr.Play("Play_VOX_SYS_00" .. rndSoundId .. "0_0118")
	else
		SoundMgr.Play("Play_VOX_SYS_0" .. rndSoundId .. "0_0118")
	end
end

function PageLogin:PlaySoundKadokawa()
	if rndSoundId < 10 then
		SoundMgr.Play("Play_VOX_SYS_00" .. rndSoundId .. "0_0094")
	else
		SoundMgr.Play("Play_VOX_SYS_0" .. rndSoundId .. "0_0094")
	end
end

function PageLogin:OnSkipVideo()
	GOUtil.SetActive(self.BtnVideoBG, false)
	SoundMgr.PostEvent(SceneLogin.Instance.BGM, UIMgr.UICamera.gameObject)
	GOUtil.SetActive(self.Bg, true)
	GOUtil.UpdateSpineSkeleton(self.Bg)

	self.titleTimer = TimerMgr.AddTimer(eTimerType.RealTime, 2, function()
		if rndSoundId < 10 then
			SoundMgr.Play("Play_VOX_SYS_00" .. rndSoundId .. "0_0097")
		else
			SoundMgr.Play("Play_VOX_SYS_0" .. rndSoundId .. "0_0097")
		end
	end, {})

	GateServer:Connect(NetManager.Host, NetManager.Port)
end

function PageLogin:OnAniClick()
	local step = 0

	for i = 1, #AniMationArr do
		if AniMationArr[i] >= self.ani_ctrl:GetCurrentAnimatorStateInfo(0).normalizedTime then
			step = AniMationArr[i]

			break
		end
	end

	self.ani_ctrl:Play("Login", 0, step)
end

function PageLogin:OnBtnLogOut()
	self.PanelNoticeTop:SetActive(false)
	self.PanelNotice:SetActive(false)

	if SDKMgr.Instance ~= nil then
		local wrap = wrapedCb(self.OnGetLogout, self)

		SDKMgr.GetInstance():Logout(wrap)
	end
end

function PageLogin:OnLoginClicked()
	if not InstructionMgr.isOpen and Kc.Config.KcAppSetting.EnabledDebugMenu then
		PlayerPrefs.SetInt("GuidePassed", 1)
	end

	NetManager.DebugSysTime = tonumber(self.InputFieldTime.text)
	NetManager.DebugLoginID = self.InputField.text

	PlayerPrefs.SetInt("DebugSysTime", NetManager.DebugSysTime)
	NetworkManager.ConnectorGate:SetDebugTime(NetManager.DebugSysTime)

	NetData.ServerName = ""
	NetData.ServerID = ""

	local hasInitSetting = PlayerPrefs.GetInt("InitGraphicSetting", 0)

	if hasInitSetting == 0 then
		local g = self:GetChildGameObject("Panel2")

		g:SetActive(false)

		g = self:GetChildGameObject("Bg/Img_Start")

		g:SetActive(false)
		require("UI/Page/PageLogin/DlgGraphicSetting")
		UIMgr.AddPanel(DlgGraphicSetting(), function()
			PageConnectLogic.StartProcessUserInfo()
		end)
	else
		PageConnectLogic.StartProcessUserInfo()
	end
end

function PageLogin:OnChangeServer()
	NetManager.IsUseInterServer = not NetManager.IsUseInterServer

	local Text = self:GetChildComponent("Panel1/BtnChange/Text", "Text")

	if NetManager.IsUseInterServer then
		Text.text = "内服"
	else
		Text.text = "外用"
	end
end

function PageLogin:OnEnterPageDistrict()
	self.Panel1 = self:GetChildGameObject("Panel1")
	self.Panel2 = self:GetChildGameObject("Panel2")
	self.AgeSafeArea = self:GetChildGameObject("AgeSafeArea")

	self.Panel2:SetActive(false)
	self:SetSafeArea(self.Panel1)
	self:SetSafeArea(self.Panel2)
	self:SetSafeArea(self.AgeSafeArea)

	self.PanelList = self:GetChildGameObject("Panel2/PanelList")
	self.BtnShowList = self:GetChildGameObject("Panel2/PanelSet/BtnShowList")
	self.BtnStart = self:GetChildGameObject("Panel2/StartArea")
	self.PanelSet = self:GetChildGameObject("Panel2/PanelSet")
	self.PanelRecommend = self:GetChildGameObject("Panel2/PanelList/Title/PanelRecommend")
	self.PanelSet = self:GetChildGameObject("Panel2/PanelSet")
	self.PanelTip = self:GetChildGameObject("Panel2/PanelTip")
	self.PanelNotice = self:GetChildGameObject("PanelNotice")
	self.TextNotice = self:GetChildComponent("PanelNotice/Panel/Text", "Text")
	self.BgNotice = self:GetChildGameObject("PanelNotice/Bg")

	self.PanelNotice:SetActive(false)

	self.PanelNoticeTop = self:GetChildGameObject("PanelNoticeTop")
	self.TextNoticeTop = self:GetChildComponent("PanelNoticeTop/Panel/Text", "Text")
	self.BgNoticeTop = self:GetChildGameObject("PanelNoticeTop/Bg")

	self.PanelNoticeTop:SetActive(false)

	self.AgeTipsObj = self:GetChildGameObject("AgeSafeArea/AgeTips")
	self.AgeTipsImg = self:GetChildComponent("AgeSafeArea/AgeTips", "Image")
	self.AageNotice = self:GetChildGameObject("AageNotice")
	self.TextAageNotice = self:GetChildComponent("AageNotice/Panel/Text", "Text")
	self.BgAageNotice = self:GetChildGameObject("AageNotice/Bg")

	self.AageNotice:SetActive(false)

	if GetConfigArgJson("AgeTipsIcon") ~= 0 then
		local path = GetConfigArgJson("AgeTipsIcon")[1]

		if path ~= nil then
			UIUtil.SetImageSprite(self.AgeTipsImg, path, self)
		end
	end

	self.PanelList:SetActive(false)
end

function PageLogin:ChangePageDistrict()
	self.Panel1:SetActive(false)
	self.Panel2:SetActive(true)
	self:RequestServerList()
	self:InitList()
end

function PageLogin:InitList()
	self.ScrollArea = self:GetChildGameObject("Panel2/PanelList/PanelArea/ScrollArea")
	self.ScrollView = GOUtil.AddMissingComponent(self.ScrollArea, "UIScrollView")
	self.ScrollView.vertical = true
	self.ScrollView.content = self:GetChildComponent("Panel2/PanelList/PanelArea/ScrollArea/Content", "Transform")
	self.ScrollServers = self:GetChildGameObject("Panel2/PanelList/PanelServers/ScrollServers")
	self.ScrollServersView = GOUtil.AddMissingComponent(self.ScrollServers, "UIScrollView")
	self.ScrollServersView.vertical = true
	self.ScrollServersView.content = self:GetChildComponent("Panel2/PanelList/PanelServers/ScrollServers/Content", "Transform")
end

function PageLogin:UpdateScrollAreaData()
	if self.listCell then
		for i = 1, #self.listCell do
			local g = self.listCell[i]

			self:RemoveClick(g, self.OnClickSelDistrict)
		end
	end

	self.listCell = {}

	GOUtil.DestroyAllChildren(self.ScrollView.content.gameObject)

	self.serData = self.serInfo.data

	local list = self.serData.list

	for i = 0, list.Count - 1 do
		local g = GOUtil.InstantiatePrefab(ResourceMgr.LoadSync("UI/PanelLogin/CellServer", GameObject), self.ScrollView.content.gameObject)
		local img = GOUtil.AddMissingComponent(g, "Image")

		if i == self.serData.selfArea then
			UIUtil.SetImageSprite(img, "UI/PanelLogin/AtlasLogin/BTN_loginline_01", false)
		else
			UIUtil.SetImageSprite(img, "UI/PanelLogin/AtlasLogin/BTN_loginline_01b", false)
		end

		local serverText = GOUtil.FindChildComponent(g, "Text", "Text")

		serverText.text = list:get_Item(i).name
		g.name = i

		local scrollviewContent = GOUtil.AddMissingComponent(g, "UIScrollViewContent")

		scrollviewContent.scrollView = self.ScrollView

		self:AddClick(g, self.OnClickSelDistrict)
		table.insert(self.listCell, g)
	end
end

function PageLogin:UpdateScrollServerData(selIndex)
	if self.listCellServer then
		for i = 1, #self.listCellServer do
			local g = self.listCellServer[i]

			self:RemoveClick(g, self.OnClickSelServer)
		end
	end

	GOUtil.DestroyAllChildren(self.ScrollServersView.content.gameObject)

	self.listCellServer = {}
	self.serData = self.serInfo.data

	local list = self.serData.list
	local dist = list:get_Item(selIndex)
	local listData = dist.listData

	for i = 0, listData.Count - 1 do
		local info = listData:get_Item(i)
		local g = GOUtil.InstantiatePrefab(ResourceMgr.LoadSync("UI/PanelLogin/CellServerInfo", GameObject), self.ScrollServersView.content.gameObject)

		g.name = tostring(info.id)

		local panelSet = GOUtil.FindChildGameObject(g, "PanelSet")
		local textAera = GOUtil.FindChildComponent(panelSet, "TextAera", "Text")
		local textServer = GOUtil.FindChildComponent(panelSet, "TextServer", "Text")

		textAera.text = dist.name
		textServer.text = info.name

		local imageStatus = GOUtil.FindChildComponent(panelSet, "ImageStatus", "Image")

		UIUtil.SetImageSprite(imageStatus, "UI/PanelLogin/AtlasLogin/ui_word_server_" .. info.status .. "@2x", false)

		local imageNew = GOUtil.FindChildComponent(panelSet, "ImageNew", "Image")

		imageNew.gameObject:SetActive(info.isNew ~= 0)

		if i % 2 == 1 then
			local GoBg = GOUtil.FindChildGameObject(g, "Image")

			GoBg.gameObject:SetActive(false)
		end

		local scrollviewContent = GOUtil.AddMissingComponent(g, "UIScrollViewContent")

		scrollviewContent.scrollView = self.ScrollServersView

		self:AddClick(g, self.OnClickSelServer)
		table.insert(self.listCellServer, g)
	end
end

function PageLogin:InitRecommend(go)
	local TextAera = GOUtil.FindChildComponent(go, "TextAera", "Text")
	local TextServer = GOUtil.FindChildComponent(go, "TextServer", "Text")
	local ImageStatus = GOUtil.FindChildComponent(go, "ImageStatus", "Image")

	if self.serInfo == nil then
		return
	end

	self.serData = self.serInfo.data
	self.serDis = self.serData.list:get_Item(self.serData.selfArea)
	self.serList = self.serDis:GetSerList(self.serData.self)
	TextAera.text = self.serDis.name
	TextServer.text = self.serList.name

	UIUtil.SetImageSprite(ImageStatus, "UI/PanelLogin/AtlasLogin/ui_word_server_" .. self.serList.status .. "@2x", false)
end

function PageLogin:OnClickSelServer(pointEventData)
	local key = pointEventData.pointerPress.name

	self.serDis = self.serData.list:get_Item(self.serData.selfArea)

	local ser = self.serDis:GetSerList(key)

	if ser.status == 4 then
		return
	end

	self.serData.self = key

	self:OnQuitPanelList()
end

function PageLogin:OnClickSelDistrict(pointEventData)
	local index = tonumber(pointEventData.pointerPress.name)

	self.serData.selfArea = index

	self:UpdateScrollAreaData()
	self:UpdateScrollServerData(index)
end

function PageLogin:RequestServerList()
	LoadingMgr.Show(eLoadingType.Repeat)

	if NetManager.SDKToken == nil then
		NetManager.SDKToken = ""
	end

	NetManager:GetServerList(self.OnGetServerList, self)
end

function PageLogin:OnGetServerList(obj)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if obj == nil then
		self:RequestServerList()
	elseif obj.code == 0 then
		self.PanelSet:SetActive(true)
		self.PanelTip:SetActive(false)
		self.BtnStart:SetActive(true)

		self.serInfo = obj

		self:UpdateScrollAreaData()
		self:UpdateScrollServerData(0)
		self:InitRecommend(self.PanelSet)

		NetManager.certify = obj.certify

		if obj.survey == nil or obj.survey == "" then
			-- block empty
		else
			NetManager.SurveyUrl = require("GameLogic.Util.json4lua").decode(obj.survey)
		end

		if NetManager.IsUseSDK then
			self:RequestUserInfo()
		end
	else
		self.TextNotice.text = obj.desc

		self.PanelNotice:SetActive(true)
	end
end

function PageLogin:OnQuitNoticeTop()
	self.PanelNoticeTop:SetActive(false)
	self:StartLogin()
end

function PageLogin:OnQuitNotice()
	self.PanelNotice:SetActive(false)
end

function PageLogin:OnQuitAageNotice()
	self.AageNotice:SetActive(false)
end

function PageLogin:OnRegisterEventPageDistrict()
	self:AddClick(self.BtnShowList.gameObject, self.OnBtnShowList)
	self:AddClick(self.BtnStart, self.OnBtnStart)
	self:AddClick(self.Bg, self.OnQuitPanelList)
	self:AddClick(self.BgNotice, self.OnQuitNotice)
	self:AddClick(self.BgNoticeTop, self.OnQuitNoticeTop)
	self:AddClick(self.AgeTipsObj, self.OpenAgeTipsObj)
	self:AddClick(self.BgAageNotice, self.OnQuitAageNotice)
end

function PageLogin:OnUnRegisterEventPageDistrict()
	self:RemoveClick(self.BtnShowList.gameObject, self.OnBtnShowList)
	self:RemoveClick(self.BtnStart, self.OnBtnStart)
	self:RemoveClick(self.Bg, self.OnQuitPanelList)
	self:RemoveClick(self.BgNotice, self.OnQuitNotice)
	self:RemoveClick(self.BgNoticeTop, self.OnQuitNoticeTop)
	self:RemoveClick(self.AgeTipsObj, self.OpenAgeTipsObj)
	self:RemoveClick(self.BgAageNotice, self.OnQuitAageNotice)
end

function PageLogin:OpenAgeTipsObj()
	self.TextAageNotice.text = _("AgeWarning")

	self.AageNotice:SetActive(true)
end

function PageLogin:OnBtnShowList()
	self.PanelList:SetActive(true)
	self.PanelSet:SetActive(false)
	self.BtnStart:SetActive(false)
	self:UpdateScrollAreaData()
	self:UpdateScrollServerData(self.serData.selfArea)
	self:InitRecommend(self.PanelRecommend)
end

function PageLogin:OnQuitPanelList()
	self.PanelList:SetActive(false)
	self.PanelSet:SetActive(true)
	self.BtnStart:SetActive(true)
	self:InitRecommend(self.PanelSet)

	if self.listCell then
		for i = 1, #self.listCell do
			local g = self.listCell[i]

			self:RemoveClick(g, self.OnClickSelDistrict)
		end
	end

	if self.listCellServer then
		for i = 1, #self.listCellServer do
			local g = self.listCellServer[i]

			self:RemoveClick(g, self.OnClickSelServer)
		end
	end
end

function PageLogin:RequestInitSDK()
	local wrap = wrapedCb(self.OnInitSDK, self)

	OzSDKManager.Instance:InitSDK(wrap)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageLogin:OnInitSDK(str)
	LoadingMgr.Hide(eLoadingType.Repeat)
	print("PageLogin:OnInitSDK")

	local json = require("GameLogic/Util/json4lua")
	local dict = json.decode(str)
	local code = dict.code
	local callbackType = dict.callbackType

	if callbackType == "Init" and tonumber(code) == 1 then
		self.initsdk = true
	end
end

function PageLogin:OnBtnStart()
	if self.serData == nil or self.serData.list == nil or self.serData.list.Count < 1 then
		self:RequestServerList()

		return
	end

	self.serDis = self.serData.list:get_Item(self.serData.selfArea)
	self.serList = self.serDis:GetSerList(self.serData.self)

	self:OnQuitPanelList()

	NetManager.Host = self.serList.host
	NetManager.Port = self.serList.port
	NetData.ServerName = self.serList.name
	NetData.ServerID = self.serData.self

	if SDKMgr.Instance ~= nil then
		SDKMgr:LoginArea(tostring(NetData.ServerID))
	end

	self:OnQuitPanelList()

	local hasInitSetting = PlayerPrefs.GetInt("InitGraphicSetting", 0)

	if hasInitSetting == 0 then
		local g = self:GetChildGameObject("Panel2")

		g:SetActive(false)

		g = self:GetChildGameObject("Bg/Img_Start")

		g:SetActive(false)
		require("UI/Page/PageLogin/DlgGraphicSetting")
		UIMgr.AddPanel(DlgGraphicSetting(), function()
			UIMgr.SwitchPanel(PageConnect)
		end)
	else
		UIMgr.SwitchPanel(PageConnect)
	end
end

function PageLogin:OnDataRec()
	UIMgr.AddPanel(PagePlatformSelect(), {
		useForLogin = true
	})
end

function PageLogin:OnDataRepair()
	local function wrap_cb(index)
		if index == 1 then
			Launcher.Instance:DataRepair()
		end
	end

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("PageTitleMenu_data_repair_title"), _("PageTitleMenu_data_repair_desc"), wrap_cb, _("UI_confirm"), _("Quite_Cancel"), true)
end

function PageLogin:OnKefu()
	UIMgr.AddPanel(PageUserSupport(), {})
end

function PageLogin:OnBtnOffLine()
	local function OnCallback(index)
		print("index:" .. index)

		if index == 1 then
			PlayerPrefs.SetInt("GuidePassed", 1)
			Restart()
		end
	end

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), _("VER_UPDATE_CONFIRM"), OnCallback, _("UI_OK"), _("Quite_Cancel"), true)
end

function PageLogin:OnBtnFight()
	local sceneName = "SkillViewer"

	SceneMgr.LoadScene(sceneName, nil)
end

function PageLogin:OnBtnSkillTipOut()
	local SkillDesc = require("UI/Dlg/Common/SkillTipDesc")

	SkillDesc.GetAllDescList()
	BuffTip.GetAllBuffTips()
	CollectionManager:GetAllTaskDesc()
end

function PageLogin:OnSwitchGuide()
	InstructionMgr.isOpen = not InstructionMgr.isOpen

	local Text = self:GetChildComponent("Panel1/BtnGuide/Text", "Text")

	if InstructionMgr.isOpen then
		Text.text = "初心者ON"
	else
		Text.text = "初心者OFF"
	end
end

function PageLogin:OnSwitchBtnFuncLock()
	OpenAllLock = not OpenAllLock

	local Text = self:GetChildComponent("Panel1/BtnFuncLock/Text", "Text")

	if OpenAllLock then
		Text.text = "機能全開"
	else
		Text.text = "機能ロック"
	end
end

function PageLogin:RequestSerNotice()
	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:GetServerNotice(self.OnGetServerNotice, self)
end

function PageLogin:OnGetServerNotice(obj)
	print("request server notice")
	LoadingMgr.Hide(eLoadingType.Repeat)

	if obj == nil then
		self:RequestSerNotice()
	elseif obj.code == 0 then
		local ct = DateTimeUtil.GetCurrentTime()

		if ct >= obj.black_start_ts and ct <= obj.black_end_ts then
			self.TextNotice.text = obj.black

			self.PanelNotice:SetActive(true)

			return
		end

		if obj.news == nil or obj.news == "" then
			self:StartLogin()
		else
			self.TextNoticeTop.text = obj.news
			NetManager.NoticeTxt = obj.news

			self.PanelNoticeTop:SetActive(true)
		end

		self.needGetSerNotice = false
	else
		self:RequestSerNotice()
	end
end

function PageLogin:OnBackAndroid()
	if GOUtil.IsActiveSelf(self.BtnAni.gameObject) then
		self:OnAniClick()

		return true
	end

	if GOUtil.IsActiveSelf(self.BtnVideoBG) then
		self:OnSkipVideo()

		return true
	end

	return false
end
