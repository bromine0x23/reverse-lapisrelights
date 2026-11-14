-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/StageDoCard.lua

local print_enable = Application.isEditor == true
local print = function(...)
	if print_enable == true then
		print(...)
	end
end

StageDoCard = class("StageDoCard", StageRecordBase)

function StageDoCard:ctor(GP)
	StageDoCard.base.ctor(self, GP)
end

function StageDoCard:Excute()
	print("-----------StageDoCard打印战报----------------")
	printTableToJson(self.MsgList, true)

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

function StageDoCard:Complete()
	self.GP.GameMsg:ExcuteEnd()
end

function StageDoCard:Dispose()
	self.controller:Dispose()
end
