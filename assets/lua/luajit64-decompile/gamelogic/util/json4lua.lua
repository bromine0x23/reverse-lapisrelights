-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Util/json4lua.lua

if _G_LAPIS_SERVER == nil then
	return require("cjson")
else
	return require("cjson")
end
