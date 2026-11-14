-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Loading/LoadingBlackCurtain.lua

LoadingBlackCurtain = class("LoadingBlackCurtain")

function LoadingBlackCurtain:ctor(vRoot)
	self.Root = vRoot
end

function LoadingBlackCurtain:Show()
	local progressPrefab = ResourceMgr.LoadSync("UI/PanelLoading/LoadingBase/LoadingBlackCurtain", GameObject)

	self.LoadingUI = GOUtil.InstantiateUIPrefab(progressPrefab, self.Root)
end

function LoadingBlackCurtain:Hide()
	Object.Destroy(self.LoadingUI)

	self.LoadingUI = nil
end
