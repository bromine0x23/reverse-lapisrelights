-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTeam/PageTeam.lua

require("UI/Page/PageTeam/TeamCard")
require("UI/Page/PageTeam/TeamCardSpine")
require("UI/Page/PageTeam/TeamCardAdd")
require("UI/Page/PageTeam/PageChooseRoleCard")
require("UI/Page/PageTeam/PageChooseAddCard")
require("Util/JobCheckingUtil")
require("UI/Page/PageRoleCard/Page/PageRoleCard")
require("UI/Page/pagePVP/PageOpponentCards")

local lev = require("luaData/LevelConfig")
local InfoTeam = require("Info/InfoTeam")
local InfoTeamGvg = require("Info/InfoTeamGvg")
local InfoTeamRaid = require("Info/InfoTeamRaid")
local InfoTeamBossRaid = require("Info/InfoTeamBossRaid")
local InfoTeamgGroup = require("Info/InfoTeamgGroup")
local InfoTeamgTS = require("Info/InfoTeamTimespace")
local InfoPVPData = require("Info/InfoPVP")

PageTeam = class("PageTeam", UIPanel)

function PageTeam:ctor()
	self.UIPrefabPath = "UI/PanelBattleTeam/PanelTeam"

	self:AddChildPanel(DlgExit(), {
		title = _("PageTeam_TeamInfo"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
end

function PageTeam:PreLoad()
	self:LoadResAsync("UI/PanelBattleTeam/TeamCard", "PrefabTeamCard")
	self:LoadResAsync("UI/PanelBattleTeam/TeamCardSpine", "PrefabTeamCardSpine")
	self:LoadResAsync("UI/PanelBattleTeam/TeamCardAdd", "PrefabTeamSupCard")
	self:LoadResAsync("UI/PanelRoleCard/CellCardSkill", "PrefabCellCardSkill")
	self:LoadResAsync("UI/Common/DlgCommon/DlgLongTip", "DlgLongTip")
end

function PageTeam:Purge()
	self:RemoveCardAnim()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabTeamCard)
	ResourceMgr.Unload(self.PrefabTeamCardSpine)
	ResourceMgr.Unload(self.PrefabTeamSupCard)
	ResourceMgr.Unload(self.PrefabCellCardSkill)

	ChapterMgr.BossLiveToTeam = 0

	if self.teamCards then
		for _, v in pairs(self.teamCards) do
			v:OnLeave()
		end

		self.teamCards = nil
	end

	if self.teamSupCards then
		for _, v in pairs(self.teamSupCards) do
			v:OnLeave()
		end

		self.teamSupCards = nil
	end

	if self.tramCardSpines then
		for _, v in pairs(self.tramCardSpines) do
			v:OnLeave()
		end

		self.tramCardSpines = nil
	end

	if self.DlgLongTip then
		ResourceMgr.Unload(self.DlgLongTip)

		self.DlgLongTip = nil
	end

	self.animList = nil

	if self.timer1 ~= nil then
		TimerMgr.RemoveTimer(self.timer1)

		self.timer1 = nil
	end

	System.GC.Collect()
end

function PageTeam:OnBack()
	local function callback(...)
		UIMgr.PopPanel()
	end

	local isFalg = self:TeamFullReturnCall(callback)

	if not isFalg then
		if UIMgr.GetPrePanel().className == "PageBossActivityStageBG" then
			UIMgr.PopPanel({
				stageType = self.infoStage.data.Type
			})
		else
			UIMgr.PopPanel()
		end
	end
end

function PageTeam:OnRegisterEvent()
	self:AddClick(self.BtnHelp, self.OnClickedBtnHelp)
	self:AddClick(self.BtnExpressTeam, self.OnClickedBtnExpressTeam)
	self:AddClick(self.BtnFittingRoom, self.OnClickedBtnFittingRoom)
	self:AddClick(self.BtnLTeam, self.OnClickedBtnLTeam)
	self:AddClick(self.BtnRTeam, self.OnClickedBtnRTeam)
	self:AddClick(self.BtnBegin, self.OnClickedBtnBegin)
	self:AddClick(self.BtnRename, self.OnClickedBtnRename)
	self:AddClick(self.GoBondage, self.OnClickedGoBondage)
	self:AddClick(self.BtnOpponentDetail, self.OnClickedOpponentDetail)
	self:AddClick(self.btn_choose_start_card.gameObject, self.OnClickedChooseStartCardState)
	Event.Instance:Add("TeamBondageChange", self.TeamBondageChangeCall, self)
	Event.Instance:Add(EventEnum.ResetCardHpPercent, self.RefreshCardHp, self)
	Event.Instance:Add("PageTeamCardAnimation", self.PlayCardAnim, self)

	if self.teamCards then
		for _, teamCard in ipairs(self.teamCards) do
			self:AddClick(teamCard.GoNoneCard, self.OnClickedCard)
			self:AddListener(teamCard.UIRootObject, self.OnPointerLongPressCard, EventTriggerType.PointerLongPress)
			self:AddListener(teamCard.UIRootObject, self.OnBeginDragCard, EventTriggerType.BeginDrag)
			self:AddListener(teamCard.UIRootObject, self.OnDragCard, EventTriggerType.Drag)
			self:AddListener(teamCard.UIRootObject, self.OnEndDragCard, EventTriggerType.EndDrag)
		end
	end
end

function PageTeam:OnUnRegisterEvent()
	self:RemoveClick(self.BtnHelp, self.OnClickedBtnHelp)
	self:RemoveClick(self.BtnExpressTeam, self.OnClickedBtnExpressTeam)
	self:RemoveClick(self.BtnFittingRoom, self.OnClickedBtnFittingRoom)
	self:RemoveClick(self.BtnLTeam, self.OnClickedBtnLTeam)
	self:RemoveClick(self.BtnRTeam, self.OnClickedBtnRTeam)
	self:RemoveClick(self.BtnBegin, self.OnClickedBtnBegin)
	self:RemoveClick(self.BtnRename, self.OnClickedBtnRename)
	self:RemoveClick(self.GoBondage, self.OnClickedGoBondage)
	self:RemoveClick(self.btn_choose_start_card.gameObject, self.OnClickedChooseStartCardState)
	Event.Instance:Remove("TeamBondageChange", self.TeamBondageChangeCall, self)
	Event.Instance:Remove(EventEnum.ResetCardHpPercent, self.RefreshCardHp, self)
	Event.Instance:Remove("PageTeamCardAnimation", self.PlayCardAnim, self)

	if self.teamCards then
		for _, teamCard in ipairs(self.teamCards) do
			self:RemoveClick(teamCard.GoNoneCard, self.OnClickedCard)
			self:RemoveListener(teamCard.UIRootObject, self.OnPointerLongPressCard, EventTriggerType.PointerLongPress)
			self:RemoveListener(teamCard.UIRootObject, self.OnBeginDragCard, EventTriggerType.BeginDrag)
			self:RemoveListener(teamCard.UIRootObject, self.OnDragCard, EventTriggerType.Drag)
			self:RemoveListener(teamCard.UIRootObject, self.OnEndDragCard, EventTriggerType.EndDrag)
		end
	end
end

function PageTeam:OnEnter(vParam)
	self:DealWithLocalization()

	self.GoCombatPower = self:GetChildGameObject("TopShape/CombatPower")
	self.TxtCombatPower = self:GetChildComponent("TopShape/CombatPower/TextValue", "Text")
	self.GoTeamCost = self:GetChildGameObject("TopShape/TeamCost")
	self.TxtTeamCost = self:GetChildComponent("TopShape/TeamCost/TextCost", "Text")
	self.GoTeamInfo = self:GetChildGameObject("BotShape/Team")
	self.TxtTeamIdx = self:GetChildComponent("BotShape/Team/BgTeamIdx/TeamIdx", "Text")
	self.TxtTeamName = self:GetChildComponent("BotShape/Team/TxtName", "Text")
	self.BtnRename = self:GetChildGameObject("BotShape/Team/BtnRename")
	self.GoBondage = self:GetChildGameObject("BotShape/Bondage")
	self.ImgBondageIcon = self:GetChildComponent("BotShape/Bondage/Icon", "Image")
	self.ImgBondageRank = self:GetChildComponent("BotShape/Bondage/Rank", "Image")
	self.GoNoEquipBondage = self:GetChildGameObject("BotShape/Bondage/Text")
	self.GoBondageDot = self:GetChildGameObject("BotShape/Bondage/Dot")
	self.GoRaid = self:GetChildGameObject("BotShape/Raid")
	self.GoArrow = self:GetChildGameObject("Arrow")
	self.BtnLTeam = self:GetChildGameObject("Arrow/BtnLeft")
	self.BtnRTeam = self:GetChildGameObject("Arrow/BtnRight")
	self.BtnHelp = self:GetChildGameObject("TopShape/RecommendJob/BtnHelp")
	self.BtnExpressTeam = self:GetChildGameObject("TopShape/BtnGroup/BtnExpressTeam")
	self.BtnFittingRoom = self:GetChildGameObject("TopShape/BtnGroup/BtnFittingRoom")
	self.BtnBegin = self:GetChildGameObject("BotShape/BtnBegin")
	self.TxtOpponentLevel = self:GetChildComponent("TopShape/OtherPlayer/HeadIcon/Level", "Text")
	self.MaskImgOpponentHead = self:GetChildComponent("TopShape/OtherPlayer/HeadIcon", "MaskableImage")
	self.TxtOpponentPower = self:GetChildComponent("TopShape/OtherPlayer/Power/Value", "Text")
	self.BtnOpponentDetail = self:GetChildGameObject("TopShape/OtherPlayer/DetailBtn")
	self.TeamGoGrag = self:GetChildGameObject("TeamGoGrag")
	self.GoTip = self:GetChildGameObject("BotShape/tips")
	self.btn_choose_start_card = self:GetChildComponent("BotShape/Auto_Choose/btn_choose_start_card", "Image")
	self.obj_chooseStart = self:GetChildGameObject("BotShape/Auto_Choose")
	self.CanvasGroup = self:GetChildComponent("TeamCard", "CanvasGroup")

	self:InitData(vParam)
	TaskManager:ClearTips()
end

function PageTeam:DealWithLocalization()
	local TextAuto

	TextAuto = self:GetChildComponent("TopShape/CombatPower/Text", "Text")
	TextAuto.text = _("Team_Combat_Power") .. "："
	TextAuto = self:GetChildComponent("TopShape/RecommendJob/Text", "Text")
	TextAuto.text = Lang(5000030) .. "："
	TextAuto = self:GetChildComponent("TopShape/TeamCost/Text", "Text")
	TextAuto.text = Lang(5000029) .. "："
	TextAuto = self:GetChildComponent("TopShape/BtnGroup/BtnExpressTeam/Text", "Text")
	TextAuto.text = Lang(5000034)
	TextAuto = self:GetChildComponent("TopShape/BtnGroup/BtnFittingRoom/Text", "Text")
	TextAuto.text = _("UI_Fittingroom")
	TextAuto = self:GetChildComponent("BotShape/Bondage/Text", "Text")
	TextAuto.text = Lang(200006)
	TextAuto = self:GetChildComponent("BotShape/Raid/Text", "Text")
	TextAuto.text = _("Desc_Team_Raid_Battle")
	TextAuto = self:GetChildComponent("BotShape/BtnBegin/Text", "Text")
	TextAuto.text = Lang(5000035)
	TextAuto = self:GetChildComponent("BotShape/tips", "Text")
	TextAuto.text = "※" .. _("Desc_JumpToGrowCard")
	TextAuto = self:GetChildComponent("TopShape/OtherPlayer/Power/Text", "Text")
	TextAuto.text = _("Desc_Combat_Power")
	TextAuto = self:GetChildComponent("BotShape/Auto_Choose/tex_choose_start_card", "Text")
	TextAuto.text = _("Desc_Auto_Choose_Skill_Card")
end

function PageTeam:InitData(vParam)
	self.teamSystemAgent = vParam

	TeamMgr.Instance:SetTeamIndex(self.teamSystemAgent.teamIndex)

	self.infoStage = InfoTeam.infoStage

	if self.teamSystemAgent.isRaid then
		if not self.teamSystemAgent.isBossRaid then
			self.infoStage = InfoTeamRaid.infoStage
		else
			self.infoStage = InfoTeamBossRaid.infoStage
		end
	elseif self.teamSystemAgent.isTeamGroup then
		self.infoStage = InfoTeamgGroup.infoStage
	elseif self.teamSystemAgent.isGvg then
		self.infoStage = InfoTeamGvg.infoStage
	elseif self.teamSystemAgent.isTimespace then
		self.infoStage = InfoTeamgTS.infoStage
	end

	self:InitUIPanel()
	self:InitStageData()
	self:InitTeamData()
	self:SetEmptyCardAlpha()
end

function PageTeam:InitUIPanel()
	local group = self:GetChildGameObject("BotShape/Team/GroupIndex")
	local go = self:GetChildGameObject("BotShape/Team/GroupIndex/Go")

	SetActiveFunc(go, true)

	for i = 1, self.teamSystemAgent.teamCount do
		local g = GOUtil.Instantiate(go, group)

		self["GoTeamEable" .. i] = GOUtil.FindChildGameObject(g, "Eable")
		self["GoTeamDable" .. i] = GOUtil.FindChildGameObject(g, "Dable")
	end

	SetActiveFunc(go, false)
	SetActiveFunc(self.GoCombatPower, not self.teamSystemAgent.noCombatPower)
	SetActiveFunc(self.GoTeamCost, not self.teamSystemAgent.noTeamSumCost)
	SetActiveFunc(self.BtnExpressTeam, not self.teamSystemAgent.noExpressTeamBtn)
	SetActiveFunc(self.BtnFittingRoom, not self.teamSystemAgent.noFittingRoomBtn and TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Dress))
	SetActiveFunc(self.GoArrow, not self.teamSystemAgent.noSwitchTeam)
	SetActiveFunc(self.GoTeamInfo, not self.teamSystemAgent.noSwitchTeam)

	if self.teamSystemAgent.isRaid == nil then
		self.teamSystemAgent.isRaid = false
	end

	SetActiveFunc(self.GoRaid, self.teamSystemAgent.isRaid)
	SetActiveFunc(self.GoBondage, TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Bondage) and not self.teamSystemAgent.noCombBondage)
	SetActiveFunc(self.BtnBegin, not self.teamSystemAgent.noBattleBeginBtn)

	if self.infoStage and self.infoStage.data.ChapterType == ChapterFromType.union then
		-- block empty
	end

	local path = TenaryOp(RoleCardMgr:GetChooseStartCardState() == "1", "UI/PanelBattleTeam/AtlasPanelTeam/BTN_option_select_2", "UI/PanelBattleTeam/AtlasPanelTeam/BTN_option_select_1")

	UIUtil.SetImageSprite(self.btn_choose_start_card, path, self)
end

function PageTeam:InitStageData()
	local goRecommendJob = self:GetChildGameObject("TopShape/RecommendJob")

	SetActiveFunc(goRecommendJob, true)
	SetActiveFunc(goRecommendJob, self.teamSystemAgent.recommendJob ~= nil)

	if self.teamSystemAgent.recommendJob ~= nil then
		local imgRecommendJob = GOUtil.FindChildComponent(goRecommendJob, "Job/Image", "Image")

		SetImageSprite(imgRecommendJob, "UI/PanelBattleTeam/AtlasPanelTeam/ICO_" .. self.teamSystemAgent.recommendJob .. "_01_S", self)
	else
		local imgRecommendJob = GOUtil.FindChildComponent(goRecommendJob, "Job/Image", "Image")

		SetImageSprite(imgRecommendJob, "UI/PanelBattleTeam/AtlasPanelTeam/ICO_NoVocation_01_S", self)
	end

	if not self.teamSystemAgent.noBattleBeginBtn then
		local imgItem = self:GetChildComponent("BotShape/BtnBegin/ImgItem", "Image")
		local txtItem = self:GetChildComponent("BotShape/BtnBegin/TxtItem", "Text")

		SetActiveFunc(imgItem.gameObject, self.teamSystemAgent.battleCost ~= nil)
		SetActiveFunc(txtItem.gameObject, self.teamSystemAgent.battleCost ~= nil)

		if self.teamSystemAgent.battleCost then
			local itemId = self.teamSystemAgent.battleCost[1].itemId
			local needNum = self.teamSystemAgent.battleCost[1].needNum
			local info = ItemManager:Get(itemId)

			SetImageSprite(imgItem, info:GetIcon(), self)

			txtItem.text = needNum
		else
			local goText = self:GetChildGameObject("BotShape/BtnBegin/Text")

			goText.transform.localPosition = Vector3(0, 0, 0)
		end
	end
end

function PageTeam:InitTeamData()
	self:CreateTeam()
	self:UpdateTeam()
end

function PageTeam:CreateTeam()
	self.teamCards = {}
	self.teamSupCards = {}
	self.tramCardSpines = {}

	local teamAgent = self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex]
	local slotList = teamAgent.slotList

	for i = 1, 5 do
		local cardSlot = self:GetChildGameObject("TeamCard/Slot" .. i)

		SetActiveFunc(cardSlot, i <= #slotList)

		if i <= #slotList then
			local teamCard = TeamCard(self.PrefabTeamCard, cardSlot, self)

			teamCard:Create()

			teamCard.UIRootObject.name = "cardRoot_" .. i

			table.insert(self.teamCards, teamCard)

			local teamSupCard = TeamCardAdd(self.PrefabTeamSupCard, cardSlot, self)

			teamSupCard:Create()

			teamSupCard.UIRootObject.name = "cardRootAdd_" .. i

			table.insert(self.teamSupCards, teamSupCard)

			cardSlot = self:GetChildGameObject("TeamSpine/Slot" .. i)

			SetActiveFunc(cardSlot, i <= #slotList)

			local teamSpine = TeamCardSpine(self.PrefabTeamCardSpine, cardSlot, self)

			teamSpine:Create()

			teamSpine.UIRootObject.name = "cardSpineRoot_" .. i

			table.insert(self.tramCardSpines, teamSpine)
		end
	end

	if self.teamSystemAgent.slotSpacing then
		local horizontal = self:GetChildComponent("TeamCard", "HorizontalLayoutGroup")

		horizontal.spacing = self.teamSystemAgent.slotSpacing
	end
end

function PageTeam:UpdateTeam()
	self.teamAgent = self.teamSystemAgent.teamList[self.teamSystemAgent.teamIndex]

	local cardReplace = false

	for i = 1, #self.teamAgent.slotList do
		if self.teamAgent.slotList[i].upInfoRoleCard then
			if not self.teamAgent.slotList[i]:LimitCheck(self.teamAgent.slotList[i].upInfoRoleCard) then
				self.teamAgent.slotList[i]:ReplaceUpCard()

				cardReplace = true
			else
				local cardId = self.teamAgent.slotList[i].upInfoRoleCard.id

				for j = 1, #self.teamAgent.slotList do
					if self.teamAgent.slotList[j].addInfoRoleCard and self.teamAgent.slotList[j].addInfoRoleCard.id == cardId then
						UIMgr.ShowMsg(_("DlgCommon_SameRoleCantAdd"))

						self.teamAgent.slotList[j].addInfoRoleCard = nil
						cardReplace = true
					end
				end

				if self.teamAgent.slotList[i].addInfoRoleCard and TeamSystemAgent.SameRole(self.teamAgent.slotList[i].addInfoRoleCard.id, cardId) then
					UIMgr.ShowMsg(_("DlgCommon_SameRoleCantAdd"))

					self.teamAgent.slotList[i].addInfoRoleCard = nil
					cardReplace = true
				end
			end
		end
	end

	if cardReplace then
		cardReplace = false

		self:TeamChangeCall()
	end

	self.upNum = 0

	for _, value in pairs(self.teamAgent.slotList) do
		if value.upInfoRole ~= nil then
			self.upNum = self.upNum + 1
		end
	end

	self:UpdateTeamCards()
	self:UpdateTeamPower()
	self:UpdateTeamCost()
	self:UpdateTeamInfo()
	self:UpdateTeamBondage()
	self:UpdatePvpInfo()
end

function PageTeam:UpdateTeamCards()
	for k, teamCard in pairs(self.teamCards) do
		teamCard.UIRootObject.transform:SetSiblingIndex(0)
		teamCard:UpdateData(self.teamSystemAgent, k)
	end

	for n, teamSupCard in pairs(self.teamSupCards) do
		teamSupCard.UIRootObject.transform:SetSiblingIndex(1)
		teamSupCard:UpdateData(self.teamSystemAgent, n)
	end

	for n, teamCardSpine in pairs(self.tramCardSpines) do
		teamCardSpine.UIRootObject.transform:SetSiblingIndex(0)
		teamCardSpine:UpdateData(self.teamSystemAgent, n)
	end
end

function PageTeam:UpdateTeamPower()
	if self.teamSystemAgent.noCombatPower then
		return
	end

	self.TxtCombatPower.text = self.teamAgent:GetTeamCP()
end

function PageTeam:UpdateTeamCost()
	if self.teamSystemAgent.noTeamSumCost then
		return
	end

	local maxCost = LevelManager:GetMaxCost(PlayerInst:GetCurLv())
	local curCost = self.teamAgent:GetTeamCost()
	local colorStr = TenaryOp(maxCost < math.ceil(curCost), "#FF0000", "#F8D616")

	self.TxtTeamCost.text = "<color=" .. colorStr .. ">" .. math.ceil(curCost) .. "</color>/" .. maxCost
end

function PageTeam:UpdateTeamInfo()
	if self.teamSystemAgent.noSwitchTeam then
		return
	end

	self.TxtTeamIdx.text = self.teamSystemAgent.teamIndex

	if self.teamAgent.name ~= "" then
		self.TxtTeamName.text = self.teamAgent.name
	else
		self.TxtTeamName.text = _("Desc_Team") .. self.teamSystemAgent.teamIndex
	end

	for i = 1, self.teamSystemAgent.teamCount do
		SetActiveFunc(self["GoTeamEable" .. i], i == self.teamSystemAgent.teamIndex)
		SetActiveFunc(self["GoTeamDable" .. i], i ~= self.teamSystemAgent.teamIndex)
	end

	SetActiveFunc(self.BtnLTeam, self.teamSystemAgent.teamIndex ~= 1)
	SetActiveFunc(self.BtnRTeam, self.teamSystemAgent.teamIndex ~= self.teamSystemAgent.teamCount)
end

function PageTeam:UpdateTeamBondage()
	if self.teamSystemAgent.noCombBondage or not TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Bondage) then
		return
	end

	local fetterId = self.teamAgent.fetterTeamId

	SetActiveFunc(self.ImgBondageIcon.gameObject, fetterId ~= nil and fetterId ~= 0)
	SetActiveFunc(self.ImgBondageRank.gameObject, fetterId ~= nil and fetterId ~= 0)
	SetActiveFunc(self.GoNoEquipBondage, fetterId ~= nil and fetterId == 0)

	if fetterId ~= nil and fetterId ~= 0 then
		SetImageSprite(self.ImgBondageIcon, "UIDyAtlas/Team/IC_IDH_" .. fetterId .. "00", self)

		local rank = CombBondageMgr:GetBondageRank(fetterId)
		local infoComb = CombinationMgr:Get(fetterId)

		if infoComb then
			SetImageSprite(self.ImgBondageRank, "UI/PanelBattleTeam/AtlasPanelTeam/IC_fetter_crown_0" .. rank .. "a", self)
		end
	end

	local hasDot = false

	for _, v in ipairs(CombinationMgr.GetAllBondageCombination()) do
		local t = BondageRDL.GetUnlockBondage(v.id)

		if #t > 0 then
			hasDot = true

			break
		end
	end

	if not hasDot and (fetterId == nil or fetterId == 0) then
		hasDot = CombBondageMgr.IsHaveUnlockCombinationBondage()
	end

	GOUtil.SetActive(self.GoBondageDot, hasDot)
end

function PageTeam:UpdatePvpInfo()
	if self.teamSystemAgent.isPvp then
		GOUtil.SetActive(self.obj_chooseStart, false)
	end

	if not self.teamSystemAgent.isPvp or not self.teamSystemAgent.isPvpAtk then
		return
	end

	local go = self:GetChildGameObject("TopShape/RecommendJob")

	SetActiveFunc(go, false)

	go = self:GetChildGameObject("TopShape/OtherPlayer")

	SetActiveFunc(go, true)

	local opponentData = InfoPVPData:GetCurrentBatllePlayer()

	self.TxtOpponentLevel.text = opponentData.playerinfo.curLevel

	UIUtil.SetImageSprite(self.MaskImgOpponentHead, opponentData.playerinfo:GetTitleIcon(1), self)

	self.TxtOpponentPower.text = InfoPVPData:GetAddRoleCard(opponentData)
end

function PageTeam:OnClickedOpponentDetail()
	UIMgr.AddPanel(PageOpponentCards())
end

function PageTeam:OnClickedBtnHelp()
	if not self.infoStage then
		return
	end

	require("UI/Dlg/Common/DlgPhase")
	UIMgr.AddPanel(DlgPhase(), {
		infoStage = self.infoStage,
		recommendJob = self.teamSystemAgent.recommendJob
	})
end

function PageTeam:OnClickedBtnExpressTeam()
	self:OnClickedQuickTeamQuickTeam()
end

function PageTeam:OnClickedBtnFittingRoom()
	require("UI/Page/PageCardShop/PageCardFittingRoom")
	UIMgr.SwitchPanel(PageCardFittingRoom, self.teamSystemAgent)
end

function PageTeam:OnClickedBtnLTeam()
	self.teamSystemAgent.teamIndex = self.teamSystemAgent.teamIndex - 1

	TeamMgr.Instance:SetTeamIndex(self.teamSystemAgent.teamIndex)
	self:UpdateTeam()
end

function PageTeam:OnClickedBtnRTeam()
	self.teamSystemAgent.teamIndex = self.teamSystemAgent.teamIndex + 1

	TeamMgr.Instance:SetTeamIndex(self.teamSystemAgent.teamIndex)
	self:UpdateTeam()
end

function PageTeam:OnClickedGoBondage()
	local haveUnlock = CombBondageMgr.IsHaveUnlockCombinationBondage()

	if not haveUnlock then
		UIMgr.ShowMsg(Lang(200007))

		return
	end

	require("UI/Page/PageBondage/DlgBondageSkillSelect")
	UIMgr.AddPanel(DlgBondageSkillSelect(), self.teamSystemAgent)
end

function PageTeam:OnClickedChooseStartCardState()
	if RoleCardMgr:GetChooseStartCardState() == "0" then
		RoleCardMgr:SetChooseStartCardState("1")
		UIUtil.SetImageSprite(self.btn_choose_start_card, "UI/PanelBattleTeam/AtlasPanelTeam/BTN_option_select_2", self)
	else
		RoleCardMgr:SetChooseStartCardState("0")
		UIUtil.SetImageSprite(self.btn_choose_start_card, "UI/PanelBattleTeam/AtlasPanelTeam/BTN_option_select_1", self)
	end
end

function PageTeam:OnClickedBtnRename()
	local function cb(input, cb)
		self:TeamNameChangeCall(input, cb)
	end

	require("UI/Page/PagePlayerInfo/DlgModifyNick")
	UIMgr.AddPanel(DlgModifyNick(), {
		eModifyInputType.Team,
		self.TxtTeamName.text,
		cb
	})
end

function PageTeam:OnClickedBtnBegin()
	for i, v in ipairs(self.teamAgent.slotList) do
		if not v.upInfoRoleCard or not v:LimitCheck(v.upInfoRoleCard) then
			UIMgr.ShowMsg(_("Msg_OrganizeWrong"))

			return
		end
	end

	if self.teamSystemAgent.isPvp ~= nil then
		if not self.teamAgent:FullUpCard() then
			UIMgr.ShowMsg(_("Desc_Team_Not_Enough"))

			return
		end

		if self.teamSystemAgent.battleCost and self.teamSystemAgent.battleCost.type == 2 then
			local costId = self.teamSystemAgent.battleCost.itemid
			local costNum = self.teamSystemAgent.battleCost.count
			local hasNum = ItemManager:GetItemCount(costId)

			if hasNum < costNum then
				local infoItem = ItemManager:Get(costId)

				UIMgr.ShowMsg(string.format(_("Desc_Count_Insufficient"), Lang(infoItem.data.Name)))

				return
			end
		end

		if self.teamSystemAgent.battleCall then
			self.teamSystemAgent.battleCall()
		end

		return
	end

	if not self.infoStage then
		return
	end

	local infoStage = self.infoStage
	local stageType = infoStage.data.Type
	local chapterType = infoStage.data.ChapterType

	if stageType == StageFromType.unionBoss then
		local isOpen, msg = UnionRaidMgr.IsBossOpenOfFloor(1)

		if not isOpen then
			UIMgr.ShowMsg(msg)

			return
		end
	end

	local function funBegin()
		self:BattleBeginCall()

		local curlist = {}
		local curCardlist = {}

		for _, slot in ipairs(self.teamAgent.slotList) do
			local card = slot.upInfoRoleCard

			if not slot.isHelperCard then
				local roleid = RoleCardMgr:GetRoleId(card.id)

				table.insert(curlist, roleid)
				table.insert(curCardlist, card.id)
			end
		end

		RoleCardMgr:SetCommonTeamRoleList(curlist)
		RoleCardMgr:SetCommonTeamRoleCardList(curCardlist)
		RoleCardMgr:SetTeamListIndex(self.teamSystemAgent.teamIndex .. "")

		if infoStage.data.ChapterType == ChapterFromType.bosslive then
			InfoStage:SetCurBossliveIndex(infoStage.data.ID)
		end

		local num = math.random(1, #self.teamAgent.slotList)
		local infoRoleCard = self.teamAgent.slotList[num].upInfoRoleCard
		local vocalEventName = RoleCardMgr:GetRole(infoRoleCard.id).data.VocalCommon12
		local vocalBankName = RoleCardMgr:GetRole(infoRoleCard.id).data.VocalBank

		InfoSoundEventMgr:LoadBank(vocalBankName)
		InfoSoundEventMgr:Play("VocalCommon12", vocalEventName)
	end

	if infoStage.id == GetConfigArgInt("GuideCard.StageID") and not infoStage:IsPass() then
		funBegin()

		return
	end

	local function funRole()
		return self.teamAgent:FullUpCard()
	end

	local function funSp()
		if self.teamSystemAgent.noTeamSumCost then
			return true
		end

		local maxCost = LevelManager:GetMaxCost(PlayerInst:GetCurLv())
		local curCost = self.teamAgent:GetTeamCost()

		return curCost <= maxCost
	end

	local function funItem()
		if not self.teamSystemAgent.battleCost then
			return true
		end

		for k, v in pairsByKeys(self.teamSystemAgent.battleCost) do
			if ItemManager:GetType(v.itemId) == eItemType.P_POWER then
				if not ItemManager:IsItemHoldEnough(v.itemId, v.needNum, true) then
					require("UI/Dlg/Common/DlgPowerBuy")
					UIMgr.AddPanel(DlgPowerBuy())

					return false
				end
			elseif not ItemManager:IsItemHoldEnough(v.itemId, v.needNum) then
				return false
			end
		end

		return true
	end

	local function funHp()
		local canBat = true

		if self.teamSystemAgent.isRaid then
			for k, slot in ipairs(self.teamAgent.slotList) do
				local card = slot.upInfoRoleCard

				if card then
					local hpPer = card.curCommRaidHpPer or 0

					if hpPer == 0 then
						if self.teamSupCards[k] then
							self.teamSupCards[k]:PlayEmptyHpAnim()
						end

						canBat = false
					end
				end
			end
		end

		return canBat
	end

	if not funRole() then
		UIMgr.ShowMsg(Lang(12185))

		return
	elseif not funSp() then
		UIMgr.ShowMsg(Lang(12187))

		return
	elseif self.teamSystemAgent.isRaid and not funHp() then
		UIMgr.ShowMsg(_("Msg_Team_Card_Battle_Unable"))

		return
	elseif self.teamSystemAgent.isGvg and not funHp() then
		UIMgr.ShowMsg(_("Msg_Team_Card_Battle_Unable"))

		return
	elseif not funItem() then
		-- block empty
	end

	funBegin()
end

function PageTeam:BattleBeginCall()
	local function cb()
		if self.teamSystemAgent.battleCall then
			self.teamSystemAgent.battleCall()
		end
	end

	if UnionMgr.HasUnion() then
		require("UI/Page/PageUnionFunction/PageUnionSkill")
		PageUnionSkill.RequestData(cb, true)
	else
		cb()
	end
end

function PageTeam:TeamChangeCall(callback)
	if self.teamSystemAgent.teamChangeCall then
		self.teamSystemAgent.teamChangeCall(callback)
	end
end

function PageTeam:TeamNameChangeCall(name, cb)
	local function wrap_cb()
		UIMgr.ShowMsg(_("Msg_Team_Name_Modify_Sucess"))

		if name ~= "" then
			self.TxtTeamName.text = name
		else
			self.TxtTeamName.text = _("Desc_Team") .. self.teamSystemAgent.teamIndex
		end

		CardFilterMgr.ResetTeamName(eFilterSystemType.Develop)
		CardFilterMgr.ResetTeamName(eFilterSystemType.Intance)

		if cb then
			cb()
		end
	end

	if self.teamSystemAgent.teamNameChangeCall then
		self.teamSystemAgent.teamNameChangeCall(wrap_cb, name)
	else
		wrap_cb()
	end
end

function PageTeam:TeamBondageChangeCall(bondageId)
	local function wrap_cb()
		self:UpdateTeamBondage()
	end

	if not self.teamSystemAgent.noCombBondage and self.teamSystemAgent.teamBondageChangeCall then
		self.teamSystemAgent.teamBondageChangeCall(bondageId, wrap_cb)
	end
end

function PageTeam:TeamFullReturnCall(callback)
	if self.teamSystemAgent and self.teamSystemAgent.teamFullReturnCall and self.teamAgent and self.teamAgent:FullUpCard() then
		self.teamSystemAgent.teamFullReturnCall(callback)

		return true
	else
		return false
	end
end

function PageTeam:OnClickedQuickTeamQuickTeam()
	self.maxCost = LevelManager:GetMaxCost(PlayerInst:GetCurLv())

	if self.teamSystemAgent.noTeamSumCost then
		self.maxCost = 9999
	end

	self.costSum = 0
	self.costSumFirst = true
	self.isOverCost = false
	self.listSimCardId = {
		0,
		0,
		0,
		0,
		0
	}
	self.listSimRoleId = {
		0,
		0,
		0,
		0,
		0
	}

	local temp = RoleCardMgr:GetAllHoldCard()
	local listCard = {}

	if self.teamSystemAgent.isRaid then
		for i = 1, #temp do
			local infoRoleCard = temp[i]
			local hp = infoRoleCard.curCommRaidHpPer or 0

			if hp ~= 0 then
				table.insert(listCard, infoRoleCard)
			end
		end
	elseif self.teamSystemAgent.isGvg then
		listCard = temp
	elseif self.teamSystemAgent.isTimespace then
		for i = 1, #temp do
			local infoRoleCard = temp[i]

			if InfoTeamgTS:CardVaild(infoRoleCard.id) then
				table.insert(listCard, infoRoleCard)
			end
		end
	else
		listCard = temp
	end

	if table.getn(listCard) == 0 then
		UIMgr.ShowMsg(_("Msg_Card_Meet_Condition_None_1"))

		return
	end

	local listC = {}

	for k, v in pairsByKeys(listCard) do
		local infoRole = RoleCardMgr:GetRole(v.id)

		v.attrsFightValue = RoleCardMgr:GetFightValue(infoRole, v)
	end

	self.listCard = listCard

	local list = {}

	list = self:DealSortPowerCounterActiveSkillLv(listCard)

	self:SetCommonSeat(1, list)
	self:SetCommonSeat(2, list)
	self:SetCommonSeat(3, list)
	self:SetCommonSeat(4, list)
	self:SetCommonSeat(5, list)

	if self.isOverCost then
		self.listSimCardId[4] = 0
		self.listSimRoleId[4] = 0
		self.costSum = self.tempCost

		self:DealOverCost(list)
	end

	local listSimAddCardId = {
		0,
		0,
		0,
		0,
		0
	}

	if not self.teamSystemAgent.noSupCard then
		local roleAddList = {
			{},
			{},
			{},
			{},
			{}
		}

		for i, card in ipairs(listCard) do
			if not self:IsInTable(card.id, self.listSimCardId) then
				for j, list in ipairs(roleAddList) do
					local cardId = self.listSimCardId[j]

					if cardId ~= 0 then
						local upCard = RoleCardMgr:GetRoleCard(cardId)

						if upCard.data.CharacterID ~= card.data.CharacterID then
							table.insert(list, card)
						end
					end
				end
			end
		end

		for i, list in ipairs(roleAddList) do
			table.sort(list, function(a, b)
				local aVal = math.floor(RoleCardMgr:GetFightValue(nil, nil, a))
				local bVal = math.floor(RoleCardMgr:GetFightValue(nil, nil, b))

				return bVal < aVal
			end)
		end

		local teampos = lev[PlayerInst:GetCurLv()].TeamPosition[1]

		for i, list in ipairs(roleAddList) do
			if self.teamSystemAgent.noLevelUnlockSup or i <= teampos - 5 then
				for j, card in ipairs(list) do
					if not self:IsInTable(card.id, listSimAddCardId) then
						local infoRole = RoleMgr:GetRole(card.data.CharacterID)
						local cost = RoleCardMgr:GetCardCost(card, infoRole, 2)
						local goingToCost = self.costSum + cost

						if goingToCost <= self.maxCost then
							listSimAddCardId[i] = card.id
							self.costSum = goingToCost

							break
						end
					end
				end
			end
		end
	end

	local isSame = true

	for i = 1, 5 do
		local upInfoRoleCard = self.teamAgent.slotList[i].upInfoRoleCard
		local upCardId = upInfoRoleCard and upInfoRoleCard.id or 0
		local addInfoRoleCard = self.teamAgent.slotList[i].addInfoRoleCard
		local addCardId = addInfoRoleCard and addInfoRoleCard.id or 0

		if upCardId ~= self.listSimCardId[i] or addCardId ~= listSimAddCardId[i] then
			isSame = false

			break
		end
	end

	if isSame then
		UIMgr.ShowMsg(_("Msg_TeamAutoSetFailed"))

		return
	else
		UIMgr.ShowMsg(_("Msg_TeamAutoSetSuccess"))
	end

	local function cb(...)
		for i = 1, 5 do
			local id = self.listSimCardId[i]

			if id == 0 then
				self.teamAgent.slotList[i]:ReplaceUpCard()
			else
				local infoRoleCard = RoleCardMgr:GetRoleCard(id)
				local infoRole = RoleCardMgr:GetRole(id)

				self.teamAgent.slotList[i]:ReplaceUpCard(infoRoleCard, infoRole)
			end

			id = listSimAddCardId[i]

			if id == 0 then
				self.teamAgent.slotList[i]:ReplaceAddCard()
			else
				infoRoleCard = RoleCardMgr:GetRoleCard(id)
				infoRole = RoleCardMgr:GetRole(id)

				self.teamAgent.slotList[i]:ReplaceAddCard(infoRoleCard, infoRole)
			end
		end

		self:UpdateTeamCards()
		self:UpdateTeamCost()
		self:UpdateTeamPower()
	end

	cb()
	self:TeamChangeCall(cb)
end

function PageTeam:DealOverCost(listCard)
	local slot4 = self.teamAgent.slotList[4]
	local slot5 = self.teamAgent.slotList[5]
	local remain = self.maxCost - self.costSum

	for i = self.tempIndex - 1, 1, -1 do
		local infoRoleCard = listCard[i]
		local cost4 = self:GetCardCost(infoRoleCard.id, 1)

		if slot4:LimitCheck(infoRoleCard) and table.getIndex(self.listSimRoleId, listCard[i].data.CharacterID) == -1 then
			for j = i - 1, 1, -1 do
				local role = listCard[j]

				if table.getIndex(self.listSimRoleId, listCard[j].data.CharacterID) == -1 and role.data.CharacterID ~= infoRoleCard.data.CharacterID then
					local cost5 = self:GetCardCost(role.id, 1)
					local sum = cost4 + cost5

					if sum <= remain then
						self.listSimCardId[4] = infoRoleCard.id
						self.listSimRoleId[4] = infoRoleCard.data.CharacterID
						self.listSimCardId[5] = role.id
						self.listSimRoleId[5] = role.data.CharacterID
						self.costSum = self.costSum + sum

						return
					end
				end
			end
		end
	end
end

function PageTeam:SortQuickTeamFunc(index)
	for i = 1, 5 do
		if not self.limitValueList[i] then
			self.listSimCardId[i] = 0
			self.listSimRoleId[i] = 0
		end
	end

	local isMax = false

	for i = 1, 5 do
		local slot = self.teamAgent.slotList[i]

		if not self.limitValueList[i] then
			for n = index, #self.sorTeamlist do
				self.costList[i] = self.sorTeamlist[n]

				local isSame = false

				for m = 1, #self.listSimRoleId do
					if self.listSimRoleId[m] == self.costList[i].data.CharacterID then
						isSame = true
					end
				end

				if not isSame and slot:LimitCheck(self.costList[i]) then
					curCardCost = self:GetCardCost(self.costList[i].id, 1)

					if self.maxCost >= self.costSum + curCardCost then
						self.listSimCardId[i] = self.costList[i].id
						self.listSimRoleId[i] = self.costList[i].data.CharacterID
						self.costSum = self.costSum + curCardCost

						break
					else
						isMax = true

						break
					end
				end
			end
		end
	end

	return isMax
end

function PageTeam:GetFightValue(infoCard)
	local initValue = infoCard.data.FightValue
	local levelValue = infoCard.curLevel > 0 and (infoCard.curLevel - 1) * infoCard.data.LevelValue or 0
	local starValue = infoCard.curStarLevel > 0 and infoCard.data.StarValue[infoCard.curStarLevel] or 0
	local flowerValue = infoCard.curPetal > 0 and infoCard.data.FlowerValue[infoCard.curPetal] or 0

	return initValue + levelValue + starValue + flowerValue
end

function PageTeam:IsInTable(value, tbl)
	for i, v in ipairs(tbl) do
		if v == value then
			return true
		end
	end

	return false
end

function PageTeam:GetCardCost(cardId, type)
	local infoRoleCard = RoleCardMgr:GetRoleCard(cardId)
	local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)

	return RoleCardMgr:GetCardCost(infoRoleCard, infoRole, type)
end

function PageTeam:SetCommonSeat(seatNum, listCard)
	local allNum = 0
	local overNum = 0

	for i = #listCard, 1, -1 do
		local infoRoleCard = listCard[i]
		local slot = self.teamAgent.slotList[seatNum]
		local gvgVaild = true

		if self.teamSystemAgent.isGvg then
			gvgVaild = Infogvg:CardVaild(infoRoleCard.id)
		end

		if slot:LimitCheck(infoRoleCard) and gvgVaild then
			local isHave = false

			for j = 1, 5 do
				if j ~= seatNum and self.listSimRoleId[j] == listCard[i].data.CharacterID then
					isHave = true

					break
				end
			end

			if not isHave then
				local sumCost = self.costSum + self:GetCardCost(infoRoleCard.id, 1)

				allNum = allNum + 1

				if sumCost <= self.maxCost then
					local info = listCard[i]

					self.listSimCardId[seatNum] = info.id
					self.listSimRoleId[seatNum] = info.data.CharacterID
					self.costSum = sumCost

					if seatNum == 3 then
						self.tempIndex = i
						self.tempCost = sumCost
					end

					break
				else
					overNum = overNum + 1

					if allNum == overNum then
						self.isOverCost = true
					end
				end
			end
		end
	end
end

function PageTeam:DealSortPowerCounter(list)
	local function func(a, b)
		return self:GetComparePowerCounter(a, b)
	end

	table.sort(list, func)

	return list
end

function PageTeam:GetComparePowerCounter(a, b)
	local counter1 = self:GetCounterRelation(a)
	local counter2 = self:GetCounterRelation(b)

	if not self.teamSystemAgent.recommendJob then
		counter1 = 1
		counter2 = 1
	end

	local valueA = a.attrsFightValue * counter1
	local valueB = b.attrsFightValue * counter2

	if valueA == valueB then
		return a.cardRank < b.cardRank
	else
		return valueA < valueB
	end
end

function PageTeam:GetCounterRelation(infoRoleCard)
	if self.teamSystemAgent.monsterJob then
		local infoRole = RoleCardMgr:GetRole(infoRoleCard.id)

		JobCheckingUtil.Init()

		local num = JobCheckingUtil.GetMul(infoRole.data.Job, self.teamSystemAgent.monsterJob)

		return num
	end

	return 0
end

function PageTeam:DealSortPowerCounterActiveSkillLv(list)
	local function func(a, b)
		return self:GetComparePowerCounterActiveSkillLv(a, b)
	end

	table.sort(list, func)

	return list
end

function PageTeam:GetComparePowerCounterActiveSkillLv(a, b, iscose)
	local pl1 = a:GetBattleSkillLevel(1)
	local pl2 = b:GetBattleSkillLevel(1)
	local counter1 = self:GetCounterRelation(a)
	local counter2 = self:GetCounterRelation(b)

	if not self.teamSystemAgent.recommendJob then
		counter1 = 1
		counter2 = 1
	end

	local valueA = a.attrsFightValue * counter1
	local valueB = b.attrsFightValue * counter2

	if iscose then
		if self:GetCardCost(a.id, 1) == self:GetCardCost(b.id, 1) then
			if valueA == valueB then
				if pl1 == pl2 then
					return a.cardRank < b.cardRank
				else
					return pl1 < pl2
				end
			else
				return valueA < valueB
			end
		else
			return self:GetCardCost(a.id, 1) < self:GetCardCost(b.id, 1)
		end
	elseif valueA == valueB then
		if pl1 == pl2 then
			return a.cardRank < b.cardRank
		else
			return pl1 < pl2
		end
	else
		return valueA < valueB
	end
end

function PageTeam:GetRoleCardValue(infoRole, infoRoleCard)
	return RoleCardMgr:GetFightValue(infoRole, infoRoleCard)
end

function PageTeam:SetCenterSeat(listC, listO)
	for i = 1, #listC do
		local infoRoleCard = listC[i]
		local slot = self.teamAgent.slotList[3]

		if slot:LimitCheck(infoRoleCard) then
			local curCardCost = self:GetCardCost(infoRoleCard.id, 1)

			if curCardCost > self.maxCost then
				break
			end

			local preCardId = self.listSimCardId[3]

			if preCardId ~= 0 then
				local preCardCost = self:GetCardCost(preCardId, 1)
				local curCostSum = self.costSum - preCardCost + curCardCost

				if curCostSum > self.maxCost then
					break
				end
			end

			self.costSum = 0

			local infoRoleCard = listC[i]

			self.listSimCardId[3] = infoRoleCard.id

			local roleId = infoRoleCard.data.CharacterID

			self.listSimRoleId[3] = roleId
			self.costSum = self.costSum + curCardCost

			local idx = 1

			for j = 1, #listO do
				local info = listO[j]
				local slot = self.teamAgent.slotList[idx]

				if slot:LimitCheck(info) then
					local roleId = info.data.CharacterID
					local isHave = false

					for k = 1, 5 do
						if k ~= idx and roleId == self.listSimRoleId[k] then
							isHave = true

							break
						end
					end

					if not isHave then
						idx = idx + 1

						if idx == 3 then
							idx = idx + 1
						end

						if idx > 5 then
							break
						end
					end
				end
			end

			if self.costSum > self.maxCost then
				break
			end
		end
	end
end

function PageTeam:OnBeginDragCard(data)
	if self.beginDragCard then
		self:DragReset()

		return
	end

	self.dragGo = data.pointerPressRaycast.gameObject

	if self.dragGo == nil then
		return
	end

	local isCardRoot = string.find(self.dragGo.name, "cardRoot_")

	if isCardRoot == nil then
		return
	end

	self.dragIndex = tonumber(string.sub(self.dragGo.name, 10))

	local upCard = self.teamAgent.slotList[self.dragIndex].upInfoRoleCard

	if upCard == nil then
		return
	end

	if self.teamAgent.slotList[self.dragIndex].limit and #self.teamAgent.slotList[self.dragIndex].limit ~= 0 and self.teamAgent.slotList[self.dragIndex].limit[1] == 2 then
		UIMgr.ShowMsg(_("Msg_Card_Change_Unable"))

		return
	end

	self.posBegin = data.position
	self.beginDragCard = true
	self.dragGoParent = self.dragGo.transform.parent
	self.dragSpineGoParent = self.tramCardSpines[self.dragIndex].UIRootObject.transform.parent
	self:GetChildComponent("TeamSpine/Slot" .. self.dragIndex, "Image").enabled = true
	self.uiEmpty = GOUtil.GetComponent(self.dragGo, "UIEmpty4Raycast")

	self.dragGo.transform:SetParent(self.TeamGoGrag.transform)
	self.tramCardSpines[self.dragIndex].UIRootObject.transform:SetParent(self.TeamGoGrag.transform)
	self.dragGo.transform:SetSiblingIndex(1)
	self.tramCardSpines[self.dragIndex].UIRootObject.transform:SetSiblingIndex(0)
	self.tramCardSpines[self.dragIndex]:IsSpineMove(true, self.dragIndex)

	self.uiEmpty.raycastTarget = false

	for i, card in ipairs(self.teamCards) do
		if i ~= self.dragIndex then
			card:RayCheck(true)
		end
	end
end

function PageTeam:OnDragCard(data)
	if not self.beginDragCard then
		return
	end

	local posX, posY, posZ = GOUtil.GetTransformLocalPosition(self.dragGo, x, y, z)
	local posCur = UIUtil.ScreenPointToLocalPoint(self.TeamGoGrag, data.position)
	local posPre = UIUtil.ScreenPointToLocalPoint(self.TeamGoGrag, self.posBegin)
	local posOff = posCur - posPre

	self.posBegin = data.position

	GOUtil.SetTransformLocalPosition(self.dragGo, posX + posOff.x, posY + posOff.y, posZ)

	posX, posY, posZ = GOUtil.GetTransformPosition(self.dragGo, x, y, z)

	GOUtil.SetTransformPosition(self.tramCardSpines[self.dragIndex].UIRootObject, posX, posY, posZ)
end

function PageTeam:OnEndDragCard(data)
	if not self.beginDragCard then
		return
	end

	local go = data.pointerCurrentRaycast.gameObject

	if go == nil or go.name ~= "CardRayCheck" then
		self:DragReset()

		return
	end

	local index = tonumber(string.sub(go.transform.parent.name, 10))

	self:DragReset()

	local msgId = self.teamAgent:ChangePos(self.dragIndex, index, self.teamSystemAgent.noLevelUnlockSup)

	if msgId == 0 then
		if self.teamAgent.slotList[index].upInfoRoleCard then
			local cardId = self.teamAgent.slotList[index].upInfoRoleCard.id

			if self.teamAgent.slotList[index].addInfoRoleCard and TeamSystemAgent.SameRole(self.teamAgent.slotList[index].addInfoRoleCard.id, cardId) then
				UIMgr.ShowMsg(_("DlgCommon_SameRoleCantAdd"))

				self.teamAgent.slotList[index].addInfoRoleCard = nil
			end
		end

		if self.teamAgent.slotList[self.dragIndex].upInfoRoleCard then
			local cardId = self.teamAgent.slotList[self.dragIndex].upInfoRoleCard.id

			if self.teamAgent.slotList[self.dragIndex].addInfoRoleCard and TeamSystemAgent.SameRole(self.teamAgent.slotList[self.dragIndex].addInfoRoleCard.id, cardId) then
				self.teamAgent.slotList[self.dragIndex].addInfoRoleCard = nil

				UIMgr.ShowMsg(_("DlgCommon_SameRoleCantAdd"))
			end
		end

		self:TeamChangeCall()
		self:UpdateTeamCards()
	else
		UIMgr.ShowMsg(_("Msg_ReplacementConditions"))
	end
end

function PageTeam:DragReset()
	self.beginDragCard = false

	self.dragGo.transform:SetParent(self.dragGoParent)
	self.dragGo.transform:SetSiblingIndex(0)

	self:GetChildComponent("TeamSpine/Slot" .. self.dragIndex, "Image").enabled = false

	self.tramCardSpines[self.dragIndex].UIRootObject.transform:SetParent(self.dragSpineGoParent)
	GOUtil.SetTransformLocalPosition(self.dragGo, 0, 0, 0)
	GOUtil.SetTransformLocalPosition(self.tramCardSpines[self.dragIndex].UIRootObject, 0, 0, 0)
	self.tramCardSpines[self.dragIndex]:IsSpineMove(false, self.dragIndex)

	self.uiEmpty.raycastTarget = true

	for i, card in ipairs(self.teamCards) do
		card:RayCheck(false)
	end

	SetActiveFunc(self.dragGo, true)
end

function PageTeam:OnPointerLongPressCard(data)
	if self.beginDragCard then
		return
	end

	local go = data.pointerPressRaycast.gameObject

	if go == nil then
		return
	end

	local isCardRoot = string.find(go.name, "cardRoot_")

	if isCardRoot == nil then
		return
	end

	local index = tonumber(string.sub(go.name, 10))
	local card = self.teamAgent.slotList[index].upInfoRoleCard

	if card == nil then
		return
	end

	if data.clickCount == 1 then
		if self.teamAgent.slotList[index].isHelperCard then
			return
		end

		if not self.GoDlgLongTip then
			self.GoDlgLongTip = GOUtil.InstantiatePrefab(self.DlgLongTip, go)
		end

		self.breakLongState = false
		self.LongPressState = true
		GOUtil.FindChildComponent(self.GoDlgLongTip, "BG/Bar", "UIDlgLongTip").onEndTween = function()
			local function func(...)
				self.LongPressState = false
			end

			if self.breakLongState then
				if not IsNil(self.GoDlgLongTip) then
					self.GoDlgLongTip:Destroy()
				end

				self.GoDlgLongTip = nil

				func()

				return
			end

			local list = {}

			for _, v in ipairs(self.teamAgent.slotList) do
				if v.upInfoRoleCard and not v.isHelperCard then
					table.insert(list, v.upInfoRoleCard)
				end
			end

			CardSwitchMgr:ResetCardIdsByBattle(list)
			UIMgr.SwitchPanel(PageRoleCard, {
				cardId = card.id,
				callback = func
			})
		end
	else
		self.breakLongState = true

		if not IsNil(self.GoDlgLongTip) then
			Object.Destroy(self.GoDlgLongTip)

			self.GoDlgLongTip = nil
		end

		if self.LongPressState then
			self.LongPressState = false

			return
		end

		if self.teamAgent.slotList[index].limit and #self.teamAgent.slotList[index].limit ~= 0 and self.teamAgent.slotList[index].limit[1] == 2 then
			UIMgr.ShowMsg(_("Msg_Card_Change_Unable"))

			return
		end

		local param = {}

		param.clickSlot = self.teamAgent.slotList[index]
		param.teamSystemAgent = self.teamSystemAgent
		param.infoStage = self.infoStage

		UIMgr.SwitchPanel(PageChooseRoleCard, param)
	end
end

function PageTeam:OnClickedCard(data)
	local go = data.pointerPress.transform.parent.gameObject
	local cardIdx = tonumber(string.sub(go.name, 10))

	if self.teamAgent.slotList[cardIdx].limit and #self.teamAgent.slotList[cardIdx].limit ~= 0 and self.teamAgent.slotList[cardIdx].limit[1] == 2 then
		UIMgr.ShowMsg(_("Msg_Card_Change_Unable"))

		return
	end

	local param = {}

	param.clickSlot = self.teamAgent.slotList[cardIdx]
	param.teamSystemAgent = self.teamSystemAgent
	param.infoStage = self.infoStage

	UIMgr.SwitchPanel(PageChooseRoleCard, param)
end

function PageTeam:RefreshCardHp()
	if self.teamSystemAgent.isRaid and self.teamCards then
		for i = 1, #self.teamCards do
			self.teamCards[i]:UpdateCardHp()
		end
	end
end

function PageTeam:OnClickedGuideBtn()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.SetTeam)
end

function PageTeam:SetEmptyCardAlpha()
	for i = 1, 5 do
		local slotAgent = self.teamAgent.slotList[i]

		if slotAgent.upInfoRoleCard == nil then
			local cardSlot = self:GetChildGameObject("TeamCard/Slot" .. i)

			if cardSlot ~= nil then
				UITweenUtil.SingleTween(cardSlot.transform, "y", 200, 0.2, true)
			end

			local spineSlot = self:GetChildGameObject("TeamSpine/Slot" .. i)

			if spineSlot ~= nil then
				UITweenUtil.SingleTween(spineSlot.transform, "y", 200, 0.2, true)
			end
		end
	end
end

function PageTeam:PlayCardAnim(index)
	if self.animList == nil then
		self.animList = {}
		self.nowNum = 0
		self.CanvasGroup.blocksRaycasts = false
	end

	if self.animList[index] then
		return
	end

	self.animList[index] = true
	self.nowNum = self.nowNum + 1

	if self.nowNum >= self.upNum then
		if self.timer1 ~= nil then
			TimerMgr.RemoveTimer(self.timer1)

			self.timer1 = nil
		end

		self.timer1 = TimerMgr.AddTimer(eTimerType.RealTime, 0.2, function()
			self.timer1 = nil
			self.CanvasGroup.blocksRaycasts = true
		end, nil)
	end

	local cardSlot = self:GetChildGameObject("TeamCard/Slot" .. index)

	if cardSlot ~= nil then
		UITweenUtil.SingleTween(cardSlot.transform, "y", 200, 0.2, true)
	end

	local spineSlot = self:GetChildGameObject("TeamSpine/Slot" .. index)

	if spineSlot ~= nil then
		UITweenUtil.SingleTween(spineSlot.transform, "y", 200, 0.2, true)
	end
end

function PageTeam:RemoveCardAnim()
	for i = 1, 5 do
		local cardSlot = self:GetChildGameObject("TeamCard/Slot" .. i)
		local spineSlot = self:GetChildGameObject("TeamSpine/Slot" .. i)

		if cardSlot ~= nil then
			UITweenUtil.RemoveTween(cardSlot.transform)
		end

		if spineSlot ~= nil then
			UITweenUtil.RemoveTween(spineSlot.transform)
		end
	end
end
