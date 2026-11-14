-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/Object/Unit/FightTeam.lua

FightTeam = class("FightTeam", nil, true)

function FightTeam:ctor(GP)
	self.GP = GP

	self:Reset()
end

function FightTeam:Reset()
	self.Teams = {}
	self.Summons = {}
	self.PlayerTeam = nil
	self.EnemyTeam = nil
	self.CenterUnit = nil
	self.PlayerMp = 0
	self.PlayerMaxShield = 0
	self.Speeds = {}
	self.Speeds[1] = 0
	self.Speeds[2] = 0
	self.ActionCamp = 0
end

function FightTeam:Get(camp)
	if camp == EnumFight.Camp.PLAYER then
		return self.PlayerTeam
	elseif camp == EnumFight.Camp.ENEMY then
		return self.EnemyTeam
	end

	print("GetTeam ERROR , camp:" .. camp)

	return nil
end

function FightTeam:RefreshCurEnemyTeam(curWave)
	self.EnemyTeam = self.Teams[2][curWave]
end

function FightTeam:SetActive(camp, val)
	local team

	if camp == 1 then
		team = self.PlayerTeam
	elseif camp == 2 then
		team = self.EnemyTeam
	end

	for i, unit in ipairs(team) do
		unit:SetActive(val)
	end
end

function FightTeam:SetActiveWithFx(camp, val)
	local team

	if camp == 1 then
		team = self.PlayerTeam
	elseif camp == 2 then
		team = self.EnemyTeam
	end

	for i, unit in ipairs(team) do
		unit:SetActiveWithFx(val)
	end
end

function FightTeam:SummonUnitReady(msg)
	local unit = UnitActor(self.GP, msg)

	table.insert(self.Summons, unit)
end

function FightTeam:UnitReady(msg)
	local unitId, cardId, camp, order, wave, skills = msg.unitId, msg.cardId, msg.camp, msg.order, msg.wave, msg.skills

	if not self.Teams[camp] then
		self.Teams[camp] = {}
	end

	if not self.Teams[camp][wave] then
		self.Teams[camp][wave] = {}

		if camp == 1 and wave == 1 then
			self.PlayerTeam = self.Teams[camp][wave]
		end
	end

	if not self.Teams[camp][wave][order] then
		self.Teams[camp][wave][order] = {}
	end

	local unit = UnitActor(self.GP, msg)

	if unit.IsCenter == true and unit.Camp == EnumFight.Camp.PLAYER then
		self.CenterUnit = unit
	end

	self.Teams[camp][wave][order] = unit
end

function FightTeam:Cache()
	for campIdx, team in ipairs(self.Teams) do
		for waveIdx, waveTeam in ipairs(self.Teams[campIdx]) do
			for order, unit in ipairs(self.Teams[campIdx][waveIdx]) do
				unit:Cache()
			end
		end
	end

	for i, unit in ipairs(self.Summons) do
		unit:Cache()
	end
end

function FightTeam:Purge()
	for campIdx, team in ipairs(self.Teams) do
		for waveIdx, waveTeam in ipairs(self.Teams[campIdx]) do
			for order, unit in ipairs(self.Teams[campIdx][waveIdx]) do
				unit:Purge()
			end
		end
	end

	for i, unit in ipairs(self.Summons) do
		unit:Purge()
	end
end

function FightTeam:_GetNewLocation()
	local emptySlots = {
		1,
		2,
		3,
		4,
		5
	}
	local left = {}
	local right = {}

	for i, alive in ipairs(self.EnemyTeam) do
		if alive.IsDead == false then
			for idx = #emptySlots, 1, -1 do
				if emptySlots[idx] == alive.LocationIndex then
					table.remove(emptySlots, idx)

					break
				end
			end

			local slot = alive.LocationIndex

			if slot < 3 then
				table.insert(left, alive)
			elseif slot > 3 then
				table.insert(right, alive)
			end
		end
	end

	local newLocation = 0

	if #left <= #right then
		newLocation = emptySlots[1]
	else
		newLocation = emptySlots[#emptySlots]
	end

	return newLocation
end

function FightTeam:CreateSummonUnit(msg)
	local unit = UnitActor(self.GP, msg)

	if unit then
		unit:SetUniqueId(msg.uniqueId)

		unit.LocationIndex = self:_GetNewLocation()

		unit:CreateImmediately()
		table.insert(self.EnemyTeam, unit)
	else
		print("ERROR unitActor is nil")
	end

	local tempList = {}

	for i, unit in ipairs(self.EnemyTeam) do
		table.insert(tempList, unit)
	end

	table.sort(tempList, function(a, b)
		return a.LocationIndex < b.LocationIndex
	end)

	for i, unit in ipairs(tempList) do
		unit.TeamIndex = i
	end
end

function FightTeam:UnitCreate(msg)
	local uniqueId, unitId, camp, order, wave = msg.uniqueId, msg.unitId, msg.camp, msg.order, msg.wave
	local unit = self.Teams[camp][wave][order]

	if unit then
		unit:SetUniqueId(uniqueId)
		unit:Create()
	else
		print("ERROR unitActor is nil")
	end
end

function FightTeam:UnitReadyImmediately(msg)
	local camp = msg.camp

	self.Teams[camp] = {}

	for i, data in ipairs(msg.datas) do
		data.camp = camp

		local unitId, cardId, camp, order, wave, skills = data.unitId, data.cardId, data.camp, data.order, data.wave, data.skills

		if not self.Teams[camp][wave] then
			self.Teams[camp][wave] = {}

			if camp == 1 and wave == 1 then
				self.PlayerTeam = self.Teams[camp][wave]
			end
		end

		if not self.Teams[camp][wave][order] then
			self.Teams[camp][wave][order] = {}
		end

		local unit = UnitActor(self.GP, data)

		if unit.IsCenter == true then
			self.CenterUnit = unit
		end

		self.Teams[camp][wave][order] = unit
	end
end

function FightTeam:UnitCreateImmediately(msg)
	local uniqueId, unitId, camp, order, wave = msg.uniqueId, msg.unitId, msg.camp, msg.order, msg.wave
	local unit = self.Teams[camp][wave][order]

	if unit then
		unit:SetUniqueId(uniqueId)
		unit:CreateImmediately()
	else
		print("ERROR unitActor is nil")
	end
end

function FightTeam:UnitDestroy(msg)
	local uniqueId = msg.uniqueId
	local unit = UnitActor.FindUnitById(uniqueId)

	unit:Purge()
end

function FightTeam:Update()
	if self.PlayerTeam then
		for order, unit in ipairs(self.PlayerTeam) do
			unit:OnUpdate()
		end
	end

	if self.EnemyTeam then
		for order, unit in ipairs(self.EnemyTeam) do
			unit:OnUpdate()
		end
	end
end
