-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/ChapterRDL/ChapterBossRaidRDL.lua

local ChapterBossRaidRDL = {}
local RD_Chapter_Boss_Raid_Branch_Path = {
	Record = "Chapter/BossRaid/Record"
}
local CUR_CAN_RECEIVE_AWARD = {}
local PRE_VALUE = 0

function ChapterBossRaidRDL.Init()
	local finishList = ActivityBossRaidMgr:GetFinishedBossRaid()
	local value = 0

	for i, v in ipairs(finishList) do
		if v.curProgress == 0 and v.selfStatus == 0 then
			value = 1

			break
		end
	end

	if value == PRE_VALUE then
		return
	end

	PRE_VALUE = value

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Boss_Raid_Branch_Path.Record, value)
end

function ChapterBossRaidRDL.Deal()
	ChapterBossRaidRDL.Init()
end

return ChapterBossRaidRDL
