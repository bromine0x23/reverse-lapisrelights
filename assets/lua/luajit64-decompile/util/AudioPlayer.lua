-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/AudioPlayer.lua

AudioPlayer = class("AudioPlayer")

function AudioPlayer:ctor(clipPaths)
	self.ClipPaths = clipPaths
end

function AudioPlayer:OnPlay(strType)
	self.AudioInfos = self.AudioInfos or {}
	self.AudioInfos[strType] = self.AudioInfos[strType] or {}

	self:Stop(strType)

	if self.AudioInfos[strType].Clip == nil then
		self.AudioInfos[strType].Clip = MxResMgr.Instance:LoadSyncLuaByType(self.ClipPaths[strType], "AudioClip")
	end
end

function AudioPlayer:OnPlayAsync(strType, onComplete)
	self.AudioInfos = self.AudioInfos or {}
	self.AudioInfos[strType] = self.AudioInfos[strType] or {}

	self:Stop(strType)
	MxResMgr.Instance:BeginSubmitCB(nil, function()
		self.AudioInfos[strType].BlockHandle = nil

		if onComplete ~= nil then
			onComplete()

			onComplete = nil
		end
	end)
	MxResMgr.Instance:SubmitCacheLuaByType(self.ClipPaths[strType], self.AudioInfos[strType], "Clip", "AudioClip")

	self.AudioInfos[strType].BlockHandle = MxResMgr.Instance:EndSubmit()
end

function AudioPlayer:CancelCacheBlock(strType)
	if self.AudioInfos == nil or self.AudioInfos[strType] == nil then
		return
	end

	if self.AudioInfos[strType].BlockHandle ~= nil then
		MxResMgr.Instance:CancelCacheBlock(self.AudioInfos[strType].BlockHandle)

		self.AudioInfos[strType].BlockHandle = nil
	end
end

function AudioPlayer:Play(strType, isLoop, onComplete)
	if self.ClipPaths == nil or string.isNullOrEmpty(self.ClipPaths[strType]) then
		return
	end

	self:OnPlay(strType)

	self.AudioInfos[strType].Source = MxAudioMgr.Instance:PlaySound(self.AudioInfos[strType].Clip, isLoop, onComplete)
end

function AudioPlayer:PlayBGM(strType, isLoop, scheduledTime)
	if self.ClipPaths == nil or string.isNullOrEmpty(self.ClipPaths[strType]) then
		return
	end

	self:OnPlay(strType)

	if scheduledTime == nil then
		scheduledTime = 0
	end

	self.AudioInfos[strType].Source = MxAudioMgr.Instance:PlayMusic(self.AudioInfos[strType].Clip, isLoop, scheduledTime)
end

function AudioPlayer:PlayBGMAsync(strType, isLoop, scheduledTime)
	if self.ClipPaths == nil or string.isNullOrEmpty(self.ClipPaths[strType]) then
		return
	end

	if scheduledTime == nil then
		scheduledTime = 0
	end

	self:OnPlayAsync(strType, function()
		self.AudioInfos[strType].Source = MxAudioMgr.Instance:PlayMusic(self.AudioInfos[strType].Clip, isLoop, scheduledTime)
	end)
end

function AudioPlayer:Stop(strType)
	if self.AudioInfos == nil or self.AudioInfos[strType] == nil then
		return
	end

	if self.AudioInfos[strType].Source ~= nil then
		MxAudioMgr.Instance:StopSound(self.AudioInfos[strType].Source)
	end

	self:CancelCacheBlock(strType)
end

function AudioPlayer:Mute(strType, bMute)
	if self.AudioInfos == nil or self.AudioInfos[strType] == nil then
		return
	end

	if self.AudioInfos[strType].Source == nil or not self.AudioInfos[strType].Source.isPlaying then
		return
	end

	self.AudioInfos[strType].Source.mute = bMute
end

function AudioPlayer:StopAll()
	if self.AudioInfos == nil then
		return
	end

	for k, v in pairs(self.AudioInfos) do
		self:Stop(k)
	end

	self.AudioInfos = nil
end

function AudioPlayer:Purge()
	self.ClipPaths = nil

	if self.AudioInfos ~= nil then
		for k, v in pairs(self.AudioInfos) do
			self:CancelCacheBlock(k)
		end
	end

	self.AudioInfos = nil
end
