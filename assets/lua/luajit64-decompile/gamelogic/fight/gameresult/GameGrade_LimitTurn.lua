-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/GameResult/GameGrade_LimitTurn.lua

local mt = GLClass("GameGrade_LimitTurn")

function mt:ctor(GL, starInfo)
	self.GL = GL
	self.StarInfo = starInfo
	self.Dest = starInfo.Dest
	self.StarInfo.State = GameGrade.enState.Processing

	self.GL:On("更新回合", self.OnEvent, self)
	self.GL:On("游戏-即将结束", self.OnEventGameOver, self)
end

function mt:Purge()
	self.GL:Off("更新回合", self.OnEvent, self)
	self.GL:Off("游戏-即将结束", self.OnEventGameOver, self)

	self.GL = nil
	self.StarInfo = nil
end

function mt:OnEvent(curRound, maxRound)
	if curRound > self.Dest then
		self.StarInfo.State = GameGrade.enState.Faild
	end
end

function mt:OnEventGameOver()
	if self.GL.RunTime.CurRound <= self.Dest then
		self.StarInfo.State = GameGrade.enState.Done
	else
		self.StarInfo.State = GameGrade.enState.Faild
	end
end

return mt
