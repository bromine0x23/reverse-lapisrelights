-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Util/Container.lua

Container = class("Container")

function Container:ctor()
	self.RelationContainer = {}
end

function Container:GetCount()
	return #self.RelationContainer
end

function Container:Push(vDlgBase)
	table.insert(self.RelationContainer, vDlgBase)
end

function Container:PushObj(vObj)
	for i = 1, #self.RelationContainer do
		if self.RelationContainer[i] == vObj then
			return
		end
	end

	table.insert(self.RelationContainer, vObj)
end

function Container:Pop()
	if #self.RelationContainer < 1 then
		return nil
	end

	local dlgBase = table.remove(self.RelationContainer)

	return dlgBase
end

function Container:GetFirst()
	local dlgBase = self.RelationContainer[1]

	return dlgBase
end

function Container:GetLast()
	if #self.RelationContainer > 0 then
		local dlgBase = self.RelationContainer[#self.RelationContainer]

		return dlgBase
	else
		return nil
	end
end

function Container:GetIndexByValue(vValue)
	local index = -1

	for i = 1, #self.RelationContainer do
		local value = self.RelationContainer[i]

		if value == vValue then
			index = i

			return index
		end
	end

	return index
end

function Container:GetValueByIndex(vIndex)
	local value = self.RelationContainer[vIndex]

	return value
end

function Container:RemoveByValue(vValue)
	local index = self:GetIndexByValue(vValue)

	if index > 0 then
		return self:RemoveByIndex(index)
	end
end

function Container:RemoveByIndex(vIndex)
	local dlgBase = table.remove(self.RelationContainer, vIndex)

	return dlgBase
end

function Container:Enumerator()
	local i = 0
	local _s, _var

	return function(s, var)
		i = i + 1

		if i > #self.RelationContainer then
			return nil
		else
			return i, self.RelationContainer[i]
		end
	end, _s, _var
end

function Container:Contains(vValue)
	for i = 1, #self.RelationContainer do
		local value = self.RelationContainer[i]

		if vValue == value then
			return true
		end
	end

	return false
end

function Container:SetValueByIndex(vIndex, vValue)
	if vIndex < 1 then
		return
	end

	self.RelationContainer[vIndex] = vValue
end

function Container:Clear()
	self.RelationContainer = nil
end
