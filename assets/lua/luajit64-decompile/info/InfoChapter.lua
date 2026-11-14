-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoChapter.lua

require("Info/InfoStage")

local ChapterData = require("luaData/ChapterData")
local ChapterGroupData = require("luaData/ChapterGroupData")
local CharacterTeam = require("luaData/CharacterTeam")
local CallTopicAward = require("luaData/CallTopicAward")

ChapterMgr = {}
ChapterMgr.dictChapter = ChapterMgr.dictChapter or Record()
ChapterMgr.dictStage = ChapterMgr.dictStage or Record()
ChapterMgr.unlockChapterId = 0
ChapterMgr.listChapter = nil
ChapterMgr.curSelectStageId = 0
ChapterMgr.curStageIndex = 0
ChapterMgr.CurChapterId = 0
ChapterMgr.CurChapterEnumIndex = 0
ChapterMgr.teamIndex = 0
ChapterMgr.bossIndex = 0
ChapterMgr.cardIndex = 0
ChapterMgr.cardEquipTabIndex = 0
ChapterMgr.resIndex = 0
ChapterMgr.resTabIndex = 0
ChapterMgr.PageCombatReadinessType = 1
ChapterMgr.BossLiveToTeam = 0
ChapterMgr.BossLiveTempIndex = 0
ChapterMgr.NextStageState = -1
ChapterMgr.ChapterTeamIdx = 1
ChapterMgr.CombPage = {}
ChapterMgr.BossActivityStageType = nil
ChapterMgr.BossActivityFirstOpen = false
ChapterMgr.IsForecastState = nil
ChapterMgr.justUnLockStage = 0
ChapterMgr.teamCE = 0
ChapterMgr.IsChallengeAgain = false
ChapterFromType = {
	bosslive = 102,
	tower = 101,
	mainhard = 6,
	union = 100,
	role = 3,
	activity = 4,
	comb = 2,
	main = 1,
	bossRaid = 103,
	towerhard = 104,
	timespace = 119,
	card = 5
}
StageFromType = {
	bossRaid = 10,
	towerHard = 8,
	timespace = 11,
	bossLive = 9,
	unionCommon = 7,
	unionBoss = 6,
	activeCommon = 5,
	story = 2,
	common = 1,
	activeBoss = 4
}
ChapterType = {
	bosslive = "bosslive",
	tower = "tower",
	mainhard = "mainhard",
	main = "main",
	towerhard = "towerhard",
	role = "role",
	comb = "comb",
	event = "event",
	timespace = "timespace",
	card = "card"
}
InfoChapter = class("InfoChapter", InfoBase)

function InfoChapter:ctor(id)
	self.data = ChapterData[id]

	if self.data == nil then
		return
	end

	self.listStage = {}

	for i = 1, #self.data.StageID do
		local id = self.data.StageID[i]
		local stage = ChapterMgr:GetStage(id)

		table.insert(self.listStage, stage)
	end

	ChapterMgr.dictChapter:Set(self.id, self)
end

function InfoChapter:IsOpen()
	if next(self.listStage) == nil then
		return false
	end

	return self.listStage[1]:IsOpen()
end

function InfoChapter:IsNew()
	if next(self.listStage) == nil then
		return false
	end

	return self.listStage[1]:IsNew()
end

function InfoChapter:IsPass()
	if next(self.listStage) == nil then
		return false
	end

	return self.listStage[#self.listStage].pb.isPass
end

function InfoChapter:CanDailyReward()
	local haveOpen = false

	for i, infoStage in ipairs(self.listStage) do
		if infoStage:IsOpen() then
			haveOpen = true

			if infoStage.pb.playNum > 0 then
				return false
			end
		end
	end

	if haveOpen then
		return true
	end

	return false
end

function InfoChapter:GetChapterAwardList()
	local curIndex = 1
	local list = {}
	local listStar = {
		self.data.CopperStar,
		self.data.SilverStar,
		self.data.GoldStar
	}
	local listItem = {
		self.data.CopperAwardList,
		self.data.SilverAwardList,
		self.data.GoldAwardList
	}

	for i = 1, 3 do
		local data = {}

		data.state = self.pb.awardStatus[i]
		data.star = listStar[i]

		local tempList = listItem[i]
		local items = {}

		for j = 1, #tempList do
			local tempItem = tempList[j]
			local item = ItemManager:GetValueItem(tempItem[1], tempItem[2])

			table.insert(items, item)
		end

		data.items = items

		table.insert(list, data)
	end

	for i = 1, 3 do
		local n = 4 - i
		local state = self.pb.awardStatus[n]

		if state == 0 then
			curIndex = n
		end
	end

	return list, curIndex
end

function InfoChapter:GetCanReceiveStarAwardList()
	local listStar = {
		self.data.CopperStar,
		self.data.SilverStar,
		self.data.GoldStar
	}
	local t = {}

	for k in ipairs(listStar) do
		if self.pb.awardStatus[k] == 0 and self:GetStar() >= listStar[k] and not table.contains(t, k) then
			table.insert(t, k)
		end
	end

	return t
end

function InfoChapter:GetStar()
	local star = 0

	for i = 1, #self.listStage do
		local infoStage = self.listStage[i]

		if infoStage.data and infoStage.data.Type ~= 2 then
			star = star + infoStage:GetStar()
		end
	end

	return star
end

function InfoChapter:GetAllStar()
	local allStarCnt = 0

	for i = 1, #self.listStage do
		local infoStage = self.listStage[i]

		if infoStage.data.Type == 1 or infoStage.data.Type == 3 or infoStage.data.Type == 9 or infoStage.data.Type == 11 then
			allStarCnt = allStarCnt + 3
		end
	end

	return allStarCnt
end

function InfoChapter:GetLastStageId()
	local infoStage = self.listStage[#self.listStage]

	return infoStage.data.ID
end

function ChapterMgr:SetData(pbChapters)
	for i = 1, #pbChapters do
		local pbChapter = pbChapters[i]
		local infoChapter = ChapterMgr:GetChapter(tonumber(pbChapter.id))

		infoChapter.pb = pbChapter

		if pbChapter.stages ~= nil then
			for i = 1, #pbChapter.stages do
				local pbStage = pbChapter.stages[i]
				local infoStage = ChapterMgr:GetStage(tonumber(pbStage.id))

				infoStage:SetData(pbStage)
			end
		end
	end

	self:UpdateProcess()
end

function ChapterMgr:GetChapter(vChapterId)
	if type(vChapterId) == "string" then
		vChapterId = tonumber("0x" .. vChapterId)
	end

	local ret = self.dictChapter:GetValue(vChapterId)

	if not ret then
		ret = InfoChapter(vChapterId)
		ret.pb.id = vChapterId
		ret.pb.awardStatus = {
			0,
			0,
			0
		}
		ret.pb.stages = nil
	end

	return ret
end

function ChapterMgr:GetStage(stageId)
	stageId = tonumber(stageId)

	local infoStage = self.dictStage:GetValue(stageId)

	if infoStage == nil then
		infoStage = InfoStage(stageId)

		self.dictStage:Set(stageId, infoStage)
	end

	return infoStage
end

function ChapterMgr:GetNewBieListString()
	local data = require("luaData/Newbie")
	local list = {}

	for k, v in pairs(data) do
		if v.ShowTips ~= 0 and v.Stage ~= 0 then
			table.insert(list, v)
		end
	end

	local chapterInfoList = ChapterMgr:GetChapterList(ChapterType.main)
	local newBieList = list
	local infoStage = ChapterMgr:GetCurStage()

	if not infoStage then
		return nil
	end

	local chapterInfo, chapterIndex, stageIndex = ChapterMgr:GetChapterByStageID(infoStage.id)
	local selInfo, nextInfo

	for k, v in pairs(chapterInfoList) do
		if chapterInfo and v.id == chapterInfo.id then
			selInfo = v
		elseif chapterInfo and chapterInfo.id + 1 == v.id then
			nextInfo = v
		end
	end

	local rangeStageList = {}

	if selInfo and #selInfo.data.StageID - stageIndex >= 4 then
		local minStageID = selInfo.data.StageID[stageIndex]
		local maxStageID = selInfo.data.StageID[stageIndex + 5 - 1]

		rangeStageList[1] = {}
		rangeStageList[1].min = minStageID
		rangeStageList[1].max = maxStageID
	else
		if selInfo then
			local minStageID = selInfo.data.StageID[stageIndex]
			local maxStageID = selInfo.data.StageID[#selInfo.data.StageID]

			rangeStageList[1] = {}
			rangeStageList[1].min = minStageID
			rangeStageList[1].max = maxStageID
		end

		if nextInfo then
			local minStageID = nextInfo.data.StageID[1]
			local maxStageID = nextInfo.data.StageID[5 - math.abs(#selInfo.data.StageID - stageIndex) - 1]

			rangeStageList[2] = {}
			rangeStageList[2].min = minStageID
			rangeStageList[2].max = maxStageID
		end
	end

	local selNewBieInfo = {}

	for k, v in pairs(newBieList) do
		if rangeStageList and rangeStageList[1] and rangeStageList[1].min <= v.Stage and rangeStageList[1].max >= v.Stage then
			table.insert(selNewBieInfo, v)
		elseif rangeStageList and rangeStageList[2] and rangeStageList[2].min <= v.Stage and rangeStageList[2].max >= v.Stage then
			table.insert(selNewBieInfo, v)
		end
	end

	if #selNewBieInfo >= 2 then
		table.sort(selNewBieInfo, function(a, b)
			return tonumber(a.Stage) < tonumber(b.Stage)
		end)
	end

	if #selNewBieInfo == 0 then
		return nil
	elseif selNewBieInfo[1] then
		chapterInfo, chapterIndex, stageIndex = ChapterMgr:GetChapterByStageID(tonumber(selNewBieInfo[1].Stage))

		return selNewBieInfo[1], string.format(_("Desc_System_Open_Prompt"), tostring(chapterIndex), tostring(stageIndex))
	end
end

function ChapterMgr:SetNextStageShow()
	local time = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local next_stageInfo, next_stage_str = ChapterMgr:GetNewBieListString()

	self.NextStageShow = time .. "_" .. next_stageInfo.Stage
	self.next_stage = tonumber(next_stageInfo.Stage)

	PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_NEXT_STAGE_SHOW, self.NextStageShow)
end

function ChapterMgr:GetNextStageShow(stage)
	if not self.NextStageShow then
		local str = PersistentStoreUtil.GetString(PersistentStoreUtil.KEY_NEXT_STAGE_SHOW)

		if str == "" then
			str = "0_0"
		end

		self.NextStageShow = str

		tonumber(string.split(self.NextStageShow, "_")[1])
	end

	if not self.next_stage and stage then
		self.next_stage = stage

		if tonumber(string.split(self.NextStageShow, "_")[2]) ~= self.next_stage then
			self.NextStageShow = "0_0"
		end
	elseif self.next_stage and stage then
		self.next_stage = stage

		if tonumber(string.split(self.NextStageShow, "_")[2]) ~= self.next_stage then
			self.NextStageShow = "0_0"
		end
	end

	if isBackMain then
		self.next_stageInfo.Stage, next_stage_str = ChapterMgr:GetNewBieListString()
	end

	local next_stageInfo, next_stage_str = ChapterMgr:GetNewBieListString()
	local curTime = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local time = GetConfigArgInt("BubbleSwitch")

	if tonumber(string.split(self.NextStageShow, "_")[2]) == 0 then
		return true
	elseif tonumber(string.split(self.NextStageShow, "_")[2]) ~= 0 then
		if time < curTime - tonumber(string.split(self.NextStageShow, "_")[1]) then
			self.NextStageShow = "0_0"

			PersistentStoreUtil.SetString(PersistentStoreUtil.KEY_NEXT_STAGE_SHOW, self.NextStageShow)

			return true
		elseif time >= curTime - tonumber(string.split(self.NextStageShow, "_")[1]) then
			return false
		end
	end

	return true
end

function ChapterMgr:GetChapterByStage(val)
	local stageId = val

	if type(val) == "table" then
		stageId = val.id
	end

	local infoStage = self:GetStage(stageId)
	local infoChapter = self:GetChapter(infoStage.data.ChapterID)

	return infoChapter
end

function ChapterMgr:SetBatteleEnumID(id)
	PersistentStoreUtil.SetInt(PersistentStoreUtil.KEY_BATTLE_ENUM_ID, id)
end

function ChapterMgr:GetBatteleEnumID()
	local value = PersistentStoreUtil.GetInt(PersistentStoreUtil.KEY_BATTLE_ENUM_ID)

	return value
end

function ChapterMgr:SetBatteleHardEnumID(id)
	PersistentStoreUtil.SetInt(PersistentStoreUtil.KEY_BATTLE_HARD_ENUM_ID, id)
end

function ChapterMgr:GetBatteleHardEnumID()
	local value = PersistentStoreUtil.GetInt(PersistentStoreUtil.KEY_BATTLE_HARD_ENUM_ID)

	return value
end

function ChapterMgr:SetBatteleTypeEnumID(id)
	PersistentStoreUtil.SetInt(PersistentStoreUtil.KEY_BATTLE_TYPE_ENUM_ID, id)
end

function ChapterMgr:GetBatteleTypeEnumID()
	local value = PersistentStoreUtil.GetInt(PersistentStoreUtil.KEY_BATTLE_TYPE_ENUM_ID)

	return value or 0
end

function ChapterMgr:InitChapterList()
	self.listAllChapter = {}
	self.listCurChapter = {}

	for k, v in pairsByKeys(ChapterData) do
		local cType = v.Type
		local infoChapter = ChapterMgr:GetChapter(k)

		if cType == 1 then
			self.listAllChapter[ChapterType.main] = self.listAllChapter[ChapterType.main] or {}

			table.insert(self.listAllChapter[ChapterType.main], infoChapter)
		elseif cType == 2 then
			self.listAllChapter[ChapterType.comb .. v.Team] = self.listAllChapter[ChapterType.comb .. v.Team] or {}

			table.insert(self.listAllChapter[ChapterType.comb .. v.Team], infoChapter)
		elseif cType == 3 then
			self.listAllChapter[ChapterType.role .. v.Role] = self.listAllChapter[ChapterType.role .. v.Role] or {}

			table.insert(self.listAllChapter[ChapterType.role .. v.Role], infoChapter)
		elseif cType == 4 then
			self.listAllChapter[ChapterType.event] = self.listAllChapter[ChapterType.event] or {}

			table.insert(self.listAllChapter[ChapterType.event], infoChapter)
		elseif cType == 5 then
			self.listAllChapter[ChapterType.card .. v.Card] = self.listAllChapter[ChapterType.card .. v.Card] or {}

			table.insert(self.listAllChapter[ChapterType.card .. v.Card], infoChapter)
		elseif cType == 6 then
			self.listAllChapter[ChapterType.mainhard] = self.listAllChapter[ChapterType.mainhard] or {}

			table.insert(self.listAllChapter[ChapterType.mainhard], infoChapter)
		elseif cType == 101 then
			self.listAllChapter[ChapterType.tower] = self.listAllChapter[ChapterType.tower] or {}

			table.insert(self.listAllChapter[ChapterType.tower], infoChapter)
		elseif cType == 104 then
			self.listAllChapter[ChapterType.towerhard] = self.listAllChapter[ChapterType.towerhard] or {}

			table.insert(self.listAllChapter[ChapterType.towerhard], infoChapter)
		elseif cType == 102 then
			self.listAllChapter[ChapterType.bosslive] = self.listAllChapter[ChapterType.bosslive] or {}

			table.insert(self.listAllChapter[ChapterType.bosslive], infoChapter)
		elseif cType == ChapterFromType.timespace then
			self.listAllChapter[ChapterType.timespace] = self.listAllChapter[ChapterType.timespace] or {}

			table.insert(self.listAllChapter[ChapterType.timespace], infoChapter)
		end
	end
end

function ChapterMgr:GetChapterList(cType, id)
	if cType == ChapterType.comb or cType == ChapterType.role or cType == ChapterType.card then
		return self.listAllChapter[cType .. id]
	else
		return self.listAllChapter[cType]
	end
end

function ChapterMgr:UpdateProcess()
	for k, v in pairs(self.listAllChapter) do
		for i = 1, #v do
			local info = v[i]

			if info:IsOpen() then
				self.listCurChapter[k] = info
			end
		end
	end
end

function ChapterMgr:ResetPlayNum()
	for _, infoStage in pairs(ChapterMgr.dictStage:GetValues()) do
		if infoStage then
			infoStage.pb.playNum = 0
		end
	end

	CardRDL.StageRDL.ResetCardStageFight()
	ChapterRDL.CardRDL.Reset()
end

function ChapterMgr:GetPlayNum(chapterId)
	local infoChapter = self:GetChapter(chapterId)
	local playNum = 0

	for i = 1, #infoChapter.listStage do
		local infoStage = infoChapter.listStage[i]

		playNum = playNum + infoStage.pb.playNum
	end

	return playNum
end

function ChapterMgr:ChapterGroupDataList(type)
	local listData = {}

	if type == 1 then
		for k, v in pairsByKeys(ChapterGroupData) do
			if v.Type == 1 then
				table.insert(listData, v)
			end
		end
	else
		for k, v in pairsByKeys(ChapterGroupData) do
			if v.Type == 2 then
				table.insert(listData, v)
			end
		end
	end

	return listData
end

function ChapterMgr:GetChapterByStageID(stageId)
	local chapterType = self:GetStage(stageId).data.ChapterType
	local chapterList = self:GetChapterList("main")

	if chapterType == ChapterFromType.mainhard then
		chapterList = self:GetChapterList("mainhard")
	end

	for _, v in ipairs(chapterList) do
		for i, j in ipairs(v.listStage) do
			if j.id == stageId then
				local idx = self:GetChapterIdx(v.data.ID)

				return v, idx, i
			end
		end
	end

	self.listComb = {}

	local list = GetConfigArgJson("TeamChapterUnlock")

	for _, v in ipairs(list) do
		if v and v[1] then
			local info = CombinationMgr:Get(v[1])

			table.insert(self.listComb, info)
		end
	end

	for n = 1, 7 do
		chapterList = self:GetChapterList("comb", n)

		for _, v in ipairs(chapterList) do
			for i, j in ipairs(v.listStage) do
				if j.id == stageId then
					local idx = self:GetChapterIdx(v.data.ID)

					return v, CharacterTeam[n].Name, v.data.Name
				end
			end
		end
	end

	return nil
end

function ChapterMgr:GetChapterIdx(chapterId)
	local infoChapter = ChapterMgr:GetChapter(chapterId)

	if not infoChapter or not infoChapter.data then
		return 1
	end

	local chapNum = Lang(infoChapter.data.TitleNumber)

	if infoChapter.data.ID ~= 100 then
		chapNum = tonumber(Lang(infoChapter.data.TitleNumber))
	end

	return chapNum
end

function ChapterMgr:GetStageIndex(stageId)
	local infoChapter = self:GetChapter(self:GetStage(stageId).data.ChapterID)

	if infoChapter.Type ~= ChapterFromType.union then
		for k, v in ipairs(infoChapter.data.StageID) do
			if v == stageId then
				return k
			end
		end
	end

	return 1
end

function ChapterMgr:GetCurChapter(cType, id)
	if cType == ChapterType.comb or cType == ChapterType.role then
		return self.listCurChapter[cType .. id]
	else
		return self.listCurChapter[cType]
	end
end

function ChapterMgr:GetCurStage()
	local list = self.listAllChapter.main
	local curChapter

	for i = 1, #list do
		local infoChapter = list[i]

		if infoChapter:IsOpen() then
			curChapter = infoChapter
		end
	end

	local curStage

	if curChapter ~= nil then
		for i = 1, #curChapter.listStage do
			local infoStage = curChapter.listStage[i]

			if infoStage:IsOpen() then
				curStage = infoStage
			end
		end
	end

	return curStage
end

function ChapterMgr:GetCurHardChapter()
	local list = self.listAllChapter.mainhard
	local curChapter

	for i = 1, #list do
		local infoChapter = list[i]

		if infoChapter:IsOpen() then
			curChapter = infoChapter
		end
	end

	local curStage

	if curChapter ~= nil then
		for i = 1, #curChapter.listStage do
			local infoStage = curChapter.listStage[i]

			if infoStage:IsOpen() then
				curStage = infoStage
				curChapter = ChapterMgr:GetChapter(curStage.data.ChapterID)
			end
		end
	end

	return curChapter
end

function ChapterMgr:SetStageAch(grade, txt)
	local InfoStageCondition = require("Info.InfoStageCondition")

	InfoStageCondition.GradeText(txt, grade)
end

function ChapterMgr:GetMainCompleteRate(stageId)
	local infoStage

	if not stageId then
		infoStage = self:GetCurStage()
	else
		infoStage = ChapterMgr:GetStage(stageId)
	end

	if not infoStage or not infoStage.data then
		return 0, 0
	end

	local chapterID = infoStage.data.ChapterID
	local chapterIdx = ChapterMgr:GetChapterIdx(chapterID)
	local stageIdx = 0
	local infoChapter = self:GetChapter(chapterID)

	if infoChapter ~= nil and infoChapter.data ~= nil then
		local listStageId = self:GetChapter(chapterID).data.StageID

		for i = 1, #listStageId do
			if infoStage.data.ID == listStageId[i] then
				stageIdx = i

				break
			end
		end
	end

	if stageIdx == 0 then
		PrintWithColor("StageID[%s] is not exist!", "yellow", tostring(stageId))

		return 0, 0
	end

	return chapterIdx, stageIdx
end

function ChapterMgr:GetUnLockStageList(chapterId)
	local list = {}
	local infoChapter = self:GetChapter(chapterId)
	local listAllStage = infoChapter.listStage
	local count = #listAllStage

	for i = 1, count do
		local infoStage = listAllStage[count + 1 - i]

		if infoStage:IsOpen() then
			table.insert(list, infoStage)
		end
	end

	if #list == 0 and infoChapter.data.Type == 4 then
		local infoStage = InfoStage(listAllStage[1].id)

		infoStage.isUnLock = true

		table.insert(list, infoStage)
	end

	return list
end

function ChapterMgr:IsChapterStoryAwardAllGet(infoChapter)
	for i, stageId in ipairs(infoChapter.data.StageID) do
		if ChapterMgr.StoryAwardList[stageId] then
			for i, v in ipairs(ChapterMgr.StoryAwardList[stageId]) do
				if not InfoGameInst:IsGetScenarioReward(v.GroupId) then
					return false
				end
			end
		end
	end

	return true
end

function ChapterMgr.ChapterHasStageNew(infoChapter, notWithStory)
	if infoChapter == nil or not infoChapter:IsOpen() then
		return false
	end

	for _, stage in ipairs(infoChapter.listStage) do
		if stage:HasNewDot(notWithStory) then
			return true
		end
	end

	return false
end

function ChapterMgr.ChapterHasStarAward(infoChapter)
	if infoChapter == nil or not infoChapter:IsOpen() then
		return false
	end

	local list = infoChapter:GetChapterAwardList()

	for _, v in ipairs(list) do
		if v.state == 0 and infoChapter:GetStar() >= v.star then
			return true
		end
	end

	return false
end

function ChapterMgr:HaveChapterDot(infoChapter)
	if ChapterMgr.ChapterHasStageNew(infoChapter) then
		return true
	end

	if ChapterMgr.ChapterHasStarAward(infoChapter) then
		return true
	end

	return false
end

function ChapterMgr:IsRoleStoryHaveNewUnlockDot(infoRole)
	local infoChapter = self:GetCurChapter(ChapterType.role, infoRole.id)
	local list = infoChapter.listStage

	for i, v in ipairs(list) do
		if infoRole.curFavorLevel >= v.data.FavorLevel and v.pb.isPass == false then
			return true
		end
	end

	return false
end

function ChapterMgr.GetStageMaxPlayNum(stageId)
	local infoStage = ChapterMgr:GetStage(stageId)

	if not infoStage then
		return 0
	end

	local chapterType = infoStage.data.ChapterType
	local stageLimitNum = infoStage:GetMaxLeftPlayNum()
	local min = stageLimitNum == 0 and 999 or stageLimitNum

	if chapterType == ChapterFromType.card then
		local singleCardLimitNum = CardChapterMgr.GetSingleLimitChallengeNum()

		singleCardLimitNum = singleCardLimitNum == 0 and 999 or singleCardLimitNum
		min = singleCardLimitNum < min and singleCardLimitNum or min

		local cardLimitNum = CardChapterMgr.GetTotalLimitChallengeNum()

		cardLimitNum = cardLimitNum == 0 and 999 or cardLimitNum
		min = cardLimitNum < min and cardLimitNum or min
	end

	if min == 999 then
		return -1
	else
		return min
	end
end

function ChapterMgr:GetStageLeftPlayNumWithLimit(stageId)
	local infoStage = self:GetStage(stageId)

	if not infoStage then
		return 0
	end

	local chapterType, stageType = infoStage.data.ChapterType, infoStage.data.Type
	local playNum, stageLimitNum = infoStage.pb.playNum, infoStage:GetMaxLeftPlayNum()
	local leftNum = -1

	if chapterType == ChapterFromType.main or chapterType == ChapterFromType.mainhard then
		if stageLimitNum ~= 0 then
			leftNum = TenaryOp(stageLimitNum - playNum < 0, 0, stageLimitNum - playNum)
		end
	elseif chapterType == ChapterFromType.comb or chapterType == ChapterFromType.card or chapterType == ChapterFromType.activity then
		local extra
		local tempLeftNum = 0

		if chapterType == ChapterFromType.comb then
			extra = self:GetChapterByStage(stageId).data.Team
			tempLeftNum = CombChapterMgr.GetCombRemainingChallengeNum(extra)
		elseif chapterType == ChapterFromType.card then
			extra = self:GetChapterByStage(stageId).data.Card
			tempLeftNum = CardChapterMgr.GetCardRemainingChallengeNum(extra)
		elseif chapterType == ChapterFromType.activity then
			local infoActive = ActiveChapterMgr.GetActiveByStageId(stageId)
			local extra

			if infoActive then
				if infoActive.data.ActiveGroup == eActiveGroupType.boss then
					extra = ActiveChapterMgr.GetActiveTypeByStageId(stageId)
					tempLeftNum = ActiveChapterMgr.GetActiveRemainingChallengeNum(extra)
				else
					extra = infoActive.data.ID
					tempLeftNum = AssetChapterMgr.GetAssetRemainingChallengeNum(extra, infoStage)
				end
			else
				tempLeftNum = -1
			end
		end

		if tempLeftNum ~= -1 or stageLimitNum ~= 0 then
			if tempLeftNum ~= -1 then
				if stageLimitNum == 0 then
					leftNum = tempLeftNum
				else
					leftNum = math.max(math.min(tempLeftNum, stageLimitNum - playNum), 0)
				end
			else
				leftNum = math.max(stageLimitNum - playNum, 0)
			end
		end
	elseif chapterType == ChapterFromType.union then
		if stageType == StageFromType.unionBoss then
			local raid = UnionRaidMgr:GetBossRaidByStageId(stageId)

			leftNum = UnionRaidMgr.maxBossPlayNum - UnionRaidMgr.GetPlayNum(eRaidType.Boss, raid.id)
		end
	elseif chapterType == ChapterFromType.bosslive then
		leftNum = BossliveChapterMgr.GetBossliveRemainingChallengeNum()
	elseif chapterType == ChapterFromType.bossRaid then
		leftNum = ActivityBossRaidMgr.playNum
	end

	return leftNum
end

function ChapterMgr:GetStageBattleCost(stageVar)
	local infoStage = stageVar

	if type(stageVar) == "number" then
		infoStage = self:GetStage(stageVar)
	end

	if not infoStage or not infoStage.data then
		return nil
	end

	local battleCost, temp = {}, {}

	if infoStage.data.CostItem and #infoStage.data.CostItem > 0 then
		temp = {
			itemId = infoStage.data.CostItem[1],
			needNum = infoStage.data.CostItem[2]
		}

		table.insert(battleCost, temp)
	end

	if infoStage.data.Stamina > 0 then
		temp = {
			itemId = ItemManager:GetItemByType("P_POWER").id,
			needNum = infoStage.data.Stamina
		}

		table.insert(battleCost, temp)
	end

	if #battleCost == 0 then
		return nil
	end

	return battleCost
end

function ChapterMgr:SetCharactorNewUnlockStory(roleId, preLevel, curLevel)
	local infoChapter = ChapterMgr:GetCurChapter(ChapterType.role, roleId)

	if infoChapter ~= nil then
		for i, v in ipairs(infoChapter.listStage) do
			local favorLevel = v.data.FavorLevel

			if preLevel < favorLevel and favorLevel <= curLevel then
				PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_FAVOR_STORY_ENTER .. v.id, false)
			end
		end
	else
		PrintWithColor("Chapter is not exist of role[%d] personal story", "red", roleId)
	end
end

function ChapterMgr:HaveBossActivityNormalStageDot()
	local infoActive = ActiveMgr:GetActiveByType(eActiveType.boss)[1]

	if infoActive then
		local infoChapter = ChapterMgr:GetChapter(infoActive.normalChapterId)

		if infoChapter.listStage then
			for i = 1, #infoChapter.listStage do
				local infoStage = infoChapter.listStage[i]
				local num = infoStage.pb.playNum

				if num > infoStage:GetMaxLeftPlayNum() then
					num = infoStage:GetMaxLeftPlayNum()
				end

				num = infoStage:GetMaxLeftPlayNum() - num

				local power = infoStage:GetCostItem()[2] or 0
				local curPower = PlayerInst:GetPower()

				if num > 0 and power <= curPower then
					return true
				end
			end
		end
	end

	return false
end

function ChapterMgr:HaveBossActivityBossStageDot()
	local infoActive = ActiveMgr:GetActiveByType(eActiveType.boss)[1]

	if infoActive then
		local infoChapter = ChapterMgr:GetChapter(infoActive.bossChapterId)

		if infoChapter.listStage then
			for i = 1, #infoChapter.listStage do
				local infoStage = infoChapter.listStage[i]
				local num = infoStage.pb.playNum

				if num > infoStage:GetMaxLeftPlayNum() then
					num = infoStage:GetMaxLeftPlayNum()
				end

				num = infoStage:GetMaxLeftPlayNum() - num

				local power = infoStage:GetCostItem()[2] or 0
				local curPower = infoStage:GetCostItem()[1]:GetCurResNum()

				if num > 0 and power <= curPower and infoStage.isUnLock then
					return true
				end
			end
		end
	end

	return false
end

function ChapterMgr:HaveBossActivityShopDot(typevalue, ActiveID)
	local info = ActiveCardPoolMgr:GetAll(ActiveID)[1]
	local itemId = info.data.OneCost[1]
	local itemNum = info.data.OneCost[2]
	local infoItem = ItemManager:Get(itemId)

	if infoItem:GetNum() >= typevalue * itemNum then
		return true
	end

	return false
end

function ChapterMgr:HaveBossActivityDot()
	local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Boss)
	local list = ActiveMgr:GetOpenActiveByType(3)

	if isOpen and #list > 0 then
		return ChapterMgr:HaveBossActivityShopDot(1, list[1].id) or ChapterMgr:HaveBossActivityBossStageDot() or ChapterMgr:HaveBossActivityNormalStageDot()
	else
		return false
	end
end

function ChapterMgr:InitStoryAwardList()
	self.StoryAwardList = {}

	for k, v in pairs(CallTopicAward) do
		if v.StageID ~= 0 then
			if not self.StoryAwardList[v.StageID] then
				self.StoryAwardList[v.StageID] = {}
			end

			table.insert(self.StoryAwardList[v.StageID], v)
		end
	end
end

CombChapterMgr = {}
CombChapterMgr.listCharacterCombId = {}

function CombChapterMgr.GetChapterCombId()
	if next(CombChapterMgr.listCharacterCombId) == nil then
		local listUnLockCon = GetConfigArgJson("TeamChapterUnlock")

		for _, v in ipairs(listUnLockCon) do
			table.insert(CombChapterMgr.listCharacterCombId, v[1])
		end
	end

	return CombChapterMgr.listCharacterCombId
end

function CombChapterMgr.GetCombChapters(combId)
	return ChapterMgr:GetChapterList(ChapterType.comb, combId) or {}
end

function CombChapterMgr.CombChapterIsUnLock(combId)
	local listUnLockCon = GetConfigArgJson("TeamChapterUnlock")

	for _, v in pairs(listUnLockCon) do
		if v[1] == combId then
			local infoStage = ChapterMgr:GetStage(v[2])

			if infoStage.pb.isPass then
				return true
			end
		end
	end

	return false
end

function CombChapterMgr.GetCombChapterStarCollect(combId, chapterId)
	if chapterId then
		local infoChapter = ChapterMgr:GetChapter(chapterId)

		return infoChapter:GetStar()
	end

	local listChapter = CombChapterMgr.GetCombChapters(combId)
	local colNum, allNum = 0, 0

	for _, v in pairs(listChapter) do
		colNum = colNum + v:GetStar()
		allNum = allNum + v:GetAllStar()
	end

	return colNum, allNum
end

function CombChapterMgr.GetTotalLimitChallengeNum()
	local count = 0

	if InfoGameInst:GetChapterTimesList() then
		count = InfoGameInst:GetChapterTimesList()[4].buyTimes
	end

	return GetConfigArgInt("StageTeamMaxNum") + count
end

function CombChapterMgr.GetSingleLimitChallengeNum(combId)
	local limits = GetConfigArgJson("StageTeamMaxNum")

	for _, v in ipairs(limits) do
		if v[1] == combId then
			local count = 0

			if InfoGameInst:GetChapterTimesList() then
				count = InfoGameInst:GetChapterTimesList()[4].buyTimes
			end

			return v[2] + count or 0
		end
	end

	return 0
end

function CombChapterMgr.GetTotalRemainingChallengeNum()
	local challengedNum = 0

	for _, v in ipairs(CombChapterMgr.GetChapterCombId()) do
		challengedNum = challengedNum + CombChapterMgr.GetCombChallengedNum(v)
	end

	local tLimit = CombChapterMgr.GetTotalLimitChallengeNum()

	if tLimit ~= 0 then
		return math.max(tLimit - challengedNum, 0)
	end

	return -1
end

function CombChapterMgr.GetCombChallengedNum(combId)
	local list = CombChapterMgr.GetCombChapters(combId)
	local num = 0

	for _, chapter in ipairs(list) do
		num = num + ChapterMgr:GetPlayNum(chapter.id)
	end

	return num
end

function CombChapterMgr.GetCombRemainingChallengeNum(combId)
	local tLimit = CombChapterMgr.GetTotalRemainingChallengeNum()
	local sLimit = CombChapterMgr.GetSingleLimitChallengeNum(combId)
	local challengedNum = CombChapterMgr.GetCombChallengedNum(combId)

	if tLimit ~= -1 then
		if sLimit ~= 0 then
			return math.max(math.min(tLimit, sLimit - challengedNum), 0)
		end

		return math.max(tLimit, 0)
	elseif sLimit ~= 0 then
		return math.max(sLimit - challengedNum, 0)
	end

	return -1
end

function CombChapterMgr.HaveDot(combId)
	if not CombChapterMgr.CombChapterIsUnLock(combId) then
		return false
	end

	local listChapter = CombChapterMgr.GetCombChapters(combId)

	for _, chapter in ipairs(listChapter) do
		if ChapterMgr:HaveChapterDot(chapter) then
			return true
		end
	end

	return false
end

function CombChapterMgr.HaveCombChapterDot()
	for _, v in ipairs(CombChapterMgr.GetChapterCombId()) do
		if CombChapterMgr.HaveDot(v) then
			return true
		end
	end

	return false
end

CardChapterMgr = {}

function CardChapterMgr.GetCardChapter(cardId)
	local infoRoleCard = RoleCardMgr:GetRoleCard(cardId)

	if not infoRoleCard then
		return {}
	end

	return ChapterMgr:GetChapter(infoRoleCard.data.CardChapter)
end

function CardChapterMgr.GetTotalLimitChallengeNum()
	local _, addNum = ShopManager:GetGoodsMonthPrivilegeFuncInfo(ShopManager.MonthPrivilegeFunc.Func8)

	return GetConfigArgInt("StageCardMaxNum") + addNum
end

function CardChapterMgr.GetSingleLimitChallengeNum()
	return GetConfigArgJson("StageCardMaxNum")[1] or 0
end

function CardChapterMgr.GetTotalRemainingChallengeNum()
	local listHoldCard = RoleCardMgr:GetAllHoldCard()
	local challengedNum = 0

	for _, v in ipairs(listHoldCard) do
		challengedNum = challengedNum + CardChapterMgr.GetCardChallengedNum(v.id)
	end

	local tLimit = CardChapterMgr.GetTotalLimitChallengeNum()

	if tLimit ~= 0 then
		return math.max(tLimit - challengedNum, 0)
	end

	return -1
end

function CardChapterMgr.GetCardChallengedNum(cardId)
	local infoChapter = CardChapterMgr.GetCardChapter(cardId)

	return ChapterMgr:GetPlayNum(infoChapter.id)
end

function CardChapterMgr.GetCardRemainingChallengeNum(cardId)
	local tLimit = CardChapterMgr.GetTotalRemainingChallengeNum()
	local sLimit = CardChapterMgr.GetSingleLimitChallengeNum()
	local challengedNum = CardChapterMgr.GetCardChallengedNum(cardId)

	if tLimit ~= -1 then
		if sLimit ~= 0 then
			return math.max(math.min(tLimit, sLimit - challengedNum), 0)
		end

		return math.max(tLimit, 0)
	elseif sLimit ~= 0 then
		return math.max(sLimit - challengedNum, 0)
	end

	return -1
end

function CardChapterMgr.GetCardIdByChapterId(chapterId)
	local list = RoleCardMgr:GetAllHoldCard()

	for _, card in ipairs(list) do
		if chapterId == card.data.CardChapter then
			return card.id
		end
	end

	return nil
end

function CardChapterMgr.GetCardChapterStory(cardId)
	local infoChapter = CardChapterMgr.GetCardChapter(cardId)

	for _, stage in ipairs(infoChapter.listStage) do
		if stage.data.Type == StageFromType.story then
			return stage
		end
	end

	return nil
end

function CardChapterMgr.HaveCardChapterDot(cardId)
	if not TutorialMgr:IsOpenNoMsg(TutorialFunctionType.CardPass) then
		return false
	end

	local infoChapter = CardChapterMgr.GetCardChapter(cardId)

	return ChapterMgr.ChapterHasStageNew(infoChapter, true)
end

function CardChapterMgr.HasCardPassDot()
	if not TutorialMgr:IsOpenNoMsg(TutorialFunctionType.CardPass) then
		return false
	end

	local allHoldCard = RoleCardMgr:GetAllHoldCard()

	for _, v in ipairs(allHoldCard) do
		if CardChapterMgr.HaveCardChapterDot(v.id) then
			return true
		end
	end

	return false
end

AssetChapterMgr = {}

local eAssetGroupType = {
	"mate",
	"equip",
	"gift"
}

function AssetChapterMgr.GetAssetChapter(assetId)
	local infoActive = ActiveMgr:GetActive(assetId)
	local chapterId = infoActive:GetOpenChapterToday()[1]

	if not chapterId then
		return nil
	end

	return ChapterMgr:GetChapter(chapterId)
end

function AssetChapterMgr.GetTotalLimitChallengeNum()
	return 0
end

function AssetChapterMgr.GetSingleGroupLimitChallengeNum(grouptype)
	if groupType == eActiveGroupType.mate then
		return GetConfigArgInt("StageMatMaxNum")
	elseif groupType == eActiveGroupType.equip then
		return GetConfigArgInt("StageEquMaxNum")
	elseif groupType == eActiveGroupType.gift then
		return GetConfigArgInt("StageGiftMaxNum")
	end

	return 0
end

function AssetChapterMgr.GetSingleLimitChallengeNum(assetId, infoStage)
	local infoAsset = ActiveMgr:GetActive(assetId)
	local count = 0

	if InfoGameInst:GetChapterTimesList() then
		count = InfoGameInst:GetChapterTimesList()[infoStage.data.ActType].buyTimes
	end

	if infoAsset then
		return infoAsset.data.ArgJson[1] + count or 0
	end

	return 0
end

function AssetChapterMgr.GetTotalRemainingChallengeNum(infoStage)
	local challengedNum = 0

	for _, v in ipairs(eAssetGroupType) do
		challengedNum = challengedNum + AssetChapterMgr.GetGroupChallengedNum(eActiveGroupType[v])
	end

	local tLimit = AssetChapterMgr.GetTotalLimitChallengeNum()

	if tLimit ~= 0 then
		return math.max(tLimit - challengedNum, 0)
	end

	return -1
end

function AssetChapterMgr.GetGroupRemainingChallengeNum(grouptype, infoStage)
	local challengedNum = AssetChapterMgr.GetGroupChallengedNum(grouptype)
	local tLimit = AssetChapterMgr.GetTotalRemainingChallengeNum(infoStage)
	local sLimit = AssetChapterMgr.GetSingleGroupLimitChallengeNum(grouptype)

	if tLimit == -1 then
		if sLimit ~= 0 then
			return math.max(math.min(tLimit, sLimit - challengedNum), 0)
		end

		return math.max(tLimit, 0)
	elseif sLimit ~= 0 then
		return math.max(sLimit - challengedNum, 0)
	end

	return -1
end

function AssetChapterMgr.GetGroupChallengedNum(grouptype)
	local challengedNum = 0
	local listAsset = ActiveMgr:GetActiveByActiveGroup(grouptype)

	for _, v in ipairs(listAsset) do
		local infoChapter = v:GetOpenChapterToday()

		challengedNum = challengedNum + ChapterMgr:GetPlayNum(infoChapter.id)
	end

	return challengedNum
end

function AssetChapterMgr.GetAssetRemainingChallengeNum(assetId, infoStage)
	local infoChapter = AssetChapterMgr.GetAssetChapter(assetId)

	if not infoChapter then
		return -1
	end

	local groupType = infoChapter.data.ActiveGroup
	local tLimit = AssetChapterMgr.GetGroupRemainingChallengeNum(grouptype)
	local sLimit = AssetChapterMgr.GetSingleLimitChallengeNum(assetId, infoStage)
	local challengedNum = AssetChapterMgr.GetAssetChallengedNum(assetId)

	if tLimit == -1 then
		if sLimit ~= 0 then
			return math.max(math.min(tLimit, sLimit - challengedNum), 0)
		end

		return math.max(tLimit, 0)
	elseif sLimit ~= 0 then
		return math.max(sLimit - challengedNum, 0)
	end

	return -1
end

function AssetChapterMgr.GetAssetChallengedNum(assetId)
	local infoChapter = AssetChapterMgr.GetAssetChapter(assetId)

	if not infoChapter then
		return 0
	end

	return ChapterMgr:GetPlayNum(infoChapter.id)
end

ActiveChapterMgr = {}

function ActiveChapterMgr.GetActiveChapter(atype)
	local infoActive = ActiveMgr:GetOpenActiveByType(eActiveType.boss)[1]

	if not infoActive then
		return nil
	end

	local chapterId

	if atype == eBossActiveType.normal then
		chapterId = infoActive.normalChapterId
	elseif atype == eBossActiveType.story then
		chapterId = infoActive.storyChapterId
	elseif atype == eBossActiveType.boss then
		chapterId = infoActive.bossChapterId
	end

	return ChapterMgr:GetChapter(chapterId)
end

function ActiveChapterMgr.GetTotalLimitChallengeNum()
	return 0
end

function ActiveChapterMgr.GetSingleLimitChallengeNum(atype)
	local infoActive = ActiveMgr:GetOpenActiveByType(eActiveType.boss)[1]

	if not infoActive then
		return 0
	end

	local infoChapter = ActiveChapterMgr.GetActiveChapter(atype)

	if not infoChapter then
		return 0
	end

	local idx = 1

	for k, v in ipairs(infoActive.data.TypeValue) do
		if table.getIndex(v, infoChapter.id) > 0 then
			idx = k

			break
		end
	end

	return infoActive.data.ArgJson[idx] or 0
end

function ActiveChapterMgr.GetActiveRemainingChallengeNum(atype)
	local tLimit = ActiveChapterMgr.GetTotalLimitChallengeNum()
	local sLimit = ActiveChapterMgr.GetSingleLimitChallengeNum(atype)
	local challengedNum = ActiveChapterMgr.GetActiveChallengedNum(atype)

	if tLimit ~= 0 then
		if sLimit ~= 0 then
			return math.max(math.min(tLimit, sLimit - challengedNum), 0)
		end

		return math.max(tLimit, 0)
	elseif sLimit ~= 0 then
		return math.max(sLimit - challengedNum, 0)
	end

	return -1
end

function ActiveChapterMgr.GetActiveChallengedNum(atype)
	local infoChapter = ActiveChapterMgr.GetActiveChapter(atype)

	if not infoChapter then
		return 0
	end

	return ChapterMgr:GetPlayNum(infoChapter.id)
end

function ActiveChapterMgr.GetActiveTypeByStageId(stageId)
	local chapterId = ChapterMgr:GetStage(stageId).data.ChapterID
	local infoActive = ActiveChapterMgr.GetActiveByStageId(stageId)

	if chapterId == infoActive.storyChapterId then
		return eBossActiveType.story
	elseif chapterId == infoActive.bossChapterId then
		return eBossActiveType.boss
	end

	return eBossActiveType.normal
end

function ActiveChapterMgr.GetActiveByStageId(stageId)
	local chapterId = ChapterMgr:GetStage(stageId).data.ChapterID
	local allActive = ActiveMgr:GetAllActive()

	for _, v in ipairs(allActive) do
		for _, n in ipairs(v.data.TypeValue) do
			if table.getIndex(n, chapterId) > 0 then
				return v
			end
		end
	end

	return nil
end

TowerChapterMgr = {}
TowerChapterMgr.CurStage = 0
TowerChapterMgr.dailyTimes = 0

function TowerChapterMgr:SetData(pb)
	return
end

function TowerChapterMgr:GetAllTower(type)
	local ctype = ChapterType.tower

	if type == ChapterFromType.tower then
		ctype = ChapterType.tower
	elseif type == ChapterFromType.towerhard then
		ctype = ChapterType.towerhard
	end

	return ChapterMgr:GetChapterList(ctype)
end

function TowerChapterMgr:GetTowerList(type)
	local ctype = ChapterType.tower

	if type == ChapterFromType.tower then
		ctype = ChapterType.tower
	elseif type == ChapterFromType.towerhard then
		ctype = ChapterType.towerhard
	end

	local towerList = ChapterMgr:GetChapterList(ctype)
	local OpenList = {
		towerList[1]
	}

	for i = 2, #towerList do
		table.insert(OpenList, towerList[i])

		if not towerList[i - 1]:IsPass() then
			break
		end
	end

	return OpenList
end

function TowerChapterMgr:GetTowerChapter(stageId)
	local ctype = ChapterType.tower
	local type = ChapterMgr:GetStage(stageId).data.ChapterType

	if type == ChapterFromType.tower then
		ctype = ChapterType.tower
	elseif type == ChapterFromType.towerhard then
		ctype = ChapterType.towerhard
	end

	local towerList = ChapterMgr:GetChapterList(ctype)

	for _, v in ipairs(towerList) do
		for i, j in ipairs(v.listStage) do
			if j.id == stageId then
				return v
			end
		end
	end

	return nil
end

function TowerChapterMgr:GetPassProgress(type)
	local ctype = ChapterType.tower

	if type == ChapterFromType.tower then
		ctype = ChapterType.tower
	elseif type == ChapterFromType.towerhard then
		ctype = ChapterType.towerhard
	end

	local towerList = ChapterMgr:GetChapterList(ctype)
	local num = 0
	local total = 0

	for i = 1, #towerList do
		for n, v in ipairs(towerList[i].listStage) do
			if v:IsPass() then
				num = num + 1
			end

			total = total + 1
		end
	end

	return num, total
end

function TowerChapterMgr:GetAddDailyItemNum(chapterID)
	local curInfoChapter = ChapterMgr:GetChapter(chapterID)
	local ctype = ChapterType.tower

	if #curInfoChapter.listStage[1].data.DailyAward == 0 then
		return nil
	end

	local lastItem = curInfoChapter.listStage[1].data.DailyAward[1]
	local curItem = curInfoChapter.listStage[#curInfoChapter.listStage].data.DailyAward[1]

	if curItem[1] == lastItem[1] then
		if curItem[2] - lastItem[2] == 0 then
			return nil
		else
			return {
				curItem[1],
				curItem[2] - lastItem[2]
			}
		end
	else
		return curItem
	end
end

function TowerChapterMgr:GetCurDailyItem()
	local towerList = ChapterMgr:GetChapterList(ChapterType.tower)
	local infoChapter

	for i, v in ipairs(towerList) do
		if v:IsOpen() and not v:IsPass() then
			infoChapter = v

			break
		end
	end

	if infoChapter == nil then
		infoChapter = towerList[#towerList]
	end

	for i = 1, #infoChapter.listStage do
		if (i == #infoChapter.listStage or not infoChapter.listStage[i + 1]:IsPass()) and infoChapter.listStage[i]:IsPass() then
			return infoChapter.listStage[i].data.DailyAward
		end
	end

	return infoChapter.listStage[1].data.DailyAward
end

function TowerChapterMgr:GetDailyAwardCount()
	local baseNum = 1
	local _, num = ShopManager:GetGoodsMonthPrivilegeFuncInfo(ShopManager.MonthPrivilegeFunc.Func4)

	return baseNum + num
end

function TowerChapterMgr:HaveAwardDot()
	local towerList = ChapterMgr:GetChapterList(ChapterType.tower)

	for i, v in ipairs(towerList) do
		if v:IsPass() and v.pb.awardStatus[3] == 0 then
			return true
		end
	end

	towerList = ChapterMgr:GetChapterList(ChapterType.towerhard)

	for i, v in ipairs(towerList) do
		if v:IsPass() and v.pb.awardStatus[3] == 0 then
			return true
		end
	end

	return false
end

BossliveChapterMgr = {}

function BossliveChapterMgr.GetTotalLimitNum()
	local _, addNum = ShopManager:GetGoodsMonthPrivilegeFuncInfo(ShopManager.MonthPrivilegeFunc.Func5)

	return GetConfigArgInt("StageBossLivesMaxNum") + addNum
end

function BossliveChapterMgr.GetBossliveRemainingChallengeNum()
	local challengedNum = 0
	local listChapter = ChapterMgr:GetChapterList(ChapterType.bosslive) or {}

	for _, infoChapter in ipairs(listChapter) do
		challengedNum = challengedNum + ChapterMgr:GetPlayNum(infoChapter.id)
	end

	local tLimit = BossliveChapterMgr.GetTotalLimitNum()

	if tLimit ~= 0 then
		return math.max(tLimit - challengedNum, 0)
	end

	return -1
end

StageScrollViewPosMgr = {}
eScrollViewPosType = {
	partyCommon = "partyCommon",
	partyBoss = "partyBoss",
	asset = "asset",
	main = "main",
	partyStory = "partyStory"
}
StageScrollViewPosMgr.PosYList = {}

function StageScrollViewPosMgr.SetPosY(vtype, y)
	if not eScrollViewPosType[vtype] then
		return
	end

	StageScrollViewPosMgr.PosYList[eScrollViewPosType[vtype]] = y or 0
end

function StageScrollViewPosMgr.GetPosY(vtype)
	if not eScrollViewPosType[vtype] then
		return 0
	end

	return StageScrollViewPosMgr.PosYList[eScrollViewPosType[vtype]] or 0
end

function ChapterMgr.GetTimes(_type, _monthCardFunc)
	local info, sumTimes = 0

	if _monthCardFunc then
		info, sumTimes = ShopManager:GetGoodsMonthPrivilegeFuncInfo(_monthCardFunc)
	end

	if _type == ePassChallengeBuyType.Gold then
		sumTimes = GetConfigArgInt("GoldStageDailyNumBuyCost") + sumTimes
	else
		sumTimes = GetConfigArgInt("ResourceDailyNumBuyCost") + sumTimes
	end

	local t = InfoGameInst:GetChapterTimesList() or {}
	local buyTimes = t[_type] ~= nil and t[_type].buyTimes or 0

	return sumTimes, buyTimes
end

TimeSpaceChapterMgr = {}
TimeSpaceChapterMgr.CurStageId = 0
TimeSpaceChapterMgr.CurChapterId = 0
TimeSpaceChapterMgr.FreezeCardList = {}
TimeSpaceChapterMgr.StartTime = 0
TimeSpaceChapterMgr.EndTime = 0

function TimeSpaceChapterMgr:GetResetTimeString()
	local now = NetData:GetCurServerTime() / DateUtil.MillsPerSecond
	local left = TimeSpaceChapterMgr.EndTime - now

	if left > 0 then
		local day = math.floor(left / 86400)
		local hour = math.floor((left - day * 86400) / 3600)
		local minute = math.ceil((left - day * 86400 - hour * 3600) / 60)

		return day .. _("Desc_day") .. " " .. hour .. _("Desc_hour") .. minute .. _("Desc_minute"), false
	else
		return "0" .. _("Desc_day") .. " 0" .. _("Desc_hour") .. "0" .. _("Desc_minute"), true
	end
end

function TimeSpaceChapterMgr:Refresh()
	TimeSpaceChapterMgr.CurStageId = 0
	TimeSpaceChapterMgr.CurChapterId = 0

	local chapters = ChapterMgr:GetChapterList(ChapterType.timespace)

	for k, v in pairs(chapters) do
		local currentChallStage = 0
		local isComplete = true

		for i = 1, #v.listStage do
			if v.listStage[i]:GetStar() < 3 then
				isComplete = false
			end

			if v.listStage[i]:IsPass() then
				currentChallStage = v.listStage[i].data.ID
			end
		end

		v.completed = isComplete

		if not v.completed and currentChallStage ~= 0 then
			TimeSpaceChapterMgr.CurStageId = currentChallStage
			TimeSpaceChapterMgr.CurChapterId = v.data.ID
		end
	end

	print("curr stage " .. TimeSpaceChapterMgr.CurStageId)
	print("curr chapter " .. TimeSpaceChapterMgr.CurChapterId)
end

function TimeSpaceChapterMgr:GetCurrChapter()
	local towerList = ChapterMgr:GetChapterList(ChapterType.timespace)

	for _, v in ipairs(towerList) do
		if v.data.ID == TimeSpaceChapterMgr.CurChapterId then
			return v
		end
	end

	return nil
end

function TimeSpaceChapterMgr:SetData(chapters, freezeCards)
	self:SetRoleCardFreeze(false)

	TimeSpaceChapterMgr.FreezeCardList = freezeCards or {}

	ChapterMgr:SetData(chapters)
	self:SetRoleCardFreeze(true)
end

function TimeSpaceChapterMgr:SetRoleCardFreeze(val)
	local count = #TimeSpaceChapterMgr.FreezeCardList > 5 and 5 or #TimeSpaceChapterMgr.FreezeCardList

	for i = 1, count do
		local v = TimeSpaceChapterMgr.FreezeCardList[i]

		if v ~= 0 then
			local roleCard = RoleCardMgr:GetRoleCard(v)

			if roleCard then
				roleCard.tsLimit = val
			end
		end
	end
end

function TimeSpaceChapterMgr:BattleEnd(freezes, stageId)
	self:SetRoleCardFreeze(false)

	TimeSpaceChapterMgr.FreezeCardList = freezes

	local currChapter = TimeSpaceChapterMgr:GetTowerChapterByChapter(TimeSpaceChapterMgr.CurChapterId)

	if currChapter then
		if currChapter:GetAllStar() == currChapter:GetStar() then
			-- block empty
		else
			self:SetRoleCardFreeze(true)
		end
	else
		self:SetRoleCardFreeze(true)
	end

	self:Refresh()
end

function TimeSpaceChapterMgr:GetAllTower()
	return ChapterMgr:GetChapterList(ChapterType.timespace)
end

function TimeSpaceChapterMgr:GetTotalStar()
	local chapters = ChapterMgr:GetChapterList(ChapterType.timespace)
	local totalStar = 0

	for k, v in pairs(chapters) do
		for i, j in ipairs(v.listStage) do
			totalStar = totalStar + j:GetStar()
		end
	end

	return totalStar
end

function TimeSpaceChapterMgr:GetTowerChapterByChapter(cid)
	local towerList = ChapterMgr:GetChapterList(ChapterType.timespace)

	for _, v in ipairs(towerList) do
		if v.data.ID == cid then
			return v
		end
	end

	return nil
end

function TimeSpaceChapterMgr:GetTowerChapter(stageId)
	local towerList = ChapterMgr:GetChapterList(ChapterType.timespace)

	for _, v in ipairs(towerList) do
		for i, j in ipairs(v.listStage) do
			if j.id == stageId then
				return v
			end
		end
	end

	return nil
end
