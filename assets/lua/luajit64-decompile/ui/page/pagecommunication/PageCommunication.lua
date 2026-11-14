-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCommunication/PageCommunication.lua

require("Info/InfoTopic")
require("UI/Page/PageCommunication/CellChat")
require("UI/Page/PageCommunication/CellTopic")

eCommuState = {
	WaitAnswer = 5,
	InChat = 4,
	LoadStory = 2,
	WaitTopic = 1,
	WaitRead = 6,
	StartChat = 3
}

local READEDPATH = "UI/PageCommunication/AtlasCommunication/BG_Writingpaper_line_04"
local UNREADEDPATH = "UI/PageCommunication/AtlasCommunication/BG_Writingpaper_line_06"

PageCommunication = class("PageCommunication", UIPanel)

function PageCommunication:ctor()
	self.UIPrefabPath = "UI/PageCommunication/PageCommunication"

	if ScenarioKit.IsScenarioEditMode() then
		-- block empty
	else
		self:AddChildPanel(DlgExit(), {
			hideMapBtn = false,
			type = 2,
			title = _("eReturn_commc"),
			callback = self.OnBack,
			panel = self
		})
	end
end

function PageCommunication:PreLoad()
	self.PrefabCell = ResourceMgr.LoadSync("UI/PageCommunication/CellChat")
	self.PrefabCellTopic = ResourceMgr.LoadSync("UI/PageCommunication/CellTopic")
end

function PageCommunication:Purge()
	PageCommunication.base.Purge(self)

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

	if self.timer4 then
		TimerMgr.RemoveTimer(self.timer3)

		self.timer4 = nil
	end

	for i = 1, #self.listChatCells do
		local item = self.listChatCells[i]

		item:OnLeave()
	end
end

function PageCommunication:OnRegisterEvent()
	self:AddClick(self.ButtonHistroy, self.OnClickedHistroy)
	self:AddClick(self.ButtonSend, self.OnClickedSend)
	self:AddClick(self.InputBar, self.OnClickedInputBar)
	self:AddClick(self.ButtonSkip, self.OnClickedSkip)

	for i = 1, 2 do
		self:AddClick(self["Answer" .. i], self.OnClickedAnswer)
	end

	EventListenerMgr.AddAnimListener(self.img_Favor.gameObject, self.EventAnim, self, eAnimEventType.OnAnimationEnd)
end

function PageCommunication:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonHistroy, self.OnClickedHistroy)
	self:RemoveClick(self.ButtonSend, self.OnClickedSend)
	self:RemoveClick(self.InputBar, self.OnClickedInputBar)
	self:RemoveClick(self.ButtonSkip, self.OnClickedSkip)

	for i = 1, 2 do
		self:RemoveClick(self["Answer" .. i], self.OnClickedAnswer)
	end

	EventListenerMgr.RemoveAnimListener(self.img_Favor.gameObject, self.EventAnim, self, eAnimEventType.OnAnimationEnd)
end

function PageCommunication:OnEnter(vParam)
	self.roleId = vParam.roleId
	self.topicId = vParam.topicId

	self:DealWithLocalization()

	self.ButtonHistroy = self:GetChildGameObject("Panel/ButtonHistroy")
	self.ButtonSend = self:GetChildGameObject("Panel/ChatPanel/InputBar/Button")
	self.AnswerPanel = self:GetChildGameObject("Panel/ChatPanel/AnswerPanel")

	for i = 1, 2 do
		self["Answer" .. i] = self:GetChildGameObject("Panel/ChatPanel/AnswerPanel/" .. i)
		self["AnswerSel" .. i] = self:GetChildGameObject("Panel/ChatPanel/AnswerPanel/" .. i .. "/Sel")
		self["AnswerText" .. i] = self:GetChildComponent("Panel/ChatPanel/AnswerPanel/" .. i .. "/Text", "Text")
		self["GoAward" .. i] = self:GetChildGameObject("Panel/ChatPanel/AnswerPanel/" .. i .. "/Gift")
	end

	self.ChatPanel = self:GetChildGameObject("Panel/ChatPanel")
	self.ChatPos = self.ChatPanel.transform.localPosition
	self.GoNew = self:GetChildGameObject("Panel/ChatPanel/InputBar/new")
	self.InputBar = self:GetChildGameObject("Panel/ChatPanel/InputBar")
	self.TextInput = self:GetChildComponent("Panel/ChatPanel/InputBar/Mask/Text", "Text")
	self.UIWalking = self:GetChildComponent("Panel/ChatPanel/InputBar/Mask", "UIWalkingLantern")
	self.GoMask = self:GetChildGameObject("Panel/ChatPanel/InputBar/mask")
	self.GoWaitSign = self:GetChildGameObject("Panel/ChatPanel/InputBar/waitSign")
	self.listSectIcon = GetConfigArgJson("FavorRankIcon")
	self.img_Favor = self:GetChildGameObject("Panel/Effect/img_Favor2")
	self.TextFavor = self:GetChildComponent("Panel/Effect/img_Favor2/Text", "Text")
	self.img_FavorAni = self:GetChildComponent("Panel/Effect/img_Favor2", "Animator")
	self.EndTopic = self:GetChildGameObject("Panel/ChatPanel/EndTopic")
	self.TextName = self:GetChildComponent("Panel/ChatPanel/Name", "Text")

	if RoleCardMgr ~= nil then
		self.infoRole = RoleMgr:GetRole(self.roleId)
		self.TextName.text = self.infoRole:GetCommuName()
	end

	self.ButtonSkip = self:GetChildGameObject("Panel/SkipBtn")
	self.EffProjector = self:GetChildGameObject("Panel/Projector")

	self.EffProjector:SetActive(false)
	self:InitData()
	self:InitScrollView()

	self.RawImage = self:GetChildGameObject("Panel/RawImage")

	self:UpdatePanel()
	self:DealWithLastTopic()
end

function PageCommunication:HideBg()
	self.RawImage:SetActive(false)
end

function PageCommunication:ShowBg()
	self.RawImage:SetActive(true)
end

function PageCommunication:OnBack()
	if ScenarioKit.Instance then
		local saveData = ScenarioKit.Instance.saveLoad:Save()
		local topicId = SceneCommunication.Instance.topicId
		local infoTopic = TopicManager:GetTopic(topicId)

		if infoTopic.pb.status == 0 then
			local function wrap_cb(vPBMessage)
				LoadingMgr.Hide(eLoadingType.Repeat)

				if vPBMessage.result.code == NetManager.Result_Sucess then
					infoTopic.pb.record = saveData

					SceneMgr.LoadScene("MainStage", {
						from = 1,
						tabType = 1,
						roleId = self.roleId
					})
				else
					UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
				end
			end

			NetManager:RequestEndTopic(topicId, 0, 1, saveData, wrap_cb)
			LoadingMgr.Show(eLoadingType.Repeat)
		else
			SceneMgr.LoadScene("MainStage", {
				from = 1,
				tabType = 1,
				roleId = self.roleId
			})
		end
	else
		SceneMgr.LoadScene("MainStage", {
			from = 1,
			tabType = 1,
			roleId = self.roleId
		})
	end
end

function PageCommunication:DealWithLocalization()
	return
end

function PageCommunication:InitData()
	self.listChat = {}
	self.listTopic = TopicManager:GetListTopic(self.roleId, 0)
	self.isContinue = false
	self.hasNewTopic = true

	if SceneCommunication.Instance ~= nil and self.topicId ~= nil then
		SceneCommunication.Instance:LoadStory(self.topicId)
	else
		self.state = eCommuState.WaitTopic
	end
end

function PageCommunication:DealWithLastTopic()
	if self.infoRole == nil then
		local lastTopicId = 1
	else
		local lastTopicId = self.infoRole.pb.lastTopicId
	end

	if lastTopicId and lastTopicId > 0 then
		self:LoadChat(lastTopicId)
		TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
			self.UIScrollTool:SetFinalPos()
		end, nil)
		self:UpdatePanel()
	end
end

function PageCommunication:LoadChat(topicId)
	return
end

function PageCommunication:InitScrollView()
	self.chatScrollArea = self:GetChildGameObject("Panel/ChatPanel/ScrollArea")
	self.chatContent = self:GetChildComponent("Panel/ChatPanel/ScrollArea/Viewport/Content", "Transform")
	self.listChatCells = {}
	self.verticalScrollbar = self:GetChildComponent("Panel/ChatPanel/Scrollbar", "Scrollbar")
end

function PageCommunication:UpdateCell(item, index)
	local chatData = self.listChat[index]

	item:UpdateData(chatData)
end

function PageCommunication:AddCellClick(item)
	self:AddClick(item.UIRootObject, self.OnClickedCell)
end

function PageCommunication:OnClickedCell(data)
	local go = data.pointerPress
	local info = self.UIScrollTool.ItemRoot2ItemDict:GetValue(go)

	if info.Item.Index == self.selectIndex then
		return
	end

	self.selectIndex = info.Item.Index
end

function PageCommunication:OnClickedInputBar()
	if self.state == eCommuState.WaitTopic then
		self.AnswerPanel:SetActive(false)
	elseif self.state == eCommuState.WaitAnswer then
		self.AnswerPanel:SetActive(true)
	end

	self.GoWaitSign:SetActive(false)
end

function PageCommunication:UpdatePanel()
	if self.state == eCommuState.WaitTopic then
		self.AnswerPanel:SetActive(false)
		self.GoNew:SetActive(self.hasNewTopic)
		self.GoMask:SetActive(false)
		self.GoWaitSign:SetActive(false)

		if #self.listTopic <= 0 then
			self.GoNew:SetActive(false)
			self.GoMask:SetActive(true)
		end

		self.EffProjector:SetActive(false)
	elseif self.state == eCommuState.LoadStory then
		-- block empty
	elseif self.state == eCommuState.StartChat then
		self.ButtonSkip:SetActive(true)

		if ScenarioKit.IsScenarioEditMode() then
			-- block empty
		else
			self.ChatPanel.transform:DOLocalMoveX(388, 0.4)
		end

		self.InputBar:SetActive(true)
		self.EndTopic:SetActive(false)

		self.state = eCommuState.InChat

		self.EffProjector:SetActive(false)
	end

	if self.listChatCells then
		self.listChat = {}

		for i = 1, #self.listChatCells do
			local item = self.listChatCells[i]

			item:OnLeave()
		end

		GOUtil.DestroyAllChildren(self.chatContent.gameObject)
	end
end

function PageCommunication:UpdateChat(chatData)
	self.state = eCommuState.InChat

	if self.listChat[#self.listChat] == nil or self.listChat[#self.listChat].flag == 0 then
		table.insert(self.listChat, chatData)

		local item = CellChat(self.PrefabCell, self.chatContent.gameObject, self)

		item:Create()
		item:UpdateData(chatData)
		table.insert(self.listChatCells, item)
		UIUtil.ForceRebuildLayoutImmediate(item.UIRootObject)
	else
		self.listChat[#self.listChat] = chatData

		self.listChatCells[#self.listChatCells]:UpdateData(chatData)
		UIUtil.ForceRebuildLayoutImmediate(self.listChatCells[#self.listChatCells].UIRootObject)
	end

	UIUtil.ForceRebuildLayoutImmediate(self.chatContent.gameObject)

	self.timer3 = TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
		self.verticalScrollbar.value = 0
	end, nil)

	self.GoMask:SetActive(true)
	self.GoNew:SetActive(false)
	self.GoWaitSign:SetActive(false)
end

function PageCommunication:DealEndChat()
	local chatData = self.listChat[#self.listChat]

	if chatData and chatData.flag == 1 then
		Object.Destroy(self.listChatCells[#self.listChatCells].UIRootObject)
		table.remove(self.listChat, #self.listChat)
		table.remove(self.listChatCells, #self.listChatCells)
	end
end

function PageCommunication:UpdateAnswerList(listAnswer)
	self.state = eCommuState.WaitAnswer

	for i = 1, 2 do
		self["Answer" .. i]:SetActive(false)
		self["AnswerSel" .. i]:SetActive(false)
	end

	for i = 1, #listAnswer do
		local answer = listAnswer[i]

		self["Answer" .. i]:SetActive(true)

		self["AnswerText" .. i].text = answer.Text

		if answer.PrizeId ~= nil and answer.PrizeId ~= "" and InfoGameInst ~= nil and not InfoGameInst:IsGetScenarioReward(answer.DialogId) then
			self["GoAward" .. i]:SetActive(true)
		else
			self["GoAward" .. i]:SetActive(false)
		end
	end

	self.TextInput.gameObject:SetActive(true)

	self.TextInput.text = ""
	self.UIWalking.enabled = false
	self.curAnswerIndex = 0
	self.listAnswer = listAnswer

	self.GoMask:SetActive(false)
	self.GoWaitSign:SetActive(true)
end

function PageCommunication:OnClickedAnswer(data)
	local go = data.pointerPress
	local index = tonumber(go.name)

	self.curAnswerIndex = index

	for i = 1, 2 do
		self["AnswerSel" .. i]:SetActive(false)
	end

	self["AnswerSel" .. index]:SetActive(true)

	local answer = self.listAnswer[index]

	self.TextInput.text = answer.Text

	if self.TextInput.preferredWidth > self.UIWalking.transform.rect.width then
		GOUtil.SetRectTransformAnchoredPosition(self.TextInput.gameObject, self.UIWalking.transform.rect.width, 0)

		self.UIWalking.enabled = true
	else
		GOUtil.SetRectTransformAnchoredPosition(self.TextInput.gameObject, 0, 0)

		self.UIWalking.enabled = false
	end

	self.AnswerPanel:SetActive(false)
end

function PageCommunication:OnClickedSend()
	if self.curAnswerIndex == 0 then
		return
	end

	if self.state == eCommuState.WaitAnswer then
		self.GoMask:SetActive(true)

		self.TextInput.text = ""
		self.UIWalking.enabled = false
		self.state = eCommuState.WaitRead

		local answer = self.listAnswer[self.curAnswerIndex]

		if answer.PrizeId ~= nil and answer.PrizeId ~= "" and InfoGameInst ~= nil and not InfoGameInst:IsGetScenarioReward(answer.DialogId) then
			local function callback(vPBMessage)
				LoadingMgr.Hide(eLoadingType.Repeat)
				ScenarioKit.Instance.Events.OnSelectLua:Dispatch(answer)
				self.AnswerPanel:SetActive(false)

				if vPBMessage.result.code == NetManager.Result_Sucess then
					require("UI/Dlg/Common/DlgStoryAward")

					local function awardCallback()
						self:DealWithAwardFavorExp(vPBMessage.setter)
					end

					UIMgr.AddPanel(DlgStoryAward(), {
						setter = vPBMessage.setter,
						callback = awardCallback
					})
				end
			end

			NetManager:RequestAnswerReward(answer.DialogId, tonumber(answer.PrizeId), callback)
			LoadingMgr.Show(eLoadingType.Repeat)
		else
			ScenarioKit.Instance.Events.OnSelectLua:Dispatch(answer)
			self.AnswerPanel:SetActive(false)
		end
	end
end

function PageCommunication:UpdateAnswer(chatData)
	local item = self.listChatCells[#self.listChatCells]

	item.GoUnRead:SetActive(true)
	item.GoReaded:SetActive(false)
	UIUtil.SetImageSprite(item.Bg2, UNREADEDPATH, self)

	self.timer1 = TimerMgr.AddTimer(eTimerType.RealTime, 1, function()
		UIUtil.SetImageSprite(item.Bg2, READEDPATH, self)
		item.GoUnRead:SetActive(false)
		item.GoReaded:SetActive(true)

		chatData.isReaded = true
	end, {
		1
	})
end

function PageCommunication:OnEnd(isManualEnd)
	if isManualEnd then
		-- block empty
	elseif ScenarioKit.IsScenarioEditMode() then
		-- block empty
	else
		self:DealEndChat()

		self.ChatPanel.transform.localPosition = self.ChatPos

		self.ButtonSkip:SetActive(false)
		self.InputBar:SetActive(false)
		self.EndTopic:SetActive(true)
		self:RequestEnd()
		self.EffProjector:SetActive(false)
	end
end

function PageCommunication:RequestEnd()
	self.state = eCommuState.WaitTopic

	local topicId = SceneCommunication.Instance.topicId

	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			local infoTopic = TopicManager:GetTopic(topicId)

			infoTopic.pb.status = 1
			infoTopic.pb.record = saveData
			self.infoRole.pb.lastTopicId = topicId

			self:DealWithAward(vPBMessage.setter)
			DotMgr:Update(ePSKey.Dot_SMS_CALL, {})
		else
			UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
		end
	end

	NetManager:RequestEndTopic(topicId, 1, 1, saveData, wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PageCommunication:DealWithAwardFavorExp(pbSetter)
	local isChange = true
	local favorCount = 0

	self.favorExpChange = 0

	for _, s in ipairs(pbSetter) do
		if s.asset == protocol_pb.R_FAVOR_UP then
			isChange = false
			favorCount = favorCount + 1
		elseif s.asset == protocol_pb.R_FAVOR_EXP then
			favorCount = favorCount + 1
			self.favorExpChange = s.num
		end
	end

	if favorCount > 0 then
		self.TextFavor.text = _("Friendliness") .. " +" .. tostring(self.favorExpChange)
		self.img_FavorAni.enabled = true

		self.img_FavorAni:Play("img_Favor")
		SetActiveFunc(self.img_Favor.gameObject, true)
	end
end

function PageCommunication:DealWithAward(pbSetter)
	local setter = SetterData.GetSetterData(pbSetter)

	setter:Parse()

	local wrap_cb
	local isChange = true
	local favorCount = 0

	self.favorExpChange = 0

	for _, s in ipairs(pbSetter) do
		if s.asset == protocol_pb.R_FAVOR_UP then
			isChange = false
			favorCount = favorCount + 1
		elseif s.asset == protocol_pb.R_FAVOR_EXP then
			favorCount = favorCount + 1
			self.favorExpChange = s.num
		end
	end

	function wrap_cb()
		if favorCount > 0 then
			self.TextFavor.text = _("Friendliness") .. " +" .. tostring(self.favorExpChange)
			self.img_FavorAni.enabled = true

			self.img_FavorAni:Play("img_Favor")
			SetActiveFunc(self.img_Favor.gameObject, true)
		end
	end

	if setter.IsFavorLevelup then
		local tmpcn = wrap_cb

		function wrap_cb()
			tmpcn()
			require("UI/Page/PageInteraction/DlgFavorUp")

			local data = {}

			data.listItem = {}
			data.preFavorLevel = setter.preFavorLevel
			data.curFavorLevel = setter.curFavorLevel
			data.infoRole = setter.infoRole

			UIMgr.AddPanel(DlgFavorUp(), data)
		end
	end

	local listNormal = setter:Getlist(protocol_pb.AF_NORMAL)
	local data = {}

	data.list = listNormal
	data.listValue = #listNormal
	data.callback = wrap_cb

	if favorCount < #listNormal then
		UIMgr.AddPanel(DlgGetAward.GetInstance(), data)
	else
		wrap_cb()
	end
end

function PageCommunication:EventAnim()
	SetActiveFunc(self.img_Favor.gameObject, false)
end

function PageCommunication:OnClickedSkip()
	if self.state == eCommuState.WaitAnswer then
		UIMgr.ShowMsg(_("Desc_WaitAnswer"))
	elseif self.state == eCommuState.InChat then
		ScenarioKit.Instance.Events.OnClickSkip:Dispatch(nil)
	end
end
