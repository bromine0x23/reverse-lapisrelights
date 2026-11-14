-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Util/RandomUtil.lua

_MTRandom = require("GameLogic/Util/MTRandom")

local mt = GLClass("_MTRandom")

function mt:ctor()
	self.Seed = 0
	self.Count = 0
	self.MTRandom = _MTRandom.new()
end

function mt:Randomseed(seed)
	self.Seed = seed

	self.MTRandom:randomseed(self.Seed)
end

function mt:_AddCount()
	self.Count = self.Count + 1
end

function mt:Random(m, n)
	self:_AddCount()

	return self.MTRandom:random(m, n)
end

function mt:Random0_100()
	self:_AddCount()

	return self.MTRandom:random(0, 100)
end

function mt:Random0_Max(max)
	self:_AddCount()

	return self.MTRandom:random(0, max)
end

RandomUtil = {}

local MTRandom, MTRandom_Reward

function RandomUtil.Init(seed1, seed2)
	MTRandom = mt()
	MTRandom_Reward = mt()

	MTRandom:Randomseed(seed1)
	MTRandom_Reward:Randomseed(seed2)
end

function RandomUtil.Purge()
	MTRandom = nil
	MTRandom_Reward = nil
end

function RandomUtil.Get(m)
	return MTRandom:Random(m)
end

function RandomUtil.Random(m, n)
	return MTRandom:Random(m, n)
end

function RandomUtil.Random0_1()
	local r = MTRandom:Random0_100()

	return r * 0.01
end

function RandomUtil.Random0_Max(max)
	return MTRandom:Random0_Max(max)
end

function RandomUtil.Reward(pr)
	pr = math.floor(pr * 100)

	return pr > MTRandom:Random0_100()
end

function RandomUtil.RandomReward(max)
	return MTRandom_Reward:Random(max)
end

function RandomUtil.GetTotalCount_Reward()
	return MTRandom_Reward.Count
end
