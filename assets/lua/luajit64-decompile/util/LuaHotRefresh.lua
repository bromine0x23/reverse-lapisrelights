-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/LuaHotRefresh.lua

function RefeshLua(luaPath)
	local tModule = string.gsub(luaPath, "/", ".")

	tModule = string.gsub(tModule, ".lua", "")

	local clsName = lastIndexValue(tModule, "%.")

	if clsName == nil then
		clsName = tModule
	end

	print(clsName)
	print(type(package.loaded[tModule]))

	if not package.loaded[tModule] then
		return
	else
		local importCls = string.gsub(luaPath, ".lua", "")

		package.loaded[tModule] = nil

		if _G[clsName] then
			print("first g", _G[clsName])
			print("make _G empty")

			_G[clsName] = nil
		end

		require(importCls)
	end

	local ins = getDebugInstance(clsName)

	if ins == nil then
		return
	end

	if type(package.loaded[tModule]) == "boolean" then
		local gobInner = _G[clsName]()

		for k, v in pairs(ins) do
			if gobInner ~= v then
				refreshTable(v, gobInner)
			end
		end

		remoteDebugInstance(clsName, gobInner)
	elseif type(package.loaded[tModule]) == "table" then
		local newInner = package.loaded[tModule]()

		for k, v in pairs(ins) do
			if newInner ~= v then
				refreshTable(v, newInner)
			end
		end

		remoteDebugInstance(clsName, newInner)
	end
end

function refreshTable(origin, newOne)
	if origin.OnUnRegisterEvent then
		origin:OnUnRegisterEvent()
	end

	for k, _ in pairs(origin) do
		if newOne[k] then
			origin[k] = newOne[k]
		end
	end

	setmetatable(origin, getmetatable(newOne))

	if origin.OnRegisterEvent then
		origin:OnRegisterEvent()
	end
end

function lastIndexValue(str, k)
	local ts = string.reverse(str)
	local _, i = string.find(ts, k)

	if i == nil then
		return str
	else
		local m = string.len(ts) - i + 1

		return string.sub(str, m + 1, string.len(str))
	end
end
