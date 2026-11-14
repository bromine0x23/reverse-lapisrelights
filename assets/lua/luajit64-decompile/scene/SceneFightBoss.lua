-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Scene/SceneFightBoss.lua

require("UI/Page/PageFight/PageFight")

local battleStageData = require("luaData/BattleStage")

SceneFightBoss = class("SceneFightBoss", SceneBase, true)

function SceneFightBoss.CreateInstance()
	if not SceneFightBoss.Instance then
		SceneFightBoss.Instance = SceneFightBoss()
	end

	return SceneFightBoss.Instance
end

function SceneFightBoss.DestroyInstance()
	SceneFightBoss.Instance = nil
end

function SceneFightBoss:OnInit(vParam)
	self.GP = vParam.GP
	self.PageFight = PageFight()
	self.BattleStageData = self.GP.StageData:GetData()
	self.SceneData = SceneMgr.data[self.BattleStageData.MainSceneId]

	local SceneData = SceneMgr.data

	self.SessionScenePrefabAsset = SceneData[self.BattleStageData.SessionSceneId].Resource
	self.SoundBanks = self.BattleStageData.SoundBanks
	self.LiveSoundBank = self.BattleStageData.LiveSoundBank
	self.LiveSoundEvent = self.BattleStageData.LiveSoundEvent
	self.LiveSoundBank_Boss = self.BattleStageData.LiveSoundBankBoss
	self.LiveSoundEvent_Boss = self.BattleStageData.LiveSoundEventBoss
end

function SceneFightBoss:OnCache()
	self.PageFight:Cache()
	ResourceMgr.SubmitCache(self.SessionScenePrefabAsset, self, "SessionScenePrefab")

	for _, bankPath in ipairs(self.SoundBanks) do
		BattleConfig.LoadSoundBank(bankPath, false, false)
	end

	BattleConfig.LoadSoundBank(self.LiveSoundBank, false, false)
	BattleConfig.LoadSoundBank(self.LiveSoundBank_Boss, false, false)
	ResourceMgr.SubmitCache("Actors/Settings/CharacterScaleSettings/SCL_Fight_Normal", self, "ActorScaleSetting", ScaleSettings)
	ResourceMgr.SubmitCache("Actors/Settings/CharacterScaleSettings/SCL_Fight_LoLi", self, "ActorScaleSettingLoli", ScaleSettings)
	self.GP:Cache()
end

function SceneFightBoss:OnPurge()
	self.GP:Purge()

	for _, bankPath in ipairs(self.SoundBanks) do
		BattleConfig.UnLoadSoundBank(bankPath)
	end

	BattleConfig.UnLoadSoundBank(self.LiveSoundBank)
	BattleConfig.UnLoadSoundBank(self.LiveSoundBank_Boss)
end

function SceneFightBoss:OnDestroy()
	return
end

function SceneFightBoss:OnEnd()
	return
end

function SceneFightBoss:OnRegisterEvent()
	self.GP:OnRegisterEvent()
	Event.Instance:Add("ResetUnitParent", self.OnResetUnitParent, self)
end

function SceneFightBoss:OnUnRegisterEvent()
	self.GP:OnUnRegisterEvent()
	Event.Instance:Remove("ResetUnitParent", self.OnResetUnitParent, self)
end

function SceneFightBoss:OnUpdate()
	self.GP:Update()
end

function SceneFightBoss:OnCreate()
	self.camera = GOUtil.GetComponent(self.UnityCamera, "Camera")
	self.CinemachineBrain = GOUtil.GetComponent(self.UnityCamera, "CinemachineBrain")
	Oz.Graphics.SceneEnvironment.ForbidApplyOnFirstEnable = true
	self.SessionSceneObject = GOUtil.InstantiatePrefab(self.SessionScenePrefab, nil)
	Oz.Graphics.SceneEnvironment.ForbidApplyOnFirstEnable = false
	self.MainSceneObject = self.Scene.Object
	self.Light = GOUtil.GetComponent(GameObject.Find("Directional Light"), "Light")
	self.DefaultLightColor = self.Light.color
	self.DefaultLightRotation = self.Light.gameObject.transform.rotation
	self.liveLights = {}

	table.insert(self.liveLights, GOUtil.GetComponent(GameObject.Find("[Predeploy]/Camera/Directional Light Scene"), "Light"))
	table.insert(self.liveLights, GOUtil.GetComponent(GameObject.Find("[Predeploy]/Camera/Directional Light Chr"), "Light"))

	local root = self:GetTimelineParent(1, 1, 1)

	self.CampFxRoot = {}

	table.insert(self.CampFxRoot, GameObject.Find("[Predeploy]/CampFxLocation/1"))
	table.insert(self.CampFxRoot, GameObject.Find("[Predeploy]/CampFxLocation/2"))
	UIMgr.SwitchPanel(self.PageFight, nil, true)
	self.GP.Live:SetLights(self.Light, self.liveLights)
	self.GP:Create()
	ReferenceRoot.Instance:CollectRefrence()
end

function SceneFightBoss:ResetLight()
	self.Light.color = self.DefaultLightColor
	self.Light.gameObject.transform.rotation = self.DefaultLightRotation
end

function SceneFightBoss:CheckMainVirtualCamera(isBossWave)
	self.GP.CameraUtil:CheckMainVirtualCamera(isBossWave)
end

function SceneFightBoss:GetUnitParent(camp, locationIdx)
	if not self.UnitParent then
		self.UnitParent = {}
		self.UnitParent[1] = {}
		self.UnitParent[2] = {}

		local actorLocationNode = GameObject.Find("[Predeploy]/ActorLocation/")

		if actorLocationNode ~= nil then
			for i = 1, 5 do
				local location = GOUtil.FindChildGameObject(actorLocationNode, i)

				if location ~= nil then
					table.insert(self.UnitParent[1], location)
				else
					error("无法找到角色出生点" .. i)
				end
			end
		else
			error("无法找到预部署角色出生点")
		end

		local actorLocationNode = GameObject.Find("[Predeploy]/EnemyActorLocation/")

		if actorLocationNode ~= nil then
			for i = 1, actorLocationNode.transform.childCount do
				local location = GOUtil.FindChildGameObject(actorLocationNode, i)

				if location ~= nil then
					table.insert(self.UnitParent[2], location)
				else
					error("无法找到怪物出生点" .. i)
				end
			end
		else
			error("无法找到预部署怪物出生点")
		end
	end

	local root = self.UnitParent[camp][locationIdx]

	root = root or self.UnitParent[camp][1]

	return root.gameObject
end

function SceneFightBoss:GetTimelineParent(camp, locationIdx)
	if not self.TimeLineActorParent then
		self.TimeLineActorParent = {}
		self.TimeLineActorParent[1] = {}
		self.TimeLineActorParent[2] = {}
		self.DefaultActorParentPos = {}
		self.DefaultActorParentPos[1] = {}
		self.DefaultActorParentPos[2] = {}
		self.DefaultActorParentRotation = {}
		self.DefaultActorParentRotation[1] = {}
		self.DefaultActorParentRotation[2] = {}

		local actorLocationNode = GameObject.Find("[Predeploy]/ActorLocation/")

		if actorLocationNode ~= nil then
			for i = 1, 5 do
				local location = GOUtil.FindChildGameObject(actorLocationNode, i)

				if location ~= nil then
					table.insert(self.TimeLineActorParent[1], location)
					table.insert(self.DefaultActorParentPos[1], location.transform.position)
					table.insert(self.DefaultActorParentRotation[1], location.transform.rotation)
				else
					error("无法找到角色出生点" .. i)
				end
			end
		else
			error("无法找到预部署角色出生点")
		end

		local actorLocationNode = GameObject.Find("[Predeploy]/EnemyActorLocation/")

		if actorLocationNode ~= nil then
			for i = 1, actorLocationNode.transform.childCount do
				local location = GOUtil.FindChildGameObject(actorLocationNode, i)

				if location ~= nil then
					table.insert(self.TimeLineActorParent[2], location)
					table.insert(self.DefaultActorParentPos[2], location.transform.position)
					table.insert(self.DefaultActorParentRotation[2], location.transform.rotation)
				else
					error("无法找到怪物出生点" .. i)
				end
			end
		else
			error("无法找到预部署怪物出生点")
		end
	end

	local root = self.TimeLineActorParent[camp][locationIdx]

	root = root or self.TimeLineActorParent[camp][1]

	return root.gameObject
end

function SceneFightBoss:SetTimeLineActorParentToZero()
	for campIdx, parents in ipairs(self.TimeLineActorParent) do
		for i, parent in ipairs(parents) do
			GOUtil.SetTransformPosition(parent, 0, 0, 0)
			GOUtil.SetTransformRotation(parent, 0, 0, 0)
		end
	end
end

function SceneFightBoss:OnResetUnitParent()
	for campIdx, parents in ipairs(self.TimeLineActorParent) do
		for i, parent in ipairs(parents) do
			parent.transform.position = self.DefaultActorParentPos[campIdx][i]
			parent.transform.rotation = self.DefaultActorParentRotation[campIdx][i]
		end
	end

	for _, unit in ipairs(self.GP.Team.EnemyTeam) do
		unit:AttachToDefaultLocation()
	end

	for _, unit in ipairs(self.GP.Team.PlayerTeam) do
		unit:AttachToDefaultLocation()
	end
end

function SceneFightBoss:ShowScene(val)
	if val == EnumFight.SceneObj.Null then
		-- block empty
	elseif val == EnumFight.SceneObj.Empty then
		GOUtil.SetActive(self.MainSceneObject, false)
		GOUtil.SetActive(self.SessionSceneObject, false)
	elseif val == EnumFight.SceneObj.Main then
		GOUtil.SetActive(self.SessionSceneObject, false)
		GOUtil.SetActive(self.MainSceneObject, true)
	elseif val == EnumFight.SceneObj.Session then
		GOUtil.SetActive(self.MainSceneObject, false)
		GOUtil.SetActive(self.SessionSceneObject, true)
	end
end

return SceneFightBoss
