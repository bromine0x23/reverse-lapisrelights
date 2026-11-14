-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTheme/PageSeat.lua

require("UI/Page/PageTheme/PageTheme")
require("Info/InfoTheme")
require("UI/Page/PageTheme/CellThemeSel")
require("UI/Page/PageTheme/CellSeatRole")

PageSeat = class("PageSeat", UIPanel)

function PageSeat:ctor()
	self.UIPrefabPath = "UI/PageTheme/PageSeat"

	if ThemeManager.TypeID == 2 then
		self:AddChildPanel(DlgExit(), {
			title = Lang(590002),
			callback = self.OnBack,
			panel = self
		})
	else
		self:AddChildPanel(DlgExit(), {
			title = _("eReturn_theme"),
			callback = self.OnBack,
			helpCallback = self.OnClickedBtnGuide,
			panel = self
		})
		self:AddChildPanel(DlgAssetsInfo(), {
			type = 1,
			x = -600,
			y = -42,
			AssetInfos = {
				1051,
				502,
				501
			}
		})
	end
end

function PageSeat:PreLoad()
	Event.Instance:Fire("UpdateSceneDisplay", true)
end

function PageSeat:Purge()
	PageSeat.base.Purge(self)
end

function PageSeat:OnRegisterEvent()
	return
end

function PageSeat:OnUnRegisterEvent()
	return
end

function PageSeat:InitLocalize()
	return
end

function PageSeat:OnEnter(vParam)
	return
end

function PageSeat:UpdateInfo()
	return
end

function PageSeat:OnUpdate()
	return
end

function PageSeat:InitData()
	self.showListTeam = false
	self.listTeam = RoleMgr:GetTeamList()
	self.selectIndex = 1
end

function PageSeat:OnBack()
	ThemeManager.SelectedIsSave = 1

	if ThemeManager.TypeID == 2 then
		local SceneTypeID = PersistentStoreUtil.GetInt(ePSKey.SceneId)

		PersistentStoreUtil.SetInt(ePSKey.SceneId, ThemeManager.SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 8
		})

		ThemeManager.TypeID = 1

		return
	elseif PersistentStoreUtil.GetInt(ePSKey.SceneId) ~= InfoGameInst:GetCurrentTheme() then
		local function DlgWorldMapEvent()
			UIMgr.ClearMain()
			UIMgr.SwitchPanel(PageMainStage, nil, true)
		end

		local SceneTypeID = InfoGameInst:GetCurrentTheme()

		PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})

		return
	end

	SceneMainStage.Instance:UpdateRole()
	UIMgr.PopPanel()
end

function PageSeat:OnClickTipsEnter()
	local SceneTypeID = ThemeManager:GetSceneSelectId()

	PersistentStoreUtil.SetInt(ePSKey.SceneId, SceneTypeID)
	SceneMgr.LoadScene("MainStage", {
		from = 8,
		type = 2
	})
end

function PageSeat:OnClickTipsBack()
	SetActiveFunc(self.DlgTips, false)
end

function PageSeat:OnClickArrowLeft()
	self.curArrowIndex = self.curArrowIndex - 1

	local list, count, curIndex = ThemeManager:GetHaveSceneList(self.infoTheme)

	if self.curArrowIndex < 1 then
		self.curArrowIndex = 1
	end
end

function PageSeat:OnClickArrowRight()
	self.curArrowIndex = self.curArrowIndex + 1

	local list, count, curIndex = ThemeManager:GetHaveSceneList(self.infoTheme)

	if count < self.curArrowIndex then
		self.curArrowIndex = count
	end
end

function PageSeat:PageUpdateArrow()
	local list, count, curIndex = ThemeManager:GetHaveSceneList(self.infoTheme)

	if self.curArrowIndex == 1 and count == 1 then
		SetActiveFunc(self.Btn_left, false)
		SetActiveFunc(self.Btn_right, false)
	elseif self.curArrowIndex == 1 and count ~= 1 then
		SetActiveFunc(self.Btn_left, false)
		SetActiveFunc(self.Btn_right, true)
	elseif self.curArrowIndex == count and count ~= 1 then
		SetActiveFunc(self.Btn_left, true)
		SetActiveFunc(self.Btn_right, false)
	else
		SetActiveFunc(self.Btn_left, true)
		SetActiveFunc(self.Btn_right, true)
	end

	if list[curIndex - 1] then
		if ThemeManager:GetSceneRoleCount(list[curIndex - 1]) == 3 and list[curIndex - 1].pb.surplus == 0 then
			SetActiveFunc(self:GetChildGameObject("Arrow/Btn_left/dot"), true)
		else
			SetActiveFunc(self:GetChildGameObject("Arrow/Btn_left/dot"), false)
		end
	else
		SetActiveFunc(self:GetChildGameObject("Arrow/Btn_left/dot"), false)
	end

	if list[curIndex + 1] then
		if ThemeManager:GetSceneRoleCount(list[curIndex + 1]) == 3 and list[curIndex + 1].pb.surplus == 0 then
			SetActiveFunc(self:GetChildGameObject("Arrow/Btn_right/dot"), true)
		else
			SetActiveFunc(self:GetChildGameObject("Arrow/Btn_right/dot"), false)
		end
	else
		SetActiveFunc(self:GetChildGameObject("Arrow/Btn_right/dot"), false)
	end
end

function PageSeat:OnVCEnd()
	self.fingerCount = FingerGesturesUtil.GetFingersCount()

	if self.fingerCount > 1 then
		return
	end

	self.camera = GOUtil.GetComponent(SceneMgr.GetCurrentScene().UnityCamera, "Camera")
	self.DragRoleItem = CellSeatRole(self.PrefabCellRole, self.UIRootObject, self)

	self.DragRoleItem:Create()
	SetActiveFunc(self.DragRoleItem.UIRootObject, false)
	GOUtil.AddComponent(self.DragRoleItem.UIRootObject, "UIRayIgnore")

	self.listItemSeat = {}

	local poslist = {}

	if self.curThemeId == 3 then
		poslist[1] = {}
		poslist[1].x = self.infoTheme.data.SetPos[1]
		poslist[1].y = self.infoTheme.data.SetPos[2]
	end

	for i = 1, self.infoTheme.data.SeatCount do
		local aPos = self["aPos" .. i]
		local pos = GOUtil.GetUIPosForCameraMode(self.camera, UIMgr.RootCanvas, aPos.transform.position)

		if self.curThemeId == 3 and poslist[i] then
			pos = poslist[i]
		end

		local item = CellThemeSel(self.PrefabCellSel, self.bg, self)

		item:Create()

		item.UIRootObject.name = i
		item.Index = i

		GOUtil.SetRectTransformAnchoredPosition(item.UIRootObject, pos.x, pos.y + 300)

		if ThemeManager.TypeID ~= 2 and self.infoTheme.pb.seats[i] then
			item:UpdateData(self.infoTheme.pb.seats[i])
			table.insert(self.listItemSeat, item)
		end

		local dragComp = GOUtil.AddComponent(item.UIRootObject, "UIDraggableObject")

		dragComp:SetDragTarget(self.DragRoleItem.UIRootObject, true)
		dragComp:SetBeginDragCallback(function(data)
			self:OnBeginDragSeatItem(data)
		end)

		function dragComp.onEndDrag(data)
			self:OnEndDragSeatItem(data)
		end

		local dropComp = GOUtil.AddComponent(item.UIRootObject, "UIDropObject")

		if dropComp ~= nil then
			dropComp:SetDropCallbackWithNoColor(function(dropObj, dragObj)
				self:OnDrop(dropObj, dragObj)
			end)
			dropComp:SetEnterAndLeaveCallback(function(pointerEnter)
				self:OnEnterDropItem(pointerEnter)
			end, function(pointerLeave)
				self:OnLeaveDropItem(pointerLeave)
			end)
		end
	end

	local list = self:GetCurRoleList()

	for i = 1, 5 do
		local g = self["CellRole" .. i].UIRootObject
		local dragComp = GOUtil.AddComponent(g, "UIDraggableObject")

		dragComp:SetDragTarget(self.DragRoleItem.UIRootObject, true)
		dragComp:SetBeginDragCallback(function(data)
			self:OnBeginDragRoleItem(data)
		end)

		if list[i] then
			local infoRole = RoleMgr:GetRole(list[i])

			dragComp.enabled = infoRole.hold

			self["CellRole" .. i]:UpdateHasRole(infoRole)
		end
	end
end

function PageSeat:OnBeginDragRoleItem(data)
	self.fingerCount = FingerGesturesUtil.GetFingersCount()

	if self.fingerCount > 1 then
		return
	end

	local selectedObject = data.pointerDrag
	local i = tonumber(selectedObject.name)
	local item = self["CellRole" .. i]
	local list = self:GetCurRoleList()
	local infoRole = RoleMgr:GetRole(list[i])

	self.DragRoleItem:UpdateData(infoRole, false)

	self.dragItem = nil
	self.curRoleIndex = i
end

function PageSeat:OnBeginDragSeatItem(data)
	self.fingerCount = FingerGesturesUtil.GetFingersCount()

	if self.fingerCount > 1 then
		return
	end

	local selectedObject = data.pointerDrag
	local i = tonumber(selectedObject.name)
	local item = self.listItemSeat[i]

	if item.id > 0 then
		local infoRole = RoleMgr:GetRole(item.id)

		self.DragRoleItem:UpdateData(infoRole, false)

		self.dragItem = item
	else
		SetActiveFunc(self.DragRoleItem.UIRootObject, false)

		self.dragItem = nil
	end

	self.seatRoleId = 0
	self.targetSeatIndex = 0
end

function PageSeat:OnEndDragSeatItem(data)
	self.fingerCount = FingerGesturesUtil.GetFingersCount()

	if self.fingerCount > 1 then
		return
	end

	if self.dragItem ~= nil and self.seatRoleId == 0 then
		local i = self.targetSeatIndex

		local function OnCallback(index)
			if index == 1 then
				if i > 0 then
					local item = self.listItemSeat[i]

					item:UpdateData(self.dragItem.id)

					self.infoTheme.tempSeats[i] = self.dragItem.id
				end

				self.dragItem:UpdateData(0)

				self.infoTheme.tempSeats[self.dragItem.Index] = 0

				self:UpdateCellRole()
				self:UpdateInfo()
			end
		end

		local listSeat = {}

		for n = 1, #self.infoTheme.tempSeats do
			table.insert(listSeat, self.infoTheme.tempSeats[n])
		end

		if i > 0 then
			listSeat[i] = self.dragItem.id
		end

		listSeat[self.dragItem.Index] = 0
		self.listSeat = listSeat

		local SeatIndex = 0

		for i = 1, #self.listSeat do
			local id = self.listSeat[i]

			if tonumber(id) ~= 0 then
				SeatIndex = SeatIndex + 1
			end
		end

		OnCallback(1)
	end
end

function PageSeat:OnDrop(dropObject, dragObject)
	self.fingerCount = FingerGesturesUtil.GetFingersCount()

	if self.fingerCount > 1 then
		return
	end

	local i = tonumber(dropObject.name)
	local item = self.listItemSeat[i]
	local infoRole = self.DragRoleItem.infoRole

	self.seatRoleId = self.infoTheme.tempSeats[i]

	if self.dragItem == nil then
		local function OnCallback(index)
			if index == 1 then
				local itemRole = self["CellRole" .. self.curRoleIndex]

				if itemRole.inSeat then
					for n = 1, #self.listItemSeat do
						local otherSeatItem = self.listItemSeat[n]
						local otherRoleId = self.infoTheme.tempSeats[n]

						otherSeatItem:UpdateData(otherRoleId)
					end
				end

				item:UpdateData(infoRole.id)

				self.infoTheme.tempSeats[i] = infoRole.id

				for n = 1, 3 do
					if n ~= i and self.infoTheme.tempSeats[n] == infoRole.id then
						self.infoTheme.tempSeats[n] = 0

						self.listItemSeat[n]:UpdateData(0)
					end
				end

				self:UpdateCellRole()
				self:UpdateInfo()
			end
		end

		local listSeat = {}

		for n = 1, #self.infoTheme.tempSeats do
			table.insert(listSeat, self.infoTheme.tempSeats[n])
		end

		listSeat[i] = infoRole.id
		self.listSeat = listSeat

		OnCallback(1)
		ThemeManager:SetReplaceSceneRoles(self.infoTheme)
	elseif self.seatRoleId == 0 then
		self.targetSeatIndex = i
	else
		local targetId = self.dragItem.id
		local preId = item.id
		local targetIndex = i
		local preIndex = self.dragItem.Index

		local function OnCallback(index)
			if index == 1 then
				item:UpdateData(targetId)
				self.listItemSeat[preIndex]:UpdateData(preId)

				self.infoTheme.tempSeats[targetIndex] = targetId
				self.infoTheme.tempSeats[preIndex] = preId

				self:UpdateInfo()
			end
		end

		local listSeat = {}

		for n = 1, #self.infoTheme.tempSeats do
			table.insert(listSeat, self.infoTheme.tempSeats[n])
		end

		listSeat[targetIndex] = targetId
		listSeat[preIndex] = preId

		OnCallback(1)
	end
end

function PageSeat:OnEnterDropItem(...)
	return
end

function PageSeat:OnLeaveDropItem(...)
	return
end

function PageSeat:RequestSetThemePosition(listSeat, type, callback)
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			callback(1)
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
			callback(0)
		end
	end

	NetManager:RequestSetThemePosition(self.infoTheme.id, listSeat, type, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageSeat:OnClickedGetAward()
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			for i = 1, 3 do
				self.infoTheme.tempSeats[i] = self.infoTheme.pb.seats[i]

				if self.listItemSeat then
					local item = self.listItemSeat[i]

					item:UpdateData(self.infoTheme.tempSeats[i])
				end
			end

			self:UpdateInfo()
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetManager:RequestGetThemeAward(self.infoTheme.id, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageSeat:OnClickSaveDefaultSceneScene()
	if ThemeManager:GetSceneIsChange(self.infoTheme) then
		return
	end

	if ThemeManager:GetSceneRoleCount(self.infoTheme) == 0 then
		UIMgr.ShowMsg(_("Msg_SetSceneFaild"))

		return
	end

	if ThemeManager:IsDefaultScene(self.infoTheme) then
		UIMgr.ShowMsg("")

		return
	end

	local function OnCallback(index)
		if index == 1 then
			InfoGameInst:SetCurrentTheme(self.infoTheme.id)
			UIMgr.ShowMsg(_("Msg_SetSceneSuccee"))
			self:UpdateInfo()
		end
	end

	self:RequestSetThemePosition(self.infoTheme.tempSeats, 1, OnCallback)
end

function PageSeat:OnClickSave()
	if not ThemeManager:GetSceneIsChange(self.infoTheme) then
		return
	end

	local isDefaultSceneNotRole = false

	if ThemeManager:IsDefaultScene(self.infoTheme) then
		for i = 1, 3 do
			local infotheme = ThemeManager:Get(i)

			if infotheme.pb.seats[1] then
				isDefaultSceneNotRole = ThemeManager:IsDefaultSceneNotRole(infotheme)
			end
		end
	else
		local infotheme = ThemeManager:Get(InfoGameInst:GetCurrentTheme())
		local sumcount = ThemeManager:GetSceneRoleCount(infotheme)

		if sumcount == 0 then
			isDefaultSceneNotRole = true
		end
	end

	if not ThemeManager:IsDefaultScene(self.infoTheme) and isDefaultSceneNotRole then
		local function wrap_cb(index)
			if index == 1 then
				local function OnCallback(index)
					if index == 1 then
						InfoGameInst:SetCurrentTheme(self.infoTheme.id)
						UIMgr.ShowMsg(_("Msg_SetSuccee"))

						self.Timer2 = TimerMgr.AddTimer(eTimerType.RealTime, 1, function()
							UIMgr.ShowMsg(_("Msg_SetSceneSuccee"))
						end, {})

						self:UpdateInfo()
					end
				end

				self:RequestSetThemePosition(self.infoTheme.tempSeats, 2, OnCallback)
			end
		end

		local strTitle = _("Desc_Alert")
		local strOkText = _("UI_OK")
		local strCancelText = _("Quite_Cancel")
		local msg = _("Desc_ChangeScene")

		UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, strTitle, msg, wrap_cb, strOkText, strCancelText)
	else
		local function OnCallback(index)
			if index == 1 then
				UIMgr.ShowMsg(_("Msg_SetSuccee"))
				self:UpdateInfo()
			end
		end

		self:RequestSetThemePosition(self.infoTheme.tempSeats, 2, OnCallback)
	end
end

function PageSeat:OnClickedChangeTeam()
	self.showListTeam = not self.showListTeam

	SetActiveFunc(self.PanelTeam, self.showListTeam)
end

function PageSeat:OnClickedChangeScene()
	UIMgr.SwitchPanel(PageTheme, {})
end

function PageSeat:InitScrollView()
	return
end

function PageSeat:UpdateCell(item, index)
	local teamData = self.listTeam[index]

	item:UpdateData(teamData)
end

function PageSeat:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCell)
end

function PageSeat:OnClickedCell(data)
	local go = data.pointerPress
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)

	if info.Item.Index == self.selectIndex then
		return
	end

	self.selectIndex = info.Item.Index

	self:UpdateCellRole()

	self.showListTeam = not self.showListTeam

	SetActiveFunc(self.PanelTeam, self.showListTeam)
end

function PageSeat:GetCurRoleList()
	local teamData = self.listTeam[self.selectIndex]

	return teamData.MemberList
end

function PageSeat:UpdateCellRole()
	local teamData = self.listTeam[self.selectIndex]
	local list = self:GetCurRoleList()
	local listRoleInSeat = ThemeManager:GetRoleInSeatList(self.infoTheme)

	for i = 1, 5 do
		local g = self["CellRole" .. i].UIRootObject

		SetActiveFunc(g, false)
	end

	for i = 1, #list do
		local g = self["CellRole" .. i].UIRootObject

		SetActiveFunc(g, true)

		local inSeat = false

		for n = 1, #listRoleInSeat do
			if listRoleInSeat[n] == list[i] then
				inSeat = true
			end
		end

		local infoRole = RoleMgr:GetRole(list[i])

		self["CellRole" .. i]:UpdateData(infoRole, inSeat)
	end

	UIUtil.SetImageSprite(self.ImageTeam, "UIDyAtlas/Team/" .. teamData.Icon)
end

function PageSeat:OnClickedBtnGuide()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.ScenceSetting)
end
