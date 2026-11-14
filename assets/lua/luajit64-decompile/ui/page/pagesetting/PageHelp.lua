-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageSetting/PageHelp.lua

local NewbieData = require("luaData/Newbie")

PageHelp = class("PageHelp", UIPanel)

function PageHelp:ctor()
	self.UIPrefabPath = "UI/PanelSetting/PanelHelp"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_help"),
		callback = self.OnBack,
		panel = self
	})
end

function PageHelp:PreLoad()
	return
end

function PageHelp:Purge()
	self.base.Purge(self)
	UnloadAllImageSprite(self)
	self:CancelDot()
end

function PageHelp:OnLeave()
	return
end

function PageHelp:OnBack()
	UIMgr.PopPanel()
end

function PageHelp:OnEnter()
	self.PrefabToggleMain = self:GetChildGameObject("ToggleTab")
	self.PrefabToggleTab = self:GetChildGameObject("ToggleMain")
	self.PrefabToggleDot = self:GetChildGameObject("ToggleDot")
	self.PrefabCellGuide = self:GetChildGameObject("CellGuide")
	self.BtnL = self:GetChildGameObject("Panel/BtnL")
	self.BtnR = self:GetChildGameObject("Panel/BtnR")
	self.BtnL2 = self:GetChildGameObject("Panel/BtnL2")
	self.BtnR2 = self:GetChildGameObject("Panel/BtnR2")
	self.ArrowL = self:GetChildGameObject("Panel/ArrowL")
	self.ArrowR = self:GetChildGameObject("Panel/ArrowR")
	self.TextLock = self:GetChildComponent("Panel/Text", "Text")
	self.GoBoard = self:GetChildGameObject("Panel/Board")
	self.ImgRect = self:GetChildGameObject("Panel/Board/Bg/ImgRect")
	self.ImgGroup = self:GetChildGameObject("Panel/Board/Bg/ImgGroup")
	self.ScrollArea = self:GetChildComponent("Panel/ScrollArea", "ScrollRect")

	self:InitText()

	self.GoMain = self:GetChildGameObject("Panel/ScrollAreaTab/Content")
	self.GoTab = self:GetChildGameObject("Panel/ScrollArea/Content")
	self.listData = GuideMgr:InitListHelp()
	self.listMain = {}

	for i = 1, #self.listData do
		local g = GOUtil.InstantiateUI(self.PrefabToggleMain, self.GoMain)

		g.name = i

		local data = self.listData[i][1].data
		local strTitle = Lang(data.HomeTitle)
		local txt = GOUtil.FindChildComponent(g, "NotSel/Text", "Text")

		txt.text = strTitle
		txt = GOUtil.FindChildComponent(g, "Sel/Text", "Text")
		txt.text = strTitle

		local img = GOUtil.FindChildComponent(g, "NotSel/Image", "Image")

		UIUtil.SetImageOverrideSprite(img, "UIDyAtlas/Help/IC_option_guide_" .. data.HelpOrder, self)

		img = GOUtil.FindChildComponent(g, "Sel/Image", "Image")

		UIUtil.SetImageOverrideSprite(img, "UIDyAtlas/Help/IC_option_guide_" .. data.HelpOrder, self)

		local isLock = self:IsLock(data.NewBieId)
		local gLock = GOUtil.FindChildGameObject(g, "ImgLock")

		SetActiveFunc(gLock, isLock)
		UIUtil.SetImageGray(img, TenaryOp(isLock, 1, 0))
		table.insert(self.listMain, g)
		RedDotSystemMgr.SetUIRedDot(g, "Setting/Help/" .. data.HelpOrder)
	end

	GOUtil.SetRectTransformAnchoredPosition(self.GoMain, 0, 0)

	local toggleFirst = GOUtil.FindChildGameObject(self.listMain[1], "Sel")

	SetActiveFunc(toggleFirst, true)

	self.goRawImg = GOUtil.InstantiateUI(self.PrefabCellGuide, self.ImgRect)

	GOUtil.SetRectTransformAnchoredPosition(self.goRawImg, 0, 0)

	self.rawImg = GOUtil.GetComponent(self.goRawImg, "RawImage")
	self.curMainTag = 1
	self.curTab = 1

	self:UpdateMainTag()
end

function PageHelp:OnRegisterEvent()
	for i = 1, #self.listData do
		local go = self.listMain[i]

		self:AddClick(go, self.OnClickMain)
	end

	self:AddClick(self.BtnL, self.OnClickBtnL)
	self:AddClick(self.BtnR, self.OnClickBtnR)
	self:AddClick(self.BtnL2, self.OnClickBtnL2)
	self:AddClick(self.BtnR2, self.OnClickBtnR2)
end

function PageHelp:OnUnRegisterEvent()
	for i = 1, #self.listData do
		local go = self.listMain[i]

		self:RemoveClick(go, self.OnClickMain)
	end

	self:RemoveClick(self.BtnL, self.OnClickBtnL)
	self:RemoveClick(self.BtnR, self.OnClickBtnR)
	self:RemoveClick(self.BtnL2, self.OnClickBtnL2)
	self:RemoveClick(self.BtnR2, self.OnClickBtnR2)
end

function PageHelp:InitText()
	return
end

function PageHelp:OnClickMain(data)
	self:CancelDot()

	local go = data.pointerPress

	self.curMainTag = tonumber(go.name)
	self.curTab = 1

	self:UpdateMainTag()
end

function PageHelp:UpdateToggleMain(index, selIdx)
	local g = self.listMain[index]
	local gt = GOUtil.FindChildGameObject(g, "Sel")

	gt:SetActive(selIdx == index)
end

function PageHelp:UpdateMainTag()
	for i = 1, #self.listData do
		self:UpdateToggleMain(i, self.curMainTag)
	end

	self:UpdateTab(true)
	self:UpdateBtnMode()
end

function PageHelp:UpdateTab(isMain)
	local listTabData = self.listData[self.curMainTag]

	GOUtil.DestroyAllChildren(self.GoTab)

	if self.listTab then
		for i = 1, #self.listTab do
			local go = self.listTab[i]

			self:RemoveClick(go, self.OnClickTab)
		end
	end

	self.listTab = {}

	for i = 1, #listTabData do
		local g = GOUtil.InstantiateUI(self.PrefabToggleTab, self.GoTab)
		local data = listTabData[i].data
		local strName = Lang(data.Name)
		local txt = GOUtil.FindChildComponent(g, "NotSel/Text", "Text")

		txt.text = strName
		txt = GOUtil.FindChildComponent(g, "Sel/Text", "Text")
		txt.text = strName

		local gLock = GOUtil.FindChildGameObject(g, "ImgLock")
		local isLock = self:IsLock(data.NewBieId)

		SetActiveFunc(gLock, isLock)

		local img = GOUtil.FindChildComponent(g, "NotSel", "Image")

		UIUtil.SetImageGray(img, TenaryOp(isLock, 1, 0))

		img = GOUtil.FindChildComponent(g, "Sel", "Image")

		UIUtil.SetImageGray(img, TenaryOp(isLock, 1, 0))

		g.name = i

		local sel = GOUtil.FindChildGameObject(g, "Sel")

		sel.gameObject:SetActive(self.curTab == i)
		table.insert(self.listTab, g)
		self:AddClick(g, self.OnClickTab)
		RedDotSystemMgr.SetUIRedDot(g, "Setting/Help/" .. data.HelpOrder .. "/" .. data.ID)
	end

	GOUtil.SetRectTransformAnchoredPosition(self.GoTab, 0, 0)

	if not self.curContentId then
		self.curContentId = 1
	end

	self.isLock = false

	if isMain then
		self.curContentId = 1
		self.isLock = GOUtil.FindChildGameObject(self.listMain[self.curMainTag], "ImgLock").activeSelf

		SetActiveFunc(self.GoTab, not self.isLock)
	end

	if self.isLock then
		SetActiveFunc(self.BtnL2, false)
		SetActiveFunc(self.BtnR2, false)
		SetActiveFunc(self.ArrowL, false)
		SetActiveFunc(self.ArrowR, false)
	end

	self.curContentId = 1

	self:UpdateContent(true)

	local pos = GetContentPosUGUIScroll(self.ScrollArea, #listTabData, self.curTab, true)

	GOUtil.SetRectTransformAnchoredPosition(self.ScrollArea.content.gameObject, 0, -pos)
end

function PageHelp:IsLock(NewBieId)
	local isLock = false
	local stageId = NewbieData[NewBieId].Stage

	if stageId ~= 0 then
		local infoStage = ChapterMgr:GetStage(stageId)

		isLock = not infoStage or not infoStage:IsPass()
	end

	return isLock
end

function PageHelp:GetLockTxt(NewBieId)
	local stageId = NewbieData[NewBieId].Stage

	if stageId ~= 0 then
		local infoStage = ChapterMgr:GetStage(stageId)

		if not infoStage or not infoStage:IsPass() then
			local str

			if infoStage.data.ChapterType == ChapterFromType.tower then
				local infoChapter = TowerChapterMgr:GetTowerChapter(info.data.Stage)

				str = string.format(_("Msg_PassStageUnlock"), Lang(infoChapter.data.Name))
			else
				local infoChapter, i, j = ChapterMgr:GetChapterByStageID(infoStage.id)

				if infoChapter == nil or i == nil or j == nil then
					-- block empty
				else
					local strStage = "<color=yellow>" .. i .. "-" .. j .. "</color>"

					str = string.format(_("Msg_PassStageUnlock"), strStage .. Lang(infoStage.data.Name))
				end
			end

			return str
		end
	end

	return nil
end

function PageHelp:OnClickTab(data)
	self:CancelDot()

	local go = data.pointerPress

	self.curTab = tonumber(go.name)

	local listTabData = self.listData[self.curMainTag]

	for i = 1, #listTabData do
		local g = self.listTab[i]
		local gt = GOUtil.FindChildGameObject(g, "Sel")

		gt:SetActive(self.curTab == i)
	end

	self.curContentId = 1

	self:UpdateContent(true)
end

function PageHelp:UpdateContent(isNoMain)
	local listTabData = self.listData[self.curMainTag]
	local data = listTabData[self.curTab].data
	local isLock = self:IsLock(data.NewBieId)

	SetActiveFunc(self.GoBoard, not isLock)

	if isLock then
		local str = self:GetLockTxt(data.NewBieId)

		if str then
			self.TextLock.text = str
		end

		SetActiveFunc(self.BtnL2, false)
		SetActiveFunc(self.BtnR2, false)
		SetActiveFunc(self.ArrowL, false)
		SetActiveFunc(self.ArrowR, false)

		return
	end

	local listPic = data.Pic
	local strId = listPic[self.curContentId]

	if strId < 10 then
		strId = "00" .. strId
	elseif strId >= 10 and strId < 100 then
		strId = "0" .. strId
	end

	UIUtil.SetRawImageTexture(self.rawImg, "Texture/Guide/guid_" .. strId, self, false)
	GOUtil.DestroyAllChildren(self.ImgGroup)

	self.listGoDot = {}

	for i = 1, #listPic do
		local go = GOUtil.InstantiateUI(self.PrefabToggleDot, self.ImgGroup)
		local tog = GOUtil.GetComponent(go, "Toggle")

		table.insert(self.listGoDot, tog)
	end

	self.listGoDot[self.curContentId].isOn = true

	if isNoMain then
		SetActiveFunc(self.BtnL2, self.curTab ~= 1 or self.curContentId ~= 1)
		SetActiveFunc(self.BtnR2, listTabData[self.curTab + 1] and listTabData[self.curTab + 1].isLockValue ~= 1 and self.curTab ~= #listTabData or self.curContentId < #listTabData[self.curTab].data.Pic)
		SetActiveFunc(self.ArrowL, self.curTab ~= 1 or self.curContentId ~= 1)
		SetActiveFunc(self.ArrowR, listTabData[self.curTab + 1] and listTabData[self.curTab + 1].isLockValue ~= 1 and self.curTab ~= #listTabData or self.curContentId < #listTabData[self.curTab].data.Pic)
	end
end

function PageHelp:OnClickBtnL2()
	local listTabData = self.listData[self.curMainTag]
	local data = listTabData[self.curTab].data
	local isLock = self:IsLock(data.NewBieId)

	if isLock then
		self.curContentId = 1
	end

	if self.curContentId - 1 < 1 then
		self:CancelDot()

		self.curTab = self.curTab - 1

		if self.curTab < 1 then
			local listTabData = self.listData[self.curMainTag]
		end

		self:UpdateTab()

		local toggleFirst = GOUtil.FindChildGameObject(self.listTab[self.curTab], "Sel")

		SetActiveFunc(toggleFirst, true)
	else
		self.curContentId = self.curContentId - 1

		self:UpdateContent(true)
	end
end

function PageHelp:OnClickBtnR2()
	local listTabData = self.listData[self.curMainTag]
	local data = listTabData[self.curTab].data
	local isLock = self:IsLock(data.NewBieId)

	if isLock then
		self.curContentId = #self.listGoDot
	end

	if self.curContentId + 1 > #self.listGoDot then
		self:CancelDot()

		self.curTab = self.curTab + 1

		local listTabData = self.listData[self.curMainTag]

		self:UpdateTab()

		local toggleFirst = GOUtil.FindChildGameObject(self.listTab[self.curTab], "Sel")

		SetActiveFunc(toggleFirst, true)
	else
		self.curContentId = self.curContentId + 1

		self:UpdateContent(true)
	end
end

function PageHelp:OnClickBtnL()
	self.curMainTag = math.max(self.curMainTag - 1, 1)
	self.curTab = 1

	self:UpdateMainTag()

	if self.curMainTag < 3 then
		GOUtil.SetRectTransformAnchoredPosition(self.GoMain, 0, 0)
	end
end

function PageHelp:OnClickBtnR()
	self.curMainTag = math.min(self.curMainTag + 1, #self.listData)
	self.curTab = 1

	self:UpdateMainTag()

	if self.curMainTag > #self.listData - 3 then
		GOUtil.SetRectTransformAnchoredPosition(self.GoMain, -228, 0)
	end
end

function PageHelp:UpdateBtnMode()
	SetActiveFunc(self.BtnL, true)
	SetActiveFunc(self.BtnR, true)

	if self.curMainTag == 1 then
		SetActiveFunc(self.BtnL, false)
	end

	if self.curMainTag == #self.listData then
		SetActiveFunc(self.BtnR, false)
	end

	local toggleFirst = GOUtil.FindChildGameObject(self.listMain[self.curMainTag], "Sel")

	SetActiveFunc(toggleFirst, true)
end

function PageHelp:CancelDot()
	HelpRDL.SubUnreadHelpId(self.listData[self.curMainTag][self.curTab].data.ID)
end
