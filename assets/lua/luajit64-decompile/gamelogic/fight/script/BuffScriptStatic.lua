-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/Script/BuffScriptStatic.lua

local function _sleep_Action_before_dmg(Buff, Unit, dmg)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	dmg.criChance = 1000000
end

local function _sleep_Action_after_dmg(Buff, Unit, dmg)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	Buff:RemoveSelf()
end

BuffScript.Not_Action = {}

function BuffScript.Not_Action.OnAdd(Buff)
	Buff.Owner:SetNotAction(true)

	if Buff.TypeOrder == "sleep" then
		Buff.Owner:On("单位-即将受到伤害", _sleep_Action_before_dmg, Buff)
		Buff.Owner:On("单位-受到伤害", _sleep_Action_after_dmg, Buff)
	end
end

function BuffScript.Not_Action.OnRemove(Buff)
	Buff.Owner:SetNotAction(false)

	if Buff.TypeOrder == "sleep" then
		Buff.Owner:Off("单位-即将受到伤害", _sleep_Action_before_dmg, Buff)
		Buff.Owner:Off("单位-受到伤害", _sleep_Action_after_dmg, Buff)
	end
end

BuffScript.Not_Action_2 = {}

function BuffScript.Not_Action_2.OnAdd(Buff)
	Buff.Owner:SetNotAction(true)
end

function BuffScript.Not_Action_2.OnRemove(Buff)
	Buff.Owner:SetNotAction(false)
end

local function _Mark_Buff(Buff)
	if Buff.TypeOrder == "Mark_Buff_Frozen" then
		if Buff.Owner:HasBuffTypeOrder("frozen") ~= nil then
			return false
		end
	elseif Buff.TypeOrder == "Mark_Buff_Stun" then
		if Buff.Owner:HasBuffTypeOrder("stun") ~= nil then
			return false
		end
	elseif Buff.TypeOrder == "Mark_Buff_Enchantment" then
		if Buff.Owner:HasBuffTypeOrder("enchantment") ~= nil then
			return false
		end
	elseif Buff.TypeOrder == "Mark_Buff_Sleep" and Buff.Owner:HasBuffTypeOrder("sleep") ~= nil then
		return false
	end

	Buff.Round = Buff.CfgRound

	Buff:AddStack(1)

	if Buff.Stack >= Buff.MaxStack then
		local buffId = Buff.Value
		local sourceId = Buff.SourceUniqueId

		Buff:RemoveSelf()

		local unit = Buff.Owner
		local data = {}

		data.pr = Buff.GL:Random()

		local source = Buff.GL.UnitMgr:FindUnitById(Buff.SourceUniqueId)

		Buff.GL:Fire("单位-即将随机buff", source, unit, data)
		Buff.GL:Fire("单位-即将被随机buff", source, unit, data)

		if data.pr <= 1 then
			unit:AddBuff(buffId, sourceId, nil)

			return true
		else
			Buff.Owner:Fire("单位-Buff自定义消息", unit, Buff, "BuffInvalid")
		end
	end

	return true
end

BuffScript.Mark_Buff = {}

function BuffScript.Mark_Buff.OnAdd(Buff)
	return _Mark_Buff(Buff)
end

function BuffScript.Mark_Buff.OnRecover(Buff)
	return _Mark_Buff(Buff)
end

function BuffScript.Mark_Buff.OnRemove(Buff)
	return
end

local function _Dot_Buff(Buff)
	if Buff.Stack >= Buff.MaxStack then
		return
	end

	Buff.Round = Buff.CfgRound

	Buff:AddStack(1)
end

local function _Reduce_Heal_Bleeding(Buff, Unit, addHpData)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	local pct = (10 - Buff.Stack) * 0.1

	if pct < 0 then
		pct = 0
	end

	addHpData.addVal = addHpData.addVal * pct
end

BuffScript.Dot_Buff = {}

function BuffScript.Dot_Buff.OnAdd(Buff)
	_Dot_Buff(Buff)

	if Buff.TypeOrder == "bleed" then
		Buff.Owner:On("单位-即将受到治疗", _Reduce_Heal_Bleeding, Buff)
	end
end

function BuffScript.Dot_Buff.OnRecover(Buff)
	_Dot_Buff(Buff)
end

function BuffScript.Dot_Buff.OnRemove(Buff)
	if Buff.TypeOrder == "bleed" then
		Buff.Owner:Off("单位-即将受到治疗", _Reduce_Heal_Bleeding, Buff)
	end
end

function BuffScript.Dot_Buff.OnUpdate(Buff)
	local maxHp = Buff.Owner:Get("最大生命")
	local percentHp = Buff.Value * Buff.Stack
	local dmgHp = maxHp * percentHp
	local source = Buff.GL.UnitMgr:FindUnitById(Buff.SourceUniqueId)
	local dmg = source:CreateDamage()

	dmg.dmgType = EnumFight.DamageType.Dot
	dmg.dot = dmgHp
	dmg.dmgSource = Buff

	Buff.Owner:DealDamage(dmg)

	local heal = Buff:GetCustomByPropName("Heal")

	if heal then
		local healVal = dmgHp * heal
		local limitHeal = Buff:GetCustomByPropName("LimitHeal")

		if limitHeal then
			limitHeal = limitHeal * source:Get("最大生命")

			if limitHeal < healVal then
				healVal = limitHeal
			end
		end

		source:HealHp(healVal, source)
	end

	if Buff.Owner:Get("生命") <= 0 then
		local spreadTarget = Buff:GetCustomByPropName("SpreadTarget")

		if spreadTarget == "BothSides" then
			local u1 = Buff.GL.UnitMgr:Selector():Camp(Buff.Owner.Camp):NotZeroHp():Order(Buff.Owner.Order - 1):Get()

			if u1 then
				u1:AddBuff(Buff.BuffId, Buff.SourceUniqueId)
			end

			local u2 = Buff.GL.UnitMgr:Selector():Camp(Buff.Owner.Camp):NotZeroHp():Order(Buff.Owner.Order + 1):Get()

			if u2 then
				u2:AddBuff(Buff.BuffId, Buff.SourceUniqueId)
			end
		elseif spreadTarget == "All" then
			for i, unit in Buff.GL.UnitMgr:Selector():Camp(Buff.Owner.Camp):NotZeroHp():Ipairs() do
				unit:AddBuff(Buff.BuffId, Buff.SourceUniqueId)
			end
		end
	end

	if Buff.Round == 1 then
		Buff:RemoveSelf()
	end
end

local function _Hot_Buff(Buff)
	if Buff.Stack >= Buff.MaxStack then
		return
	end

	Buff.Round = Buff.CfgRound

	Buff:AddStack(1)
end

BuffScript.Hot_Buff = {}

function BuffScript.Hot_Buff.OnAdd(Buff)
	_Hot_Buff(Buff)
end

function BuffScript.Hot_Buff.OnRecover(Buff)
	_Hot_Buff(Buff)
end

function BuffScript.Hot_Buff.OnRemove(Buff)
	return
end

function BuffScript.Hot_Buff.OnUpdate(Buff)
	local maxHp = Buff.Owner:Get("最大生命")
	local percentHp = Buff.Value * Buff.Stack
	local addVal = maxHp * percentHp
	local source = Buff.GL.UnitMgr:FindUnitById(Buff.SourceUniqueId)

	Buff.Owner:HealHp(addVal, source)

	if Buff.Round == 1 then
		Buff:RemoveSelf()
	end
end

local function _Hot_Mp_Buff(Buff)
	if Buff.Stack >= Buff.MaxStack then
		return
	end

	Buff.Round = Buff.CfgRound

	Buff:AddStack(1)
end

BuffScript.Hot_Mp_Buff = {}

function BuffScript.Hot_Mp_Buff.OnAdd(Buff)
	_Hot_Mp_Buff(Buff)
end

function BuffScript.Hot_Mp_Buff.OnRecover(Buff)
	_Hot_Mp_Buff(Buff)
end

function BuffScript.Hot_Mp_Buff.OnRemove(Buff)
	return
end

function BuffScript.Hot_Mp_Buff.OnUpdate(Buff)
	local addVal = Buff.Value * Buff.Stack

	Buff.Owner:ForceMp(addVal)

	if Buff.Round == 1 then
		Buff:RemoveSelf()
	end
end

BuffScript.Hot_Mp_Reduce_Buff = {}

function BuffScript.Hot_Mp_Reduce_Buff.OnAdd(Buff)
	_Hot_Mp_Buff(Buff)
end

function BuffScript.Hot_Mp_Reduce_Buff.OnRecover(Buff)
	_Hot_Mp_Buff(Buff)
end

function BuffScript.Hot_Mp_Reduce_Buff.OnRemove(Buff)
	return
end

function BuffScript.Hot_Mp_Reduce_Buff.OnUpdate(Buff)
	local addVal = Buff.Value

	Buff.Owner:ForceMp(addVal * -1)

	if Buff.Round == 1 then
		Buff:RemoveSelf()
	end
end

local function _Hot_Shield_Buff(Buff)
	if Buff.Stack >= Buff.MaxStack then
		return
	end

	Buff.Round = Buff.CfgRound

	Buff:AddStack(1)
end

BuffScript.Hot_Shield_Buff = {}

function BuffScript.Hot_Shield_Buff.OnAdd(Buff)
	_Hot_Shield_Buff(Buff)
end

function BuffScript.Hot_Shield_Buff.OnRecover(Buff)
	_Hot_Shield_Buff(Buff)
end

function BuffScript.Hot_Shield_Buff.OnRemove(Buff)
	return
end

function BuffScript.Hot_Shield_Buff.OnUpdate(Buff)
	local addVal = Buff.Value * Buff.Stack

	Buff.Owner:AddShield(addVal)

	if Buff.Round == 1 then
		Buff:RemoveSelf()
	end
end

local function _Mark_Reduce_Attribute(Buff)
	if Buff.Stack >= Buff.MaxStack then
		return
	end

	Buff.Round = Buff.CfgRound

	Buff:AddStack(1)

	local attri = Buff:GetCustomByPropName("Attri")
	local valueType = Buff:GetCustomByPropName("ValueType")

	if valueType == "Val" then
		Buff.Owner:Add(attri, Buff.Value * -1)
	else
		Buff.Owner:AddMul(attri, Buff.Value * -1)
	end
end

BuffScript.Mark_Reduce_Attribute = {}

function BuffScript.Mark_Reduce_Attribute.OnAdd(Buff)
	return _Mark_Reduce_Attribute(Buff)
end

function BuffScript.Mark_Reduce_Attribute.OnRecover(Buff)
	return _Mark_Reduce_Attribute(Buff)
end

function BuffScript.Mark_Reduce_Attribute.OnRemove(Buff)
	local attri = Buff:GetCustomByPropName("Attri")
	local valueType = Buff:GetCustomByPropName("ValueType")

	if valueType == "Val" then
		Buff.Owner:Add(attri, Buff.Value * Buff.Stack)
	else
		Buff.Owner:AddMul(attri, Buff.Value * Buff.Stack)
	end
end

local function _Mark_Add_Attribute(Buff)
	if Buff.Stack >= Buff.MaxStack then
		return
	end

	Buff.Round = Buff.CfgRound

	Buff:AddStack(1)

	local attri = Buff:GetCustomByPropName("Attri")
	local valueType = Buff:GetCustomByPropName("ValueType")

	if valueType == "Val" then
		Buff.Owner:Add(attri, Buff.Value)
	else
		Buff.Owner:AddMul(attri, Buff.Value)
	end
end

BuffScript.Mark_Add_Attribute = {}

function BuffScript.Mark_Add_Attribute.OnAdd(Buff)
	return _Mark_Add_Attribute(Buff)
end

function BuffScript.Mark_Add_Attribute.OnRecover(Buff)
	return _Mark_Add_Attribute(Buff)
end

function BuffScript.Mark_Add_Attribute.OnRemove(Buff)
	local attri = Buff:GetCustomByPropName("Attri")
	local valueType = Buff:GetCustomByPropName("ValueType")

	if valueType == "Val" then
		Buff.Owner:Add(attri, Buff.Value * Buff.Stack * -1)
	else
		Buff.Owner:AddMul(attri, Buff.Value * Buff.Stack * -1)
	end
end

local function _Mark_Avenger(Buff)
	if Buff.Stack >= Buff.MaxStack then
		return
	end

	Buff.Round = Buff.CfgRound

	Buff:AddStack(1)
end

BuffScript.Mark_Avenge = {}

function BuffScript.Mark_Avenge.OnAdd(Buff)
	return _Mark_Avenger(Buff)
end

function BuffScript.Mark_Avenge.OnRecover(Buff)
	return _Mark_Avenger(Buff)
end

function BuffScript.Mark_Avenge.OnRemove(Buff)
	return
end

local function _Add_Stack(Buff, Unit, AddBuff, data)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	for i, typeOrder in ipairs(Buff:GetCustomByPropName("TypeOrders")) do
		if AddBuff.TypeOrder == typeOrder then
			data.val = data.val + Buff.Value

			break
		end
	end
end

BuffScript.Add_Stack = {}

function BuffScript.Add_Stack.OnAdd(Buff)
	Buff.Owner:On("单位-即将buff叠层数", _Add_Stack, Buff)
end

function BuffScript.Add_Stack.OnRemove(Buff)
	return
end

local function _percentSuccess(Buff)
	local success = false
	local cfgPr = Buff:GetCustomByPropName("Percent")

	if cfgPr then
		if cfgPr * 100 >= RandomUtil.Get(100) then
			success = true
		end
	else
		success = true
	end

	return success
end

local function _sessionTypesPercentSuccess(Buff, sessionType)
	local sessionVaild, success = false, false

	for i, _type in ipairs(Buff:GetCustomByPropName("SessionTypes")) do
		if sessionType == _type then
			sessionVaild = true

			break
		end
	end

	if sessionVaild == false then
		return false
	end

	success = _percentSuccess(Buff)

	return success
end

local function _ForceMp_Attack(Buff, Unit, SessionType)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if _sessionTypesPercentSuccess(Buff, SessionType) == true then
		Buff.Owner:ForceMp(Buff.Value)
	end
end

BuffScript.ForceMp_Attack = {}

function BuffScript.ForceMp_Attack.OnAdd(Buff)
	Buff.Owner:On("Session-球发动", _ForceMp_Attack, Buff)
end

function BuffScript.ForceMp_Attack.OnRemove(Buff)
	Buff.Owner:Off("Session-球发动", _ForceMp_Attack, Buff)
end

local function _ForceMp_Damage(Buff, Attacker, Suffer, dmg)
	if Attacker.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if _sessionTypesPercentSuccess(Buff, dmg.sourceSession) == true then
		Buff.Owner:ForceMp(Buff.Value)
	end
end

BuffScript.ForceMp_Damage = {}

function BuffScript.ForceMp_Damage.OnAdd(Buff)
	Buff.Owner:On("单位-造成伤害", _ForceMp_Damage, Buff)
end

function BuffScript.ForceMp_Damage.OnRemove(Buff)
	Buff.Owner:Off("单位-造成伤害", _ForceMp_Damage, Buff)
end

local function _ForceMp_Damage_Buff(Buff, Attacker, Suffer, dmg)
	if Attacker.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if dmg.sourceSession == EnumFight.SessionType.none then
		return
	end

	if dmg.mut ~= 1 then
		return
	end

	local a = Buff:GetCustomByPropName("TypeOrders")

	printTable({
		"TypeOrders is nil",
		a
	})

	if a ~= nil then
		for i, typeOrder in ipairs(a) do
			if Suffer:HasBuffTypeOrder(typeOrder) then
				Attacker:ForceMp(Buff.Value)
			end
		end
	end
end

BuffScript.ForceMp_Damage_Buff = {}

function BuffScript.ForceMp_Damage_Buff.OnAdd(Buff)
	Buff.Owner:On("单位-造成伤害", _ForceMp_Damage_Buff, Buff)
end

function BuffScript.ForceMp_Damage_Buff.OnRemove(Buff)
	Buff.Owner:Off("单位-造成伤害", _ForceMp_Damage_Buff, Buff)
end

local function _ForceMp_Criting(Buff, Attacker, Suffer, dmg)
	if Attacker.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if dmg.isCritical == false then
		return
	end

	if _sessionTypesPercentSuccess(Buff, dmg.sourceSession) == true then
		Buff.Owner:ForceMp(Buff.Value)
	end
end

BuffScript.ForceMp_Criting = {}

function BuffScript.ForceMp_Criting.OnAdd(Buff)
	Buff.Owner:On("单位-造成伤害", _ForceMp_Criting, Buff)
end

function BuffScript.ForceMp_Criting.OnRemove(Buff)
	Buff.Owner:Off("单位-造成伤害", _ForceMp_Criting, Buff)
end

local function _ForceMp_TakeDmg(Buff, Unit, dmg)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if _percentSuccess(Buff) == true then
		Buff.Owner:ForceMp(Buff.Value)
	end
end

BuffScript.ForceMp_TakeDmg = {}

function BuffScript.ForceMp_TakeDmg.OnAdd(Buff)
	Buff.Owner:On("单位-受到伤害", _ForceMp_TakeDmg, Buff)
end

function BuffScript.ForceMp_TakeDmg.OnRemove(Buff)
	Buff.Owner:Off("单位-受到伤害", _ForceMp_TakeDmg, Buff)
end

local function _ForceMp_Dodging(Buff, Unit, dmg)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	local vaild = false

	for i, v in ipairs(Buff:GetCustomByPropName("DmgTypes")) do
		if v == "MagAtk" and dmg.damagePhy > 0 then
			vaild = true
		end

		if v == "MagAtk" and dmg.damageMag > 0 then
			vaild = true
		end
	end

	if vaild == false then
		return
	end

	if _percentSuccess(Buff) == true then
		Buff.Owner:ForceMp(Buff.Value)
	end
end

BuffScript.ForceMp_Dodging = {}

function BuffScript.ForceMp_Dodging.OnAdd(Buff)
	Buff.Owner:On("单位-即将闪避", _ForceMp_Dodging, Buff)
end

function BuffScript.ForceMp_Dodging.OnRemove(Buff)
	Buff.Owner:Off("单位-即将闪避", _ForceMp_Dodging, Buff)
end

local function _change_Dot_Dmg(Buff, source, unit, dotData, val)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if dotData.dmgSource and dotData.dmgSource.className == "Buff" then
		local Type_Order = Buff:GetCustomByPropName("Type_Order")

		if Type_Order and Type_Order == dotData.dmgSource.TypeOrder then
			dotData.mul = dotData.mul + val

			if dotData.mul < 0 then
				dotData.mul = 0
			end
		end
	end
end

local function _Add_Dot_Dmg(Buff, source, unit, dotData)
	_change_Dot_Dmg(Buff, source, unit, dotData, Buff.Value)
end

BuffScript.Add_Dot_Dmg = {}

function BuffScript.Add_Dot_Dmg.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到dot伤害", _Add_Dot_Dmg, Buff)
end

function BuffScript.Add_Dot_Dmg.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到dot伤害", _Add_Dot_Dmg, Buff)
end

local function _Reduce_Dot_Dmg(Buff, source, unit, dotData)
	_change_Dot_Dmg(Buff, source, unit, dotData, Buff.Value * -1)
end

BuffScript.Reduce_Dot_Dmg = {}

function BuffScript.Reduce_Dot_Dmg.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到dot伤害", _Reduce_Dot_Dmg, Buff)
end

function BuffScript.Reduce_Dot_Dmg.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到dot伤害", _Reduce_Dot_Dmg, Buff)
end

local function _Heal_Halo_Dot(Buff, unit, dmg)
	if dmg.dmgType ~= EnumFight.DamageType.Dot then
		return
	end

	if Buff.Owner.UniqueId ~= unit.UniqueId then
		return
	end

	if Buff.Owner:Get("生命") <= 0 then
		return
	end

	if dmg.dmgSource and dmg.dmgSource.className == "Buff" then
		local Type_Order = Buff:GetCustomByPropName("Type_Order")

		if Type_Order and Type_Order == dmg.dmgSource.TypeOrder then
			local addVal = Buff.Value * Buff.Owner:Get("最大生命")
			local u = Buff.GL.UnitMgr:FindUnitById(Buff.SourceUniqueId)

			Buff.Owner:HealHp(addVal, u)
		end

		local TypeOrders = Buff:GetCustomByPropName("TypeOrders")

		if TypeOrders then
			for i, TypeOrder in ipairs(TypeOrders) do
				if TypeOrder == dmg.dmgSource.TypeOrder then
					local addVal = Buff.Value * Buff.Owner:Get("最大生命")
					local u = Buff.GL.UnitMgr:FindUnitById(Buff.SourceUniqueId)

					Buff.Owner:HealHp(addVal, u)

					break
				end
			end
		end
	end
end

BuffScript.Heal_Halo_Dot = {}

function BuffScript.Heal_Halo_Dot.OnAdd(Buff)
	Buff.Owner:On("单位-受到伤害", _Heal_Halo_Dot, Buff)
end

function BuffScript.Heal_Halo_Dot.OnRemove(Buff)
	Buff.Owner:Off("单位-受到伤害", _Heal_Halo_Dot, Buff)
end

local function _Heal_Team_Dot(Buff, unit, dmg)
	if dmg.dmgType ~= EnumFight.DamageType.Dot then
		return
	end

	if Buff.Owner.UniqueId ~= unit.UniqueId then
		return
	end

	if Buff.Owner:Get("生命") <= 0 then
		return
	end

	if dmg.dmgSource and dmg.dmgSource.className == "Buff" then
		local TypeOrders = Buff:GetCustomByPropName("TypeOrders")

		if TypeOrders then
			for i, TypeOrder in ipairs(TypeOrders) do
				if TypeOrder == dmg.dmgSource.TypeOrder then
					local addVal = Buff.Value * dmg.dot

					for i, u in Buff.GL.UnitMgr:Selector():Camp(Buff.Owner.Camp):Alive():Ipairs() do
						u:HealHp(addVal, Buff.Owner)
					end

					break
				end
			end
		end
	end
end

BuffScript.Heal_Team_Dot = {}

function BuffScript.Heal_Team_Dot.OnAdd(Buff)
	Buff.Owner:On("单位-受到伤害", _Heal_Team_Dot, Buff)
end

function BuffScript.Heal_Team_Dot.OnRemove(Buff)
	Buff.Owner:Off("单位-受到伤害", _Heal_Team_Dot, Buff)
end

local function _Stack_Atk(Buff)
	Buff.Round = Buff.CfgRound

	Buff:AddStack(1)

	if Buff.Stack < Buff.MaxStack then
		return
	end

	local hpDmg = Buff.Value * Buff.Owner:Get("最大生命")
	local source = Buff.GL.UnitMgr:FindUnitById(Buff.SourceUniqueId)
	local dmg = source:CreateDamage()

	dmg.dmgType = EnumFight.DamageType.Dot
	dmg.dot = hpDmg
	dmg.dmgSource = Buff

	Buff.Owner:DealDamage(dmg)
	Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)

	local hp = Buff:GetCustomByPropName("AddHp")

	if hp and source then
		source:HealHp(hp * source:Get("最大生命"), source)
	end

	local mp = Buff:GetCustomByPropName("AddMp")

	if mp and source then
		source:ForceMp(mp)
	end

	Buff:RemoveSelf()
end

BuffScript.Stack_Atk = {}

function BuffScript.Stack_Atk.OnAdd(Buff)
	_Stack_Atk(Buff)
end

function BuffScript.Stack_Atk.OnRecover(Buff)
	_Stack_Atk(Buff)
end

function BuffScript.Stack_Atk.OnRemove(Buff)
	return
end

local function _Clear_Mp_Interval(Buff, curRound, maxRound)
	local start = Buff:GetCustomByPropName("X") or 0
	local interval = Buff:GetCustomByPropName("Y") or 0

	if curRound < start then
		return
	end

	if Buff.TempData.Round == nil or curRound > Buff.TempData.Round + interval then
		local othercamp = GameLogic.MAX_CAMP_COUNT - Buff.Owner.Camp + 1
		local otherTeam = Buff.GL.RunTime:GetTeamByCamp(othercamp)
		local mp = otherTeam:Get("魔力")

		otherTeam:ForceMp(-mp)

		Buff.TempData.Round = curRound
	end
end

BuffScript.Clear_Mp_Interval = {}

function BuffScript.Clear_Mp_Interval.OnAdd(Buff)
	Buff.Owner:On("更新回合", _Clear_Mp_Interval, Buff)

	Buff.TempData = {}
end

function BuffScript.Clear_Mp_Interval.OnRemove(Buff)
	Buff.Owner:Off("更新回合", _Clear_Mp_Interval, Buff)

	Buff.TempData = {}
end

local function _Add_Buff_Interval(Buff, curRound, maxRound)
	local start = Buff:GetCustomByPropName("X") or 0
	local interval = Buff:GetCustomByPropName("Y") or 0

	if curRound < start then
		return
	end

	if Buff.TempData.Round == nil or curRound > Buff.TempData.Round + interval then
		local buffIds = Buff:GetCustomByPropName("BuffIds")

		for i, id in ipairs(buffIds) do
			Buff.Owner:AddBuff(id, Buff.Owner)
		end

		Buff.TempData.Round = curRound
	end
end

BuffScript.Add_Buff_Interval = {}

function BuffScript.Add_Buff_Interval.OnAdd(Buff)
	Buff.Owner:On("更新回合", _Add_Buff_Interval, Buff)

	Buff.TempData = {}
end

function BuffScript.Add_Buff_Interval.OnRemove(Buff)
	Buff.Owner:Off("更新回合", _Add_Buff_Interval, Buff)

	Buff.TempData = {}
end
