-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/ChapterRDL/ChapterTowerRDL.lua

local ChapterTowerRDL = {}
local RD_Chapter_Tower_Branch_Path = {
	Daily_Award = "Chapter/Tower/Award",
	Common_Pass_Award = "Chapter/Tower/Common/%d/Award",
	Hard_Pass_Award = "Chapter/Tower/Hard/%d/Award"
}
local Tower_Chapters = {}
local Tower_Award_Times = 0
local Tower_Received_Times = 0
local Tower_Award_Unlock_StageId = 0
local CAN_RECEIVE_PASS_AWARD = {}

function ChapterTowerRDL.Reset()
	Tower_Received_Times = 0

	ChapterTowerRDL.InitRD()
end

function ChapterTowerRDL.Init()
	Tower_Award_Times = TowerChapterMgr:GetDailyAwardCount()
	Tower_Received_Times = TowerChapterMgr.dailyTimes
	Tower_Chapters[ChapterFromType.tower] = TowerChapterMgr:GetAllTower(ChapterFromType.tower)
	Tower_Chapters[ChapterFromType.towerhard] = TowerChapterMgr:GetAllTower(ChapterFromType.towerhard)
	CAN_RECEIVE_PASS_AWARD[ChapterFromType.tower] = {}
	CAN_RECEIVE_PASS_AWARD[ChapterFromType.towerhard] = {}

	local stage = Tower_Chapters[ChapterFromType.tower][1].listStage[1]

	if not stage:IsPass() then
		Tower_Award_Unlock_StageId = stage.id
	end

	ChapterTowerRDL.InitRD()
	ChapterTowerRDL.InitPassRD()
end

function ChapterTowerRDL.InitRD()
	if Tower_Award_Unlock_StageId == 0 then
		local value = Tower_Award_Times - Tower_Received_Times

		value = value < 0 and 0 or value

		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Tower_Branch_Path.Daily_Award, value)
	end
end

function ChapterTowerRDL.InitPassRD()
	local function fun(chapter, path)
		local hasAward = chapter.pb.awardStatus[3] ~= 1 and chapter:IsPass()

		if hasAward then
			table.insert(CAN_RECEIVE_PASS_AWARD[chapter.data.Type], chapter.id)
			RedDotSystemMgr.SetNodeValueByFormatPath(path, 1, chapter.id)
		end
	end

	for k, chapter in ipairs(Tower_Chapters[ChapterFromType.tower]) do
		fun(chapter, RD_Chapter_Tower_Branch_Path.Common_Pass_Award)
	end

	for k, chapter in ipairs(Tower_Chapters[ChapterFromType.towerhard]) do
		fun(chapter, RD_Chapter_Tower_Branch_Path.Hard_Pass_Award)
	end
end

function ChapterTowerRDL.Sub()
	Tower_Received_Times = Tower_Received_Times + 1

	RedDotSystemMgr.ChangeNodeValueByFormatPath(RD_Chapter_Tower_Branch_Path.Daily_Award, -1)
end

function ChapterTowerRDL.Add()
	local value = TowerChapterMgr:GetDailyAwardCount()

	if Tower_Award_Times == value then
		return
	end

	Tower_Award_Times = value

	ChapterTowerRDL.InitRD()
end

function ChapterTowerRDL.DealUnlock(stageid)
	if Tower_Award_Unlock_StageId == 0 then
		return
	end

	if Tower_Award_Unlock_StageId == stageid then
		Tower_Award_Unlock_StageId = 0

		ChapterTowerRDL.InitRD()
	end
end

function ChapterTowerRDL.AddPassAward()
	ChapterTowerRDL.InitPassRD()
end

function ChapterTowerRDL.SubPassAward(_info)
	local temp = CAN_RECEIVE_PASS_AWARD[_info.data.Type] or {}

	if table.contains(temp, _info.id) then
		table.removeByValue(temp, _info.id)

		local path = ""

		if _info.data.Type == ChapterFromType.tower then
			path = RD_Chapter_Tower_Branch_Path.Common_Pass_Award
		else
			path = RD_Chapter_Tower_Branch_Path.Hard_Pass_Award
		end

		RedDotSystemMgr.SetNodeValueByFormatPath(path, 0, _info.id)
	end
end

return ChapterTowerRDL
