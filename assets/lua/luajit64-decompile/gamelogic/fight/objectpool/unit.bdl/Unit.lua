-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/ObjectPool/Unit/Unit.lua

local UNIT_MODIFIABLE_ATTRIBUTES = {
	PLAYER = {
		"体能",
		"最大生命",
		"生命",
		"最大护盾",
		"物抗",
		"魔抗",
		"护盾",
		"抵御",
		"防御",
		"律能",
		"辉能",
		"射程",
		"暴击率",
		"暴击效果",
		"减伤",
		"增伤",
		"物理攻击",
		"魔法攻击",
		"暴击抵抗",
		"dot抵抗",
		"暴击减伤",
		"命中率",
		"闪避",
		"速度",
		"初始生命"
	},
	MONSTER = {
		"最大护盾",
		"护盾",
		"最大生命",
		"生命",
		"最大怒气",
		"怒气",
		"怒气阶段",
		"防御",
		"射程",
		"等待回合",
		"减伤",
		"增伤",
		"暴击抵抗",
		"初始等待回合",
		"物抗",
		"魔抗",
		"律能",
		"辉能",
		"暴击率",
		"暴击效果",
		"物理攻击",
		"魔法攻击",
		"dot抵抗",
		"暴击减伤",
		"命中率",
		"闪避",
		"速度",
		"初始生命"
	}
}

Unit = GLClass("Unit", GLCacheableObject)
Unit.print_enable = false

local print = function(...)
	if Unit.print_enable == true then
		print("<color=yellow>" .. ... .. "</color>")
	end
end

function Unit:ctor(GL)
	Unit.base.ctor(self, GL)
	self:Reset()
end

function Unit:Init(...)
	self.UniqueId = tostring(self.UID)
end

function Unit:Reset()
	self.NotAction = false
	self.DisableCardSkill = false
	self.UniqueId = ""
	self.UnitId = 0
	self.CardId = 0
	self.BaseData = {}
	self.UnitData = {}
	self.WeaponData = {}
	self.TeamIndex = -1
	self.UnitTitle = ""
	self.UnitClass = EnumFight.UnitClass.UNDEFINE
	self.Level = 1
	self.Order = 0
	self.Wave = 1
	self.Camp = EnumFight.Camp.UNDEFINE
	self.IsDead = false
	self.IsDelete = false
	self.IsMoving = false
	self.CastingSkill = nil
	self.NormalAttack = nil
	self.Event = nil
	self.AttributeMap = {}
	self.NextCastSkill = nil
	self.ActionSkillId = -1
	self.Skills = {}
	self.SkillMap = {}
	self.Buffs = {}
	self.BuffMap = {}
	self.BuffTypeOrderMap = {}
	self.Hp = 0
	self.Shield = 0
	self.Angry = 0
	self.LastAngryStage = 0
	self.LastSkillIdx = 0
	self.Mp = 0
	self.DisableCastSkill = true
	self.SkillMap = {}
	self.Skills = {}
	self.IsCenter = false
	self.DieReason = EnumFight.DieReson.Std
	self.IsSummon = false
end

function Unit:Purge()
	for i = #self.Buffs, 1, -1 do
		local buff = self.Buffs[i]

		buff:RemoveSelf()
	end

	for i, skill in ipairs(self.Skills) do
		skill:Remove()
	end

	self:Reset()
end

function Unit:RemoveAll()
	for i = #self.Buffs, 1, -1 do
		local buff = self.Buffs[i]

		buff:RemoveSelf()
	end

	for i = #self.Skills, 1, -1 do
		local skill = self.Skills[i]

		skill:Remove()
	end
end

function Unit:SetUnitData(unitData, baseData, camp, order, wave)
	self.Camp = camp
	self.CampOrder = unitData.campOrder
	self.Order = order
	self.Wave = wave
	self.BaseData = baseData
	self.UnitData = unitData
	self.Level = unitData.level
	self.UnitClass = unitData.unitClass

	if self.UnitClass == EnumFight.UnitClass.PLAYER then
		self.IsCenter = Tenary(unitData.isCenter, false)

		self:SetPlayerData(unitData)
	elseif self.UnitClass == EnumFight.UnitClass.PVPPLAYER then
		self.IsCenter = Tenary(unitData.isCenter, false)

		self:SetPlayerData(unitData)
	elseif self.UnitClass == EnumFight.UnitClass.ENEMY then
		self:SetEnemyData(unitData)
	end
end

function Unit:SetPlayerData(unitData)
	self.UnitId = self.BaseData.ID
	self.UnitTitle = GLLang(self.BaseData.Name)
	self.CardId = unitData.cardId

	for _, attriKey in ipairs(UNIT_MODIFIABLE_ATTRIBUTES.PLAYER) do
		self.AttributeMap[attriKey] = ModifyValue()
	end

	local function get(key)
		return self.AttributeMap[key]
	end

	get("体能").BaseValue = unitData.attributes.Stamina
	get("抵御").BaseValue = unitData.attributes.Defend
	get("律能").BaseValue = unitData.attributes.Song
	get("辉能").BaseValue = unitData.attributes.Will
	get("暴击率").BaseValue = unitData.attributes.Crit
	get("最大生命").BaseValue = get("体能").BaseValue * GLGetConfigArgFloat("HealthToHPRatio")

	if self.GL.GameStartData.pvp ~= EnumFight.Pvp.NONE then
		get("最大生命").BaseValue = get("最大生命").BaseValue * GLGetConfigArgFloat("PvPDefense")
	end

	get("最大生命").BaseValue = math.ceil(get("最大生命").BaseValue)
	get("生命").BaseValue = get("最大生命").BaseValue
	get("防御").BaseValue = get("抵御").BaseValue
	get("最大护盾").BaseValue = get("防御").BaseValue * GLGetConfigArgFloat("MaxShieldRatio")
	get("护盾").BaseValue = get("防御").BaseValue * GLGetConfigArgFloat("IniShieldRatio")
	get("物抗").BaseValue = 0
	get("魔抗").BaseValue = 0
	get("减伤").BaseValue = self.BaseData.ReduceInjuryRatio
	get("增伤").BaseValue = self.BaseData.AddDamageRatio
	get("暴击效果").BaseValue = unitData.attributes.Bruise
	get("物理攻击").BaseValue = get("律能").BaseValue * GLGetConfigArgFloat("WillToAttackRatio")
	get("魔法攻击").BaseValue = get("辉能").BaseValue * GLGetConfigArgFloat("SongToAttackRatio")
	get("暴击抵抗").BaseValue = unitData.attributes.CritResist
	get("dot抵抗").BaseValue = 0
	get("暴击减伤").BaseValue = unitData.attributes.BruiseDamage
	get("命中率").BaseValue = unitData.attributes.Hit
	get("闪避").BaseValue = unitData.attributes.Duck
	get("速度").BaseValue = unitData.attributes.Speed

	if unitData.hp then
		get("初始生命").BaseValue = unitData.hp
	else
		get("初始生命").BaseValue = math.ceil(unitData.hpRate * get("最大生命").BaseValue)
	end
end

function Unit:SetEnemyData()
	self.UnitId = self.BaseData.ID
	self.UnitTitle = GLLang(self.BaseData.Name)
	self.UnitClass = EnumFight.UnitClass.ENEMY

	for _, attriKey in ipairs(UNIT_MODIFIABLE_ATTRIBUTES.MONSTER) do
		self.AttributeMap[attriKey] = ModifyValue()
	end

	local function get(key)
		return self.AttributeMap[key]
	end

	get("防御").BaseValue = 0
	get("律能").BaseValue = 0
	get("辉能").BaseValue = 0
	get("初始等待回合").BaseValue = self.BaseData.BaseAttackRound
	get("等待回合").BaseValue = get("初始等待回合").BaseValue
	get("物抗").BaseValue = self.BaseData.AntiAttr[1]
	get("魔抗").BaseValue = self.BaseData.AntiAttr[2]
	get("减伤").BaseValue = self.BaseData.ReduceInjuryRatio
	get("增伤").BaseValue = self.BaseData.AddDamageRatio
	get("暴击率").BaseValue = self.BaseData.CriticalRatio
	get("暴击效果").BaseValue = self.BaseData.CriticalMul
	get("物理攻击").BaseValue = get("律能").BaseValue * GLGetConfigArgFloat("WillToAttackRatio")
	get("魔法攻击").BaseValue = get("辉能").BaseValue * GLGetConfigArgFloat("SongToAttackRatio")
	get("暴击抵抗").BaseValue = self.BaseData.AntiCritical
	get("dot抵抗").BaseValue = self.BaseData.AntiDotBleeding
	get("最大怒气").BaseValue = GLGetConfigArgInt("MaxAngry")
	get("怒气").BaseValue = self.BaseData.PrimaryAngry
	self.LastAngryStage = get("怒气阶段").BaseValue

	local StageOfAngry = self.BaseData.StageOfAngry
	local _stageLevel = 0

	for stage, angryRange in ipairs(StageOfAngry) do
		if angryRange <= get("怒气").BaseValue then
			_stageLevel = stage
		end
	end

	get("怒气阶段").BaseValue = _stageLevel

	local stageId = self.GL.GameStartData.stageId
	local attri

	if self.IsSummon == false then
		attri = AttributeUtil.GetMonsterAttri(self.CampOrder, stageId)
	else
		attri = AttributeUtil.GetMonsterAttri_(self.UnitId, self.Level)
	end

	get("防御").BaseValue = attri.def
	get("最大生命").BaseValue = attri.maxHp
	get("物理攻击").BaseValue = attri.phyAtk
	get("魔法攻击").BaseValue = attri.magAtk
	get("暴击减伤").BaseValue = 0
	get("命中率").BaseValue = 1
	get("闪避").BaseValue = 0
	get("初始生命").BaseValue = self.UnitData.hpRate * get("最大生命").BaseValue

	local _val = self.UnitData.attributes.最大生命

	if _val then
		get("最大生命").BaseValue = _val
	end

	_val = self.UnitData.attributes.初始生命

	if _val then
		get("初始生命").BaseValue = _val
	end
end

function Unit:InitAllAttribute()
	local hp = self:Get("初始生命")

	self.AttributeMap.生命.BaseValue = math.ceil(hp)

	if self.UnitClass == EnumFight.UnitClass.ENEMY then
		for _, attriKey in ipairs(UNIT_MODIFIABLE_ATTRIBUTES.MONSTER) do
			self:UpdateAttibute(attriKey)
		end

		self:SetNextActionSkillId()
	else
		for _, attriKey in ipairs(UNIT_MODIFIABLE_ATTRIBUTES.PLAYER) do
			self:UpdateAttibute(attriKey)
		end
	end
end

function Unit:ActionStart()
	return
end

function Unit:ActionEnd()
	return
end

function Unit:BuffRefreshRound()
	for i = #self.Buffs, 1, -1 do
		local buff = self.Buffs[i]

		buff:RefreshRound()
	end
end

function Unit:Get(attrName)
	if not self.AttributeMap[attrName] then
		self:ERROR(self.UnitTitle .. " not define attrName:" .. attrName)

		return 0
	end

	return self.AttributeMap[attrName]:GetValue()
end

function Unit:Set(attrName, val)
	if not self.AttributeMap[attrName] then
		self:ERROR(self.UnitTitle .. " not define attrName:" .. attrName)

		return
	end

	local lastVal = self.AttributeMap[attrName]:GetValue()

	self.AttributeMap[attrName]:SetValue(val)

	local addVal = self.AttributeMap[attrName]:GetValue() - lastVal

	self:UpdateAttibute(attrName, addVal)
end

function Unit:Resume(attrName)
	if not self.AttributeMap[attrName] then
		self:ERROR(self.UnitTitle .. " not define attrName:" .. attrName)

		return
	end

	local lastVal = self.AttributeMap[attrName]:GetValue()

	self.AttributeMap[attrName]:Resume()

	local addVal = self.AttributeMap[attrName]:GetValue() - lastVal

	self:UpdateAttibute(attrName, addVal)
end

function Unit:Add(attrName, val)
	local modifyValue = self.AttributeMap[attrName]

	if not modifyValue then
		self:ERROR(self.UnitTitle .. " UnitBase:Add ERROR attrName is not define,  attrName = " .. attrName)

		return
	end

	local lastVal = self.AttributeMap[attrName]:GetValue()

	modifyValue:Add(val)

	local addVal = self.AttributeMap[attrName]:GetValue() - lastVal

	self:UpdateAttibute(attrName, addVal)

	if attrName == "最大护盾" then
		self.GL.RunTime:GetTeamByCamp(self.Camp):Add(attrName, val)
	end
end

function Unit:AddMul(attrName, val)
	local modifyValue = self.AttributeMap[attrName]

	if not modifyValue then
		self:ERROR(self.UnitTitle .. " UnitBase:Add ERROR attrName is not define,  attrName = " .. attrName)

		return
	end

	local lastVal = self.AttributeMap[attrName]:GetValue()

	modifyValue:AddMul(val)

	local addVal = self.AttributeMap[attrName]:GetValue() - lastVal

	self:UpdateAttibute(attrName, addVal)

	if attrName == "最大生命" then
		local hp = self:Get("生命")

		if hp <= 0 then
			return
		elseif hp + addVal > self:Get("最大生命") then
			self:Set("生命", self:Get("最大生命"))
		elseif hp + addVal <= 0 then
			self:Set("生命", 1)
		else
			self:Set("生命", hp + addVal)
		end
	end

	if attrName == "最大护盾" then
		local team = self.GL.RunTime:GetTeamByCamp(self.Camp)

		lastVal = team:Get(attrName)

		team:AddMul(attrName, val)

		addVal = team:Get(attrName) - lastVal

		local hp = team:Get("护盾")

		if hp + addVal > team:Get("最大护盾") then
			team:Set("护盾", team:Get("最大护盾"))
		elseif hp + addVal <= 0 then
			team:Set("护盾", 0)
		else
			team:Set("护盾", hp + addVal)
		end
	end
end

function Unit:UpdateAttibute(attrName, addVal)
	self.GL:Fire("单位-更新属性", attrName, self, addVal)
end

function Unit:Fire(...)
	self.GL:Fire(...)
end

function Unit:On(eventId, fun, t)
	self.GL:On(eventId, fun, t)
end

function Unit:Off(eventId, fun, t)
	self.GL:Off(eventId, fun, t)
end

function Unit:HealHp(val, healer)
	local addHpData = {}

	addHpData.addVal = val

	self:Fire("单位-即将受到治疗", self, addHpData)

	if healer then
		self:Fire("单位-即将治疗目标", self, healer, addHpData)
	end

	local maxHp = self:Get("最大生命")
	local curHp = self:Get("生命")

	if addHpData.addVal > maxHp - curHp then
		addHpData.addVal = maxHp - curHp
	else
		addHpData.addVal = math.floor(addHpData.addVal)
	end

	if addHpData.addVal < 0 then
		addHpData.addVal = 0
	end

	self:Add("生命", addHpData.addVal)
	self:Fire("单位-受到治疗", self, addHpData.addVal)

	if healer then
		self:Fire("单位-治疗目标", self, healer, addHpData.addVal)
	end
end

function Unit:MinusHp(val)
	local hp = self:Get("生命") - val

	if hp <= 0 then
		hp = 0
	end

	self:Set("生命", hp)
end

function Unit:ForceMp(addVal)
	addVal = math.ceil(addVal)

	self.GL.RunTime:GetTeamByCamp(self.Camp):ForceMp(addVal)
	self:Fire("单位-回复魔力", self, addVal)
end

function Unit:AddShield(addVal)
	addVal = math.ceil(addVal)
	addVal = self.GL.RunTime:GetTeamByCamp(self.Camp):AddShield(addVal)

	self:Fire("单位-回复护盾", self, addVal)
end

function Unit:AddAngry(addVal)
	local max = self:Get("最大怒气")
	local cur = self:Get("怒气")

	if addVal > max - cur then
		addVal = max - cur
	end

	addVal = math.ceil(addVal)

	self:Add("怒气", addVal)

	if self:Get("怒气") < 0 then
		self:Set("怒气", 0)
	end

	self:Fire("单位-回复怒气", self, addVal)
end

function Unit:DealDamageDelay(dmg)
	self:DealDamage(dmg)
end

function Unit:DealDamage(dmg, isNeedDamage)
	if isNeedDamage then
		isNeedDamage.dmg = dmg:Copy()
	end

	if self.IsDead == true then
		print("鞭尸！")

		return
	end

	if not dmg or dmg.className ~= "Damage" then
		self:ERROR("<Call Unit.DealDamage> param dmg is unexpected value!!!")

		return false
	end

	local success = false

	if tostring(dmg.damage) == "nan" then
		self:ERROR("<Call Unit.DealDamage> dmg.damage is NaN!!! ")

		return false
	end

	local source = self.GL.UnitMgr:FindUnitById(dmg.srcUniqueId)

	if not source then
		self:ERROR("DealDamage ERROR , source not found dmg.srcUniqueId = " .. tostring(dmg.srcUniqueId))
	end

	dmg.target = self

	local source = self.GL.UnitMgr:FindUnitById(dmg.srcUniqueId)

	if source then
		source:Fire("单位-即将造成伤害", source, self, dmg)
	end

	self:Fire("单位-即将受到伤害", self, dmg)

	local lastHp = self:Get("生命")

	if dmg.dmgType == EnumFight.DamageType.Dot or dmg.dmgType == EnumFight.DamageType.DotBreak then
		if dmg.dot > 0 then
			local dotDmg = dmg.dot * (1 - self:Get("dot抵抗"))

			if dotDmg > 0 then
				local dotData = {}

				dotData.mul = 1
				dotData.dmgSource = dmg.dmgSource

				self:Fire("单位-即将受到dot伤害", source, self, dotData)

				dotDmg = dotDmg * dotData.mul
				dotDmg = math.ceil(dotDmg)
				dmg.finalMinusHp = dotDmg

				self:MinusHp(dotDmg)
			end
		end
	elseif dmg.dmgType == EnumFight.DamageType.Invalid then
		dmg.finalMinusHp = 0
		dmg.finalMinusShield = 0
	else
		self:StdDamage(dmg, source)
	end

	if dmg.finalMinusHp > 0 or dmg.finalMinusShield > 0 then
		if source then
			source:Fire("单位-造成伤害", source, self, dmg)
		end

		self:Fire("单位-受到伤害", self, dmg, lastHp)
	end

	if dmg.finalMinusHp > 0 or dmg.finalMinusShield > 0 then
		self:Fire("统计单位-受到伤害", self, dmg)

		if source then
			source:Fire("统计单位-造成伤害", source, self, dmg)
		end
	end

	if isNeedDamage then
		isNeedDamage.dmg = dmg:Copy()
	end

	self.GL.ObjectPool.Damage:Recycle(dmg)
end

function Unit:StdDamage(dmg, source)
	self:Fire("单位-即将闪避", self, dmg)

	if self.GL:Random() >= dmg.hitRate - self:Get("闪避") then
		dmg.finalMinusHp = 0
		dmg.finalMinusShield = 0

		self:Fire("单位-闪避", self, dmg)

		return
	end

	local armor = self:Get("防御")
	local phmagMins = 1 - self:Get("物抗")

	if phmagMins > 1 then
		phmagMins = 1
	end

	local magMins = 1 - self:Get("魔抗")

	if magMins > 1 then
		magMins = 1
	end

	local jobMul = JobCheckingHelp.GetMul(dmg.job, self.BaseData.Job)

	dmg.jobMul = jobMul

	local reduceInjuryRatio = 1 - self:Get("减伤")

	if reduceInjuryRatio < 0 then
		reduceInjuryRatio = 0
	end

	local addDamageRatio = 1 + source:Get("增伤")

	if addDamageRatio < 0 then
		addDamageRatio = 0
	end

	local damageTotal = dmg.damagePhy * phmagMins + dmg.damageMag * magMins
	local criticalMul = 1

	if damageTotal < 1 then
		damageTotal = 1
	end

	local criChance = dmg.criChance - self:Get("暴击抵抗")

	if criChance > self.GL:Random() then
		criticalMul = dmg.criMul
		criticalMul = math.max(criticalMul - self:Get("暴击减伤"), 1)
		dmg.isCritical = true
	else
		dmg.isCritical = false
	end

	local minusHp = math.max(damageTotal - armor * (1 - dmg.breakArmor), 1) * jobMul * criticalMul * reduceInjuryRatio * addDamageRatio

	minusHp = math.max(minusHp, 1)
	minusHp = minusHp * dmg.addAtkMul * (1 + dmg.pct) + dmg.finalVal
	dmg.finalMinusHp = minusHp

	self:Fire("单位-即将结算伤害", self, dmg)

	minusHp = dmg.finalMinusHp
	minusHp = math.ceil(minusHp)

	local shieldMul = 1

	if self.UnitClass == EnumFight.UnitClass.PLAYER or self.UnitClass == EnumFight.UnitClass.PVPPLAYER then
		local playerShield = self.GL.RunTime:GetTeamByCamp(self.Camp).Shield

		if playerShield <= 0 then
			shieldMul = GLGetConfigArgFloat("NoShieldMul")
			minusHp = minusHp * shieldMul
			minusHp = math.ceil(minusHp)
		end

		if dmg.IgnorShield == false then
			local breakShieldState = EnumFight.BreakShieldState.BREAKED
			local shieldRatio = GLGetConfigArgFloat("ShieldConsumeRatio")
			local shieldData = {}

			shieldData.shieldRatio = shieldRatio

			self:Fire("单位-即将产生护盾效果", self, shieldData)

			local minusShield = 0
			local targetMinusShield = minusHp * shieldData.shieldRatio

			if playerShield < targetMinusShield then
				minusShield = playerShield
			else
				minusShield = targetMinusShield
			end

			if minusShield > 0 then
				local _data = {}

				_data.minusShield = minusShield

				self:Fire("单位-即将扣除护盾", self, _data)

				minusShield = _data.minusShield
				minusShield = math.ceil(minusShield)
				dmg.finalMinusShield = minusShield

				self:AddShield(minusShield * -1, source)

				playerShield = self.GL.RunTime:GetTeamByCamp(self.Camp).Shield

				if playerShield <= 0 then
					breakShieldState = EnumFight.BreakShieldState.BREAKING
				else
					breakShieldState = EnumFight.BreakShieldState.DEFENSE
				end
			end

			minusHp = minusHp - minusShield
			dmg.breakShieldState = breakShieldState
		end

		self:MinusHp(minusHp)
	elseif self.UnitClass == EnumFight.UnitClass.ENEMY then
		local rcAngry = minusHp / self:Get("最大生命") * 100 * self.BaseData.AngryPerHP

		dmg.breakShieldState = EnumFight.BreakShieldState.BREAKED
		rcAngry = math.ceil(rcAngry)

		self:AddAngry(rcAngry, self)
		self:MinusHp(minusHp)
	end

	if minusHp > 0 then
		dmg.finalMinusHp = minusHp

		for i, buffId in ipairs(dmg.attachBuffIds) do
			self:AddBuff(buffId, source.UniqueId)
		end
	end

	local str1 = source.UnitTitle .. " 物攻：" .. dmg.damagePhy .. " 魔攻：" .. dmg.damageMag .. " ---> " .. self.UnitTitle .. " 抵御：" .. armor .. " 物抗" .. self:Get("物抗") .. " 魔抗" .. self:Get("魔抗")
	local str2 = " jobMul：" .. jobMul .. " criticalMul:" .. criticalMul .. " shieldMul:" .. shieldMul
	local str3 = " finalMinusHp:" .. dmg.finalMinusHp .. " finalMinusShield:" .. dmg.finalMinusShield

	print(str1 .. str2 .. str3)
end

function Unit:CheckAlive()
	if self:Get("生命") <= 0 then
		self:Fire("单位-即将死亡", self)
	end

	if self:Get("生命") <= 0 then
		self:Fire("单位-即将死亡2", self)
	end

	if self:Get("生命") <= 0 then
		self:Kill()
	end
end

function Unit:Kill()
	if self.IsDead == true then
		return
	end

	self.IsDead = true

	if self:Get("生命") > 0 then
		self:Set("生命", 0)
	end

	if self.IsDead == true then
		self:RemoveAllBuff()
	end

	if self:Get("初始生命") <= 0 then
		self:SetDieReason(EnumFight.DieReson.ZeroHpRate)
	end

	self:Fire("单位-死亡", self)
	self:SetNotAction(true)
end

function Unit:Reborn()
	if self.IsDead == false then
		return
	end

	self.IsDead = false

	self:SetDieReason(EnumFight.DieReson.Std)
	self:Fire("单位-复活", self)
	self:Set("生命", 1)
	self:SetNotAction(false)
end

function Unit:SetDieReason(val)
	self.DieReason = val
end

function Unit:SetNextActionSkillId()
	if self:SetNextActionSkillId_Order() == true then
		return
	end

	local _stageLevel = self:Get("怒气阶段")

	if self.ActionSkillId == -1 then
		local count_StageOfAngry = #self.BaseData.StageOfAngry
		local count_StageOfAngryBuff = #self.BaseData.StageOfAngryBuff
		local count_StageSkillId = #self.BaseData.StageSkillId
		local count_StageSkillIdWeight = #self.BaseData.StageSkillIdWeight
		local t = {
			count_StageOfAngry,
			count_StageOfAngryBuff,
			count_StageSkillId,
			count_StageSkillIdWeight
		}

		for i = 1, #t do
			for j = i + 1, #t do
				if t[i] ~= t[j] then
					self:ERROR("Monster表不对，检查StageOfAngry,StageOfAngryBuff,StageSkillId,StageSkillIdWeight  ID = " .. self.BaseData.ID)

					break
				end
			end
		end
	end

	if self.UnitData.Boss == 1 and _stageLevel > self.LastAngryStage then
		self.LastAngryStage = _stageLevel
		self.ActionSkillId = self.BaseData.StageSkillId[_stageLevel]

		if self.ActionSkillId == nil or self.ActionSkillId == 0 then
			self:ERROR("Monster表不对，检查StageSkillId  ID = " .. self.BaseData.ID .. " 怒气阶段：" .. _stageLevel)
		end

		self:Fire("单位-随机技能", self, self.ActionSkillId)

		return
	end

	local ids = {}
	local weights = {}

	for i = 1, _stageLevel do
		table.insert(ids, self.BaseData.StageSkillId[i])
		table.insert(weights, self.BaseData.StageSkillIdWeight[i])
	end

	self.ActionSkillId = WeightRandom(ids, weights)

	self:Fire("单位-随机技能", self, self.ActionSkillId)
end

function Unit:ResetLastSkillIdx()
	self.LastSkillIdx = 0
end

function Unit:SetNextActionSkillId_Order()
	local success = false

	if self.BaseData.AllowSkills == 0 then
		return success
	end

	local skills = self.BaseData.Skills

	if not skills or skills == 0 then
		return success
	end

	local _stageLevel = self:Get("怒气阶段")
	local curStageSkills = skills[_stageLevel]

	if not curStageSkills or curStageSkills == 0 then
		return success
	end

	if _stageLevel > self.LastAngryStage then
		self.LastAngryStage = _stageLevel

		self:ResetLastSkillIdx()
	end

	if self.LastSkillIdx >= #curStageSkills then
		self:ResetLastSkillIdx()
	end

	self.LastSkillIdx = self.LastSkillIdx + 1

	local _nextId = curStageSkills[self.LastSkillIdx]

	if _nextId and _nextId ~= 0 then
		self.ActionSkillId = _nextId
		success = true

		self:Fire("单位-随机技能", self, self.ActionSkillId)
	end

	return success
end

function Unit:EnemyAction()
	self:ActionStart()
	self:UpdateBuff()

	if self:Get("生命") <= 0 then
		return
	end

	if self:Get("等待回合") > 1 then
		return
	end

	if self.NotAction == false then
		self:EnemyAngryBuff()
	end
end

function Unit:EnemyActionEnd()
	self:ActionEnd()
end

function Unit:EnemyCastActionSkill()
	if self:Get("生命") <= 0 then
		return
	end

	if self:Get("等待回合") > 1 then
		return
	end

	if self.NotAction == false then
		self:CastSkill(self.ActionSkillId)
	end
end

function Unit:EnemyAngryBuff()
	local angry = self:Get("怒气")
	local maxAngry = self:Get("最大怒气")
	local StageOfAngry = self.BaseData.StageOfAngry
	local _stageLevel = 0

	for stage, angryRange in ipairs(StageOfAngry) do
		if angryRange <= angry then
			_stageLevel = stage
		end
	end

	if _stageLevel > self:Get("怒气阶段") then
		self:Set("怒气阶段", _stageLevel)

		local skillId

		if self.BaseData.StageOfAngryBuff then
			skillId = self.BaseData.StageOfAngryBuff[_stageLevel]
		end

		if skillId and skillId ~= 0 then
			self:Fire("单位-怒气buff", self, skillId)
			self:CastSkill(skillId)
		end
	end
end

function Unit:MoveToTarget(target)
	self.GL:Fire("单位-移动", self, target)
end

function Unit:AddSkill(skillId, level)
	local allSkillData = self.GL.GameBaseData.AllSkills[skillId]

	if not allSkillData then
		self:ERROR(skillId .. " 没有AllSkillData")

		return nil
	end

	if type(allSkillData.BattleSkillID) ~= "table" then
		self:ERROR(skillId .. " BattleSkillID 必须是列表")

		return nil
	end

	level = level or 1

	local battleSkillId = allSkillData.BattleSkillID[level]

	if not battleSkillId then
		self:ERROR(skillId .. " AllSkillData -> BattleSkillID 没有想相应的等级，尝试用1级替换，Lv:" .. level)

		battleSkillId = allSkillData.BattleSkillID[1]
	end

	if not battleSkillId then
		self:ERROR(skillId .. " AllSkillData -> BattleSkillID ERROR ，Lv:" .. level)
	end

	local battleSkillData = self.GL.GameBaseData.BattleSkillData[battleSkillId]

	if not battleSkillData then
		self:ERROR(battleSkillId .. " 没有配置战斗技能表")

		return nil
	end

	local skill = self.SkillMap[battleSkillId]

	if skill then
		return skill
	else
		skill = self.GL.ObjectPool.Skill:Create()

		skill:SetSkillData(self, level, allSkillData, battleSkillData)
		skill:Add()
		table.insert(self.Skills, skill)

		self.SkillMap[battleSkillId] = skill
	end

	return skill
end

function Unit:SetSkills()
	for i, skillInfo in ipairs(self.UnitData.skills) do
		self:AddSkill(skillInfo[1], skillInfo[2])
	end
end

function Unit:CastPassiveSkill()
	for i, skill in ipairs(self.Skills) do
		if skill.Type == EnumFight.SkillType.Link then
			self:LOG(self.UnitTitle .. " 释放羁绊技能 " .. skill.SkillId .. " " .. skill.ShowName)
			self:CastSkill(skill.SkillId)
		end

		if skill.Type == EnumFight.SkillType.Union then
			self:LOG(self.UnitTitle .. " 释放公会技能 " .. skill.SkillId .. " " .. skill.ShowName)
			self:CastSkill(skill.SkillId)
		end

		if skill.Type == EnumFight.SkillType.Passive then
			self:LOG(self.UnitTitle .. " 释放被动技能 " .. skill.SkillId .. " " .. skill.ShowName)
			self:CastSkill(skill.SkillId)
		end

		if self.IsCenter == true and skill.Type == EnumFight.SkillType.Center then
			self:LOG(self.UnitTitle .. " 释放C位被动技能 " .. skill.SkillId .. " " .. skill.ShowName)
			self:CastSkill(skill.SkillId)
		end
	end
end

function Unit:CastAppearSkill()
	if self.UnitClass == EnumFight.UnitClass.PVPPLAYER then
		self:CastPassiveSkill()

		return
	end

	if not self.BaseData.AppearSkills then
		return
	end

	for i, skillId in ipairs(self.BaseData.AppearSkills) do
		print(self.UnitTitle .. " 释放登场被动技能 " .. skillId)
		self:CastSkill(skillId)
	end
end

function Unit:CastCard(skillId)
	local skill = self.SkillMap[skillId]

	if skill then
		skill:CastCard()
	end
end

function Unit:GetSkill(skillId)
	return self.SkillMap[skillId]
end

function Unit:CastSkill(skillId)
	if self.IsDead == true then
		return
	end

	local skill = self.SkillMap[skillId]

	if skill then
		skill:Cast()
	else
		self:ERROR(self.UnitTitle .. " 释放了一个不属于自己的技能 可能是没有加载特效的  skillId：" .. skillId)

		local battleSkillData = self.GL.GameBaseData.BattleSkillData[skillId]

		if not battleSkillData then
			self:ERROR(skillId .. " 没有配置战斗技能表")

			return nil
		end

		local skill = self.GL.ObjectPool.Skill:Create()

		skill:SetSkillData(self, 1, nil, battleSkillData)
		skill:Cast()
	end
end

function Unit:RemoveAllBuff()
	for i = #self.Buffs, 1, -1 do
		local buff = self.Buffs[i]

		if buff.IsAlive == 0 then
			buff:RemoveSelf()
		end
	end
end

function Unit:AddBuff(buffId, sourceUniqueId, skillPower)
	local success = false

	if self.IsDead == true then
		return success
	end

	local battleBuffData = self.GL.GameBaseData.BattleBuffData[buffId]

	if not battleBuffData then
		self:ERROR(buffId .. " 没有配置buff表")

		return success
	end

	local buff = self.GL.ObjectPool.Buff:Create()

	buff:SetBuffData(self, buffId, battleBuffData)
	buff:SetSkillPower(skillPower)

	if sourceUniqueId then
		buff:SetSource(sourceUniqueId)
	end

	self:Fire("单位-即将添加buff", self, buff)

	if buff.IsMiss == true then
		self:Fire("单位-添加buff失败", self, EnumFight.BuffMissReason.Ignore)

		return success
	end

	local typeOrder = battleBuffData.TypeOrder
	local maxStack = battleBuffData.MaxStack

	if maxStack and maxStack > 0 then
		local _buff = self:HasBuffTypeOrder(typeOrder)

		if _buff then
			local recoverVal = _buff:Recover()

			if not recoverVal then
				self:Fire("单位-添加buff失败", self, EnumFight.BuffMissReason.Useless)
			end

			return recoverVal
		else
			return self:AddBuffOnSelf(buff)
		end
	end

	if typeOrder and typeOrder ~= "" then
		local ownBuff = self.BuffTypeOrderMap[typeOrder]

		if ownBuff then
			if ownBuff.Value < battleBuffData.Value then
				ownBuff:RemoveSelf()
			elseif ownBuff.Value == battleBuffData.Value then
				if ownBuff.Round <= battleBuffData.Round then
					ownBuff:RemoveSelf()
				else
					self:Fire("单位-添加buff失败", self, EnumFight.BuffMissReason.Useless)

					return success
				end
			else
				self:Fire("单位-添加buff失败", self, EnumFight.BuffMissReason.Useless)

				return success
			end
		end

		local missConfig = GLGetConfigArgJson("BuffRule2")

		if missConfig[typeOrder] then
			for _orderIdx, _order in ipairs(missConfig[typeOrder]) do
				if self.BuffTypeOrderMap[_order] then
					self:Fire("单位-添加buff失败", self, EnumFight.BuffMissReason.Useless)

					return success
				end
			end
		end
	end

	if battleBuffData.Uniquely == 1 then
		for i = #self.Buffs, 1, -1 do
			local _buff = self.Buffs[i]

			if _buff.IsUniquely == 1 then
				_buff:RemoveSelf()
			end
		end
	end

	local typeOrder = battleBuffData.TypeOrder

	if typeOrder and typeOrder ~= "" then
		local replaceConfig = GLGetConfigArgJson("BuffRule1")

		if replaceConfig[typeOrder] then
			for _orderIdx, _order in ipairs(replaceConfig[typeOrder]) do
				local replaceBuff = self.BuffTypeOrderMap[_order]

				if replaceBuff then
					replaceBuff:RemoveSelf()
				end
			end
		end
	end

	return self:AddBuffOnSelf(buff)
end

function Unit:AddBuffOnSelf(buff)
	local success = false

	success = buff:Add()

	if success == true then
		table.insert(self.Buffs, buff)

		self.BuffMap[tostring(buff.UID)] = buff

		if buff.TypeOrder ~= "" then
			self.BuffTypeOrderMap[buff.TypeOrder] = buff
		end
	else
		self:Fire("单位-添加buff失败", self, EnumFight.BuffMissReason.Useless)
	end

	return success
end

function Unit:HasBuffType(_type)
	local ownBuff

	for i, buff in ipairs(self.Buffs) do
		if buff.Type == _type then
			ownBuff = buff

			break
		end
	end

	return ownBuff
end

function Unit:HasBuff(buffId)
	local ownBuff

	for i, buff in ipairs(self.Buffs) do
		if buff.BuffId == buffId then
			ownBuff = buff

			break
		end
	end

	return ownBuff
end

function Unit:HasBuffTypeOrder(typeOrder)
	return self.BuffTypeOrderMap[typeOrder]
end

function Unit:UpdateBuff()
	table.sort(self.Buffs, function(a, b)
		return a.Priority < b.Priority
	end)

	for i = #self.Buffs, 1, -1 do
		local buff = self.Buffs[i]

		if buff then
			buff:Update()
		end
	end
end

function Unit:RemoveBuff(buff)
	if buff then
		self.BuffMap[tostring(buff.UID)] = nil
		self.BuffTypeOrderMap[buff.TypeOrder] = nil

		buff:Remove()
	end

	for i, _ownBuff in ipairs(self.Buffs) do
		if _ownBuff.UID == buff.UID then
			table.remove(self.Buffs, i)

			break
		end
	end
end

function Unit:SetNotAction(val)
	self.NotAction = val

	self.GL:Fire("单位-无法行动", self, val)
end

function Unit:SetDisableCardSkill(val)
	self.DisableCardSkill = val

	self.GL:Fire("单位-封印卡牌技能", self, val)
end
