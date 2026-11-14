-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/ManualRDL/ManualNotesRDL.lua

local TaskData = require("luaData/Figure")
local ManualNotesRDL = {}
local Nodes_Task_Type = {
	Weapon = "Weapon",
	Active = "Active",
	Avatar = "Avatar",
	Title = "Title"
}
local RD_Manual_Nodes_Branch_Path = {
	Note = "Arrow/Manual/Notes/Notes/%d/%d/%d/%d"
}
local IsViewedNotes = false
local KEY_RD_MANUAL_NOTES_VIEWED = "KEY_RD_MANUAL_NOTES_VIEWED"
local CAN_RECEIVE_NOTE_TASK = {}
local BEING_NOTE_TASK = {}

function GetNodesPath(idx)
	if idx == 1 then
		return "Arrow/Manual/Notes/Notes/%d"
	elseif idx == 2 then
		return "Arrow/Manual/Notes/Notes/%d/%d"
	elseif idx == 3 then
		return "Arrow/Manual/Notes/Notes/%d/%d/%d"
	end

	return RD_Manual_Nodes_Branch_Path.Note
end

local function IsCanReceive(info)
	local cur, max = info:GetProgress()

	if not info:IsGetAward() and max <= cur and info:CheckItemEnough() then
		return true
	end

	return false
end

function ManualNotesRDL.Init()
	local t = CollectionManager.curOpenList or {}

	for roleid, v in pairs(t) do
		local role = RoleMgr:GetRole(roleid)

		if role.hold then
			CAN_RECEIVE_NOTE_TASK[roleid] = CAN_RECEIVE_NOTE_TASK[roleid] or {}

			for i, j in pairs(v) do
				CAN_RECEIVE_NOTE_TASK[roleid][j.data.PageIndex] = CAN_RECEIVE_NOTE_TASK[roleid][j.data.PageIndex] or {}
				CAN_RECEIVE_NOTE_TASK[roleid][j.data.PageIndex][j.data.type] = CAN_RECEIVE_NOTE_TASK[roleid][j.data.PageIndex][j.data.type] or {}

				if IsCanReceive(j) then
					table.insert(CAN_RECEIVE_NOTE_TASK[roleid][j.data.PageIndex][j.data.type], j.id)
				end
			end
		end
	end

	local viewed = PersistentStoreUtil.GetBool(KEY_RD_MANUAL_NOTES_VIEWED, false)

	ManualNotesRDL.ViewedNotes(viewed)
	ManualNotesRDL.InitRD()
end

function ManualNotesRDL.InitRD()
	for roleid, v in pairs(CAN_RECEIVE_NOTE_TASK) do
		local role = RoleMgr:GetRole(roleid)

		for pageidx, j in pairs(v) do
			for pagetype, n in pairs(j) do
				RedDotSystemMgr.SetNodeValueByFormatPath(GetNodesPath(), #n, role.data.Team, roleid, pageidx, pagetype)
			end
		end
	end
end

function ManualNotesRDL.Sub(_info)
	local roleid = _info.data.roleId
	local combid = RoleMgr:GetRole(roleid).data.Team

	CAN_RECEIVE_NOTE_TASK[roleid] = {}

	local t = CollectionManager.curOpenList[roleid] or {}

	for i, j in pairs(t) do
		CAN_RECEIVE_NOTE_TASK[roleid][j.data.PageIndex] = CAN_RECEIVE_NOTE_TASK[roleid][j.data.PageIndex] or {}
		CAN_RECEIVE_NOTE_TASK[roleid][j.data.PageIndex][j.data.type] = CAN_RECEIVE_NOTE_TASK[roleid][j.data.PageIndex][j.data.type] or {}

		if IsCanReceive(j) then
			table.insert(CAN_RECEIVE_NOTE_TASK[roleid][j.data.PageIndex][j.data.type], j.id)
		end
	end

	if CAN_RECEIVE_NOTE_TASK[roleid][_info.data.PageIndex] == nil or CAN_RECEIVE_NOTE_TASK[roleid][_info.data.PageIndex][_info.data.type] == nil then
		RedDotSystemMgr.SetNodeValueByFormatPath(GetNodesPath(), 0, combid, roleid, _info.data.PageIndex, _info.data.type)
	end

	for pageidx, v in pairs(CAN_RECEIVE_NOTE_TASK[roleid]) do
		for pagetype, n in pairs(v) do
			RedDotSystemMgr.SetNodeValueByFormatPath(GetNodesPath(), #n, combid, roleid, pageidx, pagetype)
		end
	end
end

function ManualNotesRDL.Add(_info)
	local roleid = _info.data.roleId
	local combid = RoleMgr:GetRole(roleid).data.Team
	local idx, type = _info.data.PageIndex, _info.data.type

	if CAN_RECEIVE_NOTE_TASK[roleid] == nil then
		CAN_RECEIVE_NOTE_TASK[roleid] = {}
	end

	if CAN_RECEIVE_NOTE_TASK[roleid][idx] == nil then
		CAN_RECEIVE_NOTE_TASK[roleid][idx] = {}
	end

	if CAN_RECEIVE_NOTE_TASK[roleid][idx][type] == nil then
		CAN_RECEIVE_NOTE_TASK[roleid][idx][type] = {}
	end

	if not table.contains(CAN_RECEIVE_NOTE_TASK[roleid][idx][type], _info.id) then
		table.insert(CAN_RECEIVE_NOTE_TASK[roleid][idx][type], _info.id)
		RedDotSystemMgr.ChangeNodeValueByFormatPath(GetNodesPath(), 1, combid, roleid, idx, type)

		if idx == 0 then
			ManualNotesRDL.ViewedNotes(false)
		end
	end
end

function ManualNotesRDL.DealTask(roleid, _type)
	local function Deal(t, isFromItem)
		for k, v in pairs(t) do
			if IsCanReceive(v) then
				ManualNotesRDL.Add(v)
			elseif isFromItem then
				ManualNotesRDL.Sub(v)
			end
		end
	end

	if roleid then
		local t = CollectionManager.curOpenList[roleid] or {}

		Deal(t)
	else
		local allHoldCard = RoleMgr:GetAllHoldRole()

		for _, role in pairs(allHoldCard) do
			local t = CollectionManager.curOpenList[role.id] or {}

			Deal(t, true)
		end
	end
end

function ManualNotesRDL.ViewedNotes(viewstate)
	viewstate = Tenary(viewstate, false)

	if IsViewedNotes == viewstate then
		return
	end

	RedDotSystemMgr.SetNodeViewState("Arrow/Manual/Notes", viewstate)
	PersistentStoreUtil.SetBool(KEY_RD_MANUAL_NOTES_VIEWED, viewstate)

	IsViewedNotes = viewstate
end

function ManualNotesRDL.HasCanRecvLOrR(role, page_idx, page_type)
	CAN_RECEIVE_NOTE_TASK[role.id] = CAN_RECEIVE_NOTE_TASK[role.id] or {}
	CAN_RECEIVE_NOTE_TASK[role.id][page_idx] = CAN_RECEIVE_NOTE_TASK[role.id][page_idx] or {}

	local LHas, RHas = false, false

	for pagetype, v in pairs(CAN_RECEIVE_NOTE_TASK[role.id][page_idx]) do
		if pagetype < page_type then
			if #v > 0 then
				LHas = true
			end
		elseif page_type < pagetype and #v > 0 then
			RHas = true
		end
	end

	return LHas, RHas
end

return ManualNotesRDL
