-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/GameResult/ServerResult.lua

ServerResult = GLClass("ServerResult", GameHelper)

function ServerResult:ctor(GL)
	self.GL = GL
	self.result = {
		desc = "None",
		code = -1
	}
	self.isWin = false
	self.values = {}
	self.whipNum = -1
	self.bloodCost = {}
	self.bloodTeam = {}
	self.killMonsters = {}
end

function ServerResult:P300_response()
	local isWin = TenaryOp(self.GL.Winner == EnumFight.Camp.PLAYER, 1, 0)
	local round = self.GL.RunTime.CurRound
	local dieCount = #self.GL.UnitMgr:Selector():Camp(1):Die():GetArray()
	local destructCount = self.GL.Result.GameGrade:GetDestructCount()

	self.result = {
		desc = "",
		code = 0
	}
	self.isWin = self.GL.Winner == EnumFight.Camp.PLAYER
	self.values = {
		isWin,
		round,
		0,
		dieCount,
		destructCount
	}
	self.whipNum = self.GL.Result:GetWhipRewardCount()
	self.bloodCost = self.GL.Result:GetBloodCost()
	self.bloodTeam = self.GL.Result:GetBloodTeam()
	self.killMonsters = self.GL.RunTime.KillMonsterList

	local out = {
		result = self.result,
		isWin = self.isWin,
		values = self.values,
		whipNum = self.whipNum,
		bloodCost = self.bloodCost,
		bloodTeam = self.bloodTeam,
		killMonsters = self.killMonsters
	}

	return out
end
