-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Manager/TimerMgr.lua

eTimerType = {
	ScaleTime = 0,
	FrameCount = 3,
	RealTime = 2,
	UnscaleTime = 1
}
TimerMgr = {}

function TimerMgr.AddTimer(...)
	return TimerManager.AddTimer(...)
end

function TimerMgr.RemoveTimer(id)
	if id then
		TimerManager.RemoveTimer(id)
	end
end
