-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageManual/PageStoryVideo.lua

require("UI/Page/PageManual/CellPicTab")
require("UI/Page/PageManual/CellVideoPage")
require("UI/Page/PageManual/CellSong")

local videoData = require("luaData/VideoData")
local songData = require("luaData/SongSubtitleData")

PageStoryVideo = class("PageStoryVideo", UIPanel)

local PageCellCount = 6

function PageStoryVideo:ctor()
	self.UIPrefabPath = "UI/PageManual/PageStoryVideo"

	self:AddChildPanel(DlgExit(), {
		title = _("Desc_Story"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PageStoryVideo:PreLoad()
	self:LoadResAsync("UI/PageManual/CellPicTab", "PrefabCellTab", GameObject)
	self:LoadResAsync("UI/PageManual/CellVideoPage", "PrefabCellPage", GameObject)
	self:LoadResAsync("UI/PageManual/CellVideoItem", "PrefabCellItem", GameObject)
	self:LoadResAsync("UI/PageManual/CellSong", "PrefabCellSong", GameObject)
end

function PageStoryVideo:OnBack()
	UIMgr.PopPanel()
end

function PageStoryVideo:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellTab)
	ResourceMgr.Unload(self.PrefabCellPage)
	ResourceMgr.Unload(self.PrefabCellSong)
	ResourceMgr.Unload(self.PrefabCellItem)

	if self.UITabScrollTool then
		self.UITabScrollTool:Purge()
	end

	self.UITabScrollTool = nil

	if self.timer then
		TimerMgr.RemoveTimer(self.timer)
	end

	if self.UIPageScrollTool then
		self.UIPageScrollTool:Purge()
	end

	self.UIPageScrollTool = nil

	if self.videoRef then
		ResourceMgr.Unload(self.videoRef)

		self.videoRef = nil
	end
end

function PageStoryVideo:OnRegisterEvent()
	self:AddClick(self.ButtonSkip, self.OnClickButtonSkip)
	self:AddClick(self.left.gameObject, self.OnClickArrowLeft)
	self:AddClick(self.right.gameObject, self.OnClickArrowRight)
	self:AddClick(self.BtnOneKey, self.OnClickBtnOneKey)
	Event.Instance:Add("PlayStroyVideo", self.PlayStoryVideo, self)
	Event.Instance:Add("ClickPoolTab", self.OnClickTab, self)
	Event.Instance:Add("UpdateRedDot", self.UpdateRedDot, self)
	self:AddClick(self.Btn7, self.ShowRayNoOpen)
end

function PageStoryVideo:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonSkip, self.OnClickButtonSkip)
	self:RemoveClick(self.left.gameObject, self.OnClickArrowLeft)
	self:RemoveClick(self.right.gameObject, self.OnClickArrowRight)
	self:RemoveClick(self.BtnOneKey, self.OnClickBtnOneKey)
	Event.Instance:Remove("PlayStroyVideo", self.PlayStoryVideo, self)
	Event.Instance:Remove("ClickPoolTab", self.OnClickTab, self)
	Event.Instance:Remove("UpdateRedDot", self.UpdateRedDot, self)
	self:RemoveClick(self.Btn7, self.ShowRayNoOpen)
end

function PageStoryVideo:OnEnter(vParam)
	if vParam then
		self.teamIndex = vParam.Team
	end

	self:DealWithLocalization()

	self.ButtonSkip = self:GetChildGameObject("VideoBG/Button")
	self.VideoBG = self:GetChildGameObject("VideoBG")
	self.listTab = {
		{
			Name = _("Desc_Animator")
		},
		{
			Name = _("Desc_Song")
		}
	}
	self.Count = self:GetChildComponent("Panel/CollectCount/Count", "Text")
	self.imgFill = self:GetChildComponent("Panel/CollectCount/bg/imgFill", "Image")
	self.Btn7 = self:GetChildGameObject("Panel/TeamGroup/Content/Btn7/Btn")
	self.tabPageGo = self:GetChildGameObject("Panel/PageIndex")
	self.PageUITab = UITab(self.tabPageGo, 7, self.TabPageClick, self, 1)
	self.PageTabs = {}

	for i = 1, 7 do
		self.PageTabs[i] = GOUtil.FindChildGameObject(self.tabPageGo, "Btn" .. i)
	end

	self.tabTeamGo = self:GetChildGameObject("Panel/TeamGroup/Content")
	self.listTeamData = TeamMgr.Instance:GetTeamList()

	for i = 1, #self.listTeamData do
		if self.listTeamData[i].ManualVersion == 0 then
			local go = self:GetChildGameObject("Panel/TeamGroup/Content/Btn" .. i)

			SetActiveFunc(go, false)
		end
	end

	self.teamCnt = 6
	self.TeamUITab = UITab(self.tabTeamGo, self.teamCnt, self.TabTeamClick, self, self.teamIndex or 1)
	self.left = self:GetChildComponent("Panel/PageIndex/left", "Image")
	self.right = self:GetChildComponent("Panel/PageIndex/right", "Image")
	self.BtnOneKey = self:GetChildGameObject("Panel/BtnOneKey")
	self.ImgOneKey = self:GetChildComponent("Panel/BtnOneKey", "Image")
	self.Fx_UI_009_2 = self:GetChildGameObject("Panel/BtnOneKey/Fx_UI_009_2")

	self:InitTabScrollView()
	self:InitPageVideoScroll()
	self:InitSongScrollView()
	self:InitRedDot()
	self:OnClickTab(TenaryOp(self.teamIndex == nil, 1, 2))
end

function PageStoryVideo:InitRedDot()
	for i = 1, self.teamCnt do
		RedDotSystemMgr.SetUIRedDot(self.TeamUITab.rootGos[i], string.format("Arrow/Manual/Story/Song/%d", i))
	end
end

function PageStoryVideo:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/CollectCount/Text", "Text")
	txt.text = _("Collection_Progress")
end

function PageStoryVideo:UpdateCollectNum()
	local totalNum = 0
	local curNun = 0

	if self.selectIndex == 1 then
		totalNum = #videoData
		curNun = 0

		for i, v in ipairs(videoData) do
			local infoStage = ChapterMgr:GetStage(v.UnlockStageId)

			if infoStage:IsPass() then
				curNun = curNun + 1
			end
		end
	elseif self.selectIndex == 2 then
		totalNum = 0

		for i, v in ipairs(songData) do
			if self.listTeamData[v.Team].ManualVersion == 1 then
				totalNum = totalNum + 1
			end
		end

		curNun = 0

		for i, v in ipairs(songData) do
			local infoStage = ChapterMgr:GetStage(v.UnlockStageId)

			if infoStage:IsPass() and self.listTeamData[v.Team].ManualVersion == 1 then
				curNun = curNun + 1
			end
		end
	end

	self.Count.text = curNun .. "/" .. totalNum
	self.imgFill.fillAmount = curNun / totalNum
end

function PageStoryVideo:InitTabScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/ScrollArea2")
	local content = self:GetChildComponent("Panel/ScrollArea2/Content", "Transform")
	local count = #self.listTab

	local function addClick(item)
		item:OnRegisterEvent()
	end

	local function updateTab(item, index)
		item.Index = index

		local info = {}

		info.tabName = self.listTab[index].Name

		local _type = index == 1 and eCollectionAwardType.VIDEO or eCollectionAwardType.SONG

		item:UpdateData(info, self.selectIndex, _type)

		local path

		path = index == 1 and "Arrow/Manual/Story/Video" or "Arrow/Manual/Story/Song"

		item:SetDot(path)
	end

	self.UITabScrollTool = UIScrollTool()

	self.UITabScrollTool:InitList(ScrollArea, content, count, self.PrefabCellTab, CellPicTab, self, false, addClick, updateTab)

	self.UITabScrollTool.ScrollView.horizontal = false
	self.UITabScrollTool.ScrollView.vertical = false
end

function PageStoryVideo:InitPageVideoScroll()
	local function ListUpdate(item, index)
		local data = self.ListPage[index]

		function data.callback()
			self.enterScene = true
		end

		data.PrefabCellItem = self.PrefabCellItem

		item:UpdateData(data)
	end

	local function AddClick(item, index)
		return
	end

	local scrollArea = self:GetChildGameObject("Panel/ScrollAreaPage")

	self.content = self:GetChildComponent("Panel/ScrollAreaPage/Content", "Transform")

	local count = 0

	self.UIPageScrollTool = UIScrollTool()

	self.UIPageScrollTool:InitList(scrollArea, self.content, count, self.PrefabCellPage, CellVideoPage, self, true, AddClick, ListUpdate)

	self.PageView = GOUtil.AddMissingComponent(scrollArea, "UIScrollViewPageView")

	local function wrap_cb(index)
		self.PageUITab.index = TenaryOp(index + 1 > self.pageCount, self.pageCount, index + 1)

		self.PageUITab:Update()
		self:UpdateArrowColor()
	end

	self.PageView.OnPageChanged:AddListener(wrap_cb)
end

function PageStoryVideo:InitSongScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/ScrollAreaSong")
	local content = self:GetChildComponent("Panel/ScrollAreaSong/Content", "Transform")
	local count = 0

	local function addClick(item)
		self:AddClick(item.UIRootObject, function()
			if not ChapterMgr:GetStage(item.data.UnlockStageId):IsPass() then
				local infoStage = ChapterMgr:GetStage(item.data.UnlockStageId)
				local infoChapter, i, j = ChapterMgr:GetChapterByStageID(infoStage.id)
				local str
				local infoChapter, i, j = ChapterMgr:GetChapterByStageID(infoStage.id)

				if infoChapter ~= nil and infoChapter.data.Type == 1 and i ~= nil and j ~= nil then
					local strStage = "<color=yellow>" .. i .. "-" .. j .. "</color>"

					str = _("eBattleType_1") .. strStage .. Lang(infoStage.data.Name) .. " " .. _("Prompt_TutorialLimitStage")
				elseif infoChapter ~= nil and infoChapter.data.Type ~= 1 and i ~= nil and j ~= nil then
					local strStage = "<color=yellow>" .. Lang(i) .. "-" .. Lang(j) .. "</color>"

					str = strStage .. Lang(infoStage.data.Name) .. " " .. _("Prompt_TutorialLimitStage")
				end

				UIMgr.ShowMsg(str)
			else
				require("UI/Page/PageManual/PageSongPlay")
				UIMgr.SwitchPanel(PageSongPlay(), {
					data = item.data
				})
			end
		end)
		item:OnRegisterEvent()
	end

	local function updateTab(item, index)
		item.Index = index

		item:UpdateData(self.listSong[index])
	end

	self.UISongScrollTool = UIScrollTool()

	self.UISongScrollTool:InitList(ScrollArea, content, count, self.PrefabCellSong, CellSong, self, true, addClick, updateTab)
end

function PageStoryVideo:UpdataPageData()
	self.pageCount = math.ceil(#videoData / PageCellCount)
	self.ListPage = {}

	for i = 1, self.pageCount do
		local data = {}

		for j = (i - 1) * PageCellCount + 1, #videoData do
			table.insert(data, videoData[j])

			if #data == PageCellCount then
				break
			end
		end

		table.insert(self.ListPage, data)
	end

	self.UIPageScrollTool:UpdateListData(self.ListPage)

	for i = 1, #self.PageTabs do
		if i > self.pageCount then
			self.PageTabs[i]:SetActive(false)
		else
			self.PageTabs[i]:SetActive(true)
		end
	end

	self.PageUITab.index = 1

	self.PageUITab:Update()
	self:UpdateArrowColor()
	GOUtil.SetRectTransformAnchoredPosition(self.UIPageScrollTool.ScrollView.content.gameObject, 0, 0)
	self.PageView:RefreshPageIndex(self.pageCount)
end

function PageStoryVideo:TabPageClick()
	self.PageView:PageTo(self.PageUITab.index - 1)
	self:UpdateArrowColor()
end

function PageStoryVideo:UpdateArrowColor()
	if self.PageUITab.index == 1 then
		self.left.color = getColorFromString("acb6bb")
	else
		self.left.color = getColorFromString("37acbe")
	end

	if self.PageUITab.index == self.pageCount then
		self.right.color = getColorFromString("acb6bb")
	else
		self.right.color = getColorFromString("37acbe")
	end
end

function PageStoryVideo:OnClickTab(index, isForce)
	if index == self.selectIndex and not isForce then
		return
	end

	self.selectIndex = index

	self.UITabScrollTool:UpdateListDataKeepPos(self.listTab)

	if index == 1 then
		self.tabTeamGo.transform.parent.gameObject:SetActive(false)
		self.tabPageGo:SetActive(true)
		self.UIPageScrollTool.ScrollArea:SetActive(true)
		self.UISongScrollTool.ScrollArea:SetActive(false)
		self:UpdataPageData()
		self:UpdateCollectNum()
	else
		self.tabTeamGo.transform.parent.gameObject:SetActive(true)
		self.tabPageGo:SetActive(false)
		self.UIPageScrollTool.ScrollArea:SetActive(false)
		self.UISongScrollTool.ScrollArea:SetActive(true)
		self:TabTeamClick()
		self:UpdateCollectNum()
	end

	self:UpdateBtnOneKey()
end

function PageStoryVideo:UpdateRedDot()
	self:UpdateBtnOneKey()
	self.UITabScrollTool:UpdateListDataKeepPos(self.listTab)
end

function PageStoryVideo:TabTeamClick()
	self.listSong = CollectionManager:GetSongInfo(self.TeamUITab.index)

	self.UISongScrollTool:UpdateListData(self.listSong)
	self.UITabScrollTool:UpdateListDataKeepPos(self.listTab)
end

function PageStoryVideo:PlayStoryVideo(path)
	self.VideoBG:SetActive(true)
	InfoBGMEventMgr:StopBGM()

	local video = self:GetChildComponent("VideoBG/video", "VideoPlayer")

	self.videoRef = UIUtil.SetVideoPlayerClip(video, path)

	video.gameObject:SetActive(true)

	local t = tonumber(video.clip.length)

	self.timer = TimerMgr.AddTimer(eTimerType.RealTime, t, function()
		self.VideoBG:SetActive(false)
		InfoBGMEventMgr:ReplayBGM()

		if self.videoRef then
			ResourceMgr.Unload(self.videoRef)

			self.videoRef = nil
		end
	end, {})
end

function PageStoryVideo:OnClickButtonSkip()
	if self.timer then
		TimerMgr.RemoveTimer(self.timer)
	end

	if self.videoRef then
		ResourceMgr.Unload(self.videoRef)

		self.videoRef = nil
	end

	InfoBGMEventMgr:ReplayBGM()
	self.VideoBG:SetActive(false)
end

function PageStoryVideo:OnClickArrowLeft()
	if self.PageUITab.index == 1 then
		return
	end

	self.PageUITab.index = self.PageUITab.index - 1

	self.PageView:PageTo(self.PageUITab.index - 1)
	self:UpdateArrowColor()
	self.PageUITab:Update()
end

function PageStoryVideo:OnClickArrowRight()
	if self.PageUITab.index == self.pageCount then
		return
	end

	self.PageUITab.index = self.PageUITab.index + 1

	self.PageView:PageTo(self.PageUITab.index - 1)
	self:UpdateArrowColor()
	self.PageUITab:Update()
end

function PageStoryVideo:UpdateBtnOneKey()
	self.AwardList = {}

	if self.selectIndex == 1 then
		self.curType = eCollectionAwardType.VIDEO

		local list = ManualRDL.StoryRDL.Get_CAN_RECEIVE_VIDEO()

		table.merge(self.AwardList, list)
	else
		self.curType = eCollectionAwardType.SONG

		for i = 1, #self.listTeamData do
			if self.listTeamData[i].ManualVersion ~= 0 then
				local list = ManualRDL.StoryRDL.Get_CAN_RECEIVE_SONG()[self.listTeamData[i].ID]

				table.merge(self.AwardList, list)
			end
		end
	end

	if #self.AwardList > 0 then
		GOUtil.SetActive(self.Fx_UI_009_2, true)
		UIUtil.SetImageSprite(self.ImgOneKey, "UI/PageManual/AtlasPageImpression/BTN_square_pink_01", self)
	else
		GOUtil.SetActive(self.Fx_UI_009_2, false)
		UIUtil.SetImageSprite(self.ImgOneKey, "UI/PageManual/AtlasPageImpression/BTN_square_pink_02", self)
	end
end

function PageStoryVideo:OnClickBtnOneKey()
	if #self.AwardList == 0 then
		UIMgr.ShowMsg(_("Msg_Award_Can_Receive_None"))

		return
	end

	NetManager:RequestGetCollectionAward(self.curType, self.AwardList, function(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			if self.curType == eCollectionAwardType.VIDEO then
				table.merge(CollectionManager.videoAwardList, self.AwardList)
				self.UIPageScrollTool:UpdateListDataKeepPos(self.ListPage)
			elseif self.curType == eCollectionAwardType.SONG then
				table.merge(CollectionManager.songAwardList, self.AwardList)
				self.UISongScrollTool:UpdateListData(self.listSong)
			end

			self:UpdateBtnOneKey()
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageStoryVideo:ShowRayNoOpen()
	UIMgr.ShowMsg(_("Desc_RaySongNotOpen"))
end

function PageStoryVideo:OnBackAndroid()
	if GOUtil.IsActiveSelf(self.VideoBG) then
		self:OnClickButtonSkip()

		return true
	end

	return false
end
