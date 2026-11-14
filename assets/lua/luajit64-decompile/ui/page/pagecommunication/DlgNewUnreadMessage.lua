-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCommunication/DlgNewUnreadMessage.lua

DlgNewUnreadMessage = class("DlgNewUnreadMessage", UIPanel, true)

function DlgNewUnreadMessage:ctor()
	self.UIPrefabPath = "UI/PageCommunication/DlgNewUnreadMessage"
end

function DlgNewUnreadMessage:PreLoad()
	self:LoadResAsync("Fx/UI/Eff_UI_DlgSystemOpen/FX_UI_DlgSystemOpen_Fly", "PrefabFlyEff")
end

function DlgNewUnreadMessage:Purge()
	DlgNewUnreadMessage.base.Purge(self)
	ResourceMgr.Unload(self.PrefabFlyEff)

	if self.Timer1 then
		TimerMgr.RemoveTimer(self.Timer1)

		self.Timer1 = nil
	end

	if self.Timer2 then
		TimerMgr.RemoveTimer(self.Timer2)

		self.Timer2 = nil
	end

	EffectMgr:UnLoadEffect("Fx/UI/Eff_UI_DlgSystemOpen/FX_UI_DlgSystemOpen_Start")
	EffectMgr:UnLoadEffect("Fx/UI/Eff_UI_DlgSystemOpen/FX_UI_DlgSystemOpen_End")
	UIMgr.RemoveUpdatePanel(self)
	FingerGesturesUtil.Enable()
end

function DlgNewUnreadMessage:OnRegisterEvent()
	self:AddClick(self.AnswerBtn, self.OnClickedCall)
	self:AddClick(self.CloseBtn, self.OnClickedHandOff)
end

function DlgNewUnreadMessage:OnUnRegisterEvent()
	self:RemoveClick(self.AnswerBtn, self.OnClickedCall)
	self:RemoveClick(self.CloseBtn, self.OnClickedHandOff)
end

function DlgNewUnreadMessage:OnEnter(vParam)
	FingerGesturesUtil.Disable()

	local callList = PersistentStoreUtil.GetList(PersistentStoreUtil.KEY_NEW_PHONE_CALL)
	local topicList = PersistentStoreUtil.GetList(PersistentStoreUtil.KEY_NEW_TOPIC)

	self.TopicCount = #topicList
	self.PhoneCount = #callList

	local roleIdList = {}

	for i, v in ipairs(callList) do
		local infoCall = PhoneCallManager:Get(tonumber(v))

		table.insert(roleIdList, {
			tab = 2,
			id = infoCall.data.RoleId
		})
	end

	for i, v in ipairs(topicList) do
		local infoTopic = TopicManager:GetTopic(tonumber(v))

		table.insert(roleIdList, {
			tab = 1,
			id = infoTopic.data.RoleId
		})
	end

	table.sort(roleIdList, function(a, b)
		return a.id < b.id
	end)

	self.HeadIcon = self:GetChildComponent("Panel/HeadIcon", "Image")
	self.BG = self:GetChildComponent("BG", "Image")
	self.AnswerBtn = self:GetChildGameObject("Panel/Answer")
	self.CloseBtn = self:GetChildGameObject("Panel/Close")
	self.GoEffPoint = self:GetChildGameObject("EffPoint")
	self.Panel = self:GetChildGameObject("Panel")
	self.TopicBG = self:GetChildGameObject("Panel/Tips/Topic")
	self.PhoneBG = self:GetChildGameObject("Panel/Tips/Phone")
	self.TopicTip = self:GetChildComponent("Panel/Tips/Topic/Tip", "Text")
	self.PhoneTip = self:GetChildComponent("Panel/Tips/Phone/Tip", "Text")
	self.CloseTip = self:GetChildComponent("Panel/CloseTIp", "Text")
	self.roleId = roleIdList[1].id
	self.openTab = roleIdList[1].tab
	self.infoRole = RoleMgr:GetRole(self.roleId)

	UIUtil.SetImageSprite(self.HeadIcon, "UIDyAtlas/CharacterIcon/IC_IDH_" .. self.infoRole.data.Enname .. "_02", self)
	SetActiveFunc(self.TopicBG, self.TopicCount ~= 0)
	SetActiveFunc(self.PhoneBG, self.PhoneCount ~= 0)

	self.TopicTip.text = string.format(_("Desc_NewUnreadTopic"), self.TopicCount)
	self.PhoneTip.text = string.format(_("Desc_NewUnreadCall"), self.PhoneCount)

	if self.TopicCount == 0 then
		GOUtil.SetRectTransformSizeDelta(self.PhoneBG, 850, 64)
	end

	if self.PhoneCount == 0 then
		GOUtil.SetRectTransformSizeDelta(self.TopicBG, 850, 64)
	end

	self.leftTime = 5
	self.CloseTip.text = string.format(_("Desc_TopicTipAutoClose"), math.ceil(self.leftTime))

	UIMgr.SetUpdatePanel(self)
end

function DlgNewUnreadMessage:OnClickedCall()
	PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_NEW_TOPIC, {})
	PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_NEW_PHONE_CALL, {})
	require("UI/Page/PageCommunication/PageAddressBookNew")
	UIMgr.SwitchPanel(PageAddressBookNew, {
		roleId = self.roleId,
		tabType = self.openTab
	})
	self:Close()
end

function DlgNewUnreadMessage:OnClickedHandOff()
	self:ShowCloseEffect()
end

function DlgNewUnreadMessage:OnUpdate()
	if self.isEnd then
		return
	end

	if self.leftTime < 0 then
		self:ShowCloseEffect()

		self.isEnd = true
	else
		self.leftTime = self.leftTime - Time.deltaTime
		self.CloseTip.text = string.format(_("Desc_TopicTipAutoClose"), TenaryOp(self.leftTime > 0, math.ceil(self.leftTime), 0))
	end
end

function DlgNewUnreadMessage:ShowCloseEffect()
	local panel = UIMgr.GetCurPanel()

	if panel.className ~= "PageMainStage" then
		self:Close()

		return
	end

	self.GoSystem = panel.BtnSecondSystem4

	EffectMgr:Alloc("Fx/UI/Eff_UI_DlgSystemOpen/FX_UI_DlgSystemOpen_Start", self.GoEffPoint, true, 1)
	self.Panel:SetActive(false)

	self.BG.color = Color.New(0, 0, 0, 0)
	self.Timer1 = TimerMgr.AddTimer(eTimerType.ScaleTime, 0.5, function()
		if IsNil(self.UIRootObject) then
			self:Close()

			return
		end

		if IsNil(self.PrefabFlyEff) then
			self:Close()

			return
		end

		local eff = GOUtil.InstantiatePrefab(self.PrefabFlyEff, self.UIRootObject)
		local x1, y1, z1 = GOUtil.GetTransformPosition(self.GoEffPoint, x1, y1, z1)

		GOUtil.SetTransformPosition(eff, x1, y1, z1)

		if IsNil(self.GoSystem) then
			self:Close()

			return
		end

		local x, y, z = GOUtil.GetTransformPosition(self.GoSystem, x, y, z)

		if IsNil(self.GoEffPoint) then
			self:Close()

			return
		end

		GOUtil.SetTransformPosition(self.GoEffPoint, x, y, z)

		self.tweener = eff.transform:DOMove(Vector3(x, y, z), 0.3)

		GOUtil.SetTweenerCallback(self.tweener, function()
			self.Timer2 = TimerMgr.AddTimer(eTimerType.ScaleTime, 0.15, function()
				Object.Destroy(eff)
				EffectMgr:Alloc("Fx/UI/Eff_UI_DlgSystemOpen/FX_UI_DlgSystemOpen_End", self.GoEffPoint, true, 1)
				require("UI/Page/PageCommunication/DlgNewTopicTip")

				if UIMgr.GetCurPanel().className == "PageMainStage" then
					UIMgr.AddPanel(DlgNewTopicTip(), {
						count = self.TopicCount + self.PhoneCount
					}, UIMgr.GetCurPanel().BtnSecondSystem4)
				end

				self:Close()
				self.tweener:Kill()
			end, nil)
		end)
	end, nil)
end
