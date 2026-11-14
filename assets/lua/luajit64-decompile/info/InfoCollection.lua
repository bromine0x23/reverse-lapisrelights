-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoCollection.lua

local CollectionData = require("luaData/Figure")
local IllustrationData = require("luaData/Illustration")
local SongSubtitleData = require("luaData/SongSubtitleData")
local VideoData = require("luaData/VideoData")
local InfoCollection = class("InfoCollection", InfoBase)

eCollectionTaskType = {
	ROLE_CARD_COLLECT = 1,
	ROLE_CARD_STAR = 3,
	ROLE_EQUIPMENTDEVELOP = 5,
	ROLE_POTENTIAL = 6,
	ROLE_CARD_BLOOM = 4,
	ROLE_EQUIPMENTBREAK = 8,
	ROLE_CARD_LEVEL = 2,
	ROLE_LIKABILITY = 7
}

function InfoCollection:ctor(id)
	self.data = CollectionData[id]
	self.id = id
	self.status = 1
end

function InfoCollection:SetData(id)
	self.id = id
	self.status = 2
end

function InfoCollection:IsGetAward()
	if self.status == 2 then
		return true
	end

	return false
end

function InfoCollection:GetTaskDesc()
	local condition = self.data.condition[1]
	local infoRole = RoleMgr:GetRole(self.data.roleId)

	if not condition then
		return ""
	end

	if condition[1][1] == eCollectionTaskType.ROLE_CARD_COLLECT then
		if condition[2][1] ~= 0 then
			local text = {}

			for i, v in ipairs(condition[2]) do
				local name = RoleCardMgr:GetRoleCard(v):GetName()
				local rank = RoleCardMgr:GetRoleCard(v).data.Rank

				table.insert(text, string.format(_("Condition_Card"), rank, name))
			end

			local customStr = table.concat(text, " 、")

			return string.format(Lang(83000016), customStr)
		else
			local rankStr = GetRankString(condition[1][2])

			if condition[1][2] == 0 then
				return string.format(Lang(83000017), condition[1][3])
			else
				return string.format(Lang(83000018), condition[1][3], rankStr)
			end
		end
	elseif condition[1][1] == eCollectionTaskType.ROLE_CARD_LEVEL then
		if condition[2][1] ~= 0 then
			local text = {}

			for i, v in ipairs(condition[2]) do
				local name = RoleCardMgr:GetRoleCard(v):GetName()
				local rank = RoleCardMgr:GetRoleCard(v).data.Rank

				table.insert(text, string.format(_("Condition_Card"), rank, name))
			end

			local customStr = table.concat(text, " 、")

			return string.format(Lang(83000019), customStr, condition[1][2])
		else
			return string.format(Lang(83000020), condition[1][3], condition[1][2])
		end
	elseif condition[1][1] == eCollectionTaskType.ROLE_CARD_STAR then
		if condition[2][1] ~= 0 then
			local text = {}

			for i, v in ipairs(condition[2]) do
				local name = RoleCardMgr:GetRoleCard(v):GetName()
				local rank = RoleCardMgr:GetRoleCard(v).data.Rank

				table.insert(text, string.format(_("Condition_Card"), rank, name))
			end

			local customStr = table.concat(text, " 、")

			return string.format(Lang(83000021), customStr, condition[1][2])
		else
			return string.format(Lang(83000022), condition[1][3], condition[1][2])
		end
	elseif condition[1][1] == eCollectionTaskType.ROLE_CARD_BLOOM then
		if condition[2][1] ~= 0 then
			local text = {}

			for i, v in ipairs(condition[2]) do
				local name = RoleCardMgr:GetRoleCard(v):GetName()
				local rank = RoleCardMgr:GetRoleCard(v).data.Rank

				table.insert(text, string.format(_("Condition_Card"), rank, name))
			end

			local customStr = table.concat(text, " 、")

			return string.format(Lang(83000023), customStr, condition[1][2])
		else
			return string.format(Lang(83000024), condition[1][3], condition[1][2])
		end
	elseif condition[1][1] == eCollectionTaskType.ROLE_EQUIPMENTDEVELOP then
		return string.format(Lang(83000025), condition[1][3], condition[1][2])
	elseif condition[1][1] == eCollectionTaskType.ROLE_POTENTIAL then
		return string.format(Lang(83000026), _("ecNum_" .. condition[1][2]))
	elseif condition[1][1] == eCollectionTaskType.ROLE_LIKABILITY then
		return string.format(Lang(83000027), condition[1][2])
	elseif condition[1][1] == eCollectionTaskType.ROLE_EQUIPMENTBREAK then
		return string.format(Lang(83000028), condition[1][3], condition[1][2])
	end

	return ""
end

function InfoCollection:GetProgress()
	local condition = self.data.condition[1]
	local totalNum, curNum

	if not condition then
		return 0, 0
	end

	if condition[1][1] == eCollectionTaskType.ROLE_CARD_COLLECT then
		if condition[2][1] ~= 0 then
			curNum = 0

			for i, v in ipairs(condition[2]) do
				if RoleCardMgr:GetRoleCard(v):IsHold() then
					curNum = curNum + 1
				end
			end

			totalNum = #condition[2]
		else
			curNum = 0
			totalNum = condition[1][3]

			local cardList = RoleCardMgr:GetRoleHoldCard(self.data.roleId)

			for i, v in ipairs(cardList) do
				if v.cardRank >= condition[1][2] then
					curNum = curNum + 1
				end
			end
		end
	elseif condition[1][1] == eCollectionTaskType.ROLE_CARD_LEVEL then
		if condition[2][1] ~= 0 then
			curNum = 0

			for i, v in ipairs(condition[2]) do
				if RoleCardMgr:GetRoleCard(v).curLevel >= condition[1][2] then
					curNum = curNum + 1
				end
			end

			totalNum = #condition[2]
		else
			curNum = 0
			totalNum = condition[1][3]

			local cardList = RoleCardMgr:GetRoleHoldCard(self.data.roleId)

			for i, v in ipairs(cardList) do
				if v.curLevel >= condition[1][2] then
					curNum = curNum + 1
				end
			end
		end
	elseif condition[1][1] == eCollectionTaskType.ROLE_CARD_STAR then
		if condition[2][1] ~= 0 then
			curNum = 0

			for i, v in ipairs(condition[2]) do
				if RoleCardMgr:GetRoleCard(v).curStarLevel >= condition[1][2] then
					curNum = curNum + 1
				end
			end

			totalNum = #condition[2]
		else
			curNum = 0
			totalNum = condition[1][3]

			local cardList = RoleCardMgr:GetRoleHoldCard(self.data.roleId)

			for i, v in ipairs(cardList) do
				if v.curStarLevel >= condition[1][2] then
					curNum = curNum + 1
				end
			end
		end
	elseif condition[1][1] == eCollectionTaskType.ROLE_CARD_BLOOM then
		if condition[2][1] ~= 0 then
			curNum = 0

			for i, v in ipairs(condition[2]) do
				if RoleCardMgr:GetRoleCard(v).curPetal >= condition[1][2] then
					curNum = curNum + 1
				end
			end

			totalNum = #condition[2]
		else
			curNum = 0
			totalNum = condition[1][3]

			local cardList = RoleCardMgr:GetRoleHoldCard(self.data.roleId)

			for i, v in ipairs(cardList) do
				if v.curPetal >= condition[1][2] then
					curNum = curNum + 1
				end
			end
		end
	elseif condition[1][1] == eCollectionTaskType.ROLE_EQUIPMENTDEVELOP then
		local infoRole = RoleMgr:GetRole(self.data.roleId)

		curNum = 0
		totalNum = condition[1][3]

		for i, v in ipairs(infoRole.pb.slots) do
			if infoRole:IsEquipSlotUnlocked(i) and v.level >= condition[1][2] then
				curNum = curNum + 1
			end
		end
	elseif condition[1][1] == eCollectionTaskType.ROLE_POTENTIAL then
		local index = condition[1][2]

		curNum = 0

		for i = 1, index do
			local temp = SkillManager.NextTreeIsUnlock(i, self.data.roleId)

			if temp.actFull and temp.starFull then
				curNum = i
			end
		end

		totalNum = condition[1][2]
	elseif condition[1][1] == eCollectionTaskType.ROLE_LIKABILITY then
		local infoRole = RoleMgr:GetRole(self.data.roleId)

		curNum = infoRole.curFavorLevel
		totalNum = condition[1][2]
	elseif condition[1][1] == eCollectionTaskType.ROLE_EQUIPMENTBREAK then
		local infoRole = RoleMgr:GetRole(self.data.roleId)

		curNum = 0
		totalNum = condition[1][3]

		for i, v in ipairs(infoRole.pb.slots) do
			if infoRole:IsEquipSlotUnlocked(i) then
				local index = EquipmentManager:GetQualityIndex(v.quality, v.grade) - 1

				if index >= condition[1][2] then
					curNum = curNum + 1
				end
			end
		end
	end

	return curNum, totalNum
end

function InfoCollection:CheckItemEnough()
	for i, v in ipairs(self.data.ItemNeed) do
		local count = ItemManager:GetItemCount(v[1])

		if count < v[2] then
			return false
		end
	end

	return true
end

eCollectionAwardType = {
	SONG = 3,
	FINALSKILL = 1,
	VIDEO = 4,
	PICTURE = 2
}
CollectionManager = {}
CollectionManager.dict = CollectionManager.dict or Record()
CollectionManager.curSelectTeam = nil
CollectionManager.curSelectTaskId = nil
CollectionManager.pictureAwardList = {}
CollectionManager.skillAwardList = {}
CollectionManager.videoAwardList = {}
CollectionManager.songAwardList = {}

function CollectionManager:Get(id)
	local ret = self.dict:GetValue(id)

	if not ret then
		ret = InfoCollection(id)

		self.dict:Set(id, ret)
	end

	if ret.data == nil then
		print("CollectionData表をチェックしてください！！！" .. id)
	end

	return ret
end

function CollectionManager:Init()
	self.listTask = {}

	for _, v in pairs(CollectionData) do
		if self.listTask[v.roleId] == nil then
			self.listTask[v.roleId] = {}
		end

		if self.listTask[v.roleId][v.type] == nil then
			self.listTask[v.roleId][v.type] = {}
		end

		self.listTask[v.roleId][v.type][v.figureId[2]] = v
	end

	self.listIllustration = {}

	for _, v in ipairs(IllustrationData) do
		if self.listIllustration[v.RoleId] == nil then
			self.listIllustration[v.RoleId] = {}
		end

		table.insert(self.listIllustration[v.RoleId], v)
	end

	self.listSong = {}

	for _, v in ipairs(SongSubtitleData) do
		if self.listSong[v.Team] == nil then
			self.listSong[v.Team] = {}
		end

		table.insert(self.listSong[v.Team], v)
	end
end

function CollectionManager:SetData(pb, figureAward)
	local figureIds = pb

	for i = 1, #figureIds do
		local id = figureIds[i]
		local info = CollectionManager:Get(id)

		info:SetData(id)
	end

	self:CaluOpenTask()

	for k, v in pairs(figureAward) do
		if v.locktype == eCollectionAwardType.FINALSKILL then
			CollectionManager.skillAwardList = v.awardId
		end

		if v.locktype == eCollectionAwardType.PICTURE then
			CollectionManager.pictureAwardList = v.awardId
		end

		if v.locktype == eCollectionAwardType.SONG then
			CollectionManager.songAwardList = v.awardId
		end

		if v.locktype == eCollectionAwardType.VIDEO then
			CollectionManager.videoAwardList = v.awardId
		end
	end
end

function CollectionManager:CaluOpenTask()
	self.curOpenList = {}

	for k1, listType in pairs(self.listTask) do
		for k2, tasks in pairs(listType) do
			for k3, task in pairs(tasks) do
				local info = CollectionManager:Get(task.ID)

				if not info:IsGetAward() and CollectionManager:CheckPreTaskActive(task.ID) then
					if self.curOpenList[k1] == nil then
						self.curOpenList[k1] = {}
					end

					self.curOpenList[k1][k2] = info

					break
				end
			end
		end
	end
end

function CollectionManager:GetPicOpenInfo(roleId)
	local id = self.listTask[roleId][0][1].ID
	local info = CollectionManager:Get(id)

	return info
end

function CollectionManager:GetInfoListByType(roleId, type)
	local list = self.listTask[roleId][type]
	local infoList = {}

	for _, v in ipairs(list) do
		local info = CollectionManager:Get(v.ID)

		table.insert(infoList, info)
	end

	return infoList
end

function CollectionManager:GetInfoIDByAvatar(roleId, itemID)
	for k1, list in pairs(self.listTask[roleId]) do
		for k2, v in pairs(list) do
			for _, reward in ipairs(v.Reward) do
				if reward[3] and reward[3] == itemID then
					return v.ID
				end
			end
		end
	end

	return nil
end

function CollectionManager:GetInfoListByPage(roleId, index)
	local pageList = {}
	local list = self.listTask[roleId]

	for k, v in pairs(self.listTask[roleId]) do
		if index == v[1].PageIndex then
			local infoList = {}

			for _, data in ipairs(v) do
				local info = CollectionManager:Get(data.ID)

				table.insert(infoList, info)
			end

			table.insert(pageList, infoList)
		end
	end

	return pageList
end

function CollectionManager:CheckPreTaskActive(id)
	local info = CollectionManager:Get(id)
	local list = self.listTask[info.data.roleId]
	local preId

	if info.data.figureId[1] == 0 then
		return true
	end

	if info.data.figureId[2] == 1 then
		preId = list[0][1].ID
	else
		preId = list[info.data.figureId[1]][info.data.figureId[2] - 1].ID
	end

	if preId and CollectionManager:Get(preId):IsGetAward() then
		return true
	end

	return false
end

function CollectionManager:GetRoleTaskTabCount(roleId)
	local list = self.listTask[roleId]
	local count = 0

	for k, v in pairs(list) do
		if count < v[1].PageIndex then
			count = v[1].PageIndex
		end
	end

	return count
end

function CollectionManager:GetProgress(id)
	local info = CollectionManager:Get(id)

	return info:GetProgress()
end

function CollectionManager:GetIllustrationInfo(roleId)
	return self.listIllustration[roleId]
end

function CollectionManager:GetIllustrationByID(id)
	return IllustrationData[id]
end

function CollectionManager:GetSongInfo(teamId)
	if self.listSong[teamId] then
		return self.listSong[teamId]
	else
		return {}
	end
end

function CollectionManager:GetSongNext(id, isNext)
	if isNext then
		id = id + 1

		if id > #SongSubtitleData then
			id = 1
		end
	else
		id = id - 1

		if id == 0 then
			id = #SongSubtitleData
		end
	end

	if not ChapterMgr:GetStage(SongSubtitleData[id].UnlockStageId):IsPass() then
		return CollectionManager:GetSongNext(id, isNext)
	else
		return SongSubtitleData[id]
	end
end

function CollectionManager:SetNewRoleCardSkillUnlock(cardId)
	local list = PersistentStoreUtil.GetList(PersistentStoreUtil.KEY_PICTURE_ROLECARD_SKILLID)

	if table.contains(list, tostring(cardId)) then
		return
	end

	PersistentStoreUtil.AddList(PersistentStoreUtil.KEY_PICTURE_ROLECARD_SKILLID, cardId)
end

function CollectionManager:SetNewPictureUnlock(id)
	local list = PersistentStoreUtil.GetList(PersistentStoreUtil.KEY_PICTURE_ROLECARD_PICTURE)

	if table.contains(list, tostring(id)) then
		return
	end

	PersistentStoreUtil.AddList(PersistentStoreUtil.KEY_PICTURE_ROLECARD_PICTURE, id)
end

function CollectionManager:GetImpressionHaveDot()
	local listAllHoldCard = RoleCardMgr:GetAllHoldCard()

	for k, v in pairs(listAllHoldCard) do
		if not table.contains(CollectionManager.skillAwardList, v.id) then
			return true
		end
	end

	local listAllHoldRole = RoleMgr:GetAllHoldRole()

	for k, role in pairs(listAllHoldRole) do
		for _, pic in ipairs(role.pb.pictures) do
			if not table.contains(CollectionManager.pictureAwardList, pic) then
				return true
			end
		end
	end

	return false
end

function CollectionManager:GetStoryHaveDot()
	for i, v in ipairs(SongSubtitleData) do
		local infoStage = ChapterMgr:GetStage(v.UnlockStageId)

		if infoStage:IsPass() and not table.contains(CollectionManager.songAwardList, v.ID) then
			return true
		end
	end

	for i, v in ipairs(VideoData) do
		local infoStage = ChapterMgr:GetStage(v.UnlockStageId)

		if infoStage:IsPass() and not table.contains(CollectionManager.videoAwardList, v.ID) then
			return true
		end
	end

	return false
end

function CollectionManager:SetNewRoleUnlock(roleId)
	local list = PersistentStoreUtil.GetList(PersistentStoreUtil.KEY_PICTURE_ROLE)

	if table.contains(list, tostring(roleId)) then
		return
	end

	PersistentStoreUtil.AddList(PersistentStoreUtil.KEY_PICTURE_ROLE, roleId)
end

function CollectionManager:GetNoteHaveDot()
	local count = PersistentStoreUtil.GetListCount(PersistentStoreUtil.KEY_PICTURE_ROLE)

	if count > 0 then
		return true
	end

	for k1, v in pairs(self.curOpenList) do
		for k2, taskInfo in pairs(v) do
			local cur, total = taskInfo:GetProgress()

			if total <= cur and taskInfo:CheckItemEnough() then
				return true
			end
		end
	end

	return false
end

function CollectionManager:AddNewOpenTask(id)
	local taskInfo = self:Get(id)

	self.curOpenList[taskInfo.data.roleId][taskInfo.data.figureId[1]] = nil

	if taskInfo.data.figureId[1] == 0 then
		for k, v in pairs(self.listTask[taskInfo.data.roleId]) do
			if k ~= 0 then
				local info = CollectionManager:Get(v[1].ID)

				self.curOpenList[taskInfo.data.roleId][k] = info
			end
		end
	else
		local newTaskID = self.listTask[taskInfo.data.roleId][taskInfo.data.figureId[1]][taskInfo.data.figureId[2] + 1]

		if newTaskID then
			self.curOpenList[taskInfo.data.roleId][taskInfo.data.figureId[1]] = CollectionManager:Get(newTaskID.ID)
		else
			self.curOpenList[taskInfo.data.roleId][taskInfo.data.figureId[1]] = nil
		end
	end

	ManualRDL.NotesRDL.Sub(taskInfo)
end

function CollectionManager:GetAllTaskDesc(id)
	local list = {}

	for k, v in pairs(CollectionData) do
		local info = CollectionManager:Get(v.ID)
		local printInfo = {}

		printInfo.ID = v.ID
		printInfo.Desc = info:GetTaskDesc()
		printInfo.RoleName = RoleMgr:GetRole(info.data.roleId):GetName()

		table.insert(list, printInfo)
	end

	local json = require("GameLogic.Util.json4lua")
	local ret = json.encode(list)
	local path = string.gsub(Application.dataPath, "Assets", "")
	local test = assert(io.open(path .. "FigureTaskDesc.txt", "w"))

	test:write(ret)
	test:close()
end
