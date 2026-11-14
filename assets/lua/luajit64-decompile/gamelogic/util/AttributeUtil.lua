-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Util/AttributeUtil.lua

require("GameLogic/ConfigTable")

AttributeUtil = {}

function AttributeUtil.GetMonsterAttri(idx, stageId)
	local attris = {}

	attris.def = 0
	attris.maxHp = 0
	attris.phyAtk = 0
	attris.magAtk = 0

	local stagedata = ConfigTable.StageData[stageId]

	if stagedata then
		local battlestage = ConfigTable.BattleStage[stagedata.BattleStageID]

		if battlestage and battlestage.Attribute then
			local data = battlestage.Attribute[idx]

			if data then
				attris.def = data.defense
				attris.maxHp = data.hp
				attris.phyAtk = data.phyAtk
				attris.magAtk = data.magAtk
			end
		end
	end

	return attris
end

local MonsterCfg = require("luaData/Monster")

function AttributeUtil.GetMonsterAttri_(cfg, level)
	local attris = {}

	attris.def = 0
	attris.maxHp = 0
	attris.phyAtk = 0
	attris.magAtk = 0

	local lv = 1

	if level and type(level) == "number" then
		lv = level
	end

	if cfg and type(cfg) == "number" then
		local id = cfg

		cfg = MonsterCfg[id]
	end

	local a, b, c = 0.72, 0.23, 0.05

	if cfg.Boss == 1 then
		local S = math.max(145.24 * lv + 573.9, 262.4 * lv - 7888.5, 402.92 * lv - 31591)
		local DEFm = 1.2 * c * S

		attris.def = DEFm * cfg.DefAdd

		local HPRm = math.min(1.2 * lv + 18, 0.6 * lv + 30, 0.01 * lv + 38, 42) * math.max(0.001 * (lv - 150) + 1, 1) * math.sqrt(math.max(1.4, 1.4 + 0.0013333333333333335 * (lv - 100)) / 1.4) * (1 + math.min(0.01 * lv / 25, 0.2)) * 1.25
		local HPm = 1.2 * (b * S - DEFm) * HPRm

		attris.maxHp = HPm * cfg.HpAdd

		local ATKRm = math.max(3.3 - 0.002 * lv, 2.9)
		local ATKm = (a * S / ATKRm + c * S) * math.max(0.001 * (lv - 150) + 1, 1) * math.sqrt(math.max(1.4, 1.4 + 0.0013333333333333335 * (lv - 100)) / 1.4) * (1 + math.min(0.01 * lv / 25, 0.2)) * math.max(1.2 - 0.0008 * lv, 1)

		attris.phyAtk = ATKm * cfg.PhyAtkAdd
		attris.magAtk = ATKm * cfg.MagAtkAdd
	else
		local S = math.max(145.24 * lv + 573.9, 262.4 * lv - 7888.5, 402.92 * lv - 31591)
		local DEFm = 1.1 * c * S

		attris.def = DEFm * cfg.DefAdd

		local HPRm = math.min(0.35 * lv + 2, 0.08 * lv + 3.3, 0.005 * lv + 4, 6) * math.max(0.001 * (lv - 150) + 1, 1) * math.sqrt(math.max(1.4, 1.4 + 0.0013333333333333335 * (lv - 100)) / 1.4) * (1 + math.min(0.01 * lv / 25, 0.2)) * 1.25
		local HPm = 1.2 * (b * S - DEFm) * HPRm

		attris.maxHp = HPm * cfg.HpAdd

		local ATKRm = math.max(3.3 - 0.0016 * lv, 3)
		local ATKm = (a * S / ATKRm + c * S) * math.max(0.001 * (lv - 150) + 1, 1) * math.sqrt(math.max(1.4, 1.4 + 0.0013333333333333335 * (lv - 100)) / 1.4) * (1 + math.min(0.01 * lv / 25, 0.2))

		attris.phyAtk = ATKm * cfg.PhyAtkAdd
		attris.magAtk = ATKm * cfg.MagAtkAdd
	end

	attris.maxHp = math.ceil(attris.maxHp)

	return attris
end
