-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/Player.lua

require("Info/PowerMgr")
require("Info/InfoPlayer")

Player = class("Player")
Gender = {
	Man = 1,
	Woman = 0
}

function Player:ctor()
	self.InfoPlayer = InfoPlayer()
	self.CurtMusic = nil
	self.server_time = nil
	self.lp_last_time = nil
	self.MaxHP = 1000
	self.CurtHP = self.MaxHP
	self.Expection = 100
	self.MaxLevel = GetConfigArgInt("TeamMaxLevel")
	self.MaxVipLevel = GetConfigArgInt("VipMaxLevel")
	self.MaxFriendHelp = 1
	self.hasNewFriendGift = false
	self.hasNewFriend = false
	self.pbFriendList = {}
	self.needInitFriend = true
	self.pbFriendRole = {}
	self.pbFriendHelpInfo = {}
	self.pbFriendHelpTimeReset = 0
	self.pbFriendGift = {}
	self.needInitFriendGift = true
	self.pbFriendApply = {}
	self.needInitFriendApply = true
	self.giveGiftFriends = nil
	self.giveGiftTime = nil
	self.giveGiftCount = nil
	self.MaxSendFriendGift = 1
	self.otherPlayerInfo = {}
	self.pbMails = {}
	self.needInitMail = true
	self.needInitNoticeMail = true
	self.MaxMails = 200
	self.IsNewbie = false
end

function Player:ChangeNickName(v)
	self.InfoPlayer:ChangeNickName(v)
end

function Player:GetNickName()
	return self.InfoPlayer.name
end

function Player:ChangeBirthday(v)
	self.InfoPlayer:ChangeBirthday(v)
end

function Player:GetBirthday()
	return self.InfoPlayer.birthday
end

function Player:ChangeSignature(v)
	self.InfoPlayer:ChangeSignature(v)
end

function Player:GetSignature()
	return self.InfoPlayer.signature
end

function Player:SetShowRole(v)
	self.InfoPlayer:SetShowRole(v)
end

function Player:GetShowRole(v)
	return self.InfoPlayer:GetShowRole(v)
end

function Player:ChangeGold(v)
	self.InfoPlayer:ChangeGold(v)
end

function Player:GetGold()
	return self.InfoPlayer:GetGold()
end

function Player:ChangeDiamond(v)
	self.InfoPlayer:ChangeDiamond(v)
end

function Player:GetDiamond()
	return self.InfoPlayer:GetDiamond()
end

function Player:ChangeDiamondPay(v)
	self.InfoPlayer:ChangeDiamondPay(v)
end

function Player:GetDiamondPay()
	return self.InfoPlayer:GetDiamondPay()
end

function Player:GetDiamondAll()
	return self.InfoPlayer:GetDiamondAll()
end

function Player:SetPower(v)
	self.InfoPlayer:SetPower(v)
end

function Player:ChangePower(v)
	self.InfoPlayer:ChangePower(v)
end

function Player:GetPower()
	return self.InfoPlayer:GetPower()
end

function Player:ChangeFriendCoin(v)
	self.InfoPlayer:ChangeFriendCoin(v)
end

function Player:GetFriendCoin()
	return self.InfoPlayer:GetFriendCoin()
end

function Player:ChangeClubCoin(v)
	self.InfoPlayer:ChangeClubCoin(v)
end

function Player:GetClubCoin()
	return self.InfoPlayer:GetClubCoin()
end

function Player:ChangeSkinCoin(v)
	self.InfoPlayer:ChangeSkinCoin(v)
end

function Player:GetSkinCoin()
	return self.InfoPlayer:GetSkinCoin()
end

function Player:ChangePVPTicket(v)
	self.InfoPlayer:ChangePVPTicket(v)
end

function Player:GetPVPTicket()
	return self.InfoPlayer:GetPVPTicket()
end

function Player:ChangePVPCoin(v)
	self.InfoPlayer:ChangePVPCoin(v)
end

function Player:GetPVPCoin()
	return self.InfoPlayer:GetPVPCoin()
end

function Player:ChangeExpection(changeValue)
	self.Expection = self.Expection + changeValue
end

function Player:ChangeExp(changeValue)
	self.InfoPlayer:ChangeExp(changeValue)
end

function Player:GetCurLv()
	local lv = LevelManager:GetPlayerLevel(self.InfoPlayer.exp)

	lv = Mathf.Min(lv, self.MaxLevel)

	return lv
end

function Player:GetNextLvExp()
	if self:GetCurLv() == self.MaxLevel - 1 then
		return 0
	end

	return LevelManager:GetTeamExp(self:GetCurLv() + 1)
end

function Player:GetMaxLevel()
	return self.MaxLevel
end

function Player:GetVipLevel()
	local lv = LevelManager:GetVipLevel(self.InfoPlayer.vipExp)

	lv = Mathf.Min(lv, self.MaxVipLevel)

	return lv
end

function Player:ChangeRenameCard(v)
	self.InfoPlayer:ChangeRenameCard(v)
end

function Player:GetRenameCard()
	return self.InfoPlayer:GetRenameCard()
end

function Player:GetBPAvatar(avatarId)
	return self.InfoPlayer:GetBPAvatar(avatarId)
end

function Player:AddBPAvatar(pbAvatar)
	self.InfoPlayer:AddBPAvatar(pbAvatar)
end

function Player:ChangeBPAvatarBind(avatarId, roleId)
	self.InfoPlayer:ChangeBPAvatarBind(avatarId, roleId)
end

function Player:IsBPGeted(avatarId)
	return self.InfoPlayer:IsBPGeted(avatarId)
end

function Player:GetBPAvatarIdx(avatarId)
	return self.InfoPlayer:GetBPAvatarIdx(avatarId)
end

function Player:IsBind(avatarId, roleId)
	local pbAvatar = self:GetBPAvatar(avatarId)

	if pbAvatar then
		return pbAvatar.roleId == roleId
	end

	return false
end

function Player:GetGender()
	return self.InfoPlayer.gender
end

function Player:ChangeLiveTicket(changeValue)
	self.InfoPlayer:ChangeLiveTicket(changeValue)
end

function Player:GetLiveTicket()
	return self.InfoPlayer:GetLiveTicket()
end

function Player:ChangeSupportTicket(changeValue)
	self.InfoPlayer:ChangeSupportTicket(changeValue)
end

function Player:ChangeThemeTicket(changeValue)
	self.InfoPlayer:ChangeThemeTicket(changeValue)
end

function Player:ChangeMainTicket(changeValue)
	self.InfoPlayer:ChangeMainTicket(changeValue)
end

function Player:ChangeSignTicket(changeValue)
	self.InfoPlayer:ChangeSignTicket(changeValue)
end

function Player:GetSupportTicket()
	return self.InfoPlayer:GetSupportTicket()
end

function Player:OneKeyRemoveMails()
	local num = #self.pbMails

	if num <= 50 then
		self.pbMails = {}
	else
		local tableP = {}

		for i = 51, num do
			table.insert(tableP, self.pbMails[i])
		end

		self.pbMails = tableP
	end
end

function Player:GetFriendGifts()
	local tableP = {}
	local curServerTime = NetData:GetCurServerTime()

	for i = 1, #self.pbFriendGift do
		if curServerTime < self.pbFriendGift[i].expireTime then
			table.insert(tableP, self.pbFriendGift[i])
		end
	end

	return tableP
end

function Player:RemoveFirendGifts(mailId)
	local index

	for i = 1, #self.pbFriendGift do
		if self.pbFriendGift[i].mailId == mailId then
			index = i

			break
		end
	end

	if index ~= nil then
		table.remove(self.pbFriendGift, index)
	end
end

function Player:GetReputationImgAndName()
	local id = PlayerInst.InfoPlayer.reputationId

	return GetReputationById(id)
end

function Player:SortingOnline(tableP)
	table.sort(tableP, function(a, b)
		return a.isOnline and not b.isOnline
	end)
end

function Player:ReadNoticeMail(mailId)
	local mails = PlayerPrefs.GetString(self.InfoPlayer.pid .. "HaveReadMails", "")

	if not self:HaveReadNoticeMail(mailId) then
		PlayerPrefs.SetString(self.InfoPlayer.pid .. "HaveReadMails", mails .. "#" .. mailId)
	end
end

function Player:HaveReadNoticeMail(id)
	local mails = PlayerPrefs.GetString(self.InfoPlayer.pid .. "HaveReadMails", "")
	local tables = SplitByParam(mails, "#")

	for i = 1, #tables do
		if tonumber(tables[i]) == id then
			return true
		end
	end

	return false
end

function Player:HaveNewNoticeMail()
	if self.noticeMail ~= nil then
		for i = 1, #self.noticeMail do
			local id = self.noticeMail[i].mailId

			if not self:HaveReadNoticeMail(id) then
				return true
			end
		end

		return false
	end

	return false
end

function Player:AddMails(mails)
	local curServerTime = NetData:GetCurServerTime()

	for i = 1, #mails do
		if mails[i].type == 0 then
			if self.pbMails == nil then
				self.pbMails = {}
			end

			local havedmail = false

			if #self.pbMails > 0 then
				for j = 1, #self.pbMails do
					if self.pbMails[j].mailId == mails[i].mailId then
						havedmail = true

						break
					end
				end

				if havedmail then
					break
				else
					table.insert(self.pbMails, mails[i])
				end
			else
				table.insert(self.pbMails, mails[i])
			end
		elseif mails[i].type == 1 then
			if self.pbFriendGift == nil then
				self.pbFriendGift = {}
			end

			table.insert(self.pbFriendGift, mails[i])

			PlayerInst.hasNewFriendGift = true
		elseif mails[i].type == 2 and (mails[i].endTime == 0 or curServerTime < mails[i].endTime) then
			if self.noticeMail == nil then
				self.noticeMail = {}
			end

			table.insert(self.noticeMail, mails[i])
		end
	end
end

function Player:AddOtherPlayerInfo(dataP)
	local index = 0

	for i = 1, #self.otherPlayerInfo do
		if self.otherPlayerInfo[i].playerInfo.playerId == dataP.playerInfo.playerId then
			table.remove(self.otherPlayerInfo, i)

			break
		end
	end

	table.insert(self.otherPlayerInfo, dataP)
end

function Player:SendFriendGift(playerId)
	if self.giveGiftTime ~= nil and self.giveGiftTime > 0 then
		if TimeIsNotToday(self.giveGiftTime) then
			self.giveGiftCount = 1
			self.giveGiftFriends = {}
		else
			self.giveGiftCount = self.giveGiftCount + 1
		end
	else
		self.giveGiftCount = 1
		self.giveGiftFriends = {}
	end

	self.giveGiftTime = NetData:GetCurServerTime()

	table.insert(self.giveGiftFriends, playerId)
end

function Player:TodayIsSendFriendGift(playerId)
	if self.giveGiftTime ~= nil and self.giveGiftTime > 0 then
		if not TimeIsNotToday(self.giveGiftTime) and self.giveGiftFriends ~= nil then
			for i = 1, #self.giveGiftFriends do
				if playerId == self.giveGiftFriends[i] then
					return true
				end
			end
		end
	else
		return true
	end

	return false
end

function Player:DeleteFriend(name, palyerId)
	local index

	if palyerId ~= nil and self.pbFriendList ~= nil then
		for i = 1, #self.pbFriendList do
			if palyerId == self.pbFriendList[i].playerId then
				index = i

				break
			end
		end
	end

	if index ~= nil then
		table.remove(self.pbFriendList, index)
	end
end

function Player:AddVoiceHaveDownload(roleID)
	if self.loadSongRoleIds == nil then
		self.loadSongRoleIds = {}
	end

	table.insert(self.loadSongRoleIds, roleID)
end

function Player:RoleVoiceHaveDownload(roleID)
	if self.loadSongRoleIds ~= nil then
		for i = 1, #self.loadSongRoleIds do
			if self.loadSongRoleIds[i] == roleID then
				return true
			end
		end
	end

	return false
end

function Player:GetFriendHelpRoleInfo(...)
	self:ResetFriendHelpNum()

	local info = {}

	for i = 1, #self.pbFriendList do
		local player = self.pbFriendList[i]
		local times = self.pbFriendHelpInfo[player.playerId]

		if times ~= nil and times < self.MaxFriendHelp then
			table.insert(info, player)
		elseif times == nil then
			table.insert(info, player)
		end
	end

	return info
end

function Player:ResetFriendHelpNum()
	local curTimeStamp = Mathf.Round(NetData:GetCurServerTime() / 1000)
	local today = os.date("*t", curTimeStamp)
	local todayStart = os.time({
		hour = 0,
		second = 0,
		minute = 0,
		day = today.day,
		month = today.month,
		year = today.year
	})
	local changeTime = Mathf.Round(self.pbFriendHelpTimeReset / 1000)
	local changeDay = os.date("*t", changeTime)
	local changeStart = os.time({
		hour = 0,
		second = 0,
		minute = 0,
		day = changeDay.day,
		month = changeDay.month,
		year = changeDay.year
	})

	if todayStart ~= changeStart then
		for k, v in pairs(self.pbFriendHelpInfo) do
			self.pbFriendHelpInfo[k] = 0
		end

		self.pbFriendHelpTimeReset = curTimeStamp
	end
end

function Player:FirendHelpTimeAdd(playerId)
	if self.pbFriendHelpInfo[playerId] ~= nil then
		self.pbFriendHelpInfo[playerId] = self.pbFriendHelpInfo[playerId] + 1
	else
		self.pbFriendHelpInfo[playerId] = 1
	end
end

function Player:SetFriendHelpInfo(helps)
	if helps ~= nil then
		for i = 1, #helps / 2 do
			local playerId = helps[i * 2 - 1]
			local times = helps[i * 2]

			self.pbFriendHelpInfo[playerId] = times
		end
	end
end

function Player:GetFriendInfoByPid(pid)
	for i = 1, #self.pbFriendList do
		local friend = self.pbFriendList[i]

		if friend.playerId == pid then
			return friend
		end
	end

	return nil
end

function Player:GetFriendIdsNoPbRole()
	local playerIds = {}

	for i = 1, #self.pbFriendList do
		local player = self.pbFriendList[i]

		if self.pbFriendRole[player.playerId] == nil then
			table.insert(playerIds, player.playerId)
		end
	end

	return playerIds
end

function Player:InitFriendList(callBack)
	if self.needInitFriend then
		local function wrap_cb(pbMes)
			self:OnHandleGetFriendList(pbMes, callBack)
		end

		LoadingMgr.Show(eLoadingType.Repeat)
		NetManager:RequestGetFriendList(wrap_cb)
	elseif callBack then
		callBack()
	end
end

function Player:OnHandleGetFriendList(vPBMessage, callBack)
	LoadingMgr.Hide(eLoadingType.Repeat)

	if vPBMessage.result.code == NetManager.Result_Sucess then
		if callBack ~= nil then
			callBack()
		end
	else
		UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
	end
end

function Player:SetFriendPbRole(roles)
	for i = 1, #roles do
		for j = 1, #self.pbFriendList do
			local playerId = self.pbFriendList[j].playerId

			if self.pbFriendList[j].playerId == roles[i].playerId then
				self.pbFriendRole[playerId] = roles[i]

				local infoCharac = self:GetFriendCharacterInfo(roles[i].playerId, roles[i].id)

				infoCharac:SetData(roles[i])

				break
			end
		end
	end
end

function Player:GetFriendRoleById(playerId)
	return self.pbFriendRole[playerId]
end

function Player:GetFriendCharacterInfo(playerID, vCharacterId)
	if type(vCharacterId) == "string" then
		vCharacterId = tonumber("0x" .. vCharacterId)
	end

	local ret = self.friendCharacDict:GetValue(tostring(playerID) .. vCharacterId)

	if not ret then
		local character_pb = {}

		character_pb.playerId = playerID
		character_pb.id = vCharacterId
		character_pb.avatar = nil
		character_pb.listGetedAvatar = {
			1001
		}
		character_pb.order = 1
		character_pb.power = 10
		character_pb.exp = 0
		character_pb.skill = {}
		character_pb.isHold = false
		character_pb.soul = 0
		character_pb.levelExp = 0
		character_pb.starExp = 0
		character_pb.favorExp = 0
		ret = InfoCharacter(character_pb)

		self.friendCharacDict:Set(tostring(playerID) .. vCharacterId, ret)
	end

	return ret
end

function Player:GetSDKNeedPlayerInfo()
	local gamePlayerInfo = quicksdk.GameRoleInfo()

	gamePlayerInfo.serverID = NetData.ServerID
	gamePlayerInfo.serverName = NetData.ServerName
	gamePlayerInfo.gameRoleName = self.InfoPlayer.name
	gamePlayerInfo.gameRoleID = tostring(self.InfoPlayer.pid)
	gamePlayerInfo.gameRoleBalance = tostring(self:GetDiamond())
	gamePlayerInfo.vipLevel = tostring(self:GetVipLevel())
	gamePlayerInfo.gameRoleLevel = tostring(self:GetCurLv())
	gamePlayerInfo.partyName = Localization.Get("PVP_NoOrder")
	gamePlayerInfo.roleCreateTime = tostring(math.floor(self.InfoPlayer.regTime / DateUtil.MillsPerSecond))

	local strGender = ""

	if self.InfoPlayer.gender == Gender.Man then
		strGender = Localization.Get("Gender_Man")
	else
		strGender = Localization.Get("Gender_Woman")
	end

	gamePlayerInfo.gameRoleGender = strGender
	gamePlayerInfo.gameRolePower = tostring(CharacterMgr:GetFormationFC())
	gamePlayerInfo.partyId = tostring(self.InfoPlayer.partyId)
	gamePlayerInfo.professionId = "0"
	gamePlayerInfo.profession = "無し"
	gamePlayerInfo.partyRoleId = "0"
	gamePlayerInfo.partyRoleName = Localization.Get("PVP_NoOrder")
	gamePlayerInfo.friendlist = Localization.Get("PVP_NoOrder")

	return gamePlayerInfo
end

Player.OnPlayerBasicInfoChange = {}
PlayerInst = PlayerInst or Player()
PlayerInst.friendCharacDict = PlayerInst.friendCharacDict or Record()
PlayerInst.showHead = false
PlayerInst.tabIndex = 0
