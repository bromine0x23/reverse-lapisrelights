-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/pagePVP/PagePVPOver.lua

PagePVPOver = class("PagePVPOver", UIPanel)

local InfoPVP = require("Info/InfoPVP")

function PagePVPOver:ctor()
	self.UIPrefabPath = "UI/PanelPVP/PanelPVPOver"
end

function PagePVPOver:Purge()
	PagePVPOver.base.Purge(self)
end

function PagePVPOver:OnRegisterEvent()
	self:AddClick(self.UIRootObject, self.OnClickedBtnQuit)
	self:AddClick(self.battleBtn, self.OnBattle)
	self:AddClick(self.obj_clickArea.gameObject, self.OnClickArea)
end

function PagePVPOver:OnUnRegisterEvent()
	self:RemoveClick(self.UIRootObject, self.OnClickedBtnQuit)
	self:RemoveClick(self.battleBtn, self.OnBattle)
	self:RemoveClick(self.obj_clickArea.gameObject, self.OnClickArea)
end

function PagePVPOver:OnEnter(vParam)
	self.battleoverdata = vParam.battleoverdata
	self.closecallback = vParam.callBack

	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator", false)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", false)

	local textLabel = self:GetChildComponent("obj_clickArea/label", "Text")

	textLabel.text = _("Common_Click_Continue")
	self.Animator = GOUtil.GetComponent(self.UIRootObject, "Animator")
	self.txt_bottomTip = self:GetChildComponent("obj_clickArea/label", "Text")
	self.obj_clickArea = self:GetChildGameObject("obj_clickArea")
	self.fail = self:GetChildGameObject("Title/Fail")
	self.win = self:GetChildGameObject("Title/Win")
	self.title = self:GetChildGameObject("Title")
	self.panel = self:GetChildGameObject("Panel")
	self.scorecurlv = self:GetChildComponent("Panel/ScoreBar/TxtCurLv", "Text")
	self.scoreprelv = self:GetChildComponent("Panel/ScoreBar/TxtPreLv", "Text")
	self.rankcurlv = self:GetChildComponent("Panel/RankBar/TxtCurLv", "Text")
	self.rankprelv = self:GetChildComponent("Panel/RankBar/TxtPreLv", "Text")
	self.myRankRewards = {}

	for i = 1, 6 do
		local itemGo = self:GetChildGameObject("Panel/Con/" .. i)
		local itemCell = CellItem(itemGo)

		itemCell.itemCell = itemCell
		itemCell.itemGo = itemGo

		itemCell:InitItemByRoot(itemGo)
		table.insert(self.myRankRewards, itemCell)
	end
end

function PagePVPOver:UpdateUI()
	print(self.battleoverdata.battle.battleResult)

	if self.battleoverdata.battle.battleResult == 1 then
		if PlayerInst.InfoPlayer.pid == InfoPVP.BattlerPlayer.playerinfo.pid then
			self.win:SetActive(false)
			self.fail:SetActive(true)
		else
			self.win:SetActive(true)
			self.fail:SetActive(false)
		end
	elseif PlayerInst.InfoPlayer.pid == InfoPVP.BattlerPlayer.playerinfo.pid then
		self.win:SetActive(true)
		self.fail:SetActive(false)
	else
		self.win:SetActive(false)
		self.fail:SetActive(true)
	end

	self.scorecurlv.text = self.battleoverdata.battle.atkPlayerAfterScore
	self.scoreprelv.text = self.battleoverdata.battle.atkPlayerBeforeScore
	self.rankcurlv.text = TenaryOp(self.battleoverdata.battle.atkPlayerAfterScore == 0, _("Desc_PVPRankNil"), self.battleoverdata.battle.atkPlayerAfterRankingNo)
	self.rankprelv.text = TenaryOp(self.battleoverdata.battle.atkPlayerBeforeScore == 0, _("Desc_PVPRankNil"), self.battleoverdata.battle.atkPlayerBeforeRankingNo)

	local setter = SetterData.GetSetterData(self.battleoverdata.setter)

	setter:Parse()

	local listNormal = setter:Getlist(protocol_pb.AF_PVP)

	for i = 1, 6 do
		if i > #listNormal then
			self.myRankRewards[i].itemGo:SetActive(false)
		else
			local infoItem = SetterData.GetItemFromAsset(listNormal[i])

			self.myRankRewards[i].itemCell.itemGo:SetActive(true)
			self.myRankRewards[i].itemCell.itemCell:UpdateWithNumType(infoItem)
		end
	end
end

function PagePVPOver:OnBattle()
	return
end

function PagePVPOver:OnClickArea()
	GOUtil.SetActive(self.obj_clickArea, false)
	GOUtil.SetActive(self.panel, true)
	GOUtil.SetActive(self.title, true)

	self.Animator.enabled = true

	self:UpdateUI()
end

function PagePVPOver:OnClickedBtnQuit()
	local function pc(pb)
		LoadingMgr.Hide(eLoadingType.Repeat)

		local InfoPVP = require("Info/InfoPVP")

		InfoPVP:SetData(pb)

		local data = {}

		data.pvp = 10

		self:Close()
		self.closecallback(data)
	end

	LoadingMgr.Show(eLoadingType.Repeat)
	NetManager:RequestSeasonData(0, 0, 0, pc)
end
