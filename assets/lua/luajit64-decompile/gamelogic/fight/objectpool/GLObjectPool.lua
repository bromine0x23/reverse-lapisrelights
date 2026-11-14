-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/ObjectPool/GLObjectPool.lua

GLCacheableObject = GLClass("GLCacheableObject", GameHelper)

function GLCacheableObject:ctor(GL)
	self.GL = GL
	self.UID = 0
	self.__next = nil
end

function GLCacheableObject:Recycle()
	self:Reset()
end

function GLCacheableObject:Init(...)
	self:ERROR("you should implement Init()")
end

function GLCacheableObject:Reset()
	self:ERROR("you should implement Reset()")
end

function GLCacheableObject:CreateDamage()
	local dmg = self.GL.ObjectPool.Damage:Create()

	dmg.dmgType = EnumFight.DamageType.Std

	dmg:SetSource(self)

	local source = self.GL.UnitMgr:FindUnitById(dmg.srcUniqueId)

	if source then
		dmg.damagePhy = source:Get("物理攻击")
		dmg.damageMag = source:Get("魔法攻击")
		dmg.damage = dmg.damagePhy + dmg.damageMag
		dmg.criMul = source:Get("暴击效果")
		dmg.criChance = source:Get("暴击率")
		dmg.hitRate = source:Get("命中率")
	end

	return dmg
end

GLObjectPool = GLClass("GLObjectPool")

function GLObjectPool:ctor(GL, luaType)
	self.GL = GL
	self.luaType = luaType
	self.poolHead = nil
end

function GLObjectPool:Create(...)
	local obj = self:_GetFromPool()

	if obj == nil then
		obj = self.luaType(self.GL)
	end

	obj.UID = self.GL:GetNextUniqueId()

	obj:Init(...)

	return obj
end

function GLObjectPool:Recycle(obj)
	if obj ~= nil then
		obj:Recycle()
		self:_PutIntoPool(obj)
	end
end

function GLObjectPool:_GetFromPool()
	local node

	if self.poolHead ~= nil then
		node = self.poolHead
		self.poolHead = self.poolHead.__next
	end

	return node
end

function GLObjectPool:_PutIntoPool(obj)
	if obj ~= nil then
		obj.__next = self.poolHead
		self.poolHead = obj
	end
end
