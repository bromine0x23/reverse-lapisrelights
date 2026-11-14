-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoRole.lua

require("Info/InfoBase")
require("Info/InfoSkill")
require("Info/InfoAvatar")
require("Info/InfoJoin")
require("Util.EasyFilter")
require("Info/InfoRoleCard")
require("Info/AttributeAgent")

local RoleData = require("luaData/CharacterRole")
local ActorData = require("luaData/ActorData")
local RoleTeamData = require("luaData/CharacterTeam")
local FavorVoiceData = require("luaData/FavorVoiceData")
local InfoTeam = require("Info/InfoTeam")

InfoRole = class("InfoRole", InfoBase)

function InfoRole:ctor(id)
	self.data = RoleData[id]

	if self.data == nil then
		PrintWithColor("RoleID[%s] is not exist!", "yellow", tostring(self.id))

		return
	end

	self.actorData = ActorData[self.data.ActorID]
	self.job = GetJobType(self.data.Job)
	self.dictAvalible = {}
	self.voiceData = nil

	for i = 1, #FavorVoiceData do
		local voiceData = FavorVoiceData[i]

		if voiceData.CharacterId == id then
			self.voiceData = voiceData

			break
		end
	end

	self.listPlayMotionIndex = {}
	self.curFavorLevel = 1
	self.preFavorLevel = 1
	self.maxFavorLevel = GetConfigArgInt("FavorMaxLevel")
	self.curFavorExp = 0
	self.curFavorNextExp = 0
	self.preFavorExp = 0
	self.preFavorNextExp = 0
	self.sectionIndex = 1
	self.curModeId = 1
	self.hold = false
	self.bpAvatars = {}
	self.tempAvatars = {}
	self.listRoleCard = RoleCardMgr:GetRoleAllCard(id)
	self.roleAtt = AttributeOwner()
	self.baseAtt = AttributeOwner()
	self.talentAtt = AttributeOwner()
	self.equipAtt = AttributeOwner()
	self.skillAtt = AttributeOwner()
	self.activeSkillAtt = AttributeOwner()
	self.bpAvatarAtt = AttributeOwner()
	self.skillBuffAtt = AttributeOwner()
end

function InfoRole:SetData(pbRole)
	self.id = pbRole.id
	self.pb.playerId = pbRole.playerId
	self.pb.clothes = pbRole.clothes
	self.pb.avatars = pbRole.avatars
	self.pb.favorExp = pbRole.favorExp
	self.pb.skillNodes = pbRole.nodes
	self.pb.extraSkills = pbRole.extraSkills
	self.pb.roleCardId = pbRole.roleCardId
	self.pb.equipStatus = pbRole.equipStatus
	self.pb.nickName = pbRole.nickName
	self.pb.phoneBgId = pbRole.phoneBgId
	self.pb.lastTopicId = pbRole.lastTopicId
	self.hold = true
	self.pb.weaponAvatar = pbRole.weaponAvatar
	self.pb.slots = pbRole.slots
	self.pb.favorLevelRecord = pbRole.favorLevelRecord
	self.pb.avatarModes = pbRole.avatarTemplate
	self.pb.curreModeId = pbRole.currentAvatar == 0 and 1 or pbRole.currentAvatar
	self.curModeId = self.pb.curreModeId
	self.pb.pictures = pbRole.pictures
	self.listNodeSkill = {}
	self.listNodeAvatar = {}
	self.listSkillBuffSkill = {}

	self:UpdateFavorExp(pbRole.favorExp)
	self:UpdatePreFavorExp()
	self:SetBaseAttr()
	self:SetTalentAttr()
	self:SetEquipAttr()
	self:SetExtraSkillAttr()

	for _, v in ipairs(self.pb.avatars) do
		if AvatarManager.IsBPAvatar(v) then
			table.insert(self.bpAvatars, v)
		end
	end

	self:SetBPAvatarAttr()
	self:UpdateAttr()
end

function InfoRole:SetPBPlayer(pbPlayer)
	self.pbPlayer = pbPlayer
end

function InfoRole:ChangeFavorExp(changeExp)
	if not self.hold then
		return
	end

	self.pb.favorExp = self.pb.favorExp + changeExp

	self:UpdateFavorExp(self.pb.favorExp)
end

function InfoRole:UpdateFavorExp(exp)
	self:UpdatePreFavorExp()

	local curFavorLevel = LevelManager:GetRoleFavorLevel(exp)

	if curFavorLevel > self.maxFavorLevel then
		curFavorLevel = self.maxFavorLevel
	end

	local nextExp = LevelManager:GetRoleFavorNeedExp(curFavorLevel)
	local curExp = exp - LevelManager:GetRoleFavorExp(curFavorLevel - 1)

	self.curFavorLevel = curFavorLevel
	self.curFavorExp = curExp
	self.curFavorNextExp = nextExp
	self.sectionIndex = RoleMgr:GetFavorSectionIndex(curFavorLevel)
end

function InfoRole:UpdatePreFavorExp()
	self.preFavorLevel = self.curFavorLevel
	self.preFavorExp = self.curFavorExp
	self.preFavorNextExp = self.curFavorNextExp
end

function InfoRole:GetCommuName()
	if self.pb.nickName and self.pb.nickName ~= "" then
		return self.pb.nickName
	end

	return self:GetName()
end

function InfoRole:GetCVName()
	return Lang(self.data.CvName)
end

function InfoRole:GetPhoneBgId()
	if self.pb.phoneBgId and self.pb.phoneBgId > 0 then
		return self.pb.phoneBgId
	end

	return self.pb.roleCardId
end

function InfoRole:UpdateAvatarMode(id, avatarIds, name)
	if not id then
		return
	end

	if avatarIds or name then
		if avatarIds then
			for i = 1, #self.pb.avatarModes[id].avatars do
				table.remove(self.pb.avatarModes[id].avatars)
			end

			for j = 1, #avatarIds do
				table.insert(self.pb.avatarModes[id].avatars, avatarIds[j])
			end
		end

		if name then
			self.pb.avatarModes[id].name = name
		end
	else
		self.pb.curreModeId = id
	end

	if id == self.pb.curreModeId then
		self.pb.clothes = {}

		for _, v in ipairs(self.pb.avatarModes[id].avatars) do
			table.insert(self.pb.clothes, v)
		end

		Event.Instance:Fire("UpdateAvatars", self.id)
	end
end

function InfoRole:AddAvatar(avatarId)
	table.insert(self.pb.avatars, avatarId)
end

function InfoRole:RemoveAvatar(avatarId)
	local index = table.getIndex(self.pb.avatars, avatarId)

	if index ~= -1 then
		table.remove(self.pb.avatars, index)
	end

	local infoAvatar = AvatarManager:GetAvatar(avatarId)

	if infoAvatar:IsBPAvatar() then
		for k, v in ipairs(self.pb.avatarModes) do
			local t = {}

			if table.contains(v.avatars, avatarId) then
				for _, n in ipairs(v.avatars) do
					if n == avatarId then
						local hasSlot, needId = AvatarManager:FindAvatarBySlot(self.actorData.DefaultAvatars, infoAvatar.data.Slot)

						if hasSlot then
							table.insert(t, needId)
						end
					else
						table.insert(t, n)
					end
				end

				self:UpdateAvatarMode(k, t)
			end
		end
	end
end

function InfoRole:SetCurModeId(modeId)
	if modeId then
		self.curModeId = modeId

		return
	end

	self.curModeId = self.pb.curreModeId
end

function InfoRole:GetEquipAvatarIds()
	if #self.tempAvatars > 0 then
		return self.tempAvatars
	end

	return self.pb.avatarModes[self.curModeId].avatars
end

function InfoRole:SetTempEquipAvatarIds(ids)
	self.tempAvatars = ids or {}
end

function InfoRole:UpdateTalentNodeData(pbNode)
	if pbNode == nil then
		return
	end

	local isHave = false

	for _, node in ipairs(self.pb.skillNodes) do
		if node.id == pbNode.id then
			node.level = pbNode.level or 1
			node.failTimes = pbNode.failTimes or 0
			isHave = true

			break
		end
	end

	if not isHave then
		table.insert(self.pb.skillNodes, pbNode)
	end

	self:UpdateTalentAttr(true)
end

function InfoRole:UpdateTalentSkillData(pbStarTalent)
	if pbStarTalent == nil then
		return
	end

	self:AddExtraSkillData(pbStarTalent)
end

function InfoRole:UpdateFavorSkill(preLevel, curLevel)
	local listSkill = self.data.FavorLevelSkill

	if not self.pb.extraSkills then
		self.pb.extraSkills = {}
	end

	for i, v in ipairs(listSkill) do
		if v[1] == preLevel then
			for i = #self.pb.extraSkills, 1, -1 do
				if self.pb.extraSkills[i].id == v[2] then
					table.remove(self.pb.extraSkills, i)

					break
				end
			end
		end

		if v[1] == curLevel then
			self:AddExtraSkillData({
				level = 1,
				id = v[2]
			})
		end
	end
end

function InfoRole:AddExtraSkillData(pbStarTalent)
	if pbStarTalent == nil then
		return
	end

	if self.pb.extraSkills == nil then
		self.pb.extraSkills = {}
	end

	local isHave = false

	for _, v in pairs(self.pb.extraSkills) do
		if pbStarTalent.id == v.id then
			v.level = pbStarTalent.level
			isHave = true

			break
		end
	end

	if not isHave then
		table.insert(self.pb.extraSkills, pbStarTalent)
	end

	self:UpdateExtraSkillAttr()
end

function InfoRole:UpdateEquipData(pbEquipSlot)
	local sId = pbEquipSlot.slot

	for _, v in pairs(self.pb.slots) do
		if v.slot == sId then
			v.quality = pbEquipSlot.quality
			v.grade = pbEquipSlot.grade
			v.level = pbEquipSlot.level
		end
	end

	self:UpdateEquipBaseAttr(true)
end

function InfoRole:ChangeEquipEnchantScroll(slotIndex, scrollId)
	for _, v in pairs(self.pb.slots) do
		if slotIndex == v.slot then
			v.scroll = scrollId

			break
		end
	end
end

function InfoRole:ChangeEquipSlotEnchantAttr(slotIndex, pbAttributes)
	for _, v in pairs(self.pb.slots) do
		if slotIndex == v.slot then
			for i = #v.attributes, 1, -1 do
				table.remove(v.attributes, i)
			end

			for i = 1, #pbAttributes do
				table.insert(v.attributes, pbAttributes[i])
			end

			break
		end
	end

	self:UpdateEquipEnchantAttr(true)
end

function InfoRole:SetBaseAttr()
	self.baseAtt:Reset()

	local tab1 = self.data.AttriList
	local tab2 = self.data.AttriList2
	local tab3 = self.data.AttriList3

	for k, v in pairs(GetMapTab({
		tab1,
		tab2,
		tab3
	})) do
		self.baseAtt:SetBase(k, v)
	end
end

function InfoRole:SetTalentAttr()
	self.listNodeAvatar = {}

	self:UpdateTalentAttr(true)
end

function InfoRole:UpdateTalentAttr(notUpdateAllAtt)
	if self.pb == nil or self.pb.skillNodes == nil then
		return
	end

	self.talentAtt:Reset()

	for _, pbNode in ipairs(self.pb.skillNodes) do
		local node = SkillManager:GetNode(pbNode.id)

		if node.data.RewardType == eSkillNodeType.attri then
			local value = node.data.Attribute[pbNode.level]
			local etype = node.data.AttributeType

			self.talentAtt:ModBase(etype, value)
		elseif node.data.RewardType == eSkillNodeType.avatar then
			local infoAvatar = AvatarManager:GetAvatar(node.data.Avatar)

			table.insert(self.listNodeAvatar, infoAvatar)
		elseif node.data.RewardType == eSkillNodeType.skill then
			-- block empty
		end
	end

	if not notUpdateAllAtt then
		self:UpdateAttr()
	end
end

function InfoRole:SetEquipAttr()
	self.equipBaseAtt = AttributeOwner()

	self:UpdateEquipBaseAttr()

	self.equipAvatarAtt = AttributeOwner()

	self:UpdateEquipAvatarAttr()

	self.equipEnchantAtt = AttributeOwner()

	self:UpdateEquipEnchantAttr()
	self:UpdateEquipAttr(true)
end

function InfoRole:UpdateEquipAttr(notUpdateAllAtt)
	if self.pb == nil or self.pb.slots == nil then
		return
	end

	self.equipAtt:Reset()

	for _, v in pairs(ATTRIBUTE_NAME) do
		self.equipAtt:SetBase(v, self.equipBaseAtt:Get(v))
		self.equipAtt:ModMul(v, self.equipEnchantAtt:GetExtraMul(v))
		self.equipAtt:ModMul(v, self.equipAvatarAtt:GetExtraMul(v))
		self.equipAtt:ModAdd(v, self.equipEnchantAtt:GetExtraAdd(v))
		self.equipAtt:ModAdd(v, self.equipAvatarAtt:GetExtraAdd(v))
	end

	if not notUpdateAllAtt then
		self:UpdateAttr()
	end
end

function InfoRole:UpdateEquipBaseAttr(updateEquipAtt)
	if self.pb == nil or self.pb.slots == nil then
		return
	end

	self.equipBaseAtt:Reset()

	for _, v in pairs(self.pb.slots) do
		if v.slot then
			local unlock = self:IsEquipSlotUnlocked(v.slot)

			if unlock then
				local equipId = self:GetEquipId(v.slot)
				local levelAtt = EquipmentManager:GetProp(v.level, self.job, v.slot, equipId)
				local qualityAtt = EquipmentManager:GetQualityProp(self.job, v.quality, v.grade, v.slot)

				for k, v in pairs(ATTRIBUTE_NAME) do
					self.equipBaseAtt:ModBase(v, (levelAtt[k] or 0) + (qualityAtt[k] or 0))
				end
			end
		end
	end

	if updateEquipAtt then
		self:UpdateEquipAttr()
	end
end

function InfoRole:UpdateEquipAvatarAttr(updateEquipAtt)
	if self.pb == nil or self.pb.avatars == nil then
		return
	end

	self.equipAvatarAtt:Reset()

	for _, avatarId in ipairs(self.pb.avatars) do
		local infoAvatar = AvatarManager:GetAvatar(avatarId)

		if infoAvatar and infoAvatar.data and infoAvatar.data.Slot[1] == "Weapon" then
			for k, v in pairs(ATTRIBUTE_NAME) do
				self.equipAvatarAtt:ModExtraAdd(v, infoAvatar:GetAddAtt(v))
				self.equipAvatarAtt:ModExtraMul(v, infoAvatar:GetMulAtt(v))
			end
		end
	end

	if updateEquipAtt then
		self:UpdateEquipAttr()
	end
end

function InfoRole:UpdateEquipEnchantAttr(updateEquipAtt)
	if self.pb == nil or self.pb.slots == nil then
		return
	end

	self.equipEnchantAtt:Reset()

	for _, v in pairs(self.pb.slots) do
		if v.slot then
			local unlock = self:IsEquipSlotUnlocked(v.slot)

			if unlock then
				local equipId = self:GetEquipId(v.slot)
				local infoEquip = EquipmentManager:GetEquip(equipId)

				if #v.attributes ~= 0 then
					for _, z in pairs(v.attributes) do
						local name = GetAttKeyByIndex(z.type)

						if z.param == 1 then
							self.equipEnchantAtt:ModExtraAdd(name, z.value)
						elseif z.param == 2 then
							self.equipEnchantAtt:ModExtraMul(name, z.value / 1000)
						elseif z.param == 3 then
							self.equipEnchantAtt:ModExtraAdd(name, z.value / 1000)
						end
					end
				end
			end
		end
	end

	local listResSkill = EquipmentManager.GetEquipResonanceSkillByRole(self)

	for _, skill in pairs(listResSkill) do
		for _, v in pairs(ATTRIBUTE_NAME) do
			local perAtt, absAtt = skill:GetAtt(v)

			self.equipEnchantAtt:ModExtraMul(v, perAtt)
			self.equipEnchantAtt:ModExtraAdd(v, absAtt)
		end
	end

	if updateEquipAtt then
		self:UpdateEquipAttr()
	end
end

function InfoRole:SetExtraSkillAttr()
	self:UpdateExtraSkillAttr(true)
end

function InfoRole:UpdateExtraSkillAttr(notUpdateAllAtt)
	if self.pb == nil or self.pb.extraSkills == nil then
		return
	end

	self.skillAtt:Reset()

	self.listNodeSkill = {}

	for _, v in ipairs(self.pb.extraSkills) do
		local skill = TalentManager:Get(v.id)

		if skill then
			skill:SetData(v)

			if skill.data.Type == eTalentType.Passive then
				for _, v in pairs(ATTRIBUTE_NAME) do
					local perValue, absValue = skill:GetAtt(v)

					self.skillAtt:ModExtraMul(v, perValue)
					self.skillAtt:ModExtraAdd(v, absValue)
				end
			elseif skill.data.Type == eTalentType.Battle then
				table.insert(self.listNodeSkill, skill)
			end
		end
	end

	if not notUpdateAllAtt then
		self:UpdateAttr()
	end
end

function InfoRole:SetBPAvatarAttr()
	self:UpdateBPAvatarAttr(true)
end

function InfoRole:UpdateBPAvatarAttr(notUpdateAllAtt)
	self.bpAvatarAtt:Reset()

	for _, avatarId in ipairs(self.bpAvatars) do
		local infoAvatar = AvatarManager:GetAvatar(avatarId)

		for k, v in pairs(ATTRIBUTE_NAME) do
			self.bpAvatarAtt:ModExtraAdd(v, infoAvatar:GetAddAtt(v))
			self.bpAvatarAtt:ModExtraMul(v, infoAvatar:GetMulAtt(v))
		end
	end

	if not notUpdateAllAtt then
		self:UpdateAttr()
	end
end

function InfoRole:UpdateSkillBuffAttr(listSkill)
	self.activeSkillAtt:Reset()

	self.listSkillBuffSkill = {}

	if not listSkill then
		return
	end

	for i = 1, #listSkill do
		local infoTalent = TalentManager:Get(listSkill[i])

		if infoTalent then
			if infoTalent.data.Type == eTalentType.Battle then
				table.insert(self.listSkillBuffSkill, infoTalent)
			elseif infoTalent.data.Type == eTalentType.Passive then
				for _, v in pairs(ATTRIBUTE_NAME) do
					local mulAtt, addAtt = infoTalent:GetAtt(v)

					self.activeSkillAtt:ModExtraMul(v, mulAtt)
					self.activeSkillAtt:ModExtraAdd(v, addAtt)
				end
			end
		end
	end
end

function InfoRole:UpdateAttr()
	self.roleAtt:Reset()

	for _, v in pairs(ATTRIBUTE_NAME) do
		self.roleAtt:SetBase(v, self.baseAtt:Get(v))
		self.roleAtt:ModBase(v, self.equipAtt:Get(v))
		self.roleAtt:ModBase(v, self.talentAtt:Get(v))
		self.roleAtt:ModMul(v, self.skillAtt:GetExtraMul(v))
		self.roleAtt:ModAdd(v, self.skillAtt:GetExtraAdd(v))
		self.roleAtt:ModAdd(v, self.bpAvatarAtt:GetExtraAdd(v))
	end
end

function InfoRole:GetAtt(attType)
	return self.roleAtt:Get(attType)
end

function InfoRole:UpdateAttWithCard(card)
	local roleAtt = AttributeOwner()

	for _, v in pairs(ATTRIBUTE_NAME) do
		roleAtt:SetBase(v, self.baseAtt:Get(v))
		roleAtt:ModBase(v, self.equipAtt:Get(v))
		roleAtt:ModBase(v, self.talentAtt:Get(v))

		if card ~= nil then
			roleAtt:ModBase(v, card:GetAtt(v))
		end

		roleAtt:ModMul(v, self.skillAtt:GetExtraMul(v))
		roleAtt:ModAdd(v, self.skillAtt:GetExtraAdd(v))
		roleAtt:ModAdd(v, self.bpAvatarAtt:GetExtraAdd(v))
	end

	return roleAtt
end

function InfoRole:GetAttWithCard(attType, infoCard)
	local att = self:UpdateAttWithCard(infoCard)

	return att:Get(attType)
end

function InfoRole:SetReduceMul(value)
	self.reduceMul = value
end

function InfoRole:SetReduceAdd(value)
	self.reduceAdd = value
end

function InfoRole:GetBattletAtt(mainCard, supCard)
	local battleRoleAtt = self:UpdateAttWithCard(mainCard)

	for _, v in ipairs(ATTRIBUTE_NAME) do
		if table.contains(ATTRIBUTE_MAP[1], v) then
			battleRoleAtt:ModMul(v, self.reduceMul or 0, ATTRIBUTE_LEVEL.SECOND)
			battleRoleAtt:ModAdd(v, self.reduceAdd or 0, ATTRIBUTE_LEVEL.SECOND)
		end

		if supCard ~= nil and table.contains(ATTRIBUTE_MAP[1], v) then
			local mul = GetConfigArgJson("JoinAttCombat")[1] * 0.01

			battleRoleAtt:ModAdd(v, ExchangeAttValue(v, supCard:GetAtt(v) * mul), ATTRIBUTE_LEVEL.SECOND)
		end

		battleRoleAtt:ModMul(v, self.activeSkillAtt:GetExtraMul(v), ATTRIBUTE_LEVEL.THIRD)
		battleRoleAtt:ModAdd(v, self.activeSkillAtt:GetExtraAdd(v), ATTRIBUTE_LEVEL.THIRD)
	end

	return battleRoleAtt
end

function InfoRole:GetGiftType()
	local subType = 1

	for _, v in ipairs(self.data.FavorItemList) do
		if v[2] == 1 then
			local info = ItemManager:Get(v[1])

			subType = tonumber(info.data.SubType)

			break
		end
	end

	return subType
end

function InfoRole:HasGift()
	if self.pb.favorLevelRecord and self.curFavorLevel then
		-- block empty
	else
		return false
	end

	if self.pb.favorLevelRecord == 0 then
		return false
	end

	local mayHave = self.pb.favorLevelRecord < self.curFavorLevel

	if mayHave then
		return LevelManager:HasGift(self.pb.favorLevelRecord, self.curFavorLevel)
	end

	return false
end

function InfoRole:UpdateFavorAward(newLevel)
	if newLevel and newLevel > self.pb.favorLevelRecord then
		self.pb.favorLevelRecord = newLevel

		if self.pb.favorLevelRecord > self.curFavorLevel then
			self.pb.favorLevelRecord = self.curFavorLevel
		end
	end
end

function InfoRole:GetRoleCardId()
	return self.pb.roleCardId
end

function InfoRole:SetRoleCardId(roleCardId)
	self.pb.roleCardId = roleCardId
end

function InfoRole:GetEquipStatus()
	return self.pb.equipStatus or 0
end

function InfoRole:SetEquipStatus()
	if self.pb.equipStatus == 1 then
		return
	end

	self.pb.equipStatus = 1
end

function InfoRole:GetEquipId(slotIndex)
	return self.data.EquipmentList[slotIndex]
end

function InfoRole:GetEquipSlot(slotIndex)
	return self.pb.slots[slotIndex]
end

function InfoRole:IsEquipSlotUnlocked(slotIndex)
	local needLevel = GetConfigArgJson("EquipmentUnlock")[slotIndex]

	return needLevel <= self.curFavorLevel
end

function InfoRole:GetActiveSameSuitSubTypeNum(scrollId, slotIndex, isInclude)
	local infoScroll = ItemManager:Get(scrollId)
	local subType = tonumber(infoScroll.data.SubType)
	local sameCnt = 0

	for k = 1, #self.pb.slots do
		local v = self.pb.slots[k]

		if v.scroll ~= 0 then
			local info = ItemManager:Get(v.scroll)
			local stype = tonumber(info.data.SubType)

			if subType == stype then
				if isInclude then
					sameCnt = sameCnt + 1
				elseif k ~= slotIndex then
					sameCnt = sameCnt + 1
				end
			end
		end
	end

	return sameCnt
end

eInterctAnimType = {
	touchHead = 7,
	getFavor = 10,
	idle = 23,
	rankup = 12,
	changeHead = 15,
	birthdayGift = 18,
	birthdaySend = 19,
	helloMorning = 1,
	helloNight = 2,
	changeBack = 16,
	levelup = 11,
	helloZeroDay = 21,
	favorGift = 6,
	sendGiftToPlayer = 4,
	changeSuitIdle = 17,
	readySendGiftToPlayer = 3,
	helloAfternoon = 20,
	tapHead = 8,
	supreme = 13,
	birthdayPlayerSend = 22,
	changeSuit = 14,
	tapBody = 9,
	sendGift = 5
}

function InfoRole:InitFavorAni(_interectSettingFile)
	self.interectSettingFile = _interectSettingFile
end

function InfoRole:UpdateAllFavorAni()
	if IsNil(self.interectSettingFile) or self.interectSettingFile == nil then
		return
	end

	local list = GetISFBehaviour(self.interectSettingFile)

	for i = 1, eInterctAnimType.idle do
		self:FlushData(i, list[i])
	end
end

function InfoRole.GetDaySection()
	local ds = DateUtil.getDateSection()

	if ds == 1 then
		return eInterctAnimType.helloZeroDay
	elseif ds == 2 then
		return eInterctAnimType.helloMorning
	elseif ds == 3 then
		return eInterctAnimType.helloAfternoon
	else
		return eInterctAnimType.helloNight
	end
end

function InfoRole:FlushData(i, group)
	self.dictAvalible[i] = self.dictAvalible[i] or {}

	local listBehaviour = group.m_Behaviours
	local behaviourData
	local preCount = #self.dictAvalible[i]

	self.dictAvalible[i] = {}

	for n = 1, listBehaviour.Count do
		behaviourData = listBehaviour:get_Item(n - 1)

		if self.curFavorLevel >= tonumber(behaviourData.Level) then
			table.insert(self.dictAvalible[i], n)
		end
	end

	local hasNew = preCount < #self.dictAvalible[i]

	if hasNew then
		table.sort(self.dictAvalible[i], function(a, b)
			local b1 = listBehaviour:get_Item(a - 1)
			local b2 = listBehaviour:get_Item(b - 1)

			return tonumber(b1.Level) > tonumber(b2.Level)
		end)

		return
	end

	local randType = group.m_RandomType

	if BehaviourRandomType.RND == randType then
		self.dictAvalible[i] = Shuffle(self.dictAvalible[i])
	elseif BehaviourRandomType.DES == randType then
		table.sort(self.dictAvalible[i], function(a, b)
			local b1 = listBehaviour:get_Item(a - 1)
			local b2 = listBehaviour:get_Item(b - 1)

			return tonumber(b1.Level) > tonumber(b2.Level)
		end)
	elseif BehaviourRandomType.HLR == randType then
		local listRate = {
			1,
			10,
			20,
			30,
			40,
			50,
			60,
			70,
			80,
			90
		}
		local favorIndex = self.sectionIndex
		local randMax = 0

		for n = 1, #listRate do
			if n <= favorIndex then
				randMax = randMax + listRate[n]
			end
		end

		local n = math.random(0, randMax)
		local resultIndex = 1

		for n = 1, #listRate do
			if n >= listRate[n] then
				resultIndex = n
			end
		end

		favorIndex = resultIndex

		local list = {}
		local tlist = self.dictAvalible[i]

		for k = 1, #tlist do
			local nc = tlist[k]
			local d = listBehaviour:get_Item(nc - 1)
			local tf = RoleMgr:GetFavorSectionIndex(d.Level)

			if tf == favorIndex then
				table.insert(list, nc)
			end
		end

		self.dictAvalible[i] = Shuffle(list)
	elseif BehaviourRandomType.STG == randType then
		local favorIndex = self.sectionIndex
		local list = {}
		local tlist = self.dictAvalible[i]

		for k = 1, #tlist do
			local nc = tlist[k]
			local d = listBehaviour:get_Item(nc - 1)
			local tf = RoleMgr:GetFavorSectionIndex(d.Level)

			if tf == favorIndex then
				table.insert(list, nc)
			end
		end

		self.dictAvalible[i] = Shuffle(list)
	elseif BehaviourRandomType.TIM == randType then
		table.sort(self.dictAvalible[i], function(a, b)
			local b1 = listBehaviour:get_Item(a - 1)
			local b2 = listBehaviour:get_Item(b - 1)

			return tonumber(b1.Level) > tonumber(b2.Level)
		end)
	end
end

function InfoRole:GetFavorMotionLevel(favorMotionType)
	local list = {}

	for i = 1, self.sectionIndex do
		local listMotion = self.voiceData.MotionList[i]

		for n = 1, #listMotion do
			if listMotion[n] == favorMotionType then
				table.insert(list, i)
			end
		end
	end

	return list
end

local maxFavorSect = 5

function InfoRole:GetRandomMotionLevel(favorMotionType)
	local listLevel = self:GetFavorMotionLevel(favorMotionType)
	local r = math.random(1, #listLevel)

	if r > maxFavorSect then
		return maxFavorSect - 1
	end

	return listLevel[r] - 1
end

function InfoRole:GetNextMotionLevel(favorMotionType)
	local listLevel = self:GetFavorMotionLevel(favorMotionType)

	if self.listPlayMotionIndex[favorMotionType] == nil then
		self.listPlayMotionIndex[favorMotionType] = #listLevel
	else
		self.listPlayMotionIndex[favorMotionType] = self.listPlayMotionIndex[favorMotionType] - 1

		if self.listPlayMotionIndex[favorMotionType] < 1 then
			self.listPlayMotionIndex[favorMotionType] = #listLevel
		end
	end

	local r = self.listPlayMotionIndex[favorMotionType]

	if r > maxFavorSect then
		return maxFavorSect - 1
	end

	return listLevel[r] - 1
end

RoleMgr = {}
eRoleDotType = {
	Talent = 2,
	Equip = 1,
	Fitting = 3
}

local dictRole = {}
local listRole = {}

RoleMgr.CardFittingLongPress = false
RoleMgr.CardFittingUI3DActorRotate = false

function RoleMgr:GetRole(vRoleId)
	if vRoleId == 0 then
		return nil
	end

	local ret = dictRole[vRoleId]

	if not ret then
		ret = InfoRole(vRoleId)
		dictRole[vRoleId] = ret

		table.insert(listRole, ret)
	end

	if ret.data == nil then
		print("not roleID " .. vRoleId)
	end

	return ret
end

function RoleMgr:GetAllRole()
	local list = {}

	for _, v in pairsByKeys(RoleData) do
		local infoRole = self:GetRole(v.ID)

		if infoRole and infoRole.data.Version == 1 then
			table.insert(list, infoRole)
		end
	end

	return list
end

function RoleMgr:GetAllHoldRole()
	local list = {}
	local allRoles = self:GetAllRole()

	for _, v in ipairs(allRoles) do
		if v.hold then
			table.insert(list, v)
		end
	end

	return list
end

function RoleMgr:GetAllHoldTeamRole()
	local list = {}
	local allRoles = self:GetAllRole()
	local listTeam = RoleMgr:GetTeamList()

	for _, v in ipairs(allRoles) do
		for i = 1, 4 do
			for n = 1, #listTeam[i].MemberList do
				if v.id == listTeam[i].MemberList[n] then
					local infoRole = self:GetRole(v.id)

					table.insert(list, infoRole)
				end
			end
		end
	end

	return list
end

function RoleMgr:GetAllRoleId()
	local list = {}
	local allRoles = self:GetAllRole()

	for _, v in ipairs(allRoles) do
		table.insert(list, v.id)
	end

	return list
end

function RoleMgr:GetActorData(id)
	return ActorData[id]
end

function RoleMgr:IndexToAttrType(attrIndex)
	return GetAttKeyByIndex(attrIndex)
end

function RoleMgr:GetTeamList()
	local teamList = {}

	for i = 1, #RoleTeamData do
		teamList[RoleTeamData[i].TeamOrder] = RoleTeamData[i]
	end

	return teamList
end

function RoleMgr:GetRoleScore(infoRole)
	if not infoRole then
		return 0
	end

	local cards = RoleCardMgr:GetRoleHoldCard(infoRole.id)

	local function fun(a, b)
		local a1 = RoleCardMgr:GetCardFightValue(a)
		local b1 = RoleCardMgr:GetCardFightValue(b)

		return b1 < a1
	end

	table.sort(cards, fun)

	return RoleCardMgr:GetFightValue(infoRole, cards[1])
end

function RoleMgr:GetAllHoldRoleSort(type)
	local score = {}

	local function func(a, b)
		local aScore

		if score[a.id] ~= nil then
			aScore = score[a.id]
		else
			aScore = Mathf.Floor(RoleMgr:GetRoleScore(a))
			score[a.id] = aScore
		end

		local bScore

		if score[b.id] ~= nil then
			bScore = score[b.id]
		else
			bScore = Mathf.Floor(RoleMgr:GetRoleScore(b))
			score[b.id] = bScore
		end

		if aScore == bScore then
			if type == 1 then
				return a.id > b.id
			else
				return a.id < b.id
			end
		elseif type == 1 then
			return bScore < aScore
		else
			return aScore < bScore
		end
	end

	local listHoldRole = self:GetAllHoldRole()

	table.sort(listHoldRole, func)

	return listHoldRole
end

function RoleMgr:GetMaxFavorRole()
	local function func(a, b)
		if a.curFavorLevel == b.curFavorLevel then
			if a.curFavorExp == b.curFavorExp then
				return a.id < b.id
			else
				return a.curFavorExp > b.curFavorExp
			end
		else
			return a.curFavorLevel > b.curFavorLevel
		end
	end

	local listHoldRole = self:GetAllHoldRole()

	table.sort(listHoldRole, func)

	return listHoldRole[1]
end

function RoleMgr:GetFavorSectionIndex(favorLevel)
	local sectionIndex = 1
	local listSect = GetConfigArgJson("FavorSection")

	for i = 1, #listSect do
		local num = listSect[i]

		if num < favorLevel then
			sectionIndex = i + 1
		end
	end

	return sectionIndex
end

function RoleMgr:GetRoleDefaultCard(roleId)
	local defaultCard = RoleCardMgr:GetRoleAllCard(roleId)[1]

	if defaultCard then
		return defaultCard
	end

	return nil
end

function RoleMgr:ForgeRole(id)
	local infoRole = InfoRole(id)

	local function fun(isAvatar)
		local avatars = {}

		for i = 1, #infoRole.actorData.DefaultAvatars do
			table.insert(avatars, infoRole.actorData.DefaultAvatars[i])
		end

		if isAvatar then
			table.insert(avatars, infoRole.data.PersonalWeapon)
		end

		return avatars
	end

	local pbRole = {
		favorExp = 0,
		nickName = "",
		roleCardId = 0,
		phoneBgId = 0,
		favorLevelRecord = 0,
		lastTopicId = 0,
		favorRankRecord = 0,
		id = id,
		playerId = PlayerInst.InfoPlayer.pid,
		clothes = fun(),
		nodes = {},
		avatars = fun(true),
		attrs = {
			0,
			0,
			0,
			0
		},
		weaponAvatar = infoRole.data.PersonalWeapon,
		slots = {
			{
				scroll = 0,
				quality = 1,
				slot = 1,
				grade = 0,
				level = 1,
				attributes = {}
			},
			{
				scroll = 0,
				quality = 1,
				slot = 2,
				grade = 0,
				level = 1,
				attributes = {}
			},
			{
				scroll = 0,
				quality = 1,
				slot = 3,
				grade = 0,
				level = 1,
				attributes = {}
			},
			{
				scroll = 0,
				quality = 1,
				slot = 4,
				grade = 0,
				level = 1,
				attributes = {}
			},
			{
				scroll = 0,
				quality = 1,
				slot = 5,
				grade = 0,
				level = 1,
				attributes = {}
			},
			{
				scroll = 0,
				quality = 1,
				slot = 6,
				grade = 0,
				level = 1,
				attributes = {}
			}
		}
	}

	infoRole:SetData(pbRole)

	return infoRole
end
