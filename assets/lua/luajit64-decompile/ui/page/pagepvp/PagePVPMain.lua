-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/pagePVP/PagePVPMain.lua

PagePVPMain = class("PagePVPMain", UIPanel)

local InfoPVPData = require("Info/InfoPVP")
local CONST_NUM_OF_TEAM = InfoPVPData.const_num_of_team
local CONST_HELP_NUM_OF_TEAM = InfoPVPData.const_help_num_of_team

function PagePVPMain:ctor()
	self.UIPrefabPath = "UI/PanelPVP/PanelPVPMain"

	self:AddChildPanel(DlgExit(), {
		title = _("eReturn_PVP"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo(), {
		x = -600,
		y = -42
	})
end

function PagePVPMain:Purge()
	PagePVPMain.base.Purge(self)
	UnloadAllImageSprite(self)

	if self.IsNeedDealUnload then
		RoleCardMgr:UnloadEffect()
	end
end

function PagePVPMain:OnBack()
	if self.Timer then
		TimerMgr.RemoveTimer(self.Timer)

		self.Timer = nil
	end

	UIMgr.PopPanel()
end

function PagePVPMain:OnEnter(vParam)
	InfoPVPData:SetInitTeam()

	if not GuideMgr:IsGuided(GuideFunctionType.PVP) then
		UIMgr.AddPanel(PGuide(), GuideFunctionType.PVP)
	end

	self.myGradeIcon = self:GetChildComponent("MyInfo/Grade/Icon", "Image")
	self.myGradeText = self:GetChildComponent("MyInfo/Grade/Text", "Text")
	self.bigSeasonProg = self:GetChildComponent("MyInfo/BigSeasonProg/Prog", "Text")
	self.remainCount = self:GetChildComponent("BattleInfo/Count", "Text")
	self.myPower = self:GetChildComponent("BattleInfo/Defender/Score", "Text")
	self.myRank = self:GetChildComponent("MyInfo/RankScore/Rank", "Text")
	self.nextGradeName = self:GetChildComponent("MyInfo/RankScore/GradeName", "Text")
	self.next = self:GetChildGameObject("MyInfo/RankScore/Next")
	self.nextGradeIcon = self:GetChildComponent("MyInfo/RankScore/GradeName/GradeIcon", "Image")
	self.nextMax = self:GetChildGameObject("MyInfo/RankScore/GradeNameMax")
	self.nextcur = self:GetChildGameObject("MyInfo/RankScore/GradeName")
	self.nextGradeProg = self:GetChildComponent("MyInfo/RankScore/Bar/Fill", "Image")
	self.myScore = self:GetChildComponent("MyInfo/RankScore/CurScore", "Text")
	self.seasonTime = self:GetChildComponent("BattleInfo/Title/Time", "Text")
	self.seasonTimeName = self:GetChildComponent("BattleInfo/Title/Text (4)", "Text")
	self.changeBattler = self:GetChildGameObject("BattleInfo/ChangeBattler")
	self.changeBattlerText = self:GetChildComponent("BattleInfo/ChangeBattler/Text (5)", "Text")
	self.attr1 = self:GetChildComponent("BattleInfo/Defender/Attr/content/1", "Text")
	self.attr2 = self:GetChildComponent("BattleInfo/Defender/Attr/content/2", "Text")
	self.txt_defenseTip = self:GetChildComponent("BattleInfo/Defender/txt_denfenseTip", "Text")
	self.txt_defenseTip.text = _("PVPDefenseTips")
	self.Mask = self:GetChildGameObject("Mask")
	self.NoRank = self:GetChildGameObject("MyInfo/RankScore/NoRank")
	self.cellBattlerList = {}

	for i = 1, 4 do
		local go = self:GetChildGameObject("BattleInfo/Content/" .. i)
		local cell = {}

		cell.level = GOUtil.FindChildComponent(go, "Level", "Text")
		cell.name = GOUtil.FindChildComponent(go, "Name", "Text")
		cell.head = GOUtil.FindChildComponent(go, "Head", "Image")
		cell.gradeIcon = GOUtil.FindChildComponent(go, "GradeIcon", "Image")
		cell.gradeText = GOUtil.FindChildComponent(go, "GradeText", "Text")
		cell.power = GOUtil.FindChildComponent(go, "PowerText", "Text")
		cell.rank = GOUtil.FindChildComponent(go, "RankText", "Text")
		cell.battleBtn = GOUtil.FindChildGameObject(go, "Button")

		local TextAuto

		TextAuto = GOUtil.FindChildComponent(go, "Button/Text", "Text")
		TextAuto.text = _("Btn_Fight")
		TextAuto = GOUtil.FindChildComponent(go, "Level (2)", "Text")
		TextAuto.text = _("Desc_FightingCapacity")
		TextAuto = GOUtil.FindChildComponent(go, "Level (3)", "Text")
		TextAuto.text = _("Desc_PvpRankList")
		cell.go = go

		table.insert(self.cellBattlerList, cell)
	end

	self.cellMyCardList = {}

	for i = 1, CONST_NUM_OF_TEAM do
		local go = self:GetChildGameObject("BattleInfo/Defender/Con/" .. i)
		local cell = {}

		cell.go = go
		cell.head = GOUtil.FindChildComponent(go, "CardIcon", "Image")
		cell.headFrame = GOUtil.FindChildComponent(go, "HeadFrame", "Image")
		cell.job = GOUtil.FindChildComponent(go, "Job", "Image")
		cell.eff = GOUtil.FindChildGameObject(go, "CardEffect")

		for b = 1, 5 do
			cell["ImageStarFrame" .. b] = GOUtil.FindChildGameObject(go, "StarLevel/Image" .. b)
			cell["ImageStar" .. b] = GOUtil.FindChildGameObject(go, "StarLevel/Star" .. b)
		end

		cell.level = GOUtil.FindChildComponent(go, "Level", "Text")

		table.insert(self.cellMyCardList, cell)
	end

	self.rankBtn = self:GetChildGameObject("FunInfo/Rank")
	self.shopBtn = self:GetChildGameObject("FunInfo/Shop")
	self.battleInfoBtn = self:GetChildGameObject("FunInfo/BattleInfo")
	self.rewardBtn = self:GetChildGameObject("FunInfo/Reward")
	self.Seasondata = vParam.season
	self.oppdata = InfoPVPData:GetOpponentsList(InfoPVPData.opponents)
	self.seasonTimeName.text = string.format(_("Desc_SubSessonName"), _("ecNum_" .. self.Seasondata.subSeasonNum)) .. ":"

	self:UpdateMyInfo()
	self:UpdateBattler(self.oppdata)
	self:UpdateTeam()
	self:OnUpdateSecond()
	print(vParam.seasonChange .. "----------------------seasonChange----------")

	if vParam.seasonChange ~= 0 and not InfoPVPData.isOpenSeasonChange then
		InfoPVPData.isOpenSeasonChange = true

		self:OpenSeasonChange(vParam)
	end

	if InfoPVPData:IsRankLevelUp() then
		self.Mask:SetActive(true)

		self.Timer = TimerMgr.AddTimer(eTimerType.RealTime, 0.5, function()
			require("UI/Page/pagePVP/DlgPVPRankUp")
			UIMgr.AddPanel(DlgPVPRankUp(), {
				callback = self.OpemRankUpReward
			})
			self.Mask:SetActive(false)
		end, {
			1
		})
	else
		self:OpemRankUpReward()
	end

	self:Localization()
end

function PagePVPMain:Localization()
	local TextAuto

	TextAuto = self:GetChildComponent("MyInfo/Title/Text", "Text")
	TextAuto.text = _("Desc_MyInfo")
	TextAuto = self:GetChildComponent("MyInfo/BigSeasonProg/Text (1)", "Text")
	TextAuto.text = _("Desc_SeasonProgress")
	TextAuto = self:GetChildComponent("MyInfo/RankScore/Text", "Text")
	TextAuto.text = _("Desc_CurrentRanking")
	TextAuto = self:GetChildComponent("MyInfo/RankScore/Next", "Text")
	TextAuto.text = _("Desc_Promotion")
	TextAuto = self:GetChildComponent("BattleInfo/Defender/Text (5)", "Text")
	TextAuto.text = _("Desc_DefenseTeam")
	TextAuto = self:GetChildComponent("BattleInfo/Defender/Text", "Text")
	TextAuto.text = _("Desc_DefenseAttribute")
	TextAuto = self:GetChildComponent("FunInfo/Rank/Text", "Text")
	TextAuto.text = _("Desc_RankList")
	TextAuto = self:GetChildComponent("FunInfo/Shop/Text", "Text")
	TextAuto.text = _("Desc_Shop")
	TextAuto = self:GetChildComponent("FunInfo/BattleInfo/Text", "Text")
	TextAuto.text = _("Desc_FightRecord")
	TextAuto = self:GetChildComponent("FunInfo/Reward/Text", "Text")
	TextAuto.text = _("PageChapter_Award")
	TextAuto = self:GetChildComponent("MyInfo/RankScore/GradeNameMax", "Text")
	TextAuto.text = _("Desc_PVPGradeMax")
	TextAuto = self:GetChildComponent("MyInfo/RankScore/NoRank", "Text")
	TextAuto.text = _("Desc_NoPVPRank")
end

function PagePVPMain:OnRegisterEvent()
	for i, v in ipairs(self.cellBattlerList) do
		self:AddClick(v.battleBtn, self.OnBattle)
		self:AddClick(v.go, self.OnShwoBattle)
	end

	for i, v in ipairs(self.cellMyCardList) do
		self:AddClick(v.go, self.OnTeam)
	end

	self:AddClick(self.changeBattler, self.OnChangeBattler)
	self:AddClick(self.rankBtn, self.OnRankBtn)
	self:AddClick(self.shopBtn, self.OnShopBtn)
	self:AddClick(self.battleInfoBtn, self.OnBattleInfoBtn)
	self:AddClick(self.rewardBtn, self.OnRewardBtn)
	self:AddClick(self.AddButton, self.OnClickBuyNumBtn)
	Event.Instance:Add("changeBattler", self.UpdateBattler, self)
	Event.Instance:Add("setTeamover", self.UpdateTeam, self)
	Event.Instance:Add("UpdateMonthCard", self.UpdateMyBattleCount, self)
end

function PagePVPMain:OnUnRegisterEvent()
	for i, v in ipairs(self.cellBattlerList) do
		self:RemoveClick(v.battleBtn, self.OnBattle)
		self:RemoveClick(v.go, self.OnShwoBattle)
	end

	for i, v in ipairs(self.cellMyCardList) do
		self:RemoveClick(v.go, self.OnTeam)
	end

	self:RemoveClick(self.changeBattler, self.OnChangeBattler)
	self:RemoveClick(self.rankBtn, self.OnRankBtn)
	self:RemoveClick(self.shopBtn, self.OnShopBtn)
	self:RemoveClick(self.battleInfoBtn, self.OnBattleInfoBtn)
	self:RemoveClick(self.rewardBtn, self.OnRewardBtn)
	self:RemoveClick(self.AddButton, self.OnClickBuyNumBtn)
	Event.Instance:Remove("changeBattler", self.UpdateBattler, self)
	Event.Instance:Remove("setTeamover", self.UpdateTeam, self)
	Event.Instance:Remove("UpdateMonthCard", self.UpdateMyBattleCount, self)
end

function PagePVPMain:OnUpdateSecond()
	if not self.Seasondata then
		return
	end

	local time = self.Seasondata.subSeasonEndTime - NetData:GetCurServerTime() / DateUtil.MillsPerSecond - 3600

	if time <= 0 then
		self:OnBack()
		Event.Instance:Fire("PVPAutoClose")
		UIMgr.ShowMsg(_("Desc_PVPClose"))
	else
		self.seasonTime.text = _("Desc_RemainingTime") .. GetStrDisTime(time)
	end
end

function PagePVPMain:UpdateMyInfo()
	self.bigSeasonProg.text = "<color=#29c4c4>" .. self.Seasondata.subSeasonNum .. "</color>/" .. InfoPVPData:GetSeasonConfigdata(self.Seasondata.seasonId).SubSeasonNum
	self.remainCount.text = _("Desc_LeftTimes") .. ":" .. "<color=#29c4c4>" .. InfoPVPData:GetDailyBattleNum(self.Seasondata.seasonId) - InfoPVPData.SelfPVPPlayerinfo.dailyBattleNumber .. "</color>/" .. InfoPVPData:GetDailyBattleNum(self.Seasondata.seasonId)
	self.changeBattlerText.text = "<color=#29c4c4>" .. self.Seasondata.player.opponentsRefreshNumber .. "</color>/" .. self.Seasondata.player.opponentsRefreshTotal
	self.myRank.text = InfoPVPData.SelfPVPPlayerinfo.subSeasonRankingNo
	self.myGradeText.text = _("Desc_CurrentGrade") .. InfoPVPData:GetNamebyscore(self.Seasondata.player.seasonRankingScore)

	UIUtil.SetImageSprite(self.myGradeIcon, string.gsub(InfoPVPData:GetIconNamebyscore(self.Seasondata.player.seasonRankingScore), "_s", ""), self)

	if self.Seasondata.player.subSeasonScore == 0 then
		self.myRank.text = "-"

		self.NoRank:SetActive(true)
	else
		self.NoRank:SetActive(false)
	end

	self.nextGradeName.text = InfoPVPData:GetNextNamebyscore(self.Seasondata.player.seasonRankingScore).name

	UIUtil.SetImageSprite(self.nextGradeIcon, string.gsub(InfoPVPData:GetNextIconbyscore(self.Seasondata.player.seasonRankingScore), "_s", ""), self)

	if InfoPVPData:GetNextNamebyscore(self.Seasondata.player.seasonRankingScore).max == 0 then
		self.nextcur:SetActive(true)
		self.next:SetActive(true)
		self.nextMax:SetActive(false)
	else
		self.nextcur:SetActive(false)
		self.next:SetActive(false)
		self.nextMax:SetActive(true)
	end

	local str1 = string.format(_("PvPDefense"), tostring(GetConfigArgFloat("PvPDefense")))
	local str2 = string.format(_("PVPThinking"), tostring(GetConfigArgJson("PVPThinking")[1]))

	self.attr1.text = str1
	self.attr2.text = str2
	self.nextGradeProg.fillAmount = InfoPVPData:GetCurrentvaluebyscore(self.Seasondata.player.seasonRankingScore)
	self.myScore.text = _("Desc_PVPNextRankScore") .. "<color=#29c4c4>" .. self.Seasondata.player.seasonRankingScore .. "</color>" .. "/" .. InfoPVPData:GetNextRankScorebyscore(self.Seasondata.player.seasonRankingScore)
	self.changeBattlerText.text = _("Desc_ChangeBatch") .. "<color=#29c4c4>" .. self.Seasondata.player.opponentsRefreshTotal - InfoPVPData:GetSeasondata().player.opponentsRefreshNumber .. "</color>/" .. self.Seasondata.player.opponentsRefreshTotal
end

function PagePVPMain:UpdateMyBattleCount()
	self.remainCount.text = _("Desc_LeftTimes") .. InfoPVPData:GetDailyBattleNum(self.Seasondata.seasonId) - InfoPVPData.SelfPVPPlayerinfo.dailyBattleNumber .. "/" .. InfoPVPData:GetDailyBattleNum(self.Seasondata.seasonId)
end

function PagePVPMain:UpdateBattler(oppdata)
	for i = 1, 4 do
		local data = oppdata[i]
		local cell = self.cellBattlerList[i]

		if data then
			GOUtil.SetActive(cell.go, true)

			cell.level.text = data.playerinfo.curLevel
			cell.name.text = data.playerinfo.name

			UIUtil.SetImageSprite(cell.head, data.playerinfo:GetTitleIcon(1), self)

			cell.gradeText.text = InfoPVPData:GetNamebyscore(data.seasonRankingScore)

			UIUtil.SetImageSprite(cell.gradeIcon, InfoPVPData:GetIconNamebyscore(data.seasonRankingScore), self)

			cell.power.text = InfoPVPData:GetAddRoleCard(oppdata[i])
			cell.rank.text = data.subSeasonRankingNo

			local imgBtn = GOUtil.GetComponent(cell.battleBtn, "Image")

			if InfoPVPData.SelfPVPPlayerinfo.dailyBattleNumber >= InfoPVPData:GetDailyBattleNum(self.Seasondata.seasonId) then
				DealWithListRef(self, UIUtil.SetImageGray(imgBtn, 1))
			end
		else
			GOUtil.SetActive(cell.go, false)
		end
	end
end

function PagePVPMain:UpdateTeam()
	for i = 1, CONST_NUM_OF_TEAM do
		local data = InfoPVPData:GetRocardtable(i)
		local cell = self.cellMyCardList[i]
		local infoRole = RoleMgr:GetRole(data.data.CharacterID)

		UIUtil.SetImageSprite(cell.head, data.data.HeadIcon, self)
		UIUtil.SetImageSprite(cell.headFrame, "UI/PanelPVP/AtlasMain/BG_card_block_" .. data.rank .. "_01", self)
		UIUtil.SetImageSprite(cell.job, "UIDyAtlas/RoleJob/ICO_" .. infoRole.data.Job .. "_01_S", self)

		if not self.IsNeedDealUnload and RoleCardMgr.ShowCardEffect(data) then
			RoleCardMgr:CreateEffect()

			self.IsNeedDealUnload = true
		end

		SetActiveFunc(cell.eff, RoleCardMgr.ShowCardEffect(data))
		RoleCardMgr:SetStarPanel(data, cell, self)

		cell.level.text = data.curLevel
	end

	local ids = {}

	for i = 1, CONST_NUM_OF_TEAM + CONST_HELP_NUM_OF_TEAM do
		local data = InfoPVPData:GetRocardtable(i)

		table.insert(ids, data)
	end

	self.myPower.text = _("Desc_DefenseFightingCapacity") .. InfoPVPData:GetMyAddRoleCard(ids)
end

function PagePVPMain:OnChangeBattler(data)
	local function pc(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code ~= 0 then
			UIMgr.ShowMsg(pb.result.desc, pb)

			return
		end

		local setter = SetterData.GetSetterData(pb.setter)

		setter:Parse()

		self.oppdata = InfoPVPData:GetOpponentsList(pb.opponents)

		self:UpdateBattler(self.oppdata)
		InfoPVPData:SetOtherPlayerData(pb.opponents)
		InfoPVPData:SetPVPBattleNum(pb.pvpBattleNum)
		InfoPVPData:SetPVPRefashNum(pb.pvpRefreshNum)

		self.changeBattlerText.text = _("Desc_ChangeBatch") .. "<color=#29c4c4>" .. self.Seasondata.player.opponentsRefreshTotal - InfoPVPData:GetSeasondata().player.opponentsRefreshNumber .. "</color>/" .. self.Seasondata.player.opponentsRefreshTotal
	end

	if InfoPVPData:GetSeasondata().player.opponentsRefreshNumber >= self.Seasondata.player.opponentsRefreshTotal then
		UIMgr.ShowMsg(_("PvPRefashNum"))

		return
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestRefashopponent(self.Seasondata.seasonId, self.Seasondata.subSeasonNum, pc)
end

function PagePVPMain:OnChangeBattlerSucess()
	return
end

function PagePVPMain:OnBattle(data)
	if self:IsEnd() then
		return
	end

	if InfoPVPData.SelfPVPPlayerinfo.dailyBattleNumber >= InfoPVPData:GetDailyBattleNum(self.Seasondata.seasonId) then
		UIMgr.ShowMsg(_("PvPbattleNum"))

		return
	end

	local go = data.pointerPress
	local cardIdx = tonumber(go.transform.parent.name)

	self:OpenPageTeam(cardIdx)
end

function PagePVPMain:OnTeam(data)
	if self:IsEnd() then
		return
	end

	self:OpenPageTeam(nil)
end

function PagePVPMain:OnShwoBattle(data)
	if self:IsEnd() then
		return
	end

	if InfoPVPData.SelfPVPPlayerinfo.dailyBattleNumber >= InfoPVPData:GetDailyBattleNum(self.Seasondata.seasonId) then
		UIMgr.ShowMsg(_("PvPbattleNum"))

		return
	end

	local go = data.pointerPress
	local cardIdx = tonumber(go.name)

	self:OpenPageTeam(cardIdx)
end

function PagePVPMain:OpenPageTeam(opponentIdx)
	if opponentIdx then
		local pb = self.oppdata[opponentIdx]

		InfoPVPData:SetTeamType(2)
		InfoPVPData:SetCurrentBatllePlayer(pb)

		local teamdata = InfoPVPData:CreateAgent(2)

		UIMgr.SwitchPanel(PageTeam, teamdata)
	else
		InfoPVPData:SetTeamType(1)

		local teamdata = InfoPVPData:CreateAgent(1)

		UIMgr.SwitchPanel(PageTeam, teamdata)
	end
end

function PagePVPMain:OnRankBtn(data)
	if self:IsEnd() then
		return
	end

	require("UI/Page/PageRank/PageRank")

	RankMgr.CurIndex = 3

	if not TutorialMgr:IsOpenNoMsg(TutorialFunctionType.PageRank) then
		return
	end

	UIMgr.SwitchPanel(PageRank, {})
end

function PagePVPMain:OnShopBtn(data)
	if self:IsEnd() then
		return
	end

	require("UI/Page/PageShop/PageShop")

	local data = {
		tagIndex = 4,
		tabMainIndex = tabMainType.exchange
	}

	PageShop.InitNetData(data)
end

function PagePVPMain:OnBattleInfoBtn(data)
	if self:IsEnd() then
		return
	end

	local function pc(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code ~= 0 then
			return
		end

		InfoPVPData:SetRecordData(pb)
		require("UI/Page/pagePVP/PagePVPRecord")
		UIMgr.AddPanel(PagePVPRecord())
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestPvPRecord(self.Seasondata.seasonId, self.Seasondata.subSeasonNum, pc)
end

function PagePVPMain:OnRewardBtn(data)
	if self:IsEnd() then
		return
	end

	require("UI/Page/pagePVP/PageRewardShow")
	UIMgr.AddPanel(PageRewardShow(), 2)
end

function PagePVPMain:OnClickBuyNumBtn()
	if InfoPVPData.SelfPVPPlayerinfo.dailyBattleNumber == 0 then
		UIMgr.ShowMsg(_("RaidBoss_Battle_Count_Max"))

		return
	end

	if InfoPVPData.SelfPVPPlayerinfo.dailyBuyNumber == GetConfigArgInt("PVPDailyNumBuyCost") then
		UIMgr.ShowMsg(_("Buy_Battle_Count_Limit"))

		return
	end

	local costList = GetConfigArgJson("PVPDailyNumBuyCost")
	local costItemId = costList[1][2]
	local costItemCount = costList[1][3]

	for i = 1, #costList do
		if InfoPVPData.SelfPVPPlayerinfo.dailyBuyNumber + 1 >= costList[i][1] then
			costItemId = costList[i][2]
			costItemCount = costList[i][3]
		end
	end

	local str = string.format(_("RaidBoss_Buy_Battle_Count"), costItemCount)

	local function vCallBack(index)
		if index == 1 then
			if PlayerInst:GetDiamondAll() < costItemCount then
				UIMgr.ShowMsg(_("Desc_DrawCardNotEnoughRes"))

				return
			end

			InfoPVPData:RequestBuyBattleNum(function()
				self:UpdateMyBattleCount()
			end)
		end
	end

	local function showTip()
		UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), str, vCallBack)
	end

	CheckPayDiamond(costItemCount, str, vCallBack, showTip)
end

function PagePVPMain:IsEnd()
	local InfoPVP = require("Info/InfoPVP")
	local time = InfoPVP.PBPVPSeason.subSeasonEndTime - NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local endtiem = GetConfigArgInt("PVPSettleSeconds")
	local curtime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	if time <= endtiem or tonumber(curtime) < tonumber(InfoPVP:GetSeasondata().subSeasonBeginTime) then
		UIMgr.ShowMsg(_("PvPSeason"))
		UIMgr.PopPanel()
		self:Close()

		return true
	end

	return false
end

function PagePVPMain:OpemRankUpReward()
	if InfoPVPData.newHigherRank then
		InfoPVPData.newHigherRank = false

		require("UI/Page/pagePVP/DlgRankUpReward")
		UIMgr.AddPanel(DlgRankUpReward())
	end
end

function PagePVPMain:OpenSeasonChange(data)
	require("UI/Page/pagePVP/DlgPVPSeasonChange")
	UIMgr.AddPanel(DlgPVPSeasonChange(), data)
end

function PagePVPMain:OnClickedGuideBtn()
	UIMgr.AddPanel(PGuide(), GuideFunctionType.PVP)
end
