-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageCombatReadiness/DlgCombatReadiness.lua

require("UI/Page/PageCombatReadiness/CellMonster")
require("UI/Page/PageCombatReadiness/CellSpecifyCondition")
require("UI/Page/PageCombatReadiness/DlgMayFall")
require("UI/Page/PageCombatReadiness/DlgForecast")
require("UI/Page/PageUnionRaid/DlgRaidAwardRecord")

local InfoTeam = require("Info.InfoTeam")
local InfoTeamRaid = require("Info.InfoTeamRaid")
local skillTip = require("UI/Dlg/Common/SkillTipDesc")

DlgCombatReadiness = class("DlgCombatReadiness", UIPanel)

function DlgCombatReadiness:ctor()
	self.UIPrefabPath = "UI/PanelCombatReadiness/DlgCombatReadiness"
end

function DlgCombatReadiness:PreLoad()
	self:LoadResAsync("UI/PanelCombatReadiness/CellMonster", "PrefabMonster")
	self:LoadResAsync("UI/PanelCombatReadiness/CellSpecifyCondition", "PrefabSpecifyCondition")
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
	self:LoadResAsync("UI/PanelCombatReadiness/CellCardAddition", "PrefabCellCardAddition")
end

function DlgCombatReadiness:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabMonster)
	ResourceMgr.Unload(self.PrefabSpecifyCondition)
	ResourceMgr.Unload(self.PrefabCellItem)
	ResourceMgr.Unload(self.PrefabCellCardAddition)
	UnloadAllImageSprite(self)
	self:OnLeave()
end

function DlgCombatReadiness:OnLeave()
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

	if self.listCellEnemy then
		for i = 1, #self.listCellEnemy do
			self.listCellEnemy[i]:OnLeave()
		end
	end

	if self.listCellAddLimit then
		for i = 1, #self.listCellAddLimit do
			self.listCellAddLimit[i]:OnLeave()
		end
	end
end

function DlgCombatReadiness:OnRegisterEvent()
	self:AddClick(self.GoAdditional, self.OnClickedGoAdditional)
	self:AddClick(self.GoBossKill, self.OnClickedGoBossKill)
	self:AddClick(self.BtnDetail, self.OnClickedBtnDetail)
	self:AddClick(self.BtnChallenge, self.OnClickedBtnChallenge)
	self:AddClick(self.Btn_limit_close, self.OnClickedStageLimitHide)
	self:AddClick(self.Btn_limit, self.OnClickedStageLimitShow)
	self:AddClick(self.BtnClose, self.OnClickedBtnClose)
end

function DlgCombatReadiness:OnUnRegisterEvent()
	self:RemoveClick(self.GoAdditional, self.OnClickedGoAdditional)
	self:RemoveClick(self.GoBossKill, self.OnClickedGoBossKill)
	self:RemoveClick(self.BtnDetail, self.OnClickedBtnDetail)
	self:RemoveClick(self.BtnChallenge, self.OnClickedBtnChallenge)
	self:RemoveClick(self.Btn_limit_close, self.OnClickedStageLimitHide)
	self:RemoveClick(self.Btn_limit, self.OnClickedStageLimitShow)
	self:RemoveClick(self.BtnClose, self.OnClickedBtnClose)

	if self.listGoSkill then
		for i = 1, #self.listGoSkill do
			self:RemoveListener(self.listGoSkill[i], self.OnLongPressStageSkill, EventTriggerType.PointerLongPress)
		end
	end

	if self.listCellAddLimit then
		for i = 1, #self.listCellAddLimit do
			self:RemoveListener(self.listCellAddLimit[i].UIRootObject, self.OnLongPressStageSkill, EventTriggerType.PointerLongPress)
		end
	end
end

function DlgCombatReadiness:OnEnter(vParam)
	self:DealWithLocalization()

	self.ImgStageIcon = self:GetChildComponent("Bg3", "Image")
	self.TxtStageName = self:GetChildComponent("LevelName", "Text")
	self.GoBossKill = self:GetChildGameObject("Panel/StageDrop/BossKillAward")
	self.GoPower = self:GetChildGameObject("PowerGroup")
	self.BtnDetail = self:GetChildGameObject("PowerGroup/Btndetailed")
	self.BtnChallenge = self:GetChildGameObject("DownGroup/BtnChallenge")
	self.GoMonsters = self:GetChildGameObject("MosterScroll")
	self.BtnClose = self:GetChildGameObject("Bg1/BtnClose")
	self.Btn_limit_close = self:GetChildGameObject("StageLimit/Btn_close")
	self.Btn_limit = self:GetChildGameObject("Btn_limit")
	self.GoBuffGroup = self:GetChildGameObject("SkillBuffGroup")
	self.StageLimit = self:GetChildGameObject("StageLimit")

	self:InitData(vParam)
end

function DlgCombatReadiness:DealWithLocalization()
	local Text = self:GetChildComponent("Text (1)", "Text")

	Text.text = _("Desc_PassReward")
	Text = self:GetChildComponent("PowerGroup/Text (1)", "Text")
	Text.text = string.format(_("Desc_CombatReadiness_RecommendFightingCapacity"), "")
	Text = self:GetChildComponent("PowerGroup/Text (2)", "Text")
	Text.text = _("Desc_CombatReadiness_EstimateSituation")
	Text = self:GetChildComponent("PowerGroup/Btndetailed/Text", "Text")
	Text.text = _("UI_detail")
	Text = self:GetChildComponent("DownGroup/BtnChallenge/Text", "Text")
	Text.text = _("Btn_Fight")
end

function DlgCombatReadiness:InitData(vParam)
	self.stageId = vParam.stageId

	local stage = ChapterMgr:GetStage(vParam.stageId)

	if stage.data.ChapterType ~= ChapterFromType.union then
		local infoChapter = ChapterMgr:GetChapter(stage.data.ChapterID)
		local list = infoChapter.listStage

		self.listChangeStage = {}

		for i = 1, #list do
			if list[i].data.Type ~= 2 and list[i]:IsOpen() then
				table.insert(self.listChangeStage, list[i])
			end
		end
	end

	self:RefreshStage()
end

function DlgCombatReadiness:RefreshStage()
	self.infoStage = ChapterMgr:GetStage(self.stageId)
	self.stageType = self.infoStage.data.Type
	self.chapterType = self.infoStage.data.ChapterType

	self:UpdatePanel()
end

function DlgCombatReadiness:UpdatePanel()
	if self.chapterType == ChapterFromType.main then
		local _, cIdx, sIdx = ChapterMgr:GetChapterByStageID(self.stageId)

		self.TxtStageName.text = cIdx .. "-" .. sIdx .. " " .. Lang(self.infoStage.data.Name)
	else
		self.TxtStageName.text = Lang(self.infoStage.data.Name)
	end

	local battleScenceId = self.infoStage.BattleData.MainSceneId
	local name = SceneMgr.data[battleScenceId].BattleSceneicon

	UIUtil.SetImageSprite(self.ImgStage, name)
	self:InitTeam()
	self:UpdateLimitPanel()
	self:UpdateRewardPanel()
	self:UpdateMonsterPanel()
	self:UpdatePowerPanel()
	self:UpdateStageSkillPanel()
	self:UpdateBeginPanel()
end

function DlgCombatReadiness:UpdateChallengePanel()
	local haveCon = self.infoStage:HaveStarCon()

	self.GoCondtion:SetActive(haveCon)
	self.GoStageDesc:SetActive(not haveCon)

	local textTitle = self:GetChildComponent("Panel/StageReach/Title/Text", "Text")

	if haveCon then
		local star = self.infoStage.pb.stars

		for i = 1, 3 do
			local goStar = self:GetChildGameObject("Panel/StageReach/CondtionGroup/StarBox/" .. i .. "/Star")
			local txtCon = self:GetChildComponent("Panel/StageReach/CondtionGroup/Condtion" .. i .. "/Text", "Text")

			goStar:SetActive(star[i] == 1)
			ChapterMgr:SetStageAch(self.infoStage.data.Grade[i], txtCon)
		end

		self:SetSatrTip(star)

		textTitle.text = _("Desc_CombatReadiness_ChallengeGoal")
	else
		local txtDesc = GOUtil.GetComponent(self.GoStageDesc, "Text")

		txtDesc.text = Lang(self.infoStage.data.Info)
		textTitle.text = _("Stage_Description")
	end
end

function DlgCombatReadiness:UpdateLimitPanel()
	local isLimit = self.infoStage:IsLimit() or #OperationActiveMgr:GetAllSkillDataInside(self.stageId) > 0

	self.Btn_limit:SetActive(isLimit)

	if isLimit then
		local count = 0

		if #self.infoStage.data.LimitList > 0 then
			count = count + 1

			self:GetChildGameObject("StageLimit/BG/Image/ScrollArea/Viewport/Content/Panel1"):SetActive(true)

			local scrollArea = self:GetChildGameObject("StageLimit/BG/Image/ScrollArea/Viewport/Content/Panel1/CardScroll")
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
			self:GetChildGameObject("StageLimit/BG/Image/ScrollArea/Viewport/Content/Panel1"):SetActive(false)
		end

		local skillList = OperationActiveMgr:GetAllSkillDataInside(self.stageId)

		if #skillList > 0 then
			count = count + 1

			self:GetChildGameObject("StageLimit/BG/Image/ScrollArea/Viewport/Content/Panel2"):SetActive(true)

			local scrollArea = self:GetChildGameObject("StageLimit/BG/Image/ScrollArea/Viewport/Content/Panel2/CardScroll")
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
			self:GetChildGameObject("StageLimit/BG/Image/ScrollArea/Viewport/Content/Panel2"):SetActive(false)
		end

		local Image = self:GetChildGameObject("StageLimit/BG/Image")

		if count == 1 then
			GOUtil.SetRectTransformSizeDelta(Image, 1060, 390)
		else
			GOUtil.SetRectTransformSizeDelta(Image, 1060, 665)
		end
	end
end

function DlgCombatReadiness:OnPressInsideStageSkillDown(data)
	local go = data.pointerPressRaycast.gameObject
	local index = tonumber(go.transform.parent.name)
	local list = OperationActiveMgr:GetAllSkillDataInside(self.infoStage.id)
	local skillId = list[index].SkillId
	local limitData = OperationActiveMgr:GetStrSkillTipDesc(list[index].Params)
	local timeData = OperationActiveMgr:GetStrLeftHour(list[index].ID)
	local tipData = SkillTip.GetStageSkillBuffData(data.position, skillId, true, timeData, limitData)

	UIMgr.ShowSkillTip(tipData)
end

function DlgCombatReadiness:UpdateRewardPanel()
	self.listAward = {}

	local function fun(listData, isFirst)
		for _, v in pairs(listData) do
			if v[1] and v[2] then
				local infoItem = ItemManager:GetValueItem(v[1], v[2])

				if v[3] then
					infoItem = ItemManager:GetValueItem(v[1], v[2], v[3])
				end

				table.insert(self.listAward, {
					info = infoItem,
					isFirst = isFirst
				})
			end
		end
	end

	if self.chapterType ~= ChapterFromType.union then
		local isNew = self.infoStage:IsNew()

		if isNew or self.chapterType == ChapterFromType.tower then
			local firstAward = self.infoStage.data.FirstAward

			fun(firstAward, true)
		end
	end

	local commonAward = self.infoStage.data.ItemList

	fun(commonAward, false)

	local function fun()
		local scrollArea = self:GetChildGameObject("Reward")
		local content = self:GetChildComponent("Reward/Content", "RectTransform")
		local count = #self.listAward

		local function addCallback(item)
			self:AddClick(item.UIRootObject, nil)
		end

		local function updateCallback(item, index)
			local infoItem = self.listAward[index].info
			local isFirst = self.listAward[index].isFirst

			if isFirst then
				item:UpdateWithNumType(infoItem)
			elseif infoItem.randomNum then
				item:UpdateWithNumType(infoItem, nil, infoItem.randomNum)
			else
				item:UpdateWithNumType(infoItem)
			end

			if self.chapterType == ChapterFromType.tower then
				item:SetStageAward(isFirst)
			else
				item:SetFirstPass(isFirst)
			end
		end

		self.UIScrollTool = UIScrollTool()

		self.UIScrollTool:InitList(scrollArea, content, count, self.PrefabCellItem, CellItem, self, false, addCallback, updateCallback)
	end

	if self.inited then
		self.UIScrollTool:UpdateListData(self.listAward)
	else
		fun()

		self.inited = true
	end
end

function DlgCombatReadiness:SetRewardSpecialPanel()
	self.GoAdditional:SetActive(self.stageType ~= StageFromType.unionBoss)
	self.GoBossKill:SetActive(self.stageType == StageFromType.unionBoss)

	if self.stageType ~= StageFromType.unionBoss then
		local goTxtMax = self:GetChildGameObject("Panel/StageDrop/AdditionalAward/TextMax")
		local curNum = InfoGameInst:GetWhipAwardBoxNum()
		local maxNum = GetConfigArgInt("StageWhipAwardBoxMaxNum")

		goTxtMax:SetActive(curNum == maxNum)
	end

	local infoActive = ActiveMgr:GetActiveInfoByStageData(self.infoStage.data)

	self.GoHigh:SetActive(infoActive ~= nil)

	if infoActive then
		local haveHigh = infoActive:HaveDailyReward()

		self.GoHigh:SetActive(haveHigh)
	end
end

function DlgCombatReadiness:UpdateMonsterPanel()
	local listEnemy = self.infoStage.listMonster

	local function funcUnion()
		local icon = self:GetChildComponent("Panel/GuildBoss/Icon", "Image")
		local enemyId = listEnemy[1]
		local infoEnemy = EnemyManager:Get(enemyId)

		UIUtil.SetImageSprite(icon, infoEnemy.data.NameICON, self)
		require("GameLogic/Util/AttributeUtil")

		local attri = AttributeUtil.GetMonsterAttri(1, self.stageId)
		local infoRaid = UnionRaidMgr:GetBossRaidByStageId(self.infoStage.id)
		local txtBlood = self:GetChildComponent("Panel/GuildBoss/TxtBlood", "Text")

		txtBlood.text = infoRaid.progress .. "/" .. attri.maxHp

		local imgHp = self:GetChildComponent("Panel/GuildBoss/BgBar/Image", "Image")

		imgHp.fillAmount = infoRaid.progress / attri.maxHp
	end

	local function func()
		if self.listCellEnemy then
			for i = 1, #self.listCellEnemy do
				self.listCellEnemy[i]:OnLeave()
			end
		end
	end

	local function funcCommon()
		local scrollArea = self:GetChildGameObject("MosterScroll")
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
		funcUnion()
	else
		self.GoMonsters:SetActive(true)
		funcCommon()
	end
end

function DlgCombatReadiness:UpdatePowerPanel()
	local go2 = self:GetChildGameObject("PowerGroup/Image (2)")
	local txtPower = self:GetChildComponent("PowerGroup/TextNum", "Text")
	local imgState = self:GetChildComponent("PowerGroup/Image (2)", "Image")
	local listSE = self.infoStage.data.SafeCE
	local safeCE = 0

	if listSE and listSE[1] and listSE[1][1] then
		safeCE = listSE[1][1]
	end

	txtPower.text = tostring(safeCE)

	if self.chapterType == ChapterFromType.comb or self.infoStage:IsLimit() then
		go2:SetActive(false)
		self.BtnDetail:SetActive(false)
		GOUtil.SetRectTransformSizeDelta(self.GoPower, 300, 74)

		return
	else
		go2:SetActive(true)
		self.BtnDetail:SetActive(true)
		GOUtil.SetRectTransformSizeDelta(self.GoPower, 764, 74)
	end

	local forecastLevel = 1
	local coe = self.teamCE / safeCE

	forecastLevel = coe < 0.2 and 1 or coe < 0.8 and 2 or coe < 1.2 and 3 or coe < 2 and 4 or 5
	self.forecastImagePath = "UI/PanelCombatReadiness/AtlasCombatReadiness/BG_ready_word_advise_0" .. forecastLevel

	UIUtil.SetImageSprite(imgState, self.forecastImagePath, self)
end

function DlgCombatReadiness:InitTeam()
	if self.chapterType == ChapterFromType.comb or self.infoStage:IsLimit() then
		return
	end

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
		infoteam = require("Info.InfoTeamRaid")
		listUpCardId = infoteam:GetUpRoleCardList()
	elseif self.chapterType == ChapterFromType.main or self.chapterType == ChapterFromType.activity or self.chapterType == ChapterFromType.card or self.chapterType == ChapterFromType.tower then
		infoteam = require("Info.InfoTeam")
		listUpCardId = infoteam:GetUpRoleCardList()
		listAddCardId = infoteam:GetAddRoleCardList()
	end

	self.teamCE = self:GetTeamCE(listUpCardId, listAddCardId)
	self.listCardId = listUpCardId
	self.listAddCardId = listAddCardId
end

function DlgCombatReadiness:GetTeamCE(listUpCardId, listAddCardId)
	local sum = 0

	for i = 1, #listUpCardId do
		if listUpCardId[i] ~= 0 then
			local upCard = RoleCardMgr:GetRoleCard(listUpCardId[i])
			local role = RoleMgr:GetRole(upCard.data.CharacterID)
			local addCard

			if listAddCardId[i] ~= 0 then
				addCard = RoleCardMgr:GetRoleCard(listAddCardId[i])
			end

			sum = sum + RoleCardMgr:GetFightValue(role, upCard, addCard)
		end
	end

	return sum
end

function DlgCombatReadiness:UpdateStageSkillPanel()
	local list = OperationActiveMgr:GetAllSkillDataOutside(self.infoStage.id)

	self.GoBuffGroup:SetActive(#list ~= 0)

	local group = self:GetChildGameObject("SkillBuffGroup/Group")

	GOUtil.DestroyAllChildren(group)

	local groupLayout = self:GetChildComponent("SkillBuffGroup/Group", "LayoutGroup")
	local goSkill = self:GetChildGameObject("SkillBuffGroup/Skill")

	self.listGoSkill = {}

	for i = 1, #list do
		local cell = GOUtil.Instantiate(goSkill, group)
		local icon = GOUtil.GetComponent(cell, "Image")
		local txt = GOUtil.FindChildComponent(cell, "Image/Text", "Text")
		local skillId = list[i].SkillId
		local info = TalentManager:Get(skillId)

		UIUtil.SetImageSprite(icon, "UIDyAtlas/Skill/" .. info.data.Icon, self)

		txt.text = OperationActiveMgr:GetStrLeftDay(list[i].ID)
		cell.name = i

		self:AddClick(cell, self.OnPressStageSkillDown)
		table.insert(self.listGoSkill, cell)
	end

	goSkill:SetActive(false)
end

function DlgCombatReadiness:OnPressStageSkillDown(data)
	local go = data.pointerPressRaycast.gameObject
	local index = tonumber(go.name)
	local list = OperationActiveMgr:GetAllSkillDataOutside(self.infoStage.id)
	local skillId = list[index].SkillId
	local limitData = OperationActiveMgr:GetStrSkillTipDesc(list[index].Params)
	local timeData = OperationActiveMgr:GetStrLeftHour(list[index].ID)
	local tipData = SkillTip.GetStageSkillBuffData(data.position, skillId, true, timeData, limitData)

	UIMgr.ShowSkillTip(tipData)
end

function DlgCombatReadiness:UpdateBeginPanel()
	local limitNum = self.infoStage:IsLimitPlayNum()
	local txtChallengeNum = self:GetChildComponent("DownGroup/Text (1)", "Text")

	if limitNum and self.infoStage.data.Type ~= 8 then
		txtChallengeNum.text = Lang(5000008) .. self.infoStage:GetLeftPlayNum() .. "/" .. self.infoStage:GetMaxLeftPlayNum()
	else
		txtChallengeNum.text = Lang(5000008) .. "∞/∞"
	end

	local goText = self:GetChildGameObject("DownGroup/BtnChallenge/Text")
	local imgCostIcon = self:GetChildComponent("DownGroup/BtnChallenge/Image", "Image")
	local txtCostNum = self:GetChildComponent("DownGroup/BtnChallenge/TextNum", "Text")
	local costItem = self.infoStage:GetCostItem()

	imgCostIcon.gameObject:SetActive(#costItem ~= 0)
	txtCostNum.gameObject:SetActive(#costItem ~= 0)

	if #costItem ~= 0 then
		UIUtil.SetImageSprite(imgCostIcon, costItem[1]:GetIcon(), self)

		txtCostNum.text = costItem[2]

		GOUtil.SetTransformLocalPosition(goText, 50, 0, 0)
	else
		GOUtil.SetTransformLocalPosition(goText, 0, 0, 0)
	end
end

function DlgCombatReadiness:OnClickedBtnChallenge()
	if self.chapterType == 4 then
		local infoActive = ActiveMgr:GetActiveInfoByStageData(self.infoStage.data)
		local isCanPlay, msg = infoActive:IsPlayOpen()

		if not isCanPlay then
			UIMgr.ShowMsg(msg)

			return
		end
	end

	local leftNum = ChapterMgr:GetStageLeftPlayNumWithLimit(self.infoStage.id)

	if leftNum ~= -1 and leftNum == 0 then
		UIMgr.ShowMsg(_("Msg_Cnt_NotEnough"))

		return
	end

	PersistentStoreUtil.SetStageEnter(self.infoStage.data.ID, true)
	self:Close()
	Event.Instance:Fire(EventEnum.EnterStage, {
		stype = 1,
		infoStage = self.infoStage
	})
end

function DlgCombatReadiness:OnClickedBtnSweep()
	if not self.infoStage:IsFullStar() then
		UIMgr.ShowMsg(_("PageBattleTeam_SweepLock"))

		return
	end

	local leftNum = ChapterMgr:GetStageLeftPlayNumWithLimit(self.infoStage.id)

	if leftNum ~= -1 and leftNum == 0 then
		UIMgr.ShowMsg(_("Msg_Cnt_NotEnough"))

		return
	end

	self:Close()
	UIMgr.AddPanel(DlgStageSweep(), {
		infoStage = self.infoStage,
		requireItem = ItemManager:GetSweepItem()
	})
end

local function GetStageIdx(list, stageId)
	for i = 1, #list do
		if stageId == list[i].id then
			return i
		end
	end

	return 1
end

function DlgCombatReadiness:UpdateChangeArrow()
	self.GoArrow:SetActive(self.chapterType ~= ChapterFromType.union)

	if self.listChangeStage and #self.listChangeStage > 0 then
		local stageIdx = GetStageIdx(self.listChangeStage, self.stageId)

		self.BtnL:SetActive(stageIdx ~= 1)
		self.BtnR:SetActive(stageIdx ~= #self.listChangeStage)
	end
end

function DlgCombatReadiness:OnClickedBtnLeft()
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
end

function DlgCombatReadiness:OnClickedBtnRight()
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
end

function DlgCombatReadiness:OnLongPressStarBox(data)
	if data.clickCount == 1 then
		self.GoStarGroup:SetActive(true)
	else
		self.GoStarGroup:SetActive(false)
	end
end

function DlgCombatReadiness:OnClickedGoAdditional()
	if self.infoStage.data.BattleStageID ~= 0 then
		UIMgr.AddPanel(DlgMayFall(), {
			infoStage = self.infoStage
		})
	end
end

function DlgCombatReadiness:OnClickedGoBossKill()
	local info = UnionRaidMgr:GetBossRaidByStageId(self.infoStage.id)

	UIMgr.AddPanel(DlgRaidAwardRecord(), {
		type = 2,
		raidId = info.id
	})
end

function DlgCombatReadiness:OnClickedBtnDetail()
	UIMgr.AddPanel(DlgForecast(), {
		infoStage = self.infoStage,
		listRoleCardId = self.listCardId,
		listAddCardId = self.listAddCardId,
		teamCE = self.teamCE,
		forecastImagePath = self.forecastImagePath
	})
end

function DlgCombatReadiness:OnClickedBtnClose()
	self:Close()
end

function DlgCombatReadiness:UpdateStage()
	self:SetRewardSpecialPanel()
	self:UpdateBeginPanel()
	self:UpdateStageSkillPanel()
end

function DlgCombatReadiness:OnClickedStageLimitHide()
	self.StageLimit:SetActive(false)
end

function DlgCombatReadiness:OnClickedStageLimitShow()
	self.StageLimit:SetActive(true)
end
