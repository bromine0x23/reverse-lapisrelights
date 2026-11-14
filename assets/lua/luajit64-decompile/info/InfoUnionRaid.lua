-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoUnionRaid.lua

local unionRaidData = require("luaData/ClubMirror")
local raidEventData = require("luaData/ClubMirrorEvent")
local InfoTeamRaid = require("Info/InfoTeamRaid")
local InfoTeamBossRaid = require("Info/InfoTeamBossRaid")

eRaidType = {
	Common = 0,
	Boss = 1
}
InfoRaidEvent = class("InfoRaidEvent")
eRaidEventType = {
	Treasure = 4,
	Buff = 5,
	Restore = 2,
	Battle = 1,
	Relive = 3
}
eEventSpinePath = {
	"UISpine/UI_Club/UI_Raid_Event/Door3/BG_Maze_Door_03",
	"UISpine/UI_Club/UI_Raid_Event/Door1/BG_Maze_Door_01",
	"UISpine/UI_Club/UI_Raid_Event/Door1/BG_Maze_Door_01",
	"UISpine/UI_Club/UI_Raid_Event/Door4/BG_Maze_Door_04",
	"UISpine/UI_Club/UI_Raid_Event/Door5/BG_Maze_Door_05"
}

function InfoRaidEvent:ctor(id)
	self.id = id
	self.data = raidEventData[id]

	if self.data == nil then
		PrintWithColor("RaidEventId [%d] not exist", "yellow", id)
	end

	self.state = false
	self.value = 0
	self.result = {}
end

function InfoRaidEvent:SetData(...)
	local eventValue, eventState, eventParams = ...

	if eventValue == nil and eventParams == nil then
		return
	end

	if eventState == nil then
		eventState = false
	end

	if self.data.Type == eRaidEventType.Battle then
		self.result = {
			eventValue
		}
	elseif self.data.Type == eRaidEventType.Buff then
		for k, v in ipairs(eventParams or {}) do
			self.result[k] = v
		end
	elseif self.data.Type == eRaidEventType.Restore or self.data.Type == eRaidEventType.Relive then
		for k, v in ipairs(eventParams or {}) do
			self.result[k] = v
		end

		self.value = eventValue
	end

	self.state = eventState
end

function InfoRaidEvent:GetAddRate(idx)
	return self.data.AddPoint[idx or 1] or 0
end

function InfoRaidEvent:GetAddContribution()
	return self.data.Contribution or 0
end

InfoUnionRaid = class("InfoUnionRaid", InfoBase)

function InfoUnionRaid:ctor(id)
	self.id = id
	self.data = unionRaidData[id]
	self.progress = self.data.Type == eRaidType.Common and 0 or 0
	self.isReceived = false
	self.events = {}
	self.event = nil
	self.eventRound = 0
	self.listAwardRecord = {}
	self.listBuffRecord = {}
	self.battleSum = 0
	self.eventRoundNum = 3
	self.isPlayedPassAnim = false
end

function InfoUnionRaid:SetData(pb)
	if self.data.Type == eRaidType.Common then
		self.progress = tonumber(pb.progress)
		self.eventRound = pb.round

		self:ResetSelEvent(pb)
		self:ResetBuffRecord(pb.Buff)

		self.battleSum = pb.battleTimes

		if self.event and self.event.data.Type == eRaidEventType.Battle and not self.event.state then
			self.battleSum = self.battleSum - 1
		end

		if self.battleSum >= self.data.BattleRound then
			self.isPlayedPassAnim = true
		end
	else
		self.battleSum = pb.battleTimes
		self.progress = tonumber(pb.progress)
	end

	self.isReceived = pb.isAward
end

function InfoUnionRaid:ClearEvents()
	self.events = {}
end

function InfoUnionRaid:ResetEvents(pbeventids)
	self:ClearEvents()

	for _, id in ipairs(pbeventids or {}) do
		local event = InfoRaidEvent(id)

		if event.data ~= nil then
			table.insert(self.events, event)
		end
	end
end

function InfoUnionRaid:ClearEvent()
	self.event = nil
end

function InfoUnionRaid:ResetSelEvent(pbevent)
	self:ClearEvent()

	if pbevent ~= nil and pbevent.eventId ~= nil and pbevent.eventId ~= 0 then
		local event = InfoRaidEvent(pbevent.eventId)

		if event.data ~= nil then
			event:SetData(pbevent.eventValue, pbevent.eventFinish, pbevent.eventParams)
		end

		self.event = event
	end
end

function InfoUnionRaid:ResetWeeklyData()
	return
end

function InfoUnionRaid:ResetDailyData()
	if self.data.Type == eRaidType.Common then
		self.event = nil
		self.events = {}
		self.battleSum = 0
		self.eventRound = 0
		self.listBuffRecord = {}
		self.listAwardRecord = {}
		self.isPlayedPassAnim = false
	end
end

function InfoUnionRaid:FinishEvent()
	local addRate = 0

	if self.event.data.Type == eRaidEventType.Battle then
		addRate = self.event:GetAddRate(self.battleSum)
	else
		addRate = self.event:GetAddRate()
	end

	self:ChangeProgress(addRate)

	self.event.state = true
end

function InfoUnionRaid:RandomEvent()
	local pbeventids = self.data.RoundEvent[self.eventRound + 1]

	self:ResetEvents(pbeventids)
end

function InfoUnionRaid:IsSelEvent()
	return self.event ~= nil and not self.event.state
end

function InfoUnionRaid:IsToBeSelEvent()
	return table.getn(self.events) > 0 and (self.event == nil or self.event.state)
end

function InfoUnionRaid:SetProgress(vRate)
	self.progress = vRate or self.progress
end

function InfoUnionRaid:ChangeProgress(vAddRate)
	self.progress = self.progress + vAddRate
	self.progress = self.progress > self.data.FinishPoint and self.data.FinishPoint or self.progress
end

function InfoUnionRaid:ChangeBattleTimes()
	if self.event.data.Type == eRaidEventType.Battle then
		self.battleSum = self.battleSum + 1
	end
end

function InfoUnionRaid:IsBattlePass()
	return self.battleSum >= self.data.BattleRound
end

function InfoUnionRaid:ChangeEventRound()
	self.eventRound = self.eventRound + 1
end

function InfoUnionRaid:IsEventRoundEnough()
	return self.eventRound < self.data.Round
end

function InfoUnionRaid:ChangeReceState(vBool)
	if vBool == nil then
		vBool = false
	end

	self.isReceived = vBool
end

function InfoUnionRaid:IsReceived()
	return self.isReceived
end

function InfoUnionRaid:IsFinished()
	if self.data.Type == eRaidType.Common then
		return self.progress >= self.data.FinishPoint
	else
		return self.progress == 0
	end
end

function InfoUnionRaid:ResetBuffRecord(pbbuffids)
	self.listBuffRecord = {}

	for _, buffId in ipairs(pbbuffids or {}) do
		self:AddBuff(buffId)
	end
end

function InfoUnionRaid:AddBuff(buffId)
	local infoTalent = InfoTalent(buffId)

	if infoTalent.data ~= nil then
		infoTalent:SetData({
			level = 1,
			id = buffId
		})
		table.insert(self.listBuffRecord, infoTalent)
	end
end

function InfoUnionRaid:ResetAwardRecord(pbAssets)
	self.listAwardRecord = {}

	for _, v in ipairs(pbAssets or {}) do
		local id = v.awards[1] or 501
		local num = v.awards[2] or 0
		local info = ItemManager:GetValueItem(id, num)

		if info ~= nil then
			table.insert(self.listAwardRecord, info)
		end
	end
end

function InfoUnionRaid:GetBattleEventIdx()
	return self.battleSum + 1
end

UnionRaidMgr = {}
UnionRaidMgr.dictRaid = UnionRaidMgr.dictRaid or Record()

local raidOpenTime = 0
local lastRefreshTime = 0
local contributionValue = 0
local contributionAwardRecord = {}
local canUseBuffToday = {}
local IsSetData = false

UnionRaidMgr.commRaidCount = 0
UnionRaidMgr.LastRequestTime = 0

local curCommPlayNum = 0

UnionRaidMgr.maxCommPlayNum = GetConfigArgInt("ClubMirrorDailyRound")
UnionRaidMgr.maxBossPlayNum = GetConfigArgInt("ClubMirrorBossWeekPlay")
UnionRaidMgr.beingCommRaid = nil
UnionRaidMgr.ShowRaidRateUp = false
UnionRaidMgr.IsPlayedPassAnim = false
UnionRaidMgr.RaidBeginTime = 0

local isInited = false

function UnionRaidMgr.InitRaid()
	if isInited then
		return
	end

	isInited = true
	UnionRaidMgr.listCommRaid = {}
	UnionRaidMgr.listBossRaid = {}

	for _, raidData in pairsByKeys(unionRaidData) do
		local infoUnionRaid = UnionRaidMgr:GetRaid(raidData.ID)

		if infoUnionRaid ~= nil then
			if infoUnionRaid.data.Type == eRaidType.Common then
				table.insert(UnionRaidMgr.listCommRaid, infoUnionRaid)
			elseif infoUnionRaid.data.Type == eRaidType.Boss then
				table.insert(UnionRaidMgr.listBossRaid, infoUnionRaid)
			end
		end
	end

	UnionRaidMgr.commRaidCount = #UnionRaidMgr.listCommRaid
end

function UnionRaidMgr:GetRaid(id)
	local ret = self.dictRaid:GetValue(id)

	if not ret then
		ret = InfoUnionRaid(id)

		self.dictRaid:Set(id, ret)
	end

	if ret.data == nil then
		PrintWithColor("RaidId [%d] is not exist!", "yellow", id)
	end

	return ret
end

function UnionRaidMgr:SetData(pb)
	if pb == nil then
		return
	end

	lastRefreshTime = tonumber(pb.weekTime)
	curCommPlayNum = pb.bout
	IsSetData = true
	contributionValue = pb.contribution
	contributionAwardRecord = pb.contributionAward
	canUseBuffToday = {}

	for k, id in ipairs(pb.buff or {}) do
		local buff = InfoTalent(id)

		buff:SetData({
			level = 1,
			id = buffId
		})
		table.insert(canUseBuffToday, buff)
	end

	InfoTeamRaid:SetData(pb.mirrorTeam)
	InfoTeamBossRaid:SetData(pb.bossTeam)

	if pb.lastMirror and pb.lastMirror ~= 0 then
		self:SetBeingCommRaid(pb.lastMirror)
	end

	if pb.mirrorInfo then
		for _, pbRaid in ipairs(pb.mirrorInfo) do
			local infoUnionRaid = self:GetRaid(pbRaid.mirrorId)

			if infoUnionRaid then
				infoUnionRaid:SetData(pbRaid)
			end
		end
	end
end

function UnionRaidMgr:ResetData(refType)
	for _, infoUnionRaid in pairs(self.dictRaid:GetValues()) do
		if refType == eRefreshType.Weekly then
			infoUnionRaid:ResetWeeklyData()
		elseif refType == eRefreshType.Daily then
			infoUnionRaid:ResetDailyData()
		end
	end

	if refType == eRefreshType.Weekly then
		contributionValue = 0
		contributionAwardRecord = {}
	elseif refType == eRefreshType.Daily then
		curCommPlayNum = 0
		canUseBuffToday = {}
	end
end

function UnionRaidMgr:SetBeingCommRaid(raidId)
	self.beingCommRaid = self:GetRaid(raidId)
end

function UnionRaidMgr.ChangePlayNum(raidType, raidId)
	if raidType == eRaidType.Common then
		curCommPlayNum = curCommPlayNum + 1
	elseif raidType == eRaidType.Boss then
		local raid = UnionRaidMgr:GetRaid(raidId)

		if raid then
			raid.battleSum = raid.battleSum + 1
		end
	end
end

function UnionRaidMgr.GetPlayNum(raidType, raidId)
	if raidType == eRaidType.Common then
		return curCommPlayNum or 0
	elseif raidType == eRaidType.Boss then
		local raid = UnionRaidMgr:GetRaid(raidId)

		return raid and raid.battleSum or 0
	end

	return 0
end

function UnionRaidMgr:IsPlayNumEnough(raidType, raidId)
	if raidType == eRaidType.Common then
		return curCommPlayNum < self.maxCommPlayNum
	elseif raidType == eRaidType.Boss then
		local playNum = self.GetPlayNum(eRaidType.Boss, raidId)

		return playNum < self.maxBossPlayNum
	end

	return false
end

function UnionRaidMgr.ChangeContributionValue(vValue)
	contributionValue = contributionValue + vValue
end

function UnionRaidMgr.GetContributionValue()
	return contributionValue or 0
end

function UnionRaidMgr.IsRecedContributionIdx(idx)
	return table.contains(contributionAwardRecord, idx)
end

function UnionRaidMgr.AddContributionRecord(idx)
	if not table.contains(contributionAwardRecord, idx) then
		table.insert(contributionAwardRecord, idx)
	end
end

function UnionRaidMgr:FinishEvent()
	if self.beingCommRaid ~= nil and self.beingCommRaid.event ~= nil and not self.beingCommRaid.event.state then
		UnionRaidMgr.ChangeContributionValue(self.beingCommRaid.event:GetAddContribution())
		self.beingCommRaid:FinishEvent()
	end
end

function UnionRaidMgr:IsBossRaidOpen()
	if self.listCommRaid == nil then
		return false
	end

	for _, raid in pairs(self.listCommRaid) do
		if raid ~= nil and not raid:IsFinished() then
			return false
		end
	end

	return true
end

function UnionRaidMgr:IsBossRaidFinish()
	if self.listBossRaid == nil then
		return false
	end

	for _, raid in ipairs(self.listBossRaid) do
		if raid ~= nil and not raid:IsFinished() then
			return false, raid
		end
	end

	return true
end

function UnionRaidMgr.IsBossOpenOfFloor(idx)
	if idx == 1 then
		return UnionRaidMgr:IsBossRaidOpen(), _("Desc_Open_Boss_By_Complete_Comm")
	else
		return UnionRaidMgr.listBossRaid[idx - 1]:IsFinished(), string.format(_("Desc_Open_Boss_By_Complete_Last"), idx - 1, idx)
	end

	return false
end

function UnionRaidMgr:GetBossRaidsOfNotReceiveAward()
	if self.listBossRaid == nil then
		return {}
	end

	local list = {}

	for _, raid in ipairs(self.listBossRaid) do
		if raid:IsFinished() and not raid:IsReceived() then
			table.insert(list, raid)
		end
	end

	return list
end

function UnionRaidMgr.AddCanUseBuff(buffId)
	if UnionRaidMgr.HasSameBuff(buffId) then
		return
	end

	local infoTalent = InfoTalent(buffId)

	if infoTalent.data ~= nil then
		infoTalent:SetData({
			level = 1,
			id = buffId
		})
		table.insert(canUseBuffToday, infoTalent)
	end
end

function UnionRaidMgr.GetCanUseBuff()
	return canUseBuffToday
end

function UnionRaidMgr.GetBuffByType(_type)
	local t = {}

	for k, buff in ipairs(canUseBuffToday) do
		if buff.data.Type == _type then
			local skill = {
				skillId = buff.id,
				skillLevel = buff.pb.level or 1
			}

			table.insert(t, skill)
		end
	end

	return t
end

function UnionRaidMgr.HasSameBuff(buffId)
	for k, buff in ipairs(canUseBuffToday) do
		if buff.data.ID == buffId then
			return true
		end
	end

	return false
end

function UnionRaidMgr.GetFirstStageId(raidId)
	for _, v in pairsByKeys(raidEventData) do
		if raidId == v.MirrorId and v.Type == 1 and v.TypeValue[1] then
			return v.TypeValue[1][1]
		end
	end

	return nil
end

function UnionRaidMgr:GetBossRaidByStageId(stageId)
	for _, v in ipairs(self.listBossRaid) do
		if v.data.BossStage == stageId then
			return v
		end
	end

	return nil
end

function UnionRaidMgr:GetBeingBossRaid()
	for _, raid in ipairs(self.listBossRaid) do
		if not raid:IsFinished() then
			return raid
		end
	end

	return nil
end

function UnionRaidMgr.SetOpenTime(time)
	raidOpenTime = tonumber(time or 0)
end

function UnionRaidMgr.GetRaidOpenTime()
	return os.date("%Y.%m.%d", raidOpenTime)
end

function UnionRaidMgr.IsRaidOpen()
	return NetData:GetCurServerTime() / DateUtil.MillsPerSecond >= raidOpenTime
end

function UnionRaidMgr.SetLastRefreshTime(time)
	lastRefreshTime = time
end

function UnionRaidMgr.GetNextRefreshTime()
	local dis = GetConfigArgInt("ClubMirrorRefreshTime") * DateUtil.SecsPerDay

	return lastRefreshTime + dis
end

function UnionRaidMgr.IsSetData()
	return IsSetData
end
