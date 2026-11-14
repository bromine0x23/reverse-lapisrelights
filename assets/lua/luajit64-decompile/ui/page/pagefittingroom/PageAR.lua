-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFittingroom/PageAR.lua

require("UI/Dlg/DlgBase")
require("UI/Dlg/Common/DlgShare")
require("UI/Page/PageFittingroom/UIItemTakePhotoMotion")

PageAR = class("PageAR", PageBase)
MotionLockState = {
	UnClick = 2,
	UnLock = 0,
	FavorRankUnFit = 1
}

function PageAR:ctor()
	self.DlgShare = DlgShare()
end

function PageAR:Cache()
	self:SubmitUIPrefabCacheLua("UI/PageFittingroom/PageAR/PanelAR")
	MxResMgr.Instance:SubmitCacheLuaByType("Audio/Other/camara snap", self, "AudioClip", "AudioClip")
	MxResMgr.Instance:SubmitCacheLua("UI/PageFittingroom/PageAR/ItemTakePhotoMotion", self, "PrefabItemTakePhotoMotion")
	MxResMgr.Instance:SubmitCacheLua("Camera/ARCamera", self, "PrefabARCamera")
	self.DlgShare:Cache()
end

function PageAR:Purge()
	self.AudioClip = nil
	self.PrefabItemTakePhotoMotion = nil
	self.PrefabARCamera = nil

	self.DlgShare:Purge()

	self.DlgShare = nil

	PageAR.base.Purge(self)
end

function PageAR:OnPageLoaded()
	self.CurMotionIdx = -1

	self:TryDisableFog()
end

function PageAR:OnEnter(_data)
	self.charXRotate = Vector3.New(0, 0, 0)
	self.charYRotate = Vector3.New(0, 0, 0)
	self.CameraRootMinDistance = 0.67
	self.CameraRootMaxDistance = 4
	self.CameraNormaDistance = 1.2
	self.MotionListInitPos = nil
	self.MotionListTargetPos = Vector3.New(0, 50, 0)
	self.MoveTime = 0.5
	self.MotionPortraitWidth = 520
	self.MotionPortraitFontScale = Vector3.New(0.7, 0.7, 0.7)
	self.ScreenBtnDownScale = Vector3.New(1.1, 1.1, 1.1)
	self.Data = _data
	self.FromPage = _data.FromPage

	self:InitCharData()

	self.ARCameraRoot = GOUtil.InstantiatePrefab(self.PrefabARCamera, nil)

	if self.ARCameraRoot ~= nil then
		self.ARCamera = GOUtil.FindChildComponent(self.ARCameraRoot, "Camera", "Camera")
	end

	self.ScreenRaycaster = _data.ScreenRaycaster

	if self.ScreenRaycaster ~= nil then
		local cameraNum = self.ScreenRaycaster.Cameras.Count
		local own = false

		for i = 0, cameraNum - 1 do
			if self.ScreenRaycaster.Cameras:get_Item(i) == self.ARCamera then
				own = true

				break
			end
		end

		if not own then
			self.ScreenRaycaster.Cameras:Add(self.ARCamera)
		end
	end

	self.Null_ShareInfo = self:GetChildGameObject("Null_ShareInfo")
	self.Null_OtherInfo = self:GetChildGameObject("Null_OtherInfo")
	self.Img_PlayerIcon = self:GetChildComponent("Null_ShareInfo/Img_Bg/Img_PlayerIcon", "Image")
	self.Txt_Nick = self:GetChildComponent("Null_ShareInfo/Img_Bg/Txt_Nick", "Text")

	local char = CharacterMgr:GetCharacter(PlayerInst.InfoPlayer:GetShowRole())

	UIUtility.SetSprite(self.Img_PlayerIcon, PATH_CHAR_HEAD .. char:GetCharacterHeadIcon(), false)
	UIUtility.SetText(self.Txt_Nick, PlayerInst.InfoPlayer.name)

	self.BtnQuit = self:GetChildComponent("Null_OtherInfo/ButtonQuit", "Button")
	self.Btn_SwitchScreen = self:GetChildComponent("Null_OtherInfo/Null_FuncBtn/Btn_SwitchScreen", "Button")
	self.Btn_FixedSight = self:GetChildComponent("Null_OtherInfo/Null_FuncBtn/Btn_FixedSight", "Button")
	self.Btn_UnFixedSight = self:GetChildComponent("Null_OtherInfo/Null_FuncBtn/Btn_UnFixedSight", "Button")
	self.Btn_Screenshot = self:GetChildComponent("Null_OtherInfo/Btn_Screenshot", "Button")
	self.Btn_MotionList = self:GetChildComponent("Null_OtherInfo/Img_MotionList/Btn_MotionList", "Button")
	self.Btn_SwitchFrontCam = self:GetChildGameObject("Null_OtherInfo/Null_FuncBtn/Btn_SwitchFrontCam")
	self.Btn_SwitchRearCam = self:GetChildGameObject("Null_OtherInfo/Null_FuncBtn/Btn_SwitchRearCam")

	UIUtility.SetVisible(self.Btn_SwitchRearCam, false)

	self.IsBackCamera = true

	local img_DownEffect = self:GetChildGameObject("Null_OtherInfo/Btn_Screenshot/Img_DownEffect")
	local btnEffectComp = GOUtil.AddComponent(self.Btn_Screenshot.gameObject, "UIObjectInteractiveEffect")

	btnEffectComp.pointerDownActiveObjScale = self.ScreenBtnDownScale
	btnEffectComp.pointerDownActiveObj = img_DownEffect

	local txtDesc = self:GetChildComponent("Null_OtherInfo/Img_Desc/Txt_Desc", "Text")

	UIUtility.SetText(txtDesc, Localization.Get("DESC_AR_FUNC"))

	self.ScreenshotRt = GOUtil.GetComponent(self.Btn_Screenshot.gameObject, "RectTransform")
	self.AudioSource = nil
	self.Img_Bk = self:GetChildGameObject("Null_OtherInfo/Img_Bk")

	UIUtility.SetVisible(self.Img_Bk, false)

	self.CanvasScaler = GOUtil.GetComponent(MxUIMgr.Instance.RootCanvas, "CanvasScaler")
	self.ReferenceResolution = self.CanvasScaler.referenceResolution

	self:InitScrollView()
	self:HandleMovePanel()
	self:ResetCharState()
end

function PageAR:InitCharData()
	self.Character = self.Data.Character
	self.CharacterOriginalLayer = self.Character.gameObject.layer
	self.CharacterOriginalPos = self.Character.transform.position
	self.Character.transform.position = Vector3.New(0, 0, 0)

	local arLayer = LayerMask.NameToLayer("UI3DExRender")

	if arLayer ~= self.CharacterOriginalLayer then
		MxUtil.SetChildrenLayer(self.Character.gameObject, arLayer)
	end
end

function PageAR:OnLeave()
	self:CacelBlockHandle()

	self.Null_ShareInfo = nil
	self.Null_OtherInfo = nil
	self.Img_PlayerIcon = nil
	self.Txt_Nick = nil
	self.AudioSource = nil
	self.Img_MotionList = nil
	self.MotionListInitPos = nil
	self.MotionListTargetPos = nil
	self.MotionListSize = nil
	self.MotionOffsetMax = nil
	self.ScrollView = nil
	self.Btn_MotionList = nil
	self.ToggleGroup = nil
	self.Img_Bk = nil
	self.CanvasScaler = nil
	self.ReferenceResolution = nil
	self.RankNameConfig = nil
	self.InfoChar = nil
	self.ItemRootToItem = nil
	self.ItemContainer = nil

	if not IsNil(self.Character) then
		self.Character.motionSystem:PlayMotion("StandIdle")
	end

	self.ARCameraRoot = nil
	self.ARCamera = nil
	self.Character = nil
	self.Data = nil
	self.IsTouchUI = false
	self.Btn_SwitchFrontCam = nil
	self.Btn_SwitchRearCam = nil
	self.Screenshot = nil

	Event.Instance:Fire("CloseDlgShare")
end

function PageAR:Close(vParam)
	self:TryRecoverFogSetting()
	CloseDlgUI(self.DlgShare)
	PageAR.base.Close(self, vParam)
	ClearDlgMemory(PageAR.Instance)

	PageAR.Instance = nil
end

function PageAR:OnRegisterEvent()
	self:AutoRegistClick(self.BtnQuit.gameObject, self.OnBtnQuit)
	self:AutoRegistClick(self.Btn_SwitchScreen.gameObject, self.OnClickedSwitchScreenBtn)
	self:AutoRegistClick(self.Btn_FixedSight.gameObject, self.OnClickedFixedSightBtn)
	self:AutoRegistClick(self.Btn_UnFixedSight.gameObject, self.OnClickedUnFixedSightBtn)
	self:AutoRegistClick(self.Btn_Screenshot.gameObject, self.OnClickedScreenshotBtn)
	self:AutoRegistClick(self.Btn_MotionList.gameObject, self.OnClickedMotionListBtn)
	self:AutoRegistClick(self.Btn_SwitchFrontCam, self.OnClickedSwitchFrontCamBtn)
	self:AutoRegistClick(self.Btn_SwitchRearCam, self.OnClickedRearCamBtn)

	self.ScreenOrientation = ScreenOrientation.Landscape

	UIUtility.SetComponentVisible(self.Btn_UnFixedSight, false)
	self:AutoRegistClick(self.Img_Bk, self.OnClickedBk)
	Event.Instance:Add("EventOnDragEvent", self.OnHandleEventOnDragEvent, self)
	Event.Instance:Add("EventOnPinchEvent", self.OnHandlePinchEvent, self)
	Event.Instance:Add("EventFingerDownEvent", self.OnHandleFingerDownEvent, self)
end

function PageAR:OnUnRegisterEvent()
	Event.Instance:Remove("EventOnDragEvent", self.OnHandleEventOnDragEvent, self)
	Event.Instance:Remove("EventOnPinchEvent", self.OnHandlePinchEvent, self)
	Event.Instance:Remove("EventFingerDownEvent", self.OnHandleFingerDownEvent, self)
end

function PageAR:OnBtnQuit()
	if self.Quiting then
		return
	end

	if self.ScreenOrientation ~= ScreenOrientation.Landscape then
		ScreenUtil.SetOrientation(ScreenOrientation.Landscape)
		UIUtility.SetRTSize(self.Img_MotionList.rectTransform, self.MotionListSize)

		self.CanvasScaler.referenceResolution = self.ReferenceResolution
	end

	self.Quiting = true

	local function handleQuit()
		self:ResetCharState()

		if self.ARCameraRoot ~= nil then
			self.ScreenRaycaster.Cameras:Remove(self.ARCamera)
			GameObject.Destroy(self.ARCameraRoot, 0.2)

			self.ARCameraRoot = nil
			self.ScreenRaycaster = nil
			self.IsBackCamera = true
			self.ARCamera.enabled = false
			self.ARCamera = nil
		end

		Event.Instance:Fire(EventEnum.FittingroomActiveAR, true)

		if self.Data.NeedDestroyChar and self.Character then
			GameObject.Destroy(self.Character.gameObject)
		else
			self.Character.transform.position = self.CharacterOriginalPos

			MxUtil.SetChildrenLayer(self.Character.gameObject, self.CharacterOriginalLayer)
		end

		if SceneClassroom.Instance ~= nil then
			SceneClassroom.Instance:HandleGotoARUI(false)
		end

		PageSwitcher.Instance:Pop()
	end

	if not self.IsBackCamera then
		MxUtil.SetVuforiaCameraDir(Vuforia.CameraDevice.CameraDirection.CAMERA_BACK)

		self.IsBackCamera = true
	end

	MxCoroutineHelper.StartCoroutine(0.2, self.Mono, handleQuit)
end

function PageAR:OnClickedSwitchScreenBtn()
	if self.ScreenOrientation == ScreenOrientation.Landscape then
		UIUtility.SetRTSize(self.Img_MotionList.rectTransform, Vector2.New(self.MotionPortraitWidth, self.MotionListSize.y))

		self.CanvasScaler.referenceResolution = Vector2.New(self.ReferenceResolution.y, self.ReferenceResolution.x)
		self.ScreenOrientation = ScreenOrientation.Portrait
	elseif self.ScreenOrientation == ScreenOrientation.Portrait then
		UIUtility.SetRTSize(self.Img_MotionList.rectTransform, self.MotionListSize)

		self.CanvasScaler.referenceResolution = self.ReferenceResolution
		self.ScreenOrientation = ScreenOrientation.Landscape
	end

	ScreenUtil.SetOrientation(self.ScreenOrientation)

	if self.ScrollView ~= nil then
		self.ScrollView:SetViewBounds()
	end

	self:OnSwitchCameraOrScreenOrientation()
end

function PageAR:OnClickedFixedSightBtn()
	if self.Character ~= nil then
		self.Character.lockEye:Unlock()
	end

	UIUtility.SetComponentVisible(self.Btn_UnFixedSight, true)
	UIUtility.SetComponentVisible(self.Btn_FixedSight, false)
end

function PageAR:OnClickedUnFixedSightBtn()
	if self.Character ~= nil and self.ARCamera ~= nil then
		self.Character.lockEye:LockTarget(self.ARCamera.transform)
	end

	UIUtility.SetComponentVisible(self.Btn_UnFixedSight, false)
	UIUtility.SetComponentVisible(self.Btn_FixedSight, true)
end

function PageAR:OnClickedScreenshotBtn()
	self:PlayTakeAPictureAudio()
	UIUtility.SetVisible(self.Null_ShareInfo, true)
	UIUtility.SetVisible(self.Null_OtherInfo, false)

	self.Screenshot = GOUtil.AddComponent(self.UIRootObject, "Screenshot")

	function self.Screenshot.onShotFinished()
		UIUtility.SetVisible(self.Null_ShareInfo, false)
		UIUtility.SetVisible(self.Null_OtherInfo, true)
		self:ShowShareUI()
	end

	NetManager:SubmitClientAction(protocol_pb.TAKE_PHOTO, "", nil)
end

function PageAR:ShowShareUI()
	local param = {}

	param.RoleID = self.Character.ID
	param.Tex2D = self.Screenshot.screenshotTex2D
	param.ImgPath = self.Screenshot.genPath

	self:CreateAsChild(self.DlgShare, param)

	self.DlgShare.OnDlgClose[self] = self.OnShareUIClosed

	if self.ScreenOrientation == ScreenOrientation.Portrait then
		local panelSize = self.DlgShare:GetPanelSize()

		self.DlgShare:SetPanelSize(Vector2.New(panelSize.y, panelSize.x))

		local offsetMin = self.DlgShare.Img_Info.offsetMin
		local offsetMax = self.DlgShare.Img_Info.offsetMax

		UIUtility.SetRTOffsetMin(self.DlgShare.Img_Info, Vector2.New(offsetMin.y, offsetMin.x))
		UIUtility.SetRTOffsetMax(self.DlgShare.Img_Info, Vector2.New(offsetMax.y, offsetMax.x))
		self.DlgShare:SetRankDescScale(self.MotionPortraitFontScale)
	end
end

function PageAR:OnShareUIClosed(shareDlg)
	shareDlg[self] = nil

	GameObject.Destroy(self.Screenshot)

	self.Screenshot = nil

	Launcher:ClearMemory()
end

function PageAR:PlayTakeAPictureAudio()
	if self.AudioSource ~= nil then
		MxAudioMgr.Instance:StopSound(self.AudioSource)
	end

	self.AudioSource = MxAudioMgr.Instance:PlaySound(self.AudioClip, false, nil)
end

function PageAR:InitScrollView()
	self.Img_MotionList = self:GetChildComponent("Null_OtherInfo/Img_MotionList", "Image")
	self.MotionListInitPos = self.Img_MotionList.rectTransform.anchoredPosition3D
	self.MotionListSize = self.Img_MotionList.rectTransform.sizeDelta

	UIUtility.SetRTPos(self.Img_MotionList.rectTransform, self.MotionListTargetPos)

	self.Img_MotionList.enabled = false

	local svTrans = self:GetChildComponent("Null_OtherInfo/Img_MotionList/Img_ScrollView", "Transform")

	self.ScrollView = UIUtility.GetUIScrollView(svTrans, false, true)
	self.ToggleGroup = GOUtil.AddComponent(self.ScrollView.content.gameObject, "UIToggleGroupComponent")

	if self.ToggleGroup ~= nil then
		self.ToggleGroup:SetGroup("UIDyAtlas/SelectFrame/ui_bg_photoline_flash", false, function()
			self:OnSelectedMotionIcon()
		end)
	end

	self.InfoChar = CharacterMgr:GetCharacter(self.Character.ID)

	local motionCount = self.InfoChar.actorData.PoseMotions.Count

	self.RankNameConfig = DataManager.Instance:GetConfigJsonValue("FavorRankName")
	self.ItemRootToItem = Record()
	self.ItemContainer = Container()

	for i = 0, motionCount - 1 do
		local item = UIItemTakePhotoMotion(self.PrefabItemTakePhotoMotion, self.ScrollView.content.gameObject, self)

		item:Create()

		item.Index = i

		local motionData = DataManager.Instance:GetRecord_Lua("MotionData", self.InfoChar.actorData.PoseMotions:get_Item(i))
		local motionUnLockState = self:GetMotionUnLockState(i, motionData.ID)
		local strDesc = ""

		if motionUnLockState == MotionLockState.FavorRankUnFit then
			local index = self.InfoChar.data.PoseUnLockFavorRanks:get_Item(i) - 1

			if index < self.RankNameConfig.Count then
				strDesc = DataManager.Instance:GetLanguage(self.RankNameConfig:get_Item(index))
			end
		end

		item:SetItem("UIDyAtlas/Motion/" .. motionData.Icon, motionUnLockState, strDesc, motionData.Name:ToLanguage())

		local comp = GOUtil.AddMissingComponent(item.UIRootObject, "UIToggledComponent")

		comp.param = motionData
		comp.ownScrollView = self.ScrollView

		self:AutoRegistClick(item.UIRootObject, self.OnClickedItem)

		local scrollContent = GOUtil.AddComponent(item.UIRootObject, "UIScrollViewContent")

		scrollContent.scrollView = self.ScrollView
		item.MotionData = motionData

		self.ItemRootToItem:Set(item.UIRootObject, item)
		self.ItemContainer:Push(item)
	end

	self.MotionListState = "Out"
end

function PageAR:MoveIn()
	self.MoveFinish = false
	self.Img_MotionList.enabled = true

	local tweener = DG.Tweening.ShortcutExtensions46.DOAnchorPosY(self.Img_MotionList.rectTransform, self.MotionListInitPos.y, self.MoveTime, false)

	UIUtility.SetTweenerCallback(tweener, function()
		self.MotionListState = "In"

		UIUtility.SetVisible(self.Img_Bk, true)

		self.MoveFinish = true
	end)
end

function PageAR:MoveOut()
	self.MoveFinish = false

	local tweener = DG.Tweening.ShortcutExtensions46.DOAnchorPosY(self.Img_MotionList.rectTransform, self.MotionListTargetPos.y, self.MoveTime, false)

	UIUtility.SetTweenerCallback(tweener, function()
		self.MotionListState = "Out"
		self.MoveFinish = true
		self.Img_MotionList.enabled = false

		UIUtility.SetVisible(self.Img_Bk, false)
	end)
end

function PageAR:OnClickedMotionListBtn()
	if self.MotionListState == "Out" then
		self:MoveIn()
	elseif self.MotionListState == "In" then
		self:MoveOut()
	end
end

function PageAR:OnClickedItem(pointerData)
	if self.ScrollView:IsDragging() then
		return
	end

	local itemRoot = pointerData.pointerPress
	local item = self.ItemRootToItem:GetValue(itemRoot)

	if item == nil then
		return
	end

	local motionUnLockState = self:GetMotionUnLockState(item.Index, item.MotionData.ID)

	if motionUnLockState == MotionLockState.FavorRankUnFit then
		UIMgr.ShowMsg(Localization.Get("DESC_ThisPoseUnLock"))

		return
	end

	if motionUnLockState == MotionLockState.UnClick then
		PersistentStoreUtil.SetFavorMotionUnLock(self.InfoChar.id, item.MotionData.ID, 1)
		self:CreateUnLockEffect(item.UIRootObject.transform.position)
		item:SetLockBkVisible(false)
		item:SetName(item.MotionData.Name:ToLanguage())

		return
	end

	self:CacelBlockHandle()

	if self.Character ~= nil and not self.Character.motionSystem:ContainsMotion(item.MotionData.Type) then
		MxResMgr.Instance:BeginSubmitCB(nil, function()
			self.CacheBlockHandle = nil

			self.Character.motionSystem:Create()
			self:OnPose(item.MotionData.Type, item.Index)
		end)

		local motionData = DataManager.Instance:GetRecord_Lua("MotionData", item.MotionData.ID)
		local charData = CharacterFactory.CreateMotion(motionData, self.Character.motionSystem)

		self.Character.motionSystem:CacheMotion(charData)

		self.CacheBlockHandle = MxResMgr.Instance:EndSubmit()
	else
		self:OnPose(item.MotionData.Type, item.Index)
	end

	self:MoveOut()
end

function PageAR:CacelBlockHandle()
	if not IsNil(MxResMgr.Instance) and self.CacheBlockHandle ~= nil then
		MxResMgr.Instance:CancelCacheBlock(self.CacheBlockHandle)

		self.CacheBlockHandle = nil
	end
end

function PageAR:OnPose(motionType, posIdx)
	if self.Character ~= nil then
		self.Character.motionSystem:PlayMotionRecoverOnComplete(motionType, "StandIdle")
	end

	self.CurPlayPosIdx = posIdx
end

function PageAR:OnSelectedMotionIcon()
	if self.ScrollView:IsDragging() then
		return
	end

	local curSeletedComp = self.ToggleGroup.curToggledComp

	if curSeletedComp == nil then
		return
	end

	self.ToggleGroup.SelectedGo.transform:SetAsLastSibling()
end

function PageAR:OnClickedBk()
	self:MoveOut()
end

function PageAR:GetMotionUnLockState(motionIdx, motionID)
	if self.InfoChar == nil then
		return MotionLockState.UnLock
	end

	local curFavorRank = self.InfoChar:GetFavorRank()
	local needRank = 1

	if motionIdx < self.InfoChar.data.PoseUnLockFavorRanks.Count then
		needRank = self.InfoChar.data.PoseUnLockFavorRanks:get_Item(motionIdx)
	end

	if curFavorRank < needRank then
		return MotionLockState.FavorRankUnFit
	end

	if PersistentStoreUtil.FavorMotionIsUnLock(self.InfoChar.id, motionID) == 0 then
		return MotionLockState.UnClick
	end

	return MotionLockState.UnLock
end

function PageAR:CreateUnLockEffect(worldPos)
	local effect = MxFxMgr.Instance:Alloc(PATH_FX .. "Eff_UI_Support_Unlock/Eff_UI_Support_Unlock", nil, false)

	effect.transform.position = worldPos
end

function PageAR:HandleMovePanel()
	local duration = 0.5

	PlayReturnBtnMove(self.BtnQuit.gameObject, duration)

	local null_FuncBtn = self:GetChildGameObject("Null_OtherInfo/Null_FuncBtn")
	local moveComp = GOUtil.AddComponent(null_FuncBtn, "UIMoveByAxis")

	moveComp:SetParam(92, 0, duration, UIMoveByAxis.MoveAxis.Y)

	local img_Desc = self:GetChildGameObject("Null_OtherInfo/Img_Desc")

	moveComp = GOUtil.AddComponent(img_Desc, "UIMoveByAxis")

	moveComp:SetParam(60, -17, duration, UIMoveByAxis.MoveAxis.Y)

	moveComp = GOUtil.AddComponent(self.Btn_Screenshot.gameObject, "UIMoveByAxis")

	moveComp:SetParam(58, -70, duration, UIMoveByAxis.MoveAxis.X)

	moveComp = GOUtil.AddComponent(self.Img_MotionList.gameObject, "UIMoveByAxis")

	moveComp:SetParam(0, self.MotionListTargetPos.y, duration, UIMoveByAxis.MoveAxis.Y)
end

function PageAR:OnUpdate()
	if IsNil(self.Character) then
		return
	end

	local sCharTrans = self.Character.transform
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
		end
	end
end

function PageAR:ResetCharState()
	if self.Character == nil then
		return
	end

	local sCharTrans = self.Character.transform

	sCharTrans.localEulerAngles = Vector3.New(0, 0, 0)
	sCharTrans:GetChild(0).localEulerAngles = Vector3.New(0, 0, 0)
	self.charXRotate = Vector3.New(0, 0, 0)
	self.charYRotate = Vector3.New(0, 0, 0)
	sCharTrans.position = Vector3.New(0, 0, sCharTrans.position.z)

	if self.ARCamera ~= nil then
		self.Character.lockEye:LockTarget(self.ARCamera.transform)
	end
end

function PageAR:OnHandlePinchEvent(vGesture, vObj)
	if UIUtility.IsPointerOverUIObject() then
		return
	end

	if self.ARCameraRoot == nil then
		return
	end

	local position = self.ARCameraRoot.transform.position
	local zPos = Mathf.Clamp(position.z - vGesture.Delta * 0.01, self.CameraRootMinDistance, self.CameraRootMaxDistance)

	self.ARCameraRoot.transform.position = Vector3.New(position.x, position.y, zPos)
end

function PageAR:OnHandleEventOnDragEvent(vGesture)
	if UIUtility.IsPointerOverUIObject() then
		return
	end

	local fingerCount = MxUtil.GetDownFingerCount()

	if vGesture.Recognizer.RequiredFingerCount == 1 and fingerCount == 1 then
		self:HandleDragRotate(vGesture.DeltaMove)
	elseif vGesture.Recognizer.RequiredFingerCount == 2 and fingerCount == 2 then
		self:HandleTwoFingerMove(vGesture.DeltaMove)
	end
end

function PageAR:HandleDragRotate(deltaMove)
	if self.Character == nil then
		return
	end

	local sCharTrans = self.Character.transform
	local xRotate = sCharTrans.localEulerAngles
	local yRotate = sCharTrans:GetChild(0).localEulerAngles
	local xAxisChangeValue = 5
	local yAxisChangeValue = 40
	local factor = 1

	if not self.IsBackCamera then
		factor = -1
	end

	deltaMove.x = deltaMove.x * factor

	if deltaMove.x < 0 then
		local curValue = yRotate.y

		yRotate.y = yRotate.y + yAxisChangeValue

		if curValue < 100 and yRotate.y > 100 then
			yRotate.y = 100
		end
	elseif deltaMove.x > 0 then
		if yRotate.y <= 0 then
			yRotate.y = yRotate.y + 360
			sCharTrans:GetChild(0).localEulerAngles = yRotate
		end

		local curValue = yRotate.y

		yRotate.y = yRotate.y - yAxisChangeValue

		if curValue > 260 and yRotate.y < 260 then
			yRotate.y = 260
		end
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

function PageAR:HandleTwoFingerMove(deltaMove)
	if self.Character == nil then
		return
	end

	local factor = -1

	if not self.IsBackCamera then
		factor = 1
	end

	local moveFactor = self.ARCameraRoot.transform.position.z * 0.001
	local sCharTrans = self.Character.transform

	sCharTrans.position = sCharTrans.position + Vector3.New(moveFactor * deltaMove.x * factor, moveFactor * deltaMove.y, 0)
end

function PageAR:OnHandleFingerDownEvent()
	self.IsTouchUI = UIUtility.IsPointerOverUIObject()
end

function PageAR:OnClickedSwitchFrontCamBtn()
	UIUtility.SetVisible(self.Btn_SwitchFrontCam, false)
	UIUtility.SetVisible(self.Btn_SwitchRearCam, true)
	MxUtil.SetVuforiaCameraDir(Vuforia.CameraDevice.CameraDirection.CAMERA_FRONT)

	self.IsBackCamera = false

	self:OnSwitchCameraOrScreenOrientation()
end

function PageAR:OnClickedRearCamBtn()
	UIUtility.SetVisible(self.Btn_SwitchRearCam, false)
	UIUtility.SetVisible(self.Btn_SwitchFrontCam, true)
	MxUtil.SetVuforiaCameraDir(Vuforia.CameraDevice.CameraDirection.CAMERA_BACK)

	self.IsBackCamera = true

	self:OnSwitchCameraOrScreenOrientation()
end

function PageAR:OnSwitchCameraOrScreenOrientation()
	local platform = Application.platform
	local zRotate = 0

	if platform == UnityEngine.RuntimePlatform.IPhonePlayer and not self.IsBackCamera and self.ScreenOrientation == ScreenOrientation.Landscape then
		zRotate = 180
	elseif platform == UnityEngine.RuntimePlatform.Android and not self.IsBackCamera and self.ScreenOrientation == ScreenOrientation.Portrait then
		zRotate = 180
	end

	local trans = self.ARCameraRoot.transform
	local eulerAngles = trans.localEulerAngles

	trans.localEulerAngles = Vector3.New(eulerAngles.x, eulerAngles.y, zRotate)
end

function PageAR:TryDisableFog()
	self.IsFogEnable = RenderSettings.fog

	if self.IsFogEnable then
		RenderSettings.fog = false
	end
end

function PageAR:TryRecoverFogSetting()
	if not self.IsFogEnable then
		self.IsFogEnable = nil

		return
	end

	self.IsFogEnable = nil
	RenderSettings.fog = true
end

function PageAR.GetInstance()
	PageAR.Instance = PageAR.Instance or PageAR()

	return PageAR.Instance
end
