-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/3rdParty/ToLua/Lua/jit/dis_mipsel.lua

local dis_mips = require((string.match(..., ".*%.") or "") .. "dis_mips")

return {
	create = dis_mips.create_el,
	disass = dis_mips.disass_el,
	regname = dis_mips.regname
}
