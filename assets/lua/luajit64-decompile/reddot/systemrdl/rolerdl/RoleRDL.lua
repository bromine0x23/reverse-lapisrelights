-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/RoleRDL/RoleRDL.lua

require("Info/InfoChapter")
require("Info/InfoEquipment")

RoleRDL = {}
RoleRDL.ALL_ROLE = RoleMgr:GetAllRole()

local ViewedTime = 0
local ViewedRole = {}
local KEY_RDL_VIEWED_ROLE = "KEY_RDL_VIEWED_ROLE"
local KEY_RDL_VIEWED_ROLE_TIME = "KEY_RDL_VIEWED_ROLE_TIME"

RoleRDL.NewRDL = require("RedDot/SystemRDL/RoleRDL/RoleNewRDL")
RoleRDL.EquipRDL = require("RedDot/SystemRDL/RoleRDL/RoleEquipRDL")
RoleRDL.InteractRDL = require("RedDot/SystemRDL/RoleRDL/RoleInteractRDL")
RoleRDL.FittingRDL = require("RedDot/SystemRDL/RoleRDL/RoleFittingRDL")

function RoleRDL.ResetAllHoldRole()
	RoleRDL.ALL_HOLD_ROLE = RoleMgr:GetAllHoldRole()
end

function RoleRDL.PushNewRole(role)
	if role == nil and not role.hold then
		return
	end

	table.insert(RoleRDL.ALL_HOLD_ROLE, role)
	RoleRDL.FittingRDL.DealNewRoleAvatar(role)
	RoleRDL.InitRole(role)
end

function RoleRDL.Init()
	RoleRDL.DealWithViewed()
	RoleRDL.ResetAllHoldRole()
	RoleRDL.NewRDL.Init()
	RoleRDL.EquipRDL.Init()
	RoleRDL.FittingRDL.Init()
	RoleRDL.InitRD()
end

function RoleRDL.InitRD()
	RoleRDL.FittingRDL.FixRDL()

	for _, role in ipairs(RoleRDL.ALL_HOLD_ROLE) do
		RoleRDL.NewRDL.RunNewRole(role)
		RoleRDL.FittingRDL.RunFittingLogic(role)
		RoleRDL.InitRole(role)
	end
end

function RoleRDL.InitRole(role)
	RoleRDL.EquipRDL.RunEquipLogic(role)
	RoleRDL.InteractRDL.RunInteractLogic(role)
end

local role_nodes = {}

function RoleRDL.AddViewed(roleId)
	if table.contains(ViewedRole, roleId) then
		return
	end

	table.insert(ViewedRole, roleId)

	ViewedTime = NetData:GetCurServerTime()

	local node = RoleRDL.GetRoleNode(roleId)

	node:AddViewListener(function()
		if table.contains(ViewedRole, roleId) then
			RoleRDL.RemoveViewed(roleId)
		end
	end)
	RedDotSystemMgr.SetNodeViewState("Role/" .. roleId, true)
	PersistentStoreUtil.SetString(KEY_RDL_VIEWED_ROLE_TIME, ViewedTime)
	PersistentStoreUtil.AddList(KEY_RDL_VIEWED_ROLE, roleId)
	Event.Instance:Fire("UpdateThinNotify")
end

function RoleRDL.RemoveViewed(roleId)
	if not table.contains(ViewedRole, roleId) then
		return
	end

	table.removeByValue(ViewedRole, roleId)

	if #ViewedRole == 0 then
		ViewedTime = 0
	end

	RedDotSystemMgr.SetNodeViewState("Role/" .. roleId, false)
	PersistentStoreUtil.SetString(KEY_RDL_VIEWED_ROLE_TIME, ViewedTime)
	PersistentStoreUtil.SetList(KEY_RDL_VIEWED_ROLE, ViewedRole)
	Event.Instance:Fire("UpdateThinNotify")
end

function RoleRDL.Reset()
	for _, roleId in ipairs(ViewedRole) do
		RedDotSystemMgr.SetNodeViewState("Role/" .. roleId, false)
	end

	ViewedRole = {}
	ViewedTime = 0

	PersistentStoreUtil.SetString(KEY_RDL_VIEWED_ROLE_TIME, ViewedTime)
	PersistentStoreUtil.SetList(KEY_RDL_VIEWED_ROLE, ViewedRole)
	Event.Instance:Fire("UpdateThinNotify")
end

function RoleRDL.DealWithViewed()
	local _time = PersistentStoreUtil.GetString(KEY_RDL_VIEWED_ROLE_TIME, "")

	if string.isNullOrEmpty(_time) or _time == "0" then
		return
	end

	_time = tonumber(_time)

	local t = PersistentStoreUtil.GetList(KEY_RDL_VIEWED_ROLE)

	if TimeIsToday(_time) then
		for _, roleId in pairs(t) do
			table.insert(ViewedRole, tonumber(roleId))
			RedDotSystemMgr.SetNodeViewState("Role/" .. roleId, true)
		end
	end
end

function RoleRDL.GetRoleNode(roleId)
	if IsNil(role_nodes[roleId]) then
		role_nodes[roleId] = RedDotSystemMgr.GetNode("Role/" .. roleId)
	end

	return role_nodes[roleId]
end

function RoleRDL.IsShowDot(roleId)
	local viewed = table.contains(ViewedRole, roleId)

	if not viewed then
		return RoleRDL.GetRoleNode(roleId).Value > 0
	end

	return false
end

return RoleRDL
