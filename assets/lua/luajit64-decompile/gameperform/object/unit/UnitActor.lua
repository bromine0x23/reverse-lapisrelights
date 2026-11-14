-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/Object/Unit/UnitActor.lua

local print_enable = false
local print = function(...)
	if print_enable == true then
		print(...)
	end
end
local _ActorData = require("luaData/ActorData")
local CharacterCfg = require("luaData/CharacterRole")
local CharacterCardCfg = require("luaData/CharacterCard")
local DropGroupTool = require("GamePerform.DropGroupTool")
local InfoTeam = require("Info/InfoTeam")

UnitActor = class("UnitActor")
UnitActor.UnitDic = {}

function UnitActor.Init()
	UnitActor.UnitDic = {}
end

function UnitActor.Clear()
	UnitActor.UnitDic = {}
end

function UnitActor.AddToMap(unit)
	UnitActor.UnitDic[unit.UniqueId] = unit
end

function UnitActor.Delete(unit)
	UnitActor.UnitDic[unit.UniqueId] = nil
end

function UnitActor.FindUnitById(uniqueId)
	return UnitActor.UnitDic[uniqueId]
end

function UnitActor:ctor(GP, msg)
	if not GP or not msg then
		return
	end

	self:Reset()

	self.GP = GP
	self.UnitId = msg.unitId
	self.Camp = msg.camp
	self.WeaponId = msg.weaponId
	self.WeaponAvatar = msg.weaponAvatar
	self.ListAvatarID = msg.listAvatarID
	self.Order = msg.order
	self.Wave = msg.wave
	self.IsCenter = msg.isCenter
	self.IsAnimPause = false
	self.UnitClass = msg.unitClass
	self.TeamIndex = self.Order
	self.RoleId = self.UnitId

	if msg.isSummon then
		self.IsSummon = msg.isSummon
		self.UnitClass = EnumFight.UnitClass.ENEMY
	end

	if self.UnitClass == EnumFight.UnitClass.PLAYER then
		self.CardId = msg.cardId

		self:InitPlayer()
	elseif self.UnitClass == EnumFight.UnitClass.PVPPLAYER then
		self.CardId = msg.cardId

		self:InitPlayer()
	elseif self.UnitClass == EnumFight.UnitClass.ENEMY then
		self:InitMonster()
	end

	self:InitTimeLine()

	for i, skillInfo in ipairs(msg.skills) do
		local skillId = skillInfo[1]
		local skillLv = skillInfo[2]

		self:AddSkill(skillId, skillLv)
	end

	self.GP.PrewarmUtil:AddUnit(self)
end

function UnitActor:ResetData()
	self.IsDead = false
	self.IsMoving = false
	self.Pos = Vector3(0, 0, 0)
	self.MovePos = Vector3(0, 0, 0)
	self.Start = Vector3(0, 0, 0)
	self.TeamIndex = -1
	self.CurSessionType = 0
	self.LastAngryStage = 0
	self.NotAction = false
	self.ActionSkillId = -1
	self.IsStun = false
	self.DefenseStun = false
	self.DisableCardSkill = false
	self.NextCastSkill = 0
	self.CurRoundSessionType = 0
	self.IsCenter = false
	self.IsAnimPause = false
end

function UnitActor:Reset()
	self:ResetData()

	self.GP = nil
	self.IsSummon = false
	self.UniqueId = ""
	self.IsDelete = true
	self.UniqueId = ""
	self.IsBoss = false
	self.Actor = nil
	self.ActorRoot = nil
	self.UnitId = 0
	self.RoleId = 0
	self.UnitClass = 0
	self.UnitTitle = ""
	self.UnitData = nil
	self.AttributeMap = {}
	self.WeaponData = nil
	self.Buffs = {}
	self.MoveSpeed = 0
	self.Collider = nil
	self.WeaponAvatarPart = nil
	self.MoveCurve_Attack = {}
	self.MoveCurve_Attack[EnumBattle.MoveState.GO] = nil
	self.MoveCurve_Attack[EnumBattle.MoveState.BACK] = nil
	self.MoveCurve_Thump = {}
	self.MoveCurve_Thump[EnumBattle.MoveState.GO] = nil
	self.MoveCurve_Thump[EnumBattle.MoveState.BACK] = nil
	self.OwnSkills = {}
	self.ActiveSkills = {}
	self.PassiveSkills = {}
	self.CenterSkills = {}
	self.ActorSkeletonRoot = nil
	self.ModelGUID = nil
	self.ActorGUID = nil
	self.InfoRoleCard = nil
	self.SelectEffect = nil
	self.Buffs = {}
	self.BuffMap = {}
	self.HeadTipUI = nil
	self.SelectEffPrefab = nil
	self.SelectEffect = nil
	self.ActorRadius = 0
	self.ActorLipSync = nil
end

function UnitActor:SetUniqueId(uid)
	self.UniqueId = uid

	UnitActor.AddToMap(self)
end

function UnitActor:SetAttri(key, val)
	self.AttributeMap[key] = val
end

function UnitActor:GetAttri(key)
	return self.AttributeMap[key]
end

function UnitActor:InitPlayer()
	self.UnitData = {}
	self.UnitData.data = CharacterCfg[self.UnitId]

	local actorID = self.UnitData.data.ActorID

	self.UnitTitle = Lang(self.UnitData.data.Name)

	local cardId = self.CardId

	if cardId ~= 0 then
		self.InfoRoleCard = {}
		self.InfoRoleCard.data = CharacterCardCfg[self.CardId]

		BattleConfig.LoadSoundBank(self.UnitData.data.VocalBank, false, false)
	end

	local controller
	local name = ""

	if SceneMgr.GetCurrentScene().GP.FightMode == EnumFight.BattleType.NORMAL then
		self:InitWeapon(self.WeaponId, self.WeaponAvatar)

		controller = ActorUtil.MotionControllerDataFilter(actorID, "Fight@Engagement", "None")
	elseif SceneMgr.GetCurrentScene().GP.FightMode == EnumFight.BattleType.BOSS then
		name = "Battle"
		controller = ActorUtil.MotionControllerDataFilter(actorID, "Fight@Engagement", "None")
	end

	if not self.ListAvatarID or #self.ListAvatarID == 0 then
		self.ListAvatarID = {}

		for i, _avatarId in ipairs(_ActorData[self.UnitData.data.ActorID].DefaultAvatars) do
			table.insert(self.ListAvatarID, _avatarId)
		end
	end

	self.ActorFactory = ActorUtil.BuildActorFactory(actorID, self.ListAvatarID, controller)

	if not self.ActorFactory then
		print("<color=red>创建角色失败！ id:" .. self.UnitId .. "</color>")
	end

	self.MoveCurve_Attack[EnumBattle.MoveState.GO] = MoveCurveHelper("Battle/MoveCurve/MoveCurve_Melee_Light_Go")
	self.MoveCurve_Attack[EnumBattle.MoveState.BACK] = MoveCurveHelper("Battle/MoveCurve/MoveCurve_Melee_Light_Back")
	self.MoveCurve_Thump[EnumBattle.MoveState.GO] = MoveCurveHelper("Battle/MoveCurve/MoveCurve_Melee_Heavy_Go")
	self.MoveCurve_Thump[EnumBattle.MoveState.BACK] = MoveCurveHelper("Battle/MoveCurve/MoveCurve_Melee_Heavy_Back")
	self.ActorRadius = _ActorData[actorID].Radius
	self.LocationIndex = self.Order
end

function UnitActor:InitTimeLine()
	if self.IsCenter == true then
		if self.GP.FightMode == EnumFight.BattleType.BOSS then
			if self.UnitData.data.BossOpeningTimeLine and self.UnitData.data.BossOpeningTimeLine ~= 0 then
				self.GP.TimeLine:Register(self.UnitData.data.BossOpeningTimeLine)
			else
				self.GP.TimeLine:Register(self.GP.StageData:GetDataByKey("Opening"))
			end
		elseif self.UnitData.data.OpeningTimeLine ~= 0 then
			self.GP.TimeLine:Register(self.UnitData.data.OpeningTimeLine)
		else
			self.GP.TimeLine:Register(self.GP.StageData:GetDataByKey("Opening"))
		end

		if self.GP.FightMode == EnumFight.BattleType.BOSS then
			self.GP.TimeLine:Register(self.GP.StageData:GetDataByKey("Win"), UnityEngine.Playables.DirectorWrapMode.Hold)
			self.GP.TimeLine:Register(self.GP.StageData:GetDataByKey("Lose"), UnityEngine.Playables.DirectorWrapMode.Hold)
		else
			if self.UnitData.data.WinTimeLine ~= 0 then
				self.GP.TimeLine:Register(self.UnitData.data.WinTimeLine, UnityEngine.Playables.DirectorWrapMode.Hold)
			else
				self.GP.TimeLine:Register(self.GP.StageData:GetDataByKey("Win"), UnityEngine.Playables.DirectorWrapMode.Hold)
			end

			if self.UnitData.data.LoseTimeLine ~= 0 then
				self.GP.TimeLine:Register(self.UnitData.data.LoseTimeLine, UnityEngine.Playables.DirectorWrapMode.Hold)
			else
				self.GP.TimeLine:Register(self.GP.StageData:GetDataByKey("Lose"), UnityEngine.Playables.DirectorWrapMode.Hold)
			end
		end
	end
end

function UnitActor:InitWeapon(weaponId, weaponAvatarId)
	local weaponType
	local weaponData = require("luaData/Equipment")

	weaponType = weaponData[weaponId].Weapon
	self.WeaponData = weaponData[weaponId]

	if weaponType then
		local AvatarData = require("luaData/AvatarData")

		if not weaponAvatarId or weaponAvatarId == 0 then
			weaponAvatarId = self.WeaponData.Avatar
		end

		local avatarData = AvatarData[weaponAvatarId]

		self.AvaterFactory = AvatarFactory(avatarData.AvatarPath)
	end
end

function UnitActor:InitMonster()
	local monsterInfo = EnemyManager:Get(self.UnitId)

	self.UnitData = monsterInfo

	local actorID = monsterInfo.data.ActorID
	local name

	if SceneMgr.GetCurrentScene().GP.FightMode == EnumFight.BattleType.NORMAL then
		name = "Fight@Engagement"
	elseif SceneMgr.GetCurrentScene().GP.FightMode == EnumFight.BattleType.BOSS then
		name = "Battle"
	end

	local controller = ActorUtil.MotionControllerDataFilter(actorID, name, "None")

	if monsterInfo.data.PlayType == 2 then
		self.ActorFactory = ActorUtil.BuildActorFactory(actorID, nil, controller)

		local WeaponID = monsterInfo.data.WeaponID
		local weaponData = require("luaData/Equipment")

		self:InitWeapon(WeaponID, weaponData[WeaponID].Avatar)
	else
		self.ActorFactory = ActorUtil.BuildEnemyFactory(actorID, controller)
	end

	if not self.ActorFactory then
		print("<color=red>创建角色失败！ id:" .. self.UnitId .. "</color>")
	end

	self.UnitTitle = Lang(monsterInfo.data.Name)
	self.IsBoss = TenaryOp(self.UnitData.data.Boss == 1, true, false)
	self.MoveCurve_Attack[EnumBattle.MoveState.GO] = MoveCurveHelper("Battle/MoveCurve/MoveCurve_Melee_Light_Go")
	self.MoveCurve_Attack[EnumBattle.MoveState.BACK] = MoveCurveHelper("Battle/MoveCurve/MoveCurve_Melee_Light_Back")
	self.MoveCurve_Thump[EnumBattle.MoveState.GO] = MoveCurveHelper("Battle/MoveCurve/MoveCurve_Melee_Heavy_Go")
	self.MoveCurve_Thump[EnumBattle.MoveState.BACK] = MoveCurveHelper("Battle/MoveCurve/MoveCurve_Melee_Heavy_Back")
	self.ActorRadius = _ActorData[actorID].Radius

	if self.IsSummon == false then
		self.LocationIndex = self.GP.StageData:GetData().EnemyLocation[self.Wave][self.Order]
	end
end

function UnitActor:AddSkill(skillId, skillLv)
	local ownSkill = UnitOwnSkill(self, skillId, skillLv)

	table.insert(self.OwnSkills, ownSkill)
end

function UnitActor:GetOwnSkill(skillId)
	for i, skill in ipairs(self.OwnSkills) do
		if skillId == skill.Id then
			return skill
		end
	end

	return nil
end

function UnitActor:Cache()
	self.ActorFactory:Cache()

	if self.AvaterFactory then
		self.AvaterFactory:Cache()
	end

	for k, _moveCurve in pairs(self.MoveCurve_Attack) do
		_moveCurve:Cache()
	end

	for k, _moveCurve in pairs(self.MoveCurve_Thump) do
		_moveCurve:Cache()
	end

	if self.Camp == EnumFight.Camp.ENEMY then
		ResourceMgr.SubmitCache("Fx/Skill/Etc/Eff_Select/Eff_Select", self, "SelectEffPrefab")

		if self.UnitData.data.PlayType == 2 then
			ResourceMgr.SubmitCache("Actors/AnimationController/IKAnimatorController@Default", self, "IKAnimatorController", UnityEngine.RuntimeAnimatorController)
		end
	else
		ResourceMgr.SubmitCache("Fx/Skill/Etc/Eff_Select/Eff_Select_02", self, "SelectEffPrefab")
		ResourceMgr.SubmitCache("Actors/AnimationController/IKAnimatorController@Default", self, "IKAnimatorController", UnityEngine.RuntimeAnimatorController)
	end

	for i, skill in ipairs(self.OwnSkills) do
		skill:Cache()
	end
end

function UnitActor:Purge()
	if self.UniqueId == "" then
		return
	end

	if self.UnitData and self.UnitData.data and self.UnitData.data.VocalBank then
		BattleConfig.UnLoadSoundBank(self.UnitData.data.VocalBank)
	end

	self.ActorFactory:Purge()

	if self.AvaterFactory then
		self.AvaterFactory:Purge()
	end

	for i, skill in ipairs(self.OwnSkills) do
		skill:Purge()
	end

	UnitActor.Delete(self)
	self.Actor:Destroy()
	self:Reset()
end

function UnitActor:CreateImmediately()
	for i, skill in ipairs(self.OwnSkills) do
		skill:CreateImmediately()
	end

	self.SelectEffPrefab = ResourceMgr.LoadSync("Fx/Skill/Etc/Eff_Select/Eff_Select", GameObject)

	self:Create(true)
end

function UnitActor:Create(isImmediately)
	self.IsDelete = false

	if isImmediately == true then
		self.ActorFactory:CacheSync()

		self.Actor = self.ActorFactory:Build()

		self.Actor:Create()

		if self.AvaterFactory then
			self.AvaterFactory:CacheSync()

			self.WeaponAvatarPart = self.AvaterFactory:Build()
		end
	else
		self.Actor = self.ActorFactory:Build()

		self.Actor:Create()

		if self.AvaterFactory then
			self.WeaponAvatarPart = self.AvaterFactory:Build()
		end
	end

	if self.UnitClass == EnumBattle.UnitClass.PLAYER then
		self.ActorRoot = self.Actor.Root
		self.ActorSkeletonRoot = self.Actor.SkeletonSystem.Root
		self.ActorLipSync = GOUtil.AddMissingComponent(self.ActorRoot, "ActorLipSync")

		self.ActorLipSync:Init(self.UnitData.data.Lips)
	elseif self.UnitClass == EnumBattle.UnitClass.PVPPLAYER then
		self.ActorRoot = self.Actor.Root
		self.ActorSkeletonRoot = self.Actor.SkeletonSystem.Root
		self.Collider = {}

		local body = self.Actor.SkeletonSystem:GetBone("ColliderClick")

		if body then
			GOUtil.SetActive(body.gameObject, true)
			table.insert(self.Collider, body.gameObject)
		end

		local head = self.Actor.SkeletonSystem:GetBone(HumanBodyBones.Head)

		if head then
			table.insert(self.Collider, head.gameObject)
		end
	elseif self.UnitClass == EnumBattle.UnitClass.ENEMY then
		self.Collider = {}

		local body, head

		GOUtil.SetTransformLocalScale(self.Actor.Root, self.UnitData.data.Size)

		self.ActorRoot = self.Actor.Root

		if self.UnitData.data.PlayType == 2 then
			self.ActorSkeletonRoot = self.Actor.SkeletonSystem.Root
			body = self.Actor.SkeletonSystem:GetBone("ColliderClick")
			head = self.Actor.SkeletonSystem:GetBone(HumanBodyBones.Head)
		else
			self.ActorSkeletonRoot = self.Actor.ModelSystem.Root
			body = self.Actor.ModelSystem:GetBone("Collider")
		end

		if body then
			GOUtil.SetActive(body.gameObject, true)
			table.insert(self.Collider, body.gameObject)
		end

		if head then
			table.insert(self.Collider, head.gameObject)
		end
	end

	self:AttachToDefaultLocation()
	self:PutOnWeapon()

	self.ModelGUID = ReferenceRoot.AddMissingReferenceGUID(self.ActorSkeletonRoot, nil)
	self.ActorGUID = ReferenceRoot.AddMissingReferenceGUID(self.ActorRoot, nil)
	self.SelectEffect = GOUtil.InstantiatePrefab(self.SelectEffPrefab, self.ActorSkeletonRoot)

	GOUtil.ResetTransform(self.SelectEffect)
	GOUtil.SetActive(self.SelectEffect, true)
	self:SelectTargetEffect(false)
	self:SetSrpingBoneZlimit(true)
	self:SetActive(false)

	for i, skill in ipairs(self.OwnSkills) do
		skill:Create()
	end
end

function UnitActor:AttachToTimelineLocation(locationIdx)
	local root = SceneMgr.GetCurrentScene():GetTimelineParent(self.Camp, locationIdx)

	if self.Camp == EnumFight.Camp.ENEMY then
		root = SceneMgr.GetCurrentScene():GetTimelineParent(EnumFight.Camp.PLAYER, locationIdx)
	end

	self:AttachGameObject(root)
end

function UnitActor:AttachToDefaultLocation()
	local root = SceneMgr.GetCurrentScene():GetUnitParent(self.Camp, self.LocationIndex)

	self:AttachGameObject(root)
end

function UnitActor:PutOnWeapon()
	if self.WeaponAvatarPart and SceneMgr.GetCurrentScene().GP.FightMode == EnumFight.BattleType.NORMAL then
		self.Actor.AvatarSystem:PutOn(self.WeaponAvatarPart)
		self.Actor.MotionSystem:EnableAnimatorController(true)
	end
end

function UnitActor:TakeOffWeapon()
	if self.WeaponAvatarPart and SceneMgr.GetCurrentScene().GP.FightMode == EnumFight.BattleType.NORMAL then
		local tempAvatar = self.WeaponAvatarPart

		self.Actor.AvatarSystem:TakeOff(self.WeaponAvatarPart.Slot)

		self.WeaponAvatarPart = tempAvatar
	end
end

function UnitActor:GazeAtCamera(val)
	local trans_target = TenaryOp(val == true, self.GP.CameraUtil.Camera.transform, nil)

	self.Actor.ExpressionSystem:GazeAt(trans_target)
	self.Actor.ExpressionSystem:FocusAt(trans_target)
end

function UnitActor:AttachGameObject(parent)
	self:_EnabledSpringBone(false)
	GOUtil.AttachGameObject(self.ActorRoot, parent)
	GOUtil.ResetTransform(self.ActorRoot, true)
	GOUtil.ResetTransform(self.ActorSkeletonRoot, true)
	print(self.UnitTitle .. "  attach to " .. parent.gameObject.name)

	if GOUtil.IsActiveSelf(self.ActorRoot) and self.UnitClass == EnumBattle.UnitClass.ENEMY then
		GOUtil.SetActive(self.ActorRoot, false)
		GOUtil.SetActive(self.ActorRoot, true)
	end
end

function UnitActor:_EnabledSpringBone(val)
	if self.UnitClass == EnumBattle.UnitClass.PLAYER or self.UnitClass == EnumBattle.UnitClass.PVPPLAYER then
		self.Actor.SkeletonSystem:SetSrpingBoneEnabled(val)
	end
end

function UnitActor:SetSrpingBoneZlimit(val)
	if self.UnitClass == EnumBattle.UnitClass.PLAYER or self.UnitClass == EnumBattle.UnitClass.PVPPLAYER then
		self.Actor.SkeletonSystem:SetSrpingBoneZlimit(val)
	end
end

function UnitActor:MoveToTarget(target)
	local targetPos
	local radius = target.ActorRadius
	local dir = target.ActorRoot.transform.position - self.ActorRoot.transform.position

	targetPos = target.ActorRoot.transform.position - dir.normalized * radius

	self:MoveTo(targetPos)
end

function UnitActor:LookToTarget(target)
	local targetPos
	local radius = target.ActorRadius
	local dir = target.ActorRoot.transform.position - self.ActorRoot.transform.position

	targetPos = target.ActorRoot.transform.position - dir.normalized * radius

	self.ActorRoot.transform:LookAt(targetPos)
end

function UnitActor:MoveTo(targetPos)
	self.Pos = self.ActorRoot.transform.position
	self.MovePos = targetPos
	self.MoveSpeed = 30
	self.timer = 0

	self.ActorRoot.transform:LookAt(targetPos)

	self.State = EnumBattle.MoveState.GO
end

function UnitActor:MoveToZero()
	self.Pos = self.ActorRoot.transform.position
	self.MovePos = self.ActorRoot.transform.parent.position
	self.MoveSpeed = 30
	self.timer = 0
	self.State = EnumBattle.MoveState.BACK
end

function UnitActor:SetAttackType(type)
	self.CurSessionType = type
end

function UnitActor:HideBUffFx()
	for _, buff in ipairs(self.Buffs) do
		buff:HideFx()
	end
end

function UnitActor:ShowBuffFx()
	for _, buff in ipairs(self.Buffs) do
		buff:ShowFx()
	end
end

function UnitActor:SetActiveWithFx(val)
	local fx = BattleConfig.PVPActorFxEnter
	local delay = BattleConfig.PVPActorFxEnterDelay

	if val == false then
		fx = BattleConfig.PVPActorFxExit
		delay = BattleConfig.PVPActorFxExitDelay
	end

	local position, rotation, scale

	position = self.ActorRoot.transform.position
	rotation = self.ActorRoot.transform.rotation
	scale = 1

	BattleConfig:AllocAtById(fx, position, rotation, scale)
	BattleConfig.FreeTimer(self.HandleActionEndHide)

	self.HandleActionEndHide = BattleConfig.Delay(delay, function()
		self:SetActive(val)
	end)
end

function UnitActor:SetActive(val)
	local lastActive = GOUtil.IsActiveSelf(self.ActorRoot)

	if self.IsDelete == true then
		return
	end

	BattleConfig.FreeTimer(self.HandleActionEndHide)
	GOUtil.SetActive(self.ActorRoot, val)

	if SceneMgr.GetCurrentScene().GP.FightMode == EnumFight.BattleType.BOSS and self.UnitClass == EnumFight.UnitClass.PLAYER then
		return
	end

	if self.HeadTipUI then
		self.HeadTipUI:SetActive(val)
	end

	if val then
		self:ShowBuffFx()
	else
		self:HideBUffFx()
	end

	if not lastActive and val then
		self:RecoveryAnimStatus()
	end
end

function UnitActor:RecoveryAnimStatus()
	if self.IsDead then
		self:Play("Weak")

		return
	end

	for _, buff in ipairs(self.Buffs) do
		buff:RecoveryAnimStatus()
	end
end

function UnitActor:ApplyGeneralScaleSetting(val)
	local setting

	if val == true then
		if self.Actor.IsLoli == true then
			setting = SceneMgr.GetCurrentScene().ActorScaleSettingLoli
		else
			setting = SceneMgr.GetCurrentScene().ActorScaleSetting
		end
	else
		setting = self.Actor.SkeletonSystem.ScaleSettings
	end

	self.Actor.SkeletonSystem:SetScale(setting)
end

function UnitActor:EnterTimeLineSet()
	self:HideBUffFx()

	if self.HeadTipUI then
		self.HeadTipUI:SetActive(false)
	end

	if self.SelectEffect then
		self.SelectEffect.transform.localScale = Vector3.zero
	end
end

function UnitActor:LeaveTimeLineSet()
	self:ShowBuffFx()

	if self.HeadTipUI then
		self.HeadTipUI:SetActive(true)
	end

	if self.SelectEffect then
		GOUtil.ResetTransform(self.SelectEffect)
	end
end

function UnitActor:IsActive()
	return self.ActorRoot.activeSelf
end

function UnitActor:GetBone(bindSlot)
	local actorId = self.UnitData.data.ActorID
	local bonePath = _ActorData[actorId][bindSlot]
	local bone

	if self.UnitClass == EnumBattle.UnitClass.PLAYER then
		if bonePath then
			bone = self.Actor.SkeletonSystem:GetBone(bonePath)
		else
			print("Get bone ERROR1 ,  actorId = " .. actorId .. "  bindSlot = " .. bindSlot)
		end
	elseif self.UnitClass == EnumBattle.UnitClass.PVPPLAYER then
		if bonePath then
			bone = self.Actor.SkeletonSystem:GetBone(bonePath)
		else
			print("Get bone ERROR1 ,  actorId = " .. actorId .. "  bindSlot = " .. bindSlot)
		end
	elseif self.UnitClass == EnumBattle.UnitClass.ENEMY then
		if bonePath then
			if self.UnitData.data.PlayType == 2 then
				bone = self.Actor.SkeletonSystem:GetBone(bonePath)
			else
				bone = self.Actor.ModelSystem:GetBone(bonePath)
			end
		else
			print("Get bone ERROR2 ,  actorId = " .. actorId .. "  bindSlot = " .. bindSlot)
		end
	end

	if bone == nil then
		bone = self.ActorRoot.transform

		print("Get bone ERROR3 ,  actorId = " .. actorId .. "  bindSlot = " .. bindSlot)
	end

	return bone
end

function UnitActor:GetModelRoot()
	if not self.ActorRoot then
		print("UnitBase:GetModelRoot() ERROR, ActorRoot is nil , unitId:" .. self.UnitId)
	end

	return self.ActorRoot
end

function UnitActor:EnableShadowSetting(setting)
	self.Actor.SkeletonSystem:EnableShadow(setting)
end

function UnitActor:EnableAnimatorController(index)
	self:ResetVowelInfo()
	self.Actor.MotionSystem:EnableAnimatorController(index)
end

function UnitActor:SetIKAnimatorController()
	self.Actor.MotionSystem:SetOverrideAnimatorController(self.IKAnimatorController)
end

function UnitActor:ResetVowelInfo()
	self.Actor.ExpressionSystem:ResetVowelInfo()
end

function UnitActor:Play(stateName)
	self.Actor.MotionSystem:Play(stateName)
end

function UnitActor:CrossFade(stateName, normalizedTransitionDuration)
	self.Actor.MotionSystem:CrossFade(stateName, normalizedTransitionDuration)
end

function UnitActor:SetTrigger(paramName)
	self.Actor.MotionSystem:SetTrigger(paramName)
end

function UnitActor:SetBool(paramName, val)
	self.Actor.MotionSystem:SetBool(paramName, val)
end

function UnitActor:IsState(stateName)
	return self.Actor.MotionSystem:IsState(stateName)
end

function UnitActor:OnUpdate()
	self:UpdateMove()
end

function UnitActor:PauseAnim()
	self.Actor.MotionSystem:Pause()

	self.IsAnimPause = true
end

function UnitActor:ResumeAnim()
	self.Actor.MotionSystem:Resume()

	self.IsAnimPause = false
end

function UnitActor:PlayLip(VocalStr)
	if self.ActorLipSync then
		self.ActorLipSync:Play(self.Actor, VocalStr)
	end
end

function UnitActor:UpdateMove()
	if self.MoveSpeed <= 0 then
		return
	end

	self.timer = self.timer + Time.deltaTime

	local curMoveCurve

	if self.CurSessionType == EnumBattle.SeccionType.attack then
		curMoveCurve = self.MoveCurve_Thump
	else
		curMoveCurve = self.MoveCurve_Attack
	end

	local curPos = curMoveCurve[self.State]:UpdateMove(self.Pos, self.MovePos, self.timer)
	local _isMoving = self.timer < curMoveCurve[self.State]:GetDuration()

	if _isMoving then
		self.ActorRoot.transform.position = curPos

		if self.State == EnumBattle.MoveState.BACK then
			GOUtil.SetTransformLocalRotation(self.ActorRoot, 0, 0, 0)
		end
	else
		self.MoveSpeed = 0

		if self.State == EnumBattle.MoveState.BACK then
			self.ActorRoot.transform.localEulerAngles = Vector3(0, 0, 0)
		end
	end
end

function UnitActor:SetLocalPositionToZero()
	self:_EnabledSpringBone(false)
	GOUtil.SetTransformLocalPosition(self.ActorRoot.gameObject, 0, 0, 0)

	self.ActorRoot.transform.localEulerAngles = Vector3(0, 0, 0)
end

function UnitActor:SetPositionToZero()
	self:_EnabledSpringBone(false)
	GOUtil.SetTransformPosition(self.ActorRoot.gameObject, 0, 0, 0)

	self.ActorRoot.transform.eulerAngles = Vector3(0, 0, 0)
end

function UnitActor:SelectTargetEffect(val)
	GOUtil.SetActive(self.SelectEffect, val)

	if self.HeadTipUI then
		self.HeadTipUI:ShowTargetEffect(val)
	end
end

function UnitActor:SetSelectTargetEffect(SelectEffPrefab)
	self.SelectEffect = GOUtil.InstantiatePrefab(SelectEffPrefab, self.ActorSkeletonRoot)

	GOUtil.ResetTransform(self.SelectEffect)
	self:SelectTargetEffect(false)
end

function UnitActor:SetHeadTip(UI)
	self.HeadTipUI = UI
end

function UnitActor:DanceFinger(val)
	if val == true then
		self.dancerFx = BattleConfig.FxAlloc(90002, self)
	elseif self.dancerFx then
		EffectMgr:Free(self.dancerFx)
	end
end

function UnitActor:LuanchBullet(bulletId, target, boomCallback)
	local bullet = self.GP.BulletPool:Create()

	bullet:SetSource(self)
	bullet:SetBulletData(bulletId)
	bullet:SetTarget(target)

	if boomCallback then
		bullet:SetBoomCallBack(boomCallback)
	end

	bullet:Luanch()
end

function UnitActor:SelfDestruct()
	if self.UnitClass ~= EnumBattle.UnitClass.ENEMY then
		return
	end

	Event.Instance:Fire("PlayDie", self.UniqueId)
	self:SetActive(false)

	self.IsDelete = true
end

function UnitActor:PlayRebron()
	self:CrossFade("Idle", 0.3)
end

function UnitActor:PlayDie()
	if self.UnitClass ~= EnumBattle.UnitClass.ENEMY then
		print("Play die !!")
		self:CrossFade("Weak", 0.1)

		return 0.6
	end

	Event.Instance:Fire("PlayDie", self.UniqueId)
	self:CrossFade("Die", 0.1)
	print("Die")

	local DieFxs = Tenary(self.UnitData.data.DieFxs, {})
	local DieFxTimes = Tenary(self.UnitData.data.DieFxTimes, {})
	local DieHideTime = self.Actor.MotionSystem:GetAnimLength("Die")
	local DieMaterialAnimTime = Tenary(self.UnitData.data.DieMaterialAnimTime, 0)
	local DieTotalTime = Tenary(self.UnitData.data.DieTotalTime, 3)

	if DieTotalTime <= DieHideTime then
		DieTotalTime = DieHideTime + 0.1
	end

	for i, delayTime in ipairs(DieFxTimes) do
		BattleConfig.Delay(delayTime, function()
			BattleConfig.FxAlloc(DieFxs[i], self)
		end)
	end

	self:HideForDie(DieHideTime)

	if DieMaterialAnimTime ~= -1 then
		BattleConfig.Delay(DieMaterialAnimTime, function()
			if self.UniqueId ~= "" then
				local materialAnimator = GOUtil.GetComponentInChildren(self.ActorRoot, "MaterialAnimator")

				if materialAnimator then
					materialAnimator:Play("D_Show")
				end
			end
		end)
	end

	return DieTotalTime
end

function UnitActor:HideForDie(delay)
	BattleConfig.Delay(delay, function()
		if self.UniqueId ~= "" then
			self:SetActive(false)

			self.IsDelete = true

			Event.Instance:Fire("单位-死亡消失", self, self.TeamIndex)
		end
	end)
end

function UnitActor:Damage(msg)
	if not self.IsAnimPause then
		self:CrossFade("Damage", 0.1)
	end

	if self.UnitClass == EnumBattle.UnitClass.ENEMY then
		BattleConfig.FxAlloc(self.UnitData.data.DamageFx, self)
	end
end

function UnitActor:GetBuff(buffUid)
	return self.BuffMap[buffUid]
end

function UnitActor:AddBuff(buffId, buffUid, skillPower, stack, logicData)
	local buff = UnitOwnBuff(self, buffId, buffUid, skillPower, stack, logicData)

	table.insert(self.Buffs, 1, buff)

	self.BuffMap[buffUid] = buff

	buff:Add()
end

function UnitActor:UpdateBuff(buffUid, remainRound)
	if remainRound == -1 then
		return
	end

	local buff

	for i, ownBuff in ipairs(self.Buffs) do
		if ownBuff.UID == buffUid then
			buff = table.remove(self.Buffs, i)

			break
		end
	end

	if buff then
		table.insert(self.Buffs, 1, buff)
		buff:Update(remainRound)
	end
end

function UnitActor:BuffStack(buffUid, stack)
	local buff

	for i, ownBuff in ipairs(self.Buffs) do
		if ownBuff.UID == buffUid then
			buff = table.remove(self.Buffs, i)

			break
		end
	end

	if buff then
		table.insert(self.Buffs, 1, buff)
		buff:SetStack(stack)
	end
end

function UnitActor:RemoveBuff(buffId, buffUid)
	local fireBuff

	for i, buff in ipairs(self.Buffs) do
		if buff.UID == buffUid then
			table.remove(self.Buffs, i)

			fireBuff = buff

			break
		end
	end

	self.BuffMap[buffUid] = nil

	if fireBuff ~= nil then
		fireBuff:Remove()
	end
end

function UnitActor:BuffExe(buffUid)
	local buff = self.BuffMap[buffUid]

	if buff == nil then
		print("<color=red>UnitActor:BuffExe ERROR！！！， BUFF = nil</color>")
	else
		buff:Exe()
	end
end

function UnitActor:SetNotAction(val)
	self.NotAction = val
end

function UnitActor:SetDisableCardSkill(val)
	self.DisableCardSkill = val
end
