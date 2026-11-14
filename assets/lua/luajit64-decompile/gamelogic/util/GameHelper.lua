-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Util/GameHelper.lua

GameHelper = GLClass("GameHelper")
GameHelper.print_enable = true

local print = function(...)
	if GameHelper.print_enable == true then
		print(...)
	end
end
local segmentSize = 3072

local function Logcat(str)
	if GameHelper.print_enable == false then
		return
	end

	local length = #str

	if length < segmentSize then
		print(str)
	else
		while length > segmentSize do
			local log = string.sub(str, 1, segmentSize)

			str = string.sub(str, #log + 1, #str)
			length = #str

			print(log)
		end

		print(str)
	end
end

function GameHelper:ctor()
	return
end

function GameHelper:Reset()
	return
end

function GameHelper:LOG(...)
	print("<color=white>" .. ... .. "</color>")
end

function GameHelper:ERROR(...)
	print("<color=red>" .. ... .. "</color>")
end

function GameHelper:WARNING(...)
	print("<color=yellow>" .. ... .. "</color>")
end

function GameHelper:LOGCAT(...)
	if Application.isEditor == true then
		print(...)
	else
		Logcat(...)
	end
end
