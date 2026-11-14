-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/DataBuilder/BondageMgr.lua

BondageMgr = {}

function BondageMgr:IsEnableBondageSkill(combData, skillId, teamData)
	local members = combData.MemberList
	local maxNum = #members
	local battleNum = 0

	for _, v in pairs(members) do
		for _, n in pairs(teamData) do
			if v == n.role.id then
				battleNum = battleNum + 1

				break
			end
		end
	end

	local condition = combData.ActivatedRole
	local skillIds = combData.SkillList

	for k, v in pairs(skillIds) do
		if v == skillId then
			local needNum = condition[k]

			return needNum <= battleNum
		end
	end

	return false
end

function BondageMgr:GetBondageSkill(teamFetter, teamData)
	if not teamFetter or not teamFetter then
		return {}
	end

	local combData = ConfigTable.CharacterTeam[teamFetter.id]

	if not combData then
		return {}
	end

	local skills = teamFetter.skills
	local tab = {}

	for _, v in ipairs(skills) do
		local isEnable = self:IsEnableBondageSkill(combData, v.id, teamData)
		local canUse = false

		if isEnable then
			canUse = true
		end

		local temp = {
			skillId = v.id,
			skillLevel = v.level,
			canUse = canUse
		}

		table.insert(tab, temp)
	end

	local bondage = {
		maxRole = maxNum,
		battleRole = battleNum,
		skills = tab,
		combinationId = combId
	}

	return bondage
end
