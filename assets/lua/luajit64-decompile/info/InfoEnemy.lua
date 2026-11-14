-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoEnemy.lua

local EnemyData = require("luaData/Monster")
local ActorData = require("luaData/ActorData")

InfoEnemy = class("InfoEnemy", InfoBase)

function InfoEnemy:ctor(id)
	self.data = EnemyData[id]
	self.actorData = ActorData[self.data.ActorID]
end

function InfoEnemy:Init()
	self.MaxHp = self.data.AttriList[1]
	self.Hp = self.MaxHp
	self.Atk = self.data.AttriList[3]
	self.Def = self.data.AttriList[2]
end

function InfoEnemy:GetAtt(attType)
	if attType == "hp" then
		return self.data.AttriList[1]
	elseif attType == "defend" then
		return self.data.AttriList[2]
	elseif attType == "attack" then
		return self.data.AttriList[3]
	end

	return self.data.AttriList[1]
end

EnemyManager = {}
EnemyManager.dict = EnemyManager.dict or Record()

function EnemyManager:Get(id)
	local ret = self.dict:GetValue(id)

	if not ret then
		ret = InfoEnemy(id)

		EnemyManager.dict:Set(id, ret)
	end

	return ret
end

function EnemyManager:GetData(id)
	return EnemyData[id]
end
