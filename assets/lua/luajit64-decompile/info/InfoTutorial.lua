-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoTutorial.lua

require("Info/InfoChapter")

local data = require("luaData/Newbie")

InfoTutorial = class("InfoTutorial", InfoBase)
eSystemOpenReasonType = {
	Stage = 2,
	Level = 1
}

function InfoTutorial:ctor(id)
	self.id = id
	self.data = data[id]

	if self.id and self.id > 0 then
		TutorialMgr.dict:Set(self.id, self)
	end
end

TutorialMgr = {}
TutorialMgr.dict = TutorialMgr.dict or Record()
TutorialMgr.listAll = {}

local PreLevel = 0
local PreStage = 0
local ListOpenSystem = {}

function TutorialMgr:Get(id)
	local info = self.dict:GetValue(id)

	if info == nil then
		info = InfoTutorial(id)
	end

	return info
end

function TutorialMgr:ResetRecord()
	ListOpenSystem = {}
end

function TutorialMgr:IsNeedSwitchMainStage()
	return #ListOpenSystem > 0
end

function TutorialMgr:GetLevelUnlock(level)
	local t = {}

	for _, v in pairsByKeys(data) do
		if v.Level == level then
			local info = self:Get(v.ID)

			if info ~= nil then
				table.insert(t, info)
			end
		end
	end

	return t
end

function TutorialMgr:GetStageUnlock(stageId)
	local t = {}

	for _, v in pairsByKeys(data) do
		if v.Stage == stageId then
			local info = self:Get(v.ID)

			if info ~= nil then
				table.insert(t, info)
			end
		end
	end

	return t
end

function TutorialMgr:DealLevelOpenSystem()
	if PreLevel == PlayerInst:GetCurLv() then
		return
	end

	PreLevel = PlayerInst:GetCurLv()

	local list = self:GetLevelUnlock(PlayerInst:GetCurLv())

	if #list == 0 then
		return
	end

	local t = {}

	for _, v in ipairs(list) do
		if not table.contains(t, v) then
			if v.data.Type == 1 then
				if not table.contains(ListOpenSystem, v) then
					table.insert(ListOpenSystem, v)
				end
			else
				table.insert(t, v.id)
			end

			GuideMgr:ResetRecord(v.id)
			HelpRDL.AddUnreadHelpId(v.id)
		end
	end

	SystemOpenMgr.DealSystemsOpen(t)
end

function TutorialMgr:DealStageOpenSystem()
	if ChapterMgr.justUnLockStage == 0 then
		return
	end

	if PreStage == ChapterMgr.justUnLockStage then
		return
	end

	PreStage = ChapterMgr.justUnLockStage

	local list = self:GetStageUnlock(ChapterMgr.justUnLockStage)

	if #list == 0 then
		return
	end

	local t = {}

	for _, v in ipairs(list) do
		if not table.contains(t, v) then
			if v.data.Type == 1 then
				if not table.contains(ListOpenSystem, v) then
					table.insert(ListOpenSystem, v)
				end
			else
				table.insert(t, v.id)
			end

			GuideMgr:ResetRecord(v.id)
			HelpRDL.AddUnreadHelpId(v.id)
		end
	end

	SystemOpenMgr.DealSystemsOpen(t)

	ChapterMgr.justUnLockStage = 0
end

function TutorialMgr:GetListOpenSystem()
	return ListOpenSystem or {}
end

function TutorialMgr:IsOpen(id)
	if OpenAllLock then
		return {
			open = true
		}
	end

	local result = {}

	result.desc = ""
	result.open = false

	local info = self:Get(id)

	if info then
		if info.data.Level > 0 then
			if PlayerInst:GetCurLv() >= info.data.Level then
				result.open = true
			else
				result.desc = info.data.Level .. _("Prompt_TutorialLimitLevel")
				result.plevel = info.data.Level
			end
		end

		if info.data.Stage > 0 then
			local infoStage = ChapterMgr:GetStage(info.data.Stage)

			if infoStage and infoStage:IsPass() then
				result.open = true
			elseif infoStage.data.ChapterType == ChapterFromType.tower then
				local infoChapter = TowerChapterMgr:GetTowerChapter(info.data.Stage)
				local str = string.format(_("Msg_PassStageUnlock"), Lang(infoChapter.data.Name))

				result.desc = str
			else
				local infoChapter, i, j = ChapterMgr:GetChapterByStageID(infoStage.id)

				if infoChapter == nil or i == nil or j == nil then
					-- block empty
				else
					local strStage = "<color=yellow>" .. i .. "-" .. j .. "</color>"
					local str = string.format(_("Msg_PassStageUnlock"), strStage .. Lang(infoStage.data.Name))

					result.desc = str
					result.chapterIdx = i
					result.stageIdx = j
				end
			end
		end
	end

	return result
end

function TutorialMgr:IsOpenTutWithMessage(id, needMessage)
	local result = TutorialMgr:IsOpen(id)

	if not result.open then
		if needMessage then
			UIMgr.ShowMsg(result.desc)
		end

		return false
	end

	return true
end

function TutorialMgr:IsOpenTut(id)
	return self:IsOpenTutWithMessage(id, true)
end

function TutorialMgr:IsOpenNoMsg(id)
	return self:IsOpenTutWithMessage(id, false)
end

TutorialFunctionType = numEnumWithStartNum({
	"Fight",
	"Role",
	"Communication",
	"DrawCard",
	"Dress",
	"Gift",
	"TeamPass",
	"Talent",
	"Card",
	"CardPass",
	"Equipment",
	"Enchant",
	"AssetPass",
	"Theme",
	"Operation",
	"TimeTask",
	"Friend",
	"Player",
	"Shop",
	"Mail",
	"AD",
	"Option",
	"ThemeMode",
	"Boss",
	"Work",
	"CardLevel",
	"EquipLevel",
	"CardStar",
	"EquipQuality",
	"CardPetal",
	"Task",
	"Union",
	"PVP",
	"Tower",
	"Bondage",
	"Defficult",
	"BossLive",
	"Sweep",
	"BossRaid",
	"PatFace",
	"AutoFight",
	"SpeedFight",
	"Webview",
	"TowerHard",
	"Union_Wish",
	"Union_Raid",
	"PageRank",
	"PageRank_Union",
	"PageRank_BossRaid",
	"PageRank_Pvp",
	"OperationActive_BattlePass",
	"SkipTimelineBtn",
	"AutoSelectBtn"
}, 1)
