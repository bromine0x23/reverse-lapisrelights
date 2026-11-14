-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/ChapterRDL/ChapterAssetRDL.lua

local ChapterAssetRDL = {}

CHAPTER_ASSET_TYPE = {
	Exp = "Exp",
	Gold = "Gold",
	Item = "Item"
}

local RD_Chapter_Asset_Branch_Path = {
	Exp = "Chapter/Asset/Exp",
	Gold = "Chapter/Asset/Gold",
	Item = "Chapter/Asset/Item"
}
local KEY_RD_CHAPTER_ASSET = {
	Exp = "KEY_RD_CHAPTER_ASSET_EXP",
	Gold = "KEY_RD_CHAPTER_ASSET_GOLD",
	Item = "KEY_RD_CHAPTER_ASSET_ITEM"
}
local List_Active = {}
local NEW_STAGE_TYPES = {}

local function GetTypeByActiveId(activeId)
	if activeId == 101 then
		return CHAPTER_ASSET_TYPE.Gold
	elseif activeId == 102 then
		return CHAPTER_ASSET_TYPE.Exp
	elseif activeId == 106 then
		return CHAPTER_ASSET_TYPE.Item
	end

	return nil
end

function ChapterAssetRDL.Init()
	List_Active = PassMgr:GetBranchActiveList(3, PassMgr:GetListAssetBranchId(3)[1])

	ChapterAssetRDL.InitRD()
end

function ChapterAssetRDL.InitRD()
	for _, v in pairs(List_Active) do
		ChapterAssetRDL.DealNew(v.ID)
	end
end

function ChapterAssetRDL.DealNew(activeId)
	local _type = GetTypeByActiveId(activeId)
	local stages = ChapterMgr:GetUnLockStageList(ActiveMgr:GetActiveChapter(activeId))
	local newStage = stages[#stages]
	local isNew = newStage:IsNew()
	local isEnter = PersistentStoreUtil.GetStageEnter(newStage.id)
	local isFull = PlayerInst:GetCurLv() >= newStage.data.LevelUnlock
	local value = 0

	if isNew and not isEnter and isFull then
		value = 1
	end

	if value == NEW_STAGE_TYPES[_type] then
		return
	end

	NEW_STAGE_TYPES[_type] = 1

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Asset_Branch_Path[_type], value)
end

function ChapterAssetRDL.DealSubNew(activeId)
	if activeId == nil then
		return
	end

	local _type = GetTypeByActiveId(activeId)

	if _type == nil then
		return
	end

	NEW_STAGE_TYPES[_type] = 0

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Chapter_Asset_Branch_Path[_type], 0)
end

function ChapterAssetRDL.DealPLvUnlockStage()
	for _, v in pairs(List_Active) do
		ChapterAssetRDL.DealNew(v.ID)
	end
end

return ChapterAssetRDL
