-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/GameResult/GameGrade_SelfDestructLimit.lua

local mt = GLClass("GameGrade_SelfDestructLimit")

function mt:ctor(GL, starInfo)
	self.GL = GL
	self.Cfg = cfg
	self.StarInfo = starInfo
	self.Dest = starInfo.Dest
	self.DieNum = 0
	self.StarInfo.State = GameGrade.enState.Processing

	self.GL:On("单位-死亡", self.OnEvent, self)
	self.GL:On("游戏-即将结束", self.OnEventGameOver, self)
end

function mt:Purge()
	self.GL:Off("单位-死亡", self.OnEvent, self)
	self.GL:Off("游戏-即将结束", self.OnEventGameOver, self)

	self.GL = nil
	self.StarInfo = nil
	self.DieNum = 0
end

function mt:OnEvent(unit)
	if unit.Camp == EnumFight.Camp.PLAYER then
		return
	end

	if unit.DieReason ~= EnumFight.DieReson.SelfDestruct then
		return
	end

	self.DieNum = self.DieNum + 1

	if self.DieNum > self.Dest then
		self.StarInfo.State = GameGrade.enState.Faild
	end
end

function mt:OnEventGameOver()
	if self.DieNum > self.Dest then
		self.StarInfo.State = GameGrade.enState.Faild
	else
		self.StarInfo.State = GameGrade.enState.Done
	end
end

function mt:GetCount()
	return self.DieNum
end

return mt
