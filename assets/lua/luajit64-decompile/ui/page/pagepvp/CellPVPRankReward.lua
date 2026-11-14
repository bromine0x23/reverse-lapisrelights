-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/pagePVP/CellPVPRankReward.lua

CellPVPRankReward = class("CellPVPGradeReward", UIItemBase)

function CellPVPRankReward:ctor(itemPrefabCache, parent)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellPVPRankReward:Create(vParam)
	CellPVPRankReward.base.Create(self, vParam)
end

function CellPVPRankReward:OnEnter()
	self.UIRootObject:SetActive(true)

	self.rank1 = self:GetChildGameObject("Icon")
	self.rank2 = self:GetChildGameObject("Icon2")
	self.rankText = self:GetChildComponent("Icon2/Text", "Text")
	self.rankImg = self:GetChildComponent("Icon/Img", "Image")
	self.Text = self:GetChildComponent("Icon/Image/Text", "Text")
	self.itemList = {}

	for i = 1, 4 do
		local itemGo = self:GetChildGameObject("RewardCon/" .. i)
		local itemCell = CellItem(itemGo)

		itemCell:InitItemByRoot(itemGo)

		itemCell.itemGo = itemGo
		itemCell.itemCell = itemCell

		table.insert(self.itemList, itemCell)
	end
end

function CellPVPRankReward:UpdateData(data, index, max)
	self.rank1:SetActive(true)
	self.rank2:SetActive(false)

	if index == 1 then
		UIUtil.SetImageSprite(self.rankImg, "UI/PanelPVP/AtlasCommon/IC_pvp_crown_01", self)

		self.Text.text = string.format(_("Desc_RankPos"), _("ecNum_1"))
	elseif index == 2 then
		UIUtil.SetImageSprite(self.rankImg, "UI/PanelPVP/AtlasCommon/IC_pvp_crown_02", self)

		self.Text.text = string.format(_("Desc_RankPos"), _("ecNum_2"))
	elseif index == 3 then
		UIUtil.SetImageSprite(self.rankImg, "UI/PanelPVP/AtlasCommon/IC_pvp_crown_03", self)

		self.Text.text = string.format(_("Desc_RankPos"), _("ecNum_3"))
	elseif index > 3 then
		self.rank1:SetActive(false)
		self.rank2:SetActive(true)

		self.rankText.text = data.RankingNoFrom .. "-\n" .. data.RankingNoTo - 1

		if index == max then
			self.rankText.text = data.RankingNoFrom .. _("Desc_RankAfter")
		end
	end

	for i = 1, 4 do
		if i > #data.reward then
			self.itemList[i].itemGo:SetActive(false)
		else
			local infoItem = ItemManager:GetValueItem(data.reward[i][1], data.reward[i][2])

			self.itemList[i].itemGo:SetActive(true)
			self.itemList[i].itemCell:UpdateWithNumType(infoItem)
		end
	end
end

function CellPVPRankReward:OnLeave()
	for i = 1, 4 do
		self.itemList[i]:OnLeave()
	end

	UnloadAllImageSprite(self)
end
