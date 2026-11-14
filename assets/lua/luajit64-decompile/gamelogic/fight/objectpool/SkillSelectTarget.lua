-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/ObjectPool/SkillSelectTarget.lua

local table = table
local table_insert = table.insert
local table_sort = table.sort
local math = math
local ipairs = ipairs
local api = {}

function api:SetSkill(Skill)
	self.Skill = Skill
	self.GL = Skill.GL
	self.Owner = Skill.Owner
end

function api:Purge()
	self.Skill = nil
	self.GL = nil
	self.Owner = nil
end

function api:LastTargets()
	if self.Skill.Targets == nil then
		return {}
	end

	local targets = {}

	for i, unit in ipairs(self.Skill.Targets) do
		if unit.IsDead == false then
			table.insert(targets, unit)
		end
	end

	return targets
end

function api:Self()
	return {
		self.Owner
	}
end

function api:Friend()
	return self.GL.UnitMgr:Selector():Camp(self.Owner.Camp):Alive():GetArray()
end

function api:RandomFriend()
	return {
		self.GL.UnitMgr:Selector():Camp(self.Owner.Camp):Alive():GetRandom()
	}
end

function api:OtherSide()
	return self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():GetArray()
end

function api:RandomOtherSide()
	local ret = self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():GetRandom()

	return {
		ret
	}
end

function api:SelectedOtherSide()
	local _target = {}

	if self.Owner.UnitClass == EnumFight.UnitClass.ENEMY then
		local ret = self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():GetRandom()

		_target = {
			ret
		}
	elseif self.Owner.UnitClass == EnumFight.UnitClass.PVPPLAYER then
		local ret = self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMin("生命"):Get()

		_target = {
			ret
		}
	else
		local ret = self.GL.RunTime.CurSelectTarget

		if ret then
			_target = {
				ret
			}
		end
	end

	return _target
end

function api:RandomOtherSide3()
	local _target = {}
	local randmonUnits = {}

	for i, unit in self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():Ipairs() do
		table.insert(randmonUnits, unit)
	end

	for i = 1, 3 do
		local j = GameLogic.RandomToolInt(#randmonUnits)
		local random = randmonUnits[j]

		table.remove(randmonUnits, j)
		table.insert(_target, random)
	end

	return _target
end

function api:RandomOtherSide2()
	local _target = {}
	local randmonUnits = {}

	for i, unit in self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():Ipairs() do
		table.insert(randmonUnits, unit)
	end

	for i = 1, 2 do
		local j = GameLogic.RandomToolInt(#randmonUnits)
		local random = randmonUnits[j]

		table.remove(randmonUnits, j)
		table.insert(_target, random)
	end

	return _target
end

function api:MinDefOtherSide()
	local _target = {}
	local minDefUnit
	local minDef = 9999

	for i, unit in self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():Ipairs() do
		if minDef > unit:Get("防御") then
			minDef = unit:Get("防御")
			minDefUnit = unit
		end
	end

	if minDefUnit then
		_target = {
			minDefUnit
		}
	end

	return _target
end

function api:MinHpFriend()
	return {
		self.GL.UnitMgr:Selector():Camp(self.Owner.Camp):Alive():SortMin("生命"):Get()
	}
end

function api:MinHpFriend2()
	return self.GL.UnitMgr:Selector():Camp(self.Owner.Camp):Alive():SortMin("生命"):GetArray(2)
end

function api:MinHpFriend3()
	return self.GL.UnitMgr:Selector():Camp(self.Owner.Camp):Alive():SortMin("生命"):GetArray(3)
end

function api:MinHpOtherSide()
	return {
		self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMin("生命"):Get()
	}
end

function api:MinArmorFriend()
	return {
		self.GL.UnitMgr:Selector():Camp(self.Owner.Camp):Alive():SortMin("防御"):Get()
	}
end

function api:MinArmorOtherSide()
	return {
		self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMin("防御"):Get()
	}
end

function api:MinMdefOtherSide()
	return {
		self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMin("魔抗"):Get()
	}
end

function api:MinMdefOtherSide2()
	return self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMin("魔抗"):GetArray(2)
end

function api:MinMdefOtherSide3()
	return self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMin("魔抗"):GetArray(3)
end

function api:MinPdefOtherSide()
	return {
		self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMin("物抗"):Get()
	}
end

function api:MinPdefOtherSide2()
	return self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMin("物抗"):GetArray(2)
end

function api:MinPdefOtherSide3()
	return self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMin("物抗"):GetArray(3)
end

function api:RandomFriend1()
	return {
		self.GL.UnitMgr:Selector():Camp(self.Owner.Camp):Alive():GetRandom()
	}
end

function api:RandomFriend2()
	return self.GL.UnitMgr:Selector():Camp(self.Owner.Camp):Alive():GetRandom(2)
end

function api:RandomFriend3()
	return self.GL.UnitMgr:Selector():Camp(self.Owner.Camp):Alive():GetRandom(3)
end

function api:SelfAndMinHpFriend()
	local unit = self.GL.UnitMgr:Selector():Camp(self.Owner.Camp):Alive():IsNotUniqueId(self.Owner.UniqieId):SortMin("生命"):Get()

	return {
		self.Owner,
		unit
	}
end

function api:SelectAndX(num)
	local select = self:SelectedOtherSide()[1]
	local units = self.GL.UnitMgr:Selector():Camp(select.Camp):Alive():IsNotUniqueId(select.UniqueId):GetRandom(num)
	local targets = {
		select
	}

	for i, unit in ipairs(units) do
		table.insert(targets, unit)
	end

	return targets
end

function api:SelectAnd1()
	return self:SelectAndX(1)
end

function api:SelectAnd2()
	return self:SelectAndX(2)
end

function api:SelectAnd3()
	return self:SelectAndX(3)
end

function api:SelectAnd4()
	return self:SelectAndX(4)
end

function api:_GetBuffOrRandoms(camp, total, typesOrTypeOrders)
	local targets = self.GL.UnitMgr:Selector():Camp(camp):Alive():HasBuff(typesOrTypeOrders):GetArray(total)
	local outs = targets

	if total - #targets > 0 then
		local randomUnits = self.GL.UnitMgr:Selector():Camp(camp):Alive():HasNotBuff(typesOrTypeOrders):GetRandom(total - #targets)

		for i, unit in ipairs(randomUnits) do
			table.insert(outs, unit)
		end
	end

	return outs
end

function api:DebuffOtherSide()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 1, {
		"Not_Action",
		"Dot_Buff",
		"Mark_Reduce_Attribute",
		"Mark_Buff"
	})
end

function api:DebuffOtherSide2()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 2, {
		"Not_Action",
		"Dot_Buff",
		"Mark_Reduce_Attribute",
		"Mark_Buff"
	})
end

function api:DebuffOtherSide3()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 3, {
		"Not_Action",
		"Dot_Buff",
		"Mark_Reduce_Attribute",
		"Mark_Buff"
	})
end

function api:DotRandomFriend()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 1, {
		"Dot_Buff",
		"Dot_Bleeding"
	})
end

function api:DotRandomFriend2()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 2, {
		"Dot_Buff",
		"Dot_Bleeding"
	})
end

function api:DotRandomFriend3()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 3, {
		"Dot_Buff",
		"Dot_Bleeding"
	})
end

function api:NotActRandomFriend()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 1, {
		"Not_Action",
		"Set_Not_Action"
	})
end

function api:NotActRandomFriend2()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 2, {
		"Not_Action",
		"Set_Not_Action"
	})
end

function api:NotActRandomFriend3()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 3, {
		"Not_Action",
		"Set_Not_Action"
	})
end

function api:PoisonFriend()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 1, {
		"poison"
	})
end

function api:PoisonFriend2()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 2, {
		"poison"
	})
end

function api:PoisonFriend3()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 3, {
		"poison"
	})
end

function api:PoisonOtherSide()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 1, {
		"poison"
	})
end

function api:PoisonOtherSide2()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 2, {
		"poison"
	})
end

function api:PoisonOtherSide3()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 3, {
		"poison"
	})
end

function api:FireFriend()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 1, {
		"fire"
	})
end

function api:FireFriend2()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 2, {
		"fire"
	})
end

function api:FireFriend3()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 3, {
		"fire"
	})
end

function api:FireOtherSide()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 1, {
		"fire"
	})
end

function api:FireOtherSide2()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 2, {
		"fire"
	})
end

function api:FireOtherSide3()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 3, {
		"fire"
	})
end

function api:BleedFriend()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 1, {
		"bleed"
	})
end

function api:BleedFriend2()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 2, {
		"bleed"
	})
end

function api:BleedFriend3()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 3, {
		"bleed"
	})
end

function api:BleedOtherSide()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 1, {
		"bleed"
	})
end

function api:BleedOtherSide2()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 2, {
		"bleed"
	})
end

function api:BleedOtherSide3()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 3, {
		"bleed"
	})
end

function api:EnchantmentFriend()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 1, {
		"enchantment"
	})
end

function api:EnchantmentFriend2()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 2, {
		"enchantment"
	})
end

function api:EnchantmentFriend3()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 3, {
		"enchantment"
	})
end

function api:EnchantmentOtherSide()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 1, {
		"enchantment"
	})
end

function api:EnchantmentOtherSide2()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 2, {
		"enchantment"
	})
end

function api:EnchantmentOtherSide3()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 3, {
		"enchantment"
	})
end

function api:FrozenFriend()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 1, {
		"frozen"
	})
end

function api:FrozenFriend2()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 2, {
		"frozen"
	})
end

function api:FrozenFriend3()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 3, {
		"frozen"
	})
end

function api:FrozenOtherSide()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 1, {
		"frozen"
	})
end

function api:FrozenOtherSide2()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 2, {
		"frozen"
	})
end

function api:FrozenOtherSide3()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 3, {
		"frozen"
	})
end

function api:StunFriend()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 1, {
		"stun"
	})
end

function api:StunFriend2()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 2, {
		"stun"
	})
end

function api:StunFriend3()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 3, {
		"stun"
	})
end

function api:StunOtherSide()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 1, {
		"stun"
	})
end

function api:StunOtherSide2()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 2, {
		"stun"
	})
end

function api:StunOtherSide3()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 3, {
		"stun"
	})
end

function api:SleepFriend()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 1, {
		"sleep"
	})
end

function api:SleepFriend2()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 2, {
		"sleep"
	})
end

function api:SleepFriend3()
	return self:_GetBuffOrRandoms(self.Owner.Camp, 3, {
		"sleep"
	})
end

function api:SleepOtherSide()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 1, {
		"sleep"
	})
end

function api:SleepOtherSide2()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 2, {
		"sleep"
	})
end

function api:SleepOtherSide3()
	local otherCamp = GameLogic.MAX_CAMP_COUNT - self.Owner.Camp + 1

	return self:_GetBuffOrRandoms(otherCamp, 3, {
		"sleep"
	})
end

function api:_alive()
	return self.GL.UnitMgr:Selector():Camp(self.Owner.Camp):Alive()
end

function api:_otheralive()
	return self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive()
end

function api:_GetJob(isSelfSide, total, job)
	local alive

	if isSelfSide == true then
		function alive()
			return self:_alive()
		end
	else
		function alive()
			return self:_otheralive()
		end
	end

	local targets = alive():add_filter(function(u)
		return u.BaseData.Job == job
	end):GetArray(total)
	local outs = targets

	if total - #targets > 0 then
		local randomUnits = alive():add_filter(function(u)
			return u.BaseData.Job ~= job
		end):GetRandom(total - #targets)

		for i, unit in ipairs(randomUnits) do
			table.insert(outs, unit)
		end
	end

	return outs
end

function api:StrengthOtherSide1()
	return self:_GetJob(false, 1, "Strength")
end

function api:StrengthOtherSide2()
	return self:_GetJob(false, 2, "Strength")
end

function api:StrengthOtherSide3()
	return self:_GetJob(false, 3, "Strength")
end

function api:ArtificeOtherSide1()
	return self:_GetJob(false, 1, "Artifice")
end

function api:ArtificeOtherSide2()
	return self:_GetJob(false, 2, "Artifice")
end

function api:ArtificeOtherSide3()
	return self:_GetJob(false, 3, "Artifice")
end

function api:SpeedOtherSide1()
	return self:_GetJob(false, 1, "Speed")
end

function api:SpeedOtherSide2()
	return self:_GetJob(false, 2, "Speed")
end

function api:SpeedOtherSide3()
	return self:_GetJob(false, 3, "Speed")
end

function api:IntelligenceOtherSide1()
	return self:_GetJob(false, 1, "Intelligence")
end

function api:IntelligenceOtherSide2()
	return self:_GetJob(false, 2, "Intelligence")
end

function api:IntelligenceOtherSide3()
	return self:_GetJob(false, 3, "Intelligence")
end

function api:AssistanceOtherSide1()
	return self:_GetJob(false, 1, "Assistance")
end

function api:AssistanceOtherSide2()
	return self:_GetJob(false, 2, "Assistance")
end

function api:AssistanceOtherSide3()
	return self:_GetJob(false, 3, "Assistance")
end

function api:MaxMagAttackOtherSide1()
	return {
		self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMax("魔法攻击"):Get()
	}
end

function api:MaxMagAttackOtherSide2()
	return self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMax("魔法攻击"):GetArray(2)
end

function api:MaxMagAttackOtherSide3()
	return self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMax("魔法攻击"):GetArray(3)
end

function api:MaxPhyAttackOtherSide1()
	return {
		self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMax("物理攻击"):Get()
	}
end

function api:MaxPhyAttackOtherSide2()
	return self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMax("物理攻击"):GetArray(2)
end

function api:MaxPhyAttackOtherSide3()
	return self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMax("物理攻击"):GetArray(3)
end

function api:MaxPhyMagAttackOtherSide1()
	return {
		self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMaxSum("物理攻击", "魔法攻击"):Get()
	}
end

function api:MaxPhyMagAttackOtherSide2()
	return self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMaxSum("物理攻击", "魔法攻击"):GetArray(2)
end

function api:MaxPhyMagAttackOtherSide3()
	return self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMaxSum("物理攻击", "魔法攻击"):GetArray(3)
end

function api:MaxPhyMagAttackFriend1()
	return {
		self.GL.UnitMgr:Selector():Camp(self.Owner.Camp):Alive():SortMaxSum("物理攻击", "魔法攻击"):Get()
	}
end

function api:MaxPhyMagAttackFriend2()
	return self.GL.UnitMgr:Selector():Camp(self.Owner.Camp):Alive():SortMaxSum("物理攻击", "魔法攻击"):GetArray(2)
end

function api:MaxPhyMagAttackFriend3()
	return self.GL.UnitMgr:Selector():Camp(self.Owner.Camp):Alive():SortMaxSum("物理攻击", "魔法攻击"):GetArray(3)
end

function api:MaxCurHpOtherSide1()
	return {
		self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMax("生命"):Get()
	}
end

function api:MaxCurHpOtherSide2()
	return self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMax("生命"):GetArray(2)
end

function api:MaxCurHpOtherSide3()
	return self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMax("生命"):GetArray(3)
end

function api:MaxDefOtherSide1()
	return {
		self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMax("防御"):Get()
	}
end

function api:MaxDefOtherSide2()
	return self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMax("防御"):GetArray(2)
end

function api:MaxDefOtherSide3()
	return self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():SortMax("防御"):GetArray(3)
end

SkillSelectTarget = GLClass("SkillSelectTarget")

function SkillSelectTarget:ctor()
	self.Units = {}
	self.Api = nil
end

function SkillSelectTarget:Purge()
	if self.Api then
		self.Api:Purge()
	end

	self.Units = {}
	self.Api = {}
end

function SkillSelectTarget:Get(Skill, affectType)
	self.Units = {}

	if self.Api then
		self.Api:Purge()
	end

	self.Api = api

	if self.Api[affectType] then
		self.Api:SetSkill(Skill)

		self.Units = self.Api[affectType](self.Api)
	end

	return self.Units
end
