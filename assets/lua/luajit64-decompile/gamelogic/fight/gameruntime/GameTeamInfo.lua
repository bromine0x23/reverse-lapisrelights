-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/GameRunTime/GameTeamInfo.lua

local TEAM_MODIFIABLE_ATTRIBUTES = {
	PLAYER = {
		"行动序号",
		"最大生命",
		"最大魔力",
		"最大护盾",
		"生命",
		"魔力",
		"护盾",
		"速度"
	},
	MONSTER = {
		"行动序号"
	}
}

GameTeamInfo = GLClass("GameTeamInfo", GameHelper)

function GameTeamInfo:ctor(GL)
	self.GL = GL

	self:Reset()
end

function GameTeamInfo:Reset()
	self.UniqueIds = {}
	self.UnitClass = EnumFight.UnitClass.UNDEFINE
	self.Camp = 0
	self.Wave = 0
	self.StartDatas = {}
	self.AttributeMap = {}
	self.AllNotAction = false
	self.CastBuffs = {}
	self.TotalCount = 0
	self.AliveCount = 0
	self.Hp = 0
	self.Shield = 0
	self.Mp = 0
	self.ShieldBreak = false
end

function GameTeamInfo:SetCamp(camp, unitClass)
	self.Camp = camp
	self.UnitClass = unitClass
end

function GameTeamInfo:UnitDead()
	self.AliveCount = self.AliveCount - 1
end

function GameTeamInfo:Reborn()
	self.AliveCount = self.AliveCount + 1
end

function GameTeamInfo:InsertStartData(wave, startData)
	if not self.StartDatas[wave] then
		self.StartDatas[wave] = {}
	end

	table.insert(self.StartDatas[wave], startData)
end

function GameTeamInfo:GetTeamHpPercent()
	local cur, max = 0, 0

	for i, uniqueId in ipairs(self.UniqueIds) do
		local unit = self.GL.UnitMgr:FindUnitById(uniqueId)

		cur = cur + unit:Get("生命")
		max = max + unit:Get("最大生命")
	end

	return cur / max
end

function GameTeamInfo:GetTeamMaxHp()
	local cur, max = 0, 0

	for i, uniqueId in ipairs(self.UniqueIds) do
		local unit = self.GL.UnitMgr:FindUnitById(uniqueId)

		max = max + unit:Get("最大生命")
	end

	return max
end

function GameTeamInfo:HealHp(val)
	self.Hp = self.Hp + val

	if self.Hp > self:Get("最大生命") then
		self.Hp = self:Get("最大生命")
	end

	self:UpdateAttibute("生命")
end

function GameTeamInfo:MinusHp(val)
	self.Hp = self.Hp - val

	if self.Hp < 0 then
		self.Hp = 0
	end

	self:UpdateAttibute("生命")
end

function GameTeamInfo:AddShield(val)
	local addData = {}

	addData.addVal = val

	self.GL:Fire("队伍-即将更变护盾", self, addData)

	if addData.addVal == 0 then
		return 0
	end

	addData.addVal = math.ceil(addData.addVal)
	self.Shield = self.Shield + addData.addVal

	if self.Shield > self:Get("最大护盾") then
		self.Shield = self:Get("最大护盾")
	end

	if self.Shield <= 0 then
		self.Shield = 0
		self.ShieldBreak = true
	end

	self:UpdateAttibute("护盾")

	return addData.addVal
end

function GameTeamInfo:ForceMp(val)
	val = math.ceil(val)
	self.Mp = self.Mp + val

	if self.Mp > self:Get("最大魔力") then
		self.Mp = self:Get("最大魔力")
	end

	if self.Mp < 0 then
		self.Mp = 0
	end

	self:UpdateAttibute("魔力")
end

function GameTeamInfo:CreateCurWaveUnits(curWave)
	self.Wave = curWave

	local startDatas = self.StartDatas[self.Wave]

	if not startDatas then
		self:ERROR(" GameTeamInfo:CreateCurWaveUnits !!!   curWave = " .. tostring(curWave))

		if not _G_LAPIS_SERVER then
			error("GameTeamInfo:CreateCurWaveUnits !!!   curWave = " .. tostring(curWave))

			local jsonStr = self.GL:GetReplayJsonData()

			error(jsonStr)

			return
		end
	end

	for i, uniqueId in ipairs(self.UniqueIds) do
		self.GL.UnitMgr:DestroyUnitById(uniqueId)
	end

	self.UniqueIds = {}

	for i, data in ipairs(startDatas) do
		local unit = self.GL.UnitMgr:CreateUnit(false, data, self.Camp, i, curWave)

		table.insert(self.UniqueIds, unit.UniqueId)
	end

	self.TotalCount = #startDatas
	self.AliveCount = self.TotalCount

	if self.UnitClass == EnumFight.UnitClass.PLAYER or self.UnitClass == EnumFight.UnitClass.PVPPLAYER then
		for _, attriKey in ipairs(TEAM_MODIFIABLE_ATTRIBUTES.PLAYER) do
			self.AttributeMap[attriKey] = ModifyValue()
		end

		local function get(key)
			return self.AttributeMap[key]
		end

		for i, unit in self.GL.UnitMgr:Selector():Camp(self.Camp):Ipairs() do
			get("最大生命").BaseValue = get("最大生命").BaseValue + unit:Get("生命")
			get("最大护盾").BaseValue = get("最大护盾").BaseValue + unit:Get("最大护盾")
			get("速度").BaseValue = get("速度").BaseValue + unit:Get("速度")
			self.Shield = self.Shield + unit:Get("护盾")
		end

		self.ShieldBreak = self.Shield <= 0
		self.Hp = get("最大生命").BaseValue
		self.Mp = 0

		if self.GL.GameStartData.pvp ~= EnumFight.Pvp.NONE then
			self.Mp = GLGetConfigArgInt("PVPMpDefault")
		end

		get("最大魔力").BaseValue = 50

		for _, attriKey in ipairs(TEAM_MODIFIABLE_ATTRIBUTES.PLAYER) do
			self:UpdateAttibute(attriKey)
		end

		get("行动序号").BaseValue = 2

		if self.UnitClass == EnumFight.UnitClass.PVPPLAYER then
			get("行动序号").BaseValue = 1
		end
	else
		for _, attriKey in ipairs(TEAM_MODIFIABLE_ATTRIBUTES.MONSTER) do
			self.AttributeMap[attriKey] = ModifyValue()
		end

		local function get(key)
			return self.AttributeMap[key]
		end

		get("行动序号").BaseValue = 1

		for _, attriKey in ipairs(TEAM_MODIFIABLE_ATTRIBUTES.MONSTER) do
			self:UpdateAttibute(attriKey)
		end
	end

	for i, uniqueId in ipairs(self.UniqueIds) do
		local unit = self.GL.UnitMgr:FindUnitById(uniqueId)

		unit:SetSkills()
	end
end

function GameTeamInfo:SummonUnits(summonDatas)
	for i, startData in ipairs(summonDatas) do
		if self.AliveCount + 1 <= 3 then
			local unit = self.GL.UnitMgr:SummonUnit(startData, self.TotalCount + 1)

			if unit then
				table.insert(self.UniqueIds, unit.UniqueId)
				unit:SetSkills()

				self.TotalCount = self.TotalCount + 1
				self.AliveCount = self.AliveCount + 1

				table.insert(self.GL.RunTime.CurSummonUnits, unit)
			end
		end
	end
end

function GameTeamInfo:CMDReadyCreateUnits(data, camp)
	self.GL:Fire("单位-准备立即创建", data, camp)
end

function GameTeamInfo:CMDCreateUnits(startDatas, camp)
	self:SetCamp(camp, EnumFight.UnitClass.ENEMY)

	local curWave = self.Wave

	for i, uniqueId in ipairs(self.UniqueIds) do
		local unit = self.GL.UnitMgr:FindUnitById(uniqueId)

		unit:RemoveAll()
		self.GL.UnitMgr:DestroyUnitById(uniqueId)
	end

	self.UniqueIds = {}

	for i, data in ipairs(startDatas) do
		local unit = self.GL.UnitMgr:CreateUnit(true, data, self.Camp, i, curWave)

		table.insert(self.UniqueIds, unit.UniqueId)
	end

	self.TotalCount = #startDatas
	self.AliveCount = self.TotalCount

	if self.Camp == EnumFight.Camp.PLAYER then
		for _, attriKey in ipairs(TEAM_MODIFIABLE_ATTRIBUTES.PLAYER) do
			self.AttributeMap[attriKey] = ModifyValue()
		end

		local function get(key)
			return self.AttributeMap[key]
		end

		for i, unit in self.GL.UnitMgr:Selector():Camp(self.Camp):Ipairs() do
			get("最大生命").BaseValue = get("最大生命").BaseValue + unit:Get("生命")
			get("最大护盾").BaseValue = get("最大护盾").BaseValue + unit:Get("最大护盾")
			self.Shield = self.Shield + unit:Get("护盾")
		end

		self.Hp = get("最大生命").BaseValue
		self.Mp = 0
		get("最大魔力").BaseValue = 50

		for _, attriKey in ipairs(TEAM_MODIFIABLE_ATTRIBUTES.PLAYER) do
			self:UpdateAttibute(attriKey)
		end

		get("行动序号").BaseValue = 2
	else
		for _, attriKey in ipairs(TEAM_MODIFIABLE_ATTRIBUTES.MONSTER) do
			self.AttributeMap[attriKey] = ModifyValue()
		end

		local function get(key)
			return self.AttributeMap[key]
		end

		get("行动序号").BaseValue = 1

		for _, attriKey in ipairs(TEAM_MODIFIABLE_ATTRIBUTES.MONSTER) do
			self:UpdateAttibute(attriKey)
		end
	end

	for i, uniqueId in ipairs(self.UniqueIds) do
		local unit = self.GL.UnitMgr:FindUnitById(uniqueId)

		unit:SetSkills()
	end
end

function GameTeamInfo:RefreshRound()
	self:ResetActionOrder()

	self.AllNotAction = false
end

function GameTeamInfo:CastBuff(buff)
	table.insert(self.CastBuffs, buff)
end

function GameTeamInfo:UpdateBuffs()
	for i = #self.CastBuffs, 1, -1 do
		self.CastBuffs[i]:RefreshRound()
	end
end

function GameTeamInfo:RemoveBuff(buff)
	if not buff then
		return
	end

	for i, ownBuff in ipairs(self.CastBuffs) do
		if ownBuff.UID == buff.UID then
			table.remove(self.CastBuffs, i)

			break
		end
	end
end

function GameTeamInfo:CheckNotAction()
	local allNotAction = true

	for i, uniqueId in ipairs(self.UniqueIds) do
		local unit = self.GL.UnitMgr:FindUnitById(uniqueId)

		if unit.NotAction == false then
			allNotAction = false

			break
		end
	end

	self.AllNotAction = allNotAction
end

function GameTeamInfo:ResetActionOrder()
	self:Resume("行动序号")
end

function GameTeamInfo:ClearActionOrder()
	self:SetZero("行动序号")
end

function GameTeamInfo:ActionStart()
	if self.UnitClass == EnumFight.UnitClass.ENEMY then
		return
	end

	for i, uniqueId in ipairs(self.UniqueIds) do
		local unit = self.GL.UnitMgr:FindUnitById(uniqueId)

		unit:ActionStart()
		unit:UpdateBuff()
	end
end

function GameTeamInfo:ActionEnd()
	self:ClearActionOrder()

	if self.UnitClass == EnumFight.UnitClass.ENEMY then
		return
	end

	for i, uniqueId in ipairs(self.UniqueIds) do
		local unit = self.GL.UnitMgr:FindUnitById(uniqueId)

		unit:ActionEnd()
	end
end

function GameTeamInfo:CastAppearSkill()
	for i, uniqueId in ipairs(self.UniqueIds) do
		local unit = self.GL.UnitMgr:FindUnitById(uniqueId)
		local hp = unit:Get("生命")

		if unit:Get("生命") > 0 then
			if self.Camp == EnumFight.Camp.ENEMY then
				unit:CastAppearSkill()
			else
				unit:CastPassiveSkill()
			end
		end
	end
end

function GameTeamInfo:Get(attrName)
	if attrName == "生命" then
		return self.Hp
	end

	if attrName == "魔力" then
		return self.Mp
	end

	if attrName == "护盾" then
		return self.Shield
	end

	if not self.AttributeMap[attrName] then
		self:ERROR(self.Camp .. " camp not define attrName:" .. attrName)

		return 0
	end

	return self.AttributeMap[attrName]:GetValue()
end

function GameTeamInfo:Set(attrName, val)
	if attrName == "生命" then
		self.Hp = val
	end

	if attrName == "魔力" then
		self.Mp = val
	end

	if attrName == "护盾" then
		self.Shield = val
	end

	if not self.AttributeMap[attrName] then
		self:ERROR(self.Camp .. " camp not define attrName:" .. attrName)

		return
	end

	self.AttributeMap[attrName]:SetValue(val)
	self:UpdateAttibute(attrName)
end

function GameTeamInfo:Resume(attrName)
	if not self.AttributeMap[attrName] then
		self:ERROR(self.Camp .. " camp not define attrName:" .. attrName)

		return
	end

	self.AttributeMap[attrName]:Resume()
	self:UpdateAttibute(attrName)
end

function GameTeamInfo:Add(attrName, val)
	local modifyValue = self.AttributeMap[attrName]

	if not modifyValue then
		self:ERROR(self.Camp .. " camp :Add ERROR attrName is not define,  attrName = " .. attrName)

		return
	end

	modifyValue:Add(val)
	self:UpdateAttibute(attrName)
end

function GameTeamInfo:AddMul(attrName, val)
	local modifyValue = self.AttributeMap[attrName]

	if not modifyValue then
		self:ERROR(self.Camp .. " camp :Add ERROR attrName is not define,  attrName = " .. attrName)

		return
	end

	modifyValue:AddMul(val)
	self:UpdateAttibute(attrName)
end

function GameTeamInfo:SetZero(attrName)
	local modifyValue = self.AttributeMap[attrName]

	if not modifyValue then
		self:ERROR(self.Camp .. " camp :SetZero ERROR attrName is not define,  attrName = " .. attrName)

		return
	end

	modifyValue:SetZero()
	self:UpdateAttibute(attrName)
end

function GameTeamInfo:UpdateAttibute(attrName)
	self.GL:Fire("队伍-更新属性", attrName, self)
end

function GameTeamInfo:GetSessionTarget()
	local target = self.GL.RunTime.CurSelectTarget

	if self.Camp == EnumFight.Camp.ENEMY then
		target = self.GL.UnitMgr:Selector():NotCamp(self.Camp):NotZeroHp():SortMin("生命"):Get()
	else
		target = self.GL.RunTime.CurSelectTarget

		if target:Get("生命") <= 0 then
			target = self.GL.UnitMgr:Selector():Camp(2):NotZeroHp():SortMin("生命"):Get()

			if target then
				self.GL.RunTime:SelectTarget(target)
			else
				target = self.GL.RunTime.CurSelectTarget
			end
		end
	end

	return target
end

function GameTeamInfo:DoGroupSession(sessionGroup)
	local sessionBonusMP = GLGetConfigArgJson("SessionBonusMP")
	local mp_val = sessionBonusMP[#sessionGroup]
	local addMp, addShield = 0, 0

	for _, item in ipairs(sessionGroup) do
		local function func()
			item:SetAction(true)

			local target = self:GetSessionTarget()
			local sessionSkill = item:GetSessionSkill()
			local sessionType = item.SessionType
			local isPower = item.IsPower
			local unit = self.GL.UnitMgr:FindUnitById(item.PlayerUniqueId)
			local dmg = unit:CreateDamage()

			dmg.target = target
			dmg.sourceSession = sessionType

			if #sessionGroup > 1 then
				dmg.isGroupSession = true
			end

			if sessionType == EnumFight.SessionType.attack then
				local arg = {
					Dmg = dmg
				}

				self.GL:Fire("Session-球发动", unit, EnumFight.SessionType.attack, arg)
				self.GL:Fire("Session-红球发动", unit, arg)
			elseif sessionType == EnumFight.SessionType.force then
				local arg = {
					Dmg = dmg
				}

				self.GL:Fire("Session-球发动", unit, EnumFight.SessionType.force, arg)
				self.GL:Fire("Session-蓝球发动", unit, arg)
			elseif sessionType == EnumFight.SessionType.recover then
				local def = unit:Get("抵御")
				local singleShield = def * GLGetConfigArgFloat("SessionShieldRatio") * GLGetConfigArgJson("SessionRatio")[#sessionGroup]
				local arg = {
					Dmg = dmg,
					SingleShield = singleShield
				}

				self.GL:Fire("Session-球发动", unit, EnumFight.SessionType.recover, arg)
				self.GL:Fire("Session-黄球发动", unit, arg)

				singleShield = arg.SingleShield
			end

			local mul = GLGetConfigArgJson("ActionRate")[sessionType] * GLGetConfigArgJson("SessionRatio")[#sessionGroup]

			dmg:AddPhyMul(mul)
			dmg:AddMagMul(mul)
			sessionSkill:CastSession(dmg)
		end

		if item.SessionType == EnumFight.SessionType.force then
			addMp = GLGetConfigArgJson("MPSessionGetMP")[#sessionGroup]
		end

		item:SetSessionCastFunction(func)
	end

	self:ForceMp(mp_val + addMp)

	local STEP = 1000
	local headItem
	local sessionGroup_sort = {}

	for i, item in ipairs(sessionGroup) do
		if i == 1 then
			headItem = item
			headItem.SessionCastOrder = i
		elseif item:GetSessionSkill().IsRange == headItem:GetSessionSkill().IsRange then
			item.SessionCastOrder = i
		else
			item.SessionCastOrder = i + STEP
		end

		table.insert(sessionGroup_sort, item)
	end

	table.sort(sessionGroup_sort, function(a, b)
		return a.SessionCastOrder < b.SessionCastOrder
	end)

	for i, item in ipairs(sessionGroup_sort) do
		local func = item.SessionCastFunction

		func()
	end
end
