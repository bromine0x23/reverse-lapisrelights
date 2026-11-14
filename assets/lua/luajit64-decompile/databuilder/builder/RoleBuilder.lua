-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/DataBuilder/Builder/RoleBuilder.lua

RoleBuilder = BClass("RoleBuilder")

function RoleBuilder:ctor(pbRole)
	self.id = pbRole.id
	self.data = ConfigTable.Character[pbRole.id]
	self.favorLevel = 1
	self.weaponId = self.data.EquipmentList[1]
	self.attrs = {}
	self.equipAttrs = {}
	self.talentAttrs = {}
	self.listBattleSkill = {}
	self.listSkillNode = {}
	self.pb = {}

	self:SetData(pbRole)
end

function RoleBuilder:SetData(pbRole)
	self.pb.playerId = pbRole.playerId
	self.pb.clothes = pbRole.clothes
	self.pb.avatars = pbRole.avatars
	self.pb.weaponAvatar = pbRole.weaponAvatar
	self.pb.skillNodes = pbRole.nodes
	self.pb.slots = pbRole.slots
	self.pb.nodeSkills = pbRole.nodeSkills
	self.favorLevel = LevelMgr:GetLevel(eLevelType.F, pbRole.favorExp or 0)
	self.attrs = self:GetBaseAttr()
	self.equipAttrs = self:GetEquipAttr()
	self.talentAttrs = self:GetTalentAttr()
end

function RoleBuilder:GetBaseAttr()
	Attribute:Init()

	local tab1 = self.data.AttriList
	local tab2 = self.data.AttriList2
	local tab3 = self.data.AttriList3

	for k, v in pairs(GetMapTab({
		tab1,
		tab2,
		tab3
	})) do
		Attribute:ModifyAbsValue(k, v)
	end

	return Attribute:GetAttr()
end

function RoleBuilder:GetEquipAttr()
	local function fun(slotIndex)
		local needLevel = GetConfigArgJson("EquipmentUnlock")[slotIndex]

		return needLevel <= self.favorLevel
	end

	local listAvatar = {}

	if self.pb.avatars then
		for _, v in ipairs(self.pb.avatars) do
			local avatar = AvatarBuilder(v)

			table.insert(listAvatar, avatar)
		end
	end

	local listEquip = {}

	if self.pb.slots then
		for _, v in pairs(self.pb.slots) do
			if v.slot and fun(v.slot) then
				local equipId = self.data.EquipmentList[v.slot]
				local pbEquip = {
					id = equipId,
					pbSlot = v
				}
				local equip = EquipmentBuilder(pbEquip)

				table.insert(listEquip, equip)
			end
		end
	end

	local listSkill = {}
	local listReson = self:GetRoleEquipResonance()

	for _, v in ipairs(listReson) do
		local skill = SkillBuilder({
			level = 1,
			id = v.Buff
		})

		if skill.data.Type == eAllSkillType.system then
			table.insert(listSkill, skill)
		elseif skill.data.Type == eAllSkillType.battle then
			table.insert(self.listBattleSkill, skill)
		end
	end

	Attribute:Init()

	for _, v in pairs(ATTRIBUTE_NAME) do
		for _, n in pairs(listAvatar) do
			Attribute:ModifyAbsValue(v, n.attrs[v])
		end

		for _, n in pairs(listEquip) do
			Attribute:ModifyAbsValue(v, n.attrs[v])
			Attribute:ModifyPerValue(v, n.enchantPerAttrs[v])
			Attribute:ModeExtraValue(v, n.enchantAbsAttrs[v])
		end

		for _, n in pairs(listSkill) do
			Attribute:ModifyPerValue(v, n.attrs[v])
		end
	end

	return Attribute:GetAttr()
end

function RoleBuilder:GetTalentAttr()
	Attribute:Init()

	if self.pb.skillNodes then
		for i = 1, #self.pb.skillNodes do
			local pbNode = self.pb.skillNodes[i]
			local node = TalentBuilder(pbNode)

			if node.data.RewardType == eSkillNodeType.attri then
				local value = node.data.Attribute[node.level]
				local etype = node.data.AttributeType

				Attribute:ModifyAbsValue(GetKeyByIndex(etype), value)
			elseif node.data.RewardType == eSkillNodeType.skill then
				-- block empty
			end
		end
	end

	if self.pb.nodeSkills then
		for _, pbStarTalent in ipairs(self.pb.nodeSkills) do
			local skill = SkillBuilder(pbStarTalent)

			if skill.data.Type == eAllSkillType.system then
				table.insert(self.listSkillNode, skill)
			elseif skill.data.Type == eAllSkillType.battle then
				table.insert(self.listBattleSkill, skill)
			end
		end
	end

	return Attribute:GetAttr()
end

function RoleBuilder:GetRoleEquipResonance()
	local list = {}

	if self.pb.slots then
		for _, v in pairs(self.pb.slots) do
			if v.scroll and v.scroll ~= 0 then
				local scrollType = tonumber(ConfigTable.ItemData[v.scroll].SubType)

				if #list == 0 then
					table.insert(list, {
						num = 1,
						scrollType = scrollType
					})
				else
					local index = 0

					for i = 1, #list do
						if scrollType == list[i].scrollType then
							index = i

							break
						end
					end

					if index == 0 then
						table.insert(list, {
							num = 1,
							scrollType = scrollType
						})
					else
						list[index].num = list[index].num + 1
					end
				end
			end
		end
	end

	local function fun(scrollType)
		local listSuit = {}

		for _, v in ipairs(ConfigTable.ScrollSetData) do
			if scrollType == v.ScrollType then
				listSuit[#listSuit + 1] = v
			end
		end

		return listSuit
	end

	local listReson = {}

	for _, z in ipairs(list) do
		for _, n in ipairs(fun(z.scrollType)) do
			if z.num >= n.Number then
				listReson[#listReson + 1] = n
			end
		end
	end

	return listReson
end
