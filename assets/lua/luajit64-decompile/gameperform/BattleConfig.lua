-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/BattleConfig.lua

BattleConfig = {}
BattleConfig.ColorGary = Color.New(0.4745, 0.4745, 0.4745)
BattleConfig.ColorWhite = Color.New(1, 1, 1)
BattleConfig.ColorRed = Color.New(1, 0, 0)
BattleConfig.ColorGary2 = Color.New(0.7, 0.7, 0.7)
BattleConfig.MaxSelectSessionCount = 4
BattleConfig.Speed = {
	Default = 1.2,
	One = 1,
	Extreme = 2,
	Fast = 1.4
}
BattleConfig.RoundCardCount = 3
BattleConfig.CardSkillDescIconPaths = {
	"UIDyAtlas/Skill/IC_battleup_03_cn",
	"UIDyAtlas/Skill/IC_battleup_01_cn",
	"UIDyAtlas/Skill/IC_battleup_04_cn",
	"UIDyAtlas/Skill/IC_battleup_02_cn"
}
BattleConfig.SkillPath = "UIDyAtlas/Skill/"
BattleConfig.SmallIconPatn = "UIDyAtlas/RoleSmallIcon/"
BattleConfig.CutinPoseData = {
	{
		total_s = 1.3,
		play = {
			0
		},
		anim = {
			"CutinPoseC"
		}
	},
	{
		total_s = 2.5,
		play = {
			0.2,
			0
		},
		anim = {
			"CutinPoseC",
			"CutinPose"
		}
	},
	{
		total_s = 3.7,
		play = {
			0.37272727272727274,
			0.16363636363636364,
			0
		},
		anim = {
			"CutinPose",
			"CutinPoseC",
			"CutinPoseC"
		}
	},
	{
		total_s = 4.5,
		play = {
			0.5555555555555556,
			0.32592592592592595,
			0,
			0.16296296296296298
		},
		anim = {
			"CutinPose",
			"CutinPoseC",
			"CutinPose",
			"CutinPoseC"
		}
	}
}
BattleConfig.SessionCamData = {
	[101] = {
		0,
		0,
		0
	},
	[102] = {
		0,
		1,
		1
	},
	[103] = {
		1,
		1,
		1
	},
	[104] = {
		1,
		1,
		1
	},
	[105] = {
		0,
		0,
		0
	}
}

local Root = {}

Root.A = {
	Skill = "session_attack"
}
Root.A.A = {
	Skill = "double_attack"
}
Root.A.A.A = {
	Skill = "triple_attack"
}
Root.A.A.A.A = {
	Skill = "quadra_attack"
}
Root.B = {
	Skill = "session_force"
}
Root.B.B = {
	Skill = "double_force"
}
Root.B.B.B = {
	Skill = "triple_force"
}
Root.B.B.B.B = {
	Skill = "quadra_force"
}
Root.C = {
	Skill = "session_recover"
}
Root.C.C = {
	Skill = "double_recover"
}
Root.C.C.C = {
	Skill = "triple_recover"
}
Root.C.C.C.C = {
	Skill = "quadra_recover"
}

local Action = {}

Action["1111"] = {
	1
}
Action["112"] = {
	3
}
Action["121"] = {
	2
}
Action["13"] = {
	2
}
Action["211"] = {
	1
}
Action["22"] = {
	1,
	2
}
Action["31"] = {
	1
}
Action["4"] = {
	1
}
Action["1"] = {
	1
}
Action["11"] = {
	1
}
Action["111"] = {
	1
}
Action["2"] = {
	1
}
Action["12"] = {
	2
}
Action["21"] = {
	1
}
Action["3"] = {
	1
}

local Pop = {}

Pop["1111"] = {
	2,
	3,
	4
}
Pop["112"] = {
	1,
	2
}
Pop["121"] = {
	1,
	3
}
Pop["13"] = {
	1
}
Pop["211"] = {
	2,
	3
}
Pop["22"] = {}
Pop["31"] = {
	2
}
Pop["4"] = {}
Pop["1"] = {}
Pop["11"] = {
	2
}
Pop["111"] = {
	2,
	3
}
Pop["2"] = {}
Pop["12"] = {
	1
}
Pop["21"] = {
	2
}
Pop["3"] = {}
BattleConfig.Session = {}
BattleConfig.Session.Root = Root
BattleConfig.Session.Action = Action
BattleConfig.Session.Pop = Pop
BattleConfig.BreakShield = {}
BattleConfig.BreakShield.State = {
	BREAKING = 2,
	BREAKED = 3,
	DEFENSE = 1
}
BattleConfig.BreakShield.Fx = {
	70001,
	70002,
	0
}
BattleConfig.BreakShield.IsPlayHurtAnim = {
	false,
	true,
	true
}
BattleConfig.soundBanks = {}

function BattleConfig.LoadSoundBank(bankName, ...)
	if bankName == "SE_Battle" then
		bankName = "SE_BATTLE"
	end

	if bankName ~= "" then
		if not BattleConfig.soundBanks[bankName] then
			BattleConfig.soundBanks[bankName] = 0
		end

		BattleConfig.soundBanks[bankName] = BattleConfig.soundBanks[bankName] + 1

		SoundMgr.LoadBank(bankName, ...)
	end
end

function BattleConfig.UnLoadSoundBank(bankName, ...)
	if bankName ~= "" then
		if BattleConfig.soundBanks[bankName] then
			BattleConfig.soundBanks[bankName] = BattleConfig.soundBanks[bankName] - 1

			if BattleConfig.soundBanks[bankName] < 0 then
				BattleConfig.soundBanks[bankName] = 0
			end
		end

		SoundMgr.UnloadBank(bankName, ...)
	end
end

function BattleConfig.PostSoundEvent(event, go)
	SoundMgr.PostEvent(event, go)
end

function BattleConfig.StopSound(event)
	SoundMgr.Stop(event)
end

function BattleConfig.PlaySound(event)
	SoundMgr.Play(event)
end

function BattleConfig.UnloadAllBank()
	for k, v in pairs(BattleConfig.soundBanks) do
		if v > 0 then
			for i = 1, v do
				SoundMgr.UnloadBank(k)
			end
		end
	end

	BattleConfig.soundBanks = {}
end

function BattleConfig.IsGuideMode()
	if not InstructionMgr.showExitBtn then
		return true
	end

	return false
end

BattleConfig.Timers = {}

function BattleConfig.Delay(delayTime, fun, ...)
	if delayTime <= 0 then
		fun()

		return nil
	end

	local handle = TimerMgr.AddTimer(eTimerType.ScaleTime, delayTime, function(...)
		fun(...)
	end, nil)

	table.insert(BattleConfig.Timers, handle)

	return handle
end

function BattleConfig.DelayFrameCount(frameCount, fun, ...)
	if frameCount <= 0 then
		fun()

		return nil
	end

	local handle = TimerMgr.AddTimer(eTimerType.FrameCount, frameCount, function(...)
		fun(...)
	end, nil)

	table.insert(BattleConfig.Timers, handle)

	return handle
end

function BattleConfig.FreeTimers()
	for _, handle in ipairs(BattleConfig.Timers) do
		if handle then
			TimerMgr.RemoveTimer(handle)

			handle = nil
		end
	end

	BattleConfig.Timers = {}
end

function BattleConfig.FreeTimer(handle)
	TimerMgr.RemoveTimer(handle)

	handle = nil
end

BattleConfig.PlayerSessionEndWait = 0.6
BattleConfig.EnemyDieWait = 4.2
BattleConfig.EnemyDestoryWait = 0.5
BattleConfig.EnemyAppearWait = 2
BattleConfig.PlayerSessionRandomMax = 0.6
BattleConfig.MoveEffectDelay = 0.5
BattleConfig.PVPActorFxEnterDelay = 0.2
BattleConfig.PVPActorFxExitDelay = 0.2
BattleConfig.PVPActorFxEnter = 30004
BattleConfig.PVPActorFxExit = 30005

local _effectCfg = require("luaData/EffectData")
local _ActorData = require("luaData/ActorData")

function BattleConfig.CampFxAlloc(fxId, camp)
	if not fxId then
		return nil
	end

	if not SceneMgr.GetCurrentScene().CampFxRoot then
		return nil
	end

	local parent = SceneMgr.GetCurrentScene().CampFxRoot[camp]

	if _effectCfg[fxId] then
		local soundBank = _effectCfg[fxId].SoundBank

		if soundBank and soundBank ~= "" then
			BattleConfig.LoadSoundBank(soundBank, false, false)
		end
	end

	return EffectMgr:AllocById(fxId, parent)
end

BattleConfig.CamFxRoot = nil

function BattleConfig.CameraFxAlloc(fxId, camp)
	if not fxId then
		return nil
	end

	local root = SceneMgr.GetCurrentScene().UnityCamera

	root = root or GameObject.Find("[Predeploy]/Camera")

	if root and IsNil(BattleConfig.CamFxRoot) then
		BattleConfig.CamFxRoot = GOUtil.NewGameObject("CamFxRoot", root)
	end

	if IsNil(BattleConfig.CamFxRoot) == false then
		if camp == EnumFight.Camp.ENEMY then
			GOUtil.DOScale(BattleConfig.CamFxRoot.transform, -1, 0)
		else
			GOUtil.DOScale(BattleConfig.CamFxRoot.transform, 1, 0)
		end

		if _effectCfg[fxId] then
			local soundBank = _effectCfg[fxId].SoundBank

			if soundBank and soundBank ~= "" then
				BattleConfig.LoadSoundBank(soundBank, false, false)
			end
		end

		return EffectMgr:AllocById(fxId, BattleConfig.CamFxRoot)
	end

	return nil
end

function BattleConfig:AllocAtById(fxId, position, rotation, scale)
	if _effectCfg[fxId] then
		local soundBank = _effectCfg[fxId].SoundBank

		if soundBank and soundBank ~= "" then
			BattleConfig.LoadSoundBank(soundBank, false, false)
		end
	end

	EffectMgr:AllocAtById(fxId, position, rotation, scale)
end

function BattleConfig.FxAlloc(fxId, unitBase)
	if not fxId then
		return
	end

	if not SceneMgr.GetCurrentScene().GP then
		return
	end

	if SceneMgr.GetCurrentScene().GP.FightMode == EnumFight.BattleType.BOSS and unitBase.UnitClass == EnumBattle.UnitClass.PLAYER and fxId ~= 90002 then
		return
	end

	if fxId == 0 then
		return
	end

	if not _effectCfg[fxId] then
		return EffectMgr:AllocById(fxId)
	end

	if unitBase.className ~= "UnitActor" then
		print("BattleConfig.FxAlloc ERROR ,  need UnitActor")

		return nil
	end

	if GP.PVPMode == true and unitBase:IsActive() == false then
		return nil
	end

	local soundBank = _effectCfg[fxId].SoundBank

	if soundBank and soundBank ~= "" then
		BattleConfig.LoadSoundBank(soundBank, false, false)
	end

	local bindSlot = 0

	if SceneMgr.GetCurrentScene().GP.FightMode == EnumFight.BattleType.BOSS then
		bindSlot = _effectCfg[fxId].BindSlot_Boss
	else
		bindSlot = _effectCfg[fxId].BindSlot
	end

	local parent

	if bindSlot and bindSlot ~= "" then
		parent = unitBase:GetBone(bindSlot)
	end

	local isChild = _effectCfg[fxId].IsChild

	if not isChild or isChild == 0 then
		local position, rotation, scale

		if parent then
			position = parent.position
		else
			position = unitBase.ActorRoot.transform.position
		end

		rotation = unitBase.ActorRoot.transform.rotation
		scale = unitBase.ActorSkeletonRoot.transform.localScale.x

		return EffectMgr:AllocAtById(fxId, position, rotation, scale)
	else
		if not parent then
			return EffectMgr:AllocById(fxId, unitBase.ActorSkeletonRoot)
		end

		return EffectMgr:AllocById(fxId, parent)
	end
end

function BattleConfig.FxCache(path, count)
	return
end

function BattleConfig.FxPrewarm(path, count)
	return
end

BattleConfig.FxMoveStateGo = 60001
BattleConfig.FxMoveStateBack = 60002

function BattleConfig.TimeScale(scale)
	if Time.timeScale == scale then
		return
	end

	if scale == BattleConfig.Speed.Default then
		Time.timeScale = BattleConfig.Speed.Default

		return
	end

	if GP then
		if GP.SpeedMode > EnumFight.SpeedMode.Default then
			Time.timeScale = scale
		end
	else
		Time.timeScale = scale
	end
end

function BattleConfig.TimeScaleActive(val, speed)
	if val == true then
		if not speed then
			if GP.SpeedMode == EnumFight.SpeedMode.Default then
				speed = BattleConfig.Speed.Default
			elseif GP.SpeedMode == EnumFight.SpeedMode.Fast then
				speed = BattleConfig.Speed.Fast
			elseif GP.SpeedMode == EnumFight.SpeedMode.Extreme then
				speed = BattleConfig.Speed.Extreme
			end
		end

		BattleConfig.TimeScale(speed)
	else
		speed = speed or BattleConfig.Speed.Default
		Time.timeScale = speed
	end
end

function BattleConfig.TimeScaleZero(val)
	if val == true then
		Time.timeScale = 0
	else
		Time.timeScale = BattleConfig.Speed.Default
	end
end

function BattleConfig.TimeScaleOne()
	Time.timeScale = BattleConfig.Speed.One
end

function BattleConfig.OtherCamp(camp)
	return 2 - camp + 1
end

BattleConfig.Guide = {}
BattleConfig.Guide.CutIn = 1.5
BattleConfig.Guide.TakeDmg = 0.9
BattleConfig.Guide.CastSkill = 1.2
BattleConfig.Guide.EnemyAngry = 1.2
BattleConfig.Guide.LiveStart = 0.5
