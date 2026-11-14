-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/LuaMemorySnapshot.lua

local preLuaSnapshot

function LuaMemorySnapshot()
	print("GC前, Lua内存为:", collectgarbage("count"))

	local str = ""
	local snapshot = require("snapshot")

	if snapshot == nil then
		return
	end

	local curLuaSnapshot = snapshot.snapshot()
	local ret = {}
	local count = 0

	if preLuaSnapshot ~= nil then
		for k, v in pairs(curLuaSnapshot) do
			if preLuaSnapshot[k] == nil then
				count = count + 1
				ret[k] = v
			end
		end
	end

	for k, v in pairs(ret) do
		str = str .. tostring(k) .. "\n" .. tostring(v) .. "$"
	end

	print("Lua snapshot diff object count is " .. count)

	preLuaSnapshot = curLuaSnapshot

	return str
end
