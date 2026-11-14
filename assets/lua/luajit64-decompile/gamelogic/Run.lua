-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GameLogic/Run.lua

function Repaly(path)
	local file = io.open(path, "r")
	local jsonStr = file:read("*a")

	file:close()

	local game = require("GameLogic/RunGame")
	local out = game:ServerRun(jsonStr)
	local json = require("GameLogic.Util.json4lua")

	out.json = {}

	local str = json.encode(out)

	print(str)
end

function Run(path)
	local file = io.open(path, "r")
	local jsonStr = file:read("*a")

	file:close()

	local game = require("GameLogic/RunGame")
	local gl = game:TestRun(jsonStr)
	local out = gl:GetServerRet()

	out.json = {}

	local json = require("GameLogic.Util.json4lua")
	local str = json.encode(out)

	print(str)
	gl:Purge()
end

function RunByStageId(_stageId)
	local game = require("GameLogic/RunGame")
	local json = require("GameLogic.Util.json4lua")
	local vParam = {}

	vParam = FightDataUtil.GetStartData({
		stageId = _stageId,
		boutId = _stageId,
		randomSeed = tonumber(tostring(os.time()):reverse():sub(1, 6)),
		randomSeedForReward = randomSeed
	})

	local path = "GameLogic/Jsons/0_player_data.json"
	local file = io.open(path, "r")
	local playerDatas = file:read("*a")

	file:close()

	local playerDatas = json.decode(playerDatas)

	vParam.teams[1][1] = {}
	vParam.teams[1][1] = playerDatas

	local battleStageId = ConfigTable.StageData[_stageId].BattleStageID
	local battleStageData = ConfigTable.BattleStage[battleStageId]
	local enemyList = battleStageData.Enemy
	local monsterLvList = battleStageData.MonsterLv
	local monsterIdx = 0

	for _, waveEnemys in ipairs(enemyList) do
		vParam.teams[2][_] = {}

		for i, UnitId in ipairs(waveEnemys) do
			monsterIdx = monsterIdx + 1

			local _level = monsterLvList[monsterIdx]

			if not _level or type(_level) ~= "number" then
				_level = 1
			end

			local _unitData = FightDataUtil.GetEnemyStartData({
				isSummon = false,
				camp = 2,
				hpRate = 1,
				isCenter = false,
				unitId = UnitId,
				level = _level,
				unitClass = EnumFight.UnitClass.ENEMY,
				order = i,
				wave = _
			})

			table.insert(vParam.teams[2][_], _unitData)
		end
	end

	local jsonStr = json.encode(vParam)
	local gl = game:TestRun(jsonStr)
	local out = gl:GetServerRet()

	print("isWin:" .. tostring(out.isWin) .. "  round:" .. out.round)

	if out.isWin == true then
		win = win + 1
	else
		lose = lose + 1
	end

	local function writeText(filename, text)
		local f = io.open(filename, "w")

		f:write(text)
		f:close()
	end

	writeText("C:/Users/Mloong/Desktop/FightDataJsons/" .. _stageId .. ".json", out.json)
	gl:Purge()
end

win = 0
lose = 0

function RunAllStage()
	local startTime = os.time()
	local stageData = require("luaData/StageData")

	for k, v in pairs(stageData) do
		if v.Type ~= 2 and v.Type ~= 8 then
			RunByStageId(v.ID)
		end
	end

	print("win:" .. win .. "   lose:" .. lose)

	local oltime = os.time() - startTime

	print("oltime:" .. oltime)
end
