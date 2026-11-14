-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/ChapterRDL/ChapterPartyRDL.lua

local ChapterPartyRDL = {}
local RD_Chapter_Party_Branch_Path = {
	Unlock = "Chapter/Party/Unlock",
	Story = "Chapter/Party/Story",
	Draw = "Chapter/Party/Draw",
	Boss = "Chapter/Party/Boss"
}
local KEY_RDL_CHAPTER_PARTY_BOSS = "KEY_RDL_CHAPTER_PARTY_BOSS"
local IS_VIEWED = false
local CUR_PARTY_ACTIVE, DRAW_COST
local CAN_DRAW = false
local CUR_NEW_STORY = {}
local CUR_LOCK_STORY = {}
local CAN_BATTLE_BOSS = false
local clickTime = ""

function ChapterPartyRDL.Init()
	CUR_PARTY_ACTIVE = ActiveMgr:GetOpenActiveByType(eActiveType.boss)[1]

	if CUR_PARTY_ACTIVE == nil then
		return
	end

	DRAW_COST = ActiveCardPoolMgr:GetAll(CUR_PARTY_ACTIVE.id)[1].data.OneCost

	local infoChapter = ChapterMgr:GetChapter(CUR_PARTY_ACTIVE.storyChapterId)

	for _, stage in pairs(infoChapter.listStage) do
		if not table.contains(infoChapter.data.InitStage, stage.id) then
			local isUnlock = ActiveMgr:GetUnlockStoryStage(stage.id):IsPass()

			if isUnlock then
				if not stage:IsPass() then
					table.insert(CUR_NEW_STORY, stage.id)
				end
			else
				table.insert(CUR_LOCK_STORY, stage.id)
			end
		end
	end

	clickTime = PersistentStoreUtil.GetString(KEY_RDL_CHAPTER_PARTY_BOSS)

	local infoChapter = ChapterMgr:GetChapter(CUR_PARTY_ACTIVE.bossChapterId)

	for _, stage in pairs(infoChapter.listStage) do
		if stage.data.ActType == 20 and stage:IsOpen() then
			if clickTime ~= "" and TimeIsToday(clickTime) then
				CAN_BATTLE_BOSS = false

				break
			end

			CAN_BATTLE_BOSS = true

			break
		else
			CAN_BATTLE_BOSS = false
		end
	end

	ChapterPartyRDL.InitRD()
end

function ChapterPartyRDL.InitRD()
	local isPlayOpen, _ = CUR_PARTY_ACTIVE:IsPlayOpen()

	ChapterPartyRDL.DealSyetemOpen()

	if DRAW_COST ~= nil then
		local need = DRAW_COST[2] or 0
		local hold = ItemManager:GetItemCount(DRAW_COST[1])

		if need <= hold then
			CAN_DRAW = true

			RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Party_Branch_Path.Draw, 1)
		end
	end

	if isPlayOpen then
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Party_Branch_Path.Story, #CUR_NEW_STORY)

		if CAN_BATTLE_BOSS then
			RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Party_Branch_Path.Boss, 1)
		end
	end
end

function ChapterPartyRDL.DealDraw()
	if DRAW_COST == nil then
		return
	end

	local need = DRAW_COST[2] or 0
	local hold = ItemManager:GetItemCount(DRAW_COST[1])

	if need <= hold ~= CAN_DRAW then
		CAN_DRAW = need <= hold

		if CAN_DRAW then
			RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Party_Branch_Path.Draw, 1)
		else
			RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Party_Branch_Path.Draw, 0)
		end
	end
end

function ChapterPartyRDL.DealUnlock(_stageid)
	if CUR_PARTY_ACTIVE == nil then
		return
	end

	local stage = ChapterMgr:GetStage(_stageid)

	if not stage then
		return
	end

	local preValue = #CUR_NEW_STORY
	local unlockStageIds = stage.data.AssignUnlock

	for _, v in pairs(unlockStageIds) do
		if table.contains(CUR_LOCK_STORY, v) then
			table.removeByValue(CUR_LOCK_STORY, v)
			table.insert(CUR_NEW_STORY, v)
		end
	end

	local value = #CUR_NEW_STORY - preValue

	if value > 0 then
		RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Chapter_Party_Branch_Path.Story, value)
	end
end

function ChapterPartyRDL.DealComplete(_stageid)
	if CUR_PARTY_ACTIVE == nil then
		return
	end

	if not table.contains(CUR_NEW_STORY, _stageid) then
		return
	end

	RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Chapter_Party_Branch_Path.Story, -1)
end

function ChapterPartyRDL.DealBoss()
	if CUR_PARTY_ACTIVE == nil then
		return
	end

	local infoChapter = ChapterMgr:GetChapter(CUR_PARTY_ACTIVE.bossChapterId)

	clickTime = PersistentStoreUtil.GetString(KEY_RDL_CHAPTER_PARTY_BOSS)

	for _, stage in pairs(infoChapter.listStage) do
		if stage.data.ActType == 20 and stage:IsOpen() and stage:GetLeftPlayNum() > 0 then
			if clickTime ~= "" and TimeIsToday(clickTime) then
				CAN_BATTLE_BOSS = false

				break
			end

			CAN_BATTLE_BOSS = true

			break
		else
			CAN_BATTLE_BOSS = false
		end
	end

	if CAN_BATTLE_BOSS then
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Party_Branch_Path.Boss, 1)
	else
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Party_Branch_Path.Boss, 0)
	end
end

function ChapterPartyRDL.DealBossClick()
	clickTime = PersistentStoreUtil.SetString(KEY_RDL_CHAPTER_PARTY_BOSS, NetData:GetCurServerTime())

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Party_Branch_Path.Boss, 0)
end

function ChapterPartyRDL.Reset()
	if CUR_PARTY_ACTIVE == nil then
		return
	end

	local infoChapter = ChapterMgr:GetChapter(CUR_PARTY_ACTIVE.bossChapterId)

	for _, stage in pairs(infoChapter.listStage) do
		if stage.data.ActType == 20 and stage:IsOpen() then
			CAN_BATTLE_BOSS = true

			break
		else
			CAN_BATTLE_BOSS = false
		end
	end

	if CAN_BATTLE_BOSS then
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Party_Branch_Path.Boss, 1)
	else
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Party_Branch_Path.Boss, 0)
	end

	clickTime = ""

	PersistentStoreUtil.SetString(KEY_RDL_CHAPTER_PARTY_BOSS, "")
end

function ChapterPartyRDL.DealSyetemOpen()
	if IS_VIEWED then
		return
	end

	IS_VIEWED = SystemOpenMgr.GetSystemOpenPlayerPrefs(TutorialFunctionType.Boss)

	if not IS_VIEWED then
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Party_Branch_Path.Unlock, 1)
	end
end

function ChapterPartyRDL.ViewedSystem()
	if IS_VIEWED then
		return
	end

	IS_VIEWED = true

	RedDotSystemMgr.RemoveNode(RD_Chapter_Party_Branch_Path.Unlock)
	SystemOpenMgr.SetSystemOpenPlayerPrefs(TutorialFunctionType.Boss, true)
end

function ChapterPartyRDL.UpdateBegin()
	ChapterPartyRDL.Init()
end

function ChapterPartyRDL.UpdateEnd()
	RedDotSystemMgr.RemoveNode(RD_Chapter_Party_Branch_Path.Story)
end

return ChapterPartyRDL
