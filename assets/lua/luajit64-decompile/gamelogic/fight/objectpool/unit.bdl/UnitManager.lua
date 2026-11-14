-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/ObjectPool/Unit/UnitManager.lua

UnitManager = GLClass("UnitManager", GameHelper)

function UnitManager:ctor(GL)
	self.GL = GL

	self:Reset()

	self.UnitSelector = UnitSelector(GL, self.Units)
end

function UnitManager:Reset()
	self.Units = {}
	self.UnitById = {}
	self.UnitSelector = {}
	self.activeUnitCount = 0
	self.RemoveMap = {}
end

function UnitManager:Purge()
	for i, unit in ipairs(self.Units) do
		unit:Purge()
	end

	self:Reset()
end

function UnitManager:CreateUnit(isImmediately, unitData, camp, order, wave)
	if camp > GameLogic.MAX_CAMP_COUNT then
		self:ERROR("<Call UnitMgr.CreateUnit> error camp => " .. camp)
	end

	local baseData
	local unitClass = unitData.unitClass

	if unitClass == EnumFight.UnitClass.PLAYER then
		baseData = self.GL.GameBaseData.Character[unitData.unitId]
	elseif unitClass == EnumFight.UnitClass.PVPPLAYER then
		baseData = self.GL.GameBaseData.Character[unitData.unitId]
	elseif unitClass == EnumFight.UnitClass.ENEMY then
		baseData = self.GL.GameBaseData.Monster[unitData.unitId]
	end

	local unit = self.GL.ObjectPool.Unit:Create()

	unit:SetUnitData(unitData, baseData, camp, order, wave)
	self:AddUnit(unit)

	if isImmediately == true then
		self.GL:Fire("单位-立即创建", unit)
	else
		self.GL:Fire("单位-创建", unit)
	end

	unit:InitAllAttribute()

	return unit
end

function UnitManager:SummonUnit(startData, order)
	local unitData = startData
	local unit

	if unitData then
		local baseData = self.GL.GameBaseData.Monster[unitData.unitId]

		unit = self.GL.ObjectPool.Unit:Create()

		local uid = unit.UniqueId
		local camp = EnumFight.Camp.ENEMY
		local wave = self.GL.RunTime.CurWave

		unit.IsSummon = true

		unit:SetUnitData(unitData, baseData, camp, order, wave)
		self:AddUnit(unit)
		self.GL:Fire("召唤单位-创建", unit)
		unit:InitAllAttribute()
	end

	return unit
end

function UnitManager:AddUnit(unit)
	table.insert(self.Units, unit)

	self.UnitById[unit.UniqueId] = unit
end

function UnitManager:DestroyUnitById(uniqueId)
	local unit = self.UnitById[uniqueId]

	if unit then
		self:DestroyUnit(unit)
	end
end

function UnitManager:DestroyUnit(unit, unitIdx)
	if self:RemoveUnit(unit, unitIdx) == true then
		self.GL:Fire("单位-销毁", unit)

		if unit.IsSummon == false then
			if not self.RemoveMap[unit.Camp] then
				self.RemoveMap[unit.Camp] = {}
			end

			if not self.RemoveMap[unit.Camp][unit.Wave] then
				self.RemoveMap[unit.Camp][unit.Wave] = {}
			end

			if not self.RemoveMap[unit.Camp][unit.Wave][unit.Order] then
				self.RemoveMap[unit.Camp][unit.Wave][unit.Order] = {}
			end
		end

		self.GL.ObjectPool.Unit:Recycle(unit)
	end
end

function UnitManager:IsRemoved(camp, wave, order)
	if not self.RemoveMap[camp] then
		return false
	end

	if not self.RemoveMap[camp][wave] then
		return false
	end

	if not self.RemoveMap[camp][wave][order] then
		return false
	end

	return true
end

function UnitManager:RemoveUnit(unit, unitIdx)
	if unitIdx then
		if not self.Units[unitIdx] then
			self:ERROR("RemoveUnit ERROR, Can not remove unitIdx:" .. unitIdx)

			return false
		end

		table.remove(self.Units, unitIdx)
	else
		local removeIdx = -1

		for i = 1, #self.Units do
			local value = self.Units[i]

			if value == unit then
				removeIdx = i

				table.remove(self.Units, removeIdx)

				return true
			end
		end

		if removeIdx == -1 then
			self:ERROR("RemoveUnit ERROR, Can not remove Unit:" .. unit.UnitTitle)

			return false
		end
	end

	return true
end

function UnitManager:FindUnitById(uniqueId)
	if type(uniqueId) == "number" then
		uniqueId = tostring(uniqueId)
	end

	return self.UnitById[uniqueId]
end

function UnitManager:Selector()
	return self.UnitSelector:Start()
end
