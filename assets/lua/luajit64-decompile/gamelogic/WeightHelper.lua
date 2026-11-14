-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/WeightHelper.lua

local WeightHelper = GLClass("WeightHelper")

function WeightHelper:ctor()
	return
end

function WeightHelper:Random(overDropGroupPR, overDropGroupList, whipCount)
	local idx = self:GetIdx(overDropGroupPR)

	if whipCount <= 0 then
		idx = 1
	end

	return overDropGroupList[idx]
end

function WeightHelper:GetIdx(overDropGroupPR)
	local sumWeight, nowWeight = 0, 0

	for i, weight in ipairs(overDropGroupPR) do
		sumWeight = sumWeight + weight
	end

	local randomValue = RandomUtil.RandomReward(sumWeight)

	for i, weight in ipairs(overDropGroupPR) do
		nowWeight = nowWeight + weight

		if randomValue <= nowWeight then
			return i
		end
	end
end

return WeightHelper
