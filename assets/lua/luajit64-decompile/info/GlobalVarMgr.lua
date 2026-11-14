-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/GlobalVarMgr.lua

GlobalVarMgr = {}
GlobalVarMgr.Mine2DSeat = 1

function GlobalVarMgr:SetMain2DSeat(v)
	self.Mine2DSeat = v
end

function GlobalVarMgr:GetMain2DSeat()
	return self.Mine2DSeat
end
