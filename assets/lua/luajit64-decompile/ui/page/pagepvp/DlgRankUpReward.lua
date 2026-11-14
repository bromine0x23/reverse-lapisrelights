-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/pagePVP/DlgRankUpReward.lua

local InfoPVPData = require("Info/InfoPVP")

DlgRankUpReward = class("DlgRankUpReward", UIPanel)

function DlgRankUpReward:ctor()
	self.UIPrefabPath = "UI/PanelPVP/DlgRankUpReward"
end

function DlgRankUpReward:PreLoad()
	return
end

function DlgRankUpReward:Purge()
	DlgRankUpReward.base.Purge(self)

	if self.cellItem then
		self.cellItem:OnLeave()

		self.cellItem = nil
	end
end

function DlgRankUpReward:OnRegisterEvent()
	self:AddClick(self.ButtonQuit, self.OnClickedButtonQuit)
end

function DlgRankUpReward:OnUnRegisterEvent()
	self:RemoveClick(self.ButtonQuit, self.OnClickedButtonQuit)
end

function DlgRankUpReward:OnEnter(vParam)
	self.ButtonQuit = self:GetChildGameObject("List/Tital/BtnClose")

	GOUtil.SetFont(self:GetChildComponent("List/Tital/Text", "Text"), UIMgr.JPFonts.YukiB)

	self.NewRankText = self:GetChildComponent("List/Rank/RankText/NewRankText", "Text")
	self.TipText = self:GetChildComponent("List/Rank/Text", "Text")
	self.ItemObj = self:GetChildGameObject("List/Reward/CellItem")
	self.GetTip = self:GetChildComponent("List/Reward/Text (1)", "Text")
	self.No = self:GetChildComponent("List/Reward/No", "Text")

	self:UpdatePanel()
end

function DlgRankUpReward:UpdatePanel()
	self.NewRankText.text = InfoPVPData.SelfPVPPlayerinfo.subSeasonRankingNo
	self.TipText.text = string.format(_("PVP_HigtRank"), InfoPVPData.bestRankingUp)

	local item = CellItem(self.ItemObj)

	self.cellItem = item

	self.cellItem:InitItemByRoot(self.ItemObj)

	if InfoPVPData.bestRankingAward and InfoPVPData.bestRankingAward[1] and InfoPVPData.bestRankingAward[2] then
		local infoItem = ItemManager:GetValueItem(InfoPVPData.bestRankingAward[1], InfoPVPData.bestRankingAward[2])

		self.cellItem:UpdateData(1, infoItem, true)
		self.cellItem:SetGeted(false)

		self.GetTip.text = _("PVP_GetFromMail")

		SetActiveFunc(self.ItemObj, true)
		SetActiveFunc(self.No.gameObject, false)
	else
		SetActiveFunc(self.ItemObj, false)
		SetActiveFunc(self.No.gameObject, true)

		self.GetTip.text = _("PVP_RewardNo")
		self.No.text = _("PVP_UpNotEnough")
	end

	SoundMgr.Play("Play_SE_020_0049")
end

function DlgRankUpReward:OnClickedButtonQuit()
	self:Purge()
end
