-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/Common/SystemOpenMgr.lua

SystemOpenMgr = {}

local KEY_RD_SYSTEM_OPEN = "KEY_RD_SYSTEM_OPEN"

RED_DOT_SYSTEM_OPEN_TYPE = {
	CardPass = "Chapter/Card",
	Shop = "Shop",
	Bondage = "Arrow/Bondage",
	Fight = "Chapter",
	Work = "Arrow/Work",
	Operation = "Operation",
	Mail = "Mail",
	CardPetal = "Bloom/%d",
	Tower = "Chapter/Tower",
	Friend = "Arrow/Friend",
	TimeTask = "TaskLimitTime",
	Boss = "Chapter/Party",
	Theme = "Arrow/Theme",
	CardStar = "Break/%d",
	Equipment = "Role/%d/Equip",
	TeamPass = "Chapter/Comb",
	Union_Raid = "Union/Raid",
	Defficult = "Chapter/Main/Hard",
	BossRaid = "Chapter/BossRaid",
	BossLive = "Chapter/BossLive",
	Union_Wish = "Union/Wish",
	Union = "Union",
	Player = "Player",
	Role = "Role",
	AssetPass = "Chapter/Asset",
	Card = "Card",
	Enchant = "Equip/Enchant/%d/%d",
	PVP = "PVP",
	Task = "Task",
	Dress = "Role/%d/Fitting",
	CardLevel = "LvUp/%d",
	Communication = "Communication",
	Gift = "Role/%d/Interact/Gift"
}

local function DealLockState(red_dot_system_type, state, isInit)
	local formatpath = RED_DOT_SYSTEM_OPEN_TYPE[red_dot_system_type]

	if string.isNullOrEmpty(formatpath) then
		return
	end

	local function Unlock(path, lock)
		RedDotSystemMgr.SetNodeLockState(path, lock)
	end

	if red_dot_system_type == "Equipment" or red_dot_system_type == "Enchant" or red_dot_system_type == "Dress" or red_dot_system_type == "Gift" then
		if not isInit then
			for _, role in pairs(RoleRDL.ALL_HOLD_ROLE) do
				if red_dot_system_type ~= "Enchant" then
					local path = RedDotSystemMgr.GetFormatPath(formatpath, role.id)

					Unlock(path, state)
				else
					for i = 1, EquipmentManager.EquipSlotCnt do
						state = state or not role:IsEquipSlotUnlocked(i)

						local path = RedDotSystemMgr.GetFormatPath(formatpath, role.id, i)

						Unlock(path, state)
					end
				end
			end
		end
	elseif red_dot_system_type == "CardLevel" or red_dot_system_type == "CardStar" or red_dot_system_type == "CardPetal" then
		if not isInit then
			for _, card in pairs(CardRDL.ALL_HOLD_CARD) do
				local path = RedDotSystemMgr.GetFormatPath(formatpath, card.id)

				Unlock(path, state)
			end
		end
	else
		Unlock(formatpath, state)
	end
end

function SystemOpenMgr.InitRedDotSystemOpenState()
	for k in pairs(RED_DOT_SYSTEM_OPEN_TYPE) do
		local isOpen = TutorialMgr:IsOpenNoMsg(TutorialFunctionType[k])

		if not isOpen then
			DealLockState(k, true, true)
		end
	end
end

function SystemOpenMgr.DealSystemOpen(newbieId, state)
	local function GetType()
		for k, v in pairs(TutorialFunctionType) do
			if v == newbieId then
				return k
			end
		end

		return nil
	end

	DealLockState(GetType(), false)

	if newbieId == TutorialFunctionType.Boss then
		ChapterRDL.PartyRDL.DealSyetemOpen()
	end
end

function SystemOpenMgr.DealSystemsOpen(newbieIds)
	for _, v in pairs(newbieIds) do
		SystemOpenMgr.DealSystemOpen(v)
	end
end

function SystemOpenMgr.SetSystemOpenPlayerPrefs(newbieId, vbool)
	PersistentStoreUtil.SetBool(KEY_RD_SYSTEM_OPEN .. newbieId, vbool)
end

function SystemOpenMgr.GetSystemOpenPlayerPrefs(newbieId)
	return PersistentStoreUtil.GetBool(KEY_RD_SYSTEM_OPEN .. newbieId, false)
end

function SystemOpenMgr.GetLockState(systemtype, extra)
	if systemtype == nil then
		return false
	end

	if (systemtype == RED_DOT_SYSTEM_OPEN_TYPE.Equipment or systemtype == RED_DOT_SYSTEM_OPEN_TYPE.Enchant or systemtype == RED_DOT_SYSTEM_OPEN_TYPE.Dress or systemtype == RED_DOT_SYSTEM_OPEN_TYPE.Gift) and not extra then
		return false
	end
end

return SystemOpenUtil
