-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageSkillViewer/Dlg/DlgViewerMenu.lua

DlgViewerMenu = class("DlgViewerMenu", UIPanel)

function DlgViewerMenu:ctor()
	DlgViewerMenu.base.ctor(self, "UI/PageSkillViewer/Dlg/DlgViewerMenu")
end

function DlgViewerMenu:Cache()
	DlgViewerMenu.base.Cache(self)
end

function DlgViewerMenu:Close()
	DlgViewerMenu.base.Close(self)
end

function DlgViewerMenu:OnEnter()
	self.input_field = self:GetChildComponent("panel/buttons/input_field", "InputField")
	self.btn_player = self:GetChildComponent("panel/buttons/btn_player", "Button")
	self.btn_monster = self:GetChildComponent("panel/buttons/btn_monster", "Button")
	self.btn_skill = self:GetChildComponent("panel/buttons/btn_skill", "Button")
	self.btn_camera = self:GetChildComponent("panel/buttons/btn_camera", "Button")
	self.btn_anim = self:GetChildComponent("panel/buttons/btn_anim", "Button")
	self.btn_vocal = self:GetChildComponent("panel/buttons/btn_vocal", "Button")
	self.btn_timeLine = self:GetChildComponent("panel/buttons/btn_timeLine", "Button")
	self.btn_actorCheck = self:GetChildComponent("panel/buttons/btn_actorCheck", "Button")
	self.btn_simulateFight = self:GetChildComponent("panel/buttons/btn_simulateFight", "Button")
	self.btn_effect = self:GetChildComponent("panel/buttons/btn_effect", "Button")
end

function DlgViewerMenu:Purge()
	DlgViewerMenu.base.Purge(self)
end

function DlgViewerMenu:OnRegisterEvent()
	self:AddClick(self.btn_player.gameObject, self.OnBtnPlayer)
	self:AddClick(self.btn_monster.gameObject, self.OnBtnMonster)
	self:AddClick(self.btn_skill.gameObject, self.OnBtnSkill)
	self:AddClick(self.btn_camera.gameObject, self.OnBtnCamera)
	self:AddClick(self.btn_anim.gameObject, self.OnBtnAnim)
	self:AddClick(self.btn_vocal.gameObject, self.OnBtnVocal)
	self:AddClick(self.btn_timeLine.gameObject, self.OnBtnTimeLine)
	self:AddClick(self.btn_actorCheck.gameObject, self.OnBtnActorCheck)
	self:AddClick(self.btn_simulateFight.gameObject, self.OnBtnSimulateFight)
	self:AddClick(self.btn_effect.gameObject, self.OnBtnEffectId)
end

function DlgViewerMenu:OnUnRegisterEvent()
	self:RemoveClick(self.btn_player.gameObject, self.OnBtnPlayer)
	self:RemoveClick(self.btn_monster.gameObject, self.OnBtnMonster)
	self:RemoveClick(self.btn_skill.gameObject, self.OnBtnSkill)
	self:RemoveClick(self.btn_camera.gameObject, self.OnBtnCamera)
	self:RemoveClick(self.btn_anim.gameObject, self.OnBtnAnim)
	self:RemoveClick(self.btn_vocal.gameObject, self.OnBtnVocal)
	self:RemoveClick(self.btn_timeLine.gameObject, self.OnBtnTimeLine)
	self:RemoveClick(self.btn_actorCheck.gameObject, self.OnBtnActorCheck)
	self:RemoveClick(self.btn_simulateFight.gameObject, self.OnBtnSimulateFight)
	self:RemoveClick(self.btn_effect.gameObject, self.OnBtnEffectId)
end

function DlgViewerMenu:Open()
	return
end

local CharacterCardData = require("luaData/CharacterCard")

function DlgViewerMenu:OnBtnPlayer()
	if self.input_field.text ~= "" then
		local cardId = tonumber(self.input_field.text)

		if CharacterCardData[cardId] then
			SV:ReadyModel(cardId)

			self.input_field.text = ""

			return
		end
	end

	SV.UI:OpenDlg("DlgPickModel")

	self.input_field.text = ""
end

local Monster = require("luaData/Monster")

function DlgViewerMenu:OnBtnMonster()
	if self.input_field.text ~= "" then
		local unitId = tonumber(self.input_field.text)

		if Monster[unitId] then
			SV:ReadyMonster(unitId)

			self.input_field.text = ""

			return
		end
	end

	SV.UI:OpenDlg("DlgPickMonster")

	self.input_field.text = ""
end

function DlgViewerMenu:OnBtnSkill()
	SV.UI:OpenDlg("DlgNpcSkill")
end

function DlgViewerMenu:OnBtnCamera()
	SceneMgr.GetCurrentScene():OnSwitchCamera()
end

function DlgViewerMenu:OnBtnAnim()
	SV.UI:OpenDlg("DlgNpcAnim")
end

function DlgViewerMenu:OnBtnVocal()
	require("Info.gvg.InfoGvg")
	Infogvg.cmd:OfflineMode()
end

local TimelineData = require("luaData/TimelineData")

function DlgViewerMenu:OnBtnTimeLine()
	if self.input_field.text ~= "" then
		local id = tonumber(self.input_field.text)

		if SV.Npc == nil then
			return
		end

		SV.Npc:PlayTimeLine(id)
	end
end

function DlgViewerMenu:OnBtnActorCheck()
	self.CheckObjLists = {}

	local slotKeys = {
		"HeadHit",
		"HeadPoint",
		"MeleeHit",
		"RangeHit",
		"CenterPoint",
		"ChestPoint",
		"LeftHandPoint",
		"RightHandPoint",
		"RightHandFingerPoint",
		"LeftGunPoint",
		"RightGunPoint",
		"SkillStart01",
		"SkillStart02",
		"BossLiveHit"
	}
	local actorId

	if self.input_field.text ~= "" then
		actorId = tonumber(self.input_field.text)
	end

	local str = ""
	local _ActorData = require("luaData/ActorData")

	local function check_fun(actorId, data)
		local obj = ResourceMgr.LoadSync(data.SkeletonPrefab)

		if obj then
			local go = GOUtil.InstantiatePrefab(obj, nil)

			table.insert(self.CheckObjLists, go)

			for _, key in ipairs(slotKeys) do
				local slot = data[key]

				if slot ~= "" then
					local bone = go.transform:Find(slot)

					if not bone then
						print("ActorData表：" .. actorId .. " " .. key .. "対応する骨格が見つかりません")

						str = str .. "ActorData表：" .. actorId .. " " .. key .. "対応する骨格が見つかりません\n"
					end
				end
			end
		else
			print("ActorData表：" .. actorId .. " prefab存在しません、path：" .. data.SkeletonPrefab)

			str = str .. "ActorData表：" .. actorId .. " prefab存在しません、path：" .. data.SkeletonPrefab .. "\n"
		end
	end

	if actorId == nil then
		for actorId, data in pairs(_ActorData) do
			check_fun(actorId, data)
		end
	elseif _ActorData[actorId] then
		check_fun(actorId, _ActorData[actorId])
	end
end

function DlgViewerMenu:OnBtnSimulateFight()
	local game = require("GameLogic/RunGame")

	if self.input_field.text ~= "" then
		local json = require("GameLogic/Util/json4lua")

		game:RunByJson(self.input_field.text)
	else
		local jsonStr = PlayerPrefs.GetString("LastFightData", "")

		game:RunByJson(jsonStr)
	end
end

function DlgViewerMenu:OnBtnEffectId()
	if self.lastEffId then
		EffectMgr:Free(self.lastEffId)
	end

	if self.input_field.text == "" then
		return
	end

	local str = self.input_field.text

	str = string.gsub(str, " ", "")

	local args = {}

	if type(str) == "string" then
		args = str:split(",")
	end

	local argList = {}

	for i, arg in ipairs(args) do
		local numberArg = tonumber(arg)

		if numberArg then
			arg = numberArg
		end

		table.insert(argList, arg)
	end

	if #argList == 1 then
		self.lastEffId = EffectMgr:AllocAtById(argList[1], Vector3(0, 0, -2))
	elseif #argList == 2 then
		self.lastEffId = EffectMgr:AllocAtById(argList[1], Vector3(0, 0, -2), nil, argList[2])
	end
end
