-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageFight/Dlg/DlgUIResult.lua

DlgUIResult = class("DlgUIResult", UIPanel_sync)

local systemType = {
	TutorialFunctionType.Card,
	TutorialFunctionType.Equipment,
	TutorialFunctionType.Talent,
	TutorialFunctionType.DrawCard
}

function DlgUIResult:ctor()
	DlgUIResult.base.ctor(self, "UI/PageFight/Dlg/DlgUIResult")
end

function DlgUIResult:Cache()
	DlgUIResult.base.Cache(self)
	ResourceMgr.SubmitCache("UI/Common/CellCard/CellCardUp", self, "PrefabCellCardUp")
end

function DlgUIResult:Close()
	self.PrefabCellCardUp = nil

	DlgUIResult.base.Close(self)
end

function DlgUIResult:Purge()
	DlgUIResult.base.Purge(self)
end

function DlgUIResult:OnRegisterEvent()
	self:AddClick(self.obj_clickArea.gameObject, self.OnClickArea, "Play_SE_020_0029")
	self:AddClick(self.obj_giveUpBtn, self.OnBtnGiveUp)
	self:AddClick(self.obj_goOnBtn, self.OnBtnGoOn)

	for i = 1, 4 do
		self:AddClick(self.btn_failed_group[i], self.OnClickFailGroup)
	end

	self:AddClick(self.btn_Replay, self.OnClickedReplay)
	self:AddClick(self.btn_Result, self.OnClickedResultAddUp)
	self:AddClick(self.btn_Forecast, self.OnClickedForecast)
end

function DlgUIResult:OnUnRegisterEvent()
	self:RemoveClick(self.obj_clickArea.gameObject, self.OnClickArea)
	self:RemoveClick(self.obj_giveUpBtn, self.OnBtnGiveUp)
	self:RemoveClick(self.obj_goOnBtn, self.OnBtnGoOn)

	for i = 1, 4 do
		self:RemoveClick(self.btn_failed_group[i], self.OnClickFailGroup)
	end

	self:RemoveClick(self.btn_Replay, self.OnClickedReplay)
	self:RemoveClick(self.btn_Result, self.OnClickedResultAddUp)
	self:RemoveClick(self.btn_Forecast, self.OnClickedForecast)
end

function DlgUIResult:OnEnter(vParam)
	local textLabel = self:GetChildComponent("obj_clickArea/label", "Text")

	textLabel.text = _("Common_Click_Continue")
	self.animPanel_Failed = self:GetChildGameObject("animPanel_Failed")
	self.btn_failed_group = {}

	for i = 1, 4 do
		self.btn_failed_group[i] = self:GetChildGameObject("animPanel_Failed/panel/Group/" .. i)

		if systemType[i] ~= 0 then
			isOpen = TutorialMgr:IsOpenNoMsg(systemType[i])
		end

		local gray = TenaryOp(isOpen, 0, 1)

		UIUtil.SetImageGray(self:GetChildComponent("animPanel_Failed/panel/Group/" .. i .. "/Image", "Image"), gray)
	end

	self.btn_Replay = self:GetChildGameObject("animPanel_Failed/panel/btn_Replay")
	self.btn_Result = self:GetChildGameObject("animPanel_Failed/panel/btn_Result")
	self.btn_Forecast = self:GetChildGameObject("animPanel_Failed/panel/btn_Forecast")
	self.failed_panel_go = self:GetChildGameObject("animPanel_Failed/panel")
	self.animPanel_Victory = self:GetChildGameObject("animPanel_Victory")
	self.txt_bottomTip = self:GetChildComponent("obj_clickArea/label", "Text")
	self.img_word_failed = self:GetChildComponent("animPanel_Failed/img_word_cn", "Image")
	self.img_word_victory = self:GetChildComponent("animPanel_Victory/img_word_cn", "Image")
	self.img_word_bosslieve = self:GetChildGameObject("animPanel_Failed/img_word_bosslieve")
	self.img_word_bosslieve2 = self:GetChildGameObject("animPanel_Victory/img_word_bosslieve2")

	UIUtil.SetImageSprite(self.img_word_victory, "UI/PageFight/AtlasResult/ui_hd_word_en_clear")
	UIUtil.SetImageSprite(self.img_word_failed, "UI/PageFight/AtlasResult/ui_hd_word_en_failed")

	self.img_itemIcon = self:GetChildComponent("promptPanel/bg_item/img_itemIcon", "Image")
	self.txt_costValue = self:GetChildComponent("promptPanel/btn_goOn/txt_costValue", "Text")
	self.txt_holdValue = self:GetChildComponent("promptPanel/bg_item/txt_haveValue", "Text")
	self.obj_promptPanel = self:GetChildGameObject("promptPanel")
	self.obj_giveUpBtn = self:GetChildGameObject("promptPanel/btn_quit")
	self.obj_goOnBtn = self:GetChildGameObject("promptPanel/btn_goOn")
	self.obj_victoryPanel = self:GetChildGameObject("victoryPanel")
	self.obj_clickArea = self:GetChildGameObject("obj_clickArea")
	self.obj_battleEnd = self:GetChildGameObject("BattleEnd")

	local tipStr = _("eFight_ClickToContinue")

	if GP.GameStartData.playMode == EnumFight.PlayMode.Replay then
		tipStr = _("eFight_ClickToContinueForReplay")
	end

	local AutoText = self:GetChildComponent("animPanel_Failed/panel/btn_Forecast/Text", "Text")

	AutoText.text = _("Desc_FightEvaluate")
	self.txt_bottomTip.text = tipStr

	self:Show(false)
end

function DlgUIResult:Open(msg)
	GOUtil.SetActive(self.failed_panel_go, true)

	self.data = nil

	self:Show(true)

	self.bVictory = msg.isWin
	self.msg = msg

	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator", false)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", false)

	if self.bVictory and self.bVictory == true then
		SoundMgr.Play("Play_SE_020_0024")
	else
		SoundMgr.Play("Play_SE_020_0025")
	end

	local infoStage = InfoStage(self.msg.stageId)

	if infoStage.data.Type == StageFromType.unionBoss or infoStage.data.ChapterType == ChapterFromType.bossRaid or infoStage.data.ActType == 20 then
		self.obj_battleEnd:SetActive(true)
		self.animPanel_Failed:SetActive(false)
		self.animPanel_Victory:SetActive(false)
	else
		self.animPanel_Failed:SetActive(not self.bVictory)

		if not self.bVictory then
			-- block empty
		end

		self.animPanel_Victory:SetActive(self.bVictory)
	end

	self.boutId = msg.boutId

	if GP.GameStartData.playMode == EnumFight.PlayMode.Replay then
		self.obj_clickArea:SetActive(true)

		return
	end

	if self.boutId == -1 then
		self.obj_clickArea:SetActive(true)

		local infoStage = InfoStage(self.msg.stageId)

		if infoStage.data.ChapterType == ChapterFromType.bosslive and BossliveChapterMgr.GetBossliveRemainingChallengeNum() == 0 then
			self.img_word_failed.gameObject:SetActive(false)
			self.img_word_victory.gameObject:SetActive(false)
			self.img_word_bosslieve:SetActive(true)
			self.img_word_bosslieve2:SetActive(true)
		end

		return
	end

	self:RequestEndBattle(self.boutId, msg.chaos)
end

function DlgUIResult:OnClickFailGroup(data)
	local go = data.pointerPress
	local index = tonumber(go.name)
	local index = tonumber(data.pointerPress.name)
	local isOpen = true

	if systemType[index] ~= 0 then
		isOpen = TutorialMgr:IsOpenTut(systemType[index])
	end

	if not isOpen then
		return
	end

	if index == 1 then
		self:Purge()
		GP:ExitGameScript()
		SceneMgr.LoadScene("MainStage", {
			from = 11,
			cardId = self.msg.playerCardIds[3]
		})
	elseif index == 2 then
		self:Purge()
		GP:ExitGameScript()
		SceneMgr.LoadScene("MainStage", {
			from = 12,
			cardId = self.msg.playerCardIds[3],
			stageId = self.msg.stageId
		})
	elseif index == 3 then
		self:Purge()
		GP:ExitGameScript()
		SceneMgr.LoadScene("MainStage", {
			from = 13,
			cardId = self.msg.playerCardIds[3],
			stageId = self.msg.stageId
		})
	elseif index == 4 then
		self:Purge()
		GP:ExitGameScript()

		local function DlgWorldMapEvent()
			require("UI/Page/PageCardShop/PageCardShop")
			PageCardShop.InitNetData(true)
		end

		SceneMgr.LoadScene("MainStage", {
			from = 14,
			func = DlgWorldMapEvent
		})
	end
end

function DlgUIResult:RequestEndBattle(boutId, chaos)
	self.obj_clickArea:SetActive(false)

	local serverArg1 = TenaryOp(self.msg.isWin == true, 1, 0)
	local serverArg2 = self.msg.round
	local serverArg3 = Mathf.Ceil(self.msg.remainHp)
	local serverArg4 = self.msg.playerDeadCount
	local serverArg5 = self.msg.selfDestructCount
	local battlelogs = self.msg.battlelogs
	local killMonsterList = self.msg.killMonsterList
	local dropReward = self.msg.dropReward
	local oltime = self.msg.oltime
	local monsterHpRates = {}
	local blood = 0
	local cardHpRates = {}
	local infoStage = InfoStage(self.msg.stageId)

	if infoStage.data.ChapterType == ChapterFromType.union then
		if infoStage.data.Type == StageFromType.unionBoss then
			local raid = UnionRaidMgr:GetBossRaidByStageId(infoStage.id)

			UnionRaidMgr.ChangePlayNum(eRaidType.Boss, raid.id)
		else
			UnionRaidMgr.beingCommRaid:ChangeBattleTimes()
		end

		if not UnionRaidMgr.NotChangeCardHp then
			local cardIds = self.msg.playerCardIds
			local tab = self.msg.playerHpRates or {}

			for i = 1, #cardIds do
				local infoCard = RoleCardMgr:GetRoleCard(cardIds[i])
				local curCardHpPer = 0

				curCardHpPer = math.ceil((tab[i] or infoCard.curCommRaidHpPer) * 100)

				infoCard:UpdateCardHpPercent(curCardHpPer / 100)
				table.insert(cardHpRates, curCardHpPer)
			end
		else
			UnionRaidMgr.NotChangeCardHp = false
		end
	end

	local isWin = self.msg.isWin

	if infoStage.data.Type == StageFromType.unionBoss or infoStage.data.ChapterType == ChapterFromType.bossRaid or infoStage.data.ActType == 20 then
		isWin = true
	end

	monsterHpRates = self.msg.bloodCost

	Infogvg:Table(self.msg.bloodCost, "结算,本次战斗造成的伤害：")

	local gvgStage = Infogvg:Vaild(infoStage.data.ID)

	if gvgStage then
		isWin = true
		monsterHpRates = self.msg.bloodCost

		for i, val in ipairs(self.msg.bloodCost) do
			blood = blood + val
		end

		cardHpRates = {}

		local cardIds = self.msg.playerCardIds
		local tab = self.msg.playerHpRates or {}

		for i = 1, #cardIds do
			local infoCard = RoleCardMgr:GetRoleCard(cardIds[i])
			local curCardHpPer = 0

			curCardHpPer = math.ceil((tab[i] or infoCard.curGvgHpPer) * 100)

			if curCardHpPer > 0 then
				curCardHpPer = 100
			end

			table.insert(cardHpRates, curCardHpPer)
		end
	end

	local function wrap_cb(...)
		self:OnHandleEndStage(...)
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestEndStage(boutId, isWin, {
		serverArg1,
		serverArg2,
		serverArg3,
		serverArg4,
		serverArg5
	}, battlelogs, oltime, self.msg.whipRewardCount, monsterHpRates, cardHpRates, killMonsterList, chaos, wrap_cb, blood)
end

function DlgUIResult:OnHandleEndStage(vPBMessage)
	print("OnHandleEndStage code:" .. vPBMessage.result.code)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if vPBMessage.result.code == NetManager.Result_Sucess then
		if self.data ~= nil then
			return
		end

		self.bVictory = true
		self.data = {
			stars = vPBMessage.stars,
			setter = vPBMessage.setter,
			infoStage = ChapterMgr:GetStage(self.msg.stageId),
			listMonsterId = self.msg.killMonsterList,
			playerCardIds = self.msg.playerCardIds,
			dropRaidBossId = vPBMessage.dropRaidBossId,
			dropRaidBossStageId = vPBMessage.dropRaidBossStageId,
			dropReward = self.msg.dropReward,
			gvgChallengeTimes = vPBMessage.gvgChallengeTimes,
			roleCardTimes = vPBMessage.roleCardTimes
		}

		if not ChapterMgr.IsChallengeAgain then
			self:ChangeHelpCount()
		end

		ChapterMgr.IsChallengeAgain = false

		if self.data.infoStage.data.ChapterType == ChapterFromType.union then
			if self.data.infoStage.data.Type == StageFromType.unionCommon then
				UnionRaidMgr.ShowRaidRateUp = true

				UnionRaidMgr:FinishEvent()
			elseif self.data.infoStage.data.Type == StageFromType.unionBoss then
				local infoRaid = UnionRaidMgr:GetBossRaidByStageId(self.data.infoStage.id)

				if infoRaid then
					UnionRaidMgr.ChangeContributionValue(infoRaid.data.ContributionOfBattle)
				end
			end
		end

		local gvgStage = Infogvg:Vaild(self.msg.stageId)

		if gvgStage then
			if self.data.roleCardTimes then
				for i, r in ipairs(self.data.roleCardTimes) do
					Infogvg:SetCardTimes(r.cardId, r.times)
				end
			end

			if self.data.gvgChallengeTimes ~= Infogvg.stage.leftTimes then
				local blood = self.msg.curHps
				local cardIds = self.msg.playerCardIds
				local tab = self.msg.playerHpRates or {}

				Infogvg:BattleResult(gvgStage.stageId, blood, cardIds, tab, self.msg.bloodCost)
			end
		end

		self.obj_clickArea:SetActive(true)
	elseif vPBMessage.result.code == 4 then
		ReloadGameData(function()
			self.obj_clickArea:SetActive(true)
		end)
		UIMgr.ShowMsg(_("NetError_IsGetReward"))
	else
		self.bVictory = false

		self.obj_clickArea:SetActive(true)
	end
end

function DlgUIResult:OnClickedForecast()
	ChapterMgr.IsForecastState = true

	self:OnClickArea()
end

function DlgUIResult:OnClickArea(isForecast)
	GOUtil.SetActive(self.failed_panel_go, false)

	if self.boutId == -1 or SceneMgr.GetCurrentScene().GP.GameStartData.playMode == EnumFight.PlayMode.Replay then
		local infoStage = InfoStage(self.msg.stageId)

		if infoStage.data.ChapterType == ChapterFromType.bosslive and BossliveChapterMgr.GetBossliveRemainingChallengeNum() == 0 then
			local chapterId = infoStage.data.ChapterID
			local infoChapter = ChapterMgr:GetChapter(chapterId)
			local lastStageId = infoChapter:GetLastStageId()
			local stageup = 1

			if lastStageId == infoStage.data.ID then
				stageup = 0
			end

			self:Close()
			GP:ExitGameScript()
			SceneMgr.LoadScene("MainStage", {
				from = 4,
				leftnum = 0,
				stageId = infoStage.data.ID,
				stageup = stageup
			})

			return
		end

		self:Close()
		SceneMgr.GetCurrentScene().GP:ExitGame()

		return
	end

	if self.bVictory == false then
		local infoStage = ChapterMgr:GetStage(self.msg.stageId)

		if #infoStage.data.ReLiveCost < 1 then
			self:Close()
			SceneMgr.GetCurrentScene().GP:ExitGame()

			return
		else
			self:RefreshLosePanel()
		end
	else
		self:RefreshVictoryPanel()
	end
end

function DlgUIResult:RefreshVictoryPanel()
	if not self.data then
		self:Close()
		SceneMgr.GetCurrentScene().GP:ExitGame()

		return
	end

	if Infogvg:Vaild(self.msg.stageId) then
		self.obj_battleEnd:SetActive(false)
		self.obj_clickArea:SetActive(false)
		self.animPanel_Victory:SetActive(false)
		self.animPanel_Failed:SetActive(false)
		require("UI/Page/PageGvg/DlgGvgOver")
		UIMgr.AddPanel(DlgGvgOver(), self.data, self.Parent)
	elseif self.data.infoStage.data.ChapterType == ChapterFromType.bossRaid then
		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestBossRaidDamage(ActivityBossRaidMgr.curBossRaidId, function(vPBMessage)
			LoadingMgr.Hide(eLoadingType.Repeat)

			if vPBMessage.result.code == NetManager.Result_Sucess then
				self.obj_battleEnd:SetActive(false)
				self.obj_clickArea:SetActive(false)
				require("UI/Page/PageActivityBossRaid/PageBossRaidBattleEnd")

				local data = {}

				data.isBattleOver = true

				function data.callBack()
					self:Close()
					SceneMgr.GetCurrentScene().GP:ExitGame()
				end

				data.harms = vPBMessage.harms
				data.stageId = self.msg.stageId
				data.setter = self.data.setter
				data.bloodCost = self.msg.bloodCost

				UIMgr.AddPanel(PageBossRaidBattleEnd(), data, self.Parent)
			else
				UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
			end
		end)
	elseif self.data.infoStage.data.ActType == 20 then
		self.obj_battleEnd:SetActive(false)
		self.obj_clickArea:SetActive(false)
		require("UI/Page/PageActivityBossRaid/PageBossRaidBattleEnd")

		local data = {}

		data.isBattleOver = true

		function data.callBack()
			self:Close()
			SceneMgr.GetCurrentScene().GP:ExitGame()
		end

		data.stageId = self.msg.stageId
		data.setter = self.data.setter
		data.curHp = self.msg.curHps[1]

		UIMgr.AddPanel(PageBossRaidBattleEnd(), data, self.Parent)
	else
		self.obj_clickArea:SetActive(false)
		Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIVictory", true, self.data)
	end
end

function DlgUIResult:RefreshLosePanel()
	GOUtil.SetActive(self.obj_clickArea, false)
	GOUtil.SetActive(self.obj_promptPanel, true)

	local infoStage = ChapterMgr:GetStage(self.msg.stageId)
	local itemId = infoStage.data.ReLiveCost[1]

	if not itemId then
		return
	end

	local infoItem = ItemManager:Get(itemId)

	UIUtil.SetImageSprite(self.img_itemIcon, "UIDyAtlas/Icon/" .. infoItem.data.Icon)

	self.txt_costValue.text = infoStage.data.ReLiveCost[2]
	self.txt_holdValue.text = PlayerInst:GetDiamond()
end

function DlgUIResult:OnBtnGiveUp()
	self:Purge()
	SceneMgr.GetCurrentScene().GP:ExitGame()
end

function DlgUIResult:OnBtnGoOn()
	local costNum = tonumber(self.txt_costValue.text)
	local holdNum = tonumber(self.txt_holdValue.text)

	if costNum <= holdNum then
		GOUtil.SetActive(self.obj_promptPanel, false)
		self:Show(false)

		self.listRoleCardId = SceneMgr.GetCurrentScene().GP.ChapterTeam

		local function wrap_cb(pb)
			self:ResponseRestartGame(pb)
		end

		NetManager:RequestStartStage(self.msg.stageId, self.listRoleCardId, true, wrap_cb)
		LoadingMgr.Show(eLoadingType.Repeat)
	else
		UIMgr.ShowMsg(_("Msg_CostNoEnough"))
	end
end

function DlgUIResult:ResponseRestartGame(P42_Response)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if P42_Response.result.code == 0 then
		local boutId = P42_Response.boutId

		SceneMgr.GetCurrentScene().GP:BuyLive(boutId)
	else
		UIMgr.ShowMsg(P42_Response.result.desc, P42_Response)
	end
end

function DlgUIResult:OnClickedReplay()
	GP:ReplayGame()
end

function DlgUIResult:OnClickedResultAddUp()
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIResultAddUp")
end

function DlgUIResult:ChangeHelpCount()
	local InfoTeam = require("Info/InfoTeam")
	local infoStage = InfoStage(self.msg.stageId)

	if infoStage.data.ChapterType == ChapterFromType.union then
		if infoStage.data.Type == StageFromType.unionBoss then
			InfoTeam = require("Info/InfoTeamBossRaid")
		else
			InfoTeam = require("Info/InfoTeamRaid")
		end
	elseif infoStage.data.ChapterType == ChapterFromType.comb then
		InfoTeam = require("Info/InfoTeamgGroup")
	elseif infoStage.data.ChapterType == ChapterFromType.timespace then
		InfoTeam = require("Info/InfoTeamTimespace")
	else
		InfoTeam = require("Info/InfoTeam")
	end

	local gvgStage = Infogvg:Vaild(infoStage.data.ID)

	if gvgStage then
		InfoTeam = require("Info/InfoTeamGvg")
	end

	local teamAgent = InfoTeam.teamSystemAgent.teamList[InfoTeam.teamSystemAgent.teamIndex]
	local slot = teamAgent.slotList

	if slot[5].upInfoRoleCard and slot[5].upInfoRoleCard.pbPlayer and not InfoTeam.teamSystemAgent.isGvg then
		InfoGameInst:SetFriendHelpTimes(InfoGameInst:GetFriendHelpTimes() + 1)
	end
end
