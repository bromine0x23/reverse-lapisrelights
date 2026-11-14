-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/GamePerform/SkillViewer/SimulateFight.lua

local aa = " {\n    \"gameId\": \"test1\",\n    \"teams\": [\n        [\n            [{\n                \"level\": 1,\n                \"attributes\": {\n                    \"defend\": 234.6,\n                    \"will\": 585.48,\n                    \"stamina\": 10312.2,\n                    \"song\": 561\n                },\n                \"wave\": 1,\n                \"unitId\": 105,\n                \"skills\": [\n                    [1053014, 1],\n                    [1053011, 1],\n                    [1002, 1],\n                    [1001, 1]\n                ],\n                \"order\": 1,\n                \"cardId\": 105301\n            }, {\n                \"level\": 1,\n                \"attributes\": {\n                    \"defend\": 276,\n                    \"will\": 84,\n                    \"stamina\": 12132,\n                    \"song\": 1260\n                },\n                \"wave\": 1,\n                \"unitId\": 202,\n                \"skills\": [\n                    [2020011, 1],\n                    [1002, 1],\n                    [1001, 1]\n                ],\n                \"order\": 2,\n                \"cardId\": 202001\n            }, {\n                \"level\": 1,\n                \"attributes\": {\n                    \"defend\": 234.6,\n                    \"will\": 583.44,\n                    \"stamina\": 10312.2,\n                    \"song\": 561\n                },\n                \"wave\": 1,\n                \"unitId\": 201,\n                \"skills\": [\n                    [2011011, 1],\n                    [2011013, 1],\n                    [1002, 1],\n                    [1001, 1]\n                ],\n                \"order\": 3,\n                \"cardId\": 201101\n            }, {\n                \"level\": 1,\n                \"attributes\": {\n                    \"defend\": 276,\n                    \"will\": 688.8,\n                    \"stamina\": 12132,\n                    \"song\": 660\n                },\n                \"wave\": 1,\n                \"unitId\": 203,\n                \"skills\": [\n                    [2030011, 1],\n                    [1002, 1],\n                    [1001, 1]\n                ],\n                \"order\": 4,\n                \"cardId\": 203001\n            }, {\n                \"level\": 1,\n                \"attributes\": {\n                    \"defend\": 244.8,\n                    \"will\": 71.4,\n                    \"stamina\": 10322.4,\n                    \"song\": 1071\n                },\n                \"wave\": 1,\n                \"unitId\": 101,\n                \"skills\": [\n                    [1013011, 1],\n                    [1006, 1],\n                    [1005, 1]\n                ],\n                \"order\": 5,\n                \"cardId\": 101301\n            }]\n        ],\n        [\n            [{\n                \"order\": 1,\n                \"wave\": 1,\n                \"unitId\": 112001,\n                \"attributes\": [],\n                \"skills\": [\n                    [211210001, 1],\n                    [211210002, 1],\n                    [211310003, 1],\n                    [211310003, 1]\n                ],\n                \"level\": 1\n            }, {\n                \"order\": 2,\n                \"wave\": 1,\n                \"unitId\": 112001,\n                \"attributes\": [],\n                \"skills\": [\n                    [211210001, 1],\n                    [211210002, 1],\n                    [211310003, 1],\n                    [211310003, 1]\n                ],\n                \"level\": 1\n            }, {\n                \"order\": 3,\n                \"wave\": 1,\n                \"unitId\": 113001,\n                \"attributes\": [],\n                \"skills\": [\n                    [211310001, 1],\n                    [211310002, 1],\n                    [211310003, 1],\n                    [211310003, 1]\n                ],\n                \"level\": 1\n            }],\n            [{\n                \"order\": 1,\n                \"wave\": 2,\n                \"unitId\": 113001,\n                \"attributes\": [],\n                \"skills\": [\n                    [211310001, 1],\n                    [211310002, 1],\n                    [211310003, 1],\n                    [211310003, 1]\n                ],\n                \"level\": 1\n            }, {\n                \"order\": 2,\n                \"wave\": 2,\n                \"unitId\": 113001,\n                \"attributes\": [],\n                \"skills\": [\n                    [211310001, 1],\n                    [211310002, 1],\n                    [211310003, 1],\n                    [211310003, 1]\n                ],\n                \"level\": 1\n            }, {\n                \"order\": 3,\n                \"wave\": 2,\n                \"unitId\": 114001,\n                \"attributes\": [],\n                \"skills\": [\n                    [211410001, 1],\n                    [211410002, 1],\n                    [211310003, 1],\n                    [211310003, 1]\n                ],\n                \"level\": 1\n            }],\n            [{\n                \"order\": 1,\n                \"wave\": 3,\n                \"unitId\": 114001,\n                \"attributes\": [],\n                \"skills\": [\n                    [211410001, 1],\n                    [211410002, 1],\n                    [211310003, 1],\n                    [211310003, 1]\n                ],\n                \"level\": 1\n            }, {\n                \"order\": 2,\n                \"wave\": 3,\n                \"unitId\": 115001,\n                \"attributes\": [],\n                \"skills\": [\n                    [211510001, 1],\n                    [211510002, 1],\n                    [211310003, 1],\n                    [211310003, 1]\n                ],\n                \"level\": 1\n            }, {\n                \"order\": 3,\n                \"wave\": 3,\n                \"unitId\": 116001,\n                \"attributes\": [],\n                \"skills\": [\n                    [211610001, 1],\n                    [211610002, 1],\n                    [211310003, 1],\n                    [211310003, 1]\n                ],\n                \"level\": 1\n            }]\n        ]\n    ],\n    \"fightMode\": 1,\n    \"playMode\": 1,\n    \"stageId\": 110101,\n    \"boutId\": 110101\n}"

json = require("GameLogic/Util/json4lua")

require("GameLogic/Fight/GameLogic")

local function FileRead(path)
	local jsonStr = aa
	local luaTable = json.decode(jsonStr)

	return luaTable
end

local function PrintEnabled()
	GameRunTime.print_enable = true
	GameLogic.print_enable = true
	Unit.print_enable = false
	GameRecord.print_enable = true
end

local m = {}

function m:Main()
	math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))

	local game = GameLogic("game_1")
	local gameStartData = FileRead("GameLogic/Jsons/game_start_data_02.json")

	game:SetGameStartData(gameStartData)

	local gameBaseData = New(GameBaseData)

	gameBaseData.Character = require("luaData/CharacterRole")
	gameBaseData.CharacterCard = require("luaData/CharacterCard")
	gameBaseData.Monster = require("luaData/Monster")
	gameBaseData.AllSkills = require("luaData/AllSkills")
	gameBaseData.BattleSkillData = require("luaData/BattleSkillData")
	gameBaseData.BattleBuffData = require("luaData/BattleBuffData")

	game:SetGameBaseData(gameBaseData)

	local jobData = require("luaData/JobCheckingData")

	JobCheckingHelp.Init(jobData)
	PrintEnabled()

	game.TestMode = true
	game.RunTime.AutoOpetator = true

	game:Start()
end

return m
