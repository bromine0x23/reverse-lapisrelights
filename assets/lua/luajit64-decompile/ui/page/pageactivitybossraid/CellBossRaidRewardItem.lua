-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageActivityBossRaid/CellBossRaidRewardItem.lua

require("UI/Item/UIItemBase")

CellBossRaidRewardItem = class("CellBossRaidRewardItem", UIItemBase)

function CellBossRaidRewardItem:ctor(itemPrefabCache, parent, ownerUI)
	self.ItemPrefabCache = itemPrefabCache
	self.Parent = parent
end

function CellBossRaidRewardItem:Create(vParam)
	CellBossRaidRewardItem.base.Create(self, vParam)
	self:UpdateData(vParam)
end

function CellBossRaidRewardItem:OnEnter()
	local g = self.UIRootObject
	local gItem = GOUtil.FindChildGameObject(g, "CellItem")

	self.item = CellItem(gItem)

	self.item:InitItemByRoot(gItem)

	self.damage = self:GetChildGameObject("damage")
	self.finder = self:GetChildGameObject("finder")
	self.base = self:GetChildGameObject("base")
	self.first = self:GetChildGameObject("first")
	self.extra = self:GetChildGameObject("extra")
end

function CellBossRaidRewardItem:OnLeave()
	self.item:OnLeave()
end

function CellBossRaidRewardItem:UpdateData(data)
	local infoItem = SetterData.GetItemFromAsset(data.setter)

	self.item:UpdateWithNumType(infoItem, false)

	if data.setter.from == protocol_pb.AF_RAID_FINDER then
		self.finder:SetActive(true)
	elseif data.setter.from == protocol_pb.AF_RAID_HARM_BASE then
		self.base:SetActive(true)
	elseif data.setter.from == protocol_pb.AF_RAID_HARM_GRADE then
		self.damage:SetActive(true)
	elseif data.setter.from == protocol_pb.AF_RAID_FINDER_PASS then
		self.first:SetActive(true)
	elseif data.setter.from == protocol_pb.AF_RAID_HARM_DROP then
		self.extra:SetActive(true)
	elseif data.setter.from == protocol_pb.AF_GVG_STAGE_PASS then
		-- block empty
	end
end

function CellBossRaidRewardItem:SetImgDynamic(path)
	self.item:SetImgDynamic(path)
end
