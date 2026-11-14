-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/StageRecordBase.lua

StageRecordBase = class("StageRecordBase")

function StageRecordBase:ctor(GP)
	self.GP = GP
	self.Stage = 0
	self.MsgList = {}
end

function StageRecordBase:GameRecording(msg)
	table.insert(self.MsgList, msg)
end

function StageRecordBase:SetCurStage(stage)
	self.Stage = stage
end
