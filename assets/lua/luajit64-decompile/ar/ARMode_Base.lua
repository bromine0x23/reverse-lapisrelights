-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/AR/ARMode_Base.lua

require("Util/Util")

local favorPose = require("luaData/FavorPose")
local favoDance = require("luaData/DanceData")

require("Info/InfoChapter")

ARMode_Base = class("ARMode_Base")

function ARMode_Base:OnInit(vParam)
	self.infoRole = vParam.infoRole
	ARMode_Base.infoRole = self.infoRole
	ARMode_Base.orientation = ScreenOrientation.AutoRotation

	UIMgr.ResetMsg2OffsetType(DlgMessage2OffType.default)
end

function ARMode_Base:OnCreate(ARRootInstance)
	self.ARRootInstance = ARRootInstance
	ARMode_Base.ARRootInstance = ARRootInstance
	ARMode_Base.shadow = GOUtil.FindChildGameObject(ARMode_Base.ARRootInstance, "ActorPostion/Shadow/Shadow")

	self:SetShadow(ARMode_Base.shadow)
	LoadingMgr.Show(eLoadingType.Repeat)
	ResourceMgr.BeginSubmit(function()
		self:OnAsyncPrecacheActorFinish()
	end)

	local controllerMain = ActorUtil.MotionControllerDataFilter(self.infoRole.data.ActorID, "Ar", "None")
	local actorFactory

	actorFactory = ActorUtil.BuildActorFactoryByInfoRole(self.infoRole, controllerMain)

	actorFactory:Cache()

	self.actorFactory = actorFactory

	ResourceMgr.SubmitCache("AR/ARPantsBillboardQuad", self, "arPantsBillboardPrefab", GameObject)
	ResourceMgr.EndSubmit()

	if not IsNil(self.ARUI) then
		local GoDance = GOUtil.FindChildGameObject(self.ARUI, "Interface/PageMain/UIPageSelector/ToDance")

		GOUtil.AddMissingComponent(GoDance, "UIRedDot")
		RedDotSystemMgr.SetUIRedDot(GoDance, "Role/" .. self.infoRole.id .. "/Interact/AR/Dance")
	end
end

function ARMode_Base:OnAsyncPrecacheActorFinish()
	if SceneAR.CreateInstance().NotSupport ~= true then
		NetManager:SubmitClientAction(protocol_pb.P130_Request.AR, "", nil)
	end

	LoadingMgr.Hide(eLoadingType.Repeat)

	self.actor = self.actorFactory:Build()
	ARMode_Base.actor = self.actor

	self.actor:Create()
	self.actor.SkeletonSystem:SetSrpingBoneEnabled(false)

	self.BipBone = self.actor.SkeletonSystem:GetBone("Bip001_Pelvis")

	GOUtil.InstantiatePrefab(self.arPantsBillboardPrefab, self.BipBone.gameObject)

	local go = self.actor.Root
	local actorpos = GOUtil.FindChildGameObject(self.ARRootInstance, "ActorPostion")

	GOUtil.AttachGameObject(go, actorpos, true)

	local camera = GOUtil.FindChildGameObject(self.ARRootInstance, "Main Camera")

	FingerGesturesUtil.SetScreenRaycasterCamera(camera)
	FingerGesturesUtil.Enable()

	local GUID = ReferenceRoot.AddMissingReferenceGUID(go, nil)

	ReferenceRoot.Instance:SetDynamicName("AR_Actor0", GUID)

	local head = GOUtil.GetComponentInChildren(go, "Oz.ActorModule.IKHeadController")

	head:SetLookAtTarget(camera.transform, -1)

	head.WeightParts = Vector4.New(0, 0.5, 1, 1)

	local eye = GOUtil.GetComponentInChildren(go, "EyeDirection")

	eye:SetTarget(camera.gameObject)

	if actorpos.gameObject.activeInHierarchy then
		local arui = GOUtil.GetComponent(self.ARUI, "AR.ARUI")

		arui:SetState(1)
	end

	self:ToggleEyeFollow(true)
end

function ARMode_Base:OnPurge(...)
	self.ARUI = nil
	self.poseData = nil
	self.CurrentDance = nil
	self.AnimatorController = nil
	self.shadow = nil
	self.CurrentDance = nil
	self.SelectDance = nil
	self.SelectAnim = nil

	ScreenUtil.SetOrientation(ScreenOrientation.AutoRotation)

	if self.actor then
		self.actor:Destroy()

		self.actor = nil
	end
end

function ARMode_Base:OnRegisterEvent()
	local looplist = GOUtil.FindChildComponent(self.ARUI, "Interface/PageAnims/Scroll View", "GeneralLoopList_ToLua")
	local count = 0

	self.poseData = {}

	for i = 1, #favorPose do
		local v = favorPose[i]

		if v.Character == self.infoRole.data.ID then
			self.poseData[count] = v
			count = count + 1
		end
	end

	for k, v in pairs(favorPose) do
		-- block empty
	end

	looplist:RefreshView(count, self, self.OnRefreshItem)

	local Dancelooplist = GOUtil.FindChildComponent(self.ARUI, "Interface/PageDances/Scroll View", "GeneralLoopList_ToLua")
	local count = 0

	self.danceData = {}

	for k, v in pairs(favoDance) do
		self.danceData[count] = v
		count = count + 1
	end

	Dancelooplist:RefreshView(count, self, self.OnRefreshDanceItem)
	EventListenerMgr.AddFingerGestureListener(self.OnTap, self, eFingerGestureType.Tap)
end

function ARMode_Base:OnUnRegisterEvent()
	EventListenerMgr.RemoveFingerGestureListener(self.OnTap, self, eFingerGestureType.Tap)
end

function ARMode_Base:OnTap(gesture)
	if gesture.Selection ~= nil and not ARMode_Base.fobidenTouch then
		if Time.time - favioranimTime < 5 then
			return
		end

		self:StopDance(true)
		self:StopAnim(true)
		self.actor:ResetState()

		local animator = GOUtil.FindChildComponent(self.actor.Root, "Model", "Animator")

		if self.AnimatorController ~= nil then
			animator.runtimeAnimatorController = self.AnimatorController
		end

		if gesture.Selection.tag == "Head" then
			PlayAnim(eInterctAnimType.tapHead, self.actor, self.infoRole)
		elseif gesture.Selection.tag == "Body" then
			PlayAnim(eInterctAnimType.tapBody, self.actor, self.infoRole)
		end
	end

	favioranimTime = Time.time
end

function ARMode_Base:StopDance(refreshView)
	if self.CurrentDance ~= nil then
		self.CurrentDance:Stop()

		self.CurrentDance = nil
		self.SelectDance = nil

		if refreshView then
			local Dancelooplist = GOUtil.FindChildComponent(self.ARUI, "Interface/PageDances/Scroll View", "GeneralLoopList_ToLua")

			Dancelooplist:RefreshView()
		end
	end
end

function ARMode_Base:StopAnim(refreshView)
	self.SelectAnim = nil

	if refreshView and not IsNil(self.ARUI) then
		local looplist = GOUtil.FindChildComponent(self.ARUI, "Interface/PageAnims/Scroll View", "GeneralLoopList_ToLua")

		looplist:RefreshView()
	end
end

function StopDanceAni(base)
	base:StopDance(false)
	base:StopAnim(true)
	base.actor:ResetState()

	local animator = GOUtil.FindChildComponent(base.actor.Root, "Model", "Animator")

	if base.AnimatorController ~= nil then
		animator.runtimeAnimatorController = base.AnimatorController
	end
end

function ARMode_Base:ToInteraction()
	if ARMode_Free ~= nil then
		StopDanceAni(ARMode_Free)
	end

	if ARMode_Foundation ~= nil then
		StopDanceAni(ARMode_Foundation)
	end

	PlayAnim(eInterctAnimType.helloMorning, ARMode_Base.actor, ARMode_Base.infoRole)

	ARMode_Base.fobidenTouch = false
end

function ARMode_Base:ToDance()
	RoleRDL.InteractRDL.SubInteractARDance(self.infoRole)
end

function ARMode_Base:ToAnimation()
	return
end

function ARMode_Base:ReturnFromInteraction()
	ARMode_Base.fobidenTouch = true
end

function ARMode_Base:OnRefreshDanceItem(index, itemGO)
	local btn = GOUtil.GetComponentInChildren(itemGO, "Button")

	btn.name = index

	local Dance = self.danceData[index]

	EventListenerMgr.RemoveUIListener(btn.gameObject, self.OnClickDanceItem, self, 4)
	EventListenerMgr.AddUIListener(btn.gameObject, self.OnClickDanceItem, self, 4)

	local image = GOUtil.FindChildComponent(itemGO, "Image", "RawImage")

	UIUtil.SetRawImageTexture(image, Dance.Icon)
	print("Dance.Stage:" .. Dance.Stage)

	local info = ChapterMgr:GetStage(Dance.Stage)
	local chapterID = ChapterMgr:GetChapterIdx(info.data.ChapterID)
	local StageIndex = ChapterMgr:GetStageIndex(Dance.Stage)
	local Selector = GOUtil.FindChildComponent(itemGO, "Selected", "Image")
	local anim = GOUtil.GetComponent(itemGO, "Animator")

	if self.SelectDance == btn.name then
		anim.enabled = true

		Selector.gameObject:SetActive(true)
	else
		image.transform.localRotation = Quaternion.identity
		anim.enabled = false

		Selector.gameObject:SetActive(false)
	end

	local Lock = GOUtil.FindChildComponent(itemGO, "Lock", "Image")

	if info.pb.isPass == true then
		Lock.gameObject:SetActive(false)

		local text = GOUtil.FindChildComponent(itemGO, "Text", "Text")

		text.text = Lang(Dance.Name)

		text.gameObject:SetActive(true)

		local mask = GOUtil.FindChildGameObject(itemGO, "Mask")
		local maskText = GOUtil.FindChildComponent(itemGO, "Mask/Text", "Text")
		local str = Lang(Dance.Name)

		if text.preferredHeight > 30 then
			text.gameObject:SetActive(false)
			mask:SetActive(true)

			maskText.text = Lang(Dance.Name)
		else
			text.gameObject:SetActive(true)
			mask:SetActive(false)
		end
	else
		Lock.gameObject:SetActive(true)
	end
end

function ARMode_Base:OnClickDanceItem(data)
	local actorpos = GOUtil.FindChildGameObject(self.ARRootInstance, "ActorPostion")

	actorpos.transform.eulerAngles = Vector3.New(0, 180, 0)

	local Dance = self.danceData[tonumber(data.selectedObject.name)]
	local infoStage = ChapterMgr:GetStage(Dance.Stage)

	if not infoStage.pb.isPass then
		local strLock = ""
		local infoChapter, i, j = ChapterMgr:GetChapterByStageID(infoStage.id)
		local str
		local infoChapter, i, j = ChapterMgr:GetChapterByStageID(infoStage.id)

		if infoChapter ~= nil and infoChapter.data.Type == 1 and i ~= nil and j ~= nil then
			local strStage = "<color=yellow>" .. i .. "-" .. j .. "</color>"

			str = _("eBattleType_1") .. strStage .. Lang(infoStage.data.Name) .. " " .. _("Prompt_TutorialLimitStage")
		elseif infoChapter ~= nil and infoChapter.data.Type ~= 1 and i ~= nil and j ~= nil then
			local strStage = "<color=yellow>" .. Lang(i) .. "-" .. Lang(j) .. "</color>"

			str = strStage .. Lang(infoStage.data.Name) .. " " .. _("Prompt_TutorialLimitStage")
		end

		UIMgr.ShowMsg(str)

		return
	end

	self:StopDance(false)
	self:StopAnim(true)
	self.actor:ResetState()

	local actorGO = self.actor.Root
	local model = GOUtil.FindChildGameObject(actorGO, "Model")
	local actorGUID = ReferenceRoot.AddMissingReferenceGUID(actorGO)

	ReferenceRoot.Instance:SetDynamicName("Actor 1", actorGUID)

	local modelGUID = ReferenceRoot.AddMissingReferenceGUID(model)

	ReferenceRoot.Instance:SetDynamicName("Model 1", modelGUID)

	self.SelectAnim = nil
	self.SelectDance = data.selectedObject.name

	local animator = GOUtil.FindChildComponent(self.actor.Root, "Model", "Animator")

	if animator.runtimeAnimatorController ~= nil then
		self.AnimatorController = animator.runtimeAnimatorController
	end

	local dancePrefab = ResourceMgr.LoadSync(Dance.DanceTimeLine, nil)
	local danceinstance = GOUtil.InstantiatePrefab(dancePrefab, nil)

	print(self)

	self.goDanceSubtitle = GOUtil.GetComponentInChildren(danceinstance, "Canvas")

	if not IsNil(self.goDanceSubtitle) then
		self.goDanceSubtitle.gameObject:SetActive(self.SubTitleOn)
	end

	self.CurrentDance = GOUtil.FindChildComponent(danceinstance, "", "ARLiveDance")

	self.CurrentDance:Play()

	animator.runtimeAnimatorController = nil

	local Dancelooplist = GOUtil.FindChildComponent(self.ARUI, "Interface/PageDances/Scroll View", "GeneralLoopList_ToLua")

	Dancelooplist:RefreshView()
end

function ARMode_Base:OnRefreshItem(index, itemGO)
	itemGO.transform:SetSiblingIndex(index)

	local btn = GOUtil.GetComponentInChildren(itemGO, "Button")

	btn.name = index

	local Pose = self.poseData[index]

	EventListenerMgr.RemoveUIListener(btn.gameObject, self.OnClickItem, self, 4)
	EventListenerMgr.AddUIListener(btn.gameObject, self.OnClickItem, self, 4)

	local text = GOUtil.FindChildComponent(itemGO, "Text", "Text")

	text.text = Lang(Pose.Name)

	local image = GOUtil.FindChildComponent(itemGO, "Image", "RawImage")

	UIUtil.SetRawImageTexture(image, Pose.Icon)

	local Selector = GOUtil.FindChildComponent(itemGO, "Selected", "Image")

	if self.SelectAnim == btn.name then
		Selector.gameObject:SetActive(true)
	else
		Selector.gameObject:SetActive(false)
	end

	local Lock = GOUtil.FindChildComponent(itemGO, "Lock", "Image")
	local LockText = GOUtil.FindChildComponent(itemGO, "Lock/Text", "Text")

	LockText.text = string.format(_("FavorPose_LockHint"), Pose.FavorLevel)

	if self.infoRole.curFavorLevel >= Pose.FavorLevel then
		Lock.gameObject:SetActive(false)
		text.gameObject:SetActive(true)
	else
		Lock.gameObject:SetActive(true)
		text.gameObject:SetActive(false)
	end
end

animTime = -1
favioranimTime = -1

function ARMode_Base:OnClickItem(data)
	if Time.time - animTime < 0.65 then
		return
	end

	if self.SelectAnim == data.selectedObject.name then
		return
	end

	if self.actor.MotionSystem:IsInTransition() == true then
		return
	end

	self:StopDance(true)
	self:StopAnim(false)
	self.actor:ResetState()

	self.SelectDance = nil
	self.SelectAnim = data.selectedObject.name

	local Pose = self.poseData[tonumber(self.SelectAnim)]

	printTable(Pose)

	local animator = GOUtil.FindChildComponent(self.actor.Root, "Model", "Animator")
	local anim = ResourceMgr.LoadSync(Pose.Pose, UnityEngine.AnimationClip)

	if self.AnimatorController ~= nil then
		animator.runtimeAnimatorController = self.AnimatorController
	end

	print("播放", Pose.Pose, anim)
	self.actor:ResetBehaviour()
	self.actor.MotionSystem:CrossFadeFixedTime(anim, 0.25)

	local looplist = GOUtil.FindChildComponent(self.ARUI, "Interface/PageAnims/Scroll View", "GeneralLoopList_ToLua")

	looplist:RefreshView()

	animTime = Time.time
end

function ARMode_Base:ToggleShadow(isOn)
	if isOn then
		ARMode_Base.shadow:SetActive(true)

		ARMode_Base.shadow.transform.localPosition = Vector3.zero

		self:SetShadow(ARMode_Base.shadow)
	else
		ARMode_Base.shadow:SetActive(false)
	end
end

function ARMode_Base:SetShadow(shadowRoot)
	if IsNil(shadowRoot) then
		return
	end

	local enableRealtimeShadow = QualitySettingUtil.GetShadows()
	local realtimeShadow = GOUtil.FindChildGameObject(shadowRoot, "Realtime")

	if not IsNil(realtimeShadow) then
		GOUtil.SetActive(realtimeShadow, enableRealtimeShadow)
	else
		print("Can not find ActorPostion/Shadow/Realtime")
	end

	local geometryShadow = GOUtil.FindChildGameObject(shadowRoot, "Geometry")

	if not IsNil(geometryShadow) then
		GOUtil.SetActive(geometryShadow, not enableRealtimeShadow)
	else
		print("Can not find ActorPostion/Shadow/Geometry")
	end
end

function ARMode_Base:ChangeCameraFacing(frontfacing)
	return
end

function ARMode_Base:ChangeAppOrientation(horizontal)
	if self.actor ~= nil then
		self.actor.Root.transform.localPosition = Vector3.zero
	end
end

function ARMode_Base:OnARStepChanged(step)
	return
end

function ARMode_Base:ToggleEyeFollow(isOn)
	local ActorGo = self.actor.Root
	local head = GOUtil.GetComponentInChildren(ActorGo, "Oz.ActorModule.IKHeadController")
	local eye = GOUtil.GetComponentInChildren(ActorGo, "EyeDirection")
	local camera = GOUtil.FindChildGameObject(self.ARRootInstance, "Main Camera")

	if isOn then
		head:SetLookAtTarget(camera.transform)

		head.WeightParts = Vector4.New(0, 0.5, 1, 1)

		eye:SetTarget(camera.gameObject)
	else
		head:SetLookAtTarget(nil)
		eye:SetTarget(nil)
	end
end

return ARMode_Base
