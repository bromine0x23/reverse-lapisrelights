-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/PVPRDL.lua

PVPRDL = {}

local RD_PVP_Branch_Path = {
	Rank_Award = "PVP/Rank_Award/%d"
}
local CurUnreceiveIds = {}

function PVPRDL.RunPVPRankAward(tab)
	for _, v in ipairs(CurUnreceiveIds) do
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_PVP_Branch_Path.Rank_Award, 0, v)
	end

	CurUnreceiveIds = {}
	tab = tab or {}

	for k, v in ipairs(tab) do
		if v.rewardtype == 2 and not table.contains(CurUnreceiveIds, k) then
			table.insert(CurUnreceiveIds, k)
			RedDotSystemMgr.SetNodeValueByFormatPath(RD_PVP_Branch_Path.Rank_Award, 1, k)
		end
	end
end

function PVPRDL.SubPVPRankAward(index)
	if table.contains(CurUnreceiveIds, index) then
		table.removeByValue(CurUnreceiveIds, index)
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_PVP_Branch_Path.Rank_Award, 0, index)
	end
end

return PVPRDL
