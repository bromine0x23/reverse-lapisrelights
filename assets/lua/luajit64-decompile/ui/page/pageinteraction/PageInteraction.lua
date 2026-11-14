-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageInteraction/PageInteraction.lua

require("UI/Page/PageInteraction/DlgFavorInfo")
require("UI/Page/PageFittingroom/PageFittingroom")
require("UI/Page/PageInteraction/PageStoryChapter")
require("UI/Page/PageInteraction/PageChildGift")
require("UI/Dlg/Public/DlgShare")

PageInteraction = class("PageInteraction", UIPanel, true)
PageInteraction.InteractIndex = 0

function PageInteraction:ctor()
	self.UIPrefabPath = "UI/PageInteraction/PageInteraction"
	self.touchHead = false
	self.touchChest = false
	self.dragHead = false
	self.dragChest = false
	self.fobidenTouch = false
	self.dlgExit = DlgExit()

	self:AddChildPanel(self.dlgExit, {
		panel = self,
		title = _("eReturn_Interact"),
		callback = self.OnBack,
		helpCallback = self.OnClickedBtnGuide,
		preCallback = self.PlayEndAnim
	})

	if CharacterThinMgr.needReset then
		CharacterThinMgr.DoResetOperate(CharacterThinMgr.ResetType.SKIP, CharacterThinMgr.roleID)

		CharacterThinMgr.needReset = false
	end

	self.DlgAssetsInfo = DlgAssetsInfo()

	self:AddChildPanel(self.DlgAssetsInfo)

	self.DlgFavorInfo = DlgFavorInfo()

	self:AddChildPanel(self.DlgFavorInfo)

	self.DlgCharacterThin = DlgCharacterThin(THIN_SYSTEM_TYPE.Role, THIN_PAGE_TYPE.Interac)

	self:AddChildPanel(self.DlgCharacterThin)
end

function PageInteraction:PreLoad()
	Event.Instance:Fire("UpdateSceneDisplay", true)
end

local function CheckSystemUnlock(system, noMsg)
	local isOpen = true

	if system ~= 0 then
		if not noMsg then
			isOpen = TutorialMgr:IsOpenTut(system)
		else
			isOpen = TutorialMgr:IsOpenNoMsg(system)
		end
	end

	return isOpen
end

function PageInteraction:OnEnter(data)
	UIMgr.ResetMsg2OffsetType(DlgMessage2OffType.default)

	local Text = self:GetChildComponent("Panel/BtnGroup/4/Text", "Text")

	Text.text = "AR"
	Text = self:GetChildComponent("Panel/BtnGroup/2/Text", "Text")
	Text.text = _("Desc_Mean")
	Text = self:GetChildComponent("Panel/BtnGroup/3/Text", "Text")
	Text.text = _("PageInteraction_Friendliness")
	Text = self:GetChildComponent("Panel/BtnGroup/1/Text", "Text")
	Text.text = _("eReturn_Gift")
	Text = self:GetChildComponent("Panel/BtnGroup/5/Text", "Text")
	Text.text = _("Desc_Avatar")
	Text = self:GetChildComponent("Panel/BtnGroup/6/Text", "Text")
	Text.text = _("Desc_RoleCardUp")
	Text = self:GetChildComponent("Panel/PanelAward/Text", "Text")
	Text.text = _("Desc_TouchAward")
	FriendMgr.PlayerInfoData = nil
	FriendMgr.IsExitOnPageFriend = false
	SceneMainStage.Instance.IsEnterInteraction = true

	Event.Instance:Fire(EventEnum.UpdateSceneObjectShow, true)
	FingerGesturesUtil.Enable()
	self.dlgExit.UIRootObject.transform:SetSiblingIndex(0)

	self.Panel = self:GetChildGameObject("Panel")
	self.timer = TimerMgr.AddTimer(eTimerType.RealTime, 1, function()
		SetActiveFunc(self.Panel, true)
	end, {})

	local index = data.index

	self.index = index
	self.data = data
	self.infoRole = data.infoRole

	self:InitData()
	SceneMainStage.Instance:ResetVC(0.4)

	local bId = 0

	if index then
		bId = index
	end

	PageInteraction.InteractIndex = index
	self.GoArrow = self:GetChildGameObject("Panel/Arrow")
	self.BtnLeft = self:GetChildGameObject("Panel/Arrow/BtnLeft")
	self.BtnRight = self:GetChildGameObject("Panel/Arrow/BtnRight")
	self.HeartGroup = self:GetChildGameObject("Panel/HeartGroup")
	self.ButtonGroup = self:GetChildGameObject("Panel/BtnGroup")
	self.ButtonPage = self:GetChildGameObject("Panel/AreaClickPow")

	SetActiveFunc(self.ButtonPage, false)

	self.BtnShare = self:GetChildGameObject("Panel/BtnShare")
	self.BtnShareOut = self:GetChildGameObject("Panel/BtnShare/ButtonShare")
	self.Hand = self:GetChildGameObject("Panel/HandPanel")
	self.isShowHand = false
	self.TextLeftCount = self:GetChildComponent("Panel/HandPanel/TextNum", "Text")
	self.PanelLeftTime = self:GetChildGameObject("Panel/HandPanel/TextTime")
	self.TextLeftTime = self:GetChildComponent("Panel/HandPanel/TextTime", "Text")
	self.ButtonAddLeftCount = self:GetChildGameObject("Panel/HandPanel/Button")

	self:NotifyUpdate()
	self:NotifyUpdateTouchRecoverTime()

	self.TextFill = self:GetChildComponent("Panel/HeartGroup/ImageHeartBar/Text", "Text")
	self.ImageFill = self:GetChildComponent("Panel/HeartGroup/ImageHeartBar/Image", "Image")
	self.TouchProgressTarget = self.ImageFill.fillAmount
	self.LookAtPoint = GOUtil.NewGameObject("LookAtPoint", nil)
	self.FollowPoint = GOUtil.NewGameObject("FollowPoint", nil)
	self.SmoothDampPoint = GOUtil.AddComponent(self.FollowPoint, "SmoothDampPoint")

	self.SmoothDampPoint:SmoothDamp(self.LookAtPoint.transform, 0.3)

	self.actor = SceneMainStage.Instance.curActor
	index = SceneMainStage.Instance:GetPosIndex(self.infoRole.id)

	if index == 0 then
		index = 1
	end

	self.data.index = index
	self.index = index
	self.actorGo = SceneMainStage.Instance.ActorLocations[index].gameObject

	local camera = SceneMainStage.Instance.UnityCamera

	self.transCamera = camera.transform
	self.actorMotion = self.actor.MotionSystem

	self.DlgFavorInfo:Init(self.infoRole, self.actor, self.index)
	GOUtil.AttachUIGameObject(self.DlgFavorInfo.UIRootObject, self.Panel)
	self.DlgFavorInfo.UIRootObject.transform:SetSiblingIndex(6)

	self.ButtonAward = self:GetChildGameObject("Panel/PanelAward")
	self.TextAwardNum = self:GetChildComponent("Panel/PanelAward/TextNum", "Text")
	self.listTouchIdolReward = GetConfigArgJson("TouchIdolReward")

	self:UpdateTouchAward()

	self.BtnGiftImage = self:GetChildGameObject("Panel/GiftImage")

	self:UpdateButton()

	self.GroupBtn = self:GetChildGameObject("GroupBtn")

	SetActiveFunc(self.GroupBtn, false)

	self.Btn1 = self:GetChildGameObject("GroupBtn/Group/1")
	self.Btn2 = self:GetChildGameObject("GroupBtn/Group/2")
	self.Btn3 = self:GetChildGameObject("GroupBtn/Group/3")

	for i = 1, 6 do
		self["Group_btn" .. i] = self:GetChildGameObject("Panel/BtnGroup/" .. i .. "/btn")
		self["Group_btn_sel" .. i] = self:GetChildGameObject("Panel/BtnGroup/" .. i .. "/Sel")
		self["Group_btn_lock" .. i] = self:GetChildGameObject("Panel/BtnGroup/" .. i .. "/Lock")
	end

	SetActiveFunc(self["Group_btn_lock" .. 1], not CheckSystemUnlock(TutorialFunctionType.Gift, true))

	if data.initMotion and not self.infoRole:HasGift() then
		Event.Instance:Fire(EventEnum.PlayVoice, data.initMotion)
	end

	if data.tag then
		LoadingMgr.Show(eLoadingType.Repeat)
		TimerMgr.AddTimer(eTimerType.RealTime, 0.1, function()
			LoadingMgr.Hide(eLoadingType.Repeat)

			if data.tag == 1 and not self.infoRole:HasGift() then
				self:OnClickedButtonGift()
			elseif data.tag == 2 and not self.infoRole:HasGift() then
				self:OnClickedButtonStory()
			end

			data.tag = nil
		end, {
			1
		})
	end

	self.fobidenTouch = true

	if InstructionMgr.hidePageInteract then
		self:HidePanel()
		self.actor:ResetBehaviour()
		PlayAnim(eInterctAnimType.idle, self.actor, self.infoRole)
	else
		self.actor:ResetBehaviour()
		self.actor.MotionSystem:FaceAtImmediate(nil)

		if not self.infoRole:HasGift() then
			PlayAnim(InfoRole.GetDaySection(), self.actor, self.infoRole)
		end
	end

	Event.Instance:Fire("SetVcFieldOfView", {
		isNear = true,
		index = self.index
	})
	SceneMainStage.Instance:ResetVC(0.5)
	self:UpdateGiftPop()
	self:UpdateDotNotify()
	DlgShare.UpdateData(self.BtnShareOut)
end

function PageInteraction:InitData()
	self:UpdateListRole()
end

function PageInteraction:UpdateListRole()
	local listRole = CharacterThinMgr.SwitchData(THIN_SYSTEM_TYPE.Role).roles

	SetActiveFunc(self.GoArrow, table.getn(listRole) > 1)
end

function PageInteraction:HidePanel()
	SetActiveFunc(self.DlgAssetsInfo.UIRootObject, false)
	SetActiveFunc(self.ButtonGroup, false)
	SetActiveFunc(self.DlgFavorInfo.UIRootObject, false)
	SetActiveFunc(self.dlgExit.UIRootObject, false)
	SetActiveFunc(self.Hand, false)
	SetActiveFunc(self.GoArrow, false)
	SceneMainStage.Instance:ResetVC(0.5)

	self.FX_UI_FavorHand = self:GetChildGameObject("Panel/FX_UI_FavorHand")

	SetActiveFunc(self.FX_UI_FavorHand, true)
	SetActiveFunc(self.DlgCharacterThin.UIRootObject, false)
end

function PageInteraction:UpdateTouchAward()
	local curAwardNum = #self.listTouchIdolReward - InfoGameInst.gameInfo.touchDailyNum

	if curAwardNum < 0 then
		curAwardNum = 0
	end

	self.TextAwardNum.text = curAwardNum .. "/" .. #self.listTouchIdolReward
end

function PageInteraction:UpdateServerRefresh()
	InfoGameInst.gameInfo.touchDailyNum = 0

	self:UpdateTouchAward()
end

function PageInteraction:NotifyShowDlgExit(isShow)
	SetActiveFunc(self.dlgExit.UIRootObject, isShow)
	SetActiveFunc(self.FX_UI_FavorHand, false)
end

function PageInteraction:UpdateGiftPop()
	local hasGift = self.infoRole:HasGift()

	if not hasGift and self.infoRole.data.AvatarTempId > 0 then
		self:EquipAvatar(self.infoRole.data.AvatarTempId, true)
	end

	self:OnClickedPop()
end

function PageInteraction:UpdateButton()
	local isDressOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Dress)
	local imgBtn1 = self:GetChildComponent("Panel/BtnGroup/3", "Image")
	local gray1 = TenaryOp(isDressOpen, 0, 1)

	UIUtil.SetImageGray(imgBtn1, gray1)

	local isGiftOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Gift)
	local imgBtn2 = self:GetChildComponent("Panel/BtnGroup/1", "Image")
	local gray2 = TenaryOp(isGiftOpen, 0, 1)

	UIUtil.SetImageGray(imgBtn2, gray2)
end

function PageInteraction:OnRegisterEvent()
	self:AddClick(self.ButtonAward, self.OnClickedButtonAward)
	self:AddClick(self.ButtonAddLeftCount, self.OnClickedButtonAddLeftCount)
	self:AddClick(self.BtnShare, self.OnClickedBtnShare)
	self:AddClick(self.BtnShareOut, self.OnClickedBtnShareOut)
	self:AddClick(self.Btn1, self.OnClickedBtnVREntry)
	self:AddClick(self.Btn2, self.OnClickedBtnVREntry)
	self:AddClick(self.Btn3, self.OnClickedBtnVREntry)
	self:AddClick(self.GroupBtn, self.OnClickedBtnVREntryClose, PATH_SFX_UI_CANCEL)
	self:AddClick(self.BtnGiftImage, self.OnClickGetGift)
	self:AddClick(self.BtnLeft, self.OnClickedBtnRoleL)
	self:AddClick(self.BtnRight, self.OnClickedBtnRoleR)

	for i = 1, 6 do
		self:AddClick(self["Group_btn" .. i], self.OnClickGroupBtn)
	end

	Event.Instance:Add(EventEnum.UpdateFavorTouch, self.NotifyUpdate, self)
	EventListenerMgr.AddFingerGestureListener(self.OnDrag, self, eFingerGestureType.Drag)
	EventListenerMgr.AddFingerListener(self.OnDown, self, eFingerEventType.Down)
	EventListenerMgr.AddFingerListener(self.OnUp, self, eFingerEventType.Up)
	EventListenerMgr.AddFingerGestureListener(self.OnTap, self, eFingerGestureType.Tap)
	Event.Instance:Add("ShowDlgExit", self.NotifyShowDlgExit, self)
	Event.Instance:Add(EventEnum.UpdateFavorTouchRecoverTime, self.NotifyUpdateTouchRecoverTime, self)
	Event.Instance:Add(EventEnum.UpdateItemDataNotify, self.UpdateItemDataNotify, self)
	Event.Instance:Add("UpdateServerRefresh", self.UpdateServerRefresh, self)
	Event.Instance:Add("UpdateShowCharacter", self.UpdateRole, self)
end

function PageInteraction:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonAward, self.OnClickedButtonAward)
	self:RemoveClick(self.ButtonAddLeftCount, self.OnClickedButtonAddLeftCount)
	self:RemoveClick(self.BtnShare, self.OnClickedBtnShare)
	self:RemoveClick(self.BtnShareOut, self.OnClickedBtnShareOut)
	self:RemoveClick(self.Btn1, self.OnClickedBtnVREntry)
	self:RemoveClick(self.Btn2, self.OnClickedBtnVREntry)
	self:RemoveClick(self.Btn3, self.OnClickedBtnVREntry)
	self:RemoveClick(self.GroupBtn, self.OnClickedBtnVREntryClose)
	self:RemoveClick(self.BtnGiftImage, self.OnClickGetGift)
	self:RemoveClick(self.BtnLeft, self.OnClickedBtnRoleL)
	self:RemoveClick(self.BtnRight, self.OnClickedBtnRoleR)

	for i = 1, 6 do
		self:RemoveClick(self["Group_btn" .. i], self.OnClickGroupBtn)
	end

	Event.Instance:Remove(EventEnum.UpdateFavorTouch, self.NotifyUpdate, self)
	EventListenerMgr.RemoveFingerGestureListener(self.OnDrag, self, eFingerGestureType.Drag)
	EventListenerMgr.RemoveFingerListener(self.OnDown, self, eFingerEventType.Down)
	EventListenerMgr.RemoveFingerListener(self.OnUp, self, eFingerEventType.Up)
	EventListenerMgr.RemoveFingerGestureListener(self.OnTap, self, eFingerGestureType.Tap)
	Event.Instance:Remove("ShowDlgExit", self.NotifyShowDlgExit, self)
	Event.Instance:Remove(EventEnum.UpdateFavorTouchRecoverTime, self.NotifyUpdateTouchRecoverTime, self)
	Event.Instance:Remove(EventEnum.UpdateItemDataNotify, self.UpdateItemDataNotify, self)
	Event.Instance:Remove("UpdateServerRefresh", self.UpdateServerRefresh, self)
	Event.Instance:Remove("UpdateShowCharacter", self.UpdateRole, self)
end

function PageInteraction:OnClickedBtnShare()
	require("UI/Dlg/Public/DlgShare")

	local camera = GOUtil.GetComponent(SceneMainStage.Instance.UnityCamera, "Camera")
	local go = GameObject.Find("ClickEffectMountNode")

	if not IsNil(go) then
		go:SetActive(false)
	end

	SetActiveFunc(self.UIRootObject, false)

	local function cb()
		SetActiveFunc(self.UIRootObject, true)
		UIMgr.HideMsg2()
		SetActiveFunc(UIMgr.UIPopupObject, true)

		if not IsNil(go) then
			go:SetActive(true)
		end
	end

	Event.Instance:Fire("CloseDlgShare")
	MiscUtil.CaptureRenderTexture(function(t2d)
		UIMgr.AddPanel(DlgShare(), {
			texture = t2d,
			callback = cb
		})
	end)
end

function PageInteraction:OnClickedBtnShareOut()
	local camera = GOUtil.GetComponent(SceneMainStage.Instance.UnityCamera, "Camera")
	local go = GameObject.Find("ClickEffectMountNode")

	if not IsNil(go) then
		go:SetActive(false)
	end

	SetActiveFunc(self.UIRootObject, false)

	local function cb()
		UIMgr:HideBlock()
		SetActiveFunc(self.UIRootObject, true)
		UIMgr.HideMsg2()
		SetActiveFunc(UIMgr.UIPopupObject, true)

		if not IsNil(self.BtnShareOut) then
			self.BtnShareOut:SetActive(true)
		end

		if not IsNil(go) then
			go:SetActive(true)
		end
	end

	Event.Instance:Fire("CloseDlgShare")
	MiscUtil.CaptureRenderTexture(function(t2d)
		UIMgr.AddPanel(DlgShare(), {
			texture = t2d,
			callback = cb,
			GoBtnShare = self.BtnShareOut
		})
	end)
end

function PageInteraction:OnClickedButtonAward()
	require("UI/Page/PageInteraction/DlgTouchAward")
	UIMgr.AddPanel(DlgTouchAward(), {}, self.UIRootObject)
end

function PageInteraction:OnClickedBtnVREntry(data)
	if WebCamTexture.devices.Length == 0 and Application.isEditor == false or Application.platform:ToInt() == RuntimePlatform.Android and not CheckeARSupport.HasCameraPermission() then
		UIMgr.ShowArPremission(DlgCommonEvent.Type.Msg, _("ARMode_Checking"))

		return
	end

	local go = data.pointerPress
	local index = tonumber(go.name)

	PageInteraction.jumpARIndex = index

	InfoBGMEventMgr:Clear()
	SceneMgr.LoadScene("AR", {
		infoRole = self.infoRole,
		index = index
	})
end

function PageInteraction:OnClickedBtnVREntryClose()
	SetActiveFunc(self.GroupBtn, false)
	SetActiveFunc(self.DlgFavorInfo.GoImageBar, false)

	self.uiTabIndex = 0

	self:UpdateGroupBtn(0)
end

function PageInteraction:DlgRoleHeartUpdatePanel(rId)
	self.infoRole = RoleMgr:GetRole(rId)
	self.data.infoRole = self.infoRole

	SceneMainStage.Instance:ChangeActor(self.index, rId, function()
		self.index = PageInteraction.InteractIndex

		self.DlgFavorInfo:RefreshRole(self.infoRole, SceneMainStage.Instance.actor, self.index)

		self.actor = SceneMainStage.Instance.curActor

		self:UpdateGiftPop()
	end)
end

function PageInteraction:EquipAvatar(id, isTemp)
	LoadingMgr.Show(eLoadingType.Repeat)

	local actor = self.actor
	local avatarFactory

	ResourceMgr.BeginSubmit(function()
		LoadingMgr.Hide(eLoadingType.Repeat)

		if actor then
			actor.SkeletonSystem:SetSrpingBoneEnabled(false)

			local part = avatarFactory:Build()

			actor.AvatarSystem:PutOn(part)

			local g = actor.Root

			GOUtil.SetGameObjectLayer(g, LayerMask.NameToLayer("Actor"))

			if isTemp then
				part:SetVisible(false)

				local gEmoji = GameObject.Find("Maryberry_Emoji_UI")

				if gEmoji then
					gEmoji:SetActive(false)
				end
			end
		end
	end)

	avatarFactory = ActorUtil.BuildAvatarFactory(id, self.infoRole.id)

	avatarFactory:Cache()
	ResourceMgr.EndSubmit()
end

function PageInteraction:UnEquipAvatar(listSlot)
	local slot = GetAvatarSlot(listSlot)
	local actor = self.actor

	actor.SkeletonSystem:SetSrpingBoneEnabled(false)
	actor.AvatarSystem:TakeOff(slot)
end

function PageInteraction:OnClickedPop()
	if self.infoRole:HasGift() then
		local r = self.infoRole:GetNextMotionLevel(eFavorMotionType.sendGift)

		if globalInterAniState == "idleState" then
			self.actorMotion:FaceAt(nil)

			length = self.actorMotion:GetAnimLength("Body@SendGift0" .. r + 1)
		else
			length = self.actorMotion:GetAnimLength("Body@SendGift0" .. r + 1)
		end

		self:EquipAvatar(self.infoRole.data.GiftBox)

		globalInterAniState = "idleState"

		self.actor.MotionSystem:CrossFade("Idle", 0.1)
		self.actor:ResetBehaviour()
		PlayAnim(eInterctAnimType.readySendGiftToPlayer, self.actor, self.infoRole)

		self.fobidenTouch = true

		SetActiveFunc(self.BtnShare, false)
		SetActiveFunc(self.ButtonAward, false)
		self:ShowGiftPanel(false)
		SetActiveFunc(self.BtnGiftImage, true)
	else
		self:OpenFavorUnlock()
	end
end

function PageInteraction:OnBack()
	self:UnEquipAvatar({
		"Temp"
	})

	SceneMainStage.Instance.OpenFromRole = false

	FingerGesturesUtil.Enable()
	UIMgr.PopPanel()
end

function PageInteraction:PlayEndAnim(cb)
	FingerGesturesUtil.Disable()
	cb(1)
end

function PageInteraction:UpdateItemDataNotify()
	self:UpdateGroupBtn(0)
end

function PageInteraction:OnClickGroupBtn(data)
	local go = data.pointerPress.transform.parent.gameObject

	self:UpdateGroupBtn(tonumber(go.name))
end

function PageInteraction:UpdateGroupBtn(index, data)
	if index ~= 3 and self["Group_btn_sel" .. 3].activeSelf then
		self.DlgFavorInfo:OnClickHeart()
	end

	for i = 1, 6 do
		if self["Group_btn_sel" .. i].activeSelf and index == i then
			SetActiveFunc(self["Group_btn_sel" .. i], false)
		else
			SetActiveFunc(self["Group_btn_sel" .. i], index == i)
		end
	end

	Event.Instance:Fire("DlgStoryAwardHide")

	if self.PageChildGift then
		self.PageChildGift:Init(false, nil)
	end

	if self.PageStoryChapter then
		self.PageStoryChapter:Init(false, nil)
	end

	SetActiveFunc(self.DlgFavorInfo.FavorUnlock, false)
	SetActiveFunc(self.DlgFavorInfo.GoImageInfo, true)
	SetActiveFunc(self.DlgFavorInfo.GoImageBar, true)
	SetActiveFunc(self.GroupBtn, false)

	self.uiTabIndex = false

	self.DlgFavorInfo:UpdateShowFavorLevelBtn(self["Group_btn_sel" .. 3].activeSelf)

	if index == 1 then
		if not CheckSystemUnlock(TutorialFunctionType.Gift, true) then
			SetActiveFunc(self["Group_btn_lock" .. 1], not CheckSystemUnlock(TutorialFunctionType.Gift, false))
			SetActiveFunc(self["Group_btn_sel" .. 1], false)

			return
		end

		self.data.actor = self.actor
		self.data.index = PageInteraction.InteractIndex

		if not self.PageChildGift then
			self.PageChildGift = PageChildGift()

			UIMgr.AddPanel(self.PageChildGift, {
				DlgFavorInfo = self.DlgFavorInfo
			})
		end

		SetActiveFunc(self.DlgFavorInfo.GoImageInfo, true)
		self.PageChildGift:Init(self["Group_btn_sel" .. 1].activeSelf, self.data)
		SetActiveFunc(self.DlgFavorInfo.GoImageBar, true)

		self.uiTabIndex = 1
	elseif index == 2 then
		self.data.actor = self.actor
		self.data.openVoical = false

		if data then
			self.data = data

			if data.tabIndex then
				self.data.tabIndex = data.tabIndex
			end
		else
			self.data.tabIndex = 3
		end

		self.data.index = PageInteraction.InteractIndex

		if not self.PageStoryChapter then
			self.PageStoryChapter = PageStoryChapter()

			UIMgr.AddPanel(self.PageStoryChapter)
		end

		self.PageStoryChapter:Init(self["Group_btn_sel" .. 2].activeSelf, self.data)

		if self["Group_btn_sel" .. 2].activeSelf then
			SetActiveFunc(self.DlgFavorInfo.GoImageInfo, false)
			SetActiveFunc(self.DlgFavorInfo.GoImageBar, false)
		end

		self.uiTabIndex = 2
	elseif index == 3 then
		SetActiveFunc(self.DlgFavorInfo.GoImageInfo, true)
		SetActiveFunc(self.DlgFavorInfo.GoImageBar, not self["Group_btn_sel" .. 3].activeSelf)
		SetActiveFunc(self.DlgFavorInfo.FavorUnlock, not self["Group_btn_sel" .. 3].activeSelf)
		self.DlgFavorInfo:OnClickHeart()

		self.uiTabIndex = 3
	elseif index == 4 then
		if self["Group_btn_sel" .. 4].activeSelf then
			local ARChecker = self:GetChildComponent("Panel/BtnGroup/4", "CheckeARSupport")

			ARChecker:StartCheck(function()
				UIMgr.ShowArPremission(DlgCommonEvent.Type.Msg, _("ARMode_Checking"))
			end)
		end

		self.Btn1:SetActive(true)
		SetActiveFunc(self.DlgFavorInfo.GoImageBar, true)

		self.uiTabIndex = 4
	elseif index == 5 then
		require("UI/Page/PageFittingroom/PageFittingroom")
		UIMgr.SwitchPanel(PageFittingroom)
	elseif index == 6 then
		local panel = UIMgr.GetPrePanel()

		if panel.className == "PageRole" then
			self:OnBack()
		else
			require("UI/Page/PageRole/PageRole")
			UIMgr.SwitchPanel(PageRole)
		end
	end

	if index == 0 or index == 4 or not self["Group_btn_sel" .. index].activeSelf then
		GOUtil.SetRectTransformAnchoredPosition(self.GoArrow, 0, 140)
		GOUtil.SetRectTransformAnchoredPosition(self.Hand, 0, 140)
		SetActiveFunc(self.BtnShare, true)
	else
		if index == 5 or index == 6 then
			return
		end

		GOUtil.SetRectTransformAnchoredPosition(self.GoArrow, -200, 140)
		GOUtil.SetRectTransformAnchoredPosition(self.Hand, -200, 140)
		SetActiveFunc(self.BtnShare, false)
	end
end

function PageInteraction:OnClickedButtonGift()
	self:UpdateGroupBtn(1)
end

function PageInteraction:OnClickedButtonStory()
	self.data.tabIndex = 1

	self:UpdateGroupBtn(2, self.data)
end

function PageInteraction:OnClickedButtonVoice()
	UIMgr.ShowMsg(Localization("Desc_Item_Not_Open"))
end

function PageInteraction:OnClickedButtonPhotoGraphy()
	UIMgr.ShowMsg(Localization("Desc_Item_Not_Open"))
end

function PageInteraction:Purge()
	PageInteraction.base.Purge(self)

	if self.timer ~= nil then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end

	if self.timer2 ~= nil then
		TimerMgr.RemoveTimer(self.timer2)

		self.timer2 = nil
	end

	if self.timerHideMsg ~= nil then
		TimerMgr.RemoveTimer(self.timerHideMsg)

		self.timerHideMsg = nil
	end

	if self.LookAtPoint then
		GameObject.Destroy(self.LookAtPoint)
	end

	if self.FollowPoint then
		GameObject.Destroy(self.FollowPoint)
	end

	if self.PageChildGift and not self.PageChildGift.closed then
		self.PageChildGift:Close()

		self.PageChildGift = nil
	end

	if self.PageStoryChapter and not self.PageStoryChapter.closed then
		self.PageStoryChapter:Close()

		self.PageStoryChapter = nil
	end

	SceneMainStage.Instance.IsEnterInteraction = false

	if UIMgr:GetCurPanel().className ~= "PageMainStage" then
		Event.Instance:Fire("UpdateSceneDisplay", false)
	end

	FavorMgr.ShowFavorUnlock = false

	ResourceMgr.Unload(self.PrefabCellStoryChapter)

	globalInterSoundEvent = nil
	globalInterSoundBank = nil
	SceneMainStage.Instance.OpenFromRole = false

	SceneMainStage.Instance:DestroyNewRole()
	Event.Instance:Fire("CloseDlgShare")
end

function PageInteraction:LookAt(gesture)
	if self.isEnd then
		return
	end

	if self.SmoothDampPoint == nil then
		return
	end

	self.actor.ExpressionSystem:GazeAt(self.FollowPoint.transform)
	self.actor.MotionSystem:FaceAt(self.FollowPoint.transform)
	self:MoveLookPoint(gesture)
	self.SmoothDampPoint:Reset(self.LookAtPoint.transform.position)
end

function PageInteraction:OnDown(gesture)
	self.isEnd = false

	if gesture.Selection ~= nil then
		if gesture.Selection.tag == "Head" then
			if not self.fobidenTouch then
				self.touchHead = true
			end
		elseif gesture.Selection.tag == "Body" and not self.fobidenTouch then
			self.touchBody = true
		end
	end
end

function PageInteraction:OnDrag(gesture)
	if self.touchHead then
		if not self.fobidenTouch then
			if not self.dragHead then
				self.actor.MotionSystem:FaceAt(nil)
				PlayAnim(eInterctAnimType.touchHead, self.actor, self.infoRole)
			end

			self.dragHead = true
			self.TouchProgressTarget = Mathf.Clamp(self.TouchProgressTarget + gesture.DeltaMove.magnitude * 0.001, 0, 1)
		end
	elseif self.touchChest and (self.fobidenTouch or true) then
		-- block empty
	elseif globalInterAniState == "idleState" then
		self:LookAt(gesture)
	end
end

function PageInteraction:MoveLookPoint(gesture)
	self.LookAtPoint.transform.position = self.transCamera.position + self.transCamera.right * (gesture.Position.x - Screen.width / 2) * 0.01 + self.transCamera.up * (gesture.Position.y - Screen.height / 2) * 0.01 + -(self.transCamera.forward * 10)
end

function PageInteraction:OnEnd()
	self.TouchProgressTarget = 0
	self.touchHead = false
	self.touchChest = false
	self.dragHead = false
	self.dragChest = false
	self.isEnd = true

	self.actor.ExpressionSystem:GazeAt(SceneMainStage.Instance.UnityCamera.transform)
	self.actor.MotionSystem:FaceAt(nil)
end

function PageInteraction:OnUp(gesture)
	if self.dragHead then
		print("draghead out")
		PlayAnim(eInterctAnimType.idle, self.actor, self.infoRole)
	elseif self.dragChest then
		-- block empty
	end

	if globalInterAniState == "idleState" and not self.actorMotion:IsInTransition() then
		self.fobidenTouch = false
	else
		self.fobidenTouch = true
	end

	self:OnEnd()
end

function PageInteraction:OnTap(gesture)
	if gesture.Selection ~= nil then
		if gesture.Selection.tag == "Head" then
			if not self.fobidenTouch then
				self.actor.MotionSystem:FaceAt(nil)

				self.fobidenTouch = true

				PlayAnim(eInterctAnimType.tapHead, self.actor, self.infoRole)
				InstructionMgr:TriggerWait("TouchHead")

				InstructionMgr.hidePageInteract = false
			end
		elseif gesture.Selection.tag == "Body" and not self.fobidenTouch then
			self.actor.MotionSystem:FaceAt(nil)

			self.fobidenTouch = true

			PlayAnim(eInterctAnimType.tapBody, self.actor, self.infoRole)
		end
	end
end

function PageInteraction:NotifyUpdate()
	self.TextLeftCount.text = InfoGameInst.gameInfo.touchCnt
end

function PageInteraction:NotifyUpdateTouchRecoverTime(second)
	local showPanel = not FavorMgr.Instance:IsFull()

	if showPanel and second then
		local strMinute = Mathf.Floor(second / 60)
		local strSecond = second - strMinute * 60

		if strMinute < 10 then
			strMinute = "0" .. strMinute
		end

		if strSecond < 10 then
			strSecond = "0" .. strSecond
		end

		self.TextLeftTime.text = strMinute .. ":" .. strSecond
	end

	SetActiveFunc(self.PanelLeftTime, showPanel)
end

local touchSeCount = 0

function PageInteraction:OnUpdate()
	if self.ImageFill == nil then
		return
	end

	local fill = self.ImageFill.fillAmount

	if Mathf.Abs(fill - self.TouchProgressTarget) > 0.0001 then
		self.ImageFill.fillAmount = Mathf.Lerp(fill, self.TouchProgressTarget, Time.deltaTime * 5)
		self.TextFill.text = math.ceil(fill * 100) .. "%"
	end

	if self.ImageFill.fillAmount > 0.98 then
		self.ImageFill.fillAmount = 0
		self.TouchProgressTarget = 0
		self.TextFill.text = "%"

		if InstructionMgr.hidePageInteract or InfoGameInst.gameInfo.touchCnt <= 0 then
			InstructionMgr.hidePageInteract = false

			if self.DlgFavorInfo and not self.DlgFavorInfo.FavorUnlock.activeSelf then
				Event.Instance:Fire(EventEnum.UpdateFavorTouch)
			end

			PlayAnim(eInterctAnimType.getFavor, self.actor, self.infoRole)
			self:OnEnd()

			self.fobidenTouch = true

			InstructionMgr:TriggerWait("TouchHead")
		else
			SoundMgr.Play(PATH_SFX_UI_TOUCHHEAD_DONE)
			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:RequestGetFavor(self.infoRole.id, function(msg, setter)
				LoadingMgr.Hide(eLoadingType.Repeat)

				if msg.result.code == 0 then
					if self.infoRole.curFavorLevel >= self.infoRole.maxFavorLevel then
						PlayAnim(eInterctAnimType.getFavor, self.actor, self.infoRole)

						if self.DlgFavorInfo and not self.DlgFavorInfo.FavorUnlock.activeSelf then
							Event.Instance:Fire(EventEnum.UpdateFavorTouch)
						else
							self:NotifyUpdate()
						end
					else
						if self.DlgFavorInfo and not self.DlgFavorInfo.FavorUnlock.activeSelf then
							Event.Instance:Fire(EventEnum.UpdateFavorTouch)
						else
							self:NotifyUpdate()
						end

						local preFavorLv = setter.preFavorLevel
						local curFavorLv = setter.curFavorLevel

						self.infoRole:UpdatePreFavorExp()

						if preFavorLv < curFavorLv then
							local preFavorIndex = RoleMgr:GetFavorSectionIndex(preFavorLv)
							local curFavorIndex = RoleMgr:GetFavorSectionIndex(curFavorLv)

							Event.Instance:Fire("FavorLevelUp")

							if preFavorIndex < curFavorIndex then
								PlayAnim(eInterctAnimType.rankup, self.actor, self.infoRole)
							else
								PlayAnim(eInterctAnimType.levelup, self.actor, self.infoRole)
							end
						else
							PlayAnim(eInterctAnimType.getFavor, self.actor, self.infoRole)
						end

						self.DlgFavorInfo:PlayFavorHeartAnimation2(setter.list[1].num)
					end

					self:UpdateTouchAward()
					self:OnEnd()

					self.fobidenTouch = true
				else
					UIMgr.ShowMsg(msg.result.desc, msg)
				end
			end)
		end
	end

	if self.ImageFill.fillAmount > 0.02 and self.touchHead then
		SetActiveFunc(self.HeartGroup, true)

		touchSeCount = touchSeCount + 1

		if touchSeCount % 10 == 1 then
			self.preFillAmount = self.preFillAmount or 0

			if self.ImageFill.fillAmount > self.preFillAmount then
				SoundMgr.Play(PATH_SFX_UI_TOUCHHEAD_UP)
			end
		end

		self.preFillAmount = self.ImageFill.fillAmount
	elseif self.ImageFill.fillAmount <= 0.02 then
		SetActiveFunc(self.HeartGroup, false)
	end

	if globalInterAniState == "idleState" and not self.actorMotion:IsState("idleState") and not self.actorMotion:IsInTransition() then
		self.fobidenTouch = false
	end
end

function PageInteraction:DealWithFavorAward()
	if self.infoRole:HasFavorAward() then
		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestGetFavorAward(self.infoRole.id, function(msg)
			LoadingMgr.Hide(eLoadingType.Repeat)
			self.infoRole:UpdateFavorAward()
		end)
	end
end

function PageInteraction:OnClickedButtonAddLeftCount()
	local MaxLimit = GetConfigArgInt("TouchMaxNumber")

	if MaxLimit > InfoGameInst.gameInfo.touchCnt then
		local needNum = GetConfigArgInt("FullTouchNumberDiamond")

		local function OnCallback(index)
			if index == 1 then
				LoadingMgr.Show(eLoadingType.Repeat)
				NetManager:RequestResetFavorTouchCount(function(pb)
					LoadingMgr.Hide(eLoadingType.Repeat)

					if pb.result.code == 0 then
						Event.Instance:Fire(EventEnum.UpdateFavorTouch)
						Event.Instance:Fire(EventEnum.UpdateFavorTouchRecoverTime)
					else
						UIMgr.ShowMsg(pb.result.desc, pb)
					end
				end)
			end
		end

		local str = string.format(_("Desc_BuyHitHeadTimes"), needNum)

		local function showTip()
			UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Tittle_Affirm"), {
				isDiamond = true,
				text = str
			}, OnCallback, _("Button_Yes"), _("Button_No"), true)
		end

		CheckPayDiamond(needNum, str, OnCallback, showTip)
	else
		UIMgr.ShowMsg(_("DESC_FULLCOUNT"))
	end
end

function PageInteraction:SkipToVocal()
	self.data.tabIndex = 2

	self:UpdateGroupBtn(2, self.data)
end

function PageInteraction:OnClickGetGift()
	if globalInterAniState ~= "sendGiftToPlayer" then
		return
	end

	SetActiveFunc(self.BtnGiftImage, false)
	SetActiveFunc(self.BtnShare, true)
	SetActiveFunc(self.ButtonAward, true)

	local preLevel = self.infoRole.pb.favorLevelRecord

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestGetRoleGift(self.infoRole.id, function(msg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if msg.result.code == NetManager.Result_Sucess then
			self.infoRole:UpdateFavorAward(msg.favorLevelRecord)
			self:UnEquipAvatar({
				"Temp"
			})

			if self.infoRole.data.AvatarTempId > 0 then
				self:EquipAvatar(self.infoRole.data.AvatarTempId, true)
			end

			self:ShowGiftPanel(true)
			self.infoRole:UpdateFavorSkill(preLevel, self.infoRole.pb.favorLevelRecord)
			PlayAnim(eInterctAnimType.idle, self.actor, self.infoRole)
		else
			UIMgr.ShowMsg(msg.result.desc, msg)
		end
	end)
end

function PageInteraction:OnClickedBtnRoleL()
	self:OnNext(false)
end

function PageInteraction:OnClickedBtnRoleR()
	self:OnNext(true)
end

function PageInteraction:OnNext(isRight)
	UIMgr.ResetMsg2OffsetType(DlgMessage2OffType.default)

	local _type = isRight and eDirectionType.R or eDirectionType.L

	CharacterThinMgr.DOSwitch(THIN_SYSTEM_TYPE.Role, _type)
end

function PageInteraction:UpdateRole(infoRole)
	self.infoRole = infoRole

	Event.Instance:Fire("UpdateAddLevelGift", true, infoRole.id)
	self:DlgRoleHeartUpdatePanel(infoRole.id)
	self:UpdateGroupBtn(0)
	self:UpdateListRole()
	self:UpdateDotNotify()
	RoleRDL.NewRDL.SubNewRolePlayerPrefs(infoRole)
end

function PageInteraction:OpenFavorUnlock()
	return
end

function PageInteraction:ShowGiftPanel(isShow)
	SetActiveFunc(self.ButtonGroup, isShow)
	SetActiveFunc(self.DlgFavorInfo.UIRootObject, isShow)
	SetActiveFunc(self.Hand, isShow)
	SetActiveFunc(self.GoArrow, isShow)
	SetActiveFunc(self.DlgCharacterThin.UIRootObject, isShow)
end

function PageInteraction:UpdateDotNotify()
	if not self.GetedObject then
		self.GetedObject = true
		self.ButtonStory = self:GetChildGameObject("Panel/BtnGroup/2")
		self.ButtonVR = self:GetChildGameObject("Panel/BtnGroup/4")
	end

	RedDotSystemMgr.SetUIRedDot(self.ButtonVR, "Role/" .. self.infoRole.id .. "/Interact/AR")
	RedDotSystemMgr.SetUIRedDot(self.ButtonStory, "Role/" .. self.infoRole.id .. "/Interact/Information")
end

function PageInteraction:OnClickedBtnGuide()
	require("UI/Dlg/Public/GuideChooseTip")
	UIMgr.AddPanel(GuideChooseTip(), {
		guideType = "InteractionGuide"
	})
end

function PageInteraction:OnBackAndroid()
	if self.DlgCharacterThin and not IsNil(self.DlgCharacterThin.GoClick) and GOUtil.IsActiveSelf(self.DlgCharacterThin.GoClick) then
		self.DlgCharacterThin:OnClickBack()

		return true
	end

	if self.GroupBtn and not IsNil(self.GroupBtn) and GOUtil.IsActiveSelf(self.GroupBtn) then
		self:OnClickedBtnVREntryClose()

		return true
	end

	return false
end
