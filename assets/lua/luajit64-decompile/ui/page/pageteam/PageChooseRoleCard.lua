-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTeam/PageChooseRoleCard.lua

require("UI/Page/PageTeam/MyRoleCard")
require("UI/Page/PageTeam/OtherRoleCard")
require("UI/Page/PageTeam/DlgTeamCardFilter")
require("UI/Page/PageRoleCard/Cell/CellCardRoleItem")

PageChooseRoleCard = class("PageChooseRoleCard", UIPanel)

function PageChooseRoleCard:ctor()
	self.UIPrefabPath = "UI/PanelChooseCard/PanelChooseRoleCard"

	self:AddChildPanel(DlgExit(), {
		title = _("pageUpCardTitle"),
		callback = self.OnBack,
		panel = self
	})
end

function PageChooseRoleCard:PreLoad()
	self.myRoleCardPreLoad = ResourceMgr.LoadSync("UI/PanelChooseCard/MyRoleCard")
	self.helpCardPreLoad = ResourceMgr.LoadSync("UI/PanelChooseCard/OtherRoleCard")
	self.PrefabCellCardRoleItem = ResourceMgr.LoadSync("UI/PanelRoleCard/CellCardRoleItem")
end

function PageChooseRoleCard:Purge()
	PageChooseRoleCard.base.Purge(self)
	ResourceMgr.Unload(self.myRoleCardPreLoad)
	ResourceMgr.Unload(self.helpCardPreLoad)
	ResourceMgr.Unload(self.PrefabCellCardRoleItem)

	self.myRoleCardPreLoad = nil
	self.helpCardPreLoad = nil
	self.PrefabCellCardRoleItem = nil

	if self.UIScrollToolMyCard then
		self.UIScrollToolMyCard:Purge()

		self.UIScrollToolMyCard = nil
	end

	if self.UIScrollToolHelpCard then
		self.UIScrollToolHelpCard:Purge()

		self.UIScrollToolHelpCard = nil
	end

	if self.UIScrollTool2 then
		self.UIScrollTool2:Purge()

		self.UIScrollTool2 = nil
	end
end

function PageChooseRoleCard:OnBack()
	UIMgr.PopPanel()
end

function PageChooseRoleCard:OnRegisterEvent()
	self:AddClick(self.BtnTag, self.OnClickedBtnTag)
	self:AddClick(self.detailsSwitchOpen, self.OnClickDetailsSwitchOpen)
	self:AddClick(self.detailsSwitchClose, self.OnClickDetailsSwitchClose)
	self:AddClick(self.screenBtn, self.OnClickScreenBtn)
	self:AddClick(self.ascBtn, self.OnClickAscBtn)
	self:AddClick(self.descBtn, self.OnClickDescBtn)
	self:AddClick(self.BtnHelp, self.OnClickHelpBtn)
	self:AddClick(self.BtnHelpClose, self.OnClickHelpClose)
	self:AddClick(self.btn_refresh, self.OnClickRefresh)

	for i = 1, 2 do
		self:AddClick(self["tab" .. i .. "_btn"], self.OnClickTab)
	end

	Event.Instance:Add(EventEnum.ResetCardHpPercent, self.RefreshCardHp, self)
end

function PageChooseRoleCard:OnUnRegisterEvent()
	self:RemoveClick(self.BtnTag, self.OnClickedBtnTag)
	self:RemoveClick(self.detailsSwitchOpen, self.OnClickDetailsSwitchOpen)
	self:RemoveClick(self.detailsSwitchClose, self.OnClickDetailsSwitchClose)
	self:RemoveClick(self.screenBtn, self.OnClickScreenBtn)
	self:RemoveClick(self.ascBtn, self.OnClickAscBtn)
	self:RemoveClick(self.descBtn, self.OnClickDescBtn)
	self:RemoveClick(self.BtnHelp, self.OnClickHelpBtn)
	self:RemoveClick(self.BtnHelpClose, self.OnClickHelpClose)
	self:RemoveClick(self.btn_refresh, self.OnClickRefresh)

	for i = 1, 2 do
		self:RemoveClick(self["tab" .. i .. "_btn"], self.OnClickTab)
	end

	Event.Instance:Remove(EventEnum.ResetCardHpPercent, self.RefreshCardHp, self)
end

function PageChooseRoleCard:OnEnter(vParam)
	self:OnLocalText()

	CardExtraMgr.uiTabType = TenaryOp(CardExtraMgr.uiTabType > 2, 2, CardExtraMgr.uiTabType)
	self.clickSlot = vParam.clickSlot
	self.teamSystemAgent = vParam.teamSystemAgent
	self.teamSystemAgent.screenListState = CardFilterMgr.FilterListRule[eFilterSystemType.Develop]
	self.teamAgent = self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex]
	self.infoStage = vParam.infoStage
	self.listCard = RoleCardMgr:GetAllHoldCard()
	self.screenBtn = self:GetChildGameObject("ScreenBtn")
	self.ascBtn = self:GetChildGameObject("BtnAsc")
	self.descBtn = self:GetChildGameObject("BtnDesc")
	self.BtnHelp = self:GetChildGameObject("BtnHelp")
	self.BtnHelpClose = self:GetChildGameObject("CardList/ScrollAreaHelpCard/btn_help_close")
	self.btn_refresh = self:GetChildGameObject("CardList/ScrollAreaHelpCard/btn_refresh")
	self.BtnTag = self:GetChildGameObject("TopShape/InfoBar/BtnTag")

	local goInfoBar = self:GetChildGameObject("TopShape/InfoBar")

	SetActiveFunc(goInfoBar, self.teamSystemAgent.recommendJob ~= nil or not self.teamSystemAgent.noTeamSumCost)

	for i = 1, 5 do
		self["ImgAtt" .. i] = self:GetChildComponent("TopShape/InfoBar/EnemyType/Img" .. i, "Image")

		SetActiveFunc(self["ImgAtt" .. i].gameObject, false)

		if i == 1 and self.teamSystemAgent.recommendJob then
			SetActiveFunc(self["ImgAtt" .. i].gameObject, true)
			UIUtil.SetImageSprite(self["ImgAtt" .. i], "UI/PanelChooseCard/AtlasPanelChooseCard/ICO_" .. self.teamSystemAgent.recommendJob .. "_01_S", self)
		end
	end

	for i = 1, 2 do
		self["tab" .. i .. "_btn"] = self:GetChildGameObject("CardList/tablist/tab" .. i .. "/btn")
		self["tab" .. i .. "_sel"] = self:GetChildGameObject("CardList/tablist/tab" .. i .. "/sel")
	end

	self.upCardListIds = {}

	for i = 1, #self.teamAgent.slotList do
		if self.teamAgent.slotList[i].upInfoRoleCard then
			local upCardId = self.teamAgent.slotList[i].upInfoRoleCard.id
			local upRoleId = RoleCardMgr:GetRoleId(upCardId)

			self.upCardListIds[i] = {}
			self.upCardListIds[i].upCardId = upCardId
			self.upCardListIds[i].upRoleId = upRoleId
		end
	end

	self.ScrollAreaMyCard = self:GetChildGameObject("CardList/ScrollAreaMyCard")
	self.ScrollArea2 = self:GetChildGameObject("CardList/ScrollArea2")
	self.holdRoleSortList = RoleMgr:GetAllHoldRoleSort(1)

	local teamCostObj = self:GetChildGameObject("TopShape/InfoBar/TeamCost")

	SetActiveFunc(teamCostObj, not self.teamSystemAgent.noTeamSumCost)

	if not self.teamSystemAgent.noTeamSumCost then
		local txtTeamCost = self:GetChildComponent("TopShape/InfoBar/TeamCost/TxtCost", "Text")
		local totalCost = LevelManager:GetMaxCost(PlayerInst:GetCurLv())
		local teamCost = self.teamAgent:GetTeamCost()

		txtTeamCost.text = math.ceil(teamCost) .. "/" .. totalCost
	end

	self.topShape = self:GetChildGameObject("TopShape")
	self.cardList = self:GetChildGameObject("CardList")
	self.tex_num = self:GetChildComponent("BtnHelp/tex_num", "Text")
	self.tex_num2 = self:GetChildComponent("CardList/ScrollAreaHelpCard/Image/tex_num", "Text")

	local maxNum = GetConfigArgInt("FriendHelpMaxTimes")

	self.tex_num.text = maxNum - InfoGameInst:GetFriendHelpTimes() .. "/" .. maxNum
	self.tex_num2.text = string.format(_("Desc_HelpFightTimes"), maxNum - InfoGameInst:GetFriendHelpTimes())
	self.obj_bottomTip = self:GetChildComponent("CardList/Tip")

	if self.clickSlot.isHelperSlot then
		self.helpInfoRoleCardList = TeamSystemAgentMgr.helpInfoRoleCardList or {}
		self.helpInfoRoleList = TeamSystemAgentMgr.helpInfoRoleList or {}
	end

	SetActiveFunc(self.topShape, not self.teamSystemAgent.noBattleBeginBtn)

	if self.clickSlot.isHelperSlot then
		local lx, ly, lz = GOUtil.GetTransformLocalPosition(self.topShape, x, y, z)

		GOUtil.SetTransformLocalPosition(self.topShape, lx, ly, lz)

		lx, ly, lz = GOUtil.GetTransformLocalPosition(self.cardList, x, y, z)

		GOUtil.SetTransformLocalPosition(self.cardList, lx, ly, lz)
		SetActiveFunc(self:GetChildGameObject("CardList/tablist"), true)
		SetActiveFunc(self.BtnHelp, not self.teamSystemAgent.noBattleBeginBtn)
		self:InitScrollHelp()
		self:UpdateTab(CardExtraMgr.uiTabType)
	else
		local lx, ly, lz = GOUtil.GetTransformLocalPosition(self.topShape, x, y, z)

		GOUtil.SetTransformLocalPosition(self.topShape, lx, ly, lz)

		lx, ly, lz = GOUtil.GetTransformLocalPosition(self.cardList, x, y, z)

		GOUtil.SetTransformLocalPosition(self.cardList, lx, ly, lz)
		SetActiveFunc(self.BtnHelp, false)
		SetActiveFunc(self:GetChildGameObject("CardList/tablist"), true)
		self:UpdateTab(CardExtraMgr.uiTabType)
	end

	self.detailsSwitchOpen = self:GetChildGameObject("Open")
	self.detailsSwitchClose = self:GetChildGameObject("Close")

	self:UpdateDetailsSwitch()
	self:UpdateUpDownBtns()

	if self.teamSystemAgent.isGvg then
		SetActiveFunc(self.btn_refresh, false)
		SetActiveFunc(self.obj_bottomTip, true)

		self.tex_num.text = ""
		self.tex_num2.text = ""

		local Text = self:GetChildComponent("CardList/ScrollAreaHelpCard/Image/tex_tips", "Text")

		Text.text = ""

		local g = self:GetChildGameObject("BtnHelp/Text")

		GOUtil.SetRectTransformAnchoredPosition(g, 0, 0)

		g = self:GetChildGameObject("CardList/ScrollAreaHelpCard/bg_title_help/Text")

		SetActiveFunc(g, false)

		g = self:GetChildGameObject("CardList/ScrollAreaHelpCard/bg_title_help/Text_gvg")

		SetActiveFunc(g, true)

		g = self:GetChildGameObject("CardList/Tip")

		SetActiveFunc(g, true)
	end
end

function PageChooseRoleCard:OnClickTab(data)
	local go = data.pointerPress.transform.parent.gameObject
	local index = tonumber(string.sub(go.name, 4, 4))

	CardExtraMgr.uiTabType = index

	CardExtraMgr:SetCardViewPosY(0)
	self:UpdateTab(index)
end

function PageChooseRoleCard:UpdateTab(index)
	self.tabIndex = index

	SetActiveFunc(self["tab" .. 1 .. "_btn"], index ~= 1)
	SetActiveFunc(self["tab" .. 1 .. "_sel"], index == 1)
	SetActiveFunc(self["tab" .. 2 .. "_btn"], index ~= 2)
	SetActiveFunc(self["tab" .. 2 .. "_sel"], index == 2)
	SetActiveFunc(self.ScrollAreaMyCard, index == 1)
	SetActiveFunc(self.ScrollArea2, index == 2)

	if index == 1 then
		if self.UIScrollToolMyCard then
			self:UpdateListCardData()

			self.UIScrollToolMyCard.ScrollView.ScrollViewInitPos = Vector3(0, 0, 0)

			self.UIScrollToolMyCard:SetContentPosImmediate(Vector2(0, 0), self.listCard)
		else
			self:UpdateListCardData()
			self:InitScroll()
		end
	else
		self:UpdateScrollArea2()
	end
end

function PageChooseRoleCard:OnLocalText()
	local TextAuto

	TextAuto = self:GetChildComponent("ScreenBtn/text_Filter/", "Text")
	TextAuto.text = Lang(5000018)
	TextAuto = self:GetChildComponent("BtnAsc/Text/", "Text")
	TextAuto.text = Lang(5000027)
	TextAuto = self:GetChildComponent("BtnDesc/Text/", "Text")
	TextAuto.text = Lang(5000028)
	TextAuto = self:GetChildComponent("TopShape/InfoBar/TeamCost/Text2/", "Text")
	TextAuto.text = Lang(5000029)
	TextAuto = self:GetChildComponent("TopShape/InfoBar/Text/", "Text")
	TextAuto.text = Lang(5000030)
	TextAuto = self:GetChildComponent("CardList/Text", "Text")
	TextAuto.text = Lang(300008)

	local Text = self:GetChildComponent("CardList/tablist/tab2/btn/Text", "Text")

	Text.text = _("Card_Tapy_Chara")
	Text = self:GetChildComponent("CardList/tablist/tab2/sel/Text", "Text")
	Text.text = _("Card_Tapy_Chara")
	Text = self:GetChildComponent("CardList/tablist/tab1/btn/Text", "Text")
	Text.text = _("Card_Tapy_Cards")
	Text = self:GetChildComponent("CardList/tablist/tab1/sel/Text", "Text")
	Text.text = _("Card_Tapy_Cards")
	Text = self:GetChildComponent("CardList/ScrollAreaHelpCard/Image/tex_tips", "Text")
	Text.text = _("Desc_CardPropertyDecline")
end

function PageChooseRoleCard:UpdateUpDownBtns()
	SetActiveFunc(self.ascBtn, self.teamSystemAgent.screenCurSequence == 1)
	SetActiveFunc(self.descBtn, self.teamSystemAgent.screenCurSequence == 0)
end

function PageChooseRoleCard:UpdateDetailsSwitch(type)
	if CardExtraMgr.detailsLookInfo then
		if type then
			UIMgr.ShowMsg(Lang(30060000))
		end

		SetActiveFunc(self.detailsSwitchOpen, false)
		SetActiveFunc(self.detailsSwitchClose, true)
	else
		if type then
			UIMgr.ShowMsg(Lang(30060001))
		end

		SetActiveFunc(self.detailsSwitchOpen, true)
		SetActiveFunc(self.detailsSwitchClose, false)
	end
end

function PageChooseRoleCard:OnClickAscBtn()
	if self.tabIndex == 1 then
		self.teamSystemAgent.screenCurSequence = 0

		self:UpdateUpDownBtns()
		self:UpdateListCardData()

		self.UIScrollToolMyCard.ScrollView.ScrollViewInitPos = Vector3(0, 0, 0)

		self.UIScrollToolMyCard:SetContentPosImmediate(Vector2(0, 0), self.listCard)
	else
		self.teamSystemAgent.screenCurSequence = 0

		self:UpdateUpDownBtns()
		self:UpdateScrollArea2()
	end
end

function PageChooseRoleCard:OnClickDescBtn()
	if self.tabIndex == 1 then
		self.teamSystemAgent.screenCurSequence = 1

		self:UpdateUpDownBtns()
		self:UpdateListCardData()

		self.UIScrollToolMyCard.ScrollView.ScrollViewInitPos = Vector3(0, 0, 0)

		self.UIScrollToolMyCard:SetContentPosImmediate(Vector2(0, 0), self.listCard)
	else
		self.teamSystemAgent.screenCurSequence = 1

		self:UpdateUpDownBtns()
		self:UpdateScrollArea2()
	end
end

function PageChooseRoleCard:RequestHelpData(cb, noMsg)
	local function wrap_cb()
		self.helpInfoRoleCardList = TeamSystemAgentMgr.helpInfoRoleCardList or {}
		self.helpInfoRoleList = TeamSystemAgentMgr.helpInfoRoleList or {}

		if cb then
			cb()
		end
	end

	if self.teamSystemAgent.isGvg then
		TeamSystemAgentMgr:RequestGvgHelperData(wrap_cb, noMsg)
	else
		TeamSystemAgentMgr:RequestHelperData(wrap_cb, noMsg)
	end
end

function PageChooseRoleCard:OnClickHelpBtn()
	if GetConfigArgInt("FriendHelpMaxTimes") - InfoGameInst:GetFriendHelpTimes() == 0 then
		UIMgr.ShowMsg("サポート回数を使い切りました")

		return
	end

	local function cb()
		SetActiveFunc(self.ScrollAreaHelpCard, true)
		self.UIScrollToolHelpCard:UpdateListData(self.helpInfoRoleCardList)
	end

	self:RequestHelpData(cb, true)
end

function PageChooseRoleCard:OnClickHelpClose()
	SetActiveFunc(self.ScrollAreaHelpCard, false)
end

function PageChooseRoleCard:OnClickRefresh()
	local function cb()
		self.UIScrollToolHelpCard:UpdateListData(self.helpInfoRoleCardList)
	end

	self:RequestHelpData(cb)
end

function PageChooseRoleCard:SortFunc()
	local allCardList = {}

	for i, v in ipairs(RoleCardMgr:GetAllHoldCard()) do
		local cardData = RoleCardMgr:GetAllHoldCard()[i]
		local teamAgent = self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex]
		local clickUpCard = self.clickSlot.upInfoRoleCard
		local clickCardId = clickUpCard and clickUpCard.id or 0
		local isUp = teamAgent:GetUpCardIdx(cardData.id) ~= -1

		if isUp then
			cardData.uping = teamAgent:GetUpCardIdx(cardData.id)

			table.insert(allCardList, 1, cardData)
		else
			cardData.uping = false

			table.insert(allCardList, cardData)
		end
	end

	return allCardList
end

function PageChooseRoleCard:UpdateListCardData()
	local allCardList = RoleCardMgr:GetAllHoldCard()

	allCardList = self:SortFunc()

	local curSortType, allCardList = self:FilterListCard(allCardList, self.teamSystemAgent.screenListState)

	if curSortType ~= nil then
		self.teamSystemAgent.screenCurSortType = curSortType
	end

	local value, str = RoleCardMgr:GetFilterRuleNum(self.teamSystemAgent.screenListState)

	if value ~= 0 then
		if value ~= 1 then
			str = _("Desc_ScreenIn")
		end

		self:GetChildComponent("ScreenBtn/text_Filter", "Text").text = str
		self:GetChildComponent("ScreenBtn/img_Filter", "Image").color = Color.New(0.22745098039215686, 0.5137254901960784, 0.23921568627450981, 1)

		UIUtil.SetImageSprite(self:GetChildComponent("ScreenBtn", "Image"), "UI/PanelRoleCard/AtlasPanelCardList/BTN_white_02", self)
	else
		self:GetChildComponent("ScreenBtn/text_Filter", "Text").text = _("Desc_Screen")
		self:GetChildComponent("ScreenBtn/img_Filter", "Image").color = Color.New(0.44313725490196076, 0.44313725490196076, 0.44313725490196076, 1)

		UIUtil.SetImageSprite(self:GetChildComponent("ScreenBtn", "Image"), "UI/PanelRoleCard/AtlasPanelCardList/BTN_white_01", self)
	end

	local limitList = {}
	local notLimitList = {}

	for i, v in ipairs(allCardList) do
		local isNotLimit = self.clickSlot:LimitCheck(v)

		if isNotLimit then
			table.insert(notLimitList, v)
		else
			table.insert(limitList, v)
		end
	end

	notLimitList = self:SortListCard(notLimitList, self.teamSystemAgent.screenCurSortType, self.teamSystemAgent.screenCurSequence)
	limitList = self:SortListCard(limitList, self.teamSystemAgent.screenCurSortType, self.teamSystemAgent.screenCurSequence)
	self.listCard = {}

	local notLimitListSort = {}

	for i, v in ipairs(notLimitList) do
		if notLimitList[i].uping then
			table.insert(notLimitListSort, notLimitList[i])
		end
	end

	for i, v in ipairs(notLimitList) do
		if not notLimitList[i].uping then
			table.insert(notLimitListSort, notLimitList[i])
		end
	end

	for i, v in ipairs(notLimitListSort) do
		table.insert(self.listCard, v)
	end

	for i, v in ipairs(limitList) do
		table.insert(self.listCard, v)
	end

	CardSwitchMgr:ResetCardIdsByBattle(self.listCard)
end

function PageChooseRoleCard:UpdateScrollArea2()
	self.holdRoleSortList = CardFilterMgr:GetFilterRoles(nil, self.teamSystemAgent.screenCurSequence)

	if #self.holdRoleSortList == 0 and not isHelp then
		UIMgr.ShowMsg(_("Desc_NoChoiceCard"))
		SetActiveFunc(self:GetChildGameObject("go_tips"), true)

		self:GetChildComponent("go_tips/Text", "Text").text = _("Desc_NoTypeCard")
	else
		SetActiveFunc(self:GetChildGameObject("go_tips"), false)
	end

	local name, count = CardFilterMgr.GetFilterRoleRuleNameList()

	if count == 0 then
		self:GetChildComponent("ScreenBtn/text_Filter", "Text").text = _("Desc_Screen")
		self:GetChildComponent("ScreenBtn/img_Filter", "Image").color = Color.New(0.44313725490196076, 0.44313725490196076, 0.44313725490196076, 1)

		UIUtil.SetImageSprite(self:GetChildComponent("ScreenBtn", "Image"), "UI/PanelRoleCard/AtlasPanelCardList/BTN_white_01", self)
	else
		if count == 1 then
			self:GetChildComponent("ScreenBtn/text_Filter", "Text").text = name
		elseif count > 1 then
			self:GetChildComponent("ScreenBtn/text_Filter", "Text").text = _("Desc_ScreenIn")
		end

		self:GetChildComponent("ScreenBtn/img_Filter", "Image").color = Color.New(0.22745098039215686, 0.5137254901960784, 0.23921568627450981, 1)

		UIUtil.SetImageSprite(self:GetChildComponent("ScreenBtn", "Image"), "UI/PanelRoleCard/AtlasPanelCardList/BTN_white_02", self)
	end

	if self.UIScrollTool2 then
		self.UIScrollTool2.ScrollView.ScrollViewInitPos = Vector3(0, 0, 0)

		self.UIScrollTool2:SetContentPosImmediate(Vector2(0, 0), self.holdRoleSortList)

		return
	end

	local scrollArea = self:GetChildGameObject("CardList/ScrollArea2")
	local content = self:GetChildComponent("CardList/ScrollArea2/Content", "Transform")
	local count = #self.holdRoleSortList

	local function addCallback(item)
		self:AddClick(item.UIRootObject, nil)
	end

	local function updateCallback(item, index)
		if self.holdRoleSortList[index] then
			local myCardList = {}

			myCardList.teamSystemAgent = self.teamSystemAgent
			myCardList.clickSlot = self.clickSlot
			myCardList.upCardListIds = self.upCardListIds

			item:UpdateData(self.holdRoleSortList[index], CardExtraMgr.detailsLookInfo, myCardList, index, self.UIScrollTool2)
		end
	end

	self.UIScrollTool2 = UIScrollTool()

	self.UIScrollTool2:InitList(scrollArea, content, count, self.PrefabCellCardRoleItem, CellCardRoleItem, self, false, addCallback, updateCallback)

	local posY = CardExtraMgr:GetCardViewPosY()

	if posY ~= 0 then
		self.UIScrollTool2.ScrollView.ScrollViewInitPos = Vector3(0, posY, 0)
	end
end

function PageChooseRoleCard:UpdateHelpCardData()
	local listComb = CombinationMgr:GetAllCombination()
	local listCombValue = {}

	for i = 1, #listComb do
		listCombValue[i] = 0
	end

	local curSortType, listCard = self:FilterListCard(TeamSystemAgentMgr.helpInfoRoleCardList or {}, {
		{
			0,
			0,
			0,
			0,
			0
		},
		listCombValue,
		{
			0,
			0,
			0,
			0,
			0
		},
		{
			0,
			0,
			0,
			0
		}
	}, true)

	listCard = self:SortListCard(listCard, 0, 1)
	self.helpInfoRoleCardList = listCard
	self.helpInfoRoleList = {}

	for i, v in ipairs(self.helpInfoRoleCardList) do
		for i2, v2 in ipairs(TeamSystemAgentMgr.helpInfoRoleList) do
			if v.pbPlayer.playerId == v2.pbPlayer.playerId then
				table.insert(self.helpInfoRoleList, v2)

				break
			end
		end
	end
end

function PageChooseRoleCard:FilterListCard(cardList, listState, isHelp)
	local curSortType
	local listRoleCard = cardList
	local list = {}
	local jobNames = GetConfigArgJson("JobNumber")
	local jobStates = listState[1]

	for i = 1, #jobStates do
		if jobStates[i] > 0 then
			local name = jobNames[i]

			table.insert(list, name)
		end
	end

	if #list > 0 then
		listRoleCard = CardFilterMgr:GetSameJobRoleCard(list, listRoleCard)
	end

	list = {}

	local listTeam = CombinationMgr:GetCombinationSortByTeamOder()
	local teamStates = listState[2]

	for k, v in pairsByKeys(teamStates) do
		if v > 0 then
			local teamId = listTeam[k].id

			table.insert(list, teamId)
		end
	end

	if #list > 0 then
		listRoleCard = CardFilterMgr:GetSameCombRoleCard(list, listRoleCard)
	end

	list = {}

	local teamStates = listState[3]
	local InfoTeam = require("Info/InfoTeam")
	local sameList = {}
	local teams = InfoTeam.stageTeams

	for k, v in pairsByKeys(teamStates) do
		if v > 0 then
			local team = teams[k].roleCardTeams

			for i = 1, #team do
				local isSame = false

				for m = 1, #sameList do
					if sameList[m] == team[i] then
						isSame = true
					end
				end

				table.insert(sameList, team[i])

				if not isSame then
					table.insert(list, team[i])
				end
			end
		end
	end

	if #list > 0 then
		listRoleCard = CardFilterMgr:GetSameTeamRoleCard(list, listRoleCard)
	end

	local sortStates = listState[4]

	for i = 1, #sortStates do
		if sortStates[i] > 0 then
			curSortType = i

			break
		end
	end

	if #listRoleCard == 0 and not isHelp then
		UIMgr.ShowMsg(_("Desc_NoChoiceCard"))
		SetActiveFunc(self:GetChildGameObject("go_tips"), true)

		self:GetChildComponent("go_tips/Text", "Text").text = _("Desc_NoTypeCard")
	else
		SetActiveFunc(self:GetChildGameObject("go_tips"), false)
	end

	return curSortType, listRoleCard
end

function PageChooseRoleCard:SortListCard(cardList, curSortType, curSequence)
	local function funComps(a, b)
		return CardSortMgr:GetCompare4(a, b, curSequence)
	end

	if curSortType == 1 then
		function funComps(a, b)
			return CardSortMgr:GetCompare1(a, b, curSequence)
		end
	elseif curSortType == 2 then
		function funComps(a, b)
			return CardSortMgr:GetCompare2(a, b, curSequence)
		end
	elseif curSortType == 3 then
		function funComps(a, b)
			return CardSortMgr:GetCompare3(a, b, curSequence)
		end
	elseif curSortType == 4 then
		function funComps(a, b)
			return CardSortMgr:GetCompare4(a, b, curSequence)
		end
	end

	table.sort(cardList, funComps)

	return cardList
end

function PageChooseRoleCard:GetCompare1(a, b, style)
	if a.curLevel == b.curLevel then
		if a.rank == b.rank then
			if style == 1 then
				return a.curStarLevel > b.curStarLevel
			else
				return a.curStarLevel < b.curStarLevel
			end
		elseif style == 1 then
			return a.rank > b.rank
		else
			return a.rank < b.rank
		end
	elseif style == 1 then
		return a.curLevel > b.curLevel
	else
		return a.curLevel < b.curLevel
	end
end

function PageChooseRoleCard:GetCompare2(a, b, style)
	if a.rank == b.rank then
		if a.curLevel == b.curLevel then
			if style == 1 then
				return a.curStarLevel > b.curStarLevel
			else
				return a.curStarLevel < b.curStarLevel
			end
		elseif style == 1 then
			return a.curLevel > b.curLevel
		else
			return a.curLevel < b.curLevel
		end
	elseif style == 1 then
		return a.rank > b.rank
	else
		return a.rank < b.rank
	end
end

function PageChooseRoleCard:GetCompare3(a, b, style)
	if a.curStarLevel == b.curStarLevel then
		if a.curLevel == b.curLevel then
			if style == 1 then
				return a.rank > b.rank
			else
				return a.rank < b.rank
			end
		elseif style == 1 then
			return a.curLevel > b.curLevel
		else
			return a.curLevel < b.curLevel
		end
	elseif style == 1 then
		return a.curStarLevel > b.curStarLevel
	else
		return a.curStarLevel < b.curStarLevel
	end
end

function PageChooseRoleCard:GetCompare3(a, b, style)
	if a.curStarLevel == b.curStarLevel then
		if a.curLevel == b.curLevel then
			if style == 1 then
				return a.rank > b.rank
			else
				return a.rank < b.rank
			end
		elseif style == 1 then
			return a.curLevel > b.curLevel
		else
			return a.curLevel < b.curLevel
		end
	elseif style == 1 then
		return a.curStarLevel > b.curStarLevel
	else
		return a.curStarLevel < b.curStarLevel
	end
end

function PageChooseRoleCard:OnClickDetailsSwitchOpen()
	CardExtraMgr.detailsLookInfo = true

	self:UpdateDetailsSwitch(true)
end

function PageChooseRoleCard:OnClickDetailsSwitchClose()
	CardExtraMgr.detailsLookInfo = false

	self:UpdateDetailsSwitch(true)
end

function PageChooseRoleCard:OnClickedBtnTag()
	require("UI/Dlg/Common/DlgPhase")

	local InfoTeam = require("Info/InfoTeam")
	local InfoTeamRaid = require("Info/InfoTeamRaid")
	local InfoTeamBossRaid = require("Info/InfoTeamBossRaid")
	local InfoTeamgGroup = require("Info/InfoTeamgGroup")
	local InfoTeamgGvg = require("Info/InfoTeamGvg")
	local InfoTeamTs = require("Info/InfoTeamTimespace")
	local infoStage = InfoTeam.infoStage

	if self.teamSystemAgent.isRaid then
		if not self.teamSystemAgent.isBossRaid then
			infoStage = InfoTeamRaid.infoStage
		else
			infoStage = InfoTeamBossRaid.infoStage
		end
	end

	if self.teamSystemAgent.isTeamGroup then
		infoStage = InfoTeamgGroup.infoStage
	end

	if self.teamSystemAgent.isGvg then
		infoStage = InfoTeamgGvg.infoStage
	end

	if self.teamSystemAgent.isTimespace then
		infoStage = InfoTeamTs.infoStage
	end

	if self.teamSystemAgent.recommendJob then
		UIMgr.AddPanel(DlgPhase(), {
			infoStage = infoStage,
			recommendJob = self.teamSystemAgent.recommendJob
		})
	end
end

function PageChooseRoleCard:InitScroll()
	local function MyCardUpdate(item, index)
		local cardData = self.listCard[index]

		if cardData == nil then
			return
		end

		item:UpdateData(self.teamSystemAgent, self.clickSlot, cardData, self.upCardListIds, true, self.UIScrollToolMyCard)
	end

	local content = self:GetChildComponent("CardList/ScrollAreaMyCard/Content", "Transform")
	local count = #self.listCard

	self.UIScrollToolMyCard = UIScrollTool()

	self.UIScrollToolMyCard:InitList(self.ScrollAreaMyCard, content, count, self.myRoleCardPreLoad, MyRoleCard, self, false, nil, MyCardUpdate)

	local posY = CardExtraMgr:GetCardViewPosY()

	if posY ~= 0 then
		self.UIScrollToolMyCard.ScrollView.ScrollViewInitPos = Vector3(0, posY, 0)
	end
end

function PageChooseRoleCard:InitScrollHelp()
	self.ScrollAreaHelpCard = self:GetChildGameObject("CardList/ScrollAreaHelpCard")

	local ScrollArea = self:GetChildGameObject("CardList/ScrollAreaHelpCard/ScrollArea")

	if self.clickSlot.isHelperSlot then
		local function HelpCardUpdate(item, index)
			local cardData = self.helpInfoRoleCardList[index]
			local infoData = self.helpInfoRoleList[index]

			item:UpdateData(self.teamSystemAgent, self.clickSlot, cardData, infoData)
		end

		local content = self:GetChildComponent("CardList/ScrollAreaHelpCard/ScrollArea/Content", "Transform")
		local count = #self.helpInfoRoleCardList

		self.UIScrollToolHelpCard = UIScrollTool()

		self.UIScrollToolHelpCard:InitList(ScrollArea, content, count, self.helpCardPreLoad, OtherRoleCard, self, false, nil, HelpCardUpdate)
	end

	SetActiveFunc(self.ScrollAreaHelpCard, false)
end

function PageChooseRoleCard:SwitchScroll()
	return
end

function PageChooseRoleCard:TabClick(index)
	self:SwitchScroll()
end

function PageChooseRoleCard:AddCellClick(item)
	return
end

function PageChooseRoleCard:OnClickScreenBtn()
	if self.tabIndex == 1 then
		local listJob = GetConfigArgJson("JobName")
		local listComb = CombinationMgr:GetCombinationSortByTeamOder()
		local listCombName = {}

		for i = 1, #listComb do
			table.insert(listCombName, listComb[i]:GetName())
		end

		local InfoTeam = require("Info/InfoTeam")
		local teams = InfoTeam.stageTeams
		local listTeam = {}

		for i = 1, 5 do
			if teams[i].name ~= "" then
				table.insert(listTeam, teams[i].name)
			else
				table.insert(listTeam, _("PageBattleTeam_TeamNum") .. teams[i].id)
			end
		end

		local listState = self.teamSystemAgent.screenListState
		local data = {
			{
				filterType = 2,
				title = _("PageRole_TagJob"),
				list = {
					Lang(listJob[1]),
					Lang(listJob[2]),
					Lang(listJob[3]),
					Lang(listJob[4]),
					Lang(listJob[5])
				}
			},
			{
				filterType = 2,
				title = _("eBattleType_2"),
				list = listCombName
			},
			{
				filterType = 2,
				title = _("PageBattleTeam_TeamNum"),
				list = listTeam
			},
			{
				filterType = 1,
				title = _("Filter_Title_AbilitySel"),
				list = {
					_("eSortType_2"),
					_("eSortType_1"),
					_("eSortType_4"),
					_("Desc_Combat_Score")
				}
			},
			panel = self,
			callback = self.ChangeFilter,
			listState = listState
		}

		self.strList = data

		UIMgr.AddPanel(DlgCardFilter(), data)
	else
		local listJob = GetConfigArgJson("JobName")
		local listComb = CombinationMgr:GetCombinationSortByTeamOder()
		local listCombName = {}

		for i = 1, #listComb do
			table.insert(listCombName, listComb[i]:GetName())
		end

		local InfoTeam = require("Info/InfoTeam")
		local teams = InfoTeam.stageTeams
		local listTeam = {}

		for i = 1, 5 do
			if teams[i].name ~= "" then
				table.insert(listTeam, teams[i].name)
			else
				table.insert(listTeam, _("PageBattleTeam_TeamNum") .. teams[i].id)
			end
		end

		local listState = CardFilterMgr.FilterRoleListRule
		local listname = {}

		for i = 1, #RoleMgr:GetAllRole() do
			table.insert(listname, RoleMgr:GetAllRole()[i]:GetName())
		end

		local data = {
			{
				filterType = 2,
				title = _("PageRole_TagJob"),
				list = {
					Lang(listJob[1]),
					Lang(listJob[2]),
					Lang(listJob[3]),
					Lang(listJob[4]),
					Lang(listJob[5])
				}
			},
			{
				filterType = 2,
				title = _("eBattleType_2"),
				list = listCombName
			},
			{
				filterType = 2,
				title = _("PageBattleTeam_TeamNum"),
				list = listTeam
			},
			{
				filterType = 2,
				title = _("IRole"),
				list = listname
			},
			panel = self,
			callback = self.ChangeFilter,
			listState = listState
		}

		UIMgr.AddPanel(DlgCardFilter(), data)
	end
end

function PageChooseRoleCard:ChangeFilter(data)
	local hasChange = data.hasChange

	if hasChange then
		if self.tabIndex == 1 then
			CardFilterMgr.ResetFilterRule(eFilterSystemType.Develop, data.listState)

			self.teamSystemAgent.screenListState = data.listState

			self:UpdateListCardData()

			self.UIScrollToolMyCard.ScrollView.ScrollViewInitPos = Vector3(0, 0, 0)

			self.UIScrollToolMyCard:SetContentPosImmediate(Vector2(0, 0), self.listCard)
		else
			self.holdRoleSortList = CardFilterMgr:GetFilterRoles(data.listState, self.teamSystemAgent.screenCurSequence)

			self:UpdateScrollArea2()
		end
	end
end

function PageChooseRoleCard:RefreshCardHp()
	if self.UIScrollToolMyCard then
		self.UIScrollToolMyCard:UpdateListDataKeepPos(self.listCard)
	end
end
