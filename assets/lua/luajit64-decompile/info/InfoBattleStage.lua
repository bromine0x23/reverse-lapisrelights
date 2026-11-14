-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoBattleStage.lua

local BattleStageData = require("luaData/BattleStage")
local StageData = require("luaData/StageData")

InfoBattleStage = class("InfoBattleStage")

function InfoBattleStage:ctor(stageId)
	self:Reset()
	self:InitByStageId(stageId)
end

function InfoBattleStage:Reset()
	self.data = nil
	self.StageData = nil
end

function InfoBattleStage:InitByStageId(stageId)
	self.StageData = StageData[stageId]

	local id = self.StageData.BattleStageID

	if id == 0 then
		print("<color=red>检查配置表StageData 这个不是战斗地图！！！！ stageId = " .. stageId .. "</color>")

		return false
	end

	self.data = BattleStageData[id]

	if not self.data then
		print("<color=red> !!!!  stageId:" .. id .. " 没有配置BattleStage</color>")

		return false
	end

	return true
end

function InfoBattleStage:GetStageData()
	return self.StageData
end

function InfoBattleStage:GetData()
	return self.data
end

function InfoBattleStage:GetDataByKey(key)
	if self.data[key] then
		return self.data[key]
	end

	print("<color=red> InfoBattleSkill:GetDataByKey ERROR !  key = " .. key .. "</color>")

	return nil
end
