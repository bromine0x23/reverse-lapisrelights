-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/EnumFight.lua

EnumFight = {}
EnumFight.GameState = {
	OPERATOR_WAIT = 6,
	ENEMY_ACTION = 8,
	READY_END = 3,
	WARN = 10,
	DEBUG = 13,
	PLAYER_CARD = 12,
	NORMAL = 4,
	READY = 2,
	GAMEOVER = 11,
	APPEAR_SKILL = 14,
	INIT = 1,
	PLAYER_SESSION = 7,
	NEWWAVE = 5,
	ERROR = 9
}

local GameStageStr = {
	"INIT",
	"READY",
	"READY_END",
	"NORMAL",
	"NEWWAVE",
	"OPERATOR_WAIT",
	"PLAYER_SESSION",
	"ENEMY_ACTION",
	"ERROR",
	"WARN",
	"GAMEOVER",
	"PLAYER_CARD",
	"DEBUG",
	"APPEAR_SKILL"
}

function EnumFight.GameStageStr(stage)
	return GameStageStr[stage]
end

EnumFight.Camp = {
	MAX = 2,
	PLAYER = 1,
	UNDEFINE = 0,
	ENEMY = 2
}
EnumFight.BattleType = {
	PVP = 3,
	UNDEFINE = 0,
	NORMAL = 1,
	BOSS = 2
}
EnumFight.UnitClass = {
	PVPPLAYER = 3,
	PLAYER = 1,
	UNDEFINE = 0,
	ENEMY = 2
}
EnumFight.Pvp = {
	NORMAL = 1,
	NONE = 0
}
EnumFight.SessionType = {
	recover = 3,
	attack = 1,
	max = 3,
	force = 2,
	none = 0
}
EnumFight.DamageType = {
	Std = 1,
	Anti = 32,
	Extra = 16,
	Crit = 2,
	Mut = 8,
	DotBreak = 128,
	Invalid = 64,
	Dot = 4,
	Undefined = 0
}
EnumFight.BreakShieldState = {
	BREAKING = 2,
	UNDEFINE = 0,
	DEFENSE = 1,
	BREAKED = 3
}
EnumFight.SkillType = {
	SpecialAction = 6,
	Center = 3,
	Union = 8,
	AttackAction = 4,
	Passive = 2,
	ThumpAction = 5,
	PlayerModelMonster = 9,
	Active = 1,
	Link = 7,
	None = 0
}
EnumFight.PassiveSkillType = {
	Job = 1,
	Undefine = 0
}
EnumFight.SceneObj = {
	Empty = 0,
	Main = 1,
	Session = 2,
	Null = -1
}
EnumFight.DieReson = {
	Force = 2,
	ZeroHpRate = 3,
	SelfDestruct = 1,
	Std = 0
}
EnumFight.BuffMissReason = {
	Ignore = 2,
	Useless = 1,
	None = 0
}
EnumFight.SpeedMode = {
	Default = 1,
	Extreme = 3,
	Fast = 2
}
EnumFight.AutoModeState = {
	Card = 1,
	Session = 2,
	None = 0
}
EnumFight.PlayMode = {
	Replay = 2,
	Std = 1
}
EnumFight.OperatorType = {
	BuyLive = 4,
	CMD = 5,
	Card = 3,
	PickCard = 1,
	Session = 2
}
EnumFight.ShowIcon = {
	Team = 2,
	All = 3,
	Unit = 1,
	None = 0
}
