-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Public/DlgShare.lua

DlgShare = class("DlgShare", UIPanel)
NEED_SHARE = true

function DlgShare:ctor()
	self.UIPrefabPath = "UI/Common/DlgShare/DlgShareKC"
end

function DlgShare:OnRegisterEvent()
	self:AddClick(self.ButtonQuit, self.OnClickedButtonQuit)
	self:AddClick(self.ButtonPhoto, self.OnClickedButtonPhoto)
	self:AddClick(self.ButtonShare, self.OnClickedButtonShare)
	self:AddClick(self.ClickQuit, self.OnClickedQuitPhoto)
	self:AddClick(self.ButtonSelQuit, self.OnClickedButtonSelQuit)
	self:AddClick(self.ButtonQQ, self.OnClickedButtonTwitter)
	self:AddClick(self.ButtonWe, self.OnClickedButtonLine)
	self:AddClick(self.PanelShare, self.OnClickedButtonQuit)
	Event.Instance:Add("UpdateServerRefresh", self.UpdateServerRefresh, self)
	Event.Instance:Add("CloseDlgShare", self.Close, self)
end

function DlgShare:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonQuit, self.OnClickedButtonQuit)
	self:RemoveClick(self.ButtonPhoto, self.OnClickedButtonPhoto)
	self:RemoveClick(self.ButtonShare, self.OnClickedButtonShare)
	self:RemoveClick(self.ClickQuit, self.OnClickedQuitPhoto)
	self:RemoveClick(self.ButtonSelQuit, self.OnClickedButtonSelQuit)
	self:RemoveClick(self.ButtonQQ, self.OnClickedButtonTwitter)
	self:RemoveClick(self.ButtonWe, self.OnClickedButtonLine)
	self:RemoveClick(self.PanelShare, self.OnClickedButtonQuit)
	Event.Instance:Remove("UpdateServerRefresh", self.UpdateServerRefresh, self)
	Event.Instance:Remove("CloseDlgShare", self.Close, self)
	self:DestroyTexture()
end

function DlgShare:OnClickedButtonQuit()
	if self.callback then
		self.callback()
	end

	self:Close()
end

function DlgShare:OnEnter(vParam)
	if vParam then
		self.callback = vParam.callback
	end

	self.ButtonQuit = self:GetChildGameObject("Panel/ButtonQuit")
	self.ButtonPhoto = self:GetChildGameObject("Panel/ButtonPhoto")
	self.ButtonShare = self:GetChildGameObject("Panel/ButtonShare")
	self.RawImage = self:GetChildComponent("RawImage", "RawImage")
	self.ClickQuit = self:GetChildGameObject("ClickQuit")
	self.RawImage2 = self:GetChildComponent("ClickQuit/RawImage2", "RawImage")
	self.PanelShare = self:GetChildGameObject("PanelShare")
	self.TextName = self:GetChildComponent("PanelShare/bottom/Text", "Text")
	self.TextLv = self:GetChildComponent("PanelShare/bottom/TextLv", "Text")
	self.TextArea = self:GetChildComponent("PanelShare/bottom/TextArea", "Text")
	self.TextName.text = PlayerInst:GetNickName()
	self.TextLv.text = string.format(_("Desc_ShowLevel"), PlayerInst:GetCurLv())
	self.TextArea.text = NetData.ServerName

	if vParam and vParam.texture then
		self.RawImage.texture = vParam.texture

		if self.textureGroup == nil then
			self.textureGroup = {}
		end

		table.insert(self.textureGroup, vParam.texture)
	else
		self.RawImage.gameObject:SetActive(false)
		self.ButtonPhoto:SetActive(true)
		self.ButtonShare:SetActive(true)
		self.PanelShare:SetActive(false)
	end

	if not NEED_SHARE then
		self.ButtonShare:SetActive(false)
	end

	self.ButtonPhoto:SetActive(false)
	self.ButtonShare:SetActive(false)

	self.Panel = self:GetChildGameObject("Panel")
	self.PanelSelShare = self:GetChildGameObject("PanelSelShare")

	self.PanelSelShare:SetActive(false)

	self.ButtonSelQuit = self:GetChildGameObject("PanelSelShare/ButtonQuit")
	self.ButtonQQ = self:GetChildGameObject("PanelSelShare/BtnGroup/ButtonTwitter")
	self.ButtonWe = self:GetChildGameObject("PanelSelShare/BtnGroup/ButtonLine")

	if vParam.GoBtnShare then
		self.ButtonShare = vParam.GoBtnShare

		self:OnClickedButtonShare()
	else
		self:OnClickedButtonPhoto()
	end
end

function DlgShare.UpdateData(g)
	local ImageAward = GOUtil.FindChildGameObject(g, "Image")
	local TextAward = GOUtil.FindChildComponent(g, "Image/Text", "Text")
	local listAward = GetConfigArgJson("ShareAward")

	if InfoGameInst.shareNum + 1 > #listAward then
		ImageAward:SetActive(false)

		return
	end

	ImageAward:SetActive(true)

	TextAward.text = listAward[InfoGameInst.shareNum + 1][2]
end

function DlgShare:UpdateServerRefresh()
	DlgShare.UpdateData(self.ButtonShare)
end

function DlgShare:OnClickedQuitPhoto()
	self.ClickQuit:SetActive(false)

	if Application.platform:ToInt() == RuntimePlatform.IPhonePlayer then
		local iosSaveRes = PlayerPrefs.GetString("IOS_PHOTO_RESULT", "1")

		self.saveResult = iosSaveRes == "1"
	end

	if self.saveResult then
		UIMgr.ShowMsg(_("DESC_SAVE_PHOTO"))
	elseif Application.platform:ToInt() == RuntimePlatform.IPhonePlayer then
		UIMgr.ShowDialog(_("DESC_SAVE_PHOTO_NO_PERMISSION_IOS"))
	end

	self:DestroyTexture()

	if self.callback then
		self.callback()
	end

	self:Close()
end

function DlgShare:OnClickedButtonPhoto()
	self.ButtonQuit:SetActive(false)
	self.ButtonPhoto:SetActive(false)
	self.ButtonShare:SetActive(false)
	self.PanelShare:SetActive(true)
	UIMgr.HideMsg()
	SetActiveFunc(UIMgr.UILoadingObject, false)

	local texture = MiscUtil.CapturePicture(UIMgr.UICamera, nil)

	SetActiveFunc(UIMgr.UILoadingObject, true)

	if self.textureGroup == nil then
		self.textureGroup = {}
	end

	table.insert(self.textureGroup, texture)

	if self.RawImage2.texture then
		Object.Destroy(self.RawImage2.texture)
	end

	self.RawImage2.texture = texture

	self.ButtonPhoto:SetActive(true)
	self.ButtonShare:SetActive(true)
	self.PanelShare:SetActive(false)
	self.ClickQuit:SetActive(true)

	local path = NetData:GetCurServerTime() .. ".jpg"

	OzSDKManager.Instance:SaveToAlbum(self.RawImage2.texture, path)

	if not self.saveResult and Application.platform:ToInt() == RuntimePlatform.Android then
		local androidFirst = PlayerPrefs.GetString("ANDROID_PHOTO_REQUIRED_FIRST", "0") == "0"

		if androidFirst then
			UIMgr.ShowDialog(_("DESC_SAVE_PHOTO_NO_PERMISSION_ANDROID_FIRST"))
			PlayerPrefs.SetString("ANDROID_PHOTO_REQUIRED_FIRST", "1")
			PlayerPrefs.Save()
		else
			UIMgr.ShowDialog(_("DESC_SAVE_PHOTO_NO_PERMISSION_ANDROID"))
		end
	end

	if not NEED_SHARE then
		self.ButtonShare:SetActive(false)
	end

	self.ButtonPhoto:SetActive(false)
	self.ButtonShare:SetActive(false)
end

function DlgShare:OnClickedButtonShare()
	self.ClickQuit:SetActive(false)
	self.ButtonQuit:SetActive(false)
	self.ButtonPhoto:SetActive(false)
	self.ButtonShare:SetActive(false)
	self.PanelShare:SetActive(true)
	self.PanelSelShare:SetActive(true)

	local texture = self.RawImage.texture

	self.RawImage2.texture = texture

	UIMgr.HideMsg()
end

function DlgShare:DoShare()
	self.ClickQuit:SetActive(false)
	self.ButtonQuit:SetActive(false)
	self.ButtonPhoto:SetActive(false)
	self.ButtonShare:SetActive(false)
	self.PanelShare:SetActive(true)
	self.ButtonPhoto:SetActive(true)
	self.ButtonShare:SetActive(true)
	self.PanelShare:SetActive(false)

	if not NEED_SHARE then
		self.ButtonShare:SetActive(false)
	end
end

function DlgShare:OnShareComplete(str)
	print("DlgShare:OnShareComplete = " .. str)

	if not self.closed then
		self.PanelShare:SetActive(false)
	end

	if str == "successed" then
		TimerMgr.AddTimer(eTimerType.RealTime, 1.5, function()
			self:CheckAndHideCountLoading()
			self:GetAward()
		end, {})
	elseif str == "not_installed" or str == "not_installed_twitter" then
		self:CheckAndHideCountLoading()
		UIMgr.ShowMsg(str == "not_installed" and _("share_setting_uninstall_line") or _("share_setting_uninstall_twitter"))

		if self.callback then
			self.callback()
		end

		self:Close()
	else
		self:CheckAndHideCountLoading()

		if self.callback then
			self.callback()
		end

		self:Close()
	end
end

function DlgShare:OnClickedButtonSelQuit()
	self.Panel:SetActive(true)
	self.PanelSelShare:SetActive(false)
end

function DlgShare:CheckAndHideCountLoading()
	if self.isInShareLoading then
		TimerMgr.RemoveTimer(self.timeoutCount)
		LoadingMgr.Hide(eLoadingType.Repeat)

		self.isInShareLoading = false
	end
end

function DlgShare:ShowLoadingAndCount()
	LoadingMgr.Show(eLoadingType.Repeat)

	self.isInShareLoading = true
	self.timeoutCount = TimerMgr.AddTimer(eTimerType.RealTime, 5, function()
		self.isInShareLoading = false

		LoadingMgr.Hide(eLoadingType.Repeat)
	end, {})
end

function DlgShare:OnClickedButtonTwitter()
	self.PanelSelShare:SetActive(false)

	local wrap = wrapedCb(self.OnShareComplete, self)
	local texture = MiscUtil.CapturePicture(UIMgr.UICamera, nil)

	self:ShowLoadingAndCount()
	TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
		TwitterSupport.GetInstance():ShareGameScreenShot(wrap, _("share_setting_welcome_twitter"), _("share_setting_welcome_twitter_tag"), texture)
	end, {})
end

function DlgShare:OnClickedButtonLine()
	self.PanelSelShare:SetActive(false)

	local wrap = wrapedCb(self.OnShareComplete, self)
	local texture = MiscUtil.CapturePicture(UIMgr.UICamera, nil)

	self:ShowLoadingAndCount()
	TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
		LineSupport.GetInstance():ShareGameScreenShot(wrap, "line welcome to", "#lapis", texture)
	end, {})
end

function DlgShare:OnClickedButtonSina()
	self.PanelSelShare:SetActive(false)

	local wrap = wrapedCb(self.OnGetShare, self)

	OzSDKManager.Instance:ShareSDK(wrap, self.texture, "Sina")
end

function DlgShare:OnGetShare(str)
	print("DlgShare:OnGetShare")

	local json = require("GameLogic/Util/json4lua")
	local dict = json.decode(str)
	local code = dict.code
	local callbackType = dict.callbackType

	if callbackType == "Share" then
		self:GetAward()
	else
		if self.callback then
			self.callback()
		end

		self:Close()
	end
end

function DlgShare:GetAward()
	local listAward = GetConfigArgJson("ShareAward")

	if InfoGameInst.shareNum + 1 > #listAward then
		if self.callback then
			self.callback()
		end

		self:Close()

		return
	end

	local function callback(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			if not self.closed then
				self:DestroyTexture()
				DlgShare.UpdateData(self.ButtonShare)
			end
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end

		if self.callback then
			self.callback()
		end

		self:Close()
	end

	NetManager:RequestGetShareReward(callback)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function DlgShare:DestroyTexture()
	if self.textureGroup == nil then
		return
	end

	for i = #self.textureGroup, 1, -1 do
		if self.textureGroup[i] then
			Object.Destroy(self.textureGroup[i])

			self.textureGroup[i] = nil
		end
	end

	if self.RawImage2.texture then
		Object.Destroy(self.RawImage2.texture)
	end

	if self.RawImage.texture then
		Object.Destroy(self.RawImage.texture)
	end

	self.RawImage2.texture = nil
	self.texture = nil

	UnityEngine.Resources.UnloadUnusedAssets()
	System.GC.Collect()
end

function DlgShare:OnBackAndroid()
	self:OnClickedButtonQuit()
end
