-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/StageMsgs/BossBattle/BossBattleNSCutIn.lua

BossBattleNSCutIn = class("BossBattleNSCutIn")

function BossBattleNSCutIn:ctor(GP, uniqueIds)
	self.GP = GP
	self.uniqueIds = uniqueIds
end

function BossBattleNSCutIn:Play(complete)
	BattleConfig.PlaySound("Play_SE_020_0026")

	local unitActors = {}

	for _, uid in ipairs(self.uniqueIds) do
		local attackUnitActor = UnitActor.FindUnitById(uid)

		table.insert(unitActors, attackUnitActor)
	end

	local unit = self.GP.Team.EnemyTeam[1]
	local bossActive = unit:IsActive()

	self.GP:NSessionCutIn(unitActors, function()
		if bossActive then
			BattleConfig.Delay(BattleConst.bossViewDelay, function()
				complete()
			end)
		else
			self.GP.Live:PauseLive()
			self.GP.CameraUtil:EnterBossLiveSession(true)
			GOUtil.SetActive(SceneMgr.GetCurrentScene().Light.gameObject, true)
			self.GP.Team:SetActive(EnumFight.Camp.ENEMY, true)
			BattleConfig.Delay(BattleConst.bossViewDelay, function()
				complete()
			end)
		end
	end)

	if not bossActive then
		BattleConfig.Delay(0.9, function()
			self.GP.TimeLine:CamFlash()
		end)
	end
end

function BossBattleNSCutIn:Dispose()
	return
end
