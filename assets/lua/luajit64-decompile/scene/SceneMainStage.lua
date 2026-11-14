-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Scene/SceneMainStage.lua

require("Scene/SceneBase")
require("UI/Page/PageClassroom/PageMainStage")
require("UI/Page/PageInteraction/PageInteraction")
require("UI/UI3DActorRotate")
require("UI/Page/PageCommunication/DlgCallIn")
require("UI/Page/PageCommunication/DlgTopicIn")
require("Util/BaseDataUtil")
require("UI/Page/PageChapter/PageChapter")
require("UI/Dlg/DlgCharacterThin/DlgCharacterThin")

local CharThinMgr = require("UI/Dlg/DlgCharacterThin/CharacterThinMgr")

CharThinMgr.Init(THIN_SYSTEM_TYPE.Role)

SceneMainStage = class("SceneMainStage", SceneBase, true)

function SceneMainStage.CreateInstance()
	if not SceneMainStage.Instance then
		SceneMainStage.Instance = SceneMainStage()
	end

	return SceneMainStage.Instance
end

function SceneMainStage.DestroyInstance()
	SceneMainStage.Instance = nil
end

function SceneMainStage:OnInit(vParam)
	self.vParam = vParam

	if vParam == nil then
		self.vParam = {}
		self.vParam.from = 0
	end

	local listSeq = GetConfigArgJson("CharacterSequence")
	local curThemeId = 0

	curThemeId = PersistentStoreUtil.GetInt(ePSKey.SceneId)

	if curThemeId == 0 then
		PersistentStoreUtil.SetInt(ePSKey.SceneId, 1)

		curThemeId = 1
	end

	local infoTheme = ThemeManager:Get(curThemeId)
	local curSceneId = infoTheme.data.Scene

	listSeq = infoTheme.pb.seats

	local vParamTemp = {
		RoleIDs = listSeq,
		SceneID = curSceneId
	}

	self.SceneData = SceneMgr.data[vParamTemp.SceneID]
	self.SceneTitle = self.SceneData.Title

	self:InitRole()

	self.inInteraction = false
	self.curIndex = 1
end

function SceneMainStage:InitRole()
	local curThemeId = PersistentStoreUtil.GetInt(ePSKey.SceneId)
	local infoTheme = ThemeManager:Get(curThemeId)
	local listSeq = infoTheme.pb.seats

	self.listSeat = listSeq
	self.InfoRoles = {}

	for i = 1, #listSeq do
		local infoRole = RoleMgr:GetRole(listSeq[i])

		if infoRole ~= nil then
			self.InfoRoles[i] = infoRole
		end
	end
end

function SceneMainStage:UpdateRole()
	self:InitRole()

	self.listTempPart = {}

	local listPreActors = self.Actors
	local listPreActorFactories = {}

	for i, obj in ipairs(self.ActorFactories) do
		table.insert(listPreActorFactories, obj)
	end

	for i = 1, #self.listSeat do
		if listPreActors[i] then
			listPreActors[i]:Destroy()

			listPreActors[i] = nil

			if listPreActorFactories[i] then
				listPreActorFactories[i]:Purge()
			end
		end
	end

	self.Actors = {}
	self.ResBlockId = ResourceMgr.BeginSubmit(function()
		for i = 1, #self.listSeat do
			local actorFactory = self.ActorFactories[i]

			if actorFactory ~= nil then
				local infoRole = RoleMgr:GetRole(self.listSeat[i])
				local actor = actorFactory:Build()

				self.Actors[i] = actor

				actor:Create()
				infoRole:InitFavorAni(actor.InteractSettingFile)

				self.listTempPart[i] = actor.AvatarSystem:GetAvatarPart(eAvatarSlot.Temp)

				if self.listTempPart[i] == nil then
					self.listTempPart[i] = actor.AvatarSystem:GetAvatarPart(eAvatarSlot.Weapon)
				end

				actor.SkeletonSystem:SetSrpingBoneEnabled(false)

				local isNoHeel = GOUtil.GetComponent(self.ActorLocations[i], "NoHeel")

				if isNoHeel ~= nil then
					actor.SkeletonSystem:ApplyHeelSetting(0, 0)
				end

				GOUtil.AttachGameObject(actor.Root, self.ActorLocations[i])
				actor.ExpressionSystem:FocusAt(self.UnityCamera.transform)

				self.gCollideBody[i] = actor.SkeletonSystem:GetBone("Collider").gameObject
				self.gCollideHead[i] = actor.SkeletonSystem:GetBone(HumanBodyBones.Head).gameObject

				actor.SkeletonSystem:SetSrpingBoneEnabled(true)
			end
		end

		self.CurrentCameraIndex = 0

		local virtualCamerasNode = self.Scene.Object.transform:Find("[Predeploy]/VirtualCameras/").gameObject

		if virtualCamerasNode ~= nil then
			self.ObservationCamera = GOUtil.FindChildGameObject(virtualCamerasNode, "CM vcam0")
			self.VirtualCameras = {}

			for i = 1, #self.listSeat do
				local cameraGameObject = GOUtil.FindChildGameObject(virtualCamerasNode, "CM vcam" .. i)

				if self.Actors[i] then
					CinemachineUtil.SetFollowTarget(cameraGameObject, self.ActorLocations[i])
					CinemachineUtil.SetLookAtTarget(cameraGameObject, self.Actors[i].SkeletonSystem:GetBone(HumanBodyBones.Head).gameObject)
				end

				self.VirtualCameras[i] = cameraGameObject
			end

			local cameraGameObject = GOUtil.FindChildGameObject(virtualCamerasNode, "CM vcamCut")

			CinemachineUtil.SetFollowTarget(cameraGameObject, self.ActorLocations[1])

			if self.Actors[1] then
				CinemachineUtil.SetLookAtTarget(cameraGameObject, self.Actors[1].SkeletonSystem:GetBone(HumanBodyBones.Head).gameObject)
			end

			self.VirtualCameras[6] = cameraGameObject
		else
			error("无法找到预部署摄像机节点")
		end

		Event.Instance:Fire("UpdatePopGift")
	end)

	for i = 1, #self.listSeat do
		local infoRole = RoleMgr:GetRole(self.listSeat[i])

		if infoRole ~= nil then
			local actorID = infoRole.data.ActorID
			local controllerMain = ActorUtil.MotionControllerDataFilter(actorID, self.SceneTitle, "P0" .. i)
			local controllerInteract = ActorUtil.MotionControllerDataFilter(actorID, "Interact", "None")
			local mergedMotionControllerData = ActorUtil.MergeMotionControllerData(controllerMain, controllerInteract)
			local actorFactory = ActorUtil.BuildActorFactoryByInfoRole(infoRole, mergedMotionControllerData)

			self.ActorFactories[i] = actorFactory

			actorFactory:Cache()
			print(actorFactory)
		else
			self.ActorFactories[i] = nil
		end
	end

	ResourceMgr.EndSubmit()
end

function SceneMainStage:OnInfoRequestComplete(parms)
	Event.Instance:Remove("OnInfoGameReqComplete", self.OnInfoRequestComplete, self)

	self.isWaiting = false
end

function SceneMainStage:OnCache()
	InfoGameInst:TriggerEnterEvent()

	self.isWaiting = not InfoGameInst:IsRequestOk()

	if self.isWaiting then
		Event.Instance:Add("OnInfoGameReqComplete", self.OnInfoRequestComplete, self)
	end

	self.starttime = os.clock()
	self.listTempPart = {}
	self.Actors = {}
	self.ActorFactories = {}
	self.listBankPath = {}

	for i = 1, #self.listSeat do
		local infoRole = self.InfoRoles[i]

		if infoRole ~= nil then
			local actorID = infoRole.data.ActorID
			local controllerMain = ActorUtil.MotionControllerDataFilter(actorID, self.SceneTitle, "P0" .. i)
			local controllerInteract = ActorUtil.MotionControllerDataFilter(actorID, "Interact", "None")
			local mergedMotionControllerData = ActorUtil.MergeMotionControllerData(controllerMain, controllerInteract)
			local actorFactory = ActorUtil.BuildActorFactoryByInfoRole(infoRole, mergedMotionControllerData)

			self.ActorFactories[i] = actorFactory

			actorFactory:Cache()
		end
	end

	self:CacheMapObjAnimation()
	UIMgr.CachePrefab("UI/Public/DlgAssetsInfo")
	UIMgr.CachePrefab("UI/PanelOperation/New/DlgTipWindowAward")
	UIMgr.CachePrefab("UI/PanelMainStage/DlgMainStageCardPanel")
	UIMgr.CachePrefab("UI/PanelMainStage/DlgPlayerInfoPanel")
	UIMgr.CachePrefab("UI/PanelMainStage/PanelMainStage")
	UIMgr.CachePrefab("UI/PageInteraction/PageInteraction")
	UIMgr.CachePrefab("UI/Public/DlgExit")

	local noticeUrl = "https://" .. Kc.Config.KcAppSetting.NoticeEndPoint .. "/notice/noticeList?pageNum=1&pageSize=50&type=0"

	NetworkManager.GetWebViewNotice(noticeUrl, function(data)
		WebNoticeRDL.CheckNotice(data)
	end)
end

function SceneMainStage:CacheMapObjAnimation()
	self.listMapObjMotionFactory = {}

	local strACPath = "Actors/AnimationController/Common@SceneObj"

	for i = 1, 5 do
		local motionFactory = MotionFactory(strACPath)
		local OverridesAniPath = self.SceneData["P" .. i]

		for _, v in pairs(OverridesAniPath) do
			motionFactory:ApplyOverride(v[1], v[2])
		end

		motionFactory:Cache()
		table.insert(self.listMapObjMotionFactory, motionFactory)
	end
end

function SceneMainStage:InitMapObjAnimation()
	self.listMapObjAnimator = {}
	self.listMapObjLocation = {}

	local strACPath = "Actors/AnimationController/Common@SceneObj"
	local actorLocationNode = GameObject.Find("[Predeploy]/ActorLocation/")

	for i = 1, 5 do
		local location = GOUtil.FindChildGameObject(actorLocationNode, i .. "/prop")

		if location ~= nil then
			local obj = location.transform:GetChild(0)

			if obj ~= nil then
				local animator = GOUtil.GetComponent(obj.gameObject, "Animator")
				local motionFactory = MotionFactory(strACPath)
				local OverridesAniPath = self.SceneData["P" .. i]

				for _, v in pairs(OverridesAniPath) do
					motionFactory:ApplyOverride(v[1], v[2])
				end

				local controller = self.listMapObjMotionFactory[i]:Build()

				animator.runtimeAnimatorController = controller.OverrideAnimatorController

				table.insert(self.listMapObjAnimator, animator)
				table.insert(self.listMapObjLocation, location)
			end
		end
	end
end

function SceneMainStage:OnDestroy()
	return
end

function SceneMainStage:OnPurge()
	for _, v in pairs(self.ActorFactories) do
		if v then
			v:Purge()
		end
	end

	for _, actor in pairs(self.Actors) do
		GOUtil.AttachGameObject(actor.Root, nil)
		actor:Destroy()
	end

	self.Actors = nil
	self.ActorLocations = nil
	self.AnimationController = nil
	self.gCollideHead = nil
	self.gCollideBody = nil

	if self.ResBlockId ~= nil and self.ResBlockId > 0 then
		ResourceMgr.Cancel(self.ResBlockId)
	end
end

function SceneMainStage:OnEnd()
	return
end

function SceneMainStage:DealWithReturn()
	if InstructionMgr:SkipReturn() then
		return
	end

	if TutorialMgr:IsNeedSwitchMainStage() then
		return
	end

	if InstructionMgr.jumpToStageId > 0 then
		self.vParam.from = 4
		self.vParam.stageId = InstructionMgr.jumpToStageId
		self.vParam.stageAgain = true
		InstructionMgr.jumpToStageId = 0
	end

	if self.vParam and self.vParam.from then
		LoadingMgr.ForceHideRepeat()
	end

	if self.vParam.from == 1 then
		require("UI/Page/PageCommunication/PageAddressBookNew")
		UIMgr.SwitchPanel(PageAddressBookNew, {
			roleId = self.vParam.roleId,
			tabType = self.vParam.tabType
		}, false, true)
	elseif self.vParam.from == 2 then
		-- block empty
	elseif self.vParam.from == 3 then
		require("UI/Page/PageFittingroom/PageFittingroom")
		UIMgr.SwitchPanel(PageFittingroom, {
			from = 3,
			infoRole = self.vParam.infoRole
		}, false, true)
	elseif self.vParam.from == 4 then
		local stageId = self.vParam.stageId
		local infoStage = ChapterMgr:GetStage(stageId)
		local chapterType = infoStage.data.ChapterType
		local stageType = infoStage.data.Type

		if chapterType == ChapterFromType.comb then
			if ChapterMgr.teamIndex ~= 0 then
				if EquipmentManager.LastRoleId == 0 then
					require("UI/Page/PageChapter/PageChapter")
					UIMgr.InsertPanel(PageChapter, 1)
				else
					require("UI/Page/PageRole/PageRole")
					UIMgr.InsertPanel(PageRole)
					require("UI/Page/PageEquipment/PageEquip")
					UIMgr.InsertPanel(PageEquip)
					require("UI/Page/PageEquipment/PageEquipDevelop")
					UIMgr.InsertPanel(PageEquipDevelop, {
						roleId = EquipmentManager.LastRoleId
					})
				end

				require("UI/Page/PagePass/PageTeamPass")
				UIMgr.InsertPanel(PageTeamPass, 1)
				require("UI/Page/PagePass/PageStage")
				require("UI/Page/PageCombatReadiness/PageCombatReadiness")

				if not self.vParam.stageup then
					self.vParam.stageup = 0
				end

				local stage = ChapterMgr:GetStage(tonumber(self.vParam.stageId) + self.vParam.stageup)
				local pageStage = PageStage()

				pageStage.isSyncLoad = true

				if stage.data.Type == StageFromType.story then
					UIMgr.SwitchPanel(pageStage, {
						chapterType = 2,
						combId = ChapterMgr.teamIndex,
						ChapterTeamIdx = ChapterMgr.ChapterTeamIdx
					}, false, true)
				else
					UIMgr.SwitchPanel(pageStage, {
						chapterType = 2,
						combId = ChapterMgr.teamIndex,
						ChapterTeamIdx = ChapterMgr.ChapterTeamIdx
					}, false, true)

					if self.vParam.leftnum ~= 0 then
						ChapterMgr.PageCombatReadinessType = 1

						local pageCombatReadiness = PageCombatReadiness()

						pageCombatReadiness.isSyncLoad = true

						UIMgr.AddPanel(pageCombatReadiness, {
							stageId = tonumber(self.vParam.stageId) + self.vParam.stageup
						})
					end
				end
			end
		elseif chapterType == ChapterFromType.activity then
			if stageType == StageFromType.common then
				require("UI/Page/PagePass/PageAssetPass")

				if ChapterMgr.resTabIndex and ChapterMgr.resTabIndex > 0 then
					local listActive = PassMgr:GetBranchActiveList(3, ChapterMgr.resTabIndex)

					if listActive then
						PageAssetPass.isSyncLoad = true

						PageAssetPass.EnterStageList(ChapterMgr.resTabIndex)

						PageAssetPass.isSyncLoad = false

						local function stageFunc()
							if not self.vParam.stageup then
								self.vParam.stageup = 0
							end

							if ChapterMgr.IsForecastState then
								ChapterMgr.PageCombatReadinessType = 1

								UIMgr.AddPanel(PageCombatReadiness(), {
									stageId = tonumber(self.vParam.stageId) + self.vParam.stageup
								})
							end
						end

						local function sweepFunc(...)
							if not self.vParam.stageup then
								self.vParam.stageup = 0
							end

							if self.vParam.leftnum ~= 0 then
								ChapterMgr.PageCombatReadinessType = 1

								local dlgStageSweep = DlgStageSweep()

								dlgStageSweep.isSyncLoad = true

								UIMgr.AddPanel(dlgStageSweep, {
									infoStage = ChapterMgr:GetStage(self.vParam.stageId),
									requireItem = ItemManager:GetSweepItem()
								})
							end
						end

						if lastStageId ~= self.vParam.stageId then
							if self.vParam.sweep then
								sweepFunc()
							else
								stageFunc()
							end
						elseif self.vParam.stageAgain then
							stageFunc()
						elseif self.vParam.sweep then
							sweepFunc()
						end
					end
				end
			else
				require("UI/Page/PageActivity/PageBossActivityBG")

				if stageType == StageFromType.activeBoss or ChapterMgr.BossActivityFirstOpen then
					ChapterMgr.BossActivityFirstOpen = false

					require("UI/Page/PageChapter/PageChapter")
					UIMgr.InsertPanel(PageChapter, 1)

					local pageBossActivity = PageBossActivityBG()

					UIMgr.SwitchPanel(pageBossActivity, nil, false, true)

					if ChapterMgr.IsForecastState then
						ChapterMgr.PageCombatReadinessType = 1

						UIMgr.AddPanel(PageCombatReadiness(), {
							stageId = tonumber(self.vParam.stageId)
						})
					end
				elseif stageType == StageFromType.activeCommon or stageType == StageFromType.story then
					require("UI/Page/PageChapter/PageChapter")
					UIMgr.InsertPanel(PageChapter, 1)

					ChapterMgr.BossActivityStageType = stageType

					UIMgr.SwitchPanel(PageBossActivityBG(), nil, false, true)

					if self.vParam and self.vParam.sweep then
						ChapterMgr.PageCombatReadinessType = 1

						local dlgStageSweep = DlgStageSweep()

						dlgStageSweep.isSyncLoad = true

						UIMgr.AddPanel(dlgStageSweep, {
							infoStage = ChapterMgr:GetStage(self.vParam.stageId),
							requireItem = ItemManager:GetSweepItem()
						})
					end

					if ChapterMgr.IsForecastState then
						ChapterMgr.IsForecastState = tonumber(self.vParam.stageId)
					end
				end
			end
		elseif chapterType == ChapterFromType.card then
			local cardId = CardChapterMgr.GetCardIdByChapterId(infoStage.data.ChapterID)

			if not cardId then
				return
			end

			local function stageFunc()
				if CardExtraMgr.enterType == eEnterType.cardPass then
					require("UI/Page/PageChapter/PageChapter")
					UIMgr.InsertPanel(PageChapter, 1)
					require("UI/Page/PagePass/PageCardStage")
					UIMgr.SwitchPanel(PageCardStage, {
						entType = CardExtraMgr.enterType
					}, false, true)

					if ChapterMgr.IsForecastState then
						ChapterMgr.PageCombatReadinessType = 1

						UIMgr.AddPanel(PageCombatReadiness(), {
							isSyntherize = true,
							stageId = tonumber(self.vParam.stageId)
						})
					end
				else
					require("UI/Page/PageRoleCard/Page/PageRoleCardList")
					UIMgr.InsertPanel(PageRoleCardList, {
						entType = CardExtraMgr.enterType
					})
					require("UI/Page/PageRoleCard/Page/PageRoleCard")
					UIMgr.SwitchPanel(PageRoleCard, {
						cardId = cardId
					}, false, true)
				end

				if not self.vParam.stageup then
					self.vParam.stageup = 0
				end
			end

			local function sweepFunc(...)
				if CardExtraMgr.enterType == eEnterType.cardPass then
					require("UI/Page/PageChapter/PageChapter")
					UIMgr.InsertPanel(PageChapter, 1)
					require("UI/Page/PagePass/PageCardStage")
					UIMgr.SwitchPanel(PageCardStage, {
						entType = CardExtraMgr.enterType
					}, false, true)
				else
					require("UI/Page/PageRoleCard/Page/PageRoleCardList")
					UIMgr.InsertPanel(PageRoleCardList, {
						entType = CardExtraMgr.enterType
					})
					require("UI/Page/PageRoleCard/Page/PageRoleCard")
					UIMgr.SwitchPanel(PageRoleCard, {
						cardId = cardId
					}, false, true)
				end

				if not self.vParam.stageup then
					self.vParam.stageup = 0
				end

				if self.vParam.leftnum ~= 0 then
					ChapterMgr.PageCombatReadinessType = 1

					local dlgStageSweep = DlgStageSweep()

					dlgStageSweep.isSyncLoad = true

					UIMgr.AddPanel(dlgStageSweep, {
						infoStage = ChapterMgr:GetStage(self.vParam.stageId),
						requireItem = ItemManager:GetSweepItem()
					})
				end
			end

			if lastStageId ~= self.vParam.stageId then
				if self.vParam.sweep then
					sweepFunc()
				else
					stageFunc()
				end
			elseif self.vParam.stageAgain then
				stageFunc()
			elseif self.vParam.sweep then
				sweepFunc()
			else
				UIMgr.SwitchPanel(PageChapter, 1, false, true)
			end
		elseif chapterType == ChapterFromType.main or chapterType == ChapterFromType.mainhard then
			local chapterId = infoStage.data.ChapterID
			local infoChapter = ChapterMgr:GetChapter(chapterId)
			local lastStageId = infoChapter:GetLastStageId()
			local chapNum = ChapterMgr:GetChapterIdx(infoChapter.data.ID)

			if type(chapNum) ~= "number" then
				chapNum = 0
			end

			if ItemManager.synLineItems ~= nil then
				require("UI/Page/PageRole/PageRole")

				if ItemManager:Get(ItemManager.synLineItems[1]):GetType() == eItemType.I_GEM then
					require("UI/Page/PageRole/PageTalentTree")
					UIMgr.InsertPanel(PageRole)
					UIMgr.SwitchPanel(PageTalentTree, {
						roleId = ItemManager.itemSynReturnData.roleId
					}, false, true)

					if self.vParam.stageAgain then
						require("UI/Page/PageCombatReadiness/PageCombatReadiness")

						ChapterMgr.PageCombatReadinessType = 1

						local pageCombatReadiness = PageCombatReadiness()

						pageCombatReadiness.isSyncLoad = true

						UIMgr.AddPanel(pageCombatReadiness, {
							isSyntherize = true,
							stageId = tonumber(self.vParam.stageId)
						})
					end

					ItemManager.itemSynReturnData = nil
				else
					UIMgr.InsertPanel(PageRole)
					require("UI/Page/PageEquipment/PageEquip")
					UIMgr.InsertPanel(PageEquip, {
						roleId = ItemManager.itemSynReturnData.roleId
					})
					require("UI/Page/PageEquipment/PageEquipDevelop")
					UIMgr.SwitchPanel(PageEquipDevelop, {
						roleId = ItemManager.itemSynReturnData.roleId,
						slotIdx = ItemManager.itemSynReturnData.slotIdx
					}, false, true)

					if self.vParam.stageAgain then
						require("UI/Page/PageCombatReadiness/PageCombatReadiness")

						ChapterMgr.PageCombatReadinessType = 1

						local pageCombatReadiness = PageCombatReadiness()

						pageCombatReadiness.isSyncLoad = true

						UIMgr.AddPanel(pageCombatReadiness, {
							isSyntherize = true,
							stageId = tonumber(self.vParam.stageId)
						})
					end

					ItemManager.itemSynReturnData = nil
				end
			else
				local function stageFunc()
					local data = {}

					data.chapterType = chapterType
					data.chapterId = chapterId

					UIMgr.InsertPanel(PageChapter, 1)
					require("UI/Page/PagePass/PageStage")
					require("UI/Page/PageCombatReadiness/PageCombatReadiness")

					if not self.vParam.stageup then
						self.vParam.stageup = 0
					end

					local stage = ChapterMgr:GetStage(tonumber(self.vParam.stageId) + self.vParam.stageup)
					local pageStage = PageStage()

					pageStage.isSyncLoad = true

					if stage.data.Type == StageFromType.story then
						UIMgr.SwitchPanel(pageStage, data, false, true)
					else
						UIMgr.SwitchPanel(pageStage, data, false, true)

						if self.vParam.leftnum ~= 0 and InstructionMgr.showExitBtn then
							ChapterMgr.PageCombatReadinessType = 1

							local pageCombatReadiness = PageCombatReadiness()

							pageCombatReadiness.isSyncLoad = true

							UIMgr.AddPanel(pageCombatReadiness, {
								stageId = tonumber(self.vParam.stageId) + self.vParam.stageup
							})
						end
					end
				end

				local function sweepFunc(...)
					local data = {}

					data.chapterType = chapterType
					data.chapterId = chapterId

					UIMgr.InsertPanel(PageChapter, 1)
					require("UI/Page/PagePass/PageStage")
					require("UI/Page/PageCombatReadiness/PageCombatReadiness")

					if not self.vParam.stageup then
						self.vParam.stageup = 0
					end

					local stage = ChapterMgr:GetStage(tonumber(self.vParam.stageId) + self.vParam.stageup)
					local pageStage = PageStage()

					pageStage.isSyncLoad = true

					if stage.data.Type == StageFromType.story then
						UIMgr.SwitchPanel(pageStage, data, false, true)
					else
						UIMgr.SwitchPanel(pageStage, data, false, true)

						if self.vParam.leftnum ~= 0 then
							ChapterMgr.PageCombatReadinessType = 1

							local dlgStageSweep = DlgStageSweep()

							dlgStageSweep.isSyncLoad = true

							UIMgr.AddPanel(dlgStageSweep, {
								infoStage = ChapterMgr:GetStage(self.vParam.stageId),
								requireItem = ItemManager:GetSweepItem()
							})
						end
					end
				end

				if lastStageId ~= self.vParam.stageId or ChapterMgr.IsForecastState then
					if self.vParam.sweep then
						sweepFunc()
					else
						stageFunc()
					end
				elseif self.vParam.stageAgain then
					stageFunc()
				elseif self.vParam.sweep then
					sweepFunc()
				else
					UIMgr.SwitchPanel(PageChapter, 1, false, true)
				end
			end
		elseif chapterType == ChapterFromType.role then
			local chapterId = infoStage.data.ChapterID
			local infoChapter = ChapterMgr:GetChapter(chapterId)
			local roleId = infoChapter.data.Role
			local infoRole

			if roleId <= 0 then
				local listRole = RoleMgr:GetAllHoldRole()

				roleId = listRole[1].id
			end

			infoRole = RoleMgr:GetRole(roleId)

			SceneMainStage.Instance:OnEnterInteractionByRoleId(roleId, {
				from = 5,
				tag = 2
			})

			self.OpenFromRole = true

			if infoStage.data.FavorStorySkill ~= 0 and infoRole.NewUnlockSkill then
				infoRole.NewUnlockSkill = false

				require("UI.Page.PageRoleCard.Dlg.DlgUpResult")
				UIMgr.AddPanel(DlgUpResult(), {
					index = 7,
					addAttr = infoStage.data.FavorStorySkill,
					stageId = infoStage.data.ID,
					infoRole = infoRole
				})
			end
		elseif chapterType == ChapterFromType.union then
			if UnionMgr.HasUnion() then
				require("UI/Page/PageUnion/PageUnion")
				UIMgr.InsertPanel(PageUnion)
				require("UI/Page/PageUnionRaid/PageUnionRaid")

				if stageType == StageFromType.unionBoss then
					local function cb()
						UIMgr.SwitchPanel(PageUnionRaid, nil, false, true)
					end

					PageUnionRaid.RequestData(cb, true)
				else
					UIMgr.InsertPanel(PageUnionRaid, nil, false, true)
					require("UI/Page/PageUnionRaid/PageRaid")
					UIMgr.SwitchPanel(PageRaid, nil, false, true)
				end

				if ChapterMgr.IsForecastState then
					ChapterMgr.PageCombatReadinessType = 1

					UIMgr.AddPanel(PageCombatReadiness(), {
						isSyntherize = true,
						stageId = tonumber(self.vParam.stageId)
					})
				end
			end
		elseif Infogvg:Vaild(stageId) then
			if UnionMgr.HasUnion() then
				require("UI/Page/PageUnion/PageUnion")
				UIMgr.InsertPanel(PageUnion)
				Infogvg:Refresh(true, true)
			end
		elseif chapterType == ChapterFromType.tower or chapterType == ChapterFromType.towerhard then
			local data = {}

			data.infoChapter = TowerChapterMgr:GetTowerChapter(self.vParam.stageId)

			UIMgr.InsertPanel(PageChapter, 1)
			require("UI/Page/PageTower/PageTower")
			UIMgr.InsertPanel(PageTower)
			require("UI/Page/PageTower/PageTowerStage")
			UIMgr.SwitchPanel(PageTowerStage, data, false, true)
		elseif chapterType == ChapterFromType.bosslive then
			local chapterId = infoStage.data.ChapterID
			local infoChapter = ChapterMgr:GetChapter(chapterId)
			local lastStageId = infoChapter:GetLastStageId()
			local chapNum = ChapterMgr:GetChapterIdx(infoChapter.data.ID)

			local function stageFunc()
				local data = {}

				data.chapterType = chapterType
				data.chapterId = chapterId

				UIMgr.InsertPanel(PageChapter, 1)
				require("UI/Page/PageBosslive/PageBosslive")
				require("UI/Page/PageCombatReadiness/PageCombatReadiness")

				if not self.vParam.stageup then
					self.vParam.stageup = 0
				end

				local stage = ChapterMgr:GetStage(tonumber(self.vParam.stageId) + self.vParam.stageup)

				if stage.data.Type == StageFromType.story then
					UIMgr.SwitchPanel(PageBosslive, self.vParam.stageId, false, true)
				else
					UIMgr.SwitchPanel(PageBosslive, self.vParam.stageId, false, true)

					if ChapterMgr.IsForecastState then
						ChapterMgr.PageCombatReadinessType = 1

						UIMgr.AddPanel(PageCombatReadiness(), {
							isSyntherize = true,
							stageId = tonumber(self.vParam.stageId)
						})
					end
				end
			end

			local function sweepFunc()
				local data = {}

				data.chapterType = chapterType
				data.chapterId = chapterId

				UIMgr.InsertPanel(PageChapter, 1)
				require("UI/Page/PageBosslive/PageBosslive")
				require("UI/Page/PageCombatReadiness/PageCombatReadiness")

				if not self.vParam.stageup then
					self.vParam.stageup = 0
				end

				local stage = ChapterMgr:GetStage(tonumber(self.vParam.stageId) + self.vParam.stageup)

				if stage.data.Type == StageFromType.story then
					UIMgr.SwitchPanel(PageBosslive, self.vParam.stageId, false, true)
				else
					UIMgr.SwitchPanel(PageBosslive, self.vParam.stageId, false, true)

					if self.vParam.leftnum ~= 0 then
						ChapterMgr.PageCombatReadinessType = 1

						local dlgStageSweep = DlgStageSweep()

						dlgStageSweep.isSyncLoad = true

						UIMgr.AddPanel(dlgStageSweep, {
							infoStage = ChapterMgr:GetStage(self.vParam.stageId),
							requireItem = ItemManager:GetSweepItem()
						})
					end
				end
			end

			if lastStageId ~= self.vParam.stageId then
				if self.vParam.sweep then
					sweepFunc()
				else
					stageFunc()
				end
			elseif self.vParam.stageAgain then
				stageFunc()
			elseif self.vParam.sweep then
				sweepFunc()
			else
				UIMgr.InsertPanel(PageChapter, 1)
				require("UI/Page/PageBosslive/PageBosslive")
				UIMgr.SwitchPanel(PageBosslive, self.vParam.stageId, false, true)
			end
		elseif chapterType == ChapterFromType.bossRaid then
			if ActivityBossRaidMgr.bossRaidTimeData and ActivityBossRaidMgr.bossRaidTimeData:IsShowOpen() then
				require("UI/Page/PageActivityBossRaid/PageActivityBossRaid")
				UIMgr.SwitchPanel(PageActivityBossRaid(), nil, false, true)
			else
				UIMgr.ShowMsg(_("Msg_Active_Over"))
			end
		elseif chapterType == ChapterFromType.timespace then
			require("UI/Page/PageTimeSpace/PageTimeSpace")
			require("UI/Page/PageTimeSpace/PageTimeSpaceStage")

			local currChapter = TimeSpaceChapterMgr:GetCurrChapter()

			if currChapter then
				UIMgr.InsertPanel(PageTimeSpace)
				UIMgr.SwitchPanel(PageTimeSpaceStage, {
					chapter = TimeSpaceChapterMgr:GetCurrChapter()
				}, false, true)
			else
				UIMgr.SwitchPanel(PageTimeSpace, nil, false, true)
			end
		end
	elseif self.vParam.from == 5 then
		require("UI/Page/PageChapter/PageChapter")
		UIMgr.SwitchPanel(PageChapter, 1, false, true)
	elseif self.vParam.from == 6 then
		ThemeManager.TypeID = 1

		UIMgr.ShowMsg(_("Msg_SetMainSceneSucess"))
	elseif self.vParam.from == 7 then
		ThemeManager.TypeID = 2

		require("UI/Page/PageTheme/PageSeat")
		UIMgr.SwitchPanel(PageSeat, 1, false, true)
	elseif self.vParam.from == 8 then
		if self.vParam.type == 2 then
			UIMgr.ClearMain()
			UIMgr.SwitchPanel(PageMainStage, nil, true)
		else
			require("UI/Page/PageTheme/PageTheme")
			UIMgr.SwitchPanel(PageTheme, {}, false, true)
		end
	elseif self.vParam.from == 9 then
		self.OpenFromRole = true

		self:OnEnterInteractionByRoleId(self.vParam.infoRole.id)
	elseif self.vParam.from == 10 then
		require("UI/Page/pagePVP/PagePVPMain")

		local InfoPVP = require("Info/InfoPVP")
		local time = InfoPVP.PBPVPSeason.seasonEndTime - NetData:GetCurServerTime() / DateUtil.MillsPerSecond
		local endtiem = GetConfigArgInt("PVPSettleSeconds")

		if InfoPVP.pb.season.seasonStatus ~= 1 then
			UIMgr.ShowMsg(_("PvPSeason"))
		elseif time <= endtiem then
			UIMgr.ShowMsg(_("PvPSeason"))
		else
			UIMgr.SwitchPanel(PagePVPMain, InfoPVP.pb, false, true)
		end
	elseif self.vParam.from == 11 then
		require("UI/Page/PageRoleCard/Page/PageRoleCardList")
		UIMgr.SwitchPanel(PageRoleCardList, {
			entType = 1
		}, false, true)
	elseif self.vParam.from == 12 then
		require("UI/Page/PageRole/PageRole")
		UIMgr.InsertPanel(PageRole)
		require("UI/Page/PageEquipment/PageEquip")
		CharacterThinMgr.DoResetOperate(CharacterThinMgr.ResetType.STAGE, self.vParam.stageId)
		UIMgr.SwitchPanel(PageEquip, data, false, true)
	elseif self.vParam.from == 13 then
		require("UI/Page/PageRole/PageRole")
		UIMgr.InsertPanel(PageRole)
		require("UI/Page/PageRole/PageTalentTree")
		CharacterThinMgr.DoResetOperate(CharacterThinMgr.ResetType.STAGE, self.vParam.stageId)
		UIMgr.SwitchPanel(PageTalentTree, data, false, true)
	elseif self.vParam.from == 14 then
		self.vParam.func()
	end
end

function SceneMainStage:OnCreate()
	self.IsEnterInteraction = false

	self:InitMapObjAnimation()
	self:PostprocessBlurEnable(false)

	self.lightDir = GameObject.Find("[Predeploy]/Lights/Actor Light")
	self.lightDefaultDir = self.lightDir.transform.rotation

	local actorLocationNode = GameObject.Find("[Predeploy]/ActorLocation/")

	if actorLocationNode ~= nil then
		self.ActorLocations = {}
		self.listActorLightDir = {}

		for i = 1, 5 do
			local location = GOUtil.FindChildGameObject(actorLocationNode, i)

			if location ~= nil then
				table.insert(self.ActorLocations, location)
			else
				error("无法找到角色出生点" .. i)
			end

			local lightDir = GOUtil.FindChildGameObject(location, "LightLocation")

			if lightDir ~= nil then
				table.insert(self.listActorLightDir, lightDir)
			else
				error("无法找到角色灯角度点" .. i)
			end
		end
	else
		error("无法找到预部署角色出生点")
	end

	self.gCollideHead = {}
	self.gCollideBody = {}

	for i = 1, #self.listSeat do
		local actorFactory = self.ActorFactories[i]

		if actorFactory ~= nil then
			local infoRole = RoleMgr:GetRole(self.listSeat[i])
			local actor = actorFactory:Build()

			self.Actors[i] = actor

			actor:Create()
			infoRole:InitFavorAni(actor.InteractSettingFile)

			self.listTempPart[i] = actor.AvatarSystem:GetAvatarPart(eAvatarSlot.Temp)

			if self.listTempPart[i] == nil then
				self.listTempPart[i] = actor.AvatarSystem:GetAvatarPart(eAvatarSlot.Weapon)
			end

			actor.SkeletonSystem:SetSrpingBoneEnabled(false)

			local isNoHeel = GOUtil.GetComponent(self.ActorLocations[i], "NoHeel")

			if isNoHeel ~= nil then
				actor.SkeletonSystem:ApplyHeelSetting(0, 0)
			end

			GOUtil.AttachGameObject(actor.Root, self.ActorLocations[i])
			actor.ExpressionSystem:FocusAt(self.UnityCamera.transform)

			self.gCollideBody[i] = actor.SkeletonSystem:GetBone("Collider").gameObject
			self.gCollideHead[i] = actor.SkeletonSystem:GetBone(HumanBodyBones.Head).gameObject

			actor.SkeletonSystem:SetSrpingBoneEnabled(true)
		end
	end

	self.CurrentCameraIndex = 0

	local virtualCamerasNode = GameObject.Find("[Predeploy]/VirtualCameras/")

	if virtualCamerasNode ~= nil then
		self.ObservationCamera = GOUtil.FindChildGameObject(virtualCamerasNode, "CM vcam0")
		self.VirtualCameras = {}
		self.VirtualMoveCameras = {}

		for i = 1, #self.listSeat do
			local cameraGameObject = GOUtil.FindChildGameObject(virtualCamerasNode, "CM vcam" .. i)
			local moveCameraObj = GOUtil.Instantiate(cameraGameObject, virtualCamerasNode)

			moveCameraObj.name = "CM vcamMove" .. i

			CinemachineUtil.SetFieldOfView(moveCameraObj, 30)
			CinemachineUtil.SetScreenY(moveCameraObj, 0.4)
			CinemachineUtil.SetScreenX(moveCameraObj, 0.3)
			CinemachineUtil.SetDeadZoneWidth(moveCameraObj, 0)

			moveCameraObj.transform.position = cameraGameObject.transform.position

			if self.Actors[i] then
				CinemachineUtil.SetFollowTarget(cameraGameObject, self.ActorLocations[i])
				CinemachineUtil.SetLookAtTarget(cameraGameObject, self.Actors[i].SkeletonSystem:GetBone(HumanBodyBones.Head).gameObject)
				CinemachineUtil.SetFollowTarget(moveCameraObj, self.ActorLocations[i])
				CinemachineUtil.SetLookAtTarget(moveCameraObj, self.Actors[i].SkeletonSystem:GetBone(HumanBodyBones.Head).gameObject)
			end

			self.VirtualCameras[i] = cameraGameObject
			self.VirtualMoveCameras[i] = moveCameraObj
		end

		local cameraGameObject = GOUtil.FindChildGameObject(virtualCamerasNode, "CM vcamCut")

		CinemachineUtil.SetFollowTarget(cameraGameObject, self.ActorLocations[1])

		if self.Actors[1] then
			CinemachineUtil.SetLookAtTarget(cameraGameObject, self.Actors[1].SkeletonSystem:GetBone(HumanBodyBones.Head).gameObject)
		end

		self.VirtualCameras[6] = cameraGameObject
	else
		error("无法找到预部署摄像机节点")
	end

	FingerGesturesUtil.SetScreenRaycasterCamera(self.UnityCamera)
	FingerGesturesUtil.SetScreenRaycasterLayerMask("Actor")
	FingerGesturesUtil.SetScreenRaycasterLayerMask("Nothing")
	InstructionMgr:Start()
	InfoBGMEventMgr:Clear()
	UIMgr.SwitchPanel(PageMainStage, self.vParam, true)
	self:DealWithReturn()
end

function SceneMainStage:SetVcScreenX(data)
	local index = data.index
	local isLeft = data.isLeft
	local leftOffset = data.leftOffset
	local virtualCamerasNode = GameObject.Find("[Predeploy]/VirtualCameras/")

	if virtualCamerasNode ~= nil then
		local cameraGameObject = GOUtil.FindChildGameObject(virtualCamerasNode, "CM vcam" .. index)

		if isLeft then
			CinemachineUtil.SetDeadZoneWidth(cameraGameObject, 0)
			CinemachineUtil.SetScreenX(cameraGameObject, TenaryOp(leftOffset, leftOffset, 0.4))
		else
			CinemachineUtil.SetScreenX(cameraGameObject, 0.5)
		end

		if isLeft ~= nil then
			UIMgr.ResetMsg2OffsetType(isLeft and DlgMessage2OffType.offset1 or DlgMessage2OffType.default)
			UIMgr.ResetMsg2Position()
		end
	end
end

function SceneMainStage:SetVcFieldOfView(data)
	local index = data.index
	local isNear = data.isNear
	local virtualCamerasNode = GameObject.Find("[Predeploy]/VirtualCameras/")

	if virtualCamerasNode ~= nil then
		local cameraGameObject = GOUtil.FindChildGameObject(virtualCamerasNode, "CM vcam" .. index)
		local moveCameraObj = GOUtil.FindChildGameObject(virtualCamerasNode, "CM vcamMove" .. index)

		if isNear then
			moveCameraObj.transform.position = cameraGameObject.transform.position

			cameraGameObject.gameObject:SetActive(true)
			moveCameraObj.gameObject:SetActive(false)
		else
			cameraGameObject.gameObject:SetActive(false)
			CinemachineUtil.SetDeadZoneHeight(moveCameraObj, 0)
			moveCameraObj.gameObject:SetActive(true)
		end
	end
end

function SceneMainStage:OnRegisterEvent(...)
	EventListenerMgr.AddFingerGestureListener(self.OnTap, self, eFingerGestureType.Tap)
	EventListenerMgr.AddFingerGestureListener(self.OnDrag, self, eFingerGestureType.Drag)
	Event.Instance:Add("SetVcScreenX", self.SetVcScreenX, self)
	Event.Instance:Add("SetVcFieldOfView", self.SetVcFieldOfView, self)
	Event.Instance:Add("UpdateAvatars", self.UpdateAvatars, self)
	Event.Instance:Add("UpdateSceneDisplay", self.UpdateSceneDisplay, self)
	Event.Instance:Add(BillingManager.OnPaySuceed, self.OnPurchased, self)
end

function SceneMainStage:OnUnRegisterEvent(...)
	EventListenerMgr.RemoveFingerGestureListener(self.OnTap, self, eFingerGestureType.Tap)
	EventListenerMgr.RemoveFingerGestureListener(self.OnDrag, self, eFingerGestureType.Drag)
	Event.Instance:Remove("SetVcScreenX", self.SetVcScreenX, self)
	Event.Instance:Remove("SetVcFieldOfView", self.SetVcFieldOfView, self)
	Event.Instance:Remove("UpdateAvatars", self.UpdateAvatars, self)
	Event.Instance:Remove("UpdateSceneDisplay", self.UpdateSceneDisplay, self)
	Event.Instance:Remove(BillingManager.OnPaySuceed, self.OnPurchased, self)
end

function SceneMainStage:OnPurchased(item)
	return
end

function SceneMainStage:UpdateSceneDisplay(isShow)
	if not self.IsEnterInteraction and self.Scene then
		self.Scene.Object:SetActive(isShow)
	end
end

function SceneMainStage:UpdateAvatars(roleId)
	local index = -1
	local infoRole = RoleMgr:GetRole(roleId)

	for i = 1, #self.listSeat do
		if self.InfoRoles[i] and roleId == self.InfoRoles[i].id then
			index = i
		end
	end

	if index == -1 then
		return
	end

	local actor = self.Actors[index]

	if actor == nil then
		return
	end

	local ids = infoRole.pb.clothes

	ActorUtil.UpdateAvatars(ids, actor, infoRole.id)
end

function SceneMainStage:OnTap(gesture)
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Role)

	if not isOpen then
		return
	end

	if self.inInteraction then
		return
	end

	if GameObject.Find("DlgGuide(Clone)") then
		return
	end

	if gesture.Selection ~= nil then
		for i = 1, #self.listSeat do
			if self.gCollideHead[i] and self.gCollideHead[i] == gesture.Selection or self.gCollideBody[i] == gesture.Selection then
				local infoRole = RoleMgr:GetRole(self.listSeat[i])
				local index = self:GetPosIndex(infoRole.id)
				local actor = self.Actors[index]

				if actor.MotionSystem:IsState("Idle") and not actor.MotionSystem:IsInTransition() then
					self:OnEnterInteractionByRoleId(infoRole.id)
				end

				return
			end
		end
	end
end

function SceneMainStage:OnDrag(gesture)
	if self.inInteraction then
		return
	end

	if self.ObservationCamera ~= nil then
		CinemachineUtil.MoveDollyCamera(self.ObservationCamera, gesture.DeltaMove.x * 0.01)
	end
end

function SceneMainStage:GetCurActor(index)
	local curActor

	if self.isOtherIndex then
		curActor = self.actor
	else
		curActor = self.Actors[index]
	end

	return curActor
end

function SceneMainStage:GetPosIndex(roleId)
	for i = 1, #self.listSeat do
		if roleId == self.listSeat[i] then
			return i
		end
	end

	return 0
end

function SceneMainStage:DestroyActor()
	if self.actor then
		self.actor:Destroy()

		self.actor = nil
	end
end

function SceneMainStage:ChangeActor(index, roleId, onLoaded)
	self:OnSwitchPageByRoleId(roleId, function(data)
		data.cameraGameObject:SetActive(true)

		if onLoaded then
			onLoaded()
		end
	end, false)

	do return end

	local index = self:GetPosIndex(roleId)
	local infoRole = RoleMgr:GetRole(roleId)
	local isNewRole = true

	local function funGoTo()
		for i = 1, #self.listSeat do
			if self.Actors[i] then
				self.Actors[i].MotionSystem:CrossFade("Idle", 0.1)
				self.Actors[i]:ResetBehaviour()
				self.Actors[i].Root:SetActive(false)
			end

			if self.listTempPart[i] ~= nil then
				self.listTempPart[i]:SetVisible(false)
			end
		end

		for i = 1, #self.listMapObjLocation do
			self.listMapObjLocation[i]:SetActive(false)
		end

		self.curActor = self.actor

		local curActor = self.curActor

		if not infoRole:HasGift() then
			curActor.MotionSystem:FaceAtImmediate(nil)
			PlayAnim(InfoRole.GetDaySection(), curActor, infoRole)
		end

		local p = index

		if index > 5 then
			p = 1
		end

		GOUtil.AttachGameObject(curActor.Root, self.ActorLocations[p])
		print("Attach ChangeActor:" .. p)

		local virtualCamerasNode = GameObject.Find("[Predeploy]/VirtualCameras/")
		local cameraGameObject = GOUtil.FindChildGameObject(virtualCamerasNode, "CM vcam" .. p)

		cameraGameObject:SetActive(true)
		CinemachineUtil.SetLookAtTarget(cameraGameObject, curActor.SkeletonSystem:GetBone(HumanBodyBones.Head).gameObject)

		if onLoaded then
			onLoaded()
		end
	end

	self:LoadActor(roleId, funGoTo)
end

function SceneMainStage:DestroyNewRole()
	local flag = false

	if self.actorFactory then
		flag = true

		self.actorFactory:Purge()

		self.actorFactory = nil
	end

	if self.actor then
		flag = true

		self.actor:Destroy()

		self.actor = nil
	end

	if flag then
		System.GC.Collect()
	end
end

function SceneMainStage:LoadActor(roleId, onLoaded)
	local infoRole = RoleMgr:GetRole(roleId)

	self:DestroyNewRole()
	LoadingMgr.Show(eLoadingType.Repeat)
	ResourceMgr.BeginSubmit(function()
		LoadingMgr.Hide(eLoadingType.Repeat)

		local actor = self.actorFactory:Build()

		self.actor = actor

		actor:Create()
		infoRole:InitFavorAni(actor.InteractSettingFile)

		if self.Actors[1] and self.Actors[1].Root and IsNil(self.Actors[1].Root) then
			self.Actors[1].Root:SetActive(false)
		end

		self.curActor = actor
		self.curActorCreateFrame = Time.frameCount

		print("Attach load actor:1")
		GOUtil.AttachGameObject(actor.Root, self.ActorLocations[1])
		actor.ExpressionSystem:FocusAt(self.UnityCamera.transform)

		local virtualCamerasNode = GameObject.Find("[Predeploy]/VirtualCameras/")

		if not IsNil(virtualCamerasNode) then
			local cameraGameObject = GOUtil.FindChildGameObject(virtualCamerasNode, "CM vcamCut")

			if not IsNil(cameraGameObject) then
				CinemachineUtil.SetLookAtTarget(cameraGameObject, actor.SkeletonSystem:GetBone(HumanBodyBones.Head).gameObject)
			end
		end

		if onLoaded then
			onLoaded()
		end
	end)

	local controllerMain = ActorUtil.MotionControllerDataFilter(infoRole.data.ActorID, self.SceneTitle, "P01")
	local controllerInteract = ActorUtil.MotionControllerDataFilter(infoRole.data.ActorID, "Interact", "None")
	local mergedMotionControllerData = ActorUtil.MergeMotionControllerData(controllerMain, controllerInteract, true)
	local actorFactory = ActorUtil.BuildActorFactoryByInfoRole(infoRole, mergedMotionControllerData)

	actorFactory:Cache()

	self.actorFactory = actorFactory

	ResourceMgr.EndSubmit()
end

function SceneMainStage:HideVC()
	for i = 1, #self.VirtualCameras do
		if self.VirtualCameras[i] then
			self.VirtualCameras[i]:SetActive(false)
			CinemachineUtil.SetScreenX(self.VirtualCameras[i], 0.5)
		end
	end

	for i = 1, #self.VirtualMoveCameras do
		if self.VirtualMoveCameras[i] then
			self.VirtualMoveCameras[i]:SetActive(false)
		end
	end
end

function SceneMainStage:ResetVC(pos)
	for i = 1, #self.VirtualCameras do
		if self.VirtualCameras[i] then
			CinemachineUtil.SetDeadZoneWidth(self.VirtualCameras[i], 0)
			CinemachineUtil.SetScreenX(self.VirtualCameras[i], pos)
		end
	end
end

function SceneMainStage:OnSwitchPageByRoleId(roleId, callback, isInteraction)
	self:UpdateSceneDisplay(true)

	local index = self:GetPosIndex(roleId)

	print("Rid:" .. roleId .. " P:" .. index)

	local infoRole = RoleMgr:GetRole(roleId)
	local curActor
	local isNewRole = false

	self.previousRolePosIndex = self.rolePosIndex
	self.rolePosIndex = index

	local function funGoTo()
		FingerGesturesUtil.SetScreenRaycasterLayerMask("Nothing")
		self.lightDir.transform:DORotateQuaternion(self.listActorLightDir[index].transform.rotation, 0.6)

		if self.VirtualCameras[self.CurrentCameraIndex] then
			self.VirtualCameras[self.CurrentCameraIndex]:SetActive(false)
		end

		self.CurrentCameraIndex = index

		for i = 1, #self.listSeat do
			if self.Actors[i] and self.Actors[i].Root and IsNil(self.Actors[i].Root) then
				self.Actors[i].Root:SetActive(false)
			end

			if self.listTempPart[i] ~= nil then
				self.listTempPart[i]:SetVisible(false)
			end
		end

		for i = 1, #self.listMapObjLocation do
			self.listMapObjLocation[i]:SetActive(false)
		end

		if isNewRole then
			self.curActor = self.actor
		else
			self.curActor = self.Actors[index]
		end

		for i = 1, 5 do
			local g = GameObject.Find("[Predeploy]/ActorLocation/" .. i)

			if g and g.transform.childCount > 1 then
				for n = 2, g.transform.childCount do
					if g.transform:GetChild(n - 1) then
						local go = g.transform:GetChild(n - 1).gameObject

						if go ~= self.curActor.Root then
							GOUtil.SetActive(go, false)
						end
					end
				end
			end
		end

		curActor = self.curActor

		curActor.Root:SetActive(true)

		local r = infoRole:GetRandomMotionLevel(eFavorMotionType.hello)

		if not infoRole:HasGift() and not isInteraction then
			curActor.MotionSystem:FaceAtImmediate(nil)

			if self.rolePosIndex == 0 or self.previousRolePosIndex and self.previousRolePosIndex ~= self.rolePosIndex then
				curActor.SkeletonSystem:SetSrpingBoneEnabled(false)
				PlayAnimImmediately(InfoRole.GetDaySection(), curActor, infoRole)
			else
				PlayAnim(InfoRole.GetDaySection(), curActor, infoRole)
			end
		end

		local virtualCamerasNode = GameObject.Find("[Predeploy]/VirtualCameras/")
		local cameraGameObject = GOUtil.FindChildGameObject(virtualCamerasNode, "CM vcam" .. index)

		PageInteraction.InteractIndex = index

		print("cameraGameObject===============" .. index)
		CinemachineUtil.SetLookAtTarget(cameraGameObject, curActor.SkeletonSystem:GetBone(HumanBodyBones.Head).gameObject)

		local cameraMoveGameObject = GOUtil.FindChildGameObject(virtualCamerasNode, "CM vcamMove" .. index)

		CinemachineUtil.SetLookAtTarget(cameraMoveGameObject, curActor.SkeletonSystem:GetBone(HumanBodyBones.Head).gameObject)

		local data = {}

		data.index = index
		data.infoRole = infoRole
		data.roleId = infoRole.id

		if not infoRole:HasGift() then
			data.initMotion = "Body@Hello0" .. r + 1
		end

		data.cameraGameObject = cameraGameObject

		if callback then
			callback(data)
		end
	end

	if index == 0 then
		index = 1
		isNewRole = true

		self:LoadActor(roleId, funGoTo)
	else
		self.OpenFromRole = false
		isNewRole = false

		funGoTo()
		self:DestroyNewRole()
	end

	self:ChangeShadowDistance(false)
end

function SceneMainStage:ChangeShadowDistance(isAdd)
	local min = 2.5
	local max = 8
	local env = GOUtil.GetComponent(self.Scene.Object, "SceneEnvironment")

	print(env.ShadowSettings.ShadowDistance)

	if self.timerChangeShadowDistance ~= nil then
		TimerMgr.RemoveTimer(self.timerChangeShadowDistance)

		if isAdd then
			env.ShadowSettings.ShadowDistance = min
		else
			env.ShadowSettings.ShadowDistance = max
		end
	end

	self.timerChangeShadowDistance = TimerMgr.AddTimer(eTimerType.RealTime, 0.1, function()
		if isAdd then
			env.ShadowSettings.ShadowDistance = env.ShadowSettings.ShadowDistance + 1

			if env.ShadowSettings.ShadowDistance > max then
				env.ShadowSettings.ShadowDistance = max

				TimerMgr.RemoveTimer(self.timerChangeShadowDistance)
			end
		else
			env.ShadowSettings.ShadowDistance = env.ShadowSettings.ShadowDistance - 1

			if env.ShadowSettings.ShadowDistance < min then
				env.ShadowSettings.ShadowDistance = min

				TimerMgr.RemoveTimer(self.timerChangeShadowDistance)
			end
		end

		env:Apply()
	end, {}, 10)
end

function SceneMainStage:OnEnterInteractionByRoleId(roleId, vParam, isPop)
	self:OnSwitchPageByRoleId(roleId, function(data)
		data.cameraGameObject:SetActive(true)

		local curPanel = UIMgr.GetCurPanel()

		if curPanel and curPanel.className ~= "PageRole" and curPanel.className ~= "PageEquip" and curPanel.className ~= "PageTalentTree" and curPanel.className ~= "PageFittingroom" then
			CharacterThinMgr.needReset = true
			CharacterThinMgr.roleID = data.infoRole.id
		end

		if isPop then
			UIMgr.PopPanel(data)
		else
			if vParam then
				data.from = vParam.from
				data.tag = vParam.tag
			end

			UIMgr.SwitchPanel(PageInteraction, data, false, true)
		end

		self.InteractionData = data
		self.inInteraction = true
		self.IsEnterInteraction = true
	end, true)
end

function SceneMainStage:PlayVoice(str, infoRole, actor)
	Event.Instance:Fire(EventEnum.PlayVoice, str)

	do return end

	local listPath = infoRole.data.Vocals
	local strPath

	for i = 1, #listPath do
		local list = listPath[i]
		local key = list[1]

		if key == str then
			strPath = list[2]
		end
	end

	if strPath then
		if self.preVoicePath then
			SoundMgr.Stop(self.preVoicePath)
		end

		SoundMgr.Play(strPath)

		self.preVoicePath = strPath

		local lips = actor.ExpressionSystem.ExpressionAnimator.LipSyncVoice

		lips:SetData(strPath, false)
	end
end

function SceneMainStage:PostprocessBlurEnable(isEnable, index)
	self.Scene.Postprocess.RuntimeSetting.Blur.Enable = isEnable

	if isEnable then
		local curActor

		if index == 0 then
			curActor = self.actor
		else
			curActor = self.Actors[index]
		end

		if curActor then
			ReferenceRoot.AddReference(curActor.Root, self.Scene.Postprocess.RuntimeSetting.Blur.DofFocal)

			self.Scene.Postprocess.RuntimeSetting.DataSource.depthTextureMode = UnityEngine.DepthTextureMode.Depth
		else
			self.Scene.Postprocess.RuntimeSetting.DataSource.depthTextureMode = UnityEngine.DepthTextureMode.None
		end
	else
		self.Scene.Postprocess.RuntimeSetting.DataSource.depthTextureMode = UnityEngine.DepthTextureMode.None
	end
end

function SceneMainStage:UpdateVCamera()
	print("UpdateVCameraUpdateVCamera~~~~~~~~~~~~~~~~")

	if self.OpenFromRole then
		self.OpenFromRole = false

		return
	end

	FingerGesturesUtil.Disable()
	TimerMgr.AddTimer(eTimerType.RealTime, 1.2, function()
		FingerGesturesUtil.Enable()
	end, {
		1
	})

	if self.actor then
		self.actor:Destroy()

		self.actor = nil
	end

	self.lightDir.transform:DORotateQuaternion(self.lightDefaultDir, 0.6)

	if self.VirtualCameras[6] then
		self.VirtualCameras[6]:SetActive(false)

		if self.VirtualCameras[self.CurrentCameraIndex] then
			self.VirtualCameras[self.CurrentCameraIndex]:SetActive(false)
		end

		self.ObservationCamera:SetActive(true)

		self.CurrentCameraIndex = 0
	end

	local index = self.rolePosIndex

	for i = 1, #self.listSeat do
		if i ~= index and self.Actors[i] then
			self.Actors[i].Root:SetActive(true)

			globalInterAniState = "idleState"

			self.Actors[i].MotionSystem:CrossFade("Idle", 0.1)
			self.Actors[i]:ResetBehaviour()

			if self.listTempPart[i] ~= nil then
				self.Actors[i].AvatarSystem:PutOn(self.listTempPart[i])
			end
		end
	end

	for i = 1, #self.listMapObjLocation do
		self.listMapObjLocation[i]:SetActive(true)
	end

	if self.Actors[index] then
		self.Actors[index].Root:SetActive(true)

		globalInterAniState = "idleState"

		local function onCrossFadeComplete()
			if self.listTempPart[index] ~= nil then
				self.Actors[index].AvatarSystem:PutOn(self.listTempPart[index])
			end
		end

		self.Actors[index].MotionSystem:CrossFadeInFixedTime("Idle", 0.5, onCrossFadeComplete, "Base Layer")
		self.Actors[index]:ResetBehaviour()
	end

	self.inInteraction = false

	self:PostprocessBlurEnable(false)

	local max = 8
	local env = GOUtil.GetComponent(self.Scene.Object, "SceneEnvironment")

	env.ShadowSettings.ShadowDistance = max

	env:Apply()
end

function SceneMainStage:OnUpdate()
	return
end

return SceneMainStage
