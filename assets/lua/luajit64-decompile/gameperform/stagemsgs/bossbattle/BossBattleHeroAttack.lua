-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/BossBattle/BossBattleHeroAttack.lua

local SkillCfgInfo = require("GamePerform.Object.InfoBattleSkillData")

BossBattleHeroAttack = class("BossBattleHeroAttack")

function BossBattleHeroAttack:ctor(GP, isSession, sessionType, sessionCount)
	self.GP = GP
	self.sufferMsgs = {}
	self.isSession = isSession
	self.sessionType = sessionType
	self.sessionCount = sessionCount
end

function BossBattleHeroAttack:Create(data)
	self.attackData = table.remove(data, 1)
	self.isCard = self.attackData.isCard
	self.attackUnitActor = UnitActor.FindUnitById(self.attackData.uniqueId)
	self.skillCfg = SkillCfgInfo:GetData(self.attackData.skillId)
	self.skillLevel = self.attackUnitActor:GetOwnSkill(self.skillCfg.ID).Level
	self.skillTime = self.skillCfg.TotalTime
	self.sufferController = BossBattleSufferMgr(self.GP, self.isSession, self.sessionType, self.sessionCount, self.skillCfg, self.skillLevel, self.skillTime, self.isCard)
	self.isAttackBoss = false

	local sufferData
	local actionKeyIdx = -1
	local mutIdx = -1

	for i, msg in ipairs(data) do
		if msg.eventId == "技能ActionKey发动" then
			self:CreateSuffer(sufferData, actionKeyIdx, mutIdx)

			actionKeyIdx = msg.actionKeyIdx
			sufferData = nil
		elseif msg.eventId == "伤害目标" then
			self.unitBoss = UnitActor.FindUnitById(msg.targets[1])
		elseif msg.eventId == "受击打包" then
			self:CreateSuffer(sufferData, actionKeyIdx, mutIdx)

			mutIdx = msg.mutIdx
			sufferData = {}
		else
			table.insert(sufferData, msg)

			if not self.isAttackBoss and msg.uniqueId ~= nil then
				local actor = UnitActor.FindUnitById(msg.uniqueId)

				if actor.Camp == EnumFight.Camp.ENEMY then
					self.isAttackBoss = true
				end
			end
		end
	end

	self:CreateSuffer(sufferData, actionKeyIdx, mutIdx)
end

function BossBattleHeroAttack:CreateSuffer(sufferData, actionKeyIdx, mutIdx)
	if sufferData ~= nil and #sufferData > 0 then
		self.sufferController:AddData(sufferData, actionKeyIdx, mutIdx)
	end
end

function BossBattleHeroAttack:GetSufferCount()
	return self.sufferController:GetSufferCount()
end

function BossBattleHeroAttack:Play(complete)
	if self.isCard then
		local ownSkill = self.attackUnitActor:GetOwnSkill(self.skillCfg.ID)

		self.GP.UI.DlgUICardCutIn:Refresh(ownSkill, function()
			if self.GP.SkipTimelineMode == false then
				self.GP.Live:PauseLive()
			end

			self.GP.TimeLine:PlaySkill(self.skillCfg, self.attackUnitActor, function()
				if self.skillCfg.CampFxTimes then
					for i, v in ipairs(self.skillCfg.CampFxTimes) do
						BattleConfig.Delay(self.skillTime * v, function()
							local effId = self.skillCfg.CampFxs[i]
							local idx = self.skillCfg.CampFxIdx[i]
							local camp = 1

							if idx == 1 then
								-- block empty
							elseif idx == 2 then
								camp = 2 - self.attackUnitActor.Camp + 1

								BattleConfig.CampFxAlloc(effId, camp)
							end
						end)
					end
				end

				if self.skillCfg.CameraFxTimes then
					for i, v in ipairs(self.skillCfg.CameraFxTimes) do
						BattleConfig.Delay(self.skillTime * v, function()
							local effId = self.skillCfg.CameraFxs[i]

							BattleConfig.CameraFxAlloc(effId)
						end)
					end
				end

				Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIOperator")
				Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIBattleInfo", true)

				if self.isAttackBoss then
					self.GP.Live:PauseLive()

					SceneMgr.GetCurrentScene().Scene.Postprocess.RuntimeSetting.Blur.Enable = false

					self.GP.Team:SetActive(EnumFight.Camp.ENEMY, true)
					self.GP.CameraUtil:EnterBossLiveSession(true)
					Event.Instance:Fire("EVENT_SWITCH_SCENE", EnumFight.SceneObj.Session)
					BattleConfig.Delay(BattleConst.bossViewDelay, function()
						self.sufferController:Play(BossBattleSufferType.Interval, complete)
					end)
				else
					SceneMgr.GetCurrentScene().Scene.Postprocess.RuntimeSetting.Blur.Enable = true

					self.GP.Live:ResumeLive()
					self.sufferController:Play(BossBattleSufferType.Timing, complete)
					BattleConfig.Delay(self.skillTime, function()
						complete()
					end)
				end
			end)
		end)
	else
		self.sufferController:Play(BossBattleSufferType.Interval, complete)
	end
end

function BossBattleHeroAttack:Dispose()
	self.sufferController:Dispose()
end
