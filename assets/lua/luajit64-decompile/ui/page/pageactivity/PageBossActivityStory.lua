-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivity/PageBossActivityStory.lua

require("UI/Page/PagePass/CellCommonStage")

local BossActiveUIData = require("luaData/BossctiveUIData")

PageBossActivityStory = class("PageBossActivityStory", UIPanel)

function PageBossActivityStory:ctor()
	self.UIPrefabPath = "UI/PanelActivity/PanelBossActivityStory"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_ActPlot"),
		callback = self.OnBack,
		panel = self
	})
end

function PageBossActivityStory:PreLoad()
	self:LoadResAsync("UI/PanelPass/CellStage", "PrefabCellStage")
end

function PageBossActivityStory:OnBack()
	StageScrollViewPosMgr.SetPosY(eScrollViewPosType.partyStory)

	if PageBossActivity.GetCurBossActive() == nil then
		PageBossActivity.EndActiveBackMain()
	else
		self:Close()
		UIMgr.AddPanel(PageBossActivity())
	end
end

function PageBossActivityStory:Purge()
	self.base.Purge(self)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	ResourceMgr.Unload(self.PrefabCellStage)
end

function PageBossActivityStory:OnRegisterEvent()
	Event.Instance:Add(EventEnum.UpdateStage, self.UpdatePanel, self)
end

function PageBossActivityStory:OnUnRegisterEvent()
	Event.Instance:Remove(EventEnum.UpdateStage, self.UpdatePanel, self)
end

function PageBossActivityStory:OnEnter(vParam)
	PersistentStoreUtil.SetBool("UnLockActiveStoryBool", false)

	ChapterMgr.BossActivityStageType = StageFromType.story
	self.infoActive = PageBossActivity.GetCurBossActive()

	local infoChapter = ChapterMgr:GetChapter(self.infoActive.storyChapterId)

	self.StoryTital = self:GetChildComponent("Panel/StoryTital", "Image")
	self.SignName = self:GetChildComponent("Panel/SignName", "Image")
	self.LittleTitalImage = self:GetChildComponent("Panel/Line", "Image")
	self.Desc = self:GetChildComponent("Panel/Line/Text", "Text")

	local UIData = BossActiveUIData[self.infoActive.id]

	UIUtil.SetImageSprite(self.StoryTital, UIData.StoryTital, self, true)

	if UIData.SignName ~= "" then
		UIUtil.SetImageSprite(self.SignName, UIData.SignName, self, true)
		GOUtil.SetRectTransformAnchoredPosition(self.SignName.gameObject, UIData.StorySignPos[1], UIData.StorySignPos[2])
	else
		SetActiveFunc(self.SignName.gameObject, false)
	end

	if UIData.StorySubTitalDesc > 0 then
		UIUtil.SetImageSprite(self.LittleTitalImage, UIData.StorySubTitalImage, self)
		GOUtil.SetRectTransformAnchoredPosition(self.LittleTitalImage.gameObject, UIData.StorySubTitalDescPos[1], UIData.StorySubTitalDescPos[2])
		GOUtil.SetRectTransformSizeDelta(self.LittleTitalImage.gameObject, UIData.StorySubTitalDescLength[1], UIData.StorySubTitalDescLength[2])

		self.Desc.text = Lang(UIData.StorySubTitalDesc)
		self.Desc.color = getColorFromString(UIData.StorySubTitalDescPos[3])
	else
		SetActiveFunc(self.LittleTitalImage.gameObject, false)
	end

	GOUtil.SetRectTransformAnchoredPosition(self.StoryTital.gameObject, UIData.StoryTitalPos[1], UIData.StoryTitalPos[2])

	self.listAllStage = infoChapter.listStage

	self:UpdatePanel()
end

function PageBossActivityStory:Sort()
	self.listStage = {}

	local count = #self.listAllStage

	for i = 1, #self.listAllStage do
		local infoStage = self.listAllStage[i]

		table.insert(self.listStage, infoStage)
	end
end

function PageBossActivityStory:OnClickedCell(data)
	local go = data.pointerPress.transform.parent.parent.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)

	self.info = self.listStage[info.Item.Index]

	local posY = 0

	if not self.info:IsNew() then
		posY = self.UIScrollTool.ScrollView.content.anchoredPosition.y
	end

	StageScrollViewPosMgr.SetPosY(eScrollViewPosType.partyStory, posY)
end

function PageBossActivityStory:UpdatePanel()
	self:Sort()

	if self.UIScrollTool then
		self.UIScrollTool:UpdateListDataKeepPos(self.listStage)

		return
	end

	self:InitScrollView()
end

function PageBossActivityStory:InitScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/Main/BgStage/ScrollArea")
	local content = self:GetChildComponent("Panel/Main/BgStage/ScrollArea/Content", "Transform")
	local count = #self.listStage

	local function addCallback(item)
		self:AddClick(GOUtil.FindChildGameObject(item.UIRootObject, "Panel/BtnEnter"), self.OnClickedCell)
	end

	local function updateCallback(item, index)
		item:UpdateData({
			infoStage = self.listStage[index]
		})
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(ScrollArea, content, count, self.PrefabCellStage, CellCommonStage, self, false, addCallback, updateCallback)

	local posY = StageScrollViewPosMgr.GetPosY(eScrollViewPosType.partyStory)

	if posY ~= 0 then
		self.UIScrollTool.ScrollView.ScrollViewInitPos = Vector3(0, posY, 0)
	end
end

function PageBossActivityStory:OnBackAndroid()
	local exitPanel = self:GetChildPanel("DlgExit")

	if exitPanel then
		exitPanel:OnClickedBtnReturn()
	end
end
