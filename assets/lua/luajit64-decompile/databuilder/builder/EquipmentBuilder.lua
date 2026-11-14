-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/DataBuilder/Builder/EquipmentBuilder.lua

EquipmentBuilder = BClass("EquipmentBuilder")

function EquipmentBuilder:ctor(pbEquip)
	self.id = pbEquip.id
	self.data = ConfigTable.Equipment[self.id]
	self.attrs = {}
	self.enchantAbsAttrs = {}
	self.enchantPerAttrs = {}

	self:SetData(pbEquip.pbSlot)
end

function EquipmentBuilder:SetData(pbSlot)
	pbSlot = pbSlot or {}

	local levelAtt = self:GetProp(pbSlot.level, pbSlot.slot)
	local qualityAtt = self:GetQualityProp(pbSlot.quality, pbSlot.grade, pbSlot.slot)

	Attribute:Init()

	for k, v in pairsByKeys(ATTRIBUTE_NAME) do
		Attribute:ModifyAbsValue(v, (levelAtt[k] or 0) + (qualityAtt[k] or 0))
	end

	self.attrs = Attribute:GetAttr()

	Attribute:Init()

	if pbSlot.attributes and #pbSlot.attributes > 0 then
		for _, z in pairs(pbSlot.attributes) do
			local name = GetKeyByIndex(z.type)

			if z.param == 1 then
				Attribute:ModifyAbsValue(name, z.value)
			elseif z.param == 2 then
				Attribute:ModifyPerValue(name, z.value / 1000)
			elseif z.param == 3 then
				Attribute:ModifyAbsValue(name, z.value / 1000)
			end
		end
	end

	self.enchantAbsAttrs = Attribute.attAbsTab
	self.enchantPerAttrs = Attribute.attPerTab
end

function EquipmentBuilder:GetProp(level, slotIdx)
	local list = ConfigTable.EquipmentUpgradeProperty[level]

	if list == nil then
		return {
			0,
			0,
			0,
			0
		}
	end

	if slotIdx == 1 then
		local listAttr = self:DealWithListNumber(list.Weapon[self.id])

		return listAttr
	else
		local str = self.data.JobType .. slotIdx
		local listAttr = self:DealWithListNumber(list[str])

		return listAttr
	end
end

function EquipmentBuilder:GetQualityProp(quality, grade, slotIdx)
	for _, v in pairsByKeys(ConfigTable.EquipmentQualityPromote) do
		if v.Job == GetJobType(self.data.Job) and v.PresentQuality == quality and v.QualityGrade == grade and v.Slot == slotIdx then
			local listAttr = self:DealWithListNumber(v.PromoteProperty)

			return listAttr
		end
	end
end

function EquipmentBuilder:DealWithListNumber(list)
	if list == nil then
		return {
			0,
			0,
			0,
			0
		}
	end

	local listCopy = {}

	for i = 1, #list do
		listCopy[i] = math.floor(list[i] + 0.5)
	end

	return listCopy
end
