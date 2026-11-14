-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoPhoneCall.lua

local PhoneCallData = require("luaData/CallData")

InfoPhoneCall = class("InfoPhoneCall", InfoBase)

function InfoPhoneCall:ctor(id)
	self.data = PhoneCallData[id]
	self.id = id
	self.pb = {}
	self.pb.id = id
	self.pb.status = 0
	self.pb.alias = nil
	self.isNew = false
end

function InfoPhoneCall:IsGeted()
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

function InfoPhoneCall:SetData(pb)
	self.pb.id = pb.id
	self.pb.status = pb.status
	self.pb.record = pb.record
	self.pb.awardId = pb.awardId
end

PhoneCallManager = {}
PhoneCallManager.tagIndex = 0

local dict = {}

function PhoneCallManager:Get(tId)
	local vId = tId

	if type(tId) == "string" then
		vId = tonumber("0x" .. tId)
	end

	local ret = dict[vId]

	if not ret then
		ret = InfoPhoneCall(vId)
		dict[vId] = ret
	end

	if ret.data == nil then
		print("CallData表をチェックしてください！！！" .. tId)
	end

	return ret
end

function PhoneCallManager:GetListTopic(roleId, status)
	local list = {}

	for i = 1, #PhoneCallData do
		local data = PhoneCallData[i]

		if data.RoleId == roleId then
			local InfoPhoneCall = PhoneCallManager:Get(data.ID)

			if InfoPhoneCall:IsGeted() and (status == nil or InfoPhoneCall.pb.status == status) then
				table.insert(list, InfoPhoneCall)
			end
		end
	end

	return list
end

function PhoneCallManager:NotifyNewCall(stageId, infoRole)
	for i = 1, #PhoneCallData do
		local data = PhoneCallData[i]
		local info = PhoneCallManager:Get(data.ID)

		if info.pb.status == 0 then
			if info.data.StageID == stageId and not table.contains(self.getPhoneList, data.ID) then
				PersistentStoreUtil.AddList(PersistentStoreUtil.KEY_NEW_PHONE_CALL, info.id)
				PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_OPEN_PHONE_CALL_MSG, false)
				table.insert(self.getPhoneList, data.ID)
				CommunicationRDL.AddCall(data.ID)
			end

			if infoRole and infoRole.id == info.data.RoleId and info.data.FavorUnlockLevel ~= 0 and info.data.FavorUnlockLevel <= infoRole.curFavorLevel and not table.contains(self.getPhoneList, data.ID) then
				PersistentStoreUtil.AddList(PersistentStoreUtil.KEY_NEW_PHONE_CALL, info.id)
				PersistentStoreUtil.SetBool(PersistentStoreUtil.KEY_OPEN_PHONE_CALL_MSG, false)
				table.insert(self.getPhoneList, data.ID)
				CommunicationRDL.AddCall(data.ID)
			end
		end
	end
end

function PhoneCallManager:SetData(listPbMsg)
	for i = 1, #listPbMsg do
		local pb = listPbMsg[i]
		local info = PhoneCallManager:Get(pb.id)

		info:SetData(pb)
	end

	self.getPhoneList = {}

	for i = 1, #PhoneCallData do
		local data = PhoneCallData[i]
		local infoPhoneCall = PhoneCallManager:Get(data.ID)

		if infoPhoneCall.pb.status == 0 then
			local infoStage

			if infoPhoneCall.data.StageID ~= 0 then
				infoStage = ChapterMgr:GetStage(infoPhoneCall.data.StageID)
			end

			local infoRole = RoleMgr:GetRole(infoPhoneCall.data.RoleId)

			if infoStage and infoStage:IsPass() or infoPhoneCall.data.FavorUnlockLevel > 0 and infoPhoneCall.data.FavorUnlockLevel <= infoRole.curFavorLevel then
				table.insert(self.getPhoneList, data.ID)
			end
		end
	end
end

function PhoneCallManager:GetRecord(roleId)
	local listTopic = self:GetListTopic(roleId, 0)

	for i = 1, #listTopic do
		local info = listTopic[i]

		if info.pb.record ~= nil then
			return info
		end
	end

	return nil
end

function PhoneCallManager:GetAllPhoneCallList(roleId)
	local list = {}

	for i = 1, #PhoneCallData do
		local data = PhoneCallData[i]

		if data.RoleId == roleId then
			local InfoPhoneCall = PhoneCallManager:Get(data.ID)

			table.insert(list, InfoPhoneCall)
		end
	end

	return list
end
