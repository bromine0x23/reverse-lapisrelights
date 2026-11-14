-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/ManualRDL/ManualVideoRDL.lua

local ManualVideoRDL = {}
local Manual_Video_Type = {
	N = "Nirvana",
	I = "Illustration"
}
local RD_Manual_Video_Branch_Path = {
	Nirvana = "Arrow/Manual/Video/%d/Nirvana/%d",
	Illustration = "Arrow/Manual/Video/%d/Illustration/%d"
}
local CAN_RECEIVE_NIRVANA = {}
local CAN_RECEIVE_ILLUSTRATION = {}

local function GetCombIdByCardId(cardId)
	local role = RoleCardMgr:GetRole(cardId)

	return role.data.Team
end

local function GetCombIdByRoleId(roleId)
	local role = RoleMgr:GetRole(roleId)

	return role.data.Team
end

function ManualVideoRDL.Init()
	local listComb = CombinationMgr:GetCombinationList()

	for _, v in pairs(listComb) do
		CAN_RECEIVE_NIRVANA[v.id] = {}
		CAN_RECEIVE_ILLUSTRATION[v.id] = {}

		for _, id in pairs(v.data.MemberList) do
			CAN_RECEIVE_NIRVANA[v.id][id] = {}
			CAN_RECEIVE_ILLUSTRATION[v.id][id] = {}
		end
	end

	local t = CollectionManager.skillAwardList or {}

	for _, card in pairs(RoleCardMgr:GetAllHoldCard()) do
		local combid = GetCombIdByCardId(card.id)

		if not table.contains(t, card.id) then
			table.insert(CAN_RECEIVE_NIRVANA[combid][card.data.CharacterID], card.id)
		end
	end

	t = CollectionManager.pictureAwardList or {}

	for _, role in pairs(RoleMgr:GetAllHoldRole()) do
		for _, pic in ipairs(role.pb.pictures) do
			if not table.contains(t, pic) then
				table.insert(CAN_RECEIVE_ILLUSTRATION[role.data.Team][role.id], pic)
			end
		end
	end

	ManualVideoRDL.InitRD()
end

function ManualVideoRDL.InitRD()
	for combid, v in pairs(CAN_RECEIVE_NIRVANA) do
		for roleid, j in pairs(v) do
			RedDotSystemMgr.SetNodeValueByFormatPath(RD_Manual_Video_Branch_Path.Nirvana, #j, combid, roleid)
		end
	end

	for combid, v in pairs(CAN_RECEIVE_ILLUSTRATION) do
		for roleid, j in pairs(v) do
			RedDotSystemMgr.SetNodeValueByFormatPath(RD_Manual_Video_Branch_Path.Illustration, #j, combid, roleid)
		end
	end
end

local function CommFunc(_roleid, _id, _type, _changetype)
	local role = RoleMgr:GetRole(_roleid)
	local tab = _type == Manual_Video_Type.N and CAN_RECEIVE_NIRVANA[role.data.Team][role.id] or CAN_RECEIVE_ILLUSTRATION[role.data.Team][role.id]
	local num = 0

	if _changetype == RED_DOT_CHANGE_TYPE.Add then
		if not table.contains(tab, _id) then
			table.insert(tab, _id)

			num = 1
		end
	elseif table.contains(tab, _id) then
		table.removeByValue(tab, _id)

		num = -1
	end

	local formatPath = RD_Manual_Video_Branch_Path[_type]

	RedDotSystemMgr.ChangeNodeValueByFormatPath(formatPath, num, role.data.Team, role.id)
end

function ManualVideoRDL.AddNirvana(_roleid, _id)
	CommFunc(_roleid, _id, Manual_Video_Type.N, RED_DOT_CHANGE_TYPE.Add)
end

function ManualVideoRDL.SubNirvana(_roleid, _id)
	CommFunc(_roleid, _id, Manual_Video_Type.N, RED_DOT_CHANGE_TYPE.Sub)
end

function ManualVideoRDL.AddIllustration(_roleid, _id)
	CommFunc(_roleid, _id, Manual_Video_Type.I, RED_DOT_CHANGE_TYPE.Add)
end

function ManualVideoRDL.SubIllustration(_roleid, _id)
	CommFunc(_roleid, _id, Manual_Video_Type.I, RED_DOT_CHANGE_TYPE.Sub)
end

function ManualVideoRDL.IsHasNirvana(_roleid, _id)
	local combid = GetCombIdByRoleId(_roleid)

	return table.contains(CAN_RECEIVE_NIRVANA[combid][_roleid], _id)
end

function ManualVideoRDL.IsHasIllustration(_roleid, _id)
	local combid = GetCombIdByRoleId(_roleid)

	return table.contains(CAN_RECEIVE_ILLUSTRATION[combid][_roleid], _id)
end

function ManualVideoRDL.Get_CAN_RECEIVE_NIRVANA()
	return CAN_RECEIVE_NIRVANA
end

function ManualVideoRDL.Get_CAN_RECEIVE_ILLUSTRATION()
	return CAN_RECEIVE_ILLUSTRATION
end

return ManualVideoRDL
