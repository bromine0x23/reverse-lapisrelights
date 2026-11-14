-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Network/SimulateData.lua

function SimulateResponse(callback, vMsg)
	print("SimulateResponse~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")

	if vMsg then
		print(vMsg)
	end

	if vMsg == PId2Str(11) then
		P11Response(callback)
	elseif vMsg == PId2Str(42) then
		P42Response(callback)
	elseif vMsg == PId2Str(43) then
		P43Response(callback)
	else
		CommonResponse(callback)
	end
end

function PId2Str(pid)
	return "P" .. pid .. "_Request"
end

function CommonResponse(cb)
	local pb = {}

	pb.result = {
		desc = "",
		code = 0
	}

	return cb(pb)
end

function P43Response(cb)
	local pb = {}

	pb.result = {
		desc = "",
		code = 0
	}

	return cb(pb)
end

function P42Response(cb)
	local pb = {}

	pb.result = {
		desc = "",
		code = 0
	}
	pb.boutId = 1

	return cb(pb)
end

function P11Response(cb)
	local pb = {}

	pb.result = {
		desc = "",
		code = 2
	}
	pb.player = {
		headId = 0,
		isOnline = true,
		vipExp = 0,
		liveTicket = 500,
		gold = 998196,
		power = 870,
		regTime = 1553777068845,
		powerAt = 1554364517811,
		payStatus = 0,
		diamond = 5,
		isBuddy = false,
		playerId = 31622,
		nickname = 9101,
		levelExp = 0,
		medal = 1,
		roleCards = {
			0,
			0,
			0,
			0,
			0
		}
	}
	pb.roles = {
		{
			favorExp = 0,
			soulCrystal = 0,
			roleCardId = 101001,
			soulNormal = 0,
			playerId = 31622,
			id = 101,
			favorRankRecord = 1,
			clothes = {
				1010104,
				1010103,
				1010102,
				1010101
			},
			avatars = {
				1010104,
				1010103,
				1010102,
				1010101
			},
			nodes = {}
		},
		{
			favorExp = 0,
			soulCrystal = 0,
			roleCardId = 102001,
			soulNormal = 0,
			playerId = 31622,
			id = 102,
			favorRankRecord = 1,
			clothes = {
				1020103,
				1020102,
				1020101
			},
			avatars = {
				1020103,
				1020102,
				1020101
			},
			nodes = {}
		},
		{
			favorExp = 0,
			soulCrystal = 0,
			roleCardId = 201001,
			soulNormal = 0,
			playerId = 31622,
			id = 201,
			favorRankRecord = 1,
			clothes = {
				2010102,
				2010103,
				2010101
			},
			avatars = {
				2010102,
				2010103,
				2010101
			},
			nodes = {}
		},
		{
			favorExp = 0,
			soulCrystal = 0,
			roleCardId = 202001,
			soulNormal = 0,
			playerId = 31622,
			id = 202,
			favorRankRecord = 1,
			clothes = {
				2020102,
				2020103,
				2020101
			},
			avatars = {
				2020102,
				2020103,
				2020101
			},
			nodes = {}
		},
		{
			favorExp = 0,
			soulCrystal = 0,
			roleCardId = 103001,
			soulNormal = 0,
			playerId = 31622,
			id = 103,
			favorRankRecord = 1,
			clothes = {
				1030103,
				1030102,
				1030101
			},
			avatars = {
				1030103,
				1030102,
				1030101
			},
			nodes = {}
		},
		{
			favorExp = 0,
			soulCrystal = 0,
			roleCardId = 104001,
			soulNormal = 0,
			playerId = 31622,
			id = 104,
			favorRankRecord = 1,
			clothes = {
				1040103,
				1040102,
				1040101
			},
			avatars = {
				1040103,
				1040102,
				1040101
			},
			nodes = {}
		},
		{
			favorExp = 0,
			soulCrystal = 0,
			roleCardId = 203001,
			soulNormal = 0,
			playerId = 31622,
			id = 203,
			favorRankRecord = 1,
			clothes = {
				2030102,
				2030103,
				2030101
			},
			avatars = {
				2030102,
				2030103,
				2030101
			},
			nodes = {}
		},
		{
			favorExp = 0,
			soulCrystal = 0,
			roleCardId = 105001,
			soulNormal = 0,
			playerId = 31622,
			id = 105,
			favorRankRecord = 1,
			clothes = {
				10000104,
				1050101,
				1050102,
				1050103
			},
			avatars = {
				10000104,
				1050101,
				1050102,
				1050103,
				199704
			},
			nodes = {}
		}
	}
	pb.roleCards = {
		{
			starLevel = 1,
			playerId = 31622,
			id = 105001,
			levelExp = 170,
			starTalents = {
				{
					id = 1050013,
					level = 1
				},
				{
					id = 1050011,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 103001,
			levelExp = 170,
			starTalents = {
				{
					id = 1030011,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 105301,
			levelExp = 0,
			starTalents = {
				{
					id = 1053014,
					level = 1
				},
				{
					id = 1053011,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 104301,
			levelExp = 0,
			starTalents = {
				{
					id = 1043011,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 102101,
			levelExp = 0,
			starTalents = {
				{
					id = 1021011,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 105101,
			levelExp = 0,
			starTalents = {
				{
					id = 1051013,
					level = 1
				},
				{
					id = 1051011,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 104001,
			levelExp = 170,
			starTalents = {
				{
					id = 1040011,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 102001,
			levelExp = 170,
			starTalents = {
				{
					id = 1020011,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 103101,
			levelExp = 0,
			starTalents = {
				{
					id = 1031011,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 101001,
			levelExp = 170,
			starTalents = {
				{
					id = 1010011,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 104101,
			levelExp = 0,
			starTalents = {
				{
					id = 1041011,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 202101,
			levelExp = 0,
			starTalents = {
				{
					id = 2021011,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 203001,
			levelExp = 0,
			starTalents = {
				{
					id = 2030011,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 201101,
			levelExp = 0,
			starTalents = {
				{
					id = 2011011,
					level = 1
				},
				{
					id = 2011013,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 202001,
			levelExp = 0,
			starTalents = {
				{
					id = 2020011,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 203101,
			levelExp = 0,
			starTalents = {
				{
					id = 2031011,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 201001,
			levelExp = 0,
			starTalents = {
				{
					id = 2010011,
					level = 1
				},
				{
					id = 2010013,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 101101,
			levelExp = 0,
			starTalents = {
				{
					id = 1011011,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 102301,
			levelExp = 0,
			starTalents = {
				{
					id = 1023011,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 103301,
			levelExp = 0,
			starTalents = {
				{
					id = 1033011,
					level = 1
				}
			}
		},
		{
			starLevel = 1,
			playerId = 31622,
			id = 101301,
			levelExp = 0,
			starTalents = {
				{
					id = 1013011,
					level = 1
				}
			}
		}
	}
	pb.items = {
		{
			id = 641,
			num = 5
		},
		{
			id = 741,
			num = 48
		},
		{
			id = 631,
			num = 5
		},
		{
			id = 621,
			num = 5
		},
		{
			id = 831,
			num = 99
		},
		{
			id = 611,
			num = 5
		},
		{
			id = 821,
			num = 99
		},
		{
			id = 601,
			num = 100005
		},
		{
			id = 811,
			num = 99
		},
		{
			id = 801,
			num = 25
		},
		{
			id = 803,
			num = 100
		}
	}
	pb.gameInfo = {
		touchCnt = 5,
		touchTime = 1554364517794,
		stageResetPlayCountAt = 1554364517798,
		changeNameNum = 0,
		stageResetPlayCount = 0,
		chapters = {
			{
				id = 1,
				awardStatus = {
					0,
					1,
					0
				},
				stages = {
					{
						id = 10101,
						playNum = 0,
						isPass = true,
						stars = {
							1,
							1,
							1
						}
					},
					{
						id = 10102,
						playNum = 0,
						isPass = true,
						stars = {
							1,
							1,
							1
						}
					},
					{
						id = 10103,
						playNum = 0,
						isPass = true,
						stars = {
							1,
							1,
							1
						}
					},
					{
						id = 10104,
						playNum = 0,
						isPass = false,
						stars = {
							0,
							0,
							0
						}
					}
				}
			}
		},
		roleCardTeams = {
			105001,
			102001,
			103001,
			104001,
			101001
		},
		medalList = {
			1,
			2
		}
	}
	pb.equips = {
		{
			equipId = 30201,
			roleId = 0,
			serialId = 4970
		},
		{
			equipId = 30202,
			roleId = 0,
			serialId = 4971
		},
		{
			equipId = 30101,
			roleId = 0,
			serialId = 4933
		}
	}

	ChapterMgr:InitChapterList()
	PlayerInst.InfoPlayer:SetData(pb.player)
	PowerMgr.Instance:SetPowerTime(pb.player.powerAt)

	pb.gameInfo.messages = {}
	pb.gameInfo.voices = {}

	InfoGameInst:SetData(pb.gameInfo)

	for i = 1, #pb.equips do
		-- block empty
	end

	local roleCards = pb.roleCards

	for i = 1, #roleCards do
		local pbRoleCard = roleCards[i]
		local infoRoleCard = RoleCardMgr:GetRoleCard(pbRoleCard.id)

		infoRoleCard:SetData(pbRoleCard)
	end

	local roles = pb.roles

	for i = 1, #roles do
		local pbRole = roles[i]
		local infoRole = RoleMgr:GetRole(pbRole.id)

		infoRole:SetData(pbRole)
	end

	ItemManager:SetData(pb.items)
	cb(pb)
end
