-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoBattleSkillData.lua

local mt = {}
local _BattleSkillData = require("luaData/BattleSkillData")
local _AllSkill = require("luaData/AllSkills")

function mt:GetData(battleskilldataId)
	return _BattleSkillData[battleskilldataId]
end

function mt:GetAllSkillData(allskillId)
	local id = allskillId

	return _AllSkill[id]
end

function mt:GetAllSkillByBattleSkillId(battleskilldataId)
	local id = _BattleSkillData[battleskilldataId].AllSkillID

	return _AllSkill[id]
end

return mt
