-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoLevel.lua

require("Info/InfoBase")

local levelData = require("luaData/LevelConfig")
local favorData = require("luaData/FavorLevel")
local clubData = require("luaData/ClubLevel")

LevelManager = {}

function LevelManager:GetAttMax(level, eAttType)
	return
end

function LevelManager:GetLevel(field, exp)
	local level = 1
	local expValue = 0

	while true do
		if levelData[level][field] == 0 then
			level = level - 1

			break
		end

		if exp < levelData[level][field] then
			break
		end

		if levelData[level + 1] == nil then
			break
		end

		level = level + 1
	end

	return level
end

function LevelManager:GetValue(field, level)
	if levelData[level] == nil then
		return 0
	end

	return levelData[level][field]
end

function LevelManager:GetPlayerLevel(exp)
	return self:GetLevel("PlayerExperienceAdd", exp)
end

function LevelManager:GetPlayerNeedExp(level)
	if level == 0 then
		return 0
	end

	return levelData[level].PlayerExperience
end

function LevelManager:GetPlayerExp(level)
	return self:GetValue("PlayerExperienceAdd", level)
end

function LevelManager:GetFavorLevel(field, exp)
	local level = 1
	local expValue = 0

	while level < #favorData do
		if favorData[level][field] == 0 then
			level = level - 1

			break
		end

		if exp < favorData[level][field] then
			break
		end

		level = level + 1
	end

	return level
end

function LevelManager:GetLevelAwardList()
	local list = {}
	local maxFavorLevel = GetConfigArgInt("FavorMaxLevel")

	for _, v in pairs(favorData) do
		if #v.LevelAward > 0 and maxFavorLevel >= v.ID then
			table.insert(list, v)
		end
	end

	table.sort(list, function(a, b)
		return tonumber(a.ID) < tonumber(b.ID)
	end)

	return list
end

function LevelManager:GetFavorLevelSkillList(roleId)
	local list = {}

	for _, v in pairs(RoleMgr:GetRole(roleId).data.FavorLevelSkill) do
		local infoTalent = TalentManager:Get(v[2])
		local skillAttr = infoTalent.data.Argus1[1]

		table.insert(list, skillAttr)
	end

	return list
end

function LevelManager:GetFavorValue(field, level)
	if favorData[level] == nil then
		return 0
	end

	return favorData[level][field]
end

function LevelManager:GetRoleFavorLevel(exp)
	return self:GetFavorLevel("FavorPointAdd", exp)
end

function LevelManager:GetRoleFavorNeedExp(level)
	if level == 0 then
		return 0
	end

	return favorData[level].FavorPoint
end

function LevelManager:GetRoleFavorExp(level)
	return self:GetFavorValue("FavorPointAdd", level)
end

function LevelManager:IsFavorLevelMax(infoRole)
	local maxFavorLevel = GetConfigArgInt("FavorMaxLevel")

	return maxFavorLevel <= infoRole.curFavorLevel
end

function LevelManager:GetFavorAddCount(infoRole, giftItemValue, id, curSumExp)
	local maxFavorLevel = GetConfigArgInt("FavorMaxLevel") - 1
	local curMaxAddExp = LevelManager:GetRoleFavorExp(maxFavorLevel)
	local curAddExp = infoRole.curFavorExp

	if infoRole.curFavorLevel ~= 1 then
		curAddExp = curAddExp + LevelManager:GetRoleFavorExp(infoRole.curFavorLevel - 1)
	end

	curAddExp = curMaxAddExp - curAddExp

	local index = 0

	for i, v in ipairs(giftItemValue) do
		if giftItemValue[i].id ~= id then
			curAddExp = curAddExp - giftItemValue[i].expOne * giftItemValue[i].count
		else
			local addCount = curAddExp / giftItemValue[i].expOne

			addCount = math.max(addCount, 0)

			return math.ceil(addCount), curMaxAddExp <= curSumExp
		end
	end

	return GetConfigArgInt("GiftMaxNumber"), curMaxAddExp <= curSumExp, curMaxAddExp < curSumExp
end

function LevelManager:GetPreviewProgress(infoRole, giftItemValue, preFavorLevel)
	local maxFavorLevel = GetConfigArgInt("FavorMaxLevel")
	local curAddExp = 0
	local curAddExpValue = 0
	local curFavorLevel = infoRole.curFavorLevel

	if curFavorLevel ~= 1 then
		curAddExp = LevelManager:GetRoleFavorExp(curFavorLevel - 1) + infoRole.curFavorExp
	end

	for i, v in ipairs(giftItemValue) do
		curAddExp = curAddExp + giftItemValue[i].expOne * giftItemValue[i].count
		curAddExpValue = giftItemValue[i].expOne * giftItemValue[i].count + curAddExpValue
	end

	local level = curFavorLevel

	for i = curFavorLevel, maxFavorLevel do
		if curAddExp < favorData[i].FavorPointAdd then
			local FavorPointAdd = 0

			if curAddExp >= 10 then
				FavorPointAdd = favorData[i - 1].FavorPointAdd
			end

			local data = {}

			data[1] = curAddExp - FavorPointAdd
			data[2] = favorData[i].FavorPoint

			if preFavorLevel then
				curFavorLevel = preFavorLevel
			end

			data[3] = i - curFavorLevel
			data[4] = curAddExpValue
			data[5] = curAddExp

			return data
		end
	end
end

function LevelManager:GetNextUp(level)
	return levelData[level].NextUp
end

function LevelManager:HasGift(getLevel, curLevel)
	local levelGeted = getLevel + 1

	if levelGeted >= #favorData then
		return false
	end

	if curLevel < levelGeted then
		return false
	end

	for i = levelGeted, curLevel do
		if #favorData[i].LevelAward > 0 then
			return true
		end
	end

	return false
end

function LevelManager:GetRoleCardStarLevel(exp)
	local lv = self:GetLevel("StarSoulAdd", exp) - 1

	if lv < 1 then
		lv = 1
	end

	return lv
end

function LevelManager:GetRoleCardSoulMax(starLevel)
	return levelData[starLevel + 1].StarSoul
end

function LevelManager:GetRoleCardLevel(exp)
	return self:GetLevel("RoleCardExperienceAdd", exp)
end

function LevelManager:GetRoleCardNeedExp(level)
	if level == 0 then
		return 0
	end

	return levelData[level].RoleCardExperience
end

function LevelManager:GetRoleCardExp(level)
	return self:GetValue("RoleCardExperienceAdd", level)
end

function LevelManager:GetAttributeMax(level)
	return
end

function LevelManager:GetMaxPowerByLevel(level)
	if not levelData[level] then
		return 999
	end

	return levelData[level].MaxStamina
end

function LevelManager:GetSpiritCardUpItem(level)
	if not levelData[level] then
		return 999
	end

	return levelData[level].SpiritCardUpItem
end

function LevelManager:GetMaxMP(level)
	if not levelData[level] then
		return 999
	end

	return levelData[level].MaxMP
end

function LevelManager:GetMaxCost(level)
	if not levelData[level] then
		return 999
	end

	return levelData[level].MaxCost
end

function LevelManager:GetClubLiveness(level)
	if clubData[level] == nil then
		return 0
	end

	return clubData[level].LevelPointAdd
end

function LevelManager:GetClubNeedLiveness(level)
	if level == 0 then
		return 0
	end

	return clubData[level] and clubData[level].LevelPoint or 0
end

function LevelManager:GetClubLevelMaxMembers(level)
	if clubData[level] == nil then
		return 0
	end

	return clubData[level].Member
end
