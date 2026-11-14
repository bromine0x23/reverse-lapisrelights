-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/AR/ARMode_Free.lua

require("AR/ARMode_Base")

AREmotions = require("luaData/AREmotions")
ARMode_Free = class("ARMode_Free", ARMode_Base)

print(ARMode_Free)

function ARMode_Free:OnInit(vParam)
	print("当前使用 AR自由模式")
	ARMode_Free.base.OnInit(self, vParam)

	ARMode_Free.prefab = "AR/ARRoot_Free"
	self.SubTitleOn = true
	self.cameraFacing = false
end

function ARMode_Free:OnCreate(ARRootInstance)
	local function sf(gameObject, flag)
		local rt = GOUtil.GetComponent(gameObject, "RectTransform")
		local hint = GOUtil.FindChildGameObject(rt.parent.gameObject, "Hint")
		local h_rt = GOUtil.GetComponent(hint, "RectTransform")

		GOUtil.SetRectTransformAnchoredPosition(hint, rt.anchoredPosition.x + 150, h_rt.anchoredPosition.y - 10)
	end

	self.ARRootInstance = ARRootInstance
	self.ARUI = GOUtil.FindChildGameObject(ARRootInstance, "ARUI_Free")

	ScreenUtil.SetOrientation(ARMode_Base.orientation)
	ARMode_Free.base.OnCreate(self, ARRootInstance)

	local g = GOUtil.FindChildGameObject(ARRootInstance, "ARUI_Free/Interface/PageMain/ToggleHint")

	sf(g)

	local g2 = GOUtil.FindChildGameObject(ARRootInstance, "ARUI_Free/Interface/PageInteraction/ToggleHint")

	sf(g2)

	self.OrientationToggle = GOUtil.FindChildComponent(ARRootInstance, "ARUI_Free/Interface/PageBase/ChangeAppOrientation", "Toggle")
	self.width = Screen.width
	self.height = Screen.height
	self.HAnchorMin = nil
	self.HAnchorMax = nil
	self.VAnchorMin = nil
	self.VAnchorMax = nil

	self:DealWithSafeArea(GOUtil.FindChildGameObject(self.ARRootInstance, "ARUI_Free/Interface"), true)
end

function ARMode_Free:ToggleEmotion(isOn)
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

function ARMode_Free:EmotionChanged(emotion, isOn)
	if isOn then
		local expreesion = emotion.name

		self.actor.ExpressionSystem:CrossFade(expreesion)
	end
end

function ARMode_Free:ShowSubTitle(str)
	ARMode_Free.base.ShowSubTitle(self, str)

	if not self.SubTitleOn then
		return
	end

	local text = GOUtil.FindChildComponent(ARMode_Free.ARUI, "UISubTitle/Text", "Text")
	local dlg = GOUtil.FindChildGameObject(ARMode_Free.ARUI, "UISubTitle")

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

function ARMode_Free:OnPurge(...)
	ARMode_Free.base.OnPurge(self)

	self.ARUI = nil
	self.ARRootInstance = nil
	self.Emotions = nil
end

function ARMode_Free:OnRegisterEvent()
	ARMode_Free.base.OnRegisterEvent(self)
	Event.Instance:Add("ARChangeAppOrientation", self.ChangeAppOrientation, self)
end

function ARMode_Free:OnUnRegisterEvent()
	ARMode_Free.base.OnUnRegisterEvent(self)
	Event.Instance:Remove("ARChangeAppOrientation", self.ChangeAppOrientation, self)
end

ChangeCameraTime = -1

function ARMode_Free:ChangeCameraFacing(frontfacing)
	if Time.time - ChangeCameraTime < 3 then
		UIMgr.ShowMsg(_("TipsARCamera"))

		return
	end

	print("カメラチェンジ")

	self.cameraFacing = not self.cameraFacing

	ARMode_Free.base.ChangeCameraFacing(self, self.cameraFacing)
	print(self.cameraFacing)

	local ARWebCamera = GOUtil.FindChildComponent(self.ARRootInstance, "ARBack/ARBackImage", "ARWebCamera")

	ARWebCamera:ChangeCameraFacing(self.cameraFacing)

	ChangeCameraTime = Time.time
end

function ARMode_Free:ChangeAppOrientation(horizontal)
	ARMode_Free.base.ChangeAppOrientation(self, horizontal)

	if horizontal then
		ScreenUtil.SetOrientation(ScreenOrientation.Landscape)
	else
		ScreenUtil.SetOrientation(ScreenOrientation.Portrait)
	end

	self:DealWithSafeArea(GOUtil.FindChildGameObject(self.ARRootInstance, "ARUI_Free/Interface"), horizontal)

	local actorpos = GOUtil.FindChildGameObject(self.ARRootInstance, "ActorPostion")

	actorpos.transform.localPosition = Vector3.New(0, 0, -5)
	self.OrientationToggle.isOn = horizontal
end

function ARMode_Free:DealWithSafeArea(gameObject, horizontal)
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

function ARMode_Free:OnARStepChanged(step)
	PlayAnim(eInterctAnimType.helloMorning, self.actor, self.infoRole)
	ARMode_Free.base.OnARStepChanged(self, step)

	local Hints = GOUtil.FindChildGameObject(self.ARUI, "Interface/PageMain/Hint")
	local Scale_text = GOUtil.FindChildComponent(Hints, "Scale/Text", "Text")

	Scale_text.text = _("AR_ScalingIdol")

	local Rotation_text = GOUtil.FindChildComponent(Hints, "Rotation/Text", "Text")

	Rotation_text.text = _("AR_RotateIdol")

	local Move_text = GOUtil.FindChildComponent(Hints, "Move/Text", "Text")

	Move_text.text = _("AR_MoveIdol")

	local InteractionHints = GOUtil.FindChildGameObject(self.ARUI, "Interface/PageInteraction/Hint")
	local TapHead_text = GOUtil.FindChildComponent(InteractionHints, "TapHead/Text", "Text")

	TapHead_text.text = _("AR_TapHeadIdol")

	local TapBody_text = GOUtil.FindChildComponent(InteractionHints, "TapBody/Text", "Text")

	TapBody_text.text = _("AR_TapBodyIdol")
end

function ARMode_Free:BtnResetActor()
	local actorpos = GOUtil.FindChildGameObject(self.ARRootInstance, "ActorPostion")

	actorpos.transform.localPosition = Vector3.New(0, 0, -5)
	actorpos.transform.eulerAngles = Vector3.New(0, 180, 0)
	actorpos.transform.localScale = Vector3.one

	self:StopDance(true)
	self:StopAnim(true)
	self.actor:ResetState()

	local animator = GOUtil.FindChildComponent(self.actor.Root, "Model", "Animator")

	if self.AnimatorController ~= nil then
		animator.runtimeAnimatorController = self.AnimatorController
	end

	PlayAnim(eInterctAnimType.helloMorning, self.actor, self.infoRole)
end

function ARMode_Free:ToggleSubTitle(isOn)
	self.SubTitleOn = isOn

	if not IsNil(self.goDanceSubtitle) then
		self.goDanceSubtitle.gameObject:SetActive(isOn)
	end
end

function ARMode_Free:OnBackAndroid()
	local dancePanel = GOUtil.FindChildGameObject(self.ARUI, "Interface/PageDances")
	local interactionPanel = GOUtil.FindChildGameObject(self.ARUI, "Interface/PageInteraction")
	local animsPanel = GOUtil.FindChildGameObject(self.ARUI, "Interface/PageAnims")
	local mainPanel = GOUtil.FindChildGameObject(self.ARUI, "Interface/PageMain")
	local main_anim = GOUtil.FindChildComponent(self.ARUI, "Interface/PageMain", "Animator")

	if dancePanel and GOUtil.IsActiveSelf(dancePanel) then
		GOUtil.SetActive(dancePanel, false)
		GOUtil.SetActive(mainPanel, true)
		main_anim:SetTrigger("Show")

		return true
	end

	if animsPanel and GOUtil.IsActiveSelf(animsPanel) then
		GOUtil.SetActive(animsPanel, false)
		GOUtil.SetActive(mainPanel, true)
		main_anim:SetTrigger("Show")

		return true
	end

	if interactionPanel and GOUtil.IsActiveSelf(interactionPanel) then
		GOUtil.SetActive(interactionPanel, false)
		GOUtil.SetActive(mainPanel, true)
		main_anim:SetTrigger("Show")

		return true
	end

	return false
end

return ARMode_Free
