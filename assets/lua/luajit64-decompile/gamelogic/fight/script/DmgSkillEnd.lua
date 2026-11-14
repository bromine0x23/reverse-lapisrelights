-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/Script/DmgSkillEnd.lua

local mt = {}

DmgSkillEndScript = mt

function mt.DmgEnd_AddShield(Skill, idx, dmg, power)
	local t = Skill:GetCustomProperty("Target", idx)
	local typeOrders = Skill:GetCustomProperty("DmgEnd_AddShield", idx)
	local count = 0

	for i, unit in ipairs(Skill:SelectTarget(t)) do
		for _, typeOrder in ipairs(typeOrders) do
			if unit:HasBuffTypeOrder(typeOrder) then
				count = count + 1

				break
			end
		end
	end

	local success = false
	local probability = Skill:GetCustomProperty("Percent", idx)

	for i = 1, count do
		if probability >= Skill.GL:Random() then
			success = true

			break
		end
	end

	if success == true then
		local AddShieldValue = Skill:GetCustomProperty("AddShieldValue", idx)
		local addval = AddShieldValue * Skill.GL.RunTime:GetTeamByCamp(Skill.Owner.Camp):Get("最大护盾")

		Skill.Owner:AddShield(addval)
	end
end

function mt.DmgEnd_AddHp(Skill, idx, dmg, power)
	local t = Skill:GetCustomProperty("Target", idx)
	local typeOrders = Skill:GetCustomProperty("DmgEnd_AddHp", idx)
	local count = 0

	for i, unit in ipairs(Skill:SelectTarget(t)) do
		for _, typeOrder in ipairs(typeOrders) do
			if unit:HasBuffTypeOrder(typeOrder) then
				count = count + 1

				break
			end
		end
	end

	local success = false
	local probability = Skill:GetCustomProperty("Percent", idx)

	for i = 1, count do
		if probability >= Skill.GL:Random() then
			success = true

			break
		end
	end

	if success == true then
		local add = Skill:GetCustomProperty("AddHpValue", idx)
		local addval = add * Skill.Owner:Get("魔法攻击")
		local affectType = Skill:GetCustomProperty("AddHpTarget", idx)
		local temp = SkillSelectTarget()
		local _targets = temp:Get(Skill, affectType)

		temp:Purge()

		for i, unit in ipairs(_targets) do
			unit:HealHp(addval, Skill.Owner)
		end
	end
end
