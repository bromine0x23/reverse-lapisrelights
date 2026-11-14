-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTower/PageTower.lua

require("UI/Page/PageTower/CellTowerChapter")

PageTower = class("PageTower", UIPanel)

local normalBgPath = "Texture/PanelBG/BG_tower_03"
local hardBgPath = "Texture/PanelBG/BG_tower_03b"
local normalProgressPath = "UI/PageTower/AtlasPageTower/BG_tower_frame_202"
local hardProgressPath = "UI/PageTower/AtlasPageTower/BG_tower_frame_202b"

function PageTower:ctor()
	self.UIPrefabPath = "UI/PageTower/PageTower"

	self:AddChildPanel(DlgExit(), {
		title = Lang(40600002),
		callback = self.OnBack,
		helpCallback = self.OnClickedBtnGuide,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PageTower:OnBack()
	UIMgr.PopPanel()

	TowerChapterMgr.curChapter = nil
end

function PageTower:PreLoad()
	self:LoadResAsync("UI/PageTower/CellTowerChapter", "PrefabCellTowerChapter", GameObject)
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
end

function PageTower:Purge()
	self.base.Purge(self)

	if self.listCellItem then
		for i = 1, #self.listCellItem do
			self.listCellItem[i]:OnLeave()
		end
	end

	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	self.UIScrollTool = nil

	UITweenUtil.RemoveTween(self.content)
	ResourceMgr.Unload(self.PrefabCellItem)
	ResourceMgr.Unload(self.PrefabCellTowerChapter)
end

function PageTower:OnRegisterEvent()
	self:AddClick(self.DailyAward, self.OnClickedOpenDailyInfoBtn)
	self:AddClick(self.ButtonClose, self.OnClickedCloseDailyInfoBtn)
	self:AddClick(self.GetDaily, self.OnClickedDailyRewardBtn)
	self:AddClick(self.Hard, self.OnClickHard)
	self:AddClick(self.Normal, self.OnClickNormal)
end

function PageTower:OnUnRegisterEvent()
	self:RemoveClick(self.DailyAward, self.OnClickedOpenDailyInfoBtn)
	self:RemoveClick(self.ButtonClose, self.OnClickedCloseDailyInfoBtn)
	self:RemoveClick(self.GetDaily, self.OnClickedDailyRewardBtn)
	self:RemoveClick(self.Hard, self.OnClickHard)
	self:RemoveClick(self.Normal, self.OnClickNormal)
end

function PageTower:OnEnter(vParam)
	self:DealWithLocalization()

	if not GuideMgr:IsGuided(GuideFunctionType.Tower) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.Tower)
	end

	self.RawImage = self:GetChildComponent("BG/RawImage", "RawImage")
	self.Hard = self:GetChildGameObject("Panel/Difficulty/Hard")
	self.Normal = self:GetChildGameObject("Panel/Difficulty/Normal")
	self.HardImg = self:GetChildComponent("Panel/Difficulty/Hard", "Image")
	self.NormalImg = self:GetChildComponent("Panel/Difficulty/Normal", "Image")
	self.Lock = self:GetChildGameObject("Panel/Difficulty/Hard/Lock")
	self.DailyInfo = self:GetChildGameObject("Daily")
	self.DailyAward = self:GetChildGameObject("Panel/DailyAward")
	self.FX_UI_Welfare02 = self:GetChildGameObject("Panel/DailyAward/FX_UI_Welfare02")
	self.GetDaily = self:GetChildGameObject("Daily/Panel/GetDaily")
	self.GetDailyImage = self:GetChildComponent("Daily/Panel/GetDaily", "Image")
	self.Count = self:GetChildComponent("Panel/Progress/Count", "Text")
	self.Progress = self:GetChildComponent("Panel/Progress", "Image")
	self.ButtonClose = self:GetChildGameObject("Daily/Panel/ButtonClose")
	self.Anim_Chl_Idle = self:GetChildGameObject("BG/Anim_Chl_Idle")

	GOUtil.UpdateSpineSkeleton(self.Anim_Chl_Idle)
	self:InitData()
	self:InitChapterScrollView()
end

function PageTower:InitChapterScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/Chapter/ScrollArea")

	self.content = self:GetChildComponent("Panel/Chapter/ScrollArea/Content", "Transform")

	local count = #self.chapterList

	local function addClick(item)
		item:OnRegisterEvent()
	end

	local function updateTab(item, index)
		item.Index = index

		local info = self.chapterList[index]

		item:UpdateData(info)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, self.content, count, self.PrefabCellTowerChapter, CellTowerChapter, self, false, addClick, updateTab)

	local pos

	if self.selectId then
		for i, v in ipairs(self.chapterList) do
			if v.data.ID == self.selectId then
				pos = GetContentPos(self.UIScrollTool.ScrollView, #self.chapterList, i, true)
			end
		end

		self.selectId = nil
	else
		pos = GetContentPos(self.UIScrollTool.ScrollView, #self.chapterList, TenaryOp(self.chapterList[#self.chapterList]:IsOpen(), #self.chapterList, #self.chapterList - 1), true)
	end

	self.UIScrollTool:SetInitPos(Vector3(0, pos, 0))
	UITweenUtil.DoPosAnimationUp(self.content, 300, 0.3, pos)
end

function PageTower:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/Difficulty/Normal/Text", "Text")
	txt.text = _("UI_Common")
	txt = self:GetChildComponent("Panel/Difficulty/Hard/Text", "Text")
	txt.text = _("UI_Difficult")
	txt = self:GetChildComponent("Panel/Tip/Text", "Text")
	txt.text = _("Desc_TowerTip")
	txt = self:GetChildComponent("Panel/DailyAward/Text", "Text")
	txt.text = Lang(5000111)
	txt = self:GetChildComponent("Panel/Progress/Text", "Text")
	txt.text = _("PageChpater_rate")
end

function PageTower:InitData()
	if TowerChapterMgr.curChapter then
		self.diffType = TowerChapterMgr.curChapter.data.Type
		self.selectId = TowerChapterMgr.curChapter.data.ID
		TowerChapterMgr.curChapter = nil
	else
		self.diffType = ChapterFromType.tower
	end

	self.chapterList = TowerChapterMgr:GetTowerList(self.diffType)

	local num, total = TowerChapterMgr:GetPassProgress(self.diffType)

	self.Count.fontSize = 28
	self.Count.text = num .. "<size=24>/" .. total .. "</size>"

	self:SetSelectData()
	self:UpdateDailyItem()
end

function PageTower:OnClickNormal()
	if self.diffType == ChapterFromType.tower then
		return
	end

	self:OnClickDiff(ChapterFromType.tower)
	self:SetSelectData()
end

function PageTower:OnClickHard()
	if self.diffType == ChapterFromType.towerhard then
		return
	end

	if not TutorialMgr:IsOpenTut(TutorialFunctionType.TowerHard) then
		return
	end

	self:OnClickDiff(ChapterFromType.towerhard)
	self:SetSelectData()
end

function PageTower:SetSelectData()
	local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.TowerHard)

	SetActiveFunc(self.Lock, not isOpen)
	DealWithListRef(self, UIUtil.SetImageGray(self.HardImg, TenaryOp(self.diffType ~= ChapterFromType.towerhard, 1, 0)))
	DealWithListRef(self, UIUtil.SetImageGray(self.NormalImg, TenaryOp(self.diffType ~= ChapterFromType.tower, 1, 0)))
	UIUtil.SetRawImageTexture(self.RawImage, TenaryOp(self.diffType == ChapterFromType.tower, normalBgPath, hardBgPath), self)
	SetActiveFunc(self.DailyAward, self.diffType == ChapterFromType.tower)
	UIUtil.SetImageSprite(self.Progress, TenaryOp(self.diffType == ChapterFromType.tower, normalProgressPath, hardProgressPath), self)
	self:SetRewardEffect(self.diffType == ChapterFromType.tower)
end

function PageTower:OnClickDiff(type)
	self.diffType = type
	self.chapterList = TowerChapterMgr:GetTowerList(self.diffType)

	local num, total = TowerChapterMgr:GetPassProgress(self.diffType)

	self.Count.text = num .. "<size=25>/" .. total .. "</size>"

	self.UIScrollTool:UpdateListData(self.chapterList)

	local pos = GetContentPos(self.UIScrollTool.ScrollView, #self.chapterList, TenaryOp(self.chapterList[#self.chapterList]:IsOpen(), #self.chapterList, #self.chapterList - 1), true)

	self.UIScrollTool:SetInitPos(Vector3(0, pos, 0))
	self.UIScrollTool:SetContentPosImmediate(Vector3(0, -pos, 0), self.chapterList)
end

function PageTower:UpdateDailyItem()
	local dailyItem = TowerChapterMgr:GetCurDailyItem()
	local scrollArea = self:GetChildGameObject("Daily/Panel/ScrollArea")
	local scrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")

	scrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "RectTransform")
	scrollView.horizontal = true
	self.listCellItem = {}

	for i = 1, #dailyItem do
		local cell = CellItem(self.PrefabCellItem, scrollView.content.gameObject, self)
		local infoItem = ItemManager:GetValueItem(dailyItem[i][1], dailyItem[i][2])

		cell:Create()
		cell:UpdateWithNumType(infoItem)

		local scrollViewContent = GOUtil.AddMissingComponent(cell.UIRootObject, "UIScrollViewContent")

		scrollViewContent.scrollView = scrollView

		table.insert(self.listCellItem, cell)
	end
end

function PageTower:OnClickedDailyRewardBtn()
	if not self.chapterList[1].listStage[1]:IsPass() then
		UIMgr.ShowMsg(Lang(40600003))

		return
	end

	if TowerChapterMgr.dailyTimes >= TowerChapterMgr:GetDailyAwardCount() then
		return
	end

	local function pc(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Sucess then
			self:OnClickedCloseDailyInfoBtn()
			self:SetRewardEffect(false)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestTowerDailyGift(pc)
end

function PageTower:OnClickedOpenDailyInfoBtn()
	if TowerChapterMgr.dailyTimes >= TowerChapterMgr:GetDailyAwardCount() then
		UIMgr.ShowMsg(Lang(40600006))

		return
	end

	UIUtil.SetImageGray(self.GetDailyImage, self.chapterList[1].listStage[1]:IsPass() and 0 or 1)
	SetActiveFunc(self.DailyInfo, true)
end

function PageTower:SetRewardEffect(active)
	if active then
		if not self.chapterList[1].listStage[1]:IsPass() then
			SetActiveFunc(self.FX_UI_Welfare02, false)

			return
		end

		if TowerChapterMgr.dailyTimes >= TowerChapterMgr:GetDailyAwardCount() then
			SetActiveFunc(self.FX_UI_Welfare02, false)

			return
		end

		SetActiveFunc(self.FX_UI_Welfare02, true)
	else
		SetActiveFunc(self.FX_UI_Welfare02, false)
	end
end

function PageTower:OnClickedCloseDailyInfoBtn()
	SetActiveFunc(self.DailyInfo, false)
end

function PageTower:OnClickedBtnGuide()
	require("UI/Dlg/Public/PGuide")
	UIMgr.AddPanel(PGuide(), GuideFunctionType.Tower)
end

function PageTower:OnBackAndroid()
	if GOUtil.IsActiveSelf(self.DailyInfo) then
		self:OnClickedCloseDailyInfoBtn()

		return true
	end

	return false
end
