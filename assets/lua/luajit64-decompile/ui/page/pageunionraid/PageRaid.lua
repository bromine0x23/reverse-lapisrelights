-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageUnionRaid/PageRaid.lua

require("UI/Page/PageUnionRaid/CellRaidEvent")
require("UI/Page/PageUnionRaid/DlgCardHpReply")
require("UI/Page/PageUnionRaid/DlgRaidAwardRecord")

local skillTip = require("UI/Dlg/Common/SkillTipDesc")
local InfoTeamRaid = require("Info/InfoTeamRaid")

PageRaid = class("PageRaid", UIPanel)

function PageRaid:ctor()
	self.UIPrefabPath = "UI/PanelUnionRaid/PanelRaid"
	self.DlgExit = DlgExit()

	self:AddChildPanel(self.DlgExit, {
		title = Lang(2012),
		callback = self.OnBack,
		panel = self
	})
end

function PageRaid:PreLoad()
	self:LoadResAsync("UISpine/UI_Club/UI_Bg_Event/Bg_Club_03", "PrefabBgSpine", GameObject)
	self:LoadResAsync("UI/Common/CellCard/CellCardHp", "PrefabCellCardHp", GameObject)
	self:LoadResAsync("UI/PanelUnionRaid/CellRaidEvent", "PrefabCellEvent", GameObject)
end

function PageRaid:OnBack()
	UIMgr.PopPanel()
end

function PageRaid:Purge()
	self.base.Purge(self)
	self:OnLeave()
end

function PageRaid:OnLeave()
	ResourceMgr.Unload(self.PrefabBgSpine)
	ResourceMgr.Unload(self.PrefabCellCardHp)
	ResourceMgr.Unload(self.PrefabCellEvent)

	if self.listCellEvent then
		for _, cellEvent in ipairs(self.listCellEvent) do
			if cellEvent.OnLeave ~= nil then
				cellEvent:OnLeave()
			end
		end

		self.listCellEvent = nil
	end

	if self.SelCellEvent and self.SelCellEvent.OnLeave ~= nil then
		self.SelCellEvent:OnLeave()

		self.SelCellEvent = nil
	end

	EffectMgr:UnLoadEffect(self.EffectPath1)
	EffectMgr:UnLoadEffect(self.EffectPath2)
	InfoSoundEventMgr:OnBack()
end

function PageRaid:OnRegisterEvent()
	self:AddClick(self.BtnBuffView, self.OnClickedBtnBuffView)
	self:AddClick(self.BtnHpReply, self.OnClickedBtnHpReply)
	self:AddClick(self.BtnCardView, self.OnClickedBtnCardView)
	self:AddClick(self.GoEventDetail, self.OnClickedContinue)

	for i = 1, 3 do
		self:AddClick(self["GoTreasure" .. i].gameObject, self.OnClickTreasureEvent)
		self:AddClick(self["GoBuff" .. i].gameObject, self.OnClickBuffEvent)
	end

	EventListenerMgr.AddAnimListener(self.GoEventGroup, self.PlayBubble, self, eAnimEventType.OnAnimationEnd)
	Event.Instance:Add("UpdateRaidSystem", self.UpdateToRefreshTime, self)
end

function PageRaid:OnUnRegisterEvent()
	self:RemoveClick(self.BtnBuffView, self.OnClickedBtnBuffView)
	self:RemoveClick(self.BtnHpReply, self.OnClickedBtnHpReply)
	self:RemoveClick(self.BtnCardView, self.OnClickedBtnCardView)
	self:RemoveClick(self.GoEventDetail, self.OnClickedContinue)

	for i = 1, 3 do
		self:RemoveClick(self["GoTreasure" .. i].gameObject, self.OnClickTreasureEvent)
		self:RemoveClick(self["GoBuff" .. i].gameObject, self.OnClickBuffEvent)
	end

	EventListenerMgr.RemoveAnimListener(self.GoEventGroup, self.PlayBubble, self, eAnimEventType.OnAnimationEnd)
	Event.Instance:Remove("UpdateRaidSystem", self.UpdateToRefreshTime, self)
end

function PageRaid:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("EventGroup/Text", "Text")
	txt.text = Lang(42506)
	txt = self:GetChildComponent("Panel/BtnCardView/Text", "Text")
	txt.text = _("Desc_Raid_Card_View")
	txt = self:GetChildComponent("Panel/BtnHpReply/Text", "Text")
	txt.text = Lang(42140)
	txt = self:GetChildComponent("Panel/BtnBuffView/Text", "Text")
	txt.text = Lang(42531)
	txt = self:GetChildComponent("EventDetail/Text", "Text")
	txt.text = Lang(42326)
	txt = self:GetChildComponent("Panel/Cheer/Text", "Text")
	txt.text = _("Desc_CheerNum")
	txt = self:GetChildComponent("RaidState/Clear/Image1/Text", "Text")
	txt.text = _("Desc_Pass_Raid_Battle")
	txt = self:GetChildComponent("RaidState/Clear/Image2/Text", "Text")
	txt.text = _("Desc_Reset_Daily")
	txt = self:GetChildComponent("RaidState/Being/Image1/Text", "Text")
	txt.text = _("Desc_Battle_Rate_Raid_Today")
end

function PageRaid:OnEnter(vParam)
	self:DealWithLocalization()

	self.Bg = self:GetChildGameObject("Bg")

	GOUtil.InstantiateUIPrefab(self.PrefabBgSpine, self.Bg)

	self.ImgRateBar = self:GetChildComponent("Panel/Rate/Bar/Image", "Image")
	self.TxtRate = self:GetChildComponent("Panel/Rate/TxtRate", "Text")
	self.ImgRaidIcon = self:GetChildComponent("Panel/Rate/Prompt/Icon", "Image")
	self.TxtBreakPrompt = self:GetChildComponent("Panel/Rate/Prompt/Text", "Text")
	self.TxtPalyNum = self:GetChildComponent("Panel/TxtPlayNum", "Text")
	self.GOCheer = self:GetChildGameObject("Panel/Cheer")
	self.TxtCheerNum = self:GetChildComponent("Panel/Cheer/TxtNum", "Text")
	self.BtnCardView = self:GetChildGameObject("Panel/BtnCardView")
	self.BtnHpReply = self:GetChildGameObject("Panel/BtnHpReply")
	self.BtnBuffView = self:GetChildGameObject("Panel/BtnBuffView")
	self.GoEventGroup = self:GetChildGameObject("EventGroup")
	self.AnimEventGroup = GOUtil.GetComponent(self.GoEventGroup, "Animator")
	self.GoEventSelect = self:GetChildGameObject("EventSelect")
	self.AnimEventSelect = GOUtil.GetComponent(self.GoEventSelect, "Animator")
	self.GoEventDetail = self:GetChildGameObject("EventDetail")
	self.EventDetailAnim = GOUtil.GetComponent(self.GoEventDetail, "Animator")
	self.TxtEventInfo = self:GetChildComponent("EventDetail/Info/Text", "Text")
	self.GoCardPoint = self:GetChildGameObject("EventDetail/CardPoint")
	self.GoClick = self:GetChildGameObject("Click")
	self.GoClear = self:GetChildGameObject("RaidState/Clear")
	self.GoBeing = self:GetChildGameObject("RaidState/Being")
	self.AnimPassRaid = self:GetChildComponent("PassAnim", "Animator")

	for i = 1, 3 do
		self["GoTreasure" .. i] = self:GetChildGameObject("EventDetail/Box/" .. i)
		self["GoBuff" .. i] = self:GetChildGameObject("EventDetail/Buff/" .. i)
		self["ImgBuffIcon" .. i] = self:GetChildComponent("EventDetail/Buff/" .. i .. "/Icon", "Image")
		self["TxtBuffName" .. i] = self:GetChildComponent("EventDetail/Buff/" .. i .. "/TextName", "Text")
		self["TxtBuffDesc" .. i] = self:GetChildComponent("EventDetail/Buff/" .. i .. "/TextDesc", "Text")
	end

	self:Init()
end

function PageRaid:InitEventObjs()
	self.listCellEvent = {}

	for i = 1, self.eventRoundNum do
		local cell = CellRaidEvent(self.PrefabCellEvent, self.GoEventGroup, self)

		cell:Create()

		cell.UIRootObject.name = i

		table.insert(self.listCellEvent, cell)
	end
end

function PageRaid:InitSelEventObj()
	self.SelCellEvent = CellRaidEvent(self.PrefabCellEvent, self.GoEventSelect, self)

	self.SelCellEvent:Create()
end

function PageRaid:InitCardHp()
	self.CellCardHp = CellCardHp(self.PrefabCellCardHp, self.GoCardPoint, self)

	self.CellCardHp:Create()
end

function PageRaid:UpdateToRefreshTime(refrashType)
	if refrashType == eRefreshType.Daily then
		self:UpdatePlayNum()

		if not self.infoRaid:IsFinished() then
			self:UpdateEvent()
		end
	elseif refrashType == eRefreshType.Weekly then
		self:UpdatePanel()
		self:UpdateEvent()
	end
end

function PageRaid:Init()
	self.infoRaid = UnionRaidMgr.beingCommRaid
	self.eventRoundNum = self.infoRaid.eventRoundNum
	self.loadedCnt = 0
	self.EffectPath1 = "Fx/UI/FX_UI_UnionRaid/FX_PanelRaid_Poison"
	self.EffectPath2 = "Fx/UI/FX_UI_UnionRaid/FX_PanelRaid_Cure"
	self.listScore = {}

	for _, config in ipairs(GetConfigArgJson("ClubMirrorContributionAward")) do
		if config[1] ~= nil then
			table.insert(self.listScore, config[1])
		end
	end

	self.TxtBreakPrompt.text = string.format(_("Desc_Raid_Mirror_Break_Rate"), Lang(self.infoRaid.data.Name[1]))

	SetImageSprite(self.ImgRaidIcon, "UI/PanelUnionRaid/AtlasPanelRaid/bg_maze_door_s0" .. self.infoRaid.id, self)
	self:UpdatePanel()
	self:UpdateEvent()
end

function PageRaid:UpdatePanel()
	self:UpdatePlayNum()
	self:UpdateRate()
	self:UpdateCheerNum()
end

function PageRaid:UpdatePlayNum()
	self.TxtPalyNum.text = string.format(_("Desc_Raid_Cheer_Num_Today"), "<color=#FFCB6E>" .. UnionRaidMgr.maxCommPlayNum - UnionRaidMgr.GetPlayNum(eRaidType.Common) .. "</color>/" .. UnionRaidMgr.maxCommPlayNum)
end

function PageRaid:UpdateRate()
	self.TxtRate.text = self.infoRaid.progress .. "/" .. self.infoRaid.data.FinishPoint

	local rate = self.infoRaid.progress / self.infoRaid.data.FinishPoint

	self.ImgRateBar.fillAmount = TenaryOp(rate > 1, 1, rate)
end

function PageRaid:UpdateCheerNum()
	local curContributionValue = UnionRaidMgr.GetContributionValue()

	self.TxtCheerNum.text = "<color=#00FFE7>" .. curContributionValue .. "</color>/" .. self.listScore[#self.listScore]
end

function PageRaid:UpdateBattle()
	local max = self.infoRaid.data.Round

	max = TenaryOp(max > 5, 5, max)

	for i = 1, max do
		local go = self:GetChildGameObject("RaidState/Being/Bat/" .. i .. "/" .. i)

		GOUtil.SetActive(go, i <= self.infoRaid.battleSum)
	end
end

function PageRaid:UpdateEvent()
	if not UnionMgr.HasUnion(true) then
		self:OnBack()

		return
	end

	self.EventDetailAnim:Play("Anim_Raid_EventDetail_Idle")

	if self.infoRaid:IsFinished() then
		self:DealWithRaidCantContinue(1)

		return
	end

	GOUtil.SetActive(self.GoClear, self.infoRaid:IsBattlePass())
	GOUtil.SetActive(self.GoBeing, not self.infoRaid:IsBattlePass())

	if self.infoRaid:IsBattlePass() then
		if not self.infoRaid.isPlayedPassAnim then
			self.AnimPassRaid:Play("Anim_Raid_Pass")

			self.infoRaid.isPlayedPassAnim = true
		end

		return
	else
		self:UpdateBattle()
	end

	if self.infoRaid:IsSelEvent() then
		self:UpdateSelectEvent()
	elseif self.infoRaid:IsToBeSelEvent() then
		self:UpdateEventData()
	else
		self:RandomEvent()
	end
end

function PageRaid:RandomEvent()
	if not UnionMgr.HasUnion() then
		UIMgr.ShowMsg(_("Msg_Leave_Union_Current_Support"))

		self.timer = TimerMgr.AddTimer(eTimerType.ScaleTime, 1.5, function()
			self:OnBack()

			self.timer = nil
		end, {})

		return
	end

	self:DealWithRaidRate()

	if self.infoRaid:IsFinished() then
		self:DealWithRaidCantContinue(1)

		return
	end

	if not UnionRaidMgr:IsPlayNumEnough(eRaidType.Common) then
		-- block empty
	end

	if not self.infoRaid:IsEventRoundEnough() then
		self:DealWithRaidCantContinue(3)

		return
	end

	self.HaveUpdatedSelEvent = false

	self.infoRaid:RandomEvent()
	self:UpdateEventData()
end

function PageRaid:DealWithRaidCantContinue(_type)
	if _type == 1 then
		self.TxtEventInfo.text = _("Desc_Current_Raid_End")
	elseif _type == 2 then
		self.TxtEventInfo.text = _("Msg_Cnt_NotEnough")
	elseif _type == 3 then
		self.TxtEventInfo.text = _("Msg_Event_Round_Not_Enough")
	end

	self.EventDetailAnim:Play("Anim_Raid_EventDetail_Error")
end

function PageRaid:UpdateEventData()
	if not self.listCellEvent then
		self:InitEventObjs()
	end

	self.listEvent = self.infoRaid.events

	for k, cell in ipairs(self.listCellEvent) do
		cell:UpdateData(self.listEvent[k], true)
	end
end

function PageRaid:UpdateSelectEvent()
	if self.SelCellEvent == nil then
		self:InitSelEventObj()
	end

	if not self.HaveUpdatedSelEvent then
		self.SelCellEvent:UpdateData(self.infoRaid.event)

		self.HaveUpdatedSelEvent = true
	end

	self.AnimEventSelect:Play("Anim_Raid_EventSelect_Open")
	self.SelCellEvent:PlayBubble()
end

function PageRaid:OnLoadedFinish()
	if not self.loadedCnt or not self.eventRoundNum then
		return
	end

	if self.loadedCnt >= self.eventRoundNum then
		self.AnimEventGroup:Play("Anim_Raid_EventGroup_Open")

		self.loadedCnt = 0
	end
end

function PageRaid:PlayBubble()
	if not self.listCellEvent then
		return
	end

	for k, event in ipairs(self.listEvent) do
		if self.listCellEvent[k] then
			self.listCellEvent[k]:PlayBubble()
		end
	end
end

function PageRaid:SelectEvent(index)
	index = index or 1

	local infoEvent = self.infoRaid.events[index]

	if not infoEvent then
		return
	end

	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			GOUtil.SetActive(self.GoClick, true)

			local twnner = GOUtil.DOScaleAll(self.listCellEvent[index].UIRootObject.transform, 1.3, 0.3)

			GOUtil.SetTweenerCallback(twnner, function()
				self:UpdatePanel()
				self.AnimEventGroup:Play("Anim_Raid_EventGroup_Idle")
				self:DealWithEventShowOff()
			end)
		elseif vMsg.result.code == 2 then
			PageUnion.GoBackMainPage(vMsg)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)

			if vMsg.result.code == 3 then
				local function cb()
					self:OnBack()
				end

				require("UI/Page/PageUnionRaid/PageUnionRaid")
				PageUnionRaid.RequestData(cb)
			end
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestSelectEvent(self.infoRaid.id, infoEvent.id, wrap_cb)
end

function PageRaid:DealSelectedEvent()
	self:DealWithEventShowOff()
	self.AnimEventSelect:Play("Anim_Raid_EventSelect_Close")
end

function PageRaid:RolePlayVoice(_type)
	local listUpCardId = InfoTeamRaid:GetUpRoleCardList()
	local num = math.random(1, #listUpCardId)
	local role

	if listUpCardId[num] ~= 0 then
		role = RoleCardMgr:GetRole(listUpCardId[num])
	else
		role = RoleMgr:GetMaxFavorRole()
	end

	if role ~= nil then
		InfoSoundEventMgr:LoadBank(role.data.VocalBank)

		if _type == 1 then
			InfoSoundEventMgr:Play("VocalCommon11", role.data.VocalCommon11)
		elseif _type == 2 or _type == 3 then
			InfoSoundEventMgr:Play("VocalCommon6", role.data.VocalCommon6)
		elseif _type == 4 or _type == 5 then
			InfoSoundEventMgr:Play("VocalCommon2", role.data.VocalCommon2)
		elseif _type == 6 then
			InfoSoundEventMgr:Play("VocalCommon3", role.data.VocalCommon3)
		end
	end
end

function PageRaid:DealWithEventShowOff()
	local event = self.infoRaid.event

	self.TxtEventInfo.text = Lang(event.data.Info)

	local eventType = event.data.Type

	self:RolePlayVoice(eventType)

	if eventType == eRaidEventType.Battle then
		GOUtil.SetActive(self.GoClick, false)
		self:DealWithEvent()
	elseif eventType == eRaidEventType.Restore or eventType == eRaidEventType.Relive then
		self.Eff_Event2 = EffectMgr:Alloc(self.EffectPath2, self.UIRootObject)

		local function ShowEventPrompt()
			GOUtil.SetActive(self.GoClick, false)

			local function NoneCardFun()
				self.TxtEventInfo.text = _("Msg_Relive_Card_None")

				self.EventDetailAnim:Play("Anim_Raid_EventDetail_Open")
			end

			if event.result == nil or next(event) == nil then
				NoneCardFun()

				return
			end

			if eventType == eRaidEventType.Relive then
				if next(event.result) ~= nil then
					local infoRoleCard = RoleCardMgr:GetRoleCard(event.result[1])

					if self.CellCardHp == nil then
						self:InitCardHp()
					end

					self.CellCardHp:UpdateData(infoRoleCard, true)
					self.EventDetailAnim:Play("Anim_Raid_EventDetail_Open_WithCard")

					local function cb()
						local function callback()
							self.EventDetailAnim:Play("Anim_Raid_EventDetail_Loop_WithCard")
						end

						if self.CellCardHp then
							self.CellCardHp:UpdateHpPercent(event.value or 0, callback)
						end

						self.timer2 = nil
					end

					self.timer2 = TimerMgr.AddTimer(eTimerType.ScaleTime, 0.8, cb, {})
				else
					NoneCardFun()
				end
			else
				self.EventDetailAnim:Play("Anim_Raid_EventDetail_Open")
			end

			self.timer1 = nil
		end

		self.timer1 = TimerMgr.AddTimer(eTimerType.ScaleTime, 1, ShowEventPrompt, {})
	elseif eventType == eRaidEventType.Treasure then
		GOUtil.SetActive(self.GoClick, false)
		self.EventDetailAnim:Play("Anim_Raid_EventDetail_Treasure")
	elseif eventType == eRaidEventType.Buff then
		GOUtil.SetActive(self.GoClick, false)

		for i = 1, 3 do
			if event and event.result then
				local info = InfoTalent(event.result[i])

				if info then
					SetImageSprite(self["ImgBuffIcon" .. i], "UIDyAtlas/Skill/" .. info.data.Icon, self)

					self["TxtBuffName" .. i].text = Lang(info.data.Name)
					self["TxtBuffDesc" .. i].text = skillTip.GetDesc(info.id, 1, 0)
				end
			end
		end

		self.EventDetailAnim:Play("Anim_Raid_EventDetail_Buff")
	end
end

function PageRaid:OnClickedContinue()
	if self.Eff_Event1 then
		EffectMgr:Free(self.Eff_Event1)

		self.Eff_Event1 = nil
	end

	if self.Eff_Event2 then
		EffectMgr:Free(self.Eff_Event2)

		self.Eff_Event2 = nil
	end

	if self.timer1 then
		TimerMgr.RemoveTimer(self.timer1)

		self.timer1 = nil
	end

	if self.timer2 then
		TimerMgr.RemoveTimer(self.timer2)

		self.timer2 = nil
	end

	if self.timer3 then
		TimerMgr.RemoveTimer(self.timer3)

		self.timer3 = nil
	end

	self.EventDetailAnim:Play("Anim_Raid_EventDetail_Idle")
	self:DealWithEvent()
end

function PageRaid:DealWithEvent()
	local event = self.infoRaid.event

	if event == nil then
		return
	end

	local function panelCb()
		self:UpdateSelectEvent()
	end

	if event.data.Type == eRaidEventType.Battle then
		require("UI/Page/PageCombatReadiness/PageCombatReadiness")

		ChapterMgr.PageCombatReadinessType = 2

		UIMgr.AddPanel(PageCombatReadiness(), {
			stageId = event.result[1],
			panelCb = panelCb
		})
	elseif event.data.Type == eRaidEventType.Treasure or event.data.Type == eRaidEventType.Buff then
		if self.isReduceHp then
			self:ContinueRandom()

			self.isReduceHp = false
		else
			panelCb()
		end
	else
		if event.result and next(event.result) ~= nil then
			for _, cardId in ipairs(event.result) do
				local infoRoleCard = RoleCardMgr:GetRoleCard(cardId)

				if infoRoleCard then
					infoRoleCard:ChangeClubCardHpPercent(event.value or 0)
				end
			end
		end

		self:ContinueRandom()
	end
end

function PageRaid:ContinueRandom()
	UnionRaidMgr.ShowRaidRateUp = true

	UnionRaidMgr:FinishEvent()
	self:UpdatePanel()
	self:RandomEvent()
end

function PageRaid:OnClickTreasureEvent(data)
	local index = tonumber(data.pointerPress.name)

	self:DealWithSpecialEvent(self.infoRaid.event.id)
end

function PageRaid:OnClickBuffEvent(data)
	local index = tonumber(data.pointerPress.name)
	local buffId = self.infoRaid.event.result[index]

	if buffId ~= nil then
		if UnionRaidMgr.HasSameBuff(buffId) then
			local function cb(_type)
				if _type == DlgCommonEvent.ButtonType.Ok then
					self:DealWithSpecialEvent(self.infoRaid.event.id, buffId)
				end
			end

			UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), _("ClubMirror_BuffTip_2"), cb, _("UI_confirm"), _("Quite_Cancel"))
		else
			self:DealWithSpecialEvent(self.infoRaid.event.id, buffId)
		end
	end
end

function PageRaid:DealWithSpecialEvent(eventId, buffId)
	local function wrap_cb(vMsg)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vMsg.result.code == NetManager.Result_Sucess then
			self.EventDetailAnim:Play("Anim_Raid_EventDetail_Idle")

			if buffId ~= nil then
				UnionRaidMgr.AddCanUseBuff(buffId)
				self:ContinueRandom()
			elseif vMsg.eventValue and vMsg.eventValue ~= 0 and type(vMsg.eventValue) == "number" then
				self.isReduceHp = true

				GOUtil.SetActive(self.GoClick, true)

				self.Eff_Event1 = EffectMgr:Alloc(self.EffectPath1, self.UIRootObject)

				local listCard = RoleCardMgr:GetAllHoldCard()

				for i = 1, #listCard do
					listCard[i]:ChangeClubCardHpPercent(0 - vMsg.eventValue)
				end

				local function ShowEventPrompt()
					self:RolePlayVoice(6)

					self.TxtEventInfo.text = string.format(_("Msg_Reduce_HP_All_Card"), vMsg.eventValue .. "%")

					self.EventDetailAnim:Play("Anim_Raid_EventDetail_Open")
					GOUtil.SetActive(self.GoClick, false)

					self.timer3 = nil
				end

				self.timer3 = TimerMgr.AddTimer(eTimerType.ScaleTime, 1, ShowEventPrompt, {})
			end
		elseif vMsg.result.code == 2 then
			PageUnion.GoBackMainPage(vMsg)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end
	end

	local panelCb

	if buffId == nil then
		function panelCb()
			self:ContinueRandom()
		end
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestReceiveRaidAward(self.infoRaid.id, eventId, buffId, wrap_cb, panelCb)
end

function PageRaid:DealWithRaidRate()
	if UnionRaidMgr.ShowRaidRateUp then
		if self.infoRaid.event and self.infoRaid.event.state then
			local addRate = 0

			if self.infoRaid.event.data.Type == eRaidEventType.Battle then
				addRate = self.infoRaid.event:GetAddRate(self.infoRaid.battleSum)
			else
				addRate = self.infoRaid.event:GetAddRate()
			end

			local addCheer = self.infoRaid.event:GetAddContribution()
			local str = ""

			if addRate > 0 or addCheer > 0 then
				if addRate > 0 then
					str = string.format(_("Msg_Raid_Progress_Add"), "+" .. addRate)
				end

				if addCheer > 0 then
					str = str .. " " .. _("Desc_CheerNum") .. "+" .. addCheer

					self.GOCheer.transform:DOScale(1.2, 0.5):OnComplete(function()
						self.GOCheer.transform:DOScale(1, 0.5)
					end)
				end

				if self.infoRaid.event.data.Type == eRaidEventType.Buff then
					str = _("Msg_Raid_Event_Buff_Sucess") .. " " .. str
				end

				UIMgr.ShowMsg(str)
			end
		end

		UnionRaidMgr.ShowRaidRateUp = false
	end
end

function PageRaid:OnClickedBtnCardView()
	require("UI/Page/PageUnionRaid/DlgRaidCardView")
	UIMgr.AddPanel(DlgRaidCardView())
end

function PageRaid:OnClickedBtnHpReply()
	require("UI/Page/PageUnionRaid/DlgCardHpReply")
	UIMgr.AddPanel(DlgCardHpReply())
end

function PageRaid:OnClickedBtnBuffView()
	require("UI/Page/PageUnionRaid/DlgRaidBuff")
	UIMgr.AddPanel(DlgRaidBuff())
end

function PageRaid:OnBackAndroid()
	if self.Eff_Event1 or self.Eff_Event2 then
		self:OnClickedContinue()

		return true
	end

	local buffGo = self:GetChildGameObject("EventDetail/Buff")

	if GOUtil.IsActiveSelf(buffGo) then
		return true
	end

	return false
end
