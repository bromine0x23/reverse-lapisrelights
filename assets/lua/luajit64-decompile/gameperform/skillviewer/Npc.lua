-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/SkillViewer/Npc.lua

local print_enable = false
local print = function(...)
	if print_enable == true then
		print(...)
	end
end
local _ActorData = require("luaData/ActorData")
local InfoTeam = require("Info/InfoTeam")

Npc = class("Npc", UnitActor)

function Npc:ctor(gp, msg)
	if msg then
		Npc.base.ctor(self, gp, msg)
	else
		Npc.base:Reset()
	end

	self.NpcSkills = {}
	self.NpcShowSkill = {}
end

function Npc:Purge()
	for k, v in pairs(self.NpcSkills) do
		v:Purge()
	end

	self.NpcSkills = nil
	self.UniqueId = nil
	self.WeaponName = ""

	self.ActorFactory:Purge()

	if self.AvaterFactory then
		self.AvaterFactory:Purge()
	end

	self.Actor:Destroy()
	self:Reset()
end

function Npc:CreateModel(unitId, unitClass, cardId)
	self.UnitClass = unitClass

	if unitClass == EnumFight.UnitClass.ENEMY then
		self:InitMonster(unitId)
	else
		self:InitPlayer(unitId, cardId)
	end
end

function Npc:InitPlayer(unitId, cardId)
	self.UnitId = unitId
	self.CardId = cardId

	local roleInfo = RoleMgr:GetRole(self.UnitId)

	self.UnitData = roleInfo

	local actorID = roleInfo.data.ActorID

	self.UnitTitle = Lang(roleInfo.data.Name)

	local cardId = self.CardId

	if cardId ~= 0 then
		self.InfoRoleCard = RoleCardMgr:GetRoleCard(cardId)

		BattleConfig.LoadSoundBank(self.UnitData.data.VocalBank, false, false)
	end

	local controller
	local name = ""
	local weaponId = roleInfo:GetEquipId(eEquipSlotType.Weapon)
	local weaponData = require("luaData/Equipment")

	weaponAvatarId = weaponData[weaponId].Avatar

	self:InitWeapon(weaponId, weaponAvatarId)

	self.WeaponName = weaponData[weaponId].Weapon
	controller = ActorUtil.MotionControllerDataFilter(actorID, "Fight@Engagement", "None")
	self.ActorFactory = ActorUtil.BuildActorFactoryByInfoRole(roleInfo, controller)

	if not self.ActorFactory then
		print("<color=red>创建角色失败！ id:" .. self.UnitId .. "</color>")
	end

	self.ActorRadius = _ActorData[actorID].Radius

	local cardCfg = require("luaData/CharacterCard")
	local skillInfos = cardCfg[cardId].StarTalent

	for i, info in ipairs(skillInfos) do
		for _, skillId in ipairs(info) do
			self:AddSkill(skillId, 1)
		end
	end

	self:AddSkill(weaponData[weaponId].WeaponThumpSkillID, 1)
	self:AddSkill(weaponData[weaponId].WeaponAttackSkillID, 1)
	self:AddSkill(self.InfoRoleCard.data.SpecialAtkSkill, 1)
	self:InstantiateModel()
end

function Npc:InitMonster(unitId)
	self.UnitId = unitId

	local monsterInfo = EnemyManager:Get(self.UnitId)

	self.UnitData = monsterInfo

	local actorID = monsterInfo.data.ActorID
	local name = "Fight@Engagement"
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

	local UnitData = self.UnitData.data
	local skillIds = UnitData.StageSkillId

	for i, skillId in ipairs(skillIds) do
		if skillId ~= 0 then
			self:AddSkill(skillId, 1)
		end
	end

	skillIds = UnitData.StageOfAngryBuff

	for i, skillId in ipairs(skillIds) do
		if skillId ~= 0 then
			self:AddSkill(skillId, 1)
		end
	end

	if UnitData.AppearSkills then
		skillIds = UnitData.AppearSkills

		for i, skillId in ipairs(skillIds) do
			if skillId ~= 0 then
				self:AddSkill(skillId, 1)
			end
		end
	end

	if UnitData.OthersSkills then
		skillIds = UnitData.OthersSkills

		for i, skillId in ipairs(skillIds) do
			if skillId ~= 0 then
				self:AddSkill(skillId, 1)
			end
		end
	end

	self:InstantiateModel()
end

function Npc:InstantiateModel()
	self.ActorFactory:CacheSync()

	self.Actor = self.ActorFactory:Build()

	self.Actor:Create()

	if self.AvaterFactory then
		self.AvaterFactory:CacheSync()

		self.WeaponAvatarPart = self.AvaterFactory:Build()
	end

	if self.UnitClass == EnumFight.UnitClass.PLAYER then
		self.ActorRoot = self.Actor.Root
		self.ActorSkeletonRoot = self.Actor.SkeletonSystem.Root
		self.ActorLipSync = GOUtil.AddMissingComponent(self.ActorRoot, "ActorLipSync")

		self.ActorLipSync:Init(self.UnitData.data.Lips)
	elseif self.UnitClass == EnumFight.UnitClass.ENEMY then
		self.ActorRoot = self.Actor.Root

		if self.UnitData.data.PlayType == 2 then
			self.ActorSkeletonRoot = self.Actor.SkeletonSystem.Root
		else
			self.ActorSkeletonRoot = self.Actor.ModelSystem.Root
		end

		self.Collider = GOUtil.FindGameObjectByName("Collider", self.ActorRoot.gameObject)
	end

	self:AttachToDefaultLocation()

	self.ModelGUID = ReferenceRoot.AddMissingReferenceGUID(self.ActorSkeletonRoot, nil)
	self.ActorGUID = ReferenceRoot.AddMissingReferenceGUID(self.ActorRoot, nil)

	if self.WeaponAvatarPart then
		self:PutOnWeapon()
	end

	self.Actor.MotionSystem:GetAnimLength("1")
	self:SetSrpingBoneZlimit(true)
end

function Npc:AddSkill(skillId, lv)
	local skill = NpcSkill(self, skillId, lv)

	if skill.Vaild == false then
		return
	end

	if not self.NpcSkills[skillId] then
		self.NpcSkills[skillId] = {}
		self.NpcSkills[skillId] = skill
	end
end

function Npc:AttachToDefaultLocation()
	return
end

function Npc:PutOnWeapon()
	if self.WeaponAvatarPart then
		self.Actor.AvatarSystem:PutOn(self.WeaponAvatarPart)
		self.Actor.MotionSystem:EnableAnimatorController(true)
	end
end

function UnitActor:TakeOffWeapon()
	if self.WeaponAvatarPart then
		local tempAvatar = self.WeaponAvatarPart

		self.Actor.AvatarSystem:TakeOff(self.WeaponAvatarPart.Slot)

		self.WeaponAvatarPart = tempAvatar
	end
end

function Npc:SetActive(val)
	GOUtil.SetActive(self.ActorRoot, val)
end

function Npc:PlayTimeLine(timeLineId, callback)
	if not timeLineId or timeLineId == 0 then
		if callback then
			callback()
		end

		return
	end

	SV.TimeLine:CreateImmediately(timeLineId)

	local _timeLine = SV.TimeLine:Get(timeLineId)

	if not _timeLine then
		callback()

		return
	end

	local unit = self

	if unit.UnitClass == EnumFight.Camp.PLAYER then
		unit:SetIKAnimatorController()
		unit:ApplyGeneralScaleSetting(true)
		ReferenceRoot.Instance:SetDynamicName("Model 1", unit.ModelGUID)
		ReferenceRoot.Instance:SetDynamicName("Actor 1", unit.ActorGUID)
		unit:EnterTimeLineSet()
		unit:TakeOffWeapon()
		unit:EnableAnimatorController(false)
	end

	_timeLine:Rebind()
	_timeLine:Play(function()
		if callback then
			callback()
		end
	end)
end
