-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/Object/Bullet.lua

Bullet = class("Bullet", CacheableObject, true)

local _BulletData = require("luaData.BulletData")
local MAX_LIFE_TIME = 5
local nextGlobalID = 1

function Bullet.GetNextUID()
	nextGlobalID = nextGlobalID + 1

	return tostring(nextGlobalID)
end

function Bullet:Reset()
	self.TypeName = ""
	self.UniqueId = ""
	self.IsBoom = false
	self.SourceUID = ""
	self.Source = nil
	self.BoomTime = 0
	self.HitTime = 0
	self.Target = nil
	self.TargetPos = nil
	self.TargetRadius = 0
	self.Pos = nil
	self.OffsetX = 0
	self.OffsetY = 0
	self.OffsetZ = 0
	self.Speed = 0
	self.AttachDamage = nil
	self.OnBoom = nil
	self.IsRemoved = false
	self.EffId = nil
	self.TargetSlot = ""
	self.BoomCallBack = nil
	self.totalTime = 0
	self.curTime = 0
	self.center = nil
	self.startVec = nil
	self.endVec = nil
end

function Bullet:ctor()
	Bullet.base.ctor(self)
end

function Bullet:Instantiate()
	self:Reset()

	self.Obj = GOUtil.NewGameObject("bullet", nil)
end

function Bullet:IsVaild()
	return not IsNil(self.Obj)
end

function Bullet:Init()
	if IsNil(self.Obj) then
		return
	end

	self.UniqueId = Bullet.GetNextUID()

	GOUtil.SetActive(self.Obj, true)
end

function Bullet:SetSource(src)
	self.IsRemoved = false
	self.srcClassName = src.className
	self.Source = nil

	if src.className == "UnitActor" then
		self.SourceUID = src.UniqueId
		self.Source = src
		self.Pos = src.ActorRoot.transform.position
	else
		print("Bullet:SetSource ,  class not define src.className = " .. tostring(src.className))
	end
end

function Bullet:SetTarget(target)
	self.Target = target
	self.BoomPos = Bullet.GetBoomPos(self.Target, self.bulletCfg)
	self.TargetRadius = self.Target.ActorRadius
end

function Bullet.GetBoomPos(unit, bulletCfg)
	local BoomPos

	if bulletCfg.TargetSlot ~= "" then
		BoomPos = unit:GetBone(bulletCfg.TargetSlot).transform.position
	else
		BoomPos = unit.ActorRoot.transform.position + Vector3(0, bulletCfg.OffsetY, 0)
	end

	return BoomPos
end

function Bullet.GetStartPos(unit, bulletCfg)
	local pos = unit.ActorRoot.transform.position

	pos = pos + Vector3(bulletCfg.OffsetX, bulletCfg.OffsetY, bulletCfg.OffsetZ)

	return pos
end

function Bullet:SetBoomCallBack(callback)
	self.BoomCallBack = callback
end

function Bullet:SetBulletData(bulletId)
	if IsNil(self.Obj) then
		return
	end

	local info = _BulletData[bulletId]

	if not info then
		print(self.Source.UnitTitle .. " <color=red>子弹没配置！</color>   , bulletId = " .. bulletId)

		info = _BulletData[1000]
	end

	self.bulletCfg = info
	self.TypeName = info.ShowName
	self.IsBoom = false
	self.Speed = info.Speed
	self.EffId = EffectMgr:AllocById(info.Fx, self.Obj)
	self.TargetSlot = Tenary(info.TargetSlot, "")
	self.OffsetX = info.OffsetX
	self.OffsetY = info.OffsetY
	self.OffsetZ = info.OffsetZ
	self.Track = info.Track
	self.TrackParams = info.TrackParams
	self.Pos = Bullet.GetStartPos(self.Source, self.bulletCfg)
	self.Obj.transform.position = self.Pos
end

function Bullet:Luanch()
	if IsNil(self.Obj) then
		return
	end

	if not self.Target then
		print("bullet luanch no target , return")

		return
	end

	if self.Track == "Parabola" then
		self:InitParabolaData()
	end

	if self.TypeName ~= "" then
		self.Obj.transform:LookAt(self.BoomPos)
		Event.Instance:Fire("子弹-发射", self)
	end
end

function Bullet:InitParabolaData()
	local speed = self.Speed * 0.001 * 60

	self.totalTime = Vector3.Distance(self.Pos, self.BoomPos) / speed
	self.curTime = 0
	self.center = (self.Pos + self.BoomPos) * 0.5
	self.center = self.center - Vector3(0, self.TrackParams.Height, 0)
	self.startVec = self.Pos - self.center
	self.endVec = self.BoomPos - self.center
end

function Bullet:Boom()
	if self.IsBoom == true then
		return
	end

	if self.BoomCallBack then
		self.BoomCallBack()
	end

	self:DeleteSelf()
end

function Bullet:DeleteSelf()
	if IsNil(self.Obj) then
		return
	end

	self.IsBoom = true
	self.BoomTime = 0
	self.Speed = 0

	if self.TypeName ~= "" then
		Event.Instance:Fire("子弹-爆炸", self)
	end

	EffectMgr:DelayFree(self.EffId)
	GOUtil.SetActive(self.Obj, false)
	GP.BulletPool:Destroy(self)
end

local function move_to(curPos, targetPos, speed)
	if curPos == targetPos then
		return curPos
	end

	local dir = targetPos - curPos
	local dist = dir.magnitude
	local move = speed * 0.001 * 60 * Time.deltaTime

	curPos = TenaryOp(dist <= move, targetPos, curPos + dir / dist * move)

	return curPos
end

function Bullet:Update()
	if self.Speed <= 0 then
		return
	end

	if self.Track == "None" then
		self:NoneMove()
	elseif self.Track == "Parabola" then
		self:ParabolaMove()
	end
end

function Bullet:NoneMove()
	self.Pos = move_to(self.Pos, self.BoomPos, self.Speed)
	self.Obj.transform.position = self.Pos

	if (self.Pos - self.BoomPos).magnitude <= 0.3 then
		self:Boom()
	end
end

function Bullet:ParabolaMove()
	local v = self.curTime / self.totalTime

	self.Obj.transform.position = self.center + Vector3.Slerp(self.startVec, self.endVec, v)

	if v >= 1 then
		self:Boom()
	else
		self.curTime = self.curTime + Time.deltaTime
	end
end
