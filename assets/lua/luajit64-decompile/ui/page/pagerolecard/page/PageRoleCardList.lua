-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageRoleCard/Page/PageRoleCardList.lua

require("UI/UIScrollTool")
require("UI/Page/PageRoleCard/Cell/CellCard")
require("UI/Page/PageRoleCard/Page/PageRoleCard")
require("UI/Page/PageRoleCard/Cell/CellCardRoleItem")

local InfoTeam = require("Info/InfoTeam")

PageRoleCardList = class("PageRoleCardList", UIPanel, true)

function PageRoleCardList:ctor()
	self.base.ctor(self, "UI/PanelRoleCard/PanelRoleCardList")
	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_RoleCardList"),
		callback = self.OnBack,
		panel = self
	})
end

function PageRoleCardList:PreLoad()
	self:LoadResAsync("UI/Common/CellCard/CellCard", "PrefabCell")
	self:LoadResAsync("UI/PanelRoleCard/CellCardRoleItem", "PrefabCellCardRoleItem")
end

function PageRoleCardList:OnBack()
	CardExtraMgr:ResetCardViewPosY()
	UIMgr.PopPanel()
end

function PageRoleCardList:Purge()
	self.base.Purge(self)
	self:OnLeave()

	local SceneData = SceneMgr.GetCurrentScene().SceneData
end

function PageRoleCardList:OnLeave()
	if self.UIScrollTool ~= nil then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.UIScrollTool2 ~= nil then
		self.UIScrollTool2:Purge()

		self.UIScrollTool2 = nil
	end

	if self.UIScrollTool3 ~= nil then
		self.UIScrollTool3:Purge()

		self.UIScrollTool3 = nil
	end

	ResourceMgr.Unload(self.PrefabCellCardRoleItem)
	ResourceMgr.Unload(self.PrefabCell)
	InfoSoundEventMgr:UnloadBank(PATH_BANK_DRAWCARDUR)
end

function PageRoleCardList:OnRegisterEvent()
	self:AddClick(self.BtnAsce, self.OnClickedBtnAsce)
	self:AddClick(self.BtnDesce, self.OnClickedBtnDesce)
	self:AddClick(self.BtnFilter, self.OnClickedBtnFilter)
	self:AddClick(self.BtnTeam, self.OnClickedBtnTeam)
	self:AddClick(self.btn_open, self.OnClickedBtnOpen)

	for i = 1, 3 do
		self:AddClick(self["GoTab" .. i], self.OnClickTab)
	end

	Event.Instance:Add(EventEnum.UpdateStage, self.UpdatePanel, self)
	Event.Instance:Add("DealWithShowCard", self.DealWithShowCard, self)
	Event.Instance:Add("RefreshUIScrollTooPosition", self.RefreshUIScrollTooPosition, self)
	Event.Instance:Add(EventEnum.UpdateItemDataNotify, self.UpdateItemDataNotify, self)
end

function PageRoleCardList:OnUnRegisterEvent()
	self:RemoveClick(self.BtnAsce, self.OnClickedBtnAsce)
	self:RemoveClick(self.BtnDesce, self.OnClickedBtnDesce)
	self:RemoveClick(self.BtnFilter, self.OnClickedBtnFilter)
	self:RemoveClick(self.BtnTeam, self.OnClickedBtnTeam)
	self:RemoveClick(self.btn_open, self.OnClickedBtnOpen)

	for i = 1, 3 do
		self:RemoveClick(self["GoTab" .. i], self.OnClickTab)
	end

	Event.Instance:Remove(EventEnum.UpdateStage, self.UpdatePanel, self)
	Event.Instance:Remove("DealWithShowCard", self.DealWithShowCard, self)
	Event.Instance:Remove("RefreshUIScrollTooPosition", self.RefreshUIScrollTooPosition, self)
	Event.Instance:Remove(EventEnum.UpdateItemDataNotify, self.UpdateItemDataNotify, self)
end

function PageRoleCardList:OnEnter(vParam)
	self:DealWithLocalization()

	local SceneData = SceneMgr.GetCurrentScene().SceneData

	if SceneData.BGM ~= "" then
		local event = SceneData.BGM

		SoundMgr.PostEvent("Set_Upgrade", UIMgr.UICamera.gameObject)
	end

	self.BtnAsce = self:GetChildGameObject("Panel/BtnAsc")
	self.BtnDesce = self:GetChildGameObject("Panel/BtnDesc")
	self.BtnFilter = self:GetChildGameObject("Panel/BtnFilter")
	self.BtnTeam = self:GetChildGameObject("Panel/BtnTeam")
	self.btn_open = self:GetChildGameObject("Panel/btn_open")
	self.img_open = self:GetChildComponent("Panel/btn_open", "Image")

	for i = 1, 3 do
		self["GoTab" .. i] = self:GetChildGameObject("Panel/tablist/tab" .. i)
		self["tab" .. i .. "_btn"] = self:GetChildGameObject("Panel/tablist/tab" .. i .. "/btn")
		self["tab" .. i .. "_sel"] = self:GetChildGameObject("Panel/tablist/tab" .. i .. "/sel")
	end

	self.ScrollArea = self:GetChildGameObject("Panel/CardList/ScrollArea")
	self.ScrollArea2 = self:GetChildGameObject("Panel/CardList/ScrollArea2")
	self.ScrollArea3 = self:GetChildGameObject("Panel/CardList/ScrollArea3")
	self.CanvasGroup = self:GetChildComponent("", "CanvasGroup")
	CardExtraMgr.detailsLookInfo = false

	self:InitData(vParam)
	self:UpdateTab(CardExtraMgr.uiTabType)

	if InstructionMgr:IsInGuide() then
		self:SwitchDetailToggle(false)
	end

	SetActiveFunc(self.BtnTeam, CardExtraMgr.enterType ~= eEnterType.cardShow)
	InfoSoundEventMgr:LoadBank(PATH_BANK_DRAWCARDUR)
end

function PageRoleCardList:OnClickTab(data)
	local go = data.pointerPress.gameObject
	local index = tonumber(string.sub(go.name, 4, 4))

	if self.tabIndex == index then
		return
	end

	CardExtraMgr.uiTabType = index

	CardExtraMgr:SetCardViewPosY(0)
	self:UpdateTab(index)
end

function PageRoleCardList:UpdateTab(index)
	self.tabIndex = index

	SetActiveFunc(self["tab" .. 1 .. "_btn"], index ~= 1)
	SetActiveFunc(self["tab" .. 1 .. "_sel"], index == 1)
	SetActiveFunc(self["tab" .. 2 .. "_btn"], index ~= 2)
	SetActiveFunc(self["tab" .. 2 .. "_sel"], index == 2)
	SetActiveFunc(self["tab" .. 3 .. "_btn"], index ~= 3)
	SetActiveFunc(self["tab" .. 3 .. "_sel"], index == 3)
	SetActiveFunc(self.ScrollArea, index == 1)
	SetActiveFunc(self.ScrollArea2, index == 2)
	SetActiveFunc(self.ScrollArea3, index == 3)
	self:UpdatePanel()

	if self.tabIndex == 3 then
		CardRDL.ComposeRDL.DealViewd()
	end
end

function PageRoleCardList:DealWithLocalization()
	local Text = self:GetChildComponent("Panel/BtnAsc/Text", "Text")

	Text.text = Lang(5000027)
	Text = self:GetChildComponent("Panel/BtnDesc/Text", "Text")
	Text.text = Lang(5000028)
	Text = self:GetChildComponent("Panel/BtnTeam/Text", "Text")
	Text.text = Lang(12937)
	Text = self:GetChildComponent("Panel/BtnFilter/Layout/text_Filter", "Text")
	Text.text = Lang(5000018)
	Text = self:GetChildComponent("Panel/tablist/tab2/btn/Text", "Text")
	Text.text = _("Card_Tapy_Chara")
	Text = self:GetChildComponent("Panel/tablist/tab2/sel/Text", "Text")
	Text.text = _("Card_Tapy_Chara")
	Text = self:GetChildComponent("Panel/tablist/tab1/btn/Text", "Text")
	Text.text = _("Card_Tapy_Cards")
	Text = self:GetChildComponent("Panel/tablist/tab1/sel/Text", "Text")
	Text.text = _("Card_Tapy_Cards")
end

function PageRoleCardList:InitData(vParam)
	if vParam and vParam.entType then
		CardExtraMgr:SetEnterType(vParam.entType)

		if vParam.showIdx then
			self.showIdx = vParam.showIdx
		end
	end

	self.tabIndex = CardExtraMgr.uiTabType
end

function PageRoleCardList:InitPanel()
	SetActiveFunc(self.BtnTeam, CardExtraMgr.enterType ~= eEnterType.cardShow)
	self:UpdatePanel()
end

function PageRoleCardList:UpdatePanel(isSort)
	local sortType = CardFilterMgr.FilterSortRule[eFilterSystemType.Develop]

	SetActiveFunc(self.BtnAsce, sortType == eSortType.Desce)
	SetActiveFunc(self.BtnDesce, sortType == eSortType.Asce)

	if self.tabIndex == 1 then
		self:UpdateCardScroll(isSort)

		if self.UIScrollTool2 then
			self.UIScrollTool2:UpdateListData({})
		end

		if self.UIScrollTool3 then
			self.UIScrollTool3:UpdateListData({})
		end
	elseif self.tabIndex == 2 then
		self:UpdateScrollArea2(isSort)

		if self.UIScrollTool then
			self.UIScrollTool:UpdateListData({})
		end

		if self.UIScrollTool3 then
			self.UIScrollTool3:UpdateListData({})
		end
	else
		SetActiveFunc(self.BtnAsce, not CardFilterMgr.FilterSortSoul)
		SetActiveFunc(self.BtnDesce, CardFilterMgr.FilterSortSoul)
		self:UpdateScrollArea3()

		if self.UIScrollTool then
			self.UIScrollTool:UpdateListData({})
		end

		if self.UIScrollTool2 then
			self.UIScrollTool2:UpdateListData({})
		end
	end

	self:UpdateDot()
end

function PageRoleCardList:UpdateCardScroll(isSort)
	local systemType = eFilterSystemType.Develop

	if not self.listCard then
		self.listCard = {}
	end

	if not isSort then
		self.listCard = {}
		self.listCard = CardFilterMgr.GetFilterCards(systemType)
	else
		local function reverseTable(tab)
			local tmp = {}

			for i = 1, #tab do
				tmp[i] = table.remove(tab)
			end

			return tmp
		end

		self.listCard = reverseTable(self.listCard)
	end

	local list = CardFilterMgr.GetFilterRuleNameList(systemType)

	if #list == 0 then
		self:GetChildComponent("Panel/BtnFilter/Layout/text_Filter", "Text").text = _("Desc_Screen")
		self:GetChildComponent("Panel/BtnFilter/Layout/img_Filter", "Image").color = Color.New(0.44313725490196076, 0.44313725490196076, 0.44313725490196076, 1)

		UIUtil.SetImageSprite(self:GetChildComponent("Panel/BtnFilter", "Image"), "UI/PanelRoleCard/AtlasPanelCardList/BTN_white_01", self)
	else
		if #list == 1 then
			self:GetChildComponent("Panel/BtnFilter/Layout/text_Filter", "Text").text = list[1]
		elseif #list > 1 then
			self:GetChildComponent("Panel/BtnFilter/Layout/text_Filter", "Text").text = _("Desc_ScreenIn")
		end

		self:GetChildComponent("Panel/BtnFilter/Layout/img_Filter", "Image").color = Color.New(0.22745098039215686, 0.5137254901960784, 0.23921568627450981, 1)

		UIUtil.SetImageSprite(self:GetChildComponent("Panel/BtnFilter", "Image"), "UI/PanelRoleCard/AtlasPanelCardList/BTN_white_02", self)
	end

	SetActiveFunc(self:GetChildGameObject("Panel/complete"), false)

	if #self.listCard == 0 then
		SetActiveFunc(self:GetChildGameObject("Panel/go_tips"), true)

		self:GetChildComponent("Panel/go_tips/Text", "Text").text = _("Desc_NoTypeCard")
	else
		SetActiveFunc(self:GetChildGameObject("Panel/go_tips"), false)
	end

	if self.UIScrollTool then
		self.UIScrollTool.ScrollView.ScrollViewInitPos = Vector3(0, 0, 0)

		TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
			self.UIScrollTool:UpdateListData(self.listCard)
		end, nil)

		return
	end

	local scrollArea = self:GetChildGameObject("Panel/CardList/ScrollArea")
	local content = self:GetChildComponent("Panel/CardList/ScrollArea/Content", "Transform")
	local count = #self.listCard

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.OnClickedCell)
	end

	local function updateCallback(item, index)
		local info = self.listCard[index]
		local data = {
			isGrade = true,
			cardId = info.id,
			team = InfoTeam.stageTeams[tonumber(RoleCardMgr:GetTeamListIndex())].roleCardTeams
		}

		item:UpdateData(data)
	end

	self.UIScrollTool = UIScrollTool()

	self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCell, CellCard, self, false, addCallback, updateCallback)

	local posY = CardExtraMgr:GetCardViewPosY()

	if posY ~= 0 then
		self.UIScrollTool.ScrollView.ScrollViewInitPos = Vector3(0, posY, 0)
	end
end

function PageRoleCardList:OnUpdate()
	return
end

function PageRoleCardList:RefreshUIScrollTooPosition()
	if self.UIScrollTool2 then
		local posY = self.UIScrollTool2.ScrollView.content.anchoredPosition.y

		CardExtraMgr:SetCardViewPosY(posY)
	end
end

function PageRoleCardList:UpdateScrollArea2(isSort)
	local sortType = CardFilterMgr.FilterSortRule[eFilterSystemType.Develop]

	self.holdRoleSortList = CardFilterMgr:GetFilterRoles(nil, sortType)

	local name, count = CardFilterMgr.GetFilterRoleRuleNameList()

	if count == 0 then
		self:GetChildComponent("Panel/BtnFilter/Layout/text_Filter", "Text").text = _("Desc_Screen")
		self:GetChildComponent("Panel/BtnFilter/Layout/img_Filter", "Image").color = Color.New(0.44313725490196076, 0.44313725490196076, 0.44313725490196076, 1)

		UIUtil.SetImageSprite(self:GetChildComponent("Panel/BtnFilter", "Image"), "UI/PanelRoleCard/AtlasPanelCardList/BTN_white_01", self)
	else
		if count == 1 then
			self:GetChildComponent("Panel/BtnFilter/Layout/text_Filter", "Text").text = name
		elseif count > 1 then
			self:GetChildComponent("Panel/BtnFilter/Layout/text_Filter", "Text").text = _("Desc_ScreenIn")
		end

		self:GetChildComponent("Panel/BtnFilter/Layout/img_Filter", "Image").color = Color.New(0.22745098039215686, 0.5137254901960784, 0.23921568627450981, 1)

		UIUtil.SetImageSprite(self:GetChildComponent("Panel/BtnFilter", "Image"), "UI/PanelRoleCard/AtlasPanelCardList/BTN_white_02", self)
	end

	SetActiveFunc(self:GetChildGameObject("Panel/complete"), false)

	if #self.holdRoleSortList == 0 then
		SetActiveFunc(self:GetChildGameObject("Panel/go_tips"), true)

		self:GetChildComponent("Panel/go_tips/Text", "Text").text = _("Desc_NoTypeCard")
	else
		SetActiveFunc(self:GetChildGameObject("Panel/go_tips"), false)
	end

	local count = #self.holdRoleSortList

	if self.UIScrollTool2 then
		self.UIScrollTool2.ScrollView.ScrollViewInitPos = Vector3(0, 0, 0)

		TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
			self.UIScrollTool2:UpdateListData(self.holdRoleSortList)
		end, nil)

		return
	end

	local scrollArea = self:GetChildGameObject("Panel/CardList/ScrollArea2")
	local content = self:GetChildComponent("Panel/CardList/ScrollArea2/Content", "Transform")

	local function addCallback(item)
		self:AddClick(item.UIRootObject, nil)
	end

	local isPlayed = {}

	local function updateCallback(item, index)
		if self.holdRoleSortList[index] then
			item.UIRootObject.name = "cell"

			item:UpdateData(self.holdRoleSortList[index], CardExtraMgr.detailsLookInfo, nil, index, self.UIScrollTool2)

			if isPlayed[index] == nil then
				isPlayed[index] = true

				item:SetAlpha(0)
			end
		end
	end

	self.UIScrollTool2 = UIScrollTool()

	local posY = CardExtraMgr:GetCardViewPosY()

	if posY ~= 0 then
		-- block empty
	end

	self.UIScrollTool2:InitList(scrollArea, content, count, self.PrefabCellCardRoleItem, CellCardRoleItem, self, false, addCallback, updateCallback)

	if posY ~= 0 then
		self.UIScrollTool2.ScrollView.ScrollViewInitPos = Vector3(0, posY, 0)
	end
end

function PageRoleCardList:UpdateScrollArea3()
	self.listCard = CardFilterMgr.GetComnposeCards()

	if not CardFilterMgr.FilterSortSoul then
		local function reverseTable(tab)
			local tmp = {}

			for i = 1, #tab do
				tmp[i] = table.remove(tab)
			end

			return tmp
		end

		self.listCard = reverseTable(self.listCard)
	end

	local name, count = CardFilterMgr.GetFilterSoulRuleNameList()

	if count == 0 then
		self:GetChildComponent("Panel/BtnFilter/Layout/text_Filter", "Text").text = _("Desc_Screen")
		self:GetChildComponent("Panel/BtnFilter/Layout/img_Filter", "Image").color = Color.New(0.44313725490196076, 0.44313725490196076, 0.44313725490196076, 1)

		UIUtil.SetImageSprite(self:GetChildComponent("Panel/BtnFilter", "Image"), "UI/PanelRoleCard/AtlasPanelCardList/BTN_white_01", self)
	else
		if count == 1 then
			self:GetChildComponent("Panel/BtnFilter/Layout/text_Filter", "Text").text = name
		elseif count > 1 then
			self:GetChildComponent("Panel/BtnFilter/Layout/text_Filter", "Text").text = _("Desc_ScreenIn")
		end

		self:GetChildComponent("Panel/BtnFilter/Layout/img_Filter", "Image").color = Color.New(0.22745098039215686, 0.5137254901960784, 0.23921568627450981, 1)

		UIUtil.SetImageSprite(self:GetChildComponent("Panel/BtnFilter", "Image"), "UI/PanelRoleCard/AtlasPanelCardList/BTN_white_02", self)
	end

	if #RoleCardMgr:GetAllNotHoldCard() == 0 then
		SetActiveFunc(self:GetChildGameObject("Panel/complete"), true)
		SetActiveFunc(self:GetChildGameObject("Panel/go_tips"), false)

		self:GetChildComponent("Panel/complete/Text", "Text").text = "すごい！\n全カード獲得だね★"
	elseif #self.listCard == 0 then
		SetActiveFunc(self:GetChildGameObject("Panel/go_tips"), true)

		self:GetChildComponent("Panel/go_tips/Text", "Text").text = _("Desc_NoTypeCard")

		SetActiveFunc(self:GetChildGameObject("Panel/complete"), false)
	else
		SetActiveFunc(self:GetChildGameObject("Panel/complete"), false)
		SetActiveFunc(self:GetChildGameObject("Panel/go_tips"), false)
	end

	if self.UIScrollTool3 then
		self.UIScrollTool3.ScrollView.ScrollViewInitPos = Vector3(0, 0, 0)

		TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
			self.UIScrollTool3:UpdateListData(self.listCard)
		end, nil)

		return
	end

	local scrollArea = self:GetChildGameObject("Panel/CardList/ScrollArea3")
	local content = self:GetChildComponent("Panel/CardList/ScrollArea3/Content", "Transform")
	local count = #self.listCard

	local function addCallback(item)
		self:AddClick(item.UIRootObject, self.onShowCard)
	end

	local function updateCallback(item, index)
		local info = self.listCard[index]
		local complete, aim = RoleCardMgr.CheckCardCompose(info)
		local data = {
			isGrade = true,
			cardId = info.id,
			team = InfoTeam.stageTeams[tonumber(RoleCardMgr:GetTeamListIndex())].roleCardTeams,
			complete = complete,
			now = info.pb.soul,
			aim = aim
		}

		item:UpdateData(data, eEnterType.cardCompose)
	end

	self.UIScrollTool3 = UIScrollTool()

	self.UIScrollTool3:InitList(scrollArea, content, count, self.PrefabCell, CellCard, self, false, addCallback, updateCallback)

	local posY = CardExtraMgr:GetCardViewPosY()

	if posY ~= 0 then
		self.UIScrollTool3.ScrollView.ScrollViewInitPos = Vector3(0, posY, 0)
	end
end

function PageRoleCardList:onShowCard(data)
	local go = data.pointerPress.gameObject
	local info = self.UIScrollTool3.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index
	local infodata = self.listCard[index]
	local complete, aim = RoleCardMgr.CheckCardCompose(infodata)

	if complete then
		local function OnCallback(index)
			if DlgCommonEvent.ButtonType.Ok == index then
				local function wrap_cb(vMsg)
					LoadingMgr.Hide(eLoadingType.Repeat)

					if vMsg.result.code == NetManager.Result_Sucess then
						self.listRoleCard = {}

						local setter = SetterData.GetSetterData(vMsg.setter)

						setter:Parse()

						local sd

						for _, s in ipairs(setter.list) do
							if s.asset == protocol_pb.RC_RECEIVE or s.asset == protocol_pb.I_SOUL then
								table.insert(self.listRoleCard, s)
							end
						end

						self.index = 1

						self:AddDraw()
						self:UpdatePanel()
					elseif vMsg.result.code == NetManager.Result_Timeout then
						local strContent = _("Desc_NoNetwork")

						UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), strContent, function()
							Restart()
						end, _("UI_OK"), nil, false)
					else
						UIMgr.ShowMsg(vMsg.result.desc, vMsg)
					end
				end

				LoadingMgr.Show(eLoadingType.Repeat)
				NetManager:RequestExchangeRoleCard(infodata.id, wrap_cb)
			end
		end

		local strAlert = string.format(_("Desc_CardSynthesisWarning"), aim)

		UIMgr.ShowCommon(DlgCommonEvent.Type.Msg2, _("Desc_Alert"), strAlert, OnCallback, nil, nil, nil, true)
	else
		UIMgr.ShowMsg(_("Mag_Fragment_Not_Enough"))
	end
end

function PageRoleCardList:AddDraw()
	local isClose = false

	self.CanvasGroup.blocksRaycasts = false

	if self.index > #self.listRoleCard then
		self.CanvasGroup.blocksRaycasts = true

		GOUtil.SetActive(self.UIRootObject, true)

		return
	end

	self.showAddDraw = true

	local sd = self.listRoleCard[self.index]
	local hasChangeStar = not sd.newRoleCard or not (sd.newRoleCard.id > 0)

	self.index = self.index + 1

	if hasChangeStar then
		self.showAddDraw = false

		self:AddDraw()
	else
		local hasNewRole = sd.newRole and sd.newRole.id > 0
		local infoRoleCard = RoleCardMgr:GetRoleCard(sd.id)
		local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)

		local function showDlgDrawOne()
			require("UI/Page/PageCardShop/DlgDrawOne")
			UIMgr.AddPanel(DlgDrawOne(), {
				enterback = function()
					Event.Instance:Fire("CloseURCardShow")
					Event.Instance:Fire("CloseNewRoleUnlock")
				end,
				callback = function()
					if not isClose then
						GOUtil.SetActive(self.UIRootObject, false)

						isClose = true
					end

					self.showAddDraw = false

					self:AddDraw()
				end,
				setter = sd
			})
		end

		local function showURcardShow()
			if infoRoleCard.rank == "ur" then
				require("UI/Page/PageCardShop/DlgURCardShow")
				UIMgr.AddPanel(DlgURCardShow(), {
					enterback = function()
						Event.Instance:Fire("CloseNewRoleUnlock")
					end,
					endback = function()
						if not isClose then
							GOUtil.SetActive(self.UIRootObject, false)

							isClose = true
						end

						showDlgDrawOne()
					end,
					infoRole = infoRole,
					infoRoleCard = infoRoleCard
				})
			else
				showDlgDrawOne()
			end
		end

		local function showNewRoleUnlock()
			if hasNewRole then
				require("UI/Page/PageCardShop/DlgNewRoleUnlock")
				UIMgr.AddPanel(DlgNewRoleUnlock(), {
					endback = function()
						if not isClose then
							GOUtil.SetActive(self.UIRootObject, false)

							isClose = true
						end

						showURcardShow()
					end,
					infoRole = infoRole
				})
			else
				showURcardShow()
			end
		end

		showNewRoleUnlock()
	end
end

function PageRoleCardList:OnClickedCell(data)
	local go = data.pointerPress.gameObject
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)
	local index = info.Item.Index
	local cardId = self.listCard[index].id

	if not CardExtraMgr.detailsLookInfo then
		if CardExtraMgr.enterType ~= eEnterType.cardShow then
			local posY = self.UIScrollTool.ScrollView.content.anchoredPosition.y

			CardExtraMgr:SetCardViewPosY(posY)

			local data = {
				cardId = cardId
			}

			if CardExtraMgr.enterType == eEnterType.cardMain then
				CardSwitchMgr:ResetCardIdsByFilter(eFilterSystemType.Develop)

				data.tag = 1
			end

			UIMgr.SwitchPanel(PageRoleCard, data)
		else
			self:DealWithShowCard(cardId)
		end
	else
		local param = {}

		param.call = nil
		param.infoRoleCard = self.listCard[index]

		require("UI/Page/PageTeam/DlgCardDetail")
		UIMgr.AddPanel(DlgCardDetail(), param)
	end
end

function PageRoleCardList:OnClickedBtnAsce()
	if self.tabIndex == 1 then
		CardFilterMgr.ResetSortRule(eFilterSystemType.Develop, eSortType.Asce)
		self:UpdatePanel(true)
	elseif self.tabIndex == 2 then
		CardFilterMgr.ResetSortRule(eFilterSystemType.Develop, eSortType.Asce)
		self:UpdatePanel(true)
	else
		CardFilterMgr.FilterSortSoul = not CardFilterMgr.FilterSortSoul

		self:UpdatePanel(true)
	end
end

function PageRoleCardList:OnClickedBtnDesce()
	if self.tabIndex == 1 then
		CardFilterMgr.ResetSortRule(eFilterSystemType.Develop, eSortType.Desce)
		self:UpdatePanel(true)
	elseif self.tabIndex == 2 then
		CardFilterMgr.ResetSortRule(eFilterSystemType.Develop, eSortType.Desce)
		self:UpdatePanel(true)
	else
		CardFilterMgr.FilterSortSoul = not CardFilterMgr.FilterSortSoul

		self:UpdatePanel(true)
	end
end

function PageRoleCardList:OnClickedBtnFilter()
	if self.tabIndex == 1 then
		local chioceStruct = CardFilterMgr.FilterStruct[eFilterSystemType.Develop]
		local data = {}

		for k, v in ipairs(chioceStruct) do
			data[k] = v
		end

		data.panel = self
		data.callback = self.ChangeFilter
		data.listState = CardFilterMgr.FilterListRule[eFilterSystemType.Develop]

		UIMgr.AddPanel(DlgCardFilter(), data)
	elseif self.tabIndex == 2 then
		local listJob = GetConfigArgJson("JobName")
		local listComb = CombinationMgr:GetAllCombination()
		local listCombName = {}

		for i = 1, #listComb do
			table.insert(listCombName, listComb[i]:GetName())
		end

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
	else
		local chioceStruct = CardFilterMgr.FilterSoulStruct
		local data = {}

		for k, v in ipairs(chioceStruct) do
			data[k] = v
		end

		data.panel = self
		data.callback = self.ChangeFilter
		data.listState = CardFilterMgr.FilterSoulRule

		UIMgr.AddPanel(DlgCardFilter(), data)
	end
end

function PageRoleCardList:OnClickedBtnOpen()
	self:SwitchDetailToggle(not CardExtraMgr.detailsLookInfo)
end

function PageRoleCardList:SwitchDetailToggle(isShow)
	CardExtraMgr.detailsLookInfo = isShow

	if isShow then
		SetImageSprite(self.img_open, "UI/PanelRoleCard/AtlasPanelCardList/BTN_info_open", self)
	else
		SetImageSprite(self.img_open, "UI/PanelRoleCard/AtlasPanelCardList/BTN_info_close", self)
	end
end

function PageRoleCardList:ChangeFilter(data)
	if data.hasChange then
		if self.tabIndex == 1 then
			CardFilterMgr.ResetFilterRule(eFilterSystemType.Develop, data.listState)
			self:UpdatePanel()
		elseif self.tabIndex == 2 then
			local sortType = CardFilterMgr.FilterSortRule[eFilterSystemType.Develop]

			self.holdRoleSortList = CardFilterMgr:GetFilterRoles(data.listState, sortType)

			self:UpdateScrollArea2()
		else
			CardFilterMgr.FilterSoulRule = data.listState

			self:UpdateScrollArea3()
		end
	end
end

function PageRoleCardList:OnClickedBtnTeam()
	local function callback(...)
		InfoTeam.teamSystemAgent.recommendJob = nil
		InfoTeam.teamSystemAgent.monsterJob = nil
		InfoTeam.teamSystemAgent.noBattleBeginBtn = true
		InfoTeam.teamSystemAgent.noCounter = true
		InfoTeam.teamSystemAgent.teamIndex = tonumber(RoleCardMgr:GetTeamListIndex())
		InfoTeam.teamSystemAgent.localBattleTeam = true

		UIMgr.SwitchPanel(PageTeam, InfoTeam.teamSystemAgent)
	end

	InfoTeam:EnterStage(ChapterMgr:GetStage(10002))
	callback()
end

function PageRoleCardList.DirectlyShowTeam()
	local function callback(...)
		InfoTeam.teamSystemAgent.recommendJob = nil
		InfoTeam.teamSystemAgent.monsterJob = nil
		InfoTeam.teamSystemAgent.noBattleBeginBtn = true
		InfoTeam.teamSystemAgent.noCounter = true
		InfoTeam.teamSystemAgent.teamIndex = tonumber(RoleCardMgr:GetTeamListIndex())
		InfoTeam.teamSystemAgent.localBattleTeam = true

		UIMgr.SwitchPanel(PageTeam, InfoTeam.teamSystemAgent)
	end

	InfoTeam:EnterStage(ChapterMgr:GetStage(10002))
	callback()
end

function PageRoleCardList:DealWithShowCard(cardId)
	if PlayerInst.InfoPlayer.roleCards[self.showIdx] == cardId then
		self:OnBack()

		return
	end

	local listShowCard = {}

	for i = 1, #PlayerInst.InfoPlayer.roleCards do
		listShowCard[i] = PlayerInst.InfoPlayer.roleCards[i]
	end

	local curShowIdx = self.showIdx

	for k, v in pairs(listShowCard) do
		if v == 0 and k <= self.showIdx then
			curShowIdx = k

			break
		end
	end

	local preShowIdx = self.showIdx

	for k, v in pairs(listShowCard) do
		if v == cardId and k ~= self.showIdx then
			preShowIdx = k
		end
	end

	listShowCard[preShowIdx] = listShowCard[curShowIdx]
	listShowCard[curShowIdx] = cardId

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat, 13)

		if vMsg.result.code == NetManager.Result_Sucess then
			PlayerInst.InfoPlayer.roleCards = listShowCard

			UIMgr.ShowMsg(_("Msg_ChangeCardTips"))
			self:OnBack()
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat, 13)
	NetManager:RequestModifyPlayerInfo({
		roleCards = listShowCard
	}, wrap_cb)
end

function PageRoleCardList:UpdateItemDataNotify()
	if self.UIScrollTool3 then
		self.UIScrollTool3:UpdateListDataKeepPos(self.listCard)
	end
end

function PageRoleCardList:UpdateDot(tag)
	RedDotSystemMgr.SetUIRedDot(self.GoTab3, "Card/Compose")
end
