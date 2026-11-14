-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/Counter.lua

Counter = class("Counter")

function Counter:ctor()
	self.Count = 0
end

function Counter:Retain()
	self.Count = self.Count + 1

	return self.Count == 1
end

function Counter:Release()
	self.Count = self.Count - 1

	return self:IsRelease()
end

function Counter:IsRelease()
	if self.Count == 0 then
		return true
	elseif self.Count < 0 then
		return true
	else
		return false
	end
end
