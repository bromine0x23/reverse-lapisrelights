-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Manager/EventListenerMgr.lua

EventListenerMgr = {}

function EventListenerMgr.AddUIListener(go, luafunc, luaObject, type)
	EventListenerManager.AddUIListener(go, luafunc, luaObject, type)
end

function EventListenerMgr.RemoveUIListener(go, luafunc, luaObject, type)
	EventListenerManager.RemoveUIListener(go, luafunc, luaObject, type)
end

function EventListenerMgr.AddAnimListener(go, luafunc, luaObject, type)
	EventListenerManager.AddAnimListener(go, luafunc, luaObject, type)
end

function EventListenerMgr.RemoveAnimListener(go, luafunc, luaObject, type)
	EventListenerManager.RemoveAnimListener(go, luafunc, luaObject, type)
end

function EventListenerMgr.AddAnimListenerEventID(go, luafunc, luaObject, type)
	EventListenerManager.AddAnimListenerEventID(go, luafunc, luaObject, type)
end

function EventListenerMgr.RemoveAnimListenerEventID(go, luafunc, luaObject, type)
	EventListenerManager.RemoveAnimListenerEventID(go, luafunc, luaObject, type)
end

function EventListenerMgr.AddFingerListener(luaFunction, luaObject, type)
	EventListenerManager.AddFingerListener(luaFunction, luaObject, type)
end

function EventListenerMgr.RemoveFingerListener(luaFunction, luaObject, type)
	EventListenerManager.RemoveFingerListener(luaFunction, luaObject, type)
end

function EventListenerMgr.AddFingerGestureListener(luafunc, luaObject, type)
	EventListenerManager.AddFingerGestureListener(luafunc, luaObject, type)
end

function EventListenerMgr.RemoveFingerGestureListener(luafunc, luaObject, type)
	EventListenerManager.RemoveFingerGestureListener(luafunc, luaObject, type)
end

function EventListenerMgr.AddPlayableDirectorListener(go, luaFunction, luaObject, type)
	EventListenerManager.AddPlayableDirectorListener(go, luaFunction, luaObject, type)
end

function EventListenerMgr.AddPlayableClipListener(go, luaFunction, luaObject, type)
	EventListenerManager.AddPlayableClipListener(go, luaFunction, luaObject, type)
end

function EventListenerMgr.RemovePlayableDirectorListener(go, luaFunction, luaObject, type)
	EventListenerManager.RemovePlayableDirectorListener(go, luaFunction, luaObject, type)
end

function EventListenerMgr.RemovePlayableClipListener(go, luaFunction, luaObject, type)
	EventListenerManager.RemovePlayableClipListener(go, luaFunction, luaObject, type)
end

function EventListenerMgr.AddCinemachineEventListener(go, luaFunction, luaObject)
	EventListenerManager.AddCinemachineEventListener(go, luaFunction, luaObject, 1)
end

function EventListenerMgr.RemoveCinemachineEventListener(go, luaFunction, luaObject)
	EventListenerManager.RemoveCinemachineEventListener(go, luaFunction, luaObject, 1)
end

function EventListenerMgr.AddTimelineMarkerListener(go, luaFunction, luaObject, eventName)
	EventListenerManager.AddTimelineMarkerListener(go, luaFunction, luaObject, eventName)
end

function EventListenerMgr.RemoveTimelineMarkerListener(go, luaFunction, luaObject, eventName)
	EventListenerManager.RemoveTimelineMarkerListener(go, luaFunction, luaObject, eventName)
end

function wrapedCb(callback, selfObject)
	local function OnCallback(...)
		callback(selfObject, ...)

		callback = nil
		selfObject = nil
	end

	return OnCallback
end

local listWrapedCbMa = {}

function findEmptyWrapIndex()
	for k, v in pairs(listWrapedCbMa) do
		if v == nil then
			return k
		end
	end

	local index = #listWrapedCbMa + 1

	return index
end

function wrapedCbMa(callback, selfObject)
	local wrapedCbMaIndex = findEmptyWrapIndex()

	listWrapedCbMa[wrapedCbMaIndex] = {
		callback,
		selfObject
	}

	local function OnCallback(...)
		listWrapedCbMa[wrapedCbMaIndex][1](listWrapedCbMa[wrapedCbMaIndex][2], ...)
	end

	return OnCallback, wrapedCbMaIndex
end

function removeWrapedCbMa(index)
	if index then
		listWrapedCbMa[index] = nil
	end
end
