-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/StageReadyEnd.lua

StageReadyEnd = class("StageReadyEnd", StageRecordBase)

function StageReadyEnd:ctor(GP)
	StageReadyEnd.base.ctor(self, GP)
end

function StageReadyEnd:Excute()
	self.list = {}

	for i, msg in ipairs(self.MsgList) do
		if msg.eventId == "阶段-改变" then
			-- block empty
		else
			table.insert(self.list, msg)
			self.GP.GameMsg:DoMsgAction(msg.eventId, msg)
		end
	end

	self:Enter()
end

function StageReadyEnd:Enter(msg)
	self.GP:CreateTimeLine()
	self:PlayAppear()
end

function StageReadyEnd:PlayAppear()
	local appearId = 0
	local isBoss = false

	for i, unit in ipairs(self.GP.Team.EnemyTeam) do
		isBoss = unit.IsBoss

		if unit.UnitData.data.AppearTimeLine ~= 0 then
			appearId = unit.UnitData.data.AppearTimeLine
		end

		unit:SetActive(false)
	end

	SceneMgr.GetCurrentScene():CheckMainVirtualCamera(isBoss)

	if appearId ~= 0 then
		self.GP.TimeLine:Play(appearId, function()
			self:PlayOpening()
		end)
	else
		self:PlayOpening()
	end
end

function StageReadyEnd:PlayOpening()
	local timeLineId = self.GP.StageData:GetDataByKey("Opening")
	local timeLine = self.GP.TimeLine:Get(timeLineId)

	for i, unit in ipairs(self.GP.Team.PlayerTeam) do
		timeLine:SetGenericBinding("Animation Track " .. i, unit.ActorSkeletonRoot)
		timeLine:SetGenericBinding("Expression Track " .. i, unit.ActorSkeletonRoot)
		unit:EnableAnimatorController(false)
	end

	timeLine:Play(function()
		self:OpeningCallback()
	end)
end

function StageReadyEnd:OpeningCallback()
	if self.GP.FightMode == EnumFight.BattleType.NORMAL then
		self:Leave()
		self.GP.Team:SetActive(EnumFight.Camp.ENEMY, true)

		for i, unit in ipairs(self.GP.Team.PlayerTeam) do
			unit:EnableAnimatorController(true)
		end
	elseif self.GP.FightMode == EnumFight.BattleType.BOSS then
		self:StartLive()
		self:Leave()
		self.GP.Team:SetActive(EnumFight.Camp.ENEMY, false)
	end
end

function StageReadyEnd:StartLive()
	self.GP.Live:Play()
end

function StageReadyEnd:Leave()
	self.GP.GameMsg:ExcuteEnd()
end
