-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/Script/BuffScript.lua

BuffScript = {}
BuffScript.DurationAddHp = {}

function BuffScript.DurationAddHp.OnCast(Skill)
	print(Skill.GL.GameId)
	print("DurationAddHp")
end

local function _attriExFun(Buff)
	local attriValue = Buff:GetCustomByPropName("Value")

	if attriValue then
		Buff.Value = attriValue
	end

	local weight = Buff:GetCustomByPropName("Weight")
	local weightMulVal = Buff:GetCustomByPropName("WeightMulVal")

	if weight and weightMulVal then
		local val = WeightRandom(weightMulVal, weight)

		Buff.Value = GameLogic.RandomTool(val.Min * 1000, val.Max * 1000) * 0.001
	end

	local roles = Buff:GetCustomByPropName("StartAnd")

	if roles then
		local validCont = 0

		for i, roleId in ipairs(roles) do
			for _, unit in Buff.GL.UnitMgr:Selector():Camp(Buff.Owner.Camp):Alive():Ipairs() do
				if unit.UnitId == roleId then
					validCont = validCont + 1
				end
			end
		end

		if validCont >= #roles then
			Buff.Value = Buff:GetCustomByPropName("NewValue")
		end
	end

	roles = Buff:GetCustomByPropName("StartOr")

	if roles then
		for i, roleId in ipairs(roles) do
			for _, unit in Buff.GL.UnitMgr:Selector():Camp(Buff.Owner.Camp):Alive():Ipairs() do
				if unit.UnitId == roleId then
					Buff.Value = Buff:GetCustomByPropName("NewValue")

					break
				end
			end
		end
	end

	Buff.LogicData = Buff.Value
end

BuffScript.Add_Attri_Per_Ex = {}

function BuffScript.Add_Attri_Per_Ex.OnAdd(Buff)
	_attriExFun(Buff)

	local attri = Buff:GetCustomByPropName("Attri")

	Buff.Owner:AddMul(attri, Buff.Value)
end

function BuffScript.Add_Attri_Per_Ex.OnRemove(Buff)
	local attri = Buff:GetCustomByPropName("Attri")

	Buff.Owner:AddMul(attri, Buff.Value * -1)
end

BuffScript.Add_Attri_Val_Ex = {}

function BuffScript.Add_Attri_Val_Ex.OnAdd(Buff)
	_attriExFun(Buff)

	local attri = Buff:GetCustomByPropName("Attri")

	Buff.Owner:Add(attri, Buff.Value * -1)
end

function BuffScript.Add_Attri_Val_Ex.OnRemove(Buff)
	local attri = Buff:GetCustomByPropName("Attri")

	Buff.Owner:Add(attri, Buff.Value)
end

BuffScript.Reduce_Attri_Per_Ex = {}

function BuffScript.Reduce_Attri_Per_Ex.OnAdd(Buff)
	_attriExFun(Buff)

	local attri = Buff:GetCustomByPropName("Attri")

	Buff.Owner:AddMul(attri, Buff.Value * -1)
end

function BuffScript.Reduce_Attri_Per_Ex.OnRemove(Buff)
	local attri = Buff:GetCustomByPropName("Attri")

	Buff.Owner:AddMul(attri, Buff.Value)
end

BuffScript.Reduce_Attri_Val_Ex = {}

function BuffScript.Reduce_Attri_Val_Ex.OnAdd(Buff)
	_attriExFun(Buff)

	local attri = Buff:GetCustomByPropName("Attri")

	Buff.Owner:Add(attri, Buff.Value * -1)
end

function BuffScript.Reduce_Attri_Val_Ex.OnRemove(Buff)
	local attri = Buff:GetCustomByPropName("Attri")

	Buff.Owner:Add(attri, Buff.Value)
end

BuffScript.Add_Attri_Per = {}

function BuffScript.Add_Attri_Per.OnAdd(Buff)
	local attris = Buff:GetCustom()

	for i, attri in ipairs(attris) do
		Buff.Owner:AddMul(attri, Buff.Value)
	end
end

function BuffScript.Add_Attri_Per.OnRemove(Buff)
	local attris = Buff:GetCustom()

	for i, attri in ipairs(attris) do
		Buff.Owner:AddMul(attri, Buff.Value * -1)
	end
end

BuffScript.Add_Attri_Val = {}

function BuffScript.Add_Attri_Val.OnAdd(Buff)
	local attris = Buff:GetCustom()

	for i, attri in ipairs(attris) do
		Buff.Owner:Add(attri, Buff.Value)
	end
end

function BuffScript.Add_Attri_Val.OnRemove(Buff)
	local attris = Buff:GetCustom()

	for i, attri in ipairs(attris) do
		Buff.Owner:Add(attri, Buff.Value * -1)
	end
end

BuffScript.Reduce_Attri_Per = {}

function BuffScript.Reduce_Attri_Per.OnAdd(Buff)
	local attris = Buff:GetCustom()

	for i, attri in ipairs(attris) do
		Buff.Owner:AddMul(attri, Buff.Value * -1)
	end
end

function BuffScript.Reduce_Attri_Per.OnRemove(Buff)
	local attris = Buff:GetCustom()

	for i, attri in ipairs(attris) do
		Buff.Owner:AddMul(attri, Buff.Value)
	end
end

BuffScript.Reduce_Attri_Val = {}

function BuffScript.Reduce_Attri_Val.OnAdd(Buff)
	local attris = Buff:GetCustom()

	for i, attri in ipairs(attris) do
		Buff.Owner:Add(attri, Buff.Value * -1)
	end
end

function BuffScript.Reduce_Attri_Val.OnRemove(Buff)
	local attris = Buff:GetCustom()

	for i, attri in ipairs(attris) do
		Buff.Owner:Add(attri, Buff.Value)
	end
end

BuffScript.Add_Amor_Attack_Per = {}

function BuffScript.Add_Amor_Attack_Per.OnAdd(Buff)
	Buff.Owner:AddMul("物理攻击", Buff.Value)
	Buff.Owner:AddMul("魔法攻击", Buff.Value)
	Buff.Owner:AddMul("防御", Buff.Value)
end

function BuffScript.Add_Amor_Attack_Per.OnRemove(Buff)
	Buff.Owner:AddMul("物理攻击", Buff.Value * -1)
	Buff.Owner:AddMul("魔法攻击", Buff.Value * -1)
	Buff.Owner:AddMul("防御", Buff.Value * -1)
end

BuffScript.Reduce_Amor_Attack_Per = {}

function BuffScript.Reduce_Amor_Attack_Per.OnAdd(Buff)
	Buff.Owner:AddMul("物理攻击", Buff.Value * -1)
	Buff.Owner:AddMul("魔法攻击", Buff.Value * -1)
	Buff.Owner:AddMul("防御", Buff.Value * -1)
end

function BuffScript.Reduce_Amor_Attack_Per.OnRemove(Buff)
	Buff.Owner:AddMul("物理攻击", Buff.Value)
	Buff.Owner:AddMul("魔法攻击", Buff.Value)
	Buff.Owner:AddMul("防御", Buff.Value)
end

BuffScript.Reduce_Attack = {}

function BuffScript.Reduce_Attack.OnAdd(Buff)
	Buff.Owner:Add("物理攻击", Buff.Value * -1)
	Buff.Owner:Add("魔法攻击", Buff.Value * -1)
end

function BuffScript.Reduce_Attack.OnRemove(Buff)
	Buff.Owner:Add("物理攻击", Buff.Value)
	Buff.Owner:Add("魔法攻击", Buff.Value)
end

BuffScript.Add_Attack = {}

function BuffScript.Add_Attack.OnAdd(Buff)
	Buff.Owner:Add("物理攻击", Buff.Value)
	Buff.Owner:Add("魔法攻击", Buff.Value)
end

function BuffScript.Add_Attack.OnRemove(Buff)
	Buff.Owner:Add("物理攻击", Buff.Value * -1)
	Buff.Owner:Add("魔法攻击", Buff.Value * -1)
end

BuffScript.Add_Attack_Per = {}

function BuffScript.Add_Attack_Per.OnAdd(Buff)
	Buff.Owner:AddMul("物理攻击", Buff.Value)
	Buff.Owner:AddMul("魔法攻击", Buff.Value)
end

function BuffScript.Add_Attack_Per.OnRemove(Buff)
	Buff.Owner:AddMul("物理攻击", Buff.Value * -1)
	Buff.Owner:AddMul("魔法攻击", Buff.Value * -1)
end

BuffScript.Reduce_Attack_Per = {}

function BuffScript.Reduce_Attack_Per.OnAdd(Buff)
	Buff.Owner:AddMul("物理攻击", Buff.Value * -1)
	Buff.Owner:AddMul("魔法攻击", Buff.Value * -1)
end

function BuffScript.Reduce_Attack_Per.OnRemove(Buff)
	Buff.Owner:AddMul("物理攻击", Buff.Value)
	Buff.Owner:AddMul("魔法攻击", Buff.Value)
end

BuffScript.Add_Phy_Attack = {}

function BuffScript.Add_Phy_Attack.OnAdd(Buff)
	Buff.Owner:Add("物理攻击", Buff.Value)
end

function BuffScript.Add_Phy_Attack.OnRemove(Buff)
	Buff.Owner:Add("物理攻击", Buff.Value * -1)
end

BuffScript.Reduce_Phy_Attack = {}

function BuffScript.Reduce_Phy_Attack.OnAdd(Buff)
	Buff.Owner:Add("物理攻击", Buff.Value * -1)
end

function BuffScript.Reduce_Phy_Attack.OnRemove(Buff)
	Buff.Owner:Add("物理攻击", Buff.Value)
end

BuffScript.Add_Phy_Attack_Per = {}

function BuffScript.Add_Phy_Attack_Per.OnAdd(Buff)
	Buff.Owner:AddMul("物理攻击", Buff.Value)
end

function BuffScript.Add_Phy_Attack_Per.OnRemove(Buff)
	Buff.Owner:AddMul("物理攻击", Buff.Value * -1)
end

BuffScript.Reduce_Phy_Attack_Per = {}

function BuffScript.Reduce_Phy_Attack_Per.OnAdd(Buff)
	Buff.Owner:AddMul("物理攻击", Buff.Value * -1)
end

function BuffScript.Reduce_Phy_Attack_Per.OnRemove(Buff)
	Buff.Owner:AddMul("物理攻击", Buff.Value)
end

BuffScript.Add_Mag_Attack = {}

function BuffScript.Add_Mag_Attack.OnAdd(Buff)
	Buff.Owner:Add("魔法攻击", Buff.Value)
end

function BuffScript.Add_Mag_Attack.OnRemove(Buff)
	Buff.Owner:Add("魔法攻击", Buff.Value * -1)
end

BuffScript.Reduce_Mag_Attack = {}

function BuffScript.Reduce_Mag_Attack.OnAdd(Buff)
	Buff.Owner:Add("魔法攻击", Buff.Value * -1)
end

function BuffScript.Reduce_Mag_Attack.OnRemove(Buff)
	Buff.Owner:Add("魔法攻击", Buff.Value)
end

BuffScript.Add_Mag_Attack_Per = {}

function BuffScript.Add_Mag_Attack_Per.OnAdd(Buff)
	Buff.Owner:AddMul("魔法攻击", Buff.Value)
end

function BuffScript.Add_Mag_Attack_Per.OnRemove(Buff)
	Buff.Owner:AddMul("魔法攻击", Buff.Value * -1)
end

BuffScript.Reduce_Mag_Attack_Per = {}

function BuffScript.Reduce_Mag_Attack_Per.OnAdd(Buff)
	Buff.Owner:AddMul("魔法攻击", Buff.Value * -1)
end

function BuffScript.Reduce_Mag_Attack_Per.OnRemove(Buff)
	Buff.Owner:AddMul("魔法攻击", Buff.Value)
end

BuffScript.Add_Amor = {}

function BuffScript.Add_Amor.OnAdd(Buff)
	Buff.Owner:Add("防御", Buff.Value)
end

function BuffScript.Add_Amor.OnRemove(Buff)
	Buff.Owner:Add("防御", Buff.Value * -1)
end

BuffScript.Reduce_Amor = {}

function BuffScript.Reduce_Amor.OnAdd(Buff)
	Buff.Owner:Add("防御", Buff.Value * -1)
end

function BuffScript.Reduce_Amor.OnRemove(Buff)
	Buff.Owner:Add("防御", Buff.Value)
end

BuffScript.Add_Amor_Per = {}

function BuffScript.Add_Amor_Per.OnAdd(Buff)
	Buff.Owner:AddMul("防御", Buff.Value)
end

function BuffScript.Add_Amor_Per.OnRemove(Buff)
	Buff.Owner:AddMul("防御", Buff.Value * -1)
end

BuffScript.Reduce_Amor_Per = {}

function BuffScript.Reduce_Amor_Per.OnAdd(Buff)
	Buff.Owner:AddMul("防御", Buff.Value * -1)
end

function BuffScript.Reduce_Amor_Per.OnRemove(Buff)
	Buff.Owner:AddMul("防御", Buff.Value)
end

BuffScript.Add_Dmg_Inc = {}

function BuffScript.Add_Dmg_Inc.OnAdd(Buff)
	Buff.Owner:Add("增伤", Buff.Value)
end

function BuffScript.Add_Dmg_Inc.OnRemove(Buff)
	Buff.Owner:Add("增伤", Buff.Value * -1)
end

BuffScript.Add_Dmg_Dec = {}

function BuffScript.Add_Dmg_Dec.OnAdd(Buff)
	Buff.Owner:Add("减伤", Buff.Value)
end

function BuffScript.Add_Dmg_Dec.OnRemove(Buff)
	Buff.Owner:Add("减伤", Buff.Value * -1)
end

BuffScript.Add_CriticalRatio = {}

function BuffScript.Add_CriticalRatio.OnAdd(Buff)
	Buff.Owner:Add("暴击率", Buff.Value)
end

function BuffScript.Add_CriticalRatio.OnRemove(Buff)
	Buff.Owner:Add("暴击率", Buff.Value * -1)
end

BuffScript.Reduce_CriticalRatio = {}

function BuffScript.Reduce_CriticalRatio.OnAdd(Buff)
	Buff.Owner:Add("暴击率", Buff.Value * -1)
end

function BuffScript.Reduce_CriticalRatio.OnRemove(Buff)
	Buff.Owner:Add("暴击率", Buff.Value)
end

BuffScript.Add_CriticalDamage = {}

function BuffScript.Add_CriticalDamage.OnAdd(Buff)
	Buff.Owner:Add("暴击效果", Buff.Value)
end

function BuffScript.Add_CriticalDamage.OnRemove(Buff)
	Buff.Owner:Add("暴击效果", Buff.Value * -1)
end

BuffScript.Reduce_CriticalDamage = {}

function BuffScript.Reduce_CriticalDamage.OnAdd(Buff)
	Buff.Owner:Add("暴击效果", Buff.Value * -1)
end

function BuffScript.Reduce_CriticalDamage.OnRemove(Buff)
	Buff.Owner:Add("暴击效果", Buff.Value)
end

BuffScript.Add_Max_Hp_Per = {}

function BuffScript.Add_Max_Hp_Per.OnAdd(Buff)
	Buff.Owner:AddMul("最大生命", Buff.Value)
end

function BuffScript.Add_Max_Hp_Per.OnRemove(Buff)
	Buff.Owner:AddMul("最大生命", Buff.Value * -1)
end

BuffScript.Add_Max_Mp = {}

function BuffScript.Add_Max_Mp.OnAdd(Buff)
	if Buff.Owner.UnitClass ~= EnumFight.UnitClass.ENEMY then
		Buff.GL.RunTime:GetTeamByCamp(Buff.Owner.Camp):Add("最大魔力", Buff.Value)

		return
	end

	Buff.Owner:Add("最大魔力", Buff.Value)
end

function BuffScript.Add_Max_Mp.OnRemove(Buff)
	if Buff.Owner.UnitClass ~= EnumFight.UnitClass.ENEMY then
		Buff.GL.RunTime:GetTeamByCamp(Buff.Owner.Camp):Add("最大魔力", Buff.Value * -1)

		return
	end

	Buff.Owner:Add("最大魔力", Buff.Value * -1)
end

local function _bleedingFunc(Buff)
	local maxHp = Buff.Owner:Get("最大生命")
	local percentHp = Buff.Value
	local weight = Buff:GetCustomByPropName("Weight")
	local weightMulVal = Buff:GetCustomByPropName("WeightMulVal")

	if weight and weightMulVal then
		local val = WeightRandom(weightMulVal, weight)
		local r = GameLogic.RandomTool(val.Min * 1000, val.Max * 1000) * 0.001

		percentHp = r
	end

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

BuffScript.Dot_Bleeding = {}

function BuffScript.Dot_Bleeding.OnAdd(Buff)
	return
end

function BuffScript.Dot_Bleeding.OnUpdate(Buff)
	local isDelay = Buff:GetCustomByPropName("IsDelay")

	if isDelay and isDelay == 1 then
		if Buff.Round == 1 then
			_bleedingFunc(Buff)
		end
	else
		_bleedingFunc(Buff)
	end
end

function BuffScript.Dot_Bleeding.OnRemove(Buff)
	return
end

local Dot_Bleeding_Stack_ConstStack = 9
local Dot_Bleeding_Stack_ConstDmg = 0.01

BuffScript.Dot_Bleeding_Stack = {}

function BuffScript.Dot_Bleeding_Stack.OnAdd(Buff)
	if Buff.Stack < Dot_Bleeding_Stack_ConstStack then
		Buff:AddStack(1)
	end
end

function BuffScript.Dot_Bleeding_Stack.OnRecover(Buff)
	if Buff.Stack < Dot_Bleeding_Stack_ConstStack then
		Buff:AddStack(1)
	end
end

function BuffScript.Dot_Bleeding_Stack.OnUpdate(Buff)
	local maxHp = Buff.Owner:Get("最大生命")
	local dmgHp = maxHp * Dot_Bleeding_Stack_ConstDmg * Buff.Stack
	local source = Buff.GL.UnitMgr:FindUnitById(Buff.SourceUniqueId)
	local dmg = source:CreateDamage()

	dmg.dmgType = EnumFight.DamageType.Dot
	dmg.dot = dmgHp
	dmg.dmgSource = Buff

	Buff.Owner:DealDamage(dmg)

	if Buff.Round == 1 then
		Buff:RemoveSelf()
	end
end

function BuffScript.Dot_Bleeding_Stack.OnRemove(Buff)
	return
end

BuffScript.Hot_Heal = {}

function BuffScript.Hot_Heal.OnAdd(Buff)
	return
end

function BuffScript.Hot_Heal.OnUpdate(Buff)
	local maxHp = Buff.Owner:Get("最大生命")
	local percentHp = Buff.Value
	local addVal = maxHp * percentHp
	local source = Buff.GL.UnitMgr:FindUnitById(Buff.SourceUniqueId)

	Buff.Owner:HealHp(addVal, source)

	if Buff.Round == 1 then
		Buff:RemoveSelf()
	end
end

function BuffScript.Hot_Heal.OnRemove(Buff)
	return
end

BuffScript.Hot_Heal_Attri = {}

function BuffScript.Hot_Heal_Attri.OnAdd(Buff)
	return
end

function BuffScript.Hot_Heal_Attri.OnUpdate(Buff)
	local source = Buff.GL.UnitMgr:FindUnitById(Buff.SourceUniqueId)
	local addVal = source:Get(Buff:GetCustomByPropName("Attri")) * Buff.Value

	if addVal > 0 then
		Buff.Owner:HealHp(addVal, source)
	end

	if Buff.Round == 1 then
		Buff:RemoveSelf()
	end
end

function BuffScript.Hot_Heal_Attri.OnRemove(Buff)
	return
end

BuffScript.Hot_ForceMp = {}

function BuffScript.Hot_ForceMp.OnAdd(Buff)
	Buff.Hot_ForceMpTimes = Buff.CfgRound
end

function BuffScript.Hot_ForceMp.OnUpdate(Buff)
	local team = Buff.GL.RunTime:GetTeamByCamp(Buff.Owner.Camp)
	local addVal = Buff.Value

	team:ForceMp(addVal)

	Buff.Hot_ForceMpTimes = Buff.Hot_ForceMpTimes - 1

	if Buff.Hot_ForceMpTimes == 0 then
		Buff:RemoveSelf()
	end
end

function BuffScript.Hot_ForceMp.OnRemove(Buff)
	Buff.Hot_ForceMpTimes = nil
end

BuffScript.Hot_AddShield = {}

function BuffScript.Hot_AddShield.OnAdd(Buff)
	return
end

function BuffScript.Hot_AddShield.OnUpdate(Buff)
	local team = Buff.GL.RunTime:GetTeamByCamp(Buff.Owner.Camp)
	local addVal = team:Get("最大护盾") * Buff.Value

	team:AddShield(addVal)

	if Buff.Round == 1 then
		Buff:RemoveSelf()
	end
end

function BuffScript.Hot_AddShield.OnRemove(Buff)
	return
end

BuffScript.Hot_AddAttri = {}

function BuffScript.Hot_AddAttri.OnAdd(Buff)
	Buff.TempData = {}
	Buff.TempData.AddValue = 0
end

function BuffScript.Hot_AddAttri.OnUpdate(Buff)
	local startRound = Buff:GetCustomByPropName("StartRound")

	if startRound and startRound > Buff.GL.RunTime.CurRound then
		return
	end

	Buff.TempData.AddValue = Buff.TempData.AddValue + Buff.Value

	if Buff:GetCustomByPropName("Val") then
		Buff.Owner:Add(Buff:GetCustomByPropName("Attri"), Buff.Value)
	else
		Buff.Owner:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value)
	end
end

function BuffScript.Hot_AddAttri.OnRemove(Buff)
	if Buff:GetCustomByPropName("Val") then
		Buff.Owner:Add(Buff:GetCustomByPropName("Attri"), Buff.TempData.AddValue * -1)
	else
		Buff.Owner:AddMul(Buff:GetCustomByPropName("Attri"), Buff.TempData.AddValue * -1)
	end
end

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

BuffScript.Set_Not_Action = {}

function BuffScript.Set_Not_Action.OnAdd(Buff)
	Buff.Owner:SetNotAction(true)

	if Buff.TypeOrder == "sleep" then
		Buff.Owner:On("单位-即将受到伤害", _sleep_Action_before_dmg, Buff)
		Buff.Owner:On("单位-受到伤害", _sleep_Action_after_dmg, Buff)
	end
end

function BuffScript.Set_Not_Action.OnRemove(Buff)
	Buff.Owner:SetNotAction(false)

	if Buff.TypeOrder == "sleep" then
		Buff.Owner:Off("单位-即将受到伤害", _sleep_Action_before_dmg, Buff)
		Buff.Owner:Off("单位-受到伤害", _sleep_Action_after_dmg, Buff)
	end
end

local function _oneHP_Shield(Buff, unit, dmg)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	dmg.dmgType = EnumFight.DamageType.Invalid
	Buff.Value = Buff.Value - 1

	local args = {}

	args.CurVal = Buff.Value
	args.MaxVal = Buff.CfgValue

	Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "NeverSurrender", args)
	Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)

	if Buff.Value == 0 then
		Buff:RemoveSelf()
	end
end

BuffScript["1HP_Shield"] = {}
BuffScript["1HP_Shield"].OnAdd = function(Buff)
	Buff.Owner:On("单位-即将受到伤害", _oneHP_Shield, Buff)
end
BuffScript["1HP_Shield"].OnRemove = function(Buff)
	Buff.Owner:Off("单位-即将受到伤害", _oneHP_Shield, Buff)
end

local function _God_Shield_1(Buff, unit, dmg)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	dmg.damagePhy = 0
	dmg.damageMag = 0

	Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
end

local function _God_Shield_2(Buff, unit, addBuff)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if addBuff.Type == "Dot_Bleeding" or addBuff.Type == "Set_Not_Action" then
		addBuff.IsMiss = true
	end
end

BuffScript.God_Shield = {}

function BuffScript.God_Shield.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到伤害", _God_Shield_1, Buff)
	Buff.Owner:On("单位-即将添加buff", _God_Shield_2, Buff)
end

function BuffScript.God_Shield.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到伤害", _God_Shield_1, Buff)
	Buff.Owner:Off("单位-即将添加buff", _God_Shield_2, Buff)
end

local function _phy_Shield(Buff, unit, dmg)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if dmg.dmgType == EnumFight.DamageType.Std and dmg.damagePhy > 0 then
		dmg.damagePhy = 0

		Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
	end
end

BuffScript.Phy_Shield = {}

function BuffScript.Phy_Shield.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到伤害", _phy_Shield, Buff)
end

function BuffScript.Phy_Shield.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到伤害", _phy_Shield, Buff)
end

local function _mag_Shield(Buff, unit, dmg)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if dmg.dmgType == EnumFight.DamageType.Std and dmg.damageMag > 0 then
		dmg.damageMag = 0

		Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
	end
end

BuffScript.Mag_Shield = {}

function BuffScript.Mag_Shield.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到伤害", _mag_Shield, Buff)
end

function BuffScript.Mag_Shield.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到伤害", _mag_Shield, Buff)
end

local function _phy_rc_Shield(Buff, unit, dmg)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if unit:Get("生命") <= 0 then
		return
	end

	if dmg.dmgType == EnumFight.DamageType.Std and dmg.damagePhy > 0 then
		unit:HealHp(dmg.damagePhy * Buff.Value, unit)

		dmg.damagePhy = 0

		Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
	end
end

BuffScript.Phy_Rc_Shield = {}

function BuffScript.Phy_Rc_Shield.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到伤害", _phy_rc_Shield, Buff)
end

function BuffScript.Phy_Rc_Shield.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到伤害", _phy_rc_Shield, Buff)
end

local function _mag_rc_Shield(Buff, unit, dmg)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if unit:Get("生命") <= 0 then
		return
	end

	if dmg.dmgType == EnumFight.DamageType.Std and dmg.damageMag > 0 then
		unit:HealHp(dmg.damageMag * Buff.Value, unit)

		dmg.damageMag = 0

		Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
	end
end

BuffScript.Mag_Rc_Shield = {}

function BuffScript.Mag_Rc_Shield.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到伤害", _mag_rc_Shield, Buff)
end

function BuffScript.Mag_Rc_Shield.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到伤害", _mag_rc_Shield, Buff)
end

local function _Mag_Shield_Reflection(Buff, unit, dmg)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	local source = Buff.GL.UnitMgr:FindUnitById(dmg.srcUniqueId)

	if not source then
		return
	end

	if source:HasBuffType("Mag_Shield_Reflection") then
		return
	end

	if source:HasBuffType("Phy_Shield_Reflection") then
		return
	end

	if dmg.dmgType ~= EnumFight.DamageType.Std or dmg.damageMag <= 0 then
		return
	end

	local copyDmg = dmg:Copy()

	copyDmg:SetSource(Buff.Owner)

	copyDmg.damagePhy = 0
	copyDmg.damageMag = copyDmg.damageMag * Buff.Value
	copyDmg.dmgType = EnumFight.DamageType.Anti
	copyDmg.dmgSource = Buff

	source:DealDamage(copyDmg)

	dmg.damageMag = 0

	Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
end

BuffScript.Mag_Shield_Reflection = {}

function BuffScript.Mag_Shield_Reflection.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到伤害", _Mag_Shield_Reflection, Buff)
end

function BuffScript.Mag_Shield_Reflection.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到伤害", _Mag_Shield_Reflection, Buff)
end

local function _Phy_Shield_Reflection(Buff, unit, dmg)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	local source = Buff.GL.UnitMgr:FindUnitById(dmg.srcUniqueId)

	if not source then
		return
	end

	if source:HasBuffType("Mag_Shield_Reflection") then
		return
	end

	if source:HasBuffType("Phy_Shield_Reflection") then
		return
	end

	if dmg.dmgType ~= EnumFight.DamageType.Std or dmg.damagePhy <= 0 then
		return
	end

	local copyDmg = dmg:Copy()

	copyDmg:SetSource(Buff.Owner)

	copyDmg.damageMag = 0
	copyDmg.damagePhy = copyDmg.damagePhy * Buff.Value
	copyDmg.dmgType = EnumFight.DamageType.Anti
	copyDmg.dmgSource = Buff

	source:DealDamage(copyDmg)

	dmg.damagePhy = 0

	Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
end

BuffScript.Phy_Shield_Reflection = {}

function BuffScript.Phy_Shield_Reflection.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到伤害", _Phy_Shield_Reflection, Buff)
end

function BuffScript.Phy_Shield_Reflection.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到伤害", _Phy_Shield_Reflection, Buff)
end

local function _Mag_Shield_Reflection_2(Buff, unit, dmg)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	local source = Buff.GL.UnitMgr:FindUnitById(dmg.srcUniqueId)

	if not source then
		return
	end

	if source:HasBuffType("Mag_Shield_Reflection") then
		return
	end

	if source:HasBuffType("Phy_Shield_Reflection") then
		return
	end

	if dmg.dmgType ~= EnumFight.DamageType.Std or dmg.damageMag <= 0 then
		return
	end

	local copyDmg = dmg:Copy()

	copyDmg:SetSource(Buff.Owner)

	copyDmg.damagePhy = 0
	copyDmg.damageMag = copyDmg.damageMag * Buff.Value
	copyDmg.dmgType = EnumFight.DamageType.Anti
	copyDmg.dmgSource = Buff

	source:DealDamage(copyDmg)
	Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
end

BuffScript.Mag_Shield_Reflection2 = {}

function BuffScript.Mag_Shield_Reflection2.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到伤害", _Mag_Shield_Reflection_2, Buff)
end

function BuffScript.Mag_Shield_Reflection2.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到伤害", _Mag_Shield_Reflection_2, Buff)
end

local function _Phy_Shield_Reflection_2(Buff, unit, dmg)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	local source = Buff.GL.UnitMgr:FindUnitById(dmg.srcUniqueId)

	if source:HasBuffType("Mag_Shield_Reflection") then
		return
	end

	if source:HasBuffType("Phy_Shield_Reflection") then
		return
	end

	if dmg.dmgType ~= EnumFight.DamageType.Std or dmg.damagePhy <= 0 then
		return
	end

	local copyDmg = dmg:Copy()

	copyDmg:SetSource(Buff.Owner)

	copyDmg.damageMag = 0
	copyDmg.damagePhy = copyDmg.damagePhy * Buff.Value
	copyDmg.dmgType = EnumFight.DamageType.Anti
	copyDmg.dmgSource = Buff

	source:DealDamage(copyDmg)
	Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
end

BuffScript.Phy_Shield_Reflection2 = {}

function BuffScript.Phy_Shield_Reflection2.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到伤害", _Phy_Shield_Reflection_2, Buff)
end

function BuffScript.Phy_Shield_Reflection2.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到伤害", _Phy_Shield_Reflection_2, Buff)
end

local function _Teams_Attri_Shield(Buff, unit, dmg)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)

	local total = Buff.CustomArg

	total = total - dmg.finalMinusHp

	if total >= 0 then
		Buff.CustomArg = total
		dmg.finalMinusHp = 0
	else
		dmg.finalMinusHp = dmg.finalMinusHp - Buff.CustomArg

		Buff:RemoveSelf()
	end
end

BuffScript.Teams_Attri_Shield = {}

function BuffScript.Teams_Attri_Shield.OnAdd(Buff)
	local total = 0

	for i, unit in Buff.GL.UnitMgr:Selector():Camp(Buff.Owner.Camp):Alive():Ipairs() do
		total = unit:Get(Buff:GetCustomByPropName("Attri")) * Buff.Value
	end

	Buff.CustomArg = total

	Buff.Owner:On("单位-即将结算伤害", _Teams_Attri_Shield, Buff)
end

function BuffScript.Teams_Attri_Shield.OnRemove(Buff)
	Buff.Owner:Off("单位-即将结算伤害", _Teams_Attri_Shield, Buff)
end

local function _Attri_Shield(Buff, unit, dmg)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)

	local total = Buff.CustomArg

	total = total - dmg.finalMinusHp

	if total >= 0 then
		Buff.CustomArg = total
		dmg.finalMinusHp = 0
	else
		dmg.finalMinusHp = dmg.finalMinusHp - Buff.CustomArg

		Buff:RemoveSelf()
	end
end

BuffScript.Attri_Shield = {}

function BuffScript.Attri_Shield.OnAdd(Buff)
	local source = Buff.GL.UnitMgr:FindUnitById(Buff.SourceUniqueId)
	local total = 0

	if source then
		total = source:Get(Buff:GetCustomByPropName("Attri")) * Buff.Value
	end

	Buff.CustomArg = total

	Buff.Owner:On("单位-即将结算伤害", _Attri_Shield, Buff)
end

function BuffScript.Attri_Shield.OnRemove(Buff)
	Buff.Owner:Off("单位-即将结算伤害", _Attri_Shield, Buff)
end

local function _Attri_Shield_Rc(Buff, unit, dmg)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)

	local heal = 0
	local total = Buff.CustomArg

	total = total - dmg.finalMinusHp

	if total >= 0 then
		Buff.CustomArg = total
		heal = dmg.finalMinusHp
		dmg.finalMinusHp = 0
	else
		dmg.finalMinusHp = dmg.finalMinusHp - total
		heal = total

		Buff:RemoveSelf()
	end

	heal = heal * Buff:GetCustomByPropName("Per")

	if heal > 0 then
		unit:HealHp(heal, unit)
	end
end

BuffScript.Attri_Shield_Rc = {}

function BuffScript.Attri_Shield_Rc.OnAdd(Buff)
	local source = Buff.GL.UnitMgr:FindUnitById(Buff.SourceUniqueId)
	local total = 0

	if source then
		total = source:Get(Buff:GetCustomByPropName("Attri")) * Buff.Value
	end

	Buff.CustomArg = total

	Buff.Owner:On("单位-即将结算伤害", _Attri_Shield_Rc, Buff)
end

function BuffScript.Attri_Shield_Rc.OnRemove(Buff)
	Buff.Owner:Off("单位-即将结算伤害", _Attri_Shield_Rc, Buff)
end

local function _Add_Group_CriticalRatio(Buff, Unit)
	if Unit.Camp ~= Buff.Camp then
		return
	end

	Unit:Add("暴击率", Buff.Value)
end

BuffScript.Add_Group_CriticalRatio = {}

function BuffScript.Add_Group_CriticalRatio.OnAdd(Buff)
	for i, unit in Buff.GL.UnitMgr:Selector():Camp(Buff.Owner.Camp):Alive():Ipairs() do
		unit:Add("暴击率", Buff.Value)
	end

	Buff.Owner:On("单位-创建", _Add_Group_CriticalRatio, Buff)
end

function BuffScript.Add_Group_CriticalRatio.OnRemove(Buff)
	Buff.Owner:Off("单位-创建", _Add_Group_CriticalRatio, Buff)
end

local function _Add_Group_Dmg_Dec(Buff, Unit)
	if Unit.Camp ~= Buff.Camp then
		return
	end

	Unit:Add("减伤", Buff.Value)
end

BuffScript.Add_Group_Dmg_Dec = {}

function BuffScript.Add_Group_Dmg_Dec.OnAdd(Buff)
	for i, unit in Buff.GL.UnitMgr:Selector():Camp(Buff.Owner.Camp):Alive():Ipairs() do
		unit:Add("减伤", Buff.Value)
	end

	Buff.Owner:On("单位-创建", _Add_Group_Dmg_Dec, Buff)
end

function BuffScript.Add_Group_Dmg_Dec.OnRemove(Buff)
	Buff.Owner:Off("单位-创建", _Add_Group_Dmg_Dec, Buff)
end

local function _Add_Group_Dmg_Inc(Buff, Unit)
	if Unit.Camp ~= Buff.Camp then
		return
	end

	Unit:Add("增伤", Buff.Value)
end

BuffScript.Add_Group_Dmg_Inc = {}

function BuffScript.Add_Group_Dmg_Inc.OnAdd(Buff)
	for i, unit in Buff.GL.UnitMgr:Selector():Camp(Buff.Owner.Camp):Alive():Ipairs() do
		unit:Add("增伤", Buff.Value)
	end

	Buff.Owner:On("单位-创建", _Add_Group_Dmg_Inc, Buff)
end

function BuffScript.Add_Group_Dmg_Inc.OnRemove(Buff)
	Buff.Owner:Off("单位-创建", _Add_Group_Dmg_Inc, Buff)
end

local function _Reduce_Group_Attack_Per(Buff, Unit)
	if Unit.Camp == Buff.Camp then
		return
	end

	Unit:AddMul("物理攻击", Buff.Value * -1)
	Unit:AddMul("魔法攻击", Buff.Value * -1)
end

BuffScript.Reduce_Group_Attack_Per = {}

function BuffScript.Reduce_Group_Attack_Per.OnAdd(Buff)
	for i, unit in Buff.GL.UnitMgr:Selector():NotCamp(Buff.Owner.Camp):Alive():Ipairs() do
		unit:AddMul("物理攻击", Buff.Value * -1)
		unit:AddMul("魔法攻击", Buff.Value * -1)
	end

	Buff.Owner:On("单位-创建", _Reduce_Group_Attack_Per, Buff)
end

function BuffScript.Reduce_Group_Attack_Per.OnRemove(Buff)
	Buff.Owner:Off("单位-创建", _Reduce_Group_Attack_Per, Buff)
end

local function _Reduce_Group_Amor_Per(Buff, Unit)
	if Unit.Camp == Buff.Camp then
		return
	end

	Unit:AddMul("防御", Buff.Value * -1)
end

BuffScript.Reduce_Group_Amor_Per = {}

function BuffScript.Reduce_Group_Amor_Per.OnAdd(Buff)
	for i, unit in Buff.GL.UnitMgr:Selector():NotCamp(Buff.Owner.Camp):Alive():Ipairs() do
		unit:AddMul("防御", Buff.Value * -1)
	end

	Buff.Owner:On("单位-创建", _Reduce_Group_Amor_Per, Buff)
end

function BuffScript.Reduce_Group_Amor_Per.OnRemove(Buff)
	Buff.Owner:Off("单位-创建", _Reduce_Group_Amor_Per, Buff)
end

local function _Add_Group_Hp(Buff, Unit)
	if Unit.Camp ~= Buff.Camp then
		return
	end

	Unit:AddMul("最大生命", Buff.Value)
end

BuffScript.Add_Group_Hp = {}

function BuffScript.Add_Group_Hp.OnAdd(Buff)
	for i, unit in Buff.GL.UnitMgr:Selector():Camp(Buff.Owner.Camp):Alive():Ipairs() do
		unit:AddMul("最大生命", Buff.Value)
	end

	Buff.Owner:On("单位-创建", _Add_Group_Hp, Buff)
end

function BuffScript.Add_Group_Hp.OnRemove(Buff)
	Buff.Owner:Off("单位-创建", _Add_Group_Hp, Buff)

	for i, unit in Buff.GL.UnitMgr:Selector():Camp(Buff.Owner.Camp):Alive():Ipairs() do
		unit:AddMul("最大生命", Buff.Value * -1)
	end
end

local function _Session_Red(Buff, Unit, arg)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	local dmg = arg.Dmg

	dmg:AddPct(Buff.Value)
end

BuffScript.Session_Red = {}

function BuffScript.Session_Red.OnAdd(Buff)
	Buff.Owner:On("Session-红球发动", _Session_Red, Buff)
end

function BuffScript.Session_Red.OnRemove(Buff)
	Buff.Owner:Off("Session-红球发动", _Session_Red, Buff)
end

local function _Session_Blue(Buff, Unit, arg)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	local dmg = arg.Dmg

	dmg:AddPct(Buff.Value)
end

BuffScript.Session_Blue = {}

function BuffScript.Session_Blue.OnAdd(Buff)
	Buff.Owner:On("Session-蓝球发动", _Session_Blue, Buff)
end

function BuffScript.Session_Blue.OnRemove(Buff)
	Buff.Owner:Off("Session-蓝球发动", _Session_Blue, Buff)
end

local function _Session_Blue_ForceMp(Buff, Unit, arg)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	Unit:ForceMp(Buff.Value, Unit)
end

BuffScript.Session_Blue_ForceMp = {}

function BuffScript.Session_Blue_ForceMp.OnAdd(Buff)
	Buff.Owner:On("Session-蓝球发动", _Session_Blue_ForceMp, Buff)
end

function BuffScript.Session_Blue_ForceMp.OnRemove(Buff)
	Buff.Owner:Off("Session-蓝球发动", _Session_Blue_ForceMp, Buff)
end

local function _Session_Yellow(Buff, Unit, arg)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	local dmg = arg.Dmg

	dmg:AddPct(Buff.Value)
end

BuffScript.Session_Yellow = {}

function BuffScript.Session_Yellow.OnAdd(Buff)
	Buff.Owner:On("Session-黄球发动", _Session_Yellow, Buff)
end

function BuffScript.Session_Yellow.OnRemove(Buff)
	Buff.Owner:Off("Session-黄球发动", _Session_Yellow, Buff)
end

local function _Session_Yellow_Shield(Buff, Unit, arg)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	local addVal = 0

	if Unit.UnitClass == EnumFight.UnitClass.ENEMY then
		addVal = Unit:Get("最大护盾") * Buff.Value
	else
		addVal = Buff.GL.RunTime:GetTeamByCamp(Unit.Camp):Get("最大护盾") * Buff.Value
	end

	Unit:AddShield(addVal)
end

BuffScript.Session_Yellow_Shield = {}

function BuffScript.Session_Yellow_Shield.OnAdd(Buff)
	Buff.Owner:On("Session-黄球发动", _Session_Yellow_Shield, Buff)
end

function BuffScript.Session_Yellow_Shield.OnRemove(Buff)
	Buff.Owner:Off("Session-黄球发动", _Session_Yellow_Shield, Buff)
end

local function _Session_Red_CriticalDamage(Buff, Unit, arg)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	local dmg = arg.Dmg

	dmg:AddCriticalDamage(Buff.Value)
end

BuffScript.Session_Red_CriticalDamage = {}

function BuffScript.Session_Red_CriticalDamage.OnAdd(Buff)
	Buff.Owner:On("Session-红球发动", _Session_Red_CriticalDamage, Buff)
end

function BuffScript.Session_Red_CriticalDamage.OnRemove(Buff)
	Buff.Owner:Off("Session-红球发动", _Session_Red_CriticalDamage, Buff)
end

local function _Session_Blue_Heal(Buff, Unit, arg)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	local addVal = Unit:Get("最大生命") * Buff.Value

	Unit:HealHp(addVal, Buff.Owner, Unit)
end

BuffScript.Session_Blue_Heal = {}

function BuffScript.Session_Blue_Heal.OnAdd(Buff)
	Buff.Owner:On("Session-蓝球发动", _Session_Blue_Heal, Buff)
end

function BuffScript.Session_Blue_Heal.OnRemove(Buff)
	Buff.Owner:Off("Session-蓝球发动", _Session_Blue_Heal, Buff)
end

local function _Ignore_Buff_Type(Buff, unit, addBuff)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	local targetTypeOrders = Buff.Custom

	for i, targetTypeOrder in ipairs(targetTypeOrders) do
		if addBuff.TypeOrder == targetTypeOrder or addBuff.Type == targetTypeOrder then
			addBuff.IsMiss = true

			Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
		end
	end
end

BuffScript.Ignore_Buff_Type = {}

function BuffScript.Ignore_Buff_Type.OnAdd(Buff)
	Buff.Owner:On("单位-即将添加buff", _Ignore_Buff_Type, Buff)
end

function BuffScript.Ignore_Buff_Type.OnRemove(Buff)
	Buff.Owner:Off("单位-即将添加buff", _Ignore_Buff_Type, Buff)
end

local function _Ignore_Buff_Type_Ex(Buff, unit, addBuff)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	local cdVaild = true
	local cd = Buff:GetCustomByPropName("CD")

	if cd and Buff.ExcuteRound and Buff.ExcuteRound + cd >= Buff.Duration then
		cdVaild = false
	end

	if not cdVaild then
		return
	end

	local targetTypeOrders = Buff.Custom.Type

	for i, targetTypeOrder in ipairs(targetTypeOrders) do
		if addBuff.TypeOrder == targetTypeOrder or addBuff.Type == targetTypeOrder then
			addBuff.IsMiss = true
			Buff.ExcuteRound = Buff.Duration

			Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)

			local heal = Buff.Custom.Heal

			if heal then
				Buff.Owner:HealHp(heal * Buff.Owner:Get("最大生命"), Buff.Owner)
			end

			local buffIds = Buff.Custom.BuffIds

			if buffIds then
				for i, id in ipairs(buffIds) do
					Buff.Owner:AddBuff(id, Buff.Owner)
				end
			end
		end
	end
end

BuffScript.Ignore_Buff_Type_Ex = {}

function BuffScript.Ignore_Buff_Type_Ex.OnAdd(Buff)
	Buff.Owner:On("单位-即将添加buff", _Ignore_Buff_Type_Ex, Buff)
end

function BuffScript.Ignore_Buff_Type_Ex.OnRemove(Buff)
	Buff.Owner:Off("单位-即将添加buff", _Ignore_Buff_Type_Ex, Buff)
end

local function _Ignore_Stun(Buff, unit, addBuff)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if addBuff.Type == "Set_Not_Action" then
		addBuff.IsMiss = true

		Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
	end
end

BuffScript.Ignore_Stun = {}

function BuffScript.Ignore_Stun.OnAdd(Buff)
	Buff.Owner:On("单位-即将添加buff", _Ignore_Stun, Buff)
end

function BuffScript.Ignore_Stun.OnRemove(Buff)
	Buff.Owner:Off("单位-即将添加buff", _Ignore_Stun, Buff)
end

local function _Ignore_Frozen(Buff, unit, addBuff)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if addBuff.Type == "Set_Not_Action" then
		addBuff.IsMiss = true

		Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
	end
end

BuffScript.Ignore_Frozen = {}

function BuffScript.Ignore_Frozen.OnAdd(Buff)
	Buff.Owner:On("单位-即将添加buff", _Ignore_Frozen, Buff)
end

function BuffScript.Ignore_Frozen.OnRemove(Buff)
	Buff.Owner:Off("单位-即将添加buff", _Ignore_Frozen, Buff)
end

local function _Ignore_Sleep(Buff, unit, addBuff)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if addBuff.Type == "Set_Not_Action" then
		addBuff.IsMiss = true

		Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
	end
end

BuffScript.Ignore_Sleep = {}

function BuffScript.Ignore_Sleep.OnAdd(Buff)
	Buff.Owner:On("单位-即将添加buff", _Ignore_Sleep, Buff)
end

function BuffScript.Ignore_Sleep.OnRemove(Buff)
	Buff.Owner:Off("单位-即将添加buff", _Ignore_Sleep, Buff)
end

local function _Ignore_Stun(Buff, unit, addBuff)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if addBuff.Type == "Set_Not_Action" then
		addBuff.IsMiss = true

		Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
	end
end

BuffScript.Ignore_Stun = {}

function BuffScript.Ignore_Stun.OnAdd(Buff)
	Buff.Owner:On("单位-即将添加buff", _Ignore_Stun, Buff)
end

function BuffScript.Ignore_Stun.OnRemove(Buff)
	Buff.Owner:Off("单位-即将添加buff", _Ignore_Stun, Buff)
end

local function _Ignore_Poison(Buff, unit, addBuff)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if addBuff.Type == "Dot_Bleeding" then
		addBuff.IsMiss = true

		Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
	end
end

BuffScript.Ignore_Poison = {}

function BuffScript.Ignore_Poison.OnAdd(Buff)
	Buff.Owner:On("单位-即将添加buff", _Ignore_Poison, Buff)
end

function BuffScript.Ignore_Poison.OnRemove(Buff)
	Buff.Owner:Off("单位-即将添加buff", _Ignore_Poison, Buff)
end

local function _Ignore_Bleeding(Buff, unit, addBuff)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if addBuff.Type == "Dot_Bleeding" then
		addBuff.IsMiss = true

		Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
	end
end

BuffScript.Ignore_Bleeding = {}

function BuffScript.Ignore_Bleeding.OnAdd(Buff)
	Buff.Owner:On("单位-即将添加buff", _Ignore_Bleeding, Buff)
end

function BuffScript.Ignore_Bleeding.OnRemove(Buff)
	Buff.Owner:Off("单位-即将添加buff", _Ignore_Bleeding, Buff)
end

local function _Ignore_Burn(Buff, unit, addBuff)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if addBuff.Type == "Dot_Bleeding" then
		addBuff.IsMiss = true

		Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
	end
end

BuffScript.Ignore_Burn = {}

function BuffScript.Ignore_Burn.OnAdd(Buff)
	Buff.Owner:On("单位-即将添加buff", _Ignore_Burn, Buff)
end

function BuffScript.Ignore_Burn.OnRemove(Buff)
	Buff.Owner:Off("单位-即将添加buff", _Ignore_Burn, Buff)
end

local function _Add_Mag_Dmg_Inc(Buff, unit, dmg)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	dmg:AddPct(Buff.Value)
end

BuffScript.Add_Mag_Dmg_Inc = {}

function BuffScript.Add_Mag_Dmg_Inc.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到伤害", _Add_Mag_Dmg_Inc, Buff)
end

function BuffScript.Add_Mag_Dmg_Inc.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到伤害", _Add_Mag_Dmg_Inc, Buff)
end

local function _Add_Phy_Dmg_Inc(Buff, unit, dmg)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	dmg:AddPct(Buff.Value)
end

BuffScript.Add_Phy_Dmg_Inc = {}

function BuffScript.Add_Phy_Dmg_Inc.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到伤害", _Add_Phy_Dmg_Inc, Buff)
end

function BuffScript.Add_Phy_Dmg_Inc.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到伤害", _Add_Phy_Dmg_Inc, Buff)
end

local function _Add_Dot_Dmg_Inc(Buff, unit, dmg)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	dmg:AddDotMul(Buff.Value)
end

BuffScript.Add_Dot_Dmg_Inc = {}

function BuffScript.Add_Dot_Dmg_Inc.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到伤害", _Add_Dot_Dmg_Inc, Buff)
end

function BuffScript.Add_Dot_Dmg_Inc.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到伤害", _Add_Dot_Dmg_Inc, Buff)
end

local function _Own_Buff_Dmg_Inc(Buff, source, target, dmg)
	if source.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	local targetTypeOrders = Buff.Custom

	for i, targetTypeOrder in ipairs(targetTypeOrders) do
		if target:HasBuffTypeOrder(targetTypeOrder) or target:HasBuffType(targetTypeOrder) then
			dmg:AddPct(Buff.Value)

			break
		end
	end
end

BuffScript.Own_Buff_Dmg_Inc = {}

function BuffScript.Own_Buff_Dmg_Inc.OnAdd(Buff)
	Buff.Owner:On("单位-即将造成伤害", _Own_Buff_Dmg_Inc, Buff)
end

function BuffScript.Own_Buff_Dmg_Inc.OnRemove(Buff)
	Buff.Owner:Off("单位-即将造成伤害", _Own_Buff_Dmg_Inc, Buff)
end

local function _Own_Buff_Dmg_Inc2(Buff, source, target, dmg)
	if source.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if dmg.sourceSession == EnumFight.SessionType.none then
		return
	end

	local targetTypeOrders = Buff.Custom

	for i, targetTypeOrder in ipairs(targetTypeOrders) do
		if target:HasBuffTypeOrder(targetTypeOrder) or target:HasBuffType(targetTypeOrder) then
			dmg:AddPct(Buff.Value)

			break
		end
	end
end

BuffScript.Own_Buff_Dmg_Inc2 = {}

function BuffScript.Own_Buff_Dmg_Inc2.OnAdd(Buff)
	Buff.Owner:On("单位-即将造成伤害", _Own_Buff_Dmg_Inc2, Buff)
end

function BuffScript.Own_Buff_Dmg_Inc2.OnRemove(Buff)
	Buff.Owner:Off("单位-即将造成伤害", _Own_Buff_Dmg_Inc2, Buff)
end

local function _Own_Buff_Dmg_Crit(Buff, source, target, dmg)
	if source.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	local targetTypeOrders = Buff.Custom

	for i, targetTypeOrder in ipairs(targetTypeOrders) do
		if target:HasBuffTypeOrder(targetTypeOrder) or target:HasBuffType(targetTypeOrder) then
			dmg:AddCriticalRatio(Buff.Value)

			break
		end
	end
end

BuffScript.Own_Buff_Dmg_Crit = {}

function BuffScript.Own_Buff_Dmg_Crit.OnAdd(Buff)
	Buff.Owner:On("单位-即将造成伤害", _Own_Buff_Dmg_Crit, Buff)
end

function BuffScript.Own_Buff_Dmg_Crit.OnRemove(Buff)
	Buff.Owner:Off("单位-即将造成伤害", _Own_Buff_Dmg_Crit, Buff)
end

local function _Own_Buff_Dmg_Dec(Buff, target, dmg)
	if target.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	local targetTypeOrders = Buff.Custom

	for i, targetTypeOrder in ipairs(targetTypeOrders) do
		if target:HasBuffTypeOrder(targetTypeOrder) or target:HasBuffType(targetTypeOrder) then
			dmg:AddPct(Buff.Value * -1)

			break
		end
	end
end

BuffScript.Own_Buff_Dmg_Dec = {}

function BuffScript.Own_Buff_Dmg_Dec.OnAdd(Buff)
	Buff.Owner:On("单位-受到伤害", _Own_Buff_Dmg_Dec, Buff)
end

function BuffScript.Own_Buff_Dmg_Dec.OnRemove(Buff)
	Buff.Owner:Off("单位-受到伤害", _Own_Buff_Dmg_Dec, Buff)
end

local function _Add_CriticalRatio_Inc(Buff, unit, dmg)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	dmg:AddCriticalRatio(Buff.Value)
end

BuffScript.Add_CriticalRatio_Inc = {}

function BuffScript.Add_CriticalRatio_Inc.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到伤害", _Add_CriticalRatio_Inc, Buff)
end

function BuffScript.Add_CriticalRatio_Inc.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到伤害", _Add_CriticalRatio_Inc, Buff)
end

local function _Shield_Inc(Buff, unit, data)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	data.minusShield = data.minusShield * (1 - Buff.Value)
end

BuffScript.Shield_Inc = {}

function BuffScript.Shield_Inc.OnAdd(Buff)
	Buff.Owner:On("单位-即将扣除护盾", _Shield_Inc, Buff)
end

function BuffScript.Shield_Inc.OnRemove(Buff)
	Buff.Owner:Off("单位-即将扣除护盾", _Shield_Inc, Buff)
end

local function _Shield_Dec(Buff, unit, data)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	data.minusShield = data.minusShield * (1 + Buff.Value)
end

BuffScript.Shield_Dec = {}

function BuffScript.Shield_Dec.OnAdd(Buff)
	Buff.Owner:On("单位-即将扣除护盾", _Shield_Dec, Buff)
end

function BuffScript.Shield_Dec.OnRemove(Buff)
	Buff.Owner:Off("单位-即将扣除护盾", _Shield_Dec, Buff)
end

BuffScript.Self_Destruct = {}

function BuffScript.Self_Destruct.OnUpdate(Buff)
	if Buff.Round == 1 then
		local skillId = Buff:GetCustom()[1]

		if skillId and type(skillId) == "number" then
			Buff.Owner:CastSkill(skillId)
		else
			Buff.Owner:CastSkill(211210000)
		end
	end
end

function BuffScript.Self_Destruct.OnAdd(Buff)
	return
end

function BuffScript.Self_Destruct.OnRemove(Buff)
	return
end

local function _Force_Target_Single(Buff, Skill, selectTargetList)
	if not Buff.SourceUniqueId then
		return
	end

	if not selectTargetList then
		return
	end

	if #selectTargetList ~= 1 then
		return
	end

	if Skill.Owner.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	local buffSourceUnit = Buff.GL.UnitMgr:FindUnitById(Buff.SourceUniqueId)

	if buffSourceUnit and buffSourceUnit:Get("生命") > 0 and buffSourceUnit.Camp == selectTargetList[1].Camp then
		selectTargetList[1] = buffSourceUnit
	end
end

BuffScript.Force_Target_Single = {}

function BuffScript.Force_Target_Single.OnAdd(Buff)
	Buff.Owner:On("技能-即将选择目标", _Force_Target_Single, Buff)
end

function BuffScript.Force_Target_Single.OnRemove(Buff)
	Buff.Owner:Off("技能-即将选择目标", _Force_Target_Single, Buff)
end

local function _Stack_Power_Increase(Buff, Skill, data)
	if Skill.Owner.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	data.addStack = data.addStack + Buff.Value
end

BuffScript.Stack_Power_Increase = {}

function BuffScript.Stack_Power_Increase.OnAdd(Buff)
	Buff.Owner:On("技能-即将更新强化层数", _Stack_Power_Increase, Buff)
end

function BuffScript.Stack_Power_Increase.OnRemove(Buff)
	Buff.Owner:Off("技能-即将更新强化层数", _Stack_Power_Increase, Buff)
end

local function _Stack_Power_Increase2(Buff, Skill, data)
	if Skill.Owner.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	data.powerMul = Buff.Value
end

BuffScript.Stack_Power_Increase2 = {}

function BuffScript.Stack_Power_Increase2.OnAdd(Buff)
	Buff.Owner:On("黄球加强-即将发动", _Stack_Power_Increase2, Buff)
end

function BuffScript.Stack_Power_Increase2.OnRemove(Buff)
	Buff.Owner:Off("黄球加强-即将发动", _Stack_Power_Increase2, Buff)
end

local function _Shield_ConsumeRatio_Change(Buff, Unit, data)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	data.shieldRatio = data.shieldRatio + Buff.Value
end

BuffScript.Shield_ConsumeRatio_Change = {}

function BuffScript.Shield_ConsumeRatio_Change.OnAdd(Buff)
	Buff.Owner:On("单位-即将产生护盾效果", _Shield_ConsumeRatio_Change, Buff)
end

function BuffScript.Shield_ConsumeRatio_Change.OnRemove(Buff)
	Buff.Owner:Off("单位-即将产生护盾效果", _Shield_ConsumeRatio_Change, Buff)
end

local function _Add_Atk_Per_EveryRound(Buff, Unit, UpdateBuff)
	if Buff.UID ~= UpdateBuff.UID then
		return
	end

	local addVal = Buff.Duration * Buff.Value

	Buff.Owner:AddMul("物理攻击", addVal)
	Buff.Owner:AddMul("魔法攻击", addVal)
end

BuffScript.Add_Atk_EveryRound = {}

function BuffScript.Add_Atk_EveryRound.OnAdd(Buff)
	Buff.Owner:On("单位-更新buff", _Add_Atk_Per_EveryRound, Buff)
end

function BuffScript.Add_Atk_EveryRound.OnRemove(Buff)
	Buff.Owner:Off("单位-更新buff", _Add_Atk_Per_EveryRound, Buff)
end

local function _Im_Back(Buff, unit)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)

	local hp = unit:Get("最大生命") * Buff.Value

	if hp > 0 then
		unit:Add("生命", hp)
	end

	if Buff.Value < 9999 then
		Buff:RemoveSelf()
	end

	unit:RemoveAllBuff()
end

BuffScript.Im_Back = {}

function BuffScript.Im_Back.OnAdd(Buff)
	Buff.Owner:On("单位-即将死亡2", _Im_Back, Buff)
end

function BuffScript.Im_Back.OnRemove(Buff)
	Buff.Owner:Off("单位-即将死亡2", _Im_Back, Buff)
end

local function _No_Dead(Buff, unit)
	if unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
	unit:Add("生命", Buff.Value)

	if Buff.Value < 9999 then
		Buff:RemoveSelf()
	end

	unit:RemoveAllBuff()
end

BuffScript.No_Dead = {}

function BuffScript.No_Dead.OnAdd(Buff)
	Buff.Owner:On("单位-即将死亡", _No_Dead, Buff)
end

function BuffScript.No_Dead.OnRemove(Buff)
	Buff.Owner:Off("单位-即将死亡", _No_Dead, Buff)
end

local function _Force_Attack(Buff, Skill)
	if Skill.Owner.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	Buff:RemoveSelf()
end

local function _Force_Attack2(Buff, Unit, NewBuff)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if NewBuff.Type == "Set_Not_Action" or NewBuff.Type == "Dot_Bleeding" then
		NewBuff.IsMiss = true
	end
end

BuffScript.Force_Attack = {}

function BuffScript.Force_Attack.OnAdd(Buff)
	Buff.Owner:On("单位-即将添加buff", _Force_Attack2, Buff)
	Buff.Owner:On("伤害类技能释放结束", _Force_Attack, Buff)
	Buff.Owner:Add("增伤", Buff.Value)
end

function BuffScript.Force_Attack.OnRemove(Buff)
	Buff.Owner:Off("单位-即将添加buff", _Force_Attack2, Buff)
	Buff.Owner:Off("伤害类技能释放结束", _Force_Attack, Buff)
	Buff.Owner:Add("增伤", Buff.Value * -1)
end

local function _Stake_Force_Attack_Dmg(Buff, Unit, Dmg)
	if Buff.Owner.UniqueId ~= Unit.UniqueId then
		return
	end

	Buff.TempData.curVal = Buff.TempData.curVal + Dmg.finalMinusHp

	if Buff.TempData.curVal >= Buff.TempData.destVal then
		Buff:RemoveSelf()
	end
end

BuffScript.Stake_Force_Attack = {}

function BuffScript.Stake_Force_Attack.OnAdd(Buff)
	Buff.TempData = {}
	Buff.TempData.destVal = Buff.Value * Buff.Owner:Get("最大生命")
	Buff.TempData.curVal = 0

	Buff.Owner:On("单位-受到伤害", _Stake_Force_Attack_Dmg, Buff)
	Buff.Owner:SetNotAction(true)
	Buff.Owner:SetNextActionSkillId()
end

function BuffScript.Stake_Force_Attack.OnRemove(Buff)
	Buff.Owner:SetNotAction(false)
	Buff.Owner:Off("单位-受到伤害", _Stake_Force_Attack_Dmg, Buff)

	if Buff.TempData.curVal >= Buff.TempData.destVal then
		Buff.Owner:ResetLastSkillIdx()

		local faildBuffIds = Buff:GetCustomByPropName("FailBuffs")

		if faildBuffIds then
			for _, id in ipairs(faildBuffIds) do
				Buff.Owner:AddBuff(id, Buff.Owner.UniqueId)
			end
		end

		if Buff.Owner.NotAction == true then
			Buff.Owner:SetNextActionSkillId()
		end
	end

	Buff.TempData = {}
end

local function _Add_Attri_AfterAttack_Times(Buff, Skill)
	if Skill.Owner.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	Buff:AddStack(-1)

	if Buff.Stack == 0 then
		Buff:RemoveSelf()
	end
end

BuffScript.Add_Attri_AfterAttack_Times = {}

function BuffScript.Add_Attri_AfterAttack_Times.OnAdd(Buff)
	Buff.MaxStack = Buff:GetCustomByPropName("Time")
	Buff.Stack = Buff.MaxStack

	if Buff:GetCustomByPropName("Val") then
		Buff.Owner:Add(Buff:GetCustomByPropName("Attri"), Buff.Value)
	else
		Buff.Owner:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value)
	end

	Buff.Owner:On("伤害类技能释放结束", _Add_Attri_AfterAttack_Times, Buff)
end

function BuffScript.Add_Attri_AfterAttack_Times.OnRemove(Buff)
	if Buff:GetCustomByPropName("Val") then
		Buff.Owner:Add(Buff:GetCustomByPropName("Attri"), Buff.Value * -1)
	else
		Buff.Owner:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value * -1)
	end

	Buff.Owner:Off("伤害类技能释放结束", _Add_Attri_AfterAttack_Times, Buff)
end

local function _Add_Buff_AfterAttack_Times(Buff, Skill)
	if Skill.Owner.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	Buff.TempData = Buff.TempData - 1

	if Buff.TempData > 0 then
		return
	end

	Buff.TempData = Buff:GetCustomByPropName("Times")

	local ids = Buff:GetCustomByPropName("Buffs")

	for i, id in ipairs(ids) do
		Buff.Owner:AddBuff(id, Buff.Owner.UniqueId)
	end
end

BuffScript.Add_Buff_AfterAttack_Times = {}

function BuffScript.Add_Buff_AfterAttack_Times.OnAdd(Buff)
	Buff.TempData = Buff:GetCustomByPropName("Times")

	Buff.Owner:On("伤害类技能释放结束", _Add_Buff_AfterAttack_Times, Buff)
end

function BuffScript.Add_Buff_AfterAttack_Times.OnRemove(Buff)
	Buff.Owner:Off("伤害类技能释放结束", _Add_Buff_AfterAttack_Times, Buff)
end

local function _Add_Buff_Stack_TakeDamage(Buff, Skill)
	if not Skill.Targets then
		return
	end

	for i, target in ipairs(Skill.Targets) do
		if target.UniqueId == Buff.Owner.UniqueId then
			local probability = Buff:GetCustomByPropName("Percent")

			if probability >= Skill.GL:Random() then
				local id = Buff:GetCustomByPropName("BuffId")
				local addStackCount = Buff:GetCustomByPropName("Stack")

				for i = 1, addStackCount do
					Skill.Owner:AddBuff(id, Buff.Owner.UniqueId)
				end
			end
		end
	end
end

BuffScript.Add_Buff_Stack_TakeDamage = {}

function BuffScript.Add_Buff_Stack_TakeDamage.OnAdd(Buff)
	Buff.Owner:On("伤害类技能释放结束", _Add_Buff_Stack_TakeDamage, Buff)
end

function BuffScript.Add_Buff_Stack_TakeDamage.OnRemove(Buff)
	Buff.Owner:Off("伤害类技能释放结束", _Add_Buff_Stack_TakeDamage, Buff)
end

local function _Add_Buff_TakeDamage(Buff, Skill)
	for i, target in ipairs(Skill.Targets) do
		if target.UniqueId == Buff.Owner.UniqueId then
			local probability = Buff:GetCustomByPropName("Percent")

			if probability >= Skill.GL:Random() then
				local id = Buff:GetCustomByPropName("BuffId")

				Skill.Owner:AddBuff(id, Buff.Owner.UniqueId)
			end
		end
	end
end

BuffScript.Add_Buff_TakeDamage = {}

function BuffScript.Add_Buff_TakeDamage.OnAdd(Buff)
	Buff.Owner:On("伤害类技能释放结束", _Add_Buff_TakeDamage, Buff)
end

function BuffScript.Add_Buff_TakeDamage.OnRemove(Buff)
	Buff.Owner:Off("伤害类技能释放结束", _Add_Buff_TakeDamage, Buff)
end

local function _Disable_Shield(Buff, team, addData)
	if team.Camp == Buff.Owner.Camp then
		return
	end

	if addData.addVal > 0 then
		addData.addVal = 0
	end
end

BuffScript.Disable_Shield = {}

function BuffScript.Disable_Shield.OnAdd(Buff)
	Buff.Owner:On("队伍-即将更变护盾", _Disable_Shield, Buff)
end

function BuffScript.Disable_Shield.OnRemove(Buff)
	Buff.Owner:Off("队伍-即将更变护盾", _Disable_Shield, Buff)
end

local function _Disable_Shield_Breaked(Buff, team, addData)
	if team.Camp ~= Buff.Owner.Camp then
		return
	end

	if addData.addVal > 0 then
		addData.addVal = 0
	end
end

BuffScript.Disable_Shield_Breaked = {}

function BuffScript.Disable_Shield_Breaked.OnAdd(Buff)
	Buff.Owner:On("队伍-即将更变护盾", _Disable_Shield_Breaked, Buff)
end

function BuffScript.Disable_Shield_Breaked.OnRemove(Buff)
	Buff.Owner:Off("队伍-即将更变护盾", _Disable_Shield_Breaked, Buff)
end

local function _Disable_Heal(Buff, Unit, addHpData)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	addHpData.addVal = 0
end

BuffScript.Disable_Heal = {}

function BuffScript.Disable_Heal.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到治疗", _Disable_Heal, Buff)
end

function BuffScript.Disable_Heal.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到治疗", _Disable_Heal, Buff)
end

local function _Power_Heal(Buff, Unit, addHpData)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	addHpData.addVal = addHpData.addVal * (1 + Buff.Value)
end

BuffScript.Power_Heal = {}

function BuffScript.Power_Heal.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到治疗", _Power_Heal, Buff)
end

function BuffScript.Power_Heal.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到治疗", _Power_Heal, Buff)
end

local function _Power_Heal_Source(Buff, target, healer, addHpData)
	if healer.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	addHpData.addVal = addHpData.addVal * Buff.Value
end

BuffScript.Power_Heal_Source = {}

function BuffScript.Power_Heal_Source.OnAdd(Buff)
	Buff.Owner:On("单位-即将治疗目标", _Power_Heal_Source, Buff)
end

function BuffScript.Power_Heal_Source.OnRemove(Buff)
	Buff.Owner:Off("单位-即将治疗目标", _Power_Heal_Source, Buff)
end

local function _Heal_When_OtherCamp_Heal(Buff, target, healer, addHpData)
	if healer.Camp == Buff.Owner.Camp then
		return
	end

	if Buff.TempData and Buff.TempData == Buff.GL.RunTime.CurRound then
		return
	end

	Buff.TempData = Buff.GL.RunTime.CurRound

	local owner = Buff.Owner
	local healVal = Buff.Value * owner:Get("最大生命")

	owner:HealHp(healVal, owner)

	local buffIds = Buff.Custom.BuffIds

	if buffIds then
		for i, id in ipairs(buffIds) do
			owner:AddBuff(id, owner)
		end
	end
end

BuffScript.Heal_When_OtherCamp_Heal = {}

function BuffScript.Heal_When_OtherCamp_Heal.OnAdd(Buff)
	Buff.Owner:On("单位-即将治疗目标", _Heal_When_OtherCamp_Heal, Buff)
end

function BuffScript.Heal_When_OtherCamp_Heal.OnRemove(Buff)
	Buff.Owner:Off("单位-即将治疗目标", _Heal_When_OtherCamp_Heal, Buff)
end

BuffScript.Disable_Skill = {}

function BuffScript.Disable_Skill.OnAdd(Buff)
	Buff.Owner:SetDisableCardSkill(true)
end

function BuffScript.Disable_Skill.OnRemove(Buff)
	Buff.Owner:SetDisableCardSkill(false)
end

local function _Add_Buff_Pr_Cast(Buff, CastUnit, TargetUnit, Data)
	if Buff.Owner.UniqueId ~= CastUnit.UniqueId then
		return
	end

	Data.pr = Data.pr - Buff.Value
end

BuffScript.Add_Buff_Pr_Cast = {}

function BuffScript.Add_Buff_Pr_Cast.OnAdd(Buff)
	Buff.Owner:On("单位-即将随机buff", _Add_Buff_Pr_Cast, Buff)
end

function BuffScript.Add_Buff_Pr_Cast.OnRemove(Buff)
	Buff.Owner:Off("单位-即将随机buff", _Add_Buff_Pr_Cast, Buff)
end

local function _Add_Buff_Pr_Suffer(Buff, CastUnit, TargetUnit, Data)
	if Buff.Owner.UniqueId ~= TargetUnit.UniqueId then
		return
	end

	Data.pr = Data.pr + Buff.Value
end

BuffScript.Add_Buff_Pr_Suffer = {}

function BuffScript.Add_Buff_Pr_Suffer.OnAdd(Buff)
	Buff.Owner:On("单位-即将被随机buff", _Add_Buff_Pr_Suffer, Buff)
end

function BuffScript.Add_Buff_Pr_Suffer.OnRemove(Buff)
	Buff.Owner:Off("单位-即将被随机buff", _Add_Buff_Pr_Suffer, Buff)
end

local function _Dodge_Damage(Buff, Unit, dmg)
	if Unit.UniqueId ~= Buff.Owner.UniqueId then
		return
	end

	if dmg.dmgType == EnumFight.DamageType.Dot then
		return
	end

	local pr = Buff.GL:Random()

	if pr <= Buff.Value then
		dmg.dmgType = EnumFight.DamageType.Invalid
	end
end

BuffScript.Dodge_Damage = {}

function BuffScript.Dodge_Damage.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到伤害", _Dodge_Damage, Buff)
end

function BuffScript.Dodge_Damage.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到伤害", _Dodge_Damage, Buff)
end

local function _Death_Is_Coming(Buff, Skill)
	if Buff.Owner.UniqueId ~= Skill.Owner.UniqueId then
		return
	end

	Buff:RemoveSelf()
end

BuffScript.Death_Is_Coming = {}

function BuffScript.Death_Is_Coming.OnAdd(Buff)
	Buff.Owner:On("技能-释放结束", _Death_Is_Coming, Buff)
end

function BuffScript.Death_Is_Coming.OnUpdate(Buff)
	if Buff.Round == 1 then
		local unit = Buff.Owner

		Buff.Owner:Set("生命", 0)
		Buff:RemoveSelf()
	end
end

function BuffScript.Death_Is_Coming.OnRemove(Buff)
	Buff.Owner:Off("技能-释放结束", _Death_Is_Coming, Buff)
end

local function _Add_Attri_Dodging(Buff, Unit, Dmg)
	if Buff.Owner.UniqueId ~= Unit.UniqueId then
		return
	end

	local max = Buff:GetCustomByPropName("MaxStack")

	if not max then
		return
	end

	if max <= Buff.Stack then
		return
	end

	Buff:AddStack(1)

	if Buff:GetCustomByPropName("Val") then
		Buff.Owner:Add(Buff:GetCustomByPropName("Attri"), Buff.Value)
	else
		Buff.Owner:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value)
	end
end

BuffScript.Add_Attri_Dodging = {}

function BuffScript.Add_Attri_Dodging.OnAdd(Buff)
	Buff.Owner:On("单位-闪避", _Add_Attri_Dodging, Buff)
end

function BuffScript.Add_Attri_Dodging.OnRemove(Buff)
	Buff.Owner:Off("单位-闪避", _Add_Attri_Dodging, Buff)

	if Buff:GetCustomByPropName("Val") then
		Buff.Owner:Add(Buff:GetCustomByPropName("Attri"), Buff.Value * Buff.Stack * -1)
	else
		Buff.Owner:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value * Buff.Stack * -1)
	end
end

local function _Add_Attri_Atking(Buff, Source, Unit, Dmg)
	if Buff.Owner.UniqueId ~= Source.UniqueId then
		return
	end

	if Dmg.dmgType ~= EnumFight.DamageType.Std then
		return
	end

	local max = Buff:GetCustomByPropName("MaxStack")

	if not max then
		return
	end

	if max <= Buff.Stack then
		return
	end

	Buff:AddStack(1)

	if Buff:GetCustomByPropName("Val") then
		Buff.Owner:Add(Buff:GetCustomByPropName("Attri"), Buff.Value)
	else
		Buff.Owner:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value)
	end
end

BuffScript.Add_Attri_Atking = {}

function BuffScript.Add_Attri_Atking.OnAdd(Buff)
	Buff.Owner:On("单位-造成伤害", _Add_Attri_Atking, Buff)
end

function BuffScript.Add_Attri_Atking.OnRemove(Buff)
	Buff.Owner:Off("单位-造成伤害", _Add_Attri_Atking, Buff)

	if Buff:GetCustomByPropName("Val") then
		Buff.Owner:Add(Buff:GetCustomByPropName("Attri"), Buff.Value * Buff.Stack * -1)
	else
		Buff.Owner:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value * Buff.Stack * -1)
	end
end

local function _Add_Attri_Criting(Buff, Source, Unit, Dmg)
	if Buff.Owner.UniqueId ~= Source.UniqueId then
		return
	end

	if Dmg.dmgType ~= EnumFight.DamageType.Std then
		return
	end

	if Dmg.isCritical == false then
		return
	end

	local max = Buff:GetCustomByPropName("MaxStack")

	if not max then
		return
	end

	if max <= Buff.Stack then
		return
	end

	Buff:AddStack(1)

	if Buff:GetCustomByPropName("Val") then
		Buff.Owner:Add(Buff:GetCustomByPropName("Attri"), Buff.Value)
	else
		Buff.Owner:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value)
	end
end

BuffScript.Add_Attri_Criting = {}

function BuffScript.Add_Attri_Criting.OnAdd(Buff)
	Buff.Owner:On("单位-造成伤害", _Add_Attri_Criting, Buff)
end

function BuffScript.Add_Attri_Criting.OnRemove(Buff)
	Buff.Owner:Off("单位-造成伤害", _Add_Attri_Criting, Buff)

	if Buff:GetCustomByPropName("Val") then
		Buff.Owner:Add(Buff:GetCustomByPropName("Attri"), Buff.Value * Buff.Stack * -1)
	else
		Buff.Owner:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value * Buff.Stack * -1)
	end
end

local function _Add_Attri_TakeDmging(Buff, Unit, Dmg)
	if Buff.Owner.UniqueId ~= Unit.UniqueId then
		return
	end

	if Dmg.dmgType ~= EnumFight.DamageType.Std then
		return
	end

	local max = Buff:GetCustomByPropName("MaxStack")

	if not max then
		return
	end

	if max <= Buff.Stack then
		return
	end

	Buff:AddStack(1)

	if Buff:GetCustomByPropName("Val") then
		Buff.Owner:Add(Buff:GetCustomByPropName("Attri"), Buff.Value)
	else
		Buff.Owner:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value)
	end
end

BuffScript.Add_Attri_TakeDmging = {}

function BuffScript.Add_Attri_TakeDmging.OnAdd(Buff)
	Buff.Owner:On("单位-受到伤害", _Add_Attri_TakeDmging, Buff)
end

function BuffScript.Add_Attri_TakeDmging.OnRemove(Buff)
	Buff.Owner:Off("单位-受到伤害", _Add_Attri_TakeDmging, Buff)

	if Buff:GetCustomByPropName("Val") then
		Buff.Owner:Add(Buff:GetCustomByPropName("Attri"), Buff.Value * Buff.Stack * -1)
	else
		Buff.Owner:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value * Buff.Stack * -1)
	end
end

local function _Add_Attri_TakeCriting(Buff, Unit, Dmg)
	if Buff.Owner.UniqueId ~= Unit.UniqueId then
		return
	end

	if Dmg.dmgType ~= EnumFight.DamageType.Std then
		return
	end

	if Dmg.isCritical == false then
		return
	end

	local max = Buff:GetCustomByPropName("MaxStack")

	if not max then
		return
	end

	if max <= Buff.Stack then
		return
	end

	Buff:AddStack(1)

	if Buff:GetCustomByPropName("Val") then
		Buff.Owner:Add(Buff:GetCustomByPropName("Attri"), Buff.Value)
	else
		Buff.Owner:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value)
	end
end

BuffScript.Add_Attri_TakeCriting = {}

function BuffScript.Add_Attri_TakeCriting.OnAdd(Buff)
	Buff.Owner:On("单位-受到伤害", _Add_Attri_TakeCriting, Buff)
end

function BuffScript.Add_Attri_TakeCriting.OnRemove(Buff)
	Buff.Owner:Off("单位-受到伤害", _Add_Attri_TakeCriting, Buff)

	if Buff:GetCustomByPropName("Val") then
		Buff.Owner:Add(Buff:GetCustomByPropName("Attri"), Buff.Value * Buff.Stack * -1)
	else
		Buff.Owner:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value * Buff.Stack * -1)
	end
end

local function _Add_Attri_Sessioning(Buff, Unit, SessionType)
	if Buff.Owner.UniqueId ~= Unit.UniqueId then
		return
	end

	if SessionType ~= Buff:GetCustomByPropName("SessionType") then
		return
	end

	local max = Buff:GetCustomByPropName("MaxStack")

	if not max then
		return
	end

	if max <= Buff.Stack then
		return
	end

	Buff:AddStack(1)

	if Buff:GetCustomByPropName("Val") then
		Buff.Owner:Add(Buff:GetCustomByPropName("Attri"), Buff.Value)
	else
		Buff.Owner:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value)
	end
end

BuffScript.Add_Attri_Sessioning = {}

function BuffScript.Add_Attri_Sessioning.OnAdd(Buff)
	Buff.Owner:On("Session-球发动", _Add_Attri_Sessioning, Buff)
end

function BuffScript.Add_Attri_Sessioning.OnRemove(Buff)
	Buff.Owner:Off("Session-球发动", _Add_Attri_Sessioning, Buff)

	if Buff:GetCustomByPropName("Val") then
		Buff.Owner:Add(Buff:GetCustomByPropName("Attri"), Buff.Value * Buff.Stack * -1)
	else
		Buff.Owner:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value * Buff.Stack * -1)
	end
end

local function _Reduce_Attri_Sessioning(Buff, Source, Unit, Dmg)
	if Buff.Owner.UniqueId ~= Source.UniqueId then
		return
	end

	if Dmg.dmgType ~= EnumFight.DamageType.Std then
		return
	end

	if Dmg.sourceSession ~= Buff:GetCustomByPropName("SessionType") then
		return
	end

	local max = Buff:GetCustomByPropName("MaxStack")

	if not max then
		return
	end

	if max <= Buff.Stack then
		return
	end

	Buff:AddStack(1)

	if Buff:GetCustomByPropName("Val") then
		Buff.Owner:Add(Buff:GetCustomByPropName("Attri"), Buff.Value * -1)
	else
		Buff.Owner:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value * -1)
	end
end

BuffScript.Reduce_Attri_Sessioning = {}

function BuffScript.Reduce_Attri_Sessioning.OnAdd(Buff)
	Buff.Owner:On("单位-造成伤害", _Reduce_Attri_Sessioning, Buff)
end

function BuffScript.Reduce_Attri_Sessioning.OnRemove(Buff)
	Buff.Owner:Off("单位-造成伤害", _Reduce_Attri_Sessioning, Buff)

	if Buff:GetCustomByPropName("Val") then
		Buff.Owner:Add(Buff:GetCustomByPropName("Attri"), Buff.Value * Buff.Stack)
	else
		Buff.Owner:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value * Buff.Stack)
	end
end

local function _Add_Atk_Sessioning(Buff, Unit, SessionType)
	if Buff.Owner.UniqueId ~= Unit.UniqueId then
		return
	end

	if SessionType ~= Buff:GetCustomByPropName("SessionType") then
		return
	end

	local max = Buff:GetCustomByPropName("MaxStack")

	if not max then
		return
	end

	if max <= Buff.Stack then
		return
	end

	Buff:AddStack(1)
	Buff.Owner:AddMul("物理攻击", Buff.Value)
	Buff.Owner:AddMul("魔法攻击", Buff.Value)
end

BuffScript.Add_Atk_Sessioning = {}

function BuffScript.Add_Atk_Sessioning.OnAdd(Buff)
	Buff.Owner:On("Session-球发动", _Add_Atk_Sessioning, Buff)
end

function BuffScript.Add_Atk_Sessioning.OnRemove(Buff)
	Buff.Owner:Off("Session-球发动", _Add_Atk_Sessioning, Buff)
	Buff.Owner:AddMul("物理攻击", Buff.Value * Buff.Stack * -1)
	Buff.Owner:AddMul("魔法攻击", Buff.Value * Buff.Stack * -1)
end

local function _Reduce_Atk_Sessioning(Buff, Source, Unit, Dmg)
	if Buff.Owner.UniqueId ~= Source.UniqueId then
		return
	end

	if Dmg.dmgType ~= EnumFight.DamageType.Std then
		return
	end

	if Dmg.sourceSession ~= Buff:GetCustomByPropName("SessionType") then
		return
	end

	local max = Buff:GetCustomByPropName("MaxStack")

	if not max then
		return
	end

	if max <= Buff.Stack then
		return
	end

	Buff:AddStack(1)
	Buff.Owner:AddMul("物理攻击", Buff.Value * -1)
	Buff.Owner:AddMul("魔法攻击", Buff.Value * -1)
end

BuffScript.Reduce_Atk_Sessioning = {}

function BuffScript.Reduce_Atk_Sessioning.OnAdd(Buff)
	Buff.Owner:On("单位-造成伤害", _Reduce_Atk_Sessioning, Buff)
end

function BuffScript.Reduce_Atk_Sessioning.OnRemove(Buff)
	Buff.Owner:Off("单位-造成伤害", _Reduce_Atk_Sessioning, Buff)
	Buff.Owner:AddMul("物理攻击", Buff.Value * Buff.Stack)
	Buff.Owner:AddMul("魔法攻击", Buff.Value * Buff.Stack)
end

local function _Session_Dmg_Buff(Buff, Source, Unit, Dmg)
	if Buff.Owner.UniqueId ~= Source.UniqueId then
		return
	end

	if Dmg.dmgType ~= EnumFight.DamageType.Std then
		return
	end

	local sessionVaild, success = false, false

	if Buff:GetCustomByPropName("SessionTypes")[1] == -1 then
		sessionVaild = true
	end

	for i, sessionType in ipairs(Buff:GetCustomByPropName("SessionTypes")) do
		if Dmg.sourceSession == sessionType then
			sessionVaild = true

			break
		end
	end

	if sessionVaild == false then
		return
	end

	local cfgPr = Buff:GetCustomByPropName("Percent")

	if cfgPr then
		if cfgPr * 100 >= RandomUtil.Get(100) then
			success = true
		end
	else
		success = true
	end

	if success == false then
		return
	end

	local buffIds = Buff:GetCustomByPropName("Buffs")
	local isSelf = Buff:GetCustomByPropName("isSelf")
	local isFriend = Buff:GetCustomByPropName("isFriend")

	if isSelf then
		for i, id in ipairs(buffIds) do
			Buff.Owner:AddBuff(id, Source.UniqueId)
		end
	elseif isFriend then
		for i, u in Buff.GL.UnitMgr:Selector():Camp(Buff.Owner.Camp):Alive():Ipairs() do
			for i, id in ipairs(buffIds) do
				u:AddBuff(id, Source.UniqueId)
			end
		end
	else
		for i, id in ipairs(buffIds) do
			Unit:AddBuff(id, Source.UniqueId)
		end
	end
end

BuffScript.Session_Dmg_Buff = {}

function BuffScript.Session_Dmg_Buff.OnAdd(Buff)
	Buff.Owner:On("单位-造成伤害", _Session_Dmg_Buff, Buff)
end

function BuffScript.Session_Dmg_Buff.OnRemove(Buff)
	Buff.Owner:Off("单位-造成伤害", _Session_Dmg_Buff, Buff)
end

local function _Session_Dmg_Buff_Mut1(Buff, Source, Unit, Dmg)
	if Dmg.mut ~= 1 then
		return
	end

	_Session_Dmg_Buff(Buff, Source, Unit, Dmg)
end

BuffScript.Session_Dmg_Buff_Mut1 = {}

function BuffScript.Session_Dmg_Buff_Mut1.OnAdd(Buff)
	Buff.Owner:On("单位-造成伤害", _Session_Dmg_Buff_Mut1, Buff)
end

function BuffScript.Session_Dmg_Buff_Mut1.OnRemove(Buff)
	Buff.Owner:Off("单位-造成伤害", _Session_Dmg_Buff_Mut1, Buff)
end

local function _Session_Dmg_Buff_Criti(Buff, Source, Unit, Dmg)
	if Buff.Owner.UniqueId ~= Source.UniqueId then
		return
	end

	if Dmg.dmgType ~= EnumFight.DamageType.Std then
		return
	end

	local sessionVaild, success = false, false

	for i, sessionType in ipairs(Buff:GetCustomByPropName("SessionTypes")) do
		if Dmg.sourceSession == sessionType then
			sessionVaild = true

			break
		end
	end

	if sessionVaild == false then
		return
	end

	if Dmg.isCritical == true then
		success = true
	end

	if success == false then
		return
	end

	local buffIds = Buff:GetCustomByPropName("Buffs")
	local isSelf = Buff:GetCustomByPropName("isSelf")
	local isFriend = Buff:GetCustomByPropName("isFriend")

	if isSelf then
		for i, id in ipairs(buffIds) do
			Buff.Owner:AddBuff(id, Source.UniqueId)
		end
	elseif isFriend then
		for i, u in Buff.GL.UnitMgr:Selector():Camp(Buff.Owner.Camp):Alive():Ipairs() do
			for i, id in ipairs(buffIds) do
				u:AddBuff(id, Source.UniqueId)
			end
		end
	else
		for i, id in ipairs(buffIds) do
			Unit:AddBuff(id, Source.UniqueId)
		end
	end
end

BuffScript.Session_Dmg_Buff_Criti = {}

function BuffScript.Session_Dmg_Buff_Criti.OnAdd(Buff)
	Buff.Owner:On("单位-造成伤害", _Session_Dmg_Buff_Criti, Buff)
end

function BuffScript.Session_Dmg_Buff_Criti.OnRemove(Buff)
	Buff.Owner:Off("单位-造成伤害", _Session_Dmg_Buff_Criti, Buff)
end

local function _Session_Dmg_Buff_Criti_Mut1(Buff, Source, Unit, Dmg)
	if Dmg.mut ~= 1 then
		return
	end

	_Session_Dmg_Buff_Criti(Buff, Source, Unit, Dmg)
end

BuffScript.Session_Dmg_Buff_Criti_Mut1 = {}

function BuffScript.Session_Dmg_Buff_Criti_Mut1.OnAdd(Buff)
	Buff.Owner:On("单位-造成伤害", _Session_Dmg_Buff_Criti_Mut1, Buff)
end

function BuffScript.Session_Dmg_Buff_Criti_Mut1.OnRemove(Buff)
	Buff.Owner:Off("单位-造成伤害", _Session_Dmg_Buff_Criti_Mut1, Buff)
end

local function _Take_Dmg_Buff(Buff, Unit, dmg)
	if Buff.Owner.UniqueId ~= Unit.UniqueId then
		return
	end

	if dmg.dmgType ~= EnumFight.DamageType.Std then
		return
	end

	if Buff:GetCustomByPropName("Once") and dmg.mut ~= 1 then
		return
	end

	local success = false
	local cfgPr = Buff:GetCustomByPropName("Percent")

	if cfgPr then
		if cfgPr * 100 >= RandomUtil.Get(100) then
			success = true
		end
	else
		success = true
	end

	if success == false then
		return
	end

	local source = Buff.GL.UnitMgr:FindUnitById(dmg.srcUniqueId)

	if not source then
		return
	end

	local buffIds = Buff:GetCustomByPropName("Buffs")

	for i, id in ipairs(buffIds) do
		source:AddBuff(id, Buff.Owner.UniqueId)
	end
end

BuffScript.Take_Dmg_Buff = {}

function BuffScript.Take_Dmg_Buff.OnAdd(Buff)
	Buff.Owner:On("单位-受到伤害", _Take_Dmg_Buff, Buff)
end

function BuffScript.Take_Dmg_Buff.OnRemove(Buff)
	Buff.Owner:Off("单位-受到伤害", _Take_Dmg_Buff, Buff)
end

local function _TakeDmging_AddShieldValue(Buff, Unit, dmg)
	if Buff.Owner.UniqueId ~= Unit.UniqueId then
		return
	end

	if dmg.dmgType ~= EnumFight.DamageType.Std then
		return
	end

	if Buff:GetCustomByPropName("Once") and dmg.mut ~= 1 then
		return
	end

	local success = false
	local cfgPr = Buff:GetCustomByPropName("Percent")

	if cfgPr then
		if cfgPr * 100 >= RandomUtil.Get(100) then
			success = true
		end
	else
		success = true
	end

	if success == false then
		return
	end

	local shield = Buff.GL.RunTime:GetTeamByCamp(Unit.Camp):Get("最大护盾") * Buff.Value

	Unit:AddShield(shield)
end

BuffScript.TakeDmging_AddShieldValue = {}

function BuffScript.TakeDmging_AddShieldValue.OnAdd(Buff)
	Buff.Owner:On("单位-受到伤害", _TakeDmging_AddShieldValue, Buff)
end

function BuffScript.TakeDmging_AddShieldValue.OnRemove(Buff)
	Buff.Owner:Off("单位-受到伤害", _TakeDmging_AddShieldValue, Buff)
end

local function _TakeDmging_HealValue(Buff, Unit, dmg)
	if Buff.Owner.UniqueId ~= Unit.UniqueId then
		return
	end

	if dmg.dmgType ~= EnumFight.DamageType.Std then
		return
	end

	if Buff:GetCustomByPropName("Once") and dmg.mut ~= 1 then
		return
	end

	local success = false
	local cfgPr = Buff:GetCustomByPropName("Percent")

	if cfgPr then
		if cfgPr * 100 >= RandomUtil.Get(100) then
			success = true
		end
	else
		success = true
	end

	if success == false then
		return
	end

	local CriticalHeal = Buff:GetCustomByPropName("CriticalHeal")

	if CriticalHeal then
		if dmg.isCritical == true and Unit:Get("生命") > 0 then
			local hp = (Unit:Get("最大生命") - Unit:Get("生命")) * Buff.Value

			Unit:HealHp(hp, Unit)
		end

		return
	end

	local hp = Unit:Get("最大生命") * Buff.Value

	Unit:HealHp(hp, Unit)
end

BuffScript.TakeDmging_HealValue = {}

function BuffScript.TakeDmging_HealValue.OnAdd(Buff)
	Buff.Owner:On("单位-受到伤害", _TakeDmging_HealValue, Buff)
end

function BuffScript.TakeDmging_HealValue.OnRemove(Buff)
	Buff.Owner:Off("单位-受到伤害", _TakeDmging_HealValue, Buff)
end

local function _Change_Session_Weight(Buff, data, uniqueId)
	if Buff.Owner.UniqueId ~= uniqueId then
		return
	end

	for i, weight in ipairs(data.SessionWeight) do
		local destWeight = Buff.Custom[i]

		if destWeight then
			data.SessionWeight[i] = weight + destWeight
		end
	end
end

BuffScript.Change_Session_Weight = {}

function BuffScript.Change_Session_Weight.OnAdd(Buff)
	Buff.Owner:On("即将更新回合Session", _Change_Session_Weight, Buff)
end

function BuffScript.Change_Session_Weight.OnRemove(Buff)
	Buff.Owner:Off("即将更新回合Session", _Change_Session_Weight, Buff)
end

BuffScript.Add_Attri_Job = {}

function BuffScript.Add_Attri_Job.OnAdd(Buff)
	local ValueType = Buff:GetCustomByPropName("ValueType")

	for i, unit in Buff.GL.UnitMgr:Selector():Camp(Buff.Owner.Camp):Alive():Ipairs() do
		if unit.BaseData.Job == Buff:GetCustomByPropName("Job") then
			if valueType == "Val" then
				unit:Add(Buff:GetCustomByPropName("Attri"), Buff.Value)
			else
				unit:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value)
			end
		end
	end
end

function BuffScript.Add_Attri_Job.OnRemove(Buff)
	local valueType = Buff:GetCustomByPropName("ValueType")

	for i, unit in Buff.GL.UnitMgr:Selector():Camp(Buff.Owner.Camp):Alive():Ipairs() do
		if unit.BaseData.Job == Buff:GetCustomByPropName("Job") then
			if valueType == "Val" then
				unit:Add(Buff:GetCustomByPropName("Attri"), Buff.Value * -1)
			else
				unit:AddMul(Buff:GetCustomByPropName("Attri"), Buff.Value * -1)
			end
		end
	end
end

BuffScript.Remove_Heal = {}

function BuffScript.Remove_Heal.OnAdd(Buff)
	return
end

function BuffScript.Remove_Heal.OnRemove(Buff)
	local maxHp = Buff.Owner:Get("最大生命")
	local percentHp = Buff.Value
	local addVal = maxHp * percentHp
	local source = Buff.GL.UnitMgr:FindUnitById(Buff.SourceUniqueId)

	Buff.Owner:HealHp(addVal, source)
end

local function _Add_FinalDmg_Sessioning(Buff, Unit, SessionType, data)
	if Buff.Owner.UniqueId ~= Unit.UniqueId then
		return
	end

	local sessionVaild = false

	for i, sessionType in ipairs(Buff:GetCustomByPropName("SessionTypes")) do
		if SessionType == sessionType then
			sessionVaild = true

			break
		end
	end

	if sessionVaild == false then
		return
	end

	if not data then
		return
	end

	if not data.Dmg then
		return
	end

	local attri = Buff:GetCustomByPropName("Attri")

	if not attri then
		return
	end

	local val = Buff.Owner:Get(attri) * Buff.Value

	data.Dmg:AddFinalVal(val)
end

BuffScript.Add_FinalDmg_Sessioning = {}

function BuffScript.Add_FinalDmg_Sessioning.OnAdd(Buff)
	Buff.Owner:On("Session-球发动", _Add_FinalDmg_Sessioning, Buff)
end

function BuffScript.Add_FinalDmg_Sessioning.OnRemove(Buff)
	Buff.Owner:Off("Session-球发动", _Add_FinalDmg_Sessioning, Buff)
end

local function _Heal_In_Sessioning(Buff, Source, Unit, Dmg)
	if Buff.Owner.UniqueId ~= Source.UniqueId then
		return
	end

	if Dmg.dmgType ~= EnumFight.DamageType.Std then
		return
	end

	local sessionVaild, success = false, false

	for i, sessionType in ipairs(Buff:GetCustomByPropName("SessionTypes")) do
		if Dmg.sourceSession == sessionType then
			sessionVaild = true

			break
		end
	end

	if sessionVaild == false then
		return
	end

	local attri = Buff:GetCustomByPropName("Attri")

	if not attri then
		return
	end

	local val = Buff.Owner:Get(attri) * Buff.Value
	local minHpUnit = Buff.GL.UnitMgr:Selector():Camp(Buff.Owner.Camp):Alive():SortMin("生命"):Get()

	if minHpUnit then
		minHpUnit:HealHp(val, Buff.Owner)
		Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "ExeFx", {
			target = minHpUnit.UniqueId
		})
	end
end

BuffScript.Heal_In_Sessioning = {}

function BuffScript.Heal_In_Sessioning.OnAdd(Buff)
	Buff.Owner:On("单位-造成伤害", _Heal_In_Sessioning, Buff)
end

function BuffScript.Heal_In_Sessioning.OnRemove(Buff)
	Buff.Owner:Off("单位-造成伤害", _Heal_In_Sessioning, Buff)
end

local function _Shield_In_Sessioning(Buff, Source, Unit, Dmg)
	if Buff.Owner.UniqueId ~= Source.UniqueId then
		return
	end

	if Dmg.dmgType ~= EnumFight.DamageType.Std then
		return
	end

	local sessionVaild, success = false, false

	for i, sessionType in ipairs(Buff:GetCustomByPropName("SessionTypes")) do
		if Dmg.sourceSession == sessionType then
			sessionVaild = true

			break
		end
	end

	if sessionVaild == false then
		return
	end

	local attri = Buff:GetCustomByPropName("Attri")

	if not attri then
		return
	end

	local val = Buff.Owner:Get(attri) * Buff.Value

	Buff.Owner:AddShield(val)
	Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "ExeFx", {
		target = Buff.Owner.UniqueId
	})
end

BuffScript.Shield_In_Sessioning = {}

function BuffScript.Shield_In_Sessioning.OnAdd(Buff)
	Buff.Owner:On("单位-造成伤害", _Shield_In_Sessioning, Buff)
end

function BuffScript.Shield_In_Sessioning.OnRemove(Buff)
	Buff.Owner:Off("单位-造成伤害", _Shield_In_Sessioning, Buff)
end

BuffScript.Hot_Clear_Buff = {}

function BuffScript.Hot_Clear_Buff.OnAdd(Buff)
	return
end

function BuffScript.Hot_Clear_Buff.OnUpdate(Buff)
	local targetType = Buff:GetCustomByPropName("Type")
	local count = Buff:GetCustomByPropName("Count")
	local success = false
	local success = false

	for buffIdx = #Buff.Owner.Buffs, 1, -1 do
		if count <= 0 then
			break
		end

		local _buff = Buff.Owner.Buffs[buffIdx]

		for typeIdx, type in ipairs(targetType) do
			if count <= 0 then
				break
			end

			if _buff.Type == type then
				_buff:RemoveSelf()

				success = true
				count = count - 1
			end
		end
	end

	if success == true then
		Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "BuffExe", nil)
	end
end

function BuffScript.Hot_Clear_Buff.OnRemove(Buff)
	return
end

local function _Group_Tank(Buff, Unit, dmg)
	if Unit.Camp ~= Buff.Owner.Camp then
		return
	end

	if Unit.UniqueId == Buff.Owner.UniqueId then
		return
	end

	if dmg.dmgType ~= EnumFight.DamageType.Std then
		return
	end

	local copyDmg = dmg:Copy()

	copyDmg:SetAddAtkMul(Buff.Value)
	Buff.Owner:DealDamage(copyDmg)
	dmg:SetAddAtkMul(1 - Buff.Value)
	Buff.Owner:Fire("单位-Buff自定义消息", Buff.Owner, Buff, "ExeFx", {
		target = Unit.UniqueId
	})
end

BuffScript.Group_Tank = {}

function BuffScript.Group_Tank.OnAdd(Buff)
	Buff.Owner:On("单位-即将受到伤害", _Group_Tank, Buff)
end

function BuffScript.Group_Tank.OnRemove(Buff)
	Buff.Owner:Off("单位-即将受到伤害", _Group_Tank, Buff)
end

local function _Add_More_Buffs(Buff, addbuff)
	if Buff.Owner ~= addbuff.Owner then
		return
	end

	local cd = Buff:GetCustomByPropName("CD")

	if cd and Buff.ExcuteRound and cd + Buff.Duration <= Buff.ExcuteRound then
		return
	end

	local targetTypeOrders = Buff:GetCustomByPropName("BuffTypes")
	local ids = Buff:GetCustomByPropName("BuffIds")

	for i, targetTypeOrder in ipairs(targetTypeOrders) do
		if targetTypeOrder == addbuff.Type or targetTypeOrder == addbuff.TypeOrder then
			for _, id in ipairs(ids) do
				Buff.Owner:AddBuff(id, Buff.Owner)
			end

			Buff.ExcuteRound = Buff.Duration

			break
		end
	end
end

BuffScript.Add_More_Buffs = {}

function BuffScript.Add_More_Buffs.OnAdd(Buff)
	Buff.Owner:On("单位-添加buff", _Add_More_Buffs, Buff)
end

function BuffScript.Add_More_Buffs.OnRemove(Buff)
	Buff.Owner:Off("单位-添加buff", _Add_More_Buffs, Buff)
end

local function _Refresh_Dead_Add_Mp(Buff, unit)
	if unit.UnitClass == Buff.Owner.UnitClass then
		return
	end

	Buff.Owner:ForceMp(Buff.Value, Buff.Owner)
end

BuffScript.Refresh_Dead_Add_Mp = {}

function BuffScript.Refresh_Dead_Add_Mp.OnAdd(Buff)
	Buff.Owner:On("单位-死亡", _Refresh_Dead_Add_Mp, Buff)
end

function BuffScript.Refresh_Dead_Add_Mp.OnRemove(Buff)
	Buff.Owner:Off("单位-死亡", _Refresh_Dead_Add_Mp, Buff)
end
