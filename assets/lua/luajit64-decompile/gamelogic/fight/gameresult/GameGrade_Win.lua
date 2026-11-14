-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/GameResult/GameGrade_Win.lua

local mt = GLClass("GameGrade_Win")

function mt:ctor(GL, starInfo)
	self.GL = GL
	self.StarInfo = starInfo
	self.StarInfo.State = GameGrade.enState.Processing

	self.GL:On("游戏-即将结束", self.OnEvent, self)
end

function mt:Purge()
	self.GL:Off("游戏-即将结束", self.OnEvent, self)

	self.GL = nil
	self.StarInfo = nil
end

function mt:OnEvent()
	if self.GL.Winner == EnumFight.Camp.PLAYER then
		self.StarInfo.State = GameGrade.enState.Done
	else
		self.StarInfo.State = GameGrade.enState.Faild
	end
end

return mt
