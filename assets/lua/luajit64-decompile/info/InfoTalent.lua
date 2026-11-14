-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoTalent.lua

local TalentData = require("luaData/AllSkills")
local BattleData = require("luaData/BattleSkillData")

eTalentType = {
	Passive = 2,
	Settlement = 3,
	Work = 4,
	Battle = 1
}
eBattleTalentType = {
	Passive = 2,
	HeavyAtk = 5,
	Bondage = 7,
	SpecialBall = 6,
	Active = 1,
	LightAtk = 4,
	Center = 3
}
InfoTalent = class("InfoTalent", InfoBase)

function InfoTalent:ctor(talentID)
	self.id = talentID
	self.data = TalentData[talentID]

	if self.data == nil then
		PrintWithColor("talentId[%d] data is not exist!", "yellow", talentID)
		print("talentId is not exist! " .. tostring(talentID))
	end

	self.battleData = BattleData[self.data.BattleSkillID[1]]
	self.maxTalentLevel = self.data.HighestLevel
end

function InfoTalent:SetData(pbTalent)
	self.pb = pbTalent
end

function InfoTalent:GetAtt(att, level)
	local attrs = AttributeOwner()

	if self.data.Type == eTalentType.Passive then
		local index = self.pb and self.pb.level or 1

		if level then
			index = level
		end

		local _type = eValueType.Per

		if (not self.data.Argus[index] or #self.data.Argus[index] ~= 4) and self.data.Argus1[index] and #self.data.Argus1[index] == 4 then
			_type = eValueType.Abs
		end

		local tab1, tab2, tab3 = TenaryOp(_type == eValueType.Per, self.data.Argus[index], self.data.Argus1[index]), self.data.Argus2[index], self.data.Argus3[index]

		for k, v in pairs(GetMapTab({
			tab1,
			tab2,
			tab3
		})) do
			if table.contains(ATTRIBUTE_MAP[1], k) then
				if _type == eValueType.Abs then
					attrs:ModExtraAdd(k, v)
				else
					attrs:ModExtraMul(k, v / 100)
				end
			elseif GetAttValueType(v) == eValueType.Abs then
				attrs:ModExtraMul(k, v / 100)
			else
				attrs:ModExtraAdd(k, v / 100)
			end
		end
	end

	return attrs:GetExtraMul(att), attrs:GetExtraAdd(att)
end

function InfoTalent:GetIconPath()
	if self.data then
		return "UIDyAtlas/Skill/" .. self.data.Icon
	end

	return ""
end

function InfoTalent:IsMaxLevel()
	local maxLevel = self.data.HighestLevel
	local curLevel = self.pb and self.pb.level and self.pb.level or 1

	return maxLevel <= curLevel
end

TalentManager = {}
TalentManager.dict = TalentManager.dict or Record()

function TalentManager:Get(id)
	local ret = InfoTalent(id)

	if ret.data == nil then
		return nil
	end

	return ret
end

function TalentManager:GetMaxLevel(id)
	local data = TalentData[id]

	if data then
		return data.HighestLevel
	end

	return 1
end
