-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/TimeLine/LiveUtility.lua

require("Util/TimeLineBase")

LiveUtility = class("LiveUtility")

function LiveUtility:ctor(GP, timeLine)
	self.GP = GP
	self.livePlayer = nil
	self.timeLineBase = timeLine
	self.LiveSoundBank = self.GP.StageData:GetDataByKey("LiveSoundBank")
	self.LiveSoundEvent = self.GP.StageData:GetDataByKey("LiveSoundEvent")
	self.isStart = false
	self.lyricRootObj = nil
end

function LiveUtility:Purge(...)
	BattleConfig.UnLoadSoundBank(self.LiveSoundBank)
	self.timeLineBase:Purge()

	self.livePlayer = nil
	self.sceneLight = nil
	self.liveLights = nil
	self.lyricRootObj = nil
end

function LiveUtility:Create(gameObject, timeline)
	self.livePlayer = GOUtil.AddMissingComponent(gameObject, "LiveUtility")

	self.livePlayer:Init(self.LiveSoundEvent, timeline)

	local root = self.timeLineBase:GetGameObject().transform

	for i = 1, root.childCount do
		local child = root:GetChild(i - 1)

		if string.find(child.gameObject.name, "Lyric_") then
			self.lyricRootObj = child.gameObject
		end
	end

	self:MuteLyricTrack(true)
end

function LiveUtility:SetLights(sceneLight, liveLights)
	self.sceneLight = sceneLight
	self.liveLights = liveLights
end

function LiveUtility:ActiveLiveLight(val)
	self.sceneLight.enabled = not val

	for _, light in ipairs(self.liveLights) do
		light.enabled = val
	end
end

function LiveUtility:MuteLyricTrack(isMute)
	if self.lyricRootObj then
		GOUtil.SetActive(self.lyricRootObj, not isMute)
	end
end

function LiveUtility:Play()
	if not self.livePlayer then
		return
	end

	local actors = {}

	for i, unit in ipairs(self.GP.Team.PlayerTeam) do
		table.insert(actors, unit.Actor)
		unit:SetActive(true)
		unit:GazeAtCamera(true)
		unit:EnableAnimatorController(false)
	end

	self.GP.Team:SetActive(EnumFight.Camp.ENEMY, false)
	self.timeLineBase:Rebind()
	self.livePlayer:PlayWithLipSync(actors)
	GOUtil.SetActive(self.timeLineBase:GetGameObject(), true)
	self:ActiveLiveLight(true)
	Event.Instance:Fire("EVENT_SWITCH_SCENE", EnumFight.SceneObj.Main)

	self.isStart = true

	BattleConfig.Delay(BattleConfig.Guide.LiveStart, function()
		InstructionMgr:TriggerWait("LiveStart")
	end)
	BattleConfig.TimeScaleActive(false, BattleConfig.Speed.One)
end

function LiveUtility:PauseLive()
	if not self.livePlayer then
		return
	end

	self.livePlayer:PauseLive()
	self:ActiveLiveLight(false)
	GOUtil.SetActive(self.timeLineBase:GetGameObject(), false)
	Event.Instance:Fire("EVENT_SWITCH_SCENE", EnumFight.SceneObj.Session)
	BattleConfig.TimeScaleActive(true)
end

function LiveUtility:ResumeLive()
	if self.isStart == false then
		self:Play()

		return
	end

	if not self.livePlayer then
		return
	end

	self.livePlayer:ResumeLive()
	GOUtil.SetActive(self.timeLineBase:GetGameObject(), true)
	self:ActiveLiveLight(true)
	Event.Instance:Fire("EVENT_SWITCH_SCENE", EnumFight.SceneObj.Main)

	for i, unit in ipairs(self.GP.Team.PlayerTeam) do
		unit:EnableAnimatorController(false)
		unit:SetActive(true)
		unit:GazeAtCamera(true)
	end

	self.GP.Team:SetActive(EnumFight.Camp.ENEMY, false)
	BattleConfig.TimeScaleActive(false, BattleConfig.Speed.One)
end

function LiveUtility:PauseMusic()
	if not self.livePlayer then
		return
	end

	self.livePlayer:PauseMusic()
end

function LiveUtility:ResumeMusic()
	if not self.livePlayer then
		return
	end

	self.livePlayer:ResumeMusic()
end
