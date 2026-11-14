-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/GameCMD/GameCMD.lua

GameCMD = GLClass("GameCMD", GameHelper)
GameCMD.Action = {
	eaddmp = "CMD_EnemyAddMp",
	addshield = "CMD_PlayerAddShield",
	eskill = "CMD_EnemySkill",
	eaddshield = "CMD_EnemyAddShield",
	mp = "CMD_InfoMp",
	paddbuffa = "CMD_PlayerAddBuff1",
	win = "CMD_Win",
	infobuff = "CMD_InfoBuff",
	einfobuff = "CMD_EnemyInfoBuff",
	paddatk = "CMD_PlayerAddAtk",
	paddbuff = "CMD_PlayerAddBuff",
	gameinfo = "CMD_GameInfo",
	wave = "CMD_RefreshWave",
	lose = "CMD_Lose",
	pinfobuff = "CMD_PlayerInfoBuff",
	paddbuffd = "CMD_PlayerAddBuff4",
	help = "CMD_Help",
	palladdbuff = "CMD_AllPlayerAddBuff",
	eaddatk = "CMD_EnemyAddAtk",
	changemonster = "CMD_ChangeMonster",
	pkill = "CMD_PlayerKill",
	palive = "CMD_PlayerAlive",
	alive = "CMD_PlayerAlive",
	infocritical = "CMD_Critical",
	purgegamelogic = "CMD_PurgeGameLogic",
	testselect = "CMD_TestTarget",
	infoattack = "CMD_Attack",
	nobuff = "CMD_ClearAllBuff",
	testselector = "CMD_Selector",
	unitget = "CMD_UnitGet",
	addmp = "CMD_PlayerAddMp",
	paddbuffc = "CMD_PlayerAddBuff3",
	infoattri = "CMD_InfoAttribute",
	paddbuffb = "CMD_PlayerAddBuff2",
	json = "CMD_JsonRet",
	changesession = "CMD_ChangeSession",
	ekill = "CMD_EnemyKill",
	paddhp = "CMD_PlayerAddhp",
	eaddbuff = "CMD_EnemyAddBuff",
	eaddhp = "CMD_EnemyAddhp",
	round = "CMD_RefreshRound",
	unitset = "CMD_UnitSet",
	pskill = "CMD_PlayerSkill",
	paddbuffe = "CMD_PlayerAddBuff5"
}

function GameCMD:ctor(GL)
	self.GL = GL

	self:Reset()
	self:InitFunMap()
	self:OnRegisterEvent()
end

function GameCMD:Reset()
	self.FunMap = {}
end

function GameCMD:Purge()
	self:OnUnRegisterEvent()
	self:Reset()
end

function GameCMD:OnRegisterEvent()
	Event.Instance:Add("CMD_Message", self.OnCMDMessage, self)
	Event.Instance:Add("CMD_PageCMD", self.CMD_PageCMD, self)
end

function GameCMD:OnUnRegisterEvent()
	Event.Instance:Remove("CMD_Message", self.OnCMDMessage, self)
	Event.Instance:Remove("CMD_PageCMD", self.CMD_PageCMD, self)
end

function GameCMD:CMD_PageCMD(pageCmd)
	pageCmd:SetGL(self.GL)
end

function GameCMD:OnCMDMessage(str)
	if str ~= "json" then
		self.GL.OperatorRecord:CMD(str)
	end

	str = string.gsub(str, " ", "")

	local cmdKey = ""
	local cmdVal = {}
	local i, j = string.find(str, "-%d+")

	if not i then
		i, j = string.find(str, "%d+")
	end

	if not i then
		cmdKey = str
	else
		cmdKey = string.lower(string.sub(str, 0, i - 1))
		cmdVal = string.sub(str, i, #str)
	end

	local args = {}

	if type(cmdVal) == "string" then
		args = cmdVal:split(",")
	end

	local argList = {}

	for i, arg in ipairs(args) do
		local numberArg = tonumber(arg)

		if numberArg then
			arg = numberArg
		end

		table.insert(argList, arg)
	end

	local fun = self.FunMap[cmdKey]

	if fun then
		if not unpack then
			fun(self, table.unpack(argList))
		else
			fun(self, unpack(argList))
		end
	else
		self:LOG("未定义的cmdKey:" .. cmdKey)
		self.GL:Fire(cmdKey)
	end
end

function GameCMD:RegisterFun(key, fun)
	self.FunMap[key] = fun
end

function GameCMD:InitFunMap()
	self.FunMap = {}

	for k, v in pairs(GameCMD.Action) do
		self:RegisterFun(k, self[v])
	end
end

function GameCMD:CMD_Help()
	local str = ""

	for actionKey, v in pairs(GameCMD.Action) do
		str = str .. actionKey .. ", "
	end

	self:LOG(str)

	local units1 = self.GL.UnitMgr:Selector():SortMin("防御"):GetArray()

	for i, unit in ipairs(units1) do
		print(unit.UnitTitle .. " " .. unit:Get("防御"))
	end

	print("--------------------------------------------------------------")

	local units2 = self.GL.UnitMgr:Selector():SortMin("生命"):GetArray()

	for i, unit in ipairs(units2) do
		print(unit.UnitTitle .. " " .. unit:Get("生命"))
	end

	print("--------------------------------------------------------------")

	local units3 = self.GL.UnitMgr:Selector():Alive():Camp(1):SortMin("生命"):GetArray()

	for i, unit in ipairs(units3) do
		print(unit.UnitTitle .. " " .. unit:Get("生命"))
	end
end

function GameCMD:CMD_GameInfo()
	local str = "stageId:" .. self.GL.GameStartData.stageId
	local monsters = " "

	for i, unit in self.GL.UnitMgr:Selector():Camp(2):Ipairs() do
		monsters = monsters .. " " .. unit.UnitId .. unit.UnitTitle
	end

	str = str .. monsters

	self:LOG(str)
end

function GameCMD:_GetEnemy(teamIdx)
	if teamIdx then
		local unit = self.GL.UnitMgr:Selector():Camp(2):Order(teamIdx):Get()

		return unit
	end

	local unit = self.GL.RunTime.CurSelectTarget

	unit = unit or self.GL.UnitMgr:Selector():Camp(2):Alive():Get()

	return unit
end

function GameCMD:_GetPlayer(teamIdx)
	if not teamIdx then
		local unit = self.GL.UnitMgr:Selector():Camp(1):Alive():Get()

		return unit
	end

	local unit = self.GL.UnitMgr:Selector():Camp(1):Order(teamIdx):Get()

	return unit
end

function GameCMD:_GetUnit(camp, teamIdx)
	if not camp or camp == 1 then
		return self:_GetPlayer(teamIdx)
	else
		return self:_GetEnemy(teamIdx)
	end
end

function GameCMD:CMD_RefreshRound()
	self.GL.RunTime:CMDRefreshRound()
end

function GameCMD:CMD_RefreshWave()
	self.GL.RunTime:CMDRefreshWave()
end

function GameCMD:CMD_PurgeGameLogic(loserCamp)
	self.GL:Purge()
end

function GameCMD:CMD_EnemySkill(battleSkillId)
	local cfg = ConfigTable.BattleSkillData[battleSkillId]

	if not cfg then
		self:ERROR("需要填写BattleSkillId  或者BattleSkillData中没有这个id")

		return
	end

	local allSkillId = cfg.AllSkillID
	local allCfg = ConfigTable.AllSkills[allSkillId]

	if not allCfg then
		self:ERROR("AllSkills中没有这个id " .. allSkillId)

		return
	end

	local lv = 1

	for i, id in ipairs(allCfg.BattleSkillID) do
		if id == battleSkillId then
			lv = i

			break
		end
	end

	local unit = self.GL.RunTime.CurSelectTarget

	unit = unit or self.GL.UnitMgr:Selector():Camp(2):Alive():Get()

	local skill = unit:AddSkill(allSkillId, lv)

	self:CMD_CastSkill(skill.SkillId, unit)
end

function GameCMD:CMD_PlayerSkill(battleSkillId, uniqueId)
	local cfg = ConfigTable.BattleSkillData[battleSkillId]

	if not cfg then
		self:ERROR("需要填写BattleSkillId  或者BattleSkillData中没有这个id")

		return
	end

	local allSkillId = cfg.AllSkillID
	local allCfg = ConfigTable.AllSkills[allSkillId]

	if not allCfg then
		self:ERROR("AllSkills中没有这个id " .. allSkillId)

		return
	end

	local lv = 1

	for i, id in ipairs(allCfg.BattleSkillID) do
		if id == battleSkillId then
			lv = i

			break
		end
	end

	local unit = self.GL.UnitMgr:Selector():Camp(1):Alive():Get()
	local skill = unit:AddSkill(allSkillId, lv)

	self:CMD_CastSkill(skill.SkillId, unit)
end

function GameCMD:CMD_CastSkill(skillId, unit)
	self.GL.RunTime.State = EnumFight.GameState.PLAYER_CARD

	self.GL:Fire("阶段-改变", self.GL.RunTime.State, self.GL.RunTime.LastState)

	self.GL.RunTime.LastState = self.GL.RunTime.State

	self.GL.RunTime:CMDDoCard(unit, skillId)
end

function GameCMD:CMD_PlayerAddBuff1(buffId)
	for i, unit in self.GL.UnitMgr:Selector():Camp(1):Alive():Ipairs() do
		if i == 1 then
			unit:AddBuff(buffId, unit, nil)

			break
		end
	end
end

function GameCMD:CMD_PlayerAddBuff2(buffId)
	for i, unit in self.GL.UnitMgr:Selector():Camp(1):Alive():Ipairs() do
		if i == 2 then
			unit:AddBuff(buffId, unit, nil)

			break
		end
	end
end

function GameCMD:CMD_PlayerAddBuff3(buffId)
	for i, unit in self.GL.UnitMgr:Selector():Camp(1):Alive():Ipairs() do
		if i == 3 then
			unit:AddBuff(buffId, unit, nil)

			break
		end
	end
end

function GameCMD:CMD_PlayerAddBuff4(buffId)
	for i, unit in self.GL.UnitMgr:Selector():Camp(1):Alive():Ipairs() do
		if i == 4 then
			unit:AddBuff(buffId, unit, nil)

			break
		end
	end
end

function GameCMD:CMD_PlayerAddBuff5(buffId)
	for i, unit in self.GL.UnitMgr:Selector():Camp(1):Alive():Ipairs() do
		if i == 5 then
			unit:AddBuff(buffId, unit, nil)

			break
		end
	end
end

function GameCMD:CMD_EnemyAddBuff(buffId)
	local unit = self.GL.RunTime.CurSelectTarget

	unit = unit or self.GL.UnitMgr:Selector():Camp(2):Alive():Get()

	local source = self.GL.UnitMgr:Selector():Camp(1):Alive():Get()

	unit:AddBuff(buffId, source, nil)
end

function GameCMD:CMD_PlayerAddBuff(buffId)
	local source = self.GL.RunTime.CurSelectTarget

	self.GL.UnitMgr:Selector():Camp(1):Alive():Get():AddBuff(buffId, source.UniqueId, nil)
end

function GameCMD:CMD_AllPlayerAddBuff(buffId)
	for i, unit in self.GL.UnitMgr:Selector():Camp(1):Alive():Ipairs() do
		unit:AddBuff(buffId, unit, nil)
	end
end

function GameCMD:CMD_ClearAllBuff()
	for waveIdx = 1, 2 do
		for i, unit in self.GL.UnitMgr:Selector():Camp(waveIdx):Alive():Ipairs() do
			for j = #unit.Buffs, 1, -1 do
				local buff = unit.Buffs[j]

				if buff.BuffId ~= 99999 then
					buff:RemoveSelf()
				end
			end
		end
	end
end

function GameCMD:CMD_Critical()
	for waveIdx = 1, 2 do
		for i, unit in self.GL.UnitMgr:Selector():Camp(waveIdx):Alive():Ipairs() do
			self:LOG(unit.UnitTitle .. "暴击率:" .. unit:Get("暴击率") .. "暴击效果:" .. unit:Get("暴击效果") .. "暴击抵抗:" .. unit:Get("暴击抵抗"))
		end
	end
end

function GameCMD:CMD_Attack()
	for waveIdx = 1, 2 do
		for i, unit in self.GL.UnitMgr:Selector():Camp(waveIdx):Alive():Ipairs() do
			self:LOG(unit.UnitTitle .. "物理攻击:" .. unit:Get("物理攻击") .. "魔法攻击:" .. unit:Get("魔法攻击") .. "防御:" .. unit:Get("防御"))
		end
	end
end

function GameCMD:CMD_InfoBuff()
	local str = ""

	for waveIdx = 1, 2 do
		for i, unit in self.GL.UnitMgr:Selector():Camp(waveIdx):Alive():Ipairs() do
			str = unit.UnitTitle .. " buff:"

			for buffIdx, buff in ipairs(unit.Buffs) do
				str = str .. " ," .. buff.ShowName .. buff.BuffId
			end

			self:LOG(str)
		end
	end
end

function GameCMD:CMD_InfoAttribute()
	for i, team in ipairs(self.GL.RunTime.Teams) do
		self:LOG(" team:" .. i .. "     --------------------------------      ")

		local str = ""

		for k, v in pairs(team.AttributeMap) do
			str = str .. tostring(k) .. ":\t" .. v:GetBaseValue() .. " * (1 + " .. v.MulValue .. ") + " .. v.AddValue .. " = " .. tostring(v:GetValue()) .. "\n"
		end

		self:LOG(str)
	end

	for waveIdx = 1, 2 do
		self:LOG("      --------------------------------      ")

		for i, unit in self.GL.UnitMgr:Selector():Camp(waveIdx):Alive():Ipairs() do
			local str = unit.UnitTitle .. "-----属性打印---------------------:\n"

			for k, v in pairs(unit.AttributeMap) do
				str = str .. tostring(k) .. ":\t" .. v:GetBaseValue() .. " * (1 + " .. v.MulValue .. ") + " .. v.AddValue .. " = " .. tostring(v:GetValue()) .. "\n"
			end

			self:LOG(str)
		end
	end
end

function GameCMD:CMD_EnemyInfoBuff()
	local unit = self:_GetEnemy()
	local str = unit.UnitTitle .. " buff:"

	for i, buff in ipairs(unit.Buffs) do
		str = str .. " ," .. buff.ShowName .. buff.BuffId .. "回合：" .. buff.Round
	end

	self:LOG(str)
end

function GameCMD:CMD_PlayerInfoBuff()
	local unit = self:_GetPlayer()
	local str = unit.UnitTitle .. " buff:"

	for i, buff in ipairs(unit.Buffs) do
		str = str .. " ," .. buff.ShowName .. buff.BuffId .. "回合：" .. buff.Round
	end

	self:LOG(str)
end

function GameCMD:CMD_InfoMp()
	self:LOG("MP:" .. self.GL.RunTime.PlayerTeam.Mp)
	self:LOG("Shield:" .. self.GL.RunTime.PlayerTeam.Shield)
end

function GameCMD:CMD_Win()
	self.GL:MarkGameOver(EnumFight.Camp.ENEMY)
	self.GL.RunTime:ChangeState(EnumFight.GameState.DEBUG)
end

function GameCMD:CMD_Lose()
	self.GL:MarkGameOver(EnumFight.Camp.PLAYER)
	self.GL.RunTime:ChangeState(EnumFight.GameState.DEBUG)
end

function GameCMD:CMD_PlayerAddhp(val)
	local unit = self:_GetPlayer()

	unit:HealHp(val, unit)
end

function GameCMD:CMD_EnemyAddhp(val)
	local unit = self:_GetEnemy()

	unit:HealHp(val, unit)
end

function GameCMD:CMD_PlayerAddMp(val)
	local unit = self:_GetPlayer()

	unit:ForceMp(val)
end

function GameCMD:CMD_PlayerAddShield(val)
	local unit = self:_GetPlayer()

	unit:AddShield(val)
end

function GameCMD:CMD_EnemyAddMp(val)
	local unit = self:_GetEnemy()

	unit:ForceMp(val)
end

function GameCMD:CMD_EnemyAddShield(val)
	local unit = self:_GetEnemy()

	unit:AddShield(val)
end

function GameCMD:CMD_PlayerAddAtk(val)
	local unit = self:_GetPlayer()

	unit:Add("物理攻击", val)
	unit:Add("魔法攻击", val)
end

function GameCMD:CMD_EnemyAddAtk(val)
	local unit = self:_GetEnemy()

	unit:Add("物理攻击", val)
	unit:Add("魔法攻击", val)
end

function GameCMD:CMD_ChangeMonster(unitId)
	local unitIds = {
		unitId
	}

	self.GL.RunTime:ChangeState(EnumFight.GameState.DEBUG)

	local enemyTeams = {}

	for i, UnitId in ipairs(unitIds) do
		local _unitData = {}

		_unitData.unitId = UnitId
		_unitData.wave = 1
		_unitData.level = 1
		_unitData.order = i
		_unitData.skills = {}
		_unitData.attributes = {}
		_unitData.isCenter = false
		_unitData.unitClass = EnumFight.UnitClass.ENEMY
		_unitData.hpRate = 1

		table.insert(enemyTeams, _unitData)

		local UnitData = EnemyManager:Get(UnitId).data
		local skillIds = UnitData.StageSkillId

		for i, skillId in ipairs(skillIds) do
			if skillId ~= 0 then
				table.insert(_unitData.skills, {
					skillId,
					1
				})
			end
		end

		skillIds = UnitData.StageOfAngryBuff

		for i, skillId in ipairs(skillIds) do
			if skillId ~= 0 then
				table.insert(_unitData.skills, {
					skillId,
					1
				})
			end
		end

		if UnitData.AppearSkills then
			skillIds = UnitData.AppearSkills

			for i, skillId in ipairs(skillIds) do
				if skillId ~= 0 then
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
				if skillId ~= 0 then
					table.insert(_unitData.skills, {
						skillId,
						1
					})
				end
			end
		end
	end

	self.GL.RunTime.EnemyTeam:CMDReadyCreateUnits(enemyTeams, EnumFight.Camp.ENEMY)
	self.GL:Fire("更新波数", self.GL.RunTime.CurWave, self.GL.RunTime.MaxWave)
	self.GL.RunTime.EnemyTeam:CMDCreateUnits(enemyTeams, EnumFight.Camp.ENEMY)

	self.GL.RunTime.CurSelectTarget = nil
	self.GL.RunTime.LastSelectTarget = nil

	self.GL.RunTime:SelectTargetAuto()
	self.GL.RunTime:ChangeStateOnly(EnumFight.GameState.APPEAR_SKILL)
	self.GL:Fire("行动开始", self.GL.RunTime.EnemyTeam.UniqueIds, 1, 0)

	for i, unit in self.GL.UnitMgr:Selector():Alive():Ipairs() do
		unit:AddBuff(99999, unit, nil)
	end

	self.GL.RunTime.MaxRound = 9999999

	self.GL.RunTime.PlayerTeam:Set("最大魔力", 9999999)
	self.GL.RunTime.PlayerTeam:ForceMp(9999999)
	self.GL.RunTime.EnemyTeam:CastAppearSkill()

	if self.GL.RunTime:CheckAlive() == true then
		self.GL.RunTime:ChangeState(EnumFight.GameState.NORMAL)
	end

	self.GL.RunTime:ChangeState(EnumFight.GameState.NORMAL)
end

function GameCMD:CMD_ChangeSession(targetType, roleIdx)
	if targetType < 1 then
		return
	end

	self.GL.RunTime.GameRoundData:ChangeSessionEx(targetType, roleIdx)
end

function GameCMD:CMD_EnemyKill()
	local unit = self:_GetEnemy()

	if not unit then
		return
	end

	self.GL:Fire("行动开始", self.GL.RunTime.EnemyTeam.UniqueIds, 1, 0)
	unit:SetDieReason(EnumFight.DieReson.Force)
	unit:Kill()
	print("Kill " .. unit.UniqueId)

	if self.GL.RunTime:CheckAlive() == true then
		self.GL.RunTime:ChangeState(EnumFight.GameState.NORMAL)
	end
end

function GameCMD:CMD_PlayerKill(roleIdx)
	local unit = self:_GetPlayer(roleIdx)

	if not unit then
		return
	end

	self.GL:Fire("行动开始", self.GL.RunTime.EnemyTeam.UniqueIds, 1, 0)
	unit:SetDieReason(EnumFight.DieReson.Force)
	unit:Kill()

	if self.GL.RunTime:CheckAlive() == true then
		self.GL.RunTime:ChangeState(EnumFight.GameState.DEBUG)
	else
		self.GL.RunTime:ChangeState(EnumFight.GameState.DEBUG)
	end
end

function GameCMD:CMD_PlayerAlive(roleIdx)
	local unit = self:_GetPlayer(roleIdx)

	unit = unit or self.GL.UnitMgr:Selector():Camp(1):Die():Get()

	if not unit then
		return
	end

	unit:Reborn()
	self.GL.RunTime:ChangeState(EnumFight.GameState.DEBUG)
end

function GameCMD:CMD_TestTarget(camp, affectType)
	local caster

	if camp and camp == 2 then
		caster = self.GL.UnitMgr:Selector():Alive():Camp(2):Get()
	else
		caster = self.GL.UnitMgr:Selector():Alive():Camp(1):Get()
	end

	local allSkillData = self.GL.GameBaseData.AllSkills[1001]
	local battleSkillData = self.GL.GameBaseData.BattleSkillData[allSkillData.BattleSkillID[1]]
	local skill = self.GL.ObjectPool.Skill:Create()

	skill:SetSkillData(caster, 1, allSkillData, battleSkillData)

	skill.LockTarget = ""

	local units = skill:SelectTarget(affectType)

	for i, unit in ipairs(units) do
		print(unit.Order .. unit.UnitTitle)
	end
end

function GameCMD:CMD_Selector(camp, wave, order)
	local target = self.GL.UnitMgr:Selector():Camp(camp):Wave(wave):Order(order):Get()

	if not target then
		print("no target")
	else
		print(target.UnitTitle)
	end
end

function GameCMD:CMD_UnitGet(camp, attri, idx)
	local unit = self:_GetUnit(camp, idx)

	print(attri .. " = " .. unit:Get(attri))
end

function GameCMD:CMD_UnitSet(camp, attri, val, idx)
	local unit = self:_GetUnit(camp, idx)

	unit:Set(attri, val)
	print(attri .. " = " .. unit:Get(attri))
end

function GameCMD:CMD_JsonRet()
	local jsonStr = self.GL:GetReplayJsonData()

	print(jsonStr)
	PlayerPrefs.SetString("LastFightData", jsonStr)
end
