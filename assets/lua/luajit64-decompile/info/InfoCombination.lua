-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoCombination.lua

local CombData = require("luaData/CharacterTeam")
local SkillCost = require("luaData/TeamFetterCost")
local Character = require("luaData/CharacterRole")
local CharacterCard = require("luaData/CharacterCard")

eCombinationColor = {
	"D07880",
	"6599C0",
	"A780C3",
	"6BA674"
}
InfoCombination = class("InfoCombination", InfoBase)

function InfoCombination:ctor(id)
	self.id = tonumber(id)
	self.data = CombData[id]
	self.roleNum = #self.data.MemberList
	self.preBondageLv = 0
	self.curBondageLv = 0
	self.listRole = {}

	for _, roleId in ipairs(self.data.MemberList or {}) do
		local infoRole = RoleMgr:GetRole(roleId)

		if infoRole then
			table.insert(self.listRole, infoRole)
		end
	end

	self.listSkill = {}

	for _, v in ipairs(self.data.SkillList) do
		local infoTalent = InfoTalent(v)
		local pb = {
			level = 1,
			id = v
		}

		infoTalent:SetData(pb)

		infoTalent.unlock = false

		table.insert(self.listSkill, infoTalent)
	end
end

function InfoCombination:SetData(pbTeamFetter)
	self.pbTeamFetter = pbTeamFetter

	if pbTeamFetter then
		for _, infoTalent in ipairs(self.listSkill) do
			for _, pbStarTalent in ipairs(pbTeamFetter.skills) do
				if infoTalent.id == pbStarTalent.id then
					infoTalent:SetData(pbStarTalent)

					infoTalent.unlock = true

					break
				end
			end
		end
	end

	self.preBondageLv = self:GetBondageLevel()
	self.curBondageLv = self:GetBondageLevel()
end

function InfoCombination:UpdateBondageSkill(pbSkill)
	for _, v in pairs(self.listSkill) do
		if pbSkill.id == v.id then
			v:SetData(pbSkill)

			break
		end
	end

	if self.pbTeamFetter then
		for _, pbStarTalent in ipairs(self.pbTeamFetter.skills) do
			if pbSkill.id == pbStarTalent.id then
				pbStarTalent.level = pbSkill.level

				break
			end
		end
	end

	self.preBondageLv = self.curBondageLv
	self.curBondageLv = self:GetBondageLevel()
end

function InfoCombination:UpdateUnlockState(skillIds)
	if not skillIds then
		return
	end

	self.pbTeamFetter = self.pbTeamFetter or {
		id = self.id,
		skills = {}
	}

	for _, v in ipairs(skillIds) do
		local isHave = false

		for _, n in ipairs(self.pbTeamFetter.skills) do
			if v == n.id then
				isHave = true

				break
			end
		end

		if not isHave then
			local pbStarTalent = {
				level = 1,
				id = v
			}

			table.insert(self.pbTeamFetter.skills, pbStarTalent)
		end
	end

	for _, v in pairs(self.listSkill) do
		if table.contains(skillIds, v.id) then
			v.unlock = true
		end
	end

	self.preBondageLv = self.curBondageLv
	self.curBondageLv = self:GetBondageLevel()
end

function InfoCombination:GetBondageLevel()
	local sumLv = 0

	for _, v in ipairs(self.listSkill) do
		if v.unlock then
			sumLv = sumLv + v.pb.level
		end
	end

	return sumLv
end

CombinationMgr = {}

local combinationDict = combinationDict or Record()
local combinationList = {}
local combinationListTeamOder = {}

function CombinationMgr:Get(id)
	local ret = combinationDict:GetValue(id)

	if not ret then
		ret = InfoCombination(id)

		combinationDict:Set(id, ret)
	end

	if not ret.data then
		PrintWithColor("Team [%s] not is exist !", "red", tostring(id))

		return nil
	end

	return ret
end

function CombinationMgr:GetCombinationList()
	if #combinationList > 0 then
		return combinationList
	end

	for _, v in pairsByKeys(CombData) do
		local info = self:Get(v.ID)

		if info then
			table.insert(combinationList, info)
		end
	end

	return combinationList
end

function CombinationMgr:GetAllCombination()
	local list = {}

	for _, v in pairsByKeys(CombData) do
		local info = self:Get(v.ID)

		if info and info.data.Version == 1 then
			table.insert(list, info)
		end
	end

	return list
end

function CombinationMgr:GetCombinationSortByTeamOder()
	if #combinationListTeamOder > 0 then
		return combinationListTeamOder
	end

	local list = {}

	for _, v in pairsByKeys(CombData) do
		local info = self:Get(v.ID)

		if info and info.data.Version == 1 then
			table.insert(list, info)
		end
	end

	table.sort(list, function(a, b)
		return a.data.TeamOrder < b.data.TeamOrder
	end)

	combinationListTeamOder = list

	return list
end

function CombinationMgr.GetAllBondageCombination()
	local list = {}
	local all = CombinationMgr:GetAllCombination()

	for _, info in ipairs(all) do
		if info.data.FetterVersion == 1 then
			table.insert(list, info)
		end
	end

	return list
end

function CombinationMgr:GetCombRoleNumByRoleList(combId, roleIdList)
	if not roleIdList or not combId then
		return 0
	end

	local cnt = 0

	for _, v in ipairs(roleIdList) do
		if Character[v] and Character[v].Team == combId then
			cnt = cnt + 1
		end
	end

	return cnt
end

function CombinationMgr:GetRoleHoldNum(combId)
	local c = 0
	local info = self:Get(combId)

	for _, v in ipairs(info.listRole) do
		if v.hold then
			c = c + 1
		end
	end

	return {
		c,
		#info.listRole
	}
end

function CombinationMgr.GetCombIdxAndRoleIdx(roleId)
	for k, v in pairsByKeys(CombData) do
		for i = 1, #v.MemberList do
			if roleId == v.MemberList[i] then
				return k, i
			end
		end
	end

	return 0, 0
end

CombBondageMgr = {}

SafeExecute(function()
	CombBondageMgr.MaxLevel = GetConfigArgJson("FetterLevelIcon")[#GetConfigArgJson("FetterLevelIcon")][1] or 0
end, 2)

function CombBondageMgr:SetData(pbTeamFetters)
	for _, v in ipairs(pbTeamFetters) do
		local infoComb = CombinationMgr:Get(v.id)

		if infoComb then
			infoComb:SetData(v)
		end
	end
end

function CombBondageMgr:GetCombinationBySkillId(skillId)
	for _, v in pairsByKeys(CombData) do
		for _, n in ipairs(v.SkillList) do
			if skillId == n then
				return CombinationMgr:Get(v.ID)
			end
		end
	end

	return nil
end

function CombBondageMgr:GetSkillUpCost(skill)
	local temp = {}

	for _, v in pairsByKeys(SkillCost) do
		if v.SkillID == skill.id and v.Level == skill.pb.level and skill.pb.level < skill.data.HighestLevel then
			for _, n in ipairs(v.Cost) do
				if table.getn(n) > 0 then
					local t = {
						info = ItemManager:Get(n[1]),
						cost = n[2] or 0,
						type = n[3] or 0
					}

					table.insert(temp, t)
				end
			end

			break
		end
	end

	return temp
end

function CombBondageMgr:GetUnlockCondition(infoComb, skillId)
	local skillIdx = table.getIndex(infoComb.data.SkillList or {}, skillId)

	if skillIdx ~= -1 then
		local condition = infoComb.data.UnSkillCondition[skillIdx] or {
			0,
			0
		}

		return condition[1], condition[2]
	end

	return 0, 0
end

function CombBondageMgr:GetEnableCondition(infoComb, skillId)
	local skillList = infoComb.data.SkillList
	local index = table.getIndex(skillList, skillId)

	if index ~= -1 then
		return infoComb.data.ActivatedRole[index] or 0
	end

	return 0
end

function CombBondageMgr:BondageSkillIsUnlock(infoComb, skillId)
	if not infoComb or not skillId then
		return false
	end

	local num, favorLv = self:GetUnlockCondition(infoComb, skillId)
	local sum = 0

	for _, v in ipairs(infoComb.listRole) do
		if v.curFavorLevel >= (favorLv or 0) then
			sum = sum + 1
		end
	end

	return sum >= (num or 0)
end

function CombBondageMgr:BondageSkillIsEnable(skillId, battleRoleIds)
	local infoComb = self:GetCombinationBySkillId(skillId)

	if not infoComb then
		return false
	end

	local skillIdx = table.getIndex(infoComb.data.SkillList, skillId)
	local battleNum = CombinationMgr:GetCombRoleNumByRoleList(infoComb.id, battleRoleIds)

	if battleNum >= infoComb.data.ActivatedRole[skillIdx] then
		return true
	end

	return false
end

function CombBondageMgr:GetUnlockSkillByCombId(combId)
	local unlockSkills = {}
	local infoComb = CombinationMgr:Get(combId)

	if infoComb then
		for _, v in ipairs(infoComb.listSkill) do
			if self:BondageSkillIsUnlock(infoComb, v.id) then
				table.insert(unlockSkills, v)
			end
		end
	end

	return unlockSkills
end

function CombinationMgr.GetAllCanUseBondageCombList()
	local t = {}
	local list = CombinationMgr.GetAllBondageCombination()

	for _, v in ipairs(list) do
		for _, n in ipairs(v.listSkill) do
			if n.unlock then
				table.insert(t, v)

				break
			end
		end
	end

	return t
end

function CombBondageMgr:GetEnabledBondageCombList()
	local list = CombinationMgr.GetAllBondageCombination()

	local function fun(a, b)
		local unlockNum1 = #CombBondageMgr:GetUnlockSkillByCombId(a.id)
		local unlockNum2 = #CombBondageMgr:GetUnlockSkillByCombId(b.id)

		if unlockNum1 == unlockNum2 then
			return a.data.TeamOrder < b.data.TeamOrder
		else
			return unlockNum2 < unlockNum1
		end
	end

	table.sort(list, fun)

	return list
end

function CombBondageMgr.IsHaveUnlockCombinationBondage()
	local list = CombinationMgr.GetAllBondageCombination()

	for _, v in ipairs(list) do
		for _, n in ipairs(v.listSkill) do
			if n.unlock then
				return true
			end
		end
	end

	return false
end

function CombBondageMgr:GetBondageRank(combId)
	local infoComb = CombinationMgr:Get(combId)

	if not infoComb then
		return 1
	end

	local rank = CombBondageMgr:GetBondageRankBySumLv(infoComb.curBondageLv)

	return rank
end

function CombBondageMgr:GetBondageRankBySumLv(sumLv)
	local rank = 1
	local rankList = GetConfigArgJson("FetterLevelIcon")

	for k, v in ipairs(rankList) do
		if sumLv >= v[1] then
			rank = k
		else
			break
		end
	end

	rank = rank > 3 and 3 or rank

	return rank
end

function CombBondageMgr:GetBondageRankInfo(rank)
	local nextRank = rank + 1

	if nextRank > #GetConfigArgJson("FetterLevelIcon") then
		nextRank = #GetConfigArgJson("FetterLevelIcon")
	end

	local targetLv = GetConfigArgJson("FetterLevelIcon")[nextRank][1]

	return targetLv, ""
end

CombBondageMgr.UnlockSkills = {}

function CombBondageMgr.ResetJustUnlockSkills(combId)
	CombBondageMgr.UnlockSkills["T" .. combId] = {}

	BondageRDL.RemoveBondageUnlock(combId)
end

function CombBondageMgr.GetJustUnlockSkillIds(combId)
	local t = BondageRDL.GetUnlockBondage(combId)
	local infoComb = CombinationMgr:Get(combId)

	if infoComb.preBondageLv == infoComb.curBondageLv then
		infoComb.preBondageLv = infoComb.preBondageLv - #t
	end

	return t
end

function CombBondageMgr.SetJustUnlockSkills(role)
	local id = role.data.Team
	local info = CombinationMgr:Get(id)

	local function GetSkillUnlockState(skillId)
		for _, v in ipairs(info.listSkill) do
			if v.id == skillId then
				return v.unlock
			end
		end

		return true
	end

	for _, v in ipairs(info.data.SkillList) do
		local isJustUnlock = CombBondageMgr:BondageSkillIsUnlock(info, v) and not GetSkillUnlockState(v)

		if isJustUnlock then
			CombBondageMgr.UnlockSkills["T" .. id] = CombBondageMgr.UnlockSkills["T" .. id] or {}

			if not table.contains(CombBondageMgr.UnlockSkills["T" .. id], v) then
				table.insert(CombBondageMgr.UnlockSkills["T" .. id], v)
				BondageRDL.AddBondageUnlock(id, v)
			end
		end
	end

	info:UpdateUnlockState(CombBondageMgr.UnlockSkills["T" .. id])
end

function CombBondageMgr.DealWithBattleBondage(listCardId, pbTeamFetter)
	if not pbTeamFetter then
		return nil
	end

	local combId = pbTeamFetter.id

	if combId == 0 then
		return nil
	end

	local infoComb = CombinationMgr:Get(combId)

	if not infoComb then
		return nil
	end

	local roleIds = {}

	for _, v in ipairs(listCardId) do
		if v ~= 0 then
			local cardData = CharacterCard[v]

			if cardData then
				local isHave = false

				for _, n in ipairs(roleIds) do
					if cardData.CharacterID == n then
						isHave = true

						break
					end
				end

				if not isHave then
					table.insert(roleIds, cardData.CharacterID)
				end
			end
		end
	end

	local tab = {}

	for _, v in ipairs(pbTeamFetter.skills) do
		local isEnable = CombBondageMgr:BondageSkillIsEnable(v.id, roleIds)
		local canUse = false

		if isEnable then
			canUse = true
		end

		local temp = {
			skillId = v.id,
			skillLevel = v.level,
			canUse = canUse
		}

		table.insert(tab, temp)
	end

	local bondage = {
		maxRole = infoComb.roleNum,
		battleRole = CombinationMgr:GetCombRoleNumByRoleList(combId, roleIds),
		skills = tab,
		combinationId = combId
	}

	return bondage
end
