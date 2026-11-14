-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/ChapterRDL/ChapterMainRDL.lua

local ChapterGroupData = require("luaData/ChapterGroupData")
local ChapterMainRDL = {}
local RD_Chapter_Main_Branch_Path = {
	Hard = "Chapter/Main/Hard/%d/%d",
	Easy = "Chapter/Main/Easy/%d/%d"
}
local CAN_RECEIVE_EASY_STAR_AWARD = {}
local CAN_RECEIVE_HARD_STAR_AWARD = {}
local listGroup = {}

function GetChapterMainBranchPath(chapterType)
	if chapterType == ChapterFromType.main then
		return RD_Chapter_Main_Branch_Path.Easy
	elseif chapterType == ChapterFromType.mainhard then
		return RD_Chapter_Main_Branch_Path.Hard
	end

	return ""
end

function GetChapterGroup(info)
	local _type = 0

	if info.data.Type == ChapterFromType.main then
		_type = 1
	elseif info.data.Type == ChapterFromType.mainhard then
		_type = 2
	end

	for k, v in pairsByKeys(listGroup[_type] or {}) do
		if table.contains(v.Chapter, info.id) then
			return k
		end
	end

	return 1
end

local function CommFunc(info)
	local t = info:GetCanReceiveStarAwardList()
	local groupidx = GetChapterGroup(info)

	if info.data.Type == ChapterFromType.main then
		CAN_RECEIVE_EASY_STAR_AWARD[groupidx] = CAN_RECEIVE_EASY_STAR_AWARD[groupidx] or {}
		CAN_RECEIVE_EASY_STAR_AWARD[groupidx][info.id] = t
	else
		CAN_RECEIVE_HARD_STAR_AWARD[groupidx] = CAN_RECEIVE_HARD_STAR_AWARD[groupidx] or {}
		CAN_RECEIVE_HARD_STAR_AWARD[groupidx][info.id] = t
	end
end

function ChapterMainRDL.Init()
	listGroup = {}

	for _, v in pairsByKeys(ChapterGroupData) do
		listGroup[v.Type] = listGroup[v.Type] or {}

		table.insert(listGroup[v.Type], v)
	end

	local listEasy = ChapterMgr.listAllChapter[ChapterType.main]

	for _, v in pairs(listEasy) do
		CommFunc(v)
	end

	local listHard = ChapterMgr.listAllChapter[ChapterType.mainhard]

	for _, v in pairs(listHard) do
		CommFunc(v)
	end

	ChapterMainRDL.InitRD()
end

function ChapterMainRDL.InitRD()
	for k, v in pairs(CAN_RECEIVE_EASY_STAR_AWARD) do
		for i, j in pairs(v) do
			RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Main_Branch_Path.Easy, #j, k, i)
		end
	end

	for k, v in pairs(CAN_RECEIVE_HARD_STAR_AWARD) do
		for i, j in pairs(v) do
			RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Main_Branch_Path.Hard, #j, k, i)
		end
	end
end

function ChapterMainRDL.Add(_info)
	CommFunc(_info)

	local value = 0
	local groupidx = GetChapterGroup(_info)
	local ctype = _info.data.Type

	if ctype == ChapterFromType.main then
		value = #CAN_RECEIVE_EASY_STAR_AWARD[groupidx][_info.id]
	elseif ctype == ChapterFromType.mainhard then
		value = #CAN_RECEIVE_HARD_STAR_AWARD[groupidx][_info.id]
	end

	RedDotSystemMgr.SetNodeValueByFormatPath(GetChapterMainBranchPath(ctype), value, groupidx, _info.id)
end

function ChapterMainRDL.Sub(_info, _idxs)
	local ctype = _info.data.Type
	local gidx = GetChapterGroup(_info)
	local t = {}

	if ctype == ChapterFromType.main then
		t = CAN_RECEIVE_EASY_STAR_AWARD[gidx][_info.id] or {}
	elseif ctype == ChapterFromType.mainhard then
		t = CAN_RECEIVE_HARD_STAR_AWARD[gidx][_info.id] or {}
	end

	local value = ChapterRDL.RemoveStarAwardIdx(t, _idxs)

	if value == 0 then
		return
	end

	RedDotSystemMgr.ChangeNodeValueByFormatPath(GetChapterMainBranchPath(ctype), -value, gidx, _info.id)
end

return ChapterMainRDL
