-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCommunication/DlgTopicIn.lua

DlgTopicIn = class("DlgTopicIn", UIPanel, true)

function DlgTopicIn:ctor()
	self.UIPrefabPath = "UI/PageCommunication/DlgTopicIn"
end

function DlgTopicIn:PreLoad()
	self:LoadResAsync("Fx/UI/Eff_UI_DlgSystemOpen/FX_UI_DlgSystemOpen_Fly", "PrefabFlyEff")
end

function DlgTopicIn:Purge()
	DlgTopicIn.base.Purge(self)
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

function DlgTopicIn:OnRegisterEvent()
	self:AddClick(self.AnswerBtn, self.OnClickedCall)
	self:AddClick(self.CloseBtn, self.OnClickedHandOff)
end

function DlgTopicIn:OnUnRegisterEvent()
	self:RemoveClick(self.AnswerBtn, self.OnClickedCall)
	self:RemoveClick(self.CloseBtn, self.OnClickedHandOff)
end

function DlgTopicIn:OnEnter(vParam)
	FingerGesturesUtil.Disable()

	self.TopicId = vParam.topicId
	self.TopicCount = vParam.count
	self.TextTip = self:GetChildComponent("Panel/Tip", "Text")
	self.CloseTip = self:GetChildComponent("Panel/CloseTip", "Text")
	self.HeadIcon = self:GetChildComponent("Panel/HeadIcon", "Image")
	self.AnswerBtn = self:GetChildGameObject("Panel/Answer")
	self.CloseBtn = self:GetChildGameObject("Panel/Close")
	self.GoEffPoint = self:GetChildGameObject("EffPoint")
	self.Panel = self:GetChildGameObject("Panel")

	local infoTopic = TopicManager:GetTopic(self.TopicId)
	local infoRole = RoleMgr:GetRole(infoTopic.data.RoleId)

	self.roleId = infoTopic.data.RoleId

	UIUtil.SetImageSprite(self.HeadIcon, "UIDyAtlas/CharacterIcon/IC_IDH_" .. infoRole.data.Enname .. "_02", self)

	self.TextTip.text = string.format("%sからの通信", tostring(infoRole:GetCommuName()))

	UIMgr.SetUpdatePanel(self)

	self.leftTime = 3
end

function DlgTopicIn:OnClickedCall()
	PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_NEW_TOPIC, {})
	PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_NEW_PHONE_CALL, {})

	local data = {}

	data.roleId = self.roleId
	data.topicId = self.TopicId

	local g = GameObject.Find("PanelStage(Clone)")

	if g then
		data.stageId = ChapterMgr:GetCurStage().id
	else
		data.stageId = 0
	end

	SceneMgr.LoadScene("Communication", data)
	self:Close()
end

function DlgTopicIn:OnClickedHandOff()
	self:ShowCloseEffect()
end

function DlgTopicIn:OnUpdate()
	if self.isEnd then
		return
	end

	if self.leftTime < 0 then
		self:ShowCloseEffect()

		self.isEnd = true
	else
		self.leftTime = self.leftTime - Time.deltaTime
		self.CloseTip.text = string.format("%s秒後に閉じます", math.ceil(self.leftTime))
	end
end

function DlgTopicIn:ShowCloseEffect()
	local panel = UIMgr.GetCurPanel()

	if panel.className ~= "PageMainStage" then
		self:Close()

		return
	end

	self.GoSystem = panel.BtnSecondSystem4

	EffectMgr:Alloc("Fx/UI/Eff_UI_DlgSystemOpen/FX_UI_DlgSystemOpen_Start", self.GoEffPoint, true, 1)
	self.Panel:SetActive(false)

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
						count = self.TopicCount,
						topicId = self.TopicId
					}, UIMgr.GetCurPanel().BtnSecondSystem4)
				end

				self:Close()
				self.tweener:Kill()
			end, nil)
		end)
	end, nil)
end
