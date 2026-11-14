-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageTimeSpace/PageTimeSpaceStage.lua

require("UI/Page/PageTower/CellTowerTab")
require("UI/Page/PageCombatReadiness/CellMonster")
require("UI/Page/PageTeam/PageTeam")
require("UI/Page/PageCombatReadiness/DlgForecast")

PageTimeSpaceStage = class("PageTimeSpaceStage", UIPanel)

local normalTitalPath = "UI/PageTower/AtlasPageTower/BG_tower_frame_01"
local hardTitalPath = "UI/PageTower/AtlasPageTower/BG_tower_frame_01b"
local normalBgPath = "Texture/PanelBG/BG_tower_03"
local hardBgPath = "Texture/PanelBG/BG_tower_03b"

function PageTimeSpaceStage:ctor(chapter)
	self.UIPrefabPath = "UI/PageTimeSpace/PageTimeSpaceStage"
	chapter = chapter or TimeSpaceChapterMgr:GetCurrChapter()

	self:AddChildPanel(DlgExit(), {
		title = chapter and Lang(chapter.data.Name) or _("eReturn_TimeSpace"),
		callback = self.OnBack,
		helpCallback = self.OnClickedGuideBtn,
		panel = self
	})
	self:AddChildPanel(DlgAssetsInfo())
end

function PageTimeSpaceStage:OnBack()
	UIMgr.PopPanel()
end

function PageTimeSpaceStage:PreLoad()
	self:LoadResAsync("UI/PageTower/CellTowerTab", "PrefabCellTowerTab", GameObject)
	self:LoadResAsync("UI/PanelCombatReadiness/CellMonster", "PrefabMonster")
	self:LoadResAsync("UI/Item/CellItem", "PrefabCellItem")
end

function PageTimeSpaceStage:Purge()
	self.base.Purge(self)
	ResourceMgr.Unload(self.PrefabCellTowerTab)
	ResourceMgr.Unload(self.PrefabMonster)
	ResourceMgr.Unload(self.PrefabCellItem)

	if self.listItem then
		for i = 1, #self.listItem do
			self.listItem[i]:OnLeave()
		end
	end

	if self.listCellEnemy then
		for i = 1, #self.listCellEnemy do
			self.listCellEnemy[i]:OnLeave()
		end
	end

	if self.listCellCard then
		for i = 1, #self.listCellCard do
			self.listCellCard[i]:OnLeave()
		end
	end

	if self.listCellItem then
		for i = 1, #self.listCellItem do
			self.listCellItem[i]:OnLeave()
		end
	end

	if self.UITabScrollTool then
		self.UITabScrollTool:Purge()
	end

	self.UITabScrollTool = nil
end

function PageTimeSpaceStage:OnRegisterEvent()
	self:AddClick(self.GetBtn, self.OnClickGetAward)
	self:AddClick(self.Arrow, self.OnClickedBtnDetail)
	self:AddClick(self.BattleBtn, self.OnClickedBtnChallenge)
	self:AddClick(self.ResetBtn, self.OnClickBtnReset)
	Event.Instance:Add("ClickPoolTab", self.OnClickPoolTab, self)
	UIMgr.SetUpdatePanel(self)
end

function PageTimeSpaceStage:OnUnRegisterEvent()
	self:RemoveClick(self.GetBtn, self.OnClickGetAward)
	self:RemoveClick(self.Arrow, self.OnClickedBtnDetail)
	self:RemoveClick(self.BattleBtn, self.OnClickedBtnChallenge)
	Event.Instance:Remove("ClickPoolTab", self.OnClickPoolTab, self)
	UIMgr.RemoveUpdatePanel(self)
end

function PageTimeSpaceStage:OnEnter(vParam)
	self.infoChapter = vParam.chapter
	self.RawImage = self:GetChildComponent("BG/RawImage", "RawImage")
	self.StageImage = self:GetChildComponent("Panel/Left/StageImage", "Image")
	self.PDot = self:GetChildGameObject("Panel/Left/GetBtn/PDot")
	self.Fill = self:GetChildComponent("Panel/Left/Progress/Fill", "Image")
	self.ProgressText = self:GetChildComponent("Panel/Left/Progress/Text", "Text")
	self.IsGet = self:GetChildGameObject("Panel/Left/IsGet")
	self.GetBtn = self:GetChildGameObject("Panel/Left/GetBtn")
	self.ImgGet = self:GetChildComponent("Panel/Left/GetBtn", "Image")
	self.Desc = self:GetChildComponent("Panel/Left/Desc", "Text")
	self.TitalImg = self:GetChildComponent("Panel/Right/Tital", "Image")
	self.Tital = self:GetChildComponent("Panel/Right/Tital/Text", "Text")
	self.Arrow = self:GetChildGameObject("Panel/Right/Power/Arrow")
	self.PowerNum = self:GetChildComponent("Panel/Right/Power/PowerNum/Num", "Text")
	self.PowerImage = self:GetChildComponent("Panel/Right/Power/PowerImage/Image", "Image")
	self.Finish = self:GetChildGameObject("Panel/Right/Finish")
	self.BattleBtn = self:GetChildGameObject("Panel/Right/BattleBtn")
	self.noCardTip = self:GetChildComponent("Panel/Left/NoCardProper", "Text")
	self.ImgGeted2 = self:GetChildGameObject("Panel/Left/Reward/DailyAward/ImgGeted2")
	self.listStage = self.infoChapter.listStage
	self.ResetBtn = self:GetChildGameObject("Panel/Left/ResetBtn")
	self.ResetBtnImg = self:GetChildComponent("Panel/Left/ResetBtn", "Image")
	self.ResetBtnTxt = self:GetChildComponent("Panel/Left/ResetBtn/Text", "Text")
	self.ResetBtnTxt.text = _("TimeSpace_Reset")
	self.txtReset = self:GetChildComponent("Panel/txt_resettime", "Text")

	local timeStr = TimeSpaceChapterMgr:GetResetTimeString()

	self.txtReset.text = _("Desc_last_time") .. ": " .. timeStr
	self.listItem = {}

	for i = 1, 3 do
		local gItem = self:GetChildGameObject("Panel/Left/Reward/CellItem" .. i)
		local item = CellItem(gItem)

		item:InitItemByRoot(gItem)
		table.insert(self.listItem, item)
	end

	self.DailyAward = self:GetChildGameObject("Panel/Left/Reward/DailyAward")
	self.AddText = self:GetChildComponent("Panel/Left/Reward/DailyAward/AddText", "Text")

	self:DealWithLocalization()

	self.selectIndex = 1
	self.infoStage = self.listStage[1]

	for i, v in ipairs(self.listStage) do
		if v:IsOpen() and not v:IsPass() and v.data.ID <= TimeSpaceChapterMgr.CurStageId + 1 and TimeSpaceChapterMgr.CurChapterId == self.infoChapter.data.ID then
			self.infoStage = v
			self.selectIndex = i
		end
	end

	if self.listStage[#self.listStage]:IsPass() then
		self.selectIndex = #self.listStage
		self.infoStage = self.listStage[#self.listStage]
	end

	self:InitTabScrollView()
	self:UpdateChapterInfo()
	self:UpdateStageInfo()
end

function PageTimeSpaceStage:InitTabScrollView()
	local ScrollArea = self:GetChildGameObject("Panel/ScrollArea2")
	local content = self:GetChildComponent("Panel/ScrollArea2/Content", "Transform")
	local count = #self.listStage

	local function addClick(item)
		item:OnRegisterEvent()
	end

	local function updateTab(item, index)
		item.Index = index

		local info = {}

		info.tabName = Lang(self.listStage[index].data.Name)
		info.unlock = self.infoChapter.completed and true or self.listStage[index]:IsPass() or index == 1 or index > 1 and TimeSpaceChapterMgr.CurChapterId == self.infoChapter.data.ID and self.listStage[index].data.ID <= TimeSpaceChapterMgr.CurStageId + 1

		item:UpdateData(info, self.selectIndex)
	end

	self.UITabScrollTool = UIScrollTool()

	self.UITabScrollTool:InitList(ScrollArea, content, count, self.PrefabCellTowerTab, CellTowerTab, self, false, addClick, updateTab)

	local pos = GetContentPos(self.UITabScrollTool.ScrollView, #self.listStage, self.selectIndex, true)

	self.UITabScrollTool:SetInitPos(Vector3(0, pos, 0))
end

function PageTimeSpaceStage:DealWithLocalization()
	local txt

	txt = self:GetChildComponent("Panel/Left/Tip", "Text")
	txt.text = _("Desc_PageTimeSpaceStageTip")
	txt = self:GetChildComponent("Panel/Left/DescTital/Text", "Text")
	txt.text = _("Desc_PageTimeSpaceStageDesc")
	txt = self:GetChildComponent("Panel/Left/CardTital/Text", "Text")
	txt.text = _("Desc_TowerStageCard")
	txt = self:GetChildComponent("Panel/Right/Enemy/Text", "Text")
	txt.text = _("Desc_PageTimeSpaceStageEnemy")
	txt = self:GetChildComponent("Panel/Right/Award/Text", "Text")
	txt.text = _("Desc_TowerBaseAward")
	txt = self:GetChildComponent("Panel/Right/Power/PowerNum/Text", "Text")
	txt.text = string.format(_("Desc_CombatReadiness_RecommendFightingCapacity"), "")
	txt = self:GetChildComponent("Panel/Right/Power/PowerImage/Text", "Text")
	txt.text = _("Desc_CombatReadiness_EstimateSituation")
	txt = self:GetChildComponent("Panel/Right/BattleBtn/Text", "Text")
	txt.text = _("Btn_Fight")
	txt = self:GetChildComponent("Panel/Right/Enemy/Tip", "Text")
	txt.text = _("Desc_EnemyPressTip")
	txt = self:GetChildComponent("Panel/Left/Reward/DailyAward/Text", "Text")
	txt.text = _("Desc_TowerDaily")
	self.noCardTip.text = _("PageTimespaceStage_NoProperCard")
end

function PageTimeSpaceStage:UpdateMonster()
	local listEnemy = self.infoStage.listMonster
	local scrollArea = self:GetChildGameObject("Panel/Right/Enemy/Monsters/")
	local scrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")

	scrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "RectTransform")
	scrollView.horizontal = true

	GOUtil.DestroyAllChildren(scrollView.content.gameObject)

	if self.listCellEnemy then
		for i = 1, #self.listCellEnemy do
			self.listCellEnemy[i]:OnLeave()
		end
	end

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

function PageTimeSpaceStage:UpdateChapterInfo()
	local isGet = self.infoChapter.pb.awardStatus[3] == 1
	local itemList = self.infoChapter.data.GoldAwardList

	for i, v in ipairs(self.listItem) do
		if i <= #itemList then
			SetActiveFunc(self.listItem[i].UIRootObject, true)

			local item = ItemManager:GetValueItem(itemList[i][1], itemList[i][2])

			v:UpdateWithNumType(item)
			v:SetGetedGreen(isGet)
		else
			SetActiveFunc(self.listItem[i].UIRootObject, false)
		end
	end

	SetActiveFunc(self.IsGet, isGet)
	SetActiveFunc(self.GetBtn, not isGet)

	self.Desc.text = Lang(self.infoChapter.data.Title)
	self.num = 0
	self.total = #self.infoChapter.listStage

	for i, v in ipairs(self.infoChapter.listStage) do
		if v:IsPass() or v:GetStar() > 0 then
			self.num = self.num + 1
		end
	end

	self.num = isGet and self.total or self.num
	self.Fill.fillAmount = self.num / self.total
	self.ProgressText.text = self.num .. "<size= 28>/" .. self.total .. "</size>"

	SetActiveFunc(self.PDot, self.num == self.total)
	SetActiveFunc(self.ImgGeted2, self.num == self.total)

	local addItem = TowerChapterMgr:GetAddDailyItemNum(self.infoChapter.data.ID)

	if addItem then
		self.AddText.text = ""

		SetActiveFunc(self.DailyAward, true)
	else
		SetActiveFunc(self.DailyAward, false)
	end

	self:UpdateCard()
	UIUtil.SetImageSprite(self.StageImage, self.infoChapter.data.Icon, self)
	UIUtil.SetRawImageTexture(self.RawImage, TenaryOp(self.infoChapter.data.Type == ChapterFromType.tower, normalBgPath, hardBgPath), self)
	UIUtil.SetImageSprite(self.TitalImg, TenaryOp(self.infoChapter.data.Type == ChapterFromType.tower, normalTitalPath, hardTitalPath), self)

	local gray = TenaryOp(self.num == self.total, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgGet, gray))

	if self.infoChapter.completed then
		DealWithListRef(self, UIUtil.SetImageGray(self.ResetBtnImg, 1))
	end
end

function PageTimeSpaceStage:UpdateChapterInfoTiny()
	local isGet = self.infoChapter.pb.awardStatus[3] == 1
	local itemList = self.infoChapter.data.GoldAwardList

	for i, v in ipairs(self.listItem) do
		if i <= #itemList then
			SetActiveFunc(self.listItem[i].UIRootObject, true)

			local item = ItemManager:GetValueItem(itemList[i][1], itemList[i][2])

			v:UpdateWithNumType(item)
			v:SetGetedGreen(isGet)
		else
			SetActiveFunc(self.listItem[i].UIRootObject, false)
		end
	end

	SetActiveFunc(self.IsGet, isGet)
	SetActiveFunc(self.GetBtn, not isGet)

	self.Desc.text = Lang(self.infoChapter.data.Title)
	self.num = 0
	self.total = #self.infoChapter.listStage

	for i, v in ipairs(self.infoChapter.listStage) do
		if v:IsPass() or v:GetStar() > 0 then
			self.num = self.num + 1
		end
	end

	self.num = isGet and self.total or self.num
	self.Fill.fillAmount = self.num / self.total
	self.ProgressText.text = self.num .. "<size= 28>/" .. self.total .. "</size>"

	SetActiveFunc(self.PDot, self.num == self.total)
	SetActiveFunc(self.ImgGeted2, self.num == self.total)

	local addItem = TowerChapterMgr:GetAddDailyItemNum(self.infoChapter.data.ID)

	if addItem then
		self.AddText.text = ""

		SetActiveFunc(self.DailyAward, true)
	else
		SetActiveFunc(self.DailyAward, false)
	end

	UIUtil.SetImageSprite(self.StageImage, self.infoChapter.data.Icon, self)
	UIUtil.SetRawImageTexture(self.RawImage, TenaryOp(self.infoChapter.data.Type == ChapterFromType.tower, normalBgPath, hardBgPath), self)
	UIUtil.SetImageSprite(self.TitalImg, TenaryOp(self.infoChapter.data.Type == ChapterFromType.tower, normalTitalPath, hardTitalPath), self)

	local gray = TenaryOp(self.num == self.total, 0, 1)

	DealWithListRef(self, UIUtil.SetImageGray(self.ImgGet, gray))

	if self.infoChapter.completed then
		DealWithListRef(self, UIUtil.SetImageGray(self.ResetBtnImg, 1))
	end
end

function PageTimeSpaceStage:UpdateStageInfo()
	local isPass = self.infoStage:IsPass()
	local isOpen = self.infoStage:IsOpen()

	SetActiveFunc(self.BattleBtn, not self.infoChapter.completed and (self.infoStage.data.ID <= TimeSpaceChapterMgr.CurStageId + 1 and TimeSpaceChapterMgr.CurChapterId == self.infoChapter.data.ID or TimeSpaceChapterMgr.CurChapterId ~= self.infoChapter.data.ID and self.selectIndex == 1))
	SetActiveFunc(self.Finish, self.complete)

	self.Tital.text = Lang(self.infoChapter.data.Name) .. "　" .. Lang(self.infoStage.data.Name)

	self:InitTeam()
	self:UpdateStar()
	self:UpdateMonster()
	self:UpdatePowerPanel()
end

function PageTimeSpaceStage:UpdateCard()
	local listProperCard = self.infoChapter.data.ProperCard
	local scrollArea = self:GetChildGameObject("Panel/Left/Card")
	local scrollView = GOUtil.AddMissingComponent(scrollArea, "UIScrollView")

	scrollView.content = GOUtil.FindChildComponent(scrollArea, "Content", "RectTransform")
	scrollView.horizontal = true
	self.listCellCard = {}

	for i = 1, #listProperCard do
		local cell = CellItem(self.PrefabCellItem, scrollView.content.gameObject, self)
		local infoItem = ItemManager:GetValueItem(10100, listProperCard[i])

		cell:Create()

		cell.noClick = true

		cell:UpdateNoNumType(infoItem)

		local scrollViewContent = GOUtil.AddMissingComponent(cell.UIRootObject, "UIScrollViewContent")

		scrollViewContent.scrollView = scrollView

		table.insert(self.listCellCard, cell)
	end

	SetActiveFunc(self.noCardTip.gameObject, #listProperCard == 0)
end

function PageTimeSpaceStage:UpdateStar()
	local star = self.infoStage.pb.stars
	local starNum = 0

	for i = 1, 3 do
		if star[i] == 1 then
			starNum = starNum + 1
		end
	end

	for i = 1, 3 do
		local goStar = self:GetChildComponent("Panel/Right/Award/Awards/Content/Condtion" .. i .. "/Star", "Image")
		local txtCon = self:GetChildComponent("Panel/Right/Award/Awards/Content/Condtion" .. i .. "/Text", "Text")
		local img_recv = self:GetChildGameObject("Panel/Right/Award/Awards/Content/Condtion" .. i .. "/img_recv")

		UIUtil.SetImageOverrideSprite(goStar, star[i] == 1 and "UI/PageTimeSpace/AtlasPageTimeSpace/ICO_star_01" or "UI/PageTimeSpace/AtlasPageTimeSpace/ICO_star_02", false)
		img_recv:SetActive(star[i] == 1)
		ChapterMgr:SetStageAch(self.infoStage.data.Grade[i], txtCon)
	end
end

function PageTimeSpaceStage:OnClickPoolTab(index)
	if index == self.selectIndex then
		return
	end

	self.selectIndex = index

	self.UITabScrollTool:UpdateListDataKeepPos(self.listStage)

	self.infoStage = self.listStage[index]

	self:UpdateStageInfo()
end

function PageTimeSpaceStage:UpdatePowerPanel()
	local listSE = self.infoStage.data.SafeCE
	local safeCE = 0

	if listSE and listSE[1] and listSE[1][1] then
		safeCE = listSE[1][1]
	end

	self.PowerNum.text = tostring(safeCE)

	local forecastLevel = 1
	local coe = self.teamCE / safeCE
	local config = GetConfigArgJson("BattleEstimate")

	forecastLevel = coe < config[1] and 1 or coe < config[2] and 2 or coe < config[3] and 3 or coe < config[4] and 4 or 5
	self.forecastImagePath = "UI/PanelCombatReadiness/AtlasCombatReadiness/BG_ready_word_advise_0" .. forecastLevel

	SetImageSprite(self.PowerImage, self.forecastImagePath, self)
end

function PageTimeSpaceStage:InitTeam()
	self.teamCE = 0

	local infoteam = require("Info/InfoTeam")
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

	listUpCardId = infoteam:GetUpRoleCardList()
	listAddCardId = infoteam:GetAddRoleCardList()
	self.teamCE = self:GetTeamCE(listUpCardId, listAddCardId)
	ChapterMgr.teamCE = self.teamCE
	self.listCardId = listUpCardId
	self.listAddCardId = listAddCardId
end

function PageTimeSpaceStage:GetTeamCE(listUpCardId, listAddCardId)
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

function PageTimeSpaceStage:OnClickedBtnDetail()
	UIMgr.AddPanel(DlgForecast(), {
		infoStage = self.infoStage,
		listRoleCardId = self.listCardId,
		listAddCardId = self.listAddCardId,
		teamCE = self.teamCE,
		forecastImagePath = self.forecastImagePath
	})
end

function PageTimeSpaceStage:OnClickBtnReset()
	if self.infoChapter.completed then
		return
	end

	if TimeSpaceChapterMgr.CurChapterId ~= self.infoChapter.data.ID or TimeSpaceChapterMgr.CurChapterId == 0 then
		return
	end

	local function wrap_cb(idx)
		if idx == 1 then
			LoadingMgr.Show(eLoadingType.Repeat)
			NetManager:ResetTimespaceChapter(function(msg)
				LoadingMgr.Hide(eLoadingType.Repeat)

				self.selectIndex = 1
				self.infoStage = self.listStage[1]

				for i, v in ipairs(self.listStage) do
					if v:IsOpen() and not v:IsPass() and v.data.ID <= TimeSpaceChapterMgr.CurStageId + 1 then
						self.infoStage = v
						self.selectIndex = i
					end
				end

				if self.listStage[#self.listStage]:IsPass() then
					self.selectIndex = #self.listStage
					self.infoStage = self.listStage[#self.listStage]
				end

				if self.UITabScrollTool then
					self.UITabScrollTool:RefreshAllCell()
				end

				self:UpdateChapterInfoTiny()
				self:UpdateStageInfo()
			end)
		end
	end

	UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), _("PageTimespaceStage_Reset"), wrap_cb, _("UI_confirm"), _("Quite_Cancel"), true)
end

function PageTimeSpaceStage:OnClickedBtnChallenge()
	if TimeSpaceChapterMgr.CurChapterId ~= 0 and self.infoChapter.data.ID ~= TimeSpaceChapterMgr.CurChapterId then
		local function wrap_cb(idx)
			if idx == 1 then
				LoadingMgr.Show(eLoadingType.Repeat)
				NetManager:ResetTimespaceChapter(function(msg)
					LoadingMgr.Hide(eLoadingType.Repeat)
					self:OnClickedBtnChallenge()
				end)
			end
		end

		local otherChapter = TimeSpaceChapterMgr:GetTowerChapterByChapter(TimeSpaceChapterMgr.CurChapterId)
		local isComplete = otherChapter and otherChapter.completed or false

		UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), isComplete and _("PageTimespaceStage_ResetComplete") or _("PageTimespaceStage_ResetNotComplete"), wrap_cb, _("UI_confirm"), _("Quite_Cancel"), true)

		return
	elseif TimeSpaceChapterMgr.CurChapterId == 0 then
		UIMgr.ShowCommon(DlgCommonEvent.Type.Msg, _("Desc_Alert"), _("PageTimespaceStage_Start"), function(idx)
			if idx == 1 then
				if not self.isChallenge then
					self.isChallenge = true
				else
					return
				end

				local infoTeam = require("Info/InfoTeamTimespace")

				local function callback(...)
					UIMgr.SwitchPanel(PageTeam, infoTeam.teamSystemAgent)
				end

				if infoTeam then
					infoTeam:EnterStage(self.infoStage)
					callback()
				end
			end
		end, _("UI_confirm"), _("Quite_Cancel"), true)

		return
	end

	if not self.isChallenge then
		self.isChallenge = true
	else
		return
	end

	local infoTeam = require("Info/InfoTeamTimespace")

	local function callback(...)
		UIMgr.SwitchPanel(PageTeam, infoTeam.teamSystemAgent)
	end

	if infoTeam then
		infoTeam:EnterStage(self.infoStage)
		callback()
	end
end

function PageTimeSpaceStage:OnClickGetAward()
	if self.num ~= self.total then
		UIMgr.ShowMsg(_("PageTimespaceStage_NotAward"))

		return
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestGetChapterAward(self.infoChapter.data.ID, {
		2
	}, function(vMsg)
		if vMsg.result.code == NetManager.Result_Sucess then
			SetActiveFunc(self.GetBtn, false)
			SetActiveFunc(self.IsGet, true)

			self.infoChapter.pb.awardStatus[3] = 1

			local itemList = self.infoChapter.data.GoldAwardList

			for i, v in ipairs(self.listItem) do
				if i <= #itemList then
					v:SetGetedGreen(true)
				end
			end

			ChapterRDL.TowerRDL.SubPassAward(self.infoChapter)
		else
			UIMgr.ShowMsg(vMsg.result.desc, vMsg)
		end

		LoadingMgr.Hide(eLoadingType.Repeat)
	end)
end

function PageTimeSpaceStage:OnUpdateSecond()
	if not self.txtReset or self.needReboot then
		return
	end

	local timeStr, needRefresh = TimeSpaceChapterMgr:GetResetTimeString()

	self.txtReset.text = _("Desc_last_time") .. ": " .. timeStr

	if needRefresh then
		self.needReboot = true

		UIMgr.ShowDialog(_("TimeSpace_Refresh"), function()
			UIMgr.PopPanel(nil, 2)
		end)
	end
end
