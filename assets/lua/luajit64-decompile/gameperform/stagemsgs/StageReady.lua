-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/StageReady.lua

StageReady = class("StageReady", StageRecordBase)

function StageReady:ctor(GP)
	StageReady.base.ctor(self, GP)
end

function StageReady:Excute()
	for i, msg in ipairs(self.MsgList) do
		if msg.eventId == "阶段-改变" then
			-- block empty
		else
			self.GP.GameMsg:DoMsgAction(msg.eventId, msg)
		end
	end

	self:Enter()
end

function StageReady:Enter()
	self.GP:CreateTimeLine()
	self:Leave()
end

function StageReady:Leave()
	self.GP.GameMsg:ExcuteEnd()
end
