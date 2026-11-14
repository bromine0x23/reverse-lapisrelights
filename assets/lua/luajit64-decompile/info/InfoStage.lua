-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/InfoStage.lua

local StageData = require("luaData/StageData")
local MonsterData = require("luaData/Monster")
local BattleStageData = require("luaData/BattleStage")

InfoStage = class("InfoStage", InfoBase)

function InfoStage:ctor(id)
	self.data = StageData[id]
	self.isUnLock = false
	self.pb.id = id
	self.pb.stars = {
		0,
		0,
		0
	}
	self.pb.isPass = false
	self.pb.playNum = 0
	self.pb.hignAwardNum = 0
	self.preStars = {
		0,
		0,
		0
	}

	if self.data == nil then
		return
	end

	self.BattleData = BattleStageData[self.data.BattleStageID]
	self.listMonster = {}

	if self.data.BattleStageID == 0 then
		return
	end

	for i = 1, #self.BattleData.Enemy do
		local list = self.BattleData.Enemy[i]

		for j = 1, #list do
			local mId = list[j]
			local tId = table.getIndex(self.listMonster, mId)

			if tId == -1 then
				table.insert(self.listMonster, mId)
			end
		end
	end

	table.sort(self.listMonster, function(a, b)
		return MonsterData[a].Boss < MonsterData[b].Boss
	end)

	self.preferAttrs = {}

	if self.data.Evaluate then
		for i = 1, #self.data.Evaluate do
			if self.data.Evaluate[i] > 0 then
				table.insert(self.preferAttrs, i)
			end
		end
	end
end

function InfoStage:SetData(pbStage)
	self.preStars = self.pb.stars
	self.pb = pbStage
	self.isUnLock = true
end

function InfoStage:GetStar()
	local count = 0

	for i = 1, #self.pb.stars do
		if self.pb.stars[i] > 0 then
			count = count + 1
		end
	end

	return count
end

function InfoStage:IsOpen()
	return self.isUnLock
end

function InfoStage:IsPass()
	return self.pb.isPass
end

function InfoStage:IsNew()
	return self:IsOpen() and not self.pb.isPass
end

function InfoStage:IsUnlock()
	return self.isUnLock and self:IsFullCondition()
end

function InfoStage:IsFullCondition()
	return PlayerInst:GetCurLv() >= (self.data.LevelUnlock or 0)
end

function InfoStage:GetLeftPlayNum()
	return self:GetMaxLeftPlayNum() - self.pb.playNum
end

function InfoStage:GetMaxLeftPlayNum()
	if self.data.PlayNum == 0 then
		return 0
	end

	if self.data.ChapterType == ChapterFromType.activity and self.data.Type == StageFromType.common then
		local count = 0

		if InfoGameInst:GetChapterTimesList() then
			count = InfoGameInst:GetChapterTimesList()[self.data.ActType].buyTimes
		end

		return self.data.PlayNum + count
	elseif self.data.ChapterType == ChapterFromType.bosslive then
		local info, count = ShopManager:GetGoodsMonthPrivilegeFuncInfo(ShopManager.MonthPrivilegeFunc.Func5)

		return self.data.PlayNum + count
	elseif self.data.ChapterType == ChapterFromType.comb then
		local count = 0

		if InfoGameInst:GetChapterTimesList() then
			count = InfoGameInst:GetChapterTimesList()[4].buyTimes
		end

		return self.data.PlayNum + count
	end

	return self.data.PlayNum
end

function InfoStage:CanSweep()
	return self.data.Sweep == 1
end

function InfoStage:IsLimit()
	local limitList = self.data.LimitList
	local additionList = self.data.AdditionList

	return #limitList > 0 or #additionList > 0
end

function InfoStage:IsLimitPlayNum()
	return self:GetMaxLeftPlayNum() ~= 0
end

function InfoStage:IsFullStar()
	local stars = self:GetStar()

	return stars == 3 or self.data.Type == StageFromType.activeBoss
end

function InfoStage:HaveStarCon()
	local grade = self.data.Grade

	return #grade ~= 0
end

function InfoStage:GetStarAward(i)
	if i == 1 then
		return self.data.Star1Award
	elseif i == 2 then
		return self.data.Star2Award
	elseif i == 3 then
		return self.data.Star3Award
	end

	return {}
end

function InfoStage:GetCostItem()
	local costItem = self.data.CostItem

	if #costItem == 0 then
		local defaultNum = self.data.Stamina

		if defaultNum == 0 then
			return {}
		end

		costItem = {
			503,
			defaultNum
		}
	end

	local infoItem = ItemManager:Get(costItem[1])

	return {
		infoItem,
		costItem[2]
	}
end

function InfoStage:GetStageLittleIcon()
	local battleScenceId = self.BattleData.MainSceneId
	local name = SceneMgr.data[battleScenceId].BattleSceneicon

	return name
end

function InfoStage:HasNewDot(notWithStory)
	if self.data.Type == StageFromType.story and notWithStory then
		return false
	end

	if not self:IsUnlock() then
		return false
	end

	if PersistentStoreUtil.GetStageEnter(self.id) then
		return false
	end

	return true
end

function InfoStage:SetCurBossliveIndex(stageID)
	local BossliveTbl = ChapterMgr:GetChapterList(ChapterType.bosslive)
	local sortList = {}
	local sortOpenList = {}
	local sortUnOpenList = {}

	for i = 1, #BossliveTbl do
		local infoStage = ChapterMgr:GetStage(BossliveTbl[i].data.StageID[1])
		local isUnLock = infoStage:IsOpen()

		if isUnLock then
			table.insert(sortOpenList, BossliveTbl[i])
		end
	end

	for i = 1, #BossliveTbl do
		local infoStage = ChapterMgr:GetStage(BossliveTbl[i].data.StageID[1])
		local isUnLock = infoStage:IsOpen()

		if not isUnLock then
			table.insert(sortUnOpenList, BossliveTbl[i])
		end
	end

	local function func(a, b)
		local aInfoStage = ActiveMgr:GetUnlockStage(a.data.StageID[1])
		local bInfoStage = ActiveMgr:GetUnlockStage(b.data.StageID[1])
		local _, ai, aj = ChapterMgr:GetChapterByStageID(aInfoStage.id)
		local _, bi, bj = ChapterMgr:GetChapterByStageID(bInfoStage.id)

		if ai == bi then
			return aj < bj
		else
			return ai < bi
		end
	end

	table.sort(sortOpenList, func)

	local function func2(a, b)
		local aInfoStage = ActiveMgr:GetUnlockStage(a.data.StageID[1])
		local bInfoStage = ActiveMgr:GetUnlockStage(b.data.StageID[1])
		local _, ai, aj = ChapterMgr:GetChapterByStageID(aInfoStage.id)
		local _, bi, bj = ChapterMgr:GetChapterByStageID(bInfoStage.id)

		if ai == bi then
			return aj < bj
		else
			return ai < bi
		end
	end

	table.sort(sortUnOpenList, func2)

	for i = 1, #sortOpenList do
		table.insert(sortList, sortOpenList[i])
	end

	for i = 1, #sortUnOpenList do
		local bInfoStage = ChapterMgr:GetStage(sortUnOpenList[i].data.StageID[1])

		table.insert(sortList, sortUnOpenList[i])
	end

	for i = 1, #sortList do
		for n = 1, 3 do
			if stageID == sortList[i].data.StageID[n] then
				RoleCardMgr:SetBossLiveCurIndexState(i .. "_" .. n)
			end
		end
	end
end
