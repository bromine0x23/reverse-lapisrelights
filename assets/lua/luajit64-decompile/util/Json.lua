-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/Json.lua

local json = {}
local cjson = require("cjson")

function json.encode(var)
	local status, result = pcall(cjson.encode, var)

	if status then
		return result
	end

	error(string.format("json.encode() - encoding failed: %s", tostring(result)))
end

function json.decode(text)
	local status, result = pcall(cjson.decode, text)

	if status then
		return result
	end

	error(string.format("json.decode() - decoding failed: %s", tostring(result)))
end

json.null = cjson.null

return json
