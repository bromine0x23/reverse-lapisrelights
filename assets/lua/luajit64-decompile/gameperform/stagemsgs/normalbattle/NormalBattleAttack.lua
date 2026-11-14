-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/NormalBattle/NormalBattleAttack.lua

local SkillCfgInfo = require("GamePerform.Object.InfoBattleSkillData")

NormalBattleAttack = class("NormalBattleAttack")

function NormalBattleAttack:ctor(GP, parent)
	self.GP = GP
	self.parent = parent
	self.suffers = {}
	self.isLastMelee = false
	self.isFirstMelee = false
	self.attackIndex = 1
	self.groupIndex = 0
end

function NormalBattleAttack:Create(data, sessionType)
	self.sessionType = sessionType
	self.attackData = table.remove(data, 1)
	self.targetData = self:GetTargetData(data)
	self.skillCfg = SkillCfgInfo:GetData(self.attackData.skillId)
	self.isRemoteAttack = self:IsRemoteAttack()
	self.allSkillCfg = SkillCfgInfo:GetAllSkillData(self.skillCfg.AllSkillID)
	self.isSpecialBall = self.allSkillCfg.BattleSkillType == EnumFight.SkillType.SpecialAction
	self.attackUnitActor = UnitActor.FindUnitById(self.attackData.uniqueId)

	if not self.attackUnitActor then
		self.skillLevel = 1
	elseif not self.attackUnitActor:GetOwnSkill(self.skillCfg.ID) then
		self.skillLevel = 1
	else
		self.skillLevel = self.attackUnitActor:GetOwnSkill(self.skillCfg.ID).Level
	end

	self.skillTime = self.skillCfg.TotalTime ~= -1 and self.skillCfg.TotalTime or self.attackUnitActor.Actor.MotionSystem:GetAnimLength(self.skillCfg.AnimState)
	self.bullets, self.bTimes, self.bIdx = self:GetBulletData()

	if not self.isRemoteAttack then
		self.backTime = self.skillTime * self.skillCfg.Back_f
	end

	local sufferData
	local actionKeyIdx = -1
	local mutIdx = -1
	local sufferTarget

	for i, msg in ipairs(data) do
		if msg.eventId == "技能ActionKey发动" then
			self:CreateSuffer(sufferData, actionKeyIdx, mutIdx, sufferTarget)

			actionKeyIdx = msg.actionKeyIdx
			sufferData = nil
		elseif msg.eventId == "伤害目标" then
			sufferTarget = msg.targets
		elseif msg.eventId == "受击打包" then
			self:CreateSuffer(sufferData, actionKeyIdx, mutIdx, sufferTarget)

			mutIdx = msg.mutIdx
			sufferData = {}
		else
			table.insert(sufferData, msg)
		end
	end

	self:CreateSuffer(sufferData, actionKeyIdx, mutIdx, sufferTarget)
end

function NormalBattleAttack:CreateSuffer(sufferData, actionKeyIdx, mutIdx, sufferTarget)
	if sufferData ~= nil and #sufferData > 0 then
		local sufferNode = NormalBattleSuffer(self.GP, self.skillCfg, self.skillTime, self.skillLevel)

		sufferNode:Create(sufferData, actionKeyIdx, mutIdx)

		if actionKeyIdx == self.bIdx then
			sufferNode:SetBulletData(self.bullets[mutIdx], self.attackUnitActor, GetListObjByIndex(sufferTarget, mutIdx))
		end

		table.insert(self.suffers, sufferNode)
	end
end

function NormalBattleAttack:Play(complete)
	if not self.attackUnitActor then
		self.attackUnitActor = UnitActor.FindUnitById(self.attackData.uniqueId)
	end

	self.attackUnitActor:SetActive(true)
	self:PlaySkill(function()
		self:PlayTimeSuffer()

		local delay = self:GetDelay()

		BattleConfig.Delay(delay, complete)
	end)
end

function NormalBattleAttack:GetTargetData(data)
	for i, v in ipairs(data) do
		if v.eventId == "伤害目标" then
			return v
		end
	end
end

function NormalBattleAttack:GetBulletData()
	for i, v in ipairs(self.skillCfg.Custom) do
		if v.Bullet ~= nil and #v.Bullet > 0 then
			return GetListObjByIndex(v.Bullet, self.skillLevel), v.Hit_f, i
		end
	end
end

function NormalBattleAttack:IsRemoteAttack()
	for i, v in ipairs(self.skillCfg.Custom) do
		if v.AttackMode ~= nil then
			return v.AttackMode[1] == "Remote"
		end
	end

	return true
end

function NormalBattleAttack:PVPActive()
	if self.GP.PVPMode == true then
		local isPassive = false
		local passives = {
			EnumFight.SkillType.Passive,
			EnumFight.SkillType.Link,
			EnumFight.SkillType.Union,
			EnumFight.SkillType.Center
		}

		for i, _skillType in ipairs(passives) do
			if self.allSkillCfg.BattleSkillType == _skillType then
				isPassive = true

				break
			end
		end

		if self.attackIndex == 1 and self.groupIndex == 1 then
			self.attackUnitActor:SetActive(true)
		elseif isPassive then
			self.attackUnitActor:SetActive(true)
		else
			self.attackUnitActor:SetActiveWithFx(true)
		end

		BattleConfig.Delay(self.skillTime, function()
			if self.parent.actionIdx == self.parent.maxActionIdx and self.sessionType ~= 0 then
				-- block empty
			elseif isPassive then
				self.attackUnitActor:SetActive(false)
			else
				self.attackUnitActor:SetActiveWithFx(false)
			end
		end)
	end
end

function NormalBattleAttack:SkillFx()
	for i, v in ipairs(self.skillCfg.CastTime) do
		BattleConfig.Delay(self.skillTime * v, function()
			local effId = self.skillCfg.CastFxs[i]

			BattleConfig.FxAlloc(effId, self.attackUnitActor)
		end)
	end

	if self.skillCfg.CampFxTimes then
		for i, v in ipairs(self.skillCfg.CampFxTimes) do
			BattleConfig.Delay(self.skillTime * v, function()
				local effId = self.skillCfg.CampFxs[i]
				local idx = self.skillCfg.CampFxIdx[i]
				local camp

				if idx == 1 then
					camp = self.attackUnitActor.Camp
				elseif idx == 2 then
					camp = 2 - self.attackUnitActor.Camp + 1
				end

				BattleConfig.CampFxAlloc(effId, camp)
			end)
		end
	end

	if self.skillCfg.CameraFxTimes then
		for i, v in ipairs(self.skillCfg.CameraFxTimes) do
			BattleConfig.Delay(self.skillTime * v, function()
				local effId = self.skillCfg.CameraFxs[i]

				BattleConfig.CameraFxAlloc(effId, self.attackUnitActor.Camp)
			end)
		end
	end
end

function NormalBattleAttack:PlaySkill(complete)
	if self.attackData.isCard then
		local ownSkill = self.attackUnitActor:GetOwnSkill(self.skillCfg.ID)

		if self.attackUnitActor.Camp == EnumFight.Camp.ENEMY then
			self.GP.Team:SetActive(EnumFight.Camp.PLAYER, false)
			self.GP.UI.DlgUIPVPCardSkill:Refresh(ownSkill, function()
				if self.GP.PVPMode == true then
					self.GP.Team:SetActive(EnumFight.Camp.PLAYER, true)
					self:PVPActive()
					self.GP.CameraUtil:EnablePVPCamear(false)
				end

				Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator")
				Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", true)

				if self.skillCfg.AnimState ~= "" then
					if self.attackUnitActor:IsState("SpeIdle") then
						self.attackUnitActor:CrossFade(self.skillCfg.AnimState, 0.1)
					else
						self.attackUnitActor:Play(self.skillCfg.AnimState)
					end
				end

				self:SkillFx()
				complete()
			end)
		else
			self.GP.UI.DlgUICardCutIn:Refresh(ownSkill, function()
				self.GP.TimeLine:PlaySkill(self.skillCfg, self.attackUnitActor, function()
					Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator")
					Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", true)

					if self.skillCfg.AnimState ~= "" then
						if self.attackUnitActor:IsState("SpeIdle") then
							self.attackUnitActor:CrossFade(self.skillCfg.AnimState, 0.1)
						else
							self.attackUnitActor:Play(self.skillCfg.AnimState)
						end
					end

					self:PVPActive()
					self.GP.CameraUtil:MainCameraOnly()
					self:SkillFx()
					complete()
				end)
			end)
		end
	else
		if self.sessionType ~= 0 then
			Event.Instance:Fire("UnitVocalEvent", UnitVocal.enType.VocalSession, self.attackUnitActor)
		end

		if self.skillCfg.TimeLineID ~= 0 then
			if self.isSpecialBall then
				if self.attackUnitActor.Camp == EnumFight.Camp.PLAYER and self.attackIndex == 1 then
					local playerRoot = self.attackUnitActor.ActorRoot.transform
					local targetUnitActor = self.targetData ~= nil and UnitActor.FindUnitById(self.targetData.targets[1]) or nil
					local monsterRoot = targetUnitActor and targetUnitActor.ActorRoot.transform or nil

					VirtualCameraFollowAndLookAtSkill.Register(playerRoot, monsterRoot)

					local timeLineID = self.skillCfg.TimeLineID

					if targetUnitActor and targetUnitActor.UnitData.data.Boss == 1 and self.skillCfg.TimeLine_BOSS_Cam ~= 0 then
						timeLineID = self.skillCfg.TimeLine_BOSS_Cam
					end

					self.GP.TimeLine:PlaySkillCamera(timeLineID)
				end

				self:PlayRoleBehavior()
				complete()

				return
			else
				self.GP.TimeLine:PlaySkill(self.skillCfg, self.attackUnitActor, function()
					self:PlayRoleBehavior()
					complete()
				end)
			end
		elseif self.allSkillCfg.BattleSkillType == EnumFight.SkillType.PlayerModelMonster then
			local ownSkill = self.attackUnitActor:GetOwnSkill(self.skillCfg.ID)

			self.GP.UI.DlgUIPVPCardSkill:Refresh(ownSkill, function()
				self:PlayRoleBehavior()
				complete()
			end)
		else
			self:PlayRoleBehavior()
			complete()
		end
	end
end

function NormalBattleAttack:PlayRoleBehavior()
	if self.GP.PVPMode == true then
		if self.attackUnitActor.Camp == EnumFight.Camp.ENEMY then
			self.GP.CameraUtil:EnablePVPCamear(false)
		end
	elseif self.sessionType == EnumFight.SessionType.attack and self.isSpecialBall == false then
		Event.Instance:Fire("UISessionTip", self.skillCfg, self.attackUnitActor)
	end

	self:PVPActive()

	if self.skillCfg.AnimState ~= "" then
		if self.attackUnitActor:IsState("SpeIdle") then
			self.attackUnitActor:CrossFade(self.skillCfg.AnimState, 0.1)
		else
			self.attackUnitActor:Play(self.skillCfg.AnimState)
		end
	end

	for i, v in ipairs(self.skillCfg.CastTime) do
		BattleConfig.Delay(self.skillTime * v, function()
			local effId = self.skillCfg.CastFxs[i]

			BattleConfig.FxAlloc(effId, self.attackUnitActor)
		end)
	end

	if self.skillCfg.CampFxTimes then
		for i, v in ipairs(self.skillCfg.CampFxTimes) do
			BattleConfig.Delay(self.skillTime * v, function()
				local effId = self.skillCfg.CampFxs[i]
				local idx = self.skillCfg.CampFxIdx[i]
				local camp = 1

				if idx == 1 then
					camp = self.attackUnitActor.Camp
				elseif idx == 2 then
					camp = 2 - self.attackUnitActor.Camp + 1
				end

				BattleConfig.CampFxAlloc(effId, camp)
			end)
		end
	end

	if self.skillCfg.CameraFxTimes then
		for i, v in ipairs(self.skillCfg.CameraFxTimes) do
			BattleConfig.Delay(self.skillTime * v, function()
				local effId = self.skillCfg.CameraFxs[i]

				BattleConfig.CameraFxAlloc(effId, self.attackUnitActor.Camp)
			end)
		end
	end

	if not self.isRemoteAttack then
		local target = UnitActor.FindUnitById(self.targetData.targets[1])

		self.attackUnitActor:SetAttackType(self.sessionType)
		self.attackUnitActor:MoveToTarget(target)

		if self.attackUnitActor.Camp == EnumFight.Camp.PLAYER then
			local sessionCfg = require("luaData/SessionData")

			print("self.sessionType:" .. self.sessionType)

			local delay = sessionCfg[self.sessionType].WaitTime
			local targetUnitActor = self.targetData ~= nil and UnitActor.FindUnitById(self.targetData.targets[1]) or nil

			if self.isFirstMelee then
				BattleConfig.Delay(delay, function()
					self.GP.CameraUtil:OnMeleeAttack({
						targetUnitActor.ActorRoot
					})
				end)
			else
				BattleConfig.Delay(delay, function()
					local targetUnitActor = self.targetData ~= nil and UnitActor.FindUnitById(self.targetData.targets[1]) or nil

					self.GP.CameraUtil:SetTargetGroup({
						targetUnitActor.ActorRoot
					})
				end)
			end
		end

		BattleConfig.Delay(self.backTime, function()
			self.attackUnitActor:MoveToZero()

			if self.isLastMelee and self.attackUnitActor.Camp == EnumFight.Camp.PLAYER then
				self.GP.CameraUtil:MainCameraOnly()
			end
		end)
	elseif self.bullets ~= nil then
		for i, v in ipairs(self.bullets) do
			for j, targetUnitId in ipairs(self.targetData.targets) do
				local target = UnitActor.FindUnitById(targetUnitId)

				if target then
					self.attackUnitActor:LookToTarget(target)
					BattleConfig.Delay(self.skillTime * self.bTimes[i], function()
						self.attackUnitActor:LuanchBullet(v, target)
						self.attackUnitActor:MoveToZero()
					end)
				end
			end
		end
	end
end

function NormalBattleAttack:PlayTimeSuffer()
	for i, v in ipairs(self.suffers) do
		v:Timing()
	end
end

function NormalBattleAttack:FirstSufferTime()
	if #self.suffers > 0 then
		return self.suffers[1]:GetTime()
	else
		return 0
	end
end

function NormalBattleAttack:LastSufferTime()
	if #self.suffers > 0 then
		return self.suffers[#self.suffers]:GetTime()
	else
		return 0
	end
end

function NormalBattleAttack:LastSufferNode()
	if #self.suffers > 0 then
		return self.suffers[#self.suffers]
	else
		return nil
	end
end

function NormalBattleAttack:GetDelay()
	if self.attackData.isCard then
		return self.skillTime
	else
		local sufferNode = self:LastSufferNode()
		local lastSufferTime = 0
		local haveDamage = false

		if sufferNode ~= nil then
			lastSufferTime = sufferNode:GetTime()
			haveDamage = sufferNode.haveDamage
		end

		if haveDamage then
			lastSufferTime = lastSufferTime + BattleConst.sufferAnimDelay
		end

		if lastSufferTime < self.skillTime then
			return self.skillTime
		else
			return lastSufferTime
		end
	end
end

function NormalBattleAttack:Dispose()
	for i, v in ipairs(self.suffers) do
		v:Dispose()
	end
end
