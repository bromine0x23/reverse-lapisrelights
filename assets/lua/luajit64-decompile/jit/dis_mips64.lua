-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/3rdParty/ToLua/Lua/jit/dis_mips64.lua

local dis_mips = require((string.match(..., ".*%.") or "") .. "dis_mips")

return {
	create = dis_mips.create,
	disass = dis_mips.disass,
	regname = dis_mips.regname
}
