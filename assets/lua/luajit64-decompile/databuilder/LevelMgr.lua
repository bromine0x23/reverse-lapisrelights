-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/DataBuilder/LevelMgr.lua

LevelMgr = {}
eLevelType = {
	P = "player",
	C = "card",
	F = "favor"
}

function LevelMgr:GetLevel(_type, _exp)
	if _type == eLevelType.P then
		return self:GetPlayerLevel(_exp)
	elseif _type == eLevelType.C then
		return self:GetCardLevel(_exp)
	elseif _type == eLevelType.F then
		return self:GetFavorLevel(_exp)
	end

	return 1
end

function LevelMgr:ExpConverToLevel(field, exp)
	local level = 1
	local expValue = 0
	local levelData = ConfigTable.LevelConfig

	while true do
		if levelData[level][field] == 0 then
			level = level - 1

			break
		end

		if exp < levelData[level][field] then
			break
		end

		if levelData[level + 1] == nil then
			break
		end

		level = level + 1
	end

	return level
end

function LevelMgr:FavorExpConverToLevel(field, exp)
	local level = 1
	local expValue = 0
	local favorData = ConfigTable.FavorLevel

	while level < #favorData do
		if favorData[level][field] == 0 then
			level = level - 1

			break
		end

		if exp < favorData[level][field] then
			break
		end

		level = level + 1
	end

	return level
end

function LevelMgr:GetPlayerLevel(exp)
	return self:ExpConverToLevel("PlayerExperienceAdd", exp)
end

function LevelMgr:GetCardLevel(exp)
	return self:ExpConverToLevel("RoleCardExperienceAdd", exp)
end

function LevelMgr:GetFavorLevel(exp)
	return self:FavorExpConverToLevel("FavorPointAdd", exp)
end
