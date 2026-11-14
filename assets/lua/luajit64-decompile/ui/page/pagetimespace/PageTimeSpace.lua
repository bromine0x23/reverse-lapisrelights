-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTimeSpace/PageTimeSpace.lua

require("UI/Item/UITab")
require("UI/Page/PageTimeSpace/PageTimeSpaceStage")
require("UI/Page/PageTimeSpace/PageTimeSpaceTask")
require("UI/Page/PageTimeSpace/DlgPreviewEnemy")

PageTimeSpace = class("PageTimeSpace", UIPanel)
PageTimeSpace.ImageTag = {
	"UI/PageTimeSpace/AtlasPageTimeSpace/IC_crack_challenge_01",
	"UI/PageTimeSpace/AtlasPageTimeSpace/IC_crack_challenge_02",
	"UI/PageTimeSpace/AtlasPageTimeSpace/IC_crack_challenge_03"
}
PageTimeSpace.PosTag = {
	-95,
	-130
}

function PageTimeSpace:ctor()
	self.UIPrefabPath = "UI/PageTimeSpace/PageTimeSpace"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_TimeSpace"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo(), {
		x = -600,
		y = -42
	})
end

function PageTimeSpace:PreLoad()
	self:LoadResAsync("UI/PanelTask/CellTask", "PrefabCell", GameObject)
	self:LoadResAsync("UI/Item/CellScoreItem", "PrefabCellScoreItem", GameObject)
end

function PageTimeSpace:OnClickedGuideBtn()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.TimeSpace)
end

function PageTimeSpace:OnBack()
	UIMgr.PopPanel()
end

function PageTimeSpace:Purge()
	PageTimeSpace.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCell)
	ResourceMgr.Unload(self.PrefabCellScoreItem)
	UnloadAllImageSprite(self)

	if self.DlgPreviewEnemy then
		self.DlgPreviewEnemy:Purge()

		self.DlgPreviewEnemy = nil
	end

	if self.uiTab then
		self.uiTab:Dispose()
	end
end

function PageTimeSpace:OnRegisterEvent()
	self:AddClick(self.btnPrize, self.OnClickPrize)
	self:AddClick(self.btnStart, self.OnClickStart)
	self:AddClick(self.shopBtn, self.OnClickShop)
	UIMgr.SetUpdatePanel(self)
end

function PageTimeSpace:OnUnRegisterEvent()
	self:RemoveClick(self.btnPrize, self.OnClickPrize)
	self:RemoveClick(self.btnStart, self.OnClickStart)
	self:RemoveClick(self.shopBtn, self.OnClickShop)
	UIMgr.RemoveUpdatePanel(self)
end

function PageTimeSpace:OnClickPrize()
	UIMgr.SwitchPanel(PageTimeSpaceTask)
end

function PageTimeSpace:OnClickStart()
	UIMgr.SwitchPanel(PageTimeSpaceStage(self.timeSpaceChapter[self.currentStage]), {
		chapter = self.timeSpaceChapter[self.currentStage]
	})
end

function PageTimeSpace:OnClickShop()
	require("UI/Page/PageShop/PageShop")
	PageShop.InitNetData({
		tagIndex = -1,
		tabMainIndex = 3
	})
end

function PageTimeSpace:OnClickedTabGroup(idx)
	self.currentStage = idx

	self.DlgPreviewEnemy:LoadActor(tonumber(self.timeSpaceChapter[self.currentStage].data.BackIcon))
end

function PageTimeSpace:SetBattleTag()
	for i = 1, 5 do
		local chapter = self.timeSpaceChapter[i]
		local idx = 0

		idx = chapter.completed and 3 or chapter.data.ID == TimeSpaceChapterMgr.CurChapterId and 1 or 2

		UIUtil.SetImageOverrideSprite(self["uiTabTag" .. i], PageTimeSpace.ImageTag[idx], true)

		if idx == 3 then
			GOUtil.SetTransformLocalPosition(self["uiTabTag" .. i].gameObject, PageTimeSpace.PosTag[2], self["uiTabTag" .. i].transform.localPosition.y, self["uiTabTag" .. i].transform.localPosition.z)
		else
			GOUtil.SetTransformLocalPosition(self["uiTabTag" .. i].gameObject, PageTimeSpace.PosTag[1], self["uiTabTag" .. i].transform.localPosition.y, self["uiTabTag" .. i].transform.localPosition.z)
		end

		local total = #chapter.listStage
		local num = 0

		for i, v in ipairs(chapter.listStage) do
			if v:IsPass() or v:GetStar() > 0 then
				num = num + 1
			end
		end

		local isGet = chapter.pb.awardStatus[3] == 1

		if not isGet and total <= num then
			GOUtil.SetActive(self["uiTabDot" .. i], true)
		else
			GOUtil.SetActive(self["uiTabDot" .. i], false)
		end
	end
end

function PageTimeSpace:OnEnter()
	if not GuideMgr:IsGuided(GuideFunctionType.TimeSpace) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.TimeSpace)
	end

	self.currentStage = 1
	self.timeSpaceChapter = TimeSpaceChapterMgr:GetAllTower()

	for i = 1, #self.timeSpaceChapter do
		local chapter = self.timeSpaceChapter[i]

		if chapter.data.ID == TimeSpaceChapterMgr.CurChapterId then
			self.currentStage = i
		end
	end

	self:DealWithLocalization()

	self.tabGo = self:GetChildGameObject("SafeArea/TagGroup")
	self.uiTab = UITab(self.tabGo, 5, self.OnClickedTabGroup, self, self.currentStage)

	for i = 1, 5 do
		self["uiTabTag" .. i] = self:GetChildComponent("SafeArea/TagGroup/Btn" .. i .. "/Tag", "Image")
		self["uiTabDot" .. i] = GOUtil.FindChildGameObject(self.tabGo, "Btn" .. i .. "/Dot")
	end

	self:SetBattleTag()

	self.btnPrize = self:GetChildGameObject("SafeArea/Panel/prize_btn")
	self.btnStart = self:GetChildGameObject("SafeArea/Panel/start_btn")
	self.txtReset = self:GetChildComponent("SafeArea/Panel/reset_time/txt_resettime", "Text")
	self.shopBtn = self:GetChildGameObject("SafeArea/Panel/shop_btn")

	UIUtil.SetImageSprite(self:GetChildComponent("SafeArea/Panel/shop_btn", "Image"), "UI/PageGvg/AtlasGvg/BTN_scoreshop_001")
	GOUtil.SetRectTransformSizeDelta(self.shopBtn, 172, 144)

	self.startText = self:GetChildComponent("SafeArea/Panel/start_btn/Text", "Text")

	local timeStr = TimeSpaceChapterMgr:GetResetTimeString()

	self.txtReset.text = _("Desc_last_time") .. ": " .. timeStr
	self.startText.text = _("TimeSpace_Enter")
	self.GoSpinePoint = self:GetChildGameObject("Spine")

	UITweenUtil.CommonTweenRight(self.tabGo.transform, 40, 0.14)
	self:SetSafeArea(self:GetChildGameObject("SafeArea"))
	self:InitSpine()

	self.obj = self:GetChildGameObject("SafeArea/Enemy")

	local control = GOUtil.AddMissingComponent(self.obj, "UI3DRenderControl")

	self.DlgPreviewEnemy = DlgPreviewEnemy()

	self.DlgPreviewEnemy:Init(control)
	self.DlgPreviewEnemy:LoadActor(tonumber(self.timeSpaceChapter[self.currentStage].data.BackIcon))
end

function PageTimeSpace:InitSpine()
	local spineSkeAssetPath = self.timeSpaceChapter[self.currentStage].data.BackSpine .. "_SkeletonData"
	local spineSkeMatPath = self.timeSpaceChapter[self.currentStage].data.BackSpine .. "_Material"
	local skeletonDataAssetRef, materialRef = UIUtil.SetSpineSkeletonDataAsset(self.GoSpinePoint, spineSkeAssetPath, spineSkeMatPath, skeletonDataAssetRef, materialRef)

	UIUtil.SetSpineAnimationState(self.GoSpinePoint, "none", true, true)
	DealWithListSpineRef(self, skeletonDataAssetRef)
	DealWithListSpineRef(self, materialRef)
end

function PageTimeSpace:DealWithLocalization()
	for i = 1, 5 do
		local txt = self:GetChildComponent("SafeArea/TagGroup/Btn" .. i .. "/Btn/Text", "Text")

		txt.text = "<size=32>" .. Lang(self.timeSpaceChapter[i].data.Name) .. "</size>"
		txt = self:GetChildComponent("SafeArea/TagGroup/Btn" .. i .. "/Select/Text", "Text")
		txt.text = "<size=32>" .. Lang(self.timeSpaceChapter[i].data.Name) .. "</size>"
	end
end

function PageTimeSpace:OnUpdateSecond()
	if not self.txtReset or self.needReboot then
		return
	end

	local timeStr, needRefresh = TimeSpaceChapterMgr:GetResetTimeString()

	self.txtReset.text = _("Desc_last_time") .. ": " .. timeStr

	if needRefresh then
		self.needReboot = true

		UIMgr.ShowDialog(_("TimeSpace_Refresh"), function()
			self:OnBack()
		end)
	end
end

function PageTimeSpace:UpdateTab()
	return
end
