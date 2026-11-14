-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePass/PageCardStage.lua

require("UI/Page/PagePass/CellCommonStage")
require("UI/Page/PageChapter/DlgStageSweep")

local InfoTeam = require("Info/InfoTeam")

PageCardStage = class("PageCardStage", UIPanel, true)

function PageCardStage:ctor()
	self.UIPrefabPath = "UI/PanelPass/PanelCardStage"

	self:AddChildPanel(DlgExit(), {
		title = _("Desc_theme_CardStage"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo(), {
		x = -600,
		y = -42
	})
end

function PageCardStage:PreLoad()
	self:LoadResAsync("UI/PanelPass/CellStage", "PrefabCellStage", GameObject)
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem", GameObject)
	self:LoadResAsync("UI/Common/CellCard/CellCard", "PrefabCellCard", GameObject)
end

function PageCardStage:OnBack()
	CardExtraMgr.LastCardStageCardId = 0

	CardExtraMgr:SetCardStagePosX(0)
	UIMgr.PopPanel()
end

function PageCardStage:Purge()
	self.base.Purge(self)
	self:OnLeave()
end

function PageCardStage:OnLeave()
	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	ResourceMgr.Unload(self.PrefabCellStage)
	ResourceMgr.Unload(self.PrefabCellItem)
	ResourceMgr.Unload(self.PrefabCellCard)

	if self.listCellStage then
		for i = 1, #self.listCellStage do
			self.listCellStage[i]:OnLeave()
		end

		self.listCellStage = nil
	end

	UITweenUtil.RemoveTween(self.StageContent.transform)
end

function PageCardStage:OnRegisterEvent()
	self:AddClick(self.BtnAsce, self.OnClickedBtnAsce)
	self:AddClick(self.BtnDesce, self.OnClickedBtnDesce)
	self:AddClick(self.BtnFilter, self.OnClickedBtnFilter)
	Event.Instance:Add(EventEnum.EnterStage, self.DealWithEnterStage, self)
	Event.Instance:Add("UpdateStageNum", self.UpdateStageNum, self)
	Event.Instance:Add("UpdateMonthCard", self.UpdateStageNum, self)
end

function PageCardStage:OnUnRegisterEvent()
	self:RemoveClick(self.BtnAsce, self.OnClickedBtnAsce)
	self:RemoveClick(self.BtnDesce, self.OnClickedBtnDesce)
	self:RemoveClick(self.BtnFilter, self.OnClickedBtnFilter)
	Event.Instance:Remove(EventEnum.EnterStage, self.DealWithEnterStage, self)
	Event.Instance:Remove("UpdateStageNum", self.UpdateStageNum, self)
	Event.Instance:Remove("UpdateMonthCard", self.UpdateStageNum, self)
end

function PageCardStage:OnEnter(vParam)
	self:DealWithLocalization()

	if not GuideMgr:IsGuided(GuideFunctionType.CardPass) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.CardPass)
	end

	self.ImgFilter = self:GetChildComponent("Panel/BtnFilter", "Image")
	self.TxtFilterType = self:GetChildComponent("Panel/BtnFilter/Layout/Text", "Text")
	self.ImgFilterType = self:GetChildComponent("Panel/BtnFilter/Layout/Image", "Image")
	self.GoPrompt = self:GetChildGameObject("Panel/Prompt")
	self.TxtChallenge = self:GetChildComponent("Panel/ChallengeNum/Text", "Text")
	self.GoStageArea = self:GetChildGameObject("Panel/StageList")
	self.StageContent = self:GetChildGameObject("Panel/StageList/ScrollArea/Content")
	self.StageListAnim = self:GetChildComponent("Panel/StageList", "Animator")
	self.BtnAsce = self:GetChildGameObject("Panel/BtnAsce")
	self.BtnDesce = self:GetChildGameObject("Panel/BtnDesce")
	self.BtnFilter = self:GetChildGameObject("Panel/BtnFilter")
	self.ScrollArea = self:GetChildGameObject("Panel/CardList/ScrollArea")
	self.Content = GOUtil.FindChildComponent(self.ScrollArea, "Content", "Transform")

	local lg = GOUtil.GetComponent(self.Content.gameObject, "LayoutGroup")
	local cw = GOUtil.GetRectTransformWidth(self.Content.gameObject)

	self.needCnt = math.ceil((cw - lg.padding.left + lg.spacing.x) / (lg.cellSize.x + lg.spacing.x))

	self:InitData(vParam)
end

function PageCardStage:DealWithLocalization()
	local Text = self:GetChildComponent("Panel/Prompt/Text", "Text")

	Text.text = _("Desc_Card_None_Filter")
end

function PageCardStage:InitData(vParam)
	if CardExtraMgr.enterType ~= eEnterType.cardPass then
		CardExtraMgr.enterType = eEnterType.cardPass
	end

	self.cardIdx = 1

	self:UpdateData()
	self:UpdateFilterShow()
	self:UpdateSort()
	self:UpdateChallengeNum()
end

function PageCardStage:UpdateData(isSort)
	self.listShowCard = {}

	if not isSort then
		self.listCard = {}
		self.listCard = CardFilterMgr.GetFilterCards(eFilterSystemType.Intance)

		for i = #self.listCard, 1, -1 do
			local infoRoleCard = self.listCard[i]

			if not infoRoleCard:CanChallenge() then
				table.remove(self.listCard, i)
			end
		end

		if #self.listCard == 0 then
			self:UpdateCardList()
			self:UpdateStageList()

			return
		end
	else
		self.listCard = CardSortMgr.Lift(self.listCard)
	end

	if #self.listCard > 0 and #self.listCard < self.needCnt * 2 then
		for i = 1, self.needCnt * 2 do
			if self.listCard[i] then
				table.insert(self.listShowCard, self.listCard[i])
			else
				table.insert(self.listShowCard, {})
			end
		end
	else
		self.listShowCard = self.listCard
	end

	if CardExtraMgr.LastCardStageCardId ~= 0 then
		for k, v in ipairs(self.listCard) do
			if v.id == CardExtraMgr.LastCardStageCardId then
				self.cardIdx = k

				break
			end
		end

		CardExtraMgr.LastCardStageCardId = 0
	else
		self.cardIdx = 1
	end

	self:UpdateCardList()
	self:UpdateStageList()
end

function PageCardStage:UpdateCardList(keepPos)
	if self.UIScrollTool then
		if keepPos then
			self.UIScrollTool:UpdateListDataKeepPos(self.listShowCard)
		else
			self.UIScrollTool:UpdateListData(self.listShowCard)
		end

		return
	end

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCell)
		self:AddListener(item.UIRootObject, self.OnLongPressCell, EventTriggerType.PointerLongPress)
	end

	local function updateCallback(item, index)
		local info = self.listShowCard[index]
		local data = {}

		if info and info.id then
			data = {
				cardId = info.id,
				selIdx = self.cardIdx
			}
		else
			data = {
				index = index
			}
		end

		item:UpdateData(data, false, true, true)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.ScrollArea, self.Content, #self.listShowCard, self.PrefabCellCard, CellCard, self, true, addCallback, updateCallback)

	local x = GetContentPos(self.UIScrollTool.ScrollView, math.ceil(#self.listShowCard / 2), math.ceil(self.cardIdx / 2), true)

	self.UIScrollTool:SetInitPos(Vector3(-x, 0, 0))
end

function PageCardStage:UpdateFilterShow()
	local list = CardFilterMgr.GetFilterRuleNameList(eFilterSystemType.Intance)

	if #list == 0 then
		self.TxtFilterType.text = _("Desc_Screen")
		self.ImgFilterType.color = Color.New(0.44313725490196076, 0.44313725490196076, 0.44313725490196076, 1)

		SetImageSprite(self.ImgFilter, "UI/PanelPass/AtlasPanelCardStage/BTN_white_01", self)
	else
		if #list == 1 then
			self.TxtFilterType.text = list[1]
		elseif #list > 1 then
			self.TxtFilterType.text = _("Desc_ScreenIn")
		end

		self.ImgFilterType.color = Color.New(0.22745098039215686, 0.5137254901960784, 0.23921568627450981, 1)

		SetImageSprite(self.ImgFilter, "UI/PanelRoleCard/AtlasPanelCardList/BTN_white_02", self)
	end

	SetActiveFunc(self.GoPrompt, #self.listCard == 0)
end

function PageCardStage:OnClickedCell(data)
	local go = data.pointerPress.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index

	if not self.listCard[index] then
		return
	end

	if self.cardIdx == index then
		return
	end

	self.cardIdx = index

	UITweenUtil.RemoveTween(self.StageContent.transform)
	UITweenUtil.DoListAnimationUp(self.StageContent.transform, 150, 0.3, nil, nil)

	if self.UIScrollTool and self.UIScrollTool.ItemRoot2ItemDict then
		for i = 1, self.UIScrollTool.ScrollView.CachedEntryObjects.Count do
			local go = self.UIScrollTool.ScrollView.CachedEntryObjects:get_Item(i - 1)

			self.UIScrollTool.ItemRoot2ItemDict:GetValue(go).Item:UpdateSlectState(index)
		end
	end

	self:UpdateStageList()
end

function PageCardStage:OnLongPressCell(data)
	local go = data.pointerPress.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index
	local infoRoleCard = self.listCard[index]

	if not infoRoleCard then
		return
	end

	if data.clickCount == 1 then
		CardSwitchMgr:ResetCardIdsByFilter(eFilterSystemType.Intance)
		self:DealWithEnterStage()
		require("UI/Page/PageRoleCard/Page/PageRoleCard")
		UIMgr.SwitchPanel(PageRoleCard, {
			cardId = infoRoleCard.id
		})
	end
end

function PageCardStage:UpdateStageList()
	self.infoRoleCard = self.listCard[self.cardIdx]

	if not self.infoRoleCard then
		GOUtil.SetActive(self.GoStageArea, false)

		return
	end

	GOUtil.SetActive(self.GoStageArea, true)

	self.listStage = {}

	local chapterId = self.infoRoleCard.data.CardChapter

	if chapterId ~= 0 then
		local infoChapter = ChapterMgr:GetChapter(chapterId)

		self.listStage = infoChapter.listStage
	end

	local cnt = table.getn(self.listStage)

	local function sizeSet()
		local cH = GOUtil.GetRectTransformSizeDeltaHeight(self.PrefabCellStage)
		local contentH = GOUtil.GetRectTransformSizeDeltaHeight(self.StageContent)
		local spaceY = GOUtil.GetComponent(self.StageContent, "VerticalLayoutGroup").spacing
		local targetContentH = (cnt - 1) * (cH + spaceY) - spaceY

		GOUtil.SetRectTransformSizeDeltaHeight(self.StageContent, targetContentH)
	end

	local function updateC()
		for k, item in ipairs(self.listCellStage) do
			if k < cnt then
				local info = self.listStage[k + 1]

				item:DestroyContent()
				item:UpdateData({
					infoStage = info
				})
			else
				SetActiveFunc(item.UIRootObject, false)
				sizeSet()
			end
		end
	end

	if self.listCellStage and next(self.listCellStage) ~= nil then
		GOUtil.SetTransformLocalPosition(self.StageContent, 0, 0, 0)
		updateC()

		return
	end

	sizeSet()

	self.listCellStage = {}

	for i = 1, cnt - 1 do
		local cell = CellCommonStage(self.PrefabCellStage, self.StageContent)

		cell:Create()
		table.insert(self.listCellStage, cell)
	end

	updateC()
	UITweenUtil.DoListAnimationUp(self.StageContent.transform, 150, 0.3, nil, nil)
end

function PageCardStage:OnClickedBtnFilter()
	local chioceStruct = CardFilterMgr.FilterStruct[eFilterSystemType.Intance]
	local data = {}

	for k, v in ipairs(chioceStruct) do
		data[k] = v
	end

	data.panel = self
	data.callback = self.ChangeFilter
	data.listState = CardFilterMgr.FilterListRule[eFilterSystemType.Intance]

	UIMgr.AddPanel(DlgCardFilter(), data)
end

function PageCardStage:ChangeFilter(data)
	if data.hasChange then
		CardFilterMgr.ResetFilterRule(eFilterSystemType.Intance, data.listState)

		self.cardIdx = 1

		self:UpdateData()
		self:UpdateFilterShow()
	end
end

function PageCardStage:OnClickedBtnAsce()
	CardFilterMgr.ResetSortRule(eFilterSystemType.Intance, eSortType.Asce)
	self:UpdateSort()
	self:UpdateData()
end

function PageCardStage:OnClickedBtnDesce()
	CardFilterMgr.ResetSortRule(eFilterSystemType.Intance, eSortType.Desce)
	self:UpdateSort()
	self:UpdateData()
end

function PageCardStage:UpdateSort()
	local sortType = CardFilterMgr.FilterSortRule[eFilterSystemType.Intance]

	SetActiveFunc(self.BtnAsce, sortType == eSortType.Desce)
	SetActiveFunc(self.BtnDesce, sortType == eSortType.Asce)
end

function PageCardStage:DealWithEnterStage()
	CardExtraMgr.LastCardStageCardId = self.infoRoleCard.id
end

function PageCardStage:UpdateStageNum()
	self:UpdateCardList()
	self:UpdateStageList()
	self:UpdateChallengeNum()
end

function PageCardStage:UpdateChallengeNum()
	self.TxtChallenge.text = _("Desc_AllLastNum") .. CardChapterMgr.GetTotalRemainingChallengeNum() .. "/" .. CardChapterMgr.GetTotalLimitChallengeNum()
end

function PageCardStage:OnClickedGuideBtn()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.CardPass)
end
