-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/SetterData.lua

local InfoTitle = require("Info.InfoTitle")
local InfoPVP = require("Info/InfoPVP")

SetterData = class("SetterData")
SetterData.showLevelup = false
SetterData.haveOverItem = false

function SetterData.GetSetterData(_list, vParam)
	local setter = SetterData(vParam)

	setter:SetData(_list)

	return setter
end

function SetterData.ConvertSettersToPbItems(pbSetters)
	if pbSetters == nil then
		return
	end

	local pbItems = {}

	for i, v in ipairs(pbSetters) do
		if v.num > 0 then
			local item = {}

			item.id = v.id
			item.num = v.num
			item.asset = v.asset
			item.from = v.from
			item.value = v.value
			item.extra = v.extra

			table.insert(pbItems, item)
		end
	end

	return pbItems
end

function SetterData.HaveAwards(pbSetters, assetFrom)
	if pbSetters == nil then
		return false
	end

	for _, s in ipairs(pbSetters) do
		if assetFrom then
			if s.from == assetFrom and s.num > 0 then
				return true
			end
		elseif (s.from == protocol_pb.AF_NORMAL or s.from == protocol_pb.AF_EXTRA_AWARD) and s.num > 0 then
			return true
		end
	end

	return false
end

function SetterData:ctor(vParam)
	self.vParam = vParam
	self.list = nil
	self.GoldModify = 0
	self.DiamondModify = 0
	self.DiamondPayModify = 0
	self.SkinCoinModify = 0
	self.FriendCoinModify = 0
	self.PowerModify = 0
	self.ClubCoinModify = 0
	self.PlayerExpModify = 0
	self.IsPlayerLevelup = false
	self.IsFavorLevelup = false
	self.preFavorLevel = 1
	self.curFavorLevel = 1
	self.RoleExpSetterTbl = nil
	self.RoleLvlupTbl = nil
	self.RoleStarExpModify = 0
	self.StarUpgradeRoleID = 0
	self.CountGem = 0
	self.EquipmentGetList = nil
	self.isCombineSuccess = false
end

function SetterData:SetData(_list)
	self.list = _list

	for k, s in ipairs(self.list) do
		if s.asset == protocol_pb.I_SOUL then
			s.id = ItemManager:Get(s.id).data.Value
		end
	end

	self:DealData()
end

function SetterData:Getlist(assetFrom)
	local list = {}

	for _, s in pairs(self.list) do
		if s.from == assetFrom and s.num > 0 then
			table.insert(list, s)
		end
	end

	return list
end

function SetterData:GetlistItem(assetFrom)
	local list = {}

	for _, s in pairs(self.list) do
		if s.from == assetFrom then
			local infoItem = SetterData.GetItemFromAsset(s)

			if s.num > 0 and infoItem then
				table.insert(list, s)
			end
		end
	end

	return list
end

function SetterData.GetItemFromAsset(s)
	local infoItem

	if s.asset == protocol_pb.P_GOLD then
		infoItem = ItemManager:GetValueItem(501, s.num)
	elseif s.asset == protocol_pb.P_DIAMOND then
		infoItem = ItemManager:GetValueItem(502, s.num)
	elseif s.asset == protocol_pb.P_DIAMOND_PAY then
		infoItem = ItemManager:GetValueItem(513, s.num)
	elseif s.asset == protocol_pb.P_POWER then
		infoItem = ItemManager:GetValueItem(503, s.num)
	elseif s.asset == protocol_pb.R_AVATAR then
		infoItem = ItemManager:GetValueItem(571, s.num)
		infoItem.roleId = s.id
	elseif s.asset == protocol_pb.P_AVATAR then
		infoItem = ItemManager:GetValueItem(573, s.num)
	elseif s.asset == protocol_pb.I_SOUL then
		local itemId = ItemManager:GetCardSoulId(s.id)

		infoItem = ItemManager:GetValueItem(itemId, s.num)
	elseif s.asset == protocol_pb.I_DRAW then
		infoItem = ItemManager:GetValueItem(s.id, s.num)
	elseif s.asset == protocol_pb.RC_RECEIVE then
		infoItem = ItemManager:GetValueItem(10100, s.id)
	elseif s.asset == protocol_pb.P_LEVEL_EXP then
		infoItem = ItemManager:GetValueItem(504, s.num)
	elseif s.asset == protocol_pb.R_FAVOR_EXP then
		infoItem = ItemManager:GetValueItem(506, s.num)
		infoItem.value = s.id
	elseif s.asset == protocol_pb.R_PICTURE then
		infoItem = ItemManager:GetValueItem(572, s.num)
		infoItem.roleId = s.id
	elseif s.asset == protocol_pb.P_LEVEL_UP or s.asset == protocol_pb.P_LEVEL_EXP or s.asset == protocol_pb.RC_LEVEL_EXP or s.asset == protocol_pb.RC_LEVEL_UP or s.asset == protocol_pb.R_FAVOR_UP or s.asset == protocol_pb.RC_STAR_UP then
		return infoItem
	else
		infoItem = ItemManager:GetValueItem(s.id, s.num)
	end

	return infoItem
end

function SetterData:DealData()
	ItemRDL:New(self.list)

	self.EquipmentGetList = {}

	for _, s in ipairs(self.list) do
		if s.asset == protocol_pb.P_GOLD then
			self.GoldModify = self.GoldModify + s.num
		elseif s.asset == protocol_pb.P_DIAMOND then
			self.DiamondModify = self.DiamondModify + s.num
		elseif s.asset == protocol_pb.P_DIAMOND_PAY then
			self.DiamondPayModify = self.DiamondPayModify + s.num
		elseif s.asset == protocol_pb.P_FRIEND_COIN then
			self.FriendCoinModify = self.FriendCoinModify + s.num
		elseif s.asset == protocol_pb.P_DIAMOND_PAY then
			self.DiamondPayModify = self.DiamondPayModify + s.num
		elseif s.asset == protocol_pb.P_POWER then
			local curPower = PlayerInst:GetPower()

			self.PowerModify = s.value - curPower

			PlayerInst:SetPower(s.value)

			if s.extra ~= nil and s.extra[1] ~= nil then
				PowerMgr.Instance:SetPowerTime(tonumber(s.extra[1]) * DateUtil.MillsPerSecond)
			end
		elseif s.asset == protocol_pb.P_CLUB_COIN then
			self.ClubCoinModify = self.ClubCoinModify + s.num
		elseif s.asset == protocol_pb.P_LEVEL_EXP then
			self.PlayerExpModify = self.PlayerExpModify + s.num
		elseif s.asset == protocol_pb.P_LEVEL_UP then
			if s.num ~= 0 then
				self.IsPlayerLevelup = true
			end
		elseif s.asset == protocol_pb.P_VIP_EXP then
			PlayerInst.InfoPlayer.vipExp = PlayerInst.InfoPlayer.vipExp + s.num

			Event.Instance:Fire(EventEnum.UpdatePlayerVipExp)
		elseif s.asset == protocol_pb.P_VIP_UP then
			self:DealWithVIPLevelUp()
		elseif s.asset == protocol_pb.RC_LEVEL_EXP then
			if self.RoleExpSetterTbl == nil then
				self.RoleExpSetterTbl = {}
			end

			table.insert(self.RoleExpSetterTbl, s)
		elseif s.asset == protocol_pb.I_SOUL then
			self:DealWithRCSoul(s)
		elseif s.asset == protocol_pb.RC_RECEIVE then
			self:DealWithReceiveRoleCard(s)
		elseif s.asset == protocol_pb.RC_LEVEL_UP then
			if s.num ~= 0 then
				if self.RoleLvlupTbl == nil then
					self.RoleLvlupTbl = {}
				end

				self.RoleLvlupTbl[s.id] = true
			end
		elseif s.asset == protocol_pb.RC_STAR_UP then
			if s.num > 0 then
				self.StarUpgradeRoleID = s.id

				local infoRoleCard = RoleCardMgr:GetRoleCard(s.id)

				infoRoleCard:UpdateStarLevel(s.num)
				ManualRDL.NotesRDL.DealTask(infoRoleCard.data.CharacterID)
			end
		elseif s.asset == protocol_pb.R_FAVOR_EXP then
			self:DealWithFavorExp(s)
		elseif s.asset == protocol_pb.R_FAVOR_UP then
			self.IsFavorLevelup = true
		elseif s.asset == protocol_pb.R_AVATAR then
			local infoRole = RoleMgr:GetRole(s.id)

			if infoRole and infoRole.hold then
				table.insert(infoRole.pb.avatars, s.num)
				self:DealWithNewAvatar(s)
			end
		elseif s.asset == protocol_pb.P_AVATAR then
			self:DealWithNewAvatar(s)
		elseif s.asset == protocol_pb.P_MEDAL then
			InfoTitle:AddTitle(s)
		elseif s.asset == protocol_pb.P_HEAD_FRAME then
			InfoTitle:AddHeadFrame(s)
		elseif s.asset == protocol_pb.P_HEAD then
			InfoTitle:AddHead(s)
		elseif s.asset == protocol_pb.CLUB_COIN then
			if UnionMgr.HasUnion() then
				UnionMgr.releUnion:ChangeCoin(s.num)
			end
		elseif s.asset == protocol_pb.PVP_BATTLE_NUM then
			InfoPVP:SetPVPBattleNum(s.value)
		elseif s.asset == protocol_pb.PVP_REFRESH_NUM then
			InfoPVP:SetPVPRefashNum(s.value)
		elseif s.asset == protocol_pb.PVP_RANKING_AWARD then
			InfoPVP:SetCurrentRankId(s.value)
		elseif s.asset == protocol_pb.R_PICTURE then
			local infoRole = RoleMgr:GetRole(s.id)

			if infoRole and infoRole.hold then
				table.insert(infoRole.pb.pictures, s.num)
			end

			ManualRDL.VideoRDL.AddIllustration(s.id, s.num)
		else
			self:DealWithItem(s)

			if s.asset == protocol_pb.I_GEM then
				self.CountGem = s.num
			end
		end

		self:DealWithNewRole(s.newRole)
		self:DealWithNewRoleCard(s.newRoleCard)
		self:DealWithOverItem(s)
	end
end

function SetterData:DealWithNewRole(pbRole)
	if pbRole ~= nil and pbRole.id ~= nil and pbRole.id > 0 then
		local infoRole = RoleMgr:GetRole(pbRole.id)

		infoRole:SetData(pbRole)
		RoleRDL.NewRDL.AddNewRolePlayerPrefs(infoRole)
		RoleRDL.PushNewRole(infoRole)
		ManualRDL.NotesRDL.DealTask(infoRole.id)
	end
end

function SetterData:DealWithNewRoleCard(pbRoleCard)
	if pbRoleCard ~= nil and pbRoleCard.id ~= nil and pbRoleCard.id > 0 then
		local infoRoleCard = RoleCardMgr:GetRoleCard(pbRoleCard.id)

		infoRoleCard:SetData(pbRoleCard)

		local infoRole = RoleMgr:GetRole(infoRoleCard.data.CharacterID)

		if infoRole:GetEquipStatus() == 0 then
			local preEquipCardId = infoRole:GetRoleCardId()

			if infoRoleCard.id == preEquipCardId then
				CharacterThinMgr.ResetInterface(THIN_SYSTEM_TYPE.Role, nil, nil, nil, nil, true)
			else
				local equipCard = RoleCardMgr:GetRoleCard(preEquipCardId)

				if equipCard.cardRank < infoRoleCard.cardRank then
					infoRole:SetRoleCardId(infoRoleCard.id)
					CharacterThinMgr.ResetInterface(THIN_SYSTEM_TYPE.Role, nil, nil, nil, nil, true)
				end
			end
		end

		CardRDL.NewRDL.AddNewCardPlayerPrefs(infoRoleCard)
		CardRDL.PushNewCard(infoRoleCard)
		ManualRDL.VideoRDL.AddNirvana(infoRole.id, infoRoleCard.id)
		ManualRDL.NotesRDL.DealTask(infoRole.id)
	end
end

function SetterData:DealWithNewAvatar(s)
	local roleId = s.id
	local avatarId = s.num
	local infoAvatar = AvatarManager:GetAvatar(avatarId)
	local slot = infoAvatar.data.Slot[1]

	if roleId ~= 0 then
		-- block empty
	end

	if slot == "Weapon" then
		local infoRole = RoleMgr:GetRole(roleId)

		if infoRole and infoRole.hold then
			infoRole:UpdateEquipAvatarAttr(true)
		end
	end

	if infoAvatar:IsBPAvatar() then
		local pbAvatar = {
			roleId = 0,
			avatarId = avatarId
		}

		PlayerInst:AddBPAvatar(pbAvatar)
	end
end

function SetterData:DealWithRCSoul(s)
	if s == nil then
		return
	end

	local infoRoleCard = RoleCardMgr:GetRoleCard(s.id)

	if infoRoleCard then
		infoRoleCard:ChangeSoulNum(s.num)
	end
end

function SetterData:DealWithReceiveRoleCard(s)
	return
end

function SetterData:DealWithStarExp(id, changeValue)
	if changeValue == 0 then
		return
	end

	local infoRoleCard = RoleCardMgr:GetRoleCard(id)

	infoRoleCard:ChangeStarExp(changeValue)
end

function SetterData:DealWithRoleStarUpgrade()
	local infoRoleCard = RoleCardMgr:GetRoleCard(self.StarUpgradeRoleID)
	local preStarNum = infoRoleCard.curStarLevel

	self:DealWithStarExp(self.StarUpgradeRoleID, self.RoleStarExpModify)
	Event.Instance:Fire(EventEnum.RoleStarLevelup, self.StarUpgradeRoleID, preStarNum, preAttriData)
end

function SetterData:DealWithItem(s)
	ItemManager:ChangeItemCount(s.id, s.num)
end

function SetterData:DealWithOverItem(s)
	if s.overflow == 1 and not SetterData.haveOverItem then
		SetterData.haveOverItem = true
	end
end

function SetterData:DealWithEquipment(s)
	if s.num > 0 then
		local equipId = s.extra[1]

		EquipmentManager:AddEquipmentWithProp(s.id, equipId, 0)
		table.insert(self.EquipmentGetList, s.id)
	elseif s.num < 0 then
		EquipmentManager:RemoveEquipment(s.id)
	end
end

function SetterData:DealWithRLevelExp(s)
	if s == nil then
		return
	end

	local infoChar = RoleCardMgr:GetRoleCard(s.id)

	infoChar:ChangeExp(s.num)
	ManualRDL.NotesRDL.DealTask(infoChar.data.CharacterID)
	Event.Instance:Fire(EventEnum.RoleExpChanged, s.id)
end

function SetterData:DealWithFavorExp(s)
	if s == nil then
		return
	end

	local infoRole = RoleMgr:GetRole(s.id)

	infoRole:ChangeFavorExp(s.num)

	self.curFavorLevel = infoRole.curFavorLevel
	self.preFavorLevel = infoRole.preFavorLevel
	self.infoRole = infoRole

	if self.curFavorLevel > self.preFavorLevel then
		TopicManager:NotifyNewCall(nil, infoRole)
		PhoneCallManager:NotifyNewCall(nil, infoRole)
		DotMgr:Update(ePSKey.Dot_SMS_CALL, {})
		infoRole:UpdateAllFavorAni()
		CombBondageMgr.SetJustUnlockSkills(infoRole)
		ChapterMgr:SetCharactorNewUnlockStory(infoRole.id, self.preFavorLevel, self.curFavorLevel)

		local hasUnlock = false
		local unlockFavorLv = GetConfigArgJson("EquipmentUnlock")

		for _, v in ipairs(unlockFavorLv) do
			if v > self.preFavorLevel and v <= self.curFavorLevel then
				hasUnlock = true

				break
			end
		end

		if hasUnlock then
			infoRole:UpdateEquipBaseAttr(true)
			CharacterThinMgr.ResetInterface(THIN_SYSTEM_TYPE.Role, nil, nil, nil, nil, true)
			Event.Instance:Fire("UpdateThinAfterDevelop")
			RoleRDL.EquipRDL.AddUnlockEquipSlot(infoRole)
		end

		RoleRDL.InteractRDL.AddInteractStory(infoRole)
		RoleRDL.InteractRDL.AddInteractVoice(infoRole)
		ManualRDL.NotesRDL.DealTask(infoRole.id)
	end
end

function SetterData:IsRoleLevelUp(id)
	return self.RoleLvlupTbl ~= nil and self.RoleLvlupTbl[id]
end

function SetterData:DealWithAllRoleLevelExp()
	if self.RoleExpSetterTbl == nil then
		return
	end

	local roleLvlupInfoTbl

	if self.RoleLvlupTbl ~= nil then
		roleLvlupInfoTbl = {}
	end

	for i = 1, #self.RoleExpSetterTbl do
		local setter = self.RoleExpSetterTbl[i]

		if self:IsRoleLevelUp(setter.id) then
			local nextCount = #roleLvlupInfoTbl + 1

			roleLvlupInfoTbl[nextCount] = {}

			local infoChar = RoleCardMgr:GetRoleCard(setter.id)

			roleLvlupInfoTbl[nextCount].beforeLevel = infoChar.curLevel
			roleLvlupInfoTbl[nextCount].beforeExp = infoChar.pb.levelExp

			self:DealWithRLevelExp(setter)

			roleLvlupInfoTbl[nextCount].afterLevel = infoChar.curLevel
			roleLvlupInfoTbl[nextCount].afterExp = infoChar.pb.levelExp

			Event.Instance:Fire(EventEnum.RoleLevelup, setter.id)
			InstructionMgr:TriggerWait("CardLevelUp")
		else
			self:DealWithRLevelExp(setter)
		end
	end
end

function SetterData:Parse()
	PlayerInst:ChangeGold(self.GoldModify)
	PlayerInst:ChangeDiamond(self.DiamondModify)
	PlayerInst:ChangeFriendCoin(self.FriendCoinModify)
	PlayerInst:ChangeClubCoin(self.ClubCoinModify)
	PlayerInst:ChangeDiamondPay(self.DiamondPayModify)

	if self.IsPlayerLevelup then
		self:DealWithPlayeLevelup()

		if SDKMgr.Instance ~= nil then
			SDKMgr.Instance:OnUpdateRoleInfo()
		end

		Event.Instance:Fire(EventEnum.PlayerLevelup)
	else
		PlayerInst:ChangeExp(self.PlayerExpModify)
	end

	self:DealWithAllRoleLevelExp()

	if self.StarUpgradeRoleID > 0 then
		self:DealWithRoleStarUpgrade()
	else
		self:DealWithStarExp(self.StarUpgradeRoleID, self.RoleStarExpModify)
	end

	Event.Instance:Fire(EventEnum.UpdatePlayerInfo)
	ItemRDL:Grow(self.list)
end

function SetterData:DealWithPlayeLevelup()
	local curPower = PlayerInst:GetPower()
	local maxPower = PlayerInst.InfoPlayer.maxPower

	if maxPower <= curPower then
		PowerMgr.Instance:SetPowerTime(NetData:GetCurServerTime())
	end

	PlayerInst.InfoPlayer:UpdatePreLevel()
	PlayerInst:ChangeExp(self.PlayerExpModify)

	SetterData.showLevelup = true

	TutorialMgr:DealLevelOpenSystem()
	Event.Instance:Fire(EventEnum.UpdatePlayerInfo)

	local listHoldCard = RoleCardMgr:GetAllHoldCard()

	for _, infoRoleCard in pairs(listHoldCard) do
		infoRoleCard:UpdateAll()
	end

	ChapterRDL.AssetRDL.DealPLvUnlockStage()
	CardRDL.StageRDL.ResetCardStageFight()

	if self.vParam ~= nil and not self.vParam.DelayShowPlayerLvUp then
		-- block empty
	end
end

function SetterData:ShowPlayerLvUpUI(onComplete)
	local dlg = DlgPlayerLevelup.GetInstance()

	if InLevelup and dlg:IsShow() then
		dlg:Close()
	end

	dlg:Init(PlayerInst.CurtScene:GetCurrentPage().UIRootObject, self, onComplete)
end

function SetterData:DealWithVIPLevelUp()
	if SDKMgr.Instance ~= nil then
		SDKMgr.Instance:OnUpdateRoleInfo()
	end
end

function SetterData.ExchangeSoulToCardID(s)
	local cardId = s.id

	if s.asset == protocol_pb.I_SOUL then
		cardId = ItemManager:Get(sd.id).data.Value
	end

	return cardId
end
