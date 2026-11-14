-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/GameRunTime/GameRunTime.lua

GameRunTime = GLClass("GameRunTime", GameHelper)
GameRunTime.print_enable = false

local print = function(...)
	if GameRunTime.print_enable == true then
		print(...)
	end
end

function GameRunTime:ctor(GL)
	self.GL = GL

	self:Reset()

	self.GameRoundData = GameRoundData(GL)

	if self.GL.GameStartData.pvp ~= EnumFight.Pvp.NONE then
		self.GameRoundData_PVP = GameRoundData(GL)
	end
end

function GameRunTime:Reset()
	self.State = EnumFight.GameState.GAMEOVER
	self.LastState = 0
	self.AutoOpetator = false
	self.CurRound = 0
	self.MaxRound = 15
	self.PlayerWave = 0
	self.EnemyWave = 0
	self.CurWave = 0
	self.MaxWave = 0
	self.Teams = {}
	self.GameRoundData = {}
	self.GameRoundData_PVP = {}
	self.CurSelectTarget = nil
	self.KillMonsterList = {}
	self.CurSummonUnits = {}
end

function GameRunTime:ChangeStateOnly(state)
	if state ~= self.State then
		self.LastState = self.State
		self.State = state

		self.GL:Fire("阶段-改变", self.State, self.LastState)
	end
end

function GameRunTime:ChangeState(state)
	if state ~= self.State then
		self.LastState = self.State
		self.State = state

		self.GL:Fire("阶段-改变", self.State, self.LastState)
	end

	self:DoState()
end

function GameRunTime:DoState()
	if self.State == EnumFight.GameState.ERROR then
		self.GL:MarkGameOver(1)
	elseif self.State == EnumFight.GameState.GAMEOVER then
		local opData = self.GL.OperatorRecord:PopOperatorData()

		if not opData then
			self.GL:GameOver()

			return
		end

		if opData.Type == EnumFight.OperatorType.BuyLive then
			self.GL:BuyLive(opData.BoutId)
		end
	elseif self.State == EnumFight.GameState.READY_END then
		-- block empty
	elseif self.State == EnumFight.GameState.NORMAL then
		self:RefreshRound()
		self.GL:Fire("行动开始", self.PlayerTeam.UniqueIds, 1, 0)
		self.PlayerTeam:ActionStart()

		if self:CheckAlive() == false then
			return
		end

		self.GL:Fire("行动开始", self.EnemyTeam.UniqueIds, 1, 0)
		self.EnemyTeam:ActionStart()

		if self:CheckAlive() == false then
			return
		end

		self:GetTeamByCamp(EnumFight.Camp.PLAYER):UpdateBuffs()
		self:ChangeState(EnumFight.GameState.OPERATOR_WAIT)
	elseif self.State == EnumFight.GameState.OPERATOR_WAIT then
		self.GL:Fire("游戏-数据统计", self.GL.Result:GetData())
		self.PlayerTeam:CheckNotAction()

		if self.PlayerTeam.AllNotAction == true then
			self:ChangeState(EnumFight.GameState.PLAYER_SESSION)

			return
		end

		if self.GL.TestMode == true then
			self:SetAutoOperator(true)

			return
		end

		local opData = self.GL.OperatorRecord:PopOperatorData()

		if not opData then
			return
		end

		if opData.Type == EnumFight.OperatorType.Session then
			self:SelectTarget(opData.Target)
			self:PlayerOperator(opData.OperatorData)
		elseif opData.Type == EnumFight.OperatorType.Card then
			self:SelectTarget(opData.Target)
			self:PlayerCard(opData.OperatorData)
		elseif opData.Type == EnumFight.OperatorType.CMD then
			self.GL.CMD:OnCMDMessage(opData.CMDStr)
		end
	elseif self.State == EnumFight.GameState.PLAYER_CARD then
		self:DoCard()
	elseif self.State == EnumFight.GameState.PLAYER_SESSION then
		self.GameRoundData:NotifyDoSessionData()
		self:DoSession()
	elseif self.State == EnumFight.GameState.DEBUG then
		-- block empty
	elseif self.State == EnumFight.GameState.NEWWAVE then
		-- block empty
	elseif self.State == EnumFight.GameState.READY then
		-- block empty
	end
end

function GameRunTime:BackState()
	local temp = self.State

	self.State = self.LastState
	self.LastState = temp

	self.GL:Fire("阶段-改变", self.State, self.LastState)
end

function GameRunTime:Ready()
	self:ChangeState(EnumFight.GameState.INIT)
	self.GL.GlobalEvent:Add("单位-死亡", self.OnUnitDead, self)
	self.GL.GlobalEvent:Add("单位-复活", self.OnUnitReborn, self)
	self.GL.GlobalEvent:Add("PlayerOperator", self.PlayerOperator, self)
	self.GL.GlobalEvent:Add("PlayerCard", self.PlayerCard, self)
	self.GL.GlobalEvent:Add("SetAutoOperator", self.SetAutoOperator, self)
	self.GL.GlobalEvent:Add("ReqSkillChange", self.SetPickCard, self)
	self.GL.GlobalEvent:Add("ReqTargetChange", self.TargetChange, self)
	self.GL.GlobalEvent:Add("ReqTargetsPreview", self.TargetsPreview, self)
	self.GL.GlobalEvent:Add("ReqSuggestSession", self.ReqSuggestSession, self)

	local GL = self.GL
	local UnitMgr = self.GL.UnitMgr
	local teams = self.GL.GameStartData.teams
	local summons = self.GL.GameStartData.summons
	local playerTeamSkills = self.GL.GameStartData.skills
	local otherPlayerTeamSkills = self.GL.GameStartData.otherSkills

	for campIdx, camp in ipairs(teams) do
		local oneTeam = GameTeamInfo(self.GL)

		self.Teams[campIdx] = oneTeam

		if campIdx == EnumFight.Camp.ENEMY then
			self.MaxWave = #camp
		end

		local campOrder = 0

		for waveIdx, wave in ipairs(camp) do
			self.Teams[campIdx][waveIdx] = {}

			for startDataIdx, startData in ipairs(wave) do
				campOrder = campOrder + 1
				startData.campOrder = campOrder

				oneTeam:SetCamp(campIdx, startData.unitClass)
				print("创建角色:" .. tostring(startData.unitId) .. " wave:" .. tostring(startData.wave) .. " camp:" .. tostring(campIdx) .. " unitClass:" .. tostring(startData.unitClass) .. " campOrder:" .. campOrder)

				if startData.isCenter == true and campIdx == EnumFight.Camp.PLAYER then
					for i, teamSkill in ipairs(playerTeamSkills) do
						table.insert(startData.skills, teamSkill)
					end
				end

				if startData.isCenter == true and campIdx == EnumFight.Camp.ENEMY then
					for i, teamSkill in ipairs(otherPlayerTeamSkills) do
						table.insert(startData.skills, teamSkill)
					end
				end

				self.GL:Fire("单位-准备创建", startData)
				self.Teams[campIdx]:InsertStartData(waveIdx, startData)

				for i, skillItem in ipairs(startData.skills) do
					-- block empty
				end
			end
		end
	end

	if summons then
		for i, startData in ipairs(summons) do
			self.GL:Fire("召唤单位-准备创建", startData.unitId, startData.skills)
		end
	end

	self.PlayerTeam = self.Teams[EnumFight.Camp.PLAYER]
	self.EnemyTeam = self.Teams[EnumFight.Camp.ENEMY]

	self.GL:Fire("创建战斗", self.GL.GameStartData)

	self.MaxRound = self.GL.GameBaseData.BattleStageData.MaxRound

	self:StartGame()
end

function GameRunTime:Purge()
	self.GL.GlobalEvent:Remove("单位-死亡", self.OnUnitDead, self)
	self.GL.GlobalEvent:Remove("单位-复活", self.OnUnitReborn, self)
	self.GL.GlobalEvent:Remove("PlayerOperator", self.PlayerOperator, self)
	self.GL.GlobalEvent:Remove("PlayerCard", self.PlayerCard, self)
	self.GL.GlobalEvent:Remove("SetAutoOperator", self.SetAutoOperator, self)
	self.GL.GlobalEvent:Remove("ReqSkillChange", self.SetPickCard, self)
	self.GL.GlobalEvent:Remove("ReqTargetChange", self.TargetChange, self)
	self.GL.GlobalEvent:Remove("ReqTargetsPreview", self.TargetsPreview, self)
	self.GL.GlobalEvent:Remove("ReqSuggestSession", self.ReqSuggestSession, self)
	self:Reset()
end

function GameRunTime:CheckAlive()
	self.GL:Fire("行动结束")

	if self.CurRound > self.MaxRound then
		self.GL:MarkGameOver(EnumFight.Camp.PLAYER)

		return false
	end

	for i, uniqueId in ipairs(self.PlayerTeam.UniqueIds) do
		local unit = self.GL.UnitMgr:FindUnitById(uniqueId)

		unit:CheckAlive()
	end

	if self.PlayerTeam.AliveCount <= 0 then
		self.GL:MarkGameOver(EnumFight.Camp.PLAYER)

		return false
	end

	for i, uniqueId in ipairs(self.EnemyTeam.UniqueIds) do
		local unit = self.GL.UnitMgr:FindUnitById(uniqueId)

		unit:CheckAlive()
	end

	if self.EnemyTeam.AliveCount == 0 then
		self:RefreshWave()

		return false
	else
		self:SelectTargetAuto()

		return true
	end
end

function GameRunTime:OnUnitDead(unit)
	if unit.Camp == EnumFight.Camp.ENEMY then
		if unit.DieReason == EnumFight.DieReson.Std then
			table.insert(self.KillMonsterList, unit.UnitId)
		end

		self.EnemyTeam:UnitDead()
	elseif unit.Camp == EnumFight.Camp.PLAYER then
		self.PlayerTeam:UnitDead()
	end
end

function GameRunTime:GetTeamByCamp(camp)
	local team = self.Teams[camp]

	if not team then
		self:ERROR("ERROR, GetTeamByCamp  camp:" .. camp)
	end

	return team
end

function GameRunTime:OnUnitReborn(unit)
	self:GetTeamByCamp(unit.Camp):Reborn()
end

function GameRunTime:StartGame()
	self:ChangeState(EnumFight.GameState.READY)

	self.CurWave = 1

	self.GL:Fire("更新波数", self.CurWave, self.MaxWave)

	for i, team in ipairs(self.Teams) do
		team:CreateCurWaveUnits(self.CurWave)
	end

	self:SelectTargetAuto()
	self.GameRoundData:Start(self.PlayerTeam)
	self.GameRoundData_PVP:Start(self.EnemyTeam)

	if self.GL.TestMode == true then
		local cardIds = {}

		for i, card in ipairs(self.GameRoundData.CardPool) do
			if i > 3 then
				break
			end

			table.insert(cardIds, card.SkillId)
		end

		self:SetPickCard(cardIds)

		return
	end

	if self.GL.GameStartData.playMode == EnumFight.PlayMode.Std then
		local cardIds = {}

		if self.GL.GameStartData.pvp ~= EnumFight.Pvp.NONE then
			for i, card in ipairs(self.GameRoundData.CardPool) do
				if i > 3 then
					break
				end

				table.insert(cardIds, card.SkillId)
			end

			self:SetPickCard(cardIds)
		else
			self.GL:Fire("选择卡牌")
		end
	else
		local opData = self.GL.OperatorRecord:PopOperatorData()

		if not opData then
			self.GL:Fire("GL_ERROR")

			local cardIds = {}

			for i, card in ipairs(self.GameRoundData.CardPool) do
				if i > 3 then
					break
				end

				table.insert(cardIds, card.SkillId)
			end

			self:SetPickCard(cardIds)

			return
		end

		if opData.Type == EnumFight.OperatorType.PickCard then
			self:SetPickCard(opData.CardIds)
		end
	end
end

function GameRunTime:ResetRound()
	self.CurRound = 0
end

function GameRunTime:RefreshRound()
	self.CurRound = self.CurRound + 1

	print("-------- 当前回合：" .. self.CurRound .. " --------")
	self.GL:Fire("更新回合", self.CurRound, self.MaxRound)
	self.GameRoundData:Refresh()

	if self.GL.GameStartData.pvp ~= EnumFight.Pvp.NONE then
		self.GameRoundData_PVP:Refresh()
	end

	self.PlayerTeam:RefreshRound()
	self.EnemyTeam:RefreshRound()
end

function GameRunTime:RefreshWave()
	if self.EnemyTeam.Wave >= self.MaxWave then
		self.GL:MarkGameOver(EnumFight.Camp.ENEMY)

		return
	end

	self:ChangeState(EnumFight.GameState.NEWWAVE)

	self.CurWave = self.CurWave + 1

	self.GL:Fire("更新波数", self.CurWave, self.MaxWave)

	self.CurSelectTarget = nil
	self.LastSelectTarget = nil

	self.EnemyTeam:CreateCurWaveUnits(self.CurWave)
	self:SelectTargetAuto()
	self:ChangeStateOnly(EnumFight.GameState.APPEAR_SKILL)
	self.GL:Fire("行动开始", self.EnemyTeam.UniqueIds, 1, 0)
	self.EnemyTeam:CastAppearSkill()

	if self:CheckAlive() == true then
		self:ChangeState(EnumFight.GameState.NORMAL)
	end
end

function GameRunTime:SelectTargetAuto()
	local target

	if self.CurSelectTarget and self.CurSelectTarget.IsDead == false then
		target = self.CurSelectTarget
	else
		target = self.GL.UnitMgr:Selector():Camp(2):Alive():SortMin("生命"):Get()
	end

	if target then
		self:SelectTarget(target)
	end
end

function GameRunTime:SelectTarget(target)
	if type(target) == "string" then
		local unit = self.GL.UnitMgr:FindUnitById(target)

		if unit.IsDead == true then
			return
		end

		self.CurSelectTarget = unit
	elseif target.className == "Unit" then
		self.CurSelectTarget = target
	else
		self:ERROR(" SelectTarget  target error")

		return
	end

	if self.CurSelectTarget ~= self.LastSelectTarget then
		self.LastSelectTarget = self.CurSelectTarget
	end

	self.GL:Fire("锁定目标", self.CurSelectTarget)
end

function GameRunTime:IsSelectTargetVaild()
	if self.CurSelectTarget and self.CurSelectTarget.IsDead == false then
		return true
	end

	return false
end

function GameRunTime:PlayerCard(data)
	if self.GameRoundData:TryDoCard(data) == true then
		self.GL.OperatorRecord:Card(data)
		self:ChangeState(EnumFight.GameState.PLAYER_CARD)
	end
end

function GameRunTime:SetPickCard(cardIds)
	if not cardIds then
		return
	end

	if #cardIds ~= 3 then
		self:ERROR("卡牌数量不对 游戏错误")

		return
	end

	self.GL.OperatorRecord:PickCard(cardIds)
	self.GameRoundData:PickCard(cardIds)
	self:ChangeState(EnumFight.GameState.READY_END)
	self:ChangeStateOnly(EnumFight.GameState.APPEAR_SKILL)
	self.GL:Fire("行动开始", self.EnemyTeam.UniqueIds, 1, 0)
	self.PlayerTeam:CastAppearSkill()
	self.EnemyTeam:CastAppearSkill()

	local enemyFirst = false

	if self.GL.GameStartData.pvp ~= EnumFight.Pvp.NONE then
		enemyFirst = self.EnemyTeam:Get("速度") > self.PlayerTeam:Get("速度")
	end

	if enemyFirst == true then
		if self:CheckAlive() == false then
			return
		end

		if self.GL.GameStartData.pvp ~= EnumFight.Pvp.NONE then
			self.GameRoundData_PVP:Refresh()
		end

		self:EnemyAction()
	elseif self:CheckAlive() == true then
		self:ChangeState(EnumFight.GameState.NORMAL)
	end
end

function GameRunTime:TargetChange(uniqueId)
	self:SelectTarget(uniqueId)

	if self.SkillPreviewUid then
		self:TargetsPreview(self.SkillPreviewUid, self.SkillPreviewSkillId)
	end
end

function GameRunTime:TargetsPreview(uniqueId, skillId)
	if uniqueId and skillId then
		local unit = self.GL.UnitMgr:FindUnitById(uniqueId)

		if unit then
			local skill = unit:GetSkill(skillId)

			if skill then
				local uids = skill:GetAllTargets()

				self.SkillPreviewUid = uniqueId
				self.SkillPreviewSkillId = skillId

				self.GL:Fire("预览技能目标", skill.Owner.UniqueId, skillId, uids)
			end
		end
	else
		self.SkillPreviewSkillId = nil
		self.SkillPreviewUid = nil

		self:SelectTargetAuto()
	end
end

function GameRunTime:ReqSuggestSession()
	local operatorData = self.GameRoundData:AutoSetOperatorData()
	local data = {}

	for i, index in ipairs(operatorData) do
		table.insert(data, index)
	end

	self.GL:Fire("建议选球", data)
end

function GameRunTime:SetAutoOperator(val)
	if val == true and self.State == EnumFight.GameState.OPERATOR_WAIT then
		self.GameRoundData:AutoOperator()
	end
end

function GameRunTime:PlayerOperator(operatorData)
	if self.GameRoundData:TrySetOperatorData(operatorData) == true then
		self.GL.OperatorRecord:Session(operatorData)
		self:ChangeState(EnumFight.GameState.PLAYER_SESSION)
	else
		print("选球错误，建议剔除一些球")

		local data = self.GameRoundData.PopSessionData

		self:ChangeState(EnumFight.GameState.ERROR)
	end
end

function GameRunTime:GetActionTeam()
	local orders = {}

	table.insert(orders, self.EnemyTeam)
	table.insert(orders, self.PlayerTeam)
	table.sort(orders, function(a, b)
		return a:Get("行动序号") > b:Get("行动序号")
	end)

	for _, team in ipairs(orders) do
		if team:Get("行动序号") ~= 0 then
			return team
		end
	end

	return nil
end

function GameRunTime:DoSession()
	local team = self:GetActionTeam()

	if not team then
		self.SessionStage = 0
	elseif self.SessionStage ~= team.Camp then
		if team.Camp == EnumFight.Camp.ENEMY then
			self:GetTeamByCamp(team.Camp):UpdateBuffs()
		end

		self.SessionStage = team.Camp
	end

	if self.SessionStage == 0 then
		self:ChangeState(EnumFight.GameState.NORMAL)
	elseif self.SessionStage == 1 then
		self:PlayerAction()
	elseif self.SessionStage == 2 then
		self:EnemyAction()
	end
end

function GameRunTime:PlayerAction()
	local sessionGroup, groupIdx = self.GameRoundData:GetCurDoSessionData()

	if not sessionGroup then
		self.PlayerTeam:ActionEnd()
		self:DoSession()

		return
	else
		if self:IsSelectTargetVaild() == true then
			self.GameRoundData:ResetCombo()

			local uniqueIds = {}

			for itemIdx, data in ipairs(sessionGroup) do
				table.insert(uniqueIds, data.PlayerUniqueId)
			end

			local sessionType = sessionGroup[1].SessionType

			self.GL:Fire("行动开始", uniqueIds, groupIdx, sessionType)
			self.PlayerTeam:DoGroupSession(sessionGroup)
			self.GameRoundData:AddCurDoSessionDataIndex()
		else
			self:ERROR("IsSelectTargetVaild  ERROR !!! ")
		end

		if self:CheckAlive() == true then
			self:DoSession()
		end
	end
end

function GameRunTime:EnemyAction()
	if self.GL.GameStartData.pvp ~= EnumFight.Pvp.NONE then
		self.EnemyTeam:CheckNotAction()

		if self.EnemyTeam.AllNotAction == true then
			self.EnemyTeam:ActionEnd()
			self:DoSession()

			return
		end

		self:PVPPlayerDoCard()

		return
	end

	local enemy, groupIdx = self.GameRoundData:GetCurActionEnemy()

	if not enemy then
		self.EnemyTeam:ActionEnd()
		self:DoSession()

		return
	end

	self.GameRoundData:ResetCombo()
	self.GL:Fire("行动开始", {
		enemy.UniqueId
	}, groupIdx)
	enemy:EnemyAction()

	if self:CheckAlive() == false then
		return
	end

	self.GL:Fire("行动开始", {
		enemy.UniqueId
	}, groupIdx)
	enemy:EnemyCastActionSkill()
	enemy:EnemyActionEnd()

	if self:CheckAlive() == false then
		return
	end

	if #self.CurSummonUnits > 0 then
		local summonUids = {}

		for i, summonUnit in ipairs(self.CurSummonUnits) do
			table.insert(summonUids, summonUnit.UniqueId)
		end

		self.GL:Fire("行动开始", summonUids, 999)

		for i, summonUnit in ipairs(self.CurSummonUnits) do
			summonUnit:CastAppearSkill()
		end

		if self:CheckAlive() == false then
			return
		end

		self.CurSummonUnits = {}
	end

	if enemy.NotAction == false then
		enemy:Add("等待回合", -1)

		if enemy:Get("等待回合") <= 0 then
			enemy:Resume("等待回合")
			enemy:SetNextActionSkillId()
		end
	end

	self:DoSession()
end

function GameRunTime:DoCard()
	if not self.GameRoundData.CurDoCardData then
		self:ChangeState(EnumFight.GameState.OPERATOR_WAIT)

		return
	end

	self.GameRoundData:ResetCombo()

	local data = self.GameRoundData.CurDoCardData
	local unit = self.GL.UnitMgr:FindUnitById(data.uniqueId)

	self.GL:Fire("行动开始", {
		unit.UniqueId
	}, 1)
	self.GL:Fire("卡牌释放", data.skillId, data.uniqueId)
	unit:CastCard(data.skillId)

	self.GameRoundData.CurDoCardData = nil

	if self:CheckAlive() == true then
		self:DoCard()
	end
end

function GameRunTime:CMDDoCard(unit, skillId)
	if EnumFight.GameState.PLAYER_CARD ~= self.State then
		self.LastState = self.State
		self.State = state

		self.GL:Fire("阶段-改变", self.State, self.LastState)
	end

	self.GameRoundData:ResetCombo()
	self.GL:Fire("行动开始", {
		unit.UniqueId
	}, 1)
	unit:CastSkill(skillId)

	if self:CheckAlive() == true then
		self:ChangeState(EnumFight.GameState.OPERATOR_WAIT)
	end
end

function GameRunTime:PVPPlayerDoCard()
	local card = self.GameRoundData_PVP:GetMinOrderCard()

	if card then
		local data = {}

		data.uniqueId = card.PlayerUniqueId
		data.skillId = card.SkillId

		if self.GameRoundData_PVP:TryDoCard(data) == true then
			self.GameRoundData_PVP:ResetCombo()

			local unit = self.GL.UnitMgr:FindUnitById(data.uniqueId)

			self.GL:Fire("行动开始", {
				unit.UniqueId
			}, 1)
			self.GL:Fire("卡牌释放", data.skillId, data.uniqueId)
			unit:CastCard(data.skillId)

			if self:CheckAlive() == true then
				self:PVPPlayerDoCard()
			end

			return
		end
	end

	self:PVPPlayerAction()
end

function GameRunTime:PVPPlayerAction()
	local canAction = true
	local operatorData = self.GameRoundData_PVP:AutoSetOperatorData()

	if #operatorData == 0 then
		canAction = false
	end

	if self.GameRoundData_PVP:TrySetOperatorData(operatorData) == false then
		canAction = false
	end

	local sessionGroup, groupIdx = self.GameRoundData_PVP:GetCurDoSessionData()

	if not sessionGroup then
		canAction = false
	end

	if self:IsSelectTargetVaild() == false then
		canAction = false

		self:ERROR("IsSelectTargetVaild  ERROR !!! ")
	end

	if canAction == false then
		self.EnemyTeam:ActionEnd()
		self:DoSession()

		return
	end

	self.GameRoundData_PVP:ResetCombo()

	local uniqueIds = {}

	for itemIdx, data in ipairs(sessionGroup) do
		local sessionSkill = data:GetSessionSkill()

		table.insert(uniqueIds, data.PlayerUniqueId)
	end

	local sessionType = sessionGroup[1].SessionType

	self.GL:Fire("行动开始", uniqueIds, groupIdx, sessionType)
	self.EnemyTeam:DoGroupSession(sessionGroup)
	self.GameRoundData_PVP:AddCurDoSessionDataIndex()

	if self:CheckAlive() == true then
		self:PVPPlayerAction()
	end
end

function GameRunTime:CMDRefreshRound()
	self:ChangeState(EnumFight.GameState.DEBUG)
	self:GetTeamByCamp(1):UpdateBuffs()
	self:GetTeamByCamp(2):UpdateBuffs()

	for i, unit in self.GL.UnitMgr:Selector():Alive():Ipairs() do
		if unit.UnitClass == EnumFight.UnitClass.PLAYER then
			unit:ActionEnd()
		elseif unit.UnitClass == EnumFight.UnitClass.ENEMY then
			unit:ActionStart()
			unit:UpdateBuff()
			unit:ActionEnd()
		end
	end

	for i, data in ipairs(self.GameRoundData.CurCardList) do
		self.GL:Fire("卡牌释放", data.SkillId, data.PlayerUniqueId)
	end

	self.GameRoundData.CurCardList = {}

	for i, item in ipairs(self.GameRoundData.OperatorItemDatas) do
		item.IsAction = true
	end

	self:ChangeState(EnumFight.GameState.NORMAL)
end

function GameRunTime:CMDRefreshWave()
	self:ChangeState(EnumFight.GameState.DEBUG)

	for i, uniqueId in ipairs(self.EnemyTeam.UniqueIds) do
		local unit = self.GL.UnitMgr:FindUnitById(uniqueId)

		unit:SetDieReason(EnumFight.DieReson.Force)
		unit:Set("生命", 0)
	end

	self:CheckAlive()
end
