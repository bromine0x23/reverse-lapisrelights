-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/Object/Unit/UnitVocal.lua

UnitVocal = class("UnitVocal")
UnitVocal.enType = {
	Cutin = {
		"VocalCutin",
		"VocalCutin2",
		"VocalCutin3",
		"VocalCutin4",
		"VocalCutin5"
	},
	Start = {
		"VocalStart",
		"VocalStart2",
		"VocalStart3",
		"VocalStart4"
	},
	Lose = {
		"VocalLose"
	},
	Win = {
		"VocalWin",
		"VocalWin2",
		"VocalWin3",
		"VocalWin4"
	},
	Hit = {
		"VocalHit"
	},
	HitMid = {
		"VocalHitMid"
	},
	HitMax = {
		"VocalHitMax"
	},
	Recover = {
		"VocalRecover",
		"VocalRecover2"
	},
	Atk = {
		"VocalAtk"
	},
	SkillTimeline = {
		"VocalSkillTimeline"
	},
	Die = {
		"VocalCommon1"
	},
	VocalBuff = {
		"VocalRecover"
	},
	VocalDeBuff = {
		"VocalDebuff"
	},
	VocalSession = {
		"VocalAtkRandom1",
		"VocalAtkRandom2",
		"VocalAtkRandom3"
	}
}
UnitVocal.CDConfig = {
	{
		cd = 3,
		type = {
			UnitVocal.enType.Start,
			UnitVocal.enType.Recover,
			UnitVocal.enType.Hit,
			UnitVocal.enType.HitMid,
			UnitVocal.enType.HitMax,
			UnitVocal.enType.Atk,
			UnitVocal.enType.SkillTimeline,
			UnitVocal.enType.VocalBuff,
			UnitVocal.enType.VocalDeBuff,
			UnitVocal.enType.VocalSession
		}
	},
	{
		cd = 3,
		type = {
			UnitVocal.enType.Die
		}
	}
}

local CD
local MsgBoxCfg = {}

function UnitVocal.Init()
	CD = {}

	for idx, config in ipairs(UnitVocal.CDConfig) do
		for i, typeName in ipairs(config.type) do
			CD[typeName] = {}
			CD[typeName].now = 0
			CD[typeName].cd = config.cd
		end
	end
end

function UnitVocal._IsCD(enType)
	local val = false

	if CD[enType] then
		local now = os.clock()
		local last = CD[enType].now
		local t = now - last

		if t > CD[enType].cd then
			val = false
			CD[enType].now = now
		else
			val = true
		end
	end

	return val
end

function UnitVocal.End()
	CD = {}
end

function UnitVocal.Stop(enType, unit)
	for _, key in ipairs(enType) do
		local eventName = unit.UnitData.data[key]

		BattleConfig.StopSound(eventName)
	end
end

function UnitVocal:GetSoundEvent(cfg, enType)
	local r = math.random(1, #enType)
	local field = enType[r]

	return cfg[field], field
end

function UnitVocal:ctor(GP)
	self:Reset()
	self:OnRegisterEvent()

	self.GP = GP
end

function UnitVocal:Cache()
	return
end

function UnitVocal:Reset()
	self.GP = nil
end

function UnitVocal:Purge()
	self:Reset()
	self:OnUnRegisterEvent()
end

function UnitVocal:OnRegisterEvent()
	Event.Instance:Add("UnitVocalEvent", self.OnUnitVocalEvent, self)
	Event.Instance:Add("UnitVocalEvent_Hit", self.OnUnitVocalEvent_Hit, self)
	Event.Instance:Add("UnitVocalEvent_SkillTimeline", self.OnUnitVocalEvent_SkillTimeline, self)
	Event.Instance:Add("eventSkipTimeLine", self.OnSkipTimeLine, self)
end

function UnitVocal:OnUnRegisterEvent()
	Event.Instance:Remove("UnitVocalEvent", self.OnUnitVocalEvent, self)
	Event.Instance:Remove("UnitVocalEvent_Hit", self.OnUnitVocalEvent_Hit, self)
	Event.Instance:Remove("UnitVocalEvent_SkillTimeline", self.OnUnitVocalEvent_SkillTimeline, self)
	Event.Instance:Remove("eventSkipTimeLine", self.OnSkipTimeLine, self)
end

function UnitVocal:OnUnitVocalEvent(enType, unit)
	if not unit then
		return
	end

	if type(unit) == "string" then
		unit = UnitActor.FindUnitById(unit)
	end

	if not unit then
		return
	end

	if unit.className ~= "UnitActor" then
		return
	end

	if unit.UnitClass == EnumFight.UnitClass.ENEMY then
		return
	end

	if not unit.UnitData then
		return
	end

	if not unit.UnitData.data then
		return
	end

	local soundEvent, field = self:GetSoundEvent(unit.UnitData.data, enType)

	if not soundEvent then
		return
	end

	if soundEvent == "" then
		return
	end

	if UnitVocal._IsCD(enType) == true then
		return
	end

	BattleConfig.PostSoundEvent(soundEvent, UIMgr.UICamera.gameObject)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIMsgBoxs", true, field, unit)

	local tempVaild = {}

	tempVaild[UnitVocal.enType.Start] = true
	tempVaild[UnitVocal.enType.Win] = true
	tempVaild[UnitVocal.enType.Lose] = true
	tempVaild[UnitVocal.enType.Cutin] = true

	if tempVaild[enType] == true then
		unit:PlayLip(soundEvent)
	end
end

function UnitVocal:OnUnitVocalEvent_Hit(msg)
	local unit = UnitActor.FindUnitById(msg.uniqueId)

	if not unit then
		return
	end

	if unit.className ~= "UnitActor" then
		return
	end

	if unit.Camp ~= EnumFight.Camp.PLAYER then
		return
	end

	if not unit.UnitData then
		return
	end

	if not unit.UnitData.data then
		return
	end

	local enType = UnitVocal.enType.Hit

	if msg.jobMul > 1 or msg.isCritical == true then
		enType = UnitVocal.enType.HitMid
	end

	if msg.minusHp >= unit:GetAttri("最大生命") * GetConfigArgFloat("VocalHitMaxDamageRatio") then
		enType = UnitVocal.enType.HitMax
	end

	local soundEvent, field = self:GetSoundEvent(unit.UnitData.data, enType)

	if not soundEvent then
		return
	end

	if soundEvent == "" then
		return
	end

	if UnitVocal._IsCD(enType) == true then
		return
	end

	BattleConfig.PostSoundEvent(soundEvent, UIMgr.UICamera.gameObject)
	Event.Instance:Fire("EVENT_OPEN_DLG", "DlgUIMsgBoxs", true, field, unit)
end

function UnitVocal:OnUnitVocalEvent_SkillTimeline(enType, skillCfg, isEnterTimeline, unit)
	if skillCfg.SoundEvent == "" then
		return
	end

	if self.handle_skilldelay then
		BattleConfig.FreeTimer(self.handle_skilldelay)
	end

	if isEnterTimeline == true then
		self.handle_skilldelay = BattleConfig.Delay(skillCfg.SoundDelay, function()
			self.skillVocalEvent = skillCfg.SoundEvent

			BattleConfig.PostSoundEvent(skillCfg.SoundEvent, UIMgr.UICamera.gameObject)
			unit:PlayLip(skillCfg.SoundEvent)
		end)
	else
		self.skillVocalEvent = nil
	end
end

function UnitVocal:OnSkipTimeLine()
	if self.skillVocalEvent then
		BattleConfig.StopSound(self.skillVocalEvent)

		self.skillVocalEvent = nil
	end
end
