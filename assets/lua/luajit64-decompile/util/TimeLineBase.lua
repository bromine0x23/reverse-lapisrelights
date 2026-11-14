-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/TimeLineBase.lua

local CONST_FLASH_ID = 2

TimeLineBase = class("TimeLineBase")

local TimelineData = require("luaData/TimelineData")

function TimeLineBase:ctor(timelineId, directorWrapMode)
	self.Timeline = nil
	self.TimelineId = timelineId

	if not TimelineData[timelineId] then
		return
	end

	self.PrefabePath = TimelineData[timelineId].Path
	self.data = TimelineData[timelineId]

	if not self.data then
		print("<color=red> ERROR , timelineId没有配置！！" .. tostring(timelineId) .. "</color>")
	end

	if directorWrapMode then
		self.DirectorWrapMode = directorWrapMode
	else
		self.DirectorWrapMode = UnityEngine.Playables.DirectorWrapMode.None
	end
end

function TimeLineBase:Cache()
	ResourceMgr.SubmitCache(self.PrefabePath, self, "DirectorAsset")
end

function TimeLineBase:Purge()
	if self.timeLine == nil then
		return
	end

	local SoundBank = TimelineData[self.TimelineId].SoundBank

	if SoundBank ~= "" then
		SoundMgr.UnloadBank(SoundBank)
	end

	if self.DirectorAsset then
		ResourceMgr.Unload(self.DirectorAsset)

		self.DirectorAsset = nil
	end

	self:Destroy()
end

function TimeLineBase:Destroy()
	EventListenerMgr.RemovePlayableDirectorListener(self:GetGameObject(), self.OnStopped, self, ePlayableDirectorEvent.OnStopped)
	EventListenerMgr.RemovePlayableDirectorListener(self:GetGameObject(), self.OnEvent, self, ePlayableDirectorEvent.OnEvent)
	EventListenerMgr.RemoveTimelineMarkerListener(self:GetGameObject(), self.OnUI, self, "UI")
	EventListenerMgr.RemoveTimelineMarkerListener(self:GetGameObject(), self.OnCloseUI, self, "CLOSE_UI")
	EventListenerMgr.RemoveTimelineMarkerListener(self:GetGameObject(), self.OnSound, self, "SOUND")
	EventListenerMgr.RemoveTimelineMarkerListener(self:GetGameObject(), self.OnSoundBank, self, "SOUNDBANK")
	Object.Destroy(self:GetGameObject())

	self.timeLine = nil
end

function TimeLineBase:CreateAsync(callback)
	if self.DirectorAsset then
		self:OnAsyncPrecacheActorFinish()
		callback()
	else
		ResourceMgr.BeginSubmit(function()
			self:OnAsyncPrecacheActorFinish()
			callback()
		end)
		self:Cache()
		ResourceMgr.EndSubmit()
	end
end

function TimeLineBase:OnAsyncPrecacheActorFinish()
	if self.timeLine then
		return
	end

	self:Create()
	self:Rebind()
end

function TimeLineBase:CreateImmediately()
	if self.timeLine then
		return
	end

	self.DirectorAsset = ResourceMgr.LoadSync(self.PrefabePath, GameObject)

	self:Create()
	self:Rebind()
end

function TimeLineBase:Create(directorUpdateMode, directorWrapMode)
	if not self.DirectorAsset then
		print("timeline 资源与路径不匹配， 查看配置表   path = " .. self.PrefabePath)

		return
	end

	if directorUpdateMode and directorWrapMode then
		self.timeLine = Oz.Timeline.Timeline(self.DirectorAsset)

		self.timeLine:Create(directorUpdateMode, directorWrapMode, 0)
	else
		self.timeLine = Oz.Timeline.Timeline(self.DirectorAsset)

		self.timeLine:Create(UnityEngine.Playables.DirectorUpdateMode.GameTime, self.DirectorWrapMode, 0)
	end

	self.OnCompleteCallBacks = {}
	self.OnEventCallBacks = {}
	self.OnActions = {}

	EventListenerMgr.AddPlayableDirectorListener(self.timeLine.gameObject, self.OnStopped, self, ePlayableDirectorEvent.OnStopped)
	EventListenerMgr.AddPlayableDirectorListener(self.timeLine.gameObject, self.OnEvent, self, ePlayableDirectorEvent.OnEvent)
	EventListenerMgr.AddTimelineMarkerListener(self:GetGameObject(), self.OnUI, self, "UI")
	EventListenerMgr.AddTimelineMarkerListener(self:GetGameObject(), self.OnCloseUI, self, "CLOSE_UI")
	EventListenerMgr.AddTimelineMarkerListener(self:GetGameObject(), self.OnSound, self, "SOUND")
	EventListenerMgr.AddTimelineMarkerListener(self:GetGameObject(), self.OnSoundBank, self, "SOUNDBANK")

	self.Rebinder = GOUtil.GetComponent(self:GetGameObject(), "SceneTimelineRebinder")

	if self.timeLine:PlayableAssetVaild() == false then
		print("timeline ERROR, " .. self.PrefabePath)
	end

	self.timeLine:MuteTrackByName("Sound Track", true)
	self:SetActive(false)

	local camera = GOUtil.GetComponentInChildren(self.timeLine.gameObject, "Camera")

	if camera then
		camera.tag = "MainCamera"
	end
end

function TimeLineBase:Rebind()
	if self.Rebinder then
		self.Rebinder:Rebind()
	end
end

function TimeLineBase:RegisteAction(key, action)
	self.OnActions[key] = action
end

function TimeLineBase:OnUI(playableDirector, EventData)
	print(" ---------OnUI---------- " .. EventData.StringValue)
	Event.Instance:Fire("EVENT_OPEN_DLG", EventData.StringValue)
end

function TimeLineBase:OnCloseUI(playableDirector, EventData)
	Event.Instance:Fire("EVENT_OPEN_DLG", EventData.StringValue, false)
end

function TimeLineBase:OnSound(playableDirector, EventData)
	Event.Instance:Fire("EVENT_PLAY_SOUND", EventData.StringValue)
end

function TimeLineBase:OnSoundBank(playableDirector, EventData)
	Event.Instance:Fire("EVENT_BANK_SOUND", EventData.StringValue)
end

function TimeLineBase:_OnAction(playableDirector, PlayableClipActionEvent)
	if PlayableClipActionEvent.Name == "EVENT_OPEN_DLG" then
		Event.Instance:Fire("EVENT_OPEN_DLG", PlayableClipActionEvent.stringParameter)
	elseif PlayableClipActionEvent.Name == "EVENT_DANCE_FINGER" then
		Event.Instance:Fire("EVENT_DANCE_FINGER", PlayableClipActionEvent.stringParameter)
	elseif PlayableClipActionEvent.Name == "EVENT_ACTION" then
		local acton = self.OnActions[PlayableClipActionEvent.stringParameter]

		if acton then
			acton()

			self.OnActions[PlayableClipActionEvent.stringParameter] = nil
		end
	end
end

function TimeLineBase:OnMotion(playableDirector, PlayableClipMotionEvent)
	if PlayableClipMotionEvent.Name == "EVENT_ENEMY_MOTION" then
		Event.Instance:Fire("EVENT_ENEMY_MOTION", PlayableClipMotionEvent.StateName)
	end
end

function TimeLineBase:OnSound(playableDirector, PlayableClipSoundEvent)
	if PlayableClipSoundEvent.Name == "EVENT_PLAY_SOUND" then
		Event.Instance:Fire("EVENT_PLAY_SOUND", PlayableClipSoundEvent.EventName)
	elseif PlayableClipSoundEvent.Name == "EVENT_BANK_SOUND" then
		Event.Instance:Fire("EVENT_BANK_SOUND", PlayableClipSoundEvent.BankName)
	end
end

function TimeLineBase:SetGenericBinding(key, value)
	return
end

function TimeLineBase:Play(onComplete, OnEvent, aniCtrlIndex)
	if self.timeLine == nil then
		print("timeline is null!!! 检查timelineData配置表" .. self.TimelineId)

		if onComplete then
			onComplete()
		end

		return
	end

	if self:GetState() == UnityEngine.Playables.PlayState.Playing then
		return
	end

	table.insert(self.OnCompleteCallBacks, onComplete)
	table.insert(self.OnEventCallBacks, OnEvent)

	if self.timeLine ~= nil then
		self:SetActive(true)

		if self.TimelineId ~= CONST_FLASH_ID then
			local disableTimeScale = TimelineData[self.TimelineId].DisableTimeScale

			if disableTimeScale and disableTimeScale == 1 then
				BattleConfig.TimeScaleActive(false, BattleConfig.Speed.One)
			end
		end

		self.timeLine:Play()
		self.timeLine:Evaluate()
		self:DoPlayConfigAction()
	end
end

function TimeLineBase:Stop()
	if self.timeLine then
		self.timeLine:Stop()
	end
end

function TimeLineBase:Skip()
	if self.timeLine then
		self.timeLine:Skip(function()
			self:OnStopped()
		end)
	end
end

function TimeLineBase:OnStopped(playableDirector)
	if self.TimelineId ~= CONST_FLASH_ID then
		local disableTimeScale = TimelineData[self.TimelineId].DisableTimeScale

		if disableTimeScale and disableTimeScale == 1 then
			BattleConfig.TimeScaleActive(true)
		end
	end

	self:DoEndConfigAction()
	self:SetActive(false)

	local onComplete = self.OnCompleteCallBacks[#self.OnCompleteCallBacks]

	if onComplete then
		onComplete()
		table.remove(self.OnCompleteCallBacks, 1)
	end
end

function TimeLineBase:OnEvent(playableDirector)
	local onEvent = self.OnEventCallBacks[#self.OnEventCallBacks]

	if onEvent then
		onEvent()
		table.remove(self.OnEventCallBacks, 1)
	end
end

function TimeLineBase:SetActive(val)
	self.timeLine.gameObject:SetActive(val)
end

function TimeLineBase:ActiveSelf()
	if IsNil(self.timeLine) == false and IsNil(self.timeLine.gameObject) == false then
		return GOUtil.IsActiveSelf(self.timeLine.gameObject)
	end

	return false
end

function TimeLineBase:GetState()
	return self.timeLine.state
end

function TimeLineBase:GetGameObject()
	return self.timeLine.gameObject
end

function TimeLineBase:GetDirector()
	return self.timeLine.playableDirector
end

function TimeLineBase:GetDuration()
	return self.timeLine.duration
end

function TimeLineBase:DoPlayConfigAction()
	local disableSkip = TimelineData[self.TimelineId].DisableSkip

	if disableSkip ~= 1 then
		Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUISkipTimeline", true, self)
	end

	local SoundBank = TimelineData[self.TimelineId].SoundBank

	if SoundBank ~= "" then
		SoundMgr.LoadBank(SoundBank, false, false)
	end

	local SoundEvent = TimelineData[self.TimelineId].SoundEvent

	if SoundEvent ~= "" then
		SoundMgr.PostEvent(SoundEvent, UIMgr.UICamera.gameObject)
	end
end

function TimeLineBase:DoEndConfigAction()
	local disableSkip = TimelineData[self.TimelineId].DisableSkip

	if disableSkip ~= 1 then
		Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUISkipTimeline", false, self)
		Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBossAppear", false)
		Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUICenterSkill", false)
	end

	local SoundEvent = TimelineData[self.TimelineId].SoundEvent

	if SoundEvent ~= "" then
		SoundMgr.Stop(SoundEvent)
	end
end

function TimeLineBase:MuteTrackByName(trackName, isMute)
	self.timeLine:MuteTrackByName(trackName, isMute)
end
