-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/Requires.lua

require("GameLogic/Util/JobCheckingHelp")

if not class then
	require("GameLogic/Util/Class")
else
	GLClass = class
end

require("GameLogic/Util/Tool")
require("GameLogic/Util/RandomUtil")
require("GameLogic/Util/InfoBattleStage")

if not Event then
	require("GameLogic/Util/Event")
end

require("GameLogic/Util/GameHelper")
require("GameLogic/Util/AttributeUtil")
require("GameLogic/Fight/FightDatas")
require("GameLogic/Util.ObjectPool")
require("GameLogic/Util.SessionCheckingUtil")
require("GameLogic/Fight.ObjectPool.GLObjectPool")
require("GameLogic/Fight.EnumFight")
require("GameLogic/Fight.FightConst")
require("GameLogic/Fight.GameRecord.GameRecord")
require("GameLogic/Fight.GameCMD.GameCMD")
require("GameLogic.Fight.GameOperatorRecord.GameOperatorRecord")
require("GameLogic/Fight.GameRunTime.GameTeamInfo")
require("GameLogic/Fight.GameRunTime.GameRoundData")
require("GameLogic/Fight.GameRunTime.GameRunTime")
require("GameLogic.Fight.GameResult.GameResult")
require("GameLogic/Fight.GameResult.GameGrade")
require("GameLogic.Fight.GameResult.ServerResult")
require("GameLogic/Fight.ObjectPool.Unit.UnitManager")
require("GameLogic/Fight.ObjectPool.Unit.Unit")
require("GameLogic/Fight.ObjectPool.Unit.ModifyValue")
require("GameLogic/Fight.ObjectPool.Unit.UnitSelector")
require("GameLogic/Fight.ObjectPool.Damage")
require("GameLogic/Fight.ObjectPool.Skill")
require("GameLogic/Fight.ObjectPool.SkillSelectTarget")
require("GameLogic/Fight.ObjectPool.BuffPriority")
require("GameLogic/Fight.ObjectPool.Buff")
require("GameLogic/Fight.Script.BuffScript")
require("GameLogic/Fight.Script.BuffScriptStatic")
require("GameLogic/Fight.Script.DmgSkillEnd")
require("GameLogic/Fight.Script.SkillScript")
require("GameLogic/Fight.Script.SkillScript2")
