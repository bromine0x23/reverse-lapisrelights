-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/Script/Enemy/109001.lua

local m = {}

m[210910002] = {}
m[210910002].OnCast = function(Skill)
	local targets = Skill:SelectTarget(EnumFight.AffectType.Friend)

	for i, unit in ipairs(targets) do
		local val = unit:Get("最大生命") * 0.6

		print("加血：" .. val)
		unit:HealHp(val)
	end
end

return m
