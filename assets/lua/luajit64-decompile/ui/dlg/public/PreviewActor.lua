-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Public/PreviewActor.lua

require("UI/UI3DActorRotate")
require("UI/Page/PageRole/DlgRoleInfo")

PreviewActor = class("PreviewActor", UIPanel)
eActorSystemType = {
	ROLE = 1,
	AVATAR = 3,
	EQUIP = 2
}

local aRot = {
	180,
	180,
	180
}
local rtPos = {
	{
		0.05,
		1.35,
		0.162
	},
	{
		0.05,
		1.35,
		0
	},
	{
		0.05,
		1.35,
		0.05
	}
}

function PreviewActor:ctor(systemType)
	self.UIPrefabPath = "UI/Public/PreviewActor"
	self.cb = nil
	self.systemType = systemType
	self.preSystemType = systemType
	self.DlgRoleInfo = DlgRoleInfo()

	self:AddChildPanel(self.DlgRoleInfo)
end

function PreviewActor:OnRegisterEvent()
	Event.Instance:Add("UpdateShowCharacter", self.UpdateRole, self)
end

function PreviewActor:OnUnRegisterEvent()
	Event.Instance:Remove("UpdateShowCharacter", self.UpdateRole, self)
end

function PreviewActor:Purge()
	self.base.Purge(self)
	self:ClearActor()
	self:ClearAvatar()

	if self.UI3DActorRotate then
		self.UI3DActorRotate:OnLeave()

		self.UI3DActorRotate = nil
	end

	if self.matRef then
		ResourceMgr.Unload(self.matRef)

		self.matRef = nil
	end

	self.cb = nil
	self.infoRole = nil
	globalInterSoundEvent = nil
	globalInterSoundBank = nil
end

function PreviewActor:OnEnter()
	UIMgr.ResetMsg2OffsetType(DlgMessage2OffType.offset2)
	self.UIRootObject.transform:SetAsFirstSibling()

	local go = GOUtil.FindChildGameObject(self.UIRootObject, "Actor")

	GOUtil.AddMissingComponent(go, "UI3DRenderControl")

	self.UI3DActorRotate = UI3DActorRotate()

	self.UI3DActorRotate:Init(go)

	self.matRef = UIUtil.SetRawImageMaterial(GOUtil.GetComponent(go, "RawImage"), "UI/Materials/DefaultUIForRT")

	if self.DlgRoleInfo then
		if self.systemType ~= eActorSystemType.AVATAR then
			self.DlgRoleInfo:Show()
		else
			self.DlgRoleInfo:Hide()
		end
	end

	self:UpdateRole(RoleMgr:GetRole(CharacterThinMgr.LastData(THIN_SYSTEM_TYPE.Role).id))
end

function PreviewActor:UpdateRole(infoRole, callback)
	if type(callback) ~= "boolean" then
		self.cb = callback
	end

	if self.infoRole and self.infoRole.id == infoRole.id then
		if self.cb then
			self.cb()

			self.cb = nil
		end

		return
	end

	self.infoRole = infoRole

	self:UpdateDlgRoleInfo(true)
	self:LoadActor()
end

function PreviewActor:UpdateDlgRoleInfo(needUpdate)
	if self.DlgRoleInfo and needUpdate then
		self.DlgRoleInfo:UpdateRole(self.infoRole)
	end
end

function PreviewActor:OnRandomIdle()
	if self.actor == nil then
		return
	end

	if self.actor.MotionSystem == nil or not self.actor.MotionSystem.IsState then
		return
	end

	PlayAnim(InfoRole.GetDaySection(), self.actor, self.infoRole)
end

function PreviewActor:ClearActor(needGC)
	local gc_flag = false

	if self.actorFactory ~= nil and self.actorFactory.Product.SkeletonSystem then
		self.actorFactory:Purge()

		self.actorFactory = nil
		gc_flag = true
	end

	if self.actor ~= nil then
		self.actor:Destroy()

		self.actor = nil
		gc_flag = true
	end

	if gc_flag and needGC then
		System.GC.Collect()
	end
end

function PreviewActor:LoadActor()
	LoadingMgr.Show(eLoadingType.Repeat)
	self:DealWithTransform()
	self:ClearActor(true)

	local controllerMain = ActorUtil.MotionControllerDataFilter(self.infoRole.data.ActorID, "Fitting", "None")
	local controllerInteract = ActorUtil.MotionControllerDataFilter(self.infoRole.data.ActorID, "Weapon", "None")
	local mergedMotionControllerData = ActorUtil.MergeMotionControllerData(controllerMain, controllerInteract)

	local function OnAsyncPrecacheActorFinish()
		if self.actorFactory then
			local actor = self.actorFactory:Build()

			actor:Create()

			self.actor = actor

			self:SetTransformImmediately()

			if not IsNil(self.RTCamera) then
				self.actor.ExpressionSystem:FocusAt(self.RTCamera.transform)
				self.actor.ExpressionSystem:GazeAt(self.RTCamera.transform)
			end

			if self.systemType == eActorSystemType.ROLE then
				self:OnRandomIdle()
			else
				local list = self.actor.InteractSettingFile.m_IdleBehaviours.m_Behaviours

				if list.Count > 0 then
					self.actor:PlayBehaviour(list:get_Item(0))
				end
			end

			Event.Instance:Fire("UpdateSceneDisplay", false)

			if self.UI3DActorRotate then
				self.UI3DActorRotate.actor = actor.Root
				self.UI3DActorRotate.posStart = 0
			end

			if self.systemType == eActorSystemType.EQUIP or self.systemType == eActorSystemType.AVATAR then
				self:EquipAvatar()
				self.actor.Root:SetActive(false)
			elseif self.cb then
				self.cb()

				self.cb = nil
			end
		end

		self.loadActorHandle = nil

		LoadingMgr.Hide(eLoadingType.Repeat)
	end

	self.loadActorHandle = ResourceMgr.BeginSubmit(function()
		OnAsyncPrecacheActorFinish()
	end)
	self.actorFactory = ActorUtil.BuildActorFactoryByInfoRole(self.infoRole, mergedMotionControllerData)

	self.actorFactory:Cache()
	ResourceMgr.EndSubmit()
end

function PreviewActor:DealWithTransform()
	self.systemType = self.systemType == nil and eActorSystemType.ROLE or self.systemType
	self.actorPosX = 0
	self.actorPosY = self.infoRole.actorData.Height[1][1]
	self.actorPosZ = self.infoRole.actorData.Height[1][2]
	self.actorRotX = 0
	self.actorRotY = aRot[self.systemType]
	self.actorRotZ = 0
	self.rtCPosX = rtPos[self.systemType][1]
	self.rtCPosY = rtPos[self.systemType][2]
	self.rtCPosZ = rtPos[self.systemType][3]
	self.rtCRotX = 4.7
	self.rtCRotY = -0.133
	self.rtCRotZ = -0.106
end

function PreviewActor:SetTransformImmediately()
	if self.actor ~= nil then
		GOUtil.SetGameObjectLayer(self.actor.Root, LayerMask.NameToLayer("RT"))
		GOUtil.SetTransformPosition(self.actor.Root, self.actorPosX, self.actorPosY, self.actorPosZ)
		GOUtil.SetTransformRotation(self.actor.Root, self.actorRotX, self.actorRotY, self.actorRotZ)
	end

	if IsNil(self.RTCamera) then
		self.RTCamera = GameObject.Find("RTCamera")
	end

	if not IsNil(self.RTCamera) then
		GOUtil.SetTransformPosition(self.RTCamera, self.rtCPosX, self.rtCPosY, self.rtCPosZ)
		GOUtil.SetTransformRotation(self.RTCamera, self.rtCRotX, self.rtCRotY, self.rtCRotZ)
	end
end

function PreviewActor:ChangeLens()
	local needOverride = false

	if self.systemType == eActorSystemType.ROLE or self.systemType == eActorSystemType.EQUIP and self.preSystemType == eActorSystemType.ROLE then
		needOverride = true
	end

	self.preSystemType = self.systemType

	if self.DlgRoleInfo then
		self.DlgRoleInfo:UpdateShowModule()
	end

	self:UpdateDlgRoleInfo(true)
	self:DealWithTransform()

	local function ChangeTransform(callback)
		self.UI3DActorRotate.posStart = 0

		GOUtil.DORotate(self.UI3DActorRotate.actor.transform, self.actorRotY, 0.3)

		local rtCamera = GameObject.Find("RTCamera")
		local tweener = GOUtil.DoMoveX(rtCamera.transform, self.rtCPosX, 0.3)

		GOUtil.DoMoveZ(rtCamera.transform, self.rtCPosZ, 0.3)
		GOUtil.SetTweenerCallback(tweener, callback)
	end

	if needOverride then
		local function callback()
			if self.systemType == eActorSystemType.ROLE then
				UIMgr.PreviewActor:TakeOffWeaponAvatar()
				self:OnRandomIdle()
			else
				self:EquipAvatar()
			end
		end

		ChangeTransform(callback)
	else
		self:CheckEquipedAvatar()
		ChangeTransform()
	end
end

function PreviewActor:ClearAvatar()
	if self.avatarFactory ~= nil then
		self.avatarFactory:Purge()

		self.avatarFactory = nil
	end

	if self.avatarPart ~= nil then
		self.avatarPart:Destroy()

		self.avatarPart = nil
	end
end

function PreviewActor:EquipAvatar(id, isNewBuy, noAni)
	LoadingMgr.Show(eLoadingType.Repeat)

	local listAvatar = AvatarManager:GetWeaponAvatarList(self.infoRole)

	if not id then
		for k, v in pairs(listAvatar) do
			if v.RealEquiped then
				id = v.InfoAvatar.id

				break
			end
		end
	end

	self.tempEquipAvatarId = id

	local preAvatarFactory = self.avatarFactory
	local preAvatarPart = self.avatarPart

	local function asyncFinishCb()
		if self.avatarFactory and self.actor then
			self.actor.Root:SetActive(true)
			self.actor.SkeletonSystem:SetSrpingBoneEnabled(false)

			self.avatarPart = self.avatarFactory:Build()

			self.actor.AvatarSystem:PutOn(self.avatarPart)
			GOUtil.SetGameObjectLayer(self.actor.Root, LayerMask.NameToLayer("RT"))

			if not noAni then
				if isNewBuy then
					self.actor.MotionSystem:Play("Buy")
				else
					self.actor.MotionSystem:Play("PutOn")
					self.actor:ResetBehaviour()
				end
			end

			if preAvatarFactory then
				preAvatarFactory:Purge()

				preAvatarFactory = nil
			end

			if not IsNil(preAvatarPart) then
				preAvatarPart:Destroy()

				preAvatarPart = nil
			end
		end

		if self.cb then
			self.cb()

			self.cb = nil
		end

		self.avatarHandle = nil

		LoadingMgr.Hide(eLoadingType.Repeat)
	end

	self.avatarHandle = ResourceMgr.BeginSubmit(asyncFinishCb)
	self.avatarFactory = ActorUtil.BuildAvatarFactory(id, self.infoRole.id)

	self.avatarFactory:Cache()
	ResourceMgr.EndSubmit()
end

function PreviewActor:TakeOffWeaponAvatar()
	if self.actor and self.avatarPart then
		self.actor.SkeletonSystem:SetSrpingBoneEnabled(false)
		self.actor.AvatarSystem:TakeOff(self.avatarPart.Slot)
	end

	self:ClearAvatar()
end

function PreviewActor:CheckEquipedAvatar()
	local realEquipAvatarId = 0
	local listAvatar = AvatarManager:GetWeaponAvatarList(self.infoRole)

	for k, v in pairs(listAvatar) do
		if v.RealEquiped then
			realEquipAvatarId = v.InfoAvatar.id

			break
		end
	end

	if realEquipAvatarId ~= self.tempEquipAvatarId then
		self:TakeOffWeaponAvatar()
		self:EquipAvatar(realEquipAvatarId, false, true)
	end
end
