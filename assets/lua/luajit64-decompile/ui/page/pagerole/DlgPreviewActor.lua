-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRole/DlgPreviewActor.lua

DlgPreviewActor = class("DlgPreviewActor")
ePanelActorPosType = {
	Role = 1,
	Equip = 2,
	Fitting = 3
}
modelPosZ = {
	0,
	0.4,
	0,
	0.4,
	0
}

function DlgPreviewActor:ctor()
	self.IsLeft = false
	self.isRTCameraFar = false

	self:OnRegisterEvent()
end

function DlgPreviewActor:Init(renderCtrl, isWithWeapon, needRandomIdle)
	self.UI3DActorRotate = UI3DActorRotate()

	self.UI3DActorRotate:Init(renderCtrl.gameObject)

	self.isWithWeapon = isWithWeapon
	self.needRandomIdle = needRandomIdle

	local img = GOUtil.GetComponent(renderCtrl.gameObject, "RawImage")

	DealWithListRef(self, UIUtil.SetRawImageMaterial(img, "UI/Materials/DefaultUIForRT"))

	if self.IsLeft then
		UIMgr.ResetMsg2OffsetType(DlgMessage2OffType.offset2)
	else
		UIMgr.ResetMsg2OffsetType(DlgMessage2OffType.default)
	end

	self.cb = nil
	self.actorFactorys = {}
	self.UI3DActorRotates = {}
	self.actors = {}
	self.actorsName = {}
end

function DlgPreviewActor:Purge()
	self:OnUnRegisterEvent()

	self.cb = nil

	if self.infoRole then
		SoundMgr.UnloadBank(self.infoRole.data.VocalBank)
	end

	self:ClearActor()

	if self.UI3DActorRotate then
		self.UI3DActorRotate:OnLeave()

		self.UI3DActorRotate = nil
	end

	if self.actorFunc then
		self.actorFunc()
	end

	if self.actorFactorys then
		for i, v in pairs(self.actorFactorys) do
			if v then
				v:Purge()

				v = nil
			end
		end
	end

	if self.actors then
		for i, v in pairs(self.actors) do
			if v then
				v:Destroy()

				v = nil
			end
		end
	end

	UnloadAllImageSprite(self)
end

function DlgPreviewActor:ClearActor(needGC)
	local gc_flag = false

	if self.actor then
		self.actor:Destroy()

		self.actor = nil
		gc_flag = true
	end

	if self.actorFactory then
		self.actorFactory:Purge()

		self.actorFactory = nil
		gc_flag = true
	end

	if gc_flag and needGC then
		System.GC.Collect()
	end
end

function DlgPreviewActor:LoadActor(infoRole, isFixed, motionDataPath, panelType)
	self.infoRole = infoRole

	self:ClearActor(true)
	LoadingMgr.Show(eLoadingType.Repeat)
	ResourceMgr.BeginSubmit(function()
		self:OnAsyncPrecacheActorFinish()
	end)

	if isFixed then
		self.offx = infoRole.actorData.Height[ePanelActorPosType.Fitting][1]
		self.offy = infoRole.actorData.Height[ePanelActorPosType.Fitting][2]
		self.offz = 1.45
	else
		panelType = TenaryOp(panelType ~= nil, panelType, ePanelActorPosType.Role)
		self.offx = infoRole.actorData.Height[panelType][1]
		self.offy = infoRole.actorData.Height[panelType][2]
		self.offz = 0.162
	end

	local controllerMain = ActorUtil.MotionControllerDataFilter(infoRole.data.ActorID, "Fitting", "None")
	local actor, actorFactory

	if self.isWithWeapon then
		local controllerInteract = ActorUtil.MotionControllerDataFilter(infoRole.data.ActorID, "Weapon", "None")
		local mergedMotionControllerData = ActorUtil.MergeMotionControllerData(controllerMain, controllerInteract)

		actorFactory = ActorUtil.BuildActorFactoryByInfoRole(infoRole, mergedMotionControllerData)
	elseif motionDataPath then
		local c1 = ActorUtil.MotionControllerDataFilter(infoRole.data.ActorID, motionDataPath, "None")

		actorFactory = ActorUtil.BuildActorFactoryByInfoRole(infoRole, c1)
	else
		actorFactory = ActorUtil.BuildActorFactoryByInfoRole(infoRole, controllerMain)
	end

	actorFactory:Cache()

	self.actorFactory = actorFactory

	ResourceMgr.EndSubmit()
end

function DlgPreviewActor:LoadCardFittingActors(infoRole, Controls, inforolesCount)
	for i = 1, #infoRole do
		if infoRole[i] then
			LoadingMgr.Show(eLoadingType.Repeat)
			ResourceMgr.BeginSubmit(function()
				self:OnAsyncPrecacheActorCardFittingFinishs(i, Controls, self.actorFunc, inforolesCount)
			end)

			self.offz = 0.162

			local actorData = infoRole[i].actorData
			local avatarSettingsPath = {}

			if not infoRole[i].pb.clothes or #infoRole[i].pb.clothes == 0 then
				for i, _avatarId in ipairs(actorData.DefaultAvatars) do
					table.insert(avatarSettingsPath, AvatarData[_avatarId].AvatarPath)
				end
			else
				for n = 1, #infoRole[i].pb.clothes do
					table.insert(avatarSettingsPath, AvatarData[infoRole[i].pb.clothes[n]].AvatarPath)
				end
			end

			local actorFactory = ActorFactory(actorData.Comment, actorData.SkeletonPrefab, actorData.ScaleSettingsAsset, avatarSettingsPath, "Actors/AnimationController/Common@CardFitting", actorData.FacialSettingsAsset, actorData.EyeSettingsAsset, actorData.VowelSettingsAsset, "Actors/Settings/ExpressionEffectSettings/1001", "Actors/Animations/Actor/Interact/" .. infoRole[i].id)

			actorFactory:Cache()

			self.actorFactorys[i] = actorFactory

			ResourceMgr.EndSubmit()
		end
	end
end

function DlgPreviewActor:OnAsyncPrecacheActorCardFittingFinishs(i, Controls, callback, inforolesCount, poseList)
	local actor = self.actorFactorys[i]:Build()

	actor:Create()

	local g = actor.Root

	g.name = g.name .. "(clone)"
	self.actorsName[i] = g.name
	self.actors[i] = actor

	GOUtil.SetGameObjectLayer(g, LayerMask.NameToLayer("RT"))
	GOUtil.SetTransformLocalPosition(g, -2.4 + i * 0.8, 2, modelPosZ[i])
	GOUtil.SetTransformRotation(g, 0, 180, 0)

	local RTCamera = GameObject.Find("RTCamera")
	local c = GOUtil.GetComponent(RTCamera, "Camera")
	local devHeight = 1080
	local devWidth = 1920
	local aspectRatio = Screen.width * 1 / Screen.height

	if aspectRatio > devWidth / devHeight then
		local fieldOfView = 30

		c.fieldOfView = fieldOfView
	else
		local fieldOfView = 30 / (devHeight / devWidth * aspectRatio)

		c.fieldOfView = fieldOfView
	end

	GOUtil.SetTransformPosition(RTCamera, 0, 3, -4.64)
	GOUtil.SetTransformRotation(RTCamera, 0, 0, 0)

	local Camera = GOUtil.GetComponent(RTCamera, "Camera")

	Camera.orthographic = true
	Camera.orthographicSize = 1.3
	self.UI3DActorRotates[i] = UI3DActorRotate()

	self.UI3DActorRotates[i]:Init(Controls[i])

	local animator = GOUtil.FindChildComponent(g, "Model", "Animator")
	local tempPose = GetConfigArgJson("CombatTeamPose")

	animator:CrossFade(tempPose[i], 0)

	self.UI3DActorRotates[i].actor = g
	self.UI3DActorRotates[i].posStart = 0

	if self.cb then
		self.cb()

		self.cb = nil
	end

	LoadingMgr.Hide(eLoadingType.Repeat)
end

function DlgPreviewActor:OnAsyncPrecacheActorFinish()
	local actor = self.actorFactory:Build()

	self.actor = actor

	actor:Create()

	local g = actor.Root

	GOUtil.SetGameObjectLayer(g, LayerMask.NameToLayer("RT"))
	GOUtil.SetTransformLocalPosition(g, 0, self.offx, self.offy)
	GOUtil.SetTransformRotation(g, 0, 180, 0)

	if IsNil(self.RTCamera) then
		self.RTCamera = GameObject.Find("RTCamera")
	end

	actor.ExpressionSystem:FocusAt(self.RTCamera.transform)
	actor.ExpressionSystem:GazeAt(self.RTCamera.transform)

	local GoPlane = GameObject.Find("Plane")

	if GoPlane then
		local p = g.transform.localPosition

		GOUtil.SetTransformPosition(GoPlane, p.x, p.y, p.z)
	end

	self:ChangeView()

	self.UI3DActorRotate.actor = g
	self.UI3DActorRotate.posStart = 0

	if self.cb then
		self.cb()

		self.cb = nil
	end

	if self.needRandomIdle then
		self:OnRandomIdle()
	end

	LoadingMgr.Hide(eLoadingType.Repeat)
end

function DlgPreviewActor:ChangeView()
	if IsNil(self.RTCamera) then
		return
	end

	local z = 0

	if not self.isRTCameraFar then
		z = 1.45

		GOUtil.SetTransformRotation(self.RTCamera, 3, 0, 0)
	else
		z = 0.162

		GOUtil.SetTransformRotation(self.RTCamera, 6, 0, 0)
	end

	GOUtil.SetTransformPosition(self.RTCamera, 0, 1.3, z)
end

function DlgPreviewActor:OnRegisterEvent()
	Event.Instance:Add("OnAddRandomIdle", self.AddRandomIdle, self)
	Event.Instance:Add("OnRemoveRandomIdle", self.RemoveRandomIdle, self)
	Event.Instance:Add("DealWithPreviewActorRandomIdle", self.DealWithRandomIdle, self)
end

function DlgPreviewActor:OnUnRegisterEvent()
	Event.Instance:Remove("OnAddRandomIdle", self.AddRandomIdle, self)
	Event.Instance:Remove("OnRemoveRandomIdle", self.RemoveRandomIdle, self)
	Event.Instance:Remove("DealWithPreviewActorRandomIdle", self.DealWithRandomIdle, self)
	self:RemoveRandomIdle()
end

local function getRandomIdleTime()
	local sec = Mathf.Random(GetConfigArgInt("RandomIdleMinTime"), GetConfigArgInt("RandomIdleMaxTime"))

	return 10
end

function DlgPreviewActor:AddRandomIdle()
	self:RemoveRandomIdle()

	self.RandomIdelTimer = TimerMgr.AddTimer(eTimerType.ScaleTime, getRandomIdleTime(), self.OnRandomIdle, self)
end

function DlgPreviewActor:OnRandomIdle()
	if self.actor == nil then
		return
	end

	if self.actor.MotionSystem == nil or not self.actor.MotionSystem.IsState then
		return
	end

	self.event = InfoRole.GetDaySection()

	PlayAnim(self.event, self.actor, self.infoRole)
	self:AddRandomIdle()
end

function DlgPreviewActor:RemoveRandomIdle()
	if self.RandomIdelTimer then
		TimerMgr.RemoveTimer(self.RandomIdelTimer)

		self.RandomIdelTimer = nil
	end
end

function DlgPreviewActor:DealWithRandomIdle(isPause)
	if not self.needRandomIdle then
		return
	end

	if isPause then
		if self.infoRole then
			SoundMgr.UnloadBank(self.infoRole.data.VocalBank)
		end

		self:RemoveRandomIdle()
	else
		self:OnRandomIdle()
	end
end
