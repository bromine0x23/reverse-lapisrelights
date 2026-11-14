-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoEquipment.lua

local EquipmentData = require("luaData/Equipment")
local EquipmentUpgradeProperty = require("luaData/EquipmentUpgradeProperty")
local EquipmentUpgrade = require("luaData/EquipmentUpgrade")
local EquipmentQualityPromote = require("luaData/EquipmentQualityPromote")
local ScrollSetData = require("luaData/ScrollSetData")
local ScrollData = require("luaData/ScrollData")

InfoEquipment = class("InfoEquipment", InfoBase)
InfoEquipment.id = 1
InfoEquipment.data = nil

function InfoEquipment:ctor(pb)
	self.id = pb.equipId
	self.data = EquipmentData[self.id]
	self.pb = {}

	self:SetData(pb)

	self.curLevel = 1
	self.jobType = GetJobType(self.data.JobType)
end

function InfoEquipment:SetData(pb)
	self.pb.serialId = pb.serialId
	self.pb.roleId = pb.roleId
	self.pb.equipId = pb.equipId
end

function InfoEquipment:GetName()
	return Lang(self.data.Name)
end

function InfoEquipment:GetDesc()
	return Lang(self.data.Desc)
end

function InfoEquipment:GetIcon()
	return "UIDyAtlas/Equipment/" .. self.data.Icon
end

function InfoEquipment:SetIsNewState(state)
	PersistentStoreUtil.SetBool(PlayerInst.InfoPlayer.pid .. tostring(self.pb.serialId), state)
end

function InfoEquipment:GetIsNewState()
	return PersistentStoreUtil.GetBool(PlayerInst.InfoPlayer.pid .. tostring(self.pb.serialId), true)
end

EquipmentManager = {}
EquipmentManager.tlist = {}
EquipmentManager.listUpdateCost = {}
EquipmentManager.EquipSlotCnt = 6
EquipmentManager.EquipEnchantCnt = 3
EquipmentManager.EquipEnchantSuitCnt = 2
EquipmentManager.LastDevelopTab = 0
EquipmentManager.LastRoleId = 0
EquipmentManager.NotExchangeTipNextTime = false
EquipmentManager.NotCoverTipNextTime = false

function EquipmentManager:GetEquip(equipId)
	local pb = {}

	pb.equipId = equipId

	local equip = InfoEquipment(pb)

	return equip
end

function EquipmentManager:Init()
	self.listMaxQualityLevel = GetConfigArgJson("EquipLevelOfQuality")
	self.listEquipQuality = GetConfigArgJson("EquipQuality")
	self.listUpdateCost = {}

	for i = 1, #EquipmentUpgrade do
		local data = EquipmentUpgrade[i]

		if self.listUpdateCost[data.Level] == nil then
			self.listUpdateCost[data.Level] = {}
		end

		table.insert(self.listUpdateCost[data.Level], data)
	end

	EquipmentUpgrade = nil
	self.listQualityData = {}

	for i = 1, #EquipmentQualityPromote do
		local job = EquipmentQualityPromote[i].Job

		if self.listQualityData[job] == nil then
			self.listQualityData[job] = {}
		end

		table.insert(self.listQualityData[job], EquipmentQualityPromote[i])
	end

	EquipmentQualityPromote = nil
end

function EquipmentManager:GetQualityIndex(quality, grade)
	local index = 0

	for i = 1, quality do
		local maxGrade = self.listEquipQuality[i]

		if quality ~= i then
			index = index + maxGrade
		else
			index = index + grade + 1
		end
	end

	return index
end

function EquipmentManager:GetQualityByBreakNumber(num)
	local targetidx = num + 1
	local idx = 0

	for k, v in ipairs(self.listEquipQuality) do
		for i = 1, v do
			idx = idx + 1

			if idx == targetidx then
				return k, i - 1
			end
		end
	end

	return #self.listEquipQuality, self.listEquipQuality[#self.listEquipQuality] - 1
end

function EquipmentManager:GetNextQuality(quality, grade)
	local qua, gra = 1, 0
	local maxQuality = #self.listEquipQuality
	local maxGrade = self.listEquipQuality[quality]

	if grade + 1 == maxGrade then
		if quality == maxQuality then
			qua = quality
			gra = grade
		else
			qua = quality + 1
			gra = 0
		end
	else
		qua = quality
		gra = grade + 1
	end

	return qua, gra
end

function EquipmentManager:GetLastQuality(quality, grade)
	local qua, gra = 1, 0

	if grade - 1 >= 0 then
		qua = quality
		gra = grade - 1
	else
		qua = quality - 1

		if qua <= 0 then
			qua = 1
		end

		local maxGrade = self.listEquipQuality[qua]

		gra = maxGrade - 1
	end

	return qua, gra
end

function EquipmentManager:NextLevel(slot)
	local index = self:GetQualityIndex(slot.quality, slot.grade)
	local maxLevel = self.listMaxQualityLevel[index]
	local nextLevel = slot.level + 1

	if maxLevel < nextLevel then
		return maxLevel
	end

	return nextLevel
end

function EquipmentManager:GetCostList(level, job, slotIndex)
	local list = self.listUpdateCost[level]

	for _, v in pairs(list) do
		if v.Job == job and v.Slot == slotIndex then
			return v.CostList
		end
	end

	return nil
end

function EquipmentManager:GetProp(level, job, slotIndex, id)
	local list = EquipmentUpgradeProperty[level]

	if slotIndex == 1 then
		for k, v in pairs(list.Weapon) do
			if v[1] == id then
				local allprop = {}

				for i = 2, #v do
					table.insert(allprop, v[i])
				end

				return self:DealWithListNumber(allprop)
			end
		end

		return {
			0,
			0,
			0,
			0
		}
	else
		local strJob = ""

		if job == eJobType.Strength then
			strJob = "Strength"
		elseif job == eJobType.Assistance then
			strJob = "Assistance"
		elseif job == eJobType.Intelligence then
			strJob = "Intelligence"
		elseif job == eJobType.Speed then
			strJob = "Speed"
		elseif job == eJobType.Artifice then
			strJob = "Artifice"
		end

		local str = strJob .. slotIndex
		local listAttr = self:DealWithListNumber(list[str])

		return listAttr
	end
end

function EquipmentManager:GetQualityCostList(job, quality, grade, slotIdx)
	local list = self.listQualityData[job]

	for _, v in pairs(list) do
		if v.PresentQuality == quality and v.QualityGrade == grade and v.Slot == slotIdx then
			return v.CostList
		end
	end
end

function EquipmentManager:GetQualityProp(job, quality, grade, slotIdx)
	local list = self.listQualityData[job]

	for _, v in pairs(list) do
		if v.PresentQuality == quality and v.QualityGrade == grade and v.Slot == slotIdx then
			local listAttr = self:DealWithListNumber(v.PromoteProperty)

			return listAttr
		end
	end
end

function EquipmentManager:DealWithListNumber(list)
	for i = 1, #list do
		list[i] = math.floor(list[i] + 0.5)
	end

	return list
end

function EquipmentManager:IsEquipHighestQuality(slot)
	local maxQuality = #self.listEquipQuality
	local maxGrade = self.listEquipQuality[slot.quality]

	if slot.quality == maxQuality and slot.grade + 1 == maxGrade then
		return true
	end

	return false
end

function EquipmentManager:IsEquipHighestLevel(slot)
	local isHighestQuality = self:IsEquipHighestQuality(slot)

	if isHighestQuality then
		local index = self:GetQualityIndex(slot.quality, slot.grade)
		local highestLv = self.listMaxQualityLevel[index]

		if slot.level == highestLv then
			return true
		end
	end

	return false
end

function EquipmentManager:GetBreakNum(slot)
	local quality = slot.quality
	local grade = slot.grade
	local num = 0

	for i = 1, quality - 1 do
		num = num + self.listEquipQuality[i]
	end

	num = num + grade

	return num
end

function EquipmentManager:GetEquipSlotIconAndName(infoRole, infoEquip, quality, grade)
	local icon = infoEquip:GetIcon()
	local name = infoEquip:GetName()
	local list = AvatarManager:GetWeaponAvatarList(infoRole)

	if infoEquip.data.Weapon ~= "" then
		for _, v in pairs(list) do
			if v.RealEquiped then
				name = Lang(v.InfoAvatar.data.Name)
				icon = v.InfoAvatar.data.Icon

				break
			end
		end
	end

	if grade == 0 then
		-- block empty
	end

	return icon, name
end

function EquipmentManager:GetDlgEquipDevelopIntenseDot(slotIdx, infoRole)
	local infoSlot = infoRole:GetEquipSlot(slotIdx)
	local equipId = infoRole:GetEquipId(slotIdx)
	local infoEquip = EquipmentManager:GetEquip(equipId)
	local quality = infoSlot.quality
	local grade = infoSlot.grade
	local isMaxLv = EquipmentManager:IsEquipHighestLevel(infoSlot)
	local isMaxQua = EquipmentManager:IsEquipHighestQuality(infoSlot)
	local qualityIdx = EquipmentManager:GetQualityIndex(quality, grade)
	local curLimitLv = EquipmentManager.listMaxQualityLevel[qualityIdx]
	local listCost = {}

	if not isMaxLv and curLimitLv > infoSlot.level then
		listCost = EquipmentManager:GetCostList(infoSlot.level, infoEquip.jobType, slotIdx)
	elseif not isMaxQua and infoSlot.level == curLimitLv then
		listCost = EquipmentManager:GetQualityCostList(infoEquip.jobType, quality, grade, slotIdx)
	else
		return false
	end

	local function func(list, _type)
		local temp = {}

		for _, v in pairs(list) do
			local info = ItemManager:Get(v[1])

			if _type == 1 then
				if info.data.Type ~= "P_GOLD" then
					table.insert(temp, v)
				end
			elseif info.data.Type == "P_GOLD" then
				table.insert(temp, v)
			end
		end

		return temp
	end

	local listCostItem = func(listCost, 1)
	local listCostCoin = func(listCost, 2)
	local isEnough = true

	local function func(costs)
		for i = 1, #costs do
			local cost = costs[i]

			isEnough = ItemManager:IsItemHoldEnough(cost[1], cost[2], true)
		end
	end

	if isEnough then
		func(listCostItem)
	end

	if isEnough then
		func(listCostCoin)
	end

	return isEnough
end

function EquipmentManager:GetPageEquipDevelopDot(infoRole, index)
	if index then
		local t = infoRole.pb.slots

		if infoRole:IsEquipSlotUnlocked(index) then
			return EquipmentManager:GetDlgEquipDevelopIntenseDot(index, infoRole)
		else
			return false
		end
	else
		local t = infoRole.pb.slots

		for i = 1, #t do
			if infoRole:IsEquipSlotUnlocked(i) and EquipmentManager:GetDlgEquipDevelopIntenseDot(i, infoRole) then
				return true
			end
		end
	end

	return false
end

function EquipmentManager:GetEquipNotMaxResult(infoRole)
	local t = infoRole.pb.slots

	for i = 1, #t do
		if infoRole:IsEquipSlotUnlocked(i) then
			local infoSlot = infoRole:GetEquipSlot(i)
			local isMaxLv = EquipmentManager:IsEquipHighestLevel(infoSlot)
			local isMaxQua = EquipmentManager:IsEquipHighestQuality(infoSlot)

			if not isMaxLv or not isMaxQua then
				return true
			end
		end
	end

	return false
end

function EquipmentManager:GetDevelopNeedItem(equipList, needItemList, onlyCheckCost)
	if #equipList == 0 then
		return needItemList
	end

	local insertIndex = #equipList
	local lastInfoSlot = table.remove(equipList)

	for i = #equipList, 1, -1 do
		if lastInfoSlot.level > equipList[i].level or lastInfoSlot.level == equipList[i].level and lastInfoSlot.infoSlot.slot > equipList[i].infoSlot.slot then
			insertIndex = i + 1
		end
	end

	table.insert(equipList, insertIndex, lastInfoSlot)

	local curInfoSlot = equipList[#equipList]
	local listCost = EquipmentManager:GetCostList(curInfoSlot.level, curInfoSlot.infoEquip.jobType, curInfoSlot.infoSlot.slot)
	local isEnough = true

	if needItemList == nil then
		needItemList = {}
	end

	local tmpNeed = TableClone(needItemList)

	for i, v in ipairs(listCost) do
		local need = ItemManager:IsItemHoldEnoughContentSyn(v[1], v[2], tmpNeed, onlyCheckCost)

		if need then
			tmpNeed = need
		else
			isEnough = False

			break
		end
	end

	if isEnough then
		needItemList = TableClone(tmpNeed)
		curInfoSlot.level = curInfoSlot.level + 1

		local index = EquipmentManager:GetQualityIndex(curInfoSlot.infoSlot.quality, curInfoSlot.infoSlot.grade)
		local curLimitLv = EquipmentManager.listMaxQualityLevel[index]

		if curLimitLv == curInfoSlot.level then
			table.remove(equipList)
		end
	else
		table.remove(equipList)
	end

	needItemList = EquipmentManager:GetDevelopNeedItem(equipList, needItemList, onlyCheckCost)

	return needItemList
end

function EquipmentManager:GetAllEquipDevelopNeedItem(infoRole, onlyCheckCost)
	local equipList = {}

	for i, v in ipairs(infoRole.pb.slots) do
		if infoRole:IsEquipSlotUnlocked(i) then
			local data = {}

			data.infoSlot = v
			data.level = v.level
			data.infoEquip = EquipmentManager:GetEquip(infoRole.data.EquipmentList[v.slot])

			table.insert(equipList, data)
		end
	end

	for i = #equipList, 1, -1 do
		local index = EquipmentManager:GetQualityIndex(equipList[i].infoSlot.quality, equipList[i].infoSlot.grade)
		local curLimitLv = EquipmentManager.listMaxQualityLevel[index]

		if equipList[i].level == curLimitLv then
			table.remove(equipList, i)
		end
	end

	table.sort(equipList, function(v1, v2)
		if v1.level > v2.level then
			return true
		end

		if v1.level < v2.level then
			return false
		end

		if v1.infoSlot.slot > v2.infoSlot.slot then
			return true
		end

		return false
	end)

	local needItemList = EquipmentManager:GetDevelopNeedItem(equipList, needItemList, onlyCheckCost)

	return needItemList
end

function EquipmentManager:GetAllEquipBreakNeedItem(infoRole, onlyCheckCost)
	local equipList = {}

	for i, v in ipairs(infoRole.pb.slots) do
		local index = EquipmentManager:GetQualityIndex(v.quality, v.grade)
		local curLimitLv = EquipmentManager.listMaxQualityLevel[index]

		if infoRole:IsEquipSlotUnlocked(i) and v.level == curLimitLv and not EquipmentManager:IsEquipHighestQuality(v) then
			local data = {}

			data.infoSlot = v
			data.level = v.level
			data.infoEquip = EquipmentManager:GetEquip(infoRole.data.EquipmentList[v.slot])

			table.insert(equipList, data)
		end
	end

	table.sort(equipList, function(v1, v2)
		if v1.level > v2.level then
			return true
		end

		if v1.level < v2.level then
			return false
		end

		if v1.infoSlot.slot > v2.infoSlot.slot then
			return true
		end

		return false
	end)

	local needItemList = EquipmentManager:GetBreakNeedItem(equipList, needItemList, onlyCheckCost)

	return needItemList
end

function EquipmentManager:GetBreakNeedItem(equipList, needItemList, onlyCheckCost)
	if #equipList == 0 then
		return needItemList
	end

	local curInfoSlot = equipList[#equipList]
	local listCost = EquipmentManager:GetQualityCostList(curInfoSlot.infoEquip.jobType, curInfoSlot.infoSlot.quality, curInfoSlot.infoSlot.grade, curInfoSlot.infoSlot.slot)
	local isEnough = true

	if needItemList == nil then
		needItemList = {}
	end

	local tmpNeed = TableClone(needItemList)

	for i, v in ipairs(listCost) do
		local need = ItemManager:IsItemHoldEnoughContentSyn(v[1], v[2], tmpNeed, onlyCheckCost)

		if need then
			tmpNeed = need
		else
			isEnough = false

			break
		end
	end

	if isEnough then
		needItemList = TableClone(tmpNeed)

		table.remove(equipList)
	else
		table.remove(equipList)
	end

	needItemList = EquipmentManager:GetBreakNeedItem(equipList, needItemList, onlyCheckCost)

	return needItemList
end

function EquipmentManager.GetScrollData(scrollID)
	for _, v in ipairs(ScrollData) do
		if scrollID == v.ScrollID then
			return v
		end
	end

	return nil
end

function EquipmentManager.GetEnchantRank(slotIndex, reelId, attr)
	if not attr then
		return 0, 1
	end

	local attrPool = {}
	local randomAttr = {}

	for _, v in pairs(ScrollData) do
		if v.Slot == slotIndex and v.ScrollID == reelId then
			attrPool = v.ValueList

			break
		end
	end

	for _, v in ipairs(attrPool) do
		if attr.type == v[2] and attr.param == v[3] then
			randomAttr = v

			break
		end
	end

	local min = randomAttr[#randomAttr - 1]
	local max = randomAttr[#randomAttr] or 1
	local rate = attr.value / max
	local rank = 1
	local average = max / 5

	for i = 1, 5 do
		if attr.value <= i * average then
			rank = i

			break
		end
	end

	return rate, rank
end

function EquipmentManager.GetSuitByScrollType(scrollType)
	local listSuit = {}

	for k, v in ipairs(ScrollSetData) do
		if scrollType == v.ScrollType then
			listSuit[#listSuit + 1] = v
		end
	end

	return listSuit
end

function EquipmentManager.GetEquipResonanceByRole(infoRole)
	local list = {}

	for _, v in ipairs(infoRole.pb.slots) do
		if v.scroll and v.scroll ~= 0 then
			local infoItem = ItemManager:Get(v.scroll)
			local scrollType = tonumber(infoItem.data.SubType)
			local temp = {}

			if #list == 0 then
				temp.scrollType = scrollType
				temp.num = 1

				table.insert(list, temp)
			else
				local index = 0

				for i = 1, #list do
					if scrollType == list[i].scrollType then
						index = i

						break
					end
				end

				if index == 0 then
					temp = {
						scrollType = scrollType
					}
					temp.num = 1

					table.insert(list, temp)
				else
					list[index].num = list[index].num + 1
				end
			end
		end
	end

	local listReson = {}

	for _, z in ipairs(list) do
		if z.num >= 3 then
			local listSuit = EquipmentManager.GetSuitByScrollType(z.scrollType)

			for _, n in ipairs(listSuit) do
				if z.num >= n.Number then
					listReson[#listReson + 1] = n
				end
			end
		end
	end

	return listReson
end

function EquipmentManager.GetSuitIconByScrollType(scrollType)
	for _, v in ipairs(ScrollSetData) do
		if scrollType == v.ScrollType then
			return v.Img
		end
	end

	return "UIDyAtlas/Scroll/IC_ENC_201"
end

function EquipmentManager.GetEquipResonanceSkillByRole(infoRole)
	local listSkill = {}
	local listReson = EquipmentManager.GetEquipResonanceByRole(infoRole)

	for k, v in ipairs(listReson) do
		local infoSkill = TalentManager:Get(v.Buff)

		if infoSkill then
			listSkill[#listSkill + 1] = infoSkill
		end
	end

	return listSkill
end
