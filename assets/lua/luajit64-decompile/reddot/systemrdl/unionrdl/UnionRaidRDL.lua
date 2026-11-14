-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/UnionRDL/UnionRaidRDL.lua

local UnionRaidRDL = {}
local ALL_CAN_RECEIVE_RAID = {}

function UnionRaidRDL.Init()
	if not UnionMgr.HasUnion() then
		return
	end

	local function Add(list)
		for _, v in pairs(list) do
			if v:IsFinished() and not v:IsReceived() then
				table.insert(ALL_CAN_RECEIVE_RAID, v.id)
			end
		end
	end

	local t = UnionRaidMgr.listCommRaid

	Add(t)

	t = UnionRaidMgr.listBossRaid

	Add(t)
end

return UnionRaidRDL
