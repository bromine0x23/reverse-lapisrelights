-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoPlayer.lua

require("Info/InfoLevel")

InfoPlayer = class("InfoPlayer")
PlayerTitleType = {
	frame = 2,
	head = 1,
	medal = 3
}
ePlayerInfoType = {
	birthday = 2,
	nickName = 1,
	showRole = 4,
	head = 6,
	headFrame = 7,
	signature = 3,
	medal = 8,
	showCards = 5
}

function InfoPlayer:ctor()
	self.pid = 0
	self.name = 1
	self.signature = ""
	self.birthday = 0
	self.headId = 0
	self.headFrame = 0
	self.medal = 0
	self.showRole = 0
	self.leader = nil
	self.roleCards = {}
	self.isFreeCoinDebt = false
	self.gold = ObscuredUtils.GetObscuredInt(500000)
	self.diamond = ObscuredUtils.GetObscuredInt(0)
	self.diamondPay = ObscuredUtils.GetObscuredInt(0)
	self.power = ObscuredUtils.GetObscuredInt(0)
	self.friendCoin = 0
	self.clubCoin = 0
	self.skinCoin = 0
	self.pvpCoin = 0
	self.pvpTicket = 0
	self.exp = 1
	self.vip = 1
	self.vipExp = 0
	self.rank = 1
	self.curLevel = 1
	self.maxLevel = GetConfigArgInt("TeamMaxLevel")
	self.maxPower = LevelManager:GetMaxPowerByLevel(self.curLevel)
	self.preLevel = 1
	self.preCurExp = 0
	self.preNextExp = 0
	self.regTime = 0
	self.loginTime = 0
	self.logoutTime = 0
	self.isOnline = false
	self.payStatus = 0
	self.newbieProgress = 0
	self.clubName = ""
	self.favoriteRoles = {}
	self.extras = {}
	self.isBuddy = false
	self.levelTime = 0
	self.bpAvatars = {}
	self.freeDrawInfo = {}
	self.activeCardGroup = 1
	self.isPay = false
	self.publicId = 0
	self.liveTickets = 0
	self.supportTickets = 0
	self.signTicket = 0
	self.chatRoomId = ""
	self.gender = Gender.Woman
	self.partyId = 0
	self.initSkin = 1
	self.termsOfUseVersion = 0
end

function InfoPlayer:CanFreeDraw()
	return self.freeDrawInfo.freeDrawCount and self.freeDrawInfo.supportPools and self.freeDrawInfo.freeDrawCount > 0 and #self.freeDrawInfo.supportPools > 0
end

function InfoPlayer:CanFreeDrawPool(poolId)
	return self:CanFreeDraw() and table.contains(self.freeDrawInfo.supportPools, poolId)
end

function InfoPlayer:SetFreeDraw(drawCount, activityId, usedTenDrawCount, todayTenDrawCount)
	self.freeDrawInfo.freeDrawCount = drawCount
	self.freeDrawInfo.usedTenDrawCount = usedTenDrawCount
	self.freeDrawInfo.todayTenDrawCount = todayTenDrawCount

	if activityId ~= 0 then
		local freeData = require("luaData/m_activity_free_ten_draw")
		local freeInfoData = freeData[activityId]

		self.freeDrawInfo.supportPools = freeInfoData.card_pool_id
		self.freeDrawInfo.totalDrawCount = freeInfoData.free_times
		self.freeDrawInfo.drawType = freeInfoData.cumulate_or_not
	end
end

function InfoPlayer:CheckFreeGache(pid, tp)
	if tp == 2 and self:CanFreeDrawPool(pid) then
		self.freeDrawInfo.freeDrawCount = self.freeDrawInfo.freeDrawCount - 1

		return true
	end

	return false
end

function InfoPlayer:SetPlayerRes(pbPlayer)
	if pbPlayer then
		self.gold = ObscuredUtils.GetObscuredInt(pbPlayer.gold)
		self.diamond = ObscuredUtils.GetObscuredInt(pbPlayer.diamond)
		self.diamondPay = ObscuredUtils.GetObscuredInt(pbPlayer.diamondPay)
		self.isFreeCoinDebt = pbPlayer.isFreeCoinDebt
	end
end

function InfoPlayer:SetData(pbPlayer)
	if pbPlayer.playerId == 0 then
		return
	end

	self.pb = pbPlayer
	self.pid = pbPlayer.playerId
	self.name = pbPlayer.nickname
	self.signature = pbPlayer.signature
	self.birthday = pbPlayer.birthday
	self.headId = pbPlayer.headId
	self.headFrame = pbPlayer.headFrame
	self.medal = pbPlayer.medal
	self.showRole = pbPlayer.showRole
	self.leader = pbPlayer.leader
	self.roleCards = pbPlayer.roleCards
	self.gold = ObscuredUtils.GetObscuredInt(pbPlayer.gold)
	self.diamond = ObscuredUtils.GetObscuredInt(pbPlayer.diamond)
	self.diamondPay = ObscuredUtils.GetObscuredInt(pbPlayer.diamondPay)
	self.isFreeCoinDebt = pbPlayer.isFreeCoinDebt
	self.power = ObscuredUtils.GetObscuredInt(pbPlayer.power)
	self.friendCoin = pbPlayer.friendCoin
	self.clubCoin = pbPlayer.clubCoin
	self.exp = pbPlayer.levelExp
	self.vipExp = pbPlayer.vipExp

	self:UpdateExp()

	self.payStatus = pbPlayer.payStatus
	self.newbieProgress = pbPlayer.newbieProgress
	self.regTime = pbPlayer.regTime
	self.loginTime = NetData:GetCurServerTime()
	self.logoutTime = pbPlayer.logoutTime
	self.isOnline = pbPlayer.isOnline

	if self.logoutTime == 0 then
		self.logoutTime = self.loginTime
	end

	self.clubName = pbPlayer.clubName
	self.favoriteRoles = pbPlayer.favoriteRoles
	self.extras = pbPlayer.extras
	self.isBuddy = pbPlayer.isBuddy
	self.levelTime = pbPlayer.levelTime
	self.isPay = pbPlayer.isPay
	self.gender = pbPlayer.gender
	self.bpAvatars = pbPlayer.commonAvatars
	self.termsOfUseVersion = pbPlayer.termsOfUseVersion
end

function InfoPlayer:UpdateExp()
	self:UpdatePreLevel()

	local lv = LevelManager:GetPlayerLevel(self.exp) or 0

	self.curLevel = Mathf.Min(lv, self.maxLevel)

	local nextExp = LevelManager:GetPlayerNeedExp(self.curLevel)
	local curExp = self.exp - LevelManager:GetPlayerExp(self.curLevel - 1)

	self.nextExp = nextExp
	self.curExp = curExp
	self.maxPower = LevelManager:GetMaxPowerByLevel(self.curLevel)
end

function InfoPlayer:UpdatePreLevel()
	self.preLevel = self.curLevel
	self.preCurExp = self.curExp
	self.preNextExp = self.nextExp
end

function InfoPlayer:ChangeNickName(vNickName)
	self.name = vNickName
end

function InfoPlayer:GetNickName()
	return self.name
end

function InfoPlayer:ChangeBirthday(vBirthday)
	self.birthday = vBirthday
end

function InfoPlayer:GetBirthday()
	return self.birthday
end

function InfoPlayer:ChangeSignature(vSignature)
	self.signature = vSignature
end

function InfoPlayer:GetSignature()
	if self.signature == nil or self.signature == "" then
		self.signature = Lang(GetConfigArgInt("DefaultPlayerSign"))
	end

	return self.signature
end

function InfoPlayer:IsVip()
	return self.vipExp > 0
end

function InfoPlayer:SetRank(vRank)
	self.rank = vRank
end

function InfoPlayer:GetRank()
	return self.rank
end

function InfoPlayer:GetExp()
	return self.exp
end

function InfoPlayer:ChangeExp(changeValue)
	self.exp = self.exp + changeValue

	self:UpdateExp()
end

function InfoPlayer:GetShowExp()
	return self.showExp
end

function InfoPlayer:SetShowRole(vRoleId)
	self.showRole = vRoleId
end

function InfoPlayer:GetShowRole()
	if self.showRole == 0 then
		self.showRole = 105
	end

	return self.showRole
end

function InfoPlayer:GetTitleIcon(_type)
	local itemId = self.headId

	if _type == 2 then
		itemId = self.headFrame
	elseif _type == 3 then
		itemId = self.medal
	end

	local infoItem = ItemManager:Get(itemId)

	return infoItem:GetIcon()
end

function InfoPlayer:GetRegisterTime()
	return self.regTime
end

function InfoPlayer:ChangeGold(changeValue)
	self.gold = ObscuredUtils.GetObscuredInt(self.gold:GetDecrypted() + changeValue)
end

function InfoPlayer:GetGold()
	return self.gold:GetDecrypted()
end

function InfoPlayer:ChangeDiamond(changeValue)
	self.diamond = ObscuredUtils.GetObscuredInt(self.diamond:GetDecrypted() + changeValue)
end

function InfoPlayer:GetDiamond()
	return self.diamond:GetDecrypted()
end

function InfoPlayer:GetDiamondPay()
	return self.diamondPay:GetDecrypted()
end

function InfoPlayer:ChangeDiamondPay(changeValue)
	self.diamondPay = ObscuredUtils.GetObscuredInt(self.diamondPay:GetDecrypted() + changeValue)
end

function InfoPlayer:GetDiamondAll()
	return self.diamond:GetDecrypted() + self.diamondPay:GetDecrypted()
end

function InfoPlayer:SetPower(curPower)
	self.power = curPower
	self.power = ObscuredUtils.GetObscuredInt(Mathf.Min(PowerMgr.Instance.MaxLimit, self.power))
end

function InfoPlayer:ChangePower(v)
	self.power = self.power:GetDecrypted() + v
	self.power = ObscuredUtils.GetObscuredInt(Mathf.Min(PowerMgr.Instance.MaxLimit, self.power))
end

function InfoPlayer:GetPower()
	return self.power:GetDecrypted()
end

function InfoPlayer:ChangeRenameCard(changeValue)
	self.renameCard = self.renameCard + changeValue
end

function InfoPlayer:GetRenameCard()
	return self.renameCard
end

function InfoPlayer:ChangeFriendCoin(changeValue)
	self.friendCoin = self.friendCoin + changeValue
end

function InfoPlayer:GetFriendCoin()
	return self.friendCoin
end

function InfoPlayer:ChangeSkinCoin(changeValue)
	self.skinCoin = self.skinCoin + changeValue
end

function InfoPlayer:GetSkinCoin()
	return self.skinCoin
end

function InfoPlayer:ChangeClubCoin(changeValue)
	self.clubCoin = self.clubCoin + changeValue
end

function InfoPlayer:GetClubCoin()
	return self.clubCoin
end

function InfoPlayer:ChangePVPCoin(changeValue)
	self.pvpCoin = self.pvpCoin + changeValue
end

function InfoPlayer:GetPVPCoin()
	return self.pvpCoin
end

function InfoPlayer:ChangePVPTicket(changeValue)
	self.pvpTicket = self.pvpTicket + changeValue
end

function InfoPlayer:GetLuckyBackAwardLogout()
	return self.logoutTime
end

function InfoPlayer:GetPVPTicket()
	return self.pvpTicket
end

function InfoPlayer:IsFavoriteRole(vRoleId)
	for _, v in ipairs(self.favoriteRoles) do
		if tonumber(v.id) == vRoleId then
			return true
		end
	end

	return false
end

function InfoPlayer:GetRoleFavoriteTime(vRoleId)
	for _, v in ipairs(self.favoriteRoles) do
		if tonumber(v.id) == vRoleId then
			return tonumber(v.value)
		end
	end

	return 0
end

function InfoPlayer:AddFavoriteRole(vRoleId)
	local isHave = false

	for _, v in ipairs(self.favoriteRoles) do
		if v.id == vRoleId then
			v.value = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
			isHave = true

			break
		end
	end

	if not isHave then
		local t = {
			id = vRoleId,
			value = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
		}

		table.insert(self.favoriteRoles, t)
	end
end

function InfoPlayer:RemoveFavoriteRole(vRoleId)
	for k, v in ipairs(self.favoriteRoles) do
		if v.id == vRoleId then
			table.remove(self.favoriteRoles, k)

			break
		end
	end
end

function InfoPlayer:GetBPAvatar(avatarId)
	for _, pbAvatar in ipairs(self.bpAvatars) do
		if pbAvatar.avatarId == avatarId then
			return pbAvatar
		end
	end

	return nil
end

function InfoPlayer:AddBPAvatar(pbAvatar)
	if self:GetBPAvatar(pbAvatar.avatarId) == nil then
		table.insert(self.bpAvatars, pbAvatar)
	end
end

function InfoPlayer:ChangeBPAvatarBind(avatarId, roleId)
	local preRoleId = 0

	for _, pbAvatar in ipairs(self.bpAvatars) do
		if pbAvatar.avatarId == avatarId then
			preRoleId = pbAvatar.roleId
			pbAvatar.roleId = roleId

			break
		end
	end

	local infoRole = RoleMgr:GetRole(roleId)

	if infoRole then
		infoRole:AddAvatar(avatarId)

		if not table.contains(infoRole.bpAvatars, avatarId) then
			table.insert(infoRole.bpAvatars, avatarId)
			infoRole:UpdateBPAvatarAttr()
		end
	end

	if preRoleId ~= 0 then
		local preInfoRole = RoleMgr:GetRole(preRoleId)

		if preInfoRole then
			preInfoRole:RemoveAvatar(avatarId)
			table.removeByValue(preInfoRole.bpAvatars, avatarId)
			preInfoRole:UpdateBPAvatarAttr()
		end
	end
end

function InfoPlayer:IsBPGeted(avatarId)
	for _, v in ipairs(self.bpAvatars) do
		if v.avatarId == avatarId then
			return true
		end
	end

	return false
end

function InfoPlayer:GetBPAvatarIdx(avatarId)
	for k, v in ipairs(self.bpAvatars) do
		if v.avatarId == avatarId then
			return k
		end
	end

	return -1
end
