-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/gvg/InfoGvg_Union.lua

local mt = class("InfoGvg_Union")

function mt:ctor()
	return
end

function mt:Purge()
	return
end

function mt:GetUnionData()
	return UnionMgr.HasUnion(false)
end

function mt:IsLord()
	if Infogvg.offline then
		return false
	end

	local jobId = UnionMemberMgr:GetMemberJob(PlayerInst.InfoPlayer.pid)
	local isLord = UnionJobMgr:HavePremission(jobId, UnionJobPremissionType.gvgStore)

	return isLord
end

return mt
