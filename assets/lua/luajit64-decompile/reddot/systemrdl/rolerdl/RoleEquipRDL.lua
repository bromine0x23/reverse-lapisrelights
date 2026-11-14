-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/RoleRDL/RoleEquipRDL.lua

local RoleEquipRDL = {}
local KEY_RD_EQUIP_ENCHANT = "KEY_RD_EQUIP_ENCHANT"
local KEY_RD_EQUIP_SLOT_UNLOCK = "KEY_RD_EQUIP_SLOT_UNLOCK"
local RD_Equip_Branch_Path = {
	Enchant = "Equip/Enchant/%d/%d/Enchant",
	Enchant_New = "Equip/Enchant/%d/%d/New",
	Unlock = "Role/%d/Equip/%d/Unlock",
	Fast_Intense = "Role/%d/Equip/Fast_Intense"
}
local NEW_ENCHANT_REEL = {}
local UNLOCK_EQUIP = {}
local PRE_ITEM_STATE = false
local PRE_NEW_STATE = false

function RoleEquipRDL.Init()
	local t = PersistentStoreUtil.GetList(KEY_RD_EQUIP_ENCHANT)

	for _, v in ipairs(t) do
		local reelId = tonumber(v)

		if not table.contains(NEW_ENCHANT_REEL, reelId) then
			table.insert(NEW_ENCHANT_REEL, reelId)
		end
	end

	PRE_NEW_STATE = #NEW_ENCHANT_REEL > 0

	local t = ItemManager:GetScrollItemList()

	PRE_ITEM_STATE = #t > 0
end

function RoleEquipRDL.RunEquipLogic(role)
	if role == nil or not role.hold then
		return
	end

	RoleEquipRDL.RunEquipQuickIntense(role)
	RoleEquipRDL.RunEquipUnlock(role)
	RoleEquipRDL.RunEnchantReel(role)
	RoleEquipRDL.RunEquipEnchant(role)

	local lock = not TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Equipment)

	if lock then
		local path = RedDotSystemMgr.GetFormatPath("Role/%d/Equip", role.id)

		RedDotSystemMgr.SetNodeLockState(path, true)
	end

	for i = 1, EquipmentManager.EquipSlotCnt do
		lock = not TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Enchant) or not role:IsEquipSlotUnlocked(i)

		if lock then
			local path = RedDotSystemMgr.GetFormatPath("Equip/Enchant/%d/%d", role.id, i)

			RedDotSystemMgr.SetNodeLockState(path, true)
		end
	end
end

local function CanEquipIntense(role, slotIdx)
	if not role:IsEquipSlotUnlocked(slotIdx) then
		return false
	end

	local slot = role:GetEquipSlot(slotIdx)
	local equip = EquipmentManager:GetEquip(role:GetEquipId(slotIdx))
	local qualityIdx = EquipmentManager:GetQualityIndex(slot.quality, slot.grade)
	local curLimitLv = EquipmentManager.listMaxQualityLevel[qualityIdx]
	local costitemdata = {}

	if slot.level < EquipmentManager.listMaxQualityLevel[qualityIdx] and curLimitLv > slot.level then
		costitemdata = EquipmentManager:GetCostList(slot.level, equip.jobType, slotIdx)
	elseif not EquipmentManager:IsEquipHighestQuality(slot) and slot.level == curLimitLv then
		costitemdata = EquipmentManager:GetQualityCostList(equip.jobType, slot.quality, slot.grade, slotIdx)
	else
		return false
	end

	for i = 1, #costitemdata do
		local cost = costitemdata[i]

		if not ItemManager:IsItemHoldEnough(cost[1], cost[2], true) then
			return false
		end
	end

	return true
end

local function CanEquipEnchant(role, slotIdx)
	local reelIds = ItemManager:GetScrollItemList()

	if #reelIds == 0 then
		return false
	end

	local slot = role:GetEquipSlot(slotIdx)

	if #slot.attributes ~= 0 then
		return false
	end

	return true
end

function RoleEquipRDL.RunEquipQuickIntense(role, slotIdx)
	local value = 0

	if slotIdx then
		if CanEquipIntense(role, slotIdx) then
			value = 1
		end
	else
		for i = 1, 6 do
			if CanEquipIntense(role, i) then
				value = 1

				break
			end
		end
	end

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Equip_Branch_Path.Fast_Intense, value, role.id)
end

function RoleEquipRDL.RunEquipUnlock(role)
	UNLOCK_EQUIP[role.id] = PersistentStoreUtil.GetList(KEY_RD_EQUIP_SLOT_UNLOCK .. role.id)

	for _, v in pairs(UNLOCK_EQUIP[role.id]) do
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Equip_Branch_Path.Unlock, 1, role.id, tonumber(v))
	end
end

function RoleEquipRDL.RunEnchantReel(role)
	local value = #NEW_ENCHANT_REEL > 0 and 1 or 0

	for i = 1, EquipmentManager.EquipSlotCnt do
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Equip_Branch_Path.Enchant_New, value, role.id, i)
	end
end

function RoleEquipRDL.RunEquipEnchant(role, slotIdx)
	local function Deal(idx)
		local value = 0

		if CanEquipEnchant(role, idx) then
			value = value + 1
		end

		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Equip_Branch_Path.Enchant, value, role.id, idx)
	end

	if slotIdx then
		Deal(slotIdx)
	else
		for i = 1, EquipmentManager.EquipSlotCnt do
			Deal(i)
		end
	end
end

function RoleEquipRDL.ResetEquipEnchant(role, slotIdx)
	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Equip_Branch_Path.Enchant, 0, role.id, slotIdx)
end

function RoleEquipRDL.ReCalculateEquipIntense()
	for _, role in ipairs(RoleRDL.ALL_HOLD_ROLE) do
		RoleEquipRDL.RunEquipQuickIntense(role)
	end
end

function RoleEquipRDL.ReCalculateEquipEnchant()
	local t = ItemManager:GetScrollItemList()
	local curItemState = #t > 0

	if PRE_ITEM_STATE == curItemState then
		return
	end

	for _, role in ipairs(RoleRDL.ALL_HOLD_ROLE) do
		RoleEquipRDL.RunEquipEnchant(role)
	end
end

function RoleEquipRDL.AddEquipNewEnchant()
	local newScrollIds = ItemRDL.NewScrollIds or {}

	if #newScrollIds > 0 then
		for _, v in ipairs(newScrollIds) do
			if not table.contains(NEW_ENCHANT_REEL, v) then
				table.insert(NEW_ENCHANT_REEL, v)
			end
		end

		local curState = #NEW_ENCHANT_REEL > 0

		if PRE_NEW_STATE ~= curState then
			for _, role in ipairs(RoleRDL.ALL_HOLD_ROLE) do
				RoleEquipRDL.RunEnchantReel(role)
			end

			PRE_NEW_STATE = curState
		end

		PersistentStoreUtil.SetList(KEY_RD_EQUIP_ENCHANT, NEW_ENCHANT_REEL)
	end
end

function RoleEquipRDL.SubEquipNewEnchant(reelId)
	if #NEW_ENCHANT_REEL == 0 then
		return
	end

	if reelId then
		if table.contains(NEW_ENCHANT_REEL, reelId) then
			table.removeByValue(NEW_ENCHANT_REEL, reelId)
		else
			return
		end
	else
		NEW_ENCHANT_REEL = {}
	end

	local curState = #NEW_ENCHANT_REEL > 0

	if PRE_NEW_STATE ~= curState then
		for _, role in ipairs(RoleRDL.ALL_HOLD_ROLE) do
			RoleEquipRDL.RunEnchantReel(role)
		end

		PRE_NEW_STATE = curState
	end

	PersistentStoreUtil.SetList(KEY_RD_EQUIP_ENCHANT, NEW_ENCHANT_REEL)
end

function RoleEquipRDL.AddUnlockEquipSlot(role)
	local config = GetConfigArgJson("EquipmentUnlock") or {}

	for i = 1, EquipmentManager.EquipSlotCnt do
		local unlockLv = config[i]

		if unlockLv > role.preFavorLevel and unlockLv <= role.curFavorLevel then
			table.insert(UNLOCK_EQUIP[role.id], tostring(i))
			PersistentStoreUtil.AddList(KEY_RD_EQUIP_SLOT_UNLOCK .. role.id, i)
			RedDotSystemMgr.SetNodeValueByFormatPath(RD_Equip_Branch_Path.Unlock, 1, role.id, i)

			local lock = not TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Enchant)

			if not lock then
				local path = RedDotSystemMgr.GetFormatPath("Equip/Enchant/%d/%d", role.id, i)

				RedDotSystemMgr.SetNodeLockState(path, false)
				RoleEquipRDL.RunEquipEnchant(role, i)
			end

			RoleEquipRDL.RunEquipQuickIntense(role, i)
		end
	end
end

function RoleEquipRDL.SubUnlockEquipSlot(role, slotIdx)
	if not table.contains(UNLOCK_EQUIP[role.id], tostring(slotIdx)) then
		return
	end

	table.removeByValue(UNLOCK_EQUIP[role.id], tostring(slotIdx))
	PersistentStoreUtil.SetList(KEY_RD_EQUIP_SLOT_UNLOCK .. role.id, UNLOCK_EQUIP[role.id])
	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Equip_Branch_Path.Unlock, 0, role.id, slotIdx)
end

function RoleEquipRDL.IsNewEnchantReel(reelId)
	if table.contains(NEW_ENCHANT_REEL, reelId) then
		return true
	end

	return false
end

return RoleEquipRDL
