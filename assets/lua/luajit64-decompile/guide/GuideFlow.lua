-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Guide/GuideFlow.lua

GuideFlow = {}

function GuideFlow.Start()
	local function goBattle()
		local vParam = {}

		vParam.stageId = GetConfigArgInt("GuideFlow.StageID")
		vParam.boutId = -1

		local listRoleId = GetConfigArgJson("GuideFlow.ListRoleID")
		local listRoleCardId = GetConfigArgJson("GuideFlow.ListRoleCardID")
		local listAvatarID = GetConfigArgJson("GuideFlow.ListAvatarID")
		local listRole = {}
		local listRoleCard = {}
		local listAddRoleCard = {}
		local defaultClothes = {}

		for i = 1, 5 do
			local infoRole = RoleMgr:GetRole(listRoleId[i])

			table.insert(defaultClothes, infoRole.pb.clothes)

			infoRole.pb.clothes = listAvatarID[i]

			table.insert(listRole, infoRole)

			local card = RoleCardMgr:GetRoleCard(listRoleCardId[i])

			card.id = listRoleCardId[i]

			table.insert(listRoleCard, card)
		end

		vParam.player1 = {
			listRole,
			listRoleCard,
			listAddRoleCard
		}
		vParam.unionSkills = {}

		local guideSkills = GetConfigArgJson("GuideFlow.SkillList")

		for i, guideSkillid in ipairs(guideSkills) do
			table.insert(vParam.unionSkills, {
				skillLevel = 1,
				skillId = guideSkillid
			})
		end

		function vParam.callBack()
			for i = 1, 5 do
				local infoRole = RoleMgr:GetRole(listRoleId[i])

				infoRole.pb.clothes = defaultClothes[i]
			end
		end

		local game = require("GameLogic/RunGame")

		function vParam.exitCall()
			SceneMgr.LoadScene("Scenario", {
				stageId = 10003,
				BackScene = "",
				forceExit = true,
				StoryPrefabPath = GetConfigArgString("GuideFlow.StoryPrefabPath2"),
				onExit = function()
					InstructionMgr:SetPass(1)

					local infoGuide = InstructionMgr:GetGuide(1)

					infoGuide.isFinished = true

					SceneMgr.LoadScene("MainStage", nil)
				end
			})
		end

		game:Run(vParam)
	end

	if InfoGameInst.gameInfo.changeNameNum >= 1 then
		InstructionMgr:SetPass(1)
		SceneMgr.LoadScene("MainStage", nil)

		return
	end

	if InstructionMgr:IsPassed(1) then
		if InfoGameInst.gameInfo.changeNameNum < 1 then
			SceneMgr.LoadScene("Scenario", {
				stageId = 10003,
				BackScene = "",
				forceExit = true,
				StoryPrefabPath = GetConfigArgString("GuideFlow.StoryPrefabPath2"),
				onExit = function()
					SceneMgr.LoadScene("MainStage", nil)
				end
			})
		else
			SceneMgr.LoadScene("MainStage", nil)
		end
	else
		PlayerPrefs.SetInt("SceneScenario.Auto", 0)
		SceneMgr.LoadScene("Scenario", {
			stageId = 10000,
			BackScene = "",
			forceExit = true,
			StoryPrefabPath = GetConfigArgString("GuideFlow.StoryPrefabPath0"),
			onExit = function()
				SceneMgr.LoadScene("Scenario", {
					stageId = 10001,
					BackScene = "",
					forceExit = true,
					StoryPrefabPath = GetConfigArgString("GuideFlow.StoryPrefabPath"),
					onExit = goBattle
				})
			end
		})
	end
end

function GuideFlow.End()
	PlayerInst.InfoPlayer.newbieProgress = 1

	NetManager:SubmitClientAction(protocol_pb.P130_Request.NEWBIE, {
		tostring(1)
	}, nil)
end
