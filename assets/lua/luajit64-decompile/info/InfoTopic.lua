-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoTopic.lua

local TopicData = require("luaData/TopicData")

InfoTopic = class("InfoTopic", InfoBase)

function InfoTopic:ctor(id)
	self.data = TopicData[id]
	self.id = id
	self.pb = {}
	self.pb.id = id
	self.pb.status = 0
	self.pb.alias = nil
end

function InfoTopic:IsGeted()
	if ChapterMgr == nil then
		return false
	end

	local stage = ChapterMgr:GetStage(self.data.StageID)

	if stage and stage.pb.isPass then
		return true
	end

	if self.data.FavorUnlockLevel > 0 then
		local infoRole = RoleMgr:GetRole(self.data.RoleId)

		if infoRole.curFavorLevel >= self.data.FavorUnlockLevel then
			return true
		end
	end

	return false
end

function InfoTopic:SetData(pb)
	self.pb.id = pb.id
	self.pb.status = pb.status
	self.pb.record = pb.record
	self.pb.awardId = pb.awardId
end

TopicManager = {}

local dict = {}

TopicManager.save = nil

function TopicManager:GetTopic(tId)
	local vId = tId

	if type(tId) == "string" then
		vId = tonumber("0x" .. tId)
	end

	local ret = dict[vId]

	if not ret then
		ret = InfoTopic(vId)
		dict[vId] = ret
	end

	if ret.data == nil then
		print("请检查TopicData表!!!!!!!!" .. tId)
	end

	return ret
end

function TopicManager:GetListTopic(roleId, status)
	local list = {}

	for i = 1, #TopicData do
		local data = TopicData[i]

		if data.RoleId == roleId then
			local infoTopic = TopicManager:GetTopic(data.ID)

			if infoTopic:IsGeted() and (status == nil or infoTopic.pb.status == status) then
				table.insert(list, infoTopic)
			end
		end
	end

	return list
end

function TopicManager:NotifyNewCall(stageId, infoRole)
	for i = 1, #TopicData do
		local data = TopicData[i]
		local infoTopic = TopicManager:GetTopic(data.ID)

		if infoTopic.pb.status == 0 then
			if infoTopic.data.StageID == stageId and not table.contains(self.getTopicList, data.ID) then
				PersistentStoreUtil.AddList(PersistentStoreUtil.KEY_NEW_TOPIC, infoTopic.id)
				PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_OPEN_PHONE_CALL_MSG, false)
				table.insert(self.getTopicList, data.ID)
				CommunicationRDL.AddNews(data.ID)
			end

			if infoRole and infoRole.id == infoTopic.data.RoleId and infoTopic.data.FavorUnlockLevel ~= 0 and infoTopic.data.FavorUnlockLevel <= infoRole.curFavorLevel and not table.contains(self.getTopicList, data.ID) then
				PersistentStoreUtil.AddList(PersistentStoreUtil.KEY_NEW_TOPIC, infoTopic.id)
				PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_OPEN_PHONE_CALL_MSG, false)
				table.insert(self.getTopicList, data.ID)
				CommunicationRDL.AddNews(data.ID)
			end
		end
	end
end

function TopicManager:SetData(listPbMsg)
	for i = 1, #listPbMsg do
		local pb = listPbMsg[i]
		local info = TopicManager:GetTopic(pb.id)

		info:SetData(pb)
	end

	self.getTopicList = {}

	for i = 1, #TopicData do
		local data = TopicData[i]
		local infoTopic = TopicManager:GetTopic(data.ID)

		if infoTopic.pb.status == 0 then
			local infoStage

			if infoTopic.data.StageID ~= 0 then
				infoStage = ChapterMgr:GetStage(infoTopic.data.StageID)
			end

			local infoRole = RoleMgr:GetRole(infoTopic.data.RoleId)

			if infoStage and infoStage:IsPass() or infoTopic.data.FavorUnlockLevel > 0 and infoTopic.data.FavorUnlockLevel <= infoRole.curFavorLevel then
				table.insert(self.getTopicList, data.ID)
			end
		end
	end
end

function TopicManager:GetRecord(roleId)
	local listTopic = self:GetListTopic(roleId, 0)

	for i = 1, #listTopic do
		local info = listTopic[i]

		if info.pb.record ~= nil then
			return info
		end
	end

	return nil
end

function TopicManager:GetAllTopicList(roleId)
	local list = {}

	for i = 1, #TopicData do
		local data = TopicData[i]

		if data.RoleId == roleId then
			local infoTopic = TopicManager:GetTopic(data.ID)

			table.insert(list, infoTopic)
		end
	end

	return list
end
