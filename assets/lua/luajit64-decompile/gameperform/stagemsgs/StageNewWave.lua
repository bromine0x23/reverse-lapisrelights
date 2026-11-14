-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/StageNewWave.lua

StageNewWave = class("StageNewWave", StageRecordBase)

function StageNewWave:ctor(GP)
	StageNewWave.base.ctor(self, GP)
end

function StageNewWave:Excute()
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

function StageNewWave:Enter(msg)
	if self.GP.WaveData.CurWave == 1 then
		BattleConfig.DelayFrameCount(1, function()
			Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIFirstHand", true, function()
				self:PlayOpening()
			end)
		end)
	else
		self:OpeningEnd()
	end
end

function StageNewWave:PlayOpening()
	local center = self.GP.Team.CenterUnit

	if self.GP.GameStartData.pvp ~= EnumFight.Pvp.NONE and self.GP.Team.Speeds[1] < self.GP.Team.Speeds[2] then
		for i, unit in ipairs(self.GP.Team.EnemyTeam) do
			if unit.IsCenter == true then
				center = unit

				break
			end
		end
	end

	Event.Instance:Fire("UnitVocalEvent", UnitVocal.enType.Start, center)

	local centerTimelineId = 0

	if self.GP.FightMode == EnumFight.BattleType.BOSS then
		if center.UnitData.data.BossOpeningTimeLine and center.UnitData.data.BossOpeningTimeLine ~= 0 then
			centerTimelineId = center.UnitData.data.BossOpeningTimeLine
		end
	else
		centerTimelineId = center.UnitData.data.OpeningTimeLine
	end

	if self.GP.UI.DlgUICenterSkill.UIRootObject then
		self.GP.UI.DlgUICenterSkill:Open()
	end

	if centerTimelineId ~= 0 then
		if self.GP.FightMode == EnumFight.BattleType.BOSS then
			self.GP.TimeLine:PlayCenterOpeningBossLive(centerTimelineId, SceneMgr.GetCurrentScene().GP.Team.PlayerTeam, function()
				self:OpeningEnd()
			end)
		else
			Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIFirstHandTip", true, center.Camp)
			self.GP.TimeLine:PlayCenterOpening(centerTimelineId, center, function()
				self:OpeningEnd()
			end)
		end
	else
		local timeLineId = self.GP.StageData:GetDataByKey("Opening")

		if self.GP.FightMode == EnumFight.BattleType.BOSS then
			self.GP.TimeLine:PlayCenterOpeningBossLive(timeLineId, SceneMgr.GetCurrentScene().GP.Team.PlayerTeam, function()
				self:OpeningEnd()
			end)
		else
			self.GP.TimeLine:PlayCenterOpening(timeLineId, center, function()
				self:OpeningEnd()
			end)
		end
	end
end

function StageNewWave:OpeningEnd()
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIFirstHandTip", false)

	local isBoss = false

	for i, unit in ipairs(self.GP.Team.EnemyTeam) do
		isBoss = unit.IsBoss
	end

	SceneMgr.GetCurrentScene():CheckMainVirtualCamera(isBoss)

	if self.GP.PVPMode == true then
		self.GP.CameraUtil:EnablePVPCamear(true)
	end

	self:Leave()
end

function StageNewWave:Leave()
	self.GP.GameMsg:ExcuteEnd()
end
