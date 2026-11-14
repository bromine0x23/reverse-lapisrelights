-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/ChapterRDL/ChapterBossLiveRDL.lua

local ChapterBossLiveRDL = {}
local RD_Chapter_BossLive_Branch_Path = {
	BossLive_Award = "Chapter/BossLive/Award/%d"
}
local CAN_RECEIVE_BOSSLIVE_STAR_AWARD = {}

local function CommFunc(_infoChapter)
	local t = _infoChapter:GetCanReceiveStarAwardList()

	CAN_RECEIVE_BOSSLIVE_STAR_AWARD[_infoChapter.id] = t
end

function ChapterBossLiveRDL.Init()
	local t = ChapterMgr.listAllChapter[ChapterType.bosslive]

	for _, v in pairs(t) do
		CommFunc(v)
	end

	ChapterBossLiveRDL.InitRD()
end

function ChapterBossLiveRDL.InitRD()
	for k, v in pairs(CAN_RECEIVE_BOSSLIVE_STAR_AWARD) do
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_BossLive_Branch_Path.BossLive_Award, #v, k)
	end
end

function ChapterBossLiveRDL.Add(_info)
	local preValue = #(CAN_RECEIVE_BOSSLIVE_STAR_AWARD[_info.id] or {})

	CommFunc(_info)

	local curValue = #(CAN_RECEIVE_BOSSLIVE_STAR_AWARD[_info.id] or {})

	if preValue == curValue then
		return
	end

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_BossLive_Branch_Path.BossLive_Award, curValue, _info.id)
end

function ChapterBossLiveRDL.Sub(_info, _idxs)
	local t = CAN_RECEIVE_BOSSLIVE_STAR_AWARD[_info.id] or {}
	local value = ChapterRDL.RemoveStarAwardIdx(t, _idxs)

	if value == 0 then
		return
	end

	RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Chapter_BossLive_Branch_Path.BossLive_Award, -value, _info.id)
end

return ChapterBossLiveRDL
