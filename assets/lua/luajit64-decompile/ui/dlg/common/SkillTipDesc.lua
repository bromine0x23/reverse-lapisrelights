-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Common/SkillTipDesc.lua

require("UI.Dlg.Common.BuffTip")

local SkillTipDesc = {}
local BattleSkillData = require("GamePerform.Object.InfoBattleSkillData")
local MonsterData = require("luaData/Monster")
local programs
local hlh = {
	"ActionBall_Red",
	"ActionBall_Blue",
	"ActionBall_yellow"
}

local function BaseDesc(keyIndex, infoBattleSkill, skillLevel, keyName)
	local customParams = infoBattleSkill.Custom[keyIndex]

	if customParams.Mut ~= nil and customParams.FrozenAtk == nil then
		local muts = GetListObjByIndex(customParams.Mut, skillLevel)

		if #muts > 1 then
			keyName = keyName .. "_Multiple"
		end
	end

	if customParams.BreakArmor ~= nil then
		keyName = keyName .. "_BreakArmor"
	elseif customParams.Heal ~= nil and not string.find(keyName, "_HEAL") then
		keyName = keyName .. "_Heal"
	elseif customParams.TargetMul ~= nil then
		keyName = keyName .. "_TargetMul"
	elseif customParams.BuffState ~= nil then
		keyName = keyName .. "_BuffState"
	elseif customParams.BuffName ~= nil then
		keyName = keyName .. "_BuffName"
	elseif customParams.Explosion_Buff_TypeOrder ~= nil then
		keyName = keyName .. "_AddAtkStack"
	elseif customParams.Shield_Damage ~= nil then
		keyName = keyName .. "_Shield_Damage"
	elseif customParams.Expense_Shield_Damage ~= nil then
		keyName = keyName .. "_ExpenseShield"
	elseif customParams.Ignor_Shield ~= nil then
		keyName = keyName .. "_Ignor_Shield"
	elseif customParams.AddAtkFinal ~= nil then
		keyName = keyName .. "_AddAtkFinal"
	elseif customParams.Hp_Damage ~= nil then
		keyName = keyName .. "_Hp_Damage"
	elseif customParams.DebuffNum_Damage ~= nil then
		keyName = keyName .. "_DebuffNum_Damage"
	elseif customParams.FrozenAtk ~= nil then
		keyName = keyName .. "_Frozen_AddBuff"
	elseif customParams.DmgEnd_AddShield ~= nil then
		keyName = keyName .. "_AddShield"
	elseif customParams.DmgEnd_AddHp ~= nil then
		keyName = keyName .. "_AddHp"
	elseif customParams.Heal_TypeOrders ~= nil then
		keyName = keyName .. "_Heal_TypeOrders"
	end

	if customParams.Random ~= nil or customParams.WeightMulVal then
		keyName = keyName .. "_Random"
	end

	return _(keyName)
end

local function TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	local customParams = infoBattleSkill.Custom[keyIndex]
	local langKey = "Target_" .. GetListObjByIndex(customParams.Target, skillLevel)
	local replaceString = _(langKey)

	return string.gsub(desc, "{Target}", replaceString)
end

local function MulSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	local customParams = infoBattleSkill.Custom[keyIndex]

	if customParams.Mut == nil then
		return desc
	end

	local muts = GetListObjByIndex(customParams.Mut, skillLevel)
	local mutCount = #muts

	if mutCount == 1 then
		return desc
	else
		return string.gsub(desc, "{Mul}", mutCount)
	end
end

local function BuffNameSubstitution(keyIndex, infoBattleSkill, skillLevel, desc, keyName)
	local customParams = infoBattleSkill.Custom[keyIndex]
	local buffTypes = GetListObjByIndex(customParams[keyName], skillLevel)
	local langs = {}

	for i, v in ipairs(buffTypes) do
		table.insert(langs, _("BuffName_" .. v))
	end

	local langsStr = table.concat(langs, "、")

	return string.gsub(desc, "{BuffName}", langsStr)
end

local function GetPowerValue(keyIndex, infoBattleSkill, powerLevel)
	local power = 1

	if infoBattleSkill.IsStackPower and powerLevel and infoBattleSkill.IsStackPower == 1 and powerLevel >= 1 then
		local powers = infoBattleSkill.Power[keyIndex]

		if powers ~= nil and #powers > 0 then
			power = powers[powerLevel]
		end
	end

	return power
end

local function ValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, keyName)
	local power = GetPowerValue(keyIndex, infoBattleSkill, powerLevel)
	local customParams = infoBattleSkill.Custom[keyIndex]
	local addAtkMul = 1

	if customParams.AddAtkMul ~= nil then
		addAtkMul = GetListObjByIndex(customParams.AddAtkMul, skillLevel)
	end

	local value

	if keyName == "NO_ORDER_ATK" then
		value = GetListObjByIndex(customParams[GetListObjByIndex(customParams[keyName], 1)], 1) * power * addAtkMul
	else
		value = GetListObjByIndex(customParams[keyName], skillLevel) * power * addAtkMul
	end

	if customParams.Mut == nil then
		return string.gsub(desc, "{Value}", value * 100 .. "%%")
	else
		local muts = GetListObjByIndex(customParams.Mut, skillLevel)
		local mutCount = #muts

		if mutCount == 1 then
			return string.gsub(desc, "{Value}", value * 100 .. "%%")
		elseif customParams.FrozenAtk ~= nil then
			for i, v in ipairs(muts) do
				desc = string.gsub(desc, "{ValueMul" .. i .. "}", v * 100 .. "%%")
			end

			return desc
		else
			local values = {}

			for i, v in ipairs(muts) do
				table.insert(values, value * v * 100 .. "%%")
			end

			local valuesStr = table.concat(values, "、")

			return string.gsub(desc, "{Value}", valuesStr)
		end
	end
end

local function AbsValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, keyName)
	local power = GetPowerValue(keyIndex, infoBattleSkill, powerLevel)
	local customParams = infoBattleSkill.Custom[keyIndex]
	local value = GetListObjByIndex(customParams[keyName], skillLevel) * power

	if customParams.Mut == nil then
		return string.gsub(desc, "{Value}", (math.abs(value)))
	else
		local muts = GetListObjByIndex(customParams.Mut, skillLevel)
		local mutCount = #muts

		if mutCount == 1 then
			return string.gsub(desc, "{Value}", (math.abs(value)))
		else
			local values = {}

			for i, v in ipairs(muts) do
				table.insert(values, (math.abs(value)))
			end

			local valuesStr = table.concat(values, "、")

			return string.gsub(desc, "{Value}", valuesStr)
		end
	end
end

local function BuffStateSubstitution(keyIndex, infoBattleSkill, skillLevel, desc, keyName)
	local customParams = infoBattleSkill.Custom[keyIndex]
	local buffTypes = GetListObjByIndex(customParams[keyName], skillLevel)
	local langs = {}

	for i, v in ipairs(buffTypes) do
		if not table.contains(langs, _("BuffState_" .. v)) then
			table.insert(langs, _("BuffState_" .. v))
		end
	end

	local langsStr = table.concat(langs, "、")

	return string.gsub(desc, "{BuffState}", langsStr)
end

local function DMGValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, keyName)
	local power = GetPowerValue(keyIndex, infoBattleSkill, powerLevel)
	local customParams = infoBattleSkill.Custom[keyIndex]

	if customParams.AddAtkFinal ~= nil then
		local value = GetListObjByIndex(customParams.AddAtkFinal, skillLevel) * power

		if customParams.Mut == nil then
			return string.gsub(desc, "{AddAtkFinal}", value)
		else
			local muts = GetListObjByIndex(customParams.Mut, skillLevel)
			local mutCount = #muts

			if mutCount == 1 then
				return string.gsub(desc, "{AddAtkFinal}", value)
			else
				local values = {}

				for i, v in ipairs(muts) do
					table.insert(values, value * v)
				end

				local valuesStr = table.concat(values, "、")

				return string.gsub(desc, "{AddAtkFinal}", valuesStr)
			end
		end
	end

	if customParams.Explosion_Buff_TypeOrder ~= nil then
		local customParams = infoBattleSkill.Custom[keyIndex]
		local buffType = GetListObjByIndex(customParams.Explosion_Buff_TypeOrder, skillLevel)

		desc = string.gsub(desc, "{BuffName}", _("BuffName_" .. buffType))
	end

	if customParams.Heal ~= nil then
		local value = GetListObjByIndex(customParams.Heal, skillLevel)

		desc = string.gsub(desc, "{Heal}", value * 100 .. "%%")
	end

	if customParams.BreakArmor ~= nil then
		local value = GetListObjByIndex(customParams.BreakArmor, skillLevel)

		return string.gsub(desc, "{BreakArmor}", value * 100 .. "%%")
	elseif customParams.TargetMul ~= nil then
		local power = GetPowerValue(keyIndex, infoBattleSkill, powerLevel)
		local customParams = infoBattleSkill.Custom[keyIndex]
		local addAtkMul = 1

		if customParams.AddAtkMul ~= nil then
			addAtkMul = GetListObjByIndex(customParams.AddAtkMul, skillLevel)
		end

		local value

		if keyName == "NO_ORDER_ATK" then
			value = GetListObjByIndex(customParams[GetListObjByIndex(customParams[keyName], 1)], 1) * power * addAtkMul
		else
			value = GetListObjByIndex(customParams[keyName], skillLevel) * power * addAtkMul
		end

		local TargetMul = GetListObjByIndex(customParams.TargetMul, skillLevel)[2]

		if customParams.Mut == nil then
			return string.gsub(desc, "{TargetMul}", value * TargetMul * 100 .. "%%")
		else
			local muts = GetListObjByIndex(customParams.Mut, skillLevel)
			local mutCount = #muts

			if mutCount == 1 then
				return string.gsub(desc, "{TargetMul}", value * TargetMul * 100 .. "%%")
			else
				local values = {}

				for i, v in ipairs(muts) do
					table.insert(values, value * v * TargetMul * 100 .. "%%")
				end

				local valuesStr = table.concat(values, "、")

				return string.gsub(desc, "{TargetMul}", valuesStr)
			end
		end
	elseif customParams.LimitHeal ~= nil then
		local value = GetListObjByIndex(customParams.Heal, skillLevel)

		return string.gsub(desc, "{LimitHeal}", value * 100 .. "%%")
	elseif customParams.WeightMulVal ~= nil then
		local ta = GetListObjByIndex(customParams.WeightMulVal, skillLevel)
		local AddAtkMul = 1

		if customParams.AddAtkMul ~= nil then
			AddAtkMul = GetListObjByIndex(customParams.AddAtkMul, skillLevel)
		end

		local min = ta[1].Min * AddAtkMul
		local max = ta[#ta].Max * AddAtkMul

		desc = string.gsub(desc, "{Min}", min * 100 .. "%%")

		return string.gsub(desc, "{Max}", max * 100 .. "%%")
	elseif customParams.Explosion_Buff_Stack ~= nil then
		local value = GetListObjByIndex(customParams.Explosion_Buff_Stack, skillLevel)

		return string.gsub(desc, "{Value1}", value * 100 .. "%%")
	elseif customParams.Expense_Shield_Damage ~= nil then
		local value = GetListObjByIndex(customParams.Expense_Shield_Damage, skillLevel)

		return string.gsub(desc, "{Value1}", value * 100 .. "%%")
	elseif customParams.Shield_Damage ~= nil then
		local value = customParams.Shield_Damage

		return string.gsub(desc, "{Value}", value)
	elseif customParams.Hp_Damage ~= nil then
		local value = GetListObjByIndex(customParams.Hp_Damage, skillLevel)

		return string.gsub(desc, "{Hp_Damage}", value * 100 .. "%%")
	elseif customParams.DebuffNum_Damage ~= nil then
		local value = GetListObjByIndex(customParams.DebuffNum_Damage, skillLevel)

		return string.gsub(desc, "{DebuffNum_Damage}", value * 100 .. "%%")
	elseif customParams.FrozenAtk ~= nil then
		local langs = {}
		local TypeOrders = GetListObjByIndex(customParams.TypeOrders, skillLevel)

		for i, v in ipairs(TypeOrders) do
			local str = ""

			if _("BuffState_" .. v) ~= "BuffState_" .. v then
				str = _("BuffState_" .. v)
			else
				str = _("BuffName_" .. v)
			end

			if not table.contains(langs, str) then
				table.insert(langs, str)
			end
		end

		local langsStr = table.concat(langs, "、")

		desc = string.gsub(desc, "{BuffState}", langsStr)

		local value = GetListObjByIndex(customParams.FrozenPr, skillLevel)

		desc = string.gsub(desc, "{FrozenPr}", value * 100 .. "%%")

		local buffId = GetListObjByIndex(customParams.FrozenAtk, skillLevel)
		local addBuffDesc = BuffTip.GetDesc(buffId, power, -1, true, 0)

		return string.Replace(desc, "{FrozenAtk}", addBuffDesc)
	elseif customParams.DmgEnd_AddShield ~= nil then
		local pct = GetListObjByIndex(customParams.Percent, skillLevel)

		desc = string.gsub(desc, "{Pct}", pct * 100 .. "%%")

		local value = GetListObjByIndex(customParams.AddShieldValue, skillLevel)

		desc = string.gsub(desc, "{AddShieldValue}", value * 100 .. "%%")
		desc = BuffStateSubstitution(keyIndex, infoBattleSkill, skillLevel, desc, "DmgEnd_AddShield")

		return desc
	elseif customParams.DmgEnd_AddHp ~= nil then
		local pct = GetListObjByIndex(customParams.Percent, skillLevel)

		desc = string.gsub(desc, "{Pct}", pct * 100 .. "%%")

		local value = GetListObjByIndex(customParams.AddHpValue, skillLevel)

		desc = string.gsub(desc, "{AddHpValue}", value * 100 .. "%%")
		desc = BuffStateSubstitution(keyIndex, infoBattleSkill, skillLevel, desc, "DmgEnd_AddHp")

		local target = GetListObjByIndex(customParams.AddHpTarget, skillLevel)

		return string.gsub(desc, "{AddHpTarget}", _("Target_" .. target))
	elseif customParams.Heal_TypeOrders ~= nil then
		local langs = {}
		local TypeOrders = GetListObjByIndex(customParams.Heal_TypeOrders, skillLevel)

		for i, v in ipairs(TypeOrders) do
			local str = ""

			if _("BuffState_" .. v) ~= "BuffState_" .. v then
				str = _("BuffState_" .. v)
			else
				str = _("BuffName_" .. v)
			end

			if not table.contains(langs, str) then
				table.insert(langs, str)
			end
		end

		local langsStr = table.concat(langs, "、")

		desc = string.gsub(desc, "{BuffState}", langsStr)

		local value = GetListObjByIndex(customParams.Heal_TypeOrders_Val, skillLevel)

		desc = string.gsub(desc, "{Val}", value * 100 .. "%%")

		return desc
	else
		return desc
	end
end

local function BuffTargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	local customParams = infoBattleSkill.Custom[keyIndex]
	local BuffTarget = GetListObjByIndex(customParams.BuffTarget, skillLevel)

	return string.gsub(desc, "{BuffTarget}", _("BuffTarget_" .. BuffTarget))
end

local function ClearType(keyIndex, infoBattleSkill, skillLevel, desc, keyName)
	local customParams = infoBattleSkill.Custom[keyIndex]
	local des = ""
	local count = 0

	for i, v in ipairs(customParams[keyName]) do
		for j, k in ipairs(v) do
			local cleartypekey = "ClearType_" .. k
			local name = _(cleartypekey)

			if count == 0 then
				des = des .. name
			else
				des = des .. _("BuffDesc_Separator") .. name
			end

			count = count + 1
		end
	end

	return string.gsub(desc, "{ClearType}", des)
end

local function ADD_MP(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "ADD_MP")

	desc = AbsValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, "ADD_MP")

	return desc
end

local function ADD_MP_ONCE(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "ADD_MP_ONCE")

	desc = AbsValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, "ADD_MP_ONCE")

	return desc
end

local function ADD_PHY_MAG_DMG_MUL(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "ADD_PHY_MAG_DMG_MUL")

	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	desc = MulSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	desc = ValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, "ADD_PHY_MAG_DMG_MUL")
	desc = DMGValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, "ADD_PHY_MAG_DMG_MUL")

	return desc
end

local function ADD_MAG_DMG_MUL(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "ADD_MAG_DMG_MUL")

	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	desc = MulSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	desc = ValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, "ADD_MAG_DMG_MUL")
	desc = DMGValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, "ADD_MAG_DMG_MUL")

	return desc
end

local function ADD_PHY_DMG_MUL(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "ADD_PHY_DMG_MUL")

	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	desc = MulSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	desc = ValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, "ADD_PHY_DMG_MUL")
	desc = DMGValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, "ADD_PHY_DMG_MUL")

	return desc
end

local function ADD_HP_PER(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "ADD_HP_PER")

	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	desc = ValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, "ADD_HP_PER")

	return desc
end

local function ADD_SHIELD_PER(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "ADD_SHIELD_PER")

	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	desc = ValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, "ADD_SHIELD_PER")

	return desc
end

local function REDUCE_SHIELD_PER(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "REDUCE_SHIELD_PER")

	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	desc = ValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, "REDUCE_SHIELD_PER")

	return desc
end

local function CLEAR_BUFF_TYPE(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "CLEAR_BUFF_TYPE")

	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	desc = BuffStateSubstitution(keyIndex, infoBattleSkill, skillLevel, desc, "CLEAR_BUFF_TYPE")

	return desc
end

local function CHANGE_SESSION(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "CHANGE_SESSION")
	local customParams = infoBattleSkill.Custom[keyIndex]
	local ballIndex = GetListObjByIndex(customParams.CHANGE_SESSION, skillLevel)
	local ballKey = hlh[ballIndex]
	local ballStr = _(ballKey)

	return string.gsub(desc, "{Ball}", ballStr, 1)
end

local function DMG_DEBUFF_POWER(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "DMG_DEBUFF_POWER")

	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	desc = MulSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)

	local power = GetPowerValue(keyIndex, infoBattleSkill, powerLevel)
	local customParams = infoBattleSkill.Custom[keyIndex]
	local defaultValue = GetListObjByIndex(customParams.AddVal, skillLevel) * power
	local addValue = defaultValue * GetListObjByIndex(customParams.DebuffAddVal, skillLevel)
	local AddAtkMul = 1

	if customParams.AddAtkMul ~= nil then
		AddAtkMul = GetListObjByIndex(customParams.AddAtkMul, skillLevel)
	end

	if customParams.Mut == nil then
		desc = string.gsub(desc, "{DefaultValue}", defaultValue * 100 * AddAtkMul .. "%%")
		desc = string.gsub(desc, "{AddValue}", addValue * 100 * AddAtkMul .. "%%")
	else
		local muts = GetListObjByIndex(customParams.Mut, skillLevel)
		local mutCount = #muts

		if mutCount == 1 then
			desc = string.gsub(desc, "{DefaultValue}", defaultValue * 100 * AddAtkMul .. "%%")
			desc = string.gsub(desc, "{AddValue}", addValue * 100 * AddAtkMul .. "%%")
		else
			local defaultValues = {}
			local addValues = {}

			for i, v in ipairs(muts) do
				table.insert(defaultValues, defaultValue * v * 100 * AddAtkMul .. "%%")
				table.insert(addValues, addValue * v * 100 * AddAtkMul .. "%%")
			end

			local valuesStr = table.concat(defaultValues, "、")

			desc = string.gsub(desc, "{DefaultValue}", valuesStr)
			valuesStr = table.concat(addValues, "、")
			desc = string.gsub(desc, "{AddValue}", valuesStr)
		end
	end

	local SkillTypeLang = "SkillType_" .. GetListObjByIndex(customParams.Action, skillLevel)
	local SkillType = _(SkillTypeLang)

	desc = string.gsub(desc, "{SkillType}", SkillType)

	local buffNameLang = "BuffName_" .. GetListObjByIndex(customParams.DMG_DEBUFF_POWER, skillLevel)
	local buffName = _(buffNameLang)

	desc = string.gsub(desc, "{BuffName}", buffName)

	return desc
end

local function SELF_DESTRUCT(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "SELF_DESTRUCT")

	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	desc = ValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, "SELF_DESTRUCT")

	return desc
end

local function ADD_BUFF(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local power = GetPowerValue(keyIndex, infoBattleSkill, powerLevel)
	local customParams = infoBattleSkill.Custom[keyIndex]
	local buffId = GetListObjByIndex(customParams.ADD_BUFF, skillLevel)
	local desc = BuffTip.GetDesc(buffId, power, -1, true, 1)

	return TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
end

local function ADD_BUFF_PR(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local power = GetPowerValue(keyIndex, infoBattleSkill, powerLevel)
	local customParams = infoBattleSkill.Custom[keyIndex]
	local buffId = GetListObjByIndex(customParams.ADD_BUFF, skillLevel)
	local desc = BuffTip.GetDesc(buffId, power, -1, true, 2)

	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)

	local pr = GetListObjByIndex(customParams.ADD_BUFF_PR, skillLevel)

	desc = string.gsub(desc, "{PR}", pr * 100 .. "%%")

	return desc
end

local function ADD_BUFFS_PR(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local power = GetPowerValue(keyIndex, infoBattleSkill, powerLevel)
	local customParams = infoBattleSkill.Custom[keyIndex]
	local buffIds = customParams.ADD_BUFF
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "ADD_BUFFS_PR")
	local langs = {}

	for i, v in ipairs(buffIds) do
		local desc = _("Mark_" .. v)

		table.insert(langs, desc)
	end

	local langsStr = table.concat(langs, "、")

	desc = string.gsub(desc, "{BuffsDesc}", langsStr)
	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)

	return desc
end

local function ADD_BUFF_STACK(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "ADD_BUFF_STACK")
	local customParams = infoBattleSkill.Custom[keyIndex]

	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)

	local stack = GetListObjByIndex(customParams.Stack, skillLevel)

	desc = string.gsub(desc, "{Stack}", stack)

	local buffId = GetListObjByIndex(customParams.ADD_BUFF, skillLevel)

	desc = string.gsub(desc, "{Mark}", _("Mark_" .. buffId))

	return desc
end

local function ADD_BUFF_OPEN(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "ADD_BUFF_OPEN")

	return desc
end

local function CLEAR_BUFF_TYPEORDER(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "CLEAR_BUFF_TYPEORDER")

	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	desc = BuffNameSubstitution(keyIndex, infoBattleSkill, skillLevel, desc, "CLEAR_BUFF_TYPEORDER")

	return desc
end

local function REBORN(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "REBORN")
	local customParams = infoBattleSkill.Custom[keyIndex]

	desc = string.gsub(desc, "{Count}", GetListObjByIndex(customParams.Count, skillLevel))

	local power = GetPowerValue(keyIndex, infoBattleSkill, powerLevel)
	local value = GetListObjByIndex(customParams.REBORN, skillLevel) * power

	desc = string.gsub(desc, "{Value}", value * 100 .. "%%")

	return desc
end

local function DEATH_NOTE(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "DEATH_NOTE")
	local customParams = infoBattleSkill.Custom[keyIndex]
	local power = GetPowerValue(keyIndex, infoBattleSkill, powerLevel)
	local value = GetListObjByIndex(customParams.DEATH_NOTE, skillLevel) * power

	desc = string.gsub(desc, "{DEATH_NOTE}", value * 100 .. "%%")

	return desc
end

local function SUMMON(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "SUMMON")
	local customParams = infoBattleSkill.Custom[keyIndex]
	local ids = customParams.SUMMON
	local names = {}

	for i, v in ipairs(ids) do
		local id = v[1]
		local monsterCfg = MonsterData[id]
		local name = Lang(monsterCfg.Name)

		table.insert(names, name)
	end

	local namesStr = table.concat(names, "、")

	return string.gsub(desc, "{SUMMON}", namesStr)
end

local function Test_NO_ORDER_ATK(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = _("NO_ORDER_ATK")

	desc = MulSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	desc = ValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, "NO_ORDER_ATK")

	local customParams = infoBattleSkill.Custom[keyIndex]
	local name

	if customParams.NO_ORDER_ATK[1] ~= nil then
		name = _("SkillType_" .. customParams.NO_ORDER_ATK[1])
	end

	return string.gsub(desc, "{SkillType}", name)
end

local function DOT_OUTBREAK(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "DOT_OUTBREAK_BuffState")

	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)

	local customParams = infoBattleSkill.Custom[keyIndex]
	local buffTypes = GetListObjByIndex(customParams.DOT_OUTBREAK, skillLevel)
	local langs = {}

	for i, v in ipairs(buffTypes) do
		local str = ""

		if _("BuffState_" .. v) ~= "BuffState_" .. v then
			str = _("BuffState_" .. v)
		else
			str = _("BuffName_" .. v)
		end

		if not table.contains(langs, str) then
			table.insert(langs, str)
		end
	end

	local langsStr = table.concat(langs, "、")

	desc = string.gsub(desc, "{BuffState}", langsStr)

	return desc
end

local function CLEAR_BUFF_CLEARTYPE(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "CLEAR_BUFF_CLEARTYPE")

	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	desc = BuffNameSubstitution(keyIndex, infoBattleSkill, skillLevel, desc, "CLEAR_BUFF_CLEARTYPE")
	desc = ClearType(keyIndex, infoBattleSkill, skillLevel, desc, "CLEAR_BUFF_CLEARTYPE")

	return desc
end

local function REFRESH_ROUND_HP_CUSTOM(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "REFRESH_ROUND_HP_CUSTOM")
	local customParams = infoBattleSkill.Custom[keyIndex]

	desc = string.gsub(desc, "{contrast}", _("contrast_" .. customParams.REFRESH_ROUND_HP_CUSTOM[1]))

	local power = GetPowerValue(keyIndex, infoBattleSkill, powerLevel)
	local value = GetListObjByIndex(customParams.Arg1, skillLevel) * power

	desc = string.gsub(desc, "{Arg1}", value * 100 .. "%%")

	local value2 = GetListObjByIndex(customParams.Arg3[1], skillLevel) * power

	desc = string.gsub(desc, "{Arg3}", value2 * 100 .. "%%")

	local value3 = GetListObjByIndex(customParams.Arg2[1], skillLevel)

	desc = string.gsub(desc, "{BuffCustom}", _("BuffCustom_" .. value3))

	return desc
end

local function REDUCE_MP(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "REDUCE_MP")

	desc = AbsValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, "REDUCE_MP")

	return desc
end

local function ADD_HP_ATTRI(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "ADD_HP_ATTRI")

	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	desc = ValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, "ADD_HP_ATTRI")

	local customParams = infoBattleSkill.Custom[keyIndex]
	local value = GetListObjByIndex(customParams.Attri, skillLevel)

	desc = string.gsub(desc, "{BuffCustom}", _("BuffCustom_" .. value))

	return desc
end

local function ADD_SHIELD_ATTRI(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "ADD_SHIELD_ATTRI")

	desc = ValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, "ADD_SHIELD_ATTRI")

	local customParams = infoBattleSkill.Custom[keyIndex]
	local value = GetListObjByIndex(customParams.Attri, skillLevel)

	desc = string.gsub(desc, "{BuffCustom}", _("BuffCustom_" .. value))

	return desc
end

local function CLEAR_BUFF_TYPE_COUNT(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "CLEAR_BUFF_TYPE_COUNT")

	desc = BuffStateSubstitution(keyIndex, infoBattleSkill, skillLevel, desc, "CLEAR_BUFF_TYPE_COUNT")
	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)

	local customParams = infoBattleSkill.Custom[keyIndex]
	local value = GetListObjByIndex(customParams.Count, skillLevel)

	desc = string.gsub(desc, "{Count}", value)

	return desc
end

local function CLEAR_BUFF_CLEARTYPE_COUNT(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "CLEAR_BUFF_CLEARTYPE_COUNT")

	desc = ClearType(keyIndex, infoBattleSkill, skillLevel, desc, "CLEAR_BUFF_CLEARTYPE_COUNT")
	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)

	local customParams = infoBattleSkill.Custom[keyIndex]
	local value = GetListObjByIndex(customParams.Count, skillLevel)

	desc = string.gsub(desc, "{Count}", value)

	return desc
end

local function COPY_BUFFS(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "COPY_BUFFS")

	desc = BuffStateSubstitution(keyIndex, infoBattleSkill, skillLevel, desc, "COPY_BUFFS")

	return desc
end

local function BUFF_STACK(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "BUFF_STACK")

	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)

	local customParams = infoBattleSkill.Custom[keyIndex]

	if customParams.Type ~= nil then
		desc = BuffStateSubstitution(keyIndex, infoBattleSkill, skillLevel, desc, "Type")
	elseif customParams.TypeOrder ~= nil then
		desc = BuffStateSubstitution(keyIndex, infoBattleSkill, skillLevel, desc, "TypeOrder")
	end

	local stack = GetListObjByIndex(customParams.Stack, skillLevel)

	desc = string.gsub(desc, "{Stack}", stack)

	return desc
end

local function BUFF_TIME_ADD_TYPE(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "BUFF_TIME_ADD_TYPE")

	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	desc = BuffStateSubstitution(keyIndex, infoBattleSkill, skillLevel, desc, "BUFF_TIME_ADD_TYPE")
	desc = BuffTargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)

	local customParams = infoBattleSkill.Custom[keyIndex]
	local Turn = GetListObjByIndex(customParams.Turn, skillLevel)

	desc = string.gsub(desc, "{Turn}", Turn)

	return desc
end

local function BUFF_TIME_MINUS_TYPE(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "BUFF_TIME_MINUS_TYPE")

	desc = TargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)
	desc = BuffStateSubstitution(keyIndex, infoBattleSkill, skillLevel, desc, "BUFF_TIME_MINUS_TYPE")
	desc = BuffTargetSubstitution(keyIndex, infoBattleSkill, skillLevel, desc)

	local customParams = infoBattleSkill.Custom[keyIndex]
	local Turn = GetListObjByIndex(customParams.Turn, skillLevel)

	desc = string.gsub(desc, "{Turn}", Turn)

	return desc
end

local function DEAL_DMG_PERCENT_HEAL(keyIndex, infoBattleSkill, skillLevel, powerLevel)
	local desc = BaseDesc(keyIndex, infoBattleSkill, skillLevel, "DEAL_DMG_PERCENT_HEAL")

	desc = ValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, "DEAL_DMG_PERCENT_HEAL")
	desc = DMGValueSubstitution(keyIndex, infoBattleSkill, skillLevel, powerLevel, desc, "DEAL_DMG_PERCENT_HEAL")

	return desc
end

local function RegisterProgram()
	programs.ADD_PHY_MAG_DMG_MUL = ADD_PHY_MAG_DMG_MUL
	programs.ADD_MAG_DMG_MUL = ADD_MAG_DMG_MUL
	programs.ADD_PHY_DMG_MUL = ADD_PHY_DMG_MUL
	programs.ADD_HP_PER = ADD_HP_PER
	programs.ADD_SHIELD_PER = ADD_SHIELD_PER
	programs.REDUCE_SHIELD_PER = REDUCE_SHIELD_PER
	programs.CLEAR_BUFF_TYPE = CLEAR_BUFF_TYPE
	programs.CHANGE_SESSION = CHANGE_SESSION
	programs.DMG_DEBUFF_POWER = DMG_DEBUFF_POWER
	programs.SELF_DESTRUCT = SELF_DESTRUCT
	programs.ADD_BUFF = ADD_BUFF
	programs.ADD_BUFF_PR = ADD_BUFF_PR
	programs.ADD_BUFFS_PR = ADD_BUFFS_PR
	programs.ADD_BUFF_STACK = ADD_BUFF_STACK
	programs.ADD_BUFF_OPEN = ADD_BUFF_OPEN
	programs.CLEAR_BUFF_TYPEORDER = CLEAR_BUFF_TYPEORDER
	programs.REBORN = REBORN
	programs.DEATH_NOTE = DEATH_NOTE
	programs.SUMMON = SUMMON
	programs.NO_ORDER_ATK = Test_NO_ORDER_ATK
	programs.DOT_OUTBREAK = DOT_OUTBREAK
	programs.CLEAR_BUFF_CLEARTYPE = CLEAR_BUFF_CLEARTYPE
	programs.ADD_MP = ADD_MP
	programs.REFRESH_ROUND_HP_CUSTOM = REFRESH_ROUND_HP_CUSTOM
	programs.ADD_MP_ONCE = ADD_MP_ONCE
	programs.InfoSkillActionKey = InfoSkillActionKey
	programs.REDUCE_MP = REDUCE_MP
	programs.ADD_HP_ATTRI = ADD_HP_ATTRI
	programs.ADD_SHIELD_ATTRI = ADD_SHIELD_ATTRI
	programs.CLEAR_BUFF_TYPE_COUNT = CLEAR_BUFF_TYPE_COUNT
	programs.CLEAR_BUFF_CLEARTYPE_COUNT = CLEAR_BUFF_CLEARTYPE_COUNT
	programs.COPY_BUFFS = COPY_BUFFS
	programs.BUFF_STACK = BUFF_STACK
	programs.DEAL_DMG_PERCENT_HEAL = DEAL_DMG_PERCENT_HEAL
	programs.BUFF_TIME_ADD_TYPE = BUFF_TIME_ADD_TYPE
	programs.BUFF_TIME_MINUS_TYPE = BUFF_TIME_MINUS_TYPE
end

local function BallAddDesc(baseDesc, ballType)
	if ballType == nil then
		return baseDesc
	end

	if ballType > 3 then
		ballType = ballType - 3
	end

	return baseDesc .. _("BallAddDesc_" .. ballType)
end

local function GetAllSkillDescs(infoSkill, skillLevel)
	local allSkillDescs = {}

	local function GetDesc(argus, key, isValOrPer, list)
		if argus ~= nil then
			for i = 1, #argus do
				if argus[i] ~= 0 then
					if isValOrPer then
						local decs = _(key .. TenaryOp(i == 1, "Val", "Per"))

						decs = string.gsub(decs, "{Value}", TenaryOp(i == 1, argus[i], argus[i] .. "%%"))

						table.insert(list, decs)
					else
						local decs = _(key .. i)

						decs = string.gsub(decs, "{Value}", argus[i] .. "%%")

						table.insert(list, decs)
					end
				end
			end
		end
	end

	local function GetDescItem(argus, key, list)
		if argus ~= nil then
			for i = 1, #argus do
				if argus[i] ~= 0 and i ~= 1 then
					local decs = _(key .. TenaryOp(i == 2, "Val", "Per"))

					decs = string.gsub(decs, "{Value}", TenaryOp(i == 2, argus[i], argus[i] .. "%%"))

					local name = ItemManager:Get(argus[1]):GetNameAndDesc()

					decs = string.gsub(decs, "{Item}", name)

					table.insert(list, decs)
				end
			end
		end
	end

	GetDesc(GetListObjByIndex(infoSkill.Argus, skillLevel or 1), "Argus_", false, allSkillDescs)
	GetDesc(GetListObjByIndex(infoSkill.Argus2, skillLevel or 1), "Argus2_", false, allSkillDescs)
	GetDesc(GetListObjByIndex(infoSkill.Argus3, skillLevel or 1), "Argus3_", false, allSkillDescs)
	GetDesc(GetListObjByIndex(infoSkill.SkillStageBonus, skillLevel or 1), "SkillStageBonus_", true, allSkillDescs)
	GetDesc(GetListObjByIndex(infoSkill.ExpAdd, skillLevel or 1), "ExpAdd_", true, allSkillDescs)
	GetDesc(GetListObjByIndex(infoSkill.CostAdd, skillLevel or 1), "CostAdd_", true, allSkillDescs)
	GetDescItem(GetListObjByIndex(infoSkill.ItemExtraGroup, skillLevel or 1), "ItemAdd_", allSkillDescs)

	return allSkillDescs
end

function SkillTipDesc.GetDesc(skillId, skillLevel, powerLevel, ballType)
	if programs == nil then
		programs = {}

		RegisterProgram()
	end

	local infoSkill = BattleSkillData:GetAllSkillData(skillId)
	local infoBattleSkill = BattleSkillData:GetData(infoSkill.BattleSkillID[skillLevel])

	if infoSkill.Type == 1 then
		local actionKeyDescs = {}

		for i, actionKey in ipairs(infoBattleSkill.ActionKey) do
			local actionKeyDescFunc = programs[actionKey]
			local actionKeyDesc = ""

			if actionKeyDescFunc ~= nil then
				actionKeyDesc = actionKeyDescFunc(i, infoBattleSkill, 1, powerLevel)
			else
				actionKeyDesc = actionKey .. " isNil"
			end

			table.insert(actionKeyDescs, actionKeyDesc)
		end

		desc = table.concat(actionKeyDescs, _("SkillDesc_Separator"))

		return BallAddDesc(desc, ballType)
	else
		local allSkillDescs = GetAllSkillDescs(infoSkill, skillLevel or 1)

		desc = table.concat(allSkillDescs, _("SkillDesc_Separator"))

		return BallAddDesc(desc, ballType)
	end
end

function SkillTipDesc.GetAllDescList()
	if programs == nil then
		programs = {}

		RegisterProgram()
	end

	local list = {}
	local _AllSkill = require("luaData/AllSkills")

	for k, v in pairs(_AllSkill) do
		local skillId = v.ID
		local infoSkill = BattleSkillData:GetAllSkillData(skillId)

		for i, battleID in ipairs(infoSkill.BattleSkillID) do
			local desc, keys, buffKeys
			local infoBattleSkill = BattleSkillData:GetData(battleID)

			if infoBattleSkill then
				print("打印技能数据   -------  BattleSkillID  --- " .. battleID)

				if infoSkill.Type == 1 then
					local actionKeyDescs = {}
					local key = {}
					local buffKeylist = {}

					for i, actionKey in ipairs(infoBattleSkill.ActionKey) do
						local actionKeyDescFunc = programs[actionKey]
						local actionKeyDesc = ""

						if actionKeyDescFunc ~= nil then
							actionKeyDesc = actionKeyDescFunc(i, infoBattleSkill, 1, 0)
						else
							actionKeyDesc = actionKey .. " isNil"
						end

						table.insert(actionKeyDescs, actionKeyDesc)
						table.insert(key, actionKey)

						if actionKey == "ADD_BUFF" or actionKey == "ADD_BUFF_PR" then
							local customParams = infoBattleSkill.Custom[i]
							local buffId = GetListObjByIndex(customParams.ADD_BUFF, 1)
							local buffkey = BuffTip.GetBuffKey(buffId, 1, -1, true, 1)

							table.insert(buffKeylist, buffkey)
						end
					end

					desc = table.concat(actionKeyDescs, _("SkillDesc_Separator"))
					keys = table.concat(key, ",")
					buffKeys = table.concat(buffKeylist, ",")
				else
					local allSkillDescs = GetAllSkillDescs(infoSkill, skillLevel or 1)

					desc = table.concat(allSkillDescs, _("SkillDesc_Separator"))
				end

				local printInfo = {}

				printInfo.Name = Lang(infoSkill.Name)
				printInfo.AllSkillId = skillId
				printInfo.BattleSkillId = battleID
				printInfo.Desc = desc
				printInfo.DescKey = keys
				printInfo.BuffKey = buffKeys

				table.insert(list, printInfo)
			end
		end
	end

	local json = require("GameLogic.Util.json4lua")
	local ret = json.encode(list)
	local path = string.gsub(Application.dataPath, "Assets", "")
	local test = assert(io.open(path .. "SkillTipDescOut.txt", "w"))

	test:write(ret)
	test:close()
end

return SkillTipDesc
