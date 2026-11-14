-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCommunication/PagePhone.lua

local actorData = require("luaData/ActorData")

PagePhone = class("PagePhone", UIPanel, true)

function PagePhone:ctor()
	self.UIPrefabPath = "UI/PageCommunication/PagePhone"
end

function PagePhone:PreLoad()
	return
end

function PagePhone:Purge()
	PagePhone.base.Purge(self)

	if self.timer2 then
		TimerMgr.RemoveTimer(self.timer2)

		self.timer2 = nil
	end
end

function PagePhone:OnRegisterEvent()
	for i = 1, 2 do
		self:AddClick(self["GoOption" .. i], self.OnClickedOption)
	end

	self:AddClick(self.Button, self.OnClickedCallUp)
	self:AddClick(self.GoDialog, self.OnClickedDialog)
	self:AddClick(self.SkipBtn, self.OnClickedSkip)
	self:AddClick(self.HistoryBtn, self.OnClickedHistory)
	EventListenerMgr.AddAnimListener(self.panel, self.OnBack, self, eAnimEventType.OnAnimationEnd)
	EventListenerMgr.AddAnimListener(self.img_Favor.gameObject, self.EventAnim, self, eAnimEventType.OnAnimationEnd)
end

function PagePhone:OnUnRegisterEvent()
	for i = 1, 2 do
		self:RemoveClick(self["GoOption" .. i], self.OnClickedOption)
	end

	self:RemoveClick(self.Button, self.OnClickedCallUp)
	self:RemoveClick(self.GoDialog, self.OnClickedDialog)
	self:RemoveClick(self.SkipBtn, self.OnClickedSkip)
	self:RemoveClick(self.HistoryBtn, self.OnClickedHistory)
	EventListenerMgr.RemoveAnimListener(self.img_Favor.gameObject, self.EventAnim, self, eAnimEventType.OnAnimationEnd)
	EventListenerMgr.RemoveAnimListener(self.panel, self.OnBack, self, eAnimEventType.OnAnimationEnd)
end

function PagePhone:OnEnter(vParam)
	self.infoCall = vParam.infoCall
	self.roleId = vParam.roleId
	self.stageId = vParam.stageId

	local control = self:GetChildGameObject("Panel/Bg2/Image")

	control:SetActive(false)

	self.Button = self:GetChildGameObject("Panel/Canvas/Button")

	if InstructionMgr and not InstructionMgr:IsPassed(4) then
		self.Button:SetActive(false)
	end

	self.GoDialog = self:GetChildGameObject("Panel/Canvas/Dialog")
	self.GoDialog = self:GetChildGameObject("Image1111")
	self.TextContent1 = self:GetChildComponent("Panel/Canvas/Dialog/bg1/Text", "TextView")
	self.bg1 = self:GetChildGameObject("Panel/Canvas/Dialog/bg1")
	self.SkipBtn = self:GetChildGameObject("Panel/Canvas/SkipBtn")
	self.ToggleAuto = self:GetChildComponent("Panel/Canvas/ToggleAuto", "Toggle")

	if PlayerPrefs.GetInt("SceneScenario.Auto", 0) == 1 then
		self.ToggleAuto.isOn = true
	end

	local function wrap_cb(isAuto)
		if isAuto then
			PlayerPrefs.SetInt("SceneScenario.Auto", 1)
		else
			PlayerPrefs.SetInt("SceneScenario.Auto", 0)
		end

		ScenarioKit.Instance.Events.OnCheckAuto:Dispatch(isAuto)
	end

	self.ToggleAuto.onValueChanged:AddListener(wrap_cb)
	self:SetSafeArea(self:GetChildGameObject("Panel/Canvas/HistorySafeArea"))

	self.HistoryBtn = self:GetChildGameObject("Panel/Canvas/HistorySafeArea/HistoryBtn")
	self.CardIcon = self:GetChildComponent("Panel/ImageBg", "RawImage")
	self.TextName = self:GetChildComponent("Panel/Canvas/Dialog/Name/Text", "Text")
	self.Name = self:GetChildGameObject("Panel/Canvas/Dialog/Name")
	self.Arrow = self:GetChildGameObject("Panel/Canvas/Arrow")
	self.img_Favor = self:GetChildGameObject("GoEff/Effect/img_Favor2")
	self.TextFavor = self:GetChildComponent("GoEff/Effect/img_Favor2/Text", "Text")
	self.img_FavorAni = self:GetChildComponent("GoEff/Effect/img_Favor2", "Animator")
	self.Choose = self:GetChildGameObject("Panel/Canvas/Choose")

	for i = 1, 2 do
		self["Option" .. i] = self:GetChildComponent("Panel/Canvas/Choose/Group/" .. i .. "/Text", "Text")
		self["GoOption" .. i] = self:GetChildGameObject("Panel/Canvas/Choose/Group/" .. i)
		self["GoAward" .. i] = self:GetChildGameObject("Panel/Canvas/Choose/Group/" .. i .. "/Image")
	end

	if RoleCardMgr ~= nil then
		self.infoRole = RoleMgr:GetRole(self.roleId)
	end

	self.panel = self:GetChildGameObject("Panel")
	self.Animator = GOUtil.GetComponent(self.panel, "Animator")
	self.GoEffEnd = self:GetChildGameObject("GoEff/FX_CommunicatorLoading_End_2")
	self.Black = self:GetChildGameObject("GoEff/Black")

	self:DealWithLocalization()

	self.TextName.text = ""
	self.GoCanvas = self:GetChildGameObject("Panel/Canvas")
	self.GoEff = self:GetChildGameObject("GoEff")

	self.GoCanvas:SetActive(false)

	self.FX_CommunicatorLoading_Start = self:GetChildGameObject("GoEff/FX_CommunicatorLoading_Start")
	self.FX_CommunicatorLoading_Loop = self:GetChildGameObject("GoEff/FX_CommunicatorLoading_Loop")
	self.FX_CommunicatorLoading_End = self:GetChildGameObject("GoEff/FX_CommunicatorLoading_End")

	self:StartLoading()
end

function PagePhone:StartLoading()
	self.timer = TimerMgr.AddTimer(eTimerType.RealTime, 2, function()
		self.FX_CommunicatorLoading_Start:SetActive(false)
		self.FX_CommunicatorLoading_Loop:SetActive(true)
	end, {
		1
	})
end

function PagePhone:StartLoaded()
	TimerMgr.AddTimer(eTimerType.RealTime, 1, function()
		if self.timer then
			TimerMgr.RemoveTimer(self.timer)
		end

		self.FX_CommunicatorLoading_Start:SetActive(false)
		self.FX_CommunicatorLoading_Loop:SetActive(false)
		self.FX_CommunicatorLoading_End:SetActive(true)
		self.panel:SetActive(true)
		TimerMgr.AddTimer(eTimerType.RealTime, 1, function()
			self.FX_CommunicatorLoading_End:SetActive(false)
			self.GoCanvas:SetActive(true)

			self.isStarted = true

			if PlayerPrefs.GetInt("SceneScenario.Auto", 0) == 1 then
				ScenarioKit.Instance.Events.OnCheckAuto:Dispatch(true)
			end
		end, {
			1
		})
	end, {
		1
	})
end

function PagePhone:BindRT()
	return
end

function PagePhone:UpdatePhoneBg()
	if ScenarioKit.IsScenarioEditMode() then
		return
	end

	local infoRole = RoleMgr:GetRole(self.roleId)
	local cardId = infoRole:GetPhoneBgId()
	local infoRoleCard = RoleCardMgr:GetRoleCard(cardId)

	if infoRoleCard == nil then
		return
	end
end

function PagePhone:DealWithLocalization()
	return
end

function PagePhone:InitData()
	return
end

function PagePhone:OnClickedCallUp()
	if not self.isEndCall then
		SceneCall.Instance:StopVoice()

		self.isEndCall = true
		self.autoEnd = false

		self.panel:SetActive(false)
		self.GoEffEnd:SetActive(true)
		self.Black:SetActive(true)
		self.GoDialog:SetActive(false)
		TimerMgr.AddTimer(eTimerType.RealTime, 4, function()
			local data = {}

			data.from = 1
			data.roleId = self.roleId
			data.tabType = 2

			if self.stageId and self.stageId ~= 0 then
				print("stagegidssss:" .. tostring(self.stageId))

				data.from = 4
				data.stageId = self.stageId
			end

			SceneMgr.LoadScene("MainStage", data)
		end, {
			1
		})
	end
end

function PagePhone:OnClickedDialog()
	if self.isStarted then
		ScenarioKit.Instance.Events.OnClickDialog:Dispatch("")
	end
end

function PagePhone:OnClickedSkip()
	local effsGo = GameObject.Find("effectPos2")

	if effsGo then
		for i = 1, effsGo.transform.childCount do
			local go = effsGo.transform:GetChild(i - 1).gameObject

			GOUtil.SetActive(go, false)
		end
	end

	ScenarioKit.Instance.Events.OnClickSkip:Dispatch(nil)
end

function PagePhone:OnClickedHistory()
	if self.isEndCall then
		return
	end

	self.ToggleAuto.isOn = false

	PlayerPrefs.SetInt("SceneScenario.Auto", 0)
	ScenarioKit.Instance.Events.OnCheckAuto:Dispatch(false)
	require("UI/Page/PageCommunication/DlgHistory")
	UIMgr.AddPanel(DlgHistory())
end

function PagePhone:OnBack()
	if self.autoEnd then
		return
	end
end

function PagePhone:UpdateChat(chatData)
	self.Choose:SetActive(false)
	self.GoDialog:SetActive(true)

	self.TextContent1.Text = chatData.content

	if chatData.actorId >= 0 then
		self.bg1:SetActive(true)
		print("chatData.actorId:" .. chatData.actorId)
	end

	if chatData.nameKey ~= nil then
		self.Name:SetActive(true)

		local text = ScenarioKit.Instance.Language:Get(chatData.nameKey)

		if self.infoRole and text == self.infoRole:GetName() then
			text = self.infoRole:GetCommuName()
		end

		self.TextName.text = text
	else
		self.Name:SetActive(false)
	end
end

function PagePhone:UpdateAnswerList(listAnswer)
	self.Choose:SetActive(true)

	for i = 1, 2 do
		self["GoOption" .. i]:SetActive(false)
	end

	for i = 1, #listAnswer do
		self["GoOption" .. i]:SetActive(true)

		local answer = listAnswer[i]

		self["Option" .. i].text = answer.Text

		if answer.PrizeId ~= nil and answer.PrizeId ~= "" and InfoGameInst ~= nil and not InfoGameInst:IsGetScenarioReward(answer.DialogId) then
			self["GoAward" .. i]:SetActive(true)
		else
			self["GoAward" .. i]:SetActive(false)
		end
	end

	self.listAnswer = listAnswer
end

function PagePhone:OnClickedOption(data)
	local go = data.pointerPress
	local index = tonumber(go.name)
	local answer = self.listAnswer[index]

	if answer.PrizeId ~= nil and answer.PrizeId ~= "" and InfoGameInst ~= nil and not InfoGameInst:IsGetScenarioReward(answer.DialogId) then
		local function callback(vPBMessage)
			LoadingMgr.Hide(eLoadingType.Repeat)
			ScenarioKit.Instance.Events.OnSelectLua:Dispatch(answer)
			self.Choose:SetActive(false)

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
		self.Choose:SetActive(false)
	end
end

function PagePhone:OnEnd(isManualEnd)
	if self.infoCall == nil then
		return
	end

	if isManualEnd then
		-- block empty
	else
		self.GoDialog:SetActive(false)

		if self.infoCall.pb.status == 1 then
			self.Button:SetActive(false)
			self:OnClickedCallUp()
		else
			self:RequestEnd()
		end
	end

	Event.Instance:Fire("OnPhoneCallEnd")
end

function PagePhone:OnComplete()
	if self.infoCall == nil then
		return
	end

	if self.infoCall.pb.status == 1 then
		-- block empty
	else
		self:RequestEnd()
	end
end

function PagePhone:GetListAward()
	local saveData = ScenarioKit.Instance.saveLoad:Save()
	local arraySave = ScenarioKit.Instance.saveLoad:GetSaveString(saveData)
	local listAward = {}

	for i = 0, arraySave.Count - 1 do
		local item = arraySave[i]

		if item.PrizeId ~= nil and item.PrizeId ~= "" then
			local id = tonumber(item.PrizeId)

			if id > 0 then
				table.insert(listAward, id)
			end
		end
	end

	return listAward
end

function PagePhone:RequestEnd()
	local function wrap_cb(vPBMessage)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if vPBMessage.result.code == NetManager.Result_Sucess then
			self.infoCall.pb.status = 1

			print("PagePhone:RequestEnd:" .. self.infoCall.id)

			InstructionMgr.callInId = nil

			self:DealWithAward(vPBMessage.setter)
			DotMgr:Update(ePSKey.Dot_SMS_CALL, {})
			InstructionMgr:TriggerWait("PassPhoneCall")
		else
			UIMgr.ShowDialog(vPBMessage.result.desc, function()
				self:RequestEnd()
			end)
		end
	end

	NetManager:RequestEndTopic(self.infoCall.id, 1, 2, "", wrap_cb)
	LoadingMgr.Show(eLoadingType.Repeat)
end

function PagePhone:DealWithAwardFavorExp(pbSetter)
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

function PagePhone:DealWithAward(pbSetter)
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

		wrap_cb = nil
	end
end

function PagePhone:EventAnim()
	SetActiveFunc(self.img_Favor.gameObject, false)
end
