-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageChapter/CellChapter.lua

require("UI/Item/UIItemBase")

CellChapter = class("CellChapter", UIItemBase)

function CellChapter:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = ownerUI
end

function CellChapter:Create(vParam)
	CellChapter.base.Create(self, vParam)
end

function CellChapter:OnEnter()
	local g = self.UIRootObject
	local TextRate = GOUtil.FindChildComponent(g, "Cell/txt_rate", "Text")

	TextRate.text = _("PageChpater_rate")
	TextRate = GOUtil.FindChildComponent(g, "Cell/Btn/Text", "Text")
	TextRate.text = _("UI_Go")
	self.AnimRoot = GOUtil.GetComponent(g, "Animator")
	self.AnimCellRoot = GOUtil.FindChildComponent(g, "Cell", "Animator")
	self.Point = GOUtil.FindChildGameObject(g, "Point")
	self.ChapterIcon = GOUtil.FindChildComponent(g, "Cell/btn_chapIcon", "Image")
	self.txt_chapNumGo = self:GetChildGameObject("Cell/ChapterNum/txt_chapNum")
	self.ChapterNum = GOUtil.FindChildComponent(g, "Cell/ChapterNum/txt_chapNum", "Text")
	self.ChapterName = GOUtil.FindChildComponent(g, "Cell/txt_chapName", "Text")
	self.StarValue = GOUtil.FindChildComponent(g, "Cell/txt_starValue", "Text")
	self.RateValue = GOUtil.FindChildComponent(g, "Cell/txt_rateValue", "Text")
	self.RateText = GOUtil.FindChildComponent(g, "Cell/txt_rate", "Text")
	self.LockStarOn = self:GetChildGameObject("Btn_Node/Lock/Lock1/LockStarOn")
	self.LockStarOff = self:GetChildGameObject("Btn_Node/Lock/Lock1/LockStarOff")
	self.awardList = {}
	self.awardListImage = {}
	self.awardListText = {}

	for i = 1, 5 do
		self.awardList[i] = self:GetChildComponent("Cell/group/" .. i, "Transform")
		self.awardListImage[i] = self:GetChildComponent("Cell/group/" .. i .. "/2/Icon", "Image")
		self.awardListText[i] = self:GetChildComponent("Cell/group/" .. i .. "/2/BgTxt/Text", "Text")
	end

	self.listRef = {}
	self.Btn = self:GetChildGameObject("Cell/Btn")
	self.Btn_Node = self:GetChildGameObject("Btn_Node")
	self.Lock = self:GetChildGameObject("Btn_Node/Lock")
	self.UnLock = self:GetChildGameObject("Btn_Node/UnLock")
	self.tex_level = self:GetChildComponent("Btn_Node/Lock/Lock1/tex_level", "Text")
	self.Tex_0 = self:GetChildComponent("Btn_Node/Lock/Lock1/Tex_0", "Text")
	self.un_tex_level = self:GetChildComponent("Btn_Node/UnLock/tex_level", "Text")
	self.Lock1 = self:GetChildComponent("Btn_Node/Lock/Lock1", "Image")
	self.img_chapNum = self:GetChildGameObject("Cell/ChapterNum/img_chapNum")
	self.tex_levelGo = self:GetChildGameObject("Btn_Node/Lock/Lock1/Text")
	self.Cell = self:GetChildGameObject("Cell")
	self.IsCell = false

	self:AddClick(self.ChapterIcon.gameObject, self.OnClickedEnter)
	self:AddClick(self.Btn, self.OnClickedEnter)
	self:AddClick(self.Btn_Node, self.OnClickedNode)

	self:GetChildComponent("Btn_Node/Lock/Lock1/Text", "Text").fontSize = 24
	self.tex_level.fontSize = 68
	self.Tex_0.fontSize = 43
	self:GetChildComponent("Btn_Node/UnLock/Text", "Text").fontSize = 24
	self.un_tex_level.fontSize = 68
end

function CellChapter:OnLeave()
	self.AnimRoot = nil
	self.Point = nil
	self.ChapterNum = nil
	self.ChapterName = nil
	self.StarValue = nil
	self.RateValue = nil

	if self.Timer then
		TimerMgr.RemoveTimer(self.Timer)

		self.Timer = nil
	end

	self:RemoveClick(self.ChapterIcon.gameObject, self.OnClickedEnter)
	self:RemoveClick(self.Btn, self.OnClickedEnter)
	self:RemoveClick(self.Btn_Node, self.OnClickedNode)
	UnloadAllImageSprite(self)
	EffectMgr:UnLoadEffect("Fx/UI/FX_UI_003/FX_UI_003")
end

function CellChapter:OnClickedEnter()
	local infoChapter = self.info
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

function CellChapter:OnClickedNode()
	local infoChapter = self.info
	local curChapter = self.curChapter

	if not infoChapter:IsOpen() then
		if curChapter.data.ID == 100 then
			UIMgr.ShowMsg(Lang(12902))
		else
			UIMgr.ShowMsg(string.format(Lang(26000611), tostring(tonumber(curChapter.data.ID) % 100)))
		end

		return
	end

	Event.Instance:Fire("UpdateCellChapterActive")

	if self.IsCell then
		SetActiveFunc(self.Cell, false)
		self.AnimCellRoot:Play("Empty")

		self.IsCell = false
	else
		SetActiveFunc(self.Cell, true)
		self.AnimCellRoot:Play("CellChapter_Cell_Open")

		self.IsCell = true
	end
end

function CellChapter:NodeEvent()
	if self.IsCell then
		SetActiveFunc(self.Cell, false)
		self.AnimCellRoot:Play("Empty")

		self.IsCell = false
	end
end

function CellChapter:UpdateActive()
	SetActiveFunc(self.Cell, false)

	self.IsCell = false
end

function CellChapter:UpdateData(data, index, curChapter)
	self.info = data.info
	self.chapterType = data.chapterType
	self.curChapter = curChapter

	local infoChapter = data.info
	local chapterIndex = data.index
	local listChapter = data.listChapter

	self.index = index
	self.Btn.name = "CellChapterBtn" .. index

	local listStage = infoChapter.data.StageID
	local stageCnt = #listStage
	local chapNum = ChapterMgr:GetChapterIdx(infoChapter.data.ID)

	if type(chapNum) ~= "number" then
		chapNum = 0
	end

	local isUnLock = infoChapter:IsOpen()
	local isNew = infoChapter:IsNew()
	local listAward = ChapterMgr:ChapterGroupDataList()[8].MainDrop[1]

	for i = 1, #listAward do
		local award = listAward[i]

		if award then
			local infoItem = ItemManager:Get(award)

			SetActiveFunc(self.awardList[i].gameObject, true)
			SetImageSprite(self.awardListImage[i], infoItem:GetIcon(), self)
		end
	end

	RedDotSystemMgr.SetUIRedDot(self.Btn_Node, string.format(GetChapterMainBranchPath(infoChapter.data.Type), GetChapterGroup(infoChapter), infoChapter.id))

	if self.index == 1 and tonumber(curChapter.data.ID) < 200 then
		SetActiveFunc(self.img_chapNum, true)
		SetActiveFunc(self.txt_chapNumGo, false)
		SetActiveFunc(self.tex_levelGo, false)
		SetActiveFunc(self.Tex_0.gameObject, true)
		SetActiveFunc(self.tex_level.gameObject, false)

		self.Tex_0.text = Lang(13100)
	else
		SetActiveFunc(self.img_chapNum, false)
		SetActiveFunc(self.txt_chapNumGo, true)

		local typeValue = 1

		if tonumber(curChapter.data.ID) > 200 then
			typeValue = 0
		end

		self.ChapterNum.text = self.index - typeValue .. ""
		self.tex_level.text = self.index - typeValue .. "<size=43>幕</size>"
		self.un_tex_level.text = self.index - typeValue .. "<size=43>幕</size>"

		SetActiveFunc(self.Tex_0.gameObject, false)
		SetActiveFunc(self.tex_level.gameObject, true)
	end

	self.ChapterName.text = infoChapter:GetName()

	local passListStage = {}
	local starStage = {}

	for i = 1, stageCnt do
		local infoStage = ChapterMgr:GetStage(listStage[i])

		if infoStage:IsNew() then
			self.isNew = infoStage:IsNew()
		end

		if PersistentStoreUtil.GetStageEnter(infoStage.data.ID) then
			self.isEnter = PersistentStoreUtil.GetStageEnter(infoStage.data.ID)
		end

		if infoStage.pb.isPass then
			table.insert(passListStage, infoStage)
		end

		if infoStage.data.Type == 1 or infoStage.data.Type == 3 then
			table.insert(starStage, infoStage)
		end
	end

	local passCnt = #passListStage

	if passCnt == stageCnt then
		self.RateValue.text = "<color=#e0e0e0>" .. passCnt .. "/" .. stageCnt .. "</color>"
		self.RateText.text = "<color=#e0e0e0>" .. _("PageChpater_rate") .. "</color>"
	else
		self.RateValue.text = "<color=#ffffff>" .. passCnt .. "/" .. stageCnt .. "</color>"
		self.RateText.text = "<color=#ffffff>" .. _("PageChpater_rate") .. "</color>"
	end

	local starStageCnt = #starStage
	local sumStar = starStageCnt * 3
	local collectedStar = infoChapter:GetStar()

	self.StarValue.text = collectedStar .. "/" .. sumStar

	if collectedStar == sumStar then
		self.StarValue.text = "<color=#e0e0e0>" .. collectedStar .. "/" .. sumStar .. "</color>"
	else
		self.StarValue.text = "<color=#ffffff>" .. collectedStar .. "/" .. sumStar .. "</color>"
	end

	local storyAwardAllGet = ChapterMgr:IsChapterStoryAwardAllGet(infoChapter)

	if collectedStar == sumStar and passCnt == stageCnt and storyAwardAllGet then
		SetActiveFunc(self.LockStarOff, false)
		SetActiveFunc(self.LockStarOn, true)
	else
		SetActiveFunc(self.LockStarOff, true)
		SetActiveFunc(self.LockStarOn, false)
	end

	SetActiveFunc(self.Cell, self.IsCell)

	local function func()
		self.AnimRoot:Play("CellChapter_Shake")
	end

	if isUnLock then
		if not isNew then
			self:UpdateState(isUnLock, isNew)

			local curChapter = self.curChapter

			if curChapter ~= nil then
				local isSame = curChapter.data.ID == infoChapter.data.ID

				if isSame and self.IsCell then
					SetActiveFunc(self.Cell, true)
					self.AnimCellRoot:Play("CellChapter_Cell_Open")
					SetImageSprite(self.Lock1, "UI/PageChapter/AtlasChapter/BTN_map_stage_06", self)
					func()
				end
			end
		else
			self:UpdateState(false, false)
		end
	else
		self:UpdateState(isUnLock, isNew)
	end

	self.RateValue.fontSize = 30

	UIUtil.SetTextAlignment(self.RateValue, 4)

	self.StarValue.fontSize = 30

	UIUtil.SetTextAlignment(self.StarValue, 4)
end

function CellChapter:UpdateState(isUnLock, isNew)
	SetActiveFunc(self.UnLock, not isUnLock)
	SetActiveFunc(self.Lock, isUnLock)
end

function CellChapter:PlayUnLockAnim(infoChapter)
	local isUnLock = infoChapter:IsOpen()
	local isNew = infoChapter:IsNew()

	if isUnLock and isNew then
		local lastUnLockId = PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. "LastUnLockChapterId")

		if infoChapter.data.Type == ChapterFromType.mainhard then
			lastUnLockId = PlayerPrefs.GetInt(PlayerInst.InfoPlayer.pid .. "LastUnLockChapterHardId")
		end

		if infoChapter.data.ID ~= lastUnLockId then
			local function cb()
				if infoChapter.data.Type == ChapterFromType.mainhard then
					PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. "LastUnLockChapterHardId", infoChapter.data.ID)
				else
					PlayerPrefs.SetInt(PlayerInst.InfoPlayer.pid .. "LastUnLockChapterId", infoChapter.data.ID)
				end

				EffectMgr:Alloc("Fx/UI/FX_UI_003/FX_UI_003", self.Point, true, 1)
				SoundMgr.Play(PATH_SFX_UI_CHAPTER_UNLOCK)

				self.Timer = TimerMgr.AddTimer(eTimerType.RealTime, 0.6, function()
					self:UpdateState(isUnLock, isNew)
					SetImageSprite(self.Lock1, "UI/PageChapter/AtlasChapter/BTN_map_stage_06", self)
					SetActiveFunc(self.Cell, true)

					self.IsCell = true

					self.AnimRoot:Play("CellChapter_Shake")
				end, {})
			end

			if self.page then
				self.page:PromptChapterUnlock(cb)
			else
				cb()
			end
		else
			self:UpdateState(isUnLock, isNew)
			SetImageSprite(self.Lock1, "UI/PageChapter/AtlasChapter/BTN_map_stage_06", self)
			SetActiveFunc(self.Cell, true)

			self.IsCell = true

			self.AnimRoot:Play("CellChapter_Shake")
		end
	end
end
