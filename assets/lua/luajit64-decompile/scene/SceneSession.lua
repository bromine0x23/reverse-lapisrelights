-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Scene/SceneSession.lua

require("Scene/SceneBase")

SceneSession = class("SceneSession", SceneBase, true)

function SceneSession:ctor(...)
	return
end

function SceneSession:Init(vParam)
	SceneSession.base.Init(self)

	self.vParam = vParam
end

function SceneSession:LoadScene()
	self.SceneName = "Session"

	SceneSession.base.LoadScene(self)
end

function SceneSession:OnCache()
	self.Actors = {}

	for i = 1, 2 do
		local actor = ActorUtil.CreateActor(1000 + i)

		actor:Cache()

		self.Actors[i] = actor
	end

	self.Enemies = {}

	for i = 1, 1 do
		local actor = ActorUtil.CreateEnemy(9000 + i)

		actor:Cache()

		self.Enemies[i] = actor
	end

	self.SessionPerform = SessionPerform()

	self.SessionPerform:Cache()
end

function SceneSession:OnSceneLoaded()
	self.CinemachineBrain = GOUtil.GetComponent(GameObject.Find("Main Camera"), "CinemachineBrain")
	self.Light = GOUtil.GetComponent(GameObject.Find("Directional Light"), "Light")

	for i = 1, #self.Actors do
		local actor = self.Actors[i]

		actor:Create()
		GOUtil.SetTransformPosition(actor.SkeletonSystem.Root, i - 1.5, 0, 0)
	end

	for i = 1, #self.Enemies do
		local actor = self.Enemies[i]

		actor:Create()
		GOUtil.SetTransformPosition(actor.ModelSystem.Root, 0, 0, 8)
		GOUtil.SetTransformRotation(actor.ModelSystem.Root, 0, 180, 0)
	end

	self.SessionPerform:Create()
	self.SessionPerform:Play({
		self.Actors[1].SkeletonSystem.Root,
		self.Actors[2].SkeletonSystem.Root
	}, self.Enemies[1].ModelSystem.Root, self.CinemachineBrain, self.Light, function(...)
		print("OnComplete")
	end)
end

function SceneSession:OnPurge()
	self.SessionPerform:Destroy()
	self.SessionPerform:Purge()
end

function SceneSession.CreateInstance()
	if not SceneSession.Instance then
		SceneSession.Instance = SceneSession()
	end

	return SceneSession.Instance
end

function SceneSession.DestroyInstance()
	SceneSession.Instance = nil
end

function SceneSession:OnRegisterEvent()
	SceneSession.base.OnRegisterEvent(self)
end

function SceneSession:OnUnRegisterEvent()
	SceneSession.base.OnUnRegisterEvent(self)
end

return SceneSession
