-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/HotLua.lua

HotLua = {}

function CMDInject.NotifyGMCmd(exec, cmdName, path)
	if HotLua:Hotfix_file(path) ~= -1 then
		return true
	end

	return false
end

function HotLua:Fix(path)
	path = "/Products/Lua/" .. path

	local index = path:find("%.lua")

	if index then
		if self:Hotfix_file(Application.dataPath .. path) ~= -1 then
			print(path .. " hot fix")
		end
	else
		CMDInject.HotFixFolder(path)
	end
end

function HotLua:_HotFix(chunk, check_name)
	local env = {}

	setmetatable(env, {
		__index = _G
	})

	local _ENV = env
	local f, err = load(chunk, check_name, "t", env)

	assert(f, err)

	local ok, err = pcall(f)

	assert(ok, err)

	for name, value in pairs(env) do
		local g_value = _G[name]

		if type(g_value) ~= type(value) then
			_G[name] = value
		elseif type(value) == "function" then
			self:_Update_func(value, g_value, name, "G" .. "  ")

			_G[name] = value
		elseif type(value) == "table" then
			self:_Update_table(value, g_value, name, "G" .. "  ")
		end
	end
end

function HotLua:_Update_func(env_f, g_f, name, deep)
	local old_upvalue_map = {}

	for i = 1, math.huge do
		local name, value = debug.getupvalue(g_f, i)

		if not name then
			break
		end

		old_upvalue_map[name] = value
	end

	for i = 1, math.huge do
		local name, value = debug.getupvalue(env_f, i)

		if not name then
			break
		end

		local old_value = old_upvalue_map[name]

		if old_value then
			if type(old_value) ~= type(value) then
				debug.setupvalue(env_f, i, old_value)
			elseif type(old_value) == "function" then
				self:_Update_func(value, old_value, name, deep .. "  " .. name .. "  ")
			elseif type(old_value) == "table" then
				self:_Update_table(value, old_value, name, deep .. "  " .. name .. "  ")
				debug.setupvalue(env_f, i, old_value)
			else
				debug.setupvalue(env_f, i, old_value)
			end
		end
	end
end

local protection = {
	require = true,
	_ENV = true,
	next = true,
	pairs = true,
	ipairs = true,
	setmetatable = true
}
local visited_sig = {}

function HotLua:_Update_table(env_t, g_t, name, deep)
	if protection[env_t] or protection[g_t] then
		return
	end

	if env_t == g_t then
		return
	end

	local signature = tostring(g_t) .. tostring(env_t)

	if visited_sig[signature] then
		return
	end

	visited_sig[signature] = true

	for name, value in pairs(env_t) do
		local old_value = g_t[name]

		if type(value) == type(old_value) then
			if type(value) == "function" then
				self:_Update_func(value, old_value, name, deep .. "  " .. name .. "  ")

				g_t[name] = value
			elseif type(value) == "table" then
				self:_Update_table(value, old_value, name, deep .. "  " .. name .. "  ")
			end
		else
			g_t[name] = value
		end
	end

	local old_meta = debug.getmetatable(g_t)
	local new_meta = debug.getmetatable(env_t)

	if type(old_meta) == "table" and type(new_meta) == "table" then
		self:_Update_table(new_meta, old_meta, name .. "s Meta", deep .. "  " .. name .. "s Meta" .. "  ")
	end
end

function HotLua:Hotfix_file(name)
	local file_str
	local fp = io.open(name)

	if fp then
		io.input(name)

		file_str = io.read("*all")

		io.close(fp)
	end

	if not file_str then
		return -1
	end

	return self:_HotFix(file_str, name)
end
