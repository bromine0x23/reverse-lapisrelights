-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/RedDotSystem.lua

require("RedDot/RedDotNode")

RedDotSystem = class("RedDotSystem")

local splitChar = "/"

function RedDotSystem:ctor()
	self.root = RedDotNode(nil, "Root")
	self.all_node = {}
end

function RedDotSystem:GetNodeByPath(path)
	if string.isNullOrEmpty(path) then
		error("Path is illegal.")
	end

	local node = table.getValueByKey(self.all_node, path)

	if node ~= nil then
		return node
	end

	local cur = self.root
	local array = string.split(path, splitChar)

	for i = 1, #array - 1 do
		local child = cur:GetOrAddChild(array[i])

		cur = child
	end

	local target = cur:GetOrAddChild(array[#array])

	self.all_node[path] = target

	return target
end
