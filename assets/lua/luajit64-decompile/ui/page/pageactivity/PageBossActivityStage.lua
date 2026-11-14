-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivity/PageBossActivityStage.lua

require("UI/Page/PagePass/CellCommonStage")

local BossActiveUIData = require("luaData/BossctiveUIData")

PageBossActivityStage = class("PageBossActivityStage", UIPanel)

function PageBossActivityStage:ctor()
	self.UIPrefabPath = "UI/PanelActivity/PanelBossActivityStage"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_ActLevel"),
		callback = self.OnBack,
		panel = self
	})
end

function PageBossActivityStage:PreLoad()
	self:LoadResAsync("UI/PanelPass/CellStage", "PrefabCellStage")
end

function PageBossActivityStage:OnBack()
	StageScrollViewPosMgr.SetPosY(eScrollViewPosType.partyCommon)

	if PageBossActivity.GetCurBossActive() == nil then
		PageBossActivity.EndActiveBackMain()
	else
		self:Close()
		UIMgr.AddPanel(PageBossActivity())
	end
end

function PageBossActivityStage:Purge()
	self.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	ResourceMgr.Unload(self.PrefabCellStage)
	ChapterRDL.PartyRDL.ViewedSystem()
end

function PageBossActivityStage:OnRegisterEvent()
	Event.Instance:Add(EventEnum.UpdateStage, self.UpdatePanel, self)
	Event.Instance:Add("OpenActiveStory", self.OnClickedBtnStory, self)
end

function PageBossActivityStage:OnUnRegisterEvent()
	Event.Instance:Remove(EventEnum.UpdateStage, self.UpdatePanel, self)
	Event.Instance:Remove("OpenActiveStory", self.OnClickedBtnStory, self)
end

function PageBossActivityStage:OnEnter(vParam)
	ChapterMgr.BossActivityStageType = StageFromType.activeCommon
	self.infoActive = PageBossActivity.GetCurBossActive()

	local infoChapter = ChapterMgr:GetChapter(self.infoActive.normalChapterId)

	self.StageTital = self:GetChildComponent("Panel/StageTital", "Image")
	self.LittleTitalImage = self:GetChildComponent("Panel/Line", "Image")
	self.Desc = self:GetChildComponent("Panel/Line/Text", "Text")

	local UIData = BossActiveUIData[self.infoActive.id]

	UIUtil.SetImageSprite(self.StageTital, UIData.StageTital, self, true)
	GOUtil.SetRectTransformAnchoredPosition(self.StageTital.gameObject, UIData.StageTitalPos[1], UIData.StageTitalPos[2])

	self.txtHighPrize = self:GetChildComponent("Panel/HighPrize/TxtHighPrize", "Text")

	GOUtil.SetRectTransformAnchoredPosition(self.txtHighPrize.transform.parent.gameObject, UIData.HighPrizePos[1], UIData.HighPrizePos[2])

	if UIData.StageSubTitalDesc > 0 then
		UIUtil.SetImageSprite(self.LittleTitalImage, UIData.StageSubTitalImage, self)
		GOUtil.SetRectTransformAnchoredPosition(self.LittleTitalImage.gameObject, UIData.StageSubTitalDescPos[1], UIData.StageSubTitalDescPos[2])
		GOUtil.SetRectTransformSizeDelta(self.LittleTitalImage.gameObject, UIData.StageSubTitalDescLength[1], UIData.StageSubTitalDescLength[2])

		self.Desc.text = Lang(UIData.StageSubTitalDesc)
		self.Desc.color = getColorFromString(UIData.StageSubTitalDescPos[3])
	else
		SetActiveFunc(self.LittleTitalImage.gameObject, false)
	end

	self.listAllStage = infoChapter.listStage

	self:UpdatePanelInfo()
	self:UpdatePanel()
end

function PageBossActivityStage:UpdatePanelInfo()
	local infoChapter = ChapterMgr:GetChapter(self.infoActive.normalChapterId)
	local info, hignCount = ShopManager:GetGoodsMonthPrivilegeFuncInfo(ShopManager.MonthPrivilegeFunc.Func15)

	self.txtHighPrize.text = "  " .. string.format(_("Desc_High_Prize_Left"), "" .. hignCount + 1 - infoChapter.pb.highAwardNum)
end

function PageBossActivityStage:Sort()
	self.listStage = {}

	local count = #self.listAllStage

	for i = 1, #self.listAllStage do
		local infoStage = self.listAllStage[count + 1 - i]

		if infoStage:IsOpen() then
			table.insert(self.listStage, infoStage)
		end
	end

	if #self.listStage == 0 then
		local infoStage = InfoStage(self.listAllStage[1].id)

		infoStage.isUnLock = true

		table.insert(self.listStage, infoStage)
	end
end

function PageBossActivityStage:OnClickedCell(data)
	local go = data.pointerPress.transform.parent.parent.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)

	self.info = self.listStage[info.Item.Index]

	local posY = 0

	if not self.info:IsNew() then
		posY = self.UIScrollTool.ScrollView.content.anchoredPosition.y
	end

	StageScrollViewPosMgr.SetPosY(eScrollViewPosType.partyCommon, posY)
end

function PageBossActivityStage:UpdatePanel()
	self:Sort()

	if self.UIScrollTool then
		self.UIScrollTool:UpdateListDataKeepPos(self.listStage)

		return
	end

	self:InitScrollView()
end

function PageBossActivityStage:InitScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/Main/BgStage/ScrollArea")
	local content = self:GetChildComponent("Panel/Main/BgStage/ScrollArea/Content", "Transform")
	local count = #self.listStage

	local function addCallback(item)
		self:AddClick(GOUtil.FindChildGameObject(item.UIRootObject, "Panel/BtnEnter"), self.OnClickedCell)
	end

	local function updateCallback(item, index)
		item:DestroyContent()
		item:UpdateData({
			infoStage = self.listStage[index]
		})
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.PrefabCellStage, CellCommonStage, self, false, addCallback, updateCallback)

	local posY = StageScrollViewPosMgr.GetPosY(eScrollViewPosType.partyCommon)

	if posY ~= 0 then
		self.UIScrollTool.ScrollView.ScrollViewInitPos = Vector3(0, posY, 0)
	end

	if ChapterMgr.IsForecastState then
		ChapterMgr.PageCombatReadinessType = 1

		UIMgr.AddPanel(PageCombatReadiness(), {
			stageId = ChapterMgr.IsForecastState
		})
	end
end

function PageBossActivityStage:OnClickedBtnStory()
	UIMgr.AddPanel(PageBossActivityStory())
	self:Close()
end
