-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/GameLogic.lua

require("GameLogic/Fight.Requires")

GameLogic = GLClass("GameLogic", GameHelper, true)
GameLogic.MAX_CAMP_COUNT = 2
GameLogic.MAX_ALIVE_MONSTER_COUNT = 3

if _G_LAPIS_SERVER then
	Unit.print_enable = false
	GameHelper.print_enable = false
else
	Unit.print_enable = false
	GameHelper.print_enable = true
end

function GameLogic:ctor()
	self.GL = self

	self:Reset()

	self.Record = GameRecord(self)
	self.RunTime = GameRunTime(self)
	self.UnitMgr = UnitManager(self)
	self.CMD = GameCMD(self)
	self.OperatorRecord = GameOperatorRecord(self)
	self.ObjectPool.Unit = GLObjectPool(self, Unit)
	self.ObjectPool.Damage = GLObjectPool(self, Damage)
	self.ObjectPool.Skill = GLObjectPool(self, Skill)
	self.ObjectPool.Buff = GLObjectPool(self, Buff)
	self.TestMode = false
end

function GameLogic:Test()
	return
end

function GameLogic:Reset()
	self.GameId = ""
	self.GameBaseData = {}
	self.GameScriptData = {}
	self.GameStartData = {}
	self.IsFree = true
	self.IsError = false
	self.IsGameOver = true
	self.WillGameOver = false
	self.NextUniqueId = 0
	self.GlobalEvent = Event.Instance
	self.Record = nil
	self.RunTime = nil
	self.UnitMgr = nil
	self.Winner = -1
	self.GameOverCallback = nil
	self.ObjectPool = {
		Unit = {},
		Damage = {},
		Skill = {},
		Buff = {},
		Bullet = {}
	}
	self.EventMap = {}
end

function GameLogic:SetGameBaseData(data)
	self.GameBaseData = data
end

function GameLogic:SetGameScriptData(data)
	self.GameScriptData = data
end

function GameLogic:SetGameStartData(data)
	self.GameId = data.gameId
	self.GameStartData = data

	if data.randomSeed then
		self.GameStartData.randomSeed = data.randomSeed
	else
		self.GameStartData.randomSeed = tonumber(tostring(os.time()):reverse():sub(1, 6))
	end

	RandomUtil.Init(self.GameStartData.randomSeed, self.GameStartData.randomSeedForReward)
end

function GameLogic:SetEvent(event)
	self.GlobalEvent = event
end

function GameLogic:FightStage()
	return self.RunTime.FightStage
end

function GameLogic:GetNextUniqueId()
	if self.NextUniqueId == 9999999999 then
		self.NextUniqueId = 0
	end

	self.NextUniqueId = self.NextUniqueId + 1

	return self.NextUniqueId
end

function GameLogic:Start()
	if self.IsGameOver == false then
		return
	end

	self.IsGameOver = false
	self.WillGameOver = false
	self.Result = GameResult(self)
	self.ServerRet = ServerResult(self)

	self:On("GetFightData", self.GetFightData, self)
	self:On("ExitGameLogic", self.Purge, self)
	self:On("LOADSCENE", self.OnLoadScene, self)
	self:On("GiveUpGame", self.GiveUpGame, self)
	self:On("BuyLive", self.BuyLive, self)
	self.OperatorRecord:Init()
	self.Record:Start()
	self.RunTime:Ready()
end

function GameLogic:Purge()
	self:Off("GetFightData", self.GetFightData, self)
	self:Off("ExitGameLogic", self.Purge, self)
	self:Off("LOADSCENE", self.OnLoadScene, self)
	self:Off("GiveUpGame", self.GiveUpGame, self)
	self:Off("BuyLive", self.BuyLive, self)
	self.CMD:Purge()
	self.UnitMgr:Purge()
	self.RunTime:Purge()
	self.Record:Purge()
	self.Result:Purge()
	self.OperatorRecord:Purge()
	self:Reset()

	for k, v in pairs(self.EventMap) do
		self:ERROR("事件没清除！！！ " .. k)
	end

	RandomUtil.Purge()
end

function GameLogic:MarkGameOver(loser)
	local winner = GameLogic.MAX_CAMP_COUNT - loser + 1

	if self.IsGameOver == true or self.WillGameOver == true then
		return
	end

	self.Winner = winner
	self.WillGameOver = true

	for i, unit in self.GL.UnitMgr:Selector():Camp(1):Alive():Ipairs() do
		unit:RemoveAllBuff()
	end

	self.RunTime:ChangeState(EnumFight.GameState.GAMEOVER)
end

function GameLogic:GameOver()
	self:Fire("游戏-即将结束")
	self:FireOperatorRecord()
	self:Fire("游戏-数据统计", self.Result:GetData())

	local out = self:GetServerRet()

	self:Fire("游戏-结束", out)

	self.IsGameOver = true
	self.WillGameOver = true

	self:LOG("战斗结束, Win:" .. tostring(out.isWin) .. " Round:" .. out.round .. " CheckRet:" .. out.checkRet)
end

function GameLogic:PrintStartData()
	self:LOG("打印战斗数据： ----------------- ")

	local json = require("GameLogic.Util.json4lua")
	local ret = json.encode(self.GameStartData)

	self:LOGCAT(ret)
end

function GameLogic:GetServerRet()
	local out = {}

	out.json = self:GetReplayJsonData()
	out.checkRet = self.Result:CheckInfo()

	self:LOG("<color=red> checkRet" .. out.checkRet .. "</color>")

	out.boutId = self.GameStartData.boutId
	out.chaos = self.GameStartData.chaos
	out.stageId = self.GameStartData.stageId
	out.isWin = self.Winner == EnumFight.Camp.PLAYER
	out.round = self.RunTime.CurRound
	out.remainHp = 100
	out.killMonsterList = self.RunTime.KillMonsterList
	out.playerDeadCount = #self.UnitMgr:Selector():Camp(1):Die():GetArray()
	out.randomArray = {}
	out.whipRewardCount = self.Result:GetWhipRewardCount()
	out.playerHpRates, out.monsterHpRates = self.Result:GetHpRate()
	out.selfDestructCount = self.Result.GameGrade:GetDestructCount()
	out.bloodCost, out.curHps = self.Result.UnitInfo:Monter()
	out.playerBlood, out.playerCurHp = self.Result.UnitInfo:Player()

	return out
end

function GameLogic:GetReplayJsonData()
	local replayData = FightDataUtil.GetStartData(self.GameStartData)

	replayData.playMode = EnumFight.PlayMode.Replay

	if self.GameStartData.playMode == EnumFight.PlayMode.Replay then
		replayData.operators = self.GameStartData.operators
	else
		replayData.operators = self.GL.OperatorRecord:GetOperators()
	end

	local json = require("GameLogic/Util/json4lua")
	local jsonStr = json.encode(replayData)

	return jsonStr
end

function GameLogic:FireOperatorRecord()
	if self.GameStartData.playMode == EnumFight.PlayMode.Std then
		self:Fire("游戏-操作记录", self.OperatorRecord:GetOperators(), self.GameStartData)
	end
end

function GameLogic:OnLoadScene(sceneName)
	if sceneName ~= "FightNormal" and sceneName ~= "FightBoss" then
		self:Purge()
	end
end

function GameLogic:GiveUpGame()
	self:MarkGameOver(EnumFight.Camp.PLAYER)
	self.GL.RunTime:ChangeState(EnumFight.GameState.DEBUG)
end

function GameLogic:BuyLive(boutId)
	self.OperatorRecord:BuyLive(boutId)

	self.GameStartData.boutId = boutId
	self.IsGameOver = false
	self.WillGameOver = false

	self.RunTime:ChangeState(EnumFight.GameState.DEBUG)

	for i, unit in self.GL.UnitMgr:Selector():Camp(1):Ipairs() do
		unit:Reborn()
		unit:HealHp(999999, unit)
	end

	self.RunTime:ResetRound()
	self.RunTime:ChangeState(EnumFight.GameState.NORMAL)
end

function GameLogic:GameError()
	self:GameOver()
	self:ERROR("游戏错误，结束游戏")
end

function GameLogic:Fire(event, ...)
	if self.Record then
		self.Record:Recording(event, ...)
	end

	self.GlobalEvent:Fire(event, ...)
end

function GameLogic:On(eventId, fun, t)
	if not self.EventMap[eventId] then
		self.EventMap[eventId] = 1
	else
		self.EventMap[eventId] = self.EventMap[eventId] + 1
	end

	self.GL.GlobalEvent:Add(eventId, fun, t)
end

function GameLogic:Off(eventId, fun, t)
	if self.EventMap[eventId] then
		self.EventMap[eventId] = self.EventMap[eventId] - 1

		if self.EventMap[eventId] == 0 then
			self.EventMap[eventId] = nil
		end
	end

	self.GL.GlobalEvent:Remove(eventId, fun, t)
end

function GameLogic:Random()
	return GameLogic.RandomTool()
end

function GameLogic.RandomTool(m, n)
	if not m then
		return RandomUtil.Random0_1()
	elseif not n then
		return RandomUtil.Random0_Max(m)
	else
		return RandomUtil.Random(m, n)
	end
end

function GameLogic.RandomToolInt(max)
	if max == nil or max < 1 then
		return 0
	end

	return GameLogic.RandomTool(1, max)
end

function GameLogic:GetFightData(tbl)
	tbl.data = self:GetReplayJsonData()
end

function GameLogic:GetResponse()
	return self.ServerRet:P300_response()
end
