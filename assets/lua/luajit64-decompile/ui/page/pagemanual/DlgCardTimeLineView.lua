-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageManual/DlgCardTimeLineView.lua

local _BattleSkillData = require("GamePerform.Object.InfoBattleSkillData")

require("GameLogic/Fight/EnumFight")
require("Util/TimeLineBase")
require("GamePerform.Requires")

local TimelineData = require("luaData/TimelineData")

DlgCardTimeLineView = class("DlgCardTimeLineView", UIPanel)

function DlgCardTimeLineView.TimeScale(scale)
	return
end

function DlgCardTimeLineView.TimeScaleActive(val)
	return
end

function DlgCardTimeLineView:ctor()
	self.UIPrefabPath = "UI/PageManual/DlgCardTimeLineView"
	self.TimeLine = TimeLineUtility(self)
	DlgCardTimeLineView.TimeScale_temp = BattleConfig.TimeScale
	DlgCardTimeLineView.TimeScaleActive_temp = BattleConfig.TimeScaleActive
	BattleConfig.TimeScale = DlgCardTimeLineView.TimeScale
	BattleConfig.TimeScaleActive = DlgCardTimeLineView.TimeScaleActive
end

function DlgCardTimeLineView:PreLoad()
	self:LoadResAsync("Actors/Settings/CharacterScaleSettings/SCL_Normal", "ActorScaleSetting", ScaleSettings)
	self:LoadResAsync("Actors/Settings/CharacterScaleSettings/SCL_Fight_LoLi", "ActorScaleSettingLoli", ScaleSettings)
end

function DlgCardTimeLineView:OnRegisterEvent()
	Event.Instance:Add("EVENT_OPEN_DLG", self.OnOpenDlg, self)
	self:AddClick(self.Button, self.OnClickSkip)
end

function DlgCardTimeLineView:OnUnRegisterEvent()
	Event.Instance:Remove("EVENT_OPEN_DLG", self.OnOpenDlg, self)
	self:RemoveClick(self.Button, self.OnClickSkip)
end

function DlgCardTimeLineView:Purge()
	self.base.Purge(self)
	self:ClearActor()
	ResourceMgr.Unload(self.ActorScaleSetting)
	ResourceMgr.Unload(self.ActorScaleSettingLoli)
	self.TimeLine:Purge()

	self.infoRole = nil
	BattleConfig.TimeScale = DlgCardTimeLineView.TimeScale_temp
	BattleConfig.TimeScaleActive = DlgCardTimeLineView.TimeScaleActive_temp

	if self.beforeBank ~= nil then
		SoundMgr.UnloadBank(self.beforeBank)
	end
end

function DlgCardTimeLineView:OnEnter(params)
	self.unitActor = UnitActor(self)
	self.endCallback = params.endCallback
	self.beginCallback = params.beginCallback

	self.UIRootObject:SetActive(false)

	self.Button = self:GetChildGameObject("Button")
end

function DlgCardTimeLineView:Play(infoRole, skillId)
	self.UIRootObject:SetActive(true)
	self.Button:SetActive(false)

	if self.infoBattleSkill and self.infoBattleSkill.TimeLineID and self.infoBattleSkill.TimeLineID ~= 0 then
		self.TimeLine:DeleteTimeLine(self.infoBattleSkill.TimeLineID)
	end

	if self.skillId ~= skillId then
		-- block empty
	else
		local SoundBank = TimelineData[self.infoBattleSkill.TimeLineID].SoundBank

		if SoundBank ~= "" then
			SoundMgr.UnloadBank(SoundBank)
		end
	end

	self.skillId = skillId
	self.infoRole = infoRole

	if self.beforeBank ~= nil then
		SoundMgr.UnloadBank(self.beforeBank)
	end

	self.beforeBank = self.infoRole.data.VocalBank

	SoundMgr.LoadBank(self.infoRole.data.VocalBank, false, false)
	self:LoadActor()
end

function DlgCardTimeLineView:UpdateRole(infoRole)
	self.infoRole = infoRole

	self:LoadActor()
end

function DlgCardTimeLineView:ClearActor()
	if self.actor then
		self.actor:Destroy()

		self.actor = nil
	end

	if self.actorFactory then
		self.actorFactory:Purge()

		self.actorFactory = nil
	end
end

function DlgCardTimeLineView:LoadActor()
	self:ClearActor()
	LoadingMgr.Show(eLoadingType.Repeat)

	local function OnAsyncPrecacheActorFinish()
		local actor = self.actorFactory:Build()

		self.actor = actor

		actor:Create()

		self.unitActor.Actor = self.actor
		self.unitActor.ActorRoot = self.actor.Root
		self.unitActor.ActorSkeletonRoot = self.actor.SkeletonSystem.Root
		self.unitActor.ModelGUID = ReferenceRoot.AddMissingReferenceGUID(self.unitActor.ActorSkeletonRoot, nil)
		self.unitActor.ActorGUID = ReferenceRoot.AddMissingReferenceGUID(self.unitActor.ActorRoot, nil)

		self:PlayTimeLine(self.skillId, function()
			self:ClearActor()

			self.infoRole = nil

			self.endCallback()
		end)
		LoadingMgr.Hide(eLoadingType.Repeat)
	end

	ResourceMgr.BeginSubmit(function()
		OnAsyncPrecacheActorFinish()
	end)

	local controller = ActorUtil.MotionControllerDataFilter(self.infoRole.data.ActorID, "Fight@Engagement", "None")

	self.actorFactory = ActorUtil.BuildActorFactoryByInfoRole(self.infoRole, controller)

	self.actorFactory:Cache()
	ResourceMgr.EndSubmit()
end

function DlgCardTimeLineView:PlayTimeLine(skillId, callback)
	local infoSkill = _BattleSkillData:GetAllSkillData(skillId)
	local battleSkillId = infoSkill.BattleSkillID[1]

	self.infoBattleSkill = _BattleSkillData:GetData(battleSkillId)

	local timeLineId = self.infoBattleSkill.TimeLineID

	if not timeLineId or timeLineId == 0 then
		callback()

		return
	end

	local function CreateFinishCallback()
		local _timeLine = self.TimeLine:Get(timeLineId)

		if not _timeLine then
			callback()

			return
		end

		if self.beginCallback then
			self.beginCallback()
		end

		local unit = self.unitActor
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

		unit:SetIKAnimatorController()
		self:ApplyGeneralScaleSetting(true)
		ReferenceRoot.Instance:SetDynamicName("Model 1", unit.ModelGUID)
		ReferenceRoot.Instance:SetDynamicName("Actor 1", unit.ActorGUID)
		unit:EnableAnimatorController(false)
		_timeLine:Rebind()
		self:OnUnitVocalEvent_SkillTimeline(self.infoBattleSkill, true)
		_timeLine:Play(function()
			self:OnUnitVocalEvent_SkillTimeline(self.infoBattleSkill, false)
			self:SkillTimelineEnd()
			callback()
		end)
	end

	self.TimeLine:CreateAsync(timeLineId, nil, CreateFinishCallback)
end

function DlgCardTimeLineView:OnUnitVocalEvent_SkillTimeline(skillCfg, isEnterTimeline)
	if skillCfg.SoundEvent == "" then
		return
	end

	if self.handle_skilldelay then
		TimerMgr.RemoveTimer(self.handle_skilldelay)
	end

	if isEnterTimeline == true then
		self.handle_skilldelay = BattleConfig.Delay(skillCfg.SoundDelay, function()
			self.skillVocalEvent = skillCfg.SoundEvent

			SoundMgr.PostEvent(skillCfg.SoundEvent, UIMgr.UICamera.gameObject)

			local lipComponent = GOUtil.AddMissingComponent(self.actor.Root, "ActorLipSync")
			local lipPath = skillCfg.SkillLips

			if lipPath ~= "" then
				lipComponent:Init(lipPath)
				lipComponent:Play(self.actor, skillCfg.SoundEvent)
			end
		end)
	else
		self.skillVocalEvent = nil
	end
end

function DlgCardTimeLineView:SkillTimelineEnd()
	local unit = self.unitActor

	unit:SetIKAnimatorController()
	self:ApplyGeneralScaleSetting(false)
	unit:EnableAnimatorController(true)
end

function DlgCardTimeLineView:ApplyGeneralScaleSetting(val)
	local setting

	if val == true then
		if self.actor.IsLoli == true then
			setting = self.ActorScaleSettingLoli
		else
			setting = self.ActorScaleSetting
		end
	else
		setting = self.actor.SkeletonSystem.ScaleSettings
	end

	self.actor.SkeletonSystem:SetScale(setting)
end

function DlgCardTimeLineView:OnOpenDlg(val, isOpen, curTimeline)
	if isOpen then
		self.curTimeline = curTimeline
	else
		if self.curTimeline ~= nil then
			-- block empty
		end

		self.curTimeline = nil
	end

	self.Button:SetActive(isOpen)
	self.UIRootObject:SetActive(isOpen)
end

function DlgCardTimeLineView:OnClickSkip()
	if self.curTimeline then
		if self.skillVocalEvent then
			SoundMgr.Stop(self.skillVocalEvent)
		end

		self.skillVocalEvent = nil

		self.curTimeline:Stop()
	end
end
