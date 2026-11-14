-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/Class.lua

local _debugInstance = {}
local _class = {}

function getDebugInstance(className)
	return _debugInstance[className]
end

function remoteDebugInstance(className, obj)
	if _debugInstance[className] then
		table.removeByValue(_debugInstance[className], obj)
	end
end

local monitor_enable = UnityEngine.Application.isEditor
local monitor_filter = {
	"Info",
	"Record",
	"AttributeOwner",
	"AttributeAgent"
}
local instance_key = 0

local function MonitorFilter(className)
	for k, v in pairs(monitor_filter) do
		if string.find(className, v) == 1 then
			return false
		end
	end

	return true
end

function class(className, base, trace)
	local class_type = {}
	local vtbl = {}

	_class[class_type] = vtbl

	setmetatable(class_type, {
		__newindex = function(t, k, v)
			vtbl[k] = v
		end,
		__index = function(t, k)
			return vtbl[k]
		end,
		__call = function(class_tbl, ...)
			local obj = {}

			setmetatable(obj, {
				__index = _class[class_type]
			})

			local create

			function create(c, ...)
				if c.base then
					create(c.base, ...)
				end

				if c.ctor then
					c.ctor(obj, ...)
				end

				obj.isClass = false
			end

			create(class_type, ...)

			if monitor_enable and MonitorFilter(className) then
				obj.gc = newproxy(true)

				local gc = getmetatable(obj.gc)

				function gc.__gc(udata)
					LuaClassMonitor.RemoveWatch(obj.className .. ":" .. tostring(obj))
				end

				LuaClassMonitor.AddWatch(obj.className .. ":" .. tostring(obj))
			end

			instance_key = instance_key + 1
			obj.instance_key = instance_key

			if LuaDebugSupport.EnabledLuaDebug then
				if _debugInstance[className] == nil then
					_debugInstance[className] = {}
				end

				table.insert(_debugInstance[className], obj)
			end

			return obj
		end
	})

	class_type.ctor = false
	class_type.base = base
	class_type.className = className
	class_type.isClass = true

	if base then
		setmetatable(vtbl, {
			__index = function(t, k)
				local ret = _class[base][k]

				vtbl[k] = ret

				return ret
			end
		})
	end

	return class_type
end

function GetGLClassBaseTb(cls)
	return _class[cls]
end

function GetNewInstanceKey()
	instance_key = instance_key + 1

	return instance_key
end
