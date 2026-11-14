-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/GameResult/GameResult.lua

local skillData = DefineClass({
	id = -1,
	owner = "",
	count = 0,
	type = ""
})
local UnitResult = GLClass("GameResult_UnitResult", GameHelper)

function UnitResult:ctor(GL, unit)
	self.GL = GL

	self:Reset()

	self.UniqueId = unit.UniqueId
	self.UnitTitle = unit.UnitTitle
	self.UnitId = unit.UnitId
	self.Camp = unit.Camp
end

function UnitResult:Reset()
	self.UniqueId = nil
	self.SkillDamage = {}
	self.BuffDamage = {}
	self.SumDamage = 0
	self.SumDamageTake = 0
	self.SumHeal = 0
end

function UnitResult:Purge()
	self:Reset()

	self.GL = nil
end

function UnitResult:DamageResult(source, unit, dmg)
	if source.UniqueId ~= self.UniqueId then
		return
	end

	if dmg.dmgSource.className == "Skill" then
		local skill = dmg.dmgSource
		local data = self.SkillDamage[skill.SkillId]

		data = data or {
			sum = 0,
			count = 1
		}
		data.sum = data.sum + dmg.finalMinusHp + dmg.finalMinusShield + dmg.finalRealMinusHp
		self.SkillDamage[skill.SkillId] = data
	elseif dmg.dmgSource.className == "Buff" then
		local buff = dmg.dmgSource
		local data = self.BuffDamage[buff.BuffId]

		data = data or {
			sum = 0,
			count = 0,
			buffId = buff.BuffId
		}
		data.sum = data.sum + dmg.finalMinusHp + dmg.finalMinusShield + dmg.finalRealMinusHp
		data.count = data.count + 1
		self.BuffDamage[buff.BuffId] = data
	end

	local val = dmg.finalMinusHp + dmg.finalMinusShield + dmg.finalRealMinusHp

	self.SumDamage = self.SumDamage + val
end

function UnitResult:TakeDamageResult(source, unit, dmg)
	self.SumDamageTake = self.SumDamageTake + dmg.finalMinusHp + dmg.finalMinusShield + dmg.finalRealMinusHp
end

function UnitResult:HealResult(unit, healer, val)
	self.SumHeal = self.SumHeal + val
end

function UnitResult:SkillResult(skill)
	local data = self.SkillDamage[skill.SkillId]

	if not data then
		data = {
			sum = 0,
			count = 0,
			skillId = skill.SkillId
		}
		self.SkillDamage[skill.SkillId] = data
	end

	data.count = data.count + 1
end

local TeamResult = GLClass("GameResult_TeamResult", GameHelper)

function TeamResult:ctor(GL, camp)
	self:Reset()

	self.GL = GL
	self.Camp = camp
end

function TeamResult:Reset()
	self.SumDamage = 0
	self.SumDamageTake = 0
	self.SumHeal = 0
	self.Camp = EnumFight.Camp.UNDEFINE
end

function TeamResult:DamageResult(source, unit, dmg)
	local val = dmg.finalMinusHp + dmg.finalMinusShield + dmg.finalRealMinusHp

	self.SumDamage = self.SumDamage + val
end

function TeamResult:TakeDamageResult(source, unit, dmg)
	self.SumDamageTake = self.SumDamageTake + dmg.finalMinusHp + dmg.finalMinusShield + dmg.finalRealMinusHp
end

function TeamResult:HealResult(unit, healer, val)
	self.SumHeal = self.SumHeal + val
end

GameResult = GLClass("GameResult", GameHelper)

function GameResult:ctor(GL)
	self.GL = GL

	self:Reset()

	self.GameGrade = GameGrade(self.GL)

	local sc = require("GameLogic/Fight.GameResult.GameResult_RoundResult")

	self.RoundResult = sc(self.GL)

	local unitinfosc = require("GameLogic/Fight.GameResult.GameResult_UnitInfo")

	self.UnitInfo = unitinfosc(self.GL)

	self:OnRegisterEvent()

	self.WhipAwardMaxCount = self.GL.GameStartData.whipMaxNum
end

function GameResult:Reset()
	self.UnitMap = {}
	self.TeamResult = {}
	self.GameGrade = nil
	self.WhipRewardCount = 0
end

function GameResult:Purge()
	self.GameGrade:Purge()
	self.RoundResult:Purge()
	self.UnitInfo:Purge()
	self:OnUnRegisterEvent()

	for k, v in pairs(self.UnitMap) do
		v:Purge()
	end

	self:Reset()
end

function GameResult:OnRegisterEvent()
	self.GL.GlobalEvent:Add("单位-创建", self.OnUnitCreate, self)
	self.GL.GlobalEvent:Add("统计单位-造成伤害", self.OnUnitDamage, self)
	self.GL.GlobalEvent:Add("单位-治疗目标", self.OnUnitHeal, self)
	self.GL.GlobalEvent:Add("技能-释放出手", self.OnCastSkill, self)
	self.GL.GlobalEvent:Add("鞭尸掉落", self.OnWhippedReward, self)
end

function GameResult:OnUnRegisterEvent()
	self.GL.GlobalEvent:Remove("单位-创建", self.OnUnitCreate, self)
	self.GL.GlobalEvent:Remove("统计单位-造成伤害", self.OnUnitDamage, self)
	self.GL.GlobalEvent:Remove("单位-治疗目标", self.OnUnitHeal, self)
	self.GL.GlobalEvent:Remove("技能-释放出手", self.OnCastSkill, self)
	self.GL.GlobalEvent:Remove("鞭尸掉落", self.OnWhippedReward, self)
end

function GameResult:GetWhipCount()
	return self.WhipAwardMaxCount
end

function GameResult:WhipSuccess()
	self.WhipAwardMaxCount = self.WhipAwardMaxCount - 1
end

function GameResult:OnWhippedReward(rewardId, uniqueId)
	self.WhipRewardCount = self.WhipRewardCount + 1
end

function GameResult:GetWhipRewardCount()
	return self.WhipRewardCount
end

function GameResult:OnUnitCreate(unit)
	self.UnitMap[unit.UniqueId] = UnitResult(self.GL, unit)

	if not self.TeamResult[unit.Camp] then
		self.TeamResult[unit.Camp] = TeamResult(self.GL, unit.Camp)
	end
end

function GameResult:OnUnitDamage(source, unit, dmg)
	local item = self.UnitMap[source.UniqueId]

	if item then
		item:DamageResult(source, unit, dmg)
	end

	local takeDmgitem = self.UnitMap[unit.UniqueId]

	if takeDmgitem then
		takeDmgitem:TakeDamageResult(source, unit, dmg)
	end

	item = self.TeamResult[source.Camp]

	if item then
		item:DamageResult(source, unit, dmg)
	end

	takeDmgitem = self.TeamResult[unit.Camp]

	if takeDmgitem then
		takeDmgitem:TakeDamageResult(source, unit, dmg)
	end
end

function GameResult:OnUnitHeal(unit, healer, val)
	local item = self.UnitMap[healer.UniqueId]

	if item then
		item:HealResult(unit, healer, val)
	end

	item = self.TeamResult[healer.Camp]

	if item then
		item:HealResult(unit, healer, val)
	end
end

function GameResult:OnCastSkill(skill)
	local item = self.UnitMap[skill.Owner.UniqueId]

	if item then
		item:SkillResult(skill)
	end
end

function GameResult:GetData()
	return {
		unitData = self.UnitMap,
		teamData = self.TeamResult,
		Grade = self.GameGrade:GetStarInfo()
	}
end

function GameResult:CheckInfo()
	local ret = 0
	local skillCfg = self.GL.GameBaseData.BattleSkillData
	local buffCfg = self.GL.GameBaseData.BattleBuffData
	local allCfg = self.GL.GameBaseData.AllSkills
	local list = {}

	for k, v in pairs(self.UnitMap) do
		table.insert(list, v)
	end

	table.sort(list, function(a, b)
		return tonumber(a.UniqueId) < tonumber(b.UniqueId)
	end)

	for i, item in ipairs(list) do
		ret = ret + item.SumDamage + item.SumDamageTake
	end

	return tostring(ret)
end

function GameResult:GetHpRate()
	local str = ""
	local playerHpRates, monsterHpRates = {}, {}
	local teams = self.GL.GameStartData.teams

	for campIdx, camp in ipairs(teams) do
		for waveIdx, wave in ipairs(camp) do
			for startDataIdx, startData in ipairs(wave) do
				local hpRate = 0
				local target = self.GL.UnitMgr:Selector():Camp(campIdx):Wave(waveIdx):Order(startDataIdx):Get()

				if target then
					local cur = target:Get("生命")
					local max = target:Get("最大生命")

					hpRate = target:Get("生命") / target:Get("最大生命")
				elseif self.GL.UnitMgr:IsRemoved(campIdx, waveIdx, startDataIdx) == true then
					hpRate = 0
				end

				if campIdx == EnumFight.Camp.PLAYER then
					table.insert(playerHpRates, hpRate)
				else
					table.insert(monsterHpRates, hpRate)
				end
			end
		end
	end

	return playerHpRates, monsterHpRates
end

function GameResult:GetBloodCost()
	if self.GL.GameStartData.pvp ~= EnumFight.Pvp.NONE then
		return {}
	end

	local stageId = self.GL.GameStartData.stageId
	local out = {}
	local teams = self.GL.GameStartData.teams
	local totalMaxHp = 0
	local order = 0

	for waveIdx, wave in ipairs(teams[2]) do
		for startDataIdx, startData in ipairs(wave) do
			order = order + 1

			local attri = AttributeUtil.GetMonsterAttri(order, stageId)
			local maxHp = attri.maxHp

			totalMaxHp = totalMaxHp + maxHp
		end
	end

	local dmgTake = self.TeamResult[2].SumDamageTake

	table.insert(out, math.ceil(dmgTake * 10000000 / totalMaxHp))
	table.insert(out, dmgTake)

	return out
end

function GameResult:GetBloodTeam()
	local out = {}
	local hpRates, _ = self:GetHpRate()

	for i, rate in ipairs(hpRates) do
		table.insert(out, math.ceil(rate * 100))
	end

	return out
end
