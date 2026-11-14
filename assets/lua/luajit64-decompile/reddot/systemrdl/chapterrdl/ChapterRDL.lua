-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/ChapterRDL/ChapterRDL.lua

ChapterRDL = {}
ChapterRDL.MainRDL = require("RedDot/SystemRDL/ChapterRDL/ChapterMainRDL")
ChapterRDL.BossLiveRDL = require("RedDot/SystemRDL/ChapterRDL/ChapterBossLiveRDL")
ChapterRDL.TowerRDL = require("RedDot/SystemRDL/ChapterRDL/ChapterTowerRDL")
ChapterRDL.AssetRDL = require("RedDot/SystemRDL/ChapterRDL/ChapterAssetRDL")
ChapterRDL.CombRDL = require("RedDot/SystemRDL/ChapterRDL/ChapterCombRDL")
ChapterRDL.PartyRDL = require("RedDot/SystemRDL/ChapterRDL/ChapterPartyRDL")
ChapterRDL.BossRaidRDL = require("RedDot/SystemRDL/ChapterRDL/ChapterBossRaidRDL")
ChapterRDL.CardRDL = require("RedDot/SystemRDL/ChapterRDL/ChapterCardRDL")

function ChapterRDL.Init()
	ChapterRDL.MainRDL.Init()
	ChapterRDL.BossLiveRDL.Init()
	ChapterRDL.AssetRDL.Init()
	ChapterRDL.CombRDL.Init()
	ChapterRDL.PartyRDL.Init()
	ChapterRDL.BossRaidRDL.Init()
	ChapterRDL.CardRDL.Init()
end

function ChapterRDL.DealAddStarAward(_chapterid)
	local info = ChapterMgr:GetChapter(_chapterid)

	if info == nil then
		return
	end

	local _type = info.data.Type

	if _type == ChapterFromType.main or _type == ChapterFromType.mainhard then
		ChapterRDL.MainRDL.Add(info)
	elseif _type == ChapterFromType.bosslive then
		ChapterRDL.BossLiveRDL.Add(info)
	elseif _type == ChapterFromType.comb then
		ChapterRDL.CombRDL.Add(info)
	end
end

function ChapterRDL.DealSubStarAward(_chapterid, _idxs)
	local info = ChapterMgr:GetChapter(_chapterid)

	if info == nil then
		return
	end

	local _type = info.data.Type

	if _type == ChapterFromType.main or _type == ChapterFromType.mainhard then
		ChapterRDL.MainRDL.Sub(info, _idxs)
	elseif _type == ChapterFromType.bosslive then
		ChapterRDL.BossLiveRDL.Sub(info, _idxs)
	elseif _type == ChapterFromType.comb then
		ChapterRDL.CombRDL.Sub(info, _idxs)
	end
end

function ChapterRDL.RemoveStarAwardIdx(tbl, _idxs)
	local cnt = 0

	for k, v in pairs(_idxs or {}) do
		if table.contains(tbl or {}, v + 1) then
			cnt = cnt + 1

			table.removeByValue(tbl, v + 1)
		end
	end

	return cnt
end

return ChapterRDL
