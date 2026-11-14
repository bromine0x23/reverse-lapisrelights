-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/GameResult/GameGrade_JobExclude.lua

local eJobType = {
	Artifice = 2,
	Intelligence = 4,
	Assistance = 5,
	Speed = 3,
	Strength = 1
}
local mt = GLClass("GameGrade_JobExclude")

function mt:ctor(GL, starInfo)
	self.GL = GL
	self.StarInfo = starInfo
	self.Dest = starInfo.Dest

	local unitBaseData = self.GL.GameBaseData.Character

	for i, data in ipairs(self.GL.GameStartData.teams[1][1]) do
		local job = unitBaseData[data.unitId].Job

		if eJobType[job] == self.Dest then
			self.StarInfo.State = GameGrade.enState.Faild

			return
		end
	end

	self.StarInfo.State = GameGrade.enState.Done
end

function mt:Purge()
	self.GL = nil
	self.StarInfo = nil
	self.Dest = nil
end

return mt
