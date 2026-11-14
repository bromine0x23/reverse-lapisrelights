-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/PassMgr.lua

local PassData = require("luaData/TranOpen")
local ActiveData = require("luaData/ActiveData")

PassMgr = {}

function PassMgr:GetPass(passId)
	local ret

	for k, v in pairsByKeys(PassData) do
		if v.ID == passId then
			ret = v

			break
		end
	end

	if not ret then
		PrintWithColor("TranOpen [%s] is not exist!", "yellow", tostring(passId))

		return
	end

	return ret
end

function PassMgr:GetUnLockCondition(passId)
	local pass = self:GetPass(passId)
	local stype = pass.Type
	local str = ""

	if stype == 1 then
		str = string.format(_("PageTalentTree_Unlock_level"), tostring(pass.Value))
	end

	return str
end

function PassMgr:IsPassUnLock(passId)
	local pass = self:GetPass(passId)
	local stype = pass.Type

	if stype == 1 then
		local playerLevel = PlayerInst:GetCurLv()

		if playerLevel >= pass.Value then
			return true
		end
	end

	return false
end

function PassMgr:GetListAssetBranchId(passId)
	local pass = self:GetPass(passId)

	return pass.Branch
end

function PassMgr:GetBranchActiveList(passId, branchId)
	local pass = self:GetPass(passId)
	local listActiveId = pass.ActivityID[branchId]
	local list = {}

	for i = 1, #listActiveId do
		local activeId = listActiveId[i]
		local activeData = ActiveData[activeId]

		table.insert(list, activeData)
	end

	return list
end

function PassMgr:GetAssetBranchOpenChapter(passId, branchId)
	local listActive = self:GetBranchActiveList(passId, branchId)
	local listChpater = {}

	for i = 1, #listActive do
		local id = listActive[i].ID
		local infoActive = ActiveMgr:GetActive(id)

		if infoActive:TodayIsOpen() then
			local list = infoActive:GetOpenChapterToday()

			for i = 1, #list do
				table.insert(listChpater, list[i])
			end
		end
	end

	return listChpater
end

function PassMgr:GetAssetBranchPlayNum(passId, branchId)
	local playNum = 0
	local listChapter = self:GetAssetBranchOpenChapter(passId, branchId)

	for i = 1, #listChapter do
		local chapterId = listChapter[i]

		playNum = ChapterMgr:GetPlayNum(chapterId)
	end

	return playNum
end

function PassMgr:GetAssetDot(assetId)
	return not PersistentStoreUtil.GetAssetActiveEnter(assetId)
end

function PassMgr:GetBossDot()
	return not PersistentStoreUtil.GetBossActiveEnter()
end

function PassMgr:HaveAssetDot()
	local listId = PassData[3].Branch

	for i = 1, #listId do
		local assetId = listId[i]
		local haveDot = self:GetAssetDot(assetId)

		if haveDot then
			return true
		end
	end

	return false
end

function PassMgr:RemoveDot(assetId, value)
	if assetId ~= nil then
		PersistentStoreUtil.SetAssetActiveEnter(assetId, value)
	else
		PersistentStoreUtil.SetBossActiveEnter(value)
	end
end

function PassMgr:Init()
	local curServerTime = NetData:GetCurServerTime()
	local today = os.date("*t", curTimeStamp)
	local logoutTime = tonumber(PlayerInst.InfoPlayer.logoutTime or curServerTime)
	local lastDay = os.date("*t", logoutTime)
	local isThanOneDay = curServerTime - logoutTime > 86400
	local isSameDay = false

	if isThanOneDay then
		isSameDay = false
	elseif today.hour >= 4 then
		local st = tonumber(os.time({
			hour = 4,
			second = 0,
			minute = 0,
			day = today.day,
			month = today.month,
			year = today.year
		}))

		if logoutTime < st then
			isSameDay = false
		else
			isSameDay = true
		end
	else
		local st = tonumber(os.time({
			hour = -20,
			second = 0,
			minute = 0,
			day = today.day,
			month = today.month,
			year = today.year
		}))

		isSameDay = not (logoutTime < st)
	end

	if not isSameDay then
		local listId = PassData[3].Branch

		for i = 1, #listId do
			local assetId = listId[i]

			self:RemoveDot(assetId, false)
		end

		self:RemoveDot(nil, false)
	end
end
