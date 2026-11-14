-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageChapter/PageChapter.lua

require("UI/Page/PageChapter/CellChapter")
require("UI/Page/PageChapter/CellChapterNode")
require("UI/Page/PagePass/PageStage")
require("UI/Dlg/Public/DlgAssetsInfo")
require("Info/PassMgr")
require("UI/Page/PageChapter/CellChapterEnum")
require("UI/Page/PageChapter/PageChapterCanvas")

local systemType = {
	TutorialFunctionType.AssetPass,
	TutorialFunctionType.TeamPass,
	TutorialFunctionType.CardPass,
	TutorialFunctionType.Boss,
	TutorialFunctionType.Tower,
	TutorialFunctionType.BossLive
}

PageChapter = class("PageChapter", UIPanel, true)

function PageChapter:ctor()
	PageChapter.base.ctor(self, "UI/PageChapter/PageChapter")
	self:AddChildPanel(DlgExit(), {
		title = Lang(26000610),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})

	self.DlgAssetsInfo = DlgAssetsInfo()

	self:AddChildPanel(self.DlgAssetsInfo, {
		x = -600,
		y = -42
	})
end

function PageChapter:PreLoad(vParam)
	self:LoadResAsync("UI/PageChapter/CellChapterMain", "PrefabCellChapterMain")
	self:LoadResAsync("UI/PageChapter/CellChapterNode", "PrefabCellChapterNode")
	self:LoadResAsync("UI/PageChapter/CellChapterEnum", "cellChapterEnum")
	self:LoadResAsync("UI/PageChapter/PageChapterCanvas", "PrefabPageChapterCanvas")
	self:LoadResAsync("UISpine/UI_Chapter/Ui_Bg_Chapter_01/Ui_Bg_Chapter_01", "PrefabBgSpine", GameObject)

	if ChapterMgr:GetBatteleTypeEnumID() == 0 then
		self.chapterTbl = ChapterMgr:ChapterGroupDataList(1)
		self.curChapter = ChapterMgr:GetCurChapter(ChapterType.main)
	else
		self.chapterTbl = ChapterMgr:ChapterGroupDataList(2)
		self.curChapter = ChapterMgr:GetCurChapter(ChapterType.mainhard)
	end

	self.PrefabCellChapter = self.PrefabCellChapterMain
end

function PageChapter:GetChapterTblIndex()
	local curChapter = self.curChapter
	local ID = curChapter.data.ID

	for i = 1, #self.chapterTbl do
		for j = 1, #self.chapterTbl[i].Chapter do
			if tonumber(self.chapterTbl[i].Chapter[j]) == tonumber(ID) then
				self.chapterEnumIndex = i
			end
		end
	end
end

function PageChapter:GetChapterTblList()
	self.ChapterTblList = {}

	local index = self.chapterEnumIndex

	if index then
		self.ChapterTblList[1] = tonumber(self.chapterTbl[index].Chapter[1])
		self.ChapterTblList[2] = tonumber(self.chapterTbl[index].Chapter[#self.chapterTbl[index].Chapter])
	end
end

function PageChapter:GetChapterTblNodeList()
	self.ChapterTblNodeList = {}

	local index = self.chapterEnumIndex

	if index then
		if index == 1 then
			self.ChapterTblNodeList[1] = tonumber(self.chapterTbl[index + 1].Chapter[1])
			self.ChapterTblNodeList[2] = tonumber(self.chapterTbl[index + 1].Chapter[#self.chapterTbl[index + 1].Chapter])
		elseif #self.chapterTbl == index then
			self.ChapterTblNodeList[1] = tonumber(self.chapterTbl[index - 1].Chapter[1])
			self.ChapterTblNodeList[2] = tonumber(self.chapterTbl[index - 1].Chapter[#self.chapterTbl[index - 1].Chapter])
		else
			self.ChapterTblNodeList[1] = tonumber(self.chapterTbl[index - 1].Chapter[1])
			self.ChapterTblNodeList[2] = tonumber(self.chapterTbl[index - 1].Chapter[#self.chapterTbl[index - 1].Chapter])
			self.ChapterTblNodeList[3] = tonumber(self.chapterTbl[index + 1].Chapter[1])
			self.ChapterTblNodeList[4] = tonumber(self.chapterTbl[index + 1].Chapter[#self.chapterTbl[index + 1].Chapter])
		end
	end
end

function PageChapter:GetChapterTblListPos()
	local index = self.chapterEnumIndex

	self.ChapterTblListPos = {}

	if index then
		local Chapter = {}

		Chapter = self.chapterTbl[index].Chapter
		self.ChapterTblListPos[tostring(Chapter[1])] = {
			0,
			286
		}
		self.ChapterTblListPos[tostring(Chapter[2])] = {
			-156,
			176
		}
		self.ChapterTblListPos[tostring(Chapter[3])] = {
			120,
			80
		}
	end
end

function PageChapter:GetChapterTblListNodePos()
	self.ChapterTblListNodePos = {}

	local index = self.chapterEnumIndex

	if index then
		local Chapter = {}

		if index == 1 then
			Chapter = self.chapterTbl[index + 1].Chapter
			self.ChapterTblListNodePos[tostring(Chapter[1])] = {
				-1300,
				200
			}
			self.ChapterTblListNodePos[tostring(Chapter[2])] = {
				-780,
				60
			}
			self.ChapterTblListNodePos[tostring(Chapter[3])] = {
				-210,
				180
			}
		elseif #self.chapterTbl == index then
			Chapter = self.chapterTbl[index - 1].Chapter
			self.ChapterTblListNodePos[tostring(Chapter[1])] = {
				-1300,
				200
			}
			self.ChapterTblListNodePos[tostring(Chapter[2])] = {
				-780,
				60
			}
			self.ChapterTblListNodePos[tostring(Chapter[3])] = {
				-210,
				180
			}
		else
			Chapter = self.chapterTbl[index - 1].Chapter
			self.ChapterTblListNodePos[tostring(Chapter[1])] = {
				-1300,
				200
			}
			self.ChapterTblListNodePos[tostring(Chapter[2])] = {
				-780,
				60
			}
			self.ChapterTblListNodePos[tostring(Chapter[3])] = {
				-210,
				180
			}
			Chapter = self.chapterTbl[index + 1].Chapter
			self.ChapterTblListNodePos[tostring(Chapter[1])] = {
				-450,
				260
			}
			self.ChapterTblListNodePos[tostring(Chapter[2])] = {
				-1360,
				-170
			}
			self.ChapterTblListNodePos[tostring(Chapter[3])] = {
				-680,
				-280
			}
		end
	end
end

function PageChapter:InitScroll()
	self.ScrollArea = self:GetChildGameObject("Panel1/ScrollArea")
	self.content = self:GetChildComponent("Panel1/ScrollArea/Content", "Transform")

	local count = #self.chapterTbl

	if ChapterMgr.CurChapterEnumIndex == 0 then
		self:GetChapterTblIndex()
	else
		self.chapterEnumIndex = ChapterMgr.CurChapterEnumIndex
	end

	local itemList = {}

	local function ListUpdate(item, index)
		local data = {}

		data.info = self.chapterTbl[index]
		data.starCountLists = self.starCountLists

		item:UpdateData(data, self.chapterEnumIndex, index, self.curChapter)
	end

	self.timer = TimerMgr.AddTimer(eTimerType.RealTime, 0.2, function()
		self.UIScrollTool = UIScrollTool()

		self.UIScrollTool:InitList(self.ScrollArea, self.content, count, self.cellChapterEnum, CellChapterEnum, self, false, nil, ListUpdate)
		UITweenUtil.DoListAnimation(self.content, 100, 0.12, nil, nil)

		local pos = GetContentPosUGUIScroll(self.UIScrollTool.ScrollView, count, self.chapterEnumIndex)

		self.UIScrollTool:SetInitPos(Vector3(0, pos, 0))
	end, nil)
end

function PageChapter:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCell)
end

function PageChapter:OnClickedCell(data)
	local go = data.pointerPress
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index

	if index == self.chapterEnumIndex then
		return
	end

	local curChapter = self.curChapter
	local isUnLock = tonumber(self.chapterTbl[index].Chapter[1]) <= tonumber(curChapter.data.ID)

	if not isUnLock then
		if curChapter.data.ID == 100 then
			UIMgr.ShowMsg(Lang(12902))
		else
			UIMgr.ShowMsg(string.format(Lang(26000611), tostring(tonumber(curChapter.data.ID) % 100)))
		end

		return
	end

	ChapterMgr.CurChapterEnumIndex = index
	self.chapterEnumIndex = index

	GOUtil.DestroyAllChildren(self.PageChapterCanvasGo.PanelCellCanvas)

	if self.listCellChapter then
		for _, v in pairs(self.listCellChapter) do
			if v then
				v:OnLeave()
			end
		end
	end

	self.listCellChapter = {}

	self:ConstructChapter()
	self.UIScrollTool:UpdateListDataKeepPos(self.chapterTbl)
end

function PageChapter:Purge()
	PageChapter.base.Purge(self)
	UITweenUtil.RemoveTween(self.content)

	if self.timer then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end

	Event.Instance:Fire("PageChapterCanvasEvent")
	ResourceMgr.Unload(self.PrefabCellChapterMain)
	ResourceMgr.Unload(self.cellChapterEnum)
	ResourceMgr.Unload(self.PrefabCellChapterNode)
	ResourceMgr.Unload(self.PrefabPageChapterCanvas)
	ResourceMgr.Unload(self.PrefabBgSpine)

	self.PageChapterCanvasGo = nil
	self.PrefabCellChapterMain = nil
	self.cellChapterEnum = nil
	self.PrefabCellChapterNode = nil
	self.PrefabCellChapter = nil

	self:OnLeave()
end

function PageChapter:OnLeave()
	if self.listCellChapter then
		for _, v in pairs(self.listCellChapter) do
			if v then
				v:OnLeave()
			end
		end

		self.listCellChapter = nil
	end

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function PageChapter:OnBack()
	self:GetChildComponent("Panel1", "Animator"):Play("Panel1_Close")
	self:GetChildComponent("Difficulty", "Animator"):Play("Difficulty_Close")
	self:GetChildComponent("Group2", "Animator"):Play("Group_Close")
	UIMgr.PopPanel()
end

function PageChapter:OnRegisterEvent()
	for i = 1, 6 do
		self:AddClick(self["GoEntrance" .. i], self.OnClickedEntrance)
	end

	self:AddClick(self.img_normal.gameObject, self.OnClickedBtnNormal)
	self:AddClick(self.img_hard.gameObject, self.OnClickedBtnHard)
	Event.Instance:Add("UpdateCellChapterActive", self.UpdateCellChapterActive, self)
	Event.Instance:Add("PageChapterEventNode", self.OnClickedBGEvent, self)
	EventListenerMgr.AddAnimListener(self.FX_Cloud_Anim, self.SetBg, self, eAnimEventType.OnAnimationEnd)
	EventListenerMgr.AddAnimListener(self.ChapterUnlock, self.OnClickedChapterUnlock, self, eAnimEventType.OnAnimationEnd)
end

function PageChapter:OnUnRegisterEvent()
	for i = 1, 6 do
		self:RemoveClick(self["GoEntrance" .. i], self.OnClickedEntrance)
	end

	for i = 1, 3 do
		self:RemoveClick(self["BossRaidBtn" .. i], self.OnClickedBossRaid)
	end

	self:OnUnRegisterCellChapter()
	self:OnUnRegisterCellChapterNode()
	self:RemoveClick(self.img_normal.gameObject, self.OnClickedBtnNormal)
	self:RemoveClick(self.img_hard.gameObject, self.OnClickedBtnHard)
	Event.Instance:Remove("UpdateCellChapterActive", self.UpdateCellChapterActive, self)
	Event.Instance:Remove("PageChapterEventNode", self.OnClickedBGEvent, self)
	EventListenerMgr.RemoveAnimListener(self.FX_Cloud_Anim, self.SetBg, self, eAnimEventType.OnAnimationEnd)
	EventListenerMgr.RemoveAnimListener(self.ChapterUnlock, self.OnClickedChapterUnlock, self, eAnimEventType.OnAnimationEnd)
end

function PageChapter:OnClickedBGEvent()
	for i = 1, #self.listCellChapter do
		self.listCellChapter[i]:NodeEvent()
	end
end

function PageChapter:DealWithLocalization()
	local Text

	Text = self:GetChildComponent("Group2/1/Text", "Text")
	Text.text = _("UI_Battle_Asset")
	Text = self:GetChildComponent("Group2/2/Text", "Text")
	Text.text = _("UI_Battle_Comb")
	Text = self:GetChildComponent("Group2/3/Text", "Text")
	Text.text = _("UI_Battle_Card")
	Text = self:GetChildComponent("Group2/4/Text", "Text")
	Text.text = _("UI_Battle_Party")
	Text = self:GetChildComponent("Group2/5/Text", "Text")
	Text.text = _("UI_Battle_Tower")
	Text = self:GetChildComponent("Group2/6/Text", "Text")
	Text.text = _("UI_Battle_Bosslive")
	Text = self:GetChildComponent("Difficulty/bnt_hard/Text", "Text")
	Text.text = _("UI_Difficult")
	Text = self:GetChildComponent("Difficulty/btn_normal/Text", "Text")
	Text.text = _("UI_Common")
end

function PageChapter:OnEnter(vParam)
	self.isFirstOpen = true
	self.firstEnter = true

	self:DealWithLocalization()

	self.chapterType = vParam

	local LauncherGo = GameObject.Find("Launcher")

	self.PageChapterCanvasGo = PageChapterCanvas(self.PrefabPageChapterCanvas, LauncherGo, self)

	self.PageChapterCanvasGo:Create()

	self.ChapterUnlock = self:GetChildGameObject("ChapterUnlock")
	self.BgSpine = self:GetChildGameObject("BgSpine")
	self.GoSpine = GOUtil.InstantiateUIPrefab(self.PrefabBgSpine, self.BgSpine)
	self.GoClick = self:GetChildGameObject("Click")
	self.FX_Cloud_Anim = self:GetChildGameObject("Click/FX_Cloud_Anim")
	self.AnimEff = GOUtil.FindChildComponent(self.GoClick, "FX_Cloud_Anim", "Animator")
	self.PanelCell = self:GetChildGameObject("PanelCell")
	self.img_normal = self:GetChildComponent("Difficulty/btn_normal", "Image")
	self.img_hard = self:GetChildComponent("Difficulty/bnt_hard", "Image")

	for i = 1, 6 do
		self["GoEntrance" .. i] = self:GetChildGameObject("Group2/" .. i)
		self["GoLock" .. i] = self:GetChildGameObject("Group2/" .. i .. "/Lock")
		self["TxtCon" .. i] = self:GetChildComponent("Group2/" .. i .. "/Lock/Text", "Text")

		SetActiveFunc(self["GoLock" .. i], true)

		self["ImgLock" .. i] = self:GetChildGameObject("Group2/" .. i .. "/Lock/ImgLock")
		self["ImgBg" .. i] = self:GetChildComponent("Group2/" .. i .. "/Image", "Image")
		self["ImgIcon" .. i] = self:GetChildComponent("Group2/" .. i .. "/Lock", "Image")

		SetActiveFunc(self["ImgLock" .. i], false)
		SetActiveFunc(self["TxtCon" .. i].gameObject, false)
	end

	for n = 1, 3 do
		self["BossRaidIcon" .. n] = self:GetChildComponent("Group3/" .. n .. "/Image", "Image")
		self["BossRaidDot" .. n] = self:GetChildGameObject("Group3/" .. n .. "/Dot")
		self["BossRaidTime" .. n] = self:GetChildComponent("Group3/" .. n .. "/time", "Text")
		self["BossRaidBtn" .. n] = self:GetChildGameObject("Group3/" .. n)

		self:AddClick(self["BossRaidBtn" .. n], self.OnClickedBossRaid)
	end

	UIUtil.SetImageSprite(self:GetChildComponent("Group3/3/Image", "Image"), "UI/PageChapter/AtlasChapter/BTN_bossattck_004a")
	UIUtil.SetImageSprite(self:GetChildComponent("Group3/3/Image/Image", "Image"), "UI/PageChapter/AtlasChapter/Word_bossattck_001")

	self.BossRaidGroupBg = self:GetChildGameObject("Group3/Image")

	self:ShowBossRaidTime()

	self.curBtnIndex = 1
	self.listCellChapterMain = {}
	self.listCellChapterTeam = {}
	self.listCellChapter = {}

	if self.chapterType == 2 then
		self.teamIndex = 1
		self.listTeamData = RoleMgr:GetTeamList()
		self.listTeamSelGo = {}
	end

	if ChapterMgr.CurChapterEnumIndex == 0 then
		self:GetChapterTblIndex()
	else
		self.chapterEnumIndex = ChapterMgr.CurChapterEnumIndex
	end

	self:UpdateData()
	self:ConstructChapter()
	self:UpdateBtnGuide()
	self:UpdateGroup2()
	self:InitScroll()
end

function PageChapter:ShowBossRaidTime()
	ActivityBossRaidMgr.bossRaidTimeData = nil

	if ActivityBossRaidMgr.bossRaidTimeData == nil then
		local activityList = ActiveMgr:GetActiveByType(eActiveType.bossraid)

		for i, v in ipairs(activityList) do
			if v:IsShowOpen() then
				ActivityBossRaidMgr.bossRaidTimeData = v

				break
			end
		end
	end

	if ActiveMgr:GetOpenActiveByType(eActiveType.boss)[1] then
		local a = string.split(ActiveMgr:GetOpenActiveByType(eActiveType.boss)[1].data.StartTime, " ")
		local StartTime = ""
		local CloseTime = ""

		if #a > 0 then
			local date = string.split(a[1], "-")
			local yearT = tonumber(date[1])
			local monthT = tonumber(date[2])
			local dayT = tonumber(date[3])

			StartTime = yearT .. "/" .. monthT .. "/" .. dayT
		end

		local b = string.split(ActiveMgr:GetOpenActiveByType(eActiveType.boss)[1].data.CloseTime, " ")

		if #b > 0 then
			local date = string.split(b[1], "-")
			local yearT = tonumber(date[1])
			local monthT = tonumber(date[2])
			local dayT = tonumber(date[3])

			CloseTime = yearT .. "/" .. monthT .. "/" .. dayT
		end
	end

	if ActivityBossRaidMgr.bossRaidTimeData then
		local a = string.split(ActivityBossRaidMgr.bossRaidTimeData.data.StartTime, " ")
		local StartTime = ""
		local CloseTime = ""

		if #a > 0 then
			local date = string.split(a[1], "-")
			local yearT = tonumber(date[1])
			local monthT = tonumber(date[2])
			local dayT = tonumber(date[3])

			StartTime = yearT .. "/" .. monthT .. "/" .. dayT
		end

		local b = string.split(ActivityBossRaidMgr.bossRaidTimeData.data.CloseTime, " ")

		if #b > 0 then
			local date = string.split(b[1], "-")
			local yearT = tonumber(date[1])
			local monthT = tonumber(date[2])
			local dayT = tonumber(date[3])

			CloseTime = yearT .. "/" .. monthT .. "/" .. dayT
		end
	end

	local isShow1 = #ActiveMgr:GetOpenActiveByType(eActiveType.boss) ~= 0 and ActiveMgr:GetOpenActiveByType(eActiveType.boss)[1]:IsShowOpen()

	SetActiveFunc(self.BossRaidBtn1, isShow1)

	local isShow2 = ActivityBossRaidMgr.bossRaidTimeData and ActivityBossRaidMgr.bossRaidTimeData:IsShowOpen()

	SetActiveFunc(self.BossRaidBtn2, isShow2)
	SetActiveFunc(self.BossRaidBtn3, true)
	SetActiveFunc(self.BossRaidGroupBg, isShow1 or isShow2)
end

function PageChapter:UpdateGroup2()
	for i = 1, 6 do
		local systemId = systemType[i]
		local isOpen = true

		if systemId ~= 0 then
			isOpen = TutorialMgr:IsOpenNoMsg(systemId)
		end

		SetActiveFunc(self["ImgLock" .. i], not isOpen)

		local gray = TenaryOp(isOpen, 0, 1)

		DealWithListRef(self, UIUtil.SetImageGray(self["ImgBg" .. i], gray))
		DealWithListRef(self, UIUtil.SetImageGray(self["ImgIcon" .. i], gray))
	end

	local gray = TenaryOp(TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Boss), 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.BossRaidIcon1, gray))

	gray = TenaryOp(TutorialMgr:IsOpenNoMsg(TutorialFunctionType.BossRaid), 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.BossRaidIcon2, gray))
end

function PageChapter:UpdateData()
	if self.chapterType == 1 then
		self.listCellChapter = self.listCellChapterMain
		self.PrefabCellChapter = self.PrefabCellChapterMain

		if ChapterMgr:GetBatteleTypeEnumID() == 0 then
			self:UndateBtnType(1)

			self.listChapter = ChapterMgr:GetChapterList(ChapterType.main)
		else
			self.listChapter = ChapterMgr:GetChapterList(ChapterType.mainhard)

			self:UndateBtnType(2)
		end
	elseif self.chapterType == 2 then
		self.listCellChapter = self.listCellChapterTeam
		self.PrefabCellChapter = self.PrefabCellChapterTeam

		local tId = self.listTeamData[self.teamIndex].ID

		self.listChapter = ChapterMgr:GetChapterList(ChapterType.comb, tId)
	elseif self.chapterType == 3 then
		self.listCellChapter = self.listCellChapterMain
		self.PrefabCellChapter = self.PrefabCellChapterMain
		self.listChapter = ChapterMgr:GetChapterList(ChapterType.event)
	end

	for i = 1, #self.listChapter do
		local infoChapter = self.listChapter[i]

		if infoChapter:IsOpen() then
			self.curChapterIndex = i
		end
	end
end

function PageChapter:ConstructChapter()
	for i = 1, #self.listCellChapter do
		local item = self.listCellChapter[i]

		SetActiveFunc(item.UIRootObject, false)
	end

	local listChapter = self.listChapter

	self:OnUnRegisterCellChapter()
	self:OnUnRegisterCellChapterNode()

	self.listChapterGo = {}
	self.listChapterGoNode = {}
	self.chapterCount = #listChapter
	self.starCountLists = {}

	self:GetChapterTblList()
	self:GetChapterTblListPos()
	self:GetChapterTblNodeList()
	self:GetChapterTblListNodePos()

	local IsCell = false

	if self.ChapterTblList[1] <= tonumber(self.curChapter.data.ID) and self.ChapterTblList[2] >= tonumber(self.curChapter.data.ID) then
		IsCell = true
	end

	for i = 1, self.chapterCount do
		local listStage = listChapter[i].data.StageID
		local stageCnt = #listStage
		local passListStage = {}
		local starStage = {}

		for j = 1, stageCnt do
			local infoStage = ChapterMgr:GetStage(listStage[j])

			if infoStage.data and (infoStage.data.Type == 1 or infoStage.data.Type == 3) then
				table.insert(starStage, infoStage)
			end
		end

		local starStageCnt = #starStage
		local sumStar = starStageCnt * 3
		local collectedStar = listChapter[i]:GetStar()

		self.starCountLists[i] = {
			listChapter[i].data.ID,
			collectedStar,
			sumStar
		}

		if self.ChapterTblList[1] <= tonumber(listChapter[i].data.ID) and self.ChapterTblList[2] >= tonumber(listChapter[i].data.ID) then
			local item = self.listCellChapter[i]

			if self.listCellChapter[i] == nil then
				item = CellChapter(self.PrefabCellChapter, self.PageChapterCanvasGo.PanelCellCanvas, self)

				item:Create()

				item.UIRootObject.name = i

				table.insert(self.listCellChapter, item)
				table.insert(self.listChapterGo, item.UIRootObject)

				local offx = tonumber(self.ChapterTblListPos[tostring(listChapter[i].data.ID)][1])
				local offy = tonumber(self.ChapterTblListPos[tostring(listChapter[i].data.ID)][2])

				GOUtil.SetRectTransformAnchoredPosition(item.UIRootObject, offx, offy)
			end

			if not IsCell and collectedStar < sumStar then
				IsCell = true
				item.IsCell = true
			end

			if listChapter[i] == self.curChapter then
				item.IsCell = true

				if i == self.chapterCount and sumStar <= collectedStar then
					item.IsCell = false
				end
			end

			local data = {}

			data.listChapter = listChapter
			data.info = listChapter[i]
			data.index = i
			data.chapterType = self.chapterType

			item:UpdateData(data, i, self.curChapter)
			item:PlayUnLockAnim(listChapter[i])
			SetActiveFunc(item.UIRootObject, true)
		end
	end

	local RW = Screen.width
	local RH = Screen.height
	local sw = RW
	local mx = 1574

	mx = 1420
	self.maxPanelCellLength = mx - sw
	self.limitWidth = GOUtil.GetRectTransformSizeDeltaWidth(self.BgSpine) - sw
	self.posStart = 600
	self.moveRate = 0.8

	if self.maxPanelCellLength > self.limitWidth then
		self.moveRate = self.limitWidth / self.maxPanelCellLength
	end

	if self.maxPanelCellLength < 0 then
		self.maxPanelCellLength = 0
	end

	if self.chapterCount > 4 then
		local mx = 150 + 356 * self.curChapterIndex

		self.posStart = sw / 2 - mx

		if self.posStart < -self.maxPanelCellLength then
			self.posStart = -self.maxPanelCellLength
		end

		if self.posStart > 0 then
			self.posStart = 0
		end
	end
end

function PageChapter:PromptChapterUnlock(callback)
	SetActiveFunc(self.ChapterUnlock, true)

	self.listCallback = self.listCallback or {}

	if callback ~= nil then
		table.insert(self.listCallback, callback)
	end
end

function PageChapter:OnClickedChapterUnlock()
	SetActiveFunc(self.ChapterUnlock, false)

	if self.listCallback then
		for _, cb in ipairs(self.listCallback) do
			cb()
		end

		self.listCallback = nil
	end

	InstructionMgr:TriggerWait("ChapterUnlock")
	self:ShowPhoneCallIn()
end

function PageChapter:UpdateCellChapterActive()
	for i = 1, #self.listCellChapter do
		self.listCellChapter[i]:UpdateActive()
	end
end

function PageChapter:OnUnRegisterCellChapter()
	if self.listChapterGo == nil then
		return
	end

	for i = 1, #self.listChapterGo do
		-- block empty
	end
end

function PageChapter:OnUnRegisterCellChapterNode()
	if self.listChapterGoNode == nil then
		return
	end

	for i = 1, #self.listChapterGoNode do
		self:RemoveClick(self.listChapterGoNode[i], self.OnClickedCellChapterNode)
	end
end

function PageChapter:OnClickedBtnNormal()
	if self.type ~= nil and self.type == 1 then
		return
	end

	if self.listCellChapter then
		for _, v in pairs(self.listCellChapter) do
			if v then
				v:OnLeave()
			end
		end
	end

	self.chapterTbl = ChapterMgr:ChapterGroupDataList(1)
	self.listChapter = ChapterMgr:GetChapterList(ChapterType.main)
	self.curChapter = ChapterMgr:GetCurChapter(ChapterType.main)

	ChapterMgr:SetBatteleTypeEnumID(0)
	self:UndateBtnType(1)

	if self.DlgAssetsInfo then
		self.DlgAssetsInfo:ResetByConfig()
	end
end

function PageChapter:UndateBtnType(type)
	self.type = type

	Event.Instance:Fire("ChangePageBuff")

	if self.firstEnter then
		self.firstEnter = false

		self:SetTab()
	else
		self.AnimEff:Play("FX_Cloud_Anim")
	end
end

function PageChapter:SetTab()
	if self.type == 1 then
		UIUtil.SetSpineAnimationState(self.GoSpine, "day", false, true)
		SetImageSprite(self.img_normal, "UI/PageChapter/AtlasChapter/BTN_white_mid_01a", self)
		SetImageSprite(self.img_hard, "UI/PageChapter/AtlasChapter/BTN_white_mid_01b", self)

		self:GetChildComponent("Difficulty/btn_normal/Text", "Text").color = Color.New(1, 1, 1, 1)
		self:GetChildComponent("Difficulty/bnt_hard/Text", "Text").color = Color.New(0.35294117647058826, 0.35294117647058826, 0.35294117647058826, 1)
	else
		UIUtil.SetSpineAnimationState(self.GoSpine, "night", false, true)
		SetImageSprite(self.img_normal, "UI/PageChapter/AtlasChapter/BTN_white_mid_01b", self)
		SetImageSprite(self.img_hard, "UI/PageChapter/AtlasChapter/BTN_white_mid_01a", self)

		self:GetChildComponent("Difficulty/btn_normal/Text", "Text").color = Color.New(0.35294117647058826, 0.35294117647058826, 0.35294117647058826, 1)
		self:GetChildComponent("Difficulty/bnt_hard/Text", "Text").color = Color.New(1, 1, 1, 1)
	end

	if self.isFirstOpen then
		GOUtil.UpdateSpineSkeleton(self.GoSpine)

		self.isFirstOpen = false
	end

	local curChapter = ChapterMgr:GetCurChapter(ChapterType.main)

	SetActiveFunc(self:GetChildGameObject("Difficulty/bnt_hard/hard_lock"), tonumber(curChapter.id) <= GetConfigArgInt("HeroDungeonLock"))
end

function PageChapter:SetBg()
	self:SetTab()

	ChapterMgr.CurChapterEnumIndex = 0

	self:GetChapterTblIndex()
	GOUtil.DestroyAllChildren(self.PageChapterCanvasGo.PanelCellCanvas)

	self.listCellChapter = {}

	self:ConstructChapter()
	self.UIScrollTool:UpdateListData(self.chapterTbl)

	local pos = GetContentPosUGUIScroll(self.UIScrollTool.ScrollView, #self.chapterTbl, self.chapterEnumIndex)

	self.UIScrollTool.ScrollView:SetContentPosImmediate(Vector2(0, -pos))
	UITweenUtil.RemoveTween(self.content)
	UITweenUtil.DoListAnimation(self.content, 100, 0.12, nil, nil)

	if self.type == 2 then
		local hasDot = PersistentStoreUtil.GetBool("DeffDot")

		if hasDot then
			UIMgr:ShowDot(10)
		else
			UIMgr:HideDot(10)
		end
	end
end

function PageChapter:OnClickedBtnHard()
	if self.type ~= nil and self.type == 2 then
		return
	end

	if tonumber(ChapterMgr:GetCurChapter(ChapterType.main).id) <= GetConfigArgInt("HeroDungeonLock") then
		local isOpen, msg = ActiveMgr:IsBossStageUnlock(20101)

		UIMgr.ShowMsg(msg)

		return
	end

	if self.listCellChapter then
		for _, v in pairs(self.listCellChapter) do
			if v then
				v:OnLeave()
			end
		end
	end

	self.chapterTbl = ChapterMgr:ChapterGroupDataList(2)
	self.listChapter = ChapterMgr:GetChapterList(ChapterType.mainhard)
	self.curChapter = ChapterMgr:GetCurHardChapter()

	ChapterMgr:SetBatteleTypeEnumID(1)
	self:UndateBtnType(2)

	if self.DlgAssetsInfo then
		self.DlgAssetsInfo:ResetByConfig()
	end
end

function PageChapter:OnClickedBossRaid(data)
	local go = data.pointerPress.gameObject
	local index = tonumber(go.name)

	if index == 1 then
		local isOpen = TutorialMgr:IsOpenTutWithMessage(TutorialFunctionType.Boss, true)

		if not isOpen then
			return
		end
	elseif index == 2 then
		local isOpen = TutorialMgr:IsOpenTutWithMessage(TutorialFunctionType.BossRaid, true)

		if not isOpen then
			return
		end
	end

	if index == 1 then
		local isShow, msg = ActiveMgr:IsBossActiveOpen()

		if not isShow then
			UIMgr.ShowMsg(msg)

			return
		end

		ChapterMgr.bossIndex = 0

		require("UI/Page/PageActivity/PageBossActivityBG")

		ChapterMgr.BossActivityStageType = nil

		PageBossActivityBG.OpenActivity()
	elseif index == 2 then
		if ActivityBossRaidMgr.bossRaidTimeData and ActivityBossRaidMgr.bossRaidTimeData:IsShowOpen() then
			ActivityBossRaidMgr.selectTab = nil

			require("UI/Page/PageActivityBossRaid/PageActivityBossRaid")
			UIMgr.SwitchPanel(PageActivityBossRaid())
		else
			UIMgr.ShowMsg(_("Msg_Active_Over"))
		end
	else
		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:GetTimeSpaceData(function(msg)
			TimeSpaceChapterMgr:Refresh()
			NetManager:RequestTaskList(function()
				LoadingMgr.Hide(eLoadingType.Repeat)
				require("UI/Page/PageTimeSpace/PageTimeSpace")
				UIMgr.SwitchPanel(PageTimeSpace())
			end)
		end)
	end
end

function PageChapter:OnClickedEntrance(data)
	local go = data.pointerPress.gameObject
	local index = tonumber(go.name)
	local systemId = systemType[index]

	if systemId ~= 0 then
		local isOpen = TutorialMgr:IsOpenTut(systemId)

		if not isOpen then
			return
		end
	end

	if index == 1 then
		local assetPass = 3
		local listAssetBranch = PassMgr:GetListAssetBranchId(assetPass)
		local branchId = listAssetBranch[1]
		local temp = {
			assetPass = assetPass,
			branchId = branchId
		}

		require("UI/Page/PagePass/PageAssetStage")
		UIMgr.SwitchPanel(PageAssetStage, temp)
	elseif index == 2 then
		require("UI/Page/PagePass/PageTeamPass")
		UIMgr.SwitchPanel(PageTeamPass)
	elseif index == 3 then
		require("UI/Page/PagePass/PageCardStage")
		UIMgr.SwitchPanel(PageCardStage)
	elseif index == 4 then
		local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Boss)

		if not isOpen then
			return
		end

		local isShow, msg = ActiveMgr:IsBossActiveOpen()

		if not isShow then
			UIMgr.ShowMsg(msg)

			return
		end

		ChapterMgr.bossIndex = 0

		require("UI/Page/PageActivity/PageBossActivityBG")

		ChapterMgr.BossActivityStageType = nil

		PageBossActivityBG.OpenActivity()
	elseif index == 5 then
		require("UI/Page/PageTower/PageTower")
		UIMgr.SwitchPanel(PageTower)
	elseif index == 6 then
		ChapterMgr.BossLiveToTeam = 0

		require("UI/Page/PageBosslive/PageBosslive")
		UIMgr.SwitchPanel(PageBosslive)
	end
end

function PageChapter:UpdateBtnGuide()
	return
end

function PageChapter:OnClickedCellChapterNode(data)
	local go = data.pointerPress.gameObject
	local index = tonumber(go.name)
	local infoChapter = self.listChapter[index]
	local curChapter = self.curChapter

	if not infoChapter:IsOpen() then
		if curChapter.data.ID == 100 then
			UIMgr.ShowMsg(Lang(12902))
		else
			UIMgr.ShowMsg(string.format(Lang(26000611), tostring(tonumber(curChapter.data.ID) % 100)))
		end

		return
	end

	for i = 1, #self.chapterTbl do
		for j = 1, #self.chapterTbl[i].Chapter do
			if tonumber(self.chapterTbl[i].Chapter[j]) == tonumber(infoChapter.data.ID) then
				self.chapterEnumIndex = i
			end
		end
	end

	self.UIScrollTool:UpdateListDataKeepPos(self.chapterTbl)
	GOUtil.DestroyAllChildren(self.PageChapterCanvasGo.PanelCellCanvas)

	if self.listCellChapter then
		for _, v in pairs(self.listCellChapter) do
			if v then
				v:OnLeave()
			end
		end
	end

	self.listCellChapter = {}

	self:ConstructChapter()
end

function PageChapter:OnClickedCellChapter(data)
	local go = data.pointerPress.gameObject
	local index = tonumber(go.name)
	local infoChapter = self.listChapter[index]
	local curChapter = self.curChapter
	local chapNum = ChapterMgr:GetChapterIdx(infoChapter.data.ID)

	if type(chapNum) ~= "number" then
		chapNum = 0
	end

	if not infoChapter:IsOpen() then
		if curChapter.data.ID == 100 then
			UIMgr.ShowMsg(Lang(12902))
		else
			UIMgr.ShowMsg(string.format(Lang(26000611), tostring(tonumber(curChapter.data.ID) % 100)))
		end

		return
	end

	local chapterType = infoChapter.data.Type
	local isOpen = infoChapter:IsOpen()

	if isOpen then
		UIMgr.SwitchPanel(PageStage, {
			chapterType = self.chapterType,
			chapterId = infoChapter.data.ID
		})
	end
end

function PageChapter:OnClickedGuideBtn()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.BigMap)
end

function PageChapter:ShowPhoneCallIn()
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
