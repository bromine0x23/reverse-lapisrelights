-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePass/PageAssetPass.lua

require("UI/Page/PagePass/PageAssetStage")
require("Info/PassMgr")

PageAssetPass = class("PageAssetPass", UIPanel)

function PageAssetPass:ctor()
	PageAssetPass.base.ctor(self, "UI/PanelPass/PanelAssetPass")
	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_Daily"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo(), {
		x = -600,
		y = -42
	})
end

function PageAssetPass:PreLoad()
	return
end

function PageAssetPass:OnBack()
	UIMgr.PopPanel()
end

function PageAssetPass:Purge()
	PageAssetPass.base.Purge(self)
end

function PageAssetPass:OnRegisterEvent()
	return
end

function PageAssetPass:OnUnRegisterEvent()
	return
end

function PageAssetPass:OnEnter(vParam)
	PersistentStoreUtil.SetBool("AssetDot", false)

	if not GuideMgr:IsGuided(GuideFunctionType.AssetPass) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.AssetPass)
	end
end

function PageAssetPass.EnterStageList(index, isTipFrom, needItem)
	local assetPass = 3
	local listAssetBranch = PassMgr:GetListAssetBranchId(assetPass)
	local branchId = listAssetBranch[1]
	local temp = {
		assetPass = assetPass,
		branchId = branchId,
		needItem = needItem
	}

	require("UI/Page/PageChapter/PageChapter")

	if not isTipFrom then
		UIMgr.InsertPanel(PageChapter, 1)
	end

	local page = PageAssetStage()

	UIMgr.SwitchPanel(page, temp, false, PageAssetPass.isSyncLoad)
end

function PageAssetPass:OnClickedGuideBtn()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.AssetPass)
end
