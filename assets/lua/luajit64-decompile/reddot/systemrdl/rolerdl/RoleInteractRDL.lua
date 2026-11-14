-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/SystemRDL/RoleRDL/RoleInteractRDL.lua

local favorPose = require("luaData/FavorPose")
local favoDance = require("luaData/DanceData")
local RoleInteractRDL = {}
local KEY_RD_INTERACT_STORY = "KEY_RD_INTERACT_STORY"
local KEY_RD_INTERACT_VOICE = "KEY_RD_INTERACT_VOICE"
local KEY_RD_INTERACT_GIFT = "KEY_RD_INTERACT_GIFT"
local KEY_RD_INTERACT_AR_DANCE = "KEY_RD_INTERACT_AR_DANCE"
local KEY_RD_INTERACT_AR_POSE = "KEY_RD_INTERACT_AR_POSE"
local RD_Interact_Branch_Path = {
	Ar_Dance = "Role/%d/Interact/AR/Dance",
	Story = "Role/%d/Interact/Information/Story",
	Voice = "Role/%d/Interact/Information/Voice",
	Ar_Pose = "Role/%d/Interact/AR/Pose",
	Gift = "Role/%d/Interact/Gift/%d"
}
local DanceUnlockStageList = {}
local RolePoseList = {}
local RoleFavoriteGift = {}
local NewUnlockVoice = {}

function RoleInteractRDL.RunInteractLogic(role)
	if next(RoleFavoriteGift) == nil then
		for _, v in pairs(RoleRDL.ALL_ROLE) do
			RoleFavoriteGift[v.id] = RoleFavoriteGift[v.id] or {}

			for i, j in ipairs(v.data.FavorItemList) do
				if j[2] == 1 then
					table.insert(RoleFavoriteGift[v.id], j[1])
				end
			end
		end
	end

	RoleInteractRDL.RunInteractStory(role)
	RoleInteractRDL.RunInteractVoice(role)
	RoleInteractRDL.RunInteractARDance(role)

	local lock = not TutorialMgr:IsOpenNoMsg(TutorialFunctionType.Gift)

	if lock then
		local path = RedDotSystemMgr.GetFormatPath("Role/%d/Interact/Gift", role.id)

		RedDotSystemMgr.SetNodeLockState(path, true)
	end
end

function RoleInteractRDL.RunInteractStory(role)
	local value = PersistentStoreUtil.GetInt(KEY_RD_INTERACT_STORY .. role.id, 0)

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Interact_Branch_Path.Story, value, role.id)
end

function RoleInteractRDL.RunInteractVoice(role)
	NewUnlockVoice[role.id] = NewUnlockVoice[role.id] or {}

	local list = PersistentStoreUtil.GetList(KEY_RD_INTERACT_VOICE .. role.id)

	for _, v in ipairs(list) do
		table.insert(NewUnlockVoice[role.id], tonumber(v))
	end

	local value = 0

	if #NewUnlockVoice[role.id] > 0 then
		value = 1
	end

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Interact_Branch_Path.Voice, value, role.id)
end

function RoleInteractRDL.RunInteractGift(role)
	local subType = role:GetGiftType()

	if subType then
		local value = PersistentStoreUtil.GetInt(KEY_RD_INTERACT_GIFT .. role.id .. subType, 0)

		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Interact_Branch_Path.Gift, value, role.id, subType)
	end
end

function RoleInteractRDL.RunInteractARDance(role)
	local value = PersistentStoreUtil.GetInt(KEY_RD_INTERACT_AR_DANCE, 0)

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Interact_Branch_Path.Ar_Dance, value, role.id)
end

function RoleInteractRDL.RunInteractARPose(role)
	local value = PersistentStoreUtil.GetInt(KEY_RD_INTERACT_AR_POSE .. role.id, 0)

	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Interact_Branch_Path.Ar_Pose, value, role.id)
end

function RoleInteractRDL.AddInteractStory(role)
	local hasStoryUnlock = false
	local infoChapter = ChapterMgr:GetCurChapter(ChapterType.role, role.id)

	if infoChapter ~= nil then
		for _, stage in ipairs(infoChapter.listStage) do
			if role.curFavorLevel >= stage.data.FavorLevel and not stage:IsPass() then
				hasStoryUnlock = true

				break
			end
		end
	end

	if hasStoryUnlock then
		PersistentStoreUtil.SetInt(KEY_RD_INTERACT_STORY .. role.id, 1)
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Interact_Branch_Path.Story, 1, role.id)
	end
end

function RoleInteractRDL.SubInteractStory(role)
	if PersistentStoreUtil.GetInt(KEY_RD_INTERACT_STORY .. role.id, 0) == 0 then
		return
	end

	PersistentStoreUtil.SetInt(KEY_RD_INTERACT_STORY .. role.id, 0)
	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Interact_Branch_Path.Story, 0, role.id)
end

function RoleInteractRDL.AddInteractVoice(role)
	local hasNew = false
	local interactSettingFile = ActorUtil.GetInteractSettingFile(role)

	if IsNil(interactSettingFile) then
		return
	end

	local listGroup = GetISFBehaviour(interactSettingFile)

	for i = 1, #listGroup do
		if i == 3 or i == 6 or i == 7 or i == 15 or i == 16 then
			-- block empty
		else
			local listBehaviour = listGroup[i].m_Behaviours

			for n = 1, listBehaviour.Count do
				local behaviourData = listBehaviour:get_Item(n - 1)

				if role.preFavorLevel < behaviourData.Level and role.curFavorLevel >= behaviourData.Level then
					table.insert(NewUnlockVoice[role.id], tonumber(behaviourData.VoiceName))

					hasNew = true
				end
			end
		end
	end

	if hasNew then
		PersistentStoreUtil.SetList(KEY_RD_INTERACT_VOICE .. role.id, NewUnlockVoice[role.id])
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Interact_Branch_Path.Voice, 1, role.id)
	end
end

function RoleInteractRDL.SubInteractOneVoice(role, voiceName)
	voiceName = tonumber(voiceName)

	if not table.contains(NewUnlockVoice[role.id], voiceName) then
		return
	end

	table.removeByValue(NewUnlockVoice[role.id], voiceName)
	PersistentStoreUtil.SetList(KEY_RD_INTERACT_VOICE .. role.id, NewUnlockVoice[role.id])

	if #NewUnlockVoice[role.id] == 0 then
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Interact_Branch_Path.Voice, 0, role.id)
	end
end

function RoleInteractRDL.SubInteractVoice(role)
	if #NewUnlockVoice[role.id] == 0 then
		return
	end

	NewUnlockVoice[role.id] = {}

	PersistentStoreUtil.SetList(KEY_RD_INTERACT_VOICE .. role.id, NewUnlockVoice[role.id])
	RedDotSystemMgr.SetNodeValueByFormatPath(RD_Interact_Branch_Path.Voice, 0, role.id)
end

function RoleInteractRDL.IsNewVoice(role, voiceName)
	voiceName = tonumber(voiceName)

	return table.contains(NewUnlockVoice[role.id], voiceName)
end

local function IsFavoriteGift(roleId, id)
	if RoleFavoriteGift[roleId] then
		return table.contains(RoleFavoriteGift[roleId], id)
	end

	return false
end

function RoleInteractRDL.AddInteractGift()
	local t = ItemRDL.NewFavorIds or {}
	local item, subType = nil, 0

	for _, role in ipairs(RoleRDL.ALL_HOLD_ROLE) do
		item = nil
		subType = 0

		for k, itemId in pairs(t) do
			if IsFavoriteGift(role, itemId) then
				item = ItemManager:Get(itemId)
				subType = tonumber(item.data.SubType)

				break
			end
		end

		if subType ~= 0 then
			RedDotSystemMgr.SetNodeValueByFormatPath(RD_Interact_Branch_Path.Gift, 1, role.id, subType)

			if PersistentStoreUtil.GetInt(KEY_RD_INTERACT_GIFT .. role.id .. subType, 0) == 0 then
				PersistentStoreUtil.SetInt(KEY_RD_INTERACT_GIFT .. role.id .. subType, 1)
			end
		end
	end
end

function RoleInteractRDL.SubInteractGift(role, subType)
	if PersistentStoreUtil.GetInt(KEY_RD_INTERACT_GIFT .. role.id .. subType, 0) ~= 0 then
		PersistentStoreUtil.SetInt(KEY_RD_INTERACT_GIFT .. role.id .. subType, 0)
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Interact_Branch_Path.Gift, 0, role.id, subType)
	end
end

function RoleInteractRDL.AddInteractARDance(stageId)
	if #DanceUnlockStageList == 0 then
		for _, v in pairs(favoDance) do
			table.insert(DanceUnlockStageList, v.Stage)
		end
	end

	if table.contains(DanceUnlockStageList, stageId) and PersistentStoreUtil.GetInt(KEY_RD_INTERACT_AR_DANCE, 0) == 0 then
		PersistentStoreUtil.SetInt(KEY_RD_INTERACT_AR_DANCE, 1)

		for _, role in ipairs(RoleRDL.ALL_HOLD_ROLE) do
			RedDotSystemMgr.SetNodeValueByFormatPath(RD_Interact_Branch_Path.Ar_Dance, 1, role.id)
		end
	end
end

function RoleInteractRDL.SubInteractARDance()
	if PersistentStoreUtil.GetInt(KEY_RD_INTERACT_AR_DANCE, 0) ~= 0 then
		PersistentStoreUtil.SetInt(KEY_RD_INTERACT_AR_DANCE, 0)

		for _, role in ipairs(RoleRDL.ALL_HOLD_ROLE) do
			RedDotSystemMgr.SetNodeValueByFormatPath(RD_Interact_Branch_Path.Ar_Dance, 0, role.id)
		end
	end
end

function RoleInteractRDL.AddInteractARPose(role)
	if RolePoseList[role.id] == nil then
		RolePoseList[role.id] = {}

		for _, pose in pairs(favorPose) do
			if role.id == pose.Character then
				table.insert(RolePoseList[role.id], pose)
			end
		end
	end

	if PersistentStoreUtil.GetInt(KEY_RD_INTERACT_AR_POSE .. role.id, 0) == 0 then
		for _, v in pairs(RolePoseList[role.id]) do
			if role.preFavorLevel < v.FavorLevel and role.curFavorLevel >= v.FavorLevel then
				PersistentStoreUtil.SetInt(KEY_RD_INTERACT_AR_POSE .. role.id, 1)
				RedDotSystemMgr.SetNodeValueByFormatPath(RD_Interact_Branch_Path.Ar_Pose, 1, role.id)

				break
			end
		end
	end
end

function RoleInteractRDL.SubInteractARPose(role)
	if PersistentStoreUtil.GetInt(KEY_RD_INTERACT_AR_POSE .. role.id, 0) ~= 0 then
		PersistentStoreUtil.SetInt(KEY_RD_INTERACT_AR_POSE .. role.id, 0)
		RedDotSystemMgr.SetNodeValueByFormatPath(RD_Interact_Branch_Path.Ar_Pose, 0, role.id)
	end
end

return RoleInteractRDL
