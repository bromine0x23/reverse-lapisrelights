-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/Script/SkillScript.lua

local WeightHelper = require("GameLogic.WeightHelper")

SkillScript = {}

local BASE_DMG_TYPE_CONFIG = {
	"ADD_PHY_MAG_DMG_MUL",
	"ADD_MAG_DMG_MUL",
	"ADD_PHY_DMG_MUL",
	"ADD_MAG_DMG",
	"ADD_PHY_DMG"
}
local DMG_TYPE_CONFIG = {
	"MIX_DMG"
}
local BASE_HEAL_CONFIG = {
	"ADD_HP_PER"
}

function SkillScript.SetDamage(actonType, dmg, addVal, Skill, idx)
	if actonType == "ADD_PHY_MAG_DMG_MUL" then
		dmg:AddPhyMul(addVal)
		dmg:AddMagMul(addVal)
	elseif actonType == "ADD_MAG_DMG_MUL" then
		dmg:AddMagMul(addVal)

		dmg.damagePhy = 0
	elseif actonType == "ADD_PHY_DMG_MUL" then
		dmg:AddPhyMul(addVal)

		dmg.damageMag = 0
	elseif actonType == "ADD_MAG_DMG" then
		dmg:AddMag(addVal)

		dmg.damagePhy = 0
	elseif actonType == "ADD_PHY_DMG" then
		dmg:AddPhy(addVal)

		dmg.damageMag = 0
	end

	local breakArmorVal = Skill:GetCustomProperty("BreakArmor", idx)

	dmg:SetBreakArmor(breakArmorVal)

	local atkMul = Skill:GetCustomProperty("AddAtkMul", idx)

	if power then
		atkMul = atkMul and atkMul * power
	end

	dmg:SetAddAtkMul(atkMul)

	local dmgpct = Skill:GetCustomProperty("AddAtkPct", idx)

	if power then
		dmgpct = dmgpct and dmgpct * power
	end

	dmg:AddPct(dmgpct)

	local dmgfinal = Skill:GetCustomProperty("AddAtkFinal", idx)

	if power then
		dmgfinal = dmgfinal and dmgfinal * power
	end

	dmg:AddFinalVal(dmgfinal)
end

local function GetWhippedCorpseReward(GL, hurt, maxHp, isBoss, skillAddPR)
	local overDropPR = GL.GameBaseData.BattleStageData.OverDropPR
	local addPR = skillAddPR

	if isBoss then
		addPR = addPR + FightConst.whippedBossAddPR(hurt, maxHp)
	else
		addPR = addPR + FightConst.whippedMonsterAddPR(hurt, maxHp)
	end

	overDropPR = overDropPR + addPR

	local overDropGroupList = GL.GameBaseData.BattleStageData.OverDropGroupList
	local overDropGroupPR = GL.GameBaseData.BattleStageData.OverDropGroupPR

	if RandomUtil.Reward(overDropPR) == true then
		local helper = WeightHelper()
		local rewardId = helper:Random(overDropGroupPR, overDropGroupList, GL.Result:GetWhipCount())

		GL.Result:WhipSuccess()

		return rewardId
	end

	return nil
end

function SkillScript.DealDamage(Skill, idx, dmg, targets)
	local mutInfo = Skill:GetCustomProperty("Mut", idx)
	local mutDamages = {}

	if mutInfo then
		for i, mut in ipairs(mutInfo) do
			local mutDmg = dmg:Copy()

			mutDmg:SetAddAtkMul(mut)
			table.insert(mutDamages, mutDmg)
		end
	else
		table.insert(mutDamages, dmg)
	end

	if not targets then
		local t = Skill:GetCustomProperty("Target", idx)

		targets = Skill:SelectTarget(t)
	end

	Skill.GL:Fire("伤害目标", Skill, targets)

	local award = false
	local frozenAtk = Skill:GetCustomProperty("FrozenAtk", idx)
	local frozenAtk_success = false

	if frozenAtk then
		local typeOrders = Skill:GetCustomProperty("TypeOrders", idx)

		for i, unit in ipairs(targets) do
			if typeOrders then
				for _, t in ipairs(typeOrders) do
					if unit:HasBuffTypeOrder(t) or unit:HasBuffType(t) then
						frozenAtk_success = true

						break
					end
				end
			elseif unit:HasBuffTypeOrder("frozen") then
				frozenAtk_success = true

				break
			end
		end
	end

	local targetMuls = Skill:GetCustomProperty("TargetMul", idx)
	local whipAwardSuccess = false

	for mutIdx, mutDmg in ipairs(mutDamages) do
		if frozenAtk and frozenAtk_success == false and mutIdx == #mutDamages then
			break
		end

		for i, unit in ipairs(targets) do
			if whipAwardSuccess == false and unit.UnitClass == EnumFight.UnitClass.ENEMY and unit:Get("生命") <= 0 and Skill.GL.GameBaseData.BattleStageData.OverDropPR > 0 then
				award = true
			end

			Skill.Owner:Fire("受击打包", Skill, mutIdx)

			local dmg = mutDmg:Copy()

			dmg:SetMut(mutIdx)

			if targetMuls and targetMuls[i] then
				dmg:SetAddAtkMul(targetMuls[i])
			end

			Skill.ComboCount = Skill.ComboCount + 1

			local curCombo = Skill.GL.RunTime.GameRoundData:UpdateCombo()

			Skill.GL:Fire("更新连击", curCombo, Skill.Owner.Camp, Skill.Owner.UniqueId)

			if dmg.isGroupSession == true then
				dmg:GroupSessionCombo(curCombo)
			end

			dmg.dmgSource = Skill

			local hpDamage = Skill:GetCustomProperty("Hp_Damage", idx)

			if hpDamage then
				local hpDamageVal = hpDamage * unit:Get("生命") / unit:Get("最大生命")

				dmg:AddPct(hpDamageVal)
			end

			local debuffNum_Damage = Skill:GetCustomProperty("DebuffNum_Damage", idx)

			if debuffNum_Damage then
				local buffNum = 0
				local clearType = Skill:GetCustomProperty("ClearTypes", idx)

				for i, buff in ipairs(unit.Buffs) do
					for _, type in ipairs(clearType) do
						if buff.ClearType == type then
							buffNum = buffNum + 1
						end
					end
				end

				if buffNum > 0 then
					dmg:AddPct(buffNum * debuffNum_Damage)
				end
			end

			local Explosion_Buff_TypeOrder = Skill:GetCustomProperty("Explosion_Buff_TypeOrder", idx)
			local Explosion_Buff_Stack = Skill:GetCustomProperty("Explosion_Buff_Stack", idx)

			if Explosion_Buff_TypeOrder and Explosion_Buff_Stack then
				local buff = unit:HasBuffTypeOrder(Explosion_Buff_TypeOrder)

				if buff then
					dmg:AddPct(buff.Stack * Explosion_Buff_Stack)
				end
			end

			local Shield_Damage = Skill:GetCustomProperty("Shield_Damage", idx)

			if Shield_Damage then
				local cur = Skill.GL.RunTime:GetTeamByCamp(Skill.Owner.Camp):Get("护盾")
				local max = Skill.GL.RunTime:GetTeamByCamp(Skill.Owner.Camp):Get("最大护盾")

				if max ~= 0 and cur ~= 0 then
					dmg:AddPct(cur / max * Shield_Damage)
				end
			end

			local Expense_Shield_Damage = Skill:GetCustomProperty("Expense_Shield_Damage", idx)

			if Expense_Shield_Damage then
				local cur = Skill.GL.RunTime:GetTeamByCamp(Skill.Owner.Camp):Get("护盾")

				if cur >= 1 then
					dmg:AddFinalVal(cur * Expense_Shield_Damage)
					Skill.GL.RunTime:GetTeamByCamp(Skill.Owner.Camp):Set("护盾", cur * Expense_Shield_Damage)
				end
			end

			local Ignor_Shield = Skill:GetCustomProperty("Ignor_Shield", idx)

			if Ignor_Shield then
				dmg:SetIgnorShield()
			end

			local HealDamageAddTurn = Skill:GetCustomProperty("HealDamageAddTurn", idx)
			local HealDamageAddMul = Skill:GetCustomProperty("HealDamageAddMul", idx)

			if HealDamageAddTurn and HealDamageAddMul then
				if not Skill.TempData then
					Skill.TempData = {}
				end

				if not Skill.TempData.HealDamageAddTurn then
					Skill.TempData.HealDamageAddTurn = 0
				end

				local vaildHeal = 0
				local curRound = Skill.GL.RunTime.CurRound
				local roundDatas = Skill.GL.Result.RoundResult:GetData()

				for i, data in ipairs(roundDatas) do
					if i > Skill.TempData.HealDamageAddTurn and i >= curRound - HealDamageAddTurn then
						vaildHeal = vaildHeal + data.sumHeal[GameLogic.MAX_CAMP_COUNT - Skill.Owner.Camp + 1]

						print(string.format("第[%d]回合，治疗量[%d]", i, tostring(data.sumHeal[GameLogic.MAX_CAMP_COUNT - Skill.Owner.Camp + 1])))
					end
				end

				local max = Skill.GL.RunTime:GetTeamByCamp(GameLogic.MAX_CAMP_COUNT - Skill.Owner.Camp + 1):GetTeamMaxHp()

				dmg:AddPct(vaildHeal / max * HealDamageAddMul)

				Skill.TempData.HealDamageAddTurn = curRound

				if vaildHeal > 0 then
					local str = string.format("总治疗:%d , 总血量:%d：,增伤增加：%.3f", vaildHeal, max, vaildHeal / max * HealDamageAddMul)

					print(str)
				end
			end

			local isNeedDmg = {}

			isNeedDmg.dmg = {}

			unit:DealDamage(dmg, isNeedDmg)

			local damage = isNeedDmg.dmg
			local sumDmg = damage.finalMinusHp + damage.finalMinusShield + damage.finalRealMinusHp

			if award == true and whipAwardSuccess == false then
				Skill.GL:Fire("鞭尸", unit.UniqueId)

				local maxHp = unit:Get("最大生命")
				local precentUp = 0
				local rewardId = GetWhippedCorpseReward(Skill.GL, sumDmg, maxHp, unit.BaseData.Boss == 1, precentUp)

				if rewardId ~= nil then
					whipAwardSuccess = true

					Skill.GL:Fire("鞭尸掉落", rewardId, unit.UniqueId)
				end
			end

			if Skill.Owner:Get("生命") > 0 then
				local heal = Skill:GetCustomProperty("Heal", idx)

				if heal then
					local healVal = sumDmg * heal
					local limitHeal = Skill:GetCustomProperty("LimitHeal", idx)

					if limitHeal then
						limitHeal = limitHeal * Skill.Owner:Get("最大生命")

						if limitHeal < healVal then
							healVal = limitHeal
						end
					end

					Skill.Owner:HealHp(healVal, Skill.Owner)
				end
			end

			Skill.GL:Fire("技能-生效目标", Skill, unit, mutIdx)
			Skill.GL.ObjectPool.Damage:Recycle(damage)
		end
	end

	if frozenAtk and frozenAtk_success == true then
		local probability = Skill:GetCustomProperty("FrozenPr", idx)

		if probability then
			for i, unit in Skill.GL.UnitMgr:Selector():NotCamp(Skill.Owner.Camp):Alive():Ipairs() do
				local pr = Skill.GL:Random()

				if pr <= probability then
					unit:AddBuff(frozenAtk, unit)
				end
			end
		end
	end
end

for i, actionType in ipairs(BASE_DMG_TYPE_CONFIG) do
	SkillScript[actionType] = {}
	SkillScript[actionType].NeedPackage = true
	SkillScript[actionType].OnCast = function(Skill, idx, dmg)
		dmg = dmg or Skill:CreateDamage()

		local addVal = Skill:GetCustomProperty(actionType, idx)
		local weight = Skill:GetCustomProperty("Weight", idx)
		local weightMulVal = Skill:GetCustomProperty("WeightMulVal", idx)

		if weight and weightMulVal then
			local val = WeightRandom(weightMulVal, weight)
			local r = GameLogic.RandomTool(val.Min * 1000, val.Max * 1000) * 0.001

			addVal = r
		end

		local powerIdx = Skill.YellowBallStack
		local power = Skill:GetPowerProperty(idx, powerIdx)

		if power then
			addVal = addVal and addVal * power
		end

		if addVal then
			SkillScript.SetDamage(actionType, dmg, addVal, Skill, idx)
		else
			print("ERROR , 配置不对 ， 技能ID：" .. Skill.SkillId)
		end

		SkillScript.DealDamage(Skill, idx, dmg)

		for k, v in pairs(DmgSkillEndScript) do
			local key = Skill:GetCustomProperty(k, idx)

			if key then
				v(Skill, idx, dmg, power)
			end
		end

		Skill.GL:Fire("伤害类技能释放结束", Skill)
	end
end

SkillScript.DMG_DEBUFF_POWER = {}

function SkillScript.DMG_DEBUFF_POWER.OnCast(Skill, idx, dmg)
	dmg = dmg or Skill:CreateDamage()

	local debuffTypeOrder = Skill:GetCustomProperty("DMG_DEBUFF_POWER", idx)
	local debuffAddVal = Skill:GetCustomProperty("DebuffAddVal", idx)
	local actionType = Skill:GetCustomProperty("Action", idx)
	local addVal = Skill:GetCustomProperty("AddVal", idx)
	local weight = Skill:GetCustomProperty("Weight", idx)
	local weightMulVal = Skill:GetCustomProperty("WeightMulVal", idx)

	if weight and weightMulVal then
		local val = WeightRandom(weightMulVal, weight)
		local r = GameLogic.RandomTool(val.Min * 1000, val.Max * 1000) * 0.001

		addVal = r
	end

	local powerIdx = Skill.YellowBallStack
	local power = Skill:GetPowerProperty(idx, powerIdx)

	if power then
		addVal = addVal and addVal * power
	end

	if addVal then
		SkillScript.SetDamage(actionType, dmg, addVal, Skill, idx)
	else
		print("ERROR , 配置不对 ， 技能ID：" .. Skill.SkillId)
	end

	local mutInfo = Skill:GetCustomProperty("Mut", idx)
	local mutDamages = {}

	if mutInfo then
		for i, mut in ipairs(mutInfo) do
			local mutDmg = dmg:Copy()

			mutDmg:SetAddAtkMul(mut)
			table.insert(mutDamages, mutDmg)
		end
	else
		table.insert(mutDamages, dmg)
	end

	local t = Skill:GetCustomProperty("Target", idx)
	local targets = Skill:SelectTarget(t)

	Skill.GL:Fire("伤害目标", Skill, targets)

	for mutIdx, mutDmg in ipairs(mutDamages) do
		for i, unit in ipairs(targets) do
			Skill.Owner:Fire("受击打包", Skill, mutIdx)

			local dmg = mutDmg:Copy()

			dmg:SetMut(mutIdx)

			if unit:HasBuffTypeOrder(debuffTypeOrder) then
				dmg:AddPhyMul(debuffAddVal)
				dmg:AddMagMul(debuffAddVal)
			end

			Skill.ComboCount = Skill.ComboCount + 1

			local curCombo = Skill.GL.RunTime.GameRoundData:UpdateCombo()

			Skill.GL:Fire("更新连击", curCombo, Skill.Owner.Camp, Skill.Owner.UniqueId)

			if dmg.isGroupSession == true then
				dmg:GroupSessionCombo(curCombo)
			end

			dmg.dmgSource = Skill

			unit:DealDamage(dmg)
			Skill.GL:Fire("技能-生效目标", Skill, unit, mutIdx)
		end
	end

	Skill.GL:Fire("伤害类技能释放结束", Skill)
end

SkillScript.MIX_DMG = {}

function SkillScript.MIX_DMG.OnCast(Skill, idx, dmg)
	dmg = dmg or Skill:CreateDamage()

	local actionTypes = Skill:GetCustomProperty("MIX_DMG", idx)

	for i, actionType in ipairs(actionTypes) do
		local addVal = Skill:GetCustomProperty(actionType, idx)

		SkillScript.SetDamage(actionType, dmg, addVal, Skill, idx)
	end

	SkillScript.DealDamage(Skill, idx, dmg)
end

SkillScript.ADD_HP_PER = {}

function SkillScript.ADD_HP_PER.OnCast(Skill, idx)
	local val = Skill:GetCustomProperty("ADD_HP_PER", idx)

	if not val then
		print("ERROR , 配置不对 ， 技能ID：" .. Skill.SkillId)

		return
	end

	local powerIdx = Skill.YellowBallStack
	local power = Skill:GetPowerProperty(idx, powerIdx)

	if power then
		val = val and val * power
	end

	local t = Skill:GetCustomProperty("Target", idx)
	local targets = Skill:SelectTarget(t)

	for i, unit in ipairs(targets) do
		local addVal = unit:Get("最大生命") * val

		unit:HealHp(addVal, Skill.Owner)
		Skill.GL:Fire("技能-生效目标", Skill, unit, 1)
	end
end

SkillScript.ADD_HP_ATTRI = {}

function SkillScript.ADD_HP_ATTRI.OnCast(Skill, idx)
	local val = Skill:GetCustomProperty("ADD_HP_ATTRI", idx)

	if not val then
		print("ERROR , 配置不对 ， 技能ID：" .. Skill.SkillId)

		return
	end

	local attri = Skill:GetCustomProperty("Attri", idx)

	val = Skill.Owner:Get(attri) * val

	local powerIdx = Skill.YellowBallStack
	local power = Skill:GetPowerProperty(idx, powerIdx)

	if power then
		val = val and val * power
	end

	local t = Skill:GetCustomProperty("Target", idx)
	local targets = Skill:SelectTarget(t)

	for i, unit in ipairs(targets) do
		unit:HealHp(val, Skill.Owner)
		Skill.GL:Fire("技能-生效目标", Skill, unit, 1)
	end
end

SkillScript.ADD_SHIELD_PER = {}

function SkillScript.ADD_SHIELD_PER.OnCast(Skill, idx)
	local val = Skill:GetCustomProperty("ADD_SHIELD_PER", idx)

	if not val then
		print("ERROR , 配置不对 ， 技能ID：" .. Skill.SkillId)

		return
	end

	local powerIdx = Skill.YellowBallStack
	local power = Skill:GetPowerProperty(idx, powerIdx)

	if power then
		val = val and val * power
	end

	local t = Skill:GetCustomProperty("Target", idx)
	local targets = Skill:SelectTarget(t)
	local campIdx = targets[1].Camp
	local teamHpRemain = Skill:GetCustomProperty("TeamHpRemain", idx)

	if teamHpRemain then
		local totalHp, totalMaxHp = 0, 0

		for i, unit in Skill.GL.UnitMgr:Selector():Camp(campIdx):Ipairs() do
			totalHp = totalHp + unit:Get("生命")
			totalMaxHp = totalMaxHp + unit:Get("最大生命")
		end

		if totalMaxHp > 0 then
			local addVal = ((1 - totalHp / totalMaxHp) * teamHpRemain + 1) * val * Skill.GL.RunTime:GetTeamByCamp(campIdx):Get("最大护盾")

			Skill.Owner:AddShield(addVal)
			Skill.GL:Fire("技能-生效目标", Skill, Skill.Owner, 1)
		end
	else
		local addVal = Skill.GL.RunTime:GetTeamByCamp(campIdx):Get("最大护盾") * val

		Skill.Owner:AddShield(addVal)
		Skill.GL:Fire("技能-生效目标", Skill, Skill.Owner, 1)
	end
end

SkillScript.ADD_SHIELD_ATTRI = {}

function SkillScript.ADD_SHIELD_ATTRI.OnCast(Skill, idx)
	local val = Skill:GetCustomProperty("ADD_SHIELD_ATTRI", idx)

	if not val then
		print("ERROR , 配置不对 ， 技能ID：" .. Skill.SkillId)

		return
	end

	local attri = Skill:GetCustomProperty("Attri", idx)

	val = Skill.Owner:Get(attri) * val

	local powerIdx = Skill.YellowBallStack
	local power = Skill:GetPowerProperty(idx, powerIdx)

	if power then
		val = val and val * power
	end

	Skill.Owner:AddShield(val, Skill)
end

SkillScript.REDUCE_SHIELD_PER = {}

function SkillScript.REDUCE_SHIELD_PER.OnCast(Skill, idx)
	local val = Skill:GetCustomProperty("REDUCE_SHIELD_PER", idx)

	if not val then
		print("ERROR , 配置不对 ， 技能ID：" .. Skill.SkillId)

		return
	end

	local powerIdx = Skill.YellowBallStack
	local power = Skill:GetPowerProperty(idx, powerIdx)

	if power then
		val = val and val * power
	end

	local t = Skill:GetCustomProperty("Target", idx)
	local targets = Skill:SelectTarget(t)

	for i, unit in ipairs(targets) do
		local addVal = 0

		if unit.UnitClass == EnumFight.UnitClass.ENEMY then
			addVal = unit:Get("最大护盾") * val
		else
			addVal = Skill.GL.RunTime:GetTeamByCamp(unit.Camp):Get("最大护盾") * val * 0.2
		end

		unit:AddShield(addVal * -1, Skill)
		Skill.GL:Fire("技能-生效目标", Skill, unit, 1)
	end
end

SkillScript.ADD_BUFF_STACK = {}

function SkillScript.ADD_BUFF_STACK.OnCast(Skill, idx)
	local buffId = Skill:GetCustomProperty("ADD_BUFF", idx)
	local stack = Skill:GetCustomProperty("Stack", idx)
	local t = Skill:GetCustomProperty("Target", idx)
	local targets = Skill:SelectTarget(t)

	for i, unit in ipairs(targets) do
		for j = 1, stack do
			unit:AddBuff(buffId, Skill.Owner.UniqueId, nil)
		end

		Skill.GL:Fire("技能-生效目标", Skill, unit, 1)
	end
end

SkillScript.ADD_BUFF_PR = {}

function SkillScript.ADD_BUFF_PR.OnCast(Skill, idx)
	local buffId = Skill:GetCustomProperty("ADD_BUFF", idx)
	local probability = Skill:GetCustomProperty("ADD_BUFF_PR", idx)
	local t = Skill:GetCustomProperty("Target", idx)
	local targets = Skill:SelectTarget(t)
	local powerIdx = Skill.YellowBallStack
	local power = Skill:GetPowerProperty(idx, powerIdx)

	for i, unit in ipairs(targets) do
		local data = {}

		data.pr = Skill.GL:Random()

		Skill.GL:Fire("单位-即将随机buff", Skill.Owner, unit, data)
		Skill.GL:Fire("单位-即将被随机buff", Skill.Owner, unit, data)

		if probability >= data.pr then
			unit:AddBuff(buffId, Skill.Owner.UniqueId, power)
			Skill.GL:Fire("技能-生效目标", Skill, unit, 1)
		end
	end
end

SkillScript.ADD_BUFFS_PR = {}

function SkillScript.ADD_BUFFS_PR.OnCast(Skill, idx)
	local buffIds = Skill:GetCustomProperty("ADD_BUFFS_PR", idx)
	local t = Skill:GetCustomProperty("Target", idx)
	local targets = Skill:SelectTarget(t)
	local powerIdx = Skill.YellowBallStack
	local power = Skill:GetPowerProperty(idx, powerIdx)

	for i, unit in ipairs(targets) do
		local j = GameLogic.RandomToolInt(#buffIds)
		local id = buffIds[j]

		unit:AddBuff(id, Skill.Owner.UniqueId, power)
		Skill.GL:Fire("技能-生效目标", Skill, unit, 1)
	end
end

SkillScript.ADD_BUFF = {}

function SkillScript.ADD_BUFF.OnCast(Skill, idx)
	local buffId = Skill:GetCustomProperty("ADD_BUFF", idx)
	local t = Skill:GetCustomProperty("Target", idx)
	local targets = Skill:SelectTarget(t)
	local powerIdx = Skill.YellowBallStack
	local power = Skill:GetPowerProperty(idx, powerIdx)

	for i, unit in ipairs(targets) do
		unit:AddBuff(buffId, Skill.Owner.UniqueId, power)
		Skill.GL:Fire("技能-生效目标", Skill, unit, 1)
	end
end

SkillScript.CLEAR_BUFF_TYPE = {}

function SkillScript.CLEAR_BUFF_TYPE.OnCast(Skill, idx)
	local targetType = Skill:GetCustomProperty("CLEAR_BUFF_TYPE", idx)
	local t = Skill:GetCustomProperty("Target", idx)
	local targets = Skill:SelectTarget(t)

	for i, unit in ipairs(targets) do
		local success = false

		for buffIdx = #unit.Buffs, 1, -1 do
			local buff = unit.Buffs[buffIdx]

			for typeIdx, type in ipairs(targetType) do
				if buff.Type == type then
					buff:RemoveSelf()

					success = true
				end
			end
		end

		if success == true then
			unit:Fire("技能-飘字", unit, Skill, idx)
		end

		Skill.GL:Fire("技能-生效目标", Skill, unit, 1)
	end
end

SkillScript.CLEAR_BUFF_TYPEORDER = {}

function SkillScript.CLEAR_BUFF_TYPEORDER.OnCast(Skill, idx)
	local targetTypeorder = Skill:GetCustomProperty("CLEAR_BUFF_TYPEORDER", idx)
	local t = Skill:GetCustomProperty("Target", idx)
	local targets = Skill:SelectTarget(t)

	for i, unit in ipairs(targets) do
		local success = false

		for buffIdx = #unit.Buffs, 1, -1 do
			local buff = unit.Buffs[buffIdx]

			for typeIdx, typeorder in ipairs(targetTypeorder) do
				if buff.TypeOrder == typeorder then
					buff:RemoveSelf()

					success = true
				end
			end
		end

		if success == true then
			unit:Fire("技能-飘字", unit, Skill, idx)
		end

		Skill.GL:Fire("技能-生效目标", Skill, unit, 1)
	end
end

SkillScript.CLEAR_BUFF_CLEARTYPE = {}

function SkillScript.CLEAR_BUFF_CLEARTYPE.OnCast(Skill, idx)
	local targetTypeorder = Skill:GetCustomProperty("CLEAR_BUFF_CLEARTYPE", idx)
	local t = Skill:GetCustomProperty("Target", idx)
	local targets = Skill:SelectTarget(t)

	for i, unit in ipairs(targets) do
		local success = false

		for buffIdx = #unit.Buffs, 1, -1 do
			local buff = unit.Buffs[buffIdx]

			for typeIdx, typeorder in ipairs(targetTypeorder) do
				if buff.ClearType == typeorder then
					buff:RemoveSelf()

					success = true
				end
			end
		end

		if success == true then
			unit:Fire("技能-飘字", unit, Skill, idx)
		end

		Skill.GL:Fire("技能-生效目标", Skill, unit, 1)
	end
end

SkillScript.CLEAR_BUFF_CLEARTYPE_COUNT = {}

function SkillScript.CLEAR_BUFF_CLEARTYPE_COUNT.OnCast(Skill, idx)
	local targetTypeorder = Skill:GetCustomProperty("CLEAR_BUFF_CLEARTYPE_COUNT", idx)
	local count = Skill:GetCustomProperty("Count", idx)
	local t = Skill:GetCustomProperty("Target", idx)
	local targets = Skill:SelectTarget(t)

	for i, unit in ipairs(targets) do
		if count <= 0 then
			break
		end

		local success = false

		for buffIdx = #unit.Buffs, 1, -1 do
			if count <= 0 then
				break
			end

			local buff = unit.Buffs[buffIdx]

			for typeIdx, typeorder in ipairs(targetTypeorder) do
				if count <= 0 then
					break
				end

				if buff.ClearType == typeorder then
					buff:RemoveSelf()

					success = true
					count = count - 1
				end
			end
		end

		if success == true then
			unit:Fire("技能-飘字", unit, Skill, idx)
		end

		Skill.GL:Fire("技能-生效目标", Skill, unit, 1)
	end
end

SkillScript.CLEAR_BUFF_TYPE_COUNT = {}

function SkillScript.CLEAR_BUFF_TYPE_COUNT.OnCast(Skill, idx)
	local targetType = Skill:GetCustomProperty("CLEAR_BUFF_TYPE_COUNT", idx)
	local count = Skill:GetCustomProperty("Count", idx)
	local t = Skill:GetCustomProperty("Target", idx)
	local targets = Skill:SelectTarget(t)

	for i, unit in ipairs(targets) do
		if count <= 0 then
			break
		end

		local success = false

		for buffIdx = #unit.Buffs, 1, -1 do
			if count <= 0 then
				break
			end

			local buff = unit.Buffs[buffIdx]

			for typeIdx, type in ipairs(targetType) do
				if count <= 0 then
					break
				end

				if buff.Type == type then
					buff:RemoveSelf()

					success = true
					count = count - 1
				end
			end
		end

		if success == true then
			unit:Fire("技能-飘字", unit, Skill, idx)
		end

		Skill.GL:Fire("技能-生效目标", Skill, unit, 1)
	end
end

SkillScript.SELF_DESTRUCT = {}

function SkillScript.SELF_DESTRUCT.OnCast(Skill, idx)
	local val = Skill:GetCustomProperty("SELF_DESTRUCT", idx)
	local buffId = Skill:GetCustomProperty("ADD_BUFF", idx)
	local t = Skill:GetCustomProperty("Target", idx)
	local targets = Skill:SelectTarget(t)

	for i, unit in ipairs(targets) do
		local dmg = Skill:CreateDamage()

		dmg:AddPhyMul(val)
		dmg:AddMagMul(val)

		dmg.dmgSource = Skill

		unit:DealDamage(dmg)
		Skill.GL:Fire("技能-生效目标", Skill, unit, 1)
	end

	Skill.Owner:SetDieReason(EnumFight.DieReson.SelfDestruct)
	Skill.Owner:Kill()
	Skill.Owner:Set("生命", 0)
end

SkillScript.CHANGE_SESSION = {}

function SkillScript.CHANGE_SESSION.OnCast(Skill, idx)
	local targetType = Skill:GetCustomProperty("CHANGE_SESSION", idx)

	Skill.GL.RunTime.GameRoundData:ChangeSession(targetType)
	Skill.Owner:Fire("DoMsgAction-Trigger")
end

SkillScript.REBORN = {}

function SkillScript.REBORN.OnCast(Skill, idx)
	local val = Skill:GetCustomProperty("REBORN", idx)
	local count = Skill:GetCustomProperty("Count", idx)
	local campIdx = Skill.Owner.Camp
	local randmonUnits = {}

	for i, unit in Skill.GL.UnitMgr:Selector():Camp(campIdx):Die():Ipairs() do
		table.insert(randmonUnits, unit)
	end

	for i = 1, count do
		local j = GameLogic.RandomToolInt(#randmonUnits)
		local unit = randmonUnits[j]

		if unit then
			table.remove(randmonUnits, j)
			unit:Reborn()

			local hp = unit:Get("最大生命") * val
			local powerIdx = Skill.YellowBallStack
			local power = Skill:GetPowerProperty(idx, powerIdx)

			if power then
				hp = hp and hp * power
			end

			if hp > 0 then
				unit:Add("生命", hp)
			end

			Skill.GL:Fire("技能-生效目标", Skill, unit, 1)
		end
	end
end

SkillScript.SUMMON = {}

function SkillScript.SUMMON.OnCast(Skill, idx)
	local unitIds = Skill:GetCustomProperty("SUMMON", idx)
	local startDatas = {}

	for i, id in ipairs(unitIds) do
		local v = FightDataUtil.GetEnemyStartData({
			isSummon = true,
			unitId = id,
			level = Skill.Owner.Level
		})

		table.insert(startDatas, v)
	end

	Skill.GL.RunTime.EnemyTeam:SummonUnits(startDatas)
end

SkillScript.DEATH_NOTE = {}

function SkillScript.DEATH_NOTE.OnCast(Skill, idx)
	local probability = Skill:GetCustomProperty("DEATH_NOTE", idx)
	local t = Skill:GetCustomProperty("Target", idx)
	local targets = Skill:SelectTarget(t)
	local powerIdx = Skill.YellowBallStack
	local power = Skill:GetPowerProperty(idx, powerIdx)

	if power then
		probability = probability + power
	end

	for i, unit in ipairs(targets) do
		local data = {}

		data.pr = Skill.GL:Random()

		if probability >= data.pr then
			unit:Set("生命", 0)
		end
	end
end
