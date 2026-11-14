-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/gvg/trigger.lua

local mt = {}

mt.__index = mt
mt.type = "trigger"
mt.enable_flag = true
mt.removed = false
mt.event = nil

function mt:Disable()
	self.enable_flag = false
end

function mt:Enable()
	self.enable_flag = true
end

function mt:IsEnable()
	return self.enable_flag
end

function mt:__call(...)
	if self.removed then
		return
	end

	if self.enable_flag then
		return self:callback(...)
	end
end

function mt:Remove()
	if not self.event then
		return
	end

	local event = self.event

	self.event = nil
	self.removed = true

	for i, trg in ipairs(event) do
		if trg == self then
			table.remove(event, i)

			break
		end
	end
end

local function _trigger(event, callback)
	local trg = setmetatable({
		event = event,
		callback = callback
	}, mt)

	table.insert(event, trg)

	return trg
end

local event = {}

function event.Notify(obj, name, ...)
	local events = obj.events

	if not events then
		return
	end

	local event = events[name]

	if not event then
		return
	end

	for i = #event, 1, -1 do
		event[i](...)
	end
end

function event.Register(obj, name)
	local events = obj.events

	if not events then
		events = {}
		obj.events = events
	end

	local event = events[name]

	if not event then
		event = {}
		events[name] = event

		function event:Remove()
			events[name] = nil
		end
	end

	return function(f)
		return _trigger(event, f)
	end
end

return event
