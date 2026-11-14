-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoItem.lua

local ItemData = require("luaData/ItemData")

InfoItem = class("InfoItem", InfoBase)

function InfoItem:ctor(id)
	self.data = ItemData[id]
	self.pb = {}
	self.pb.id = id
	self.pb.num = 0
	self.simNum = 0
	self.value = 0
	self.id = id
	self.roleId = 0
	self.clearTime = 0

	if self.data and self.data.Time ~= "" then
		self.clearTime = GetTimeTampByString(self.data.Time)
	end

	self.minRandomNum = 0
	self.maxRandomNum = 0
end

function InfoItem:GetName()
	return Lang(self.data.Name)
end

function InfoItem:GetNameAndDesc()
	local name = Lang(self.data.Name)
	local desc = Lang(self.data.Info)
	local type = self:GetType()

	if type == eItemType.RC_RECEIVE then
		local infoRoleCard = RoleCardMgr:GetRoleCard(self:GetNum())

		name = Lang(infoRoleCard.data.Name)
		desc = Lang(infoRoleCard.data.ShowInfo)
	elseif type == eItemType.R_AVATAR or type == eItemType.P_AVATAR then
		local infoAvatar = AvatarManager:GetAvatar(self:GetNum())

		name = Lang(infoAvatar.data.Name)
		desc = Lang(infoAvatar.data.Description)
	elseif type == eItemType.R_PICTURE then
		local data = CollectionManager:GetIllustrationByID(self:GetNum())

		name = Lang(data.Name)
		desc = Lang(data.Desc)
	end

	return name, desc
end

function InfoItem:GetNum()
	if not self.pb then
		return 0
	end

	if self.clearTime ~= 0 and self.pb.num ~= 0 then
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

		if curServerTime >= self.clearTime then
			self.pb.num = 0
		end
	end

	return self.pb.num or 0
end

function InfoItem:GetCurResNum()
	local eType = self:GetType()

	if eType == eItemType.P_GOLD then
		return PlayerInst:GetGold()
	elseif eType == eItemType.P_DIAMOND then
		return PlayerInst:GetDiamond()
	elseif eType == eItemType.P_DIAMOND_PAY then
		return PlayerInst:GetDiamondPay()
	elseif eType == eItemType.P_POWER then
		return PlayerInst:GetPower()
	elseif eType == eItemType.P_FRIEND_COIN then
		return PlayerInst:GetFriendCoin()
	elseif eType == eItemType.P_CLUB_COIN then
		return PlayerInst:GetClubCoin()
	elseif eType == eItemType.I_SOUL then
		if self.data.Value == 0 then
			local rank = self.data.Level
			local list, count = ItemManager:GetStarList(rank)

			return count
		else
			local infoRoleCard = RoleCardMgr:GetRoleCard(self.data.Value)

			return infoRoleCard.pb.soul
		end
	elseif eType == eItemType.CLUB_COIN then
		if UnionMgr.HasUnion() then
			return UnionMgr.releUnion.pb.coin
		end

		return 0
	else
		return self:GetNum()
	end
end

function InfoItem:ChangeNumSimulate(changeNum)
	self.simNum = self.simNum + changeNum

	if self.simNum < 0 then
		self.simNum = 0
	end
end

function InfoItem:GetType()
	return GetItemType(self.data.Type)
end

function InfoItem:GetIcon()
	if self.data then
		local start = string.find(self.data.Icon, "/")
		local path = self.data.Icon

		if start == nil then
			path = "UIDyAtlas/Item/" .. self.data.Icon
		end

		if self:GetType() == eItemType.RC_RECEIVE then
			local infoRoleCard = RoleCardMgr:GetRoleCard(self:GetNum())

			path = infoRoleCard.data.HeadIcon
		elseif self:GetType() == eItemType.R_AVATAR or self:GetType() == eItemType.P_AVATAR then
			local infoAvatar = AvatarManager:GetAvatar(self:GetNum())

			path = infoAvatar.data.Icon
		elseif self:GetType() == eItemType.R_PICTURE then
			local data = CollectionManager:GetIllustrationByID(self:GetNum())

			path = data.LittleIcon
		end

		return path
	else
		return ""
	end
end

function InfoItem:GetQuality()
	local quality = self.data.Quality
	local itemType = self:GetType()

	if itemType == eItemType.RC_RECEIVE or itemType == eItemType.R_AVATAR or itemType == eItemType.P_AVATAR or itemType == eItemType.I_SOUL then
		quality = 4
	end

	return quality
end

function InfoItem:IsSpecialType()
	local eType = self:GetType()

	if eType == eItemType.P_GOLD or eType == eItemType.P_DIAMOND or eType == eItemType.P_POWER or eType == eItemType.P_FRIEND_COIN or eType == eItemType.I_SOUL then
		return true
	else
		return false
	end
end

function InfoItem:IsTargetItem(itemId)
	local composeItems = self.data.Compose

	for i = 1, #composeItems do
		if composeItems[i][1] == itemId then
			return true
		end
	end

	return false
end

function InfoItem:GetRequireItem()
	local composeItems = self.data.Compose
	local item1, item2
	local money = 0

	if composeItems[1] ~= nil then
		money = composeItems[1][2]
	end

	if composeItems[2] ~= nil then
		item1 = {
			itemInfo = ItemManager:Get(composeItems[2][1]),
			count = composeItems[2][2]
		}
	end

	if composeItems[3] ~= nil then
		item2 = {
			itemInfo = ItemManager:Get(composeItems[3][1]),
			count = composeItems[3][2]
		}
	end

	return item1, item2, money
end

ItemManager = {}
ItemManager.dict = ItemManager.dict or Record()
ItemManager.tlistGem = ItemManager.tlistGem or {}
ItemManager.tlistGift = ItemManager.tlistGift or {}
ItemManager.tabIndex = 0
ItemManager.synLineItems = nil
ItemManager.itemSynReturnData = nil
ItemManager.GoodIdList = {}
ItemManager.needItem = nil

function ItemManager:Get(id)
	if type(id) == "string" then
		id = tonumber("0x" .. id)
	end

	local ret = self.dict:GetValue(id)

	if not ret then
		ret = InfoItem(id)

		ItemManager.dict:Set(id, ret)
	end

	if ret.data == nil then
		print("请检查Item表!!!!!!!!" .. id)
	end

	return ret
end

function ItemManager:SetData(pbItemTbl)
	if pbItemTbl == nil then
		return
	end

	for i = 1, #pbItemTbl do
		local pbItem = pbItemTbl[i]
		local infoItem = self:Get(pbItem.id)

		if not infoItem.data then
			table.insert(ItemManager.GoodIdList, pbItem)
		elseif infoItem:GetType() == protocol_pb.I_SOUL then
			local infoRoleCard = RoleCardMgr:GetRoleCard(infoItem.data.Value)

			if infoRoleCard then
				infoRoleCard.pb.soul = pbItem.num
			end
		else
			infoItem.pb = pbItem
		end
	end

	self.listExpId = self:GetExpItemIdList()
end

function ItemManager:ChangeItemCount(id, num)
	local infoItem = self:Get(id)
	local numPre = infoItem.pb.num

	infoItem.pb.num = infoItem.pb.num + num
	infoItem.pb.num = Mathf.Max(infoItem.pb.num, 0)

	if infoItem.data.MaxNum > 0 then
		infoItem.pb.num = Mathf.Min(infoItem.pb.num, infoItem.data.MaxNum)
	end

	if infoItem.data.BagPage > 0 then
		if num > 0 then
			if numPre == 0 then
				BagRDL.Add(infoItem.id)
			end
		elseif num < 0 and infoItem.pb.num <= 0 then
			BagRDL.Remove(infoItem.id, infoItem.data.BagPage)
		end
	end
end

function ItemManager:GetItemCount(id)
	local infoItem = self:Get(id)

	if infoItem == nil or infoItem.pb == nil then
		return 0
	end

	return infoItem:GetCurResNum()
end

function ItemManager:GetValueItem(id, value, randomNum, roleId)
	local infoItem = InfoItem()

	infoItem.data = ItemData[id]

	if infoItem.data == nil then
		return nil
	end

	infoItem.pb.id = id
	infoItem.pb.num = value
	infoItem.simNum = value
	infoItem.id = id
	infoItem.value = value
	infoItem.randomNum = randomNum
	infoItem.roleId = roleId

	return infoItem
end

function ItemManager:GetType(id)
	return self:Get(id):GetType()
end

function ItemManager:GetConfigType(id)
	return self:Get(id).data.Type
end

function ItemManager:GetIcon(id)
	return GetItemIcon(self:GetType(id), id)
end

function ItemManager:GetExpItemIdList()
	if self.listExpId then
		return self.listExpId
	end

	local list = {}

	for k, v in pairsByKeys(ItemData) do
		if v.Type == "I_EXP" then
			table.insert(list, v)
		end
	end

	table.sort(list, function(a, b)
		return a.Value < b.Value
	end)

	local t = {}

	for _, v in ipairs(list) do
		table.insert(t, v.ID)
	end

	return t
end

function ItemManager:GetScrollItemList()
	local list = {}

	for k, v in pairsByKeys(ItemData) do
		if v.Type == "I_SCROLL" and self:GetItemCount(k) > 0 then
			table.insert(list, k)
		end
	end

	return list
end

function ItemManager:GetScrollItemListWithCount(minQuality)
	local list1 = {}
	local list2 = {}

	for k, v in pairsByKeys(ItemData) do
		if v.Type == "I_SCROLL" and minQuality <= v.Quality then
			table.insert(list1, {
				k,
				v.Quality,
				v.SubType,
				self:GetItemCount(k)
			})
		end
	end

	table.sort(list1, function(a, b)
		if a[2] == b[2] then
			if a[4] ~= 0 and b[4] ~= 0 or a[4] == 0 and b[4] == 0 then
				return a[3] < b[3]
			else
				return a[4] ~= 0
			end
		else
			return a[2] > b[2]
		end
	end)

	for _, v in pairsByKeys(list1) do
		table.insert(list2, {
			v[1],
			v[4]
		})
	end

	return list2
end

function ItemManager:GetLowerScrollItem(info)
	for k, v in pairsByKeys(ItemData) do
		if v.Type == "I_SCROLL" and v.SubType == info.data.SubType and v.Quality == info.data.Quality - 1 then
			return self:Get(k)
		end
	end

	return nil
end

function ItemManager:GetCardSoulShardId(cardId)
	for _, v in pairs(ItemData) do
		if v.Type == "I_SOUL_DEBRIS" and v.Value == cardId then
			return v.ID
		end
	end

	return 0
end

function ItemManager:GetCardSoulId(cardId)
	for _, v in pairsByKeys(ItemData) do
		if v.Type == "I_SOUL" and cardId == v.Value then
			return v.ID
		end
	end

	return nil
end

function ItemManager:GetStarList(rank)
	local list = {}
	local count = 0

	for id, data in pairs(ItemData) do
		local infoItem = ItemManager:Get(id)

		if infoItem:GetType() == eItemType.I_SOUL then
			local roleCardId = infoItem.data.Value

			if roleCardId > 0 then
				local infoRoleCard = RoleCardMgr:GetRoleCard(roleCardId)

				if rank == infoRoleCard.cardRank and infoRoleCard.pb.soul > 0 then
					table.insert(list, infoItem)

					count = count + infoRoleCard.pb.soul
				end
			end
		end
	end

	return list, count
end

function ItemManager:GetItemListByType(_type)
	local list = {}

	for _, v in pairsByKeys(ItemData) do
		if v.Type == _type then
			table.insert(list, v)
		end
	end

	return list
end

function ItemManager:GetItemByType(eType)
	for _, v in pairsByKeys(ItemData) do
		if v.Type == eType then
			return self:Get(v.ID)
		end
	end

	return nil
end

function ItemManager:IsItemHoldEnough(id, needNum, noMsg)
	local infoItem = self:Get(id)

	if not infoItem then
		return false
	end

	local add = 0

	if GetItemType(infoItem.data.Type) == eItemType.P_DIAMOND then
		add = PlayerInst:GetDiamondPay()
	end

	local holdNum = infoItem:GetCurResNum() + add

	if holdNum < needNum then
		if not noMsg then
			if GetItemType(infoItem.data.Type) == eItemType.P_POWER then
				UIMgr.ShowMsg(string.format("<color=yellow>%s</color>" .. _("Msg_NoEnoughItem"), Lang(infoItem.data.Name)))
			else
				UIMgr.ShowMsg(string.format(Lang(12390), "<color=yellow>" .. Lang(infoItem.data.Name) .. "</color>"))
			end
		end

		return false
	end

	return true
end

function ItemManager:IsItemHoldEnoughContentSyn(id, needNum, itemCost, onlyCheckCost)
	local infoItem = ItemManager:Get(id)

	if not infoItem then
		return false
	end

	local usedCount = 0

	if itemCost[id] ~= nil then
		usedCount = itemCost[id]
	end

	if onlyCheckCost[id] ~= nil then
		usedCount = onlyCheckCost[id] + usedCount
	end

	local holdNum = infoItem:GetCurResNum() - usedCount

	if holdNum < needNum then
		local itemCompose = infoItem.data.Compose

		if #itemCompose == 0 then
			return false
		end

		local curItemCost = TableClone(itemCost)

		for k, v in pairs(itemCompose) do
			local needSynCount = (needNum - holdNum) * v[2]
			local tmpCost = ItemManager:IsItemHoldEnoughContentSyn(v[1], needSynCount, curItemCost, onlyCheckCost)

			if tmpCost then
				curItemCost = tmpCost
			else
				return false
			end
		end

		if holdNum ~= 0 then
			if curItemCost[id] == nil then
				curItemCost[id] = holdNum
			else
				curItemCost[id] = holdNum + curItemCost[id]
			end
		end

		return curItemCost
	else
		if itemCost[id] == nil then
			itemCost[id] = needNum
		else
			itemCost[id] = needNum + itemCost[id]
		end

		return itemCost
	end
end

function ItemManager:IsCommonStone(id)
	local listId = {
		581,
		582,
		583,
		584
	}

	for i = 1, #listId do
		if id == listId[i] then
			return true
		end
	end

	return false
end

function ItemManager:GetListByCommonStone(id, teamId)
	local list = {}

	if not self:IsCommonStone(id) then
		return list
	end

	local listCard = RoleCardMgr:GetAllCard()

	if teamId and teamId ~= 0 then
		local temp = {}
		local listRoleId = CombinationMgr:Get(teamId).data.MemberList

		for i = 1, #listCard do
			for j = 1, #listRoleId do
				if listCard[i].data.CharacterID == listRoleId[j] then
					table.insert(temp, listCard[i])
				end
			end
		end

		listCard = temp
	end

	local quality = self:Get(id).data.Level

	for _, v in pairs(listCard) do
		if v.cardRank == quality and v.pb.soul > 0 then
			local soulId = self:GetCardSoulId(v.data.ID)
			local num = v.pb.soul
			local info = self:GetValueItem(soulId, num)

			table.insert(list, info)
		end
	end

	return list
end

function ItemManager:GetCountByCommonStone(id)
	local num = 0
	local list = self:GetListByCommonStone(id)

	for i = 1, #list do
		num = num + list[i]:GetNum()
	end

	return num
end

function ItemManager:GetRoleFavorInfoList(infoRole)
	local favorList = {}
	local favorTabList = {}

	for i = 1, 4 do
		favorList["Type" .. i] = {}
		favorTabList[i] = 0
	end

	for _, v in pairs(ItemData) do
		if v.Type == "I_FAVOR" then
			for k, v2 in pairs(favorList) do
				local str = string.split(v.SubType, ".")

				if str[1] == "cake" and k == "Type" .. tonumber(str[2]) and ItemManager:Get(v.ID):GetNum() > 0 then
					table.insert(v2, v)
				elseif str[1] ~= "cake" and k == "Type" .. tonumber(v.SubType) then
					table.insert(v2, v)
				end
			end
		end
	end

	for i = 1, 4 do
		local function fun(a, b)
			local aQuality = a.Quality
			local bQuality = b.Quality
			local aID = a.ID
			local bID = b.ID

			if aQuality == bQuality then
				return aID < bID
			else
				return bQuality < aQuality
			end
		end

		table.sort(favorList["Type" .. i], fun)

		local list = {}

		for j = 1, #favorList["Type" .. i] do
			local holdInfo
			local listId = infoRole.data.FavorItemList

			for _, v in pairs(listId) do
				if v[1] == favorList["Type" .. i][j].ID then
					holdInfo = v
					favorTabList[i] = 1
				end
			end

			local gray = TenaryOp(holdInfo, 0, 1)

			if gray == 0 and holdInfo and holdInfo[2] == 1 then
				table.insert(list, 1, favorList["Type" .. i][j])
			else
				table.insert(list, favorList["Type" .. i][j])
			end
		end

		favorList["Type" .. i] = list
	end

	return favorList, favorTabList
end

local BadgeData = require("luaData/Reputation")

function ItemManager:GetAllBadgeList()
	return BadgeData
end

function ItemManager:GetBadgeData(id)
	return BadgeData[id]
end

function ItemManager:HasBadge(id)
	local list = InfoGameInst.gameInfo.medalList

	for i = 1, #list do
		if id == list[i] then
			return true
		end
	end

	return false
end

function ItemManager:BadgeInUse(id)
	return PlayerInst.InfoPlayer.badgeId == id
end

function ItemManager:GetValueItemType(list)
	local itemId = list[1]
	local item = self:Get(itemId)

	if item.data.Type == "R_AVATAR" or item.data.Type == "P_AVATAR" then
		local avatarId = list[2]
		local infoItem = AvatarManager:GetAvatar(avatarId)

		infoItem.pb.num = 1

		return infoItem
	else
		local itemNum = list[2]
		local infoItem = self:GetValueItem(itemId, itemNum)

		return infoItem
	end
end

function ItemManager:SetItemInfo(infoItem, itemIcon, itemRank1, itemRank2, panel)
	if not infoItem then
		return
	end

	local path = infoItem:GetIcon()

	UIUtil.SetImageSprite(itemIcon, path, panel)
	self:SetItemRank(infoItem, itemRank1, itemRank2, panel)
end

function ItemManager:SetItemRank(infoItem, itemRank1, itemRank2, panel)
	if not infoItem then
		return
	end

	if infoItem:GetType() == eItemType.RC_RECEIVE then
		local infoRoleCard = RoleCardMgr:GetRoleCard(infoItem:GetNum())
		local path = "UIDyAtlas/RoleCardRank/ui_hd_card_back_" .. infoRoleCard.rank .. "_12"

		UIUtil.SetImageSprite(itemRank2, path, panel)
	else
		local quality = infoItem:GetQuality()

		if quality == 0 then
			quality = 4
		end

		if quality == 0 then
			itemRank2.gameObject:SetActive(false)
		else
			itemRank2.gameObject:SetActive(true)
			UIUtil.SetImageSprite(itemRank2, "UIDyAtlas/ItemRarity/BG_frame_item_0" .. quality .. "_a", panel)
		end

		UIUtil.SetImageSprite(itemRank1, "UIDyAtlas/ItemRarity/BG_frame_item_0" .. quality .. "_b", panel)
	end
end

function ItemManager:Init()
	self.bagTagNum = 5
	self.dictBag = {}
	self.listRcSoulData = {}

	for _, v in pairsByKeys(ItemData) do
		if v.BagPage > 0 then
			self.dictBag[v.BagPage] = self.dictBag[v.BagPage] or {}

			table.insert(self.dictBag[v.BagPage], v)

			if v.Type == "I_SOUL" then
				table.insert(self.listRcSoulData, v)
			end
		end
	end
end

function ItemManager:GetBagList(BagPage)
	local listResult = {}
	local list = self.dictBag[BagPage]

	for i = 1, #list do
		local data = list[i]
		local infoItem = ItemManager:Get(data.ID)

		if infoItem:GetCurResNum() > 0 then
			table.insert(listResult, infoItem)
		end
	end

	table.sort(listResult, function(a, b)
		if a.data.Priority == b.data.Priority then
			return a.data.Quality > b.data.Quality
		end

		return a.data.Priority < b.data.Priority
	end)

	return listResult
end

function ItemManager:UpdateSoulDot(roleCardId, preSoul, changeSoulNum)
	for _, v in pairs(self.listRcSoulData) do
		if v.BagPage > 0 and v.Value == roleCardId then
			local infoItem = self:Get(v.ID)
			local num = changeSoulNum

			if num > 0 then
				if preSoul == 0 then
					BagRDL.Add(infoItem.id)
				end
			elseif num < 0 and preSoul + num <= 0 then
				BagRDL.Remove(infoItem.id, infoItem.data.BagPage)
			end
		end
	end
end

ItemManager.sweepItem = {}

function ItemManager:SetSweepItem(sweepItem)
	ItemManager.sweepItem = sweepItem
end

function ItemManager:GetSweepItem()
	require("UI/Dlg/Public/DlgExit")

	if DlgExit.GetSweepItemState() then
		return ItemManager.sweepItem
	else
		ItemManager.sweepItem = {}

		return ItemManager.sweepItem
	end
end

local RewardPackData = require("luaData/RewardPack")

function ItemManager.GetRewardPackData(rewardPackId)
	return RewardPackData[rewardPackId] or {}
end

function ItemManager.GetRewardPackItems(rewardPackId)
	return RewardPackData[rewardPackId].PackItem
end
