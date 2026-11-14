-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCommunication/DlgCallIn.lua

DlgCallIn = class("DlgCallIn", UIPanel, true)

function DlgCallIn:ctor()
	self.UIPrefabPath = "UI/PageCommunication/DlgCallIn"
end

function DlgCallIn:PreLoad()
	self:LoadResAsync("Fx/UI/Eff_UI_DlgSystemOpen/FX_UI_DlgSystemOpen_Fly", "PrefabFlyEff")
end

function DlgCallIn:Purge()
	DlgCallIn.base.Purge(self)
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
	SoundMgr.UnloadBank("SE_ADV")
end

function DlgCallIn:OnRegisterEvent()
	self:AddClick(self.Button1, self.OnButton1Click)
	self:AddClick(self.Button2, self.OnButton2Click)
end

function DlgCallIn:OnUnRegisterEvent()
	self:RemoveClick(self.Button1, self.OnButton1Click)
	self:RemoveClick(self.Button2, self.OnButton2Click)
end

function DlgCallIn:OnEnter(vParam)
	if vParam.callId then
		self.callId = vParam.callId
		self.isCall = true
	end

	if vParam.topicId then
		self.topicId = vParam.topicId
		self.isCall = false
	end

	if self.isCall then
		SoundMgr.Play(PATH_SFX_UI_COMM)

		local infoCall = PhoneCallManager:Get(self.callId)

		self.infoRole = RoleMgr:GetRole(infoCall.data.RoleId)
		self.roleId = infoCall.data.RoleId
	else
		local infoTopic = TopicManager:GetTopic(self.topicId)

		self.infoRole = RoleMgr:GetRole(infoTopic.data.RoleId)
		self.roleId = infoTopic.data.RoleId
	end

	self.Button1 = self:GetChildGameObject("Panel/Bg/Button1")
	self.Button2 = self:GetChildGameObject("Panel/Bg/Button2")
	self.GoEffPoint = self:GetChildGameObject("EffPoint")
	self.ImageHead = self:GetChildComponent("Panel/Bg/CellHead/Image", "Image")
	self.TextName = self:GetChildComponent("Panel/Bg/Name", "Text")
	self.MailBg = self:GetChildGameObject("Panel/Bg/MailBg")
	self.PhoneBg = self:GetChildGameObject("Panel/Bg/PhoneBg")
	self.Mail = self:GetChildGameObject("Panel/Bg/Mail")
	self.Phone = self:GetChildGameObject("Panel/Bg/Phone")
	self.Panel = self:GetChildGameObject("Panel")
	self.Mask = self:GetChildComponent("", "Image")

	SetActiveFunc(self.MailBg, not self.isCall)
	SetActiveFunc(self.PhoneBg, self.isCall)
	SetActiveFunc(self.Mail, not self.isCall)
	SetActiveFunc(self.Phone, self.isCall)
	UIUtil.SetImageSprite(self.ImageHead, self.infoRole.actorData.CharacterIcon, self)

	self.TextName.text = self.infoRole:GetCommuName()

	self:DealWithLocalization()
end

function DlgCallIn:EndCall(needMsg)
	if needMsg then
		self:ShowCloseEffect()
	else
		self:Close()
	end

	SoundMgr.Stop(PATH_SFX_UI_COMM)
end

function DlgCallIn:DealWithLocalization()
	local Tip = self:GetChildComponent("Panel/Bg/Tip", "Text")

	if self.isCall then
		Tip.text = _("Desc_CallIn")
	else
		Tip.text = _("Desc_TopicIn")
	end
end

function DlgCallIn:OnButton1Click()
	if self.isCall then
		self:OnClickedCall()
	else
		self:OnClickedTopic()
	end
end

function DlgCallIn:OnButton2Click()
	if self.isCall then
		self:OnClickedHandOff(true)
	else
		self:ShowCloseEffect()
	end
end

function DlgCallIn:OnClickedCall()
	self:OnClickedHandOff(false)

	local data = {}

	data.from = 2
	data.callId = self.callId
	data.roleId = self.roleId

	local g = GameObject.Find("PanelStage(Clone)")

	if g then
		data.stageId = ChapterMgr:GetCurStage().id
	else
		data.stageId = 0
	end

	if InstructionMgr.isGuideCall then
		data.stageId = ChapterMgr:GetCurStage().id
		InstructionMgr.isGuideCall = false
	end

	SoundMgr.Stop(PATH_SFX_UI_COMM)

	if not AppConst.AssetBundleMode then
		PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_NEW_TOPIC, {})
		PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_NEW_PHONE_CALL, {})
		SceneMgr.LoadScene("Call", data)
	else
		local exist, type = OptionDownMgr:CheckBundleExist(data.callId, 2)

		if exist then
			PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_NEW_TOPIC, {})
			PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_NEW_PHONE_CALL, {})
			SceneMgr.LoadScene("Call", data)
		else
			local function cb()
				PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_NEW_TOPIC, {})
				PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_NEW_PHONE_CALL, {})
				SceneMgr.LoadScene("Call", data)
			end

			local downloadData = {}

			downloadData.callback = cb
			downloadData.existType = type
			downloadData.stageId = data.callId
			downloadData.openFrom = 2

			require("UI/Page/PageSetting/DlgOptionalDownload")
			UIMgr.AddPanel(DlgOptionalDownload(), downloadData)
		end
	end
end

function DlgCallIn:OnClickedHandOff(needMsg)
	self:EndCall(needMsg)
end

function DlgCallIn:OnClickedTopic()
	PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_NEW_TOPIC, {})
	PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_NEW_PHONE_CALL, {})

	local data = {}

	data.roleId = self.roleId
	data.topicId = self.topicId

	local g = GameObject.Find("PanelStage(Clone)")

	if g then
		data.stageId = ChapterMgr:GetCurStage().id
	else
		data.stageId = 0
	end

	SceneMgr.LoadScene("Communication", data)
	self:Close()
end

function DlgCallIn:ShowCloseEffect()
	local panel = UIMgr.GetCurPanel()

	if panel.className ~= "PageMainStage" then
		self:Close()

		return
	end

	self.GoSystem = panel.BtnSecondSystem4

	EffectMgr:Alloc("Fx/UI/Eff_UI_DlgSystemOpen/FX_UI_DlgSystemOpen_Start", self.GoEffPoint, true, 1)
	self.Panel:SetActive(false)

	self.Mask.color = Color.New(0, 0, 0, 0)
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
						count = 1,
						roleId = self.roleId
					}, UIMgr.GetCurPanel().BtnSecondSystem4)
				end

				self:Close()
				self.tweener:Kill()
			end, nil)
		end)
	end, nil)
end

function DlgCallIn:OnBackAndroid()
	self:OnButton2Click()
end
