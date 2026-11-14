-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/ObjectPool/Buff.lua

Buff = GLClass("Buff", GLCacheableObject)
Buff.ConstBuff = {
	sleep = 14,
	stun = 12,
	enchantment = 13,
	frozen = 11,
	fire = 22,
	bleed = 23,
	poison = 21
}

function Buff:ctor(GL)
	Buff.base.ctor(self, GL)
	self:Reset()
end

function Buff:Init(...)
	self:Reset()
end

function Buff:Reset()
	self.Owner = nil
	self.BuffId = 0
	self.ShowName = ""
	self.Type = ""
	self.ClearType = 0
	self.Custom = {}
	self.Stack = 0
	self.MaxStack = 0
	self.Target = nil
	self.TypeOrder = ""
	self.IsMiss = false
	self.SourceUniqueId = ""
	self.CfgValue = nil
	self.CfgRound = nil
	self.Duration = 0
	self.IsTeam = 0
	self.SkillPower = -1
	self.LogicData = nil
	self.Priority = 0
end

function Buff:SetBuffData(owner, buffId, battleBuffData)
	self.Owner = owner
	self.BuffId = buffId
	self.TypeOrder = TenaryOp(battleBuffData.TypeOrder, battleBuffData.TypeOrder, "")
	self.ClearType = TenaryOp(battleBuffData.ClearType, battleBuffData.ClearType, 0)
	self.MaxStack = TenaryOp(battleBuffData.MaxStack, battleBuffData.MaxStack, 0)
	self.ShowName = GLLang(battleBuffData.ShowName)
	self.Type = battleBuffData.Type
	self.Value = battleBuffData.Value
	self.CfgValue = battleBuffData.Value
	self.Round = battleBuffData.Round
	self.CfgRound = battleBuffData.Round
	self.Custom = TenaryOp(battleBuffData.Custom, battleBuffData.Custom, {})
	self.IsUniquely = battleBuffData.Uniquely
	self.IsTeam = battleBuffData.IsTeam
	self.IsAlive = battleBuffData.IsAlive

	if BuffPriority[self.Type] then
		self.Priority = BuffPriority[self.Type]
	end
end

function Buff:SetSkillPower(skillPower)
	if skillPower and type(skillPower) == "number" then
		self.SkillPower = skillPower
		self.Value = self.Value * skillPower
	end
end

function Buff:SetSource(sourceUniqueId)
	if type(sourceUniqueId) == "string" then
		self.SourceUniqueId = sourceUniqueId
	else
		self.SourceUniqueId = sourceUniqueId.UniqueId
	end
end

function Buff:Add()
	local success = self:ConfigBuffAdd()

	if success == true then
		local source = self.GL.UnitMgr:FindUnitById(self.SourceUniqueId)

		if source then
			self.GL.RunTime:GetTeamByCamp(source.Camp):CastBuff(self)
		end

		self.Owner:Fire("单位-添加buff", self)
	end

	return success
end

function Buff:Recover()
	local success = self:ConfigBuffRecover()

	if success == true then
		self.Owner:Fire("单位-更新buff", self.Owner, self)
	end

	return success
end

function Buff:Update()
	if self.OnUpdate then
		self.OnUpdate(self)
	end

	self:ConfigBuffUpdate()
end

function Buff:RefreshRound()
	if self.Owner.UniqueId == "" then
		return
	end

	self.Duration = self.Duration + 1

	if self.Round ~= -1 and self.Round ~= 0 and self.GL.RunTime.CurRound > 1 then
		self.Round = self.Round - 1
	end

	if self.Round == 0 then
		self:RemoveSelf()

		return
	end

	self.Owner:Fire("单位-更新buff", self.Owner, self)
end

function Buff:RemoveSelf()
	for i, teams in ipairs(self.GL.RunTime.Teams) do
		teams:RemoveBuff(self)
	end

	self.Owner:RemoveBuff(self)
end

function Buff:Remove()
	self:ConfigBuffRemove()
	self.Owner:Fire("单位-移除buff", self.Owner, self.BuffId, self.UID)
end

function Buff:GetCustomByPropName(propName)
	return self.Custom[propName]
end

function Buff:GetCustom()
	return self.Custom
end

function Buff:ConfigBuffAdd()
	local success = false

	if BuffScript[self.Type] then
		local _onAdd = BuffScript[self.Type].OnAdd

		if _onAdd then
			success = _onAdd(self) ~= false
		end
	end

	return success
end

function Buff:ConfigBuffRecover()
	local success = false

	if BuffScript[self.Type] then
		local _onRecover = BuffScript[self.Type].OnRecover

		if _onRecover then
			success = _onRecover(self) ~= false
		end
	end

	return success
end

function Buff:ConfigBuffUpdate()
	if BuffScript[self.Type] then
		local _onUpdate = BuffScript[self.Type].OnUpdate

		if _onUpdate then
			self.Owner:Fire("单位-buff即将生效", self.Owner, self.BuffId, self.UID)
			_onUpdate(self)
		end
	end
end

function Buff:ConfigBuffRemove()
	if BuffScript[self.Type] then
		local _onRemove = BuffScript[self.Type].OnRemove

		if _onRemove then
			_onRemove(self)
		end
	end
end

function Buff:AddStack(val)
	self.Stack = self.Stack + val

	self.Owner:Fire("单位-buff叠层数", self.Owner, self.BuffId, self.UID, self.Stack)
end
