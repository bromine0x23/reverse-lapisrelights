-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/GameResult/GameResult_RoundResult.lua

local _item = GLClass("GameResult_GameResult_RoundResult_item", GameHelper)

function _item:ctor(GL, round)
	self.round = round
	self.GL = GL
	self.sumHeal = {}
	self.sumHeal[EnumFight.Camp.PLAYER] = 0
	self.sumHeal[EnumFight.Camp.ENEMY] = 0
end

function _item:OnUnitHeal(unit, healer, val)
	if self.sumHeal[unit.Camp] then
		self.sumHeal[unit.Camp] = self.sumHeal[unit.Camp] + val
	end
end

function _item:Purge()
	self.round = 0
	self.sumHeal = {}
	self.GL = nil
end

local GameResult_RoundResult = GLClass("GameResult_GameResult_RoundResult", GameHelper)

function GameResult_RoundResult:ctor(GL)
	self.GL = GL
	self.list = {}

	self:OnRegisterEvent()
end

function GameResult_RoundResult:Purge()
	self:OnUnRegisterEvent()

	for i, item in ipairs(self.list) do
		item:Purge()
	end

	self.list = {}
	self.GL = nil
end

function GameResult_RoundResult:GetData()
	return self.list
end

function GameResult_RoundResult:OnRegisterEvent()
	self.GL.GlobalEvent:Add("更新回合", self.OnRound, self)
	self.GL.GlobalEvent:Add("单位-治疗目标", self.OnUnitHeal, self)
end

function GameResult_RoundResult:OnUnRegisterEvent()
	self.GL.GlobalEvent:Remove("更新回合", self.OnRound, self)
	self.GL.GlobalEvent:Remove("单位-治疗目标", self.OnUnitHeal, self)
end

function GameResult_RoundResult:OnRound(cur, max)
	if cur <= 0 then
		return
	end

	table.insert(self.list, _item(self.GL, cur))
end

function GameResult_RoundResult:GetItem(round)
	if round and round > 0 then
		return self.list[round]
	end

	if self.GL.RunTime.CurRound and self.GL.RunTime.CurRound > 0 then
		return self.list[self.GL.RunTime.CurRound]
	end

	return nil
end

function GameResult_RoundResult:OnUnitHeal(unit, healer, val)
	local item = self:GetItem()

	if item then
		item:OnUnitHeal(unit, healer, val)
	end
end

return GameResult_RoundResult
