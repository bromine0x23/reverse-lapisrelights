-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCardShop/PageCardFittingRoom.lua

PageCardFittingRoom = class("PageCardFittingRoom", UIPanel)

local InfoTeam = require("Info.InfoTeam")

modelPosX = {
	-1.6,
	-0.8,
	0,
	0.8,
	1.6
}
modelPosZ = {
	0,
	0,
	0,
	0,
	0
}
fingerPos = {
	{
		-600,
		185
	},
	{
		-200,
		185
	},
	{
		150,
		185
	},
	{
		500,
		185
	},
	{
		850,
		185
	}
}

local enumPose = {
	Ani_Show_In = 6
}

function PageCardFittingRoom:ctor()
	PageCardFittingRoom.base.ctor(self, "UI/PageCardShop/PageCardFittingRoom")
	self:AddChildPanel(DlgExit(), {
		title = _("CardFittingRoom_Dressing"),
		callback = self.OnBack,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo(), {
		x = -600,
		y = -42
	})
end

function PageCardFittingRoom:Cache()
	PageCardFittingRoom.base.Cache(self)
end

function PageCardFittingRoom:PreLoad()
	self:LoadResAsync("UI/Common/DlgCommon/DlgLongTip", "DlgLongTip")
end

function PageCardFittingRoom:OnBack()
	UIMgr.PopPanel()
end

function PageCardFittingRoom:Purge()
	PageCardFittingRoom.base.Purge(self)

	if not self.timer then
		self.DlgPreviewActor.actorsName = {}

		self.DlgPreviewActor:Purge()

		RoleMgr.CardFittingUI3DActorRotate = false
		RoleMgr.CardFittingLongPress = false
	end

	if self.DlgLongTip then
		ResourceMgr.Unload(self.DlgLongTip)

		self.DlgLongTip = nil
	end
end

function PageCardFittingRoom:OnRegisterEvent()
	for i = 1, 5 do
		self:AddClick(self["btn_jump_go" .. i], self.OnClickedControl)
		self:AddListener(self["btn_jump_go" .. i], self.OnBeginDragCard, EventTriggerType.BeginDrag)
		self:AddListener(self["btn_jump_go" .. i], self.OnDownCard, EventTriggerType.PointerDown)
		self:AddListener(self["btn_jump_go" .. i], self.OnUpCard, EventTriggerType.PointerUp)
		self:AddListener(self["btn_jump_go" .. i], self.OnEndDragCard, EventTriggerType.EndDrag)
		self:AddListener(self["btn_jump_go" .. i], self.OnDragCard, EventTriggerType.Drag)
		self:AddListener(self["btn_jump_go" .. i], self.OnDragCardLongPress, EventTriggerType.PointerLongPress)
	end
end

function PageCardFittingRoom:OnUnRegisterEvent()
	for i = 1, 5 do
		self:RemoveClick(self["btn_jump_go" .. i], self.OnClickedControl)
		self:RemoveListener(self["btn_jump_go" .. i], self.OnBeginDragCard, EventTriggerType.BeginDrag)
		self:RemoveListener(self["btn_jump_go" .. i], self.OnDownCard, EventTriggerType.PointerDown)
		self:RemoveListener(self["btn_jump_go" .. i], self.OnUpCard, EventTriggerType.PointerUp)
		self:RemoveListener(self["btn_jump_go" .. i], self.OnEndDragCard, EventTriggerType.EndDrag)
		self:RemoveListener(self["btn_jump_go" .. i], self.OnDragCard, EventTriggerType.Drag)
		self:RemoveListener(self["btn_jump_go" .. i], self.OnDragCardLongPress, EventTriggerType.PointerLongPress)
	end
end

function PageCardFittingRoom:OnEnter(vParam)
	self.teamSystemAgent = vParam
	self.teamAgent = self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex]

	local rolelist = {}

	for i = 1, #self.teamAgent.slotList do
		if self.teamAgent.slotList[i].upInfoRoleCard then
			table.insert(rolelist, RoleCardMgr:GetRole(self.teamAgent.slotList[i].upInfoRoleCard.id))
		else
			table.insert(rolelist, false)
		end
	end

	self.roleList = rolelist
	self.Control = self:GetChildComponent("Role", "UI3DRenderControl")
	self.Controls = {}

	for i = 1, 5 do
		self["go_dance" .. i] = self:GetChildGameObject("ScrollArea/Content/" .. i .. "/go/Image/go_dance")
		self["btn_jump" .. i] = self:GetChildGameObject("ScrollArea/Content/" .. i)
		self["btn_jump_go" .. i] = self:GetChildGameObject("ScrollArea/Content/" .. i .. "/go")
		self["go_show" .. i] = self:GetChildGameObject("ScrollArea/Content/" .. i .. "/go/Image")
		self["raycast" .. i] = GOUtil.GetComponent(self["btn_jump_go" .. i], "UIEmpty4Raycast")
		self["FX_UI_stage_por" .. i] = self:GetChildGameObject("go_Refresh/FX_UI_stage_por" .. i)

		SetActiveFunc(self["FX_UI_stage_por" .. i], false)
		table.insert(self.Controls, self["btn_jump_go" .. i])
	end

	self:GetChildComponent("tex_tips", "Text").text = _("Desc_Card_Fit_Tips")
	self.DlgPreviewActor = DlgPreviewActor()

	self.DlgPreviewActor:Init(self.Control)
	self:UpdateShowRole()

	self.isLongPress = nil
	self.downPosition = nil
	self.posBegin = nil
	self.isBeginDrag = nil
	self.selectIdx = nil
	self.begin3DPos = nil
	self.RTCamera = nil
	self.go_DlgLongTip = self:GetChildGameObject("go_DlgLongTip")
	self.go_move_finger = self:GetChildGameObject("go_move_finger")

	SetActiveFunc(self.go_move_finger, false)

	self.go_fx = self:GetChildGameObject("go_fx")

	SetActiveFunc(self.go_fx, false)

	if self.teamSystemAgent.localBattleTeam then
		InfoBGMEventMgr:LoadBank("PageMainStage")

		local SceneData = SceneMgr.GetCurrentScene().SceneData

		if SceneData.BGM ~= "" then
			local event = SceneData.BGM

			SoundMgr.PostEvent("Set_Upgrade", UIMgr.UICamera.gameObject)
		end
	else
		InfoBGMEventMgr:LoadBank("PageChapter")
	end
end

function PageCardFittingRoom:UpdateShowRole()
	local inforoles = {}
	local inforolesCount = 0
	local listSectIcon = GetConfigArgJson("FavorRankIcon")

	for i = 1, 5 do
		local infoRole = self.roleList[i]

		if type(infoRole) == "table" then
			table.insert(inforoles, infoRole)
			self:GetChildGameObject("ScrollArea/Content/" .. i .. "/go/Image"):SetActive(true)

			self:GetChildComponent("ScrollArea/Content/" .. i .. "/go/Image/tex_name", "Text").text = Lang(infoRole.data.NameLine)

			local danceNum = InfoTeam:GetTimelineDataDanceNum()

			if danceNum then
				if danceNum[i] == 1 then
					self:GetChildComponent("ScrollArea/Content/" .. i .. "/go/Image/Image", "Image").color = Color.New(0.12941176470588237, 0.5686274509803921, 0.7098039215686275, 1)
				end

				SetActiveFunc(self["go_dance" .. i], danceNum[i] == 1)
			end

			inforolesCount = inforolesCount + 1
		else
			table.insert(inforoles, false)
			self:GetChildGameObject("ScrollArea/Content/" .. i .. "/go/Image"):SetActive(true)
			self:GetChildGameObject("ScrollArea/Content/" .. i .. "/go/Image"):SetActive(false)
		end
	end

	self:Set3DRole(inforoles, inforolesCount)
end

function PageCardFittingRoom:Set3DRole(infoRoles, inforolesCount)
	self.DlgPreviewActor:LoadCardFittingActors(infoRoles, self.Controls, inforolesCount)
end

function PageCardFittingRoom:OnDownCard(data)
	self.downPosition = data.position
end

function PageCardFittingRoom:OnUpCard(data)
	return
end

function PageCardFittingRoom:OnClickedControl(data)
	print("===========================現在の距離")

	if self.downPosition and Vector2.Distance(self.downPosition, data.position) > 15 then
		print("===========距離は" .. Vector2.Distance(self.downPosition, data.position))

		self.downPosition = nil

		return
	end

	if self.isLongPress then
		self.isLongPress = nil
	end

	if self.selectIdx then
		return false
	end

	local go = data.pointerPress.transform.parent.gameObject
	local index = tonumber(go.name)
	local infoRole = self.roleList[index]

	if infoRole then
		if self.teamAgent.slotList[index].isHelperCard then
			return
		end

		require("UI/Page/PageFittingroom/PageFittingroom")

		self.timer = TimerMgr.AddTimer(eTimerType.RealTime, 2, function()
			self.DlgPreviewActor.actorsName = {}

			self.DlgPreviewActor:Purge()
			TimerMgr.RemoveTimer(self.timer)

			self.timer = nil
		end, nil)

		local t = {}

		for _, v in ipairs(self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex].slotList) do
			if v.upInfoRoleCard then
				local role = RoleCardMgr:GetRole(v.upInfoRoleCard.id)

				table.insert(t, role)
			end
		end

		CharacterThinMgr.TempResetData(THIN_SYSTEM_TYPE.Role, t, infoRole.id)
		UIMgr.SwitchPanel(PageFittingroom)
	end
end

function PageCardFittingRoom:GetRoleModel(index)
	local model = GameObject.Find(self.DlgPreviewActor.actorsName[index])

	if model then
		return model
	end

	return nil
end

function PageCardFittingRoom:SetRoleAnimator(index, pose, time, trigger)
	local model = self:GetRoleModel(index)

	if model then
		local actor = GOUtil.GetComponent(model, "Actor")
		local tempPose = GetConfigArgJson("CombatTeamPose")
		local animator = GOUtil.FindChildComponent(GOUtil.GetComponent(model, "Actor").Root, "Model", "Animator")

		if trigger then
			actor.MotionSystem:SetInteger("show_" .. pose, 1)
		else
			actor.MotionSystem:SetInteger("show_" .. pose, 0)
			animator:CrossFade(tempPose[pose], time)
		end
	end
end

function PageCardFittingRoom:IsDragTrue()
	self.fingerCount = FingerGesturesUtil.GetFingersCount()

	if self.fingerCount > 1 then
		return false
	end

	if not RoleMgr.CardFittingLongPress and self.go_DlgLongTip then
		return false
	end

	if RoleMgr.CardFittingUI3DActorRotate then
		return false
	end

	return true
end

function PageCardFittingRoom:OnBeginDragCard(pointerEventData)
	local curRaycast = pointerEventData.pointerPressRaycast

	if curRaycast.gameObject == nil then
		return
	end

	if not self:IsDragTrue() then
		return
	end

	if self.selectIdx then
		return false
	end

	local go = curRaycast.gameObject.transform.parent.gameObject
	local index = tonumber(go.name)

	if self.teamAgent.slotList[index].isHelperCard then
		UIMgr.ShowMsg(_("Msg_CanntMove"))

		return
	end

	self.posBegin = pointerEventData.position
	self.isBeginDrag = true
	self.selectIdx = index

	for i = 1, 5 do
		if i ~= index then
			local model = self:GetRoleModel(i)

			if model then
				GOUtil.GetComponent(model, "Actor"):SetMaterialPropertyAlphaForRTRendering(0.5)
			end
		end
	end

	local model = self:GetRoleModel(self.selectIdx)

	if model then
		if not self.RTCamera or not IsNil(self.RTCamera) then
			self.RTCamera = GameObject.Find("RTCamera")
		end

		self.begin3DPos = UIUtil.GetWorldToScreenPoint(self.RTCamera, model, Vector3.New(0, 0, 0.2))
		self.begin3DPos = self.begin3DPos + Vector3.New(-modelPosX[self.selectIdx], -2, 0)
	end

	self.selectCard = self["btn_jump_go" .. index]

	local drag = GOUtil.GetComponent(self.selectCard, "UIDraggableObject")

	drag:SetDragTarget(self.selectCard, false)

	self.uiEmpty = GOUtil.GetComponent(self.selectCard, "UIEmpty4Raycast")
	self.uiEmpty.raycastTarget = false
end

function PageCardFittingRoom:OnDragCard(pointerEventData)
	if not self.isBeginDrag then
		return
	end

	if not self:IsDragTrue() then
		return
	end

	SetActiveFunc(self.go_move_finger, true)
	SetActiveFunc(self.go_fx, true)

	for i = 1, 5 do
		SetActiveFunc(self["go_show" .. i], false)
		SetActiveFunc(self["FX_UI_stage_por" .. i], false)
	end

	local model = self:GetRoleModel(self.selectIdx)

	if not self.RTCamera or not IsNil(self.RTCamera) then
		self.RTCamera = GameObject.Find("RTCamera")
	end

	self.beginMovePos = false

	UIUtil.SetWorldToScreenPoint(self.RTCamera, model, self.begin3DPos)

	local posX, posY, posZ = GOUtil.GetTransformLocalPosition(self.go_move_finger, x, y, z)
	local posCur = UIUtil.ScreenPointToLocalPoint(self.go_move_finger, pointerEventData.position)

	GOUtil.SetTransformLocalPosition(self.go_move_finger, posX + posCur.x, posY + posCur.y, posZ)
end

function PageCardFittingRoom:OnEndDragCard(pointerEventData)
	RoleMgr.CardFittingUI3DActorRotate = false
	RoleMgr.CardFittingLongPress = false

	SetActiveFunc(self.go_fx, false)
	SetActiveFunc(self.go_move_finger, false)

	for i = 1, 5 do
		local model = self:GetRoleModel(i)

		if model then
			GOUtil.GetComponent(model, "Actor"):SetMaterialPropertyAlphaForRTRendering(1)
			SetActiveFunc(self["go_show" .. i], true)
		end
	end

	if not self.isBeginDrag then
		return
	end

	self.fingerCount = FingerGesturesUtil.GetFingersCount()

	if self.fingerCount > 1 then
		return
	end

	local curRaycast = pointerEventData.pointerCurrentRaycast
	local index

	if not IsNil(curRaycast.gameObject) then
		index = tonumber(curRaycast.gameObject.transform.parent.name)
	end

	if curRaycast.gameObject == nil or tonumber(curRaycast.gameObject.transform.parent.name) == nil or index ~= nil and self.teamAgent.slotList[index].isHelperCard then
		self:NoChangeRolePosition()
	else
		self:ChangeRolePosition(index)
		self:ChangeRoleData(index)
		SetActiveFunc(self["FX_UI_stage_por" .. index], true)
		SetActiveFunc(self["FX_UI_stage_por" .. self.selectIdx], true)
	end

	if index ~= nil and self.teamAgent.slotList[index].isHelperCard then
		UIMgr.ShowMsg(_("Msg_CanntMove"))
	end

	self.isBeginDrag = false
	self.uiEmpty.raycastTarget = true
	self.selectIdx = nil
	self.begin3DPos = nil
	self.pos_begin_figer = nil
end

function PageCardFittingRoom:OnDragCardLongPress(data)
	if self.selectIdx then
		return false
	end

	local curRaycast = data.pointerPressRaycast
	local go = curRaycast.gameObject.transform.parent.gameObject
	local index = tonumber(go.name)
	local model = self:GetRoleModel(index)

	if not model then
		return
	end

	if data.clickCount == 1 and not RoleMgr.CardFittingUI3DActorRotate then
		if not self.GoDlgLongTip then
			self.isLongPress = true
			self.GoDlgLongTip = GOUtil.InstantiatePrefab(self.DlgLongTip, self.go_DlgLongTip)
			self.GoDlgLongTip.transform.localPosition = UIUtil.ScreenPointToLocalPoint(self.GoDlgLongTip, data.position)
		end

		GOUtil.FindChildComponent(self.GoDlgLongTip, "BG/Bar", "UIDlgLongTip").onEndTween = function()
			if RoleMgr.CardFittingUI3DActorRotate or not data.pointerPress then
				GOUtil.DestroyAllChildren(self.go_DlgLongTip)
				GOUtil.SetTransformLocalPosition(self.DlgPreviewActor.actors[index].Root, modelPosX[index], 2, modelPosZ[index])

				RoleMgr.CardFittingLongPress = false
				self.pos_begin_figer = nil

				self:SetRoleAnimator(index, index, 0.2)

				self.beginMovePos = nil
				self.GoDlgLongTip = nil

				return
			end

			if self.DlgPreviewActor.actors[index] then
				self.DlgPreviewActor.actors[index].SkeletonSystem:SetSrpingBoneEnabled(false)
				GOUtil.SetTransformLocalPosition(self.DlgPreviewActor.actors[index].Root, modelPosX[index], 2, -1)
			end

			self.pos_begin_figer = Vector2.New(fingerPos[index][1], fingerPos[index][2])
			self.go_move_finger.transform.localPosition = Vector3.New(self.pos_begin_figer.x, self.pos_begin_figer.y, 0)

			self:SetRoleAnimator(index, enumPose.Ani_Show_In, 0.2)

			self.beginMovePos = true

			GOUtil.DestroyAllChildren(self.go_DlgLongTip)

			RoleMgr.CardFittingLongPress = true
			self.GoDlgLongTip = nil
		end
	else
		if self.GoDlgLongTip then
			GOUtil.DestroyAllChildren(self.go_DlgLongTip)
			GOUtil.SetTransformLocalPosition(self.DlgPreviewActor.actors[index].Root, modelPosX[index], 2, modelPosZ[index])

			RoleMgr.CardFittingLongPress = false
			self.pos_begin_figer = nil

			self:SetRoleAnimator(index, index, 0.2, true)

			self.beginMovePos = nil
			self.GoDlgLongTip = nil

			return
		end

		if RoleMgr.CardFittingLongPress and self.DlgPreviewActor.actors[index] then
			self.DlgPreviewActor.actors[index].SkeletonSystem:SetSrpingBoneEnabled(false)
			GOUtil.SetTransformLocalPosition(self.DlgPreviewActor.actors[index].Root, modelPosX[index], 2, modelPosZ[index])
		end

		SetActiveFunc(self.go_move_finger, false)

		RoleMgr.CardFittingLongPress = false
		self.pos_begin_figer = nil

		if self.beginMovePos then
			self:SetRoleAnimator(index, index, 0.2)

			self.beginMovePos = nil
		end
	end
end

function PageCardFittingRoom:NoChangeRolePosition()
	local curIndex = self.selectIdx

	self:SetRoleAnimator(curIndex, curIndex, 0.2)
	GOUtil.SetTransformLocalPosition(self.selectCard, 0, 0, 0)

	if self.DlgPreviewActor.actors[self.selectIdx] then
		GOUtil.SetTransformLocalPosition(self.DlgPreviewActor.actors[self.selectIdx].Root, modelPosX[self.selectIdx], 2, modelPosZ[self.selectIdx])
	end
end

function PageCardFittingRoom:ChangeRolePosition(index)
	local curIndex = self.selectIdx

	for i = 1, 5 do
		if self.DlgPreviewActor.actors[i] then
			self:GetChildGameObject("ScrollArea/Content/" .. i .. "/go/Image"):SetActive(true)
		else
			self:GetChildGameObject("ScrollArea/Content/" .. i .. "/go/Image"):SetActive(false)
		end

		local model = self:GetRoleModel(i)

		if model then
			GOUtil.SetTransformRotation(model, 0, 180, 0)
		end
	end

	self:SetRoleAnimator(self.selectIdx, index, 0.2)
	self:SetRoleAnimator(index, self.selectIdx, 0.2)

	local curCard = self["btn_jump_go" .. index]

	GOUtil.AttachGameObject(self.selectCard, self["btn_jump" .. index])
	GOUtil.SetTransformLocalPosition(self.selectCard, 0, 0, 0)
	GOUtil.AttachGameObject(curCard, self["btn_jump" .. self.selectIdx])
	GOUtil.SetTransformLocalPosition(curCard, 0, 0, 0)

	if self.DlgPreviewActor.actors[self.selectIdx] then
		GOUtil.SetTransformLocalPosition(self.DlgPreviewActor.actors[self.selectIdx].Root, modelPosX[index], 2, modelPosZ[index])
	end

	if self.DlgPreviewActor.actors[index] then
		GOUtil.SetTransformLocalPosition(self.DlgPreviewActor.actors[index].Root, modelPosX[self.selectIdx], 2, modelPosZ[self.selectIdx])
	end
end

function PageCardFittingRoom:ChangeRoleData(index)
	local tempactor = self.DlgPreviewActor.actors[self.selectIdx]

	self.DlgPreviewActor.actors[self.selectIdx] = self.DlgPreviewActor.actors[index]
	self.DlgPreviewActor.actors[index] = tempactor

	local tempactorName = self.DlgPreviewActor.actorsName[self.selectIdx]

	self.DlgPreviewActor.actorsName[self.selectIdx] = self.DlgPreviewActor.actorsName[index]
	self.DlgPreviewActor.actorsName[index] = tempactorName

	local tempaRole = self.roleList[self.selectIdx]

	self.roleList[self.selectIdx] = self.roleList[index]
	self.roleList[index] = tempaRole

	local temp_Btn_jump = self["btn_jump_go" .. self.selectIdx]

	self["btn_jump_go" .. self.selectIdx] = self["btn_jump_go" .. index]
	self["btn_jump_go" .. index] = temp_Btn_jump

	local temp_go_show = self["go_show" .. self.selectIdx]

	self["go_show" .. self.selectIdx] = self["go_show" .. index]
	self["go_show" .. index] = temp_go_show

	self.teamAgent:ChangePos(self.selectIdx, index, true)

	if self.teamAgent.slotList[index].upInfoRoleCard then
		local cardId = self.teamAgent.slotList[index].upInfoRoleCard.id

		if self.teamAgent.slotList[index].addInfoRoleCard and TeamSystemAgent.SameRole(self.teamAgent.slotList[index].addInfoRoleCard.id, cardId) then
			UIMgr.ShowMsg(_("DlgCommon_SameRoleCantAdd"))

			self.teamAgent.slotList[index].addInfoRoleCard = nil
		end
	end

	if self.teamAgent.slotList[self.selectIdx].upInfoRoleCard then
		local cardId = self.teamAgent.slotList[self.selectIdx].upInfoRoleCard.id

		if self.teamAgent.slotList[self.selectIdx].addInfoRoleCard and TeamSystemAgent.SameRole(self.teamAgent.slotList[self.selectIdx].addInfoRoleCard.id, cardId) then
			self.teamAgent.slotList[self.selectIdx].addInfoRoleCard = nil

			UIMgr.ShowMsg(_("DlgCommon_SameRoleCantAdd"))
		end
	end

	if self.teamSystemAgent.teamChangeCall then
		self.teamSystemAgent.teamChangeCall()
	end
end
