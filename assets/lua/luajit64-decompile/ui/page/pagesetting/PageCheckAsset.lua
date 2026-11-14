-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageSetting/PageCheckAsset.lua

PageCheckAsset = class("PageCheckAsset", UIPanel)

function PageCheckAsset:ctor()
	PageCheckAsset.base.ctor(self, "UI/PanelLoading/LoadingBase/LoadingProgress")

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

function PageCheckAsset:Purge()
	self.base.Purge(self)
end

function PageCheckAsset:PreLoad()
	return
end

function PageCheckAsset:OnRegisterEvent()
	return
end

function PageCheckAsset:OnUnRegisterEvent()
	return
end

function PageCheckAsset:OnEnter(vParam)
	local HandleBackground = GOUtil.FindChildGameObject(self.UIRootObject, "HandleBackground")
	local backgroundPrefab = ResourceMgr.LoadSync(self.PanelPrefabs[Mathf.Random(1, #self.PanelPrefabs)], GameObject)

	GOUtil.InstantiateUIPrefab(backgroundPrefab, HandleBackground)

	self.ImgProgress = GOUtil.FindChildComponent(self.UIRootObject, "Img_ProgressBar/Img_ProgressSlot/Progress", "Image")
	self.tex_tips = GOUtil.FindChildComponent(self.UIRootObject, "Img_ProgressBar/Img_ProgressSlot/Progress/tex_tips", "Text")
	self.AniLoading = self:GetChildGameObject("AniLoading")

	self.AniLoading:SetActive(false)

	self.curCount = 0
	self.tex_tips.text = ""
	self.AssetHashCheck = GOUtil.AddMissingComponent(self.UIRootObject, "AssetHashCheck")

	self.AssetHashCheck:CheckAssetHash(self.ImgProgress, self.tex_tips, self.OnFinish)
end

function PageCheckAsset.OnFinish(isBreak)
	local function wrap_cb(index)
		Restart()
	end

	if isBreak then
		UIMgr.ShowDialog(_("破損したリソースを確認しました"), wrap_cb)
	else
		UIMgr.ShowDialog(_("リソース確認完了"), wrap_cb)
	end
end
