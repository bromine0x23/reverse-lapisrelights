-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/DropGroupTool.lua

local DropGroup = require("luaData/DropGroup")
local DropGroupTool = {}

function DropGroupTool.Init()
	if DropGroupTool.map == nil then
		DropGroupTool.map = {}

		for i, v in ipairs(DropGroup) do
			local arr = DropGroupTool.map[v.GroupID]
			local maxWeightKey = v.GroupID .. "maxWeight"

			if arr == nil then
				arr = {}
				DropGroupTool.map[v.GroupID] = arr
				DropGroupTool.map[maxWeightKey] = 0
			end

			table.insert(arr, v)

			DropGroupTool.map[maxWeightKey] = DropGroupTool.map[maxWeightKey] + v.Weight
		end
	end
end

function DropGroupTool.GetRandomData(GroupID)
	local arr = DropGroupTool.map[GroupID]
	local maxWeight = DropGroupTool.map[GroupID .. "maxWeight"]
	local randomWeight = Mathf.Random(0, maxWeight)

	table.sort(arr, function(d1, d2)
		return d1.Weight < d2.Weight
	end)

	local lastWeight = 0

	for i, v in ipairs(arr) do
		lastWeight = lastWeight + v.Weight

		if randomWeight <= lastWeight then
			return v
		end
	end
end

return DropGroupTool
