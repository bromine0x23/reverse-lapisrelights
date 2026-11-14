-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageGvg/Monster3dRenderCfg.lua

local MonsterCfg = require("luaData/Monster")
local mts = {}

mts.map = {}

local mt = {}

mt.key = "DlgGvgCombatReadiness"
mts.map[mt.key] = setmetatable({}, {
	__index = mt
})
mt.cameraPos = {
	0,
	1000,
	7.45
}
mt.cameraRot = {
	0,
	180,
	0
}
mt.defaultModelPos = {
	0,
	998,
	0
}
mt.defaultScale = 2
mt.defaultBossScale = 0.4
mt.modelPos = {}
mt.modelPos["532014"] = {
	0,
	996,
	0
}
mt.modelScale = {}

function mt:ModelPos(key)
	key = tostring(key)

	if self.modelPos[key] then
		return self.modelPos[key]
	else
		return self.defaultModelPos
	end
end

function mt:ModelScale(key)
	key = tostring(key)

	if self.modelScale[key] then
		return self.modelScale[key]
	elseif MonsterCfg[tonumber(key)] and MonsterCfg[tonumber(key)].Boss == 1 then
		return self.defaultBossScale
	else
		return self.defaultScale
	end
end

local mt2 = mt

mt2.key = "DlgGvgOver"
mts.map[mt.key] = setmetatable({}, {
	__index = mt2
})

local mt = {}

mt.key = "Steps"
mts.map[mt.key] = setmetatable({}, {
	__index = mt
})
mt.cameraPos = {
	0,
	4.88,
	30.41
}
mt.cameraRot = {
	0,
	180,
	0
}
mt.defaultModelPos = {
	{
		8.26,
		-0.53,
		0
	},
	{
		-8.52,
		1.56,
		0
	},
	{
		-3.56,
		-0.87,
		0
	},
	{
		0.73,
		2.09,
		0
	}
}
mt.defaultModelRot = {
	{
		0,
		1.6,
		0
	},
	{
		-1.975,
		19.434,
		0.005
	},
	{
		-7.33,
		20.697,
		-2.324
	},
	{
		7.6,
		32.8,
		4.8
	}
}
mt.defaultScale = {
	0.4849,
	0.359,
	0.35,
	0.6
}
mt.modelPos = {}
mt.modelScale = {}

function mt:ModelPos(key, idx)
	key = tostring(key)

	if self.modelPos[key] then
		return self.modelPos[key]
	else
		return self.defaultModelPos[idx]
	end
end

function mt:ModelRot(key, idx)
	return self.defaultModelRot[idx]
end

function mt:ModelScale(key, idx)
	key = tostring(key)

	if self.modelScale[key] then
		return self.modelScale[key]
	else
		return self.defaultScale[idx]
	end
end

return mts.map
