-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Scene/SceneLogin.lua

require("Scene/SceneBase")
require("UI/Page/PageLogin/PageLogin")
require("UI/Page/PageLogin/PageDistrict")
require("UI/Page/PageLogin/PlayerCreate")
require("UI/Page/PageLogin/PageGenName")

SceneLogin = class("SceneLogin", SceneBase, true)

function SceneLogin.CreateInstance()
	if not SceneLogin.Instance then
		SceneLogin.Instance = SceneLogin()
	end

	return SceneLogin.Instance
end

function SceneLogin.DestroyInstance()
	SceneLogin.Instance = nil
end

function SceneLogin:OnInit(vParam)
	self.SceneData = SceneMgr.data[11]
	self.BGM = self.SceneData.BGM
	self.SceneData.BGM = ""
end

function SceneLogin:OnCache()
	UIMgr.CachePrefab("UI/PanelLogin/PanelConfirm")
	require("luaData/LoginPageManage")
	require("luaData/CardPool")
	require("Info/InfoChapter")
	ChapterMgr:InitChapterList()
end

function SceneLogin:OnCreate()
	UIMgr.SwitchPanel(PageLogin, nil, true)
end

function SceneLogin:OnRegisterEvent()
	return
end

function SceneLogin:OnUnRegisterEvent()
	return
end

function SceneLogin:OnDestroy()
	return
end

function SceneLogin:OnPurge()
	return
end

function SceneLogin:OnEnd()
	self.PageLogin = nil
end

return SceneLogin
