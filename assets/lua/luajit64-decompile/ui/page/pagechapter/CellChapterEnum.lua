-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageChapter/CellChapterEnum.lua

require("UI/Item/UIItemBase")

CellChapterEnum = class("CellChapterEnum", UIItemBase)

function CellChapterEnum:ctor(itemPrefabCache, parent, ownUI, page)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
	self.page = page
end

function CellChapterEnum:Create(vParam)
	CellChapterEnum.base.Create(self, vParam)
end

function CellChapterEnum:OnEnter()
	local g = self.UIRootObject

	self.bigbg = GOUtil.FindChildGameObject(g, "bigbg")
	self.upText1 = GOUtil.FindChildComponent(g, "bigbg/Text", "Text")
	self.texNum1 = self:GetChildComponent("bigbg/texNum", "Text")
	self.img_zero1 = self:GetChildGameObject("bigbg/img_zero")
	self.imgstar1 = GOUtil.FindChildComponent(g, "bigbg/imgstar", "Image")
	self.texlevel1 = GOUtil.FindChildComponent(g, "bigbg/texlevel", "Text")
	self.smallbg = GOUtil.FindChildGameObject(g, "smallbg")
	self.smallDot = GOUtil.FindChildGameObject(g, "smallbg/go_dot")
	self.upText2 = GOUtil.FindChildComponent(g, "smallbg/Text", "Text")
	self.texNum2 = self:GetChildComponent("smallbg/texNum", "Text")
	self.img_zero2 = self:GetChildGameObject("smallbg/img_zero")
	self.imgstar2 = GOUtil.FindChildComponent(g, "smallbg/imgstar", "Image")
	self.texlevel2 = GOUtil.FindChildComponent(g, "smallbg/texlevel", "Text")
	self.upText3 = GOUtil.FindChildComponent(g, "lockbg/Text", "Text")
	self.texNum3 = self:GetChildComponent("lockbg/texNum", "Text")
	self.img_zero3 = self:GetChildGameObject("lockbg/img_zero")
	self.lockbg = self:GetChildGameObject("lockbg")
	self.smalldot = self:GetChildGameObject("smallbg/dot")
	self.texlevel1.fontSize = 18
	self.texlevel2.fontSize = 16

	self:OnRegisterEvent()
end

function CellChapterEnum:UpdateData(data, index, Index, curChapter)
	local infoChapter = data.info
	local starCountLists = data.starCountLists

	self.upText1.text = Lang(infoChapter.Name)
	self.upText2.text = Lang(infoChapter.Name)
	self.upText3.text = Lang(infoChapter.Name)
	self.FX_UI_004 = self:GetChildGameObject("FX_UI_004")

	if ChapterMgr:GetBatteleTypeEnumID() == 0 then
		self.texNum1.text = Index - 1 .. ""
		self.texNum2.text = Index - 1 .. ""
		self.texNum3.text = Index - 1 .. ""

		SetActiveFunc(self.texNum1.gameObject, Index ~= 1)
		SetActiveFunc(self.texNum2.gameObject, Index ~= 1)
		SetActiveFunc(self.texNum3.gameObject, Index ~= 1)
		SetActiveFunc(self.img_zero1, Index == 1)
		SetActiveFunc(self.img_zero2, Index == 1)
		SetActiveFunc(self.img_zero3, Index == 1)
	else
		self.texNum1.text = Index .. ""
		self.texNum2.text = Index .. ""
		self.texNum3.text = Index .. ""

		SetActiveFunc(self.texNum1.gameObject, true)
		SetActiveFunc(self.texNum2.gameObject, true)
		SetActiveFunc(self.texNum3.gameObject, true)
		SetActiveFunc(self.img_zero1, false)
		SetActiveFunc(self.img_zero2, false)
		SetActiveFunc(self.img_zero3, false)
	end

	local curChapter = curChapter

	for i = 1, #infoChapter.Chapter do
		local isUnLock = tonumber(infoChapter.Chapter[i]) <= tonumber(curChapter.data.ID)

		self:UpdateState(isUnLock, index, tonumber(curChapter.data.ID) < 200)

		if isUnLock then
			break
		end
	end

	local isdot = false
	local collectedStarCount = 0
	local sumStarCount = 0

	for i = 1, #infoChapter.Chapter do
		for j = 1, #starCountLists do
			local isUnLock = starCountLists[j][1] == infoChapter.Chapter[i]

			if ChapterMgr.ChapterHasStarAward(ChapterMgr:GetChapter(tonumber(infoChapter.Chapter[i]))) then
				isdot = true
			end

			if isUnLock then
				collectedStarCount = collectedStarCount + starCountLists[j][2]
				sumStarCount = sumStarCount + starCountLists[j][3]

				break
			end
		end
	end

	if collectedStarCount == sumStarCount then
		self.texlevel1.text = "<color=#b7b7b7>" .. collectedStarCount .. "/" .. sumStarCount .. "</color>"
		self.texlevel2.text = "<color=#b7b7b7>" .. collectedStarCount .. "/" .. sumStarCount .. "</color>"
	else
		self.texlevel1.text = "<color=#409fb5>" .. collectedStarCount .. "/" .. sumStarCount .. "</color>"
		self.texlevel2.text = "<color=#409fb5>" .. collectedStarCount .. "/" .. sumStarCount .. "</color>"
	end

	self:UpdateDot()
end

function CellChapterEnum:UpdateState(isUnLock, index, isNormal)
	if isNormal then
		local timer = TenaryOp(isUnLock and ChapterMgr:GetBatteleEnumID() < self.Index and index == self.Index, 0.45, 0)

		if timer == 0.45 then
			local function cb()
				SetActiveFunc(self.FX_UI_004, isUnLock)

				self.Timer = TimerMgr.AddTimer(eTimerType.RealTime, timer, function()
					SetActiveFunc(self.FX_UI_004, false)
					SetActiveFunc(self.lockbg, not isUnLock)
					SetActiveFunc(self.bigbg, index == self.Index and isUnLock)
					SetActiveFunc(self.smallbg, index ~= self.Index and isUnLock)
				end, {})
			end

			if self.page then
				self.page:PromptChapterUnlock(cb)
			else
				cb()
			end
		else
			SetActiveFunc(self.lockbg, not isUnLock)
			SetActiveFunc(self.bigbg, index == self.Index and isUnLock)
			SetActiveFunc(self.smallbg, index ~= self.Index and isUnLock)
		end

		local id = TenaryOp(index == self.Index, self.Index, ChapterMgr:GetBatteleEnumID())

		if id > ChapterMgr:GetBatteleEnumID() then
			ChapterMgr:SetBatteleEnumID(id)
		end
	else
		local timer = TenaryOp(isUnLock and ChapterMgr:GetBatteleHardEnumID() < self.Index and index == self.Index, 0.45, 0)

		if timer == 0.45 then
			local function cb()
				SetActiveFunc(self.FX_UI_004, isUnLock)

				self.Timer = TimerMgr.AddTimer(eTimerType.RealTime, timer, function()
					SetActiveFunc(self.FX_UI_004, false)
					SetActiveFunc(self.lockbg, not isUnLock)
					SetActiveFunc(self.bigbg, index == self.Index and isUnLock)
					SetActiveFunc(self.smallbg, index ~= self.Index and isUnLock)
				end, {})
			end

			if self.page then
				self.page:PromptChapterUnlock(cb)
			else
				cb()
			end
		else
			SetActiveFunc(self.lockbg, not isUnLock)
			SetActiveFunc(self.bigbg, index == self.Index and isUnLock)
			SetActiveFunc(self.smallbg, index ~= self.Index and isUnLock)
		end

		local id = TenaryOp(index == self.Index, self.Index, ChapterMgr:GetBatteleHardEnumID())

		if id > ChapterMgr:GetBatteleHardEnumID() then
			ChapterMgr:SetBatteleHardEnumID(id)
		end
	end
end

function CellChapterEnum:UpdateStateNew(isHaveDot)
	return
end

function CellChapterEnum:OnLeave()
	self:OnUnRegisterEvent()

	if self.Timer then
		TimerMgr.RemoveTimer(self.Timer)
	end

	self.Timer = nil
end

function CellChapterEnum:UpdateDot()
	local path

	if ChapterMgr:GetBatteleTypeEnumID() == 0 then
		path = string.format("Chapter/Main/Easy/%d", self.Index)
	else
		path = string.format("Chapter/Main/Hard/%d", self.Index)
	end

	RedDotSystemMgr.SetUIRedDot(self.UIRootObject, path)
end
