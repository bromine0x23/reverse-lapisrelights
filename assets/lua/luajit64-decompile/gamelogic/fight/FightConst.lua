-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Fight/FightConst.lua

FightConst = {
	whippedMonsterAddPR = function(hurt, maxHp)
		local value = hurt / maxHp

		if value < 0.1 then
			return 0
		elseif value >= 0.1 and value < 0.2 then
			return 0.02
		elseif value >= 0.2 and value < 0.4 then
			return 0.05
		elseif value >= 0.4 and value < 0.6 then
			return 0.1
		elseif value >= 0.6 and value < 0.8 then
			return 0.2
		else
			return 0.5
		end
	end,
	whippedBossAddPR = function(hurt, maxHp)
		local value = hurt / maxHp

		if value < 0.05 then
			return 0
		elseif value >= 0.05 and value < 0.1 then
			return 0.1
		elseif value >= 0.1 and value < 0.2 then
			return 0.2
		else
			return 0.5
		end
	end
}
