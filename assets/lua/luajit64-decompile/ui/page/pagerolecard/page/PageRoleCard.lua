-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Page/PageRoleCard.lua

require("UI/Page/PageRoleCard/Cell/CellCostItem")
require("UI/Page/PageRoleCard/Dlg/DlgCardUpAward")
require("UI/Page/PageRoleCard/Dlg/DlgCardUpResult")
require("UI/Page/PageRoleCard/Dlg/CardSkillTip")
require("UI/Page/PageRoleCard/Dlg/DlgCardUpPreview")
require("UI/Page/PagePass/DlgCardStage")
require("UI/Page/PageRoleCard/Page/DlgCardOverviewPanel")
require("UI/Page/PageRoleCard/Page/DlgCardBreakoutPanel")
require("UI/Page/PageRoleCard/Page/DlgCardStarStonePanel")
require("UI/Page/PageRoleCard/Page/DlgCardBloomPanel")

local skillTip = require("UI/Dlg/Common/SkillTipDesc")

require("UI/Page/PageRoleCard/Cell/CellCardSkill")
require("UI/Dlg/Public/DlgShare")

PageRoleCard = class("PageRoleCard", UIPanel)
eTabType = {
	Stone = 4,
	Bloom = 3,
	OverV = 1,
	Break = 2
}
eTabStrType = {
	Stone = "Stone",
	Bloom = "Bloom",
	OverV = "OverV",
	Break = "Break"
}

function PageRoleCard:ctor()
	self.UIPrefabPath = "UI/PanelRoleCard/PanelCard"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_RoleCardUp"),
		callback = self.OnBack,
		helpCallback = self.OnClickedBtnInfo,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())

	self.needResetStackData = false
end

function PageRoleCard:PreLoad()
	self:LoadResAsync("UI/PanelRoleCard/CellCardSkill", "PrefabCellCardSkill", GameObject)
end

function PageRoleCard:OnBack()
	CardExtraMgr.tabIndex = 0

	if self.closeCallback then
		self.closeCallback()
	end

	if UIMgr.GetPrePanel().className == "New" then
		local data = UIMgr.GetPrePanel().vParam

		if data == nil then
			data = {}
		end

		data.tag = self.popData.tag

		UIMgr.PopPanel(data)

		return
	end

	if GameObject.Find("DlgDrawCard(Clone)") then
		self:Close()

		return
	end

	UIMgr.PopPanel()
end

function PageRoleCard:Purge()
	self.base.Purge(self)

	if self.needResetStackData then
		local panel = UIMgr.GetPanel(self.className)

		if panel and panel.vParam and self.infoRoleCard and panel.vParam.cardId ~= self.infoRoleCard.id then
			panel.vParam.cardId = self.infoRoleCard.id
		end
	end

	Event.Instance:Fire("CloseDlgShare")
	self:OnLeave()
end

function PageRoleCard:NotifyPanelLoaded(panelName)
	if panelName == "PageTimeLimitTask" then
		UIMgr.PopPanel()
	end
end

function PageRoleCard:OnLeave()
	self:ClearSpine()

	if self.listCell then
		for _, v in ipairs(self.listCell) do
			v:OnLeave()
		end

		self.listCell = nil
	end

	ResourceMgr.Unload(self.PrefabCellCardSkill)
end

function PageRoleCard:ClearSpine()
	if #self.listSpineRef1 == 0 and #self.listSpineRef2 == 0 then
		return
	end

	for _, spineAsset in ipairs(self.listSpineRef1) do
		ResourceMgr.Unload(spineAsset)
	end

	self.listSpineRef1 = {}

	for _, spineAsset in ipairs(self.listSpineRef2) do
		ResourceMgr.Unload(spineAsset)
	end

	self.listSpineRef2 = {}
	self.GoSpine1 = nil
	self.GoSpine2 = nil

	System.GC.Collect()
end

function PageRoleCard:OnRegisterEvent()
	self:AddClick(self.BtnView, self.OnClickedBtnView)
	self:AddClick(self.GoCard2, self.OnClickedScreenCard)
	self:AddClick(self.BtnL, self.OnClickedBtnL)
	self:AddClick(self.BtnR, self.OnClickedBtnR)
	self:AddClick(self.ButtonShare, self.OnClickedBtnShare)
	self:AddClick(self.BtnShareOut, self.OnClickedBtnShareOut)
	self:AddClick(self.BtnEquip, self.OnClickedBtnEquip)

	for i = 1, self.tabCnt do
		self:AddClick(self["GoTag" .. i], self.OnClickedBtnTag)
	end

	Event.Instance:Add("UpdateAfterCardDevelop", self.UpdateCardData, self)
	Event.Instance:Add(EventEnum.UpdateItemDataNotify, self.UpdateItemData, self)
	Event.Instance:Add("UpdateNetData", self.UpdateNetData, self)
	Event.Instance:Add("NotifyPanelLoaded", self.NotifyPanelLoaded, self)
end

function PageRoleCard:OnUnRegisterEvent()
	self:RemoveClick(self.BtnView, self.OnClickedBtnView)
	self:RemoveClick(self.GoCard2, self.OnClickedScreenCard)
	self:RemoveClick(self.BtnL, self.OnClickedBtnL)
	self:RemoveClick(self.BtnR, self.OnClickedBtnR)
	self:RemoveClick(self.ButtonShare, self.OnClickedBtnShare)
	self:RemoveClick(self.BtnShareOut, self.OnClickedBtnShareOut)
	self:RemoveClick(self.BtnEquip, self.OnClickedBtnEquip)

	if self.tabCnt then
		for i = 1, self.tabCnt do
			self:RemoveClick(self["GoTag" .. i], self.OnClickedBtnTag)
		end
	end

	Event.Instance:Remove("UpdateAfterCardDevelop", self.UpdateCardData, self)
	Event.Instance:Remove(EventEnum.UpdateItemDataNotify, self.UpdateItemData, self)
	Event.Instance:Remove("UpdateNetData", self.UpdateNetData, self)
	Event.Instance:Remove("NotifyPanelLoaded", self.NotifyPanelLoaded, self)
end

function PageRoleCard:OnClickedBtnShareOut()
	GOUtil.SetActive(self.ButtonShare, false)
	GOUtil.SetActive(UIMgr.UIPopupObject, false)

	local go = GameObject.Find("ClickEffectMountNode")

	if not IsNil(go) then
		go:SetActive(false)
	end

	local function cb()
		if not IsNil(go) then
			go:SetActive(true)
		end
	end

	local t2d = MiscUtil.CapturePicture(UIMgr.UICamera, nil)

	Event.Instance:Fire("CloseDlgShare")
	UIMgr.AddPanel(DlgShare(), {
		texture = t2d,
		callback = cb,
		GoBtnShare = self.BtnShareOut
	})
	GOUtil.SetActive(self.ButtonShare, true)
	GOUtil.SetActive(UIMgr.UIPopupObject, true)
end

function PageRoleCard:OnClickedBtnShare()
	require("UI/Dlg/Public/DlgShare")
	GOUtil.SetActive(self.ButtonShare, false)
	GOUtil.SetActive(UIMgr.UIPopupObject, false)

	local go = GameObject.Find("ClickEffectMountNode")

	if not IsNil(go) then
		go:SetActive(false)
	end

	local function cb()
		if not IsNil(go) then
			go:SetActive(true)
		end
	end

	local t2d = MiscUtil.CapturePicture(UIMgr.UICamera, nil)

	Event.Instance:Fire("CloseDlgShare")
	UIMgr.AddPanel(DlgShare(), {
		texture = t2d,
		callback = cb
	})
	GOUtil.SetActive(self.ButtonShare, true)
	GOUtil.SetActive(UIMgr.UIPopupObject, true)
end

function PageRoleCard:OnEnter(vParam)
	Event.Instance:Fire("UpdateSceneDisplay", false)

	if not GuideMgr:IsGuided(GuideFunctionType.CardAttribute) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.CardAttribute)
	end

	if vParam.callback then
		vParam.callback()
	end

	if vParam.closeCallback then
		self.closeCallback = vParam.closeCallback
	end

	self.tabCnt = table.getCount(eTabType)

	self:DealWithLocalization()

	self.GoPanel = self:GetChildGameObject("Panel")
	self.GoCard1 = self:GetChildGameObject("Card1")
	self.GoCard2 = self:GetChildGameObject("Card2")

	self:SetSafeArea(self.GoPanel)

	self.GoFrame = self:GetChildGameObject("Panel/Info/Star/Frame")
	self.GoStar1 = self:GetChildGameObject("Panel/Info/Star/Star1")
	self.GoStar2 = self:GetChildGameObject("Panel/Info/Star/Star2")

	for i = 1, table.getCount(eRankType) do
		self["GoRank" .. i] = self:GetChildGameObject("Panel/Info/Rank" .. i)
	end

	for i = 1, 2 do
		self["RICardBg" .. i] = GOUtil.FindChildComponent(self["GoCard" .. i], "CardBg", "RawImage")
		self["RICardIcon" .. i] = GOUtil.FindChildComponent(self["GoCard" .. i], "CardIcon", "RawImage")
	end

	DealWithListRef(self, UIUtil.SetRawImageMaterial(self.RICardBg1, "UI/Materials/BlurMat"))

	self.GoTags = self:GetChildGameObject("Panel/Tag")
	self.GoShow = self:GetChildGameObject("Panel/Show")

	for i = 1, self.tabCnt do
		self["GoTag" .. i] = self:GetChildGameObject("Panel/Tag/" .. i)
		self["BtnTag" .. i] = self:GetChildGameObject("Panel/Tag/" .. i .. "/Button")
		self["SelTag" .. i] = self:GetChildGameObject("Panel/Tag/" .. i .. "/Select")
	end

	self.GoAbiGroup = self:GetChildGameObject("Panel/Other/Ability")
	self.BtnView = self:GetChildGameObject("Panel/Info/BtnView")
	self.BtnL = self:GetChildGameObject("Panel/Other/BtnL")
	self.BtnR = self:GetChildGameObject("Panel/Other/BtnR")
	self.ButtonShare = self:GetChildGameObject("Card2/BtnShare")
	self.BtnShareOut = self:GetChildGameObject("Card2/BtnShare/ButtonShare")
	self.BtnEquip = self:GetChildGameObject("Panel/BtnEquip")
	self.GoLock = self:GetChildGameObject("Panel/BtnEquip/Lock")
	self.listSpineRef1 = {}
	self.listSpineRef2 = {}

	self:InitData(vParam)
	self:InitEquip()
	DlgShare.UpdateData(self.BtnShareOut)

	if not self.infoRoleCard:IsHold() then
		self.ButtonShare:SetActive(false)
		self.BtnShareOut:SetActive(false)
	end
end

function PageRoleCard:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/Show/Extra/Text", "Text")
	txt.text = _("Desc_Card_Preview")

	for i = 1, self.tabCnt do
		local str = Lang(12355)

		if i == 2 then
			str = Lang(12260)
		elseif i == 3 then
			str = Lang(20014)
		elseif i == 4 then
			str = Lang(5000048)
		end

		txt = self:GetChildComponent("Panel/Tag/" .. i .. "/Button/Text", "Text")
		txt.text = str
		txt = self:GetChildComponent("Panel/Tag/" .. i .. "/Select/Text", "Text")
		txt.text = str
	end

	txt = self:GetChildComponent("Panel/BtnEquip/Image/Text", "Text")
	txt.text = Lang(9123)
end

function PageRoleCard:InitData(vParam)
	if not vParam or not vParam.cardId then
		return
	end

	self.vParam = vParam
	self.popData = vParam.popData
	self.isOpenDlgTimeLimitTask = vParam.isOpenDlgTimeLimitTask
	self.onlyShow = vParam.onlyShow

	if self.onlyShow == nil then
		self.onlyShow = false
	end

	local cardId = vParam.cardId
	local infoRoleCard

	if self.onlyShow then
		infoRoleCard = InfoRoleCard(cardId)

		self.SetCardData(infoRoleCard)
	else
		infoRoleCard = RoleCardMgr:GetRoleCard(cardId)
	end

	if not infoRoleCard then
		return
	end

	self.infoRoleCard = infoRoleCard
	self.enterRoleId = infoRoleCard.data.CharacterID
	self.listCardId = CardSwitchMgr.listCardId or {}
	self.cardIdx = table.getIndex(self.listCardId, cardId)
	self.curTabIdx = vParam.tag and not self.onlyShow and vParam.tag or 1

	if not self.onlyShow and CardExtraMgr.tabIndex ~= 0 then
		self.curTabIdx = CardExtraMgr.tabIndex
	end

	self.preTabIdx = self.curTabIdx

	self:InitPanel()
	self:UpdateDot()
end

function PageRoleCard.SetCardData(infoRoleCard)
	infoRoleCard.curLevel = infoRoleCard.maxLevel
	infoRoleCard.curStarLevel = infoRoleCard.maxStarLevel
	infoRoleCard.curPetal = infoRoleCard.maxPetal

	for _, config in ipairs(infoRoleCard.data.StarTalent) do
		for _, tId in ipairs(config) do
			local infoTalent = TalentManager:Get(tId)

			infoTalent:SetData({
				id = tId,
				level = infoTalent.maxTalentLevel
			})

			if infoTalent.data.BattleSkillType ~= eBattleTalentType.SpecialBall then
				table.insert(infoRoleCard.listSkill, infoTalent)
			end

			table.insert(infoRoleCard.listAllSkill, infoTalent)
		end
	end

	local function func(a, b)
		if a.data.Type == b.data.Type then
			return a.data.ID < b.data.ID
		end

		return a.data.Type < b.data.Type
	end

	table.sort(infoRoleCard.listSkill, func)
	table.sort(infoRoleCard.listAllSkill, func)

	infoRoleCard.attrs = infoRoleCard:UpdateAtt(infoRoleCard.maxLevel, infoRoleCard.maxStarLevel, infoRoleCard.maxPetal)
end

function PageRoleCard:InitPanel()
	GOUtil.SetActive(self.GoShow, self.onlyShow)
	GOUtil.SetActive(self.GoTags, not self.onlyShow)
	GOUtil.SetActive(self.BtnL, not self.onlyShow and self.listCardId and #self.listCardId > 1)
	GOUtil.SetActive(self.BtnR, not self.onlyShow and self.listCardId and #self.listCardId > 1)
	GOUtil.SetActive(self.BtnEquip, not self.onlyShow)
	self:UpdatePanel()
end

function PageRoleCard:UpdatePanel()
	self:UpdateStaticVal()
	self:UpdateDynamicVal()
	self:UpdateTabPanel()
end

function PageRoleCard:UpdateTabPanel()
	CardExtraMgr.tabIndex = self.curTabIdx

	for i = 1, self.tabCnt do
		GOUtil.SetActive(self["BtnTag" .. i], self.curTabIdx ~= i)
		GOUtil.SetActive(self["SelTag" .. i], self.curTabIdx == i)
	end

	local data = {}

	if self.curTabIdx == eTabType.OverV then
		data = {
			onlyShow = self.onlyShow,
			infoRoleCard = self.infoRoleCard
		}
	else
		data = {
			infoRoleCard = self.infoRoleCard
		}
	end

	local function CreateChildPanel(panel)
		if not panel then
			return
		end

		panel:Create(self.UIRootObject, data)

		self["update" .. self.curTabIdx] = true
		panel.parentPanel = self

		self:AddChildPanel(panel)
	end

	local function UpdateChildPanel(panel)
		if not panel then
			return
		end

		panel:InitPanel(data)

		self["update" .. self.curTabIdx] = true
	end

	local update = self["update" .. self.curTabIdx]

	if self.curTabIdx == eTabType.OverV then
		if self.DlgOverV then
			if not update then
				UpdateChildPanel(self.DlgOverV)
			end

			self.DlgOverV:Show()
		else
			self.DlgOverV = DlgCardOverviewPanel()

			CreateChildPanel(self.DlgOverV)
		end
	elseif self.curTabIdx == eTabType.Break then
		if self.DlgBreak then
			if not update then
				UpdateChildPanel(self.DlgBreak)
			end

			self.DlgBreak:Show()
		else
			self.DlgBreak = DlgCardBreakoutPanel()

			CreateChildPanel(self.DlgBreak)
		end
	elseif self.curTabIdx == eTabType.Bloom then
		if self.DlgBloom then
			if not update then
				UpdateChildPanel(self.DlgBloom)
			end

			self.DlgBloom:Show()
		else
			self.DlgBloom = DlgCardBloomPanel()

			CreateChildPanel(self.DlgBloom)
		end
	elseif self.curTabIdx == eTabType.Stone then
		if self.DlgStone then
			if not update then
				UpdateChildPanel(self.DlgStone)
			end

			self.DlgStone:Show()
		else
			self.DlgStone = DlgCardStarStonePanel()

			CreateChildPanel(self.DlgStone)
		end
	end

	if self.curTabIdx ~= self.preTabIdx then
		self:SetActivePanel(self.preTabIdx, false)
	end
end

function PageRoleCard:SetActivePanel(tagIdx, active)
	local panel

	if tagIdx == eTabType.OverV then
		panel = self.DlgOverV
	elseif tagIdx == eTabType.Break then
		panel = self.DlgBreak
	elseif tagIdx == eTabType.Bloom then
		panel = self.DlgBloom
	elseif tagIdx == eTabType.Stone then
		panel = self.DlgStone
	end

	if panel ~= nil then
		if active == false and panel.Hide ~= nil then
			panel:Hide()
		end

		if active == true and panel.Show ~= nil then
			panel:Show()
		end
	end
end

function PageRoleCard:UpdateStaticVal()
	local txtCardName = self:GetChildComponent("Panel/Info/TxtName", "Text")

	txtCardName.text = self.infoRoleCard:GetName(true)

	for i = 1, table.getCount(eRankType) do
		GOUtil.SetActive(self["GoRank" .. i], i == self.infoRoleCard.cardRank)
	end

	local function UpdateCellInstance(listInfo, listCell, infoRoleCard, infoType)
		for k, cell in ipairs(listCell) do
			if k <= #listInfo then
				local data = {}

				data.info = listInfo[k]
				data.infoRoleCard = self.infoRoleCard
				data.infoType = 3

				cell:UpdateData(data)
			end
		end
	end

	local function DealNewCell(listInfo, listCell)
		local newCnt, oldCnt = #listInfo, #listCell

		if oldCnt < newCnt then
			for k in ipairs(listInfo) do
				if oldCnt < k then
					local cell = CellCardSkill(self.PrefabCellCardSkill, self.GoAbiGroup, self)

					cell:Create()
					table.insert(listCell, cell)
				else
					GOUtil.SetActive(listCell[k].UIRootObject, true)
				end
			end
		else
			for k, cell in ipairs(listCell) do
				GOUtil.SetActive(cell.UIRootObject, k <= newCnt)
			end
		end
	end

	self.listCell = Tenary(self.listCell, {})

	local listAbi = self.infoRoleCard.listAbility or {}

	DealNewCell(listAbi, self.listCell)
	UpdateCellInstance(listAbi, self.listCell)
	self:ClearSpine()
	self:LoadAsyncCard(1)

	self.loadedScreenSpine = false
end

function PageRoleCard:UpdateDynamicVal()
	self:UpdateStarInfo()
	self:UpdatePetalInfo()
	self:UpdateCombat()
end

function PageRoleCard:UpdateStarInfo()
	RoleCardMgr:SetStar(self.infoRoleCard, self)
end

function PageRoleCard:UpdatePetalInfo()
	local curPetal = self.infoRoleCard.curPetal

	for i = 1, 4 do
		local state = self:GetChildGameObject("Panel/Info/Petal/State" .. i)

		GOUtil.SetActive(state, i == self.infoRoleCard.cardRank)

		if i == self.infoRoleCard.cardRank then
			for j = 1, self.infoRoleCard.maxPetal do
				local petal = GOUtil.FindChildComponent(state, "" .. j, "Image")
				local grayN = TenaryOp(curPetal < j, 1, 0)
				local ref = UIUtil.SetImageGray(petal, grayN)

				DealWithListRef(self, ref)
			end
		end
	end
end

function PageRoleCard:UpdateCombat()
	local txtScore = self:GetChildComponent("Panel/Other/Score/TxtScore", "Text")

	txtScore.text = tostring(RoleCardMgr:GetCardFightValue(self.infoRoleCard))
end

function PageRoleCard:LoadAsyncCard(ptype)
	if self["spineHandle" .. ptype] then
		ResourceMgr.Cancel(self["spineHandle" .. ptype])

		self["spineHandle" .. ptype] = nil
	else
		GOUtil.DestroyAllChildren(self["RICardIcon" .. ptype].gameObject)
	end

	if ptype == 1 then
		SetRawImageTexture(self["RICardBg" .. ptype], self.infoRoleCard.data.BGIcon, self)
	end

	local path = self.infoRoleCard.data.SpineData

	if not string.isNullOrEmpty(path) then
		if ptype == 1 then
			path = TenaryOp(string.isNullOrEmpty(self.infoRoleCard.data.AttachSpineData), path, self.infoRoleCard.data.AttachSpineData)
		else
			path = path .. "_Anim_All"
		end

		local function wrap_cb()
			LoadingMgr.Hide(eLoadingType.Repeat)

			if self["spineRef" .. ptype] then
				if ptype == 1 then
					RoleCardMgr:SetCardLocation(self.infoRoleCard, self["RICardIcon" .. ptype].gameObject, 4)
				end

				self["GoSpine" .. ptype] = GOUtil.InstantiateUIPrefab(self["spineRef" .. ptype], self["RICardIcon" .. ptype].gameObject)

				GOUtil.UpdateSpineSkeleton(self["RICardIcon" .. ptype].gameObject)
				table.insert(self["listSpineRef" .. ptype], self["spineRef" .. ptype])

				self["spineHandle" .. ptype] = nil
				self["spineRef" .. ptype] = nil
			end
		end

		LoadingMgr.Show(eLoadingType.Repeat)

		self["spineHandle" .. ptype] = ResourceMgr.BeginSubmit(wrap_cb)

		ResourceMgr.SubmitCache(path, self, "spineRef" .. ptype, GameObject)
		ResourceMgr.EndSubmit()
	end
end

function PageRoleCard:OnClickedBtnView()
	GOUtil.SetActive(self.GoCard1, false)
	GOUtil.SetActive(self.GoCard2, true)
	GOUtil.SetActive(self.GoPanel, false)
	self:SetActivePanel(self.curTabIdx, false)

	if not self.loadedScreenSpine then
		self:LoadAsyncCard(2)

		self.loadedScreenSpine = true
	elseif not IsNil(self.GoSpine2) then
		UIUtil.ReplaySpineAnimation(self.GoSpine2)
	end
end

function PageRoleCard:OnClickedScreenCard()
	GOUtil.SetActive(self.GoCard1, true)
	GOUtil.SetActive(self.GoCard2, false)
	GOUtil.SetActive(self.GoPanel, true)
	self:SetActivePanel(self.curTabIdx, true)
end

function PageRoleCard:OnClickedBtnL()
	self.cardIdx = self.cardIdx - 1

	self:UpdateCard()
end

function PageRoleCard:OnClickedBtnR()
	self.cardIdx = self.cardIdx + 1

	self:UpdateCard()
end

function PageRoleCard:UpdateCard()
	self.cardIdx = TenaryOp(self.cardIdx > #self.listCardId, 1, TenaryOp(self.cardIdx < 1, #self.listCardId, self.cardIdx))

	for i = 1, self.tabCnt do
		self["update" .. i] = false
	end

	local cardId = self.listCardId[self.cardIdx]

	self.infoRole = RoleCardMgr:GetRole(cardId)
	self.infoRoleCard = RoleCardMgr:GetRoleCard(cardId)

	self:UpdatePanel()
	self:UpdateDot()
	DlgShare.UpdateData(self.BtnShareOut)
end

function PageRoleCard:OnClickedBtnTag(data)
	local go = data.pointerPress.gameObject
	local index = tonumber(go.name)

	if self.curTabIdx == index then
		return
	end

	local isOpen = true

	if index == eTabType.Break then
		isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.CardStar)
	elseif index == eTabType.Bloom then
		isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.CardPetal)
	elseif index == eTabType.Stone then
		isOpen = true
	end

	if not isOpen then
		return
	end

	self.preTabIdx = self.curTabIdx
	self.curTabIdx = index

	if self.curTabIdx == eTabType.Break then
		if not GuideMgr:IsGuided(GuideFunctionType.CardStar) then
			UIMgr.AddPanel(PGuide(), GuideFunctionType.CardStar)
		end
	elseif self.curTabIdx == eTabType.Bloom and not GuideMgr:IsGuided(GuideFunctionType.CardPetal) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.CardPetal)
	end

	self:UpdateTabPanel()
end

function PageRoleCard:OnClickedBtnInfo()
	require("UI/Dlg/Public/GuideChooseTip")
	UIMgr.AddPanel(GuideChooseTip(), {
		guideType = "CardGuide"
	})
end

function PageRoleCard:UpdateCardData(_type)
	if _type == eTabType.Break then
		self:UpdateStarInfo()

		if self.update2 then
			self.DlgBreak:UpdatePanel()
		end
	elseif _type == eTabType.Bloom then
		self:UpdatePetalInfo()

		if self.update3 then
			self.DlgBloom:UpdatePanel()
		end

		if self.update4 then
			self.DlgStone:UpdateSoulNum()

			if self.infoRoleCard.curPetal == GetConfigArgInt("CardStoryUnlock") then
				self.DlgStone:UpdateStory()
			end
		end
	end

	if self.update1 then
		self.DlgOverV:UpdatePanelData(_type)
	end

	self:UpdateCombat()
end

function PageRoleCard:UpdateItemData(_type)
	if self.onlyShow then
		return
	end

	local function fun1()
		if self.update1 then
			self.DlgOverV:UpdateUpLvState()
		end
	end

	local function fun2()
		if self.update2 then
			self.DlgBreak:UpdateCostItem()
		end
	end

	local function fun3()
		if self.update3 then
			self.DlgBloom:UpdateCost()
		end
	end

	local function fun4()
		if self.update4 then
			self.DlgStone:UpdateSoulNum()
		end
	end

	if _type then
		if _type == eTabType.OverV then
			fun1()
		elseif _type == eTabType.Break then
			fun2()
		elseif _type == eTabType.Bloom then
			fun3()
			fun4()
		elseif _type == eTabType.Stone then
			fun3()
		end

		return
	end

	fun1()
	fun2()
	fun3()
	fun4()
end

function PageRoleCard:UpdateDot(tag)
	if self.onlyShow then
		return
	end

	RedDotSystemMgr.SetUIRedDot(self.GoTag1, "LvUp/" .. self.infoRoleCard.id)
	RedDotSystemMgr.SetUIRedDot(self.GoTag2, "Break/" .. self.infoRoleCard.id)
	RedDotSystemMgr.SetUIRedDot(self.GoTag3, "Bloom/" .. self.infoRoleCard.id)

	if not self.isSet then
		self.isSet = true

		RedDotSystemMgr.SetUIRedDot(self.BtnEquip, "Role/" .. self.infoRoleCard.data.CharacterID .. "/Equip")
	end

	CardRDL.NewRDL.SubNewCardPlayerPrefs(self.infoRoleCard)
end

function PageRoleCard:UpdateNetData()
	self:UpdateCardData(self.curTabIdx)
end

function PageRoleCard:InitEquip()
	if self.onlyShow then
		return
	end

	local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Equipment)

	self.GoLock:SetActive(not isOpen)
end

function PageRoleCard:OnClickedBtnEquip()
	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Equipment)

	if not isOpen then
		return
	end

	local panel = UIMgr.GetPrePanel()

	if panel.className == "PageEquip" then
		self:OnBack()
	else
		require("UI/Page/PageEquipment/PageEquip")

		self.needResetStackData = true

		UIMgr.SwitchPanel(PageEquip, {
			roleId = self.infoRoleCard.data.CharacterID
		})
	end
end

function PageRoleCard:OnBackAndroid()
	if self.GoCard2 and GOUtil.IsActiveSelf(self.GoCard2) then
		self:OnClickedScreenCard()

		return true
	end

	if self.DlgOverV and self.DlgOverV:IsShow() and self.DlgOverV.CardSkillTip and self.DlgOverV.CardSkillTip:IsShow() then
		self.DlgOverV.CardSkillTip:Hide()

		return true
	end

	return false
end
