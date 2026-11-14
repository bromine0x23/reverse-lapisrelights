-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/DataBuilder/Builder/CardBuilder.lua

CardBuilder = BClass("CardBuilder")

local eRankType = {
	SR = 2,
	SSR = 3,
	UR = 4,
	R = 1
}

function CardBuilder:ctor(pbRoleCard, pbPlayer)
	self.id = pbRoleCard.id
	self.playerId = pbRoleCard.playerId
	self.data = ConfigTable.CharacterCard[self.id]
	self.specialAtkSkill = self.data.SpecialAtkSkill
	self.curLevel = 1
	self.maxLevel = GetConfigArgJson("StarCardLevel")[#GetConfigArgJson("StarCardLevel")]
	self.curStarLevel = 0
	self.maxStarLevel = GetConfigArgJson("StarMaxLevel")[eRankType["" .. self.data.Rank]] or 0
	self.curPetal = 0
	self.maxPetal = GetConfigArgJson("FlowerNum")[eRankType["" .. self.data.Rank]] or 0
	self.playerLevel = 1

	if pbPlayer then
		self.playerLevel = LevelMgr:GetLevel(eLevelType.P, pbPlayer.levelExp)
	end

	self.curCommRaidHpPer = 1
	self.curBossRaidHpPer = 1
	self.attrs = {}
	self.listSkill = {}
	self.pb = {}

	self:SetData(pbRoleCard)
end

function CardBuilder:SetData(pb)
	self.pb.levelExp = pb.levelExp
	self.pb.starTalents = pb.starTalents
	self.curCommRaidHpPer = pb.clubBlood / 100
	self.curBossRaidHpPer = pb.clubBossBlood / 100
	self.curLevel = self:GetLimitLevel()
	self.curStarLevel = pb.starLevel
	self.curPetal = pb.petal

	self:UpdateTalent()
	self:UpdateAttr()
end

function CardBuilder:GetLimitLevel()
	local listLimit = GetConfigArgJson("RoleCardLevelLimit")
	local num = 1

	for k, v in pairs(listLimit) do
		if self.playerLevel >= v[1] then
			num = k
		end
	end

	local level = LevelMgr:GetLevel(eLevelType.C, self.pb.levelExp)

	if level > listLimit[num][2] then
		level = listLimit[num][2]
	end

	return level
end

function CardBuilder:TalentIsUnLock(talentId)
	local list = self.data.StarTalent

	for k, v in ipairs(list) do
		if table.contains(v, talentId) then
			if self.curStarLevel >= k - 1 then
				return true
			else
				return false
			end
		end
	end

	return false
end

function CardBuilder:UpdateTalent()
	if self.pb.starTalents then
		for i = 1, #self.pb.starTalents do
			local pbTalent = self.pb.starTalents[i]
			local id = pbTalent.id

			if self:TalentIsUnLock(id) then
				local skill = SkillBuilder(pbTalent)

				table.insert(self.listSkill, skill)
			end
		end
	end
end

function CardBuilder:UpdateAttr()
	local tab1 = {}
	local tab2 = self.data.AttriList2
	local tab3 = self.data.AttriList3
	local starLevelAttr = self.data.StarAttribute[self.curStarLevel + 1] or {
		0,
		0,
		0,
		0
	}
	local starRatio = self.data.StarAddLevelAttr[self.curStarLevel + 1] or 0

	for i = 1, 4 do
		local max, min = 0, 0

		for j = 1, 6 do
			local ratio = self.data["LevelRatio" .. j]
			local const = self.data["LevelConstant" .. j]

			min = ratio[i] * self.curLevel + const[i]

			if max < min then
				max = min
			end
		end

		tab1[i] = max * starRatio + starLevelAttr[i]
	end

	local petalAttPer = self.data.FlowerAtr[self.curPetal] or 0
	local petalAttAbs = self.data.FlowerAtr2[1]

	Attribute:Init()

	for k, v in pairs(GetMapTab({
		tab1,
		tab2,
		tab3
	})) do
		Attribute:ModifyAbsValue(k, v)
	end

	for _, v in pairs(self.listSkill) do
		if v.data.Type == eAllSkillType.System then
			for _, n in pairs(ATTRIBUTE_NAME) do
				Attribute:ModifyPerValue(n, v.attrs[n] / 100)
			end
		end
	end

	for _, n in pairs(ATTRIBUTE_NAME) do
		Attribute:ModifyPerValue(n, petalAttPer / 100)
	end

	self.attrs = Attribute:GetAttr()
end
