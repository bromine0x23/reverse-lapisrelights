-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCombatReadiness/PageCombatReadiness.lua

require("UI/Page/PageCombatReadiness/CellMonster")
require("UI/Page/PageCombatReadiness/CellSpecifyCondition")
require("UI/Page/PageCombatReadiness/CellCardAddition")
require("UI/Page/PageCombatReadiness/DlgMayFall")
require("UI/Page/PageCombatReadiness/DlgForecast")
require("UI/Page/PageUnionRaid/DlgRaidAwardRecord")
require("UI/Page/PageActivityBossRaid/CellBossRaidDamage")

local InfoTeam = require("Info/InfoTeam")
local InfoTeamRaid = require("Info/InfoTeamRaid")
local InfoTeamBossRaid = require("Info/InfoTeamBossRaid")
local InfoTeamgGroup = require("Info/InfoTeamgGroup")
local skillTip = require("UI/Dlg/Common/SkillTipDesc")
local battleStageData = require("luaData/BattleStage")
local SceneData = require("luaData/SceneData")

require("UI/Page/PageCombatReadiness/PageCombatReadinessJP")

PageCombatReadiness = class("PageCombatReadiness", UIPanel)

function PageCombatReadiness:ctor()
	self.UIPrefabPath = "UI/PanelCombatReadiness/PanelCombatReadiness"

	if ChapterMgr.PageCombatReadinessType == 2 then
		self.UIPrefabPath = "UI/PanelCombatReadiness/PanelCombatReadinessSmall"
		self.isSmall = true
	end

	ChapterMgr.PageCombatReadinessType = 0
	self.closeCb = nil
	self.jpPageCombatReadiness = PageCombatReadinessJP(self)
end

function PageCombatReadiness:PreLoad()
	self:LoadResAsync("UI/PanelCombatReadiness/CellMonster", "PrefabMonster")
	self:LoadResAsync("UI/PanelCombatReadiness/CellSpecifyCondition", "PrefabSpecifyCondition")
	self:LoadResAsync("UI/PanelCombatReadiness/CellCardAddition", "PrefabCellCardAddition")
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
	self:LoadResAsync("UI/PanelCombatReadiness/CellDamage", "PrefabCellBossRaidDamage")
end

function PageCombatReadiness:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabMonster)
	ResourceMgr.Unload(self.PrefabCellBossRaidDamage)
	ResourceMgr.Unload(self.PrefabSpecifyCondition)
	ResourceMgr.Unload(self.PrefabCellCardAddition)
	ResourceMgr.Unload(self.PrefabCellItem)

	ChapterMgr.PageCombatReadinessType = 1

	UnloadAllImageSprite(self)

	self.closeCb = nil

	self:OnLeave()
end

function PageCombatReadiness:OnLeave()
	if self.UIScrollTool then
		self.UIScrollTool:Purge()

		self.UIScrollTool = nil
	end

	if self.listCellItem then
		for i = 1, #self.listCellItem do
			self.listCellItem[i]:OnLeave()
		end
	end

	if self.listCellLimit then
		for i = 1, #self.listCellLimit do
			self.listCellLimit[i]:OnLeave()
		end
	end

	if self.listCellAddLimit then
		for i = 1, #self.listCellAddLimit do
			self.listCellAddLimit[i]:OnLeave()
		end
	end

	if self.listCellEnemy then
		for i = 1, #self.listCellEnemy do
			self.listCellEnemy[i]:OnLeave()
		end
	end

	if self.listCellDamage then
		for i = 1, #self.listCellDamage do
			self.listCellDamage[i]:OnLeave()
		end
	end

	InfoSoundEventMgr:OnBack()
end

function PageCombatReadiness:OnRegisterEvent()
	self:AddClick(self.GoAdditional, self.OnClickedGoAdditional)
	self:AddClick(self.GoBossKill, self.OnClickedGoBossKill)
	self:AddClick(self.BtnDetail, self.OnClickedBtnDetail)
	self:AddClick(self.BtnSweep, self.OnClickedBtnSweep)
	self:AddClick(self.BtnShared, self.OnClickedSharedBtn)
	self:AddClick(self.BtnChallenge, self.OnClickedBtnChallenge)
	self:AddClick(self.BtnL, self.OnClickedBtnLeft)
	self:AddClick(self.BtnR, self.OnClickedBtnRight)
	self:AddClick(self.BtnClose, self.OnClickedBtnClose)
	self:AddClick(self.Btn_limit_close, self.OnClickedStageLimitHide)
	self:AddClick(self.Btn_limit, self.OnClickedStageLimitShow)
	self:AddListener(self.GoStarBox, self.OnLongPressStarBox, EventTriggerType.PointerLongPress)
	Event.Instance:Add("UpdateStage", self.UpdateStage, self)
	Event.Instance:Add("UpdateRaidSystem", self.UpdateRaidSystem, self)
	Event.Instance:Add("NotifyPanelLoaded", self.NotifyPanelLoaded, self)
end

function PageCombatReadiness:OnUnRegisterEvent()
	self:RemoveClick(self.GoAdditional, self.OnClickedGoAdditional)
	self:RemoveClick(self.GoBossKill, self.OnClickedGoBossKill)
	self:RemoveClick(self.BtnDetail, self.OnClickedBtnDetail)
	self:RemoveClick(self.BtnSweep, self.OnClickedBtnSweep)
	self:RemoveClick(self.BtnShared, self.OnClickedSharedBtn)
	self:RemoveClick(self.BtnChallenge, self.OnClickedBtnChallenge)
	self:RemoveClick(self.BtnL, self.OnClickedBtnLeft)
	self:RemoveClick(self.BtnR, self.OnClickedBtnRight)
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)
	self:RemoveClick(self.Btn_limit_close, self.OnClickedStageLimitHide)
	self:RemoveClick(self.Btn_limit, self.OnClickedStageLimitShow)
	self:RemoveListener(self.GoStarBox, self.OnLongPressStarBox, EventTriggerType.PointerLongPress)
	Event.Instance:Remove("UpdateStage", self.UpdateStage, self)
	Event.Instance:Remove("UpdateRaidSystem", self.UpdateRaidSystem, self)
	Event.Instance:Remove("NotifyPanelLoaded", self.NotifyPanelLoaded, self)

	if self.listGoSkill then
		for i = 1, #self.listGoSkill do
			self:RemoveClick(self.listGoSkill[i], self.OnPressStageSkillDown)
		end
	end

	if self.listCellAddLimit then
		for i = 1, #self.listCellAddLimit do
			self:RemoveClick(self.listCellAddLimit[i].UIRootObject, self.OnPressInsideStageSkillDown)
		end
	end

	if self.chapterType == ChapterFromType.union and self.stageType == StageFromType.unionBoss then
		self:RemoveClick(self.BtnRaidRank, self.OnClickBtnRaidRank)
	end
end

function PageCombatReadiness:NotifyPanelLoaded(panelName)
	if panelName == "PageTeam" then
		self:Close()
	end
end

function PageCombatReadiness:OnEnter(vParam)
	SetActiveFunc(self.UIRootObject, not ChapterMgr.IsForecastState)
	self:DealWithLocalization()

	self.ImgStageIcon = self:GetChildComponent("Panel/Stage", "Image")
	self.TxtStageName = self:GetChildComponent("Panel/Stage/TxtName", "Text")
	self.BgName = self:GetChildGameObject("Panel/Stage/BgName")
	self.GoCondtion = self:GetChildGameObject("Panel/StageReach/CondtionGroup")
	self.GoStarBox = self:GetChildGameObject("Panel/StageReach/CondtionGroup/StarBox")
	self.GoStarGroup = self:GetChildGameObject("Panel/StarGroup")
	self.GoStar = self:GetChildGameObject("Panel/Star")
	self.GoStageDrop = self:GetChildGameObject("Panel/StageDrop")
	self.GoBossRaidDrop = self:GetChildGameObject("Panel/BossRaidDrop")
	self.GoHigh = self:GetChildGameObject("Panel/StageDrop/GoHigh")
	self.GoAwardBg = self:GetChildGameObject("Panel/StarGroup/AwardBg")
	self.GoAdditional = self:GetChildGameObject("Panel/StarGroup/AdditionalAward")
	self.GoMax = self:GetChildGameObject("Panel/StarGroup/AdditionalAward/TextMax")
	self.GoBossKill = self:GetChildGameObject("Panel/StageDrop/BossKillAward")
	self.GoPower = self:GetChildGameObject("Panel/Power")
	self.BtnDetail = self:GetChildGameObject("Panel/Power/BtnDetail")
	self.GoGroup = self:GetChildGameObject("Panel/Begin/Group")
	self.GoChallengeNum = self:GetChildGameObject("Panel/Begin/ChallengeNum")
	self.BtnSweep = self:GetChildGameObject("Panel/Begin/Group/BtnSweep")
	self.ImgBtnSweep = GOUtil.GetComponent(self.BtnSweep, "Image")
	self.BtnChallenge = self:GetChildGameObject("Panel/Begin/Group/BtnChallenge")
	self.ImgBtnChallenge = GOUtil.GetComponent(self.BtnChallenge, "Image")
	self.BtnShared = self:GetChildGameObject("Panel/Begin/Group/BtnShared")
	self.BattleTip = self:GetChildComponent("Panel/Begin/BattleTip", "Text")
	self.GoMonsters = self:GetChildGameObject("Panel/Monsters")
	self.GoBoss = self:GetChildGameObject("Panel/GuildBoss")
	self.GoRaidBoss = self:GetChildGameObject("Panel/BossRaidBoss")
	self.GoBuffGroup = self:GetChildGameObject("Panel/SkillBuffGroup")
	self.GoArrow = self:GetChildGameObject("Arrow")
	self.BtnL = self:GetChildGameObject("Arrow/BtnLeft")
	self.BtnR = self:GetChildGameObject("Arrow/BtnRight")
	self.BtnClose = self:GetChildGameObject("Panel/BtnClose")
	self.Btn_limit_close = self:GetChildGameObject("Panel/StageLimit/Btn_close")
	self.Btn_limit = self:GetChildGameObject("Panel/Stage/Btn_limit")
	self.StageLimit = self:GetChildGameObject("Panel/StageLimit")
	self.DamageList = self:GetChildGameObject("Panel/DamageList")
	self.DamageEmpty = self:GetChildGameObject("Panel/DamageList/Empty")
	self.DamageLine = self:GetChildGameObject("Panel/DamageList/Line")
	self.TextRewardTitle = self:GetChildComponent("Panel/StageDrop/Title/Text", "Text")
	self.TextRewardTitle.text = _("Desc_Drop_May")
	self.TxtStageName.fontSize = 38

	self:InitData(vParam)
end

function PageCombatReadiness:DealWithLocalization()
	Text = self:GetChildComponent("Panel/StarGroup/AdditionalAward/TextMax", "Text")
	Text.text = _("Desc_CombatReadiness_BoxMax")
	Text = self:GetChildComponent("Panel/StarGroup/AdditionalAward/Text", "Text")
	Text.text = _("Desc_CombatReadiness_ExtraDrop")
	Text = self:GetChildComponent("Panel/StarGroup/AwardBg/Title/Text", "Text")
	Text.text = _("Desc_RewardBossBox")
	Text = self:GetChildComponent("Panel/StageDrop/BossKillAward/Text", "Text")
	Text.text = _("Desc_CombatReadiness_KillReward")
	Text = self:GetChildComponent("Panel/Power/Image1/Text", "Text")
	Text.text = string.format(_("Desc_CombatReadiness_RecommendFightingCapacity"), "")
	Text = self:GetChildComponent("Panel/Power/Image2/Text", "Text")
	Text.text = _("Desc_CombatReadiness_EstimateSituation")
	Text = self:GetChildComponent("Panel/StarGroup/Title/Text", "Text")
	Text.text = _("Desc_CombatReadiness_StarReward")
	Text = self:GetChildComponent("Panel/Begin/Group/BtnSweep/Text", "Text")
	Text.text = _("Btn_Sweep")
	Text = self:GetChildComponent("Panel/Begin/Group/BtnShared/Text", "Text")
	Text.text = _("Desc_Shared")

	GOUtil.SetFont(Text, UIMgr.JPFonts.YukiB)

	Text.fontSize = 40
	Text = self:GetChildComponent("Panel/Begin/Group/BtnChallenge/Text", "Text")
	Text.text = _("Btn_Fight")
	Text = self:GetChildComponent("Panel/StageLimit/BG/Image/ScrollArea/Viewport/Content/Panel2/Title/Text", "Text")
	Text.text = _("Desc_SkillBuff")
	Text = self:GetChildComponent("Panel/Power/BtnDetail/Text", "Text")
	Text.text = Lang(5000054)
end

local function GetStageIdx(list, stageId)
	for i = 1, #list do
		if stageId == list[i].id then
			return i
		end
	end

	return 1
end

function PageCombatReadiness:InitData(vParam)
	vParam = Tenary(vParam, {})
	self.stageId = vParam.stageId
	self.needItem = vParam.needItem
	self.sumLeftNum = vParam.sumLeftNum
	self.bossliveCurIndex = vParam.bossliveCurIndex
	self.damage = vParam.Damage
	self.totalDamage = vParam.totalHarm
	self.raidBossInfo = vParam.raidBossInfo
	self.isSyntherize = vParam.isSyntherize
	self.closeCb = vParam.panelCb

	local stage = ChapterMgr:GetStage(vParam.stageId)

	self.jpPageCombatReadiness:InitData(vParam, stage)
	self.jpPageCombatReadiness:Debug()

	if stage.data.ChapterType ~= ChapterFromType.union and stage.data.ChapterType ~= ChapterFromType.bossRaid then
		local infoChapter = ChapterMgr:GetChapter(stage.data.ChapterID)
		local list = infoChapter.listStage

		self.listChangeStage = {}

		local plv = PlayerInst.InfoPlayer.curLevel

		for _, info in ipairs(infoChapter.listStage) do
			if info and info:IsOpen() and info.data.Type ~= StageFromType.story and plv >= info.data.LevelUnlock then
				table.insert(self.listChangeStage, info)
			end
		end
	elseif stage.data.Type == StageFromType.unionBoss then
		self.listChangeStage = {}

		for i = 1, #UnionRaidMgr.listBossRaid do
			local stageId = UnionRaidMgr.listBossRaid[i].data.BossStage
			local infoStage = ChapterMgr:GetStage(stageId)

			table.insert(self.listChangeStage, infoStage)
		end

		self:InitUnionBossRaid()
	end

	self:RefreshStage()
end

function PageCombatReadiness:InitUnionBossRaid()
	self.selectRaidIdx = 1

	local go = self:GetChildGameObject("Panel/UnionBossRaid")

	GOUtil.SetActive(go, true)

	local group = self:GetChildGameObject("Panel/UnionBossRaid/UnionBossRaidTab")
	local obj = self:GetChildGameObject("Panel/UnionBossRaid/UnionBossRaidTab/1")

	for i = 1, #UnionRaidMgr.listBossRaid do
		if i ~= 1 then
			obj = GOUtil.InstantiateUI(obj, group)
			obj.name = i
		end

		self["SelTab" .. i] = GOUtil.FindChildGameObject(obj, "Sel")
	end

	local x, y, z = GOUtil.GetTransformLocalPosition(self.GoGroup, x, y, z)

	GOUtil.SetTransformLocalPosition(self.GoGroup, x, y + 35, z)

	self.GoUnionBossRaidLock = self:GetChildGameObject("Panel/UnionBossRaid/UnionBossRaidLock")
	self.TextPrompt = GOUtil.FindChildComponent(self.GoUnionBossRaidLock, "TextPrompt", "Text")
	self.GoUnionBossRaidContribute = self:GetChildGameObject("Panel/UnionBossRaid/UnionBossRaidContribute")
	self.TextContribute = GOUtil.FindChildComponent(self.GoUnionBossRaidContribute, "Text", "Text")
	self.GoUnionBossRaidBreak = self:GetChildGameObject("Panel/UnionBossRaid/UnionBossRaidBreak")
	self.BtnRaidRank = self:GetChildGameObject("Panel/UnionBossRaid/BtnRaidRank")

	self:AddClick(self.BtnRaidRank, self.OnClickBtnRaidRank)

	local txt = GOUtil.FindChildComponent(self.GoUnionBossRaidBreak, "Text", "Text")

	txt.text = _("Desc_Pass_Boss_Raid")
	txt = GOUtil.FindChildComponent(self.BtnRaidRank, "Text", "Text")
	txt.text = _("Tip_Mirror_Report")
end

function PageCombatReadiness:UpdateUnionBossRaid()
	local raid = UnionRaidMgr.listBossRaid[self.selectRaidIdx]
	local isOpen, msg = UnionRaidMgr.IsBossOpenOfFloor(self.selectRaidIdx)

	self.TextPrompt.text = msg

	local isFinish = isOpen and raid:IsFinished()

	GOUtil.SetActive(self.GoChallengeNum, isOpen and not isFinish)
	GOUtil.SetActive(self.GoGroup, isOpen and not isFinish)
	GOUtil.SetActive(self.GoUnionBossRaidLock, not isOpen)
	GOUtil.SetActive(self.GoUnionBossRaidContribute, isOpen and not isFinish)
	GOUtil.SetActive(self.GoUnionBossRaidBreak, isFinish)
	GOUtil.SetActive(self.BtnRaidRank, isOpen)

	self.TextContribute.text = raid.data.ContributionOfBattle or 3

	if self.preSelectRaidIdx then
		GOUtil.SetActive(self["SelTab" .. self.preSelectRaidIdx], false)
		GOUtil.SetActive(self["SelTab" .. self.selectRaidIdx], true)
	else
		GOUtil.SetActive(self["SelTab" .. self.selectRaidIdx], true)
	end

	self.preSelectRaidIdx = self.selectRaidIdx
end

function PageCombatReadiness:OnClickBtnRaidRank()
	if not UnionMgr.HasUnion(true) then
		return
	end

	require("UI/Page/PageUnionRaid/PageUnionBossRaidHarmRank")
	UIMgr.SwitchPanel(PageUnionBossRaidHarmRank, self.selectRaidIdx)
	self:Close()
end

function PageCombatReadiness:RefreshStage()
	self.infoStage = ChapterMgr:GetStage(self.stageId)
	self.stageType = self.infoStage.data.Type
	self.chapterType = self.infoStage.data.ChapterType

	if self.stageType == StageFromType.unionBoss then
		self.selectRaidIdx = GetStageIdx(self.listChangeStage, self.stageId)
	end

	self:UpdatePanel()

	local infoTeam = InfoTeam

	if chapterType == ChapterFromType.comb then
		infoTeam = InfoTeamgGroup
	elseif chapterType == ChapterFromType.union then
		if stageType == StageFromType.unionBoss then
			infoTeam = InfoTeamBossRaid
		else
			infoTeam = InfoTeamRaid
		end
	end

	if not infoTeam.teamSystemAgent and infoTeam.EnterStage then
		infoTeam:EnterStage(self.infoStage)
	end
end

function PageCombatReadiness:UpdatePanel()
	if self.chapterType == ChapterFromType.main then
		local _, cIdx, sIdx = ChapterMgr:GetChapterByStageID(self.stageId)

		self.TxtStageName.text = cIdx .. "-" .. sIdx .. " " .. Lang(self.infoStage.data.Name)

		if battleStageData[self.stageId] then
			local mainSceneId = battleStageData[self.stageId].MainSceneId

			SetImageSprite(self.ImgStageIcon, SceneData[mainSceneId].BattleUIicon, self)
		end
	elseif self.chapterType == ChapterFromType.bossRaid then
		self.TxtStageName.text = ""

		self.BgName:SetActive(false)
	else
		self.TxtStageName.text = Lang(self.infoStage.data.Name)

		if self.chapterType == ChapterFromType.union and self.stageType == StageFromType.unionBoss then
			self:UpdateUnionBossRaid()
		end
	end

	self:InitTeam()
	self:UpdateChallengePanel()
	self:UpdateLimitPanel()
	self:UpdateRewardPanel()
	self:UpdateMonsterPanel()
	self:UpdatePowerPanel()
	self:UpdateStageSkillPanel()
	self:UpdateDamagePanel()
	self:UpdateBeginPanel()
	self:UpdateChangeArrow()

	if ChapterMgr.IsForecastState then
		local function closeFunc(...)
			self:Purge()
		end

		UIMgr.AddPanel(DlgForecast(), {
			infoStage = self.infoStage,
			listRoleCardId = self.listCardId,
			listAddCardId = self.listAddCardId,
			teamCE = self.teamCE,
			forecastImagePath = self.forecastImagePath,
			closeFunc = closeFunc
		})

		ChapterMgr.IsForecastState = nil
	end
end

function PageCombatReadiness:UpdateChallengePanel()
	if self.chapterType == ChapterFromType.bossRaid then
		local StageReach = self:GetChildGameObject("Panel/StageReach")

		StageReach:SetActive(false)
		self.GoStarGroup:SetActive(false)
		self.GoStar:SetActive(false)

		return
	end

	local haveCon = self.infoStage:HaveStarCon()

	self.GoCondtion:SetActive(haveCon)

	local textTitle = self:GetChildComponent("Panel/StageReach/Title/Text", "Text")

	if haveCon then
		local star = self.infoStage.pb.stars
		local starNum = 0

		for i = 1, 3 do
			if star[i] == 1 then
				starNum = starNum + 1
			end
		end

		for i = 1, 3 do
			local goStar = self:GetChildGameObject("Panel/StageReach/CondtionGroup/StarBox/" .. i .. "/Star")

			goStar = self:GetChildGameObject("Panel/Star/Star" .. i)

			local txtCon = self:GetChildComponent("Panel/StageReach/CondtionGroup/Condtion" .. i .. "/Text", "Text")

			goStar:SetActive(i <= starNum)

			local img_recv = self:GetChildGameObject("Panel/StageReach/CondtionGroup/Condtion" .. i .. "/img_recv")

			img_recv:SetActive(star[i] == 1)
			ChapterMgr:SetStageAch(self.infoStage.data.Grade[i], txtCon)
		end

		self:SetSatrTip(starNum)

		textTitle.text = _("Desc_CombatReadiness_ChallengeGoal")
	else
		textTitle.text = _("Stage_Description")
	end
end

function PageCombatReadiness:SetSatrTip(starNum)
	self.listCellItem = {}

	for i = 1, 3 do
		local ImgFinish = self:GetChildGameObject("Panel/StarGroup/" .. i .. "/ImgFinish")

		ImgFinish:SetActive(i <= starNum)

		local cell = self:GetChildGameObject("Panel/StarGroup/" .. i .. "/CellItem")
		local item = CellItem(cell)

		item:InitItemByRoot(cell)

		local reward = self.infoStage:GetStarAward(i)

		if table.getn(reward) ~= 0 then
			local info = ItemManager:GetValueItem(reward[1][1], reward[1][2])

			item:UpdateWithNumType(info)
			item:SetGray(i <= starNum)
		end

		table.insert(self.listCellItem, item)
	end
end

function PageCombatReadiness:UpdateLimitPanel()
	if not self.isSmall then
		-- block empty
	end

	local isLimit = self.infoStage:IsLimit() or #OperationActiveMgr:GetAllSkillDataInside(self.stageId) > 0

	self.Btn_limit:SetActive(isLimit)

	if isLimit then
		local count = 0

		if #self.infoStage.data.LimitList > 0 then
			count = count + 1

			self:GetChildGameObject("Panel/StageLimit/BG/Image/ScrollArea/Viewport/Content/Panel1"):SetActive(true)

			local scrollArea = self:GetChildGameObject("Panel/StageLimit/BG/Image/ScrollArea/Viewport/Content/Panel1/CardScroll")
			local scrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")

			scrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "RectTransform")
			scrollView.horizontal = false
			scrollView.vertical = false

			GOUtil.DestroyAllChildren(scrollView.content.gameObject)

			local listLimit = self.infoStage.data.LimitList

			self.listCellLimit = {}

			for i = 1, #listLimit do
				local cell = CellSpecifyCondition(self.PrefabSpecifyCondition, scrollView.content.gameObject, self)

				cell:Create()
				cell:UpdateData(listLimit[i], i)
				table.insert(self.listCellLimit, cell)
			end
		else
			self:GetChildGameObject("Panel/StageLimit/BG/Image/ScrollArea/Viewport/Content/Panel1"):SetActive(false)
		end

		local skillList = OperationActiveMgr:GetAllSkillDataInside(self.stageId)

		if #skillList > 0 then
			count = count + 1

			self:GetChildGameObject("Panel/StageLimit/BG/Image/ScrollArea/Viewport/Content/Panel2"):SetActive(true)

			local scrollArea = self:GetChildGameObject("Panel/StageLimit/BG/Image/ScrollArea/Viewport/Content/Panel2/CardScroll")
			local scrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")

			scrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "RectTransform")

			if #skillList > 5 then
				scrollView.horizontal = true
			else
				scrollView.horizontal = false
			end

			scrollView.vertical = false

			GOUtil.DestroyAllChildren(scrollView.content.gameObject)

			self.listCellAddLimit = {}

			for i = 1, #skillList do
				local cell = CellCardAddition(self.PrefabCellCardAddition, scrollView.content.gameObject, self)

				cell:Create()
				cell:UpdateData(skillList[i], i)

				cell.UIRootObject.name = i

				table.insert(self.listCellAddLimit, cell)
				self:AddClick(cell.UIRootObject, self.OnPressInsideStageSkillDown)
			end
		else
			self:GetChildGameObject("Panel/StageLimit/BG/Image/ScrollArea/Viewport/Content/Panel2"):SetActive(false)
		end

		local Image = self:GetChildGameObject("Panel/StageLimit/BG/Image")

		if count == 1 then
			GOUtil.SetRectTransformSizeDelta(Image, 1060, 390)
		else
			GOUtil.SetRectTransformSizeDelta(Image, 1060, 665)
		end
	end
end

function PageCombatReadiness:OnPressInsideStageSkillDown(data)
	local go = data.pointerPressRaycast.gameObject
	local index = tonumber(go.transform.parent.name)
	local list = OperationActiveMgr:GetAllSkillDataInside(self.infoStage.id)
	local skillId = list[index].SkillId
	local limitData = OperationActiveMgr:GetStrSkillTipDesc(list[index].Params)
	local timeData = OperationActiveMgr:GetStrLeftHour(list[index].ID)
	local tipData = SkillTip.GetStageSkillBuffData(data.position, skillId, true, timeData, limitData)

	UIMgr.ShowSkillTip(tipData)
end

function PageCombatReadiness:UpdateRewardPanel()
	if self.chapterType ~= ChapterFromType.bossRaid then
		self:SetRewardSpecialPanel()
	else
		self.GoAdditional:SetActive(false)
		self.GoAwardBg:SetActive(false)
		self.GoHigh:SetActive(false)
		self.GoBossRaidDrop:SetActive(true)
		self.GoStageDrop:SetActive(false)
	end

	self.listAward = {}

	local function fun(listData, isFirst, isItemListFix, isHigh)
		for _, v in pairs(listData) do
			if v[1] and v[2] then
				local infoItem = ItemManager:GetValueItem(v[1], v[2])

				if v[3] then
					infoItem = ItemManager:GetValueItem(v[1], v[2], v[3])
				end

				table.insert(self.listAward, {
					info = infoItem,
					isFirst = isFirst,
					isItemListFix = isItemListFix,
					isHigh = isHigh
				})
			end
		end
	end

	if self.chapterType ~= ChapterFromType.union and self.chapterType ~= ChapterFromType.bossRaid then
		local isNew = self.infoStage:IsNew()

		if isNew then
			local firstAward = self.infoStage.data.FirstAward

			fun(firstAward, true)
		end
	end

	if self.chapterType ~= ChapterFromType.bossRaid and self.stageType ~= StageFromType.unionBoss then
		local commonAward = self.infoStage.data.ItemList
		local itemListFix = self.infoStage.data.ItemListFix

		fun(itemListFix, false, true)
		fun(commonAward, false)

		if self.haveHigh then
			local commonHighAward = self.infoStage.data.ItemList

			fun(commonHighAward, false, false, true)
		end
	elseif self.chapterType == ChapterFromType.bossRaid then
		local function addFun(reward, list)
			for k, v in pairs(list) do
				if not table.contains(reward, v[1]) then
					table.insert(reward, v[1])
				end
			end
		end

		local rewardList = {}

		addFun(rewardList, self.raidBossInfo.raidBossData.FindFirstPassReward)
		addFun(rewardList, self.raidBossInfo.raidBossData.FindReward)
		addFun(rewardList, self.raidBossInfo.raidBossData.BossKillReward)

		local RewardPack = require("luaData/RewardPack")

		addFun(rewardList, RewardPack[self.raidBossInfo.raidBossData.PercentHarmReward[1]].PackItem)

		self.listAward = {
			{
				info = ItemManager:GetValueItem(6000, 1)
			}
		}

		for k, v in pairs(rewardList) do
			table.insert(self.listAward, {
				info = ItemManager:GetValueItem(v, 1)
			})
		end
	elseif self.stageType == StageFromType.unionBoss then
		self.TextRewardTitle.text = _("Mirror_ItemsRewards")

		local raid = UnionRaidMgr.listBossRaid[self.selectRaidIdx]

		if raid then
			local info

			for _, v in ipairs(raid.data.Award) do
				info = ItemManager:GetValueItem(v[1], v[2])

				table.insert(self.listAward, {
					info = info
				})
			end

			if raid.data.ContributionOfKill ~= 0 then
				info = ItemManager:GetValueItem(401, raid.data.ContributionOfKill)

				table.insert(self.listAward, {
					info = info
				})
			end
		end
	end

	local function fun()
		local scrollArea = self:GetChildGameObject("Panel/StageDrop/Reward")
		local content = self:GetChildComponent("Panel/StageDrop/Reward/Content", "RectTransform")

		if self.chapterType == ChapterFromType.bossRaid then
			scrollArea = self:GetChildGameObject("Panel/BossRaidDrop/Reward")
			content = self:GetChildComponent("Panel/BossRaidDrop/Reward/Content", "RectTransform")
		end

		local count = #self.listAward

		local function addCallback(item)
			self:AddClick(item.UIRootObject, nil)
		end

		local function updateCallback(item, index)
			local infoItem = self.listAward[index].info
			local isFirst = self.listAward[index].isFirst
			local isItemListFix = self.listAward[index].isItemListFix
			local isHigh = self.listAward[index].isHigh

			if self.chapterType ~= ChapterFromType.bossRaid then
				if isFirst then
					item:UpdateWithNumType(infoItem)
				elseif isItemListFix then
					item:UpdateWithNumType(infoItem)
				elseif infoItem.randomNum then
					item:UpdateWithNumType(infoItem, nil, infoItem.randomNum)
				else
					item:UpdateWithNumType(infoItem)
				end
			else
				item:UpdateNoNumType(infoItem)
			end

			item.tipData = {
				showNum = true,
				initPanelIndex = 1,
				needFromBtn = false
			}

			item:SetFirstPass(isFirst)
			item:SetHigh(isHigh)

			if self.chapterType == ChapterFromType.bossRaid then
				item.percent = self.raidBossInfo.raidBossData.FinishReward
			end

			item:SetHigh(isHigh)
		end

		self.UIScrollTool = UIScrollTool()

		self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellItem, CellItem, self, true, addCallback, updateCallback)
	end

	if self.inited then
		self.UIScrollTool:UpdateListData(self.listAward)
	else
		fun()

		self.inited = true
	end
end

function PageCombatReadiness:SetRewardSpecialPanel()
	self.GoAdditional:SetActive(self.stageType ~= StageFromType.unionBoss)
	self.GoBossKill:SetActive(self.stageType == StageFromType.unionBoss)

	if self.stageType ~= StageFromType.unionBoss then
		local goTxtMax = self:GetChildGameObject("Panel/StarGroup/AdditionalAward/TextMax")
		local curNum = InfoGameInst:GetWhipAwardBoxNum()
		local maxNum = GetConfigArgInt("StageWhipAwardBoxMaxNum")

		goTxtMax:SetActive(curNum == maxNum)
	end

	local infoActive = ActiveMgr:GetActiveInfoByStageData(self.infoStage.data)

	self.GoHigh:SetActive(infoActive ~= nil)

	if infoActive then
		local type

		if self.infoStage.data.Type == StageFromType.activeCommon then
			type = 1
		elseif self.infoStage.data.Type == StageFromType.activeBoss then
			type = 2
		end

		local haveHigh = infoActive:HaveDailyReward(type)

		self.haveHigh = haveHigh

		self.GoHigh:SetActive(haveHigh)
	end
end

function PageCombatReadiness:UpdateMonsterPanel()
	local listEnemy = self.infoStage.listMonster

	local function funcUnion()
		local icon = self:GetChildComponent("Panel/GuildBoss/Icon", "Image")
		local enemyId = listEnemy[1]
		local infoEnemy = EnemyManager:Get(enemyId)

		SetImageSprite(icon, infoEnemy.data.NameIcon, self)
		require("GameLogic/Util/AttributeUtil")

		local level = 1
		local monsterIdx = 0
		local monsterLvList = self.infoStage.BattleData.MonsterLv
		local mosters = self.infoStage.BattleData.Enemy

		for _, waveEnemys in ipairs(mosters) do
			for i, UnitId in ipairs(waveEnemys) do
				monsterIdx = monsterIdx + 1
				level = monsterLvList[monsterIdx]

				if not level or type(level) ~= "number" then
					level = 1
				end
			end
		end

		local attri = AttributeUtil.GetMonsterAttri(1, self.infoStage.id)
		local txtBlood = self:GetChildComponent("Panel/GuildBoss/TxtBlood", "Text")

		txtBlood.text = UnionRaidMgr.listBossRaid[self.selectRaidIdx].progress .. "/" .. attri.maxHp

		local imgHp = self:GetChildComponent("Panel/GuildBoss/BgBar/Image", "Image")

		imgHp.fillAmount = UnionRaidMgr.listBossRaid[self.selectRaidIdx].progress / attri.maxHp

		local TextLevel = self:GetChildComponent("Panel/GuildBoss/Image/TextLevel", "Text")

		TextLevel.text = string.format(_("Desc_Level_Common1"), level)
		TextLevel.fontSize = 26

		local TextName = self:GetChildComponent("Panel/GuildBoss/Image/TextName", "Text")

		TextName.text = Lang(infoEnemy.data.Name)

		local ImgJob = self:GetChildComponent("Panel/GuildBoss/Job", "Image")

		SetImageSprite(ImgJob, "UIDyAtlas/RoleJob/ICO_" .. infoEnemy.data.Job .. "_01_S", self)
	end

	local function funcBossRaid()
		self.BossRaidIcon = self:GetChildComponent("Panel/BossRaidBoss/CellMonster/Icon", "Image")

		self:AddClick(self.BossRaidIcon.transform.parent.gameObject, self.OnClickBossRaidHead)

		local enemyId = listEnemy[1]
		local infoEnemy = EnemyManager:Get(enemyId)

		SetImageSprite(self.BossRaidIcon, infoEnemy.data.NameIcon, self)

		local HPImage = self:GetChildComponent("Panel/BossRaidBoss/HPBg/HP", "Image")
		local txtBlood = self:GetChildComponent("Panel/BossRaidBoss/BossHPTxt", "Text")
		local txtLevel = self:GetChildComponent("Panel/BossRaidBoss/CellMonster/Text", "Text")
		local BossName = self:GetChildComponent("Panel/BossRaidBoss/BossName", "Text")

		BossName.text = Lang(infoEnemy.data.Name)

		require("GameLogic/Util/AttributeUtil")

		local level = 1
		local monsterIdx = 0
		local monsterLvList = self.infoStage.BattleData.MonsterLv
		local mosters = self.infoStage.BattleData.Enemy

		for _, waveEnemys in ipairs(mosters) do
			for i, UnitId in ipairs(waveEnemys) do
				monsterIdx = monsterIdx + 1
				level = monsterLvList[monsterIdx]

				if not level or type(level) ~= "number" then
					level = 1
				end
			end
		end

		local attri = AttributeUtil.GetMonsterAttri(1, self.infoStage.id)

		self.bossHp = attri.maxHp
		self.curProgress = self.raidBossInfo.curProgress / attri.maxHp
		HPImage.fillAmount = self.curProgress
		txtBlood.text = math.ceil(self.raidBossInfo.curProgress) .. "/" .. attri.maxHp
		PageCombatReadinessJP.isBossFullHP = math.ceil(self.raidBossInfo.curProgress) == attri.maxHp
		txtLevel.text = _("Player_Level") .. self.raidBossInfo.bossLevel
	end

	local function funcActivityBoss()
		local icon = self:GetChildComponent("Panel/GuildBoss/Icon", "Image")
		local enemyId = listEnemy[1]
		local infoEnemy = EnemyManager:Get(enemyId)

		self:AddClick(icon.gameObject, self.OnClickBossRaidHead)
		SetImageSprite(icon, infoEnemy.data.NameIcon, self)
		require("GameLogic/Util/AttributeUtil")

		local level = 1
		local monsterIdx = 0
		local monsterLvList = self.infoStage.BattleData.MonsterLv
		local mosters = self.infoStage.BattleData.Enemy

		for _, waveEnemys in ipairs(mosters) do
			for i, UnitId in ipairs(waveEnemys) do
				monsterIdx = monsterIdx + 1
				level = monsterLvList[monsterIdx]

				if not level or type(level) ~= "number" then
					level = 1
				end
			end
		end

		local attri = AttributeUtil.GetMonsterAttri(1, self.infoStage.id)
		local txtBlood = self:GetChildComponent("Panel/GuildBoss/TxtBlood", "Text")

		txtBlood.text = self.infoStage.pb.leftBlood .. "/" .. attri.maxHp

		local imgHp = self:GetChildComponent("Panel/GuildBoss/BgBar/Image", "Image")

		imgHp.fillAmount = self.infoStage.pb.leftBlood / attri.maxHp

		local TextLevel = self:GetChildComponent("Panel/GuildBoss/Image/TextLevel", "Text")

		TextLevel.text = string.format(_("Desc_Level_Common1"), level)

		local TextName = self:GetChildComponent("Panel/GuildBoss/Image/TextName", "Text")

		TextName.text = Lang(infoEnemy.data.Name)

		local ImgJob = self:GetChildComponent("Panel/GuildBoss/Job", "Image")

		SetImageSprite(ImgJob, "UIDyAtlas/RoleJob/ICO_" .. infoEnemy.data.Job .. "_01_S", self)
	end

	local function func()
		if self.listCellEnemy then
			for i = 1, #self.listCellEnemy do
				self.listCellEnemy[i]:OnLeave()
			end
		end
	end

	local function funcCommon()
		local scrollArea = self:GetChildGameObject("Panel/Monsters")
		local scrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")

		scrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "RectTransform")
		scrollView.horizontal = true

		GOUtil.DestroyAllChildren(scrollView.content.gameObject)
		func()

		self.listCellEnemy = {}

		for i = 1, #listEnemy do
			local cell = CellMonster(self.PrefabMonster, scrollView.content.gameObject, self)

			cell:Create()
			cell:UpdateData(listEnemy[i], i, self.infoStage)

			local scrollViewContent = GOUtil.AddMissingComponent(cell.UIRootObject, "UIScrollViewContent")

			scrollViewContent.scrollView = scrollView

			table.insert(self.listCellEnemy, cell)
		end
	end

	if self.chapterType == ChapterFromType.union and self.stageType == StageFromType.unionBoss then
		self.GoMonsters:SetActive(false)
		self.GoBoss:SetActive(true)
		funcUnion()
	elseif self.chapterType == ChapterFromType.bossRaid then
		self.GoMonsters:SetActive(false)
		self.GoBoss:SetActive(false)
		self.GoRaidBoss:SetActive(true)
		funcBossRaid()
	elseif self.infoStage.data.ActType == 20 then
		self.GoMonsters:SetActive(false)
		self.GoBoss:SetActive(true)
		funcActivityBoss()
	else
		self.GoMonsters:SetActive(true)
		self.GoBoss:SetActive(false)
		funcCommon()
	end
end

function PageCombatReadiness:UpdatePowerPanel()
	local go1 = self:GetChildGameObject("Panel/Power/Image1")
	local go2 = self:GetChildGameObject("Panel/Power/Image2")
	local txtPower = GOUtil.FindChildComponent(go1, "TxtPower", "Text")
	local imgState = GOUtil.FindChildComponent(go2, "ImgState", "Image")
	local texState = GOUtil.FindChildComponent(go2, "TxtState", "Text")
	local listSE = self.infoStage.data.SafeCE
	local safeCE = 0

	if listSE and listSE[1] and listSE[1][1] then
		safeCE = listSE[1][1]
	end

	txtPower.text = tostring(safeCE)

	if self.chapterType == ChapterFromType.comb or self.infoStage:IsLimit() then
		go2:SetActive(true)
		self.BtnDetail:SetActive(true)
	elseif self.chapterType == ChapterFromType.union then
		-- block empty
	elseif self.chapterType == ChapterFromType.bossRaid then
		GOUtil.SetRectTransformAnchoredPosition(self.GoPower, -48, -376)
	else
		go2:SetActive(true)
		self.BtnDetail:SetActive(true)
	end

	local forecastLevel = 1
	local coe = self.teamCE / safeCE
	local config = GetConfigArgJson("BattleEstimate")

	forecastLevel = coe < config[1] and 1 or coe < config[2] and 2 or coe < config[3] and 3 or coe < config[4] and 4 or 5
	self.forecastLevel = forecastLevel
	self.forecastImagePath = "UI/PanelCombatReadiness/AtlasCombatReadiness/BG_ready_word_advise_0" .. forecastLevel

	SetImageSprite(imgState, self.forecastImagePath, self)

	if self.teamCE == 0 then
		SetActiveFunc(self.BtnDetail, false)
		SetActiveFunc(imgState.gameObject, false)

		txtPower.text = _("Desc_Team_None")
		texState.text = _("Desc_Team_None")

		SetActiveFunc(texState.gameObject, true)
	else
		SetActiveFunc(self.BtnDetail, true)
		SetActiveFunc(imgState.gameObject, true)
		SetActiveFunc(texState.gameObject, false)
	end
end

function PageCombatReadiness:InitTeam()
	self.teamCE = 0

	local infoteam
	local listUpCardId, listAddCardId = {
		0,
		0,
		0,
		0,
		0
	}, {
		0,
		0,
		0,
		0,
		0
	}

	if self.chapterType == ChapterFromType.union then
		if self.infoStage.data.Type == StageFromType.unionBoss then
			infoteam = require("Info.InfoTeamBossRaid")
		else
			infoteam = require("Info.InfoTeamRaid")
		end

		listUpCardId = infoteam:GetUpRoleCardList()
	elseif self.chapterType == ChapterFromType.comb then
		infoteam = require("Info.InfoTeamgGroup")

		local infoChapter = ChapterMgr:GetChapterByStage(self.infoStage.id)

		listUpCardId = infoteam:GetUpRoleCardList(infoChapter.data.Team)
		listAddCardId = infoteam:GetAddRoleCardList(infoChapter.data.Team)
	elseif self.chapterType == ChapterFromType.main or self.chapterType == ChapterFromType.mainhard or self.chapterType == ChapterFromType.activity or self.chapterType == ChapterFromType.bosslive or self.chapterType == ChapterFromType.card or self.chapterType == ChapterFromType.bossRaid then
		if InstructionMgr.isOpen and self.infoStage.id == GetConfigArgInt("GuideCard.StageID") and not self.infoStage:IsPass() then
			local listCardId = GetConfigArgJson("GuideFlow.ListRoleCardID2")
			local listAddId = {
				0,
				0,
				0,
				0,
				0
			}

			local function fun(cardId)
				local id = cardId

				if cardId ~= 0 then
					local infoCard = RoleCardMgr:GetRoleCard(cardId)

					if not infoCard.isHold then
						local listCard = RoleCardMgr:GetRoleHoldCard(infoCard.data.CharacterID)

						id = listCard[1].id
					end
				end

				return id
			end

			for i = 1, 5 do
				local upId = fun(listCardId[i])

				listUpCardId[i] = upId

				local addId = fun(listAddId[i])

				listAddCardId[i] = addId
			end
		else
			infoteam = require("Info/InfoTeam")
			listUpCardId = infoteam:GetUpRoleCardList()
			listAddCardId = infoteam:GetAddRoleCardList()
		end
	end

	self.teamCE = self:GetTeamCE(listUpCardId, listAddCardId)
	ChapterMgr.teamCE = self.teamCE
	self.listCardId = listUpCardId
	self.listAddCardId = listAddCardId
end

function PageCombatReadiness:GetTeamCE(listUpCardId, listAddCardId)
	local sum = 0

	for i = 1, #listUpCardId do
		if listUpCardId[i] ~= 0 then
			local upCard = RoleCardMgr:GetRoleCard(listUpCardId[i])
			local role = RoleMgr:GetRole(upCard.data.CharacterID)
			local addCard

			if listAddCardId[i] ~= nil and listAddCardId[i] ~= 0 then
				addCard = RoleCardMgr:GetRoleCard(listAddCardId[i])
			end

			sum = sum + RoleCardMgr:GetFightValue(role, upCard, addCard)
		end
	end

	return sum
end

function PageCombatReadiness:UpdateStageSkillPanel()
	local list = OperationActiveMgr:GetAllSkillDataOutside(self.infoStage.id)

	self.GoBuffGroup:SetActive(#list ~= 0)

	local group = self:GetChildGameObject("Panel/SkillBuffGroup/Group")

	GOUtil.DestroyAllChildren(group)

	local groupLayout = self:GetChildComponent("Panel/SkillBuffGroup/Group", "LayoutGroup")

	if not self.isSmall and self.chapterType == ChapterFromType.bossRaid then
		GOUtil.SetRectTransformAnchoredPosition(self.GoBuffGroup, -48, -260)
	end

	local goSkill = self:GetChildGameObject("Panel/SkillBuffGroup/Skill")

	self.listGoSkill = {}

	for i = 1, #list do
		local cell = GOUtil.Instantiate(goSkill, group)
		local icon = GOUtil.GetComponent(cell, "Image")
		local txt = GOUtil.FindChildComponent(cell, "Image/Text", "Text")
		local skillId = list[i].SkillId
		local info = TalentManager:Get(skillId)

		SetImageSprite(icon, "UIDyAtlas/Skill/" .. info.data.Icon, self)

		txt.text = OperationActiveMgr:GetStrLeftDay(list[i].ID)
		cell.name = i

		self:AddClick(cell, self.OnPressStageSkillDown)
		table.insert(self.listGoSkill, cell)
	end

	goSkill:SetActive(false)
end

function PageCombatReadiness:OnPressStageSkillDown(data)
	local go = data.pointerPressRaycast.gameObject
	local index = tonumber(go.name)
	local list = OperationActiveMgr:GetAllSkillDataOutside(self.infoStage.id)
	local skillId = list[index].SkillId
	local limitData = OperationActiveMgr:GetStrSkillTipDesc(list[index].Params)
	local timeData = OperationActiveMgr:GetStrLeftHour(list[index].ID)
	local tipData = SkillTip.GetStageSkillBuffData(data.position, skillId, true, timeData, limitData)

	UIMgr.ShowSkillTip(tipData)
end

function PageCombatReadiness:UpdateDamagePanel()
	if self.infoStage.data.ChapterType ~= ChapterFromType.bossRaid then
		return
	end

	self.DamageList:SetActive(true)

	if not self.damage or #self.damage == 0 then
		self.DamageEmpty:SetActive(true)
		self.DamageLine:SetActive(false)

		return
	end

	local scrollArea = self:GetChildGameObject("Panel/DamageList/ScrollArea")
	local scrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")

	scrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "RectTransform")
	scrollView.vertical = true
	scrollView.horizontal = false

	table.sort(self.damage, function(a, b)
		return a.harm > b.harm
	end)

	if self.listCellDamage then
		for i = 1, #self.listCellDamage do
			self.listCellDamage[i]:OnLeave()
		end
	end

	GOUtil.DestroyAllChildren(scrollView.content.gameObject)

	self.listCellDamage = {}

	for i = 1, #self.damage do
		local cell = CellBossRaidDamage(self.PrefabCellBossRaidDamage, scrollView.content.gameObject, self)
		local data = {}

		data.damage = self.damage[i]
		data.rank = i
		data.type = 1
		data.stageId = self.infoStage.id
		data.bossHp = self.bossHp

		if PlayerInst.InfoPlayer.pid == data.damage.playerId then
			self.rankData = data
		end

		cell:Create(data)
		table.insert(self.listCellDamage, cell)
	end

	if self.rankData then
		local selfDamagePos = self:GetChildGameObject("Panel/DamageList/SelfDamage")
		local cell = CellBossRaidDamage(self.PrefabCellBossRaidDamage, selfDamagePos, self)

		cell:Create(self.rankData)
		table.insert(self.listCellDamage, cell)
	end
end

function PageCombatReadiness:UpdateBeginPanel()
	local txtChallengeNum = self:GetChildComponent("Panel/Begin/ChallengeNum/TextNum", "Text")
	local leftTitleStr = Lang(5000008)

	if self.chapterType == ChapterFromType.bosslive then
		leftTitleStr = _("Desc_Award_Num")
	elseif self.stageType == StageFromType.unionBoss then
		leftTitleStr = _("Mirror_FightTimes")
	end

	local stageType = self.infoStage.data.Type
	local chapterType = self.infoStage.data.ChapterType
	local IsNumNotEnough = false

	if chapterType == ChapterFromType.bossRaid then
		local playMaxNum = 0

		if self.raidBossInfo.fromType == 0 then
			playMaxNum = GetConfigArgInt("RailBossActiveFinderNum")
		else
			playMaxNum = GetConfigArgInt("RailBossActivePartnerNum")
		end

		leftTitleStr = _("Desc_FightTimes")
		txtChallengeNum.text = leftTitleStr .. playMaxNum - self.raidBossInfo.selfPlayNum .. "/" .. playMaxNum

		local txtTotalNum = self:GetChildComponent("Panel/Begin/ChallengeNum/TextTotalNum", "Text")
		local txtTotal = self:GetChildGameObject("Panel/Begin/ChallengeNum/TextTotal")

		txtTotal:SetActive(true)
		txtTotalNum.gameObject:SetActive(true)

		txtTotalNum.text = ActivityBossRaidMgr.playNum .. "/" .. ActivityBossRaidMgr:GetPlayMaxNum()

		if ActivityBossRaidMgr.playNum <= 0 then
			txtTotalNum.color = Color.red
		else
			txtTotalNum.color = Color.New(0.34509803921568627, 0.3686274509803922, 0.34509803921568627, 1)
		end

		if playMaxNum - self.raidBossInfo.selfPlayNum <= 0 then
			txtChallengeNum.color = Color.red
		else
			txtChallengeNum.color = Color.New(0.34509803921568627, 0.3686274509803922, 0.34509803921568627, 1)
		end

		if ActivityBossRaidMgr.playNum <= 0 or playMaxNum - self.raidBossInfo.selfPlayNum <= 0 then
			DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnChallenge, 1))
		else
			DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnChallenge, 0))
		end
	elseif chapterType == ChapterFromType.union then
		if stageType == StageFromType.unionBoss then
			local reminingWithLimit = ChapterMgr:GetStageLeftPlayNumWithLimit(self.infoStage.id)

			txtChallengeNum.text = "<size=28>" .. leftTitleStr .. reminingWithLimit .. "/" .. GetConfigArgInt("ClubMirrorBossWeekPlay") .. "</size>"

			if reminingWithLimit == 0 then
				IsNumNotEnough = true
			end
		else
			GOUtil.SetActive(self.GoChallengeNum, false)

			IsNumNotEnough = false
		end
	elseif chapterType == ChapterFromType.activity and self.infoStage.data.ActType == 20 then
		txtChallengeNum.text = _("Activity_Boss") .. self.infoStage:GetLeftPlayNum() .. "/" .. self.infoStage:GetMaxLeftPlayNum()

		GOUtil.SetRectTransformSizeDelta(self.BtnChallenge, 330, 95)

		local x, y, z = GOUtil.GetTransformLocalPosition(self.GoGroup, x, y, z)

		GOUtil.SetTransformLocalPosition(self.GoGroup, 0, 140, 0)
		SetActiveFunc(self.BattleTip.gameObject, true)

		self.BattleTip.text = _("Activity_BossTip")
	else
		if chapterType == ChapterFromType.activity and self.infoStage.data.Type == StageFromType.activeBoss then
			SetActiveFunc(self.BattleTip.gameObject, false)
			GOUtil.SetRectTransformSizeDelta(self.BtnChallenge, 380, 120)
			GOUtil.SetTransformLocalPosition(self.GoGroup, 0, 105, 0)
		end

		local stageChallNum = self.infoStage.pb.playNum
		local stageLimitNum = self.infoStage:GetMaxLeftPlayNum()
		local reminingWithLimit = ChapterMgr:GetStageLeftPlayNumWithLimit(self.infoStage.id)

		if reminingWithLimit ~= -1 and reminingWithLimit == 0 then
			IsNumNotEnough = true
		end

		if stageLimitNum ~= 0 and stageLimitNum - stageChallNum == 0 then
			IsNumNotEnough = true
		end

		if stageLimitNum ~= 0 then
			txtChallengeNum.text = leftTitleStr .. self.infoStage:GetLeftPlayNum() .. "/" .. self.infoStage:GetMaxLeftPlayNum()

			if self.chapterType == ChapterFromType.bosslive then
				txtChallengeNum.text = leftTitleStr .. BossliveChapterMgr.GetBossliveRemainingChallengeNum() .. "/" .. self.infoStage:GetMaxLeftPlayNum()
			end
		else
			txtChallengeNum.text = leftTitleStr .. "-/-"
		end

		if chapterType == ChapterFromType.comb then
			local teamId = ChapterMgr:GetChapter(self.infoStage.data.ChapterID).data.Team

			txtChallengeNum.text = leftTitleStr .. CombChapterMgr.GetCombRemainingChallengeNum(teamId) .. "/" .. CombChapterMgr.GetSingleLimitChallengeNum(teamId)
		end
	end

	if IsNumNotEnough then
		txtChallengeNum.color = Color.red

		if chapterType == ChapterFromType.bosslive then
			local Text = self:GetChildComponent("Panel/Begin/Group/BtnChallenge/Text", "Text")

			Text.text = _("Btn_Watch")
		else
			local gray = TenaryOp(IsNumNotEnough, 1, 0)

			DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnChallenge, gray))
		end
	else
		DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnChallenge, 0))

		txtChallengeNum.color = Color.New(0.34509803921568627, 0.3686274509803922, 0.34509803921568627, 1)
	end

	local isPass = self.infoStage:IsPass()
	local canSweep = self.infoStage:CanSweep()

	if isPass and canSweep then
		local isFull = self.infoStage:IsFullStar()
		local txtSweepCon = self:GetChildComponent("Panel/Begin/Group/BtnSweep/TextSweep", "Text")
		local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Sweep)

		txtSweepCon.gameObject:SetActive(not isFull and isOpen)

		local imgBtn = GOUtil.GetComponent(self.BtnSweep, "Image")
		local gray = TenaryOp(isFull and isOpen, 0, 1)

		DealWithListRef(self, UIUtil.SetImageGray(imgBtn, gray))

		if self.chapterType == ChapterFromType.bosslive then
			self.BtnSweep:SetActive(not IsNumNotEnough)
		else
			self.BtnSweep:SetActive(true)

			local gray = TenaryOp(IsNumNotEnough, 1, 0)

			DealWithListRef(self, UIUtil.SetImageGray(self.ImgBtnSweep, gray))
		end
	else
		self.BtnSweep:SetActive(false)
	end

	local goText = self:GetChildGameObject("Panel/Begin/Group/BtnChallenge/Text")
	local imgCostIcon = self:GetChildComponent("Panel/Begin/Group/BtnChallenge/Icon", "Image")
	local txtCostNum = self:GetChildComponent("Panel/Begin/Group/BtnChallenge/TextNum", "Text")
	local costItem = self.infoStage:GetCostItem()

	imgCostIcon.gameObject:SetActive(#costItem ~= 0)
	txtCostNum.gameObject:SetActive(#costItem ~= 0)

	if #costItem ~= 0 then
		SetImageSprite(imgCostIcon, costItem[1]:GetIcon(), self)

		txtCostNum.text = costItem[2]

		GOUtil.SetTransformLocalPosition(goText, 50, 0, 0)
	else
		GOUtil.SetTransformLocalPosition(goText, 0, 0, 0)
	end

	if self.chapterType ~= ChapterFromType.bossRaid then
		self.BtnShared:SetActive(false)
	else
		local battleCount = self.raidBossInfo.selfPlayNum
		local shared = self.raidBossInfo.selfShared
		local fromType = self.raidBossInfo.fromType

		self.BtnShared:SetActive(fromType == 0 and shared == 0 and battleCount > 0)
	end

	self.jpPageCombatReadiness:UpdateBeginPanel()
end

function PageCombatReadiness:OnClickedBtnChallenge(vParam)
	if type(vParam) ~= "table" or vParam.clickType ~= 1 then
		PageCombatReadinessJP.clickType = 0
	end

	if not self.isChallenge then
		self.isChallenge = true
	end

	local stageType = self.infoStage.data.Type
	local chapterType = self.infoStage.data.ChapterType

	if PlayerInst:GetCurLv() < self.infoStage.data.LevelUnlock then
		UIMgr.ShowMsg(string.format(_("Msg_UnlockTeamPosition"), self.infoStage.data.LevelUnlock))

		return
	end

	if chapterType == ChapterFromType.activity then
		local infoActive = ActiveMgr:GetActiveInfoByStageData(self.infoStage.data)
		local isCanPlay, msg = infoActive:IsPlayOpen()

		if not isCanPlay then
			UIMgr.ShowMsg(msg)

			return
		end
	end

	if stageType == StageFromType.unionBoss then
		local isOpen = UnionRaidMgr:IsBossRaidOpen()

		if not isOpen then
			UIMgr.ShowMsg(_("Msg_Boss_Raid_Not_Open"))

			return
		end
	end

	local leftNum = ChapterMgr:GetStageLeftPlayNumWithLimit(self.infoStage.id)

	if leftNum ~= -1 and leftNum == 0 and self.chapterType ~= ChapterFromType.bosslive and PageCombatReadinessJP.clickType == 0 then
		if chapterType == ChapterFromType.bossRaid then
			if GetConfigArgInt("RailBossActiveDailyNumBuyCost") > 0 and ActivityBossRaidMgr.buyNum < GetConfigArgInt("RailBossActiveDailyNumBuyCost") then
				local function responseCb()
					if not IsNil(self.UIRootObject) then
						self:UpdateBeginPanel()
					end
				end

				require("UI/Page/PageActivityBossRaid/PageActivityBossRaid")
				PageActivityBossRaid.GoBuyTimes(responseCb)
			end
		else
			UIMgr.ShowMsg(_("Msg_Cnt_NotEnough"))
		end

		return
	end

	local function funItem(teamSystemAgent)
		if not teamSystemAgent.battleCost then
			return true
		end

		for k, v in pairsByKeys(teamSystemAgent.battleCost) do
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

	local infoTeam = InfoTeam

	if chapterType == ChapterFromType.comb then
		infoTeam = InfoTeamgGroup
	elseif chapterType == ChapterFromType.union then
		if stageType == StageFromType.unionBoss then
			infoTeam = InfoTeamBossRaid
		else
			infoTeam = InfoTeamRaid
		end
	end

	if chapterType == ChapterFromType.bossRaid then
		self.infoStage.raidBossId = self.raidBossInfo.id
		self.infoStage.bossHp = self.bossHp
	end

	if ChapterFromType.bosslive == chapterType then
		ChapterMgr.BossLiveToTeam = 1
	end

	local function callback(...)
		if not funItem(infoTeam.teamSystemAgent) then
			return
		end

		UIMgr.SwitchPanel(PageTeam, infoTeam.teamSystemAgent)
		Event.Instance:Fire(EventEnum.EnterStage)
		PersistentStoreUtil.SetStageEnter(self.infoStage.id, true)
	end

	if infoTeam then
		if self.forecastLevel < 3 and self.teamCE > 0 then
			local function wrap_cb(index2)
				if index2 == 1 then
					infoTeam:EnterStage(self.infoStage)
					callback()

					return
				elseif index2 == 2 then
					UIMgr.AddPanel(DlgForecast(), {
						infoStage = self.infoStage,
						listRoleCardId = self.listCardId,
						listAddCardId = self.listAddCardId,
						teamCE = self.teamCE,
						forecastImagePath = self.forecastImagePath
					})

					return
				end
			end

			local strTitle = _("Desc_Alert")
			local strOkText = _("UI_OK")
			local strCancelText = _("PageRoleCard_CheckDetail")
			local msg = _("Desc_Forecast_Tips")
			local DlgCommon = DlgCommonEvent()

			DlgCommon:Create(self.UIRootObject, {
				DlgCommonEvent.Type.Msg,
				strTitle,
				msg,
				wrap_cb,
				strOkText,
				strCancelText
			})
			self:AddChildPanel(DlgCommon)
		else
			infoTeam:EnterStage(self.infoStage)
			callback()
		end
	end
end

function PageCombatReadiness:OnClickedBtnSweep()
	if self.jpPageCombatReadiness:OnClickedBtnSweepToHelp() then
		return
	end

	local isOpen = TutorialMgr:IsOpenTut(TutorialFunctionType.Sweep)

	if not isOpen then
		return
	end

	if not self.infoStage:IsFullStar() then
		UIMgr.ShowMsg(_("PageBattleTeam_SweepLock"))

		return
	end

	local leftNum = ChapterMgr:GetStageLeftPlayNumWithLimit(self.infoStage.id)

	if leftNum ~= -1 and leftNum == 0 then
		UIMgr.ShowMsg(_("Msg_Cnt_NotEnough"))

		return
	end

	local function callback(...)
		self:Close()
	end

	UIMgr.AddPanel(DlgStageSweep(), {
		infoStage = self.infoStage,
		needItem = self.needItem,
		callback = callback
	})
end

function PageCombatReadiness:UpdateChangeArrow()
	local isSyntherize = false

	if self.isSyntherize then
		isSyntherize = true
	end

	self.GoArrow:SetActive(not isSyntherize and self.chapterType ~= ChapterFromType.bossRaid and self.infoStage.data.Type ~= StageFromType.unionCommon)

	if self.listChangeStage and #self.listChangeStage > 0 then
		local stageIdx = GetStageIdx(self.listChangeStage, self.stageId)

		self.BtnL:SetActive(stageIdx ~= 1)
		self.BtnR:SetActive(stageIdx ~= #self.listChangeStage)
	end
end

function PageCombatReadiness:OnClickedBtnLeft()
	if self.listChangeStage then
		local stageIdx = GetStageIdx(self.listChangeStage, self.stageId)

		stageIdx = stageIdx - 1

		if stageIdx == 0 then
			stageIdx = 1
		end

		self.stageId = self.listChangeStage[stageIdx].id

		self:RefreshStage()
		self:UpdateChangeArrow()
	end

	if self.bossliveCurIndex then
		self.bossliveCurIndex = self.bossliveCurIndex - 1
	end
end

function PageCombatReadiness:OnClickedBtnRight()
	if self.listChangeStage then
		local stageIdx = GetStageIdx(self.listChangeStage, self.stageId)

		stageIdx = stageIdx + 1

		if stageIdx == #self.listChangeStage + 1 then
			stageIdx = #self.listChangeStage
		end

		self.stageId = self.listChangeStage[stageIdx].id

		self:RefreshStage()
		self:UpdateChangeArrow()
	end

	if self.bossliveCurIndex then
		self.bossliveCurIndex = self.bossliveCurIndex + 1
	end
end

function PageCombatReadiness:OnLongPressStarBox(data)
	if data.clickCount == 1 then
		self.GoStarGroup:SetActive(true)
	else
		self.GoStarGroup:SetActive(false)
	end
end

function PageCombatReadiness:OnClickedGoAdditional()
	if self.infoStage.data.BattleStageID ~= 0 then
		UIMgr.AddPanel(DlgMayFall(), {
			infoStage = self.infoStage
		})
	end
end

function PageCombatReadiness:OnClickedGoBossKill()
	local info = UnionRaidMgr:GetBossRaidByStageId(self.infoStage.id)

	UIMgr.AddPanel(DlgRaidAwardRecord(), {
		type = 2,
		raidId = info.id
	})
end

function PageCombatReadiness:OnClickedBtnDetail()
	UIMgr.AddPanel(DlgForecast(), {
		infoStage = self.infoStage,
		listRoleCardId = self.listCardId,
		listAddCardId = self.listAddCardId,
		teamCE = self.teamCE,
		forecastImagePath = self.forecastImagePath
	})
end

function PageCombatReadiness:OnClickedBtnClose()
	if self.bossliveCurIndex then
		Event.Instance:Fire("PageBossliveUpdateCurIndex", self.bossliveCurIndex)
	end

	if self.closeCb then
		self.closeCb()

		self.closeCb = nil
	end

	self:Close()
end

function PageCombatReadiness:OnClickedStageLimitHide()
	self.StageLimit:SetActive(false)
end

function PageCombatReadiness:OnClickedStageLimitShow()
	self.StageLimit:SetActive(true)
end

function PageCombatReadiness:OnClickBossRaidHead()
	UIMgr.AddPanel(DlgMonsterDes(), {
		index = 1,
		listMonster = self.infoStage.listMonster
	}, UIMgr.UIOverLayObject)
end

function PageCombatReadiness:UpdateStage()
	self:SetRewardSpecialPanel()
	self:UpdateBeginPanel()
	self:UpdateStageSkillPanel()
end

function PageCombatReadiness:UpdateRaidSystem()
	if self.infoStage.data.ChapterType == ChapterFromType.union then
		self:Close()
	end
end

function PageCombatReadiness:OnClickedSharedBtn()
	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestBossRaidShared(tonumber(self.raidBossInfo.id), function(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		if pb.result.code == NetManager.Result_Sucess then
			Event.Instance:Fire("UpdateBossRaidShard", self.raidBossInfo.id)
			self.BtnShared:SetActive(false)

			self.raidBossInfo.selfShared = 1

			UIMgr.ShowMsg(_("Desc_Shared_Sucess"))
		else
			UIMgr.ShowMsg(pb.result.desc, pb)
		end
	end)
end

function PageCombatReadiness:OnBackAndroid()
	self:OnClickedBtnClose()
end
