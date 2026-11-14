-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/pagePVP/CellPVPGradeReward.lua

CellPVPGradeReward = class("CellPVPGradeReward", UIItemBase)

local InfoPVP = require("Info/InfoPVP")

function CellPVPGradeReward:ctor(itemPrefabCache, parent)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellPVPGradeReward:Create(vParam)
	CellPVPGradeReward.base.Create(self, vParam)
end

function CellPVPGradeReward:OnRegisterEvent()
	self:AddClick(self.getBtn, self.OnGetBtn)
end

function CellPVPGradeReward:OnUnRegisterEvent()
	self:RemoveClick(self.getBtn, self.OnGetBtn)
end

function CellPVPGradeReward:OnEnter()
	self.UIRootObject:SetActive(true)

	self.icon = self:GetChildComponent("Icon", "Image")
	self.received = self:GetChildGameObject("Received")
	self.getBtn = self:GetChildGameObject("Button")
	self.No = self:GetChildGameObject("No")
	self.Text = self:GetChildComponent("Name/Text", "Text")
	self.TextNo = self:GetChildComponent("No", "Text")
	self.itemList = {}

	for i = 1, 3 do
		local itemGo = self:GetChildGameObject("RewardCon/" .. i)
		local itemCell = CellItem(itemGo)

		itemCell:InitItemByRoot(itemGo)

		itemCell.itemCell = itemCell
		itemCell.itemGo = itemGo

		table.insert(self.itemList, itemCell)
	end

	local TextAuto

	TextAuto = self:GetChildComponent("Button/Text", "Text")
	TextAuto.text = _("Desc_Get")
	TextAuto = self:GetChildComponent("Received", "Text")
	TextAuto.text = _("Desc_Has_Get")

	self:OnRegisterEvent()
end

function CellPVPGradeReward:UpdateData(data, index)
	self.data = data
	self.index = index

	UIUtil.SetImageSprite(self.icon, data.icon, self)
	print(data.RankingTitle)

	self.Text.text = Lang(data.RankingTitle)

	for i = 1, 3 do
		if i > #data.reward then
			self.itemList[i].itemGo:SetActive(false)
		else
			local infoItem = ItemManager:GetValueItem(data.reward[i][1], data.reward[i][2])

			self.itemList[i].itemGo:SetActive(true)
			self.itemList[i].itemCell:UpdateWithNumType(infoItem)
		end
	end

	if data.RankingId == 1 then
		self.TextNo.text = _("Desc_FirstPlayGet")
	else
		self.TextNo.text = _("Desc_Not_Get")
	end

	if data.rewardtype == 1 then
		self.received:SetActive(true)
		self.getBtn:SetActive(false)
		self.No:SetActive(false)
	elseif data.rewardtype == 2 then
		self.received:SetActive(false)
		self.getBtn:SetActive(true)
		self.No:SetActive(false)
	elseif data.rewardtype == 3 then
		self.received:SetActive(false)
		self.getBtn:SetActive(false)
		self.No:SetActive(true)
	end
end

function CellPVPGradeReward:OnGetBtn()
	local num = InfoPVP:GetCurrentRankId() + 1

	if num ~= self.data.RankingId then
		UIMgr.ShowMsg("順番で受け取ってください")
	else
		local function pc(pb)
			if pb.result.code == NetManager.Result_Sucess then
				local InfoPVPData = require("Info/InfoPVP")
				local num = math.random(1, 5)

				InfoSoundEventMgr:LoadBank(RoleCardMgr:GetRole(InfoPVPData:GetRocardtable(num).id).data.VocalBank)
				InfoSoundEventMgr:Play("VocalCommon10", RoleCardMgr:GetRole(InfoPVPData:GetRocardtable(num).id).data.VocalCommon10)
				DealWithGetpvpAward(pb.setter)
				InfoPVP:SetCurrentRankId(pb.rankingId)
				InfoPVP:SetSeasonRankRewarddata(self.index)
				Event.Instance:Fire("changerward", self)
			else
				UIMgr.ShowMsg(pb.result.desc, pb)
			end
		end

		NetManager:RequestPVPReward(InfoPVP:GetSeasondata().seasonId, InfoPVP:GetSeasondata().subSeasonNum, self.data.RankingId, pc)
	end
end

function DealWithGetpvpAward(pbSetter)
	local setter = SetterData.GetSetterData(pbSetter)

	setter:Parse()

	local cb

	if SetterData.showLevelup then
		function cb()
			UIMgr.AddPanel(DlgProducerLevelUp())
		end
	end

	local listNormal = setter:Getlist(protocol_pb.AF_PVP)

	if #listNormal > 0 then
		local data = {
			list = listNormal,
			callback = cb,
			listValue = #listNormal
		}

		UIMgr.AddPanel(DlgGetAward.GetInstance(), data)
	end
end

function CellPVPGradeReward:OnLeave()
	for i = 1, 3 do
		self.itemList[i]:OnLeave()
	end

	self:OnUnRegisterEvent()
	UnloadAllImageSprite(self)
end
