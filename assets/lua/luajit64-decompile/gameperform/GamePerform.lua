-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/GamePerform.lua

local dialog_enabled = true

local function ShowDialog(str, callback)
	if dialog_enabled == true then
		UIMgr.ShowDialog(str, callback)
	else
		callback()
	end
end

local print_enable = false
local print = function(...)
	if print_enable == true then
		print(...)
	end
end
local json = require("GameLogic.Util.json4lua")
local dropGroupTool = require("GamePerform.DropGroupTool")

require("GamePerform.Requires")

GamePerform = class("GamePerform", nil, true)

local _roundData = DefineClass({})
local _waveData = DefineClass({})

function GamePerform:ctor()
	if GP then
		GP:PurgeAll()
	end

	self:Reset()
	dropGroupTool.Init()

	self.GameMsg = GameMessage(self)
	self.Team = FightTeam(self)
	self.UI = nil
	self.EventDeal = EventDeal(self)
	self.RoundData = New(_roundData)
	self.WaveData = New(_waveData)
	self.CameraUtil = CameraUtility(self)
	self.SelectUnits = {}
	self.PrewarmUtil = PrewarmUtility(self)
	self.SpriteUtil = FightSpriteUtility(self)
	self.IsPurge = false
	self.DropGroupList = {}
	self.BulletPool = ObjectPool(Bullet)
	self.UnitVocal = UnitVocal(self)
	GP = self
end

function GamePerform:Reset()
	BattleConfig.TimeScaleOne()

	self.GameStartData = {}
	self.SpeedMode = EnumFight.SpeedMode.Default
	self.TimeLine = nil
	self.CameraUtil = nil
	self.UI = nil
	self.UnitReadyMsgs = {}
	self.SummonUnitReadyMsgs = {}
	self.GameMsg = {}
	self.Team = nil
	self.UnitVocal = nil
	self.FightMode = 0
	self.RoundData = nil
	self.WaveData = nil
	self.GameStage = -1
	self.LoseTimelineId = 0
	self.AutoMode = false
	self.SkipTimelineMode = false
	self.DropGroupList = {}
	self.fightStartTime = 0
	self.BulletPool = {}
	GP = nil
end

function GamePerform:Start()
	self.GameMsg:Start()
	JobCheckingUtil.Init()
	self.EventDeal:Init()
end

function GamePerform:SetInfoRole(vParam)
	self.StartParam = vParam
	self.infoRoleList = vParam.player1 and vParam.player1[1] or {}
	self.infoRoleCardList = vParam.player1 and vParam.player1[2] or {}
	self.infoRoleList2 = vParam.player2 and vParam.player2[1] or {}
	self.infoRoleCardList2 = vParam.player2 and vParam.player2[2] or {}
end

function GamePerform:GetInfoRole(unitId, camp)
	local roles = self.infoRoleList

	if camp == EnumFight.Camp.ENEMY then
		roles = self.infoRoleList2
	end

	for i, infoRole in ipairs(roles) do
		if unitId == infoRole.id then
			return infoRole
		end
	end

	return RoleMgr:GetRole(unitId)
end

function GamePerform:GetInfoCard(cardId, camp)
	local card = self.infoRoleCardList

	if camp == EnumFight.Camp.ENEMY then
		card = self.infoRoleCardList2
	end

	for i, infoCard in ipairs(card) do
		if cardId == infoCard.ID then
			return infoCard
		end
	end

	return RoleCardMgr:GetRoleCard(cardId)
end

function GamePerform:OnRegisterEvent()
	return
end

function GamePerform:OnUnRegisterEvent()
	return
end

function GamePerform:UnitReady(msg)
	table.insert(self.UnitReadyMsgs, msg)
end

function GamePerform:SummonUnitReady(msg)
	table.insert(self.SummonUnitReadyMsgs, msg)
end

function GamePerform:UnitInit()
	for i, msg in ipairs(self.UnitReadyMsgs) do
		self.Team:UnitReady(msg)
	end

	for i, msg in ipairs(self.SummonUnitReadyMsgs) do
		self.Team:SummonUnitReady(msg)
	end
end

function GamePerform:CreateFight(msg)
	self.GameStartData.gameId = msg.gameId
	self.GameStartData.boutId = msg.boutId
	self.GameStartData.stageId = msg.stageId
	self.GameStartData.playMode = msg.playMode
	self.GameStartData.fightMode = msg.fightMode
	self.GameStartData.pvp = msg.pvp
	self.GameStartData.teams = msg.teams
	self.GameStartData.myPower = msg.myPower
	self.GameStartData.otherPower = msg.otherPower
	self.GameStartData.myName = msg.myName
	self.GameStartData.otherName = msg.otherName
	self.GameStartData.bondage = msg.bondage
	self.PVPMode = self.GameStartData.pvp ~= EnumFight.Pvp.NONE
	self.BoutId = msg.boutId
	self.FightMode = msg.fightMode
	self.StageData = InfoBattleStage(msg.stageId)
	self.Pvp = msg.pvp

	self:InitSceneTimeLine()

	local sceneName = ""

	if msg.fightMode == 1 then
		sceneName = "FightNormal"
	elseif msg.fightMode == 2 then
		sceneName = "FightBoss"
	end

	local arg = {}

	arg.GP = self
	arg.startData = msg

	BattleConfig.LoadSoundBank(PATH_BATTLE_MUSIC_RESOULT_BANK, false, false)

	SceneMgr.autoHideLoading = true

	SceneMgr.LoadScene(sceneName, arg, self)
end

function GamePerform:AddDrop(rewardId)
	table.insert(self.DropGroupList, rewardId)
end

function GamePerform:SetFightStartTime(time)
	self.fightStartTime = time
end

function GamePerform:InitSceneTimeLine()
	self.TimeLine = TimeLineUtility(self)

	if self.FightMode == EnumFight.BattleType.NORMAL then
		self.TimeLine:Register(self.StageData:GetDataByKey("Session1P")[1])
		self.TimeLine:Register(self.StageData:GetDataByKey("Session2P")[1])
		self.TimeLine:Register(self.StageData:GetDataByKey("Session3P")[1])
		self.TimeLine:Register(self.StageData:GetDataByKey("Session4P")[1])
	elseif self.FightMode == EnumFight.BattleType.BOSS then
		local sessionCfg = require("luaData/SessionData")
		local keys = {
			"Session1P",
			"Session2P",
			"Session3P",
			"Session4P"
		}

		for i = 1, 3 do
			for j, key in ipairs(keys) do
				local timelineIds = sessionCfg[i][key]

				for _, timelineId in ipairs(timelineIds) do
					self.TimeLine:Register(timelineId)
				end
			end
		end

		self.TimeLine:Register(self.StageData:GetDataByKey("CamFlash"))
		self.TimeLine:Register(self.StageData:GetDataByKey("LiveTimeLine"))

		local timeLineBase = self.TimeLine:Get(self.StageData:GetDataByKey("LiveTimeLine"))

		self.Live = LiveUtility(self, timeLineBase)
	end
end

function GamePerform:Update()
	if self.Team then
		self.Team:Update()
	end
end

function GamePerform:Purge()
	if self.IsPurge == true then
		return
	end

	self.IsPurge = true

	UnitActor.Clear()
	UnitOwnSkill.Clear()
	self.CameraUtil:Purge()
	self.EventDeal:Purge()
	self.Team:Purge()
	self.UnitVocal:Purge()
	self.GameMsg:End()
	self.SpriteUtil:Purge()
	self.PrewarmUtil:Purge()
	self.TimeLine:Purge()
	FloatTipUtil.Purge()
	UnitVocal.End()
	self:Reset()

	self.StageData = nil
	self.StageId = nil
	self.BoutId = nil
	self.PlayerUnitIds = nil
	self.PlayerCardIds = nil

	if self.Timer then
		TimerMgr.RemoveTimer(self.Timer)
	end

	self.Timer = nil
end

function GamePerform:Cache()
	BattleConfig.LoadSoundBank(PATH_BATTLE_MUSIC_RESOULT_BANK, false, false)
	FloatTipUtil.Cache()
	self:UnitInit()
	self.Team:Cache()
	self.TimeLine:Cache()
	self.PrewarmUtil:Cache()
	self.UnitVocal:Cache()
end

function GamePerform:Create()
	FloatTipUtil.OnEnter()
	self.PrewarmUtil:PrewarmEffect()
	self.CameraUtil:Init()
	self.EventDeal:Create()

	self.UI = SceneMgr.GetCurrentScene().PageFight

	UnitActor.Init()
	UnitVocal.Init()
	self:LoadLocalCustom()
	self.GameMsg:Excute()
end

function GamePerform:LoadLocalCustom()
	local speedMode = PersistentStoreUtil.GetFloat(PersistentStoreUtil.KEY_FIGHT_SPEED_MODE, EnumFight.SpeedMode.Default)

	self:SetGameSpeedMode(speedMode)

	if self.GameStartData.playMode == EnumFight.PlayMode.Replay then
		return
	end

	self.AutoMode = PersistentStoreUtil.GetBool(PersistentStoreUtil.KEY_FIGHT_AUTO_MODE, false)

	if InstructionMgr.showAutoBtn == false then
		self.AutoMode = false
	end

	Event.Instance:Fire("SwitchAutoOperator", self.AutoMode)

	self.SkipTimelineMode = PersistentStoreUtil.GetBool(PersistentStoreUtil.KEY_FIGHT_SKIP_TL_MODE, false)

	Event.Instance:Fire("SwitchSkipMode", self.SkipTimelineMode)
end

function GamePerform:CreateTimeLine()
	self.TimeLine:Create()
end

local saveData = false

function GamePerform:GameOver(msg)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgBattleSetting", false)
	Event.Instance:Fire("EVENT_CLOSE_DLG_COOMN")
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIAuto", false)

	local data = msg.data

	self.ResultJson = data.json

	self:PlayGameOver(data.isWin)

	local resultData = {}

	resultData.jsonData = data.json
	resultData.stageId = data.stageId
	resultData.boutId = data.boutId
	resultData.isWin = data.isWin
	resultData.round = data.round
	resultData.remainHp = data.remainHp
	resultData.killMonsterList = data.killMonsterList
	resultData.playerDeadCount = data.playerDeadCount
	resultData.chaos = data.chaos
	resultData.whipRewardCount = data.whipRewardCount
	resultData.monsterHpRates = data.monsterHpRates
	resultData.playerHpRates = data.playerHpRates
	resultData.selfDestructCount = data.selfDestructCount
	resultData.bloodCost = data.bloodCost
	resultData.curHps = data.curHps

	local json = require("GameLogic.Util.json4lua")
	local ret = json.encode(self.GameStartData.operators)

	resultData.battlelogs = ret

	local oltime = os.time() - self.fightStartTime

	resultData.oltime = oltime

	local dropReward = #self.DropGroupList == 0 and "" or self.DropGroupList

	resultData.dropReward = dropReward
	resultData.playerCardIds = self.PlayerCardIds

	if self.GameStartData.pvp == EnumFight.Pvp.NONE then
		self.UI.DlgUIResult:Open(resultData)
	else
		self:PvpResult(resultData)
	end

	if saveData == true and self.GameStartData.playMode == EnumFight.PlayMode.Std and self.BoutId ~= -1 then
		io.write_text("C:/Users/Mloong/Desktop/fight_data" .. self.BoutId .. ".json", data.json)
	end
end

function GamePerform:PvpResult(msg)
	local InfoPVP = require("Info/InfoPVP")
	local battleid = self.BoutId
	local battleWin = TenaryOp(msg.isWin == true, 1, 0)
	local battleSeconds = math.ceil(msg.oltime)
	local battleRandoms = msg.randomCount
	local serverArg1 = TenaryOp(msg.isWin == true, 1, 0)
	local serverArg2 = msg.round
	local serverArg3 = Mathf.Ceil(msg.remainHp)
	local serverArg4 = msg.playerDeadCount
	local serverArg5 = msg.selfDestructCount
	local battleLogsLite = {
		serverArg1,
		serverArg2,
		serverArg3,
		serverArg4,
		serverArg5
	}
	local json = require("GameLogic.Util.json4lua")
	local ret = json.encode(GP.GameStartData.operators)
	local battlelogs = ret

	local function endBattleCB(arg)
		self:ExitGame(arg)
	end

	self.Timer = TimerMgr.AddTimer(eTimerType.RealTime, 1.5, function()
		InfoPVP:RequestBattleEnd(battleid, battleWin, battleSeconds, {
			battleRandoms
		}, battleLogsLite, battlelogs, endBattleCB)
	end, {})
end

function GamePerform:PlayGameOver(isWin)
	local center = self.Team.CenterUnit
	local centerTimelineId = 0
	local bgm = ""
	local timelineId = 0
	local unitvocal

	if isWin == true then
		unitvocal = UnitVocal.enType.Win

		if self.FightMode == EnumFight.BattleType.NORMAL then
			timelineId = center.UnitData.data.WinTimeLine
		else
			timelineId = self.StageData:GetDataByKey("Win")
		end

		bgm = PATH_BATTLE_MUSIC_RESOULT_WIN
	else
		unitvocal = UnitVocal.enType.Lose

		if self.FightMode == EnumFight.BattleType.NORMAL then
			timelineId = center.UnitData.data.LoseTimeLine
		else
			timelineId = self.StageData:GetDataByKey("Lose")
		end

		bgm = PATH_BATTLE_MUSIC_RESOULT_LOSE
	end

	BattleConfig.LoadSoundBank(PATH_BATTLE_MUSIC_RESOULT_BANK, false, false)
	BattleConfig.PostSoundEvent(bgm, UIMgr.UICamera.gameObject)
	Event.Instance:Fire("UnitVocalEvent", unitvocal, center)

	if self.FightMode == EnumFight.BattleType.BOSS then
		self.Live:PauseLive()
		self.TimeLine:PlayGameOverBossLive(timelineId, self.Team.PlayerTeam, function()
			BattleConfig.PostSoundEvent("Stop_All", UIMgr.UICamera.gameObject)
			self.Live:Play()
		end)
	else
		self.TimeLine:PlayGameOver(timelineId, center, function()
			BattleConfig.PostSoundEvent("Stop_All", UIMgr.UICamera.gameObject)
			SceneMgr:GetCurrentScene():PlayBgm()
		end)
	end

	self.LoseTimelineId = timelineId
end

function GamePerform:BuyLive(boutId)
	self.BoutId = boutId

	local loseTimeline = self.TimeLine:Get(self.LoseTimelineId)

	loseTimeline:Stop()
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator")
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo")
	Event.Instance:Fire("BuyLive", boutId)
end

function GamePerform:RestartGame()
	Event.Instance:Fire("ExitGameLogic")
	BattleConfig.FreeTimers()
	BattleConfig.UnloadAllBank()
	self:Purge()

	local game = require("GameLogic/RunGame")

	game:Run(self.StartParam)
end

function GamePerform:ReplayGame()
	Event.Instance:Fire("ExitGameLogic")
	BattleConfig.FreeTimers()
	BattleConfig.UnloadAllBank()
	self:Purge()

	local game = require("GameLogic/RunGame")

	game:RunByJson(self.ResultJson)
end

function GamePerform:GameOperatorRecord(msg)
	self.GameStartData.operators = msg.operators
	self.GameStartData.randomSeed = msg.randomSeed
end

function GamePerform:ExitGameScript()
	Event.Instance:Fire("ExitGameLogic")
	BattleConfig.FreeTimers()
	BattleConfig.UnloadAllBank()
	UIMgr.HideSkillTip()
	UIMgr.HideBuffTip()

	if self.callBack then
		self.callBack()
	end
end

function GamePerform:PurgeAll()
	self:ExitGameScript()
	self:Purge()
end

function GamePerform:ExitGame(vParam)
	Event.Instance:Fire("ExitGameLogic")
	BattleConfig.FreeTimers()
	BattleConfig.UnloadAllBank()
	UIMgr.HideSkillTip()
	UIMgr.HideBuffTip()

	if self.callBack then
		self.callBack()
	end

	if self.GameStartData.pvp ~= EnumFight.Pvp.NONE and GP.GameStartData.playMode == EnumFight.PlayMode.Std then
		SceneMgr.LoadScene("MainStage", {
			from = vParam.pvp,
			stageId = self.StageId
		})

		return
	end

	if not vParam then
		self:ExitToScene(vParam)
	end
end

function GamePerform:ExitToScene(vParam)
	if TutorialMgr:IsNeedSwitchMainStage(2) then
		SceneMgr.LoadScene("MainStage")

		return
	end

	if self.exitCall then
		self.exitCall()

		return
	end

	if self.BoutId == -1 then
		SceneMgr.LoadScene("MainStage")

		return
	end

	SceneMgr.LoadScene("MainStage", {
		from = 4,
		stageId = self.StageId
	})
end

function GamePerform:PickCard(msg)
	self.Team:SetActive(EnumFight.Camp.ENEMY, false)
	self.Team:SetActive(EnumFight.Camp.PLAYER, false)

	local function callback()
		self.Team:SetActive(EnumFight.Camp.PLAYER, true)

		for i, unit in ipairs(self.Team.EnemyTeam) do
			unit:SetActive(true)
		end
	end

	self.UI.DlgSkillChange:Open(callback)
end

function GamePerform:SwitchAutoMode()
	if self.GameStartData.playMode == EnumFight.PlayMode.Replay then
		return
	end

	self.AutoMode = not self.AutoMode

	if self.GameStage == EnumFight.GameState.OPERATOR_WAIT then
		Event.Instance:Fire("SetAutoOperator", self.AutoMode)
	end

	PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_FIGHT_AUTO_MODE, self.AutoMode)
	Event.Instance:Fire("SwitchAutoOperator", self.AutoMode)

	return self.AutoMode
end

function GamePerform:KeepAutoMode()
	if self.GameStartData.playMode == EnumFight.PlayMode.Replay then
		return
	end

	if self.AutoMode == true then
		Event.Instance:Fire("SetAutoOperator", self.AutoMode)
	end
end

function GamePerform:SetGameSpeedMode(speedMode)
	if speedMode < EnumFight.SpeedMode.Default or speedMode > EnumFight.SpeedMode.Extreme then
		speedMode = EnumFight.SpeedMode.Default
	end

	if self.SpeedMode == speedMode then
		return
	end

	self.SpeedMode = speedMode

	PersistentStoreUtil.SetFloat(PersistentStoreUtil.KEY_FIGHT_SPEED_MODE, self.SpeedMode)

	if self.FightMode == EnumFight.BattleType.BOSS then
		if self.Live.timeLineBase:ActiveSelf() == false then
			BattleConfig.TimeScaleActive(true)
		end
	else
		BattleConfig.TimeScaleActive(true)
	end

	Event.Instance:Fire("SetGameSpeedMode", self.SpeedMode)
end

function GamePerform:SetSkilTimeLineMode()
	self.SkipTimelineMode = not self.SkipTimelineMode

	PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_FIGHT_SKIP_TL_MODE, self.SkipTimelineMode)

	return self.SkipTimelineMode
end

function GamePerform:RefreshRound(msg)
	self.RoundData.CurRound = msg.curRound
	self.RoundData.MaxRound = msg.maxRound

	print("更新回合 " .. msg.curRound .. "/" .. msg.maxRound)
	self.UI.DlgUIOperator:RefreshRound()
	self.UI.DlgUIBattleInfo:RefreshRound(msg.curRound, msg.maxRound)

	if msg.curRound == 2 then
		BattleConfig.Delay(BattleConfig.Guide.CastSkill, function()
			InstructionMgr:TriggerWait("CastSkill")
		end)
	end
end

function GamePerform:RefreshWave(msg)
	self.WaveData.CurWave = msg.curWave
	self.WaveData.MaxWave = msg.maxWave

	print("更新波数 " .. msg.curWave .. "/" .. msg.maxWave)
	self.Team:RefreshCurEnemyTeam(msg.curWave)
	self.UI.DlgUIBattleInfo:RefreshWave(msg.curWave, msg.maxWave)
end

function GamePerform:RefreshRoundSession(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	if unit.UnitClass == EnumFight.UnitClass.PVPPLAYER then
		unit.NextCastSkill = msg.skillId

		local session = 0

		if msg.isPower == true then
			session = msg.sessionType + 3
		else
			session = msg.sessionType
		end

		unit.CurRoundSessionType = session
	end

	Event.Instance:Fire("RefreshRoundSession", msg)
end

function GamePerform:RefreshRoundCard(msg)
	Event.Instance:Fire("RefreshRoundCard", msg)
end

function GamePerform:SuggestSession(msg)
	Event.Instance:Fire("SuggestSession", msg)
end

function GamePerform:DoCard(msg)
	Event.Instance:Fire("DoCard", msg)
end

function GamePerform:ClearCard(msg)
	Event.Instance:Fire("ClearCard", msg)
end

function GamePerform:SummonUnitCreate(msg)
	self.Team:CreateSummonUnit(msg)
	self.UI.DlgUIBattleInfo:RefreshEnemyHpCons()
	Event.Instance:Fire("UnitCreate", msg)

	local unit = UnitActor.FindUnitById(msg.uniqueId)

	unit.HeadTipUI:ShowTargetEffect(true)
end

function GamePerform:UnitCreate(msg)
	self.Team:UnitCreate(msg)
	Event.Instance:Fire("UnitCreate", msg)
end

function GamePerform:UnitCreateReadyImmediately(msg)
	self.Team:UnitReadyImmediately(msg)
end

function GamePerform:UnitCreateImmediately(msg)
	local isBoss = false

	for i, unit in ipairs(self.Team.EnemyTeam) do
		isBoss = unit.IsBoss

		local enemyIdx = 3

		if isBoss == true then
			enemyIdx = 6
		end

		unit.LocationIndex = enemyIdx
	end

	self.Team:UnitCreateImmediately(msg)
	Event.Instance:Fire("UnitCreate", msg)
	SceneMgr.GetCurrentScene():CheckMainVirtualCamera(isBoss)
end

function GamePerform:UnitDestroy(msg)
	Event.Instance:Fire("UnitDestroy", msg)
end

function GamePerform:UnitDie(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	unit.IsDead = true

	local waitTime = 0

	if msg.dieReason == EnumFight.DieReson.SelfDestruct then
		unit:SelfDestruct()
	elseif msg.dieReason == EnumFight.DieReson.Std then
		waitTime = unit:PlayDie()

		Event.Instance:Fire("UnitVocalEvent", UnitVocal.enType.Die, unit)
	elseif msg.dieReason == EnumFight.DieReson.Force then
		unit:SelfDestruct()
	elseif msg.dieReason == EnumFight.DieReson.ZeroHpRate then
		waitTime = 0

		unit:SelfDestruct()
	end

	Event.Instance:Fire("UnitDie", msg.uniqueId)

	return waitTime
end

function GamePerform:UnitReborn(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	Event.Instance:Fire("UnitVocalEvent", UnitVocal.enType.Recover, unit)

	unit.IsDead = false

	unit:PlayRebron()
end

function GamePerform:TeamDie(msg)
	print("<color=yellow>TeamDie " .. msg.camp .. " </color>")
end

function GamePerform:UnitUpdateAttri(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	unit:SetAttri(msg.attriName, msg.cur)
	Event.Instance:Fire("UnitUpdateAttri", msg)
end

function GamePerform:TeamUpdateAttri(msg)
	if msg.attriName == "魔力" and msg.camp == EnumFight.Camp.PLAYER then
		self.Team.PlayerMp = msg.cur
	end

	if msg.attriName == "最大护盾" and msg.camp == EnumFight.Camp.PLAYER then
		self.Team.PlayerMaxShield = msg.cur
	end

	if msg.attriName == "速度" then
		self.Team.Speeds[msg.camp] = {}
		self.Team.Speeds[msg.camp] = msg.cur
	end

	Event.Instance:Fire("TeamUpdateAttri", msg)
end

function GamePerform:UnitMove(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)
	local target = UnitActor.FindUnitById(msg.targetUniqueId)

	unit:MoveToTarget(target)
end

function GamePerform:ChangeStage(msg)
	return
end

function GamePerform:SessionCutIn(msg, callback)
	if msg.sessionType then
		self.UI.DlgUICombo:SetSessionData(msg.sessionType, #msg.uniqueIds)
	else
		self.UI.DlgUICombo:SetSessionData(nil)
	end
end

function GamePerform:NSessionCutIn(unitActors, callback)
	self.UI.DlgUICutInNSession:Open(unitActors, callback)
end

function GamePerform:UpdateCombo(msg)
	local count = msg.count
	local camp = msg.camp
	local ownerUniqueId = msg.ownerUniqueId

	Event.Instance:Fire("UpdateCombo", msg)
end

function GamePerform:UnitDealDamage(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	Event.Instance:Fire("UnitVocalEvent_Hit", msg)
	unit:Damage(msg)
	Event.Instance:Fire("EVENT_CAMERA_SHAKE")
	Event.Instance:Fire("UnitDealDamage", msg)

	if unit.Camp == EnumFight.Camp.PLAYER then
		BattleConfig.Delay(BattleConfig.Guide.TakeDmg, function()
			InstructionMgr:TriggerWait("TakeDmg")
		end)
	end
end

function GamePerform:UnitHealHp(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	Event.Instance:Fire("UnitVocalEvent", UnitVocal.enType.Recover, unit)
	Event.Instance:Fire("UnitHealHp", msg)
end

function GamePerform:UnitForceMp(msg)
	return
end

function GamePerform:AddShield(msg)
	Event.Instance:Fire("AddShield", msg)
end

function GamePerform:AddAngry(msg)
	return
end

function GamePerform:UnitAngryBuffCast(msg)
	BattleConfig.Delay(BattleConfig.Guide.EnemyAngry, function()
		InstructionMgr:TriggerWait("EnemyAngry")
	end)
end

function GamePerform:UnitAddBuff(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	unit:AddBuff(msg.buffId, msg.buffUid, msg.skillPower, msg.stack, msg.logicData)
	unit:UpdateBuff(msg.buffUid, msg.remainRound)
	Event.Instance:Fire("AddBuff", msg.uniqueId, msg.buffId, msg.buffUid)
end

function GamePerform:UnitAddBuffFail(msg)
	Event.Instance:Fire("BuffMiss", msg.uniqueId, msg.reason)
end

function GamePerform:UnitUpdateBuff(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	unit:UpdateBuff(msg.buffUid, msg.remainRound)
	unit:BuffStack(msg.buffUid, msg.stack)
	Event.Instance:Fire("UpdateBuff", msg.uniqueId, msg.buffId, msg.buffUid)
end

function GamePerform:UnitBuffStack(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	unit:BuffStack(msg.buffUid, msg.stack)
	Event.Instance:Fire("BuffStack", msg.uniqueId, msg.buffId, msg.buffUid)
end

function GamePerform:UpdateBuffData(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)
	local buff = unit:GetBuff(msg.buffUid)

	if buff then
		buff:SetLogicData(msg.logicData)
	end
end

function GamePerform:UnitRemoveBuff(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	unit:RemoveBuff(msg.buffId, msg.buffUid)
	Event.Instance:Fire("RemoveBuff", msg.uniqueId, msg.buffId, msg.buffUid)
end

function GamePerform:UnitNotAction(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	unit:SetNotAction(msg.val)
	Event.Instance:Fire("UnitNotAction", msg.uniqueId, msg.val)
end

function GamePerform:UnitMissing(msg)
	Event.Instance:Fire("UnitMissing", msg)
end

function GamePerform:UnitDisableCardSkill(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	unit:SetDisableCardSkill(msg.val)
	Event.Instance:Fire("UnitDisableCardSkill", msg.uniqueId, msg.val)
end

function GamePerform:SkillUpdateStackPower(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)
	local ownSkill = unit:GetOwnSkill(msg.skillId)

	if ownSkill then
		ownSkill:StackPower(msg.stack)
		Event.Instance:Fire("SkillUpdateStackPower", msg)
	end
end

function GamePerform:ReqSelectTarget(unitId)
	for _, unit in ipairs(self.Team.EnemyTeam) do
		if unit.UnitId == unitId then
			Event.Instance:Fire("ReqTargetChange", unit.UniqueId)

			return
		end
	end
end

function GamePerform:GetUnitTransform(unitId)
	for _, unit in ipairs(self.Team.EnemyTeam) do
		if unit.UnitId == unitId then
			return GOUtil.GetUIPosForCameraMode(SceneMgr.GetCurrentScene().camera, UIMgr.RootCanvas, unit.ActorRoot.transform.position)
		end
	end

	return nil
end

function GamePerform:SelectTarget(msg)
	for i, unit in ipairs(self.Team.EnemyTeam) do
		local val = msg.uniqueId == unit.UniqueId

		if val == true then
			self.SelectUnits = {}
			self.SelectUnits[1] = unit
		end

		unit:SelectTargetEffect(val)
	end

	for i, unit in ipairs(self.Team.PlayerTeam) do
		unit:SelectTargetEffect(false)
	end

	Event.Instance:Fire("OnSelectorTarget", msg)
end

function GamePerform:SkillPreviewTargets(msg)
	local uniqueid, skillid, targetUids = msg.uniqueid, msg.skillId, msg.targetUids

	for i, unit in ipairs(self.Team.PlayerTeam) do
		unit:SelectTargetEffect(false)
	end

	for i, unit in ipairs(self.Team.EnemyTeam) do
		unit:SelectTargetEffect(false)
	end

	for _, uid in ipairs(targetUids) do
		local unit = UnitActor.FindUnitById(uid)

		unit:SelectTargetEffect(true)

		if self.SelectUnits[1] and self.SelectUnits[1].UniqueId ~= unit.UniqueId then
			table.insert(self.SelectUnits, unit)
		end
	end
end

function GamePerform:UnitRandomSkill(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	unit.NextCastSkill = msg.skillId

	Event.Instance:Fire("OnUnitRandomSkill", msg)
end

function GamePerform:UnitBuffCutomMsg(msg)
	if msg.custom == "BuffExe" then
		local unit = UnitActor.FindUnitById(msg.uniqueId)

		unit:BuffExe(msg.buffUid)
		Event.Instance:Fire("OnBuffExe", msg.uniqueId, msg.buffId, msg.buffUid)
	elseif msg.custom == "ExeFx" then
		local unit = UnitActor.FindUnitById(msg.uniqueId)
		local buff = unit.BuffMap[msg.buffUid]

		if buff then
			local target = UnitActor.FindUnitById(msg.args.target)

			if target then
				BattleConfig.FxAlloc(buff.ExeFx, target)
			end
		end
	else
		Event.Instance:Fire("OnBuffCutomMsg", msg)
	end
end

function GamePerform:UnitAttachFx(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	if unit then
		BattleConfig.FxAlloc(msg.fx, unit)
	end
end

function GamePerform:UnitAttachUIFx(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	if unit and unit.HeadTipUI then
		local uiRoot = unit.HeadTipUI.roleIconEffRoot

		EffectMgr:AllocById(msg.fx, uiRoot)
	end
end

function GamePerform:UnitAttachIconFx(msg)
	Event.Instance:Fire("IconFx", msg)
end

function GamePerform:SkillFloatTip(msg)
	Event.Instance:Fire("OnSkillFloatTip", msg)
end

function GamePerform:Whipped(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	BattleConfig.FxAlloc(BattleConst.whippedCorpseEff, unit)
end

function GamePerform:WhippedDrop(msg)
	local overDropGroupList = self.StageData:GetDataByKey("OverDropGroupList")

	for type, rewardId in ipairs(overDropGroupList) do
		if rewardId == msg.rewardId then
			Event.Instance:Fire("WhippedCorpseAwards", msg.uniqueId, type)
			Event.Instance:Fire("OnUIEffect", msg.uniqueId, BattleConst.whippedAwardEff)
			self:AddDrop(msg.rewardId)

			return
		end
	end
end

function GamePerform:GameResultData(msg)
	self.GameResultAddUpData = msg.resultData
end
