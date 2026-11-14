-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoFriend.lua

InfoFriend = class("InfoFriend", InfoBase)
Friend_Gift_State = {
	Have = 2,
	Geted = 3,
	None = 1
}

function InfoFriend:ctor(pb)
	self.id = pb.playerId
	self.level = 1
	self.sendCoinTime = 0
	self.coinState = 1
	self.pb = {}

	self:SetCommonData(pb)
end

function InfoFriend:SetCommonData(pb)
	self.pb.nickname = pb.nickname
	self.pb.showRole = pb.showRole
	self.pb.headId = pb.headId
	self.pb.headFrame = pb.headFrame
	self.pb.medal = pb.medal
	self.pb.levelExp = pb.levelExp
	self.pb.power = pb.power
	self.pb.isOnline = pb.isOnline
	self.pb.logoutTime = pb.logoutTime
	self.pb.clubName = pb.clubName
	self.level = LevelManager:GetPlayerLevel(self.pb.levelExp)
end

function InfoFriend:SetSpecialData(pb)
	self.sendCoinTime = tonumber(pb.sendTime)
	self.coinState = pb.receiveCoin
end

function InfoFriend:GetStrLogoutTime()
	local logoutTime = tonumber(self.pb.logoutTime)

	return GetLogoutTimeFormat(logoutTime)
end

function InfoFriend:ChangeReceiveCoinState(state)
	self.coinState = state
end

function InfoFriend:ChangeLastGiftCoinTime()
	self.sendCoinTime = 1
end

function InfoFriend:IsGiftToday()
	if self.sendCoinTime == 1 then
		return true
	end

	return false
end

function InfoFriend:IsGiftToMe()
	if self.coinState == 2 then
		return true
	end

	return false
end

function InfoFriend:GetShowRole()
	if self.pb.showRole == 0 then
		self.pb.showRole = 105
	end

	return self.pb.showRole
end

function InfoFriend:GetTitleIcon(_type)
	local itemId = self.pb.headId

	if _type == PlayerTitleType.frame then
		itemId = self.pb.headFrame
	elseif _type == PlayerTitleType.medal then
		itemId = self.pb.medal
	end

	local infoItem = ItemManager:Get(itemId)

	return infoItem:GetIcon()
end

FriendMgr = {}
FriendMgr.listFriend = {}
FriendMgr.listApply = {}
FriendMgr.listRecommend = {}
FriendMgr.listBlack = {}

local listSearch = {}

FriendMgr.listRequest = {}

local lastChangeRecommendTime = 0

FriendMgr.maxFriendNum = GetConfigArgInt("FriendsMax")
FriendMgr.maxBlackNum = GetConfigArgInt("BlackListMax")

local recommendWaitTime = GetConfigArgInt("FriendRecommendWait")

FriendMgr.Requested = false
FriendMgr.IsExitOnPageFriend = false

function FriendMgr:GetInfoFriend(id)
	for i = 1, #self.listFriend do
		if self.listFriend[i].id == id then
			return self.listFriend[i]
		end
	end

	return nil
end

function FriendMgr:SetData(pb)
	self.listFriend = {}

	for i = 1, #pb.friends do
		local pbFriend = pb.friends[i]
		local pbPlayer = pbFriend.player
		local infoFriend = InfoFriend(pbPlayer)

		infoFriend:SetSpecialData(pbFriend)
		table.insert(self.listFriend, infoFriend)
	end

	self.listApply = {}

	for i = 1, #pb.applys do
		local pbPlayer = pb.applys[i]

		self:AddPlayerToList(self.listApply, pbPlayer)
	end

	self.listRecommend = {}

	for i = 1, #pb.recommends do
		local pbPlayer = pb.recommends[i]

		self:AddPlayerToList(self.listRecommend, pbPlayer)
	end

	self.listBlack = {}

	for i = 1, #pb.blacks do
		local pbPlayer = pb.blacks[i]

		self:AddPlayerToList(self.listBlack, pbPlayer)
	end

	FriendRDL.InitRD()
end

function FriendMgr:ChangeRecommendList(listpb)
	self.listRecommend = {}

	for i = 1, #listpb do
		local pbPlayer = listpb[i]

		self:AddPlayerToList(self.listRecommend, pbPlayer)
	end
end

function FriendMgr:SetSearchData(listpb)
	listSearch = {}

	self:AddSearchData(listpb)
end

function FriendMgr:AddSearchData(listpb)
	for i = 1, #listpb do
		if listpb[i].playerId ~= tostring(PlayerInst.InfoPlayer.pid) then
			self:AddPlayerToList(listSearch, listpb[i])
		end
	end
end

function FriendMgr:AddPlayerToList(list, pbPlayer)
	list = list or {}

	local infoFriend = InfoFriend(pbPlayer)
	local index = 0

	for k, v in ipairs(list) do
		if v.id == infoFriend.id then
			index = k

			break
		end
	end

	if index == 0 then
		table.insert(list, infoFriend)
	else
		list[index] = infoFriend
	end
end

function FriendMgr:AddToListFriend(list)
	for i = 1, #list do
		table.insert(self.listFriend, list[i])
		FriendMgr:DeleteFromListRequest(list[i].id)
	end
end

function FriendMgr:DeleteFromListFriend(id)
	for i = 1, #self.listFriend do
		if id == self.listFriend[i].id then
			table.remove(self.listFriend, i)

			break
		end
	end

	FriendRDL.InitGiftRD()
end

function FriendMgr:AddToListBlack(info)
	self:DeleteFromListFriend(info.id)
	self:DeleteFromListRecommend({
		info.id
	})
	self:DeleteFromListApply({
		info.id
	})
	table.insert(self.listBlack, info)
	FriendMgr:DeleteFromListRequest(info.id)
end

function FriendMgr:DeleteFromListBlack(info)
	for i = 1, #self.listBlack do
		if info.id == self.listBlack[i].id then
			table.remove(self.listBlack, i)

			break
		end
	end
end

function FriendMgr:DeleteFromListRecommend(listId)
	for i = #self.listRecommend, 1, -1 do
		local info = self.listRecommend[i]

		for j = 1, #listId do
			if info.id == listId[j] then
				table.remove(self.listRecommend, i)
			end
		end
	end
end

function FriendMgr:DeleteFromListApply(listId)
	for i = #self.listApply, 1, -1 do
		local info = self.listApply[i]

		for j = 1, #listId do
			if info.id == listId[j] then
				table.remove(self.listApply, i)
			end
		end
	end

	if #self.listApply == 0 then
		FriendRDL.RemoveFriendApply()
	end
end

function FriendMgr:SetGiftOrRecvCoinState(style, listId)
	for i = 1, #self.listFriend do
		local infoFriend = self.listFriend[i]

		for j = 1, #listId do
			if infoFriend.id == listId[j] then
				if style == 1 then
					infoFriend:ChangeLastGiftCoinTime()
				else
					infoFriend:ChangeReceiveCoinState(3)
				end
			end
		end
	end
end

function FriendMgr:ResetSendCoin()
	local listFriend = self:GetFriendList()

	for i = 1, #listFriend do
		local infoFriend = listFriend[i]

		infoFriend.sendCoinTime = 0

		if infoFriend.coinState == 3 then
			infoFriend.coinState = 1
		end
	end

	FriendRDL.InitRD()
end

function FriendMgr:GetFriendList()
	return self.listFriend
end

function FriendMgr:GetApplyList()
	return self.listApply
end

function FriendMgr:GetRecommendList()
	return self.listRecommend
end

function FriendMgr:GetBlackList()
	return self.listBlack
end

function FriendMgr:GetSearchList()
	return listSearch
end

function FriendMgr:GetFriendNum()
	return #self.listFriend
end

function FriendMgr:GetBlackNum()
	return #self.listBlack
end

function FriendMgr:IsOverMaxFriend()
	local curFriendNum = self:GetFriendNum()

	if curFriendNum >= self.maxFriendNum then
		return true
	end

	return false
end

function FriendMgr:IsOverMaxBlack()
	local curBlackNum = self:GetBlackNum()

	if curBlackNum >= self.maxBlackNum then
		return true
	end

	return false
end

function FriendMgr:IsGiftAllFriendToday()
	for i = 1, #self.listFriend do
		local info = self.listFriend[i]

		if not info:IsGiftToday() then
			return false
		end
	end

	return true
end

function FriendMgr:IsRecvAllFriendToday()
	for i = 1, #self.listFriend do
		local info = self.listFriend[i]

		if info:IsGiftToMe() then
			return false
		end
	end

	return true
end

function FriendMgr:IsGameSelf(playerId)
	if playerId == PlayerInst.InfoPlayer.pid then
		return true
	end

	return false
end

function FriendMgr:IsGameFriend(playerId)
	for i = 1, #self.listFriend do
		if playerId == self.listFriend[i].id then
			return true
		end
	end

	return false
end

function FriendMgr:IsBlackFriend(playerId)
	for i = 1, #self.listBlack do
		if playerId == self.listBlack[i].id then
			return true
		end
	end

	return false
end

function FriendMgr:IsRequestFriend(playerId)
	for i = 1, #self.listRequest do
		if playerId == self.listRequest[i].id then
			return true
		end
	end

	return false
end

function FriendMgr:SetLastChangeRecommendTime()
	lastChangeRecommendTime = NetData:GetCurServerTime()
end

function FriendMgr:RefreshRecoverTime()
	local curServerTime = NetData:GetCurServerTime()
	local leftTime = recommendWaitTime - math.floor((curServerTime - lastChangeRecommendTime) / DateUtil.MillsPerSecond)

	if leftTime <= 0 then
		leftTime = 0
	end

	return leftTime
end

function FriendMgr:SortFriend(listInfo)
	if not listInfo or #listInfo == 0 then
		return listInfo
	end

	local listOnline = {}
	local listOutline = {}

	for i = 1, #listInfo do
		local info = listInfo[i]

		if info.pb.isOnline then
			table.insert(listOnline, info)
		else
			table.insert(listOutline, info)
		end
	end

	local function funComps(a, b)
		if a.level == b.level then
			return a.pb.power > b.pb.power
		else
			return a.level > b.level
		end
	end

	table.sort(listOnline, funComps)
	table.sort(listOutline, funComps)

	local list = {}

	for i = 1, #listOnline do
		table.insert(list, listOnline[i])
	end

	for i = 1, #listOutline do
		table.insert(list, listOutline[i])
	end

	return list
end

function FriendMgr:AddToListRequest(id)
	local curServerTime = NetData:GetCurServerTime()

	if #self.listRequest == 0 then
		table.insert(self.listRequest, {
			id = id,
			time = curServerTime
		})

		return
	end

	local isHave = false

	for _, v in pairs(self.listRequest) do
		if v.id == id then
			isHave = true
			v.time = curServerTime

			break
		end
	end

	if not isHave then
		table.insert(self.listRequest, {
			id = id,
			time = curServerTime
		})
	end
end

function FriendMgr:IsCanRequestAgain(id, noMsg)
	local leftTime = 0

	for k, v in pairs(self.listRequest) do
		if v.id == id then
			local curServerTime = NetData:GetCurServerTime()

			if v.time then
				leftTime = 3600 - Mathf.Ceil((curServerTime - v.time) / DateUtil.MillsPerSecond)
			end
		end
	end

	if leftTime > 0 then
		if not noMsg then
			local str = GetStrDisTime(leftTime)

			UIMgr.ShowMsg(string.format(Lang(12514), str))
		end

		return false
	end

	return true
end

function FriendMgr:DeleteFromListRequest(id)
	for i = #self.listRequest, 1, -1 do
		if self.listRequest[i].id == id then
			table.remove(self.listRequest, i)
		end
	end
end

function FriendMgr:HaveFriendSendCoin()
	for _, v in pairs(self.listFriend) do
		if v.coinState == 2 and not InfoGameInst:IsOverRecvFriendCoinNumToday() then
			return true
		end
	end

	return false
end

function FriendMgr:HavePlayerApply()
	return #self.listApply > 0
end

FriendMgr.keyWord = ""

function FriendMgr:SetKeyWord(str)
	self.keyWord = str
end

function FriendMgr:ClearKeyWord()
	self.keyWord = ""
	listSearch = {}
end

function FriendMgr:ClearListSearch()
	listSearch = {}
end

function FriendMgr:IsSearching()
	return self.keyWord ~= ""
end

FriendMgr.tag = 1
FriendMgr.PlayerInfoData = nil
