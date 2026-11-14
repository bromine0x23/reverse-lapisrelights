-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/GameOperatorRecord/GameOperatorRecord.lua

GameOperatorRecord = GLClass("GameOperatorRecord", GameHelper)

local PickCardData = DefineClass({
	CardIds = {}
})
local OperatorSessionData = DefineClass({
	OperatorData = {}
})
local OperatorCardData = DefineClass({
	OperatorData = {}
})
local BuyLiveData = DefineClass({
	BoutId = {}
})
local CMDData = DefineClass({
	CMDStr = {}
})

function GameOperatorRecord:ctor(GL)
	self.GL = GL
	self.Operators = {}

	self:Reset()
end

function GameOperatorRecord:Reset()
	return
end

function GameOperatorRecord:Purge()
	self:Reset()
end

function GameOperatorRecord:Init()
	self.PlayMode = self.GL.GameStartData.playMode

	if self.PlayMode == EnumFight.PlayMode.Replay then
		if self.GL.GameStartData.operators ~= nil then
			self.Operators = {}

			for k, v in ipairs(self.GL.GameStartData.operators) do
				table.insert(self.Operators, v)
			end
		else
			self:ERROR("replay mode without operator data")
		end
	end
end

function GameOperatorRecord:GetOperators()
	return self.Operators
end

function GameOperatorRecord:PopOperatorData()
	if self.PlayMode == EnumFight.PlayMode.Std then
		return nil
	end

	local data = self.Operators[1]

	if data then
		table.remove(self.Operators, 1)
	end

	return data
end

function GameOperatorRecord:PickCard(cardIds)
	if self.PlayMode == EnumFight.PlayMode.Replay then
		return
	end

	local data = New(PickCardData)

	data.Type = EnumFight.OperatorType.PickCard
	data.CardIds = cardIds

	table.insert(self.Operators, data)
end

function GameOperatorRecord:Session(operatorData)
	if self.PlayMode == EnumFight.PlayMode.Replay then
		return
	end

	local data = New(OperatorSessionData)

	data.Type = EnumFight.OperatorType.Session
	data.OperatorData = operatorData
	data.Target = self.GL.RunTime.CurSelectTarget.UniqueId

	table.insert(self.Operators, data)
end

function GameOperatorRecord:Card(operatorData)
	if self.PlayMode == EnumFight.PlayMode.Replay then
		return
	end

	local data = New(OperatorCardData)

	data.Type = EnumFight.OperatorType.Card
	data.OperatorData = operatorData
	data.Target = self.GL.RunTime.CurSelectTarget.UniqueId

	table.insert(self.Operators, data)
end

function GameOperatorRecord:BuyLive(boutId)
	if self.PlayMode == EnumFight.PlayMode.Replay then
		return
	end

	local data = New(BuyLiveData)

	data.Type = EnumFight.OperatorType.BuyLive
	data.BoutId = boutId

	table.insert(self.Operators, data)
end

function GameOperatorRecord:CMD(str)
	if self.PlayMode == EnumFight.PlayMode.Replay then
		return
	end

	local data = New(CMDData)

	data.Type = EnumFight.OperatorType.CMD
	data.CMDStr = str

	table.insert(self.Operators, data)
end
