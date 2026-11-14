-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Scene/SceneFittingRoom.lua

require("Scene/SceneBase")
require("UI/Page/PageFittingroom/PageFittingroom")
require("UI/Page/PageVote/PageVote")
require("UI/Page/PageVote/PagePartRank")
require("UI/Page/PageVote/PageVoteTheme")
require("UI/Page/PageVote/PageTotalRank")
require("UI/Page/PageVote/PageDevoteRank")
require("UI/Page/PageVote/PageVoteLadyGod")

SceneFittingRoom = class("SceneFittingRoom", SceneBase, true)

function SceneFittingRoom:ctor(...)
	self.name = "aaa"
	self.bottemFrame = nil
	self.activeAR = true
	self.charXRotate = Vector3.New(0, 0, 0)
	self.charYRotate = Vector3.New(0, 0, 0)
	self.charCanRotate = true
	self.LookAtPoint = nil
	self.FollowPoint = nil
end

function SceneFittingRoom:Init(vParam)
	SceneFittingRoom.base.Init(self)

	self.charId = vParam.charId
	self.data = vParam
end

function SceneFittingRoom:LoadScene()
	self.SceneName = "FittingRoom"

	SceneFittingRoom.base.LoadScene(self)
end

function SceneFittingRoom:OnCache()
	self.CameraController = CameraMgr.Instance:CreatePrefabStaticCameraCtrl()

	self.CameraController:Cache("Camera/Camera Positions Fittingroom")

	self.CharacterGroup = {}
	self.CharacterGroup.MiniGO = GOUtil.NewGameObject("Mini Character_" .. self.charId, nil)
	self.CharacterGroup.MiniCharacter = GOUtil.AddComponent(self.CharacterGroup.MiniGO, "Character")

	CharacterMgr:Cache(self.charId, self.CharacterGroup.MiniCharacter, false, "MotionsQ")

	self.CharacterGroup.StandardGO = GOUtil.NewGameObject("Standard Character_" .. self.charId, nil)
	self.CharacterGroup.StandardCharacter = GOUtil.AddComponent(self.CharacterGroup.StandardGO, "Character")

	CharacterMgr:Cache(self.charId, self.CharacterGroup.StandardCharacter, true, "Motions")
end

function SceneFittingRoom:OnPurge()
	if self.CharacterGroup.MiniGO then
		GameObject.Destroy(self.CharacterGroup.MiniGO)
	end

	if self.CharacterGroup.StandardGO then
		GameObject.Destroy(self.CharacterGroup.StandardGO)
	end

	self.CharacterGroup = nil
	self.CameraController = nil

	SceneFittingRoom.base.OnPurge(self)
end

function SceneFittingRoom:OnSceneLoaded()
	CreateDlgInScene(PageFittingroom.GetInstance(), self.data)
	self.CameraController:Create()
	self.CharacterGroup.MiniCharacter:Create()
	self.CharacterGroup.MiniCharacter.motionSystem:PlayMotion("StandIdle")

	self.CharacterGroup.MiniCharacter.transform.position = Vector3(1.7, 1.1, -1.5)
	self.CharacterGroup.MiniCharacter.transform.eulerAngles = Vector3(0, 0, 0)
	self.CharacterGroup.MiniCharacter.transform.localScale = Vector3(0.8, 0.8, 0.8)

	self.CharacterGroup.StandardCharacter:Create()
	self.CharacterGroup.StandardCharacter.motionSystem:PlayMotion("StandIdle")

	self.CharacterGroup.StandardCharacter.transform.position = Vector3(0.35, 0, 5)
	self.CharacterGroup.StandardCharacter.transform.eulerAngles = Vector3(0, 0, 0)

	self.CharacterGroup.StandardCharacter.lockEye:LockTarget(self.CameraController.controlledCamera.transform)
	self.CharacterGroup.StandardCharacter.lockHead:LockTarget(self.CameraController.controlledCamera.transform)

	local colliderTrans = self.CharacterGroup.StandardCharacter.transform
	local boxCllider = GOUtil.AddMissingComponent(colliderTrans.gameObject, "BoxCollider")

	boxCllider.center = Vector3(0, 0.85, 0)
	boxCllider.size = Vector3(0.6, 1.5, 0.6)
	self.bottemFrame = GOUtil.NewGameObject("MiniBottemFrame", nil)

	local sr = GOUtil.AddComponent(self.bottemFrame, "SpriteRenderer")

	UIUtility.SetSpriteRenderer(sr, "UIDyAtlas/Mist/ui_bg_charplat_02")

	self.bottemFrame.transform.localScale = Vector3(0.4, 0.4, 0)
	self.bottemFrame.transform.localPosition = Vector3(1.72, 1.05, -1.87)

	local gestures = GameObject.Find("Gestures")

	self.ScreenRaycaster = GOUtil.AddMissingComponent(gestures, "ScreenRaycaster")

	GOUtil.AddMissingComponent(gestures, "TapRecognizer")

	self.LookAtPoint = GOUtil.NewGameObject("LookAtPoint", nil)
	self.FollowPoint = GOUtil.NewGameObject("FollowPoint", nil)
	self.SmoothDampPoint = GOUtil.AddComponent(self.FollowPoint, "SmoothDampPoint")

	self.SmoothDampPoint:SmoothDamp(self.LookAtPoint.transform, 0.3)

	local character = self.CharacterGroup.StandardCharacter

	character.lockEye:Unlock()
	character.lockHead:Unlock()
end

function SceneFittingRoom.CreateInstance()
	if not SceneFittingRoom.Instance then
		SceneFittingRoom.Instance = SceneFittingRoom()
	end

	return SceneFittingRoom.Instance
end

function SceneFittingRoom.DestroyInstance()
	SceneFittingRoom.Instance = nil
end

function SceneFittingRoom:OnRegisterEvent(...)
	SceneFittingRoom.base.OnRegisterEvent(self, ...)
	Event.Instance:Add("EventOnDragEvent", self.OnHandleEventOnDragEvent, self)
	Event.Instance:Add(EventEnum.FittingroomChangePart, self.OnHandleChangePart, self)
	Event.Instance:Add(EventEnum.FittingroomChangeMultiPart, self.OnHandleChangeMultiPart, self)
	Event.Instance:Add(EventEnum.FittingroomRestoreCamera, self.OnHandleRestoreCamera, self)
	Event.Instance:Add(EventEnum.FittingroomActiveAR, self.OnHandleActiveAR, self)
	Event.Instance:Add(EventEnum.FittingroomRemovePart, self.OnHandleRemovePart, self)
	Event.Instance:Add(EventEnum.FittingroomDragItem, self.OnHandleDragItem, self)
end

function SceneFittingRoom:OnUnRegisterEvent(...)
	SceneFittingRoom.base.OnUnRegisterEvent(self, ...)
	Event.Instance:Remove("EventOnDragEvent", self.OnHandleEventOnDragEvent, self)
	Event.Instance:Remove(EventEnum.FittingroomChangePart, self.OnHandleChangePart, self)
	Event.Instance:Remove(EventEnum.FittingroomChangeMultiPart, self.OnHandleChangeMultiPart, self)
	Event.Instance:Remove(EventEnum.FittingroomRestoreCamera, self.OnHandleRestoreCamera, self)
	Event.Instance:Remove(EventEnum.FittingroomActiveAR, self.OnHandleActiveAR, self)
	Event.Instance:Remove(EventEnum.FittingroomRemovePart, self.OnHandleRemovePart, self)
	Event.Instance:Remove(EventEnum.FittingroomDragItem, self.OnHandleDragItem, self)
end

function SceneFittingRoom:OnHandleDragItem(_data)
	self.charCanRotate = not _data.IsDrag

	local character = self.CharacterGroup.StandardCharacter

	if not self.charCanRotate then
		self.SmoothDampPoint:Reset(character.transform.position + Vector3(0, 1.4, 100))

		if character.motionSystem.CurrentMotionType == "StandIdle" or not character.motionSystem.CurrentMotion.isPlaying then
			character.lockEye:LockTarget(self.FollowPoint.transform)
			character.lockHead:LockTarget(self.FollowPoint.transform)
		end
	else
		character.lockEye:Unlock()
		character.lockHead:Unlock()
	end
end

function SceneFittingRoom:OnHandleEventOnTapEvent(vGesture, clickedObj)
	if not self.activeAR then
		return
	end

	if clickedObj == nil then
		return
	end
end

function SceneFittingRoom:OnHandleEventOnDragEvent(vGesture)
	if UIUtility.IsPointerOverUIObject() then
		return
	end

	if not self.charCanRotate then
		local character = self.CharacterGroup.StandardCharacter

		self.LookAtPoint.transform.position = character.transform.position + Vector3(-(vGesture.Position.x - Screen.width * 0.25) * 0.1, 1.35 + (vGesture.Position.y - Screen.height * 0.75) * 0.1, 100)

		return
	end

	if self.activeAR then
		local fingerCount = MxUtil.GetDownFingerCount()

		if vGesture.Recognizer.RequiredFingerCount == 1 and fingerCount == 1 then
			self:HandleDragRotate(vGesture.DeltaMove)
		end
	end
end

function SceneFittingRoom:HandleDragRotate(deltaMove)
	if self.CharacterGroup.StandardCharacter == nil then
		return
	end

	local sCharTrans = self.CharacterGroup.StandardCharacter.transform
	local xRotate = sCharTrans.localEulerAngles
	local yRotate = sCharTrans:GetChild(0).localEulerAngles
	local xAxisChangeValue = 5
	local yAxisChangeValue = 40

	if deltaMove.x < 0 then
		local curValue = yRotate.y

		yRotate.y = yRotate.y + yAxisChangeValue
	elseif deltaMove.x > 0 then
		if yRotate.y <= 0 then
			yRotate.y = yRotate.y + 360
			sCharTrans:GetChild(0).localEulerAngles = yRotate
		end

		local curValue = yRotate.y

		yRotate.y = yRotate.y - yAxisChangeValue
	end

	self.charYRotate = yRotate

	if deltaMove.y < 0 then
		xRotate.x = xRotate.x + xAxisChangeValue
	elseif deltaMove.y > 0 then
		xRotate.x = xRotate.x - xAxisChangeValue
	end

	xRotate.x = Mathf.Clamp(xRotate.x, 0, 20)
	self.charXRotate = xRotate
end

function SceneFittingRoom:OnHandleFingerDownEvent(vFingerEvent, vTouchObj)
	if not vTouchObj or vTouchObj.tag == "Head" then
		-- block empty
	elseif vTouchObj.tag == "Chest" then
		-- block empty
	end
end

function SceneFittingRoom:OnHandleFingerUpEvent(vFingerEvent, vTouchObj)
	return
end

function SceneFittingRoom:OnHandleChangePart(avatarId)
	LoadingMgr.Show(eLoadingType.Repeat)
	MxResMgr.Instance:BeginSubmitCB(nil, function()
		self:OnAsyncLoadAllFinish1()
	end)
	self.CharacterGroup.StandardCharacter:CacheAvatars({
		avatarId
	}, true)
	self.CharacterGroup.MiniCharacter:CacheAvatars({
		avatarId
	}, false)
	MxResMgr.Instance:EndSubmit()
end

function SceneFittingRoom:OnAsyncLoadAllFinish1()
	LoadingMgr.Hide(eLoadingType.Repeat)
	self.CharacterGroup.StandardCharacter.avatarSystem:Create()
	self.CharacterGroup.StandardCharacter.motionSystem:PlayMotionRecoverOnComplete("Change", "StandIdle")
	self.CharacterGroup.MiniCharacter.avatarSystem:Create()
	CreateEffect(self.CharacterGroup.StandardCharacter.gameObject, PE_CHANGE_AVATAR)
end

function SceneFittingRoom:OnHandleChangeMultiPart(listAvatarId)
	LoadingMgr.Show(eLoadingType.Repeat)
	MxResMgr.Instance:BeginSubmitCB(nil, function()
		self:OnAsyncLoadAllFinish2()
	end)
	self.CharacterGroup.StandardCharacter:CacheAvatars(listAvatarId, true)
	self.CharacterGroup.MiniCharacter:CacheAvatars(listAvatarId, false)
	MxResMgr.Instance:EndSubmit()
end

function SceneFittingRoom:OnAsyncLoadAllFinish2()
	LoadingMgr.Hide(eLoadingType.Repeat)
	self:OnHandleRemoveAll(true)
	self:OnHandleRemoveAll(false)
	self.CharacterGroup.StandardCharacter.avatarSystem:Create()
	self.CharacterGroup.StandardCharacter.motionSystem:PlayMotionRecoverOnComplete("Change", "StandIdle")
	self.CharacterGroup.MiniCharacter.avatarSystem:Create()
	CreateEffect(self.CharacterGroup.StandardCharacter.gameObject, PE_CHANGE_AVATAR)
end

function SceneFittingRoom:OnHandleRemovePart(avatarSlot)
	self.CharacterGroup.MiniCharacter.avatarSystem:TakeOff(avatarSlot)
	self.CharacterGroup.StandardCharacter.avatarSystem:TakeOff(avatarSlot)
end

function SceneFittingRoom:OnHandleRemoveAll(isStandardChar)
	local indexTrinket = EnumUtil.ToInt("eAvatarSlot", tostring(eAvatarSlot.Trinket))
	local indexTail = EnumUtil.ToInt("eAvatarSlot", tostring(eAvatarSlot.Tail))

	if isStandardChar then
		for i = indexTrinket + 1, indexTail do
			local avatarSlot = TLIST_AVATARSLOT[i]

			self.CharacterGroup.StandardCharacter.avatarSystem:TakeOff(avatarSlot)
		end
	else
		for i = indexTrinket + 1, indexTail do
			local avatarSlot = TLIST_AVATARSLOT[i]

			self.CharacterGroup.MiniCharacter.avatarSystem:TakeOff(avatarSlot)
		end
	end
end

function SceneFittingRoom:OnHandleRestoreCamera(...)
	self:ResetCharState()
end

function SceneFittingRoom:OnHandleActiveAR(isActive)
	self.activeAR = isActive

	self:ResetCharState()

	self.CameraController.controlledCamera.enabled = isActive

	self.CharacterGroup.MiniCharacter.gameObject:SetActive(isActive)
	self.bottemFrame:SetActive(isActive)

	if isActive then
		self.CharacterGroup.StandardCharacter.transform.position = Vector3.New(0.35, 0, 5)

		self.CharacterGroup.MiniCharacter.motionSystem:PlayMotionForce("StandIdle")
	end
end

function SceneFittingRoom:ResetCharState()
	local mCharTrans = self.CharacterGroup.MiniCharacter.transform

	mCharTrans.localEulerAngles = Vector3.New(0, 0, 0)
	mCharTrans:GetChild(0).localEulerAngles = Vector3.New(0, 0, 0)
	self.charXRotate = Vector3.New(0, 0, 0)
	self.charYRotate = Vector3.New(0, 0, 0)
end

function SceneFittingRoom:OnARCharRotate(curYRotate)
	local mCharTrans = self.CharacterGroup.MiniCharacter.transform

	mCharTrans:GetChild(0).localEulerAngles = curYRotate
end

function SceneFittingRoom:Update()
	if not self.activeAR then
		return
	end

	if self.CharacterGroup == nil or self.CharacterGroup.StandardCharacter == nil then
		return
	end

	local sCharTrans = self.CharacterGroup.StandardCharacter.transform
	local curXRotate = sCharTrans.localEulerAngles
	local xDistance = Vector3.Distance(curXRotate, self.charXRotate)

	if xDistance > 0.001 then
		curXRotate = Vector3.Lerp(curXRotate, self.charXRotate, 10 * Time.deltaTime)
		sCharTrans.localEulerAngles = curXRotate
	end

	if sCharTrans.childCount > 0 then
		local curYRotate = sCharTrans:GetChild(0).localEulerAngles
		local yDistance = Vector3.Distance(curYRotate, self.charYRotate)

		if yDistance > 0.001 then
			curYRotate = Vector3.Lerp(curYRotate, self.charYRotate, 10 * Time.deltaTime)

			if self.charYRotate.y >= 360 and curYRotate.y >= 360 then
				self.charYRotate.y = self.charYRotate.y - 360
				curYRotate.y = curYRotate.y - 360
			elseif self.charYRotate.y < 0 and curYRotate.y < 0 then
				self.charYRotate.y = self.charYRotate.y + 360
				curYRotate.y = curYRotate.y + 360
			end

			sCharTrans:GetChild(0).localEulerAngles = curYRotate

			self:OnARCharRotate(curYRotate)
		end
	end
end
