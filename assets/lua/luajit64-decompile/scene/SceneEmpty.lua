-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Scene/SceneEmpty.lua

require("Scene/SceneBase")

SceneEmpty = class("SceneEmpty", SceneBase, true)

function SceneEmpty.CreateInstance()
	if not SceneEmpty.Instance then
		SceneEmpty.Instance = SceneEmpty()
	end

	return SceneEmpty.Instance
end

function SceneEmpty.DestroyInstance()
	SceneEmpty.Instance = nil
end

function SceneEmpty:OnInit(vParam)
	return
end

function SceneEmpty:OnCache()
	return
end

function SceneEmpty:OnCreate()
	return
end

function SceneEmpty:OnRegisterEvent()
	return
end

function SceneEmpty:OnUnRegisterEvent()
	return
end

function SceneEmpty:OnDestroy()
	return
end

function SceneEmpty:OnPurge()
	return
end

function SceneEmpty:OnEnd()
	return
end

return SceneEmpty
