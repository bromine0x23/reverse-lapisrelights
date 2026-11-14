-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoRoleCard.lua

require("Info/InfoTalent")
require("Info/Player")

local Character = require("luaData/CharacterRole")
local CharacterCard = require("luaData/CharacterCard")
local CardGroupData = require("luaData/CharacterCardSet")
local AbilityData = require("luaData/WorkAbility")
local CardStarData = require("luaData/CardStarData")
local FavorLevelData = require("luaData/FavorLevel")
local CardTag = require("luaData/CardTag")

InfoRoleCard = class("InfoRoleCard", InfoBase)

local eCardPetalRankPivot = {
	SR = -0.1,
	SSR = -0.15,
	UR = -0.2,
	R = -0.05
}

function InfoRoleCard:ctor(id)
	self.id = id
	self.data = CharacterCard[id]

	if self.data == nil then
		PrintWithColor("RoleCardID[%s] is not exist!", "yellow", tostring(self.id))
	end

	self.listSign = {}

	if self.data ~= nil then
		for _, id in ipairs(self.data.CardTag) do
			local info = CardTag[id]

			if info ~= nil then
				table.insert(self.listSign, info)
			end
		end
	end

	self.curLevel = 1
	self.preLevel = 1
	self.curExp = 0
	self.nextExp = 0
	self.preExp = 0
	self.preNextExp = 0
	self.curStarLevel = 0
	self.curPetal = 0
	self.isHold = false
	self.JobStr = Character[self.data and self.data.CharacterID or 101].Job
	self.job = GetJobType(self.JobStr)
	self.cardRank = GetRankType(self.data and self.data.Rank or "R")
	self.rank = string.lower(self.data.Rank or "R")
	self.maxStarLevel = GetConfigArgJson("StarMaxLevel")[self.cardRank]
	self.maxLevel = GetConfigArgJson("StarCardLevel")[#GetConfigArgJson("StarCardLevel")]
	self.maxPetal = GetConfigArgJson("FlowerNum")[self.cardRank]
	self.curLimitLevel = GetConfigArgJson("RoleCardLevelLimit")[1][2]
	self.attrCnt = #self.data.BaseAttribute
	self.listAbility = RoleCardMgr:GetRoleCardAbility(self)
	self.listAllSkill = {}
	self.listSkill = {}
	self.hpPercent = 1
	self.curCommRaidHpPer = 1
	self.curGvgHpPer = 1
	self.curGvgTimes = 0
	self.maxRaidHpPer = 1
	self.pb = {}
	self.pb.soul = 0
	self.pb.real = false
	self.pb.playerId = PlayerInst.InfoPlayer.pid
	self.publishTime = GetTimeTampByString(self.data.Publish_At or "")
end

function InfoRoleCard:SetData(pbRoleCard)
	self.id = pbRoleCard.id
	self.pb.playerId = pbRoleCard.playerId
	self.pb.levelExp = pbRoleCard.levelExp
	self.pb.starAwards = pbRoleCard.starAwards
	self.pb.petalAwards = pbRoleCard.petalAwards
	self.pb.starTalents = pbRoleCard.starTalents
	self.isHold = true
	self.pb.real = pbRoleCard.real
	self.curStarLevel = pbRoleCard.starLevel
	self.curPetal = pbRoleCard.petal
	self.curCommRaidHpPer = pbRoleCard.clubBlood / 100

	if pbRoleCard.clubGVGBlood then
		self.curGvgHpPer = pbRoleCard.clubGVGBlood / 100
	end

	if pbRoleCard.roleCardTimes then
		self.curGvgTimes = pbRoleCard.roleCardTimes
	end

	self:SetTalent()
	self:UpdateAll()
end

function InfoRoleCard:GetName(isVer)
	if isVer then
		return Lang(self.data.NameSpe)
	end

	return Lang(self.data.Name)
end

function InfoRoleCard:GetDesc()
	if self.data.Info then
		return Lang(self.data.Info)
	end

	return Lang(self.data.Desc)
end

function InfoRoleCard:SetPBPlayer(pbPlayer)
	self.pbPlayer = pbPlayer
end

function InfoRoleCard:SetTalent()
	self.listAllSkill = {}
	self.listSkill = {}

	for _, config in ipairs(self.data.StarTalent) do
		if next(config) ~= nil then
			for _, tId in ipairs(config) do
				local infoTalent = TalentManager:Get(tId)

				if infoTalent.data.BattleSkillType ~= eBattleTalentType.SpecialBall then
					for _, pbt in ipairs(self.pb.starTalents) do
						if tId == pbt.id then
							infoTalent:SetData(pbt)
							table.insert(self.listSkill, infoTalent)

							break
						end
					end
				end

				table.insert(self.listAllSkill, infoTalent)
			end
		end
	end

	local function func(a, b)
		if a.data.Type == b.data.Type then
			return a.data.ID < b.data.ID
		end

		return a.data.Type < b.data.Type
	end

	table.sort(self.listSkill, func)
	table.sort(self.listAllSkill, func)
end

function InfoRoleCard:UpdateAll()
	self:UpdatePreData()
	self:UpdateCurData()
	self:UpdateSimData()
end

function InfoRoleCard:UpdatePreData()
	self.preLevel = self.curLevel
	self.preExp = self.curExp
	self.preNextExp = self.nextExp
	self.preAttrs = self.attrs or {}
end

function InfoRoleCard:UpdateCurData()
	local data = self:UpdateExp(self.pb.levelExp)

	self.curLevel = data.curLevel
	self.curExp = data.curExp
	self.nextExp = data.nextExp
	self.attrs = self:UpdateAtt(self.curLevel, self.curStarLevel, self.curPetal)
	self.fightValue = RoleCardMgr:GetCardFightValue(self)
end

function InfoRoleCard:UpdateSimData()
	self.simCurLevel = self.curLevel
	self.simExp = self.pb.levelExp
	self.simCurExp = self.curExp
	self.simNextExp = self.nextExp
	self.simAttrs = self.attrs or {}
end

function InfoRoleCard:GetAtt(attType)
	if self.attrs == nil then
		self.attrs = AttributeOwner()
	end

	return self.attrs:Get(attType)
end

function InfoRoleCard:ChangeExp(changeExp)
	self.pb.levelExp = self.pb.levelExp + changeExp

	self:UpdateAll()
end

function InfoRoleCard:ChangeSimulateExp(changeExp)
	self.simExp = self.simExp + changeExp

	local data = self:UpdateExp(self.simExp)

	self.simCurLevel = data.curLevel
	self.simCurExp = data.curExp
	self.simNextExp = data.nextExp
	self.simAttrs = self:UpdateAtt(self.simCurLevel, self.curStarLevel, self.curPetal)
end

function InfoRoleCard:ChangeSoulNum(changeSoulNum)
	local preSoul = self.pb.soul

	self.pb.soul = self.pb.soul + changeSoulNum

	ItemManager:UpdateSoulDot(self.id, preSoul, changeSoulNum)
end

function InfoRoleCard:UpdateStarLevel(starLevel)
	if not self:IsHold() then
		return
	end

	self.curStarLevel = starLevel

	self:SetGetStarReward(starLevel)
	self:UpdateAll()
end

function InfoRoleCard:UpdatePetalLevel()
	self.curPetal = TenaryOp(self.curPetal + 1 > self.maxPetal, self.maxPetal, self.curPetal + 1)

	self:UpdateAll()
end

function InfoRoleCard:UpdateTalentLevel(pbTalent)
	for i = 1, #self.listSkill do
		local infoTalent = self.listSkill[i]

		if infoTalent and infoTalent.id == pbTalent.id then
			infoTalent:SetData(pbTalent)

			break
		end
	end

	if self:TalentIsUnLock(pbTalent.id) then
		self:UpdateAll()
	end
end

function InfoRoleCard:UpdateAtt(level, starLevel, petal)
	local cardAtt = AttributeOwner()
	local tab1 = {}
	local tab2 = self.data.AttriList2
	local tab3 = self.data.AttriList3
	local starLevelAttr = self.data.StarAttribute[starLevel + 1] or {
		0,
		0,
		0,
		0
	}
	local starRatio = self.data.StarAddLevelAttr[starLevel + 1] or 0

	for i = 1, 4 do
		local max, min = 0, 0

		for j = 1, 6 do
			local ratio = self.data["LevelRatio" .. j]
			local const = self.data["LevelConstant" .. j]

			min = ratio[i] * level + const[i]

			if max < min then
				max = min
			end
		end

		tab1[i] = max * starRatio + starLevelAttr[i]
	end

	local skillAtt = AttributeOwner()

	for i = 1, #self.listSkill do
		local infoTalent = self.listSkill[i]

		if infoTalent.data.Type == eTalentType.Passive and self:TalentIsUnLock(infoTalent.id, starLevel) then
			local level = self:GetTalentLevelByPetal(infoTalent.id, petal)

			for _, v in pairs(ATTRIBUTE_NAME) do
				local perAtt, absAtt = infoTalent:GetAtt(v, level)

				skillAtt:ModExtraMul(v, perAtt)
				skillAtt:ModExtraAdd(v, absAtt)
			end
		end
	end

	local petalAttPer = self.data.FlowerAtr[petal] or 0
	local petalAttAbs = self.data.FlowerAtr2[petal] or {}

	for k, v in pairs(GetMapTab({
		tab1,
		tab2,
		tab3
	})) do
		cardAtt:SetBase(k, v)
	end

	for _, v in ipairs(ATTRIBUTE_NAME) do
		cardAtt:ModMul(v, skillAtt:GetExtraMul(v))
		cardAtt:ModAdd(v, skillAtt:GetExtraAdd(v))

		local idx = table.getIndex(ATTRIBUTE_MAP[1], v)

		if idx > 0 then
			cardAtt:ModAdd(v, petalAttAbs[idx] or 0)
			cardAtt:ModMul(v, petalAttPer / 100)
		end
	end

	return cardAtt
end

function InfoRoleCard:UpdateExp(exp)
	local curLevel = LevelManager:GetRoleCardLevel(exp)

	curLevel = self:UpdateLimitLevel(curLevel)

	local curExp = exp - LevelManager:GetRoleCardExp(curLevel - 1)
	local nextExp = LevelManager:GetRoleCardNeedExp(curLevel)
	local data = {
		curLevel = curLevel,
		nextExp = nextExp,
		curExp = curExp
	}

	return data
end

function InfoRoleCard:UpdateLimitLevel(level)
	local listLimit = {}
	local starLimitLv, playerLimitLv = 0, 0

	listLimit = GetConfigArgJson("StarCardLevel")
	starLimitLv = listLimit[self.curStarLevel + 1] or 0
	listLimit = GetConfigArgJson("RoleCardLevelLimit")

	local playerLevel = PlayerInst:GetCurLv()

	if self.pb.playerId ~= PlayerInst.InfoPlayer.pid then
		if self.pbPlayer ~= nil then
			playerLevel = LevelManager:GetPlayerLevel(self.pbPlayer.levelExp or 0)
			playerLevel = Mathf.Min(playerLevel, GetConfigArgInt("TeamMaxLevel"))
		else
			playerLevel = 1
		end
	end

	local idx = 1

	for k, v in pairs(listLimit) do
		if playerLevel >= v[1] then
			idx = k
		end
	end

	playerLimitLv = listLimit[idx][2] or 0
	self.curLimitLevel = TenaryOp(playerLimitLv < starLimitLv, playerLimitLv, starLimitLv)

	if level > self.curLimitLevel then
		level = self.curLimitLevel
	end

	return level
end

function InfoRoleCard:IsGet()
	return self.isHold and self.pb.real
end

function InfoRoleCard:IsHold()
	return self.isHold and self.pb.real
end

function InfoRoleCard:GetCardHoldState()
	if self:IsHold() then
		return 1
	else
		return 0
	end
end

function InfoRoleCard:TalentIsUnLock(talentId, starLevel)
	local starLv = Tenary(starLevel, self.curStarLevel)
	local unLockLevel = 0

	for k, v in ipairs(self.data.StarTalent) do
		if table.getIndex(v, talentId) ~= -1 then
			unLockLevel = k - 1

			break
		end
	end

	if unLockLevel <= starLv then
		return true
	end

	return false, unLockLevel
end

function InfoRoleCard:GetTalentLevel(talentId)
	local level = 1

	for i = 1, #self.listSkill do
		if self.listSkill[i].id == talentId then
			level = self.listSkill[i].pb.level
		end
	end

	return level
end

function InfoRoleCard:GetTalentLevelByPetal(talentId, petal)
	local level = 1
	local isHave = false
	local list = self.data.FlowerSkill or {}

	for k, v in ipairs(list) do
		if v[1] and v[1] == talentId then
			if k <= petal then
				level = v[2] or 1
			end

			isHave = true
		end
	end

	if not isHave then
		local infoTalent = TalentManager:Get(talentId)

		if infoTalent then
			level = infoTalent.data.HighestLevel
		end
	end

	return level
end

function InfoRoleCard:GetBattleSkillLevel(battleSkillType)
	local level = 1

	for i = 1, #self.listSkill do
		local infoSkill = self.listSkill[i]

		if infoSkill.data.BattleSkillType == battleSkillType then
			level = infoSkill.pb.level
		end
	end

	return level
end

function InfoRoleCard:SetCardHpPercentBeforeBattle(isUnion, isBossRaid)
	if isUnion then
		self.hpPercent = self.curCommRaidHpPer
	else
		self.hpPercent = 1
	end
end

function InfoRoleCard:SetHpPercent(val)
	self.hpPercent = val
end

function InfoRoleCard:SetGvgHpPer(val)
	self.curGvgHpPer = val
end

function InfoRoleCard:SetGvgTimes(val)
	self.curGvgTimes = val
end

function InfoRoleCard:ResetGvgTimes()
	self.curGvgTimes = 0
end

function InfoRoleCard:GvgTimesVaild()
	local CONST_TIMES = GetConfigArgInt("GvgCardTimesLimit")

	return CONST_TIMES > self.curGvgTimes
end

function InfoRoleCard:SetGvgHelpTimes(val)
	self.curGvgHelpTimes = val
end

function InfoRoleCard:GvgHelpVaild()
	local CONST_TIMES = GetConfigArgInt("GvgCardHelpTimesLimit")
	local CONST_LV = GetConfigArgInt("GvgHelpLevelLimit")
	local ret = 0
	local timesVaild = false
	local levelVaild = false

	if self.curGvgHelpTimes then
		timesVaild = CONST_TIMES > self.curGvgHelpTimes
	end

	if self.pbPlayer and self.pbPlayer.levelExp then
		local lv_helper = LevelManager:GetPlayerLevel(self.pbPlayer.levelExp)
		local lv_self = PlayerInst:GetCurLv()

		levelVaild = not (lv_self < lv_helper) or not (lv_helper > lv_self + CONST_LV)
	end

	if timesVaild and levelVaild then
		ret = 0
	elseif not timesVaild and not levelVaild then
		ret = 1
	elseif not timesVaild then
		ret = 2
	elseif not levelVaild then
		ret = 3
	end

	return ret == 0, ret
end

function InfoRoleCard:UpdateCardHpPercent(v, isBossRaid)
	self.curCommRaidHpPer = v
end

function InfoRoleCard:ResetCardHpPercent(isBossRaid)
	self.curCommRaidHpPer = 1
end

function InfoRoleCard:ResetGvgCardHpPercent()
	if self.curGvgHpPer then
		self.curGvgHpPer = 1
	end
end

function InfoRoleCard:ChangeClubCardHpPercent(percent, isBossRaid)
	percent = Tenary(percent, 100)

	if percent then
		self.curCommRaidHpPer = self.curCommRaidHpPer + percent / 100
		self.curCommRaidHpPer = TenaryOp(self.curCommRaidHpPer > self.maxRaidHpPer, self.maxRaidHpPer, TenaryOp(self.curCommRaidHpPer < 0, 0, self.curCommRaidHpPer))
	end
end

function InfoRoleCard:IsGetStarReward(index)
	local award = self.data.StarReward[index] or {}

	if not award[1] or #award[1] == 0 then
		return true
	end

	for i = 1, #self.pb.starAwards do
		if index == self.pb.starAwards[i] then
			return true
		end
	end

	return false
end

function InfoRoleCard:SetGetStarReward(index)
	table.insert(self.pb.starAwards, index)
end

function InfoRoleCard:IsGetPetalReward(index)
	local award = self.data.FlowerAward[index] or {}

	if not award[1] or #award[1] == 0 then
		return true
	end

	for i = 1, #self.pb.petalAwards do
		if index == self.pb.petalAwards[i] then
			return true
		end
	end

	return false
end

function InfoRoleCard:SetGetPetalReward(index)
	table.insert(self.pb.petalAwards, index)
end

function InfoRoleCard:CanChallenge()
	return self.data.CardChapterShow == 1
end

RoleCardMgr = {}

local dictRoleCard = {}

function RoleCardMgr:GetRoleCard(vRoleCardId)
	local ret = dictRoleCard[vRoleCardId]

	if not ret then
		ret = InfoRoleCard(vRoleCardId)
		dictRoleCard[vRoleCardId] = ret
	end

	if ret.data == nil then
		print("not roleCardID " .. vRoleCardId)
	end

	return ret
end

function RoleCardMgr:GetRoleId(roleCardId)
	local infoRoleCard = self:GetRoleCard(roleCardId)

	return infoRoleCard.data.CharacterID
end

function RoleCardMgr:GetRole(roleCardId)
	local roleId = self:GetRoleId(roleCardId)
	local infoRole = RoleMgr:GetRole(roleId)

	return infoRole
end

function RoleCardMgr:GetAllCard()
	local list = {}
	local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	for k in pairsByKeys(CharacterCard) do
		local infoRoleCard = self:GetRoleCard(k)

		if infoRoleCard and infoRoleCard.data.Version == 1 and curServerTime >= infoRoleCard.publishTime then
			table.insert(list, infoRoleCard)
		end
	end

	return list
end

function RoleCardMgr:GetAllHoldCard()
	local list = {}
	local listAllCard = self:GetAllCard()

	for _, card in ipairs(listAllCard) do
		if card:IsHold() then
			table.insert(list, card)
		end
	end

	return list
end

function RoleCardMgr:GetAllNotHoldCard()
	local list = {}
	local listAllCard = self:GetAllCard()

	for _, card in ipairs(listAllCard) do
		if not card:IsHold() then
			table.insert(list, card)
		end
	end

	return list
end

function RoleCardMgr:GetRoleAllCard(roleId)
	local list = {}
	local listAllCard = self:GetAllCard()

	for _, card in ipairs(listAllCard) do
		if roleId == card.data.CharacterID then
			table.insert(list, card)
		end
	end

	return list
end

function RoleCardMgr:GetRoleHoldCard(roleId)
	local list = {}
	local listRoleCard = self:GetRoleAllCard(roleId)

	for _, card in ipairs(listRoleCard) do
		if card:IsHold() then
			table.insert(list, card)
		end
	end

	return list
end

function RoleCardMgr:GetCardNextLevelLimitInfo(infoRoleCard, level)
	local curLevel = level or infoRoleCard.curLevel
	local starLv = infoRoleCard.curStarLevel
	local starLimitLv = GetConfigArgJson("StarCardLevel")[starLv + 1] or 0
	local listLimit = GetConfigArgJson("RoleCardLevelLimit")
	local playerLevel = PlayerInst:GetCurLv()
	local idx = 1

	for k, v in pairs(listLimit) do
		if playerLevel >= v[1] then
			idx = k
		end
	end

	local playerLimitLv = listLimit[idx] and listLimit[idx][2] or 0
	local str = ""

	if curLevel < starLimitLv then
		local nextIdx = TenaryOp(idx + 1 > #listLimit, #listLimit, idx + 1)

		str = string.format(_("Msg_Level_After_PlayerLevel"), tostring(listLimit[nextIdx][1]))
	else
		local nextStarLv = TenaryOp(starLv + 1 > infoRoleCard.maxStarLevel, infoRoleCard.maxStarLevel, starLv + 1)

		str = string.format(_("Msg_Level_After_Star"), tostring(nextStarLv))
	end

	return str
end

function RoleCardMgr:GetRoleCardSpecialBall(infoRoleCard)
	local infoSkillBall, index = nil, 0

	if infoRoleCard then
		local list = infoRoleCard.data.SessionWeight

		for i = #list, #list - 2, -1 do
			if list[i] == 1 then
				index = i - 3

				break
			end
		end

		local skillBallId = infoRoleCard.data.SpecialAtkSkill

		if skillBallId ~= 0 and index ~= 0 then
			infoSkillBall = TalentManager:Get(skillBallId)
		end
	end

	return infoSkillBall, index
end

function RoleCardMgr:GetRoleCardAbility(infoRoleCard)
	local list = {}
	local listAbility = infoRoleCard.data.AbilityList

	for i = 1, #listAbility do
		local infoAbility = AbilityData[listAbility[i]]

		if not infoAbility then
			print(string.format("ID [%d] not exist in WorkAbility!!!", listAbility[i]))
		else
			table.insert(list, infoAbility)
		end
	end

	return list
end

function RoleCardMgr:SetStar(infoRoleCard, panel, starLevel)
	local sl = starLevel

	if not starLevel then
		sl = infoRoleCard.curStarLevel
	end

	local half = math.floor(infoRoleCard.maxStarLevel / 2) <= 5 and 5 or math.floor(infoRoleCard.maxStarLevel / 2)

	GOUtil.SetActive(panel.GoStar1, sl <= half)
	GOUtil.SetActive(panel.GoStar2, half < sl)

	local starGroup = sl <= half and panel.GoStar1 or panel.GoStar2

	for i = 1, half do
		local frame = GOUtil.FindChildGameObject(panel.GoFrame, "" .. i)
		local star = GOUtil.FindChildGameObject(starGroup, "" .. i)

		if half < sl then
			GOUtil.SetActive(frame, i > sl - half)
			GOUtil.SetActive(star, i <= sl - half)
		else
			GOUtil.SetActive(frame, sl < i)
			GOUtil.SetActive(star, i <= sl)
		end
	end
end

function RoleCardMgr:SetPetal(infoRoleCard, panel)
	for i = 1, table.getCount(eRankType) do
		GOUtil.SetActive(panel["GoPetal" .. i], i == infoRoleCard.cardRank)

		if i == infoRoleCard.cardRank then
			local maxPetal = infoRoleCard.maxPetal
			local curPetal = infoRoleCard.curPetal

			for j = 1, maxPetal do
				local imgF = GOUtil.FindChildComponent(panel["GoPetal" .. i], "" .. j, "Image")
				local gray = TenaryOp(j <= curPetal, 0, 1)

				DealWithListRef(panel, UIUtil.SetImageGray(imgF, gray))
			end
		end
	end
end

function RoleCardMgr.SetPetalInfo(infoCard, panel)
	local cnt, max = infoCard.cardRank + 2, eRankType.UR + 2
	local angle, pivot = 360 / cnt, eCardPetalRankPivot[infoCard.data.Rank]

	for i = 1, max do
		GOUtil.SetActive(panel["GoPetal" .. i], i <= cnt)

		if i <= cnt then
			GOUtil.SetRectTransformPivot(panel["GoPetal" .. i], 0.5, pivot)
			GOUtil.SetTransformLocalRotation(panel["GoPetal" .. i], 0, 0, (1 - i) * angle)
		end
	end
end

function RoleCardMgr:SetStarPanel(infoRoleCard, panel, page)
	for i = 1, 5 do
		local curLevel = infoRoleCard.curStarLevel
		local img = GOUtil.FindChildComponent(panel["ImageStar" .. i], "", "Image")

		if curLevel > 5 then
			UIUtil.SetImageSprite(img, "UI/Common/CellCard/AtlasCellCard/IC_star_01", page)

			curLevel = infoRoleCard.curStarLevel - 5
		else
			UIUtil.SetImageSprite(img, "UI/Common/CellCard/AtlasCellCard/IC_star_03", page)
		end

		if curLevel < i then
			panel["ImageStarFrame" .. i]:SetActive(true)
			panel["ImageStar" .. i]:SetActive(false)
		else
			panel["ImageStarFrame" .. i]:SetActive(false)
			panel["ImageStar" .. i]:SetActive(true)
		end
	end
end

function RoleCardMgr:SetInfoPanel(infoRoleCard, cardIcon, cardBg, panel)
	if cardBg then
		UIUtil.SetRawImageTexture(cardBg, infoRoleCard.data.BGIcon, panel)
	end

	if cardIcon then
		UIUtil.SetRawImageTexture(cardIcon, infoRoleCard.data.FullIcon, panel)
	end
end

function RoleCardMgr:SetCardLocation(infoRoleCard, cardObject, chooseType)
	local _type = chooseType ~= nil and chooseType or 1
	local pos, rot, sca = infoRoleCard.data.Drift[_type], infoRoleCard.data.Rotate[_type], infoRoleCard.data.Scale[_type]

	if pos then
		GOUtil.SetTransformLocalPosition(cardObject, pos[1], pos[2], pos[3])
	end

	if rot then
		GOUtil.SetTransformLocalRotation(cardObject, rot[1], rot[2], rot[3])
	end

	if sca then
		GOUtil.SetTransformLocalScale(cardObject, sca)
	end
end

function RoleCardMgr:GetCardSkill(infoRoleCard)
	local list = {}

	for _, v in ipairs(infoRoleCard.data.StarTalent) do
		if next(v) ~= nil then
			for _, n in ipairs(v) do
				local infoTalent = TalentManager:Get(n)

				table.insert(list, infoTalent)
			end
		end
	end

	return list
end

function RoleCardMgr:GetCardCost(infoRoleCard, infoRole, _type)
	if not infoRoleCard or not infoRole then
		return 0
	end

	local favorLv = infoRole.curFavorLevel or 1
	local costRate = FavorLevelData[favorLv].CardCostRatio
	local baseCost = 0

	if _type == 1 then
		baseCost = infoRoleCard.data.Cost[1]

		return math.ceil(baseCost * (costRate / 100))
	else
		baseCost = infoRoleCard.data.Cost[2]

		return math.ceil(baseCost * (costRate / 100))
	end
end

local function GetCardActSkillAddition(infoRoleCard)
	local list = infoRoleCard.listSkill
	local skill

	for _, v in ipairs(list) do
		if infoRoleCard:TalentIsUnLock(v.id) and v.data.Type == eTalentType.Battle and v.data.BattleSkillType == eBattleTalentType.Active then
			skill = v

			break
		end
	end

	if skill then
		local level = infoRoleCard:GetTalentLevelByPetal(skill.id, infoRoleCard.curPetal)
		local listK = GetConfigArgJson("FightValueSkillAddPer") or {}
		local index = TenaryOp(level > #listK, #listK, TenaryOp(level < 1, 1, level))

		return listK[index] or 0, skill
	end

	return 0, nil
end

function RoleCardMgr:GetFightValue(infoRole, upCard, addCard)
	local stamina, defend, song, will = 0, 0, 0, 0

	if infoRole ~= nil and upCard ~= nil then
		local att = infoRole:UpdateAttWithCard(upCard)

		stamina = Mathf.Round(att:Get("Stamina"))
		defend = Mathf.Round(att:Get("Defend"))
		song = Mathf.Round(att:Get("Song"))
		will = Mathf.Round(att:Get("Will"))
	end

	if addCard ~= nil then
		local percent = (GetConfigArgJson("JoinAttCombat")[1] or 0) / 100

		stamina = stamina + addCard:GetAtt("Stamina") * percent
		defend = defend + addCard:GetAtt("Defend") * percent
		song = song + addCard:GetAtt("Song") * percent
		will = will + addCard:GetAtt("Will") * percent
	end

	local hp = stamina * GetConfigArgInt("FightValueHPRatio")
	local def = defend * GetConfigArgInt("FightValueDefRatio")
	local atk = (will + song) * GetConfigArgInt("FightValueAtkRatio")
	local k = 0

	if upCard then
		k = GetCardActSkillAddition(upCard)
	end

	return math.ceil((hp + def + atk) * (1 + k))
end

function RoleCardMgr:GetCardFightValue(mainCard, supCard)
	local k = 0

	if mainCard then
		k = GetCardActSkillAddition(mainCard)
	end

	local function fun(card)
		local hp = card:GetAtt("Stamina") * GetConfigArgInt("FightValueHPRatio")
		local def = card:GetAtt("Defend") * GetConfigArgInt("FightValueDefRatio")
		local atk = (card:GetAtt("Song") + card:GetAtt("Will")) * GetConfigArgInt("FightValueAtkRatio")

		return math.ceil((atk + def + hp) * (1 + k))
	end

	if not supCard then
		if mainCard then
			return fun(mainCard)
		end
	else
		return fun(supCard)
	end

	return 0
end

function RoleCardMgr:GetFightValueByAtt(att, extra)
	extra = extra or 1

	if not att then
		return 0
	end

	local stamina = Mathf.Round(att:Get("Stamina") or 0) * extra
	local defend = Mathf.Round(att:Get("Defend") or 0) * extra
	local song = Mathf.Round(att:Get("Song") or 0) * extra
	local will = Mathf.Round(att:Get("Will") or 0) * extra
	local hp = stamina * GetConfigArgInt("FightValueHPRatio")
	local def = defend * GetConfigArgInt("FightValueDefRatio")
	local atk = (will + song) * GetConfigArgInt("FightValueAtkRatio")

	return math.floor(hp + def + atk + 0.5)
end

function RoleCardMgr:GetAward(infoRoleCard, aType)
	local list = {}

	if aType == 1 then
		list = infoRoleCard.data.StarReward
	elseif aType == 2 then
		list = infoRoleCard.data.FlowerAward
	end

	local listAward = {}

	for k, v in ipairs(list) do
		local tab = {}

		if next(v) ~= nil then
			local temp = {}

			for _, n in ipairs(v) do
				if next(n) ~= nil then
					local infoItem = ItemManager:GetValueItem(n[1], n[2] or 0)

					table.insert(temp, infoItem)
				end
			end

			tab.index = k
			tab.award = temp

			table.insert(listAward, tab)
		end
	end

	return listAward
end

function RoleCardMgr:GetNextUpCost(infoRoleCard, eType)
	if infoRoleCard == nil then
		return {}, {}
	end

	local list = {}

	if eType == 1 then
		for _, data in pairs(CardStarData) do
			if data.Rank == infoRoleCard.cardRank and data.Star == infoRoleCard.curStarLevel + 1 then
				list = data.Cost or {}

				break
			end
		end
	elseif eType == 2 then
		local listCost = infoRoleCard.data.FlowerCost or {}

		list = listCost[infoRoleCard.curPetal + 1] or {}
	end

	local listItem = {}
	local listCoin = {}

	for k, v in ipairs(list) do
		if next(v) ~= nil then
			local eType = ItemManager:GetType(v[1])

			if eType ~= eItemType.P_GOLD and eType ~= eItemType.P_DIAMOND and eType ~= eItemType.P_DIAMOND_PAY then
				table.insert(listItem, v)
			else
				table.insert(listCoin, v)
			end
		end
	end

	return listItem, listCoin
end

function RoleCardMgr:CanUpStar(infoRoleCard)
	local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.CardStar)

	if not isOpen then
		return false
	end

	if infoRoleCard.curStarLevel >= infoRoleCard.maxStarLevel then
		return false
	else
		local listItem, listGold = RoleCardMgr:GetNextUpCost(infoRoleCard, 1)

		for i = 1, #listItem do
			local isEnough = ItemManager:IsItemHoldEnough(listItem[i][1], listItem[i][2], true)

			if not isEnough then
				return false
			end
		end

		if listGold[1] and listGold[1][1] then
			local isEnough = ItemManager:IsItemHoldEnough(listGold[1][1], listGold[1][2], true)

			if not isEnough then
				return false
			end
		end
	end

	return true
end

function RoleCardMgr:CanUpPetal(infoRoleCard)
	local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.CardPetal)

	if not isOpen then
		return false
	end

	if infoRoleCard.curPetal >= infoRoleCard.maxPetal then
		return false
	else
		local listItem, listGold = RoleCardMgr:GetNextUpCost(infoRoleCard, 2)
		local temp = {}
		local tRankCost = {
			0,
			0,
			0,
			0
		}

		for _, v in ipairs(listItem) do
			if next(v) ~= nil then
				local infoItem = ItemManager:Get(v[1])
				local _type = infoItem.data.Type

				if ItemManager:IsCommonStone(v[1]) then
					local t = {}

					t.id = v[1]
					t.need = v[2] or 0
					t.rank = infoItem.data.Level

					table.insert(temp, t)
				elseif not ItemManager:IsItemHoldEnough(v[1], v[2] or 0, true) then
					return false
				end
			end
		end

		for _, v in ipairs(temp) do
			local used = tRankCost[v.rank]
			local _, hold = ItemManager:GetStarList(v.rank)

			if v.need > hold - tRankCost[v.rank] then
				return false
			end
		end

		if listGold[1] and listGold[1][1] and not ItemManager:IsItemHoldEnough(listGold[1][1], listGold[1][2], true) then
			return false
		end
	end

	return true
end

function RoleCardMgr:SetTeamListIndex(str)
	self.keyTeamListIndex = str

	PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_TEAM_LIST_INDEX, str)
end

function RoleCardMgr:GetTeamListIndex()
	if not self.keyTeamListIndex then
		self.keyTeamListIndex = PersistentStoreUtil.GetString(PersistentStoreUtil.KEY_TEAM_LIST_INDEX)
	end

	local str = self.keyTeamListIndex

	if str == "" then
		str = "1"

		return str
	else
		return str
	end
end

function RoleCardMgr:SetChooseStartCardState(str)
	self.keyChooseStartCardState = str

	PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_CHOOSE_START_CARD_STATE, str)
end

function RoleCardMgr:GetChooseStartCardState()
	if not self.keyChooseStartCardState then
		self.keyChooseStartCardState = PersistentStoreUtil.GetString(PersistentStoreUtil.KEY_CHOOSE_START_CARD_STATE)
	end

	local str = self.keyChooseStartCardState

	if str == "" then
		str = "0"

		return str
	else
		return str
	end
end

function RoleCardMgr:SetCommonTeamRoleList(list)
	local curList = {}
	local commonList = RoleCardMgr:GetCommonTeamRoleList()

	if #commonList > 0 then
		for i = #commonList, 1, -1 do
			local id = string.split(commonList[i], "_")[1]

			for n = 1, #list do
				if tonumber(id) == list[n] then
					table.remove(commonList, i)

					break
				else
					local logoutTime = string.split(commonList[i], "_")[2]
					local curTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
					local disTime = curTime - logoutTime

					if disTime > 86400 then
						table.remove(commonList, i)

						break
					end
				end
			end
		end
	end

	curList = commonList

	local curTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	for i = 1, #list do
		table.insert(curList, list[i] .. "_" .. curTime)
	end

	PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_BATTLE_COMMON_TEAM_ROLE_LIST, curList)
end

function RoleCardMgr:GetCommonTeamRoleList()
	local commonList = PersistentStoreUtil.GetList(PersistentStoreUtil.KEY_BATTLE_COMMON_TEAM_ROLE_LIST)

	if #commonList > 0 then
		for i = #commonList, 1, -1 do
			local logoutTime = string.split(commonList[i], "_")[2]
			local curTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
			local disTime = curTime - logoutTime

			if disTime > 86400 then
				table.remove(commonList, i)
			end
		end
	end

	return commonList
end

function RoleCardMgr:SetCommonTeamRoleCardList(list)
	local curList = {}
	local commonList = RoleCardMgr:GetCommonTeamRoleCardList()

	if #commonList > 0 then
		for i = #commonList, 1, -1 do
			local id = string.split(commonList[i], "_")[1]

			for n = 1, #list do
				if tonumber(id) == list[n] then
					table.remove(commonList, i)

					break
				else
					local logoutTime = string.split(commonList[i], "_")[2]
					local curTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
					local disTime = curTime - logoutTime

					if disTime > 86400 then
						table.remove(commonList, i)

						break
					end
				end
			end
		end
	end

	curList = commonList

	local curTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond

	for i = 1, #list do
		table.insert(curList, list[i] .. "_" .. curTime)
	end

	self.keyBattleCommonTeamRoleCardList = curList

	PersistentStoreUtil.SetList(PersistentStoreUtil.KEY_BATTLE_COMMON_TEAM_ROLE_CARD_LIST, curList)
end

function RoleCardMgr:GetCommonTeamRoleCardList()
	if not self.keyBattleCommonTeamRoleCardList then
		self.keyBattleCommonTeamRoleCardList = PersistentStoreUtil.GetList(PersistentStoreUtil.KEY_BATTLE_COMMON_TEAM_ROLE_CARD_LIST)
	end

	local commonList = self.keyBattleCommonTeamRoleCardList

	if #commonList > 0 then
		for i = #commonList, 1, -1 do
			local logoutTime = string.split(commonList[i], "_")[2]
			local curTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
			local disTime = curTime - logoutTime

			if disTime > 86400 then
				table.remove(commonList, i)
			end
		end
	end

	return commonList
end

function RoleCardMgr.IsNewCard(cardId)
	return CardRDL.NewRDL.IsNewCard(cardId)
end

function RoleCardMgr.CheckCardCompose(info)
	local aim = 0
	local result = false
	local rank = info.data.Rank
	local data = GetConfigArgJson("CardSynthesisCost")

	if rank == "R" then
		aim = data[1]
	elseif rank == "SR" then
		aim = data[2]
	elseif rank == "SSR" then
		aim = data[3]
	elseif rank == "UR" then
		aim = data[4]
	end

	if aim <= info.pb.soul then
		result = true
	end

	return result, aim
end

local InfoTeam = require("Info/InfoTeam")

function RoleCardMgr:SetBossLiveCurIndexState(str)
	PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_BOSS_LIVE_CURINDEX_STADE, str)
end

function RoleCardMgr:GetBossLiveCurIndexState()
	local str = PersistentStoreUtil.GetString(PersistentStoreUtil.KEY_BOSS_LIVE_CURINDEX_STADE)

	if str == "" then
		str = "1_1"

		return str
	else
		return str
	end
end

function RoleCardMgr:SetTipWindowState(str)
	PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_TIP_WINDOW_STADE, str)
end

function RoleCardMgr:GetTipWindowState()
	local str = PersistentStoreUtil.GetString(PersistentStoreUtil.KEY_TIP_WINDOW_STADE)

	if str == "" then
		str = "1"

		return str
	else
		return str
	end
end

function RoleCardMgr:SetTipWindowOnGameState(str)
	PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_TIP_WINDOW_ONGAME_STADE, str)
end

function RoleCardMgr:GetTipWindowOnGameState()
	local str = PersistentStoreUtil.GetString(PersistentStoreUtil.KEY_TIP_WINDOW_ONGAME_STADE)

	if str == "" then
		str = "1"

		return str
	else
		return str
	end
end

function RoleCardMgr:SetTipWindowAwardState(str)
	PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_TIP_WINDOW_AWARD_STADE, str)
end

function RoleCardMgr:GetTipWindowAwardState()
	local str = PersistentStoreUtil.GetString(PersistentStoreUtil.KEY_TIP_WINDOW_AWARD_STADE)

	if str == "" then
		str = "1"

		return str
	else
		return str
	end
end

function RoleCardMgr:SetTipWindowPatFaceState(str)
	local str2 = PersistentStoreUtil.GetString(PersistentStoreUtil.KEY_TIP_WINDOW_PAT_FACE_STADE)

	str2 = str .. "_" .. string.split(str2, "_")[2]

	PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_TIP_WINDOW_PAT_FACE_STADE, str2)
end

function RoleCardMgr:GetTipWindowPatFaceState()
	local str = PersistentStoreUtil.GetString(PersistentStoreUtil.KEY_TIP_WINDOW_PAT_FACE_STADE)

	if str == "" then
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond - 14400
		local time = os.date("%m:%d", curServerTime)

		str = "1_" .. time

		PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_TIP_WINDOW_PAT_FACE_STADE, str)

		return string.split(str, "_")[1]
	else
		local curServerTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond - 14400
		local time = os.date("%m:%d", curServerTime)

		if time ~= string.split(str, "_")[2] then
			str = "1_" .. time
		end

		PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_TIP_WINDOW_PAT_FACE_STADE, str)

		return string.split(str, "_")[1]
	end
end

function RoleCardMgr:SetTipWindowVideoState(str)
	PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_TIP_WINDOW_VIDEO_STADE, self.windowVideoStadeStr)
end

function RoleCardMgr:GetTipWindowVideoState()
	local adsList = InfoGameInst:GetTipWindowAdsList()

	self.adsStr = ""

	for i = 1, #adsList do
		if adsList[i].Type == 1 then
			self.adsStr = self.adsStr .. "_" .. adsList[i].ID
		end
	end

	self.windowVideoStadeStr = PersistentStoreUtil.GetString(PersistentStoreUtil.KEY_TIP_WINDOW_VIDEO_STADE)

	if self.windowVideoStadeStr ~= self.adsStr then
		self.windowVideoStadeStr = self.adsStr

		return self.windowVideoStadeStr ~= ""
	else
		return false
	end
end

function RoleCardMgr:SetTipWindowAwardSignState(str)
	PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_TIP_WINDOW_AWARD_SIGN_STADE, str)
end

function RoleCardMgr:GetTipWindowAwardSignState()
	local str = PersistentStoreUtil.GetString(PersistentStoreUtil.KEY_TIP_WINDOW_AWARD_SIGN_STADE)

	if str == "" then
		str = "1"

		return str
	else
		return str
	end
end

function RoleCardMgr:SetDayTimeRefresh(str)
	PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_DAY_TIME_REFRESH, str)
end

function RoleCardMgr:GetDayTimeRefresh()
	local str = PersistentStoreUtil.GetString(PersistentStoreUtil.KEY_DAY_TIME_REFRESH)

	if str == "" then
		return str
	else
		return str
	end
end

function RoleCardMgr:GetFilterRuleNum(rule)
	local value = 0
	local str = ""
	local listJob = GetConfigArgJson("JobName")
	local listComb = RoleMgr:GetTeamList()
	local teams = InfoTeam.stageTeams
	local listTeam = {}

	for i = 1, 5 do
		if teams[i].name ~= "" then
			table.insert(listTeam, teams[i].name)
		else
			table.insert(listTeam, _("PageBattleTeam_TeamNum") .. teams[i].id)
		end
	end

	local data = {
		{
			filterType = 1,
			title = _("PageRole_TagJob"),
			list = {
				Lang(listJob[1]),
				Lang(listJob[2]),
				Lang(listJob[3]),
				Lang(listJob[4]),
				Lang(listJob[5])
			}
		},
		{
			filterType = 1,
			title = _("eBattleType_2"),
			list = {
				Lang(listComb[1].Name),
				Lang(listComb[2].Name),
				Lang(listComb[3].Name),
				Lang(listComb[4].Name),
				Lang(listComb[5].Name),
				Lang(listComb[6].Name),
				Lang(listComb[7].Name)
			}
		},
		{
			filterType = 1,
			title = _("PageBattleTeam_TeamNum"),
			list = listTeam
		},
		{
			filterType = 2,
			title = _("Filter_Title_AbilitySel"),
			list = {
				_("eSortType_2"),
				_("eSortType_1"),
				_("eSortType_4"),
				_("Desc_Combat_Score")
			}
		}
	}

	for m, v in ipairs(rule) do
		for n, v2 in ipairs(v) do
			if v2 == 1 then
				value = value + 1
				str = data[m].list[n]
			end
		end
	end

	return value, str
end

function RoleCardMgr:ForgeRoleCard(id)
	local infoRoleCard = InfoRoleCard(id)

	local function fun()
		local skills = infoRoleCard.data.StarTalent
		local pbStarTalents = {}

		for k, v in pairs(skills) do
			for i = 1, #v do
				if v[i] then
					local t = {
						level = 1,
						id = v[i]
					}

					table.insert(pbStarTalents, t)
				end
			end
		end

		return pbStarTalents
	end

	local pbRoleCard = {
		petal = 0,
		clubBlood = 0,
		starLevel = 1,
		clubBossBlood = 0,
		soul = 0,
		levelExp = 0,
		id = id,
		playerId = PlayerInst.InfoPlayer.pid,
		attrs = {
			0,
			0,
			0,
			0
		},
		starAwards = {
			1
		},
		starTalents = fun(),
		petalAwards = {}
	}

	infoRoleCard:SetData(pbRoleCard)

	return infoRoleCard
end

function RoleCardMgr:GetCardLevelUpMaxNeed(cardId, onlyCheckCost)
	local infoRoleCard = RoleCardMgr:GetRoleCard(cardId)
	local listCostItem = {}

	for i = 1, #ItemManager.listExpId do
		if i > 3 then
			break
		end

		local temp = {
			num = 0,
			id = ItemManager.listExpId[i]
		}

		table.insert(listCostItem, temp)
	end

	local cost = onlyCheckCost[501] ~= nil and onlyCheckCost[501] or 0
	local holdGold = PlayerInst:GetGold() - cost
	local goldExp = math.floor(holdGold / GetConfigArgInt("GoldPerExp"))
	local limitLevelExp = LevelManager:GetRoleCardExp(infoRoleCard.curLimitLevel - 1)
	local limitExp = limitLevelExp - infoRoleCard.pb.levelExp
	local exp = limitExp <= goldExp and limitExp or goldExp
	local stype = 1

	if limitExp < goldExp then
		stype = 2
	end

	local changeExp = 0

	for i = 1, #ItemManager.listExpId do
		local expId = ItemManager.listExpId[i]
		local info = ItemManager:Get(expId)
		local count = info:GetCurResNum()

		if count > 0 and exp > 0 then
			local num = math.floor(exp / info.data.Value)

			if count <= num then
				listCostItem[i].num = count
				exp = exp - count * info.data.Value
				changeExp = changeExp + count * info.data.Value
			else
				listCostItem[i].num = num
				exp = exp - num * info.data.Value
				changeExp = changeExp + num * info.data.Value

				if stype == 2 and exp > 0 and holdGold >= (changeExp + info.data.Value) * GetConfigArgInt("GoldPerExp") then
					exp = exp - (num + 1) * info.data.Value
					changeExp = changeExp + (num + 1) * info.data.Value
					listCostItem[i].num = listCostItem[i].num + 1
				end
			end
		end
	end

	local needItem = {}
	local goldNum = 0
	local removeKey = {}

	for i, v in ipairs(listCostItem) do
		if v.num > 0 then
			needItem[v.id] = v.num
		end

		goldNum = goldNum + ItemManager:Get(v.id).data.Value * GetConfigArgInt("GoldPerExp") * v.num
	end

	if goldNum > 0 then
		needItem[501] = goldNum
	end

	infoRoleCard:ChangeSimulateExp(changeExp)

	return needItem
end

local createCnt = 0

function RoleCardMgr:CreateEffect()
	createCnt = createCnt + 1

	if IsNil(RoleCardMgr.cardEffect) then
		RoleCardMgr.cardEffect = ResourceMgr.LoadSync("UI/Common/CellCard/CardEffect/CellCardEffect", GameObject)
		RoleCardMgr.cardEffectObj = GOUtil.InstantiateUIPrefab(RoleCardMgr.cardEffect, UIMgr.UIRootObject)
	end
end

function RoleCardMgr:UnloadEffect()
	createCnt = createCnt - 1
	createCnt = TenaryOp(createCnt < 0, 0, createCnt)

	if RoleCardMgr.cardEffect and createCnt == 0 then
		ResourceMgr.Unload(RoleCardMgr.cardEffect)
		Object.Destroy(RoleCardMgr.cardEffectObj)

		RoleCardMgr.cardEffect = nil
		RoleCardMgr.cardEffectObj = nil
	end
end

function RoleCardMgr.ShowCardEffect(infoRoleCard)
	if infoRoleCard == nil then
		return false
	end

	return infoRoleCard.data.CardEffect == 1
end
