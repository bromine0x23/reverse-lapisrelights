-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Manager/SoundMgr.lua

SoundMgr = {}

function SoundMgr.LoadBank(...)
	SoundManager.LoadBank(...)
end

function SoundMgr.UnloadBank(...)
	SoundManager.UnloadBank(...)
end

function SoundMgr.DelayUnloadBank(...)
	SoundManager.DelayUnloadBank(...)
end

function SoundMgr.PostEvent(...)
	return SoundManager.PostEvent(...)
end

function SoundMgr.Play(path)
	return SoundManager.PostEvent(path, UIMgr.UICamera.gameObject)
end

function SoundMgr.PlayWithCallback(path, flags, callback)
	return SoundManager.PostEvent(path, UIMgr.UICamera.gameObject, flags, callback, "")
end

function SoundMgr.Stop(path)
	return SoundManager.ExecuteActionOnEvent(path, AkActionOnEventType.AkActionOnEventType_Stop)
end

function SoundMgr.SetSwitch(...)
	return SoundManager.SetSwitch(...)
end

function SoundMgr.ExecuteActionOnEvent(...)
	return SoundManager.ExecuteActionOnEvent(...)
end

function SoundMgr.SeekOnEvent(...)
	return SoundManager.SeekOnEvent(...)
end

function SoundMgr.Seek(...)
	return SoundManager.Seek(...)
end

function SoundMgr.StopAll()
	SoundManager.StopAll()
end

function SoundMgr.SetMusicVolume(volume)
	SoundManager.SetMusicVolume(volume)
end

function SoundMgr.SetSoundVolume(volume)
	SoundManager.SetSoundVolume(volume)
end

function SoundMgr.SetVoiceVolume(volume)
	SoundManager.SetVoiceVolume(volume)
end

function SoundMgr.GetMusicVolume()
	return SoundManager.GetMusicVolume()
end

function SoundMgr.GetSoundVolume()
	return SoundManager.GetSoundVolume()
end

function SoundMgr.GetVoiceVolume()
	return SoundManager.GetVoiceVolume()
end
