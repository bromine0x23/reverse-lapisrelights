-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoUnionWish.lua

InfoUnionWish = class("InfoUnionWish", InfoBase)

local function GetStrDisTime(second)
	local d, h, m, s = GetTimeFormatBySec(second)

	if d >= 1 then
		strTime = string.format(_("Desc_Days_Ago"), d)
	elseif d < 1 and h >= 1 then
		strTime = string.format(_("Desc_Hours_Ago"), h)
	elseif h < 1 and m >= 1 then
		strTime = string.format(_("Desc_Minutes_Ago"), m)
	elseif m < 1 and s >= 1 then
		strTime = string.format(_("Desc_Seconds_Ago"), s)
	else
		strTime = _("Desc_Just_Ago")
	end

	return strTime
end

function InfoUnionWish:ctor(pbWish)
	self.id = pbWish.playerId
	self.pb = {}

	self:SetData(pbWish)
end

function InfoUnionWish:SetData(pb)
	self.pb.playerName = pb.playerName
	self.pb.roleCard = pb.roleCard
	self.pb.need = pb.need
	self.pb.grant = pb.grant
	self.pb.time = tonumber(pb.time)
	self.pb.selfGrant = pb.selfGrant
end

function InfoUnionWish:GetWishCard()
	return RoleCardMgr:GetRoleCard(self.pb.roleCard)
end

function InfoUnionWish:GetWishSoul()
	local soulId = ItemManager:GetCardSoulId(self.pb.roleCard)

	return ItemManager:Get(soulId)
end

function InfoUnionWish:IsMine()
	local mineId = PlayerInst.InfoPlayer.pid

	return self.id == mineId
end

function InfoUnionWish:IsReached()
	return self.pb.grant >= self.pb.need
end

function InfoUnionWish:IsGifted()
	return self.pb.selfGrant
end

function InfoUnionWish:ChangeSelfGrant()
	self.pb.selfGrant = true
end

function InfoUnionWish:ChangeGrant(v)
	self.pb.grant = self.pb.grant + v
end

UnionWishMgr = {}
UnionWishMgr.listUnionWish = {}

local IsSetData = false

function UnionWishMgr:SetData(pbWishs)
	IsSetData = true
	self.listUnionWish = {}

	for i = 1, #pbWishs do
		local pbWish = pbWishs[i]

		if UnionMgr.releUnion:HaveMember(pbWish.playerId) then
			local infoUnionWish = InfoUnionWish(pbWish)

			table.insert(self.listUnionWish, infoUnionWish)
		end
	end

	self:SortUnionWishList()
end

function UnionWishMgr:SortUnionWishList()
	local function fun(a, b)
		return a.pb.time < b.pb.time
	end

	table.sort(self.listUnionWish, fun)

	local mineWish

	for k, v in pairs(self.listUnionWish) do
		if v:IsMine() then
			mineWish = v

			table.remove(self.listUnionWish, k)

			break
		end
	end

	if mineWish then
		table.insert(self.listUnionWish, 1, mineWish)
	end
end

function UnionWishMgr:GetUnionWish(wishId)
	for _, v in pairs(self.listUnionWish) do
		if v.id == wishId then
			return v
		end
	end

	return nil
end

function UnionWishMgr:Clear()
	self.listUnionWish = {}

	UnionWishRecvMgr:Clear()
end

function UnionWishMgr:GetCanReleaseWishs()
	local listWish = {}
	local listHoldCard = RoleCardMgr:GetAllHoldCard()
	local listNumOfRank = GetConfigArgJson("ClubWishCardRank")

	for i = 1, #listHoldCard do
		local soulId = ItemManager:GetCardSoulId(listHoldCard[i].id)
		local infoItem = ItemManager:Get(soulId)
		local need = listNumOfRank[listHoldCard[i].cardRank]
		local temp = {
			info = infoItem,
			need = need
		}

		table.insert(listWish, temp)
	end

	return listWish
end

function UnionWishMgr:SetMineWish(cardId, need)
	local pbWish = {}

	pbWish.playerId = PlayerInst.InfoPlayer.pid
	pbWish.playerName = PlayerInst:GetNickName()
	pbWish.roleCard = cardId or 105001
	pbWish.need = need or 0
	pbWish.grant = 0
	pbWish.time = NetData:GetCurServerTime()
	pbWish.selfGrant = false

	local infoUnionWish = InfoUnionWish(pbWish)

	table.insert(self.listUnionWish, 1, infoUnionWish)
end

function UnionWishMgr:GetMineWishs()
	local temp = {}

	for i = 1, #self.listUnionWish do
		if type(self.listUnionWish[i]) == "table" then
			local infoUnionWish = self.listUnionWish[i]

			if infoUnionWish:IsMine() then
				table.insert(temp, infoUnionWish)
			end
		end
	end

	return temp
end

function UnionWishMgr:CanReleaseWish()
	local mineWishs = self:GetMineWishs()
	local limitNum = GetConfigArgInt("ClubWishDailyCount")

	return limitNum > table.getn(mineWishs)
end

UnionWishRecvMgr = {}
UnionWishRecvMgr.listRecvGift = {}
UnionWishRecvMgr.ExistCanReceive = false
UnionWishRecvMgr.Requested = false
eThanksType = {
	NotThanked = 0,
	Thanked = 1
}

function UnionWishRecvMgr:SetData(pbPlayers)
	self.listRecvGift = {}

	for i = 1, #pbPlayers do
		local pbPlayer = pbPlayers[i]
		local info = InfoPlayer()

		info:SetData(pbPlayer)
		table.insert(self.listRecvGift, info)
	end

	local mineWishs = UnionWishMgr:GetMineWishs()

	mineWishs[1].grant = #pbPlayers
end

function UnionWishRecvMgr:Clear()
	self.listRecvGift = {}
	self.ExistCanReceive = false

	UnionRDL.WishRDL.SubRD()
end

function UnionWishRecvMgr:ChangeCanReceiveState(state)
	self.ExistCanReceive = state
end

function UnionWishRecvMgr:GetGiftMeTime(playerId)
	local time = 0

	for _, v in pairs(self.listRecvGift) do
		if playerId == v.pid then
			time = v.extras[2]
		end
	end

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local disTime = Mathf.Round(curServerTime - time)

	return GetStrDisTime(disTime)
end

UnionWishRecordMgr = {}
UnionWishRecordMgr.listRecord = {}

local recordLimitNum = GetConfigArgInt("ClubWishLogNum")

function UnionWishRecordMgr:SetData(pbLogs)
	self.listRecord = {}

	for i = 1, #pbLogs do
		local pbLog = pbLogs[i]
		local infoRecord = self:SetRecordInfo(pbLog)

		table.insert(self.listRecord, infoRecord)
	end
end

function UnionWishRecordMgr:SetRecordInfo(pbLog)
	local temp = {}
	local soulId = ItemManager:GetCardSoulId(pbLog.roleCard)

	temp.soul = ItemManager:Get(soulId)
	temp.type = pbLog.type

	local str = _("Desc_Presented_Other_Player")

	if pbLog.type == 2 then
		str = _("Desc_Received_Other_Player")
	end

	temp.info = string.format(str, pbLog.playerName)

	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local disTime = Mathf.Round(curServerTime - pbLog.time)

	temp.strTime = GetStrDisTime(disTime)

	return temp
end

require("Info/InfoTalent")

local unionSkillLevel = require("luaData/ClubSkillLevel")

InfoUnionSkill = class("InfoUnionSkill", InfoBase)

function InfoUnionSkill:ctor(id)
	self.id = id
	self.data = TalentManager:Get(id).data
	self.maxLevel = UnionSkillMgr:GetSkillMaxLevel(id)
	self.exp = 0
	self.curExp = 0
	self.nextExp = 0
	self.curLevel = 0
	self.hotSpot = 0
	self.selfHot = false
	self.pb = {}
end

function InfoUnionSkill:SetData(pbSkill)
	self.curLevel = pbSkill.skillLevel
	self.exp = pbSkill.skillExp
	self.hotSpot = pbSkill.hotspot
	self.selfHot = pbSkill.selfHot

	self:UpdateAll()
end

function InfoUnionSkill:UpdateAll()
	local data = self:UpdateExp(self.exp)

	self.curExp = data.curExp
	self.nextExp = data.nextExp
end

function InfoUnionSkill:UpdateExp(exp)
	local curExp = self.exp - UnionSkillMgr:GetClubSkillExp(self.id, self.curLevel - 1)
	local nextExp = UnionSkillMgr:GetClubSkillNeedExp(self.id, self.curLevel)
	local data = {
		curExp = curExp,
		nextExp = nextExp
	}

	return data
end

function InfoUnionSkill:ChangeSelfHot(vboll)
	self.selfHot = vboll
end

function InfoUnionSkill:ChangeHotSpot(v)
	self.hotSpot = self.hotSpot + v
end

function InfoUnionSkill:ChangeLevel()
	self.curLevel = UnionSkillMgr:GetUnionSkillLevel(self.id, self.exp)

	self:UpdateAll()
end

function InfoUnionSkill:ChangeExp(changeValue)
	self.exp = self.exp + changeValue

	self:UpdateAll()
end

function InfoUnionSkill:NeedUpLevel()
	local data = self:UpdateExp(self.exp)

	if data.curExp >= data.nextExp then
		return true
	end

	return false
end

function InfoUnionSkill:IsMaxLevel()
	return self.curLevel >= self.maxLevel
end

function InfoUnionSkill:GetIconPath()
	if self.data then
		return "UIDyAtlas/Skill/" .. self.data.Icon
	end

	return ""
end

UnionSkillMgr = {}
UnionSkillMgr.listUnionSkill = {}

function UnionSkillMgr:Get(skillId)
	if next(self.listUnionSkill) ~= nil then
		for _, v in ipairs(self.listUnionSkill) do
			if v.id == skillId then
				return v
			end
		end
	end

	return nil
end

function UnionSkillMgr:SetData(pbSkills)
	self.listUnionSkill = {}

	for _, pbSkill in ipairs(pbSkills) do
		if pbSkill.skillId ~= 400010003 then
			local info = self:Get(pbSkill.skillId)

			if info then
				info:SetData(pbSkill)
			else
				info = InfoUnionSkill(pbSkill.skillId)

				info:SetData(pbSkill)
				table.insert(self.listUnionSkill, info)
			end
		end
	end

	table.sort(self.listUnionSkill, function(a, b)
		return a.id < b.id
	end)
end

function UnionSkillMgr:ResetSkill(pbSkill)
	local info = self:Get(pbSkill.id)

	if info then
		info:SetData(pbSkill)
	end
end

function UnionSkillMgr:GetMineSpots()
	local sum = 0

	for k, v in pairs(self.listUnionSkill) do
		if v.selfHot then
			sum = sum + 1
		end
	end

	return sum
end

function UnionSkillMgr:CanPointSkill()
	local limitSpotNum = GetConfigArgInt("ClubSkillHotNum")
	local curSpotNum = self:GetMineSpots()

	return curSpotNum < limitSpotNum
end

function UnionSkillMgr:GetUpCostAsset(infoSkill)
	local id = 501
	local num = 0

	if infoSkill.curLevel >= infoSkill.maxLevel then
		num = 0
	end

	for _, v in pairs(unionSkillLevel) do
		if v.SkillId == infoSkill.id and v.Level == infoSkill.curLevel then
			num = v.UpClubCoin
		end
	end

	return id, num
end

function UnionSkillMgr.GetSkillUpCostItemData()
	local list = ItemManager:GetItemListByType("I_EXP_CLUB")
	local item = ItemManager:Get(list[1].ID)

	return item
end

function UnionSkillMgr:GetSkillLevelList(id)
	local listLevel = {}

	for _, v in pairsByKeys(unionSkillLevel) do
		if v.SkillId == id then
			table.insert(listLevel, v)
		end
	end

	table.sort(listLevel, function(a, b)
		return a.Level < b.Level
	end)

	return listLevel
end

function UnionSkillMgr:GetSkillMaxLevel(id)
	local listLevel = self:GetSkillLevelList(id)

	return listLevel[#listLevel].Level
end

function UnionSkillMgr:GetUnionSkillLevel(id, exp)
	local level = 1
	local listLevel = self:GetSkillLevelList(id)

	while level < #listLevel do
		if listLevel[level].LevelPointAdd == 0 then
			level = level - 1

			break
		end

		if exp < listLevel[level].LevelPointAdd then
			break
		end

		level = level + 1
	end

	return level
end

function UnionSkillMgr:GetClubSkillExp(id, level)
	local listLevel = self:GetSkillLevelList(id)

	if listLevel[level] == nul then
		return 0
	end

	return listLevel[level].LevelPointAdd
end

function UnionSkillMgr:GetClubSkillNeedExp(id, level)
	local listLevel = self:GetSkillLevelList(id)

	if level == 0 then
		return 0
	end

	return listLevel[level].LevelPoint
end

function UnionSkillMgr:GetUnionSkill(_type)
	local list = {}

	for i = 1, #self.listUnionSkill do
		local skill = self.listUnionSkill[i]

		if skill.data.Type == _type then
			local skill = {
				skillId = skill.id,
				skillLevel = skill.curLevel
			}

			table.insert(list, skill)
		end
	end

	return list
end

function UnionWishMgr.IsSetData()
	return IsSetData
end
