-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Scene/SceneSkillViewer.lua

require("Scene/SceneBase")
require("GameLogic/Fight.EnumFight")
require("GamePerform/SkillViewer/SkillViewer")
require("UI/Page/PageSkillViewer/PageSkillViewer")

SceneSkillViewer = class("SceneSkillViewer", SceneBase, true)

function SceneSkillViewer.CreateInstance()
	if not SceneSkillViewer.Instance then
		SceneSkillViewer.Instance = SceneSkillViewer()
	end

	return SceneSkillViewer.Instance
end

function SceneSkillViewer.DestroyInstance()
	SceneSkillViewer.Instance = nil
end

function SceneSkillViewer:OnInit(vParam)
	SV = SkillViewer()
	SV.UI = PageSkillViewer()
	SV.Scene = self
end

function SceneSkillViewer:OnCache()
	SoundMgr.LoadBank(PATH_BATTLE_BANK, false, false)
	ResourceMgr.SubmitCache("Actors/Settings/CharacterScaleSettings/SCL_Normal", self, "ActorScaleSetting", ScaleSettings)
	ResourceMgr.SubmitCache("Actors/Settings/CharacterScaleSettings/SCL_LoLi", self, "ActorScaleSettingLoli", ScaleSettings)
	SV.UI:Cache()
end

function SceneSkillViewer:OnCreate()
	SoundMgr.StopAll()
	UIMgr.SwitchPanel(SV.UI, nil, true)

	self.VCamGos = {}
	self.VCamGos[1] = GameObject.Find("[Predeploy]/SkillViewerCameraGroup/CharFaceView")
	self.VCamGos[2] = GameObject.Find("[Predeploy]/SkillViewerCameraGroup/CharGameView")
	self.VCamGos[3] = GameObject.Find("[Predeploy]/SkillViewerCameraGroup/BossFaceView")
	self.VCamGos[4] = GameObject.Find("[Predeploy]/SkillViewerCameraGroup/BossGameView")
	self.VCamGos[5] = GameObject.Find("[Predeploy]/SkillViewerCameraGroup/MonsterFaceView")
	self.VCamGos[6] = GameObject.Find("[Predeploy]/SkillViewerCameraGroup/MonsterGameView")
	self.VCamIdx = 0
	self.CampFxRoot = {}

	table.insert(self.CampFxRoot, GameObject.Find("[Predeploy]/CampFxLocation/1"))
	table.insert(self.CampFxRoot, GameObject.Find("[Predeploy]/CampFxLocation/2"))

	self.Light = GOUtil.GetComponent(GameObject.Find("Directional Light"), "Light")
end

function SceneSkillViewer:SetLightActive(val)
	GOUtil.SetActive(self.Light.gameObject, val)
end

function SceneSkillViewer:OnRegisterEvent()
	Event.Instance:Add("单位-创建", self.OnNpcCreate, self)
end

function SceneSkillViewer:OnUnRegisterEvent()
	Event.Instance:Remove("单位-创建", self.OnNpcCreate, self)
end

function SceneSkillViewer:OnDestroy()
	return
end

function SceneSkillViewer:OnPurge()
	SV:Purge()

	SV = nil
	self.VCamGos = nil
end

function SceneSkillViewer:OnEnd()
	return
end

function SceneSkillViewer:OnNpcCreate(npc)
	local index = 1

	if npc.UnitClass == EnumFight.UnitClass.PLAYER then
		index = 1
	elseif npc.UnitClass == EnumFight.UnitClass.ENEMY then
		index = npc.IsBoss == true and 3 or 5
	end

	for i, go in ipairs(self.VCamGos) do
		GOUtil.SetActive(go, i == index)
	end

	self.VCamIdx = index
end

function SceneSkillViewer:OnSwitchCamera()
	if not SV.Npc then
		return
	end

	local index = 1

	if SV.Npc.UnitClass == EnumFight.UnitClass.PLAYER then
		if self.VCamIdx == 2 or self.VCamIdx == 4 then
			index = 1
		else
			index = 2
		end
	elseif SV.Npc.UnitClass == EnumFight.UnitClass.ENEMY then
		if self.VCamIdx == 2 or self.VCamIdx == 4 or self.VCamIdx == 6 then
			self:OnNpcCreate(SV.Npc)

			return
		else
			index = SV.Npc.IsBoss == true and 4 or 6
		end
	end

	for i, go in ipairs(self.VCamGos) do
		GOUtil.SetActive(go, i == index)
	end

	self.VCamIdx = index
end

return SceneSkillViewer
