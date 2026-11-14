-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/TimeLine/TimeLineUtility.lua

local TimelineData = require("luaData/TimelineData")

TimeLineUtility = class("TimeLineUtility")

function TimeLineUtility:ctor(GP)
	self.GP = GP

	self:Reset()
	self:InitFunMap()
end

function TimeLineUtility:Reset()
	self.Map = {}
	self.FunMap = {}
	self.UnitFunMap = {}
end

function TimeLineUtility:Cache()
	for k, v in pairs(self.Map) do
		v:Cache()
	end
end

function TimeLineUtility:DeleteTimeLine(timeLineId)
	local timeline = self:Get(timeLineId)

	if timeline then
		timeline:Purge()
	end
end

function TimeLineUtility:Purge()
	for k, v in pairs(self.Map) do
		if v.data.IsLive == 1 then
			self.GP.Live:Purge()
		else
			v:Purge()
		end
	end

	self.Map = {}
end

function TimeLineUtility:Create()
	for i, unit in ipairs(self.GP.Team.PlayerTeam) do
		ReferenceRoot.Instance:SetDynamicName("Model " .. i, unit.ModelGUID)
		ReferenceRoot.Instance:SetDynamicName("Actor " .. i, unit.ActorGUID)
	end

	for k, v in pairs(self.Map) do
		if v.data.IsLive == 1 then
			v:Create(UnityEngine.Playables.DirectorUpdateMode.Manual, UnityEngine.Playables.DirectorWrapMode.None)
			self.GP.Live:Create(v:GetGameObject(), v.timeLine)
		else
			v:Create()
		end

		v:Rebind()
	end
end

function TimeLineUtility:Register(timeLineId, directorWrapMode)
	if timeLineId == 0 then
		return
	end

	if self.Map[tostring(timeLineId)] then
		return
	end

	local timeLine = TimeLineBase(timeLineId, directorWrapMode)

	self.Map[tostring(timeLineId)] = timeLine
end

function TimeLineUtility:CreateImmediately(timeLineId, directorWrapMode)
	self:Register(timeLineId, directorWrapMode)

	local timeline = self:Get(timeLineId)

	timeline:CreateImmediately()
end

function TimeLineUtility:CreateAsync(timeLineId, directorWrapMode, callback)
	self:Register(timeLineId, directorWrapMode)

	local timeline = self:Get(timeLineId)

	timeline:CreateAsync(callback)
end

function TimeLineUtility:Get(timeLineId)
	return self.Map[tostring(timeLineId)]
end

function TimeLineUtility:Play(timeLineId, onComplete)
	local timeLine = self:Get(timeLineId)

	if timeLine then
		timeLine:Play(onComplete)
	else
		print("timeLine not regist !!!  timeLineId = " .. tostring(timeLineId))

		if onComplete then
			onComplete()
		end
	end
end

function TimeLineUtility:PlayCenterOpeningBossLive(timeLineId, units, callback)
	local timeLine = self.GP.TimeLine:Get(timeLineId)
	local enter = {
		TimeLineAnim = true,
		GazeAtCamera = true,
		Model = true,
		Light = false,
		ApplyScale = true,
		EnemyActive = false,
		Scene = EnumFight.SceneObj.Main
	}
	local exit = {
		TimeLineAnim = false,
		GazeAtCamera = false,
		Model = false,
		Light = false,
		ApplyScale = false,
		EnemyActive = true
	}

	self.GP.Live:ActiveLiveLight(true)
	self:ApplyCfg(enter, units)
	self:SetPlayersActive(false)
	units[3]:SetActive(true)
	timeLine:Rebind()
	timeLine:Play(function()
		self:ApplyCfg(exit, units)

		if callback then
			callback()
		end
	end)
end

function TimeLineUtility:PlayCenterOpening(timeLineId, unit, callback)
	local timeLine = self.GP.TimeLine:Get(timeLineId)
	local enter = {
		Light = false,
		TakeOffWeapon = true,
		Model = true,
		EnemyActive = false,
		Camera = false,
		TimeLineAnim = true,
		GazeAtCamera = true,
		PlayerActive = false,
		ApplyScale = true
	}
	local exit = {
		Light = true,
		TakeOffWeapon = false,
		Model = false,
		EnemyActive = false,
		Camera = true,
		TimeLineAnim = false,
		GazeAtCamera = false,
		PlayerActive = true,
		ApplyScale = false
	}

	self:ApplyCfg(enter, {
		unit
	})
	timeLine:Rebind()
	timeLine:Play(function()
		self:ApplyCfg(exit, {
			unit
		})

		if callback then
			callback()
		end
	end)
end

function TimeLineUtility:PlayGameOverBossLive(timeLineId, units, callback)
	local timeLine = self.GP.TimeLine:Get(timeLineId)
	local enter = {
		TimeLineAnim = true,
		GazeAtCamera = true,
		Model = true,
		Light = false,
		EnemyActive = false,
		Scene = EnumFight.SceneObj.Main
	}
	local exit = {
		TimeLineAnim = false,
		Model = false,
		GazeAtCamera = false,
		Light = true,
		EnemyActive = true
	}

	self.GP.Live:ActiveLiveLight(true)
	self:ApplyCfg(enter, units)
	timeLine:Rebind()
	timeLine:Play(function()
		self:ApplyCfg(exit, units)

		if callback then
			callback()
		end
	end)
end

function TimeLineUtility:PlayGameOver(timeLineId, unit, callback)
	local timeLine = self.GP.TimeLine:Get(timeLineId)
	local enter = {
		TimeLineAnim = true,
		GazeAtCamera = true,
		PlayerActive = false,
		Model = true,
		TakeOffWeapon = true,
		Light = false,
		EnemyActive = false,
		Camera = false
	}
	local exit = {
		TimeLineAnim = false,
		GazeAtCamera = false,
		PlayerActive = true,
		Model = false,
		TakeOffWeapon = false,
		Light = true,
		EnemyActive = true,
		Camera = true
	}

	self:ApplyCfg(enter, {
		unit
	})
	timeLine:Rebind()
	timeLine:Play(function()
		self:ApplyCfg(exit, {
			unit
		})

		if callback then
			callback()
		end
	end)
end

function TimeLineUtility:PlayAppear(timeLineId, callback)
	local _scene = EnumFight.SceneObj.Main

	if SceneMgr.GetCurrentScene().GP.FightMode == EnumFight.BattleType.BOSS then
		_scene = EnumFight.SceneObj.Session
	end

	local enter = {
		EnemyActive = false,
		PlayerActive = false,
		Scene = _scene
	}

	self:ApplyCfg(enter, {})

	local timeLine = self.GP.TimeLine:Get(timeLineId)

	timeLine:Play(function()
		local exit = {
			EnemyActive = true,
			PlayerActive = true,
			Scene = _scene
		}

		self:ApplyCfg(exit, {})

		if callback then
			callback()
		end
	end)
end

function TimeLineUtility:PlayCutIn(sessionType, uniqueIds, callback)
	if self.GP.SkipTimelineMode == true then
		callback()

		return
	end

	local enter = {
		PlayerActive = false,
		GazeAtCamera = true,
		EnemyActive = false,
		Light = false
	}
	local exit = {
		Light = true,
		GazeAtCamera = false,
		EnemyActive = true
	}
	local _list = {}

	for i, uniqueId in ipairs(uniqueIds) do
		local unit = UnitActor.FindUnitById(uniqueId)

		if unit.WeaponData.Weapon == "Hammer" then
			table.insert(_list, 1, unit)
		else
			table.insert(_list, unit)
		end
	end

	self:ApplyCfg(enter, _list)

	local count = #uniqueIds
	local sceneAllRoots = SceneMgr.GetCurrentScene():GetSessionPoint()
	local roots = sceneAllRoots[count]
	local keys = {
		"Session1P",
		"Session2P",
		"Session3P",
		"Session4P"
	}
	local key = keys[count]
	local timeLineId = self.GP.StageData:GetDataByKey(key)[1]
	local timeLine = self.GP.TimeLine:Get(timeLineId)

	for i, unit in ipairs(_list) do
		unit:SetActive(true)

		if roots[i] then
			unit:GazeAtCamera(true)
			unit:AttachGameObject(roots[i].gameObject)

			local total_s = BattleConfig.CutinPoseData[#_list].total_s
			local play = BattleConfig.CutinPoseData[#_list].play[i]
			local animState = BattleConfig.CutinPoseData[#_list].anim[i]

			unit:Play(animState)
			unit.Actor.MotionSystem:Pause()
			unit:EnterTimeLineSet()
			BattleConfig.Delay(play * total_s, function()
				unit.Actor.MotionSystem:Resume()
			end)
		end

		ReferenceRoot.Instance:SetDynamicName("Model " .. i, unit.ModelGUID)
		ReferenceRoot.Instance:SetDynamicName("Actor " .. i, unit.ActorGUID)
	end

	local effsGo = GOUtil.FindChildGameObject(timeLine:GetGameObject(), "Eff_Session_pose")

	if effsGo then
		for i = 1, effsGo.transform.childCount do
			local go = effsGo.transform:GetChild(i - 1).gameObject

			GOUtil.SetActive(go, i == sessionType)
		end
	end

	timeLine:Rebind()
	timeLine:Play(function()
		self:ApplyCfg(exit, _list)
		self:OnPlayCutInEnd(sessionType, uniqueIds)

		if callback then
			callback()
		end
	end)
end

function TimeLineUtility:OnPlayCutInEnd(sessionType, uniqueIds)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUICutInSession", false)

	for i, unit in ipairs(self.GP.Team.PlayerTeam) do
		unit.Actor.MotionSystem:Resume()
		unit:GazeAtCamera(false)

		if self.GP.PVPMode == false then
			unit:SetActive(true)
		end

		unit:Play("Idle")
		unit:LeaveTimeLineSet()

		local roots = SceneMgr.GetCurrentScene():GetPlayerParent()

		unit:AttachGameObject(roots[i])
	end

	local sessionCfg = require("luaData/SessionData")
	local sessionCfgData = sessionCfg[sessionType]

	BattleConfig.Delay(sessionCfgData.PoseStateWaitTime, function()
		for i, uniqueId in ipairs(uniqueIds) do
			local unit = UnitActor.FindUnitById(uniqueId)

			BattleConfig.FxAlloc(sessionCfg[sessionType].PoseFx, unit)
		end
	end)
end

function TimeLineUtility:PlaySkill(skillcfg, unit, callback)
	local timeLineId = skillcfg.TimeLineID

	if not timeLineId or timeLineId == 0 then
		print("PlaySkill failed , timelineId = " .. tostring(timeLineId))

		if callback then
			callback()
		end

		return
	end

	if self.GP.TimeLine:Get(timeLineId) == nil then
		if callback then
			callback()
		end

		return
	end

	if self.GP.SkipTimelineMode == true then
		local bossAppearInLive = self.GP.FightMode == EnumFight.BattleType.BOSS and unit.UnitClass == EnumFight.Camp.ENEMY and self.GP.RoundData.CurRound == nil

		if bossAppearInLive then
			local enter_enemy = {
				EnemyActive = false,
				PlayerActive = false,
				ShowUI = false,
				Light = false,
				Camera = false,
				Scene = EnumFight.SceneObj.Empty
			}

			self:ApplyCfg(enter_enemy, {
				unit
			})

			local exit_enemy = {
				EnemyActive = true,
				PlayerActive = false,
				ShowUI = true,
				Light = true,
				Camera = true,
				Scene = EnumFight.SceneObj.Session
			}

			self:ApplyCfg(exit_enemy, {
				unit
			})
		end

		if callback then
			callback()
		end

		return
	end

	local enter_player = {
		Model = true,
		EnemyActive = false,
		PositionToZero = true,
		TakeOffWeapon = true,
		Zlimit = false,
		Light = false,
		Camera = false,
		TimeLineAnim = true,
		GazeAtCamera = false,
		PlayerActive = false,
		ApplyScale = true,
		Scene = EnumFight.SceneObj.Empty
	}
	local sceneForEnemy = EnumFight.SceneObj.Main

	if SceneMgr.GetCurrentScene().GP.FightMode == EnumFight.BattleType.BOSS then
		sceneForEnemy = EnumFight.SceneObj.Session
	end

	local enter_enemy = {
		EnemyActive = false,
		PlayerActive = false,
		ShowUI = false,
		Light = false,
		Camera = false,
		Scene = EnumFight.SceneObj.Empty
	}
	local timeLine = self.GP.TimeLine:Get(timeLineId)

	if unit.UnitClass == EnumFight.Camp.PLAYER then
		self:ApplyCfg(enter_player, {
			unit
		})
		unit:SetIKAnimatorController()
	else
		self:ApplyCfg(enter_enemy, {
			unit
		})
	end

	timeLine:Rebind()
	timeLine:Play(function()
		Event.Instance:Fire("UnitVocalEvent_SkillTimeline", UnitVocal.enType.SkillTimeline, skillcfg, false, unit)
		self:OnPlaySkillEnd(unit, callback)
	end)
	Event.Instance:Fire("UnitVocalEvent_SkillTimeline", UnitVocal.enType.SkillTimeline, skillcfg, true, unit)
end

function TimeLineUtility:PlaySkillCamera(timeLineId, callback)
	if not timeLineId or timeLineId == 0 then
		print("PlaySkillCamera failed , timelineId = " .. tostring(timeLineId))

		if callback then
			callback()
		end

		return
	end

	if self.GP.SkipTimelineMode == true then
		if callback then
			callback()
		end

		return
	end

	local timeLine = self.GP.TimeLine:Get(timeLineId)

	if timeLine then
		timeLine:Rebind()
		timeLine:Play(function()
			if callback then
				callback()
			end
		end)
	elseif callback then
		callback()
	end
end

function TimeLineUtility:OnPlaySkillEnd(unit, callback)
	local exit_player = {
		EnemyActive = true,
		Model = false,
		PositionToZero = false,
		TakeOffWeapon = false,
		Zlimit = true,
		Light = true,
		Camera = true,
		TimeLineAnim = false,
		GazeAtCamera = false,
		ApplyScale = false,
		Scene = EnumFight.SceneObj.Main
	}
	local exit_enemy = {
		EnemyActive = true,
		PlayerActive = true,
		ShowUI = true,
		Light = true,
		Camera = true,
		Scene = EnumFight.SceneObj.Main
	}

	if self.GP.FightMode == EnumFight.BattleType.BOSS then
		exit_enemy = {
			EnemyActive = true,
			PlayerActive = false,
			ShowUI = true,
			Light = true,
			Camera = true,
			Scene = EnumFight.SceneObj.Session
		}
	end

	if self.GP.PVPMode == true then
		unit:SetActive(true)
	else
		self.GP.Team:SetActive(1, true)
	end

	if SceneMgr.GetCurrentScene().Scene.FogSetting then
		RenderSettings.fog = SceneMgr.GetCurrentScene().Scene.FogSetting.m_Fog
	end

	if unit.UnitClass == EnumFight.Camp.PLAYER then
		self:ApplyCfg(exit_player, {
			unit
		})
	else
		self:ApplyCfg(exit_enemy, {
			unit
		})
	end

	if callback then
		callback()
	end
end

function TimeLineUtility:CamFlash(complete)
	local timeLineId = self.GP.StageData:GetDataByKey("CamFlash")
	local timeLine = self.GP.TimeLine:Get(timeLineId)

	timeLine:Play()

	if complete then
		BattleConfig.Delay(0.65, complete)
	end
end

function TimeLineUtility:PlaySession(timeLineId, sessionType, uniqueIds, callback)
	if self.GP.SkipTimelineMode == true then
		self.GP.CameraUtil:EnterBossLiveSession(true)
		self.GP.Team:SetActive(EnumFight.Camp.ENEMY, true)
		self:SetLightActive(true)

		if callback then
			callback()
		end

		return
	end

	local enter = {
		TimeLineAnim = true,
		GazeAtCamera = false,
		PlayerActive = false,
		Model = true,
		Light = false,
		EnemyActive = false,
		Camera = false
	}
	local exit = {
		TimeLineAnim = false,
		GazeAtCamera = false,
		PlayerActive = true,
		Model = false,
		Light = true,
		EnemyActive = true,
		Camera = true
	}
	local units = {}

	for i, uniqueId in ipairs(uniqueIds) do
		table.insert(units, UnitActor.FindUnitById(uniqueId))
	end

	local timeLine = self.GP.TimeLine:Get(timeLineId)

	local function completeCallback()
		self:ApplyCfg(exit, units)
		self.GP.CameraUtil:EnterBossLiveSession(true)

		if callback then
			callback()
		end
	end

	self:ApplyCfg(enter, units)
	timeLine:Rebind()
	timeLine:Play(completeCallback, nil, -1)
end

function TimeLineUtility:SetScene(val)
	Event.Instance:Fire("EVENT_SWITCH_SCENE", val)
end

function TimeLineUtility:SetLightActive(val)
	if not SceneMgr.GetCurrentScene().Light then
		return
	end

	GOUtil.SetActive(SceneMgr.GetCurrentScene().Light.gameObject, val)
end

function TimeLineUtility:SetCameraActive(val)
	GOUtil.SetActive(SceneMgr.GetCurrentScene().UnityCamera, val)
end

function TimeLineUtility:SetPlayersActive(val)
	self.GP.Team:SetActive(EnumFight.Camp.PLAYER, val)
end

function TimeLineUtility:SetEnemysActive(val)
	self.GP.Team:SetActive(EnumFight.Camp.ENEMY, val)
end

function TimeLineUtility:SetTimeLineAnim(val, unit)
	unit:EnableAnimatorController(not val)
end

function TimeLineUtility:SetGazeAtCamera(val, unit)
	unit:GazeAtCamera(val == true)
end

function TimeLineUtility:SetApplyScale(val, unit)
	unit:ApplyGeneralScaleSetting(val)
end

function TimeLineUtility:SetModel(val, unit, i)
	if val == true then
		SceneMgr.GetCurrentScene():SetTimeLineActorParentToZero()
		unit:SetActive(true)
		ReferenceRoot.Instance:SetDynamicName("Model " .. i, unit.ModelGUID)
		ReferenceRoot.Instance:SetDynamicName("Actor " .. i, unit.ActorGUID)
		unit:AttachToTimelineLocation(i)
		unit:EnterTimeLineSet()
	else
		Event.Instance:Fire("ResetUnitParent")
		unit:AttachToDefaultLocation()
		unit:SetLocalPositionToZero()
		unit:LeaveTimeLineSet()
	end
end

function TimeLineUtility:SetPositionToZero(val, unit, i)
	if val == true then
		SceneMgr.GetCurrentScene():SetTimeLineActorParentToZero()
	else
		Event.Instance:Fire("ResetUnitParent")
	end
end

function TimeLineUtility:SetTakeOffWeapon(val, unit)
	if self.GP.FightMode == EnumFight.BattleType.BOSS then
		return
	end

	if val == true then
		unit:TakeOffWeapon()
	else
		unit:PutOnWeapon()
	end
end

function TimeLineUtility:SetSrpingBoneZlimit(val, unit)
	unit:SetSrpingBoneZlimit(val)
end

function TimeLineUtility:SetShowUI(val)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator", val)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", val)
end

function TimeLineUtility:RegisterFun(key, fun)
	self.FunMap[key] = fun
end

function TimeLineUtility:RegisterUnitFun(key, fun)
	self.UnitFunMap[key] = fun
end

function TimeLineUtility:InitFunMap()
	self.FunMap = {}
	self.UnitFunMap = {}

	self:RegisterFun("Scene", self.SetScene)
	self:RegisterFun("Light", self.SetLightActive)
	self:RegisterFun("Camera", self.SetCameraActive)
	self:RegisterFun("PlayerActive", self.SetPlayersActive)
	self:RegisterFun("EnemyActive", self.SetEnemysActive)
	self:RegisterFun("ShowUI", self.SetShowUI)
	self:RegisterUnitFun("TimeLineAnim", self.SetTimeLineAnim)
	self:RegisterUnitFun("GazeAtCamera", self.SetGazeAtCamera)
	self:RegisterUnitFun("ApplyScale", self.SetApplyScale)
	self:RegisterUnitFun("Model", self.SetModel)
	self:RegisterUnitFun("PositionToZero", self.SetPositionToZero)
	self:RegisterUnitFun("TakeOffWeapon", self.SetTakeOffWeapon)
	self:RegisterUnitFun("Zlimit", self.SetSrpingBoneZlimit)
end

local opening_boss_enter = {
	TimeLineAnim = false,
	PlayerActive = false,
	EnemyActive = false,
	GazeAtCamera = true,
	Light = false,
	Camera = true,
	Scene = EnumFight.SceneObj.Main
}
local opening_boss_exit = {
	TimeLineAnim = true,
	PlayerActive = false,
	EnemyActive = false,
	GazeAtCamera = false,
	Light = true,
	Camera = true,
	Scene = EnumFight.SceneObj.Main
}

function TimeLineUtility:ApplyCfg(cfg, units)
	local unitFunKeyStore = {}

	for key, val in pairs(cfg) do
		local fun = self.FunMap[key]

		if fun then
			fun(self, val)
		else
			local _data = {
				key = key,
				val = val
			}

			table.insert(unitFunKeyStore, _data)
		end
	end

	for i, unit in ipairs(units) do
		for j, _data in ipairs(unitFunKeyStore) do
			local fun = self.UnitFunMap[_data.key]

			if fun then
				fun(self, _data.val, unit, i)
			else
				print("ERROR, TimeLineUtility:ApplyCfg not define function , key:" .. _data.key)
			end
		end
	end
end
