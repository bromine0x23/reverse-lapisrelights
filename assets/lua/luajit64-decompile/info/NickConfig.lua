-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/NickConfig.lua

local NickData = require("luaData/Nickname")

function GetRandomPlayerNick()
	local len = #NickData
	local n = GlobalRNG:RollRandomIntLessThan(len - 1) + 1
	local strPrefix = Lang(NickData[n].PrefixName)

	n = GlobalRNG:RollRandomIntLessThan(len - 1) + 1

	local result = strPrefix

	return result
end
