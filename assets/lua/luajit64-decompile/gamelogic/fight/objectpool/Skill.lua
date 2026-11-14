-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/ObjectPool/Skill.lua

Skill = GLClass("Skill", GLCacheableObject)

function Skill:ctor(GL)
	Skill.base.ctor(self, GL)
	self:Reset()
end

function Skill:Init(...)
	self:Reset()
end

function Skill:Reset()
	if self.IsRemoved == false then
		self:Remove()
	end

	self.IsRemoved = true
	self.Scripts = {}
	self.Owner = nil
	self.SkillId = 0
	self.YellowBallStack = 0
	self.ShowName = ""
	self.Level = 1
	self.AllSkillLv = 1
	self.Type = EnumFight.SkillType.None
	self.ActionKey = {}
	self.Custom = {}
	self.Targets = {}
	self.Cost = 0
	self.ComboCount = 0
	self.IsRoundActive = false
end

function Skill:SetSkillData(owner, level, allSkillData, battleSkillData)
	self.Owner = owner
	self.AllSkillLv = level

	if not self.AllSkillLv then
		self.AllSkillLv = 1
	end

	self.Level = 1
	self.SkillId = battleSkillData.ID

	if allSkillData and allSkillData.Type and allSkillData.Type ~= 1 then
		self:ERROR(self.SkillId .. " Type不是战斗技能！！！检查来源 ")
	end

	self.ShowName = "skillShowName"

	if allSkillData then
		self.ShowName = GLLang(allSkillData.Name)
		self.Type = allSkillData.BattleSkillType
	else
		self:ERROR(self.SkillId .. " 对应的Allskill错误！！！")
	end

	self.Custom = battleSkillData.Custom
	self.Power = Tenary(battleSkillData.Power, {})
	self.Cost = battleSkillData.Cost
	self.ActionKey = battleSkillData.ActionKey
	self.IsRange = TenaryOp(battleSkillData.IsRange == 1, true, false)
	self.IsStackPower = TenaryOp(battleSkillData.IsStackPower == 1, true, false)

	self:SetScript()
end

function Skill:DeviceScriptBase(actionIdx)
	local mt = {}

	mt.GL = self.GL
	mt.Owner = self.Owner
	mt.Skill = self
	mt.ActionIdx = actionIdx

	function mt:GetCustom(propName)
		return self.Skill:GetCustomProperty(propName, self.ActionIdx)
	end

	function mt:GetTargets()
		local affectType = self.Skill:GetCustomProperty("Target", self.ActionIdx)

		return self.Skill:SelectTarget(affectType)
	end

	function mt:GetPowerProperty()
		local powerIdx = self.Skill.YellowBallStack

		return self.Skill:GetPowerProperty(self.ActionIdx, powerIdx)
	end

	return mt
end

function Skill:GetAllTargets()
	local VaildMap = {
		SelectAnd4 = "SelectedOtherSide",
		MinHpFriend = "MinHpFriend",
		Friend = "Friend",
		MinDefOtherSide = "MinDefOtherSide",
		SelectAnd3 = "SelectedOtherSide",
		Self = "Self",
		SelectAnd2 = "SelectedOtherSide",
		SelectedOtherSide = "SelectedOtherSide",
		SelectAnd1 = "SelectedOtherSide",
		OtherSide = "OtherSide"
	}
	local maps = {}

	if not self.ActionKey then
		return
	end

	local temp = SkillSelectTarget()

	for actionIdx, action in ipairs(self.ActionKey) do
		local affectType = self:GetCustomProperty("Target", actionIdx)

		if VaildMap[affectType] then
			local _targets = temp:Get(self, VaildMap[affectType])

			for _, target in ipairs(_targets) do
				if not maps[target.UniqueId] then
					maps[target.UniqueId] = target
				end
			end
		end
	end

	temp:Purge()

	local list = {}

	for k, v in pairs(maps) do
		table.insert(list, v.UniqueId)
	end

	return list
end

function Skill:SetScript()
	if not self.ActionKey then
		return
	end

	for actionIdx, action in ipairs(self.ActionKey) do
		if SkillScript[action] then
			local mt = self:DeviceScriptBase(actionIdx)
			local script = New(SkillScript[action], mt)

			table.insert(self.Scripts, script)
		end
	end
end

function Skill:GetPowerProperty(actionIdx, powerIdx)
	if powerIdx == 0 then
		return nil
	end

	if not self.Power then
		return nil
	end

	if not self.Power[actionIdx] then
		return nil
	end

	if not self.Power[actionIdx][powerIdx] then
		return nil
	end

	local arg = {}

	arg.powerMul = 1

	self.GL:Fire("黄球加强-即将发动", self, arg)

	return self.Power[actionIdx][powerIdx] * arg.powerMul
end

function Skill:GetCustomProperty(propName, actionIdx, propIdx)
	if not self.Custom then
		return nil
	end

	if not self.Custom[actionIdx] then
		return nil
	end

	local prop = self.Custom[actionIdx][propName]

	if not prop then
		return nil
	end

	if propIdx ~= nil then
		return prop[propIdx]
	end

	if not prop[self.Level] then
		return prop[1]
	end

	return prop[self.Level]
end

function Skill:ConfigSkillCast(dmg)
	for i, script in ipairs(self.Scripts) do
		if script.Cast then
			self.GL:Fire("技能ActionKey发动", self, script.ActionIdx)
			self.GL:Fire("受击打包", self, 1)
			script:Cast(dmg)
		elseif script.OnCast then
			local action = self.ActionKey[i]

			if SkillScript[action] and SkillScript[action].OnCast then
				self.GL:Fire("技能ActionKey发动", self, i)

				if SkillScript[action].NeedPackage ~= true then
					self.GL:Fire("受击打包", self, 1)
				end

				SkillScript[action].OnCast(self, i, dmg)
			end
		else
			local action = self.ActionKey[i]

			if SkillScript[action] and SkillScript[action].OnCast then
				self.GL:Fire("技能ActionKey发动", self, i)

				if SkillScript[action].NeedPackage ~= true then
					self.GL:Fire("受击打包", self, 1)
				end

				SkillScript[action].OnCast(self, i, dmg)
			end
		end
	end
end

function Skill:ConfigSkillCastEnd()
	if not self.ActionKey then
		return
	end

	for i, action in ipairs(self.ActionKey) do
		if SkillScript[action] and SkillScript[action].OnEnd then
			SkillScript[action].OnEnd(self, i)
		end
	end
end

function Skill:Cast()
	self:CastShot()
	self:CastEnd()
end

function Skill:CastSession(dmg)
	self.GL:Fire("技能-释放出手", self, false)
	self:ConfigSkillCast(dmg)

	self.ComboCount = 0

	self.GL:Fire("技能-释放结束", self)
end

function Skill:CastCard(dmg)
	if self.Owner.DisableCardSkill == true then
		return
	end

	self.GL.RunTime:GetTeamByCamp(self.Owner.Camp):ForceMp(self.Cost * -1)
	self.GL:Fire("技能-释放出手", self, true)
	self:ConfigSkillCast(dmg)
	self:UseStackPower()
	self.GL:Fire("技能-释放结束", self)
end

function Skill:CastShot()
	self.GL:Fire("技能-释放出手", self)
	self:ConfigSkillCast(nil)

	self.ComboCount = 0

	self.GL:Fire("技能-释放结束", self)
end

function Skill:CastEnd()
	self.GL:Fire("技能-释放结束", self)
	self:ConfigSkillCastEnd()
end

function Skill:Add()
	self.IsRemoved = false

	if self.IsStackPower == true then
		self.GL.GlobalEvent:Add("Session-黄球发动", self.StackPower, self)
	end

	for i, script in ipairs(self.Scripts) do
		if script.Add then
			script:Add()
		end
	end
end

function Skill:Remove()
	self.IsRemoved = true

	if self.IsStackPower == true then
		self.GL.GlobalEvent:Remove("Session-黄球发动", self.StackPower, self)
	end

	for i, script in ipairs(self.Scripts) do
		if script.Remove then
			script:Remove()
		end

		script = nil
	end

	self.Scripts = nil
end

function Skill:SelectTarget(affectType)
	local temp = SkillSelectTarget()
	local _targets = temp:Get(self, affectType)

	temp:Purge()
	self.GL:Fire("技能-即将选择目标", self, _targets)

	self.Targets = _targets

	return _targets
end

function Skill:StackPower(unit, arg)
	if self.IsRoundActive == false then
		return
	end

	if unit.Camp ~= self.Owner.Camp then
		return
	end

	local data = {}

	data.addStack = 1

	self.GL:Fire("技能-即将更新强化层数", self, data)

	self.YellowBallStack = self.YellowBallStack + data.addStack

	if self.YellowBallStack > 5 then
		self.YellowBallStack = 5
	end

	self.GL:Fire("技能-更新强化层数", self, self.YellowBallStack)
end

function Skill:UseStackPower()
	if self.YellowBallStack ~= 0 then
		self.YellowBallStack = 0

		self.GL:Fire("技能-更新强化层数", self, self.YellowBallStack)
	end
end

function Skill:RoundActive(val)
	self.IsRoundActive = val
end
