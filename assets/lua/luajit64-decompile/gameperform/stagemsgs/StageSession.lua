-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/StageSession.lua

local print_enable = Application.isEditor == true
local print = function(...)
	if print_enable == true then
		print(...)
	end
end

StageSession = class("StageSession", StageRecordBase)

function StageSession:ctor(GP)
	StageSession.base.ctor(self, GP)
end

function StageSession:Excute()
	if self.GP.FightMode == EnumFight.BattleType.BOSS then
		self.controller = BossBattleMgr(self.GP)
	elseif self.GP.FightMode == EnumFight.BattleType.NORMAL then
		self.controller = NormalBattleMgr(self.GP)
	end

	self.controller:Create(self.MsgList)
	self.controller:Play(function()
		self:Complete()
	end)
end

function StageSession:Complete()
	self.GP.GameMsg:ExcuteEnd()
end

function StageSession:Dispose()
	self.controller:Dispose()
end
