-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGvg/Monster3dRender.lua

local _cameraPos = {
	0,
	1000,
	7.45
}
local _cameraRot = {
	0,
	180,
	0
}
local _monsterPos = {
	0,
	998,
	0
}
local _monsterScale = 0.4
local mt = {}
local model = {}

function mt:Init(rawImgObj)
	if self.rawimg_UI3dRender and self.rawimg_UI3dRender.gameObject == rawImgObj then
		return
	end

	if self.renderCtrl then
		self:Purge()
	end

	self.rawimg_UI3dRender = GOUtil.GetComponent(rawImgObj, "RawImage")

	if not self.rawimg_UI3dRender then
		return
	end

	self.renderCtrl = GOUtil.AddMissingComponent(self.rawimg_UI3dRender.gameObject, "UI3DRenderControl")
	self.matRef = UIUtil.SetRawImageMaterial(self.rawimg_UI3dRender, "UI/Materials/DefaultUIForRT")

	local v = _cameraPos

	self.renderCtrl:SetCameraPosition(v[1], v[2], v[3])

	v = _cameraRot

	self.renderCtrl:SetCameraRotation(v[1], v[2], v[3])

	self.models = {}
	self.submitHandles = {}

	local obj = self.renderCtrl:GetRTCameraTransform().gameObject

	self.camera = GOUtil.GetComponent(obj, "Camera")

	self:OnRegisterEvent()
end

function mt:OnRegisterEvent()
	return
end

function mt:OnUnRegisterEvent()
	return
end

function mt:Purge()
	self:PurgeModel()

	if self.matRef then
		ResourceMgr.Unload(self.matRef)

		self.matRef = nil
	end

	if self.renderCtrl then
		Object.Destroy(self.renderCtrl)

		self.renderCtrl = nil
	end

	self:OnUnRegisterEvent()

	self.rawimg_UI3dRender = nil
	self.camera = nil
end

function mt:GetCamera()
	return self.camera
end

function mt:SetCameraPosition(x, y, z)
	self.renderCtrl:SetCameraPosition(x, y, z)
end

function mt:SetCameraRotation(x, y, z)
	self.renderCtrl:SetCameraRotation(x, y, z)
end

function mt:GetModel(idx)
	return self.models[idx]
end

function mt:LoadMonsters(monsterIds)
	self:PurgeModel()

	self.monsterIds = {}

	for i, id in ipairs(monsterIds) do
		self.monsterIds[i] = id

		self:_LoadModel(i)
	end
end

function mt:_LoadModel(idx)
	local handle = ResourceMgr.BeginSubmit(function()
		self:_OnAsyncPrecacheActorFinish(idx)
	end)

	table.insert(self.submitHandles, handle)

	local monsterId = self.monsterIds[idx]

	if monsterId then
		local monster = setmetatable({}, {
			__index = model
		})

		monster:Cache(monsterId)

		self.models[idx] = monster
		monster.portalIdx = idx
	end

	ResourceMgr.EndSubmit()
end

function mt:PurgeModel()
	for i = #self.submitHandles, 1, -1 do
		local handle = table.remove(self.submitHandles, i)

		ResourceMgr.Cancel(handle)
	end

	for i = #self.models, 1, -1 do
		local item = table.remove(self.models, i)

		item:Purge()
	end
end

function mt:_OnAsyncPrecacheActorFinish(idx)
	local monster = self.models[idx]

	if monster then
		monster:Create()

		self.rawimg_UI3dRender.enabled = true

		Event.Instance:Fire("OnLoaded_Monster3dRender", monster, idx)
	end
end

function model:Cache(monsterId)
	self.fxHandle = nil
	self.portalIdx = 1
	self.monsterId = monsterId

	local monsterInfo = EnemyManager:Get(monsterId)

	if monsterInfo and monsterInfo.data then
		local actorID = monsterInfo.data.ActorID
		local controller = ActorUtil.MotionControllerDataFilter(actorID, "Fight@Engagement", "None")
		local factory = ActorUtil.BuildEnemyFactory(actorID, controller)

		factory:Cache()

		self.factory = factory
	end
end

function model:Create()
	if not self.factory then
		return
	end

	self.actor = self.factory:Build()

	self.actor:Create()
	GOUtil.SetGameObjectLayer(self.actor.Root, LayerMask.NameToLayer("RT"))
	self:InitCollider()
end

function model:SetLocalPos(x, y, z)
	if self.actor then
		GOUtil.SetTransformLocalPosition(self.actor.Root, x, y, z)
	end
end

function model:SetLocalRot(x, y, z)
	if self.actor then
		GOUtil.SetTransformLocalRotation(self.actor.Root, x, y, z)
	end
end

function model:SetLocalScale(scale)
	if self.actor then
		GOUtil.SetTransformLocalScale(self.actor.Root, scale)
	end
end

function model:SetActive(val)
	if self.actor then
		GOUtil.SetActive(self.actor.Root, val)
	end
end

function model:GetActorRoot()
	return self.actor.Root
end

function model:Play(stateName, normalizedTime)
	self.actor.MotionSystem:Play(stateName, normalizedTime)
end

function model:Pause()
	self.actor.MotionSystem:Pause()
end

function model:Resume()
	self.actor.MotionSystem:Resume()
end

function model:SetLightRadiance(val)
	self.actor:SetMaterialProperty("_LightRadiance", val)
end

local _effectCfg = require("luaData/EffectData")
local _ActorData = require("luaData/ActorData")

function model:AllocFx(path, duration)
	EffectMgr:Free(self.fxHandle)

	self.fxHandle = EffectMgr:Alloc(path, self.actor.ModelSystem.Root, nil, duration)

	GOUtil.SetGameObjectLayer(self.actor.Root, LayerMask.NameToLayer("RT"))
end

function model:RemoveFx()
	EffectMgr:Free(self.fxHandle)
end

function model:InitCollider()
	self.collider = {}

	local body, head

	body = self.actor.ModelSystem:GetBone("Collider")

	if body then
		GOUtil.SetActive(body.gameObject, true)
		table.insert(self.collider, body.gameObject)
	end

	if head then
		table.insert(self.collider, head.gameObject)
	end
end

function model:Purge()
	if not self.actor then
		return
	end

	EffectMgr:Free(self.fxHandle)

	self.monsterId = nil

	self.actor:Destroy()

	self.actor = nil

	self.factory:Purge()

	self.factory = nil
	self.collider = {}
	self.portalIdx = 1
	self.waitFuns = {}
end

return mt
