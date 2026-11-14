-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/DlgGraphicSetting.lua

DlgGraphicSetting = class("DlgGraphicSetting", UIPanel)

function DlgGraphicSetting:ctor()
	self.UIPrefabPath = "UI/PanelLogin/DlgGraphicSetting"
end

function DlgGraphicSetting:OnRegisterEvent()
	self:AddClick(self.BtnConfirm, self.OnClickedButton)
end

function DlgGraphicSetting:OnUnRegisterEvent()
	self:RemoveClick(self.BtnConfirm, self.OnClickedButton)
end

function DlgGraphicSetting:ApplyGraphicSetting(deviceLevel)
	local defaultGraphicSetting = GetDefaultGraphicSetting(deviceLevel)
	local level = defaultGraphicSetting.GlobalMaximumLOD

	UnityEngine.Shader.globalMaximumLOD = level

	PlayerPrefs.SetInt("GraphicSetting.GlobalMaximumLOD", level)

	if level == 400 then
		QualitySettingUtil.SetSkinWeights(SkinWeights.FourBones)
		QualitySettingUtil.SetMasterTextureLimit(0)
		PlayerPrefs.SetInt("GraphicSetting.GlobalMaximumLOD", 400)
	elseif level == 300 then
		QualitySettingUtil.SetSkinWeights(SkinWeights.FourBones)
		QualitySettingUtil.SetMasterTextureLimit(0)
		PlayerPrefs.SetInt("GraphicSetting.GlobalMaximumLOD", 300)
	elseif level == 200 then
		QualitySettingUtil.SetSkinWeights(SkinWeights.TwoBones)
		QualitySettingUtil.SetMasterTextureLimit(1)
		PlayerPrefs.SetInt("GraphicSetting.GlobalMaximumLOD", 200)
	elseif level == 100 then
		QualitySettingUtil.SetSkinWeights(SkinWeights.OneBone)
		QualitySettingUtil.SetMasterTextureLimit(2)
		PlayerPrefs.SetInt("GraphicSetting.GlobalMaximumLOD", 100)
	end

	local targetFrameRate = defaultGraphicSetting.TargetFrameRate

	Application.targetFrameRate = targetFrameRate

	PlayerPrefs.SetInt("GraphicSetting.TargetFrameRate", targetFrameRate)

	local resolution = defaultGraphicSetting.Resolution

	SeanLib.PostProcessV2.GlobleSetting.SetResolution(resolution)
	PlayerPrefs.SetInt("GraphicSetting.Resolution", resolution)

	if defaultGraphicSetting.Shadow == 1 then
		QualitySettingUtil.SetShadows(true)
		PlayerPrefs.SetInt("GraphicSetting.Shadow", 1)
	else
		QualitySettingUtil.SetShadows(false)
		PlayerPrefs.SetInt("GraphicSetting.Shadow", 0)
	end

	if defaultGraphicSetting.HDR == 1 and SystemInfoUtil.SupportsRenderTextureFormat(RenderTextureFormat.ARGBHalf) then
		SeanLib.PostProcessV2.GlobleSetting.HDR = true

		PlayerPrefs.SetInt("GraphicSetting.HDR", 1)
	else
		SeanLib.PostProcessV2.GlobleSetting.HDR = false

		PlayerPrefs.SetInt("GraphicSetting.HDR", 0)
	end

	if defaultGraphicSetting.BLOOM == 1 then
		SeanLib.PostProcessV2.GlobleSetting.Enable("BLOOM")
		PlayerPrefs.SetInt("GraphicSetting.BLOOM", 1)
	else
		SeanLib.PostProcessV2.GlobleSetting.Disable("BLOOM")
		PlayerPrefs.SetInt("GraphicSetting.BLOOM", 0)
	end

	if defaultGraphicSetting.BLUR == 1 then
		SeanLib.PostProcessV2.GlobleSetting.Enable("BLUR")
		PlayerPrefs.SetInt("GraphicSetting.BLUR", 1)
	else
		SeanLib.PostProcessV2.GlobleSetting.Disable("BLUR")
		PlayerPrefs.SetInt("GraphicSetting.BLUR", 0)
	end

	if defaultGraphicSetting.AntiAliasing == 1 then
		SeanLib.PostProcessV2.GlobleSetting.Enable("AntiAliasing")
		PlayerPrefs.SetInt("GraphicSetting.AntiAliasing", 1)
	else
		SeanLib.PostProcessV2.GlobleSetting.Disable("AntiAliasing")
		PlayerPrefs.SetInt("GraphicSetting.AntiAliasing", 0)
	end

	if defaultGraphicSetting.VolumetricLight == 1 then
		SeanLib.PostProcessV2.GlobleSetting.Enable("VolumetricLight")
		PlayerPrefs.SetInt("GraphicSetting.VOLUMETRICLIGHT", 1)
	else
		SeanLib.PostProcessV2.GlobleSetting.Disable("VolumetricLight")
		PlayerPrefs.SetInt("GraphicSetting.VOLUMETRICLIGHT", 0)
	end
end

function DlgGraphicSetting:OnClickedButton()
	print(self.targetLevel)
	self:ApplyGraphicSetting(self.targetLevel)

	local deviceLevel = self.targetLevel

	if deviceLevel == DEVICE_LEVEL.LOW then
		bestId = 1
	elseif deviceLevel == DEVICE_LEVEL.MEDIUM then
		bestId = 2
	elseif deviceLevel == DEVICE_LEVEL.HIGH then
		bestId = 3
	elseif deviceLevel == DEVICE_LEVEL.ULTRA then
		bestId = 4
	else
		bestId = 3
	end

	self.GraphicSettingLevel = bestId

	PlayerPrefs.SetInt("GraphicSettingLevel", self.GraphicSettingLevel)
	PlayerPrefs.SetInt("InitGraphicSetting", 1)
	self:Close()
	self.cb()
end

function DlgGraphicSetting:OnEnter(vParam)
	self.BtnConfirm = self:GetChildGameObject("Panel/Button")
	self.cb = vParam
	self.Text = self:GetChildComponent("Panel/Button/Text", "Text")
	self.Text1 = self:GetChildComponent("Panel/Text1", "Text")
	self.Text.text = _("Button_OK")
	self.Text1.text = _("Desc_Graphic_Setting")

	local bestId = 4
	local deviceLevel = SystemInfoUtil.GDeviceU3DInterfaceDeviceLevelResult()

	bestId = deviceLevel == DEVICE_LEVEL.LOW and 1 or deviceLevel == DEVICE_LEVEL.MEDIUM and 2 or deviceLevel == DEVICE_LEVEL.HIGH and 3 or deviceLevel == DEVICE_LEVEL.ULTRA and 4 or 3
	self.GraphicSettingLevel = bestId
	self.targetLevel = deviceLevel
	self.txtBest = "  <color=#fff661>(" .. _("PageActive_GoodLevel") .. ")</color>"

	for i = 1, 4 do
		self["toggle" .. i] = self:GetChildComponent("Panel/Image/Group/" .. i, "Toggle")
		self["label" .. i] = self:GetChildComponent("Panel/Image/Group/" .. i .. "/Label", "Text")

		local function wrap_cb(str)
			self:UpdateToggle(bestId)
		end

		self["toggle" .. i].onValueChanged:AddListener(wrap_cb)
	end

	self:UpdateToggle(bestId)

	self["toggle" .. bestId].isOn = true
end

function DlgGraphicSetting:UpdateToggle(bestId)
	for n = 1, 4 do
		local labelTemp = self["label" .. n]

		if self["toggle" .. n].isOn then
			labelTemp.text = "<color=white>" .. Lang(5000067 + n) .. "</color>"

			local deviceLevel = DEVICE_LEVEL.LOW

			if n == 1 then
				deviceLevel = DEVICE_LEVEL.LOW
			elseif n == 2 then
				deviceLevel = DEVICE_LEVEL.MEDIUM
			elseif n == 3 then
				deviceLevel = DEVICE_LEVEL.HIGH
			elseif n == 4 then
				deviceLevel = DEVICE_LEVEL.ULTRA
			else
				deviceLevel = DEVICE_LEVEL.LOW
			end

			self.targetLevel = deviceLevel
		else
			labelTemp.text = Lang(5000067 + n)
		end

		if n == bestId then
			labelTemp.text = labelTemp.text .. self.txtBest
		end
	end
end

function DlgGraphicSetting:OnBackAndroid()
	self:OnClickedButton()
end
