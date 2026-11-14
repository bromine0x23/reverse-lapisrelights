-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InstructionMgr.lua

local GuideData = require("luaData/guide")

eTriggerType = {
	Auto = "Auto",
	Trigger = "Trigger",
	Battle = "Battle"
}
eEventFinishType = {
	Auto = "Auto",
	Operation = "Operation"
}
InfoGuideEvent = class("InfoGuideEvent")

function InfoGuideEvent:ctor()
	self.isFinished = false
	self.infoGuideStep = nil
end

function InfoGuideEvent:SetData(pData)
	self.isFinished = false

	for k, v in pairs(pData) do
		self[k] = v
	end
end

function InfoGuideEvent:IsNotFinished()
	return not self.isFinished
end

function InfoGuideEvent:Process()
	local hasMaskObj = false
	local checkValid = false

	UIMgr.DlgGuide.IsLongPress = self.IsLongPress

	if InstructionMgr.DelayTime then
		return
	end

	if self.Type == "ShowMask" then
		hasMaskObj = UIMgr.DlgGuide:ShowMask(self.Value, self.Target, self.Page, self.OffsetX, self.OffsetY, self.OffsetW, self.OffsetH, self.IsOriginSize, self.HideLight)
		UIMgr.DlgGuide.fobidenClick = false

		if self.FinishType == eEventFinishType.Auto then
			UIMgr.DlgGuide.fobidenClick = true
		end

		if self.AvatarEnd then
			InstructionAvatarEnd = true
		end
	elseif self.Type == "HideMask" then
		UIMgr.DlgGuide:HideMask()
	elseif self.Type == "ShowOpaqueMask" then
		UIMgr.DlgGuide:ShowOpaqueMask()
	elseif self.Type == "HideOpaqueMask" then
		UIMgr.DlgGuide:HideOpaqueMask()
	elseif self.Type == "Talk" then
		if tonumber(self.Value) ~= InstructionMgr.preTalkId then
			UIMgr.DlgGuide:ShowTalk(self.Value, self.Target, self.OffsetX, self.OffsetY)

			InstructionMgr.preTalkId = tonumber(self.Value)
		end
	elseif self.Type == "FullTalk" then
		if tonumber(self.Value) ~= InstructionMgr.preTalkId then
			UIMgr.DlgGuide:ShowFullTalk(self.Value)

			InstructionMgr.preTalkId = tonumber(self.Value)
		end

		if self.IsKeep then
			UIMgr.DlgGuide:SetTalkKeep(tonumber(self.IsKeep) == 1)
		else
			UIMgr.DlgGuide.isKeepTalk = false
		end
	elseif self.Type == "ShowEffect" then
		local g = GOUtil.FindChildGameObject(UIMgr.GetCurPanel().UIRootObject, self.Target)
		local gEff = EffectMgr:Alloc(self.Value, g, true)

		InstructionMgr.dictEff[self.Value] = gEff
	elseif self.Type == "HideEffect" then
		if InstructionMgr.dictEff[self.Value] then
			EffectMgr:Free(InstructionMgr.dictEff[self.Value])
		end
	elseif self.Type == "ClickRepeatOn" then
		InstructionMgr.isClickRepeatOn = true

		UIMgr.DlgGuide:SetClickDown(true)
	elseif self.Type == "ClickRepeatOff" then
		InstructionMgr.isClickRepeatOn = false

		UIMgr.DlgGuide:SetClickDown(false)
	elseif self.Type == "PauseBattle" then
		Time.timeScale = tonumber(self.Value)
	elseif self.Type == "HideSkipTimeLine" then
		InstructionMgr.isSkipTimeLine = tonumber(self.Value)
	elseif self.Type == "PauseMusic" then
		if self.Value == "1" then
			GP.Live:PauseMusic()
		else
			GP.Live:ResumeMusic()
		end
	elseif self.Type == "PlayVideo" then
		UIMgr.DlgGuide:PlayVideo(self.Value)
	elseif self.Type == "SkipReturn" then
		InstructionMgr.isSkipReturn = true
	elseif self.Type == "CheckAndOpenUnlock" then
		InstructionMgr:CheckAndOpenUnlock(self.Value)
	elseif self.Type == "show2DBtn" then
		InstructionMgr.show2DBtn = true
	elseif self.Type == "ShowDrawCardTip" then
		require("UI/Page/PageCardShop/PageCardShop")

		PageCardShop.needTips = tonumber(self.Value) == 1
	elseif self.Type == "ShowGuidePic" then
		require("UI/Dlg/Public/PGuide")
		UIMgr.AddPanel(PGuide(), tonumber(self.Value))
	elseif self.Type == "CheckAndJumpToStage" then
		print("jumpto:" .. self.Value)

		InstructionMgr.jumpToStageId = tonumber(self.Value)
	elseif self.Type == "GoToInteract" then
		InstructionMgr.hidePageInteract = true

		SceneMainStage.Instance:OnEnterInteractionByRoleId(tonumber(self.Value))
	elseif self.Type == "SelectMonster" then
		GP:ReqSelectTarget(tonumber(self.Value))
	elseif self.Type == "ShowDlgExit" then
		Event.Instance:Fire("ShowDlgExit", true)
	elseif self.Type == "ShowExitBtn" then
		InstructionMgr.showExitBtn = tonumber(self.Value) == 1
	elseif self.Type == "CheckAndCall" then
		InstructionMgr.isGuideCall = true
		InstructionMgr.fobidCall = false
		InstructionMgr.callInId = nil

		local info = PhoneCallManager:Get(tonumber(self.Value))

		print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" .. tostring(info.pb.status))

		if info.pb.status == 0 then
			InstructionMgr.callInId = tonumber(self.Value)
		end
	elseif self.Type == "SetEndId" then
		InstructionMgr.EndId = tonumber(self.Value)
	elseif self.Type == "NeedGoMainStage" then
		InstructionMgr.NeedGoMainStage = true
	elseif self.Type == "EndGuide" then
		GuideFlow.End()

		InstructionMgr.showExitBtn = true
	elseif self.Type == "showAutoBtn" then
		print("showAutoBtn:" .. tostring(tonumber(self.Value) == 1))

		InstructionMgr.showAutoBtn = tonumber(self.Value) == 1
		isShowAutoInstruction = tonumber(self.Value) == 1

		Event.Instance:Fire("SetGuideBtn", InstructionMgr.showAutoBtn)
	elseif self.Type == "ShowShare" then
		isShowShare = tonumber(self.Value) == 1
	elseif self.Type == "ShowAvatarMask" then
		local str = string.split(self.Value, ",")
		local roleId = tonumber(str[1])
		local avatarId = tonumber(str[2])
		local infoRole = RoleMgr:GetRole(roleId)
		local list = AvatarManager:GetListAvatar(infoRole, eAvatarTabType.Body)
		local index

		for i = 1, #list do
			local avatarData = list[i]

			if avatarData.InfoAvatar.id == avatarId then
				index = i
			end
		end

		local p = "Panel/AvatarList/ScrollArea/Content/EntryRoot" .. index .. "/cell"

		UIMgr.DlgGuide:ShowMask("Target", p, self.Page, self.OffsetX, self.OffsetY, self.OffsetW, self.OffsetH, self.IsOriginSize)

		UIMgr.DlgGuide.fobidenClick = false
	elseif self.Type == "showRoleCardMask" then
		local cardId = tonumber(self.Value)
		local roleId = RoleCardMgr:GetRoleId(cardId)
		local listCard = RoleCardMgr:GetRoleHoldCard(roleId)

		local function sortFun(a, b)
			return CardSortMgr:GetCompare4(a, b, 1)
		end

		table.sort(listCard, sortFun)

		local index = 1

		for i = 1, #listCard do
			if listCard[i].id == cardId then
				index = i
			end
		end

		local p = "Panel/CardList/ScrollArea2/Content/EntryRoot1/cell/ScrollArea/Content/EntryRoot" .. index .. "/Cell" .. index

		UIMgr.DlgGuide:ShowMask("Target", p, self.Page, self.OffsetX, self.OffsetY, self.OffsetW, self.OffsetH, self.IsOriginSize)

		UIMgr.DlgGuide.fobidenClick = false
	elseif self.Type == "ChapterUnlock" then
		hasMaskObj = GameObject.Find("ChapterUnlock")
		checkValid = true
	elseif self.Type == "HideSkillTip" then
		UIMgr.HideSkillTip()
	end

	if self.PassEnd then
		NetManager:RecordGuide(self.infoGuideStep.infoGuide.ID, 1, {
			self.infoGuideStep.ID
		})
		print("PassEndPassEnd:" .. self.infoGuideStep.infoGuide.ID)
	end

	local function funEnd()
		print("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
		print(self.infoGuideStep.infoGuide.ID .. " Type:" .. self.Type .. " Value:" .. tostring(self.Value) .. " GuideEnd:" .. tostring(self.GuideEnd))

		self.isFinished = true

		if self.StepEnd then
			self.infoGuideStep.isFinished = true

			if self.Contain and self.Contain == "1" then
				FingerGesturesUtil.Disable()
			else
				UIMgr.DlgGuide:HideMask()
			end

			NetManager:RecordGuide(self.infoGuideStep.infoGuide.ID, 0, {
				self.infoGuideStep.ID
			})

			return
		end

		if self.GuideEnd then
			if self.Contain and self.Contain == "1" then
				FingerGesturesUtil.Disable()
			else
				UIMgr.DlgGuide:HideMask()
			end

			if self.infoGuideStep.infoGuide.GuideSpot then
				InstructionMgr:GuideSpot()
			end

			self.infoGuideStep.infoGuide.isFinished = true

			NetManager:RecordGuide(self.infoGuideStep.infoGuide.ID, 1, {
				self.infoGuideStep.ID
			})
			InstructionMgr:SetPass(self.infoGuideStep.infoGuide.ID)

			if InstructionMgr.maxGuideId == tonumber(self.infoGuideStep.infoGuide.ID) then
				GuideFlow.End()

				InstructionMgr.showExitBtn = true
				InstructionMgr.fobidCall = false
			end

			return
		end

		if self:IsTriggered() then
			self:Next()
		end
	end

	if self.FinishType == eEventFinishType.Auto then
		if checkValid then
			if hasMaskObj then
				funEnd()
			else
				self.isFinished = true

				self:Next()
			end
		else
			funEnd()
		end
	elseif self.FinishType == eEventFinishType.Operation then
		function UIMgr.DlgGuide.callbackClick()
			UIMgr.DlgGuide.callbackClick = nil

			funEnd()
		end
	end
end

function InfoGuideEvent:IsTriggered()
	return InstructionMgr:DealWithTrigger(self.Trigger)
end

function InfoGuideEvent:Next()
	if self.DelayTime then
		InstructionMgr.DelayTime = self.DelayTime
	end

	if InstructionMgr.DelayTime then
		TimerMgr.AddTimer(eTimerType.RealTime, InstructionMgr.DelayTime, function()
			InstructionMgr.DelayTime = nil

			InstructionMgr:Next()
		end, {
			1
		})
	else
		InstructionMgr:Next()
	end
end

InfoGuideStep = class("InfoGuideStep")

function InfoGuideStep:ctor()
	self.listGuideEvent = {}
	self.isFinished = false
	self.infoGuide = nil
end

function InfoGuideStep:SetData(pData)
	self.listGuideEvent = {}

	for k, v in pairs(pData) do
		if type(v) == "table" then
			for _, v2 in pairs(v) do
				local infoGuideEvent = InfoGuideEvent()

				infoGuideEvent:SetData(v2)

				infoGuideEvent.infoGuideStep = self

				table.insert(self.listGuideEvent, infoGuideEvent)
			end
		else
			self[k] = v
		end
	end
end

function InfoGuideStep:IsNotFinished()
	return not self.isFinished
end

function InfoGuideStep:IsTriggered()
	return InstructionMgr:DealWithTrigger(self.Trigger)
end

function InfoGuideStep:GetCurEvent()
	for _, v in pairs(self.listGuideEvent) do
		if v:IsNotFinished() then
			return v
		end
	end

	return nil
end

InfoGuide = class("InfoGuide")

function InfoGuide:ctor()
	self.listGuideStep = {}
	self.isFinished = false
end

function InfoGuide:SetData(pData)
	self.listGuideStep = {}

	for k, v in pairs(pData) do
		if type(v) == "table" then
			for _, v2 in pairs(v) do
				local infoGuideStep = InfoGuideStep()

				infoGuideStep:SetData(v2)

				infoGuideStep.infoGuide = self

				table.insert(self.listGuideStep, infoGuideStep)
			end
		else
			self[k] = v
		end
	end
end

function InfoGuide:RequestPass()
	if not InstructionMgr:IsPassed(self.ID) then
		NetManager:RecordGuide(self.ID, 1, {
			self.ID
		})
		InstructionMgr:SetPass(self.ID)

		if InstructionMgr.maxGuideId == tonumber(self.ID) then
			print("alll guide compleelelele")
			GuideFlow.End()

			InstructionMgr.showExitBtn = true
			InstructionMgr.fobidCall = false

			UIMgr.HideGuide()
		end
	end
end

function InfoGuide:IsNotFinished()
	if self.isFinished then
		return false
	end

	if InstructionMgr:IsPassed(self.ID) then
		return false
	end

	if self.Pass then
		local str = string.split(self.Pass, ",")
		local key = str[1]
		local value = str[2]

		if key == "StagePass" then
			local infoStage = ChapterMgr:GetStage(tonumber(value))

			if infoStage == nil then
				return false
			end

			if infoStage.pb.isPass then
				self:RequestPass()

				return false
			end
		elseif key == "PhoneCallPass" then
			local info = PhoneCallManager:Get(tonumber(value))

			if info == nil then
				return false
			end

			if info.pb.status == 1 then
				return false
			end
		elseif key == "CardGet" then
			local infoRoleCard = RoleCardMgr:GetRoleCard(tonumber(value))

			if infoRoleCard == nil then
				return false
			end

			local g = GameObject.Find("PanelMainStage(Clone)")

			if infoRoleCard:IsGet() and g then
				self:RequestPass()

				return false
			end
		elseif key == "AvatarSet" then
			local avatarId = tonumber(str[3])
			local roleId = tonumber(value)
			local infoRole = RoleMgr:GetRole(roleId)

			if infoRole == nil then
				return false
			end

			for k, v in pairs(infoRole.pb.clothes) do
				if v == avatarId and InstructionAvatarEnd == nil then
					print("AvatarSet~~~~~~~~~~~~~~~~~")

					return false
				end
			end
		elseif key == "CardLevel" then
			if not self.isFinished then
				return true
			end

			local infoRoleCard = RoleCardMgr:GetRoleCard(tonumber(value))

			if infoRoleCard == nil then
				return false
			end

			if infoRoleCard.curLevel > 1 then
				self:RequestPass()

				return false
			end
		end
	end

	return not InstructionMgr:IsPassed(self.ID)
end

function InfoGuide:IsTriggered()
	return InstructionMgr:DealWithTrigger(self.Trigger)
end

function InfoGuide:GetCurStep()
	for _, v in pairs(self.listGuideStep) do
		if v:IsNotFinished() then
			return v
		end
	end

	return nil
end

InfoGuideGroup = class("InfoGuideGroup")

function InfoGuideGroup:ctor()
	self.listGuide = {}
end

function InfoGuideGroup:SetData(pData)
	self.listGuide = {}

	for k, v in pairs(pData) do
		if type(v) == "table" then
			for _, v2 in pairs(v) do
				local infoGuide = InfoGuide()

				infoGuide:SetData(v2)
				table.insert(self.listGuide, infoGuide)
			end
		else
			self[k] = v
		end
	end
end

function InfoGuideGroup:GetCurGuide()
	for _, v in pairs(self.listGuide) do
		if v:IsNotFinished() then
			return v
		end
	end

	return nil
end

function InfoGuideGroup:GetCurEvent()
	local infoGuide = self:GetCurGuide()

	if infoGuide and infoGuide:IsTriggered() then
		local infoStep = infoGuide:GetCurStep()

		if infoStep and infoStep:IsTriggered() then
			print("infoGuideID:" .. infoGuide.ID)

			local infoEvent = infoStep:GetCurEvent()

			if infoEvent and infoEvent:IsTriggered() then
				print("IsTriggered infoGuideID:" .. infoGuide.ID)

				return infoEvent
			end
		end
	end

	return nil
end

InstructionMgr = {}
InstructionMgr.dictEff = {}

function InstructionMgr:DealWithTrigger(trigger)
	local isInPage = false

	if trigger == nil then
		if self.isTriggerInPage then
			return false
		end

		return true
	else
		local listTrigger = string.split(trigger, "|")

		for _, v in pairs(listTrigger) do
			local strTrigger = string.split(v, ",")
			local key = strTrigger[1]
			local value = strTrigger[2]
			local value2 = strTrigger[3]

			if key == "PlayerLevel" then
				local r = self:ParseOp(value, PlayerInst:GetCurLv())

				if not r then
					return false
				end
			elseif key == "GetHero" then
				local infoCard = RoleCardMgr:GetRoleCard(tonumber(value))

				if infoCard and infoCard:IsHold() then
					-- block empty
				else
					return false
				end
			elseif key == "WithoutHero" then
				local infoCard = RoleCardMgr:GetRoleCard(tonumber(value))

				if infoCard and not infoCard:IsHold() then
					-- block empty
				else
					return false
				end
			elseif key == "LevelFinished" then
				local infoStage = ChapterMgr:GetStage(tonumber(value))

				if infoStage and infoStage.pb.isPass then
					-- block empty
				else
					return false
				end
			elseif key == "LevelUnfinished" then
				local infoStage = ChapterMgr:GetStage(tonumber(value))

				if infoStage and not infoStage.pb.isPass then
					-- block empty
				else
					return false
				end
			elseif key == "InPage" then
				local g = GameObject.Find(value .. "(Clone)")

				print("InPage:" .. value)

				if g == nil then
					return false
				end

				isInPage = true
			elseif key == "InPageLoaded" then
				print("InPageLoaded:" .. value)

				if self.strPageName == nil then
					return false
				end

				if self.strPageName ~= value then
					return false
				end
			elseif key == "StageNotPass" then
				local infoStage = ChapterMgr:GetStage(tonumber(value))

				if infoStage == nil then
					return false
				end

				InstructionMgr.fobidCall = false

				if infoStage.pb.isPass then
					return false
				end

				InstructionMgr.fobidCall = true
			elseif key == "StagePass" then
				local infoStage = ChapterMgr:GetStage(tonumber(value))

				if infoStage == nil then
					return false
				end

				if not infoStage.pb.isPass then
					return false
				end
			elseif key == "PhoneCallNotPass" then
				local info = PhoneCallManager:Get(tonumber(value))

				if info == nil then
					return false
				end

				if info.pb.status == 1 then
					return false
				end
			elseif key == "CardLevel" then
				local infoRoleCard = RoleCardMgr:GetRoleCard(tonumber(value2))

				if infoRoleCard == nil then
					return false
				end

				local r = self:ParseOp(value, infoRoleCard.curLevel)

				if not r then
					return false
				end
			elseif key == "CardNotGet" then
				local infoRoleCard = RoleCardMgr:GetRoleCard(tonumber(value))

				if infoRoleCard == nil then
					return false
				end

				if infoRoleCard:IsGet() then
					return false
				end
			elseif key == "TestPass" then
				if tonumber(value) == 1 then
					return false
				end
			elseif key == "Wait" then
				if value == "ChapterUnlock" then
					local g = GameObject.Find("ChapterUnlock")

					if g == nil then
						return true
					end
				end

				if self.isTriggerWait ~= value then
					return false
				end
			end
		end
	end

	if self.isTriggerInPage and not isInPage then
		return false
	end

	return true
end

function InstructionMgr:ParseOp(value, pLv)
	local op = string.sub(value, 1, 1)
	local num = tonumber(string.sub(value, 2))

	if op == ">" then
		if not (num < pLv) then
			return false
		end
	elseif op == "<" then
		if not (pLv < num) then
			return false
		end
	elseif pLv ~= num then
		return false
	end

	return true
end

function InstructionMgr:SetData(pbListGuide)
	print("~~~~~~~~~~~~~~~~~~~~~InstructionMgr:SetData(pbListGuide)~~~~~~~~~~~~~~~~~~~~~")

	for i = 1, #pbListGuide do
		local pb = pbListGuide[i]

		print("GuideID:" .. pb.guideId .. " sta:" .. pb.status)

		self.listPassed[pb.guideId] = pb.status
	end
end

function InstructionMgr:SetPass(guideId)
	local id = tonumber(guideId)

	self.listPassed = self.listPassed or {}
	self.listPassed[id] = 1
end

function InstructionMgr:IsPassed(guideId)
	local id = tonumber(guideId)

	if self.listPassed[id] and self.listPassed[id] == 1 then
		return true
	end

	return false
end

function InstructionMgr:GetGuideStep(guideId, stepId)
	local infoGuide = InstructionMgr:GetGuide(guideId)

	if infoGuide then
		for _, infoGuideStep in pairs(infoGuide.listGuideStep) do
			if tonumber(infoGuideStep.ID) == stepId then
				return infoGuideStep
			end
		end
	end

	return nil
end

function InstructionMgr:GetGuide(id)
	local listAll = {
		self.mainGuideGroup
	}

	for i = 1, #self.listBranchGuideGroup do
		table.insert(listAll, self.listBranchGuideGroup[i])
	end

	for _, v in pairs(listAll) do
		for k, infoGuide in pairs(v.listGuide) do
			if tonumber(infoGuide.ID) == tonumber(id) then
				return infoGuide
			end
		end
	end

	return nil
end

function InstructionMgr:SkipReturn()
	if not self.isOpen then
		return false
	end

	if self.isSkipReturn then
		self.isSkipReturn = false

		return true
	end

	return false
end

function InstructionMgr:Init()
	self:Destroy()

	self.isOpen = false

	if NetManager.IsUseSDK then
		self.isOpen = true
	end

	self.showExitBtn = true
	self.jumpToStageId = 0
	self.isSkipReturn = false
	self.isSkipTimeLine = 0
	self.isStart = false
	self.isTriggerInPage = false
	self.isClickRepeatOn = false
	self.mainGuideGroup = nil
	self.listBranchGuideGroup = {}
	self.dictEff = {}
	self.listPassed = {}
	self.preTalkId = 0
	self.getSpot = false

	for _, v in pairs(GuideData.GuideGroup) do
		local infoGroup = InfoGuideGroup()

		infoGroup:SetData(v)

		if tonumber(infoGroup.Type) == 0 then
			self.mainGuideGroup = infoGroup
		else
			table.insert(self.listBranchGuideGroup, infoGroup)
		end
	end

	self.maxGuideId = #self.mainGuideGroup.listGuide

	Event.Instance:Add("OnPageLoaded", self.OnPageLoaded, self)
end

function InstructionMgr:Destroy()
	Event.Instance:Remove("OnPageLoaded", self.OnPageLoaded, self)

	if self.dictEff then
		for _, v in pairs(self.dictEff) do
			if v then
				EffectMgr:Free(v)
			end
		end
	end
end

function InstructionMgr:End()
	self.isOpen = false
	InstructionMgr.showExitBtn = true
	InstructionMgr.fobidCall = false
end

isShowShare = true

function InstructionMgr:Start()
	if not self.isOpen then
		return
	end

	if InstructionMgr:IsPassed(self.maxGuideId) then
		self.isOpen = false

		return
	end

	self.isStart = true
	self.showExitBtn = false
	self.showAutoBtn = true
	self.isTriggerInPage = false

	InstructionMgr:Next()
	print("InstructionMgr:Start()")

	local curGuide, spotGuide
	local hasFinishGuide = false

	for _, v in pairs(self.mainGuideGroup.listGuide) do
		if v:IsNotFinished() then
			-- block empty
		elseif curGuide == nil or v.ID > curGuide.ID then
			curGuide = v
		end
	end

	self.getSpot = false

	if curGuide then
		for _, v in pairs(self.mainGuideGroup.listGuide) do
			local infoGuide = InstructionMgr:GetGuide(v.ID)

			if infoGuide and infoGuide.GuideSpot then
				spotGuide = infoGuide
			end
		end

		if spotGuide:IsNotFinished() and tonumber(curGuide.ID) >= tonumber(spotGuide.ID) then
			if not self.getSpot then
				InstructionMgr:GuideSpot()

				self.getSpot = true
			end

			print("1111111")
		end

		if not spotGuide:IsNotFinished() or tonumber(curGuide.ID) >= tonumber(spotGuide.ID) then
			self.getSpot = true

			PlayerPrefs.SetInt("GuidePassed", 1)
			print("2222222")
		end

		print("curGuide.ID:" .. curGuide.ID)
	end

	if not self:IsPassed(1) then
		require("GameLogic/Fight/EnumFight")
		PersistentStoreUtil.SetFloat(PersistentStoreUtil.KEY_FIGHT_SPEED_MODE, EnumFight.SpeedMode.Default)
		PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_FIGHT_AUTO_MODE, false)
		PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_FIGHT_SKIP_TL_MODE, false)
	end

	print("getSpot:" .. tostring(self.getSpot))
end

function InstructionMgr:IsInGuide()
	if not self.isOpen or not self.isStart then
		return false
	end

	return not IsNil(UIMgr.DlgGuide.UIRootObject) and GOUtil.IsActiveSelf(UIMgr.DlgGuide.UIRootObject) or not isShowAutoInstruction
end

function InstructionMgr:IsInGuideKc()
	if not self.isOpen or not self.isStart then
		return false
	end

	if not UIMgr.DlgGuide or not UIMgr.DlgGuide.UIRootObject then
		return false
	end

	return GOUtil.IsActiveSelf(UIMgr.DlgGuide.UIRootObject)
end

function InstructionMgr:IsGuidePassed()
	local guidePassed = PlayerPrefs.GetInt("GuidePassed", 0)

	return guidePassed ~= 0
end

function InstructionMgr:Next()
	if not self.isOpen or not self.isStart then
		return
	end

	local infoEvent = self.mainGuideGroup:GetCurEvent()

	if infoEvent then
		print("InstructionMgr:Next(2):" .. tostring(infoEvent.Type) .. " Value:" .. tostring(infoEvent.Value))
		UIMgr.ShowGuide()
		infoEvent:Process()
	end
end

function InstructionMgr:CheckAndOpenUnlock(strUnlockFunc)
	print("CheckAndOpenUnlock~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

	local id = tonumber(strUnlockFunc)
	local data = require("luaData/Newbie")
	local stageId = data[id].Stage

	print("CheckA:" .. id .. " stageId:" .. stageId)

	local infoStage = ChapterMgr:GetStage(stageId)

	if infoStage and infoStage:IsPass() then
		ChapterMgr.justUnLockStage = stageId

		TutorialMgr:DealStageOpenSystem()
	end
end

function InstructionMgr:TriggerInPage()
	self.isTriggerInPage = true

	InstructionMgr:Next()

	self.isTriggerInPage = false
end

function InstructionMgr:OnPageLoaded(strPageName)
	self.isTriggerInPage = false
	self.strPageName = strPageName

	InstructionMgr:Next()

	self.strPageName = nil
end

function InstructionMgr:TriggerWait(key)
	print("~~~~TriggerWait~~~:" .. key)

	self.isTriggerInPage = false
	self.isTriggerWait = key

	InstructionMgr:Next()

	self.isTriggerWait = nil
end

function InstructionMgr:GuideSpot()
	print("InstructionMgr:GuideSpot()~~~~~~~~~")
	AppsFlyerService.TrackTutorialEvent()
end

function InstructionMgr.UpdateAfterGuide()
	print("InstructionMgr.UpdateAfterGuide~~~~")
end

function InstructionMgr:GetNewBieStageID(stageId)
	self.NewBieStageID = PersistentStoreUtil.GetInt(PersistentStoreUtil.KEY_NEWBIE_STAGEID)

	if self.NewBieStageID ~= stageId then
		self.NewBieStageID = stageId

		PersistentStoreUtil.SetInt(PersistentStoreUtil.KEY_NEWBIE_STAGEID, self.NewBieStageID)

		return true
	end

	return false
end

function InstructionMgr:ProcessBack()
	UIMgr.DlgGuide:OnBackAndroid()

	return true
end
