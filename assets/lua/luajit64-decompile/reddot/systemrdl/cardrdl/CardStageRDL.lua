-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/CardRDL/CardStageRDL.lua

local CardStageRDL = {}
local KEY_RD_CARD_STAGE_STORY = "KEY_RD_CARD_STAGE_STORY"
local KEY_RD_CARD_STAGE_FIGHT = "KEY_RD_CARD_STAGE_FIGHT"
local PRE_FIGHT_DOT_VALUE = {}

local function IsCardStoryNew(card)
	local stage = CardChapterMgr.GetCardChapterStory(card.id)

	if stage and not stage:IsPass() and card.curPetal > 0 then
		return true
	end

	return false
end

function CardStageRDL.RunCardStage(card)
	CardStageRDL.RunCardStageStory(card)
	CardStageRDL.RunCardStageFight(card)
end

function CardStageRDL.RunCardStageStory(card)
	local value = 0

	if IsCardStoryNew(card) then
		value = 1
	end

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Card_Branch_Path.Stage_Story, value, card.id)
end

function CardStageRDL.RunCardStageFight(card)
	local value = 0
	local listStage = CardChapterMgr.GetCardChapter(card.id).listStage

	for _, v in ipairs(listStage) do
		if v.data.Type ~= StageFromType.story and v:IsUnlock() then
			local leftNum = ChapterMgr:GetStageLeftPlayNumWithLimit(v.id)

			if leftNum == -1 or leftNum > 0 then
				value = 1

				break
			end
		end
	end

	if PRE_FIGHT_DOT_VALUE[card.id] ~= value then
		PRE_FIGHT_DOT_VALUE[card.id] = value

		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Card_Branch_Path.Stage_Fight, value, card.id)
	end
end

function CardStageRDL.ResetCardStageFight()
	for _, card in ipairs(CardRDL.ALL_HOLD_CARD) do
		CardStageRDL.RunCardStageFight(card)
	end
end

return CardStageRDL
