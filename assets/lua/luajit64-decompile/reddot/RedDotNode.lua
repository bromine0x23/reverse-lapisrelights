-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/RedDot/RedDotNode.lua

RedDotNode = class("RedDotNode")

function RedDotNode:ctor(parent, name)
	self.node_name = name or ""
	self.node_type = RED_DOT_TYPE.A
	self.node_parent = parent
	self.node_children = {}
	self.node_value = 0
	self.node_state = RED_DOT_STATE_TYPE.NORMAL
end

function RedDotNode:SetParent(node)
	node = node or RedDotNode()
	self.node_parent = node
end

function RedDotNode:SetType(type)
	self.node_type = type or RED_DOT_TYPE.A
end

function RedDotNode:SetValue(value)
	self.node_value = math.max(value, 0)
end

function RedDotNode:GetValue()
	return math.max(self.node_value, 0)
end

function RedDotNode:GetOrAddChild(key)
	local node = table.getValueByKey(self.node_children, key)

	if node ~= nil then
		return node
	end

	local child = RedDotNode(self, key)

	self.node_children[key] = child

	return child
end

function RedDotNode:ChangeValue(value)
	value = value or 0
	self.node_value = math.max(self.node_value + value, 0)

	local function ChangeCall(parent)
		if parent then
			parent:ValueChangeCall()
			ChangeCall(parent.node_parent)
		else
			return
		end
	end

	ChangeCall(self.node_parent)

	if self.node_value == 0 and self.node_type == RED_DOT_TYPE.C then
		self.node_state = RED_DOT_STATE_TYPE.WATING
	end
end

function RedDotNode:ValueChangeCall()
	if table.getCount(self.node_children) ~= 0 then
		local sum = 0

		for _, node in pairs(self.node_children) do
			sum = sum + node.node_value
		end

		self.node_value = sum
	end
end
