-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/GameRecord/GameRecord.lua

local json = require("GameLogic/Util/json4lua")
local GRP = require("GameLogic/Fight.GameRecord.GameRecordProto")
local GameRecordData = GLClass("GameRecordData")

function GameRecordData:ctor()
	self.gameId = ""
	self.winner = EnumFight.Camp.UNDEFINE
	self.records = {}
end

GameRecord = GLClass("GameRecord")
GameRecord.print_enable = false

function GameRecord:ctor(GL)
	self.GL = GL

	self:Reset()

	self.RecordData = GameRecordData()
end

function GameRecord:Reset()
	self.RecordData = {}
	self.RecordBuilderMap = {}

	self:RegisterRecordBuilder()
end

function GameRecord:Purge()
	self:Reset()
end

function GameRecord:Start()
	self.RecordData.gameId = self.GL.GameId
end

function GameRecord:ToJson()
	return json.encode(self.RecordData)
end

function GameRecord:Recording(event, ...)
	local builder = self.RecordBuilderMap[event]

	if not builder then
		return
	end

	local item = {}

	item[GRP.RecordItem.eventId] = event

	table.insert(self.RecordData.records, item)
	builder(item, ...)
	Event.Instance:Fire("GameRecording", item)

	if GameRecord.print_enable == true then
		local ret = json.encode(item)

		print(ret)
	end
end

function GameRecord:Builder(event, ...)
	local builder = self.RecordBuilderMap[event]

	if not builder then
		return
	end

	local item = {}

	item[GRP.RecordItem.eventId] = event

	builder(item, ...)

	return item
end

function GameRecord:RegisterRecordBuilder()
	local function _SET_FUNC(key, func)
		self.RecordBuilderMap[key] = func
	end

	_SET_FUNC("创建战斗", function(item, fightData)
		item[GRP.CreateFight.gameId] = fightData.gameId
		item[GRP.CreateFight.boutId] = fightData.boutId
		item[GRP.CreateFight.stageId] = fightData.stageId
		item[GRP.CreateFight.playMode] = fightData.playMode
		item[GRP.CreateFight.fightMode] = fightData.fightMode
		item.teams = fightData.teams
		item.pvp = fightData.pvp
		item.myPower = fightData.myPower
		item.otherPower = fightData.otherPower
		item.myName = fightData.myName
		item.otherName = fightData.otherName
		item.bondage = fightData.bondage
	end)
	_SET_FUNC("阶段-改变", function(item, stage, lastStage)
		item[GRP.ChangeStage.stage] = stage
		item[GRP.ChangeStage.lastStage] = lastStage
	end)
	_SET_FUNC("单位-准备创建", function(item, data)
		item[GRP.UnitReady.unitId] = data.unitId
		item[GRP.UnitReady.cardId] = data.cardId
		item[GRP.UnitReady.camp] = data.camp
		item[GRP.UnitReady.order] = data.order
		item[GRP.UnitReady.wave] = data.wave
		item[GRP.UnitReady.skills] = data.skills
		item.isCenter = data.isCenter
		item.unitClass = data.unitClass
		item.weaponId = data.weaponId
		item.weaponAvatar = data.weaponAvatar
		item.listAvatarID = data.listAvatarID
	end)
	_SET_FUNC("召唤单位-创建", function(item, unit)
		item[GRP.UnitCreate.uniqueId] = unit.UniqueId
		item[GRP.UnitCreate.unitId] = unit.UnitId
		item[GRP.UnitCreate.camp] = unit.Camp
		item[GRP.UnitCreate.order] = unit.Order
		item[GRP.UnitCreate.wave] = unit.Wave
		item.isCenter = unit.IsCenter
		item.unitClass = unit.UnitClass
		item.isSummon = unit.UnitData.isSummon
		item.skills = unit.UnitData.skills
	end)
	_SET_FUNC("单位-创建", function(item, unit)
		item[GRP.UnitCreate.uniqueId] = unit.UniqueId
		item[GRP.UnitCreate.unitId] = unit.UnitId
		item[GRP.UnitCreate.camp] = unit.Camp
		item[GRP.UnitCreate.order] = unit.Order
		item[GRP.UnitCreate.wave] = unit.Wave
	end)
	_SET_FUNC("单位-准备立即创建", function(item, datas, camp)
		item.datas = datas
		item.camp = camp
	end)
	_SET_FUNC("单位-立即创建", function(item, unit)
		item[GRP.UnitCreate.uniqueId] = unit.UniqueId
		item[GRP.UnitCreate.unitId] = unit.UnitId
		item[GRP.UnitCreate.camp] = unit.Camp
		item[GRP.UnitCreate.order] = unit.Order
		item[GRP.UnitCreate.wave] = unit.Wave
	end)
	_SET_FUNC("单位-销毁", function(item, unit)
		item[GRP.UnitDestroy.uniqueId] = unit.UniqueId
	end)
	_SET_FUNC("单位-添加技能", function(item, unit, skillId, skillLv)
		item[GRP.UnitAddSkill.uniqueId] = unit.UniqueId
		item[GRP.UnitAddSkill.skillId] = skillId
		item[GRP.UnitAddSkill.skillLv] = skillLv
	end)
	_SET_FUNC("卡牌释放", function(item, skillId, uniqueId)
		item[GRP.DoCard.skillId] = skillId
		item[GRP.DoCard.uniqueId] = uniqueId
	end)
	_SET_FUNC("卡牌清除", function(item, skillId, uniqueId)
		item[GRP.DoCard.skillId] = skillId
		item[GRP.DoCard.uniqueId] = uniqueId
	end)
	_SET_FUNC("单位-闪避", function(item, unit, dmg)
		item.uniqueId = unit.UniqueId
	end)
	_SET_FUNC("技能-释放出手", function(item, skill, isCard)
		item[GRP.SkillCastShot.uniqueId] = skill.Owner.UniqueId
		item[GRP.SkillCastShot.skillId] = skill.SkillId
		item[GRP.SkillCastShot.isRange] = skill.IsRange
		item[GRP.SkillCastShot.isCard] = TenaryOp(isCard == true, true, false)
	end)
	_SET_FUNC("技能ActionKey发动", function(item, skill, actionKeyIdx)
		item.actionKeyIdx = actionKeyIdx
	end)
	_SET_FUNC("技能-更新强化层数", function(item, skill, stack)
		item.uniqueId = skill.Owner.UniqueId
		item.skillId = skill.SkillId
		item.stack = stack
	end)
	_SET_FUNC("锁定目标", function(item, unit)
		item.uniqueId = unit.UniqueId
	end)
	_SET_FUNC("预览技能目标", function(item, skillOwnerUniqueId, skillId, targetUids)
		item.uniqueId = uniqueId
		item.skillId = skillId
		item.targetUids = targetUids
	end)
	_SET_FUNC("行动开始", function(item, uniqueIds, groupIdx, sessionType)
		item[GRP.PlayerSession.groupIdx] = groupIdx

		if sessionType then
			item[GRP.PlayerSession.sessionType] = sessionType
		else
			item[GRP.PlayerSession.sessionType] = 0
		end

		item[GRP.PlayerSession.uniqueIds] = uniqueIds
	end)
	_SET_FUNC("行动结束", function(item)
		return
	end)
	_SET_FUNC("更新回合", function(item, cur, max)
		item[GRP.RefreshRound.curRound] = cur
		item[GRP.RefreshRound.maxRound] = max
	end)
	_SET_FUNC("更新波数", function(item, cur, max)
		item[GRP.RefreshWave.curWave] = cur
		item[GRP.RefreshWave.maxWave] = max
	end)
	_SET_FUNC("更新回合Session", function(item, operatorItemDatas)
		item[GRP.RefreshRoundSession.sessionType] = operatorItemDatas.SessionType
		item[GRP.RefreshRoundSession.uniqueId] = operatorItemDatas.PlayerUniqueId
		item[GRP.RefreshRoundSession.isPower] = operatorItemDatas.IsPower
		item[GRP.RefreshRoundSession.isNew] = operatorItemDatas.IsNew
		item[GRP.RefreshRoundSession.index] = operatorItemDatas.Index
		item.skillId = operatorItemDatas:GetSessionSkill().SkillId
	end)
	_SET_FUNC("更新回合Card", function(item, CardItemData)
		item[GRP.RefreshRoundCard.skillId] = CardItemData.SkillId
		item[GRP.RefreshRoundCard.uniqueId] = CardItemData.PlayerUniqueId
	end)
	_SET_FUNC("单位-移动", function(item, unit, target)
		item[GRP.UnitMoveTo.uniqueId] = unit.UniqueId
		item[GRP.UnitMoveTo.targetUniqueId] = target.UniqueId
	end)
	_SET_FUNC("更新连击", function(item, comboCount, camp, ownerUniqueId)
		item[GRP.UpdateCombo.count] = comboCount
		item[GRP.UpdateCombo.camp] = camp
		item[GRP.UpdateCombo.ownerUniqueId] = ownerUniqueId
	end)
	_SET_FUNC("伤害目标", function(item, skill, targets)
		item[GRP.DamageSkillTarget.uniqueId] = skill.Owner.UniqueId
		item[GRP.DamageSkillTarget.targets] = {}

		for i, target in ipairs(targets) do
			table.insert(item[GRP.DamageSkillTarget.targets], target.UniqueId)
		end
	end)
	_SET_FUNC("单位-受到伤害", function(item, unit, dmg, lastHp)
		item[GRP.UnitDealDamage.uniqueId] = unit.UniqueId
		item[GRP.UnitDealDamage.dmgType] = dmg.dmgType
		item[GRP.UnitDealDamage.mutIdx] = dmg.mut
		item[GRP.UnitDealDamage.minusHp] = dmg.finalMinusHp
		item.minusShield = dmg.finalMinusShield
		item.breakShieldState = dmg.breakShieldState
		item.isCritical = dmg.isCritical
		item.jobMul = dmg.jobMul
		item[GRP.UnitDealDamage.remainHp] = unit:Get("生命")
		item.lastHp = lastHp
		item.damagePhy = dmg.damagePhy
		item.damageMag = dmg.damageMag
		item.dot = dmg.dot
	end)
	_SET_FUNC("单位-受到治疗", function(item, unit, val)
		item[GRP.UnitHealHp.uniqueId] = unit.UniqueId
		item[GRP.UnitHealHp.healHp] = val
	end)
	_SET_FUNC("单位-回复魔力", function(item, unit, val)
		item.uniqueId = unit.UniqueId
		item.forceMp = val
	end)
	_SET_FUNC("单位-回复护盾", function(item, unit, val)
		item.uniqueId = unit.UniqueId
		item.addShield = val
	end)
	_SET_FUNC("单位-回复怒气", function(item, unit, val)
		item.uniqueId = unit.UniqueId
		item.addAngry = val
	end)
	_SET_FUNC("单位-更新属性", function(item, attriName, unit, addVal)
		item[GRP.UnitUpdateAttri.uniqueId] = unit.UniqueId
		item[GRP.UnitUpdateAttri.attriName] = attriName
		item[GRP.UnitUpdateAttri.cur] = unit:Get(attriName)
		item.addVal = addVal
	end)
	_SET_FUNC("队伍-更新属性", function(item, attriName, team)
		item[GRP.TeamUpdateAttri.camp] = team.Camp
		item[GRP.TeamUpdateAttri.attriName] = attriName
		item[GRP.TeamUpdateAttri.cur] = team:Get(attriName)
	end)
	_SET_FUNC("单位-更新血量", function(item, uniqueId, cur, max)
		item[GRP.UnitUpdateHp.uniqueId] = uniqueId
		item[GRP.UnitUpdateHp.maxHp] = max
		item[GRP.UnitUpdateHp.hp] = cur
	end)
	_SET_FUNC("队伍-更新血量", function(item, cur, max)
		item[GRP.TeamUpdateHp.maxHp] = max
		item[GRP.TeamUpdateHp.hp] = cur
	end)
	_SET_FUNC("单位-死亡", function(item, unit)
		item[GRP.UnityDie.uniqueId] = unit.UniqueId
		item.dieReason = unit.DieReason
	end)
	_SET_FUNC("单位-复活", function(item, unit)
		item.uniqueId = unit.UniqueId
	end)
	_SET_FUNC("游戏-结束", function(item, data)
		item.data = data
	end)
	_SET_FUNC("单位-添加buff失败", function(item, unit, reason)
		item.uniqueId = unit.UniqueId
		item.reason = reason
	end)
	_SET_FUNC("单位-添加buff", function(item, buff)
		item[GRP.UnitAddBuff.uniqueId] = buff.Owner.UniqueId
		item[GRP.UnitAddBuff.buffId] = buff.BuffId
		item[GRP.UnitAddBuff.buffUid] = tostring(buff.UID)
		item.remainRound = buff.Round
		item.skillPower = buff.SkillPower
		item.stack = buff.Stack
		item.logicData = nil

		if buff.LogicData then
			item.logicData = buff.LogicData
		end
	end)
	_SET_FUNC("单位-添加特效", function(item, fx, unit)
		item.fx = fx
		item.uniqueId = unit.UniqueId
	end)
	_SET_FUNC("单位-添加UI特效", function(item, fx, unit)
		item.fx = fx
		item.uniqueId = unit.UniqueId
	end)
	_SET_FUNC("单位-添加Icon特效", function(item, fx, unit)
		item.fx = fx
		item.uniqueId = unit.UniqueId
	end)
	_SET_FUNC("单位-Buff自定义消息", function(item, unit, buff, custom, args)
		item.custom = custom
		item.args = args
		item.uniqueId = unit.UniqueId
		item.buffId = buff.BuffId
		item.buffUid = tostring(buff.UID)
	end)
	_SET_FUNC("技能-飘字", function(item, unit, skill, idx, args)
		item.uniqueId = unit.UniqueId
		item.sourceId = skill.Owner.UniqueId
		item.skillId = skill.SkillId
		item.skillLv = skill.Level
		item.idx = idx
		item.args = args
	end)
	_SET_FUNC("单位-移除buff", function(item, unit, buffId, buffUid)
		item[GRP.UnitRemoveBuff.uniqueId] = unit.UniqueId
		item[GRP.UnitRemoveBuff.buffId] = buffId
		item[GRP.UnitRemoveBuff.buffUid] = tostring(buffUid)
	end)
	_SET_FUNC("单位-更新buff", function(item, unit, buffId, buffUid, round)
		item[GRP.UnitUpdateBuff.uniqueId] = unit.UniqueId
		item[GRP.UnitUpdateBuff.buffId] = buffId
		item[GRP.UnitUpdateBuff.buffUid] = tostring(buffUid)
		item[GRP.UnitUpdateBuff.remainRound] = round
	end)
	_SET_FUNC("单位-更新buff", function(item, unit, buff)
		item[GRP.UnitUpdateBuff.uniqueId] = unit.UniqueId
		item[GRP.UnitUpdateBuff.buffId] = buff.BuffId
		item[GRP.UnitUpdateBuff.buffUid] = tostring(buff.UID)
		item[GRP.UnitUpdateBuff.remainRound] = buff.Round
		item.duration = buff.Duration
		item.stack = buff.Stack
	end)
	_SET_FUNC("单位-buff即将生效", function(item, unit, buffId, buffUid)
		item[GRP.UnitUpdateBuff.uniqueId] = unit.UniqueId
		item[GRP.UnitUpdateBuff.buffId] = buffId
		item[GRP.UnitUpdateBuff.buffUid] = tostring(buffUid)
	end)
	_SET_FUNC("单位-buff叠层数", function(item, unit, buffId, buffUid, stack)
		item[GRP.UnitUpdateBuff.uniqueId] = unit.UniqueId
		item[GRP.UnitUpdateBuff.buffId] = buffId
		item[GRP.UnitUpdateBuff.buffUid] = tostring(buffUid)
		item.stack = stack
	end)
	_SET_FUNC("单位-buff同步数据", function(item, unit, buffId, buffUid, data)
		item[GRP.UnitUpdateBuff.uniqueId] = unit.UniqueId
		item[GRP.UnitUpdateBuff.buffId] = buffId
		item[GRP.UnitUpdateBuff.buffUid] = tostring(buffUid)
		item.logicData = data
	end)
	_SET_FUNC("单位-怒气buff", function(item, unit, skillId)
		item[GRP.UnitAngryBuffSkill.uniqueId] = unit.UniqueId
		item[GRP.UnitAngryBuffSkill.skillId] = skillId
	end)
	_SET_FUNC("单位-无法行动", function(item, unit, val)
		item.uniqueId = unit.UniqueId
		item.val = val
	end)
	_SET_FUNC("单位-封印卡牌技能", function(item, unit, val)
		item.uniqueId = unit.UniqueId
		item.val = val
	end)
	_SET_FUNC("单位-随机技能", function(item, unit, skillId)
		item.uniqueId = unit.UniqueId
		item.skillId = skillId
	end)
	_SET_FUNC("鞭尸", function(item, uniqueId)
		item.uniqueId = uniqueId
	end)
	_SET_FUNC("鞭尸掉落", function(item, rewardId, uniqueId)
		item.rewardId = rewardId
		item.uniqueId = uniqueId
	end)
	_SET_FUNC("DoMsgAction-Trigger", function(item)
		return
	end)
	_SET_FUNC("受击打包", function(item, Skill, mutIdx)
		item.skillId = Skill.SkillId
		item.mutIdx = mutIdx
	end)
	_SET_FUNC("选球", function(item, uniqueIds, sessionTypes)
		item.uniqueIds = uniqueIds
		item.sessionTypes = sessionTypes
	end)
	_SET_FUNC("技能-生效目标", function(item, Skill, Unit, mutIdx)
		item.uniqueId = Unit.UniqueId
		item.mutIdx = mutIdx
	end)
	_SET_FUNC("建议选球", function(item, data)
		item.data = data
	end)
	_SET_FUNC("游戏-操作记录", function(item, operators, startData)
		item.operators = operators
		item.randomSeed = startData.randomSeed
	end)
	_SET_FUNC("游戏-数据统计", function(item, resultData)
		item.resultData = resultData
	end)
	_SET_FUNC("选择卡牌", function(item)
		return
	end)
end

function GameRecord:Debug()
	print(" ----------- ")

	for i, item in ipairs(self.RecordData.records) do
		print("item.eventId = " .. item.eventId)
		print("unitId = " .. item.unitId)
		print("camp = " .. item.camp)
	end
end
