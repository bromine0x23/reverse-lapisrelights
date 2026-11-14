-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/GameResult/GameGrade.lua

local map = {
	SelfDestructLimit = "GameLogic/Fight.GameResult.GameGrade_SelfDestructLimit",
	LimitTurn = "GameLogic/Fight.GameResult.GameGrade_LimitTurn",
	DieNum = "GameLogic/Fight.GameResult.GameGrade_DieNum",
	JobInclude = "GameLogic/Fight.GameResult.GameGrade_JobInclude",
	JobExclude = "GameLogic/Fight.GameResult.GameGrade_JobExclude",
	Win = "GameLogic/Fight.GameResult.GameGrade_Win"
}

GameGrade = GLClass("GameGrade", GameHelper)
GameGrade.enState = {
	Done = 2,
	Faild = 1,
	Processing = 3
}

function GameGrade:ctor(GL)
	self:Reset()

	self.GL = GL

	local Grade = self.GL.GameBaseData.StageData.Grade

	for i, itemCfg in ipairs(Grade) do
		local item = self:CreateStarItemData(i, itemCfg)
		local scriptPath = map[item.Condition]

		if scriptPath then
			local script = require(scriptPath)(self.GL, item)

			table.insert(self.Scripts, script)
		end

		table.insert(self.StarInfo, item)
	end

	self:OnRegisterEvent()
end

function GameGrade:GetDestructCount()
	local count = 0

	for i, script in ipairs(self.Scripts) do
		if script.className == "GameGrade_SelfDestructLimit" then
			count = script:GetCount()

			break
		end
	end

	return count
end

function GameGrade:CreateStarItemData(idx, cfg)
	local item = {}

	item.State = GameGrade.enState.Processing
	item.Cfg = cfg

	for k, v in pairs(item.Cfg) do
		item.Condition = k
		item.Dest = v
	end

	item.Idx = idx
	item.Cur = 0

	return item
end

function GameGrade:Reset()
	self.StarInfo = {}
	self.Scripts = {}
end

function GameGrade:GetStarInfo()
	local Grade = {}

	for i, item in ipairs(self.StarInfo) do
		table.insert(Grade, item.State == GameGrade.enState.Done)
	end

	return Grade
end

function GameGrade:Purge()
	for i, script in ipairs(self.Scripts) do
		script:Purge()
	end

	self:OnUnRegisterEvent()
end

function GameGrade:OnRegisterEvent()
	self.GL.GlobalEvent:Add("单位-创建", self.OnUnitCreate, self)
end

function GameGrade:OnUnRegisterEvent()
	self.GL.GlobalEvent:Remove("单位-创建", self.OnUnitCreate, self)
end

function GameGrade:OnUnitCreate(unit)
	return
end
