-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/ChapterRDL/ChapterCardRDL.lua

local ChapterCardRDL = {}
local RD_Chapter_Card_Branch_Path = {
	PlayNum = "Chapter/Card/PlayNum"
}
local CHAPTER_CARD_LEFT_CHALLENGE_NUMBER = 0
local PRE_PLAY_NUM_DOT_VALUE = 0

function ChapterCardRDL.Reset()
	CHAPTER_CARD_LEFT_CHALLENGE_NUMBER = CardChapterMgr.GetTotalRemainingChallengeNum()

	ChapterCardRDL.InitRD()
end

function ChapterCardRDL.Init()
	ChapterCardRDL.Reset()
end

function ChapterCardRDL.InitRD()
	local value = 0

	if CHAPTER_CARD_LEFT_CHALLENGE_NUMBER == -1 or CHAPTER_CARD_LEFT_CHALLENGE_NUMBER > 0 then
		value = 1
	end

	if PRE_PLAY_NUM_DOT_VALUE ~= value then
		PRE_PLAY_NUM_DOT_VALUE = value

		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Card_Branch_Path.PlayNum, value)
	end
end

function ChapterCardRDL.ChangeChallengeNum(vChange)
	CHAPTER_CARD_LEFT_CHALLENGE_NUMBER = CHAPTER_CARD_LEFT_CHALLENGE_NUMBER + vChange

	ChapterCardRDL.InitRD()
end

return ChapterCardRDL
