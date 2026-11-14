-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PagePass/CellCommonStage.lua

require("UI/Item/UIItemBase")
require("UI/Page/PageCombatReadiness/PageCombatReadiness")

CellCommonStage = class("CellCommonStage", UIItemBase)

function CellCommonStage:ctor(itemPrefabCache, parent, ownerUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellCommonStage:Create(vParam)
	CellCommonStage.base.Create(self, vParam)
end

function CellCommonStage:OnEnter()
	local g = self.UIRootObject

	self.AnimRoot = GOUtil.GetComponent(g, "Animator")

	EventListenerMgr.AddAnimListener(self.UIRootObject, self.EventAnim, self, eAnimEventType.OnAnimationEnd)

	for i = 1, 3 do
		self["Stage" .. i] = GOUtil.FindChildGameObject(g, "" .. i)
		self["GoInfo" .. i] = GOUtil.FindChildGameObject(g, "" .. i .. "/ImgType")

		self:AddClick(self["GoInfo" .. i], self.OnClickedBtnInfo)

		self["GoFrame" .. i] = GOUtil.FindChildGameObject(g, "Panel/Star/Image" .. i)
		self["GoStar" .. i] = GOUtil.FindChildGameObject(g, "Panel/Star/Star" .. i)
	end

	self.listItem = {}
	self.ScrollRect = self:GetChildComponent("Panel/Award/ScrollArea", "UIScrollView")
	self.ImgStory = self:GetChildComponent("2/ImgStory", "Image")
	self.TxtStageName = GOUtil.FindChildComponent(g, "Panel/TxtName", "Text")
	self.TxtRecomLv = GOUtil.FindChildComponent(g, "Panel/TxtLevel", "Text")
	self.TxtPlayNum = GOUtil.FindChildComponent(g, "Panel/Award/BgNum/Text", "Text")
	self.TxtAwardType = GOUtil.FindChildComponent(g, "Panel/Award/BgType/Text", "Text")
	self.BtnEnter = GOUtil.FindChildGameObject(g, "Panel/BtnEnter")

	self:AddClick(self.BtnEnter, self.OnClickedBtnEnter)

	self.GoNew = GOUtil.FindChildGameObject(g, "Panel/GoNew")
	self.fx_ui_GoNew = self:GetChildGameObject("Panel/GoNew/fx_ui_GoNew")
	self.GoLock = GOUtil.FindChildGameObject(g, "Lock")
	self.TxtLock = GOUtil.FindChildComponent(g, "Lock/Text", "Text")
	self.TxtLockBg = GOUtil.FindChildGameObject(g, "Lock/Line")

	self:AddClick(self.GoLock, self.OnClickedGoLock)

	self.NotGet = GOUtil.FindChildGameObject(g, "Panel/NotGet")
	self.IsGet = GOUtil.FindChildGameObject(g, "Panel/IsGet")

	self:AddClick(self.NotGet, self.OnClickedNotGet)

	local text = GOUtil.FindChildComponent(g, "Panel/NotGet/Text", "Text")

	text.text = _("Story_AwardNotGet")
	text = GOUtil.FindChildComponent(g, "Panel/IsGet/Text", "Text")
	text.text = _("Story_AwardGet")
	self.btn_add = self:GetChildGameObject("Panel/btn_add")

	self:AddClick(self.btn_add, self.OnClickedAddLeftNum)

	self.GoStarGroup = GOUtil.FindChildGameObject(g, "Panel/Star")
	self.GoPlayNum = GOUtil.FindChildGameObject(g, "Panel/Award/BgNum")
end

function CellCommonStage:OnLeave()
	self.AnimRoot = nil

	EventListenerMgr.RemoveAnimListener(self.UIRootObject, self.EventAnim, self, eAnimEventType.OnAnimationEnd)

	for i = 1, #self.listItem do
		self.listItem[i]:OnLeave()
		self:RemoveClick(self["GoInfo" .. i], self.OnClickedBtnInfo)
	end

	self:RemoveClick(self.BtnEnter, self.OnClickedBtnEnter)
	self:RemoveClick(self.GoLock, self.OnClickedGoLock)
	self:RemoveClick(self.btn_add, self.OnClickedAddLeftNum)
	UnloadAllImageSprite(self)
end

function CellCommonStage:OnClickedAddLeftNum()
	return
end

function CellCommonStage:DestroyContent()
	if #self.listItem ~= 0 then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
			self:RemoveClick(self["GoInfo" .. i], self.OnClickedBtnInfo)
		end

		GOUtil.DestroyAllChildren(self:GetChildGameObject("Panel/Award/ScrollArea/Content"))

		self.listItem = {}
	end
end

function CellCommonStage:UpdateData(data)
	local infoStage = data.infoStage

	self.info = data.infoStage
	self.needItem = data.needItem

	local chapterType = infoStage.data.ChapterType
	local stageType = infoStage.data.Type

	for i = 1, 3 do
		SetActiveFunc(self["Stage" .. i], i == stageType)
	end

	if stageType == StageFromType.activeCommon then
		SetActiveFunc(self.Stage1, true)
	end

	if chapterType == ChapterFromType.main then
		local chapNum = ChapterMgr:GetChapterIdx(infoStage.data.ChapterID)

		self.TxtStageName.text = chapNum .. "-" .. ChapterMgr:GetStageIndex(infoStage.id) .. " " .. infoStage:GetName()
	elseif chapterType == ChapterFromType.activity and stageType == StageFromType.activeCommon then
		self.TxtStageName.text = infoStage:GetName()
	elseif stageType == StageFromType.activeCommon then
		local chapNum = ChapterMgr:GetChapterIdx(infoStage.data.ChapterID)

		self.TxtStageName.text = ChapterMgr:GetStageIndex(infoStage.id) .. " " .. infoStage:GetName()
	else
		self.TxtStageName.text = infoStage:GetName()
	end

	local isUnlock = infoStage:IsOpen()
	local isNew = infoStage:IsNew()
	local isEnter = PersistentStoreUtil.GetStageEnter(self.info.data.ID)
	local isFull = PlayerInst:GetCurLv() >= infoStage.data.LevelUnlock

	SetActiveFunc(self.GoNew, isNew and not isEnter and isUnlock and isFull)
	SetActiveFunc(self.fx_ui_GoNew, isNew and not isEnter and isUnlock and isFull)
	SetActiveFunc(self.GoStarGroup, stageType ~= StageFromType.story and isUnlock and isFull)

	if self.info.data.Type ~= StageFromType.story and isUnlock and isFull then
		self:SetStar()
	end

	SetActiveFunc(self.TxtRecomLv.gameObject, infoStage.data.SafeLevel ~= 0)

	if infoStage.data.SafeLevel ~= 0 then
		self.TxtRecomLv.text = Lang(12333) .. "LV." .. infoStage.data.SafeLevel
	end

	SetActiveFunc(self.NotGet, false)
	SetActiveFunc(self.IsGet, false)

	if stageType == StageFromType.story then
		GOUtil.SetRectTransformAnchoredPosition(self:GetChildGameObject("Panel/Award"), -157, -20)
		UIUtil.SetImageSprite(self.ImgStory, infoStage.data.StageBgImage, self)

		if ChapterMgr.StoryAwardList[self.info.id] then
			local isGet = true

			for i, v in ipairs(ChapterMgr.StoryAwardList[self.info.id]) do
				if not InfoGameInst:IsGetScenarioReward(v.GroupId) then
					isGet = false

					break
				end
			end

			SetActiveFunc(self.NotGet, not isGet)
			SetActiveFunc(self.IsGet, isGet)
		end
	else
		GOUtil.SetRectTransformAnchoredPosition(self:GetChildGameObject("Panel/Award"), -157, -50)
	end

	SetActiveFunc(self.btn_add, false)
	SetActiveFunc(self.GoPlayNum, stageType ~= StageFromType.story and (chapterType ~= ChapterFromType.activity or stageType ~= StageFromType.common))

	if stageType ~= StageFromType.story and (chapterType ~= ChapterFromType.activity or stageType ~= StageFromType.common) then
		self.TxtPlayNum.color = getColorFromString("5A5A5A")

		if infoStage.data.PlayNum == 0 then
			self.TxtPlayNum.text = Lang(5000009) .. "∞"
		else
			if ChapterMgr:GetStageLeftPlayNumWithLimit(infoStage.id) == 0 then
				self.TxtPlayNum.color = Color.red
			end

			self.TxtPlayNum.text = Lang(5000009) .. infoStage:GetMaxLeftPlayNum() - infoStage.pb.playNum .. "/" .. infoStage:GetMaxLeftPlayNum()
		end
	end

	if chapterType == ChapterFromType.activity and stageType == StageFromType.common then
		local listActive = PassMgr:GetBranchActiveList(3, ActiveMgr.branchId)
		local activeId = listActive[ActiveMgr.TabIndex].ID
		local infoActive = ActiveMgr:GetActive(activeId)
		local singleMaxNum = infoActive:GetMaxArgJson(nil, infoStage.data.ActType)
		local singlePlayNum = ActiveMgr:GetActivePlayNum(activeId)
		local leftNum = singleMaxNum - singlePlayNum

		self.addLeftNumType = infoStage.data.ActType
	elseif chapterType == ChapterFromType.comb then
		local teamId = ChapterMgr:GetChapter(infoStage.data.ChapterID).data.Team
		local leftCount = CombChapterMgr.GetCombRemainingChallengeNum(teamId)

		self.addLeftNumType = 4
		self.TxtPlayNum.text = CombChapterMgr.GetCombRemainingChallengeNum(teamId) .. "/" .. CombChapterMgr.GetSingleLimitChallengeNum(teamId)
	end

	local isNoNum = false
	local listAward = {}
	local listAwardFirst = {}
	local txtTitle = Lang(5000007)

	if isNew or not isUnlock then
		listAwardFirst = infoStage.data.FirstAward
	elseif stageType == StageFromType.story then
		listAwardFirst = infoStage.data.FirstAward
	else
		txtTitle = Lang(12488)
		isNoNum = true
	end

	listAward = infoStage.data.ItemList
	self.TxtAwardType.text = txtTitle

	if #self.listItem == 0 then
		local gItem = self:GetChildGameObject("Panel/Award/gCell")
		local Content = self:GetChildGameObject("Panel/Award/ScrollArea/Content")

		GOUtil.SetRectTransformAnchoredPosition(Content, 0, 0)
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
				item:SetFirstPass(not infoStage:IsPass())
				item:SetGeted(stageType == StageFromType.story and not isNew and isUnlock)
			end
		end
	end

	for i = 1 + #listAwardFirst, #self.listItem do
		local item = self.listItem[i]
		local award = listAward[i - #listAwardFirst]

		if award and award[1] then
			local infoItem = ItemManager:GetValueItem(award[1], award[2])

			if isNoNum == false then
				if award[3] then
					item:UpdateWithNumType(infoItem, nil, award[3])
				else
					item:UpdateWithNumType(infoItem)
				end
			elseif award[3] then
				item:UpdateWithNumType(infoItem, nil, award[3])
			else
				item:UpdateWithNumType(infoItem)
			end

			item:SetGeted(stageType == StageFromType.story and not isNew and isUnlock)
		end
	end

	local value = #listAward + #listAwardFirst

	GOUtil.SetRectTransformSizeDelta(self:GetChildGameObject("Panel/Award/ScrollArea/Content"), value * 128, 128)

	if value >= 4 then
		value = 3.5
	end

	self.ScrollRect.horizontal = TenaryOp(value > 3, true, false)

	GOUtil.SetRectTransformSizeDelta(self:GetChildGameObject("Panel/Award/Image"), value * 128, 128)
	self:SetLockInfo()
end

function CellCommonStage:SetLockInfo()
	local isUnlock = self.info:IsOpen()
	local isFull = PlayerInst:GetCurLv() >= self.info.data.LevelUnlock

	SetActiveFunc(self.GoLock, not isUnlock or not isFull)

	if self.info.data.Type == StageFromType.story and self.info.data.ChapterType == ChapterFromType.activity then
		SetActiveFunc(self.TxtLock.gameObject, not isUnlock)
		SetActiveFunc(self.TxtLockBg.gameObject, not isUnlock)

		if not isUnlock then
			local unlockInfo = ActiveMgr:GetUnlockStoryStage(self.info.id)
			local infoChapter = ChapterMgr:GetChapter(unlockInfo.data.ChapterID)

			if unlockInfo.data.Type == StageFromType.activeCommon then
				self.TxtLock.text = string.format(_("Dance_LockHint"), " " .. _("Desc_ActiveCommon") .. "-" .. Lang(unlockInfo.data.Name) .. " ")
			else
				self.TxtLock.text = string.format(_("Dance_LockHint"), " " .. Lang(infoChapter.data.Name) .. "-" .. Lang(unlockInfo.data.Name) .. " ")
			end
		end

		SetActiveFunc(self.BtnEnter, isUnlock and isFull)
	else
		SetActiveFunc(self.TxtLock.gameObject, isUnlock and not isFull)
		SetActiveFunc(self.TxtLockBg.gameObject, isUnlock and not isFull)

		if isUnlock and not isFull then
			self.TxtLock.text = string.format(_("Msg_UnlockTeamPosition"), self.info.data.LevelUnlock)
		end
	end

	SetActiveFunc(self.BtnEnter, isUnlock and isFull)
end

function CellCommonStage:SetStar()
	local starCount = self.info:GetStar()

	for i = 1, 3 do
		SetActiveFunc(self["GoFrame" .. i], starCount < i)
		SetActiveFunc(self["GoStar" .. i], i <= starCount)
	end

	local isUnlock = self.info:IsOpen()
	local isFull = PlayerInst:GetCurLv() >= self.info.data.LevelUnlock

	SetActiveFunc(self:GetChildGameObject("Panel/FullStar"), starCount == 3 and not isUnlock and not isFull)
end

function CellCommonStage:OnClickedGoLock()
	if not self.info:IsOpen() then
		if self.info.data.Type == StageFromType.story and self.info.data.ChapterType == ChapterFromType.activity then
			local unlockInfo = ActiveMgr:GetUnlockStoryStage(self.info.id)
			local infoChapter = ChapterMgr:GetChapter(unlockInfo.data.ChapterID)

			if unlockInfo.data.Type == StageFromType.activeCommon then
				UIMgr.ShowMsg(string.format(_("Dance_LockHint"), " " .. _("Desc_ActiveCommon") .. "-" .. Lang(unlockInfo.data.Name) .. " "))
			else
				UIMgr.ShowMsg(string.format(_("Dance_LockHint"), " " .. Lang(infoChapter.data.Name) .. "-" .. Lang(unlockInfo.data.Name) .. " "))
			end
		else
			UIMgr.ShowMsg(Lang(5000004))
		end

		return
	end

	if PlayerInst:GetCurLv() < self.info.data.LevelUnlock then
		UIMgr.ShowMsg(string.format(_("Msg_UnlockTeamPosition"), self.info.data.LevelUnlock))
	end
end

function CellCommonStage:OnClickedNotGet()
	require("UI/Page/PagePass/DlgStoryAwardShow")
	UIMgr.AddPanel(DlgStoryAwardShow(), {
		stageId = self.info.data.ID
	})
end

function CellCommonStage:OnClickedBtnEnter()
	local chapterType = self.info.data.ChapterType

	if chapterType == ChapterFromType.activity and self.info.data.Type ~= StageFromType.story then
		local infoActive = ActiveMgr:GetActiveInfoByStageData(self.info.data)
		local isCanPlay, msg = infoActive:IsPlayOpen()

		if not isCanPlay then
			UIMgr.ShowMsg(msg)

			return
		end
	end

	if self.info.data.Type == StageFromType.story then
		PersistentStoreUtil.SetStageEnter(self.info.data.ID, true)

		ChapterMgr.PageCombatReadinessType = 1

		local function cb(...)
			if self.page then
				self.page:Purge()
			end
		end

		require("UI/Page/PagePass/PageStage")
		PageStage.RequestStartStage(self.info, "MainStage", cb)
	else
		ChapterMgr.PageCombatReadinessType = 1

		UIMgr.AddPanel(PageCombatReadiness(), {
			stageId = self.info.id,
			needItem = self.needItem
		})

		if self.page and self.page.CloseSelf then
			self.page:CloseSelf()
		end
	end
end

function CellCommonStage:EventAnim()
	return
end
