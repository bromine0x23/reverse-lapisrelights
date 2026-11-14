-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageSetting/DlgOptionalDownload.lua

DlgOptionalDownload = class("DlgOptionalDownload", UIPanel)

function DlgOptionalDownload:ctor()
	DlgOptionalDownload.base.ctor(self, "UI/PanelSetting/DlgDownLoad")
end

function DlgOptionalDownload:Purge()
	DlgOptionalDownload.base.Purge(self)
	self:OnLeave()
	OptionDownMgr:RemoveCallback(self.id, self.openFrom)
end

function DlgOptionalDownload:OnLeave()
	return
end

function DlgOptionalDownload:OnRegisterEvent()
	self:AddClick(self.BtnClose, self.Close)
	self:AddClick(self.AllBtn, self.OnClickAll)
	self:AddClick(self.OnlyVideoBtn, self.OnClickOnlyVideo)
	self:AddClick(self.Group2DownBtn, self.OnClickOnlySound)
	self:AddClick(self.BtnNotDown, self.OnClickNone)
	self:AddClick(self.Group3DownBtn, self.OnClickOnlyVideo)
	self:AddClick(self.CancelBtn, self.OnClickCancle)
	self:AddClick(self.Group5CancleBtn, self.Close)
	self:AddClick(self.DownloadAllBtn, self.OnClickDownloadAll)
end

function DlgOptionalDownload:OnUnRegisterEvent()
	self:RemoveClick(self.BtnClose, self.Close)
	self:RemoveClick(self.AllBtn, self.OnClickAll)
	self:RemoveClick(self.OnlyVideoBtn, self.OnClickOnlyVideo)
	self:RemoveClick(self.Group2DownBtn, self.OnClickOnlySound)
	self:RemoveClick(self.BtnNotDown, self.OnClickNone)
	self:RemoveClick(self.Group3DownBtn, self.OnClickOnlyVideo)
	self:RemoveClick(self.CancelBtn, self.OnClickCancle)
	self:RemoveClick(self.Group5CancleBtn, self.Close)
	self:RemoveClick(self.DownloadAllBtn, self.OnClickDownloadAll)
end

function DlgOptionalDownload:OnEnter(vParam)
	self.callback = vParam.callback
	self.existType = vParam.existType
	self.stageId = vParam.stageId
	self.openFrom = vParam.openFrom
	self.BtnClose = self:GetChildGameObject("BtnClose")
	self.Group1 = self:GetChildGameObject("Group1")
	self.AllBtn = self:GetChildGameObject("Group1/AllBtn")
	self.OnlyVideoBtn = self:GetChildGameObject("Group1/OnlyVideoBtn")
	self.AllSize = self:GetChildComponent("Group1/AllSize", "Text")
	self.OnlyVideoSize = self:GetChildComponent("Group1/OnlyVideoSize", "Text")
	self.Group2 = self:GetChildGameObject("Group2")
	self.Group2DownBtn = self:GetChildGameObject("Group2/DownBtn")
	self.BtnNotDown = self:GetChildGameObject("Group2/BtnNotDown")
	self.Group2AllSize = self:GetChildComponent("Group2/AllSize", "Text")
	self.Group3 = self:GetChildGameObject("Group3")
	self.Group3DownBtn = self:GetChildGameObject("Group3/DownBtn")
	self.Group3AllSize = self:GetChildComponent("Group3/AllSize", "Text")
	self.Group4 = self:GetChildGameObject("Group4")
	self.CancelBtn = self:GetChildGameObject("Group4/CancelBtn")
	self.Group5 = self:GetChildGameObject("Group5")
	self.DownloadAllBtn = self:GetChildGameObject("Group5/DownloadBtn")
	self.Group5CancleBtn = self:GetChildGameObject("Group5/CancleBtn")
	self.TopText = self:GetChildComponent("TopText", "Text")
	self.TextDes = self:GetChildComponent("TextDes", "Text")
	self.DownloadSpeed = self:GetChildComponent("DownloadSpeed", "Text")
	self.Slider = self:GetChildComponent("Slider", "Slider")
	self.Tip = self:GetChildGameObject("Tip")
	self.Tip1 = self:GetChildComponent("Tip/Tip1", "Text")

	self:LocalText()

	if self.openFrom == 3 then
		self.id = 0
	elseif self.stageId then
		self.id = self.stageId
	end

	local isContains = OptionDownMgr:CheckIsDownload(self.id, self.openFrom)

	if not isContains then
		self:InitButton()
		self:InitData()
	else
		self:AddCallback()
	end
end

function DlgOptionalDownload:LocalText()
	local Text

	self.TopText.text = Lang(5000099)
	Text = self:GetChildComponent("Tital", "Text")
	Text.text = Lang(5000098)
	Text = self:GetChildComponent("Group1/AllBtn/Text", "Text")
	Text.text = Lang(5000102)
	Text = self:GetChildComponent("Group1/OnlyVideoBtn/Text", "Text")
	Text.text = Lang(5000103)
	Text = self:GetChildComponent("Group2/DownBtn/Text", "Text")
	Text.text = _("Desc_DownVoice")
	Text = self:GetChildComponent("Group2/BtnNotDown/Text", "Text")
	Text.text = _("Desc_NotDownVoice")
	Text = self:GetChildComponent("Group3/DownBtn/Text", "Text")
	Text.text = _("Desc_DownVideo")
	Text = self:GetChildComponent("Group4/CancelBtn/Text", "Text")
	Text.text = _("Desc_CancelDown")
	Text = self:GetChildComponent("Group5/DownloadBtn/Text", "Text")
	Text.text = _("UI_download")
	Text = self:GetChildComponent("Group5/CancleBtn/Text", "Text")
	Text.text = _("OptionalDownload_Cancel")
end

function DlgOptionalDownload:InitButton()
	if self.openFrom == 3 then
		self.Group5:SetActive(true)
	elseif self.existType == eDownloadType.none then
		self.Group1:SetActive(true)

		self.OnlyVideoSize.text = OptionDownMgr:GetDownSize(self.stageId, eDownloadType.onlyVideo, self.openFrom)
		self.AllSize.text = OptionDownMgr:GetDownSize(self.stageId, eDownloadType.all, self.openFrom)
	elseif self.existType == eDownloadType.onlyVideo then
		self.Group2:SetActive(true)

		self.Group2AllSize.text = OptionDownMgr:GetDownSize(self.stageId, eDownloadType.onlySound, self.openFrom)
	elseif self.existType == eDownloadType.onlySound then
		self.Group3:SetActive(true)

		self.Group3AllSize.text = OptionDownMgr:GetDownSize(self.stageId, eDownloadType.onlyVideo, self.openFrom)
	end
end

function DlgOptionalDownload:InitData()
	if self.openFrom == 1 then
		local infoStage = ChapterMgr:GetStage(self.stageId)
		local chapNum = ChapterMgr:GetChapterIdx(infoStage.data.ChapterID)

		self.TextDes.text = _("PageChapter_title") .. " " .. infoStage:GetName()
	elseif self.openFrom == 2 then
		local infoPhone = PhoneCallManager:Get(self.stageId)

		self.TextDes.text = Lang(5000061) .. " " .. Lang(infoPhone.data.Name)
	elseif self.openFrom == 3 then
		self.TopText.text = string.format(_("Desc_DownLoad"), OptionDownMgr:GetAllDownSize())
		self.TextDes.text = ""
	end

	self.Tip:SetActive(true)

	local isOn = PersistentStoreUtil.GetBool(PersistentStoreUtil.KEY_OPTIONAL_ASSET_AUTO_DELECT)

	self.Tip1.text = TenaryOp(isOn, _("Desc_AutoDeleteOpen"), _("Desc_AutoDeleteClose"))
end

function DlgOptionalDownload:OnClickOnlySound()
	self:RequestDownload(eDownloadType.onlySound)
end

function DlgOptionalDownload:OnClickOnlyVideo()
	self:RequestDownload(eDownloadType.onlyVideo)
end

function DlgOptionalDownload:OnClickAll()
	self:RequestDownload(eDownloadType.all)
end

function DlgOptionalDownload:RequestDownload(type, isContinue)
	self.type = type

	local function DownloadFinsh()
		self:Close()
		self:Close()

		if self.callback then
			self.callback()

			self.callback = nil
		end
	end

	local function DownloadError(errorText)
		local str = _("Desc_NoNetwork")

		if errorText == "notWifi" then
			str = _("Download_WifiChange")
		elseif errorText == "Check hash failed" then
			str = _("Download_HashCheckFailed")
		end

		print(errorText)
		UIMgr.ShowCommon(DlgCommonEvent.Type.Del, _("Desc_Alert"), str, function(index)
			if index == DlgCommonEvent.ButtonType.Ok then
				OptionDownMgr:ContinueDownload()
			else
				self:Close()
				OptionDownMgr:CancleContinueDownload()

				self.callback = nil
			end
		end, _("リトライ"), _("OptionalDownload_Cancel"), false)
	end

	local function UpdateProgress(value, str)
		self.Slider.value = value
		self.DownloadSpeed.text = str
	end

	local function cb(index)
		if index == 1 then
			self.Group1:SetActive(false)
			self.Group2:SetActive(false)
			self.Group3:SetActive(false)
			self.TextDes.gameObject:SetActive(false)
			self.Group4:SetActive(true)
			self.Slider.gameObject:SetActive(true)
			self.DownloadSpeed.gameObject:SetActive(true)
			self.BtnClose:SetActive(false)
			self.Tip:SetActive(false)

			self.TopText.text = _("Desc_Downloading")

			OptionDownMgr:RequestDownload(self.stageId, DownloadFinsh, DownloadError, UpdateProgress, type, self.openFrom, isContinue)
		end
	end

	if tostring(Application.internetReachability) == "ReachableViaCarrierDataNetwork" then
		local strContent = _("Desc_NetworkChange")

		UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), strContent, cb, _("UI_OK"), _("OptionalDownload_Cancel"), true)
	else
		cb(1, true)
	end
end

function DlgOptionalDownload:OnClickNone()
	self:Close()

	if self.callback then
		self.callback()

		self.callback = nil
	end
end

function DlgOptionalDownload:OnClickCancle()
	self:Close()
	OptionDownMgr:CancelOptionalDownload(self.id, self.openFrom)
end

function DlgOptionalDownload:OnClickDownloadAll(isContinue)
	local function DownloadFinsh()
		self:Close()
		self:Close()

		if self.callback then
			self.callback()

			self.callback = nil
		end
	end

	local function DownloadError(errorText)
		local str = _("Desc_NoNetwork")

		if errorText == "notWifi" then
			str = _("Download_WifiChange")
		elseif errorText == "Check hash failed" then
			str = _("Download_HashCheckFailed")
		end

		print(errorText)
		UIMgr.ShowCommon(DlgCommonEvent.Type.Del, _("Desc_Alert"), str, function(index)
			if index == DlgCommonEvent.ButtonType.Ok then
				OptionDownMgr:ContinueDownload()
			else
				self:Close()
				OptionDownMgr:CancleContinueDownload()

				self.callback = nil
			end
		end, _("リトライ"), _("OptionalDownload_Cancel"), false)
	end

	local function UpdateProgress(value, str)
		self.Slider.value = value
		self.DownloadSpeed.text = str
	end

	local function cb(index)
		if index == DlgCommonEvent.ButtonType.OkNoMoreTips then
			OptionDownMgr.needTips = false
		end

		if index == DlgCommonEvent.ButtonType.Ok or index == DlgCommonEvent.ButtonType.OkNoMoreTips then
			self.TextDes.gameObject:SetActive(false)
			self.Group4:SetActive(true)
			self.Group5:SetActive(false)
			self.Slider.gameObject:SetActive(true)
			self.DownloadSpeed.gameObject:SetActive(true)
			self.Tip:SetActive(false)

			self.TopText.text = _("Desc_Downloading")

			self.BtnClose:SetActive(false)
			OptionDownMgr:RequestDownloadVideo(0, DownloadFinsh, DownloadError, UpdateProgress, nil, isContinue)
		end
	end

	if tostring(Application.internetReachability) == "ReachableViaCarrierDataNetwork" and OptionDownMgr.needTips then
		local strContent = _("Desc_NetworkChange")

		UIMgr.ShowCommon(DlgCommonEvent.Type.TodayNoMoreTips, _("Desc_Alert"), {
			strContent
		}, cb, _("UI_OK"), _("OptionalDownload_Cancel"), true)
	else
		cb(1, true)
	end
end

function DlgOptionalDownload:AddCallback()
	local function DownloadFinsh()
		self:Close()
		self:Close()

		if self.callback then
			self.callback()

			self.callback = nil
		end
	end

	local function DownloadError(errorText)
		local str = _("Desc_NoNetwork")

		if errorText == "notWifi" then
			str = _("Download_WifiChange")
		elseif errorText == "Check hash failed" then
			str = _("Download_HashCheckFailed")
		end

		print(errorText)
		UIMgr.ShowCommon(DlgCommonEvent.Type.Del, _("Desc_Alert"), str, function(index)
			if index == DlgCommonEvent.ButtonType.Ok then
				OptionDownMgr:ContinueDownload()
			else
				self:Close()
				OptionDownMgr:CancleContinueDownload()

				self.callback = nil
			end
		end, _("リトライ"), _("Quite_Cancel"), false)
	end

	local function UpdateProgress(value, str)
		self.Slider.value = value
		self.DownloadSpeed.text = str
	end

	self.TextDes.gameObject:SetActive(false)
	self.Group4:SetActive(true)
	self.Group5:SetActive(false)
	self.Slider.gameObject:SetActive(true)
	self.DownloadSpeed.gameObject:SetActive(true)
	self.Tip:SetActive(false)

	self.TopText.text = _("Desc_Downloading")

	self.BtnClose:SetActive(false)
	OptionDownMgr:AddCallback(self.id, DownloadFinsh, DownloadError, UpdateProgress, self.openFrom)
end

function DlgOptionalDownload:OnBackAndroid()
	self:OnClickCancle()
end
