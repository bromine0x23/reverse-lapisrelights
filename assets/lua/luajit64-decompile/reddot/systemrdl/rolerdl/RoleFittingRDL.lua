-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/RoleRDL/RoleFittingRDL.lua

local RoleFittingRDL = {}

FITTING_AVATAR_TYPE = {
	"Event",
	"BP",
	"Ornament",
	"FaceUp",
	"FaceDown",
	"Body",
	"Back",
	"Waist"
}
PUBLIC_AVATAR_GROUPID = 100

local KEY_RD_Fitting = "KEY_RD_Fitting"
local RD_Fitting_Branch_Path = {
	Fitting_Slot = "Role/%d/Fitting/%s",
	Fitting_Weapon = "Role/%d/Equip/Weapon"
}
local CurNewAvatarIds = {}

function RoleFittingRDL.FixAndClearLocalCache()
	local characterInfos = require("luaData/CharacterRole")

	for k, v in pairs(characterInfos) do
		PersistentStoreUtil.DelList(KEY_RD_Fitting .. k)
	end
end

function RoleFittingRDL.Init()
	CurNewAvatarIds[PUBLIC_AVATAR_GROUPID] = {}

	local t = PersistentStoreUtil.GetList(KEY_RD_Fitting .. PUBLIC_AVATAR_GROUPID)

	for _, v in ipairs(t) do
		local avatarId = tonumber(v)

		if not table.contains(CurNewAvatarIds[PUBLIC_AVATAR_GROUPID], avatarId) then
			table.insert(CurNewAvatarIds[PUBLIC_AVATAR_GROUPID], avatarId)
		end
	end
end

local function GetTargetTab(infoAvatar)
	local tabType = infoAvatar.data.AvatarTabType

	if string.isNullOrEmpty(tabType) then
		return infoAvatar.data.Slot[1]
	end

	return tabType
end

local function DealBelongAvatar(infoAvatar, role)
	if role.hold then
		local avatarId = infoAvatar.id

		if not infoAvatar:IsWeaponAvatar() then
			RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Fitting_Branch_Path.Fitting_Slot, 1, role.id, GetTargetTab(infoAvatar))
		else
			RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Fitting_Branch_Path.Fitting_Weapon, 1, role.id)
		end

		CurNewAvatarIds[role.id] = CurNewAvatarIds[role.id] or {}

		if not table.contains(CurNewAvatarIds[role.id], avatarId) then
			table.insert(CurNewAvatarIds[role.id], avatarId)
		end
	end
end

local function DealPublicAvatar(role)
	if role.hold then
		local publicCnt = #CurNewAvatarIds[PUBLIC_AVATAR_GROUPID]

		if publicCnt > 0 then
			for _, v in ipairs(CurNewAvatarIds[PUBLIC_AVATAR_GROUPID]) do
				local infoAvatar = AvatarManager:GetAvatar(tonumber(v))

				if infoAvatar ~= nil then
					RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Fitting_Branch_Path.Fitting_Slot, 1, role.id, GetTargetTab(infoAvatar))
				end
			end
		end
	end
end

function RoleFittingRDL.FixRDL()
	local wrongIds = {
		"501",
		"502",
		"503",
		"601",
		"602",
		"102"
	}
	local wrongAvatarIds = {
		"33241054",
		"33244024",
		"33244034",
		"33242014",
		"33241014",
		"33245024"
	}
	local tmpAvatarIds = {}

	for i = 1, #wrongIds do
		local roleId = wrongIds[i]
		local wrongAvatarNum = tonumber(wrongAvatarIds[i])
		local t = PersistentStoreUtil.GetList(KEY_RD_Fitting .. roleId)

		if #t > 0 then
			for _, v in ipairs(t) do
				local infoAvatar = AvatarManager:GetAvatar(tonumber(v))

				if infoAvatar ~= nil then
					local avatarId = infoAvatar.id

					tmpAvatarIds[roleId] = tmpAvatarIds[roleId] or {}

					if not table.contains(tmpAvatarIds[roleId], avatarId) then
						table.insert(tmpAvatarIds[roleId], avatarId)
					end
				end
			end

			table.removeByValue(tmpAvatarIds[roleId], wrongAvatarNum)
			PersistentStoreUtil.SetList(KEY_RD_Fitting .. roleId, tmpAvatarIds[roleId])
		end
	end
end

function RoleFittingRDL.RunFittingLogic(role)
	local t = PersistentStoreUtil.GetList(KEY_RD_Fitting .. role.id)

	for _, v in ipairs(t) do
		local infoAvatar = AvatarManager:GetAvatar(tonumber(v))

		if infoAvatar ~= nil then
			DealBelongAvatar(infoAvatar, role)
		end
	end

	DealPublicAvatar(role)

	local lock = not TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Dress)

	if lock then
		local path = RedDotSystemMgr.GetFormatPath("Role/%d/Fitting", role.id)

		RedDotSystemMgr.SetNodeLockState(path, true)
	end
end

function RoleFittingRDL.AddFittingAvatarId()
	local newAvatarIds = ItemRDL.NewAvatarIds or {}

	for id, v in pairs(newAvatarIds) do
		for _, avatarId in ipairs(v) do
			local infoAvatar = AvatarManager:GetAvatar(avatarId)

			if infoAvatar ~= nil then
				if id ~= 100 then
					local role = RoleMgr:GetRole(id)

					DealBelongAvatar(infoAvatar, role)
				else
					for _, role in ipairs(RoleRDL.ALL_HOLD_ROLE) do
						RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Fitting_Branch_Path.Fitting_Slot, 1, role.id, GetTargetTab(infoAvatar))
					end

					CurNewAvatarIds[id] = CurNewAvatarIds[id] or {}

					if not table.contains(CurNewAvatarIds[id], avatarId) then
						table.insert(CurNewAvatarIds[id], avatarId)
					end
				end

				PersistentStoreUtil.AddList(KEY_RD_Fitting .. id, avatarId)
			end
		end
	end
end

function RoleFittingRDL.SubNewAvatarId(role, avatarId)
	local isPublic

	local function Deal(_type)
		local roleid = _type == 1 and role.id or PUBLIC_AVATAR_GROUPID

		if CurNewAvatarIds[roleid] and table.contains(CurNewAvatarIds[roleid], avatarId) then
			table.removeByValue(CurNewAvatarIds[roleid], avatarId)
			PersistentStoreUtil.SetList(KEY_RD_Fitting .. roleid, CurNewAvatarIds[roleid])

			if _type == 1 then
				isPublic = false
			else
				isPublic = true
			end
		end
	end

	Deal(2)

	if isPublic == nil then
		Deal(1)
	end

	if isPublic ~= nil then
		local infoAvatar = AvatarManager:GetAvatar(avatarId)

		if infoAvatar ~= nil then
			if isPublic then
				for _, role in ipairs(RoleRDL.ALL_HOLD_ROLE) do
					RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Fitting_Branch_Path.Fitting_Slot, -1, role.id, GetTargetTab(infoAvatar))
				end
			elseif not infoAvatar:IsWeaponAvatar() then
				RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Fitting_Branch_Path.Fitting_Slot, -1, role.id, GetTargetTab(infoAvatar))
			else
				RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Fitting_Branch_Path.Fitting_Weapon, -1, role.id)
			end
		end
	end
end

function RoleFittingRDL.IsNewAvatar(role, avatarId)
	if avatarId == nil then
		return false
	end

	if table.contains(CurNewAvatarIds[PUBLIC_AVATAR_GROUPID], avatarId) then
		return true
	end

	if role ~= nil and CurNewAvatarIds[role.id] ~= nil and table.contains(CurNewAvatarIds[role.id], avatarId) then
		return true
	end

	return false
end

function RoleFittingRDL.IsHasNewAvatar(role)
	if CurNewAvatarIds[PUBLIC_AVATAR_GROUPID] and #CurNewAvatarIds[PUBLIC_AVATAR_GROUPID] > 0 then
		return true
	end

	if not CurNewAvatarIds[role.id] then
		return false
	end

	return #CurNewAvatarIds[role.id] > 0
end

function RoleFittingRDL.DealNewRoleAvatar(role)
	local t = PersistentStoreUtil.GetList(KEY_RD_Fitting .. role.id)

	for _, v in ipairs(t) do
		local infoAvatar = AvatarManager:GetAvatar(tonumber(v))

		if infoAvatar ~= nil then
			DealBelongAvatar(infoAvatar, role)
		end
	end

	DealPublicAvatar(role)
end

return RoleFittingRDL
