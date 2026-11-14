-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/pagePVP/PageRewardShow.lua

require("UI/Page/pagePVP/CellPVPGradeReward")
require("UI/Page/pagePVP/CellPVPRankReward")

local InfoPVP = require("Info/InfoPVP")

PageRewardShow = class("PageRewardShow", UIPanel)

function PageRewardShow:ctor()
	self.UIPrefabPath = "UI/PanelPVP/PanelRewardShow"
end

function PageRewardShow:PreLoad()
	self.cellGradePreLoad = ResourceMgr.LoadSync("UI/PanelPVP/CellGradeReward")
	self.cellRankPreLoad = ResourceMgr.LoadSync("UI/PanelPVP/CellRankReward")
end

function PageRewardShow:Purge()
	PageRewardShow.base.Purge(self)

	if self.cellGradePreLoad then
		ResourceMgr.Unload(self.cellGradePreLoad)

		self.cellGradePreLoad = nil
	end

	if self.cellRankPreLoad then
		ResourceMgr.Unload(self.cellRankPreLoad)

		self.cellRankPreLoad = nil
	end

	if self.UIScrollToolGrade then
		self.UIScrollToolGrade:Purge()
	end

	if self.UIScrollToolRank then
		self.UIScrollToolRank:Purge()
	end

	self.uiTab:Dispose()

	for i = 1, 5 do
		self.myRankRewards[i]:OnLeave()
	end
end

function PageRewardShow:OnRegisterEvent()
	self:AddClick(self.closeBtn, self.OnClickedBtnQuit)
	Event.Instance:Add("changerward", self.RefashScroll, self)
	Event.Instance:Add("PVPAutoClose", self.OnClickedBtnQuit, self)
end

function PageRewardShow:OnUnRegisterEvent()
	self:RemoveClick(self.closeBtn, self.OnClickedBtnQuit)
	Event.Instance:Remove("changerward", self.RefashScroll, self)
	Event.Instance:Remove("PVPAutoClose", self.OnClickedBtnQuit, self)
end

function PageRewardShow:RefashScroll()
	self.listGrade = {}
	self.listGrade = InfoPVP:GetAllSeasonRankRewarddata()

	self.UIScrollToolGrade:UpdateListDataKeepPos(self.listGrade)
end

function PageRewardShow:OnEnter(vParam)
	self.closeBtn = self:GetChildGameObject("Panel/BtnClose")
	self.tabGo = self:GetChildGameObject("Panel/Tab")
	self.uiTab = UITab(self.tabGo, 2, self.TabClick, self, vParam)
	self.gradePanel = self:GetChildGameObject("Panel/GradePanel")
	self.gradeIcon = self:GetChildComponent("Panel/GradePanel/Left/GradeIcon", "Image")
	self.gradeName = self:GetChildComponent("Panel/GradePanel/Left/GradeIcon/Text", "Text")
	self.BigProg = self:GetChildComponent("Panel/GradePanel/Left/BigSeasonProg/Prog", "Text")
	self.NextGradeName = self:GetChildComponent("Panel/GradePanel/Left/RankScore/GradeName", "Text")
	self.NextGradeIcon = self:GetChildComponent("Panel/GradePanel/Left/RankScore/GradeName/GradeIcon", "Image")
	self.gradeTime = self:GetChildComponent("Panel/GradePanel/Left/Time/Text", "Text")
	self.gradeProg = self:GetChildComponent("Panel/GradePanel/Left/RankScore/Bar/Fill", "Image")
	self.myScore = self:GetChildComponent("Panel/GradePanel/Left/RankScore/CurScore", "Text")
	self.GradeNameMax = self:GetChildGameObject("Panel/GradePanel/Left/RankScore/GradeNameMax")
	self.subGradeSeasonName = self:GetChildComponent("Panel/GradePanel/Left/Time/TextName", "Text")
	self.Next = self:GetChildGameObject("Panel/GradePanel/Left/RankScore/Next")
	self.rankPanel = self:GetChildGameObject("Panel/RankPanel")
	self.headIcon = self:GetChildComponent("Panel/RankPanel/Left/HeadIcon/Image", "Image")
	self.headIconBox = self:GetChildComponent("Panel/RankPanel/Left/HeadIcon/ImageBox", "Image")
	self.name = self:GetChildComponent("Panel/RankPanel/Left/Name/Value", "Text")
	self.rank = self:GetChildComponent("Panel/RankPanel/Left/Rank/Value", "Text")
	self.rankTime = self:GetChildComponent("Panel/RankPanel/Left/Time/Text", "Text")
	self.tabGoRank = self:GetChildGameObject("Panel/Tab/Btn2")
	self.SeasonName = self:GetChildComponent("Panel/RankPanel/Left/Tital/Text", "Text")
	self.subRankSeasonName = self:GetChildComponent("Panel/RankPanel/Left/Time/TextName", "Text")
	self.NoRank = self:GetChildGameObject("Panel/RankPanel/Left/NoRank")
	self.myRankRewards = {}

	for i = 1, 5 do
		local itemGo = self:GetChildGameObject("Panel/RankPanel/Left/Reward/" .. i)
		local itemCell = CellItem(itemGo)

		itemCell:InitItemByRoot(itemGo)

		itemCell.itemCell = itemCell
		itemCell.itemGo = itemGo

		table.insert(self.myRankRewards, itemCell)
	end

	self.Seasondata = InfoPVP:GetSeasondata()

	UIMgr.SetUpdatePanel(self)

	self.listRank = InfoPVP:GetAllSubSeasonRankRewarddata()
	self.listGrade = InfoPVP:GetAllSeasonRankRewarddata()

	self:InitScroll()
	self:UpdateUI(vParam)
	self:OnUpdateSecond()
	self:TabClick()
	self:Localization()
end

function PageRewardShow:Localization()
	local TextAuto

	TextAuto = self:GetChildComponent("Panel/Title/Text", "Text")
	TextAuto.text = _("PageChapter_Award")

	GOUtil.SetFont(TextAuto, UIMgr.JPFonts.YukiB)

	TextAuto = self:GetChildComponent("Panel/Tab/Btn1/Select/Text", "Text")
	TextAuto.text = _("Desc_Rank")
	TextAuto = self:GetChildComponent("Panel/Tab/Btn1/1/Text", "Text")
	TextAuto.text = _("Desc_Rank")
	TextAuto = self:GetChildComponent("Panel/Tab/Btn2/Select/Text", "Text")
	TextAuto.text = _("Desc_RankName")
	TextAuto = self:GetChildComponent("Panel/Tab/Btn2/2/Text", "Text")
	TextAuto.text = _("Desc_RankName")
	TextAuto = self:GetChildComponent("Panel/RankPanel/Left/Name/Text", "Text")
	TextAuto.text = _("PageRole_TagName")
	TextAuto = self:GetChildComponent("Panel/RankPanel/Left/Image/Text", "Text")
	TextAuto.text = _("Desc_CurrentRankAward")
	TextAuto = self:GetChildComponent("Panel/RankPanel/Right/Text (1)", "Text")
	TextAuto.text = _("Desc_CurrentRankAward")
	TextAuto = self:GetChildComponent("Panel/GradePanel/Right/Text (1)", "Text")
	TextAuto.text = _("Desc_RewardBrowsing")
	TextAuto = self:GetChildComponent("Panel/RankPanel/Right/Text (2)", "Text")
	TextAuto.text = _("Desc_RewardFromEmail")
	TextAuto = self:GetChildComponent("Panel/RankPanel/Left/NoRank/Text", "Text")
	TextAuto.text = _("Desc_NoPVPRank")
	TextAuto = self:GetChildComponent("Panel/RankPanel/Left/NoRank/Tip", "Text")
	TextAuto.text = _("Desc_NoPVPRankTip")
	TextAuto = self:GetChildComponent("Panel/GradePanel/Left/BigSeasonProg/Text (1)", "Text")
	TextAuto.text = _("Desc_SeasonProgress")
	TextAuto = self:GetChildComponent("Panel/GradePanel/Left/RankScore/Next", "Text")
	TextAuto.text = _("Desc_Promotion")
	TextAuto = self:GetChildComponent("Panel/GradePanel/Left/RankScore/GradeNameMax", "Text")
	TextAuto.text = _("Desc_PVPGradeMax")
	TextAuto = self:GetChildComponent("Panel/GradePanel/Left/Text", "Text")
	TextAuto.text = _("Desc_MyInfo")
end

function PageRewardShow:AddCellClick(item)
	return
end

function PageRewardShow:UpdateUI(index)
	if index == 2 then
		self.gradePanel:SetActive(true)
		self.rankPanel:SetActive(false)
		UIUtil.SetImageSprite(self.gradeIcon, string.gsub(InfoPVP:GetIconNamebyscore(InfoPVP.SelfPVPPlayerinfo.seasonRankingScore), "_s", ""), self)

		self.gradeName.text = _("Desc_CurrentGrade") .. InfoPVP:GetNamebyscore(InfoPVP.SelfPVPPlayerinfo.seasonRankingScore)
		self.gradeProg.fillAmount = InfoPVP:GetCurrentvaluebyscore(InfoPVP.SelfPVPPlayerinfo.seasonRankingScore)
		self.BigProg.text = "<color=#29c4c4>" .. self.Seasondata.subSeasonNum .. "</color>/" .. InfoPVP:GetSeasonConfigdata(self.Seasondata.seasonId).SubSeasonNum
		self.NextGradeName.text = InfoPVP:GetNextNamebyscore(self.Seasondata.player.seasonRankingScore).name

		UIUtil.SetImageSprite(self.NextGradeIcon, string.gsub(InfoPVP:GetNextIconbyscore(self.Seasondata.player.seasonRankingScore), "_s", ""), self)

		self.myScore.text = _("Desc_PVPNextRankScore") .. "<color=#29c4c4>" .. self.Seasondata.player.seasonRankingScore .. "</color>" .. "/" .. InfoPVP:GetNextRankScorebyscore(self.Seasondata.player.seasonRankingScore)

		if InfoPVP:GetNextNamebyscore(self.Seasondata.player.seasonRankingScore).max == 0 then
			self.NextGradeName.gameObject:SetActive(true)
			self.Next:SetActive(true)
			self.GradeNameMax:SetActive(false)
		else
			self.NextGradeName.gameObject:SetActive(false)
			self.Next:SetActive(false)
			self.GradeNameMax:SetActive(true)
		end

		self.subGradeSeasonName.text = _("Desc_BigSeasonCountdown") .. ""
	else
		self.gradePanel:SetActive(false)
		self.rankPanel:SetActive(true)

		self.name.text = InfoPVP.SelfPVPPlayerinfo.playerinfo.name
		self.rank.text = _("Desc_CurrentRanking") .. ":" .. tostring(InfoPVP.SelfPVPPlayerinfo.subSeasonRankingNo)
		self.SeasonName.text = string.format(_("Desc_SubSessonName"), _("ecNum_" .. self.Seasondata.subSeasonNum))
		self.subRankSeasonName.text = string.format(_("Desc_SubSessonName"), _("ecNum_" .. self.Seasondata.subSeasonNum)) .. ":"

		UIUtil.SetImageSprite(self.headIcon, PlayerInst.InfoPlayer:GetTitleIcon(1), self)
		UIUtil.SetImageSprite(self.headIconBox, PlayerInst.InfoPlayer:GetTitleIcon(2), self)

		if InfoPVP.SelfPVPPlayerinfo.subSeasonScore == 0 then
			self.rank.text = _("Desc_CurrentRanking") .. ":" .. _("Desc_NoPVPRank")

			self.NoRank:SetActive(true)

			for i = 1, 5 do
				local item = self.myRankRewards[i]

				item.itemGo:SetActive(false)
			end
		else
			local rankrewarddata = InfoPVP:GetSubSeasonRankRewarddata()

			for i = 1, 5 do
				local item = self.myRankRewards[i]

				if i > #rankrewarddata then
					item.itemGo:SetActive(false)
				else
					item.itemGo:SetActive(true)

					local infoItem = ItemManager:GetValueItem(rankrewarddata[i][1], rankrewarddata[i][2])

					item.itemCell:UpdateWithNumType(infoItem)
				end
			end
		end
	end
end

function PageRewardShow:InitScroll()
	local function GradeUpdate(item, index)
		local gradeData = self.listGrade[index]

		item:UpdateData(gradeData, index)
	end

	local content = self:GetChildComponent("Panel/GradePanel/Right/ScrollArea/Content", "Transform")
	local count = #self.listGrade
	local scrollArea = self:GetChildGameObject("Panel/GradePanel/Right/ScrollArea")

	self.UIScrollToolGrade = UIScrollTool()

	self.UIScrollToolGrade:InitList(scrollArea, content, count, self.cellGradePreLoad, CellPVPGradeReward, self, false, nil, GradeUpdate)

	local function RankUpdate(item, index)
		local rankData = self.listRank[index]

		item:UpdateData(rankData, index, #self.listRank)
	end

	content = self:GetChildComponent("Panel/RankPanel/Right/ScrollArea/Content", "Transform")
	count = #self.listRank
	scrollArea = self:GetChildGameObject("Panel/RankPanel/Right/ScrollArea")
	self.UIScrollToolRank = UIScrollTool()

	self.UIScrollToolRank:InitList(scrollArea, content, count, self.cellRankPreLoad, CellPVPRankReward, self, false, nil, RankUpdate)
end

function PageRewardShow:TabClick()
	self.gradePanel:SetActive(false)
	self.rankPanel:SetActive(false)

	if self.uiTab.index == 1 then
		self:UpdateUI(1)
		self.UIScrollToolRank:SetContentPosImmediate(Vector2.New(0, 0), self.listRank)
	else
		self:UpdateUI(2)

		local index = 0

		for i = 1, #self.listGrade do
			if self.listGrade[#self.listGrade - i + 1].rewardtype == 2 then
				index = #self.listGrade - i + 1

				break
			end
		end

		local posY = TenaryOp(index * 152 - 560 > 0, index * 152 - 560, 0)

		self.UIScrollToolGrade:SetContentPosImmediate(Vector2.New(0, posY), self.listGrade)
	end
end

function PageRewardShow:OnClickedBtnQuit()
	self:Close()
	UIMgr.RemoveUpdatePanel(self)
end

function PageRewardShow:UpdateDot()
	local has = DotMgr:HasDot(ePSKey.Dot_PVP)

	if has then
		UIMgr:ShowDot(1)
	else
		UIMgr:HideDot(1)
	end
end

function PageRewardShow:OnUpdateSecond()
	local subEndTime = InfoPVP:GetSeasondata().subSeasonEndTime - NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local endTime = InfoPVP:GetSeasondata().seasonEndTime - NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	self.gradeTime.text = _("Desc_RemainingTime") .. GetStrDisTime(endTime)
	self.rankTime.text = _("Desc_RemainingTime") .. GetStrDisTime(subEndTime)
end

function PageRewardShow:OnBackAndroid()
	self:OnClickedBtnQuit()
end
