-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/StageAppearSkill.lua

StageAppearSkill = class("StageAppearSkill", StageRecordBase)

function StageAppearSkill:ctor(GP)
	StageAppearSkill.base.ctor(self, GP)
end

function StageAppearSkill:Excute()
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

function StageAppearSkill:Complete()
	self.GP.GameMsg:ExcuteEnd()
end

function StageAppearSkill:Dispose()
	self.controller:Dispose()
end
