-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Manager/SceneMgr.lua

SceneMgr = {
	data = require("luaData/SceneData")
}

local currentScene, loadScene

function SceneMgr.LoadScene(sceneName, param)
	Event.Instance:Fire("LOADSCENE", sceneName)
	LoadingMgr.Show(eLoadingType.Progress)

	loadScene = {
		SceneName = sceneName,
		Param = param
	}

	UIMgr:RemoveAllSafeArea()

	local availMemeory = OzSDKManager.GetMemeryInfo()

	if AppConst.LRUEnable then
		ResourceManager.SetLRUCacher(1, 20)
	end

	EffectMgr:Clear()
	UIMgr.Clear()

	if currentScene ~= nil then
		currentScene:OnUnRegisterEvent()
		currentScene:OnDestroy()
		currentScene:Destroy()
	end

	TimerMgr.AddTimer(eTimerType.FrameCount, 1, SceneMgr.OnLoadScene, nil)
end

function SceneMgr.OnLoadScene()
	if currentScene ~= nil then
		currentScene:OnPurge()
		currentScene:Purge()
		currentScene:OnEnd()
		currentScene.DestroyInstance()

		currentScene = nil
	end

	SceneManager.LoadSceneAsync(loadScene.SceneName, LoadSceneMode.Single)
end

function SceneMgr.Update()
	if currentScene ~= nil then
		currentScene:OnUpdate()
	end
end

function SceneMgr.GetCurrentScene()
	return currentScene
end

function OnSceneUnloaded()
	if loadScene ~= nil then
		local SceneClass = require("Scene/Scene" .. loadScene.SceneName)

		if SceneClass ~= nil then
			currentScene = SceneClass.CreateInstance()

			currentScene:OnInit(loadScene.Param)
		end

		loadScene = nil
	end
end

function OnSceneLoaded()
	ResourceMgr.SetMaxCoroutine(4)
	ResourceMgr.BeginSubmit(OnResourceLoaded)
	currentScene:Cache()
	currentScene:OnCache()
	ResourceMgr.EndSubmit()
end

SceneMgr.autoHideLoading = false

function OnResourceLoaded()
	if currentScene.isWaiting then
		Event.Instance:Add("OnInfoGameReqCompleteMgr", OnResourceLoaded, nil)

		return
	end

	Event.Instance:Remove("OnInfoGameReqCompleteMgr", OnResourceLoaded, nil)
	ResourceMgr.SetMaxCoroutine(1)
	currentScene:Create()
	currentScene:OnCreate()
	currentScene:OnRegisterEvent()
	System.GC.Collect()

	if SceneMgr.autoHideLoading then
		SceneMgr.autoHideLoading = false

		TimerMgr.AddTimer(eTimerType.FrameCount, 1, SceneMgr.OnHideLoadingUI, nil)
	end
end

function SceneMgr.OnHideLoadingUI()
	LoadingMgr.Hide(eLoadingType.Progress)
end
