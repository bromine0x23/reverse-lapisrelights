-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/Common/ByStageUtil.lua

ByStageUtil = {}
RD_STAGE_PASS_TYPE = {
	First_Time = 1,
	Not_First_Time = 2
}

local STAGE, STAGE_TYPE, CHAPTER_TYPE

function ByStageUtil.Deal(stage, type)
	if stage == nil then
		return
	end

	STAGE = stage
	STAGE_TYPE = stage.data.Type
	CHAPTER_TYPE = stage.data.ChapterType

	if type == RD_STAGE_PASS_TYPE.First_Time then
		ByStageUtil.Unlock()
		ByStageUtil.Remove()
	end

	ByStageUtil.Grand()
end

function ByStageUtil.Unlock()
	if CHAPTER_TYPE == ChapterFromType.main then
		RoleRDL.InteractRDL.AddInteractARDance(STAGE.id)
		ManualRDL.StoryRDL.DealWith(STAGE.id)
		ChapterRDL.CombRDL.DealUnlock(STAGE.id)
	elseif CHAPTER_TYPE == ChapterFromType.tower then
		ChapterRDL.TowerRDL.DealUnlock(STAGE.id)
	elseif CHAPTER_TYPE == ChapterFromType.activity then
		if STAGE_TYPE == StageFromType.activeCommon then
			ChapterRDL.PartyRDL.DealUnlock(STAGE.id)
		elseif STAGE_TYPE == StageFromType.story then
			ChapterRDL.PartyRDL.DealComplete(STAGE.id)
		else
			local active = ActiveMgr:GetActiveInfoByStageData(STAGE.data)

			if active and active.data and active.data.Type == eActiveType.asset then
				ChapterRDL.AssetRDL.DealNew(active.data.ID)
			end
		end
	end
end

function ByStageUtil.Grand()
	if STAGE_TYPE ~= StageFromType.story then
		ChapterRDL.DealAddStarAward(STAGE.data.ChapterID)
	end
end

function ByStageUtil.Remove()
	if CHAPTER_TYPE == ChapterFromType.card then
		local cardId = ChapterMgr:GetChapter(STAGE.data.ChapterID).data.Card

		CardRDL.StageRDL.RunCardStageStory(RoleCardMgr:GetRoleCard(cardId))
	end
end

return ByStageUtil
