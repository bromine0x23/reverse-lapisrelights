-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Loading/LoadingRepeat.lua

LoadingRepeat = class("LoadingRepeat")

function LoadingRepeat:ctor(vRoot)
	self.Root = vRoot
	self.ReferenceCount = 0
	self.prefab = ResourceMgr.LoadSync("UI/PanelLoading/LoadingRepeat/LoadingRepeat", GameObject)
	self.prefab.DontDisposeOnUnloadAll = true
end

function LoadingRepeat:Show()
	self.ReferenceCount = self.ReferenceCount + 1

	if self.ReferenceCount == 1 and self.LoadingUI == nil then
		self.LoadingUI = GOUtil.InstantiateUIPrefab(self.prefab, self.Root)
	end
end

function LoadingRepeat:Hide()
	self.ReferenceCount = self.ReferenceCount - 1

	if self.ReferenceCount < 0 then
		self.ReferenceCount = 0
	end

	if self.ReferenceCount == 0 and self.LoadingUI ~= nil then
		Object.Destroy(self.LoadingUI)

		self.LoadingUI = nil
	end
end
