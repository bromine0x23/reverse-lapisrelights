-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/GameResult/GameResult_UnitInfo.lua

local GameResult_UnitInfo = GLClass("GameResult_GameResult_UnitInfo", GameHelper)

function GameResult_UnitInfo:ctor(GL)
	self.GL = GL
	self.player = {}
	self.deadplayers = {}
	self.enemy = {}
	self.deadmonsters = {}

	self:OnRegisterEvent()
end

function GameResult_UnitInfo:Purge()
	self:OnUnRegisterEvent()

	self.GL = nil
	self.deadmonsters = {}
	self.deadplayers = {}
end

function GameResult_UnitInfo:GetData()
	return self.list
end

function GameResult_UnitInfo:OnRegisterEvent()
	self.GL.GlobalEvent:Add("单位-准备创建", self.OnUnitReady, self)
	self.GL:On("单位-死亡", self.OnUnitDie, self)
end

function GameResult_UnitInfo:OnUnRegisterEvent()
	self.GL.GlobalEvent:Remove("单位-准备创建", self.OnUnitReady, self)
	self.GL:Off("单位-死亡", self.OnUnitDie, self)
end

function GameResult_UnitInfo:OnUnitReady(startData)
	local camp = startData.camp
	local order = startData.order
	local wave = startData.wave

	if camp == 1 then
		self.player[order] = startData
	else
		if not self.enemy[wave] then
			self.enemy[wave] = {}
		end

		if not self.enemy[wave][order] then
			self.enemy[wave][order] = {}
		end

		self.enemy[wave][order] = startData
	end
end

function GameResult_UnitInfo:OnUnitDie(unit)
	if unit.Camp == EnumFight.Camp.ENEMY then
		if unit.CampOrder then
			self.deadmonsters[unit.CampOrder] = 0
		end
	else
		self.deadplayers[unit.CampOrder] = 0
	end
end

function GameResult_UnitInfo:Monter()
	local minusHp = {}
	local curHps = {}
	local campOrder = 0

	if self.GL.GameStartData.pvp == EnumFight.Pvp.NONE then
		for wave, enemys in ipairs(self.enemy) do
			for order, enemy in ipairs(enemys) do
				campOrder = campOrder + 1

				if self.deadmonsters[campOrder] then
					table.insert(minusHp, enemy.hp)
					table.insert(curHps, 0)
				else
					table.insert(minusHp, 0)
					table.insert(curHps, enemy.hp)
				end
			end
		end
	end

	for i, unit in self.GL.UnitMgr:Selector():Camp(2):Ipairs() do
		if minusHp[unit.CampOrder] then
			local curHp = unit:Get("生命")
			local initHp = unit:Get("初始生命")
			local _minusHp = math.max(initHp - curHp, 0)

			minusHp[unit.CampOrder] = _minusHp
			curHps[unit.CampOrder] = math.ceil(curHp)
		end
	end

	return minusHp, curHps
end

function GameResult_UnitInfo:Player()
	local minusHp = {}
	local curHps = {}
	local campOrder = 0

	for order, enemy in ipairs(self.player) do
		campOrder = campOrder + 1

		if self.deadplayers[campOrder] then
			table.insert(minusHp, enemy.hp)
			table.insert(curHps, 0)
		else
			table.insert(minusHp, 0)
			table.insert(curHps, enemy.hp)
		end
	end

	for i, unit in self.GL.UnitMgr:Selector():Camp(1):Ipairs() do
		if minusHp[unit.CampOrder] then
			local curHp = unit:Get("生命")
			local initHp = unit:Get("初始生命")
			local _minusHp = math.max(initHp - curHp, 0)

			minusHp[unit.CampOrder] = _minusHp
			curHps[unit.CampOrder] = math.ceil(curHp)
		end
	end

	return minusHp, curHps
end

return GameResult_UnitInfo
