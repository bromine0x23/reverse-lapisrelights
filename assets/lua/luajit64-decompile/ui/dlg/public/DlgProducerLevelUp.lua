-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Public/DlgProducerLevelUp.lua

DlgProducerLevelUp = class("DlgProducerLevelUp", UIPanel)

function DlgProducerLevelUp:ctor()
	self.callback = nil
	self.callback1 = nil
	self.UIPrefabPath = "UI/Common/DlgProducerLevelUp/DlgProducerLevelUp"
end

function DlgProducerLevelUp:PreLoad()
	return
end

function DlgProducerLevelUp:Purge()
	DlgProducerLevelUp.base.Purge(self)

	if self.timer then
		TimerMgr.RemoveTimer(self.timer)

		self.timer = nil
	end
end

function DlgProducerLevelUp:OnRegisterEvent()
	self:AddClick(self.ButtonQuit, self.OnClickedButtonQuit)
end

function DlgProducerLevelUp:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonQuit, self.OnClickedButtonQuit)
end

function DlgProducerLevelUp:OnEnter(vParam)
	self.ButtonQuit = self:GetChildGameObject("Bg")

	if vParam and vParam.callback then
		self.callback1 = vParam.callback
	end

	if vParam and vParam.DlgNewBossRaidFunc then
		self.DlgNewBossRaidFunc = vParam.DlgNewBossRaidFunc
	end

	self.isCanClose = false
	self.timer = TimerMgr.AddTimer(eTimerType.RealTime, 1, function()
		self.isCanClose = true
	end, nil)

	SoundMgr.PostEvent(PATH_SFX_UI_PLAYER_LEVELUP, self.UIRootObject)

	local preLevel = PlayerInst.InfoPlayer.preLevel

	if vParam ~= nil and vParam.perLevel ~= nil then
		preLevel = vParam.perLevel
	end

	local curLevel = PlayerInst:GetCurLv()
	local textTitle = self:GetChildComponent("Panel/TxtTitle", "Text")

	textTitle.text = _("Player_LvUp")

	local Text = self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/ToUnlock/Text", "Text")

	Text.text = _("Desc_Player_Level_Open")
	self.Img_bg_panel = self:GetChildGameObject("Panel/BgPanel/Img_bg_panel")

	local txtPreLv = self:GetChildComponent("Panel/PlayerLv/TxtPreLv", "Text")
	local txtCurLv = self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/Title/Image/TxtCurLv", "Text")
	local txtSupportCardPre = self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/SupportCard/TxtPre", "Text")
	local txtSupportCardCur = self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/SupportCard/TxtCur", "Text")

	txtPreLv.text = string.format(_("Desc_Level"), preLevel)
	txtCurLv.text = curLevel .. ""

	local curPower = PlayerInst:GetPower()
	local PlayerLevelAward = LevelManager:GetValue("PlayerLevelAward", preLevel)
	local addPower = 0

	for _, datas in ipairs(PlayerLevelAward) do
		if datas[1] == 503 then
			addPower = datas[2] * (curLevel - preLevel)

			break
		end
	end

	local infoItem = ItemManager:GetItemByType("P_POWER")

	if infoItem then
		local curHoldPower = infoItem:GetCurResNum()

		if curHoldPower + addPower > infoItem.data.MaxNum then
			addPower = infoItem.data.MaxNum - curHoldPower
		end
	end

	local txtPre = self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/PlayerPower/TxtPre", "Text")
	local txtCur = self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/PlayerPower/TxtCur", "Text")

	self.BgPanel = self:GetChildGameObject("Panel/BgPanel")

	local bkGo0 = self:GetChildGameObject("Panel/BgPanel/ScrollArea/Viewport/Content/Bk0")
	local bkGo1 = self:GetChildGameObject("Panel/BgPanel/ScrollArea/Viewport/Content/Bk1")
	local bkGo2 = self:GetChildGameObject("Panel/BgPanel/ScrollArea/Viewport/Content/Bk2")
	local bkGo3 = self:GetChildGameObject("Panel/BgPanel/ScrollArea/Viewport/Content/Bk3")
	local PlayerPower = self:GetChildGameObject("Panel/BgPanel/ScrollArea/Viewport/Content/PlayerPower")
	local LevelGo = self:GetChildGameObject("Panel/BgPanel/ScrollArea/Viewport/Content/Level")
	local costGo = self:GetChildGameObject("Panel/BgPanel/ScrollArea/Viewport/Content/Cost")
	local supportCardGo = self:GetChildGameObject("Panel/BgPanel/ScrollArea/Viewport/Content/SupportCard")
	local ToUnlockGo = self:GetChildGameObject("Panel/BgPanel/ScrollArea/Viewport/Content/ToUnlock")
	local tolock1Go = self:GetChildGameObject("Panel/BgPanel/ScrollArea/Viewport/Content/ToUnlock/ScrollArea/Viewport/Content/go1")
	local Tex_tolock1 = self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/ToUnlock/ScrollArea/Viewport/Content/go1/Tex_tolock", "Text")
	local Tex_locklevel1 = self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/ToUnlock/ScrollArea/Viewport/Content/go1/Tex_locklevel", "Text")
	local tolock2Go = self:GetChildGameObject("Panel/BgPanel/ScrollArea/Viewport/Content/ToUnlock/ScrollArea/Viewport/Content/go2")
	local Tex_tolock2 = self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/ToUnlock/ScrollArea/Viewport/Content/go2/Tex_tolock", "Text")
	local Tex_locklevel2 = self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/ToUnlock/ScrollArea/Viewport/Content/go2/Tex_locklevel", "Text")
	local tolock3Go = self:GetChildGameObject("Panel/BgPanel/ScrollArea/Viewport/Content/ToUnlock/ScrollArea/Viewport/Content/go3")
	local Tex_tolock3 = self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/ToUnlock/ScrollArea/Viewport/Content/go3/Tex_tolock", "Text")
	local Tex_locklevel3 = self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/ToUnlock/ScrollArea/Viewport/Content/go3/Tex_locklevel", "Text")
	local tolock4Go = self:GetChildGameObject("Panel/BgPanel/ScrollArea/Viewport/Content/ToUnlock/ScrollArea/Viewport/Content/go4")
	local Tex_tolock4 = self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/ToUnlock/ScrollArea/Viewport/Content/go4/Tex_tolock", "Text")
	local Tex_locklevel4 = self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/ToUnlock/ScrollArea/Viewport/Content/go4/Tex_locklevel", "Text")
	local bgPanelGo = self:GetChildGameObject("Panel/BgPanel")
	local curTotalCost = LevelManager:GetMaxCost(PlayerInst:GetCurLv())
	local lastTotalCost = LevelManager:GetMaxCost(PlayerInst:GetCurLv() - 1)
	local countList = {}

	for i = 1, 4 do
		countList[i] = 0
	end

	if addPower > 0 then
		bkGo0:SetActive(true)
		PlayerPower:SetActive(true)

		self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/PlayerPower/TxtStatic", "Text").text = _("Desc_Cur_Power_Up")
		countList[1] = 1

		local strL = string.format("%d", curPower)
		local strR = string.format("（+%d）", addPower)

		txtPre.text = strL
		txtCur.text = strR
	end

	if lastTotalCost < curTotalCost then
		bkGo2:SetActive(true)
		costGo:SetActive(true)

		local costTxtPre = self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/Cost/TxtPre", "Text")
		local costTxtCur = self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/Cost/TxtCur", "Text")

		costTxtPre.text = curTotalCost
		costTxtCur.text = string.format("（+%d）", curTotalCost - lastTotalCost)
		countList[2] = 1
	end

	local TeamPositionMessageList = GetConfigArgJson("TeamPositionMessage")

	for i, v in ipairs(TeamPositionMessageList) do
		if preLevel < TeamPositionMessageList[i][2] and curLevel >= TeamPositionMessageList[i][2] then
			bkGo3:SetActive(true)
			supportCardGo:SetActive(true)

			self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/SupportCard/Text", "Text").text = _("Msg_RoleCantAdd")
			txtSupportCardCur.text = "（+1）"
			txtSupportCardPre.text = i
			countList[3] = 1
		end
	end

	local RoleCardLevelLimitList = GetConfigArgJson("RoleCardLevelLimit")

	for i, v in ipairs(RoleCardLevelLimitList) do
		if preLevel < RoleCardLevelLimitList[i][1] and curLevel >= RoleCardLevelLimitList[i][1] and RoleCardLevelLimitList[i - 1] then
			bkGo1:SetActive(true)
			LevelGo:SetActive(true)

			local LevelTxtPre = self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/Level/TxtPre", "Text")
			local LevelTxtCur = self:GetChildComponent("Panel/BgPanel/ScrollArea/Viewport/Content/Level/TxtCur", "Text")

			LevelTxtPre.text = RoleCardLevelLimitList[i][2]
			LevelTxtCur.text = string.format("（+%d）", RoleCardLevelLimitList[i][2] - RoleCardLevelLimitList[i - 1][2])
			countList[4] = 1
		end
	end

	tolock1Go:SetActive(false)
	tolock2Go:SetActive(false)
	tolock3Go:SetActive(false)
	tolock4Go:SetActive(false)

	local lockCount = 0
	local toLockPosy = 0

	if #LevelManager:GetNextUp(curLevel) ~= 0 then
		ToUnlockGo:SetActive(true)

		toLockPosy = 30

		local NextUpList = LevelManager:GetNextUp(curLevel)

		for i = 1, #NextUpList do
			if NextUpList[i][1] == 1 then
				tolock4Go:SetActive(true)

				lockCount = lockCount + 1
				Tex_tolock4.text = _("Filter_Card_3")
				Tex_locklevel4.text = string.format(_("Superviso_Cost"), "<size=30>" .. NextUpList[i][3] .. "</size><size=24>", "\n\n</size><size=28>", "\n<color=#16dfe7>", NextUpList[i][2] .. "</color></size>")
				toLockPosy = toLockPosy + 30
			elseif NextUpList[i][1] == 2 then
				tolock3Go:SetActive(true)

				lockCount = lockCount + 1
				Tex_tolock3.text = _("Dese_CardLevelMax")
				Tex_locklevel3.text = string.format(_("Superviso_Card"), "<size=30>" .. NextUpList[i][3] .. "</size><size=24>", "\n\n</size><size=28>", "\n<color=#16dfe7>", NextUpList[i][2] .. "</color></size>")
				toLockPosy = toLockPosy + 30
			elseif NextUpList[i][1] == 3 then
				tolock2Go:SetActive(true)

				lockCount = lockCount + 1
				Tex_tolock2.text = _("Msg_RoleCantAdd")
				Tex_locklevel2.text = string.format(_("Superviso_Assist"), "<size=30>" .. NextUpList[i][3] .. "</size><size=24>", "\n\n</size><size=28>", "\n<color=#16dfe7>", NextUpList[i][2], "</color></size>")
				toLockPosy = toLockPosy + 30
			elseif NextUpList[i][1] == 4 then
				tolock1Go:SetActive(true)

				lockCount = lockCount + 1

				local colorTex = string.format("<color=#59D728>%s</color>", curLevel)

				Tex_locklevel1.text = string.format(_("Superviso_Spirit"), "<size=30>" .. NextUpList[i][3] .. "</size><size=24>", "\n\n</size><size=28>", "\n<color=#16dfe7>", NextUpList[i][2] .. "</color></size>")
			end
		end
	end

	local count = 0

	for i = 1, 4 do
		if countList[i] == 1 then
			count = count + 1
		end
	end

	if count == 1 then
		GOUtil.SetRectTransformSizeDelta(self.Img_bg_panel, 1266, 70)
		GOUtil.SetRectTransformSizeDelta(self.BgPanel, 1920, 300)
		GOUtil.SetRectTransformAnchoredPosition(self.BgPanel, 0, 420)
	elseif count == 2 then
		GOUtil.SetRectTransformSizeDelta(self.Img_bg_panel, 1266, 140)
		GOUtil.SetRectTransformSizeDelta(self.BgPanel, 1920, 345)
		GOUtil.SetRectTransformAnchoredPosition(self.BgPanel, 0, 450)
	elseif count == 3 then
		GOUtil.SetRectTransformSizeDelta(self.Img_bg_panel, 1266, 210)
		GOUtil.SetRectTransformSizeDelta(self.BgPanel, 1920, 370)
		GOUtil.SetRectTransformAnchoredPosition(self.BgPanel, 0, 480)
	elseif count == 4 then
		GOUtil.SetRectTransformSizeDelta(self.Img_bg_panel, 1266, 280)
		GOUtil.SetRectTransformSizeDelta(self.BgPanel, 1920, 400)
		GOUtil.SetRectTransformAnchoredPosition(self.BgPanel, 0, 510)
	elseif count == 0 then
		GOUtil.SetRectTransformSizeDelta(self.Img_bg_panel, 1266, 0)
		GOUtil.SetRectTransformSizeDelta(self.BgPanel, 1920, 270)
		GOUtil.SetRectTransformAnchoredPosition(self.BgPanel, 0, 390)
	end

	if lockCount == 0 then
		GOUtil.SetRectTransformAnchoredPosition(self.BgPanel, 0, 300)
	end

	if TutorialMgr:IsNeedSwitchMainStage() then
		function self.callback()
			if self.callback1 then
				self.callback1()

				self.callback1 = nil
			end

			local curScene = SceneMgr.GetCurrentScene()

			if curScene.className == "SceneMainStage" then
				UIMgr.SwitchPanel(PageMainStage)
			else
				SceneMgr.LoadScene("MainStage")
			end
		end
	end

	SetterData.showLevelup = false
end

function DlgProducerLevelUp:OnClickedButtonQuit()
	if not self.isCanClose then
		return
	end

	Event.Instance:Fire("DlgUIVictoryChangeHaveLife")

	if self.callback then
		self.callback()

		self.callback = nil
	end

	if self.callback1 then
		self.callback1()

		self.callback1 = nil
	end

	if self.DlgNewBossRaidFunc then
		self.DlgNewBossRaidFunc()

		self.DlgNewBossRaidFunc = nil
	end

	self:Purge()
end

function DlgProducerLevelUp:OnBackAndroid()
	self:OnClickedButtonQuit()
end
