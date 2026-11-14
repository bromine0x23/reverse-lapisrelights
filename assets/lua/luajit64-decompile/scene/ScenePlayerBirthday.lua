-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Scene/ScenePlayerBirthday.lua

require("Scene/SceneBase")
require("UI/Page/PagePlayerInfo/PagePlayerBirthday")

local combData = require("luaData/CharacterTeam")

ScenePlayerBirthday = class("ScenePlayerBirthday", SceneBase, true)

function ScenePlayerBirthday.CreateInstance()
	if not ScenePlayerBirthday.Instance then
		ScenePlayerBirthday.Instance = ScenePlayerBirthday()
	end

	return ScenePlayerBirthday.Instance
end

function ScenePlayerBirthday.DestroyInstance()
	if ScenePlayerBirthday.Instance then
		ScenePlayerBirthday.Instance = nil
	end
end

local function GetLocationGroup(num)
	num = num or 1

	if num == 2 then
		return "ActorLocation_Two"
	elseif num == 3 then
		return "ActorLocation_Three"
	elseif num == 4 then
		return "ActorLocation_Four"
	elseif num == 5 then
		return "ActorLocation_Five"
	end

	return "ActorLocation_Five"
end

function ScenePlayerBirthday:OnInit(vParam)
	self.combIdx = 1

	if vParam and vParam.index then
		self.combIdx = vParam.index
	end

	self.combId = combData[self.combIdx].ID

	if vParam and vParam.combId then
		self.combId = vParam.combId
	end

	self:InitRole()

	self.SceneData = {
		Resource = "SceneAssets/Scene_talk/BG503/Prefab/BG503"
	}
	self.SceneTitle = "Magic"
end

function ScenePlayerBirthday:InitRole()
	self.InfoComb = CombinationMgr:Get(self.combId)

	if not self.InfoComb then
		self.InfoComb = CombinationMgr:Get(combData[1])
	end

	local config = {
		{
			105,
			104,
			103,
			102,
			101
		},
		{
			201,
			203,
			202
		},
		{
			301,
			302,
			303,
			304
		},
		{
			401,
			402,
			403
		},
		{
			501,
			502,
			503
		},
		{
			601,
			602
		},
		{
			701,
			702,
			703,
			704,
			705
		}
	}

	self.ListRole = {}

	local listRoleId = config[self.InfoComb.id] or {}

	for _, roleId in ipairs(listRoleId) do
		local role = RoleMgr:GetRole(roleId)

		if role ~= nil then
			table.insert(self.ListRole, role)
		end
	end
end

function ScenePlayerBirthday:OnCache()
	if not self.ListRole or next(self.ListRole) == nil then
		return
	end

	self.Actors = {}
	self.ActorFactories = {}
	self.ListRoleBank = {}

	for k, role in ipairs(self.ListRole) do
		if role ~= nil then
			local actorId = role.data.ActorID
			local controllerMain = ActorUtil.MotionControllerDataFilter(role.data.ActorID, "Fitting", "None")
			local actorFactory = ActorUtil.BuildActorFactoryByInfoRole(role, controllerMain)

			self.ActorFactories[k] = actorFactory

			actorFactory:Cache()
			SoundMgr.LoadBank(role.data.VocalBank, false, false)
			table.insert(self.ListRoleBank, role.data.VocalBank)
		end
	end
end

function ScenePlayerBirthday:OnCreate()
	self:PostprocessBlurEnable(false)

	local actorLocationNode = GameObject.Find("[Predeploy]/" .. GetLocationGroup(self.InfoComb.roleNum) .. "/")

	if actorLocationNode ~= nil then
		self.ActorLocations = {}

		for i = 1, self.InfoComb.roleNum do
			local actorLocation = GOUtil.FindChildGameObject(actorLocationNode, i)

			if actorLocation ~= nil then
				table.insert(self.ActorLocations, actorLocation)
			else
				error("Cannot find the character's location, please confirm...")
			end
		end
	else
		error("Cannot find the character's location, please confirm...")
	end

	if self.ActorFactories ~= nil then
		for k, actorFactory in pairs(self.ActorFactories) do
			if actorFactory ~= nil then
				local role = self.ListRole[k]

				if role ~= nil then
					local actor = actorFactory:Build()

					self.Actors[k] = actor

					actor:Create()
					role:InitFavorAni(actor.InteractSettingFile)
					actor.MotionSystem:FaceAtImmediate(self.UnityCamera.transform)
					actor.ExpressionSystem:FocusAt(self.UnityCamera.transform)
					actor.ExpressionSystem:GazeAt(self.UnityCamera.transform)
					GOUtil.AttachGameObject(actor.Root, self.ActorLocations[k])

					globalInterAniState = "otherState"

					PlayAnim(eInterctAnimType.idle, actor, role)
				end
			end
		end
	end

	UIMgr.SwitchPanel(PagePlayerBirthday, {
		combIdx = self.combIdx
	}, true)
end

function ScenePlayerBirthday:PostprocessBlurEnable(isEnable, index)
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

function ScenePlayerBirthday:OnRegisterEvent()
	return
end

function ScenePlayerBirthday:OnUnRegisterEvent()
	return
end

function ScenePlayerBirthday:OnDestroy()
	return
end

function ScenePlayerBirthday:OnPurge()
	if self.ActorFactories ~= nil then
		for _, actorFactory in pairs(self.ActorFactories) do
			if v ~= nil then
				actorFactory:Purge()
			end
		end

		self.ActorFactories = nil
	end

	if self.Actors ~= nil then
		for _, actor in pairs(self.Actors) do
			if actor ~= nil then
				GOUtil.AttachGameObject(actor.Root, nil)
				actor:Destroy()
			end
		end

		self.Actors = nil
	end

	if self.ListRoleBank ~= nil then
		for _, bankStr in ipairs(self.ListRoleBank) do
			SoundMgr.UnloadBank(bankStr)
		end

		self.ListRoleBank = nil
	end
end

function SceneBase:OnEnd()
	return
end

return ScenePlayerBirthday
