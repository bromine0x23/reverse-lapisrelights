-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/ObjectPool/Damage.lua

Damage = GLClass("Damage", GLCacheableObject)

function Damage:Reset()
	self.dmgType = EnumFight.DamageType.Undefined
	self.srcSkillName = ""
	self.srcUnitName = ""
	self.srcUniqueId = ""
	self.srcClassName = ""
	self.info = ""
	self.damage = 0
	self.damagePhy = 0
	self.damageMag = 0
	self.realDamage = 0
	self.criMul = 0
	self.criChance = 0
	self.sourceSession = EnumFight.SessionType.none
	self.isGroupSession = false
	self.isCritical = false
	self.job = ""
	self.jobMul = 1
	self.finalMinusHp = 0
	self.finalMinusShield = 0
	self.finalRealMinusHp = 0
	self.unitCountRate = 0
	self.target = nil
	self.IsRemoved = false
	self.HitEff = 0
	self.hp = 0
	self.shield = 0
	self.breakShieldState = EnumFight.BreakShieldState.UNDEFINE
	self.dot = 0
	self.mut = 1
	self.breakArmor = 0
	self.addAtkMul = 1
	self.dmgSource = nil
	self.hitRate = 1
	self.pct = 0
	self.finalVal = 0
	self.attachBuffIds = {}
	self.IgnorShield = false
end

function Damage:ctor(GL)
	Damage.base.ctor(self, GL)
	self:Reset()
end

function Damage:Init(...)
	self:Reset()
end

function Damage:Copy()
	local dmg = self.GL.ObjectPool.Damage:Create()

	dmg.dmgType = self.dmgType
	dmg.srcSkillName = self.srcSkillName
	dmg.srcUnitName = self.srcUnitName
	dmg.srcUniqueId = self.srcUniqueId
	dmg.srcClassName = self.srcClassName
	dmg.info = self.info
	dmg.damage = self.damage
	dmg.damagePhy = self.damagePhy
	dmg.damageMag = self.damageMag
	dmg.criMul = self.criMul
	dmg.criChance = self.criChance
	dmg.isCritical = self.isCritical
	dmg.sourceSession = self.sourceSession
	dmg.isGroupSession = self.isGroupSession
	dmg.job = self.job
	dmg.jobMul = self.jobMul
	dmg.finalMinusHp = self.finalMinusHp
	dmg.finalMinusShield = self.finalMinusShield
	dmg.finalRealMinusHp = self.finalRealMinusHp
	dmg.unitCountRate = self.unitCountRate
	dmg.target = self.target
	dmg.IsRemoved = self.IsRemoved
	dmg.HitEff = self.HitEff
	dmg.hp = self.hp
	dmg.shield = self.shield
	dmg.breakShieldState = self.breakShieldState
	dmg.mut = self.mut
	dmg.dot = self.dot
	dmg.breakArmor = self.breakArmor
	dmg.addAtkMul = self.addAtkMul
	dmg.dmgSource = self.dmgSource
	dmg.hitRate = self.hitRate
	dmg.pct = self.pct
	dmg.finalVal = self.finalVal
	dmg.attachBuffIds = self.attachBuffIds
	dmg.IgnorShield = self.IgnorShield

	return dmg
end

function Damage:SetSource(src)
	self.IsRemoved = false
	self.srcClassName = src.className

	if src.className == "Skill" then
		self.srcSkillName = src.ShowName
		self.srcUniqueId = src.Owner.UniqueId
		self.srcClassName = src.Owner.className
		self.target = src.Target
	elseif src.className == "Unit" then
		self.srcUniqueId = src.UniqueId
		self.job = src.BaseData.Job
	else
		self:ERROR("Damage:SetSource ,  class not define src.className = " .. tostring(src.className))
	end
end

function Damage:AttachBuffs(buffsId)
	self.attachBuffIds = buffsId
end

function Damage:SetMut(step)
	self.mut = step
end

function Damage:AddMul(mul)
	self.damagePhy = self.damagePhy * mul
	self.damageMag = self.damageMag * mul
end

function Damage:AddPhyMul(mul)
	self.damagePhy = self.damagePhy * mul
end

function Damage:AddMagMul(mul)
	self.damageMag = self.damageMag * mul
end

function Damage:AddPhy(val)
	self.damagePhy = self.damagePhy + val
end

function Damage:AddMag(val)
	self.damageMag = self.damageMag + val
end

function Damage:SetPhy(val)
	self.damagePhy = val
end

function Damage:SetMag(val)
	self.damageMag = val
end

function Damage:AddCriticalRatio(val)
	self.criChance = self.criChance + val
end

function Damage:AddCriticalRatioMul(val)
	self.criChance = self.criChance * val
end

function Damage:AddCriticalDamage(val)
	self.criMul = self.criMul + val
end

function Damage:AddDotMul(mul)
	self.dot = self.dot * mul
end

function Damage:SetBreakArmor(val)
	if not val then
		return
	end

	self.breakArmor = self.breakArmor + val
end

function Damage:SetAddAtkMul(val)
	if not val then
		return
	end

	self.addAtkMul = self.addAtkMul * val
end

function Damage:AddPct(val)
	if not val then
		return
	end

	self.pct = self.pct + val
end

function Damage:AddFinalVal(val)
	if not val then
		return
	end

	self.finalVal = self.finalVal + val
end

function Damage:SetIgnorShield()
	self.IgnorShield = true
end

function Damage:GroupSessionCombo(comboNum)
	local data = 0.05

	self.pct = self.pct + data * comboNum
end
