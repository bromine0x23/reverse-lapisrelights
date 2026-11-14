-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUIVictory.lua

require("UI/Dlg/Common/DlgGetAward")
require("UI/Dlg/Common/CellCardUp")
require("UI/Page/PageFight/Cells/CellBattleAch")
require("UI/Page/PageFight/Cells/CellExtraAward")

DlgUIVictory = class("DlgUIVictory", UIPanel_sync)

function DlgUIVictory:ctor()
	DlgUIVictory.base.ctor(self, "UI/PageFight/Dlg/DlgUIVictory")
end

function DlgUIVictory:PreLoad()
	self.PrefabCellCardUp = ResourceMgr.LoadSync("UI/Common/CellCard/CellCardUp")
	self.PrefabCellBattleAch = ResourceMgr.LoadSync("UI/PageFight/Cells/CellBattleAch")
	self.PrefabCellItem = ResourceMgr.LoadSync("UI/Item/CellItem")
	self.CellExtraAward = ResourceMgr.LoadSync("UI/PageFight/Cells/CellExtraAward")
end

function DlgUIVictory:OnRegisterEvent()
	self:AddClick(self.GoClickArea, self.OnClickedCloseArea)
	self:AddClick(self.GoClickArea2, self.OnClickedCloseAnim)
	self:AddClick(self.btn_Replay, self.OnClickedReplay)
	self:AddClick(self.btn_Result, self.OnClickedResultAddUp)
	self:AddClick(self.btn_Replay2, self.OnClickedReplay)
	self:AddClick(self.btn_Result2, self.OnClickedResultAddUp)
	self:AddClick(self.Btn_again, self.OnClickedBtnAgain, "Play_SE_020_0028")
	self:AddClick(self.Btn_enter, self.OnClickedBtnEnter)
	self:AddClick(self.Btn_enter2, self.OnClickedBtnEnter)
	self:AddClick(self.Btn_sweep, self.OnClickedBtnSweep)
	self:AddClick(self.Btn_addfriend, self.OnClickedBtnAddfriend)
	self:AddClick(self.Btn_addfriend2, self.OnClickedBtnAddfriend)
	self:AddClick(self.Btn_Extra_OK, self.OnClickedExtraClose)
	self:AddClick(self.Btn_Extra_OK2, self.OnClickedExtraClose)
	self:AddClick(self.Btn_Extra2_OK, self.OnClickedExtraClose)
	self:AddClick(self.Btn_Extra2_OK2, self.OnClickedExtraClose)
	Event.Instance:Add("DlgUIVictoryChangeHaveLife", self.DlgUIVictoryChangeHaveLife, self)
end

function DlgUIVictory:OnUnRegisterEvent()
	self:RemoveClick(self.GoClickArea, self.OnClickedCloseArea)
	self:RemoveClick(self.GoClickArea2, self.OnClickedCloseAnim)
	self:RemoveClick(self.btn_Replay, self.OnClickedReplay)
	self:RemoveClick(self.btn_Result, self.OnClickedResultAddUp)
	self:RemoveClick(self.btn_Replay2, self.OnClickedReplay)
	self:RemoveClick(self.btn_Result2, self.OnClickedResultAddUp)
	self:RemoveClick(self.Btn_again, self.OnClickedBtnAgain)
	self:RemoveClick(self.Btn_enter, self.OnClickedBtnEnter)
	self:RemoveClick(self.Btn_enter2, self.OnClickedBtnEnter)
	self:RemoveClick(self.Btn_sweep, self.OnClickedBtnSweep)
	self:RemoveClick(self.Btn_addfriend, self.OnClickedBtnAddfriend)
	self:RemoveClick(self.Btn_addfriend2, self.OnClickedBtnAddfriend)
	self:RemoveClick(self.Btn_Extra_OK, self.OnClickedExtraClose)
	self:RemoveClick(self.Btn_Extra_OK2, self.OnClickedExtraClose)
	self:RemoveClick(self.Btn_Extra2_OK, self.OnClickedExtraClose)
	self:RemoveClick(self.Btn_Extra2_OK2, self.OnClickedExtraClose)
	Event.Instance:Remove("DlgUIVictoryChangeHaveLife", self.DlgUIVictoryChangeHaveLife, self)

	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end
end

function DlgUIVictory:Purge()
	DlgUIVictory.base.Purge(self)

	self.PrefabCellCardUp = nil
	self.PrefabCellBattleAch = nil

	if self.listCardItem then
		for i, v in ipairs(self.listCardItem) do
			v:Purge()
		end

		self.listCardItem = nil
	end

	self:OnLeave()
end

function DlgUIVictory:ClearTime()
	if self.Timer0 then
		TimerMgr.RemoveTimer(self.Timer0)
	end

	if self.Timer1 then
		TimerMgr.RemoveTimer(self.Timer1)
	end

	if self.Timer2 then
		TimerMgr.RemoveTimer(self.Timer2)
	end

	if self.Timer3 then
		TimerMgr.RemoveTimer(self.Timer3)
	end

	if self.Timer4 then
		TimerMgr.RemoveTimer(self.Timer4)
	end

	if self.Timer5 then
		TimerMgr.RemoveTimer(self.Timer5)
	end

	InfoSoundEventMgr:OnBack()
end

function DlgUIVictory:OnLeave()
	self:ClearTime()
end

function DlgUIVictory:PlayRoleSpine(cardId)
	self.isPlayRoleSpine = true

	local infoRoleCard = RoleCardMgr:GetRoleCard(cardId)
	local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)
	local hasNewRole = true

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

				self:Open(self.data)
			end,
			setter = infoRoleCard
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

function DlgUIVictory:Open(vParam)
	if not vParam then
		return
	end

	self.data = vParam
	self.infoStage = vParam.infoStage
	self.stars = vParam.stars
	self.listEnemyId = vParam.listMonsterId
	self.listRoleCardId = vParam.playerCardIds
	self.dropRaidBossId = tonumber(vParam.dropRaidBossId)
	self.dropRaidBossStageId = tonumber(vParam.dropRaidBossStageId)

	local setter = SetterData.GetSetterData(vParam.setter)

	setter:Parse()

	if CACHED_PLAYER then
		PlayerInst.InfoPlayer:SetPlayerRes(CACHED_PLAYER)

		CACHED_PLAYER = nil
	end

	self.listFirst = setter:Getlist(protocol_pb.AF_STAGE_FIRST)

	if self.listFirst and not self.isPlayRoleSpine then
		local cnt = #self.listFirst

		for i = 1, cnt do
			local s = self.listFirst[i]

			if s.asset == protocol_pb.RC_RECEIVE then
				local infoItem = SetterData.GetItemFromAsset(s)

				if s.newRoleCard ~= nil and s.newRoleCard.id > 0 then
					self:PlayRoleSpine(infoItem.pb.num)

					return
				end
			end
		end
	end

	self.listNormal = setter:Getlist(protocol_pb.AF_NORMAL)
	self.listStar1 = setter:Getlist(protocol_pb.AF_STAGE_STAR)
	self.listStar2 = setter:Getlist(protocol_pb.AF_STAGE_STAR2)
	self.listStar3 = setter:Getlist(protocol_pb.AF_STAGE_STAR3)
	self.listLvUp = setter:Getlist(protocol_pb.AF_TEAM_LV_UP)
	self.listEnemy = setter:Getlist(protocol_pb.AF_STAGE_MONSTER)
	self.listWhip = setter:Getlist(protocol_pb.AF_STAGE_WHIP)
	self.listPlayer = setter:Getlist(protocol_pb.AF_TEAM_LV_UP)
	self.listHigh = setter:Getlist(protocol_pb.AF_STAGE_HIGH_AWARD)
	self.listActiveAward = setter:Getlist(protocol_pb.AF_ACTIVE_AWARD)

	if self.infoStage.data.Type == StageFromType.activeBoss or self.infoStage.data.Type == StageFromType.unionCommon or self.infoStage.data.Type == StageFromType.unionBoss then
		-- block empty
	elseif SetterData.haveOverItem and #self.listWhip == 0 then
		UIMgr.ShowMsg(_("Msg_OverItem_Common"))

		SetterData.haveOverItem = false
	end

	self.PlayerExpModify = 0
	self.RoleExpSetterTbl = {}

	for k, s in ipairs(setter.list) do
		if s.asset == protocol_pb.P_LEVEL_EXP then
			self.PlayerExpModify = s.num
		elseif s.asset == protocol_pb.RC_LEVEL_EXP then
			if self.RoleExpSetterTbl == nil then
				self.RoleExpSetterTbl = {}
			end

			table.insert(self.RoleExpSetterTbl, s)
		end
	end

	local Text = self:GetChildComponent("Panel/GoAgain/Btn_again/Text2", "Text")

	Text.text = _("eBtn_PlayAgain")
	Text = self:GetChildComponent("Panel/GoAgain/Btn_enter/Text2", "Text")
	Text.text = _("eBtn_NextStep")

	if self.infoStage:GetMaxLeftPlayNum() ~= 0 and stageType ~= 2 and self.infoStage.data.Type ~= 8 then
		self.leftNum = ChapterMgr:GetStageLeftPlayNumWithLimit(self.infoStage.id)

		if self.infoStage.data.ChapterType == ChapterFromType.card then
			self.leftNum = 1
		end

		if self.leftNum ~= 0 then
			-- block empty
		else
			self.Btn_again:SetActive(false)
			GOUtil.SetRectTransformAnchoredPosition(self.Btn_enter.gameObject, -300, 20)
		end

		self.textPlayNum.text = self.leftNum .. "/" .. self.infoStage:GetMaxLeftPlayNum()

		if self.infoStage.data.ChapterType == ChapterFromType.card then
			self.textPlayNum.text = 0 .. "/" .. self.infoStage:GetMaxLeftPlayNum()

			GOUtil.SetRectTransformAnchoredPosition(self.Btn_enter.gameObject, -300, 20)
		elseif self.infoStage.data.ChapterType == ChapterFromType.activity then
			-- block empty
		end
	else
		self.textPlayNum.text = "∞/∞"
		self.textPlayNum2.text = "∞/∞"
	end

	if self.infoStage.data.Type == StageFromType.common and self.infoStage.data.ChapterType == ChapterFromType.activity and ActiveMgr:GetActiveSumPlayNum(self.infoStage) == 0 then
		self.Btn_again:SetActive(false)
		GOUtil.SetRectTransformAnchoredPosition(self.Btn_enter.gameObject, -300, 20)
	end

	self.costNum1.text = self.infoStage:GetCostItem()[2] or 0

	if self.infoStage.data.Type == StageFromType.timespace then
		TimeSpaceChapterMgr:BattleEnd(self.listRoleCardId, self.infoStage.data.ID)
		self.Panel:SetActive(false)
		self.Panel2:SetActive(false)
		self.Panel3:SetActive(true)
	elseif self.infoStage.data.Type ~= 8 then
		self.Panel:SetActive(true)
		self.Panel2:SetActive(false)
		self.Panel3:SetActive(false)
		self.Btn_again2:SetActive(true)
		self.Btn_enter2:SetActive(false)

		self.curPowerNum.text = PlayerInst:GetPower() .. ""
	else
		self.Panel:SetActive(false)
		self.Panel2:SetActive(true)
		self.Panel3:SetActive(false)
		self.Btn_again2:SetActive(false)
		self.Btn_enter2:SetActive(true)

		self.curPowerNum2.text = PlayerInst:GetPower() .. ""
		TowerChapterMgr.stageUp = true
	end

	if SetterData.showLevelup then
		local preLevel = PlayerInst.InfoPlayer.preLevel

		if vParam ~= nil and vParam.perLevel ~= nil then
			preLevel = vParam.perLevel
		end

		local curLevel = PlayerInst:GetCurLv()
		local curPower = PlayerInst:GetPower()
		local PlayerLevelAward = LevelManager:GetValue("PlayerLevelAward", preLevel)
		local addPower = 0

		for _, datas in ipairs(PlayerLevelAward) do
			if datas[1] == 503 then
				addPower = datas[2]

				break
			end
		end

		self.curPowerNum.text = tostring(tonumber(PlayerInst:GetPower()) - addPower) .. ""
	else
		self.curPowerNum.text = PlayerInst:GetPower() .. ""
	end

	local canSweep = self.infoStage:CanSweep() and self.infoStage:IsFullStar() and not TutorialMgr:IsNeedSwitchMainStage()

	if self.infoStage.data.ChapterType == ChapterFromType.card then
		self.Btn_again:SetActive(false)
		GOUtil.SetRectTransformAnchoredPosition(self.Btn_enter.gameObject, -300, 20)
	elseif self.infoStage.data.ChapterType == ChapterFromType.union then
		self.go_fight_num:SetActive(false)
		self.Btn_again:SetActive(false)
		GOUtil.SetRectTransformAnchoredPosition(self.Btn_enter.gameObject, -300, 20)
	end

	if self.infoStage.data.Type == StageFromType.activeBoss or self.infoStage.data.Type == StageFromType.unionCommon or self.infoStage.data.Type == StageFromType.unionBoss then
		self.Panel:SetActive(false)
		self.GoClickArea:SetActive(false)
		self.GoClickArea2:SetActive(false)

		local function wrap_cb()
			self:GetChildGameObject("Panel/Img_Mask"):SetActive(false)
			self:OnClickedCloseArea()
		end

		if TutorialMgr:IsNeedSwitchMainStage(1) then
			function wrap_cb()
				self:GetChildGameObject("Panel/Img_Mask"):SetActive(false)
				SceneMgr.GetCurrentScene().GP:ExitGame()
				self:Close()
			end
		end

		local data = {}

		data.list = setter.list
		data.listValue = #setter.list
		data.isStage = true

		if SetterData.showLevelup then
			function data.callback()
				local temp = {
					callback = wrap_cb,
					DlgNewBossRaidFunc = self.DlgNewBossRaidFunc
				}

				UIMgr.AddPanel(DlgProducerLevelUp(), temp)
			end
		else
			data.callback = wrap_cb
		end

		UnitVocal.Stop(UnitVocal.enType.Win, GP.Team.CenterUnit)
		UnitVocal.Stop(UnitVocal.enType.Lose, GP.Team.CenterUnit)

		if #setter.list ~= 0 then
			local num = math.random(1, 5)

			if RoleCardMgr:GetRole(self.listRoleCardId[num]).data then
				InfoSoundEventMgr:LoadBank(RoleCardMgr:GetRole(self.listRoleCardId[num]).data.VocalBank)
				InfoSoundEventMgr:Play("VocalCustomsclearance", RoleCardMgr:GetRole(self.listRoleCardId[num]).data.VocalCustomsclearance)
			end

			UIMgr.AddPanel(DlgGetAward(), data)
		else
			data.callback()

			return
		end
	elseif self.infoStage.data.Type == StageFromType.timespace then
		self:UpdateStar()
	else
		self:UpdatePanel()
	end

	self:Show(true)

	if not InstructionMgr.showExitBtn then
		self.Btn_again:SetActive(false)
		self.btn_Replay:SetActive(false)
	end

	self.Btn_sweep:SetActive(canSweep)

	if InstructionMgr.isOpen and not InstructionMgr:IsPassed(12) then
		self.Btn_sweep:SetActive(false)
	end
end

function DlgUIVictory:UpdateStar()
	local haveCon = self.infoStage:HaveStarCon()

	if haveCon then
		local star = self.infoStage.pb.stars
		local starNum = 0

		for i = 1, 3 do
			if star[i] == 1 then
				starNum = starNum + 1
			end
		end

		for i = 1, 3 do
			local goStar = self:GetChildComponent("Panel3/Cond" .. i .. "/Star", "Image")
			local txtCon = self:GetChildComponent("Panel3/Cond" .. i .. "/Text", "Text")

			ChapterMgr:SetStageAch(self.infoStage.data.Grade[i], txtCon)
			UIUtil.SetImageSprite(goStar, star[i] == 1 and "UI/Common/DlgCommon/AtlasDlgCommon/6" or "UI/Common/DlgCommon/AtlasDlgCommon/5", self)
		end
	end
end

function DlgUIVictory:OnEnter(vParam)
	self.GoClickArea = self:GetChildGameObject("ClickArea")
	self.GoClickArea2 = self:GetChildGameObject("ClickArea2")
	self.GoContinue = self:GetChildGameObject("Continue")

	self.GoContinue:SetActive(false)

	self.Panel = self:GetChildGameObject("Panel")
	self.Panel2 = self:GetChildGameObject("Panel2")
	self.Panel3 = self:GetChildGameObject("Panel3")
	self.ExpBar = self:GetChildComponent("Panel/Player/GoBar/ImgBar", "Image")
	self.Level = self:GetChildComponent("Panel/Player/TxtValue", "Text")
	self.TxtAddAnim = self:GetChildComponent("Panel/Player/TxtAddAnim", "Text")
	self.TxtFill = self:GetChildComponent("Panel/Player/TxtFill", "Text")
	self.ExpBar2 = self:GetChildComponent("Panel2/Player/GoBar/ImgBar", "Image")
	self.Level2 = self:GetChildComponent("Panel2/Player/TxtValue", "Text")
	self.TxtAddAnim2 = self:GetChildComponent("Panel2/Player/TxtAddAnim", "Text")
	self.TxtFill2 = self:GetChildComponent("Panel2/Player/TxtFill", "Text")
	self.GoCardGroup = self:GetChildGameObject("Panel/CardGroup")
	self.GoCardGroup2 = self:GetChildGameObject("Panel2/CardGroup")
	self.GoAchGroup = self:GetChildGameObject("Panel/StarAch/AchGroup")
	self.GoAwardGroup = self:GetChildGameObject("Panel/Award/MainAward")
	self.GoSpeAward = self:GetChildGameObject("Panel/Award/ActiveAward")
	self.SpeGroup = self:GetChildGameObject("Panel/Award/ActiveAward/Group")
	self.ImgSpe = self:GetChildComponent("Panel/Award/ActiveAward/GoldSum/Image", "Image")
	self.TxtSpeSum = self:GetChildComponent("Panel/Award/ActiveAward/GoldSum/Text", "Text")
	self.btn_Replay = self:GetChildGameObject("Panel/btn_Replay")
	self.btn_Result = self:GetChildGameObject("Panel/btn_Result")
	self.btn_Replay2 = self:GetChildGameObject("Panel2/btn_Replay")
	self.btn_Result2 = self:GetChildGameObject("Panel2/btn_Result")
	self.go_fight_num = self:GetChildGameObject("Panel/GoAgain/go_fight_num")
	self.textPlayNum = self:GetChildComponent("Panel/GoAgain/go_fight_num/tex_fight_num", "Text")
	self.curPowerNum = self:GetChildComponent("Panel/GoAgain/go_fight_num/go_have/Tex_have", "Text")
	self.textPlayNum2 = self:GetChildComponent("Panel2/GoAgain/go_fight_num/tex_fight_num", "Text")
	self.curPowerNum2 = self:GetChildComponent("Panel2/GoAgain/go_fight_num/go_have/Tex_have", "Text")
	self.Btn_again = self:GetChildGameObject("Panel/GoAgain/Btn_again")
	self.Btn_again2 = self:GetChildGameObject("Panel2/GoAgain/Btn_again")
	self.Btn_enter2 = self:GetChildGameObject("Panel2/GoAgain/Btn_enter")
	self.Btn_enter = self:GetChildGameObject("Panel/GoAgain/Btn_enter")
	self.Btn_sweep = self:GetChildGameObject("Panel/GoAgain/Btn_sweep")
	self.Btn_addfriend = self:GetChildGameObject("Panel/Btn_addfriend")
	self.Btn_addfriend2 = self:GetChildGameObject("Panel2/Btn_addfriend")

	self:Show(false)

	self.Btn_Extra_OK = self:GetChildGameObject("Panel/ExtraAward/Bnt_Ok")
	self.Btn_Extra_OK2 = self:GetChildGameObject("Panel/ExtraAward2/Bnt_Ok")
	self.Btn_Extra2_OK = self:GetChildGameObject("Panel2/ExtraAward/Bnt_Ok")
	self.Btn_Extra2_OK2 = self:GetChildGameObject("Panel2/ExtraAward2/Bnt_Ok")
	self.costNum1 = self:GetChildComponent("Panel/GoAgain/Btn_again/Text", "Text")
	self.DlgNewBossRaidFunc = nil
end

function DlgUIVictory:DealWithLocalization()
	local Text = self:GetChildComponent("Panel/Title/Text", "Text")

	Text.text = _("DlgUIVictory_Pass")
	Text = self:GetChildComponent("Panel/Player/TextLv", "Text")
	Text.text = _("Player_Lv")
	Text = self:GetChildComponent("Panel/StarAch/Title/Text", "Text")
	Text.text = _("DlgUIVictory_Task")
	Text = self:GetChildComponent("Panel/Award/Title/Text", "Text")
	Text.text = _("DlgUIVictory_Award")
	Text = self:GetChildComponent("Continue/Text", "Text")
	Text.text = _("Common_Click_Continue")
	Text = self:GetChildComponent("Panel/Award/ActiveAward/TextSum", "Text")
	Text.text = _("Desc_Sum")
	Text = self:GetChildComponent("Panel/GoAgain/Btn_again/Text2", "Text")
	Text.text = _("eBtn_PlayAgain")
	Text = self:GetChildComponent("Panel/GoAgain/Btn_enter/Text2", "Text")
	Text.text = _("eBtn_NextStep")
end

function DlgUIVictory:DlgUIVictoryChangeHaveLife()
	self.curPowerNum.text = PlayerInst:GetPower() .. ""
end

function DlgUIVictory:UpdatePanel()
	local curExp = PlayerInst.InfoPlayer.curExp
	local nextExp = PlayerInst.InfoPlayer.nextExp

	self.ExpBar.fillAmount = curExp / nextExp
	self.ExpBar2.fillAmount = curExp / nextExp

	if curExp and nextExp then
		self.TxtFill.text = string.format("%d/%d", curExp, nextExp)
		self.TxtFill2.text = string.format("%d/%d", curExp, nextExp)
	else
		self.TxtFill.text = ""
		self.TxtFill2.text = ""
	end

	if self.PlayerExpModify > 0 then
		self.TxtAddAnim.text = string.format("+%d", self.PlayerExpModify)
		self.TxtAddAnim2.text = string.format("+%d", self.PlayerExpModify)
	else
		self.TxtAddAnim.text = ""
		self.TxtAddAnim2.text = ""
	end

	self.Level.text = PlayerInst:GetCurLv()
	self.Level2.text = PlayerInst:GetCurLv()

	self:UpdateCard()
	self:UpdateAch()
	self.GoSpeAward:SetActive(false)
	self:UpdateMainStageAward()

	if self.infoStage.data.ChapterType == 3 then
		-- block empty
	end

	self.GoClickArea:SetActive(false)

	local theOprea = #self.listFirst > 0
	local whipTime = 0

	self:GetChildGameObject("Panel/Img_Mask"):SetActive(false)

	if self.listWhip and #self.listWhip ~= 0 then
		whipTime = 5

		self:GetChildGameObject("Panel/Img_Mask"):SetActive(true)
	else
		if SetterData.showLevelup then
			self:GetChildGameObject("Panel/Img_Mask"):SetActive(true)
		end

		self.Timer2 = TimerMgr.AddTimer(eTimerType.RealTime, 2.5 + whipTime, function()
			if SetterData.showLevelup then
				local function wrap_cb()
					self:GetChildGameObject("Panel/Img_Mask"):SetActive(false)
				end

				local temp = {
					callback = wrap_cb,
					DlgNewBossRaidFunc = self.DlgNewBossRaidFunc
				}

				UIMgr.AddPanel(DlgProducerLevelUp(), temp)
			end
		end, {})
	end

	self.Timer1 = TimerMgr.AddTimer(eTimerType.RealTime, 1.5 + whipTime, function()
		self:ShowAward()
	end, {})

	if false then
		self.Timer0 = TimerMgr.AddTimer(eTimerType.RealTime, 1.5 + whipTime, function()
			self.GoClickArea:SetActive(true)
			self.GoClickArea2:SetActive(false)
		end, {})
	end
end

function DlgUIVictory:UpdateCard()
	self.listCardItem = {}
	self.cellCardLevelUplist = {}
	self.cellCardFavorList = {}
	self.roleCardCid = 0

	if #self.RoleExpSetterTbl == 5 then
		for i, setter in ipairs(self.RoleExpSetterTbl) do
			local id = setter.id
			local item = {}

			if self.infoStage.data.Type ~= 8 then
				item = CellCardUp(self.PrefabCellCardUp, self.GoCardGroup, self)
			else
				item = CellCardUp(self.PrefabCellCardUp, self.GoCardGroup2, self)
			end

			item:Create()

			item.UIRootObject.name = i

			item:SetAddExpText(setter.num)
			item:UpdateData(setter.id, nil, self.listFirst, self.infoStage.data.CharacterFavor, i)
			table.insert(self.listCardItem, item)

			local infoRoleCard = RoleCardMgr:GetRoleCard(id)
			local num = setter.num or 0

			if i == 3 then
				self.roleCardCid = id
			end

			if infoRoleCard.curLevel > infoRoleCard.preLevel and num ~= 0 then
				table.insert(self.cellCardLevelUplist, RoleCardMgr:GetRole(id))
			end

			local giftItemValue = {}

			giftItemValue.id = 99999
			giftItemValue.count = 1
			giftItemValue.expOne = tonumber(self.infoStage.data.CharacterFavor)

			local addLevelList = LevelManager:GetPreviewProgress(RoleCardMgr:GetRole(setter.id), {
				giftItemValue
			}, RoleCardMgr:GetRole(setter.id).preFavorLevel)

			if addLevelList and addLevelList[3] > 0 then
				table.insert(self.cellCardFavorList, RoleCardMgr:GetRole(id))
			end
		end
	end

	if #self.RoleExpSetterTbl ~= 5 and self.infoStage.data.ChapterType ~= ChapterFromType.union then
		self.listCardItem = {}

		for i = 1, 5 do
			if self.infoStage.data.Type ~= 8 then
				item = CellCardUp(self.PrefabCellCardUp, self.GoCardGroup, self)

				self.Btn_addfriend:SetActive(true)
			else
				item = CellCardUp(self.PrefabCellCardUp, self.GoCardGroup2, self)

				self.Btn_addfriend2:SetActive(false)
			end

			self.Btn_addfriend:SetActive(false)

			local InfoTeam = require("Info.InfoTeam")

			if self.infoStage.data.ChapterType == ChapterFromType.union then
				if self.infoStage.data.Type == StageFromType.unionBoss then
					InfoTeam = require("Info.InfoTeamBossRaid")
				else
					InfoTeam = require("Info.InfoTeamRaid")
				end
			elseif self.infoStage.data.ChapterType == ChapterFromType.comb then
				InfoTeam = require("Info/InfoTeamgGroup")
			elseif self.infoStage.data.ChapterType == ChapterFromType.timespace then
				InfoTeam = require("Info/InfoTeamTimespace")
			else
				InfoTeam = require("Info/InfoTeam")
			end

			local teamAgent = InfoTeam.teamSystemAgent.teamList[InfoTeam.teamSystemAgent.teamIndex]
			local slot = teamAgent.slotList

			if slot[i].upInfoRoleCard then
				if i == 5 and slot[i].upInfoRoleCard.pbPlayer then
					self.pbPlayer = slot[i].upInfoRoleCard.pbPlayer

					item:Create()

					item.UIRootObject.name = i

					item:UpdateData(self.listRoleCardId[i], self.pbPlayer, self.listFirst, self.infoStage.data.CharacterFavor, i)
					item:SetAddExpText(0)
					table.insert(self.listCardItem, item)
					self.Btn_addfriend:SetActive(not FriendMgr:IsGameFriend(self.pbPlayer.leader.playerId))
				else
					item:Create()

					item.UIRootObject.name = i

					item:UpdateData(self.listRoleCardId[i], nil, self.listFirst, self.infoStage.data.CharacterFavor, i)
					item:SetAddExpText(0)
					table.insert(self.listCardItem, item)

					if i == 3 then
						self.roleCardCid = self.listRoleCardId[i]
					end
				end
			end
		end
	end

	UnitVocal.Stop(UnitVocal.enType.Win, GP.Team.CenterUnit)
	UnitVocal.Stop(UnitVocal.enType.Lose, GP.Team.CenterUnit)

	local randomNum = 0

	if #self.cellCardLevelUplist ~= 0 then
		randomNum = math.random(1, #self.cellCardLevelUplist)
	end

	for i = 1, #self.cellCardLevelUplist do
		if i == randomNum and self.cellCardLevelUplist[i] and self.cellCardLevelUplist[i].data then
			InfoSoundEventMgr:LoadBank(self.cellCardLevelUplist[i].data.VocalBank)
			InfoSoundEventMgr:Play("VocalCharaUp", self.cellCardLevelUplist[i].data.VocalCharaUp)
			SoundMgr.PostEvent("Play_SE_020_0014", self.UIRootObject)
		end
	end

	if table.getItemCount(self.cellCardFavorList) ~= 0 then
		SoundMgr.PostEvent("Play_SE_020_0020", self.UIRootObject)
	end

	if #self.cellCardLevelUplist == 0 and self.infoStage.data.Type ~= 4 and self.infoStage.data.Type ~= 7 and self.infoStage.data.Type ~= 6 then
		if self.roleCardCid == 0 then
			self.roleCardCid = self.listRoleCardId[3]
		end

		local num = math.random(1, 5)

		if RoleCardMgr:GetRole(self.listRoleCardId[num]) then
			InfoSoundEventMgr:LoadBank(RoleCardMgr:GetRole(self.listRoleCardId[num]).data.VocalBank)
			InfoSoundEventMgr:Play("VocalCustomsclearance", RoleCardMgr:GetRole(self.listRoleCardId[num]).data.VocalCustomsclearance)
		end
	end
end

function DlgUIVictory:UpdateCardRightNow()
	for i = 1, #self.listCardItem do
		local item = self.listCardItem[i]

		item:UpdateExpBarNow()
	end
end

function DlgUIVictory:UpdateAch()
	local grade = self.infoStage.data.Grade

	self.listStarItem = {}
	self.listStarAch = {}

	for i = 1, #grade do
		local item = CellBattleAch(self.PrefabCellBattleAch, self.GoAchGroup, self)

		item:Create()

		local curGrade = grade[i]
		local txt = item.TxtDesc

		ChapterMgr:SetStageAch(curGrade, txt)

		local infoItem = ItemManager:GetValueItem(self.infoStage:GetStarAward(i)[1][1])
		local path = infoItem:GetIcon()

		UIUtil.SetImageSprite(item.ImgIcon, path)

		item.TxtAward.text = self.infoStage:GetStarAward(i)[1][2]

		local index = 0

		if self.stars[i] == 1 then
			index = self.infoStage.preStars[i] == 1 and 2 or 1
		end

		item:UpdateData(index)
		table.insert(self.listStarItem, item)

		if index == 1 then
			table.insert(self.listStarAch, i)
		end
	end

	local dateTime = 0.3

	for i = 1, #self.listStarAch do
		local item = self.listStarItem[self.listStarAch[i]]

		self.Timer3 = TimerMgr.AddTimer(eTimerType.RealTime, dateTime * (i - 1), function()
			item:PlayAnim()
		end, {})
	end
end

function DlgUIVictory:UpdateAchRightNow()
	for i = 1, #self.listStarAch do
		local item = self.listStarItem[self.listStarAch[i]]

		item:DestroyEffect()
	end
end

function DlgUIVictory:UpdateMainStageAward()
	local Content = {}

	if self.infoStage.data.Type ~= 8 then
		Content = self:GetChildGameObject("Panel/Award/MainAward/Content")
	else
		Content = self:GetChildGameObject("Panel2/Award/MainAward/Content")
	end

	local cw = 1112
	local ch = 138
	local sum = 0

	self.listItem = {}
	self.extraListItem = {}
	self.extraEffectListItem = {}

	if self.listWhip and #self.listWhip ~= 0 then
		local cnt = #self.listWhip
		local ExtraContent = {}
		local ExtraAwardGo = {}
		local ExtraEffectContent = {}
		local path = ""

		if cnt > 6 then
			path = "2"
		end

		if self.infoStage.data.Type ~= 8 then
			ExtraAwardGo = self:GetChildGameObject("Panel/ExtraAward" .. path)
			ExtraEffectGo = self:GetChildGameObject("Panel/GoExtraAwardEffects")
			ExtraContent = self:GetChildGameObject("Panel/ExtraAward" .. path .. "/MainAward/Content")
			ExtraEffectContent = self:GetChildGameObject("Panel/GoExtraAwardEffects/Content")
		else
			ExtraAwardGo = self:GetChildGameObject("Panel2/ExtraAward" .. path)
			ExtraEffectGo = self:GetChildGameObject("Panel2/GoExtraAwardEffects")
			ExtraContent = self:GetChildGameObject("Panel2/ExtraAward" .. path .. "/MainAward/Content")
			ExtraEffectContent = self:GetChildGameObject("Panel2/GoExtraAwardEffects/Content")
		end

		self.Timer4 = TimerMgr.AddTimer(eTimerType.RealTime, 2, function()
			ExtraAwardGo:SetActive(false)
			ExtraEffectGo:SetActive(true)
			BattleConfig.PlaySound(PATH_SFX_UI_CHAPTER_UNLOCK)
			self:GetChildGameObject("Panel/Img_Mask"):SetActive(false)

			local goldEffectValue = 0
			local silverEffectValue = 0
			local copperEffectValue = 0

			for i = 1, #self.data.dropReward do
				if self.data.dropReward[i] == 1000011 or self.data.dropReward[i] == 1000001 then
					copperEffectValue = copperEffectValue + 1
				elseif self.data.dropReward[i] == 1000012 or self.data.dropReward[i] == 1000002 then
					silverEffectValue = silverEffectValue + 1
				elseif self.data.dropReward[i] == 1000013 or self.data.dropReward[i] == 1000003 then
					goldEffectValue = goldEffectValue + 1
				end
			end

			if goldEffectValue >= 1 then
				local item = CellExtraAward(self.CellExtraAward, ExtraEffectContent, self)

				item:Create()
				item:UpdateData(goldEffectValue, 3)
				table.insert(self.extraEffectListItem, item)
			end

			if silverEffectValue >= 1 then
				local item = CellExtraAward(self.CellExtraAward, ExtraEffectContent, self)

				item:Create()
				item:UpdateData(silverEffectValue, 2)
				table.insert(self.extraEffectListItem, item)
			end

			if copperEffectValue >= 1 then
				local item = CellExtraAward(self.CellExtraAward, ExtraEffectContent, self)

				item:Create()
				item:UpdateData(copperEffectValue, 1)
				table.insert(self.extraEffectListItem, item)
			end
		end, {})
		self.Timer5 = TimerMgr.AddTimer(eTimerType.RealTime, 3.5, function()
			ExtraEffectGo:SetActive(false)
			self:GetChildGameObject("Panel/Img_Mask"):SetActive(false)

			local data = {}

			data.list = self.listWhip
			data.listValue = #self.listWhip

			local function wrap_cb()
				self:GetChildGameObject("Panel/Img_Mask"):SetActive(false)

				if tonumber(self.dropRaidBossId) > 0 then
					local data = {}

					function data.callback()
						if ActivityBossRaidMgr.bossRaidTimeData == nil then
							local activityList = ActiveMgr:GetActiveByType(eActiveType.bossraid)

							for i, v in ipairs(activityList) do
								if v:IsShowOpen() then
									ActivityBossRaidMgr.bossRaidTimeData = v

									break
								end
							end
						end

						if ActivityBossRaidMgr.bossRaidTimeData and ActivityBossRaidMgr.bossRaidTimeData:IsShowOpen() then
							self:Purge()
							GP:ExitGameScript()
							SceneMgr.LoadScene("MainStage", {
								from = 14,
								func = function()
									ActivityBossRaidMgr.selectTab = nil

									require("UI/Page/PageActivityBossRaid/PageActivityBossRaid")
									UIMgr.SwitchPanel(PageActivityBossRaid(), nil, false, true)
								end
							})
						else
							UIMgr.ShowMsg(_("Msg_Active_Over"))
						end
					end

					data.dropRaidBossStageId = self.dropRaidBossStageId
					data.dropRaidBossId = self.dropRaidBossId

					require("UI/Page/PageActivityBossRaid/DlgNewBossRaid")
					UIMgr.AddPanel(DlgNewBossRaid(), data, self.Parent)
				end
			end

			if SetterData.showLevelup then
				function data.callback()
					local temp = {
						callback = wrap_cb
					}

					UIMgr.AddPanel(DlgProducerLevelUp(), temp)
				end
			else
				data.callback = wrap_cb
			end

			UIMgr.AddPanel(DlgGetAward(), data)
		end, {})
	elseif tonumber(self.dropRaidBossId) > 0 and not SetterData.showLevelup then
		require("UI/Page/PageActivityBossRaid/DlgNewBossRaid")

		local data = {}

		function data.callback()
			if ActivityBossRaidMgr.bossRaidTimeData == nil then
				local activityList = ActiveMgr:GetActiveByType(eActiveType.bossraid)

				for i, v in ipairs(activityList) do
					if v:IsShowOpen() then
						ActivityBossRaidMgr.bossRaidTimeData = v

						break
					end
				end
			end

			if ActivityBossRaidMgr.bossRaidTimeData and ActivityBossRaidMgr.bossRaidTimeData:IsShowOpen() then
				self:Purge()
				GP:ExitGameScript()
				SceneMgr.LoadScene("MainStage", {
					from = 14,
					func = function()
						ActivityBossRaidMgr.selectTab = nil

						require("UI/Page/PageActivityBossRaid/PageActivityBossRaid")
						UIMgr.SwitchPanel(PageActivityBossRaid(), nil, false, true)
					end
				})
			else
				UIMgr.ShowMsg(_("Msg_Active_Over"))
			end
		end

		data.dropRaidBossStageId = self.dropRaidBossStageId
		data.dropRaidBossId = self.dropRaidBossId

		UIMgr.AddPanel(DlgNewBossRaid(), data, self.Parent)
	elseif tonumber(self.dropRaidBossId) > 0 and SetterData.showLevelup then
		function self.DlgNewBossRaidFunc(...)
			require("UI/Page/PageActivityBossRaid/DlgNewBossRaid")

			local data = {}

			function data.callback()
				if ActivityBossRaidMgr.bossRaidTimeData == nil then
					local activityList = ActiveMgr:GetActiveByType(eActiveType.bossraid)

					for i, v in ipairs(activityList) do
						if v:IsShowOpen() then
							ActivityBossRaidMgr.bossRaidTimeData = v

							break
						end
					end
				end

				if ActivityBossRaidMgr.bossRaidTimeData and ActivityBossRaidMgr.bossRaidTimeData:IsShowOpen() then
					self:Purge()
					GP:ExitGameScript()
					SceneMgr.LoadScene("MainStage", {
						from = 14,
						func = function()
							ActivityBossRaidMgr.selectTab = nil

							require("UI/Page/PageActivityBossRaid/PageActivityBossRaid")
							UIMgr.SwitchPanel(PageActivityBossRaid(), nil, false, true)
						end
					})
				else
					UIMgr.ShowMsg(_("Msg_Active_Over"))
				end
			end

			data.dropRaidBossStageId = self.dropRaidBossStageId
			data.dropRaidBossId = self.dropRaidBossId

			UIMgr.AddPanel(DlgNewBossRaid(), data, self.Parent)
		end
	end

	if self.listNormal then
		local cnt = #self.listNormal

		for i = 1, cnt do
			local s = self.listNormal[i]
			local infoItem = SetterData.GetItemFromAsset(s)

			if infoItem and infoItem.data.Type ~= "R_FAVOR_EXP" then
				sum = sum + 1

				local item = CellItem(self.PrefabCellItem, Content, self)

				item:Create()
				item:UpdateData(i, infoItem)
				GOUtil.SetTransformLocalScale(item.UIRootObject, 0.9)
				table.insert(self.listItem, item)
			end
		end
	end

	for i = 1, 3 do
		if self["listStar" .. i] then
			local cnt = #self["listStar" .. i]
			local levelList = {}

			for j = 1, cnt do
				local s = self["listStar" .. i][j]
				local infoItem = SetterData.GetItemFromAsset(s)

				if infoItem then
					sum = sum + 1

					local item = CellItem(self.PrefabCellItem, Content, self)

					item:Create()
					item:SetStar(i)
					item:UpdateData(j, infoItem)
					GOUtil.SetTransformLocalScale(item.UIRootObject, 0.9)
					table.insert(self.listItem, item)
				end
			end
		end
	end

	if self.listFirst then
		local cnt = #self.listFirst

		for i = 1, cnt do
			local s = self.listFirst[i]
			local infoItem = SetterData.GetItemFromAsset(s)

			if infoItem then
				sum = sum + 1

				local item = CellItem(self.PrefabCellItem, Content, self)

				item:Create()
				item:UpdateData(i, infoItem)

				if self.infoStage.data.Type == 8 then
					item:SetStageAward(true)
				else
					item:SetFirstPass(true)
				end

				GOUtil.SetTransformLocalScale(item.UIRootObject, 0.9)
				table.insert(self.listItem, item)
			end
		end
	end

	if self.listHigh then
		local cnt = #self.listHigh

		for i = 1, cnt do
			local s = self.listHigh[i]
			local infoItem = SetterData.GetItemFromAsset(s)

			if infoItem then
				sum = sum + 1

				local item = CellItem(self.PrefabCellItem, Content, self)

				item:Create()
				item:UpdateData(i, infoItem)
				item:SetHigh(true)
				GOUtil.SetTransformLocalScale(item.UIRootObject, 0.9)
				table.insert(self.listItem, item)
			end
		end
	end

	if self.listWhip then
		local cnt = #self.listWhip

		for i = 1, cnt do
			local s = self.listWhip[i]
			local infoItem = SetterData.GetItemFromAsset(s)

			if infoItem then
				sum = sum + 1

				local item = CellItem(self.PrefabCellItem, Content, self)

				item:Create()
				item:UpdateData(i, infoItem)
				item:SetWhip(true)

				item.name = "whip"

				GOUtil.SetTransformLocalScale(item.UIRootObject, 0.9)
				table.insert(self.listItem, item)
			end
		end
	end

	if self.listActiveAward then
		local cnt = #self.listActiveAward

		for i = 1, cnt do
			local s = self.listActiveAward[i]
			local infoItem = SetterData.GetItemFromAsset(s)

			if infoItem then
				sum = sum + 1

				local item = CellItem(self.PrefabCellItem, Content, self)

				item:Create()
				item:UpdateData(i, infoItem)
				item:SetActiveAward(true)

				item.name = "active"

				GOUtil.SetTransformLocalScale(item.UIRootObject, 0.9)
				table.insert(self.listItem, item)
			end
		end
	end

	if self.listEnemyId and self.infoStage.data.ActType == 1 and #self.listEnemyId > 0 then
		local goldList = self:GetActiveGoldEnemyList()

		if self.listEnemy then
			local s = self.listEnemy[1]

			if s == nil then
				return
			end

			local infoItem = SetterData.GetItemFromAsset(s)

			if infoItem then
				for i = 1, #goldList do
					sum = sum + 1
					infoItem.num = goldList[i].goldNum
					infoItem.pb.num = goldList[i].goldNum

					local item = CellItem(self.PrefabCellItem, Content, self)

					item:Create()
					item:UpdateData(i, infoItem)
					item:SetGoldEnemy(goldList[i].enemyId, goldList[i].enemyNum, goldList[i].IC_tip)
					GOUtil.SetTransformLocalScale(item.UIRootObject, 0.9)
					table.insert(self.listItem, item)
				end
			end
		end
	end
end

function DlgUIVictory:UpdateActiveStageAward()
	local listEnemy = {}

	for i = 1, #self.listEnemyId do
		local enemyId = self.listEnemyId[i]
		local infoEnemy = EnemyManager:Get(enemyId)

		if infoEnemy.data.PlayType == 1 then
			if #listEnemy == 0 then
				local temp = {}

				temp.enemyId = enemyId
				temp.num = 1

				table.insert(listEnemy, temp)
			else
				local idx

				for j = 1, #listEnemy do
					if enemyId == listEnemy[j].enemyId then
						idx = j

						break
					end
				end

				if idx ~= nil then
					listEnemy[idx].num = listEnemy[idx].num + 1
				else
					local temp = {}

					temp.enemyId = enemyId
					temp.num = 1

					table.insert(listEnemy, temp)
				end
			end
		end
	end

	local enemyTypeCnt = #listEnemy
	local sum = 0
	local Cell = self:GetChildGameObject("Panel/Award/ActiveAward/Cell")

	for i = 1, enemyTypeCnt do
		local infoEnemy = EnemyManager:Get(listEnemy[i].enemyId)
		local base = 0
		local itemList = infoEnemy.data.DropItemList

		if #itemList ~= 0 and #itemList[1] > 1 then
			base = infoEnemy.data.DropItemList[1][2]
		end
	end
end

function DlgUIVictory:GetActiveGoldEnemyList()
	local listEnemy = {}

	for i = 1, #self.listEnemyId do
		local enemyId = self.listEnemyId[i]
		local infoEnemy = EnemyManager:Get(enemyId)

		if infoEnemy.data.PlayType == 1 then
			if #listEnemy == 0 then
				local temp = {}

				temp.enemyId = enemyId
				temp.num = 1

				table.insert(listEnemy, temp)
			else
				local idx

				for j = 1, #listEnemy do
					if enemyId == listEnemy[j].enemyId then
						idx = j

						break
					end
				end

				if idx ~= nil then
					listEnemy[idx].num = listEnemy[idx].num + 1
				else
					local temp = {}

					temp.enemyId = enemyId
					temp.num = 1

					table.insert(listEnemy, temp)
				end
			end
		end
	end

	local enemyTypeCnt = #listEnemy
	local goldList = {}

	for i = 1, enemyTypeCnt do
		local infoEnemy = EnemyManager:Get(listEnemy[i].enemyId)
		local base = 0
		local itemList = infoEnemy.data.DropItemList

		goldList[i] = {}
		goldList[i].enemyId = listEnemy[i].enemyId
		goldList[i].goldNum = listEnemy[i].num * infoEnemy.data.DropItemList[1][2]
		goldList[i].IC_tip = infoEnemy.data.ItemTipIcon
		goldList[i].enemyNum = listEnemy[i].num
	end

	return goldList
end

function DlgUIVictory:ShowAward()
	local wrap_cb

	if TutorialMgr:IsNeedSwitchMainStage(1) then
		function wrap_cb()
			self:GetChildGameObject("Panel/Img_Mask"):SetActive(false)
			self:Close()
			SceneMgr.GetCurrentScene().GP:ExitGame(1)
		end
	else
		function wrap_cb()
			self:GetChildGameObject("Panel/Img_Mask"):SetActive(false)
		end
	end

	local list = self.listFirst

	if #list > 0 then
		local strTitle = _("Award_FirstPass")
		local data = {
			list = list,
			title = strTitle
		}

		if SetterData.showLevelup then
			function data.callback()
				local temp = {
					callback = wrap_cb,
					DlgNewBossRaidFunc = self.DlgNewBossRaidFunc
				}

				UIMgr.AddPanel(DlgProducerLevelUp(), temp)
			end
		end
	elseif SetterData.showLevelup then
		local temp = {
			callback = wrap_cb,
			DlgNewBossRaidFunc = self.DlgNewBossRaidFunc
		}

		UIMgr.AddPanel(DlgProducerLevelUp(), temp)
	end

	self.GoClickArea:SetActive(true)
	self.GoClickArea2:SetActive(false)
	self.GoClickArea:SetActive(true)
	self.GoClickArea2:SetActive(false)
end

function DlgUIVictory:OnClickedCloseArea()
	if self.infoStage.data.ChapterType == ChapterFromType.card or self.infoStage.data.ChapterType == ChapterFromType.activity or self.infoStage.data.ChapterType == ChapterFromType.union then
		self:Close()
		SceneMgr.GetCurrentScene().GP:ExitGame()
	elseif self.leftNum == 0 then
		self:Close()
		SceneMgr.GetCurrentScene().GP:ExitGame()
	end
end

function DlgUIVictory:OnClickedCloseAnim()
	self:ClearTime()

	if self.infoStage.data.Type ~= StageFromType.timespace then
		self:UpdateCardRightNow()
		self:UpdateAchRightNow()
		self:ShowAward()
	else
		self:Close()
		SceneMgr.GetCurrentScene().GP:ExitGame()
	end
end

function DlgUIVictory:OnClickedReplay()
	GP:ReplayGame()
end

function DlgUIVictory:OnClickedResultAddUp()
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIResultAddUp")
end

function DlgUIVictory:OnClickedBtnAgain()
	ChapterMgr.IsChallengeAgain = true

	self:ClearTime()
	self:UpdateCardRightNow()
	self:UpdateAchRightNow()

	local function battle()
		local InfoTeam = require("Info/InfoTeam")

		if self.infoStage.data.ChapterType == ChapterFromType.comb then
			InfoTeam = require("Info/InfoTeamgGroup")
		end

		local teamAgent = InfoTeam.teamSystemAgent.teamList[InfoTeam.teamSystemAgent.teamIndex]

		if InfoTeam.teamSystemAgent.battleCall then
			InfoTeam.teamSystemAgent.battleCall()
		end
	end

	local costData = self.infoStage:GetCostItem()

	if next(costData) ~= nil then
		local item, cost = costData[1], costData[2]

		if ItemManager:GetType(item.id) == eItemType.P_POWER then
			local function tipCb(index)
				if index == DlgCommonEvent.ButtonType.Ok then
					if cost > PlayerInst:GetPower() then
						require("UI/Dlg/Common/DlgPowerBuy")

						local function cb()
							if cost <= PlayerInst:GetPower() then
								battle()
							end
						end

						UIMgr.AddPanel(DlgPowerBuy(), {
							cb = cb
						})
					else
						battle()
					end
				end
			end

			local str = string.format(_("Desc_UseLastTimeTeam"), cost or 0)

			UIMgr.ShowCommon(DlgCommonEvent.Type.TipsAndItem, _("Desc_Alert"), str, tipCb, nil, nil, nil, true)
		elseif ItemManager:IsItemHoldEnough(item.id, cost) then
			battle()
		end
	else
		battle()
	end
end

function DlgUIVictory:OnClickedBtnEnter()
	if self.infoStage.data.ChapterType == ChapterFromType.main or self.infoStage.data.ChapterType == ChapterFromType.mainhard or self.infoStage.data.ChapterType == ChapterFromType.comb or self.infoStage.data.ChapterType == ChapterFromType.activity or self.infoStage.data.ChapterType == ChapterFromType.card or self.infoStage.data.ChapterType == ChapterFromType.tower or self.infoStage.data.ChapterType == ChapterFromType.bosslive then
		local chapterId = self.infoStage.data.ChapterID
		local infoChapter = ChapterMgr:GetChapter(chapterId)
		local lastStageId = infoChapter:GetLastStageId()
		local stageup = 1

		if lastStageId == self.infoStage.data.ID then
			stageup = 0
		end

		self:Purge()
		GP:ExitGameScript()
		SceneMgr.LoadScene("MainStage", {
			from = 4,
			stageId = self.infoStage.data.ID,
			stageup = stageup,
			leftnum = self.leftNum
		})
	else
		self:Close()
		SceneMgr.GetCurrentScene().GP:ExitGame()
	end
end

function DlgUIVictory:OnClickedBtnSweep()
	if InstructionMgr.isOpen and not InstructionMgr:IsPassed(10) then
		UIMgr.ShowMsg(_("PageTalentTree_Locked"))

		return
	end

	if self.infoStage.data.ChapterType == ChapterFromType.main or ChapterFromType.mainhard or self.infoStage.data.ChapterType == ChapterFromType.comb or self.infoStage.data.ChapterType == ChapterFromType.activity or self.infoStage.data.ChapterType == ChapterFromType.bosslive then
		self:Purge()
		GP:ExitGameScript()
		SceneMgr.LoadScene("MainStage", {
			sweep = true,
			from = 4,
			stageAgain = false,
			stageup = 0,
			stageId = self.infoStage.data.ID,
			leftnum = self.leftNum
		})
	else
		self:Close()
		SceneMgr.GetCurrentScene().GP:ExitGame()
	end
end

function DlgUIVictory:OnClickedBtnAddfriend()
	local data = {}

	print(self.pbPlayer.leader.playerId)

	data.listId = {
		self.pbPlayer.playerId
	}

	require("UI/Page/PageFriend/PageFriendMain")
	PageFriendMain:OperateAddFriend(data)
	self.Btn_addfriend:SetActive(false)
end

function DlgUIVictory:OnClickedExtraClose()
	self:GetChildGameObject("Panel/ExtraAward"):SetActive(false)
	self:GetChildGameObject("Panel/ExtraAward2"):SetActive(false)
end
