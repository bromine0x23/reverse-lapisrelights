-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/Camera/CameraUtility.lua

CameraUtility = class("CameraUtility")

function CameraUtility:ctor(GP)
	self.GP = GP

	self:Reset()
end

function CameraUtility:Reset()
	self.IsBossWave = false
	self.LastMainCamera = nil
	self.CurMainCamera = nil
	self.Camera = nil
	self.CameraComponent = nil
	self.CinemachineBrain = nil
	self.vCamMain = nil
	self.vCamMain_boss = nil
	self.TargetGroup = nil
	self.vAffectCam_Monster = nil
	self.vAffectCam_Boss = nil
	self.vAffectCam_Boss_Skill = nil
	self.vAffectCam_Monster_Skill = nil
	self.vAffectCam_Player = nil
end

function CameraUtility:Init()
	local PredeployObj = GameObject.Find("[Predeploy]")

	self.TargetGroup = GameObject.Find("CameraGrp/TargetGroup")
	self.Camera = GOUtil.FindChildGameObject(PredeployObj, "Camera")
	self.CameraComponent = GOUtil.GetComponent(self.Camera, "Camera")
	self.CinemachineBrain = GOUtil.GetComponent(self.Camera, "CinemachineBrain")
	self.vCamMain = GOUtil.FindChildGameObject(PredeployObj, "CameraGrp/CameraMonsterBattleGrp/CM Monster")

	if self.GP.PVPMode == true then
		self.vCamPVP = GOUtil.FindChildGameObject(PredeployObj, "CameraGrp/CameraMonsterBattleGrp/CM PVP")
	end

	GOUtil.SetActive(self.vCamMain, false)

	self.vCamMain_boss = GOUtil.FindChildGameObject(PredeployObj, "CameraGrp/CameraBossBattleGrp/CM Boss")

	GOUtil.SetActive(self.vCamMain_boss, false)

	self.vAffectCam_Monster = GOUtil.FindChildGameObject(PredeployObj, "CameraGrp/Damage/CM Damage Monster")
	self.vAffectCam_Boss = GOUtil.FindChildGameObject(PredeployObj, "CameraGrp/Damage/CM Damage Boss")
	self.vAffectCam_Player = GOUtil.FindChildGameObject(PredeployObj, "CameraGrp/Damage/CM Damage Character")
	self.vAffectCam_Boss_Skill = GOUtil.FindChildGameObject(PredeployObj, "CameraGrp/Damage/CM Skill Boss")
	self.vAffectCam_Monster_Skill = GOUtil.FindChildGameObject(PredeployObj, "CameraGrp/Damage/CM Skill Monster")
	self.ActorLayer = LayerMask.NameToLayer("Actor")
end

function CameraUtility:Purge()
	self:CloseCam(self.Camera)
	self:CloseCam(self.vCamMain)
	self:CloseCam(self.vCamMain_boss)
	self:CloseCam(self.vAffectCam_Monster)
	self:CloseCam(self.vAffectCam_Boss)
	self:CloseCam(self.vAffectCam_Player)
	self:CloseCam(self.vAffectCam_Boss_Skill)
	self:CloseCam(self.vAffectCam_Monster_Skill)
	self:Reset()
end

function CameraUtility:CloseCam(cam)
	if cam then
		GOUtil.SetActive(cam, false)
	end
end

function CameraUtility:CheckMainVirtualCamera(isBoss)
	if isBoss == false then
		self.IsBossWave = false
		self.CurMainCamera = self.vCamMain
	else
		self.IsBossWave = true
		self.CurMainCamera = self.vCamMain_boss
	end

	if self.LastMainCamera == self.CurMainCamera then
		return
	end

	if self.LastMainCamera then
		GOUtil.SetActive(self.LastMainCamera, false)
	end

	GOUtil.SetActive(self.CurMainCamera, true)

	self.LastMainCamera = self.CurMainCamera
end

function CameraUtility:SetTargetGroup(actorRoots)
	CinemachineUtil.ResetTargetGroup(self.TargetGroup)

	for i, actorRoot in ipairs(actorRoots) do
		CinemachineUtil.SetTargetGroup(self.TargetGroup, i - 1, actorRoot.transform)
	end
end

function CameraUtility:AddTargetGroup(actorRoots)
	for i, actorRoot in ipairs(actorRoots) do
		CinemachineUtil.AddTargetGroupMember(self.TargetGroup, actorRoot.transform, 1, 0)
	end
end

function CameraUtility:OnMeleeAttack(actorRoots)
	self:SetTargetGroup(actorRoots)
	GOUtil.SetActive(self.CurMainCamera, false)

	if self.IsBossWave == true then
		GOUtil.SetActive(self.vAffectCam_Boss, true)
	else
		GOUtil.SetActive(self.vAffectCam_Monster, true)
	end
end

function CameraUtility:EnablePVPCamear(val)
	if self.GP.PVPMode == true then
		if val == true then
			self.GP.Team:SetActive(EnumFight.Camp.PLAYER, false)
			self.GP.Team:SetActive(EnumFight.Camp.ENEMY, true)
		end

		GOUtil.SetActive(self.CurMainCamera, not val)
		GOUtil.SetActive(self.vCamPVP, val)
	end
end

function CameraUtility:OnRangeAttack()
	return
end

function CameraUtility:OnSkillAll()
	return
end

function CameraUtility:OnSkillPlayer()
	GOUtil.SetActive(self.CurMainCamera, true)
end

function CameraUtility:OnSkillEnemy()
	GOUtil.SetActive(self.CurMainCamera, false)

	if self.IsBossWave == true then
		GOUtil.SetActive(self.vAffectCam_Boss_Skill, true)
	else
		GOUtil.SetActive(self.vAffectCam_Monster_Skill, true)
	end
end

function CameraUtility:MainCameraOnly()
	Event.Instance:Fire("EnterFightCamera", false)
	GOUtil.SetActive(self.CurMainCamera, true)
	GOUtil.SetActive(self.vAffectCam_Monster, false)
	GOUtil.SetActive(self.vAffectCam_Boss, false)
	GOUtil.SetActive(self.vAffectCam_Boss_Skill, false)
	GOUtil.SetActive(self.vAffectCam_Monster_Skill, false)
	GOUtil.SetActive(self.vAffectCam_Player, false)
end

function CameraUtility:CloseMainCamera()
	if self.CurMainCamera then
		GOUtil.SetActive(self.CurMainCamera, false)
	end
end

function CameraUtility:EnterBossLiveSession(val)
	GOUtil.SetActive(self.vCamMain_boss, val)

	if val then
		self.GP.Team:SetActive(EnumFight.Camp.PLAYER, false)
	end
end
