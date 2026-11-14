-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/Controller.lua

HookEventPrefix = "HookEvent"

local function HookEventTableCtor()
	local hookEventTable = {}
	local mt = {
		__index = function(vTable, vHashCode)
			local o = {}

			vTable[vHashCode] = o

			return o
		end
	}

	setmetatable(hookEventTable, mt)

	return hookEventTable
end

HookEventHashCode2ControllerList = HookEventHashCode2ControllerList or HookEventTableCtor()

function SetController(vController, vHashCode)
	local controllerList = HookEventHashCode2ControllerList[HookEventPrefix .. vHashCode]

	for k, v in pairs(controllerList) do
		if v == vController then
			return
		end
	end

	table.insert(controllerList, vController)
end

function GetController(vHashCode)
	local controllerList = HookEventHashCode2ControllerList[HookEventPrefix .. vHashCode]

	return controllerList
end

function RemoveController(vHashCode)
	local controllerList = HookEventHashCode2ControllerList[HookEventPrefix .. vHashCode]

	HookEventHashCode2ControllerList[HookEventPrefix .. vHashCode] = nil
end

function InvokeController(vHashCode, vFuncName, ...)
	local vList = GetController(vHashCode)

	for i = 1, #vList do
		local controller = vList[i]

		if not controller then
			error("controller = nil i:" .. tostring(i) .. " hashcode:" .. vHashCode)
		end

		local func = controller[vFuncName]

		if func then
			func(controller, ...)
		else
			error("funName :" .. vFuncName .. " can not find gameObject:" .. controller.m_dlg.name)
		end
	end
end

function Start(vHashCode)
	InvokeController(vHashCode, "Start")
end

function OnEnable(vHashCode)
	InvokeController(vHashCode, "OnEnable")
end

function OnDisable(vHashCode)
	InvokeController(vHashCode, "OnDisable")
end

function OnUpdate(vHashCode)
	InvokeController(vHashCode, "OnUpdate")
end

Controller = class("Controller")
Controller.HashCode = nil

function Controller:HookEvent(vGameObject)
	self.HashCode = GOUtil.GetGameObjectHashCode(vGameObject)

	SetController(self, self.HashCode)

	self.Mono = GOUtil.AddMissingComponent(vGameObject, "OzMonoEventToLua")
end

function Controller:UnHookEvent()
	Object.Destroy(self.Mono)

	self.Mono = nil

	RemoveController(self.HashCode)

	self.HashCode = nil
end

function Controller:Start()
	return
end

function Controller:OnEnable()
	return
end

function Controller:OnDisable()
	return
end

function Controller:OnUpdate()
	return
end
