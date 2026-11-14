-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Loading/LoadingProgress.lua

LoadingProgress = class("LoadingProgress")

function LoadingProgress:ctor(vRoot)
	self.Root = vRoot
	self.PanelPrefabs = {
		"UI/PanelLoading/Loading1/Loading1",
		"UI/PanelLoading/Loading2/Loading2",
		"UI/PanelLoading/Loading3/Loading3",
		"UI/PanelLoading/Loading4/Loading4",
		"UI/PanelLoading/Loading5/Loading5",
		"UI/PanelLoading/Loading6/Loading6",
		"UI/PanelLoading/Loading7/Loading7",
		"UI/PanelLoading/Loading8/Loading8"
	}
end

function LoadingProgress:Show()
	TaskManager:ClearTips()

	self.progressPrefab = ResourceMgr.LoadSync("UI/PanelLoading/LoadingBase/LoadingProgress", GameObject)
	self.progressPrefab.DontDisposeOnUnloadAll = true
	self.LoadingUI = GOUtil.InstantiateUIPrefab(self.progressPrefab, self.Root)

	local HandleBackground = GOUtil.FindChildGameObject(self.LoadingUI, "HandleBackground")

	self.backgroundPrefab = ResourceMgr.LoadSync(self.PanelPrefabs[Mathf.Random(1, #self.PanelPrefabs)], GameObject)
	self.backgroundPrefab.DontDisposeOnUnloadAll = true

	GOUtil.InstantiateUIPrefab(self.backgroundPrefab, HandleBackground)

	self.ImgProgress = GOUtil.FindChildComponent(self.LoadingUI, "Img_ProgressBar/Img_ProgressSlot/Progress", "Image")
	self.tex_tips = GOUtil.FindChildComponent(self.LoadingUI, "Img_ProgressBar/Img_ProgressSlot/Progress/tex_tips", "Text")

	local loadingNoticeList = GetConfigArgJson("LoadingNoticeMessage") or {}
	local randomNum = Mathf.Random(1, #loadingNoticeList)

	self.tex_tips.text = Lang(loadingNoticeList[randomNum])
end

function LoadingProgress:Hide()
	if self.LoadingUI == nil then
		return
	end

	self.ImgProgress = nil

	Object.Destroy(self.LoadingUI)

	self.LoadingUI = nil

	ResourceMgr.Unload(self.progressPrefab)
	ResourceMgr.Unload(self.backgroundPrefab)
end

function LoadingProgress:SetProgress(percent)
	if self.ImgProgress ~= nil then
		self.ImgProgress.fillAmount = percent
	end
end
