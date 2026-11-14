-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/FightDatas.lua

FightDataUtil = {}

function FightDataUtil.GetStartData(data)
	local gameStartData = {}

	gameStartData.gameId = Tenary(data.gameId, "no_game_id")
	gameStartData.stageId = data.stageId
	gameStartData.boutId = Tenary(data.boutId, -1)
	gameStartData.chaos = data.chaos
	gameStartData.pvp = Tenary(data.pvp, EnumFight.Pvp.NONE)
	gameStartData.playMode = Tenary(data.playMode, EnumFight.PlayMode.Std)

	local battleData = ConfigTable.BattleStage[ConfigTable.StageData[data.stageId].BattleStageID]

	if battleData.BattleType == "Normal" then
		gameStartData.fightMode = EnumFight.BattleType.NORMAL
	elseif battleData.BattleType == "Boss" then
		gameStartData.fightMode = EnumFight.BattleType.BOSS
	end

	gameStartData.operators = Tenary(data.operators, {})
	gameStartData.randomSeed = Tenary(data.randomSeed, 666)
	gameStartData.randomSeedForReward = Tenary(data.randomSeedForReward, 666)
	gameStartData.whipMaxNum = Tenary(data.whipMaxNum, 0)
	gameStartData.myPower = Tenary(data.myPower, 2)
	gameStartData.otherPower = Tenary(data.otherPower, 1)
	gameStartData.myName = Tenary(data.myName, "myName")
	gameStartData.otherName = Tenary(data.otherName, "otherName")
	gameStartData.bondage = Tenary(data.bondage, nil)
	gameStartData.skills = {}

	if gameStartData.bondage and gameStartData.bondage.skills then
		for k, skill in pairs(gameStartData.bondage.skills) do
			if skill.canUse then
				table.insert(gameStartData.skills, {
					skill.skillId,
					skill.skillLevel
				})
			end
		end
	end

	local unionSkills = Tenary(data.unionSkills, {})

	for i, skill in ipairs(unionSkills) do
		table.insert(gameStartData.skills, {
			skill.skillId,
			skill.skillLevel
		})
	end

	gameStartData.otherBondage = Tenary(data.otherBondage, nil)
	gameStartData.otherSkills = {}

	if gameStartData.otherBondage and gameStartData.otherBondage.skills then
		for k, skill in pairs(gameStartData.otherBondage.skills) do
			if skill.canUse then
				table.insert(gameStartData.otherSkills, {
					skill.skillId,
					skill.skillLevel
				})
			end
		end
	end

	local unionSkills = Tenary(data.otherUnionSkills, {})

	for i, skill in ipairs(unionSkills) do
		table.insert(gameStartData.otherSkills, {
			skill.skillId,
			skill.skillLevel
		})
	end

	gameStartData.teams = {}
	gameStartData.teams[1] = {}
	gameStartData.teams[2] = {}

	if data.teams then
		gameStartData.teams = data.teams

		return gameStartData
	end

	return gameStartData
end

function FightDataUtil.GetPlayerStartData(data)
	local role = data.infoRole
	local card = data.infoCard
	local addCard = data.addCard
	local _unitData = {}

	_unitData.unitId = data.infoRole.id
	_unitData.cardId = data.infoCard.id
	_unitData.camp = data.camp
	_unitData.weaponId = role:GetEquipId(eEquipSlotType.Weapon)

	if role.pb and role.pb.weaponAvatar then
		_unitData.weaponAvatar = role.pb.weaponAvatar
	end

	_unitData.listAvatarID = {}

	if role.pb and role.pb.clothes then
		for i = 1, #role.pb.clothes do
			table.insert(_unitData.listAvatarID, role.pb.clothes[i])
		end
	end

	_unitData.wave = data.wave or 1
	_unitData.level = data.level or 1
	_unitData.hpRate = card.hpPercent or 1
	_unitData.order = data.order
	_unitData.skills = {}

	local addskills = data.skills or {}

	_unitData.isCenter = data.isCenter
	_unitData.unitClass = data.unitClass or EnumFight.UnitClass.PLAYER
	_unitData.attributes = {}

	local att = role:GetBattletAtt(card, addCard)

	_unitData.attributes.Stamina = att:Get("Stamina")
	_unitData.attributes.Defend = att:Get("Defend")
	_unitData.attributes.Song = att:Get("Song")
	_unitData.attributes.Will = att:Get("Will")
	_unitData.attributes.Speed = att:Get("Speed")
	_unitData.attributes.Hit = att:Get("Hit")
	_unitData.attributes.Duck = att:Get("Duck")
	_unitData.attributes.Crit = att:Get("Crit")
	_unitData.attributes.Bruise = att:Get("Bruise")
	_unitData.attributes.CritResist = att:Get("CritResist")
	_unitData.attributes.BruiseDamage = att:Get("BruiseDamage")

	for i, data in ipairs(addskills) do
		local skillId = data.id
		local lv = data.lv

		if skillId ~= 0 then
			table.insert(_unitData.skills, {
				skillId,
				lv
			})
		end
	end

	for i, infoSkill in ipairs(card.listAllSkill) do
		local isSkillUnlock = card:TalentIsUnLock(infoSkill.data.ID)

		if infoSkill.data.Type == 1 and isSkillUnlock then
			local lv = 1

			if infoSkill.pb and infoSkill.pb.level and type(infoSkill.pb.level) == "number" then
				lv = infoSkill.pb.level
			end

			local skillId = infoSkill.data.ID

			if skillId ~= 0 then
				table.insert(_unitData.skills, {
					skillId,
					lv
				})
			end
		end
	end

	if role.listNodeSkill then
		for _, infoSkill in ipairs(role.listNodeSkill) do
			if infoSkill.data.Type == 1 then
				local lv = 1

				if infoSkill.pb and infoSkill.pb.level and type(infoSkill.pb.level) == "number" then
					lv = infoSkill.pb.level
				end

				local skillId = infoSkill.data.ID

				if skillId ~= 0 then
					table.insert(_unitData.skills, {
						skillId,
						lv
					})
				end
			end
		end
	end

	if role.listSkillBuffSkill then
		for _, infoSkill in ipairs(role.listSkillBuffSkill) do
			if infoSkill.data.Type == 1 then
				local lv = 1

				if infoSkill.pb and infoSkill.pb.level and type(infoSkill.pb.level) == "number" then
					lv = infoSkill.pb.level
				end

				local skillId = infoSkill.data.ID

				if skillId ~= 0 then
					table.insert(_unitData.skills, {
						skillId,
						lv
					})
				end
			end
		end
	end

	local enchantInfoSkills = EquipmentManager.GetEquipResonanceSkillByRole(role)

	for i, infoSkill in ipairs(enchantInfoSkills) do
		if infoSkill.data.Type == 1 then
			local lv = 1

			if infoSkill.pb and infoSkill.pb.level and type(infoSkill.pb.level) == "number" then
				lv = infoSkill.pb.level
			end

			local skillId = infoSkill.data.ID

			if skillId ~= 0 then
				table.insert(_unitData.skills, {
					skillId,
					lv
				})
			end
		end
	end

	local weaponId = role:GetEquipId(eEquipSlotType.Weapon)
	local weaponData = ConfigTable.Equipment
	local WeaponInfo = weaponData[weaponId]

	if not WeaponInfo then
		print("<color=red> not WeaponInfo  weaponId = " .. weaponId .. " UnitId = " .. UnitId .. "</color>")
	end

	if WeaponInfo.WeaponThumpSkillID == 0 then
		print("<color=red> not Thump  weaponId = " .. weaponId .. " UnitId = " .. UnitId .. "</color>")
	end

	if WeaponInfo.WeaponAttackSkillID == 0 then
		print("<color=red> not Attack  weaponId = " .. weaponId .. " UnitId = " .. UnitId .. "</color>")
	end

	table.insert(_unitData.skills, {
		WeaponInfo.WeaponThumpSkillID,
		1
	})
	table.insert(_unitData.skills, {
		WeaponInfo.WeaponAttackSkillID,
		1
	})

	local hasActiveSkill = false

	for i, skill in ipairs(_unitData.skills) do
		local cfg = ConfigTable.AllSkills[skill[1]]

		if cfg.BattleSkillType == EnumFight.SkillType.Active then
			hasActiveSkill = true

			break
		end
	end

	if hasActiveSkill == false then
		local skillId = card.data.StarTalent[1][1]

		table.insert(_unitData.skills, {
			skillId,
			1
		})
	end

	return _unitData
end

function FightDataUtil.GetEnemyStartData(data)
	local unitId = data.unitId
	local _unitData = {}

	_unitData.unitId = data.unitId
	_unitData.cardId = 0
	_unitData.camp = data.camp
	_unitData.wave = data.wave or 1
	_unitData.level = data.level or 1
	_unitData.hpRate = data.hpRate or 1
	_unitData.order = data.order or 1
	_unitData.skills = {}
	_unitData.isCenter = data.isCenter or false
	_unitData.unitClass = data.unitClass or EnumFight.UnitClass.ENEMY
	_unitData.attributes = {}
	_unitData.isSummon = data.isSummon or false
	_unitData.hp = data.hp
	_unitData.attributes.初始生命 = data.hp
	_unitData.attributes.最大生命 = data.maxhp

	local UnitData = ConfigTable.Monster[data.unitId]
	local addskills = data.skills or {}
	local skillIds = {}
	local skillIdmap = {}

	for i, data in ipairs(addskills) do
		local skillId = data.id
		local lv = data.lv

		if skillId ~= 0 and not skillIdmap[skillId] then
			skillIdmap[skillId] = {}

			table.insert(_unitData.skills, {
				skillId,
				lv
			})
		end
	end

	if UnitData.AllowSkills and UnitData.AllowSkills == 1 then
		for i, _skillIds in ipairs(UnitData.Skills) do
			for _, skillId in ipairs(_skillIds) do
				if skillId ~= 0 and not skillIdmap[skillId] then
					skillIdmap[skillId] = {}

					table.insert(_unitData.skills, {
						skillId,
						1
					})
				end
			end
		end
	else
		skillIds = UnitData.StageSkillId

		for i, skillId in ipairs(skillIds) do
			if skillId ~= 0 and not skillIdmap[skillId] then
				skillIdmap[skillId] = {}

				table.insert(_unitData.skills, {
					skillId,
					1
				})
			end
		end
	end

	skillIds = UnitData.StageOfAngryBuff

	for i, skillId in ipairs(skillIds) do
		if skillId ~= 0 and not skillIdmap[skillId] then
			skillIdmap[skillId] = {}

			table.insert(_unitData.skills, {
				skillId,
				1
			})
		end
	end

	if UnitData.AppearSkills then
		skillIds = UnitData.AppearSkills

		for i, skillId in ipairs(skillIds) do
			if skillId ~= 0 and not skillIdmap[skillId] then
				skillIdmap[skillId] = {}

				table.insert(_unitData.skills, {
					skillId,
					1
				})
			end
		end
	end

	if UnitData.OthersSkills then
		skillIds = UnitData.OthersSkills

		for i, skillId in ipairs(skillIds) do
			if skillId ~= 0 and not skillIdmap[skillId] then
				skillIdmap[skillId] = {}

				table.insert(_unitData.skills, {
					skillId,
					1
				})
			end
		end
	end

	return _unitData
end
