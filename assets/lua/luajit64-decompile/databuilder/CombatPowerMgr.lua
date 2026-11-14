-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/DataBuilder/CombatPowerMgr.lua

CombatPowerMgr = {}

function GetTeamSlotCombatPower(teamSlot, card)
	local attr = teamSlot.attributes
	local hp = attr.Stamina * GetConfigArgInt("FightValueHPRatio")
	local def = attr.Defend * GetConfigArgInt("FightValueDefRatio")
	local atk = (attr.Song + attr.Will) * GetConfigArgInt("FightValueAtkRatio")
	local k = 0

	if card then
		local skill

		for _, v in pairs(card.listSkill) do
			if v.data.Type == eAllSkillType.battle and v.data.BattleSkillType == eBattleSkillType.active then
				skill = v

				break
			end
		end

		if skill then
			local listK = GetConfigArgJson("FightValueSkillAddPer") or {}
			local level = math.abs(skill.skillLevel or 1)
			local index = TenaryOp(level < #listK, level, #listK)

			k = listK[index]
		end
	end

	return math.ceil((atk + def + hp) * (1 + k))
end

function CombatPowerMgr:GetTeamCombatPower(team, listRoleData)
	local combatPower = 0

	for _, v in pairs(team) do
		local card

		for _, n in pairs(listRoleData) do
			if v.cardId == n.card.id then
				card = n.card

				break
			end
		end

		combatPower = combatPower + GetTeamSlotCombatPower(v, card)
	end

	return combatPower
end
