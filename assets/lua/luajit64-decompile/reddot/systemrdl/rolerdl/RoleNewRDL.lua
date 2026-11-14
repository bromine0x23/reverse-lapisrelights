-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/RoleRDL/RoleNewRDL.lua

local RoleNewRDL = {}
local RD_Role_New_Branch_Path = {
	New = "Role/%d/New"
}
local KEY_RD_ROLE_NEW = "KEY_RD_ROLE_NEW"
local CurNewRoleIds = {}

function RoleNewRDL.Init()
	local t = PersistentStoreUtil.GetList(KEY_RD_ROLE_NEW)

	for _, v in ipairs(t) do
		local roleid = tonumber(v)

		if not table.contains(CurNewRoleIds, roleid) then
			table.insert(CurNewRoleIds, roleid)
		end
	end
end

function RoleNewRDL.RunNewRole(role)
	if table.contains(t, tostring(role.id)) then
		RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Role_New_Branch_Path.New, 1, role.id)
	end
end

function RoleNewRDL.AddNewRolePlayerPrefs(role)
	if table.contains(CurNewRoleIds, role.id) then
		return
	end

	PersistentStoreUtil.AddList(KEY_RD_ROLE_NEW, role.id)
	RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Role_New_Branch_Path.New, 1, role.id)
	table.insert(CurNewRoleIds, role.id)
end

function RoleNewRDL.SubNewRolePlayerPrefs(role)
	if not table.contains(CurNewRoleIds, role.id) then
		return
	else
		table.removeByValue(CurNewRoleIds, role.id)
	end

	PersistentStoreUtil.SetList(KEY_RD_ROLE_NEW, CurNewRoleIds)
	RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Role_New_Branch_Path.New, -1, role.id)
	Event.Instance:Fire("UpdateThinNotify")
end

function RoleNewRDL.IsNewRole(role)
	return table.contains(CurNewRoleIds, role.id)
end

return RoleNewRDL
