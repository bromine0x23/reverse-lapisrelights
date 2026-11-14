-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageSetting/PageOption.lua

PageOption = class("PageOption", UIPanel)

function PageOption:ctor()
	self.UIPrefabPath = "UI/PanelSetting/PanelOption"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_setting"),
		callback = self.OnBack,
		panel = self
	})
end

function PageOption:PreLoad()
	return
end

function PageOption:Purge()
	self.base.Purge(self)

	if self.videoRes then
		ResourceMgr.Unload(self.videoRes)

		self.videoRes = nil
	end

	if self.videoAniRes then
		ResourceMgr.Unload(self.videoAniRes)

		self.videoAniRes = nil
	end

	self.VideoPlayer.loopPointReached = self.VideoPlayer.loopPointReached - function()
		self:OnSkipVideo()
	end
end

function PageOption:OnEnter()
	local function wrap_cb(res)
		LoadingMgr.Hide(eLoadingType.Repeat)

		local cleared_ids = res.cleared_ids

		if Application.platform:ToInt() == RuntimePlatform.IPhonePlayer then
			print("update for ios")

			for i = 1, #cleared_ids do
				cleared_ids[i] = string.gsub(cleared_ids[i], "-", "")
			end
		end

		GameServiceSupport.GetInstance():ReportScore(cleared_ids)
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:GetClearedPlatformAchievement(wrap_cb)

	self.BtnSetting = GOUtil.FindChildGameObject(self.UIRootObject, "BtnSetting")
	self.BtnNotice = GOUtil.FindChildGameObject(self.UIRootObject, "BtnNotice")
	self.BtnReturnLogin = GOUtil.FindChildGameObject(self.UIRootObject, "grid/BtnReturnLogin")
	self.BtnCdkey = GOUtil.FindChildGameObject(self.UIRootObject, "grid/BtnCdkey")

	self.BtnCdkey:SetActive(false)

	self.BtnAni = GOUtil.FindChildGameObject(self.UIRootObject, "grid/BtnAni")
	self.BtnAsk = GOUtil.FindChildGameObject(self.UIRootObject, "grid/BtnAsk")
	self.BtnDownLoad = GOUtil.FindChildGameObject(self.UIRootObject, "grid/BtnDownLoad")
	self.BtnRemove = GOUtil.FindChildGameObject(self.UIRootObject, "grid/BtnRemove")
	self.BtnKefu = GOUtil.FindChildGameObject(self.UIRootObject, "BtnKefu")
	self.BtnDownLoadSetting = GOUtil.FindChildGameObject(self.UIRootObject, "grid/BtnDownLoadSetting")
	self.BtnMV = GOUtil.FindChildGameObject(self.UIRootObject, "BtnMV")
	self.BtnHelp = GOUtil.FindChildGameObject(self.UIRootObject, "grid/BtnHelp")
	self.BtnVideoBG = GOUtil.FindChildGameObject(self.UIRootObject, "VideoBG")
	self.VideoPlayer = GOUtil.FindChildComponent(self.UIRootObject, "VideoBG/Video", "VideoPlayer")
	self.VideoPlayer.loopPointReached = self.VideoPlayer.loopPointReached + function()
		self:OnSkipVideo()
	end
	self.Btn_1_4 = GOUtil.FindChildGameObject(self.UIRootObject, "grid/Btn_1_4")
	self.Btn_2_2 = GOUtil.FindChildGameObject(self.UIRootObject, "grid/Btn_2_2")
	self.Btn_2_4 = GOUtil.FindChildGameObject(self.UIRootObject, "grid/Btn_2_4")
	self.Btn_3_1 = GOUtil.FindChildGameObject(self.UIRootObject, "grid/Btn_3_1")
	self.Btn_3_2 = GOUtil.FindChildGameObject(self.UIRootObject, "grid/Btn_3_2")
	self.Btn_3_3 = GOUtil.FindChildGameObject(self.UIRootObject, "grid/Btn_3_3")

	self:InitText()

	local images = GOUtil.FindChildGameObject(self.UIRootObject, "grid").transform:GetComponentsInChildren(TypeUtil.GetType("Image"), true)

	for i = 1, images.Length do
		GOUtil.SetRectTransformAnchoredPosition(images[i - 1].gameObject, -110, 0)
	end

	local helpDot = GOUtil.FindChildGameObject(self.UIRootObject, "grid/BtnHelp/Dot")

	if helpDot then
		GOUtil.SetRectTransformAnchoredPosition(helpDot, -26, -12)
	end
end

function PageOption:OnRegisterEvent()
	self:AddClick(self.BtnSetting, self.OnClickBtnSetting)
	self:AddClick(self.BtnNotice, self.OnClickedBtn_3_2)
	self:AddClick(self.BtnReturnLogin, self.OnClickReturnLogin)
	self:AddClick(self.BtnCdkey, self.OnClickBtnCdKey)
	self:AddClick(self.BtnAni, self.OnClickBtnAni)
	self:AddClick(self.BtnAsk, self.OnClickBtnAsk)
	self:AddClick(self.BtnDownLoad, self.OnClickBtnDownLoad)
	self:AddClick(self.BtnKefu, self.OnClickBtnKefu)
	self:AddClick(self.BtnRemove, self.OnClickBtnRemove)
	self:AddClick(self.BtnDownLoadSetting, self.OnClickBtnDownLoadSetting)
	self:AddClick(self.BtnVideoBG, self.OnSkipVideo)
	self:AddClick(self.BtnMV, self.OnBtnMv)
	self:AddClick(self.BtnHelp, self.OnBtnHelp)
	self:AddClick(self.Btn_1_4, self.OnClickedBtn_1_4)
	self:AddClick(self.Btn_2_2, self.OnClickedBtn_2_2)
	self:AddClick(self.Btn_2_4, self.OnClickedBtn_2_4)
	self:AddClick(self.Btn_3_1, self.OnClickedBtn_3_1)
	self:AddClick(self.Btn_3_3, self.OnClickedBtn_3_3)
end

function PageOption:OnUnRegisterEvent()
	self:RemoveClick(self.BtnSetting, self.OnClickBtnSetting)
	self:RemoveClick(self.BtnNotice, self.OnClickBtnNotice)
	self:RemoveClick(self.BtnReturnLogin, self.OnClickReturnLogin)
	self:RemoveClick(self.BtnCdkey, self.OnClickBtnCdKey)
	self:RemoveClick(self.BtnAni, self.OnClickBtnAni)
	self:RemoveClick(self.BtnAsk, self.OnClickBtnAsk)
	self:RemoveClick(self.BtnDownLoad, self.OnClickBtnDownLoad)
	self:RemoveClick(self.BtnKefu, self.OnClickBtnKefu)
	self:RemoveClick(self.BtnRemove, self.OnClickBtnRemove)
	self:RemoveClick(self.BtnDownLoadSetting, self.OnClickBtnDownLoadSetting)
	self:RemoveClick(self.BtnVideoBG, self.OnSkipVideo)
	self:RemoveClick(self.BtnMV, self.OnBtnMv)
	self:RemoveClick(self.BtnHelp, self.OnBtnHelp)
	self:RemoveClick(self.Btn_1_4, self.OnClickedBtn_1_4)
	self:RemoveClick(self.Btn_2_2, self.OnClickedBtn_2_2)
	self:RemoveClick(self.Btn_2_4, self.OnClickedBtn_2_4)
	self:RemoveClick(self.Btn_3_1, self.OnClickedBtn_3_1)
	self:RemoveClick(self.Btn_3_3, self.OnClickedBtn_3_3)
end

function PageOption:OnLeave()
	return
end

function PageOption:OnBack()
	UIMgr.PopPanel()
end

function PageOption:OnBtnHelp()
	require("UI/Page/PageSetting/PageHelp")
	UIMgr.SwitchPanel(PageHelp())
end

function PageOption:OnClickBtnSetting()
	require("UI/Page/PageSetting/PageSetting")
	UIMgr.AddPanel(PageSetting())
end

function PageOption:OnClickBtnNotice()
	require("UI/Dlg/Public/DlgWeb")
	PersistentStoreUtil.SetInt(PersistentStoreUtil.KEY_WEBVIEW_TIME, InfoGameInst.gameInfo.webTime)
	UIMgr.AddPanel(DlgWeb(), {
		isAuto = false
	})
end

function PageOption:OnClickReturnLogin()
	UIMgr.ShowCommon(DlgCommonEvent.Type.Del, _("Desc_Alert"), _("Desc_BackLoginScene"), function(index)
		if index == 1 then
			Restart()
		end
	end, _("UI_OK"), _("Quite_Cancel"), false)
end

function PageOption:OnClickBtnCdKey()
	UIMgr.ShowMsg(Lang(12173))
end

function PageOption:OnClickBtnAni()
	local path = "Videos/Opening/AJ_PARA_OP"

	self.videoAniRes = UIUtil.SetVideoPlayerClip(self.VideoPlayer, path)

	SetActiveFunc(self.BtnVideoBG, true)
	InfoBGMEventMgr:StopBGM()
end

function PageOption.CheckAsk()
	if NetManager.SurveyUrl == nil then
		return false
	end

	local serverTime = NetData:GetCurServerTime() / 1000

	if serverTime >= NetManager.SurveyUrl.start_time and serverTime <= NetManager.SurveyUrl.end_time then
		return true
	end

	return false
end

function PageOption:OnClickBtnAsk()
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			local function call(Msg)
				LoadingMgr.Hide(eLoadingType.Repeat)

				if Msg.result.code == NetManager.Result_Sucess then
					UIMgr.ShowMsg("イベント参加に成功")
				else
					UIMgr.ShowMsg(Msg.result.desc, Msg)
				end
			end

			local function fun()
				NetManager:RequestGetQuestionReward(call)
				LoadingMgr.Show(eLoadingType.Repeat)
			end

			NotificationSender.questionCall = fun

			Application.OpenURL(NetManager.SurveyUrl.url)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	NetManager:RequestQuestionnaire(wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageOption:OnClickBtnRemove()
	local function wrap_cb1(vMsg)
		local function wrap_cb2(index)
			print(index)
		end

		UIMgr.ShowCommon(DlgCommonEvent.Type.Del, _("Account_DoubleApplyTitle"), _("Account_DoubleApplyText"), wrap_cb2, _("UI_OK"), _("Quite_Cancel"), false)
	end

	UIMgr.ShowCommon(DlgCommonEvent.Type.Del, _("Account_ApplyTitle"), _("Account_ApplyText"), wrap_cb1, _("Account_ApplyButton"), nil, false)
end

function PageOption:OnClickBtnService()
	UIMgr.ShowMsg(Lang(12173))
end

function PageOption:OnClickBtnDownLoad()
	if AppConst.AssetBundleMode then
		local function callback(exist)
			if not exist then
				require("UI/Page/PageSetting/DlgOptionalDownload")

				local data = {}

				data.openFrom = 3

				function data.callback()
					local strContent = _("Desc_DownloadFinish")

					UIMgr.ShowCommon(DlgCommonEvent.Type.Del, _("Desc_Alert"), _("Desc_DownloadFinish"), function()
						if PersistentStoreUtil.GetBool(PersistentStoreUtil.KEY_OPTIONAL_ASSET_AUTO_DELECT) then
							UIMgr.ShowCommon(DlgCommonEvent.Type.Del, _("Desc_Alert"), _("Desc_OpenDelectTip"), function(index)
								if index == 1 then
									self:OnClickBtnDownLoadSetting()
								end
							end, _("UI_OK"), _("Quite_Cancel"), false)
						end
					end, _("UI_OK"), nil, false)
				end

				UIMgr.AddPanel(DlgOptionalDownload(), data)
			else
				UIMgr.ShowMsg(_("Msg_Download_All"))
			end
		end

		if #OptionDownMgr.CurDownloadList == 0 then
			OptionDownMgr:CheckAll(callback)
		else
			callback()
		end
	else
		UIMgr.ShowMsg(_("Msg_Download_All"))
	end
end

function PageOption:OnClickBtnDownLoadSetting()
	if #OptionDownMgr.CurDownloadList == 0 then
		require("UI/Page/PageSetting/DlgDownloadSetting")
		UIMgr.AddPanel(DlgDownloadSetting())
	else
		UIMgr.ShowMsg(_("Desc_Downloading"))
	end
end

function PageOption:OnClickBtnKefu()
	UIMgr.AddPanel(PageUserSupport(), {})
end

function PageOption:OnSkipVideo()
	SetActiveFunc(self.BtnVideoBG, false)
	InfoBGMEventMgr:ReplayBGM()
end

function PageOption:OnBtnMv()
	local data = require("luaData/LoginPageManage")

	self.videoRes = UIUtil.SetVideoPlayerClip(self.VideoPlayer, data[1].Resource)

	SetActiveFunc(self.BtnVideoBG, true)
	InfoBGMEventMgr:StopBGM()
end

function PageOption:OnClickedBtn_1_4()
	UIMgr.AddPanel(PagePlatformSelect(), {
		useForLogin = false
	})
end

function PageOption:OnClickedBtn_2_2()
	UIMgr.AddPanel(PagePayRule(), {
		curIndex = 1,
		mode = 2
	})
end

function PageOption:OnClickedBtn_2_4()
	local function wrap_cb()
		UIMgr.ShowDialog(Localization("PageOtherMenu_plz_signin_gc"), nil)
	end

	GameServiceSupport.GetInstance():ShowAchievements(wrap_cb)
end

function PageOption:OnClickedBtn_3_1()
	UIMgr.AddPanel(PageCopyright(), {})
end

function PageOption:OnClickedBtn_3_2()
	UIMgr.AddPanel(PageHistory(), {})
end

function PageOption:OnClickedBtn_3_3()
	require("UI/Page/PageOtherMenu/PageAccountDel")

	local function secondCb()
		UIMgr.AddPanel(PageAccountDel(), {
			okText = _("UI_confirm"),
			canelText = _("Quite_Cancel"),
			title = _("Account_DoubleApplyTitle"),
			content = _("Account_DoubleApplyText"),
			cb = function()
				LoadingMgr.Show(eLoadingType.Repeat)
				NetManager:RequestACDel(function()
					PlayerPrefs.SetInt(PersistentStoreUtil.KEY_ACCOUNT_DELETED, 1)
					LoadingMgr.Hide(eLoadingType.Repeat)
				end)
			end
		})
	end

	UIMgr.AddPanel(PageAccountDel(), {
		okText = _("Account_ApplyButton"),
		title = _("Account_ApplyTitle"),
		content = _("Account_ApplyText"),
		cb = secondCb
	})
end

function PageOption:FormatButtonText(text)
	local s = string.gsub(text, "<[^>]*>", "")

	return s
end

function PageOption:UpdateButtonText(btnPath, key)
	if key == "" then
		GOUtil.FindChildGameObject(self.UIRootObject, "grid/" .. btnPath).gameObject:SetActive(false)

		return
	end

	self:GetChildComponent("grid/" .. btnPath .. "/Text", "Text").text = self:FormatButtonText(_(key))
end

function PageOption:InitText()
	local TextAuto

	TextAuto = self:GetChildComponent("BtnSetting/Text", "Text")
	TextAuto.text = Lang(5000066)
	TextAuto = self:GetChildComponent("BtnNotice/Text/", "Text")
	TextAuto.text = _("Option_Notice")
	TextAuto = self:GetChildComponent("grid/BtnReturnLogin/Text/", "Text")
	TextAuto.text = self:FormatButtonText(Lang(5000088))
	TextAuto = self:GetChildComponent("grid/BtnCdkey/Text/", "Text")
	TextAuto.text = self:FormatButtonText(Lang(5000089))
	TextAuto = self:GetChildComponent("grid/BtnAni/Text/", "Text")
	TextAuto.text = self:FormatButtonText(Lang(5000090))
	TextAuto = self:GetChildComponent("grid/BtnAsk/Text/", "Text")
	TextAuto.text = self:FormatButtonText(Lang(5000092))
	TextAuto.text = _("Option_Service")
	TextAuto = self:GetChildComponent("grid/BtnDownLoad/Text/", "Text")
	TextAuto.text = _("Option_DownLoad")
	TextAuto = self:GetChildComponent("BtnKefu/Text/", "Text")
	TextAuto.text = Lang(5000095)
	TextAuto = self:GetChildComponent("BtnMV/Text/", "Text")
	TextAuto.text = _("Desc_AniReplay")

	self:UpdateButtonText("Btn_1_4", "PageOtherMenu_account_link")
	self:UpdateButtonText("Btn_2_2", "PageOtherMenu_rule")
	self:UpdateButtonText("Btn_2_4", "PageOtherMenu_achievement")
	self:UpdateButtonText("Btn_3_1", "PageOtherMenu_copyright")
	self:UpdateButtonText("Btn_3_2", "")
	self:UpdateButtonText("Btn_3_3", Application.platform:ToInt() == RuntimePlatform.Android and "" or "Account_Enter")
	self:UpdateButtonText("BtnAsk", "")
	self:UpdateButtonText("BtnRemove", "")
end

function PageOption:OnBackAndroid()
	if GOUtil.IsActiveSelf(self.BtnVideoBG) then
		self:OnSkipVideo()

		return true
	end

	return false
end
