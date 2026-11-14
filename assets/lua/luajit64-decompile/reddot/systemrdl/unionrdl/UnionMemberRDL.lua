-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/UnionRDL/UnionMemberRDL.lua

local UnionMemberRDL = {}
local KEY_RD_UNION_MEMBER = "KEY_RD_UNION_MEMBER"
local ALL_APPLY_MEMBER = {}
local PRE_VALUE = 0
local CanDealApply = true

function UnionMemberRDL.Init()
	if not UnionMgr.HasUnion() then
		return
	end

	UnionMemberRDL.DealWithApplyPremission()

	for _, v in ipairs(UnionMgr.releUnion.applys) do
		table.insert(ALL_APPLY_MEMBER, v)
	end

	PRE_VALUE = #ALL_APPLY_MEMBER > 0 and 1 or 0

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Union_Branch_Path.Member, PRE_VALUE)
end

function UnionMemberRDL.Reset()
	local preCnt = #ALL_APPLY_MEMBER

	ALL_APPLY_MEMBER = {}

	for _, v in ipairs(UnionMgr.releUnion.applys) do
		table.insert(ALL_APPLY_MEMBER, v)
	end

	UnionMemberRDL.DealWithApplyPremission()

	if preCnt == #ALL_APPLY_MEMBER then
		return
	end

	local value = preCnt < #ALL_APPLY_MEMBER and 1 or 0

	if value ~= PRE_VALUE then
		PRE_VALUE = value

		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Union_Branch_Path.Member, PRE_VALUE)
	end
end

function UnionMemberRDL.RemoveApply(id)
	if id and table.contains(ALL_APPLY_MEMBER, id) then
		table.removeByValue(ALL_APPLY_MEMBER, id)
	end
end

function UnionMemberRDL.ResetMemberRDAfterLeaveUnion()
	ALL_APPLY_MEMBER = {}

	UnionMemberRDL.CancelRD()
end

function UnionMemberRDL.CancelRD()
	if PRE_VALUE == 0 then
		return
	end

	PRE_VALUE = 0

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Union_Branch_Path.Member, PRE_VALUE)
end

function UnionMemberRDL.DealWithApplyPremission()
	local jobId = UnionMemberMgr:GetMemberJob(PlayerInst.InfoPlayer.pid)

	if CanDealApply == UnionJobMgr:HavePremission(jobId, UnionJobPremissionType.apply) then
		return
	end

	CanDealApply = not CanDealApply

	RedDotSystemMgr.SetNodeLockState(RD_Union_Branch_Path.Member, not CanDealApply)
end

return UnionMemberRDL
