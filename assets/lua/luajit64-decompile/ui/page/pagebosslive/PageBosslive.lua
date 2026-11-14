-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageBosslive/PageBosslive.lua

local InfoTeam = require("Info.InfoTeam")
local SceneData = require("luaData/SceneData")
local CharacterTeam = require("luaData.CharacterTeam")

require("UI/Page/PageBosslive/CellBossliveEnum")
require("UI/Page/PageBosslive/CellBossliveStage")

PageBosslive = class("PageBosslive", UIPanel, true)

function PageBosslive:ctor()
	PageBosslive.base.ctor(self, "UI/PageBosslive/PageBosslive")
	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_BossLive"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PageBosslive:Cache()
	PageBosslive.base.Cache(self)
end

function PageBosslive:PreLoad()
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
	self:LoadResAsync("UI/PageBosslive/CellBossliveEnum", "cellBossliveEnum")
end

function PageBosslive:Purge()
	PageBosslive.base.Purge(self)

	ChapterMgr.BossLiveTempIndex = 0

	if self.Timer then
		TimerMgr.RemoveTimer(self.Timer)

		self.Timer = nil
	end

	SoundMgr.LoadBank("BGM_0036", false, false)
	SoundMgr.PostEvent("Play_BGM_0036", UIMgr.UICamera.gameObject)
	UnloadAllImageSprite(self)
	ResourceMgr.Unload(self.PrefabCellItem)
	ResourceMgr.Unload(self.cellBossliveEnum)

	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end
end

function PageBosslive:OnBack()
	UIMgr.PopPanel()
end

function PageBosslive:Close()
	PageBosslive.base.Close(self)
end

function PageBosslive:OnRegisterEvent()
	self:AddClick(self.BtnShow, self.OnClickedShowAward)
	self:AddClick(self.btn_close, self.OnClickedCloseAward)
	self:AddClick(self.BtnRecv, self.OnClickedRecvAward)
	self:AddClick(self.BtnOver, self.OnClickedShowAward)
	self:AddClick(self.GoAwardList, self.OnClickedHideAward)
	self:AddClick(self.BtnEnter, self.OnClickedBtnEnter)
	self:AddClick(self.btn_left, self.OnClickedBtnLeft)
	self:AddClick(self.btn_right, self.OnClickedBtnRight)

	for i = 1, 3 do
		self:AddClick(self["TabBtn" .. i], self.OnClickedTabBtn)
	end

	self:AddClick(self.GoAward, self.OnCloseAward)
	Event.Instance:Add("PageBossliveEvent", self.PageBossliveEvent, self)
	Event.Instance:Add("PageBossliveUpdateCurIndex", self.PageBossliveUpdateCurIndex, self)
	Event.Instance:Add("UpdateStageNum", self.PageBossliveEvent, self)
	Event.Instance:Add("OpenShopPanel", self.OnOpenShopPanel, self)
end

function PageBosslive:OnUnRegisterEvent()
	self:RemoveClick(self.BtnShow, self.OnClickedShowAward)
	self:RemoveClick(self.btn_close, self.OnClickedCloseAward)
	self:RemoveClick(self.BtnRecv, self.OnClickedRecvAward)
	self:RemoveClick(self.BtnOver, self.OnClickedShowAward)
	self:RemoveClick(self.GoAwardList, self.OnClickedHideAward)
	self:RemoveClick(self.BtnEnter, self.OnClickedBtnEnter)
	self:RemoveClick(self.btn_left, self.OnClickedBtnLeft)
	self:RemoveClick(self.btn_right, self.OnClickedBtnRight)

	for i = 1, 3 do
		self:AddClick(self["TabBtn" .. i], self.OnClickedTabBtn)
	end

	self:RemoveClick(self.GoAward, self.OnCloseAward)
	Event.Instance:Remove("UpdateStageNum", self.PageBossliveEvent, self)
	Event.Instance:Remove("PageBossliveEvent", self.PageBossliveEvent, self)
	Event.Instance:Remove("PageBossliveUpdateCurIndex", self.PageBossliveUpdateCurIndex, self)
	Event.Instance:Remove("OpenShopPanel", self.OnOpenShopPanel, self)
	EventListenerMgr.RemoveAnimListener(self.StarAchGo, self.EventAnim, self, eAnimEventType.OnAnimationEnd)

	if self.listAward then
		for _, v in pairs(self.listAward) do
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

	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end

		self.listItem = nil
	end
end

function PageBosslive:OnEnter(vParam)
	PersistentStoreUtil.SetBool("BossLiveDot", false)

	self.stageId = vParam
	self.listChapter = {}

	self:DealWithLocalization()
	self:Init()
	self:InitScroll()
end

function PageBosslive:DealWithLocalization()
	return
end

function PageBosslive:UpdateBgSpine(index)
	local spineSkeAssetPath = self.BossliveTbl[index].data.BackSpine .. "_SkeletonData"
	local spineSkeMatPath = self.BossliveTbl[index].data.BackSpine .. "_Material"
	local skeletonDataAssetRef, materialRef = UIUtil.SetSpineSkeletonDataAsset(self.GoSpinePoint, spineSkeAssetPath, spineSkeMatPath, skeletonDataAssetRef, materialRef)

	UIUtil.SetSpineAnimationState(self.GoSpinePoint, "none", true, true)
	DealWithListSpineRef(self, skeletonDataAssetRef)
	DealWithListSpineRef(self, materialRef)
end

function PageBosslive:Init()
	self:DealWithLocalization()

	if not GuideMgr:IsGuided(GuideFunctionType.BossLive) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.BossLive)
	end

	self.img_song = self:GetChildComponent("img_song", "Image")
	self.TxtBossliveStar = self:GetChildComponent("Panel/StarAch/TxtStarCnt", "Text")
	self.BtnShow = self:GetChildGameObject("Panel/StarAch/1")
	self.BtnRecv = self:GetChildGameObject("Panel/StarAch/2")
	self.BtnOver = self:GetChildGameObject("Panel/StarAch/3")
	self.StarAchGo = self:GetChildGameObject("Panel/StarAch")
	self.StarAchAni = self:GetChildComponent("Panel/StarAch", "Animator")

	EventListenerMgr.AddAnimListener(self.StarAchGo, self.EventAnim, self, eAnimEventType.OnAnimationEnd)

	self.img_award = self:GetChildComponent("Panel/StarAch/img_award", "Image")
	self.GoAward = self:GetChildGameObject("Award")
	self.GoGroup = self:GetChildGameObject("Award/Group")
	self.GoAwardList = self:GetChildGameObject("AwardList")
	self.GoAwardGroup = self:GetChildGameObject("AwardList/BgList/Bg/Group")
	self.BtnGuide = self:GetChildGameObject("BtnGuide")
	self.BtnEnter = self:GetChildGameObject("Panel2/BtnEnter")
	self.btn_left = self:GetChildGameObject("Panel2/btn_left")
	self.btn_right = self:GetChildGameObject("Panel2/btn_right")
	self.PanelGo = self:GetChildGameObject("Panel")
	self.btn_close = self:GetChildGameObject("Award/btn_close")
	self.GoSpinePoint = self:GetChildGameObject("Spine")

	local strlist = {
		_("UI_Simple"),
		_("UI_Common"),
		(_("UI_Difficult"))
	}

	for i = 1, 3 do
		self["TabBtn" .. i] = self:GetChildGameObject("Panel2/tab/" .. i .. "/Btn")
		self["TabSel" .. i] = self:GetChildGameObject("Panel2/tab/" .. i .. "/Sel")

		SetActiveFunc(self["TabBtn" .. i], true)
		SetActiveFunc(self["TabSel" .. i], false)

		self["TabBtnTex" .. i] = self:GetChildComponent("Panel2/tab/" .. i .. "/Btn/Text", "Text")
		self["TabSelTex" .. i] = self:GetChildComponent("Panel2/tab/" .. i .. "/Sel/Text", "Text")
		self["TabBtnTex" .. i].text = strlist[i]
		self["TabSelTex" .. i].text = strlist[i]
	end
end

function PageBosslive:DealWithLocalization()
	local Text

	Text = self:GetChildComponent("Panel/img_havenum/Text", "Text")
	Text.text = string.format(Lang(8111005), tostring(InfoGameInst.RefreshTime))
	Text = self:GetChildComponent("Panel2/BtnEnter/Text", "Text")
	Text.text = _("Desc_Raid_Choice")
end

function PageBosslive:InitScroll()
	self.preIndex = 1
	self.BossliveEnumIndex = 1
	self.CurPanel2Index = 1

	self:GetSortBossliveTal()

	self.ScrollArea = self:GetChildGameObject("Panel/ScrollArea")

	local content = self:GetChildComponent("Panel/ScrollArea/Content", "Transform")
	local count = #self.BossliveTbl

	self.BossliveEnumIndex = tonumber(string.split(RoleCardMgr:GetBossLiveCurIndexState(), "_")[1])
	self.CurPanel2Index = tonumber(string.split(RoleCardMgr:GetBossLiveCurIndexState(), "_")[2])

	self:RefreshArrow(self.CurPanel2Index)

	local itemList = {}

	local function AddClick(item)
		self:AddClick(item.UIRootObject, self.OnClickedCellTab)
	end

	local function ListUpdate(item, index)
		local data = {}

		data.info = self.BossliveTbl[index]

		local isUnLock, msg = self:GetTabLockMsg(index)

		data.isUnLock = isUnLock
		data.msg = msg
		item.UIRootObject.transform.localScale = Vector3(1, 1, 1)

		item:UpdateData(data, self.BossliveEnumIndex, index)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(self.ScrollArea, content, count, self.cellBossliveEnum, CellBossliveEnum, self, true, AddClick, ListUpdate)

	if self.BossliveEnumIndex > 10 then
		local pos = Vector2.New(-3680, 0)

		self.UIScrollTool:SetContentPosImmediate(pos, self.BossliveTbl)
	else
		local pos = Vector2.New(-370 * (self.BossliveEnumIndex - 1), 0)

		self.UIScrollTool:SetContentPosImmediate(pos, self.BossliveTbl)
	end

	self:InitGroup(self.BossliveEnumIndex, true)
	self:InitPanel2(self.BossliveEnumIndex)

	self.tabMsgList = {}

	for i = 1, count do
		local isUnLock, msg = self:GetTabLockMsg(i)

		self.tabMsgList[i] = {}
		self.tabMsgList[i].isUnLock = isUnLock
		self.tabMsgList[i].msg = msg
	end
end

function PageBosslive:GetSortBossliveTal()
	local BossliveTbl = ChapterMgr:GetChapterList(ChapterType.bosslive)
	local sortList = {}
	local sortOpenList = {}
	local sortUnOpenList = {}

	for i = 1, #BossliveTbl do
		local infoStage = ChapterMgr:GetStage(BossliveTbl[i].data.StageID[1])
		local isUnLock = infoStage:IsOpen()

		if isUnLock then
			table.insert(sortOpenList, BossliveTbl[i])
		else
			table.insert(sortUnOpenList, BossliveTbl[i])
		end
	end

	local function func(a, b)
		local aInfoStage = ActiveMgr:GetUnlockStage(a.data.StageID[1])
		local bInfoStage = ActiveMgr:GetUnlockStage(b.data.StageID[1])
		local _, ai, aj = ChapterMgr:GetChapterByStageID(aInfoStage.id)
		local _, bi, bj = ChapterMgr:GetChapterByStageID(bInfoStage.id)

		if ai == bi then
			return aj < bj
		else
			return ai < bi
		end
	end

	table.sort(sortOpenList, func)
	table.sort(sortUnOpenList, func)
	table.merge(sortList, sortOpenList)
	table.merge(sortList, sortUnOpenList)

	self.BossliveTbl = sortList
end

function PageBosslive:GetPageBossPlayNum()
	local playNum = 0

	for i = 1, #self.BossliveTbl do
		playNum = playNum + ChapterMgr:GetPlayNum(self.BossliveTbl[i].id)
	end

	return playNum
end

function PageBosslive:OnClickedCellTab(data)
	local go = data.pointerPress
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local Index = tonumber(info.Item.Index)

	if self.BossliveEnumIndex == Index then
		return
	end

	self.preIndex = self.BossliveEnumIndex

	self.StarAchAni:Play("PageBosslive_StarAni")
	SetActiveFunc(self.GoAwardList, false)
	SetActiveFunc(self.GoAward, false)

	self.isShow = false

	self:UpdateBgSpine(Index)

	local strlist = string.split(self.BossliveTbl[Index].data.BackIcon, "_")
	local teamCfg = CharacterTeam[self.BossliveTbl[Index].data.Team]

	UIUtil.SetImageSprite(self.img_song, "UIDyAtlas/Team/IC_IDH_" .. teamCfg.ID .. "00", self, true)

	self.BossliveEnumIndex = Index

	self.UIScrollTool:UpdateListDataKeepPos(self.BossliveTbl)
	self:InitGroup(Index)

	self.CurPanel2Index = 1

	self:InitPanel2(Index)
	self:RefreshArrow(self.CurPanel2Index)
end

function PageBosslive:OnCloseAward()
	if self.isShow then
		SetActiveFunc(self.GoAward, false)

		self.isShow = false
	end

	if self.GoAwardList.activeSelf then
		SetActiveFunc(self.GoAwardList, false)
	end
end

function PageBosslive:OnClickedShowAward()
	if not self.isShow then
		SetActiveFunc(self.GoAward, true)

		self.isShow = true

		return
	end

	SetActiveFunc(self.GoAward, false)
	SetActiveFunc(self.GoAwardList, false)

	self.isShow = false
end

function PageBosslive:OnClickedCloseAward()
	SetActiveFunc(self.GoAward, false)
	SetActiveFunc(self.GoAwardList, false)

	self.isShow = false
end

function PageBosslive:OnClickedRecvAward()
	if self.isShow then
		SetActiveFunc(self.GoAward, false)
		SetActiveFunc(self.GoAwardList, false)

		self.isShow = false

		return
	end

	SetActiveFunc(self.GoAward, true)

	self.isShow = true
end

function PageBosslive:OnClickedHideAward()
	SetActiveFunc(self.GoAwardList, false)
end

function PageBosslive:OnClickedBtnEnter()
	local unLockMsg = ""

	if PlayerInst:GetCurLv() < ChapterMgr:GetStage(self.bossLiveStageID).data.LevelUnlock then
		unLockMsg = " " .. string.format(_("Msg_UnlockTeamPosition"), ChapterMgr:GetStage(self.bossLiveStageID).data.LevelUnlock)
	end

	if not self.tabMsgList[self.BossliveEnumIndex].isUnLock then
		if self.CurPanel2Index == 1 then
			UIMgr.ShowMsg(self.tabMsgList[self.BossliveEnumIndex].msg)

			return
		end

		if self.CurPanel2Index == 2 then
			if not self.listStage:IsOpen() then
				UIMgr.ShowMsg(string.format(_("Msg_Difficulty_Pass"), _("UI_Simple")) .. unLockMsg)

				return
			end
		elseif self.CurPanel2Index == 3 and not self.listStage:IsOpen() then
			UIMgr.ShowMsg(string.format(_("Msg_Difficulty_Pass"), _("UI_Common")) .. unLockMsg)

			return
		end
	elseif self.CurPanel2Index == 2 then
		if not self.listStage:IsOpen() then
			UIMgr.ShowMsg(string.format(_("Msg_Difficulty_Pass"), _("UI_Simple")) .. unLockMsg)

			return
		end
	elseif self.CurPanel2Index == 3 and not self.listStage:IsOpen() then
		UIMgr.ShowMsg(string.format(_("Msg_Difficulty_Pass"), _("UI_Common")) .. unLockMsg)

		return
	end

	if PlayerInst:GetCurLv() < ChapterMgr:GetStage(self.bossLiveStageID).data.LevelUnlock then
		UIMgr.ShowMsg(unLockMsg)

		return
	end

	ChapterMgr.PageCombatReadinessType = 1

	UIMgr.AddPanel(PageCombatReadiness(), {
		stageId = self.bossLiveStageID,
		bossliveCurIndex = self.CurPanel2Index
	})
end

function PageBosslive:OnClickedBtnLeft()
	self.CurPanel2Index = self.CurPanel2Index - 1

	if self.CurPanel2Index < 1 then
		self.CurPanel2Index = 1
	end

	self:InitPanel2(self.BossliveEnumIndex)
	self:RefreshArrow(self.CurPanel2Index)
end

function PageBosslive:OnClickedTabBtn(data)
	local goCell = data.pointerPress.transform.parent.gameObject
	local cellIdx = tonumber(goCell.name)

	self.CurPanel2Index = cellIdx

	for i = 1, 3 do
		SetActiveFunc(self["TabBtn" .. i], i ~= self.CurPanel2Index)
		SetActiveFunc(self["TabSel" .. i], i == self.CurPanel2Index)
	end

	self:InitPanel2(self.BossliveEnumIndex)
end

function PageBosslive:OnClickedBtnRight()
	self.CurPanel2Index = self.CurPanel2Index + 1

	if self.CurPanel2Index > 3 then
		self.CurPanel2Index = 3
	end

	self:InitPanel2(self.BossliveEnumIndex)
	self:RefreshArrow(self.CurPanel2Index)
end

function PageBosslive:RefreshArrow(CurPanel2Index)
	return
end

function PageBosslive:ResponseGetChapterAward(msg)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if msg.result.code == 0 then
		for i = 1, #self.awardListIndexs do
			self.infoChapter.pb.awardStatus[self.awardListIndexs[i] + 1] = 1
		end

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

		GOUtil.DestroyAllChildren(self.GoAwardGroup)

		local listItem = list[awardIdx].items

		if not self.listCell then
			self.listCell = {}
		end

		for i = 1, #listItem do
			local infoItem = listItem[i]
			local item = CellItem(self.PrefabCellItem, self.GoAwardGroup, self)

			item:Create()
			item:UpdateWithNumType(infoItem)
			table.insert(self.listCell, item)
		end

		SetActiveFunc(self.GoAwardList, true)

		local goCellPos = self.listAward["" .. self.awardListIdx][self.curAwardIdx].transform.position

		self.GoAwardList.transform.position = Vector3.New(goCellPos.x, goCellPos.y + 1.56, goCellPos.z)

		local Bg = self:GetChildGameObject("AwardList/BgList/Bg")
		local Group = self:GetChildGameObject("AwardList/BgList/Bg/Group")

		GOUtil.SetRectTransformSizeDelta(Bg, 167 * #listItem, 200)
		GOUtil.SetRectTransformSizeDelta(Group, 154 * #listItem, 136)
	end
end

function PageBosslive:PageBossliveEvent()
	self:GetChildComponent("Panel/img_havenum/tex_havenum", "Text").text = _("Desc_Last_Num") .. BossliveChapterMgr.GetBossliveRemainingChallengeNum()
end

function PageBosslive:PageBossliveUpdateCurIndex(CurPanel2Index)
	self.CurPanel2Index = CurPanel2Index

	self:InitPanel2(self.BossliveEnumIndex)
	self:RefreshArrow(self.CurPanel2Index)
end

function PageBosslive:GetTabLockMsg(Index)
	self:GetChildComponent("Panel/img_havenum/tex_havenum", "Text").text = _("Desc_Last_Num") .. BossliveChapterMgr.GetBossliveRemainingChallengeNum()

	local allStarCnt = self.infoChapter:GetAllStar()
	local curStarCnt = self.infoChapter:GetStar()

	for i = 1, 3 do
		local infoStage = ChapterMgr:GetStage(self.BossliveTbl[Index].data.StageID[i])
		local stageIdx = 3
		local data = {
			infoStage = infoStage,
			index = stageIdx
		}

		if i == 1 then
			local isOpen, msg = ActiveMgr:IsBossStageUnlock(infoStage.data.ID)
			local isUnLock = infoStage:IsOpen()

			return isUnLock, msg
		end
	end
end

function PageBosslive:InitPanel2(Index)
	self.infoChapter = ChapterMgr:GetChapter(self.BossliveTbl[Index].data.ID)
	self:GetChildComponent("Panel/img_havenum/tex_havenum", "Text").text = _("Desc_Last_Num") .. BossliveChapterMgr.GetBossliveRemainingChallengeNum()

	local allStarCnt = self.infoChapter:GetAllStar()
	local curStarCnt = self.infoChapter:GetStar()

	self.TxtBossliveStar.text = curStarCnt .. "/" .. allStarCnt
	self.curStar = curStarCnt
	self.listStage = ChapterMgr:GetStage(self.BossliveTbl[Index].data.StageID[self.CurPanel2Index])
	self.bossLiveStageID = self.listStage.data.ID

	local infoStage = self.listStage
	local stageIdx = 3
	local data = {
		infoStage = infoStage,
		index = stageIdx
	}
	local isOpen, msg = ActiveMgr:IsBossStageUnlock(infoStage.data.ID)
	local isUnLock = infoStage:IsOpen()
	local isFull = PlayerInst:GetCurLv() >= infoStage.data.LevelUnlock
	local gray = TenaryOp(isUnLock and isFull, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self:GetChildComponent("Panel2/BtnEnter/Image", "Image"), gray))

	local starCount = infoStage:GetStar()

	for n = 1, 3 do
		SetActiveFunc(self:GetChildGameObject("Panel2/Star/Image" .. n), starCount < n)
		SetActiveFunc(self:GetChildGameObject("Panel2/Star/Star" .. n), n <= starCount)
	end

	local isNoNum = false
	local listAward = {}
	local listAwardFirst = {}
	local txtTitle = Lang(5000007)
	local isNew = infoStage:IsNew()
	local isFirst = false

	listAward = infoStage.data.ItemList

	if not isUnLock or isNew then
		listAwardFirst = infoStage.data.FirstAward
		isFirst = true
	elseif stageType == 2 then
		listAwardFirst = infoStage.data.FirstAward
		isFirst = true
	else
		txtTitle = Lang(12488)
		isNoNum = true
	end

	if self.listItem and #self.listItem ~= 0 then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end

		GOUtil.DestroyAllChildren(self:GetChildGameObject("Panel2/ScrollArea/Content"))

		self.listItem = nil
	end

	if not self.listItem then
		self.listItem = {}

		local gItem = self:GetChildGameObject("Panel2/gItem")
		local Content = self:GetChildGameObject("Panel2/ScrollArea/Content")

		SetActiveFunc(gItem, true)

		for i = 1, #listAward + #listAwardFirst do
			local gItem = GOUtil.Instantiate(gItem, Content)
			local item = CellItem(gItem)

			item:InitItemByRoot(gItem)

			gItem.name = i
			gItem.transform.localScale = Vector3(0.85, 0.85, 1)

			table.insert(self.listItem, item)
		end

		SetActiveFunc(gItem, false)
	end

	if #listAwardFirst > 0 then
		for i = 1, #listAwardFirst do
			local item = self.listItem[i]
			local award = listAwardFirst[i]

			if award and award[1] then
				local infoItem = ItemManager:GetValueItem(award[1], award[2])

				item:UpdateWithNumType(infoItem)
				item:SetFirstPass(true)
				item:SetGeted(stageType == StageFromType.story and not isNew and isUnlock)
				item:SetGray(num == 1)
			end
		end
	end

	for n = 1 + #listAwardFirst, #self.listItem do
		local item = self.listItem[n]
		local award = listAward[n - #listAwardFirst]

		if award and award[1] then
			local infoItem = ItemManager:GetValueItem(award[1], award[2])

			if award[3] then
				item:UpdateWithNumType(infoItem, nil, award[3])
			else
				item:UpdateWithNumType(infoItem)
			end

			item:SetGeted(stageType == 2 and not isNew and isUnLock and isFull)
			item:SetGray(num == 1)
		end
	end

	local value = #listAward + #listAwardFirst

	GOUtil.SetRectTransformSizeDelta(self:GetChildGameObject("Panel2/ScrollArea/Content"), value * 128, 128)
	GOUtil.SetRectTransformAnchoredPosition(self:GetChildGameObject("Panel2/ScrollArea/Content"), 0, 0)

	local strlist = {
		_("UI_Simple"),
		_("UI_Common"),
		(_("UI_Difficult"))
	}

	for i = 1, 3 do
		SetActiveFunc(self["TabBtn" .. i], i ~= self.CurPanel2Index)
		SetActiveFunc(self["TabSel" .. i], i == self.CurPanel2Index)
	end

	self:GetChildComponent("Panel2/tex_type", "Text").text = strlist[self.CurPanel2Index]
end

function PageBosslive:GetBankBGM(isUnFirst)
	self:GetSortBossliveTal()

	if ChapterMgr.BossLiveTempIndex == 0 then
		ChapterMgr.BossLiveTempIndex = tonumber(string.split(RoleCardMgr:GetBossLiveCurIndexState(), "_")[1])

		return self.BossliveTbl[ChapterMgr.BossLiveTempIndex].data.BossLiveBGMBank, self.BossliveTbl[ChapterMgr.BossLiveTempIndex].data.BossLiveBGMEvent
	else
		return self.BossliveTbl[ChapterMgr.BossLiveTempIndex].data.BossLiveBGMBank, self.BossliveTbl[ChapterMgr.BossLiveTempIndex].data.BossLiveBGMEvent
	end
end

function PageBosslive:InitGroup(Index, isfirst)
	local strlist = string.split(self.BossliveTbl[Index].data.BackIcon, "_")

	self:UpdateBgSpine(Index)

	local teamCfg = CharacterTeam[self.BossliveTbl[Index].data.Team]

	UIUtil.SetImageOverrideSprite(self.img_song, "UIDyAtlas/Team/IC_IDH_" .. teamCfg.ID .. "00", self, true)

	if isfirst then
		if ChapterMgr.BossLiveToTeam ~= 1 then
			self.Timer = TimerMgr.AddTimer(eTimerType.RealTime, 0, function()
				return
			end, {})
		else
			ChapterMgr.BossLiveToTeam = 0
		end
	elseif ChapterMgr.BossLiveToTeam ~= 1 then
		ChapterMgr.BossLiveTempIndex = Index

		InfoBGMEventMgr:LoadBank("PageBosslive")
	else
		ChapterMgr.BossLiveToTeam = 0
	end

	self.infoChapter = ChapterMgr:GetChapter(self.BossliveTbl[Index].data.ID)
	self:GetChildComponent("Panel/img_havenum/tex_havenum", "Text").text = _("Desc_Last_Num") .. BossliveChapterMgr.GetBossliveRemainingChallengeNum()

	local allStarCnt = self.infoChapter:GetAllStar()
	local curStarCnt = self.infoChapter:GetStar()

	self.TxtBossliveStar.text = curStarCnt .. "/" .. allStarCnt
	self.curStar = curStarCnt

	if isfirst then
		local infoChapter = ChapterMgr:GetChapter(self.BossliveTbl[Index].data.ID)

		table.insert(self.listChapter, infoChapter)
		self:InitAward()
		self:UpdateAward()
	else
		self.listChapter = {}

		local infoChapter = ChapterMgr:GetChapter(self.BossliveTbl[Index].data.ID)

		table.insert(self.listChapter, infoChapter)
		self:InitAward()
	end
end

function PageBosslive:InitAward()
	local content = self:GetChildGameObject("Award/ScrollArea/Content")

	GOUtil.DestroyAllChildren(content)

	local cell = self:GetChildGameObject("Award/Cell")
	local award = self:GetChildGameObject("Award/CellAward")

	SetActiveFunc(cell, true)
	SetActiveFunc(award, true)

	self.listAward = {}
	self.listCellItem = {}
	self.listOneKey = {}

	for i = 1, #self.listChapter do
		local goCell = GOUtil.Instantiate(cell, content)
		local infoChapter = self.listChapter[i]
		local isOpen = infoChapter:IsOpen()
		local goStar = GOUtil.FindChildGameObject(goCell, "Star/GoStar")
		local goFrame = GOUtil.FindChildGameObject(goCell, "Star/GoFrame")

		SetActiveFunc(goStar, isOpen)
		SetActiveFunc(goFrame, not isOpen)

		local txtTitle = GOUtil.FindChildComponent(goCell, "Title/Text", "Text")

		txtTitle.text = Lang(infoChapter.data.Name)
		txtTitle.color = Color.New(1, 1, 1, 1)

		local txtStarNum = GOUtil.FindChildComponent(goCell, "Star/TxtStarNum", "Text")

		txtStarNum.text = infoChapter:GetStar() .. "/" .. infoChapter:GetAllStar()

		local goOneKey = GOUtil.FindChildGameObject(goCell, "btn_onekey")

		self:AddClick(goOneKey, self.OnClickOneKey)
		table.insert(self.listOneKey, goOneKey)

		local isOneKey = false

		self.listAward["" .. i] = {}
		self.listCellItem["" .. i] = {}

		local awardgroup = GOUtil.FindChildGameObject(goCell, "Group")
		local list, curIdx = infoChapter:GetChapterAwardList()

		for j = 1, #list do
			local goAward = GOUtil.Instantiate(award, awardgroup)
			local isRecv = list[j].state == 1
			local isCanRecv = infoChapter:GetStar() >= list[j].star
			local goNew = GOUtil.FindChildGameObject(goAward, "GoNew")

			SetActiveFunc(goNew, not isRecv and isCanRecv)

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
				UIUtil.SetImageSprite(img_state, "UI/PageBosslive/bossliveAtlas/BG_reward_star_line_01", self)
			else
				UIUtil.SetImageSprite(img_state, "UI/PageBosslive/bossliveAtlas/BG_reward_star_line_02", self)
			end

			local img_state2 = GOUtil.FindChildComponent(goAward, "img_state/img_state2", "Image")

			if isRecv then
				UIUtil.SetImageSprite(img_state2, "UI/PageBosslive/bossliveAtlas/BG_reward_star_dot_01", self)
			else
				UIUtil.SetImageSprite(img_state2, "UI/PageBosslive/bossliveAtlas/BG_reward_star_dot_02", self)
			end

			goAward.name = j

			local gCellItem = GOUtil.FindChildGameObject(goAward, "CellItem")
			local cellItem = CellItem(gCellItem)

			cellItem:InitItemByRoot(gCellItem)
			cellItem:UpdateWithNumType(list[j].items[1])
			self:AddClick(goAward, self.OnClickGoAward)
			table.insert(self.listAward["" .. i], goAward)
			table.insert(self.listCellItem["" .. i], cellItem)

			if not isRecv and isCanRecv then
				isOneKey = true
			end
		end

		goCell.name = i

		local gray = TenaryOp(isOneKey, 0, 1)
		local img_onekey = GOUtil.GetComponent(self.listOneKey[i], "Image")

		DealWithListRef(self, UIUtil.SetImageGray(img_onekey, gray))
	end

	SetActiveFunc(cell, false)
	SetActiveFunc(award, false)
end

function PageBosslive:UpdateAward()
	RedDotSystemMgr.SetUIRedDot(self.StarAchGo, string.format("Chapter/BossLive/Award/%d", self.infoChapter.id))

	local list, curIndex = self.infoChapter:GetChapterAwardList()

	self.curAwardIdx = curIndex

	SetActiveFunc(self.BtnShow, false)
	SetActiveFunc(self.BtnRecv, false)
	SetActiveFunc(self.BtnOver, false)
	UIUtil.SetImageSprite(self.img_award, "UI/PageBosslive/bossliveAtlas/IC_stage_box_01", self)

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

			if not isRecv and isCanRecv then
				UIUtil.SetImageSprite(self.img_award, "UI/PageBosslive/bossliveAtlas/IC_stage_box_03", self)
			end

			local img_state = GOUtil.FindChildComponent(go, "img_state", "Image")

			if isRecv then
				UIUtil.SetImageSprite(img_state, "UI/PageBosslive/bossliveAtlas/BG_reward_star_line_01", self)
			else
				UIUtil.SetImageSprite(img_state, "UI/PageBosslive/bossliveAtlas/BG_reward_star_line_02", self)
			end

			local img_state2 = GOUtil.FindChildComponent(go, "img_state/img_state2", "Image")

			if isRecv then
				UIUtil.SetImageSprite(img_state2, "UI/PageBosslive/bossliveAtlas/BG_reward_star_dot_01", self)
			else
				UIUtil.SetImageSprite(img_state2, "UI/PageBosslive/bossliveAtlas/BG_reward_star_dot_02", self)
			end

			SetActiveFunc(goNew, not isRecv and isCanRecv)
			SetActiveFunc(goRecv, isRecv)
			SetActiveFunc(goStar, isCanRecv)
			SetActiveFunc(goFrame, not isCanRecv)

			if not isRecv and isCanRecv then
				isOneKey = true
			end
		end

		local gray = TenaryOp(isOneKey, 0, 1)
		local img_onekey = GOUtil.GetComponent(self.listOneKey[i], "Image")

		DealWithListRef(self, UIUtil.SetImageGray(img_onekey, gray))
	end
end

function PageBosslive:OnClickGoAward(data)
	local goCell = data.pointerPress.transform
	local cellIdx = tonumber(goCell.name)
	local awardListIdx = tonumber(data.pointerPress.transform.parent.parent.name)

	LoadingMgr.Show(eLoadingType.Repeat)

	local function wrap_cb(pb)
		self:ResponseGetChapterAward(pb)
	end

	self.curAwardIdx = cellIdx
	self.awardListIdx = awardListIdx
	self.awardListIndexs = {}

	table.insert(self.awardListIndexs, cellIdx - 1)
	NetManager:RequestGetChapterAward(self.infoChapter.id, self.awardListIndexs, wrap_cb)
end

function PageBosslive:OnClickOneKey(data)
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

function PageBosslive:EventAnim()
	self.StarAchAni:Play("Empty")
	self:UpdateAward()
end

function PageBosslive:OnClickedGuideBtn()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.BossLive)
end

function PageBosslive:OnOpenShopPanel(isOpen)
	if isOpen == true then
		SoundMgr.LoadBank("BGM_0036", false, false)
		SoundMgr.PostEvent("Play_BGM_0036", UIMgr.UICamera.gameObject)
	else
		SoundMgr.PostEvent(InfoBGMEventMgr.BGM.PageBosslive, UIMgr.UICamera.gameObject)
	end
end

function PageBosslive:OnBackAndroid()
	if self.isShow then
		self:OnCloseAward()

		return true
	end

	return false
end
