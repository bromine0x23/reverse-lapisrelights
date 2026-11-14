-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/EnumBattle.lua

EnumBattle = {}
EnumBattle.Camp = {
	MAX = 2,
	PLAYER = 1,
	ENEMY = 2
}
EnumBattle.BattleType = {
	NORMAL = 1,
	UNDEFINE = 0,
	BOSS = 1
}
EnumBattle.UnitClass = {
	PVPPLAYER = 3,
	PLAYER = 1,
	UNDEFINE = 0,
	ENEMY = 2
}
EnumBattle.SeccionType = {
	force = 2,
	attack = 1,
	recover = 3
}
EnumBattle.MoveState = {
	GO = 1,
	BACK = 2
}

function EnumBattle.GetSecctionShowIcon(type, isSpecialIcon)
	local sessionCfg = require("luaData/SessionData")

	if isSpecialIcon == true then
		return sessionCfg[type].SpecialIcon
	end

	return sessionCfg[type].Icon
end

function EnumBattle.GetSecctionShowBigIcon(type)
	if type == EnumBattle.SeccionType.attack then
		return "UIDyAtlas/Battle/ui_hd_icon_sing"
	elseif type == EnumBattle.SeccionType.force then
		return "UIDyAtlas/Battle/ui_hd_icon_charge"
	elseif type == EnumBattle.SeccionType.recover then
		return "UIDyAtlas/Battle/ui_hd_icon_dance"
	end
end

EnumBattle.ActionState = numEnumWithStartNum({
	"battleReady",
	"battleStart",
	"updateWave",
	"roundStart",
	"doCard",
	"sessionShow",
	"playerAction",
	"enemyAction",
	"roundResult"
}, 0)
