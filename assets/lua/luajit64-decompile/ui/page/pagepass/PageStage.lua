-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePass/PageStage.lua

require("UI/Page/PagePass/CellCommonStage")
require("UI/Page/PageChapter/DlgStageSweep")
require("UI/Page/PageTeam/PageTeam")

local InfoTeam = require("Info/InfoTeam")
local InfoTeamgGroup = require("Info/InfoTeamgGroup")

PageStage = class("PageStage", UIPanel, true)

function PageStage:ctor()
	PageStage.base.ctor(self, "UI/PanelPass/PanelStage")

	self.DlgExit = DlgExit()

	self:AddChildPanel(self.DlgExit, {
		title = _("eReturn_PlotMap"),
		callback = self.OnBack,
		helpCallback = self.OnClickedBtnGuide,
		panel = self
	})

	self.DlgAssetsInfo = DlgAssetsInfo()

	self:AddChildPanel(self.DlgAssetsInfo)
end

function PageStage:PreLoad(vParam)
	if vParam and vParam.chapterType then
		self.chapterType = vParam.chapterType
	end

	self.PrefabCellStage = ResourceMgr.LoadSync("UI/PanelPass/CellStage")
	self.PrefabCellItem = ResourceMgr.LoadSync("UI/Item/CellItem")
end

function PageStage:OnBack()
	ChapterMgr.StageScrollIndex = 0

	StageScrollViewPosMgr.SetPosY(eScrollViewPosType.main)
	UIMgr.PopPanel()
end

function PageStage:Purge()
	PageStage.base.Purge(self)
	UITweenUtil.RemoveTween(self.content)
	UITweenUtil.RemoveTween(self.StarAch)
	self:OnLeave()
end

function PageStage:OnLeave()
	if self.UIScrollTool then
		self.UIScrollTool:Purge()
	end

	self.UIScrollTool = nil

	if self.PrefabCellStage then
		ResourceMgr.Unload(self.PrefabCellStage)

		self.PrefabCellStage = nil
	end

	if self.PrefabCellItem then
		ResourceMgr.Unload(self.PrefabCellItem)

		self.PrefabCellItem = nil
	end

	UnloadAllImageSprite(self)
end

function PageStage:OnRegisterEvent()
	self:AddClick(self.BtnShow, self.OnClickedShowAward)
	self:AddClick(self.BtnRecv, self.OnClickedRecvAward)
	self:AddClick(self.BtnOver, self.OnClickedShowAward)
	self:AddClick(self.BtnLeft, self.OnClickedBtnLeft)
	self:AddClick(self.BtnRight, self.OnClickedBtnRight)
	self:AddClick(self.GoAward, self.OnCloseAward)
	Event.Instance:Add(EventEnum.UpdateStage, self.UpdatePanel, self)
	Event.Instance:Add("UpdateStageNum", self.UpdateStageNum, self)
end

function PageStage:OnUnRegisterEvent()
	self:RemoveClick(self.BtnShow, self.OnClickedShowAward)
	self:RemoveClick(self.BtnRecv, self.OnClickedRecvAward)
	self:RemoveClick(self.BtnOver, self.OnClickedShowAward)
	self:RemoveClick(self.BtnLeft, self.OnClickedBtnLeft)
	self:RemoveClick(self.BtnRight, self.OnClickedBtnRight)
	self:RemoveClick(self.GoAward, self.OnCloseAward)
	Event.Instance:Remove(EventEnum.UpdateStage, self.UpdatePanel, self)
	Event.Instance:Remove("UpdateStageNum", self.UpdateStageNum, self)
	EventListenerMgr.RemoveAnimListener(self.StarAchGo, self.EventAnim, self, eAnimEventType.OnAnimationEnd)
	self:OnRegisterOtherEvent()
end

function PageStage:OnRegisterOtherEvent()
	if self.clickEvent then
		for _, v in pairs(self.clickEvent) do
			for i = 1, #v do
				self:RemoveClick(v[i], self.OnClickGoAward)
			end
		end
	end

	if self.listCellItem then
		for _, v in pairs(self.listCellItem) do
			for i = 1, #v do
				v[i]:OnLeave()
			end
		end
	end

	if self.listOneKey then
		for _, v in pairs(self.listOneKey) do
			self:RemoveClick(v, self.OnClickOneKey)
		end
	end

	if self.listCell then
		for i = 1, #self.listCell do
			self.listCell[i]:OnLeave()
		end
	end

	if self.clipRef then
		ResourceMgr.Unload(self.clipRef)

		self.clipRef = nil
	end
end

function PageStage:OnEnter(vParam)
	if not GuideMgr:IsGuided(GuideFunctionType.Stage) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.Stage)
	end

	self:DealWithLocalization()

	self.TxtChapterName = self:GetChildComponent("Panel/BgScroll/BgChapter/TxtName", "Text")
	self.TxtChapterStar = self:GetChildComponent("Panel/StarAch/TxtStarCnt", "Text")
	self.StarAch = self:GetChildComponent("Panel/StarAch", "Transform")
	self.StarAchGo = self:GetChildGameObject("Panel/StarAch")
	self.StarAchAni = self:GetChildComponent("Panel/StarAch", "Animator")

	EventListenerMgr.AddAnimListener(self.StarAchGo, self.EventAnim, self, eAnimEventType.OnAnimationEnd)

	self.PanelGo = self:GetChildGameObject("Panel")
	self.BtnShow = self:GetChildGameObject("Panel/StarAch/1")
	self.BtnRecv = self:GetChildGameObject("Panel/StarAch/2")
	self.BtnOver = self:GetChildGameObject("Panel/StarAch/3")
	self.img_award = self:GetChildComponent("Panel/StarAch/img_award", "Image")
	self.GoAward = self:GetChildGameObject("Panel/Award")
	self.GoGroup = self:GetChildGameObject("Panel/Award/Group")
	self.GoAwardList = self:GetChildGameObject("Panel/AwardList")
	self.GoAwardGroup = self:GetChildGameObject("Panel/AwardList/BgList/Bg/Group")
	self.Select = self:GetChildGameObject("Panel/BgScroll/BgChapter/Select")
	self.BtnLeft = self:GetChildGameObject("Panel/BgScroll/BgChapter/Select/BtnLeft")
	self.BtnRight = self:GetChildGameObject("Panel/BgScroll/BgChapter/Select/BtnRight")
	self.LeftImage = self:GetChildGameObject("Panel/BgScroll/BgChapter/Select/BtnLeft/BtnLeft")
	self.RightImage = self:GetChildGameObject("Panel/BgScroll/BgChapter/Select/BtnRight/BtnRight")
	self.LeftText = self:GetChildComponent("Panel/BgScroll/BgChapter/Select/BtnLeft/Text", "Text")
	self.RighText = self:GetChildComponent("Panel/BgScroll/BgChapter/Select/BtnRight/Text", "Text")
	self.Logo = self:GetChildGameObject("Panel/Logo")
	self.LogoImg = self:GetChildComponent("Panel/Logo/logo", "Image")
	self.LogoBack = self:GetChildComponent("Panel/Logo/back", "Image")
	self.LogoText = self:GetChildComponent("Panel/Logo/Text", "Text")
	self.Logo1 = self:GetChildGameObject("Panel/Logo1")
	self.LogoImg1 = self:GetChildComponent("Panel/Logo1/logo", "Image")
	self.LogoBack1 = self:GetChildComponent("Panel/Logo1/back", "Image")
	self.LogoText1 = self:GetChildComponent("Panel/Logo1/Text", "Text")
	self.VideoPlayer = self:GetChildComponent("Bg", "VideoPlayer")
	self.GoPrompt = self:GetChildGameObject("Panel/Logo/GoPrompt")
	self.TxtRefresh = self:GetChildComponent("Panel/Logo/GoPrompt/Text1", "Text")
	self.TxtPlayNum = self:GetChildComponent("Panel/Logo/GoPrompt/Text2", "Text")

	local txtGo = self:GetChildGameObject("Panel/Logo/GoPrompt/Text2")

	GOUtil.SetRectTransformSizeDeltaHeight(txtGo, 50)

	self.TxtPlayNum1 = self:GetChildComponent("Panel/Logo1/GoPrompt/Text2", "Text")
	self.isShow = false

	self.UIRootObject.transform:SetAsFirstSibling()
	self:InitData(vParam)
	self:ShowPhoneCallIn()
	InstructionMgr:Start()
	UITweenUtil.SingleTween(self.StarAch, "x", 300, 0.3)
end

function PageStage:DealWithLocalization()
	return
end

function PageStage:ShowPhoneCallIn()
	if PersistentStoreUtil.GetBool(PersistentStoreUtil.KEY_OPEN_PHONE_CALL_MSG, true) then
		return
	end

	local phoneNum = PersistentStoreUtil.GetListCount(PersistentStoreUtil.KEY_NEW_PHONE_CALL)
	local topicNum = PersistentStoreUtil.GetListCount(PersistentStoreUtil.KEY_NEW_TOPIC)

	if phoneNum == 1 and topicNum == 0 then
		local list = PersistentStoreUtil.GetList(PersistentStoreUtil.KEY_NEW_PHONE_CALL)

		require("UI.Page.PageCommunication.DlgCallIn")
		UIMgr.AddPanel(DlgCallIn(), {
			callId = tonumber(list[1])
		}, UIMgr.UIOverLayObject)
		PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_OPEN_PHONE_CALL_MSG, true)
	elseif phoneNum == 0 and topicNum == 1 then
		require("UI.Page.PageCommunication.DlgCallIn")

		local list = PersistentStoreUtil.GetList(PersistentStoreUtil.KEY_NEW_TOPIC)

		UIMgr.AddPanel(DlgCallIn(), {
			topicId = tonumber(list[1])
		}, UIMgr.UIOverLayObject)
		PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_OPEN_PHONE_CALL_MSG, true)
	elseif phoneNum ~= 0 or topicNum ~= 0 then
		require("UI.Page.PageCommunication.DlgNewUnreadMessage")
		UIMgr.AddPanel(DlgNewUnreadMessage(), nil, UIMgr.UIOverLayObject)
		PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_OPEN_PHONE_CALL_MSG, true)
	end
end

function PageStage:InitData(vParam)
	if vParam and vParam.chapterId then
		self.chapterId = vParam.chapterId

		PersistentStoreUtil.SetChapterEnter(self.chapterId, true)

		self.infoStageList = {}

		for i = 1, #ChapterMgr:GetUnLockStageList(self.chapterId) do
			if ChapterMgr:GetUnLockStageList(self.chapterId)[i].data.Type ~= 2 then
				table.insert(self.infoStageList, ChapterMgr:GetUnLockStageList(self.chapterId)[i])
			end
		end
	end

	if vParam and vParam.combId then
		self.combId = vParam.combId
	end

	if vParam and vParam.ChapterTeamIdx then
		self.ChapterTeamIdx = vParam.ChapterTeamIdx
	end

	self.listChapter = {}
	self.listStage = {}

	if self.chapterType == 1 then
		self:InitMainChapterPanel()
	elseif self.chapterType == 2 then
		self:InitTeamChapterPanel()

		if self.DlgExit then
			self.DlgExit:SetTextExit(_("eReturn_TeamStage"))
		end
	elseif self.chapterType == 6 then
		self:InitMainChapterPanel()
	end

	if self.DlgAssetsInfo then
		self.DlgAssetsInfo:ResetByBannerId(ResourceBannerMgr.GetBannerID(self.className, self.chapterType))
	end
end

function PageStage:InitMainChapterPanel()
	local infoChapter = ChapterMgr:GetChapter(self.chapterId)

	table.insert(self.listChapter, infoChapter)
	self:InitAward()
	self:UpdatePanel()
	self:UpdateAward()
end

function PageStage:InitTeamChapterPanel()
	self.listChapter = CombChapterMgr.GetCombChapters(self.combId)
	self.listOpenChapter = {}

	for i = 1, #self.listChapter do
		local isOpen = self.listChapter[i]:IsOpen()

		if isOpen then
			table.insert(self.listOpenChapter, self.listChapter[i])
		end
	end

	if #self.listOpenChapter == 0 then
		return
	end

	local page = ChapterMgr.CombPage[self.combId]

	if page ~= nil and page > 0 then
		self.chapterIdx = page
	else
		self.chapterIdx = self.ChapterTeamIdx or #self.listOpenChapter
	end

	ChapterMgr.ChapterTeamIdx = self.chapterIdx
	self.chapterId = self.listOpenChapter[self.chapterIdx].data.ID

	self:InitAward()
	self:UpdatePanel()
	self:UpdateAward()
end

function PageStage:OnClickedBtnLeft()
	if not self.canLeft then
		return
	end

	self.chapterIdx = self.chapterIdx - 1

	if self.chapterIdx <= 1 then
		self.chapterIdx = 1
	end

	ChapterMgr.CombPage[self.combId] = self.chapterIdx
	ChapterMgr.ChapterTeamIdx = self.chapterIdx
	self.chapterId = self.listOpenChapter[self.chapterIdx].id

	self.StarAchAni:Play("PanelStage_StarAni")
	self:UpdatePanel(true)
end

function PageStage:OnClickedBtnRight()
	if not self.canRight then
		return
	end

	self.chapterIdx = self.chapterIdx + 1

	if self.chapterIdx >= #self.listOpenChapter then
		self.chapterIdx = #self.listOpenChapter
	end

	ChapterMgr.CombPage[self.combId] = self.chapterIdx
	ChapterMgr.ChapterTeamIdx = self.chapterIdx
	self.chapterId = self.listOpenChapter[self.chapterIdx].id

	self:UpdatePanel(true)
	self.StarAchAni:Play("PanelStage_StarAni")
end

function PageStage:EventAnim()
	self.StarAchAni:Play("Empty")
	self:UpdateAward()
end

function PageStage:UpdatePanel(isKeepPos)
	self.infoChapter = ChapterMgr:GetChapter(self.chapterId)
	self.listStage = ChapterMgr:GetUnLockStageList(self.chapterId)
	self.TxtChapterName.text = Lang(self.infoChapter.data.Title) .. "   " .. Lang(self.infoChapter.data.Name)

	if self.chapterType == 2 then
		self.TxtChapterName.text = Lang(self.infoChapter.data.Name)
	end

	local allStarCnt = self.infoChapter:GetAllStar()
	local curStarCnt = self.infoChapter:GetStar()

	self.TxtChapterStar.text = curStarCnt .. "/" .. allStarCnt

	if self.infoChapter.data.Animation ~= "" then
		self.clipRef = UIUtil.SetVideoPlayerClip(self.VideoPlayer, self.infoChapter.data.Animation)
	end

	self.curStar = curStarCnt

	self:UpdateBtnState()

	if not self.inited then
		self:InitScrollViewStage()

		self.inited = true
	elseif not isKeepPos then
		local posY = StageScrollViewPosMgr.GetPosY(eScrollViewPosType.main)

		self.UIScrollTool.ScrollView.ScrollViewInitPos = Vector3(0, posY, 0)

		self.UIScrollTool:SetContentPosImmediate(Vector2(0, posY), self.listStage)
	else
		self.UIScrollTool:UpdateListData(self.listStage)
	end

	local _type = self.infoChapter.data.Type

	if _type == ChapterFromType.main or _type == ChapterFromType.mainhard then
		RedDotSystemMgr.SetUIRedDot(self.StarAchGo, string.format(GetChapterMainBranchPath(_type), GetChapterGroup(self.infoChapter), self.infoChapter.id))
	elseif _type == ChapterFromType.comb then
		RedDotSystemMgr.SetUIRedDot(self.StarAchGo, string.format("Chapter/Comb/%d/%d", self.infoChapter.data.Team, self.infoChapter.id))
	end
end

function PageStage:UpdateBtnState()
	SetActiveFunc(self.Select, false)
	SetActiveFunc(self.Logo, false)
	SetActiveFunc(self.Logo1, false)

	if self.chapterType == 2 then
		local info = ChapterMgr:GetChapter(self.chapterId)
		local iconData = info.data.ChapterShowIcon

		if #iconData > 0 then
			if iconData[4] == 1 then
				SetActiveFunc(self.Logo1, true)
				UIUtil.SetImageSprite(self.LogoImg1, iconData[1], self)
				UIUtil.SetImageSprite(self.LogoBack1, iconData[2], self)

				self.LogoText1.text = Lang(iconData[3])
				self.TxtPlayNum1.text = _("Desc_Times") .. CombChapterMgr.GetCombRemainingChallengeNum(self.combId) .. "/" .. CombChapterMgr.GetSingleLimitChallengeNum(self.combId)
			else
				SetActiveFunc(self.Logo, true)
				UIUtil.SetImageSprite(self.LogoImg, iconData[1], self)
				UIUtil.SetImageSprite(self.LogoBack, iconData[2], self)

				self.LogoText.text = Lang(iconData[3])
				self.TxtPlayNum.text = _("Desc_Times") .. CombChapterMgr.GetCombRemainingChallengeNum(self.combId) .. "/" .. CombChapterMgr.GetSingleLimitChallengeNum(self.combId)
			end
		end

		if #self.listOpenChapter <= 1 then
			return
		end

		self.canLeft = true
		self.canRight = true

		SetActiveFunc(self.Select, true)
		GOUtil.SetImageColor(self.LeftImage, 255, 255, 255)
		GOUtil.SetTextColor(self.LeftText.gameObject, 255, 255, 255)
		GOUtil.SetImageColor(self.RightImage, 255, 255, 255)
		GOUtil.SetTextColor(self.RighText.gameObject, 255, 255, 255)

		if self.chapterIdx == 1 then
			self.canLeft = false

			GOUtil.SetImageColor(self.LeftImage, 159, 164, 172)
			GOUtil.SetTextColor(self.LeftText.gameObject, 159, 164, 172)
		end

		if self.chapterIdx == #self.listOpenChapter then
			self.canRight = false

			GOUtil.SetImageColor(self.RightImage, 159, 164, 172)
			GOUtil.SetTextColor(self.RighText.gameObject, 159, 164, 172)
		end
	end
end

function PageStage:InitScrollViewStage()
	local scrollArea = self:GetChildGameObject("Panel/BgScroll/ScrollArea")

	self.content = self:GetChildComponent("Panel/BgScroll/ScrollArea/Content", "Transform")

	local count = #self.listStage

	local function AddClick(item)
		self:AddClick(GOUtil.FindChildGameObject(item.UIRootObject, "Panel/BtnEnter"), self.OnClickedCell)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, self.content, count, self.PrefabCellStage, CellCommonStage, self, false, AddClick, nil)

	local posY = StageScrollViewPosMgr.GetPosY(eScrollViewPosType.main)

	if posY ~= 0 then
		self.UIScrollTool.ScrollView.ScrollViewInitPos = Vector3(0, posY, 0)
	else
		UITweenUtil.DoListAnimationUp(self.content, 300, 0.2, nil, nil)
	end
end

function PageStage:UpdateCell(item, index)
	local infoStage = self.listStage[index]
	local stageIdx = #self.listStage - index + 1
	local data = {
		infoStage = infoStage,
		index = stageIdx,
		maxIndex = #self.listStage
	}

	item:DestroyContent()
	item:UpdateData(data)
end

function PageStage:AddCellClick(item)
	return
end

function PageStage:OnClickedCell(data)
	local go = data.pointerPress.transform.parent.parent.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)

	self.info = self.listStage[info.Item.Index]

	local posY = 0

	if not self.info:IsNew() then
		posY = self.UIScrollTool.ScrollView.content.anchoredPosition.y
	end

	StageScrollViewPosMgr.SetPosY(eScrollViewPosType.main, posY)
end

function PageStage:InitAward()
	local content = self:GetChildGameObject("Panel/Award/ScrollArea/Content")
	local cell = self:GetChildGameObject("Panel/Award/Cell")
	local award = self:GetChildGameObject("Panel/Award/CellAward")

	self.listAward = {}
	self.listCellItem = {}
	self.listOneKey = {}
	self.listCellGo = {}
	self.clickEvent = {}

	for i = 1, #self.listChapter do
		local goCell = GOUtil.Instantiate(cell, content)
		local infoChapter = self.listChapter[i]
		local isOpen = infoChapter:IsOpen()
		local goStar = GOUtil.FindChildGameObject(goCell, "Star/GoStar")
		local goFrame = GOUtil.FindChildGameObject(goCell, "Star/GoFrame")

		SetActiveFunc(goStar, isOpen)
		SetActiveFunc(goFrame, not isOpen)

		local txtTitle = GOUtil.FindChildComponent(goCell, "Title/Text", "Text")

		if infoChapter.data.Type == 1 or infoChapter.data.Type == 6 then
			txtTitle.text = Lang(infoChapter.data.Title)
		else
			txtTitle.text = string.format(Lang(12070), tostring(i))
		end

		local txtStarNum = GOUtil.FindChildComponent(goCell, "Star/TxtStarNum", "Text")

		txtStarNum.text = infoChapter:GetStar() .. "/" .. infoChapter:GetAllStar()

		if isOpen then
			txtTitle.color = Color.New(0.26666666666666666, 0.26666666666666666, 0.26666666666666666, 1)
		else
			txtTitle.color = Color.New(0.7764705882352941, 0.7764705882352941, 0.7764705882352941, 1)
		end

		local goOneKey = GOUtil.FindChildGameObject(goCell, "btn_onekey")

		self:AddClick(goOneKey, self.OnClickOneKey)
		table.insert(self.listOneKey, goOneKey)

		self.listAward["" .. i] = {}
		self.listCellItem["" .. i] = {}
		self.clickEvent[i] = {}

		local awardgroup = GOUtil.FindChildGameObject(goCell, "Group")
		local list, curIdx = infoChapter:GetChapterAwardList()
		local isOneKey = false

		for j = 1, #list do
			local goAward = GOUtil.Instantiate(award, awardgroup)
			local isRecv = list[j].state == 1
			local isCanRecv = infoChapter:GetStar() >= list[j].star
			local itemIcon = GOUtil.FindChildComponent(goAward, "Item", "Image")
			local goNew = GOUtil.FindChildGameObject(goAward, "GoNew")

			SetActiveFunc(goNew, not isRecv and isCanRecv)

			local goGet = GOUtil.FindChildGameObject(goAward, "Get")

			SetActiveFunc(goGet, not isRecv and isCanRecv)

			goGet.name = "Get_" .. j

			local goRecv = GOUtil.FindChildGameObject(goAward, "GoRecv")

			SetActiveFunc(goRecv, isRecv)

			local goStar = GOUtil.FindChildGameObject(goAward, "GoStar")

			SetActiveFunc(goStar, isCanRecv)

			local goFrame = GOUtil.FindChildGameObject(goAward, "GoFrame")

			SetActiveFunc(goFrame, not isCanRecv)

			local txtStar = GOUtil.FindChildComponent(goAward, "TxtStar", "Text")

			txtStar.text = list[j].star

			local img_state = GOUtil.FindChildComponent(goAward, "img_state", "Image")

			if isRecv then
				UIUtil.SetImageSprite(img_state, "UI/PanelPass/AtlasPanelStage/BG_reward_star_line_01", self)
			else
				UIUtil.SetImageSprite(img_state, "UI/PanelPass/AtlasPanelStage/BG_reward_star_line_02", self)
			end

			local img_state2 = GOUtil.FindChildComponent(goAward, "img_state/img_state2", "Image")

			if isRecv then
				UIUtil.SetImageSprite(img_state2, "UI/PanelPass/AtlasPanelStage/BG_reward_star_dot_01", self)
			else
				UIUtil.SetImageSprite(img_state2, "UI/PanelPass/AtlasPanelStage/BG_reward_star_dot_02", self)
			end

			goAward.name = j

			local gCellItem = GOUtil.FindChildGameObject(goAward, "CellItem")
			local cellItem = CellItem(gCellItem)

			cellItem:InitItemByRoot(gCellItem)
			cellItem:UpdateWithNumType(list[j].items[1])
			self:AddClick(goGet, self.OnClickGoAward)
			table.insert(self.clickEvent[i], goGet)
			table.insert(self.listAward["" .. i], goAward)
			table.insert(self.listCellItem["" .. i], cellItem)

			if not isRecv and isCanRecv then
				isOneKey = true
			end
		end

		goCell.name = i

		SetActiveFunc(goCell, self.chapterIdx == nil or i == self.chapterIdx)
		table.insert(self.listCellGo, goCell)

		local gray = TenaryOp(isOneKey, 0, 1)
		local img_onekey = GOUtil.FindChildComponent(goCell, "btn_onekey", "Image")

		DealWithListRef(self, UIUtil.SetImageGray(img_onekey, gray))

		local Fx_UI_009_2 = GOUtil.FindChildGameObject(goCell, "btn_onekey/Fx_UI_009_2")

		SetActiveFunc(Fx_UI_009_2, gray == 0)
	end

	SetActiveFunc(cell, false)
	SetActiveFunc(award, false)
end

function PageStage:UpdateAward()
	local list, curIndex = self.infoChapter:GetChapterAwardList()

	SetActiveFunc(self.BtnShow, false)
	SetActiveFunc(self.BtnRecv, false)
	SetActiveFunc(self.BtnOver, false)
	UIUtil.SetImageSprite(self.img_award, "UI/PanelPass/AtlasPanelStage/IC_stage_box_01", self)

	if list[3].state == 1 then
		SetActiveFunc(self.BtnOver, true)
	else
		local canGet = self.curStar >= list[curIndex].star

		SetActiveFunc(self.BtnShow, not canGet)
		SetActiveFunc(self.BtnRecv, canGet)
	end

	for i = 1, #self.listChapter do
		local infoChapter = self.listChapter[i]
		local isOpen = infoChapter:IsOpen()
		local list, curIdx = infoChapter:GetChapterAwardList()
		local listGo = self.listAward["" .. i]
		local isOneKey = false

		for j = 1, #list do
			local isRecv = list[j].state == 1
			local isCanRecv = infoChapter:GetStar() >= list[j].star
			local go = listGo[j]
			local goNew = GOUtil.FindChildGameObject(go, "GoNew")
			local goRecv = GOUtil.FindChildGameObject(go, "GoRecv")
			local goStar = GOUtil.FindChildGameObject(go, "GoStar")
			local goFrame = GOUtil.FindChildGameObject(go, "GoFrame")
			local goGet = GOUtil.FindChildGameObject(go, "Get_" .. j)

			if not isRecv and isCanRecv and (self.chapterIdx == nil or i == self.chapterIdx) then
				UIUtil.SetImageSprite(self.img_award, "UI/PanelPass/AtlasPanelStage/IC_stage_box_03", self)
			end

			local img_state = GOUtil.FindChildComponent(go, "img_state", "Image")

			if isRecv then
				UIUtil.SetImageSprite(img_state, "UI/PanelPass/AtlasPanelStage/BG_reward_star_line_01", self)
			else
				UIUtil.SetImageSprite(img_state, "UI/PanelPass/AtlasPanelStage/BG_reward_star_line_02", self)
			end

			local img_state2 = GOUtil.FindChildComponent(go, "img_state/img_state2", "Image")

			if isRecv then
				UIUtil.SetImageSprite(img_state2, "UI/PanelPass/AtlasPanelStage/BG_reward_star_dot_01", self)
			else
				UIUtil.SetImageSprite(img_state2, "UI/PanelPass/AtlasPanelStage/BG_reward_star_dot_02", self)
			end

			SetActiveFunc(goNew, not isRecv and isCanRecv)
			SetActiveFunc(goGet, not isRecv and isCanRecv)
			SetActiveFunc(goRecv, isRecv)
			SetActiveFunc(goStar, isCanRecv)
			SetActiveFunc(goFrame, not isCanRecv)

			if not isRecv and isCanRecv then
				isOneKey = true
			end
		end

		local goCell = self.listCellGo[i]

		SetActiveFunc(goCell, self.chapterIdx == nil or i == self.chapterIdx)

		local gray = TenaryOp(isOneKey, 0, 1)
		local img_onekey = GOUtil.FindChildComponent(goCell, "btn_onekey", "Image")

		DealWithListRef(self, UIUtil.SetImageGray(img_onekey, gray))

		local Fx_UI_009_2 = GOUtil.FindChildGameObject(goCell, "btn_onekey/Fx_UI_009_2")

		SetActiveFunc(Fx_UI_009_2, gray == 0)
	end
end

function PageStage:OnClickGoAward(data)
	local goCell = data.pointerPress.transform
	local cellIdx = tonumber(string.split(goCell.name, "_")[2])
	local awardListIdx = tonumber(data.pointerPress.transform.parent.parent.parent.name)

	LoadingMgr.Show(eLoadingType.Repeat)

	local function wrap_cb(pb)
		self:ResponseGetChapterAward(pb)
	end

	self.curAwardIdx = cellIdx
	self.awardListIdx = awardListIdx
	self.infoChapter = self.listChapter[awardListIdx]
	self.awardListIndexs = {}

	table.insert(self.awardListIndexs, cellIdx - 1)
	NetManager:RequestGetChapterAward(self.infoChapter.id, self.awardListIndexs, wrap_cb)
end

function PageStage:OnClickOneKey(data)
	local goCell = data.pointerPress.transform.parent
	local cellIdx = tonumber(goCell.name)
	local infoChapter = self.listChapter[cellIdx]
	local isOpen = infoChapter:IsOpen()
	local list, curIdx = infoChapter:GetChapterAwardList()

	self.infoChapter = infoChapter
	self.awardListIndexs = {}

	for j = 1, #list do
		local isRecv = list[j].state == 1
		local isCanRecv = infoChapter:GetStar() >= list[j].star

		if not isRecv and isCanRecv then
			table.insert(self.awardListIndexs, j - 1)
		end
	end

	self.curAwardIdx = cellIdx
	self.onekeyFlag = true

	LoadingMgr.Show(eLoadingType.Repeat)

	local function wrap_cb(pb)
		self:ResponseGetChapterAward(pb)
	end

	if #self.awardListIndexs == 0 then
		UIMgr.ShowMsg(_("Msg_Award_Can_Receive_None"))
	end

	NetManager:RequestGetChapterAward(infoChapter.id, self.awardListIndexs, wrap_cb)
end

function PageStage:OnClickedHideAward()
	SetActiveFunc(self.GoAwardList, false)
end

function PageStage:OnCloseAward()
	if self.isShow then
		SetActiveFunc(self.GoAward, false)

		self.isShow = false
	end

	if self.GoAwardList.activeSelf then
		SetActiveFunc(self.GoAwardList, false)
	end
end

function PageStage:OnClickedShowAward()
	if not self.isShow then
		SetActiveFunc(self.GoAward, true)

		self.isShow = true

		return
	end

	SetActiveFunc(self.GoAward, false)

	self.isShow = false
end

function PageStage:OnClickedRecvAward()
	if self.isShow then
		SetActiveFunc(self.GoAward, false)

		self.isShow = false

		return
	end

	SetActiveFunc(self.GoAward, true)

	self.isShow = true
end

function PageStage:ResponseGetChapterAward(msg)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if msg.result.code == 0 then
		for i = 1, #self.awardListIndexs do
			self.infoChapter.pb.awardStatus[self.awardListIndexs[i] + 1] = 1
		end

		InfoSoundEventMgr:LoadBank(RoleMgr:GetMaxFavorRole().data.VocalBank)
		InfoSoundEventMgr:Play("VocalCommon10", RoleMgr:GetMaxFavorRole().data.VocalCommon10)
		self:UpdateAward()
	else
		if self.GoAwardList.activeSelf then
			SetActiveFunc(self.GoAwardList, false)

			return
		elseif self.onekeyFlag then
			self.onekeyFlag = nil

			return
		end

		local awardIdx = self.curAwardIdx
		local infoChapter = self.listChapter[1]
		local list = infoChapter:GetChapterAwardList()

		if self.listCell then
			for i = 1, #self.listCell do
				self.listCell[i]:OnLeave()
			end
		end

		GOUtil.DestroyAllChildren(self.GoAwardGroup)

		local listItem = list[awardIdx].items

		self.listCell = {}

		for i = 1, #listItem do
			local infoItem = listItem[i]
			local item = CellItem(self.PrefabCellItem, self.GoAwardGroup, self)

			item:Create()
			item:UpdateWithNumType(infoItem)
			table.insert(self.listCell, item)
		end

		SetActiveFunc(self.GoAwardList, true)

		local list, curIdx = infoChapter:GetChapterAwardList()
		local x = awardIdx / 3 * 405
		local goCellPos = self.listAward["" .. self.awardListIdx][self.curAwardIdx].transform.position

		self.GoAwardList.transform.position = Vector3.New(goCellPos.x, goCellPos.y + 1.56, goCellPos.z)

		local Bg = self:GetChildGameObject("Panel/AwardList/BgList/Bg")
		local Group = self:GetChildGameObject("Panel/AwardList/BgList/Bg/Group")

		GOUtil.SetRectTransformSizeDelta(Bg, 167 * #listItem, 200)
		GOUtil.SetRectTransformSizeDelta(Group, 154 * #listItem, 136)
	end
end

function PageStage:UpdateStageNum()
	self:UpdatePanel()
end

function PageStage.RequestStartStage(infoStage, backScene, cb)
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			if cb ~= nil then
				cb()
			end

			InfoBGMEventMgr:Clear()

			NetManager.playStoryDuration = NetData:GetCurServerTime()

			SceneMgr.LoadScene("Scenario", {
				forceExit = false,
				StoryPrefabPath = infoStage.data.StoryPrefabPath,
				BackScene = backScene,
				stageId = infoStage.id,
				boutId = vPBMessage.boutId,
				chaos = {
					norce = vPBMessage.chaos.norce,
					ut = vPBMessage.chaos.ut,
					signature = vPBMessage.chaos.signature
				}
			})
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	if not AppConst.AssetBundleMode then
		NetManager:RequestStartStage(infoStage.id, {}, false, wrap_cb)
		LoadingMgr.Show(eLoadingType.Repeat)
	else
		local exist, type = OptionDownMgr:CheckBundleExist(infoStage.id, 1)

		if exist then
			NetManager:RequestStartStage(infoStage.id, {}, false, wrap_cb)
			LoadingMgr.Show(eLoadingType.Repeat)
		else
			local function cb()
				NetManager:RequestStartStage(infoStage.id, {}, false, wrap_cb)
				LoadingMgr.Show(eLoadingType.Repeat)
			end

			local data = {}

			data.callback = cb
			data.existType = type
			data.stageId = infoStage.id
			data.openFrom = 1

			require("UI/Page/PageSetting/DlgOptionalDownload")
			UIMgr.AddPanel(DlgOptionalDownload(), data)
		end
	end
end

function PageStage:OnClickedBtnGuide()
	require("UI/Dlg/Public/PGuide")
	UIMgr.AddPanel(PGuide(), GuideFunctionType.Stage)
end

function PageStage:OnBackAndroid()
	if self.isShow then
		self:OnCloseAward()

		return true
	end

	return false
end
