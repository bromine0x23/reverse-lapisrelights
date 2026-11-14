-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Scene/SceneBase.lua

SceneBase = class("SceneBase")
SceneBase.LastBank = nil

function SceneBase:ctor()
	self.Scene = {}
	self.SceneData = nil
	self.UnityCamera = nil
end

function SceneBase:Cache()
	if self.SceneData ~= nil and self.SceneData.Resource ~= "" then
		ResourceMgr.SubmitCache(self.SceneData.Resource, self.Scene, "Prefab", GameObject)
	end
end

function SceneBase:Create()
	if self.Scene.Prefab ~= nil then
		self.Scene.Object = GOUtil.InstantiatePrefab(self.Scene.Prefab, nil)
		self.UnityCamera = GameObject.Find("[Predeploy]/Camera")
		self.Scene.Postprocess = GOUtil.AddMissingComponent(self.UnityCamera, "SeanLib.PostProcessV2.SeanPostProcessLayer")
	end

	if self.SceneData ~= nil then
		if self.SceneData.Bank ~= "" and InfoBGMEventMgr:GetSceneMusic().Bank ~= self.SceneData.Bank and self.SceneData.Bank ~= nil then
			SoundMgr.LoadBank(self.SceneData.Bank, false, false)
		end

		if self.SceneData.BGM ~= "" then
			if InfoBGMEventMgr:GetSceneMusic().BGM ~= self.SceneData.BGM and self.SceneData.BGM ~= nil then
				local event = self.SceneData.BGM

				SoundMgr.PostEvent(self.SceneData.BGM, UIMgr.UICamera.gameObject)
			end
		else
			SoundMgr.StopAll()
		end

		if SceneBase.LastBank ~= nil then
			SoundMgr.DelayUnloadBank(SceneBase.LastBank, 1)

			SceneBase.LastBank = nil
		end

		SceneBase.LastBank = self.SceneData.Bank
	end
end

function SceneBase:Destroy()
	if self.Scene.SceneObject ~= nil then
		Object.Destroy(self.Scene.SceneObject)
	end
end

function SceneBase:Purge()
	self.Scene = nil
	self.SceneData = nil
	self.UnityCamera = nil
end

function SceneBase:OnInit()
	error("you should implement OnInit")
end

function SceneBase:OnCache()
	error("you should implement OnCache")
end

function SceneBase:OnCreate()
	error("you should implement OnCreate")
end

function SceneBase:OnRegisterEvent()
	error("you should implement OnRegisterEvent")
end

function SceneBase:OnUpdate()
	return
end

function SceneBase:OnUnRegisterEvent()
	error("you should implement OnUnRegisterEvent")
end

function SceneBase:OnDestroy()
	error("you should implement OnDestroy")
end

function SceneBase:OnPurge()
	error("you should implement OnPurge")
end

function SceneBase:OnEnd()
	error("you should implement OnEnd")
end
