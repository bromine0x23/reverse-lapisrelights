-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/Script/SkillScript2.lua

local mt = {}

function DefineSkill(key, t)
	key = key or "NO_KEY"
	t = t or {}

	function t.LOG(t, ...)
		print("<color=white>" .. ... .. "</color>")
	end

	function t.ERROR(t, ...)
		print("<color=red>" .. ... .. "</color>")
	end

	function t.WARNING(t, ...)
		print("<color=yellow>" .. ... .. "</color>")
	end

	SkillScript[key] = DefineClass(t)

	return SkillScript[key]
end

mt = DefineSkill("NO_KEY")
mt = DefineSkill("NO_ORDER_ATK")

function mt:Cast(dmg)
	dmg = dmg or self.Skill:CreateDamage()

	local type = self:GetCustom("NO_ORDER_ATK")
	local addval = self:GetCustom(type)
	local power = self:GetPowerProperty()

	if power then
		addval = addval and addval * power
	end

	SkillScript.SetDamage(type, dmg, addval, self.Skill, self.ActionIdx)

	local mutInfo = self:GetCustom("Mut")
	local mutDamages = {}
	local targets = {}

	for i, mut in ipairs(mutInfo) do
		local mutDmg = dmg:Copy()

		mutDmg:AddPhyMul(mut)
		mutDmg:AddMagMul(mut)
		table.insert(mutDamages, mutDmg)
		table.insert(targets, self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():GetRandom())
	end

	self.GL:Fire("伤害目标", self.Skill, targets)

	local targetMuls = self:GetCustom("TargetMul")

	for mutIdx, mutDmg in ipairs(mutDamages) do
		local unit = targets[mutIdx]

		if unit then
			if mutIdx ~= 1 then
				self.Owner:Fire("受击打包", self.Skill, mutIdx)
			end

			local dmg = mutDmg:Copy()

			dmg:SetMut(mutIdx)

			if targetMuls and targetMuls[i] then
				dmg:SetAddAtkMul(targetMuls[i])
			end

			self.Skill.ComboCount = self.Skill.ComboCount + 1

			local curCombo = self.GL.RunTime.GameRoundData:UpdateCombo()

			self.GL:Fire("更新连击", curCombo, self.Owner.Camp, self.Owner.UniqueId)

			dmg.dmgSource = self.Skill

			unit:DealDamage(dmg)
			self.GL:Fire("技能-生效目标", self.Skill, unit, mutIdx)
		end
	end

	self.GL:Fire("伤害类技能释放结束", self.Skill)
end

mt = DefineSkill("FROZEN_ATK")

function mt:Cast(dmg)
	dmg = dmg or self.Skill:CreateDamage()

	local targetTypeOrders = self:GetCustom("TyperOrders")
	local targets = {}

	for i, unit in self.GL.UnitMgr:Selector():NotCamp(self.Owner.Camp):Alive():Ipairs() do
		if unit:HasBuffTypeOrder("frozen") then
			table.insert(targets, unit)

			break
		end
	end

	local type, addval

	if #targets > 0 then
		type = self:GetCustom("TYPEORDER_ATK")
		addval = self:GetCustom(type)
	else
		targets = self:GetTargets()
		type = self:GetCustom("DEFAULT")
		addval = self:GetCustom(type)
	end

	local power = self:GetPowerProperty()

	if power then
		addval = addval and addval * power
	end

	SkillScript.SetDamage(type, dmg, addval, self.Skill, self.ActionIdx)
	SkillScript.DealDamage(self.Skill, self.ActionIdx, dmg, targets)
	self.GL:Fire("伤害类技能释放结束", self.Skill)
end

mt = DefineSkill("REFRESH_ROUND_HP_CUSTOM")

function mt:_Active(val)
	local arrtis = self:GetCustom("Arg2")
	local vals = self:GetCustom("Arg3")
	local isVal = self:GetCustom("Val")
	local fx = self:GetCustom("Fx")

	if fx and val == true then
		self.GL:Fire("单位-添加特效", fx, self.Owner)
	end

	local uifx = self:GetCustom("UIFx")

	if uifx and val == true then
		self.GL:Fire("单位-添加UI特效", uifx, self.Owner)
	end

	local iconfx = self:GetCustom("IconFx")

	if iconfx and val == true then
		self.GL:Fire("单位-添加Icon特效", iconfx, self.Owner)
	end

	for i, attri in ipairs(arrtis) do
		if val == false then
			if isVal then
				self.Owner:Add(attri, vals[i] * -1)
			else
				self.Owner:AddMul(attri, vals[i] * -1)
			end
		elseif isVal then
			self.Owner:Add(attri, vals[i])
		else
			self.Owner:AddMul(attri, vals[i])
		end
	end

	self.IsActive = val
end

function mt:OnEvent()
	local operator = self:GetCustom("REFRESH_ROUND_HP_CUSTOM")
	local dest = self:GetCustom("Arg1")
	local hp = self.Owner:Get("生命") / self.Owner:Get("最大生命")

	if operator == ">" then
		if dest <= hp and self.IsActive == false then
			self:_Active(true)
		elseif hp < dest and self.IsActive == true then
			self:_Active(false)
		end
	elseif operator == "<" then
		if hp <= dest and self.IsActive == false then
			self:_Active(true)
		elseif dest < hp and self.IsActive == true then
			self:_Active(false)
		end
	end
end

function mt:Add()
	self.IsActive = false

	self.Owner:On("更新回合", self.OnEvent, self)
end

function mt:Remove()
	if self.IsActive == true then
		self:_Active(false)
	end

	self.Owner:Off("更新回合", self.OnEvent, self)
end

mt = DefineSkill("REFRESH_ROUND_HP_CUSTOM_BUFF")

function mt:_Active(val)
	local buffs = self:GetCustom("Arg2")

	if val == false then
		for buffidx, buffId in ipairs(buffs) do
			local ownbuff = self.Owner:HasBuff(buffId)

			if ownbuff then
				ownbuff:RemoveSelf()
			end
		end
	else
		for buffidx, buffId in ipairs(buffs) do
			self.Owner:AddBuff(buffId)
		end
	end

	self.IsActive = val
end

function mt:OnEvent()
	local operator = self:GetCustom("REFRESH_ROUND_HP_CUSTOM_BUFF")
	local dest = self:GetCustom("Arg1")
	local hp = self.Owner:Get("生命") / self.Owner:Get("最大生命")

	if operator == ">" then
		if dest <= hp and self.IsActive == false then
			self:_Active(true)
		elseif hp < dest and self.IsActive == true then
			self:_Active(false)
		end
	elseif operator == "<" then
		if hp <= dest and self.IsActive == false then
			self:_Active(true)
		elseif dest < hp and self.IsActive == true then
			self:_Active(false)
		end
	end
end

function mt:Add()
	self.IsActive = false

	self.Owner:On("更新回合", self.OnEvent, self)
end

function mt:Remove()
	if self.IsActive == true then
		self:_Active(false)
	end

	self.Owner:Off("更新回合", self.OnEvent, self)
end

mt = DefineSkill("DEAL_DMG_HP_CUSTOM")

function mt:OnEvent(unit, dmg, lastHp)
	if unit.UniqueId ~= self.Owner.UniqueId then
		return
	end

	local fx = self:GetCustom("Fx")
	local operator = self:GetCustom("DEAL_DMG_HP_CUSTOM")
	local dest = self:GetCustom("Arg1")
	local hp = dmg.finalMinusHp / self.Owner:Get("最大生命")

	if operator == ">" then
		if dest <= hp then
			if fx then
				self.GL:Fire("单位-添加特效", fx, self.Owner)
			end

			local uifx = self:GetCustom("UIFx")

			if uifx then
				self.GL:Fire("单位-添加UI特效", uifx, self.Owner)
			end

			local iconfx = self:GetCustom("IconFx")

			if iconfx then
				self.GL:Fire("单位-添加Icon特效", iconfx, self.Owner)
			end

			local buffs = self:GetCustom("Arg2")

			for i, buff in ipairs(buffs) do
				self.Owner:AddBuff(buff, self.Owner)
			end
		end
	elseif operator == "<" and hp <= dest then
		if fx then
			self.GL:Fire("单位-添加特效", fx, self.Owner)
		end

		local uifx = self:GetCustom("UIFx")

		if uifx then
			self.GL:Fire("单位-添加UI特效", uifx, self.Owner)
		end

		local iconfx = self:GetCustom("IconFx")

		if iconfx then
			self.GL:Fire("单位-添加Icon特效", iconfx, self.Owner)
		end

		local buffs = self:GetCustom("Arg2")

		for i, buff in ipairs(buffs) do
			self.Owner:AddBuff(buff, self.Owner)
		end
	end
end

function mt:Add()
	self.Owner:On("单位-受到伤害", self.OnEvent, self)
end

function mt:Remove()
	self.Owner:Off("单位-受到伤害", self.OnEvent, self)
end

mt = DefineSkill("DEAL_DMG_HEAL_CUSTOM")

function mt:OnEvent(unit, dmg, lastHp)
	if unit.UniqueId ~= self.Owner.UniqueId then
		return
	end

	local operator = self:GetCustom("DEAL_DMG_HEAL_CUSTOM")
	local dest = self:GetCustom("Arg1")
	local hp = dmg.finalMinusHp / self.Owner:Get("最大生命")

	if operator == ">" then
		if dest <= hp and self.Owner:Get("生命") > 0 then
			local healVal = self:GetCustom("Arg2")

			self.Owner:HealHp(healVal * self.Owner:Get("最大生命"), self.Owner)
		end
	elseif operator == "<" and hp <= dest and self.Owner:Get("生命") > 0 then
		local healVal = self:GetCustom("Arg2")

		self.Owner:HealHp(healVal * self.Owner:Get("最大生命"), self.Owner)
	end
end

function mt:Add()
	self.Owner:On("单位-受到伤害", self.OnEvent, self)
end

function mt:Remove()
	self.Owner:Off("单位-受到伤害", self.OnEvent, self)
end

mt = DefineSkill("DEAL_DMG_PERCENT_ADD_BUFF")

function mt:OnEvent(unit, dmg, lastHp)
	if unit.UniqueId ~= self.Owner.UniqueId then
		return
	end

	local probability = self:GetCustom("DEAL_DMG_PERCENT_ADD_BUFF")
	local buffIds = self:GetCustom("AddBuff")
	local pr = self.Skill.GL:Random()

	if pr <= probability then
		local fx = self:GetCustom("Fx")

		if fx then
			self.GL:Fire("单位-添加特效", fx, self.Owner)
		end

		local uifx = self:GetCustom("UIFx")

		if uifx then
			self.GL:Fire("单位-添加UI特效", uifx, self.Owner)
		end

		local iconfx = self:GetCustom("IconFx")

		if iconfx then
			self.GL:Fire("单位-添加Icon特效", iconfx, self.Owner)
		end

		for i, buffId in ipairs(buffIds) do
			unit:AddBuff(buffId, self.Owner.UniqueId)
		end
	end
end

function mt:Add()
	self.Owner:On("单位-受到伤害", self.OnEvent, self)
end

function mt:Remove()
	self.Owner:Off("单位-受到伤害", self.OnEvent, self)
end

mt = DefineSkill("SOURCE_DMG_PERCENT_ADD_BUFF")

function mt:OnEvent(source, unit, dmg)
	if source.UniqueId ~= self.Owner.UniqueId then
		return
	end

	local probability = self:GetCustom("SOURCE_DMG_PERCENT_ADD_BUFF")
	local buffIds = self:GetCustom("AddBuff")
	local pr = self.Skill.GL:Random()
	local buffTarget = self:GetTargets()

	if pr <= probability then
		local fx = self:GetCustom("Fx")

		if fx then
			self.GL:Fire("单位-添加特效", fx, self.Owner)
		end

		local uifx = self:GetCustom("UIFx")

		if uifx then
			self.GL:Fire("单位-添加UI特效", uifx, self.Owner)
		end

		local iconfx = self:GetCustom("IconFx")

		if iconfx then
			self.GL:Fire("单位-添加Icon特效", iconfx, self.Owner)
		end

		for i, buffId in ipairs(buffIds) do
			for _, _target in ipairs(buffTarget) do
				_target:AddBuff(buffId, self.Owner.UniqueId)
			end
		end
	end
end

function mt:Add()
	self.Owner:On("单位-造成伤害", self.OnEvent, self)
end

function mt:Remove()
	self.Owner:Off("单位-造成伤害", self.OnEvent, self)
end

mt = DefineSkill("DEAL_DMG_PERCENT_HEAL")

function mt:OnEvent(unit, dmg, lastHp)
	if unit.UniqueId ~= self.Owner.UniqueId then
		return
	end

	local probability = self:GetCustom("DEAL_DMG_PERCENT_HEAL")
	local healVal = self:GetCustom("Heal")
	local pr = self.Skill.GL:Random()

	if pr <= probability and self.Owner:Get("生命") > 0 then
		local fx = self:GetCustom("Fx")

		if fx then
			self.GL:Fire("单位-添加特效", fx, self.Owner)
		end

		local uifx = self:GetCustom("UIFx")

		if uifx then
			self.GL:Fire("单位-添加UI特效", uifx, self.Owner)
		end

		local iconfx = self:GetCustom("IconFx")

		if iconfx then
			self.GL:Fire("单位-添加Icon特效", iconfx, self.Owner)
		end

		local addval = healVal * self.Owner:Get("最大生命")

		self.Owner:HealHp(addval, unit)
	end
end

function mt:Add()
	self.Owner:On("单位-受到伤害", self.OnEvent, self)
end

function mt:Remove()
	self.Owner:Off("单位-受到伤害", self.OnEvent, self)
end

mt = DefineSkill("SOURCE_DMG_PERCENT_HEAL")

function mt:OnEvent(source, unit, dmg)
	if source.UniqueId ~= self.Owner.UniqueId then
		return
	end

	local probability = self:GetCustom("SOURCE_DMG_PERCENT_HEAL")
	local healVal = self:GetCustom("Heal")
	local pr = self.Skill.GL:Random()

	if pr <= probability then
		local addval = healVal * self.Owner:Get("最大生命")

		self.Owner:HealHp(addval, unit)

		local fx = self:GetCustom("Fx")

		if fx then
			self.GL:Fire("单位-添加特效", fx, self.Owner)
		end

		local uifx = self:GetCustom("UIFx")

		if uifx then
			self.GL:Fire("单位-添加UI特效", uifx, self.Owner)
		end

		local iconfx = self:GetCustom("IconFx")

		if iconfx then
			self.GL:Fire("单位-添加Icon特效", iconfx, self.Owner)
		end
	end
end

function mt:Add()
	self.Owner:On("单位-造成伤害", self.OnEvent, self)
end

function mt:Remove()
	self.Owner:Off("单位-造成伤害", self.OnEvent, self)
end

mt = DefineSkill("SOURCE_DMG_PERCENT_SHIELD")

function mt:OnEvent(source, unit, dmg)
	if self.Owner.UnitClass ~= EnumFight.UnitClass.PLAYER then
		return
	end

	if source.UniqueId ~= self.Owner.UniqueId then
		return
	end

	local probability = self:GetCustom("SOURCE_DMG_PERCENT_SHIELD")
	local healVal = self:GetCustom("Shield")
	local pr = self.Skill.GL:Random()

	if pr <= probability then
		local fx = self:GetCustom("Fx")

		if fx then
			self.GL:Fire("单位-添加特效", fx, self.Owner)
		end

		local uifx = self:GetCustom("UIFx")

		if uifx then
			self.GL:Fire("单位-添加UI特效", uifx, self.Owner)
		end

		local iconfx = self:GetCustom("IconFx")

		if iconfx then
			self.GL:Fire("单位-添加Icon特效", iconfx, self.Owner)
		end

		local addval = healVal * self.Owner:Get("最大护盾")

		self.Owner:AddShield(addval, unit)
	end
end

function mt:Add()
	if self.Owner.UnitClass ~= EnumFight.UnitClass.PLAYER then
		return
	end

	self.Owner:On("单位-造成伤害", self.OnEvent, self)
end

function mt:Remove()
	if self.Owner.UnitClass ~= EnumFight.UnitClass.PLAYER then
		return
	end

	self.Owner:Off("单位-造成伤害", self.OnEvent, self)
end

mt = DefineSkill("POWER_HEAL")

function mt:OnEvent(unit, addHpData)
	if unit.UniqueId ~= self.Owner.UniqueId then
		return
	end

	local val = self:GetCustom("POWER_HEAL")

	addHpData.addVal = addHpData.addVal * (1 + val)

	local fx = self:GetCustom("Fx")

	if fx then
		self.GL:Fire("单位-添加特效", fx, self.Owner)
	end

	local uifx = self:GetCustom("UIFx")

	if uifx then
		self.GL:Fire("单位-添加UI特效", uifx, self.Owner)
	end

	local iconfx = self:GetCustom("IconFx")

	if iconfx then
		self.GL:Fire("单位-添加Icon特效", iconfx, self.Owner)
	end
end

function mt:Add()
	self.Owner:On("单位-即将受到治疗", self.OnEvent, self)
end

function mt:Remove()
	self.Owner:Off("单位-即将受到治疗", self.OnEvent, self)
end

mt = DefineSkill("POWER_HEAL_SOUECE")

function mt:OnEvent(target, healer, addHpData)
	if healer.UniqueId ~= self.Owner.UniqueId then
		return
	end

	local val = self:GetCustom("POWER_HEAL_SOUECE")

	addHpData.addVal = addHpData.addVal * val

	local fx = self:GetCustom("Fx")

	if fx then
		self.GL:Fire("单位-添加特效", fx, self.Owner)
	end

	local uifx = self:GetCustom("UIFx")

	if uifx then
		self.GL:Fire("单位-添加UI特效", uifx, self.Owner)
	end

	local iconfx = self:GetCustom("IconFx")

	if iconfx then
		self.GL:Fire("单位-添加Icon特效", iconfx, self.Owner)
	end
end

function mt:Add()
	self.Owner:On("单位-即将治疗目标", self.OnEvent, self)
end

function mt:Remove()
	self.Owner:Off("单位-即将治疗目标", self.OnEvent, self)
end

mt = DefineSkill("DEAL_DMG_PERCENT_REFLECT")

function mt:OnEvent(unit, dmg, lastHp)
	if unit.UniqueId ~= self.Owner.UniqueId then
		return
	end

	if dmg.dmgType == EnumFight.DamageType.Dot then
		return
	end

	if dmg.dmgType == EnumFight.DamageType.Anti then
		return
	end

	local probability = self:GetCustom("DEAL_DMG_PERCENT_REFLECT")
	local reflect = self:GetCustom("Reflect")
	local pr = self.Skill.GL:Random()

	if pr <= probability then
		local fx = self:GetCustom("Fx")

		if fx then
			self.GL:Fire("单位-添加特效", fx, self.Owner)
		end

		local uifx = self:GetCustom("UIFx")

		if uifx then
			self.GL:Fire("单位-添加UI特效", uifx, self.Owner)
		end

		local iconfx = self:GetCustom("IconFx")

		if iconfx then
			self.GL:Fire("单位-添加Icon特效", iconfx, self.Owner)
		end

		local val = reflect * dmg.finalMinusHp
		local newDamage = dmg:Copy()

		newDamage:SetSource(self.Owner)

		newDamage.damagePhy = val
		newDamage.damageMag = 0
		newDamage.dmgType = EnumFight.DamageType.Anti

		local source = self.Owner.GL.UnitMgr:FindUnitById(dmg.srcUniqueId)

		if source then
			newDamage.dmgSource = self.Skill

			source:DealDamage(newDamage)
		end
	end
end

function mt:Add()
	self.Owner:On("单位-受到伤害", self.OnEvent, self)
end

function mt:Remove()
	self.Owner:Off("单位-受到伤害", self.OnEvent, self)
end

mt = DefineSkill("ADD_MP")

function mt:Cast()
	local val = self:GetCustom("ADD_MP")

	self.GL.RunTime:GetTeamByCamp(self.Owner.Camp):ForceMp(val)
end

mt = DefineSkill("REDUCE_MP")

function mt:Cast()
	local val = self:GetCustom("REDUCE_MP")
	local targets = self:GetTargets()

	self.GL.RunTime:GetTeamByCamp(targets[1].Camp):ForceMp(val * -1)

	for i, unit in ipairs(targets) do
		self.Owner:Fire("技能-生效目标", self.Skill, unit, 1)
	end
end

mt = DefineSkill("REFRESH_ROUND_ADD_MP")

function mt:OnEvent()
	local val = self:GetCustom("REFRESH_ROUND_ADD_MP")

	self.GL.RunTime:GetTeamByCamp(self.Owner.Camp):ForceMp(val)
end

function mt:Add()
	self.Owner:On("更新回合", self.OnEvent, self)
end

function mt:Remove()
	self.Owner:Off("更新回合", self.OnEvent, self)
end

mt = DefineSkill("ADD_MP_ONCE")

function mt:Add()
	local val = self:GetCustom("ADD_MP_ONCE")

	self.GL.RunTime:GetTeamByCamp(self.Owner.Camp):ForceMp(val)
end

mt = DefineSkill("ADD_MAX_HP_ONCE")

local function AddMaxHp_ADD_MAX_HP_ONCE(unit, val)
	unit:AddMul("最大生命", val)
end

function mt:OnEvent(unit)
	local val = self:GetCustom("ADD_MAX_HP_ONCE")

	AddMaxHp_ADD_MAX_HP_ONCE(unit, val)
end

function mt:Add()
	for i, unit in self.GL.UnitMgr:Selector():Camp(self.Owner.Camp):Ipairs() do
		local val = self:GetCustom("ADD_MAX_HP_ONCE")

		AddMaxHp_ADD_MAX_HP_ONCE(unit, val)
	end

	self.Owner:On("单位-创建", self.OnEvent, self)
end

function mt:Remove()
	self.Owner:Off("单位-创建", self.OnEvent, self)
end

mt = DefineSkill("DOT_OUTBREAK")

function mt:Cast()
	local targets = self:GetTargets()

	self.GL:Fire("伤害目标", self.Skill, targets)

	for i, unit in ipairs(targets) do
		local targetTypeOrders = self:GetCustom("DOT_OUTBREAK")

		for i, targetTypeOrder in ipairs(targetTypeOrders) do
			local Buff = unit:HasBuffTypeOrder(targetTypeOrder)

			if Buff == nil then
				Buff = unit:HasBuffType(targetTypeOrder)
			end

			if Buff then
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

				if Buff.Stack > 0 then
					dmgHp = maxHp * percentHp * Buff.Stack
				end

				local source = Buff.GL.UnitMgr:FindUnitById(Buff.SourceUniqueId)
				local dmg = source:CreateDamage()

				dmg.dmgType = EnumFight.DamageType.DotBreak
				dmg.dot = dmgHp * Buff.Round
				dmg.dmgSource = Buff

				Buff.Owner:DealDamage(dmg)
				Buff:RemoveSelf()
				self.GL:Fire("技能-生效目标", self.Skill, Buff.Owner, 1)
			end
		end
	end
end

mt = DefineSkill("ADD_BUFF_OPEN")

function mt:Add()
	local buffId = self:GetCustom("ADD_BUFF_OPEN")
	local targets = self:GetTargets()

	for i, unit in ipairs(targets) do
		unit:AddBuff(buffId, self.Owner.UniqueId)
		self.Owner:Fire("技能-生效目标", self.Skill, self.Owner, 1)
	end
end

mt = DefineSkill("BUFF_STACK")

function mt:Cast()
	local types = self:GetCustom("Type")

	types = types or {}

	local typeOrders = self:GetCustom("TypeOrder")

	typeOrders = typeOrders or {}

	local stack = self:GetCustom("Stack")
	local targets = self:GetTargets()

	for i, unit in ipairs(targets) do
		for buffIdx, ownBuff in ipairs(unit.Buffs) do
			local success = false

			for _, cfgType in ipairs(types) do
				if ownBuff.Type == cfgType then
					for stackIdx = 1, stack do
						unit:AddBuff(ownBuff.BuffId, ownBuff.SourceUniqueId)

						success = true
					end
				end
			end

			for _, cfgTypeOrder in ipairs(typeOrders) do
				if ownBuff.TypeOrder == cfgTypeOrder then
					for stackIdx = 1, stack do
						unit:AddBuff(ownBuff.BuffId, ownBuff.SourceUniqueId)

						success = true
					end
				end
			end

			if success == true then
				self.Owner:Fire("技能-生效目标", self.Skill, unit, 1)
			end
		end
	end
end

mt = DefineSkill("COPY_BUFFS")

function mt:Cast()
	local typeOrTypeOrders = self:GetCustom("COPY_BUFFS")
	local targets = self:GetTargets()
	local target = targets[1]

	if not target then
		return
	end

	local copyBuffs = {}

	for i, buff in ipairs(target.Buffs) do
		for _, typeOrTypeOrder in ipairs(typeOrTypeOrders) do
			if buff.Type == typeOrTypeOrder or buff.TypeOrder == typeOrTypeOrder then
				table.insert(copyBuffs, buff)
			end
		end
	end

	for i, unit in self.GL.UnitMgr:Selector():Camp(target.Camp):Alive():IsNotUniqueId(target.UniqueId):Ipairs() do
		for _, buff in ipairs(copyBuffs) do
			if buff.Stack > 0 then
				for j = 1, buff.Stack do
					unit:AddBuff(buff.BuffId, buff.SourceUniqueId, nil)
				end
			else
				unit:AddBuff(buff.BuffId, buff.SourceUniqueId, nil)
			end
		end

		self.Owner:Fire("技能-生效目标", self.Skill, self.Owner, 1)
	end
end

local function _getVaildBuff_BUFF_TIME_ADD_TYPE(mt)
	local targets = mt:GetTargets()
	local target = targets[1]

	if not target then
		return {}
	end

	local bufftypes = mt:GetCustom("BUFF_TIME_ADD_TYPE")
	local outs = {}
	local count = 0
	local _buffTarget = mt:GetCustom("BuffTarget")

	if _buffTarget == "Random1" then
		count = 1
	elseif _buffTarget == "Random2" then
		count = 2
	elseif _buffTarget == "Random3" then
		count = 3
	elseif _buffTarget == "All" then
		count = #vaildBuffs
	else
		count = 0
	end

	for _, target in ipairs(targets) do
		local vaildBuffs = {}

		for __, buff in ipairs(target.Buffs) do
			for ___, type in ipairs(bufftypes) do
				if buff.Type == type and buff.Round ~= -1 then
					table.insert(vaildBuffs, buff)
				end
			end
		end

		if count < #vaildBuffs then
			for i = 1, count do
				local j = GameLogic.RandomToolInt(#vaildBuffs)
				local random = vaildBuffs[j]

				table.remove(vaildBuffs, j)
				table.insert(outs, random)
			end
		else
			for i, bf in ipairs(vaildBuffs) do
				table.insert(outs, bf)
			end
		end
	end

	return outs
end

mt = DefineSkill("BUFF_TIME_ADD_TYPE")

function mt:Cast()
	local outs = _getVaildBuff_BUFF_TIME_ADD_TYPE(self)
	local addRound = self:GetCustom("Turn")

	for i, buff in ipairs(outs) do
		local newRound = buff.Round + addRound

		if newRound > buff.CfgRound then
			newRound = buff.CfgRound
		elseif newRound <= 0 then
			newRound = 0
		end

		buff.Round = newRound

		self.Owner:Fire("单位-更新buff", buff.Owner, buff)
	end
end

mt = DefineSkill("BUFF_TIME_MINUS_TYPE")

function mt:Cast()
	local outs = _getVaildBuff_BUFF_TIME_ADD_TYPE(self)
	local addRound = self:GetCustom("Turn")

	for i, buff in ipairs(outs) do
		local newRound = buff.Round - addRound

		if newRound > buff.CfgRound then
			newRound = buff.CfgRound
		elseif newRound <= 0 then
			newRound = 0
		end

		buff.Round = newRound

		self.Owner:Fire("单位-更新buff", buff.Owner, buff)
	end
end
