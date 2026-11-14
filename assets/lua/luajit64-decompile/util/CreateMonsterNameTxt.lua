-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/CreateMonsterNameTxt.lua

local monster = require("luaData/monster")
local language = require("luaData/language")
local dic = {}
local str = "警告魔獣出現！！"

for k, v in pairs(monster) do
	if v.Boss == 1 then
		local lid = v.Name

		if language[lid] then
			local name = language[lid].CN

			if not dic[name] then
				str = str .. name
				dic[name] = 1
			end
		end
	end
end

return str
