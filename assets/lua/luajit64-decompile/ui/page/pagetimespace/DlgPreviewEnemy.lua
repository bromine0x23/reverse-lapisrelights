-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTimeSpace/DlgPreviewEnemy.lua

DlgPreviewEnemy = class("DlgPreviewEnemy")
ePanelActorPosType = {
	Role = 1,
	Equip = 2,
	Fitting = 3
}
modelPosZ = {
	0,
	0.4,
	0,
	0.4,
	0
}

function DlgPreviewEnemy:ctor()
	self.isRTCameraFar = false

	self:OnRegisterEvent()
end

function DlgPreviewEnemy:Init(renderCtrl, needRandomIdle)
	self.UI3DActorRotate = UI3DActorRotate()

	self.UI3DActorRotate:Init(renderCtrl.gameObject)

	self.needRandomIdle = needRandomIdle

	local img = GOUtil.GetComponent(renderCtrl.gameObject, "RawImage")

	DealWithListRef(self, UIUtil.SetRawImageMaterial(img, "UI/Materials/DefaultUIForRT"))

	self.cb = nil
	self.actorFactorys = {}
	self.UI3DActorRotates = {}
	self.actors = {}
	self.actorsName = {}
end

function DlgPreviewEnemy:Purge()
	self:OnUnRegisterEvent()

	self.cb = nil

	if self.infoRole then
		SoundMgr.UnloadBank(self.infoRole.data.VocalBank)
	end

	self:ClearActor()

	if self.UI3DActorRotate then
		self.UI3DActorRotate:OnLeave()

		self.UI3DActorRotate = nil
	end

	if self.actorFunc then
		self.actorFunc()
	end

	if self.actorFactorys then
		for i, v in pairs(self.actorFactorys) do
			if v then
				v:Purge()

				v = nil
			end
		end
	end

	if self.actors then
		for i, v in pairs(self.actors) do
			if v then
				v:Destroy()

				v = nil
			end
		end
	end

	UnloadAllImageSprite(self)
end

function DlgPreviewEnemy:ClearActor(needGC)
	local gc_flag = false

	if self.actor then
		self.actor:Destroy()

		self.actor = nil
		gc_flag = true
	end

	if self.actorFactory then
		self.actorFactory:Purge()

		self.actorFactory = nil
		gc_flag = true
	end

	if self.AvaterFactory then
		self.AvaterFactory:Purge()
	end

	if gc_flag and needGC then
		System.GC.Collect()
	end
end

function DlgPreviewEnemy:LoadActor(enemyId, motionDataPath)
	self.infoEnemy = EnemyManager:Get(enemyId)

	local actorID = self.infoEnemy.data.ActorID

	self:ClearActor(true)
	LoadingMgr.Show(eLoadingType.Repeat)
	ResourceMgr.BeginSubmit(function()
		self:OnAsyncPrecacheActorFinish()
	end)

	self.offx = 0
	self.offy = 15
	self.offz = 1.45

	local actorFactory
	local controller = ActorUtil.MotionControllerDataFilter(actorID, "Battle", "None")

	if self.infoEnemy.data.PlayType == 2 then
		actorFactory = ActorUtil.BuildActorFactory(actorID, nil, controller)

		local WeaponID = self.infoEnemy.data.WeaponID
		local weaponData = require("luaData/Equipment")

		self:InitWeapon(WeaponID, weaponData[WeaponID].Avatar)
	else
		actorFactory = ActorUtil.BuildEnemyFactory(actorID, controller)
	end

	if not actorFactory then
		print("<color=red>创建角色失败！ id:" .. self.UnitId .. "</color>")
	end

	actorFactory:Cache()

	if self.AvaterFactory then
		self.AvaterFactory:Cache()
	end

	self.actorFactory = actorFactory

	ResourceMgr.EndSubmit()
end

function DlgPreviewEnemy:InitWeapon(weaponId, weaponAvatarId)
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

function DlgPreviewEnemy:LoadCardFittingActors(infoRole, Controls, inforolesCount)
	for i = 1, #infoRole do
		if infoRole[i] then
			LoadingMgr.Show(eLoadingType.Repeat)
			ResourceMgr.BeginSubmit(function()
				self:OnAsyncPrecacheActorCardFittingFinishs(i, Controls, self.actorFunc, inforolesCount)
			end)

			self.offz = 0.162

			local actorData = infoRole[i].actorData
			local avatarSettingsPath = {}

			if not infoRole[i].pb.clothes or #infoRole[i].pb.clothes == 0 then
				for i, _avatarId in ipairs(actorData.DefaultAvatars) do
					table.insert(avatarSettingsPath, AvatarData[_avatarId].AvatarPath)
				end
			else
				for n = 1, #infoRole[i].pb.clothes do
					table.insert(avatarSettingsPath, AvatarData[infoRole[i].pb.clothes[n]].AvatarPath)
				end
			end

			local actorFactory = ActorFactory(actorData.Comment, actorData.SkeletonPrefab, actorData.ScaleSettingsAsset, avatarSettingsPath, "Actors/AnimationController/Common@CardFitting", actorData.FacialSettingsAsset, actorData.EyeSettingsAsset, actorData.VowelSettingsAsset, "Actors/Settings/ExpressionEffectSettings/1001", "Actors/Animations/Actor/Interact/" .. infoRole[i].id)

			actorFactory:Cache()

			self.actorFactorys[i] = actorFactory

			ResourceMgr.EndSubmit()
		end
	end
end

function DlgPreviewEnemy:OnAsyncPrecacheActorFinish()
	local actor = self.actorFactory:Build()

	self.actor = actor

	actor:Create()

	if self.AvaterFactory then
		local weaponAvatarPart = self.AvaterFactory:Build()

		self.actor.AvatarSystem:PutOn(self.weaponAvatarPart)
		self.actor.MotionSystem:EnableAnimatorController(true)
	end

	local g = actor.Root

	GOUtil.SetGameObjectLayer(g, LayerMask.NameToLayer("RT"))
	GOUtil.SetTransformLocalPosition(g, 0, self.offx, self.offy)
	GOUtil.SetTransformRotation(g, 0, 180, 0)

	if IsNil(self.RTCamera) then
		self.RTCamera = GameObject.Find("RTCamera")
	end

	local GoPlane = GameObject.Find("Plane")

	if GoPlane then
		local p = g.transform.localPosition

		GOUtil.SetTransformPosition(GoPlane, p.x, p.y, p.z)
	end

	self:ChangeView()

	self.UI3DActorRotate.actor = g
	self.UI3DActorRotate.posStart = 0

	if self.cb then
		self.cb()

		self.cb = nil
	end

	if self.needRandomIdle then
		self:OnRandomIdle()
	end

	LoadingMgr.Hide(eLoadingType.Repeat)
end

function DlgPreviewEnemy:ChangeView()
	if IsNil(self.RTCamera) then
		return
	end

	local z = 0

	if not self.isRTCameraFar then
		z = -11

		GOUtil.SetTransformRotation(self.RTCamera, 3, 0, 0)
	else
		z = 0.162

		GOUtil.SetTransformRotation(self.RTCamera, 6, 0, 0)
	end

	GOUtil.SetTransformPosition(self.RTCamera, 0, 6.5, z)
end

function DlgPreviewEnemy:OnRegisterEvent()
	return
end

function DlgPreviewEnemy:OnUnRegisterEvent()
	return
end
