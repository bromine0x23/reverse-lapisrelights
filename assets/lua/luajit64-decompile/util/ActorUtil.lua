-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/ActorUtil.lua

ActorUtil = {}

local ActorData = require("luaData/ActorData")
local AvatarData = require("luaData/AvatarData")
local MotionControllerData = require("luaData/MotionControllerData")
local MotionControllerDataIndexer = {}

for k, v in pairs(MotionControllerData) do
	MotionControllerDataIndexer[v.Actor .. "@" .. v.Category .. "@" .. v.MotionGroup] = v
end

function ActorUtil.MotionControllerDataFilter(actor, category, group)
	return MotionControllerDataIndexer[actor .. "@" .. category .. "@" .. group]
end

function ActorUtil.MergeMotionControllerData(src, dest, isEmpty)
	if src.Actor == dest.Actor and src.AnimationController == dest.AnimationController then
		local avatar

		if isEmpty then
			avatar = {}
		else
			avatar = src.Avatar
		end

		local motionControllerData = {
			AnimationController = dest.AnimationController,
			Overrides = {},
			Avatar = avatar
		}

		for _, v in pairs(src.Overrides) do
			motionControllerData.Overrides[v[1]] = v
		end

		for _, v in pairs(dest.Overrides) do
			motionControllerData.Overrides[v[1]] = v
		end

		motionControllerData.Overrides["Body@Preview"] = ""

		return motionControllerData
	end
end

function ActorUtil.UpdateAvatars(ids, actor, roleId)
	require("Info/InfoAvatar")

	local listAvatarFactory = {}
	local listSlot = {
		"Ornament",
		"FaceUp",
		"FaceDown",
		"Back",
		"Waist"
	}

	ResourceMgr.BeginSubmit(function()
		local slot = GetAvatarSlot(listSlot)

		actor.AvatarSystem:TakeOff(slot)

		for i = 1, #listAvatarFactory do
			local avatarPart = listAvatarFactory[i]:Build()

			actor.AvatarSystem:PutOn(avatarPart)
		end
	end)

	for i = 1, #ids do
		local infoAvatar = AvatarManager:GetAvatar(ids[i])

		if infoAvatar.data.Slot[1] ~= "Head" then
			local avatarFactory = ActorUtil.BuildAvatarFactory(ids[i], roleId)

			table.insert(listAvatarFactory, avatarFactory)
			avatarFactory:Cache()
		end
	end

	ResourceMgr.EndSubmit()
end

function ActorUtil.BuildAvatarFactory(avatarID, roleID)
	require("Info/InfoAvatar")

	local avatarPath = AvatarManager:GetAvatarAssetPath(avatarID, roleID)
	local avatarFactory = AvatarFactory(avatarPath)

	return avatarFactory
end

function ActorUtil.BuildEnemyFactory(actorID, controllerData)
	local actorData = ActorData[actorID]
	local actorFactory = EnemyFactory(actorData.Comment, actorData.SkeletonPrefab, actorData.ScaleSettingsAsset, controllerData.AnimationController)

	for k, v in pairs(controllerData.Overrides) do
		actorFactory:ApplyOverride(v[1], v[2])
	end

	return actorFactory
end

function ActorUtil.BuildActorFactoryByInfoRole(infoRole, controllerData)
	local actorData = infoRole.actorData
	local avatarSettingsPath = {}

	if not infoRole.pb.clothes or #infoRole.pb.clothes == 0 then
		for i, _avatarId in ipairs(actorData.DefaultAvatars) do
			table.insert(avatarSettingsPath, AvatarData[_avatarId].AvatarPath)
		end
	elseif infoRole.pb.playerId == PlayerInst.InfoPlayer.pid then
		local ids = infoRole:GetEquipAvatarIds()

		for _, _avatarId in ipairs(ids) do
			table.insert(avatarSettingsPath, AvatarData[_avatarId].AvatarPath)
		end
	else
		for i = 1, #infoRole.pb.clothes do
			table.insert(avatarSettingsPath, AvatarData[infoRole.pb.clothes[i]].AvatarPath)
		end
	end

	if controllerData then
		local listAvatar = controllerData.Avatar

		for i = 1, #listAvatar do
			table.insert(avatarSettingsPath, AvatarData[listAvatar[i]].AvatarPath)
		end
	end

	local actorFactory = ActorFactory(actorData.Comment, actorData.SkeletonPrefab, actorData.ScaleSettingsAsset, avatarSettingsPath, controllerData.AnimationController, actorData.FacialSettingsAsset, actorData.EyeSettingsAsset, actorData.VowelSettingsAsset, "Actors/Settings/ExpressionEffectSettings/1001", "Actors/Animations/Actor/Interact/" .. infoRole.id)

	for k, v in pairs(controllerData.Overrides) do
		actorFactory:ApplyOverride(v[1], v[2])
	end

	return actorFactory
end

function ActorUtil.BuildActorFactory(actorID, listAvatarID, controllerData)
	local actorData = ActorData[actorID]
	local motionControllerData = {
		ID = 0,
		AnimationController = "Actors/AnimationController/Common@MainStage",
		Avatar = {},
		Overrides = {}
	}

	if controllerData ~= nil then
		motionControllerData = controllerData
	end

	local avatarSettingsPath = {}

	if listAvatarID ~= nil then
		for k, v in pairs(listAvatarID) do
			table.insert(avatarSettingsPath, AvatarData[v].AvatarPath)
		end
	else
		for i, _avatarId in ipairs(actorData.DefaultAvatars) do
			table.insert(avatarSettingsPath, AvatarData[_avatarId].AvatarPath)
		end
	end

	if motionControllerData ~= nil then
		local listAvatar = motionControllerData.Avatar

		for i = 1, #listAvatar do
			table.insert(avatarSettingsPath, AvatarData[listAvatar[i]].AvatarPath)
		end
	end

	local actorFactory = ActorFactory(actorData.Comment, actorData.SkeletonPrefab, actorData.ScaleSettingsAsset, avatarSettingsPath, motionControllerData.AnimationController, actorData.FacialSettingsAsset, actorData.EyeSettingsAsset, actorData.VowelSettingsAsset, "Actors/Settings/ExpressionEffectSettings/1001", "")

	for k, v in pairs(motionControllerData.Overrides) do
		actorFactory:ApplyOverride(v[1], v[2])
	end

	return actorFactory
end

function ActorUtil.GetInteractSettingFile(infoRole)
	local interactSetting = ActorFactory.GetInteractSetting("Actors/Animations/Actor/Interact/" .. infoRole.id)

	return interactSetting
end
