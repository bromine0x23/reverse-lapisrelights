-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/AR/ARMode_Foundation.lua

require("AR/ARMode_Base")

AREmotions = require("luaData/AREmotions")
ARMode_Foundation = class("ARMode_Foundation", ARMode_Base)

function ARMode_Foundation:OnInit(vParam)
	print("当前使用 AR 平面模式")
	ARMode_Foundation.base.OnInit(self, vParam)

	ARMode_Foundation.prefab = "AR/ARRoot_Foundation"
	self.SubTitleOn = true
	self.cameraFacing = true
end

function ARMode_Foundation:OnCreate(ARRootInstance)
	self.ARRootInstance = ARRootInstance
	self.ARUI = GOUtil.FindChildGameObject(ARRootInstance, "ARUI_Foundation")

	ARMode_Foundation.base.OnCreate(self, ARRootInstance)

	Physics.autoSimulation = true

	local function sf(gameObject)
		local rt = GOUtil.GetComponent(gameObject, "RectTransform")
		local hint = GOUtil.FindChildGameObject(rt.parent.gameObject, "Hint")
		local h_rt = GOUtil.GetComponent(hint, "RectTransform")

		GOUtil.SetRectTransformAnchoredPosition(hint, rt.anchoredPosition.x + 150, h_rt.anchoredPosition.y - 10)
	end

	local g = GOUtil.FindChildGameObject(ARRootInstance, "ARUI_Foundation/Interface/PageMain/ToggleHint")

	sf(g)

	local g2 = GOUtil.FindChildGameObject(ARRootInstance, "ARUI_Foundation/Interface/PageInteraction/ToggleHint")

	sf(g2)

	self.OrientationToggle = GOUtil.FindChildComponent(ARRootInstance, "ARUI_Foundation/Interface/PageBase/ChangeAppOrientation", "Toggle")
	self.width = Screen.width
	self.height = Screen.height
	self.HAnchorMin = nil
	self.HAnchorMax = nil
	self.VAnchorMin = nil
	self.VAnchorMax = nil

	self:DealWithSafeArea(GOUtil.FindChildGameObject(self.ARRootInstance, "ARUI_Foundation/Interface"), true)
end

function ARMode_Foundation:OnPurge(...)
	ARMode_Foundation.base.OnPurge(self)

	self.ARUI = nil
	self.ARRootInstance = nil
	Physics.autoSimulation = false
end

function ARMode_Foundation:OnRegisterEvent()
	ARMode_Foundation.base.OnRegisterEvent(self)
	Event.Instance:Add("ARChangeAppOrientation", self.ChangeAppOrientation, self)
	Event.Instance:Add("ARDisappearReset", self.ARDisappearReset, self)
end

function ARMode_Foundation:OnUnRegisterEvent()
	ARMode_Foundation.base.OnUnRegisterEvent(self)
	Event.Instance:Remove("ARChangeAppOrientation", self.ChangeAppOrientation, self)
	Event.Instance:Remove("ARDisappearReset", self.ARDisappearReset, self)
end

ChangeCameraTime = -1

function ARMode_Foundation:ChangeCameraFacing(frontfacing)
	if Time.time - ChangeCameraTime < 3 then
		UIMgr.ShowMsg(_("TipsARCamera"))

		return
	end

	print("カメラチェンジ")

	self.cameraFacing = not self.cameraFacing

	ARMode_Foundation.base.ChangeCameraFacing(self, self.cameraFacing)

	local ARWebCamera = GOUtil.FindChildComponent(self.ARRootInstance, "ARBack/ARBackImage", "ARWebCamera")

	ARWebCamera:ChangeCameraFacing(self.cameraFacing)

	ChangeCameraTime = Time.time
end

function ARMode_Foundation:ChangeAppOrientation(horizontal)
	ARMode_Foundation.base.ChangeAppOrientation(self, horizontal)

	if horizontal then
		ScreenUtil.SetOrientation(ScreenOrientation.Landscape)
	else
		ScreenUtil.SetOrientation(ScreenOrientation.Portrait)
	end

	self:DealWithSafeArea(GOUtil.FindChildGameObject(self.ARRootInstance, "ARUI_Foundation/Interface"), horizontal)

	self.OrientationToggle.isOn = horizontal
end

function ARMode_Foundation:DealWithSafeArea(gameObject, horizontal)
	local RectTransformComponent = GOUtil.GetComponent(gameObject, "RectTransform")

	if horizontal and self.HAnchorMin ~= nil then
		RectTransformComponent.anchorMin = self.HAnchorMin
		RectTransformComponent.anchorMax = self.HAnchorMax

		return
	end

	if not horizontal and self.VAnchorMin ~= nil then
		RectTransformComponent.anchorMin = self.VAnchorMin
		RectTransformComponent.anchorMax = self.VAnchorMax

		return
	end

	local r = Screen.safeArea
	local anchorMin = r.position
	local anchorMax = r.position + r.size

	if horizontal then
		anchorMin.x = TenaryOp(anchorMin.x / self.width < 0.06, anchorMin.x / self.width, 0.06)
		anchorMin.y = TenaryOp(anchorMin.y / self.height < 0.01, anchorMin.y / self.height, 0.01)
		anchorMax.x = TenaryOp(anchorMax.x / self.width < 0.98, anchorMax.x / self.width, 0.98)
		anchorMax.y = TenaryOp(anchorMax.y / self.height < 0, anchorMax.y / self.height, 1)
		self.HAnchorMin = anchorMin
		self.HAnchorMax = anchorMax
	else
		anchorMax = r.position
		anchorMin = r.position + r.size
		anchorMin.x = TenaryOp(anchorMin.x / Screen.height < 0.01, anchorMin.x / Screen.height, 0.01)
		anchorMin.y = TenaryOp(anchorMin.y / Screen.width < 0.01, anchorMin.y / Screen.width, 0.01)
		anchorMax.x = TenaryOp(anchorMax.y / Screen.width < 0, anchorMax.y / Screen.width, 1)
		anchorMax.y = TenaryOp(anchorMax.x / Screen.height > 0.945, anchorMax.x / Screen.height, 0.945)
		self.VAnchorMin = anchorMin
		self.VAnchorMax = anchorMax
	end

	RectTransformComponent.anchorMin = anchorMin
	RectTransformComponent.anchorMax = anchorMax
end

function ARMode_Foundation:EmotionChanged(emotion, isOn)
	if isOn then
		local expreesion = emotion.name

		self.actor.ExpressionSystem:CrossFade(expreesion)
	end
end

function ARMode_Foundation:ToggleEmotion(isOn)
	local emotions_anim = GOUtil.FindChildComponent(self.ARUI, "Interface/PageMain/Emotions", "Animator")

	if self.Emotions == nil then
		self.Emotions = {}

		local count = 0

		for i = 1, #AREmotions do
			local v = AREmotions[i]

			if v.Character == self.infoRole.data.ID then
				self.Emotions[count] = v
				count = count + 1
			end
		end
	end

	local emotions_UI_content = GOUtil.FindChildGameObject(self.ARUI, "Interface/PageMain/Emotions/Scroll View/Viewport/Content")
	local template = GOUtil.FindChildGameObject(self.ARUI, "Interface/PageMain/Emotions/Scroll View/Viewport/_Template")

	GOUtil.DestroyAllChildren(emotions_UI_content)

	local toggle

	for k, v in pairs(self.Emotions) do
		local item = GOUtil.Instantiate(template, emotions_UI_content)
		local image = GOUtil.FindChildComponent(item, "Background", "RawImage")

		if toggle == nil then
			toggle = GOUtil.FindChildComponent(item, "", "Toggle")
		end

		UIUtil.SetRawImageTexture(image, v.Icon)

		item.name = v.Emotion

		item:SetActive(true)
	end

	toggle.isOn = true

	if isOn then
		emotions_anim:SetTrigger("Show")
	else
		emotions_anim:SetTrigger("Hide")
	end
end

function ARMode_Foundation:ShowSubTitle(str)
	ARMode_Foundation.base.ShowSubTitle(self, str)

	if not self.SubTitleOn then
		return
	end

	local text = GOUtil.FindChildComponent(ARMode_Foundation.ARUI, "UISubTitle/Text", "Text")
	local dlg = GOUtil.FindChildGameObject(ARMode_Foundation.ARUI, "UISubTitle")

	dlg:SetActive(true)

	text.text = str

	local function cb()
		if not IsNil(dlg) then
			dlg:SetActive(false)
		end
	end

	if timeId ~= nil then
		TimerMgr.RemoveTimer(timeId)
	end

	timeId = TimerMgr.AddTimer(eTimerType.RealTime, 4, cb, self)
end

function ARMode_Foundation:OnARStepChanged(step)
	print("OnARStepChanged:" .. step)
	ARMode_Foundation.base.OnARStepChanged(self, step)

	local Hints = GOUtil.FindChildGameObject(self.ARUI, "Interface/PageBase/Hints")
	local arui = GOUtil.GetComponent(self.ARUI, "ARUI")

	if step == 0 then
		local HintsText = GOUtil.FindChildGameObject(Hints, "HintText")
		local HintsText_text = GOUtil.FindChildComponent(HintsText, "Text", "Text")
		local HintsText_Anim = GOUtil.FindChildGameObject(HintsText, "Anim")

		HintsText_Anim:SetActive(false)

		HintsText_text.text = _("AR_SearchPlane")

		HintsText:SetActive(true)
	elseif step == 1 then
		local HintsText = GOUtil.FindChildGameObject(Hints, "HintText")
		local HintsText_text = GOUtil.FindChildComponent(HintsText, "Text", "Text")
		local HintsText_Anim = GOUtil.FindChildGameObject(HintsText, "Anim")

		HintsText_Anim:SetActive(true)

		HintsText_text.text = _("AR_ClickBlackCallIdol")

		HintsText:SetActive(true)
		arui:ShowVisualARPlane()
	elseif step == 2 then
		PlayAnim(eInterctAnimType.helloMorning, self.actor, self.infoRole)

		local HintsText = GOUtil.FindChildGameObject(Hints, "HintText")

		arui:HideVisualARPlane()
		HintsText:SetActive(false)
	end

	local MainHints = GOUtil.FindChildGameObject(self.ARUI, "Interface/PageMain/Hint")
	local Scale_text = GOUtil.FindChildComponent(MainHints, "Scale/Text", "Text")

	Scale_text.text = _("AR_ScalingIdol")

	local Rotation_text = GOUtil.FindChildComponent(MainHints, "Rotation/Text", "Text")

	Rotation_text.text = _("AR_RotateIdol")

	local Move_text = GOUtil.FindChildComponent(MainHints, "Move/Text", "Text")

	Move_text.text = _("AR_MoveIdol")

	local InteractionHints = GOUtil.FindChildGameObject(self.ARUI, "Interface/PageInteraction/Hint")
	local TapHead_text = GOUtil.FindChildComponent(InteractionHints, "TapHead/Text", "Text")

	TapHead_text.text = _("AR_TapHeadIdol")

	local TapBody_text = GOUtil.FindChildComponent(InteractionHints, "TapBody/Text", "Text")

	TapBody_text.text = _("AR_TapBodyIdol")
end

function ARMode_Foundation:BtnResetActor()
	self:StopDance(true)
	self:StopAnim(true)
	self.actor:ResetState()

	local ActorPostion = GOUtil.FindChildComponent(self.ARRootInstance, "ActorPostion", "Transform")

	ActorPostion.localPosition = Vector3(1000, 0, 0)

	for i = 1, ActorPostion.childCount do
		SetActiveFunc(ActorPostion:GetChild(i - 1), true)
	end

	local animator = GOUtil.FindChildComponent(self.actor.Root, "Model", "Animator")

	if self.AnimatorController ~= nil then
		animator.runtimeAnimatorController = self.AnimatorController
	end

	UIMgr.HideMsg2()
end

function ARMode_Foundation:ToggleSubTitle(isOn)
	self.SubTitleOn = isOn

	if not IsNil(self.goDanceSubtitle) then
		self.goDanceSubtitle.gameObject:SetActive(isOn)
	end
end

function ARMode_Foundation:ARDisappearReset()
	self:StopDance(true)
	self:StopAnim(true)
	self.actor:ResetState()
end

function ARMode_Foundation:OnBackAndroid()
	return fasle
end

return ARMode_Foundation
