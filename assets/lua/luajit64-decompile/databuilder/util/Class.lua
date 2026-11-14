-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/DataBuilder/Util/Class.lua

local _class = {}

function BClass(className, base, trace)
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
