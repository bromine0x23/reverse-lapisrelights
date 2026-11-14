-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/FuncOperablity.lua

FuncOperablity = class("FuncOperablity")

function FuncOperablity:CanUpgradCardLevel(cardId)
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.CardLevel) then
		return false
	end

	return true
end

function FuncOperablity:CardUpgradStarIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.CardStar) then
		return false
	end

	return true
end

function FuncOperablity:CanUpgradCardStar(cardId)
	if not FuncOperablity:CardUpgradStarIsOpen() then
		return false
	end

	if infoCard.curStarLevel >= infoCard.maxStarLevel then
		UIMgr.ShowMsg(_("星ランクMAX"))

		return false
	end

	return true
end

function FuncOperablity:CardUpgradPetalIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.CardPetal) then
		return false
	end

	return true
end

function FuncOperablity:CanUpgradCardPetal(cardId)
	if not FuncOperablity:CardUpgradPetalIsOpen() then
		return false
	end

	local infoCard = RoleCardMgr:GetRoleCard(cardId)

	if infoCard.curPetal >= infoCard.maxPetal then
		UIMgr.ShowMsg(_("開花コンプリート"))

		return false
	end

	return true
end

function FuncOperablity:UnionIsExist(noMsg)
	if not UnionMgr.HasUnion() then
		if not noMsg then
			UIMgr.ShowMsg(_("Msg_Union_Been_Disband"))
		end

		return false
	end

	return true
end

function FuncOperablity:CanCreateUnion()
	local curLv = PlayerInst:GetCurLv()
	local createLv = GetConfigArgInt("ClubCreateLimitLevel")

	if curLv < createLv then
		local msg = string.format(_("Msg_UnlockTeamPosition"), createLv)

		return false, msg
	end

	return true
end

function FuncOperablity:CanApplyJoin(infoUnion)
	local msg = ""
	local haveApplied = infoUnion:HaveApplied(PlayerInst.InfoPlayer.pid)

	if haveApplied then
		msg = _("Msg_Union_Repeat_Apply")

		return false, msg
	end

	local joinType = infoUnion.joinType

	if joinType == UnionJoinType.close then
		msg = _("Msg_Union_Close_Join")

		return false, msg
	end

	local curMemberNum = infoUnion.curMemberNum

	if infoUnion.curMemberNum == infoUnion.maxMemberNum then
		msg = _("Msg_Union_Full")

		return false, msg
	end

	local joinLevel = infoUnion.joinLevel

	if infoUnion.joinLevel > PlayerInst:GetCurLv() then
		msg = _("Msg_Union_Level_Less")

		return false, msg
	end

	return true
end

function FuncOperablity:EnterRaidMian()
	if not UnionRaidMgr.beingCommRaid then
		return true
	elseif UnionRaidMgr.beingCommRaid:IsFinished() then
		return true
	elseif UnionRaidMgr:IsBossRaidOpen() then
		return true
	end

	return false
end

function FuncOperablity:EnterRaid()
	if UnionRaidMgr.beingCommRaid and UnionRaidMgr.beingCommRaid:IsSelEvent() or UnionRaidMgr.beingCommRaid:IsToBeSelEvent() then
		return true
	end

	return false
end

function FuncOperablity:FightIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Fight) then
		return false
	end

	return true
end

function FuncOperablity:RoleIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Role) then
		return false
	end

	return true
end

function FuncOperablity:CommunicationIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Communication) then
		return false
	end

	return true
end

function FuncOperablity:DrawCardIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.DrawCard) then
		return false
	end

	return true
end

function FuncOperablity:DressIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Dress) then
		return false
	end

	return true
end

function FuncOperablity:GiftIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Gift) then
		return false
	end

	return true
end

function FuncOperablity:TeamPassIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.TeamPass) then
		return false
	end

	return true
end

function FuncOperablity:TalentIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Talent) then
		return false
	end

	return true
end

function FuncOperablity:CardIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Card) then
		return false
	end

	return true
end

function FuncOperablity:CardPassIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.CardPass) then
		return false
	end

	return true
end

function FuncOperablity:EquipmentIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Equipment) then
		return false
	end

	return true
end

function FuncOperablity:EhchantIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Ehchant) then
		return false
	end

	return true
end

function FuncOperablity:AssetPassIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.AssetPass) then
		return false
	end

	return true
end

function FuncOperablity:ThemeIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Theme) then
		return false
	end

	return true
end

function FuncOperablity:OperationIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Operation) then
		return false
	end

	return true
end

function FuncOperablity:TimeTaskIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.TimeTask) then
		return false
	end

	return true
end

function FuncOperablity:FriendIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Friend) then
		return false
	end

	return true
end

function FuncOperablity:PlayerIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Player) then
		return false
	end

	return true
end

function FuncOperablity:ShopIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Shop) then
		return false
	end

	return true
end

function FuncOperablity:MailIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Mail) then
		return false
	end

	return true
end

function FuncOperablity:ADIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.AD) then
		return false
	end

	return true
end

function FuncOperablity:OptionIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Option) then
		return false
	end

	return true
end

function FuncOperablity:ThemeModeIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.ThemeMode) then
		return false
	end

	return true
end

function FuncOperablity:BossIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Boss) then
		return false
	end

	return true
end

function FuncOperablity:WorkIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Work) then
		return false
	end

	return true
end

function FuncOperablity:ThemeModeIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.ThemeMode) then
		return false
	end

	return true
end

function FuncOperablity:FriendIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.Friend) then
		return false
	end

	return true
end

function FuncOperablity:TimeTaskIsOpen()
	if not TutorialMgr:IsOpenTut(TutorialFunctionType.TimeTask) then
		return false
	end

	return true
end

function FuncOperablity:CanRoleUpgradeStar(roleID)
	if not TutorialMgr:IsOpenTutWithMessage(TutorialFunctionType.StarUp, false) then
		return false
	end

	local infoChar = CharacterMgr:GetCharacter(roleID)

	if infoChar == nil then
		return false
	end

	local curStarCount = infoChar:GetStarCount()
	local curSoul = infoChar:GetSoulNum()
	local nextStarExp = StarManager:GetRoleStarExp(curStarCount + 1)
	local soulFit = nextStarExp <= curSoul

	if not soulFit then
		return false
	end

	local reachMaxLv = curStarCount == StarManager:GetMaxStarCount()

	if reachMaxLv then
		return false
	end

	return true
end

function FuncOperablity:CanRoleUpgradeSkill(roleID)
	if not TutorialMgr:IsOpenTutWithMessage(TutorialFunctionType.Skill, false) then
		return false
	end

	local infoChar = CharacterMgr:GetCharacter(roleID)
	local talentCount = #infoChar.infoTalents

	for i = 1, talentCount do
		if FuncOperablity:RoleSkillCanUpgrade(infoChar, infoChar.infoTalents[i]) then
			return true
		end
	end

	return false
end

function FuncOperablity:RoleSkillCanUpgrade(infoChar, infoTalent)
	return false
end

function FuncOperablity:CanOperationTeamRoleFunc()
	local roleTbl = CharacterMgr:GetCharacterList()

	for i, v in ipairs(roleTbl) do
		if FuncOperablity:CanOperationRoleFunc(v.id) then
			return true
		end
	end

	return false
end

function FuncOperablity:CanOperationRoleFuncButEquip(roleID)
	if FuncOperablity:CanRoleUpgradeStar(roleID) then
		return true
	end

	if FuncOperablity:CanRoleUpgradeSkill(roleID) then
		return true
	end

	if FuncOperablity:CanRoleUpgradeSkillTree(roleID) then
		return true
	end

	return false
end

function FuncOperablity:CanOperationRoleFuncEquip(roleID)
	if FuncOperablity:CanRoleUpgradeIntensifySlot(roleID) then
		return true
	end

	if FuncOperablity:CanRoleUpgradeEquipment(roleID) then
		return true
	end

	return false
end

function FuncOperablity:CanNewEquipUp(roleID, equipIndex)
	if not TutorialMgr:IsOpenTutWithMessage(TutorialFunctionType.Equip, false) then
		return false
	end

	local infoChar = CharacterMgr:GetCharacter(roleID)
	local sid = infoChar.pb.equips[equipIndex]
	local eTypeStr = EnumUtil.ToString("eEquipType", equipIndex - 1)
	local eType = EnumUtil.ToEnum("eEquipType", eTypeStr)
	local list

	if infoChar:IsOwnSecondJob() then
		list = EquipmentManager:GetListWithSecondJob(infoChar.data.Job, infoChar.data.SecondJob, eType)
	else
		list = EquipmentManager:GetList(infoChar.data.Job, eType)
	end

	if sid == 0 then
		for i = 1, #list do
			local info = list[i]

			if info.pb.roleId == 0 and info:GetIsNewState() then
				return true
			end
		end
	else
		local equipInfo = EquipmentManager:GetBySerialId(sid)

		for i = 1, #list do
			local info = list[i]

			if info.pb.roleId ~= 0 and info.data.FightValue > equipInfo.data.FightValue and info:GetIsNewState() then
				return true
			end
		end
	end

	return false
end

function FuncOperablity:CanOperationRoleFunc(roleID)
	if FuncOperablity:CanTakeFavorRankGift(roleID) then
		return true
	end

	if FuncOperablity:CanOperationRoleFuncButEquip(roleID) then
		return true
	end

	if FuncOperablity:CanOperationRoleFuncEquip(roleID) then
		return true
	end

	return false
end

function FuncOperablity:CanRoleUpgradeSkillTree(roleID)
	local infoChar = CharacterMgr:GetCharacter(roleID)

	return infoChar.hasCanUpdateSkill
end

function FuncOperablity:CanRoleUpgradeEquipment(roleID)
	return false
end

function FuncOperablity:CanRoleIntensifySlotIndex(roleID, slotIndex)
	if not TutorialMgr:IsOpenTutWithMessage(TutorialFunctionType.Equip, false) then
		return false
	end

	local infoChar = CharacterMgr:GetCharacter(roleID)
	local roleLv = infoChar:GetLevel()

	if infoChar.pb.slotLv ~= nil then
		local slotLv = infoChar.pb.slotLv[slotIndex]
		local canIntentify = true

		if slotLv == roleLv then
			canIntentify = false
		else
			local need = LevelManager:GetIntensifyNeed(slotLv)

			if need > PlayerInst:GetGold() then
				canIntentify = false
			end
		end

		if canIntentify then
			return true
		end
	end

	return false
end

function FuncOperablity:CanRoleUpgradeIntensifySlot(roleID)
	if not TutorialMgr:IsOpenTutWithMessage(TutorialFunctionType.Equip, false) then
		return false
	end

	local infoChar = CharacterMgr:GetCharacter(roleID)
	local roleLv = infoChar:GetLevel()

	for i = 1, 4 do
		if infoChar.pb.slotLv ~= nil then
			local slotLv = infoChar.pb.slotLv[i]
			local canIntentify = true

			if slotLv == roleLv then
				canIntentify = false
			else
				local curNeed = LevelManager:GetIntensifyNeedByLevel(slotLv - 1)
				local need = LevelManager:GetIntensifyNeed(slotLv)

				if need > PlayerInst:GetGold() then
					canIntentify = false
				end
			end

			if canIntentify then
				return true
			end
		end
	end

	return false
end

function FuncOperablity:HasNewWork()
	if WorkTaskManager:HaveWorkTaskComplete() or PersistentStoreUtil.GetBool("hasNewWorkTask", ture) then
		return true
	end

	return false
end

function FuncOperablity:CanTakeFavorRankGift(roleID)
	local infoCharacter = CharacterMgr:GetCharacter(roleID)
	local lastRank = infoCharacter:GetFavorRankRecord()
	local curRank = infoCharacter:GetFavorRank()

	return curRank > 1 and lastRank < curRank
end

function FuncOperablity:CanShowStory(infoStage)
	local IsStagePassed = infoStage.pb.isPass
	local isClose = PersistentStoreUtil.GetIsCloseStory()
	local canShow = true

	if isClose and IsStagePassed then
		canShow = false
	end

	return canShow
end

function FuncOperablity:HasNewMails()
	if PlayerInst.pbMails ~= nil and #PlayerInst.pbMails > 0 then
		return true
	end

	return false
end

function FuncOperablity:HasNewFriendMessage()
	if PlayerInst.hasNewFriend or PlayerInst.hasNewFriendGift then
		return true
	end

	return false
end

function FuncOperablity:HasActivesMsg()
	local haveNew = false

	haveNew = haveNew or self:HasActiveFifteenMsg()
	haveNew = haveNew or self:HasActiveMounthSpring()
	haveNew = haveNew or self:HasActivesMsgLevelUp()
	haveNew = haveNew or self:HasActivesMsgGetPower()
	haveNew = haveNew or self:HasActivesMsgInvest()
	haveNew = haveNew or self:HasActivesMsgRecharge()

	return haveNew
end

function FuncOperablity:HasActiveSevenMsg()
	local IsLastDaySign = InfoGameInst.gameInfo.sevenMarkTime == 0 or TimeIsNotToday(InfoGameInst.gameInfo.sevenMarkTime) and InfoGameInst.gameInfo.sevenMark < 7

	return IsLastDaySign
end

function FuncOperablity:HasActiveFifteenMsg()
	local IsLastDaySign = InfoGameInst.gameInfo.fifteenMarkTime == 0 or TimeIsNotToday(InfoGameInst.gameInfo.fifteenMarkTime)

	return IsLastDaySign
end

function FuncOperablity:HasActiveMounthSpring()
	if (InfoGameInst:GetMonthCardType() == 1 or InfoGameInst:GetMonthCardType() == 2) and (InfoGameInst.gameInfo.monthCardDrawTime == 0 or TimeIsNotToday(InfoGameInst.gameInfo.monthCardDrawTime)) then
		return true
	end

	return false
end

function FuncOperablity:HasActivesMsgLevelUp()
	local listData = DataManager.Instance:GetRecordsArray_Lua("LevelConfig", function(db)
		return db.EventLevelReward ~= nil and db.EventLevelReward.Count > 0
	end)

	if listData ~= nil and listData.Length > 0 then
		for i = 1, listData.Length do
			local level = listData[i - 1].ID

			if level <= PlayerInst:GetCurLv() and not self:IsGetReward(level) then
				return true
			end
		end
	end

	return false
end

function FuncOperablity:IsGetReward(level)
	local lists = InfoGameInst.gameInfo.levelMark

	for i = 1, #lists do
		if level == lists[i] then
			return true
		end
	end

	return false
end

function FuncOperablity:HasActivesMsgEnjoy()
	local lists = TaskMgr:GetCurShowInfoTasks(4)

	for i = 1, #lists do
		local infoReputation = ReputationTaskManager:Get(lists[i].id)
		local isD, p1, p2 = infoReputation:TaskIsDone()

		if isD then
			return true
		end
	end

	return false
end

function FuncOperablity:HasActivesMsgGetPower()
	local powerRewardTime = DataManager.Instance:GetConfigJsonValue("PowerRewardTime")
	local curTimeStamp = Mathf.Round(NetData:GetCurServerTime() / 1000)
	local curDate = os.date("*t", curTimeStamp)

	curTs = (curDate.hour * 60 + curDate.min) * 60

	local t1s = powerRewardTime:get_Item(0):get_Item(0)
	local t1e = powerRewardTime:get_Item(0):get_Item(1)
	local t2s = powerRewardTime:get_Item(1):get_Item(0)
	local t2e = powerRewardTime:get_Item(1):get_Item(1)

	if InfoGameInst.gameInfo.powerDrawTime > 0 then
		local getTimep = Mathf.Round(InfoGameInst.gameInfo.powerDrawTime / 1000)
		local getTimepDate = os.date("*t", getTimep)
		local getTimeps = (getTimepDate.hour * 60 + getTimepDate.min) * 60
	end

	if t1s * 60 <= curTs and t1e * 60 >= curTs and TimeIsNotToday(InfoGameInst.gameInfo.powerDrawTime) then
		return true
	end

	if t2s * 60 <= curTs and t2e * 60 >= curTs and TimeIsNotToday(InfoGameInst.gameInfo.powerDrawTime) then
		return true
	end

	return false
end

function FuncOperablity:HasActivesMsgInvest()
	if InfoGameInst.gameInfo.isInvest == 1 then
		local investSection = DataManager.Instance:GetConfigJsonValue("InvestSection")
		local levelP = PlayerInst:GetCurLv()
		local canGetIndex = 0

		for i = 1, investSection.Count do
			if levelP >= investSection:get_Item(i - 1) then
				canGetIndex = i
			end
		end

		if canGetIndex > InfoGameInst.gameInfo.investMark then
			return true
		end
	end

	return false
end

function FuncOperablity:HasActivesMsgRecharge()
	local lists = DataManager.Instance:GetAllRecords_Lua("ActiveRecharge")

	if lists ~= nil then
		for i = 1, lists.Length do
			if InfoGameInst.gameInfo.rechargeTotal >= lists[i - 1].DiamondCount and not InfoGameInst:IsGetRechargeReward(lists[i - 1].ID) then
				return true
			end
		end
	end

	return false
end

function FuncOperablity:HasNewTaskMsg()
	local taskList = ReputationTaskManager:GetCurShowInfoTasks(3)

	if taskList ~= nil then
		for i = 1, #taskList do
			local infoReputation = taskList[i]
			local taskIsDone, progressNum, totalNum = infoReputation:TaskIsDone()

			if taskIsDone then
				return true
			end
		end
	end

	return false
end

function FuncOperablity:HasNewLimitActive()
	return TaskMgr:HasNewVoteActive() or TaskMgr:HasNewBirthdayActive() or ActiveManager:CanGetReward()
end

function FuncOperablity:IsFirstPurchase()
	return PlayerInst.InfoPlayer.payStatus ~= 2
end

function FuncOperablity.GetOpenData(strOpenJsonData)
	if strOpenJsonData == nil then
		return nil
	end

	local configJsonValue = DataManager.Instance:GetConfigJsonValue(strOpenJsonData)
	local weekData = {}
	local configNum = configJsonValue.Count

	for i = 0, configNum - 1 do
		local data = configJsonValue:get_Item(i)

		if data.Count >= 3 then
			table.insert(weekData, {
				data:get_Item(0),
				data:get_Item(1),
				data:get_Item(2)
			})
		end
	end

	table.sort(weekData, function(elem1, elem2)
		return elem1[1] < elem2[1] or elem1[1] == elem2[1] and elem1[2] < elem2[2]
	end)

	return weekData
end

function FuncOperablity.GetOpenDesc(openDataTbl)
	if openDataTbl == nil then
		return ""
	end

	local strDesc = Localization.Get("DESC_OpenTime")
	local strWeek = Localization.Get("DESC_Week")
	local strPoint = Localization.Get("PVP_Point")

	for i, v in ipairs(openDataTbl) do
		if v ~= nil and #v >= 3 then
			strDesc = strDesc .. strWeek .. Localization.Get("Number_" .. v[1])
		end

		if i ~= #openDataTbl then
			strDesc = strDesc .. ","
		end
	end

	return strDesc
end
