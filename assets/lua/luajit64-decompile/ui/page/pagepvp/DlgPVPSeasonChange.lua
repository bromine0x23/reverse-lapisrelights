-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/pagePVP/DlgPVPSeasonChange.lua

local InfoPVPData = require("Info/InfoPVP")

DlgPVPSeasonChange = class("DlgPVPSeasonChange", UIPanel)

function DlgPVPSeasonChange:ctor()
	self.UIPrefabPath = "UI/PanelPVP/DlgPVPSeasonChange"
end

function DlgPVPSeasonChange:PreLoad()
	return
end

function DlgPVPSeasonChange:Purge()
	DlgPVPSeasonChange.base.Purge(self)
end

function DlgPVPSeasonChange:OnRegisterEvent()
	self:AddClick(self.Close1, self.OnClickedButtonQuit)
	self:AddClick(self.Close2, self.OnClickedButtonQuit)
end

function DlgPVPSeasonChange:OnUnRegisterEvent()
	self:RemoveClick(self.Close1, self.OnClickedButtonQuit)
	self:RemoveClick(self.Close2, self.OnClickedButtonQuit)
end

function DlgPVPSeasonChange:OnEnter(vParam)
	self.PanelBigSeason = self:GetChildGameObject("PanelBigSeason")
	self.PanelSubSeason = self:GetChildGameObject("PanelSubSeason")
	self.Close1 = self:GetChildGameObject("PanelBigSeason/Close")
	self.Close2 = self:GetChildGameObject("PanelSubSeason/Close")
	self.BeforeIcon = self:GetChildComponent("PanelBigSeason/Rank/Before", "Image")
	self.CurIcon = self:GetChildComponent("PanelBigSeason/Rank/Now", "Image")
	self.TextScoreBefore = self:GetChildComponent("PanelBigSeason/Score/TextBefore", "Text")
	self.TextScoreNow = self:GetChildComponent("PanelBigSeason/Score/TextNow", "Text")
	self.TextRankBefore = self:GetChildComponent("PanelBigSeason/RankNum/TextBefore", "Text")
	self.TextRankNow = self:GetChildComponent("PanelBigSeason/RankNum/TextNow", "Text")
	self.TextSubScoreBefore = self:GetChildComponent("PanelSubSeason/Score/TextBefore", "Text")
	self.TextSubScoreNow = self:GetChildComponent("PanelSubSeason/Score/TextNow", "Text")
	self.TextSubRankBefore = self:GetChildComponent("PanelSubSeason/RankNum/TextBefore", "Text")
	self.TextSubRankNow = self:GetChildComponent("PanelSubSeason/RankNum/TextNow", "Text")

	if vParam.seasonChange == 1 then
		SetActiveFunc(self.PanelBigSeason, true)
		SetActiveFunc(self.PanelSubSeason, false)
		UIUtil.SetImageSprite(self.CurIcon, string.gsub(InfoPVPData:GetIconNamebyscore(InfoPVPData.curScore), "_s", ""), self)
		UIUtil.SetImageSprite(self.BeforeIcon, string.gsub(InfoPVPData:GetIconNamebyscore(vParam.seasonRankingScore), "_s", ""), self)

		self.TextScoreBefore.text = _("Desc_PVPBeforeScore") .. vParam.seasonRankingScore
		self.TextScoreNow.text = _("Desc_PVPNowScore") .. "<color=#29C4C4> " .. InfoPVPData.curScore .. "</color>"
		self.TextRankBefore.text = TenaryOp(vParam.subSeasonRankingNo == 0, _("Desc_PVPRankNil"), string.format(_("Desc_PVPBeforeRank"), vParam.subSeasonRankingNo))
		self.TextRankNow.text = TenaryOp(InfoPVPData.SelfPVPPlayerinfo.subSeasonScore == 0, _("Desc_PVPRankNil"), _("Desc_PVPNowRank") .. "<color=#29C4C4> " .. InfoPVPData.SelfPVPPlayerinfo.subSeasonRankingNo .. "</color>")
	elseif vParam.seasonChange == 2 then
		SetActiveFunc(self.PanelBigSeason, false)
		SetActiveFunc(self.PanelSubSeason, true)

		self.TextSubScoreBefore.text = _("Desc_PVPSubBeforeScore") .. vParam.subSeasonScore
		self.TextSubScoreNow.text = _("Desc_PVPSubNowScore") .. "<color=#29C4C4> " .. InfoPVPData.SelfPVPPlayerinfo.subSeasonScore .. "</color>"
		self.TextSubRankBefore.text = TenaryOp(vParam.subSeasonRankingNo == 0, _("Desc_PVPRankNil"), string.format(_("Desc_PVPBeforeRank"), vParam.subSeasonRankingNo))
		self.TextSubRankNow.text = TenaryOp(InfoPVPData.SelfPVPPlayerinfo.subSeasonScore == 0, _("Desc_PVPRankNil"), _("Desc_PVPNowRank") .. "<color=#29C4C4> " .. InfoPVPData.SelfPVPPlayerinfo.subSeasonRankingNo .. "</color>")
	end

	self:Localization()
end

function DlgPVPSeasonChange:Localization()
	local TextAuto

	TextAuto = self:GetChildComponent("PanelBigSeason/Title/Text", "Text")
	TextAuto.text = _("Desc_Alert")
	TextAuto = self:GetChildComponent("PanelBigSeason/Tip/Text", "Text")
	TextAuto.text = _("Desc_PVPBigSeasonChange")
	TextAuto = self:GetChildComponent("PanelBigSeason/Rank/TitalText", "Text")
	TextAuto.text = _("Desc_PVPRankIconChange")
	TextAuto.fontSize = 24
	TextAuto = self:GetChildComponent("PanelBigSeason/Rank/TextBefore", "Text")
	TextAuto.text = _("Desc_PVPRankIconBefore")
	TextAuto = self:GetChildComponent("PanelBigSeason/Rank/TextNow", "Text")
	TextAuto.text = _("Desc_PVPRankIconNow")
	TextAuto = self:GetChildComponent("PanelBigSeason/Score/TitalText", "Text")
	TextAuto.text = _("Desc_PVPScoreChange")
	TextAuto = self:GetChildComponent("PanelBigSeason/RankNum/TitalText", "Text")
	TextAuto.text = _("Desc_PVPRankChange")
	TextAuto.fontSize = 24
	TextAuto = self:GetChildComponent("PanelSubSeason/Title/Text", "Text")
	TextAuto.text = _("Desc_Alert")
	TextAuto = self:GetChildComponent("PanelSubSeason/Tip/Text", "Text")
	TextAuto.text = _("Desc_PVPSubSeasonChange")
	TextAuto = self:GetChildComponent("PanelSubSeason/Score/TitalText", "Text")
	TextAuto.text = _("Desc_PVPSubScoreChange")
	TextAuto = self:GetChildComponent("PanelSubSeason/RankNum/TitalText", "Text")
	TextAuto.text = _("Desc_PVPRankChange")
end

function DlgPVPSeasonChange:OnClickedButtonQuit()
	self:Purge()

	if self.callback then
		self.callback()
	end
end
