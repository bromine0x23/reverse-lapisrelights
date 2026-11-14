-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Scene/SceneFightNormal.lua

require("UI/Page/PageFight/PageFight")

local battleStageData = require("luaData/BattleStage")

SceneFightNormal = class("SceneFightNormal", SceneBase, true)

function SceneFightNormal.CreateInstance()
	if not SceneFightNormal.Instance then
		SceneFightNormal.Instance = SceneFightNormal()
	end

	return SceneFightNormal.Instance
end

function SceneFightNormal.DestroyInstance()
	SceneFightNormal.Instance = nil
end

function SceneFightNormal:OnInit(vParam)
	self.GP = vParam.GP
	self.PageFight = PageFight()
	self.BattleStageData = self.GP.StageData:GetData()
	self.SceneData = SceneMgr.data[self.BattleStageData.MainSceneId]

	local SceneData = SceneMgr.data

	if self.BattleStageData.BossSceneId ~= 0 then
		self.BossScenePrefabAsset = SceneData[self.BattleStageData.BossSceneId].Resource
	end

	self.SoundBanks = self.BattleStageData.SoundBanks
	self.LiveSoundBank = self.BattleStageData.LiveSoundBank
	self.LiveSoundEvent = self.BattleStageData.LiveSoundEvent
	self.LiveSoundBank_Boss = self.BattleStageData.LiveSoundBankBoss
	self.LiveSoundEvent_Boss = self.BattleStageData.LiveSoundEventBoss
	self.FightBgm = ""
end

function SceneFightNormal:OnCache()
	self.PageFight:Cache()

	if self.BattleStageData.BossSceneId ~= 0 then
		ResourceMgr.SubmitCache(self.BossScenePrefabAsset, self, "BossScenePrefab")
	end

	for _, bankPath in ipairs(self.SoundBanks) do
		BattleConfig.LoadSoundBank(bankPath, false, false)
	end

	BattleConfig.LoadSoundBank(self.LiveSoundBank, false, false)
	BattleConfig.LoadSoundBank(self.LiveSoundBank_Boss, false, false)
	ResourceMgr.SubmitCache("Actors/Settings/CharacterScaleSettings/SCL_Fight_Normal", self, "ActorScaleSetting", ScaleSettings)
	ResourceMgr.SubmitCache("Actors/Settings/CharacterScaleSettings/SCL_Fight_LoLi", self, "ActorScaleSettingLoli", ScaleSettings)
	self.GP:Cache()
end

function SceneFightNormal:OnPurge()
	self.GP:Purge()

	for _, bankPath in ipairs(self.SoundBanks) do
		BattleConfig.UnLoadSoundBank(bankPath)
	end

	BattleConfig.UnLoadSoundBank(self.LiveSoundBank)
	BattleConfig.UnLoadSoundBank(self.LiveSoundBank_Boss)
end

function SceneFightNormal:OnDestroy()
	return
end

function SceneFightNormal:OnEnd()
	return
end

function SceneFightNormal:OnRegisterEvent()
	self.GP:OnRegisterEvent()
	Event.Instance:Add("子弹-发射", self.BulletLuanch, self)
	Event.Instance:Add("子弹-爆炸", self.BulletDelete, self)
	Event.Instance:Add("ResetUnitParent", self.OnResetUnitParent, self)
end

function SceneFightNormal:OnUnRegisterEvent()
	self.GP:OnUnRegisterEvent()
	Event.Instance:Remove("子弹-发射", self.BulletLuanch, self)
	Event.Instance:Remove("子弹-爆炸", self.BulletDelete, self)
	Event.Instance:Remove("ResetUnitParent", self.OnResetUnitParent, self)
end

function SceneFightNormal:OnUpdate()
	self.GP:Update()

	if self.IsUpdataBullet == true then
		for i, bullet in ipairs(self.UpdataBullets) do
			bullet:Update()
		end
	end
end

function SceneFightNormal:OnCreate()
	self.IsUpdataBullet = false
	self.UpdataBullets = {}
	self.camera = GOUtil.GetComponent(SceneMgr.GetCurrentScene().UnityCamera, "Camera")
	self.CinemachineBrain = GOUtil.GetComponent(self.UnityCamera, "CinemachineBrain")

	if self.BattleStageData.BossSceneId ~= 0 then
		Oz.Graphics.SceneEnvironment.ForbidApplyOnFirstEnable = true
		self.BossSceneObject = GOUtil.InstantiatePrefab(self.BossScenePrefab, nil)
		Oz.Graphics.SceneEnvironment.ForbidApplyOnFirstEnable = false

		GOUtil.SetActive(self.BossSceneObject, false)
	end

	self.MainSceneObject = self.Scene.Object
	self.Light = GOUtil.GetComponent(GameObject.Find("Directional Light"), "Light")
	self.DefaultLightColor = self.Light.color
	self.DefaultLightRotation = self.Light.gameObject.transform.rotation

	local root = self:GetTimelineParent(1, 1, 1)

	self.CampFxRoot = {}

	table.insert(self.CampFxRoot, GameObject.Find("[Predeploy]/CampFxLocation/1"))
	table.insert(self.CampFxRoot, GameObject.Find("[Predeploy]/CampFxLocation/2"))
	UIMgr.SwitchPanel(self.PageFight, nil, true)
	self.GP:Create()
	ReferenceRoot.Instance:CollectRefrence()
end

function SceneFightNormal:ChangeMainScene(sceneId)
	if not SceneMgr.data[sceneId] then
		return
	end

	local path = SceneMgr.data[sceneId].Resource
	local prefab = ResourceMgr.LoadSync(path, GameObject)

	if not prefab then
		return
	end

	Object.Destroy(self.MainSceneObject)

	local obj = GOUtil.InstantiatePrefab(prefab, GameObject.Find("[Predeploy]"))

	self.MainSceneObject = obj
	self.Scene.Object = obj
end

function SceneFightNormal:ResetLight()
	self.Light.color = self.DefaultLightColor
	self.Light.gameObject.transform.rotation = self.DefaultLightRotation
end

function SceneFightNormal:PlayBgm()
	if self.FightBgm ~= "" then
		BattleConfig.PostSoundEvent(self.FightBgm, self.UnityCamera)
	end
end

function SceneFightNormal:CheckMainVirtualCamera(isBossWave)
	if isBossWave == false then
		if self.GP.WaveData.CurWave == 1 then
			self.FightBgm = self.LiveSoundEvent

			BattleConfig.PostSoundEvent(self.LiveSoundEvent, self.UnityCamera)
		end

		self.MainSceneObject = self.Scene.Object

		if self.BossSceneObject then
			GOUtil.SetActive(self.BossSceneObject, false)
		end

		GOUtil.SetActive(self.Scene.Object, true)
	else
		self.FightBgm = self.LiveSoundEvent_Boss

		BattleConfig.PostSoundEvent(self.LiveSoundEvent_Boss, self.UnityCamera)
		GOUtil.SetActive(self.Scene.Object, false)

		self.MainSceneObject = self.BossSceneObject

		if self.BossSceneObject then
			GOUtil.SetActive(self.BossSceneObject, true)
		end

		self.CampFxRoot[2].transform.position = self.UnitParent[2][6].transform.position

		GOUtil.SetTransformLocalScale(self.CampFxRoot[2].gameObject, 2)
	end

	self.GP.CameraUtil:CheckMainVirtualCamera(isBossWave)
end

function SceneFightNormal:GetUnitParent(camp, locationIdx)
	if not self.UnitParent then
		self.UnitParent = {}
		self.UnitParent[1] = {}
		self.UnitParent[2] = {}

		local actorLocationNode

		if self.GP.GameStartData.pvp ~= EnumFight.Pvp.NORMAL then
			actorLocationNode = GameObject.Find("[Predeploy]/DefaultPlayerLocation/")
		else
			actorLocationNode = GameObject.Find("[Predeploy]/PvpDefaultPlayerLocation/")
		end

		if actorLocationNode ~= nil then
			for i = 1, actorLocationNode.transform.childCount do
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

		actorLocationNode = nil

		if self.GP.GameStartData.pvp ~= EnumFight.Pvp.NORMAL then
			actorLocationNode = GameObject.Find("[Predeploy]/DefaultEnemyLocation/")
		else
			actorLocationNode = GameObject.Find("[Predeploy]/PvpDefaultEnemyLocation/")
		end

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

function SceneFightNormal:GetTimelineParent(camp, locationIdx)
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
			for i = 1, actorLocationNode.transform.childCount do
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

function SceneFightNormal:GetPlayerParent()
	return self.UnitParent[1]
end

function SceneFightNormal:SetTimeLineActorParentToZero()
	for campIdx, parents in ipairs(self.TimeLineActorParent) do
		for i, parent in ipairs(parents) do
			GOUtil.SetTransformPosition(parent, 0, 0, 0)
			GOUtil.SetTransformRotation(parent, 0, 0, 0)
		end
	end
end

function SceneFightNormal:OnResetUnitParent()
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

function SceneFightNormal:InitSessionPoint()
	self.SessionRootParent = {}

	local actorLocationNode = GameObject.Find("[Predeploy]/SessionLocation/")

	if actorLocationNode ~= nil then
		for i = 1, actorLocationNode.transform.childCount do
			local location = actorLocationNode.transform:GetChild(i - 1)

			if location ~= nil then
				local childRoots = {}

				for j = 1, location.transform.childCount do
					local ele = location.transform:GetChild(j - 1)

					table.insert(childRoots, ele)
				end

				table.insert(self.SessionRootParent, childRoots)
			end
		end
	end
end

function SceneFightNormal:GetSessionPoint()
	if not self.SessionRootParent then
		self:InitSessionPoint()
	end

	return self.SessionRootParent
end

function SceneFightNormal:ShowScene(val)
	if val == EnumFight.SceneObj.Null then
		-- block empty
	elseif val == EnumFight.SceneObj.Empty then
		GOUtil.SetActive(self.MainSceneObject, false)
	elseif val == EnumFight.SceneObj.Main then
		GOUtil.SetActive(self.MainSceneObject, true)
	end
end

function SceneFightNormal:BulletLuanch(_bullet)
	self.IsUpdataBullet = true

	table.insert(self.UpdataBullets, _bullet)
end

function SceneFightNormal:BulletDelete(_bullet)
	for i, bullet in ipairs(self.UpdataBullets) do
		if bullet.UniqueId == _bullet.UniqueId then
			table.remove(self.UpdataBullets, i)

			break
		end
	end

	if #self.UpdataBullets == 0 then
		self.IsUpdataBullet = false
	end
end

return SceneFightNormal
