-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Util/ObjectPool.lua

CacheableObject = GLClass("CacheableObject")

function CacheableObject:ctor()
	self.__next = nil
end

function CacheableObject:Instantiate()
	error("you should implement Instantiate()")
end

function CacheableObject:Init(...)
	error("you should implement Init()")
end

function CacheableObject:Reset()
	error("you should implement Reset()")
end

function CacheableObject:IsVaild()
	error("you should implement IsVaild()")
end

ObjectPool = GLClass("ObjectPool")

function ObjectPool:ctor(luaType, prefab)
	self.luaType = luaType
	self.poolHead = nil
	self.prefab = prefab
end

function ObjectPool:Create(...)
	local obj = self:_GetFromPool()

	if obj == nil then
		obj = self.luaType()

		obj:Instantiate(self.prefab)
	elseif not obj:IsVaild() then
		obj:Instantiate(self.prefab)
	end

	obj:Init(...)

	return obj
end

function ObjectPool:Destroy(obj)
	if obj ~= nil then
		obj:Reset()
		self:_PutIntoPool(obj)
	end
end

function ObjectPool:_GetFromPool()
	local node

	if self.poolHead ~= nil then
		node = self.poolHead
		self.poolHead = self.poolHead.__next
	end

	return node
end

function ObjectPool:_PutIntoPool(obj)
	if obj ~= nil then
		obj.__next = self.poolHead
		self.poolHead = obj
	end
end
