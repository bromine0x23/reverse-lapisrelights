-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/DataBuilder/Util/TestData.lua

TestData = TestData or {}
TestData.game = {
	stageId = 10002,
	boutId = 10002,
	randomSeed = 101,
	whipMaxNum = 0,
	pvp = 0,
	randomSeedForReward = 101
}

local clothes = {
	[101] = {
		1010204,
		1010202,
		1010103,
		1010101
	},
	[102] = {
		1020204,
		1020202,
		1020103,
		1020101
	},
	[103] = {
		1030204,
		1030202,
		1030103,
		1030101
	},
	[104] = {
		1040202,
		1040103,
		1040101,
		1040004
	},
	[105] = {
		1050101,
		1050103,
		1050202,
		1050204
	}
}
local weaponAvatar = {
	[101] = 10101,
	[102] = 10201,
	[104] = 10401,
	[103] = 10301,
	[105] = 10501
}
local slot = {
	{
		scroll = 911,
		quality = 1,
		slot = 1,
		grade = 0,
		level = 1
	},
	{
		scroll = 911,
		quality = 1,
		slot = 2,
		grade = 0,
		level = 1
	},
	{
		scroll = 911,
		quality = 1,
		slot = 3,
		grade = 0,
		level = 1
	},
	{
		scroll = 0,
		quality = 1,
		slot = 4,
		grade = 0,
		level = 1
	},
	{
		scroll = 0,
		quality = 1,
		slot = 5,
		grade = 0,
		level = 1
	},
	{
		scroll = 0,
		quality = 1,
		slot = 6,
		grade = 0,
		level = 1
	}
}

function BuildPlayer()
	local pb = {}

	pb.playerId = 625530
	pb.nickname = ""
	pb.levelExp = 0

	return pb
end

function BuildRole(id)
	local pb = {}

	pb.id = id
	pb.playerId = 625530
	pb.clothes = clothes[id]
	pb.weaponAvatar = weaponAvatar[id]
	pb.avatars = {
		weaponAvatar[id]
	}
	pb.slots = slot
	pb.nodeSkills = {
		101001
	}

	return pb
end

function BuildCard(id)
	local pb = {}

	pb.id = id
	pb.playerId = 625530
	pb.levelExp = 5
	pb.starLevel = 0
	pb.petal = 0
	pb.clubBlood = 1
	pb.clubBossBlood = 1

	return pb
end

function TestData:GetData()
	local data = {
		stageId = self.game.stageId,
		boutId = self.game.boutId,
		pvp = self.game.pvp or 0,
		randomSeed = self.game.randomSeed,
		randomSeedForReward = self.game.randomSeedForReward,
		whipMaxNum = self.game.whipNum or 0,
		player1 = {
			pbPlayers = {
				BuildPlayer(),
				BuildPlayer()
			},
			slot = {
				{
					playerIdx = 1,
					pbRole = BuildRole(101),
					pbCard = BuildCard(101001),
					pbSupCard = BuildCard(105001)
				},
				{
					playerIdx = 1,
					pbRole = BuildRole(102),
					pbCard = BuildCard(102001),
					pbSupCard = BuildCard(104001)
				},
				{
					playerIdx = 1,
					pbRole = BuildRole(103),
					pbCard = BuildCard(103001),
					pbSupCard = BuildCard(102001)
				},
				{
					playerIdx = 1,
					pbRole = BuildRole(104),
					pbCard = BuildCard(104001),
					pbSupCard = BuildCard(103001)
				},
				{
					playerIdx = 2,
					pbRole = BuildRole(105),
					pbCard = BuildCard(105001),
					pbSupCard = BuildCard(101001)
				}
			},
			pbTeamFetter = {
				id = 1,
				skills = {
					{
						id = 500010001,
						level = 1
					}
				}
			}
		},
		player2 = {
			pbPlayers = {
				BuildPlayer(),
				BuildPlayer()
			},
			slot = {
				{
					playerIdx = 1,
					pbRole = BuildRole(101),
					pbCard = BuildCard(101001),
					pbSupCard = BuildCard(105001)
				},
				{
					playerIdx = 1,
					pbRole = BuildRole(102),
					pbCard = BuildCard(102001),
					pbSupCard = BuildCard(104001)
				},
				{
					playerIdx = 1,
					pbRole = BuildRole(103),
					pbCard = BuildCard(103001),
					pbSupCard = BuildCard(102001)
				},
				{
					playerIdx = 1,
					pbRole = BuildRole(104),
					pbCard = BuildCard(104001),
					pbSupCard = BuildCard(103001)
				},
				{
					playerIdx = 2,
					pbRole = BuildRole(105),
					pbCard = BuildCard(105001),
					pbSupCard = BuildCard(101001)
				}
			},
			pbTeamFetter = {
				id = 1,
				skills = {
					{
						id = 500010001,
						level = 1
					}
				}
			}
		}
	}

	return data
end

local fakerOperator = "    [{\"Type\":1,\"CardIds\":[102001104,103001101,104001104]},{\"Type\":2,\"OperatorData\":[1,2,5,3],\"Target\":\"21\"},{\"Type\":2,\"OperatorData\":[1,2,5,3],\"Target\":\"21\"},{\"Type\":2,\"OperatorData\":[1,2,3,5],\"Target\":\"21\"},{\"Type\":2,\"OperatorData\":[1,4,5,2],\"Target\":\"21\"},{\"Type\":2,\"OperatorData\":[1,2,4,3],\"Target\":\"21\"},{\"Type\":2,\"OperatorData\":[3,4,5,1],\"Target\":\"21\"}]\n"

require("DataBuilder/BuilderMgr")

local data = TestData:GetData()
local gameData = BuilderMgr:BuildGameData(data)

function TestData.TestRun()
	local game = require("GameLogic/RunGame")
end

function TestData.TestRunnn()
	local json = require("GameLogic.Util.json4lua")

	gameData.operators = json.decode(fakerOperator)

	local game = require("GameLogic/RunGame")

	game:ServerRun(gameData)
end

return TestData
