-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/Event.lua

Event = class("Event")

function Event:ctor()
	local mt = {
		__index = function(vTable, vEventId)
			local o = {}

			if not vEventId then
				error("vEventId = nil")
			end

			vTable[vEventId] = o

			return o
		end
	}

	self.EventId2FuntionList = {}

	setmetatable(self.EventId2FuntionList, mt)

	self.EventId2FuntionListExclude = {}

	setmetatable(self.EventId2FuntionListExclude, mt)

	self.DelegateMap = {}
end

function Event:AddDelegate(vDgtOwner, vDgtName, vFunc, vObj)
	local function handle(...)
		vFunc(vObj, ...)
	end

	vDgtOwner[vDgtName] = vDgtOwner[vDgtName] + handle
	self.DelegateMap[handle] = {
		Owner = vDgtOwner,
		Name = vDgtName
	}

	return handle
end

function Event:RemoveDelegate(handle)
	local dgt = self.DelegateMap[handle]

	dgt.Owner[dgt.Name] = dgt.Owner[dgt.Name] - handle
	self.DelegateMap[handle] = nil
end

function Event:SetArgDelegate(vArgDelegateWrapper, vFunc, vObj)
	self:Add("CSArg" .. vArgDelegateWrapper.Target:GetHashCode(), vFunc, vObj, true)
end

function Event:ClearArgDelegate(vArgDelegate)
	local aKey = "CSArg" .. vArgDelegate:GetHashCode()

	if self.EventId2FuntionList[aKey] == nil then
		error("remove vArgDelegate faild")

		return
	end

	self.EventId2FuntionList[aKey] = nil
end

function Event:AddEvent(vEvent, vFunc, vObj)
	self:Add("NGUI" .. vEvent:GetHashCode(), vFunc, vObj)
end

function Event:RemoveEvent(vEvent, vFunc, vObj)
	self:Remove("NGUI" .. vEvent:GetHashCode(), vFunc, vObj)
end

function Event:Add(vEventId, vFunc, vObj)
	self:_AddByEventId2FuntionList(self.EventId2FuntionList, vEventId, vFunc, vObj)
end

function Event:Remove(vEventId, vFunc, vObj, vClearIfEmpty)
	self:_RemoveByEventId2FuntionList(self.EventId2FuntionList, vEventId, vFunc, vObj, vClearIfEmpty)
end

function Event:AddExclude(vEventId, vFunc, vObj)
	self:_AddByEventId2FuntionList(self.EventId2FuntionListExclude, vEventId, vFunc, vObj)
end

function Event:RemoveExclude(vEventId, vFunc, vObj, vClearIfEmpty)
	self:_RemoveByEventId2FuntionList(self.EventId2FuntionListExclude, vEventId, vFunc, vObj, vClearIfEmpty)
end

function Event:_AddByEventId2FuntionList(vByEventId2FuntionList, vEventId, vFunc, vObj)
	table.insert(vByEventId2FuntionList[vEventId], {
		vFunc,
		vObj
	})
end

function Event:_RemoveByEventId2FuntionList(vEventId2FuntionList, vEventId, vFunc, vObj, vClearIfEmpty)
	local functionList = vEventId2FuntionList[vEventId]
	local removePos = -1

	if functionList then
		for k, v in pairs(functionList) do
			if vFunc == v[1] then
				if vObj then
					if vObj == v[2] then
						removePos = k

						break
					end
				else
					removePos = k

					break
				end
			end
		end
	else
		error("Can not find correspond event by id:" .. tostring(vEventId))
	end

	if removePos == -1 then
		return
	end

	table.remove(functionList, removePos)

	if vClearIfEmpty and #functionList == 0 then
		vEventId2FuntionList[vEventId] = nil
	end
end

function Event:Fire(vEventId, ...)
	local isFindFunc, ret = self:_FireByEventId2FuntionList(self.EventId2FuntionListExclude, vEventId, ...)

	if isFindFunc then
		return ret
	end

	isFindFunc, ret = self:_FireByEventId2FuntionList(self.EventId2FuntionList, vEventId, ...)

	return ret
end

function Event:_FireByEventId2FuntionList(vEventId2FuntionList, vEventId, ...)
	local functionList = vEventId2FuntionList[vEventId]
	local ret, tempRet
	local isFindFunc = false

	for k, v in pairs(functionList) do
		isFindFunc = true

		if v[1] then
			tempRet = v[1](v[2], ...)

			if tempRet and not ret then
				ret = tempRet
			end
		else
			error("Event = nil id:" .. vEventId)
		end
	end

	return isFindFunc, ret
end

if not Event.Instance then
	Event.Instance = Event()
end

function EventFire(event, arg)
	Event.Instance:Fire(event, arg)
end
