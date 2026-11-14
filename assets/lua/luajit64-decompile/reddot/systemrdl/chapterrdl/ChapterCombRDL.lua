-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/ChapterRDL/ChapterCombRDL.lua

local ChapterCombRDL = {}
local RD_Chapter_Comb_Branch_Path = {
	Unlock = "Chapter/Comb/%d",
	Award = "Chapter/Comb/%d/%d"
}
local KEY_RD_CHAPTER_COMB_UNLOCK = "KEY_RD_CHAPTER_COMB_UNLOCK"
local ALL_COMB = {}
local ALL_COMB_CHAPTER = {}
local NEW_CHAPTER_COMB = {}
local CAN_RECEIVE_COMB_STAR_AWARD = {}

local function CommFunc(_info)
	local t = _info:GetCanReceiveStarAwardList()

	CAN_RECEIVE_COMB_STAR_AWARD[_info.data.Team][_info.id] = t
end

function ChapterCombRDL.FixAndClearLocalCache()
	local characterInfos = require("luaData/CharacterRole")

	for k, v in pairs(characterInfos) do
		PersistentStoreUtil.DelList(KEY_RD_Fitting .. k)
	end
end

function ChapterCombRDL.Init()
	ALL_COMB = CombinationMgr:GetCombinationList()
	NEW_CHAPTER_COMB = PersistentStoreUtil.GetList(KEY_RD_CHAPTER_COMB_UNLOCK)

	for _, comb in ipairs(ALL_COMB) do
		ALL_COMB_CHAPTER[comb.id] = ChapterMgr.listAllChapter[ChapterType.comb .. comb.id] or {}
		CAN_RECEIVE_COMB_STAR_AWARD[comb.id] = CAN_RECEIVE_COMB_STAR_AWARD[comb.id] or {}

		for _, chapter in ipairs(ALL_COMB_CHAPTER[comb.id]) do
			CommFunc(chapter)
		end
	end

	ChapterCombRDL.InitRD()
end

function ChapterCombRDL.InitRD()
	for _, id in pairs(NEW_CHAPTER_COMB) do
		local info = CombinationMgr:Get(tonumber(id))

		if info and info.data.Version == 1 and info.data.StageVersion == 1 then
			RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Comb_Branch_Path.Unlock, 1, info.id)
		end
	end

	for combid, v in pairs(CAN_RECEIVE_COMB_STAR_AWARD) do
		for chapterid, j in pairs(v) do
			RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Comb_Branch_Path.Award, #j, combid, chapterid)
		end
	end
end

function ChapterCombRDL.AddUnlockPlayerPrefs(_id)
	if table.contains(NEW_CHAPTER_COMB, tostring(_id)) then
		return
	end

	PersistentStoreUtil.AddList(KEY_RD_CHAPTER_COMB_UNLOCK, _id)

	local info = CombinationMgr:Get(_id)

	if info and info.data.Version == 1 and info.data.StageVersion == 1 then
		table.insert(NEW_CHAPTER_COMB, tostring(_id))
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Comb_Branch_Path.Unlock, 1, _id)
	end
end

function ChapterCombRDL.RemoveUnlockPlayerPrefs(_id)
	if not table.contains(NEW_CHAPTER_COMB, tostring(_id)) then
		return
	end

	table.removeByValue(NEW_CHAPTER_COMB, tostring(_id))
	PersistentStoreUtil.SetList(KEY_RD_CHAPTER_COMB_UNLOCK, NEW_CHAPTER_COMB)
	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Comb_Branch_Path.Unlock, 0, _id)
end

function ChapterCombRDL.DealUnlock(_stageid)
	local t = GetConfigArgJson("TeamChapterUnlock")

	for k, v in ipairs(t) do
		if v and v[1] and v[2] == _stageid then
			ChapterCombRDL.AddUnlockPlayerPrefs(v[1])

			break
		end
	end
end

function ChapterCombRDL.Add(_info)
	local preValue = #(CAN_RECEIVE_COMB_STAR_AWARD[_info.data.Team][_info.id] or {})

	CommFunc(_info)

	local curValue = #(CAN_RECEIVE_COMB_STAR_AWARD[_info.data.Team][_info.id] or {})

	if preValue == value then
		return
	end

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Comb_Branch_Path.Award, curValue, _info.data.Team, _info.id)
end

function ChapterCombRDL.Sub(_info, _idxs)
	local t = CAN_RECEIVE_COMB_STAR_AWARD[_info.data.Team][_info.id]
	local value = ChapterRDL.RemoveStarAwardIdx(t, _idxs)

	if value == 0 then
		return
	end

	RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Chapter_Comb_Branch_Path.Award, -value, _info.data.Team, _info.id)
end

return ChapterCombRDL
