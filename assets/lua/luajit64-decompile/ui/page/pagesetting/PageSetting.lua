-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageSetting/PageSetting.lua

PageSetting = class("PageSetting", UIPanel)

function PageSetting:ctor()
	self.UIPrefabPath = "UI/PanelSetting/PanelSetting"
end

function PageSetting:PreLoad()
	return
end

function PageSetting:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.UIPrefabCache)
	SoundMgr.UnloadBank("VOX_SYS_0010")
end

function PageSetting:OnEnter()
	SoundMgr.LoadBank("VOX_SYS_0010", false, false)

	self.targetLevel = PlayerPrefs.GetInt("GraphicSettingLevel")
	self.toggleQualityAllUltra = self:GetChildComponent("Picture/QualityAll/Ultra", "Toggle")
	self.toggleQualityAllUltra.isOn = self.targetLevel == 4
	self.toggleQualityAllHigh = self:GetChildComponent("Picture/QualityAll/High", "Toggle")
	self.toggleQualityAllHigh.isOn = self.targetLevel == 3
	self.toggleQualityAllMedium = self:GetChildComponent("Picture/QualityAll/Medium", "Toggle")
	self.toggleQualityAllMedium.isOn = self.targetLevel == 2
	self.toggleQualityAllLow = self:GetChildComponent("Picture/QualityAll/Low", "Toggle")
	self.toggleQualityAllLow.isOn = self.targetLevel == 1
	self.toggleQualityUltra = self:GetChildComponent("Picture/Quality/Ultra", "Toggle")
	self.toggleQualityUltra.isOn = UnityEngine.Shader.globalMaximumLOD == 400
	self.toggleQualityHigh = self:GetChildComponent("Picture/Quality/High", "Toggle")
	self.toggleQualityHigh.isOn = UnityEngine.Shader.globalMaximumLOD == 300
	self.toggleQualityMedium = self:GetChildComponent("Picture/Quality/Medium", "Toggle")
	self.toggleQualityMedium.isOn = UnityEngine.Shader.globalMaximumLOD == 200
	self.toggleQualityLow = self:GetChildComponent("Picture/Quality/Low", "Toggle")
	self.toggleQualityLow.isOn = UnityEngine.Shader.globalMaximumLOD == 100
	self.toggleResolutionHigh = self:GetChildComponent("Picture/Resolution/High", "Toggle")
	self.toggleResolutionHigh.isOn = SeanLib.PostProcessV2.GlobleSetting.ResolutionPercent == 100
	self.toggleResolutionMedium = self:GetChildComponent("Picture/Resolution/Medium", "Toggle")
	self.toggleResolutionMedium.isOn = SeanLib.PostProcessV2.GlobleSetting.ResolutionPercent == 85
	self.toggleResolutionLow = self:GetChildComponent("Picture/Resolution/Low", "Toggle")
	self.toggleResolutionLow.isOn = SeanLib.PostProcessV2.GlobleSetting.ResolutionPercent == 67
	self.toggleShadow = self:GetChildComponent("Picture/Shadow/Toggle", "Toggle")
	self.toggleShadow.isOn = QualitySettingUtil.GetShadows()
	self.toggleFrameRate = self:GetChildComponent("Picture/FrameRate/Toggle", "Toggle")
	self.toggleFrameRate.isOn = Application.targetFrameRate == 60
	self.toggleHDR = self:GetChildComponent("Picture/PostProcess/HDR", "Toggle")
	self.toggleHDR.isOn = SeanLib.PostProcessV2.GlobleSetting.HDR

	if not SystemInfoUtil.SupportsRenderTextureFormat(RenderTextureFormat.ARGBHalf) then
		self.toggleHDR.interactable = false
	end

	self.toggleBloom = self:GetChildComponent("Picture/PostProcess/Bloom", "Toggle")
	self.toggleBloom.isOn = SeanLib.PostProcessV2.GlobleSetting.Get("BLOOM")
	self.toggleDepthOfField = self:GetChildComponent("Picture/PostProcess/DepthOfField", "Toggle")
	self.toggleDepthOfField.isOn = SeanLib.PostProcessV2.GlobleSetting.Get("BLUR")
	self.toggleAntiAliasing = self:GetChildComponent("Picture/PostProcess/AntiAliasing", "Toggle")
	self.toggleAntiAliasing.isOn = SeanLib.PostProcessV2.GlobleSetting.Get("AntiAliasing")
	self.toggleVolumetricLight = self:GetChildComponent("Picture/PostProcess/VolumetricLight", "Toggle")
	self.toggleVolumetricLight.isOn = SeanLib.PostProcessV2.GlobleSetting.Get("VolumetricLight")
	self.toggleAutoClip = self:GetChildComponent("Picture/PostProcess/AutoClip", "Toggle")
	self.toggleAutoClip.isOn = PersistentStoreUtil.GetBool(PersistentStoreUtil.KEY_FIGHT_SKIP_TL_MODE, false) == false
	self.slider_soundVolume = self:GetChildComponent("Voice/SliderSoundVolume", "UnityEngine.UI.Slider")
	self.slider_musicVolume = self:GetChildComponent("Voice/SliderMusicVolume", "UnityEngine.UI.Slider")
	self.slider_voiceVolume = self:GetChildComponent("Voice/SliderVoiceVolume", "UnityEngine.UI.Slider")

	function self.eventCallback_music(floatVal)
		self:SliderMusicVolume(floatVal)
	end

	function self.eventCallback_sound(floatVal)
		self:SliderSoundVolume(floatVal)
	end

	function self.eventCallback_voice(floatVal)
		self:SliderVoiceVolume(floatVal)
	end

	self.txt_musicVolume = self:GetChildComponent("Voice/Txt/TxtMusicVolumeValue", "Text")
	self.txt_soundVolume = self:GetChildComponent("Voice/Txt/TxtSoundVolumeValue", "Text")
	self.txt_voiceVolume = self:GetChildComponent("Voice/Txt/TxtVoiceVolumeValue", "Text")

	local musicV = SoundMgr.GetMusicVolume()
	local soundV = SoundMgr.GetSoundVolume()
	local voiceV = SoundMgr.GetVoiceVolume()

	self.slider_musicVolume.value = musicV
	self.slider_soundVolume.value = soundV
	self.slider_voiceVolume.value = voiceV
	self.txt_musicVolume.text = string.format("%d", musicV)
	self.txt_soundVolume.text = string.format("%d", soundV)
	self.txt_voiceVolume.text = string.format("%d", voiceV)
	self.picture = GOUtil.FindChildGameObject(self.UIRootObject, "Picture")
	self.voice = GOUtil.FindChildGameObject(self.UIRootObject, "Voice")
	self.notice = GOUtil.FindChildGameObject(self.UIRootObject, "Notice")
	self.btnpicture = GOUtil.FindChildGameObject(self.UIRootObject, "BtnGroup/BtnPicture")
	self.btnvoice = GOUtil.FindChildGameObject(self.UIRootObject, "BtnGroup/BtnVocie")
	self.btnnotice = GOUtil.FindChildGameObject(self.UIRootObject, "BtnGroup/BtnNotice")
	self.btnpictureset = GOUtil.FindChildGameObject(self.UIRootObject, "BtnGroup/BtnPicture/Set")
	self.btnpicturenotset = GOUtil.FindChildGameObject(self.UIRootObject, "BtnGroup/BtnPicture/NotSet")
	self.btnvoiceset = GOUtil.FindChildGameObject(self.UIRootObject, "BtnGroup/BtnVocie/Set")
	self.btnvoicenotset = GOUtil.FindChildGameObject(self.UIRootObject, "BtnGroup/BtnVocie/NotSet")
	self.btnnoticeset = GOUtil.FindChildGameObject(self.UIRootObject, "BtnGroup/BtnNotice/Set")
	self.btnnoticenotset = GOUtil.FindChildGameObject(self.UIRootObject, "BtnGroup/BtnNotice/NotSet")
	self.btnclose = GOUtil.FindChildGameObject(self.UIRootObject, "BtnClose")
	self.togglebodymax = self:GetChildComponent("Notice/BodyMax", "Toggle")
	self.toggleRewardBody = self:GetChildComponent("Notice/RewardBody", "Toggle")
	self.toggleTask = self:GetChildComponent("Notice/Task", "Toggle")
	self.togglebodymax.isOn = NotificationMgr.Instance:CheckState(eNotificationType.FullPower)
	self.toggleRewardBody.isOn = NotificationMgr.Instance:CheckState(eNotificationType.CanGetPower)
	self.toggleTask.isOn = NotificationMgr.Instance:CheckState(eNotificationType.CompleteWork)
	self.btntable = {}
	self.btntable[1] = {
		set = self.btnpictureset,
		notset = self.btnpicturenotset
	}
	self.btntable[2] = {
		set = self.btnvoiceset,
		notset = self.btnvoicenotset
	}
	self.btntable[3] = {
		set = self.btnnoticeset,
		notset = self.btnnoticenotset
	}
	self.currentIndex = 1
	self.lastindex = -1

	self:InitText()
end

function PageSetting:OnLeave()
	return
end

function PageSetting:OnBack()
	UIMgr.PopPanel()
end

function PageSetting:OnRegisterEvent()
	local function wrap_cb(...)
		self:OnQualityAllUltra(...)
	end

	self.toggleQualityAllUltra.onValueChanged:AddListener(wrap_cb)

	local function wrap_cb(...)
		self:OnQualityAllHigh(...)
	end

	self.toggleQualityAllHigh.onValueChanged:AddListener(wrap_cb)

	local function wrap_cb(...)
		self:OnQualityAllMedium(...)
	end

	self.toggleQualityAllMedium.onValueChanged:AddListener(wrap_cb)

	local function wrap_cb(...)
		self:OnQualityAllLow(...)
	end

	self.toggleQualityAllLow.onValueChanged:AddListener(wrap_cb)
	self.toggleQualityUltra.onValueChanged:AddListener(self.OnQualityUltra)
	self.toggleQualityHigh.onValueChanged:AddListener(self.OnQualityHigh)
	self.toggleQualityMedium.onValueChanged:AddListener(self.OnQualityMedium)
	self.toggleQualityLow.onValueChanged:AddListener(self.OnQualityLow)
	self.toggleResolutionHigh.onValueChanged:AddListener(self.OnResolutionHigh)
	self.toggleResolutionMedium.onValueChanged:AddListener(self.OnResolutionMedium)
	self.toggleResolutionLow.onValueChanged:AddListener(self.OnResolutionLow)
	self.toggleFrameRate.onValueChanged:AddListener(self.OnFrameRate)
	self.toggleHDR.onValueChanged:AddListener(self.OnHDR)
	self.toggleBloom.onValueChanged:AddListener(self.OnBloom)
	self.toggleDepthOfField.onValueChanged:AddListener(self.OnDepthOfField)
	self.toggleAntiAliasing.onValueChanged:AddListener(self.OnAntiAliasing)
	self.toggleVolumetricLight.onValueChanged:AddListener(self.OnVolumetricLight)
	self.toggleAutoClip.onValueChanged:AddListener(self.OnAutoClip)
	self.slider_musicVolume.onValueChanged:AddListener(self.eventCallback_music)
	self.slider_soundVolume.onValueChanged:AddListener(self.eventCallback_sound)
	self.slider_voiceVolume.onValueChanged:AddListener(self.eventCallback_voice)
	self:AddClick(self.btnpicture.gameObject, self.OnClickBtnPicture)
	self:AddClick(self.btnvoice.gameObject, self.OnClickBtnVoice)
	self:AddClick(self.btnnotice.gameObject, self.OnClickBtnnotice)
	self:AddClick(self.btnclose.gameObject, self.OnClickBtnClose)
	self.togglebodymax.onValueChanged:AddListener(self.OnFullPower)
	self.toggleRewardBody.onValueChanged:AddListener(self.OnCanGetPower)
	self.toggleTask.onValueChanged:AddListener(self.OnCompleteWork)
	self.toggleShadow.onValueChanged:AddListener(self.OnShadow)
	self:AddListener(self.slider_soundVolume.gameObject, self.OnSoundSetFinish, EventTriggerType.PointerUp)
	self:AddListener(self.slider_voiceVolume.gameObject, self.OnVoiceSetFinish, EventTriggerType.PointerUp)
end

function PageSetting:OnUnRegisterEvent()
	self.toggleQualityUltra.onValueChanged:RemoveListener(self.OnQualityUltra)
	self.toggleQualityHigh.onValueChanged:RemoveListener(self.OnQualityHigh)
	self.toggleQualityMedium.onValueChanged:RemoveListener(self.OnQualityMedium)
	self.toggleQualityLow.onValueChanged:RemoveListener(self.OnQualityLow)
	self.toggleResolutionHigh.onValueChanged:RemoveListener(self.OnResolutionHigh)
	self.toggleResolutionMedium.onValueChanged:RemoveListener(self.OnResolutionMedium)
	self.toggleResolutionLow.onValueChanged:RemoveListener(self.OnResolutionLow)
	self.toggleFrameRate.onValueChanged:RemoveListener(self.OnFrameRate)
	self.toggleHDR.onValueChanged:RemoveListener(self.OnHDR)
	self.toggleBloom.onValueChanged:RemoveListener(self.OnBloom)
	self.toggleDepthOfField.onValueChanged:RemoveListener(self.OnDepthOfField)
	self.toggleAntiAliasing.onValueChanged:RemoveListener(self.OnAntiAliasing)
	self.toggleVolumetricLight.onValueChanged:RemoveListener(self.OnVolumetricLight)
	self.toggleAutoClip.onValueChanged:RemoveListener(self.OnAutoClip)
	self.slider_musicVolume.onValueChanged:RemoveListener(self.eventCallback_music)
	self.slider_soundVolume.onValueChanged:RemoveListener(self.eventCallback_sound)
	self.slider_voiceVolume.onValueChanged:RemoveListener(self.eventCallback_voice)
	self:RemoveClick(self.btnpicture.gameObject, self.OnClickBtnPicture)
	self:RemoveClick(self.btnvoice.gameObject, self.OnClickBtnVoice)
	self:RemoveClick(self.btnnotice.gameObject, self.OnClickBtnnotice)
	self:RemoveClick(self.btnclose.gameObject, self.OnClickBtnClose)
	self.togglebodymax.onValueChanged:RemoveListener(self.OnFullPower)
	self.toggleRewardBody.onValueChanged:RemoveListener(self.OnCanGetPower)
	self.toggleTask.onValueChanged:RemoveListener(self.OnCompleteWork)
	self.toggleShadow.onValueChanged:RemoveListener(self.OnShadow)
	self:RemoveListener(self.slider_soundVolume.gameObject, self.OnSoundSetFinish, EventTriggerType.PointerUp)
	self:RemoveListener(self.slider_voiceVolume.gameObject, self.OnVoiceSetFinish, EventTriggerType.PointerUp)
end

function PageSetting.OnClickShow()
	UIMgr.ShowMsg(Lang(12173))
end

function PageSetting:OnClickBtnClose()
	self:Close()
end

function PageSetting:OnClickBtnPicture()
	if self.currentIndex ~= 1 then
		self.lastindex = self.currentIndex
		self.currentIndex = 1

		if self.lastindex ~= -1 then
			self.btntable[self.lastindex].set.gameObject:SetActive(false)
			self.btntable[self.lastindex].notset.gameObject:SetActive(true)
		end

		self.btntable[self.currentIndex].set.gameObject:SetActive(true)
		self.btntable[self.currentIndex].notset.gameObject:SetActive(false)
		self.picture.gameObject:SetActive(true)
		self.voice.gameObject:SetActive(false)
		self.notice.gameObject:SetActive(false)
	end
end

function PageSetting:OnClickBtnVoice()
	if self.currentIndex ~= 2 then
		self.lastindex = self.currentIndex
		self.currentIndex = 2

		if self.lastindex ~= -1 then
			self.btntable[self.lastindex].set.gameObject:SetActive(false)
			self.btntable[self.lastindex].notset.gameObject:SetActive(true)
		end

		self.btntable[self.currentIndex].set.gameObject:SetActive(true)
		self.btntable[self.currentIndex].notset.gameObject:SetActive(false)
		self.picture.gameObject:SetActive(false)
		self.voice.gameObject:SetActive(true)
		self.notice.gameObject:SetActive(false)
	end
end

function PageSetting:OnClickBtnnotice()
	if self.currentIndex ~= 3 then
		self.lastindex = self.currentIndex
		self.currentIndex = 3

		if self.lastindex ~= -1 then
			self.btntable[self.lastindex].set.gameObject:SetActive(false)
			self.btntable[self.lastindex].notset.gameObject:SetActive(true)
		end

		self.btntable[self.currentIndex].set.gameObject:SetActive(true)
		self.btntable[self.currentIndex].notset.gameObject:SetActive(false)
		self.picture.gameObject:SetActive(false)
		self.voice.gameObject:SetActive(false)
		self.notice.gameObject:SetActive(true)
	end
end

function PageSetting.OnShadow(isOn)
	if isOn then
		QualitySettingUtil.SetShadows(true)
		PlayerPrefs.SetInt("GraphicSetting.Shadow", 1)
	else
		QualitySettingUtil.SetShadows(false)
		PlayerPrefs.SetInt("GraphicSetting.Shadow", 0)
	end
end

function PageSetting.OnResolutionHigh(isOn)
	if isOn then
		SeanLib.PostProcessV2.GlobleSetting.SetResolution(100)
		PlayerPrefs.SetInt("GraphicSetting.Resolution", 100)
	end
end

function PageSetting.OnResolutionMedium(isOn)
	if isOn then
		SeanLib.PostProcessV2.GlobleSetting.SetResolution(85)
		PlayerPrefs.SetInt("GraphicSetting.Resolution", 85)
	end
end

function PageSetting.OnResolutionLow(isOn)
	if isOn then
		SeanLib.PostProcessV2.GlobleSetting.SetResolution(67)
		PlayerPrefs.SetInt("GraphicSetting.Resolution", 67)
	end
end

function PageSetting.OnDetail(isOn)
	return
end

function PageSetting:OnQualityAllUltra(isOn)
	if isOn then
		PlayerPrefs.SetInt("GraphicSettingLevel", 4)

		self.toggleQualityUltra.isOn = true
		self.toggleResolutionHigh.isOn = true
		self.toggleShadow.isOn = true
		self.toggleFrameRate.isOn = false
		self.toggleHDR.isOn = true
		self.toggleBloom.isOn = true
		self.toggleDepthOfField.isOn = true
		self.toggleAntiAliasing.isOn = true
		self.toggleVolumetricLight.isOn = true
	end
end

function PageSetting:OnQualityAllHigh(isOn)
	if isOn then
		PlayerPrefs.SetInt("GraphicSettingLevel", 3)

		self.toggleQualityHigh.isOn = true
		self.toggleResolutionMedium.isOn = true
		self.toggleShadow.isOn = false
		self.toggleFrameRate.isOn = false
		self.toggleHDR.isOn = true
		self.toggleBloom.isOn = true
		self.toggleDepthOfField.isOn = false
		self.toggleAntiAliasing.isOn = false
		self.toggleVolumetricLight.isOn = true
	end
end

function PageSetting:OnQualityAllMedium(isOn)
	if isOn then
		PlayerPrefs.SetInt("GraphicSettingLevel", 2)

		self.toggleQualityMedium.isOn = true
		self.toggleResolutionMedium.isOn = true
		self.toggleShadow.isOn = false
		self.toggleFrameRate.isOn = false
		self.toggleHDR.isOn = false
		self.toggleBloom.isOn = true
		self.toggleDepthOfField.isOn = false
		self.toggleAntiAliasing.isOn = false
		self.toggleVolumetricLight.isOn = false
	end
end

function PageSetting:OnQualityAllLow(isOn)
	if isOn then
		PlayerPrefs.SetInt("GraphicSettingLevel", 1)

		self.toggleQualityMedium.isOn = true
		self.toggleResolutionLow.isOn = true
		self.toggleShadow.isOn = false
		self.toggleFrameRate.isOn = false
		self.toggleHDR.isOn = false
		self.toggleBloom.isOn = false
		self.toggleDepthOfField.isOn = false
		self.toggleAntiAliasing.isOn = false
		self.toggleVolumetricLight.isOn = false
	end
end

function PageSetting.OnQualityUltra(isOn)
	if isOn then
		UnityEngine.Shader.globalMaximumLOD = 400

		PlayerPrefs.SetInt("GraphicSetting.GlobalMaximumLOD", 400)
		QualitySettingUtil.SetSkinWeights(SkinWeights.FourBones)
		QualitySettingUtil.SetMasterTextureLimit(0)
	end
end

function PageSetting.OnQualityHigh(isOn)
	if isOn then
		UnityEngine.Shader.globalMaximumLOD = 300

		PlayerPrefs.SetInt("GraphicSetting.GlobalMaximumLOD", 300)
		QualitySettingUtil.SetSkinWeights(SkinWeights.FourBones)
		QualitySettingUtil.SetMasterTextureLimit(0)
	end
end

function PageSetting.OnQualityMedium(isOn)
	if isOn then
		UnityEngine.Shader.globalMaximumLOD = 200

		PlayerPrefs.SetInt("GraphicSetting.GlobalMaximumLOD", 200)
		QualitySettingUtil.SetSkinWeights(SkinWeights.TwoBones)
		QualitySettingUtil.SetMasterTextureLimit(1)
	end
end

function PageSetting.OnQualityLow(isOn)
	if isOn then
		UnityEngine.Shader.globalMaximumLOD = 100

		PlayerPrefs.SetInt("GraphicSetting.GlobalMaximumLOD", 100)
		QualitySettingUtil.SetSkinWeights(SkinWeights.OneBone)
		QualitySettingUtil.SetMasterTextureLimit(2)
	end
end

function PageSetting.OnFrameRate(isOn)
	if isOn then
		Application.targetFrameRate = 60

		PlayerPrefs.SetInt("GraphicSetting.TargetFrameRate", 60)
	else
		Application.targetFrameRate = 30

		PlayerPrefs.SetInt("GraphicSetting.TargetFrameRate", 30)
	end
end

function PageSetting.OnHDR(isOn)
	if isOn then
		SeanLib.PostProcessV2.GlobleSetting.HDR = true

		PlayerPrefs.SetInt("GraphicSetting.HDR", 1)
	else
		SeanLib.PostProcessV2.GlobleSetting.HDR = false

		PlayerPrefs.SetInt("GraphicSetting.HDR", 0)
	end
end

function PageSetting.OnBloom(isOn)
	if isOn then
		SeanLib.PostProcessV2.GlobleSetting.Enable("BLOOM")
		PlayerPrefs.SetInt("GraphicSetting.BLOOM", 1)
	else
		SeanLib.PostProcessV2.GlobleSetting.Disable("BLOOM")
		PlayerPrefs.SetInt("GraphicSetting.BLOOM", 0)
	end
end

function PageSetting.OnDepthOfField(isOn)
	if isOn then
		SeanLib.PostProcessV2.GlobleSetting.Enable("BLUR")
		PlayerPrefs.SetInt("GraphicSetting.BLUR", 1)
	else
		SeanLib.PostProcessV2.GlobleSetting.Disable("BLUR")
		PlayerPrefs.SetInt("GraphicSetting.BLUR", 0)
	end
end

function PageSetting.OnVolumetricLight(isOn)
	if isOn then
		SeanLib.PostProcessV2.GlobleSetting.Enable("VolumetricLight")
		PlayerPrefs.SetInt("GraphicSetting.VOLUMETRICLIGHT", 1)
	else
		SeanLib.PostProcessV2.GlobleSetting.Disable("VolumetricLight")
		PlayerPrefs.SetInt("GraphicSetting.VOLUMETRICLIGHT", 0)
	end
end

function PageSetting.OnAntiAliasing(isOn)
	if isOn then
		SeanLib.PostProcessV2.GlobleSetting.Enable("AntiAliasing")
		PlayerPrefs.SetInt("GraphicSetting.AntiAliasing", 1)
	else
		SeanLib.PostProcessV2.GlobleSetting.Disable("AntiAliasing")
		PlayerPrefs.SetInt("GraphicSetting.AntiAliasing", 0)
	end
end

function PageSetting.OnAutoClip(isOn)
	PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_FIGHT_SKIP_TL_MODE, isOn == false)
end

function PageSetting:SliderMusicVolume(val)
	self.txt_musicVolume.text = string.format("%d", val)

	SoundMgr.SetMusicVolume(val)
end

function PageSetting:SliderSoundVolume(val)
	self.txt_soundVolume.text = string.format("%d", val)

	SoundMgr.SetSoundVolume(val)
end

function PageSetting:SliderVoiceVolume(val)
	self.txt_voiceVolume.text = string.format("%d", val)

	SoundMgr.SetVoiceVolume(val)
end

function PageSetting:OnSoundSetFinish()
	SoundMgr.Play(PATH_SFX_UI_CLICK)
end

function PageSetting:OnVoiceSetFinish()
	SoundMgr.Stop("Play_VOX_SYS_0010_0097")
	SoundMgr.Play("Play_VOX_SYS_0010_0097")
end

function PageSetting.OnCanGetPower(isOn)
	if isOn then
		if not NotificationMgr.Instance:GetPermission() then
			UIMgr.ShowMsg("本アプリの通知権限をオンにしてください")

			UIMgr.GetPanel("PageSetting").toggleRewardBody.isOn = false

			return
		end

		PersistentStoreUtil.SetInt(NotificationMgr.Setting .. eNotificationType.CanGetPower, 1)
	else
		PersistentStoreUtil.SetInt(NotificationMgr.Setting .. eNotificationType.CanGetPower, 2)
	end

	NotificationMgr.Instance:ChangeSetting(eNotificationType.CanGetPower)
end

function PageSetting.OnFullPower(isOn)
	if isOn then
		if not NotificationMgr.Instance:GetPermission() then
			UIMgr.ShowMsg("本アプリの通知権限をオンにしてください")

			UIMgr.GetPanel("PageSetting").togglebodymax.isOn = false

			return
		end

		PersistentStoreUtil.SetInt(NotificationMgr.Setting .. eNotificationType.FullPower, 1)
	else
		PersistentStoreUtil.SetInt(NotificationMgr.Setting .. eNotificationType.FullPower, 2)
	end

	NotificationMgr.Instance:ChangeSetting(eNotificationType.FullPower)
end

function PageSetting.OnCompleteWork(isOn)
	if isOn then
		if not NotificationMgr.Instance:GetPermission() then
			UIMgr.ShowMsg("本アプリの通知権限をオンにしてください")

			UIMgr.GetPanel("PageSetting").toggleTask.isOn = false

			return
		end

		PersistentStoreUtil.SetInt(NotificationMgr.Setting .. eNotificationType.CompleteWork, 1)
	else
		PersistentStoreUtil.SetInt(NotificationMgr.Setting .. eNotificationType.CompleteWork, 2)
	end

	NotificationMgr.Instance:ChangeSetting(eNotificationType.CompleteWork)
end

function PageSetting:InitText()
	local TextAuto

	TextAuto = self:GetChildComponent("BtnGroup/BtnPicture/Set/Text/", "Text")
	TextAuto.text = Lang(5000105)
	TextAuto = self:GetChildComponent("BtnGroup/BtnVocie/Set/Text/", "Text")
	TextAuto.text = Lang(5000064)
	TextAuto = self:GetChildComponent("BtnGroup/BtnNotice/Set/Text/", "Text")
	TextAuto.text = Lang(5000065)
	TextAuto = self:GetChildComponent("BtnGroup/BtnPicture/NotSet/Text/", "Text")
	TextAuto.text = Lang(5000105)
	TextAuto = self:GetChildComponent("BtnGroup/BtnVocie/NotSet/Text/", "Text")
	TextAuto.text = Lang(5000064)
	TextAuto = self:GetChildComponent("BtnGroup/BtnNotice/NotSet/Text/", "Text")
	TextAuto.text = Lang(5000065)
	TextAuto = self:GetChildComponent("Text/", "Text")
	TextAuto.text = Lang(5000066)
	TextAuto = self:GetChildComponent("Picture/Quality/Text/", "Text")
	TextAuto.text = Lang(5000067)
	TextAuto = self:GetChildComponent("Picture/Quality/Low/Label/", "Text")
	TextAuto.text = Lang(5000068)
	TextAuto = self:GetChildComponent("Picture/Quality/Medium/Label/", "Text")
	TextAuto.text = Lang(5000069)
	TextAuto = self:GetChildComponent("Picture/Quality/High/Label/", "Text")
	TextAuto.text = Lang(5000070)
	TextAuto = self:GetChildComponent("Picture/Quality/Ultra/Label/", "Text")
	TextAuto.text = Lang(5000071)
	TextAuto = self:GetChildComponent("Picture/FrameRate/Text/", "Text")
	TextAuto.text = Lang(5000072)
	TextAuto = self:GetChildComponent("Picture/FrameRate/Toggle/Label/", "Text")
	TextAuto.text = Lang(5000073)
	TextAuto = self:GetChildComponent("Picture/PostProcess/Text/", "Text")
	TextAuto.text = Lang(5000074)
	TextAuto = self:GetChildComponent("Picture/PostProcess/HDR/Label/", "Text")
	TextAuto.text = Lang(5000075)
	TextAuto = self:GetChildComponent("Picture/PostProcess/Bloom/Label/", "Text")
	TextAuto.text = Lang(5000076)
	TextAuto = self:GetChildComponent("Picture/PostProcess/DepthOfField/Label/", "Text")
	TextAuto.text = Lang(5000077)
	TextAuto = self:GetChildComponent("Picture/PostProcess/AntiAliasing/Label/", "Text")
	TextAuto.text = Lang(5000078)
	TextAuto = self:GetChildComponent("Voice/Txt/TxtMusicVolume/", "Text")
	TextAuto.text = Lang(5000079)
	TextAuto = self:GetChildComponent("Voice/Txt/TxtSoundVolume/", "Text")
	TextAuto.text = Lang(5000080)
	TextAuto = self:GetChildComponent("Voice/Txt/TxtVoiceVolume/", "Text")
	TextAuto.text = Lang(5000081)
	TextAuto = self:GetChildComponent("Notice/Txt/TxtMusicVolume/", "Text")
	TextAuto.text = Lang(5000082)
	TextAuto = self:GetChildComponent("Notice/Txt/TxtSoundVolume/", "Text")
	TextAuto.text = Lang(5000083)
	TextAuto = self:GetChildComponent("Notice/Txt/TxtVoiceVolume/", "Text")
	TextAuto.text = Lang(5000084)
	TextAuto = self:GetChildComponent("Notice/Txt/TxtMusicVolumeValue/", "Text")
	TextAuto.text = Lang(5000085)
	TextAuto = self:GetChildComponent("Notice/Txt/TxtSoundVolumeValue/", "Text")
	TextAuto.text = Lang(5000086)
end

function PageSetting:OnBackAndroid()
	self:Close()
end
