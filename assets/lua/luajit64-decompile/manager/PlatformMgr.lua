-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Manager/PlatformMgr.lua

PlatformMgr = {}

function PlatformMgr.Init()
	KlabIDSupport.GetInstance():Initialize()
	GameServiceSupport.GetInstance():Initialize()
	TwitterSupport.GetInstance():Initialize()
end
