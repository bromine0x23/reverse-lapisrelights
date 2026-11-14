-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/SkillViewer/NpcSkill.lua

local _BattleSkillData = require("GamePerform.Object.InfoBattleSkillData")

NpcSkill = class("NpcSkill", GameHelper)
NpcSkill.Map = {}

function NpcSkill.Get(battleSkillId)
	return NpcSkill.Map[battleSkillId]
end

function NpcSkill.GetName(battleSkillId)
	return NpcSkill.Map[battleSkillId].Name
end

function NpcSkill.GetDesc(battleSkillId)
	return NpcSkill.Map[battleSkillId].Description
end

function NpcSkill.Clear()
	NpcSkill.Map = {}
end

NpcSkill.enSkillType = {
	CENTER = 3,
	PASSIVE = 2,
	ACTIVE = 1
}
NpcSkill.enPassiveSkillType = {
	UNDEFINE = 0,
	JOB = 1
}

function NpcSkill:ctor(unit, skillId, level)
	self.Vaild = true

	if not skillId or skillId == 0 then
		self.Vaild = false

		return
	end

	self.Owner = unit
	self.Level = level

	local infoSkill = _BattleSkillData:GetAllSkillData(skillId)

	if not infoSkill then
		self.Vaild = false

		return
	end

	if infoSkill.Type == EnumFight.SkillType.Passive then
		self.Vaild = false

		return
	end

	if infoSkill.Type == EnumFight.SkillType.Center then
		self.Vaild = false

		return
	end

	self.infoSkill = infoSkill

	local battleSkillId = infoSkill.BattleSkillID[1]
	local infoBattleSkill = _BattleSkillData:GetData(battleSkillId)

	if not infoBattleSkill then
		self.Vaild = false

		return
	end

	self.infoBattleSkill = infoBattleSkill
	self.Name = Lang(infoSkill.Name)
	self.Description = Lang(infoSkill.Description[self.Level])

	if infoSkill.Icon ~= "" then
		self.IconPath = BattleConfig.SkillPath .. infoSkill.Icon
	else
		self.IconPath = ""
	end

	self.BattleSkillType = infoSkill.BattleSkillType
	self.PassiveType = infoSkill.PassiveType
	self.BattleSkillId = battleSkillId
	self.Id = infoSkill.ID
	NpcSkill.Map[self.BattleSkillId] = self
	self.YellowBallStack = 0
	self.Cost = infoBattleSkill.Cost

	self:InitTimeLine()
end

function NpcSkill:Cache()
	return
end

function NpcSkill:Purge()
	local infoSkill = _BattleSkillData:GetData(self.BattleSkillId)
	local timeLineId = infoSkill.TimeLineID

	if timeLineId and timeLineId ~= 0 then
		SV.TimeLine:DeleteTimeLine(timeLineId)
	end

	self.Owner = nil
	self.Level = 1
end

function NpcSkill:_SetImage(img, path)
	UIUtil.SetImageSprite(img, path)
end

function NpcSkill:SetIcon(img)
	local path = self.IconPath

	self:_SetImage(img, path)
end

function NpcSkill:SetName(txt)
	UIUtil.SetTextString(txt, self.Name)
end

function NpcSkill:SetDesc(txt)
	local desc = SkillTip.GetDesc(self.Id, self.Level, self.YellowBallStack)

	UIUtil.SetTextString(txt, desc)
end

function NpcSkill:InitTimeLine()
	local infoSkill = _BattleSkillData:GetData(self.BattleSkillId)
	local timeLineId = infoSkill.TimeLineID

	if timeLineId and timeLineId ~= 0 then
		-- block empty
	end
end

function NpcSkill:StackPower(stack)
	self.YellowBallStack = stack
end

function NpcSkill:Cast()
	self:PlayTimeLine(function()
		self:PlaySkill()
	end)
end

function NpcSkill:PlaySkill()
	local anim = self.infoBattleSkill.AnimState

	if anim ~= "" then
		self.Owner:Play(anim)
	end

	local time = self.infoBattleSkill.TotalTime ~= -1 and self.infoBattleSkill.TotalTime or self.Owner.Actor.MotionSystem:GetAnimLength(anim)

	for i, v in ipairs(self.infoBattleSkill.CastTime) do
		BattleConfig.Delay(time * v, function()
			local effId = self.infoBattleSkill.CastFxs[i]

			BattleConfig.FxAlloc(effId, self.Owner)
		end)
	end

	if self.infoBattleSkill.CampFxTimes then
		for i, v in ipairs(self.infoBattleSkill.CampFxTimes) do
			BattleConfig.Delay(time * v, function()
				local effId = self.infoBattleSkill.CampFxs[i]
				local camp = self.infoBattleSkill.CampFxIdx[i]

				BattleConfig.CampFxAlloc(effId, camp)
			end)
		end
	end

	if self.infoBattleSkill.CameraFxTimes then
		for i, v in ipairs(self.infoBattleSkill.CameraFxTimes) do
			BattleConfig.Delay(time * v, function()
				local effId = self.infoBattleSkill.CameraFxs[i]

				BattleConfig.CameraFxAlloc(effId)
			end)
		end
	end

	local hit_f = {}
	local Hit_eff = {}

	for i, action in ipairs(self.infoBattleSkill.Custom) do
		if action.Hit_eff and action.Hit_eff[self.Level] and action.Hit_f then
			for effIdx, effId in ipairs(action.Hit_eff[self.Level]) do
				if action.Hit_f[effIdx] then
					table.insert(Hit_eff, {
						eff = effId,
						hitTime = action.Hit_f[effIdx]
					})
				end
			end
		end
	end

	for i, v in ipairs(Hit_eff) do
		BattleConfig.Delay(time * v.hitTime, function()
			local effId = v.eff
			local position, rotation, scale

			position = self.Owner.ActorRoot.transform.position + Vector3(0, 0, 6)
			rotation = self.Owner.ActorRoot.transform.rotation + Vector3(0, 180, 0)
			scale = self.Owner.ActorSkeletonRoot.transform.localScale.x

			return BattleConfig:AllocAtById(effId, position, rotation, scale)
		end)
	end
end

function NpcSkill:PlayTimeLine(callback)
	local timeLineId = self.infoBattleSkill.TimeLineID

	if not timeLineId or timeLineId == 0 then
		callback()

		return
	end

	if self.Id < 10000 then
		callback()

		return
	end

	SV.TimeLine:CreateImmediately(timeLineId)

	local _timeLine = SV.TimeLine:Get(timeLineId)

	if not _timeLine then
		callback()

		return
	end

	if self.BattleSkillType == EnumFight.SkillType.Active then
		local lipPath = self.infoBattleSkill.SkillLips

		if self.Owner.ActorLipSync and lipPath ~= "" then
			self.Owner.ActorLipSync:AddByPath(lipPath)
		end
	end

	local unit = self.Owner
	local enter_player = {
		TimeLineAnim = true,
		GazeAtCamera = false,
		PositionToZero = true,
		TakeOffWeapon = true,
		Model = true,
		ApplyScale = true,
		Light = false,
		Camera = false
	}
	local enter_enemy = {
		Light = false,
		Camera = false
	}

	if unit.UnitClass == EnumFight.Camp.PLAYER then
		unit:SetIKAnimatorController()
		unit:ApplyGeneralScaleSetting(true)
		ReferenceRoot.Instance:SetDynamicName("Model 1", unit.ModelGUID)
		ReferenceRoot.Instance:SetDynamicName("Actor 1", unit.ActorGUID)
		unit:EnterTimeLineSet()
		unit:TakeOffWeapon()
		unit:EnableAnimatorController(false)
		SceneMgr.GetCurrentScene():SetLightActive(false)
	else
		unit:SetActive(false)
	end

	_timeLine:Rebind()
	_timeLine:Play(function()
		Event.Instance:Fire("UnitVocalEvent_SkillTimeline", UnitVocal.enType.SkillTimeline, self.infoBattleSkill, false, unit)
		self:SkillTimelineEnd()
		callback()
	end)
	Event.Instance:Fire("UnitVocalEvent_SkillTimeline", UnitVocal.enType.SkillTimeline, self.infoBattleSkill, true, unit)
end

function NpcSkill:SkillTimelineEnd()
	local unit = self.Owner

	if unit.UnitClass == EnumFight.Camp.PLAYER then
		unit:SetIKAnimatorController()
		unit:ApplyGeneralScaleSetting(false)
		unit:LeaveTimeLineSet()
		unit:PutOnWeapon()
		unit:EnableAnimatorController(true)
		SceneMgr.GetCurrentScene():SetLightActive(true)
	else
		unit:SetActive(true)
	end
end
