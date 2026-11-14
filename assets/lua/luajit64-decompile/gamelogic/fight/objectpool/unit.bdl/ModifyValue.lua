-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/ObjectPool/Unit/ModifyValue.lua

ModifyValue = GLClass("ModifyValue")

local baseMetaTable = getmetatable(ModifyValue)

function baseMetaTable.__call(class_tbl, ...)
	local obj = {}
	local attrTb = {}
	local sourceTb = GetGLClassBaseTb(ModifyValue)

	setmetatable(obj, {
		__index = function(tb, key)
			if key == "BaseValue" then
				return attrTb[key]:GetDecrypted()
			else
				return attrTb[key] == nil and sourceTb[key] or attrTb[key]
			end
		end,
		__newindex = function(tb, key, val)
			if key == "BaseValue" then
				attrTb[key] = ObscuredUtils.GetObscuredDouble(val)
			else
				attrTb[key] = val
			end
		end
	})

	local create

	function create(c, ...)
		if c.base then
			create(c.base, ...)
		end

		if c.ctor then
			c.ctor(obj, ...)
		end

		obj.isClass = false
	end

	create(ModifyValue, ...)

	return obj
end

function ModifyValue:Reset()
	self.BaseValue = 0

	function self.BindAttriFun()
		return 0
	end

	self.AddValue = 0
	self.MulValue = 0
	self.Value = 0
	self.Dirty = false
end

function ModifyValue:Resume()
	self.AddValue = 0
	self.MulValue = 0

	return self:GetValue()
end

function ModifyValue:ctor()
	self:Reset()
end

function ModifyValue:SetZero()
	self.AddValue = self:GetValue() * -1
	self.MulValue = 0
end

function ModifyValue:Calculate()
	self.Value = self.BaseValue * (1 + self.MulValue) + self.AddValue
	self.Dirty = false
end

function ModifyValue:Add(val)
	self.AddValue = self.AddValue + val
	self.Dirty = true
end

function ModifyValue:AddMul(val)
	self.MulValue = self.MulValue + val
	self.Dirty = true
end

function ModifyValue:SetBindAttriFun(fun)
	self.BindAttriFun = fun
end

function ModifyValue:GetBaseValue()
	return self.BaseValue
end

function ModifyValue:SetBaseValue(baseValue)
	self.BaseValue = baseValue
	self.Dirty = true
end

function ModifyValue:SetValue(val)
	self.AddValue = 0
	self.MulValue = 0

	self:SetBaseValue(val)
end

function ModifyValue:GetValue()
	self:Calculate()

	return self.Value
end
