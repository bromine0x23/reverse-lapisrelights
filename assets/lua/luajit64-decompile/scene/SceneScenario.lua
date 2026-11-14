-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Scene/SceneScenario.lua

require("Scene/SceneBase")
require("Util/Util")
require("Scenario/ScenarioKitLua")
require("UI/Dlg/Common/DlgGetAward")
require("UI/Page/PageLogin/PageGenName")

local actorData = require("luaData/ActorData")
local StoryAward = require("luaData/StoryAward")
local characters = require("luaData/CharacterRole")
local endstage = false

SceneScenario = class("SceneScenario", SceneBase, true)

function SceneScenario:OnCache()
	SceneMgr.autoHideLoading = true

	print("-----------加载剧本-----------", self.InputParam.stageId, self.StoryPrefabPath)
	ResourceMgr.SubmitCache(self.StoryPrefabPath, self, "SceneStoryPrefab")
end

function SceneScenario.OnShare()
	require("UI/Dlg/Public/DlgShare")

	local btnShare = GOUtil.FindChildComponent(ScenarioKit.Instance.UI.gameObject, "MainCanvas/Controlls/BtnShare", "Image")
	local mainCamera = GameObject.Find("Main Camera")
	local camera = GOUtil.GetComponent(mainCamera, "Camera")
	local go = GameObject.Find("ClickEffectMountNode")

	if not IsNil(go) then
		go:SetActive(false)
	end

	SetActiveFunc(btnShare, false)

	local function cb()
		SetActiveFunc(btnShare, true)

		if not IsNil(go) then
			go:SetActive(true)
		end
	end

	Event.Instance:Fire("CloseDlgShare")
	MiscUtil.CaptureRenderTexture(function(t2d)
		UIMgr.AddPanel(DlgShare(), {
			texture = t2d,
			callback = cb
		})
	end)
end

function SceneScenario:OnCreate()
	print("-----------加载剧本----------- self.SceneStoryPrefab", self.SceneStoryPrefab)

	SceneScenario.endstage = false
	self.goprefab = GOUtil.InstantiatePrefab(self.SceneStoryPrefab, nil)

	local rootObject = GameObject.Find("MainCanvas")

	if rootObject then
		local transHistory = rootObject.transform:Find("History")

		if transHistory then
			transHistory.gameObject:SetActive(true)

			local go = GameObject.Find("Text (1)")

			if go then
				local text = GOUtil.GetComponent(go, "Text")

				text.text = _("Desc_Review")
			end

			transHistory.gameObject:SetActive(false)
		end

		local Autotext = GOUtil.FindChildComponent(rootObject, "Controlls/BtnPause/Image/Text", "Text")

		Autotext.text = _("Story_Auto")

		if SceneScenario.forceExit then
			local gControl = rootObject.transform:Find("Controlls").gameObject

			gControl:SetActive(false)
		end

		local Endtext = GOUtil.FindChildComponent(rootObject, "Ending/root/Back/Text", "Text")

		Endtext.text = _("Common_Click_Continue")
	end
end

function SceneScenario.CreateInstance()
	if not SceneScenario.Instance then
		SceneScenario.Instance = SceneScenario()
	end

	return SceneScenario.Instance
end

function SceneScenario.DestroyInstance()
	SceneScenario.Instance = nil
end

function SceneScenario.ShowPageGenName()
	if InfoGameInst.gameInfo.changeNameNum < 1 then
		local tg_auto = GOUtil.FindChildComponent(ScenarioKit.Instance.UI.gameObject, "MainCanvas/DlgStoryDialog/Panel/BgTalk/Controls/ToggleAuto", "Toggle")
		local preAuto = tg_auto.isOn

		tg_auto.isOn = false

		local function wrap_cb()
			tg_auto.isOn = preAuto
		end

		UIMgr.AddPanel(PageGenName(), wrap_cb)

		local g = GOUtil.FindChildGameObject(ScenarioKit.Instance.UI.gameObject, "MainCanvas/DlgStoryDialog/")

		g:SetActive(false)
	end
end

function SceneScenario:ShowLoading()
	LoadingMgr.Show(eLoadingType.Repeat)
end

function SceneScenario:HideLoading()
	LoadingMgr.Hide(eLoadingType.Repeat)
end

function SceneScenearioReturnScene()
	if SceneScenario.InputParam.onExit then
		SceneScenario.InputParam.onExit()

		return
	end

	local StageId = SceneScenario.InputParam.stageId

	SceneMgr.LoadScene("MainStage", {
		from = 4,
		stageId = StageId
	})
end

function SceneScenario:RequestEnd()
	if self.InputParam.onExit ~= nil then
		SceneScenearioReturnScene()
	else
		local function wrap_cb(vPBMessage)
			self.endstage = true

			self:OnHandleEndStage(vPBMessage)
		end

		if self.endstage == false then
			NetManager:RequestEndStage(self.InputParam.boutId, true, {}, "", 180, 0, {}, {}, {}, self.InputParam.chaos, wrap_cb)
		end

		LoadingMgr.Show(eLoadingType.Repeat)
	end
end

function SceneScenario:OnHandleEndStage(vPBMessage)
	LoadingMgr.Hide(eLoadingType.Repeat)
	print(vPBMessage.result.code)

	if vPBMessage.result.code == NetManager.Result_Sucess then
		local setter = SetterData.GetSetterData(vPBMessage.setter)

		setter:Parse()

		local listFirst = setter:Getlist(protocol_pb.AF_STAGE_FIRST)

		if #listFirst > 0 then
			local function comfirm_cb()
				if SetterData.showLevelup then
					local function cb()
						if TutorialMgr:IsNeedSwitchMainStage(2) then
							SceneMgr.LoadScene("MainStage")
						else
							SceneScenearioReturnScene()
						end
					end

					local data = {
						callback = cb
					}

					UIMgr.AddPanel(DlgProducerLevelUp(), data)
				elseif TutorialMgr:IsNeedSwitchMainStage(2) then
					SceneMgr.LoadScene("MainStage")
				else
					SceneScenearioReturnScene()
				end
			end

			local listcall = {}

			listcall.list = listFirst
			listcall.listValue = #listFirst
			listcall.callback = comfirm_cb

			UIMgr.AddPanel(DlgGetAward(), listcall)
		else
			SceneScenearioReturnScene()
		end

		if self.InputParam and self.InputParam.stageId then
			NetManager:RecordPlayStory(self.InputParam.stageId)
		end
	elseif vPBMessage.result.code == 4 then
		ReloadGameData(function()
			SceneScenearioReturnScene()
		end)
	else
		UIMgr.ShowMsg(vPBMessage.result.desc, vPBMessage)
	end
end

function SceneScenario:OnBeging()
	if PlayerInst ~= nil then
		local savedName = PlayerPrefs.GetString("SceneScenario.savedName", self.GetUserName())

		if savedName ~= self.GetUserName() then
			PlayerPrefs.SetInt("SceneScenario.Auto", 0)
		end
	end

	if PlayerPrefs.GetInt("SceneScenario.Auto", 0) == 1 then
		local tg_auto = GOUtil.FindChildComponent(ScenarioKit.Instance.UI.gameObject, "MainCanvas/DlgStoryDialog/Panel/BgTalk/Controls/ToggleAuto", "Toggle")

		tg_auto.isOn = true
	end
end

function SceneScenario:ToggleAuto(ison)
	if ison then
		PlayerPrefs.SetInt("SceneScenario.Auto", 1)
	else
		PlayerPrefs.SetInt("SceneScenario.Auto", 0)
	end

	PlayerPrefs.SetString("SceneScenario.savedName", self.GetUserName())
end

function SceneScenario:OnSelectOption(param)
	print("服务端领奖")
	SoundMgr.Play(PATH_SFX_UI_PROMPT)

	if param.PrizeId ~= nil and param.PrizeId ~= "" and not InfoGameInst:IsGetScenarioReward(param.DialogId) and NetManager ~= nil then
		local function callback(vPBMessage)
			LoadingMgr.Hide(eLoadingType.Repeat)
			print("code" .. vPBMessage.result.code)

			if vPBMessage.result.code == NetManager.Result_Sucess then
				local award = StoryAward[tonumber(param.PrizeId)]
				local has506 = false

				if award ~= nil then
					for i = 1, #award.AwardList do
						local item = award.AwardList[i]
						local itemid = item[1]
						local itemCount = item[2]

						if itemid == 506 then
							local charactorID = item[3]

							print(charactorID)

							local headImg = GOUtil.FindChildComponent(ScenarioKit.Instance.UI.gameObject, "MainCanvas/friendHit/HeadMask/Head", "Image")

							UIUtil.SetImageSprite(headImg, actorData[characters[charactorID].ActorID].CharacterIcon, nil, false)

							local numberTxt = GOUtil.FindChildComponent(ScenarioKit.Instance.UI.gameObject, "MainCanvas/friendHit/Number", "Text")

							if itemCount >= 0 then
								numberTxt.text = "+" .. itemCount
							else
								numberTxt.text = "-" .. itemCount
							end

							local titleText = GOUtil.FindChildComponent(ScenarioKit.Instance.UI.gameObject, "MainCanvas/friendHit/Text", "Text")

							titleText.text = _("Friendliness")

							local anim = GOUtil.FindChildComponent(ScenarioKit.Instance.UI.gameObject, "MainCanvas/friendHit", "Animator")

							anim:SetTrigger("Show")

							has506 = true

							break
						end
					end
				end

				if has506 == true and #award.AwardList == 1 then
					-- block empty
				else
					require("UI/Dlg/Common/DlgStoryAward")
					UIMgr.AddPanel(DlgStoryAward(), {
						setter = vPBMessage.setter
					})
				end
			end
		end

		NetManager:RequestAnswerReward(param.DialogId, tonumber(param.PrizeId), callback)
		LoadingMgr.Show(eLoadingType.Repeat)
	end
end

function SceneScenario:GetUserName(...)
	return PlayerInst.InfoPlayer.name
end

function SceneScenario:Exit()
	Time.timeScale = 0

	UIMgr.ShowCommon(DlgCommonEvent.Type.Confirm, "", _("Quite_Title"), function(index)
		Time.timeScale = 1

		if index == 1 then
			SceneScenearioReturnScene()
			NetManager:RecordPlayStory(StageId)
		end
	end, _("SceneScenario_OK"), _("UI_Cancel"))
end

function SceneScenario:ToEnd(param)
	local StageId = SceneScenario.InputParam.stageId
	local isGet = true

	if ChapterMgr.StoryAwardList[StageId] then
		for i, v in ipairs(ChapterMgr.StoryAwardList[StageId]) do
			if not InfoGameInst:IsGetScenarioReward(v.GroupId) then
				isGet = false

				break
			end
		end
	end

	local data = {}

	if isGet then
		data.msg = param.summary
		data.needTip = false
	else
		data.msg = param.summary .. "\n  "
		data.needTip = true
	end

	UIMgr.ShowCommon(DlgCommonEvent.Type.MsgStory, _("Scenario_Sum_Title"), data, function(index)
		if index == 1 then
			if InfoGameInst.gameInfo.changeNameNum < 1 and SceneScenario.InputParam.stageId == 10003 then
				local function wrap_cb()
					ScenarioKit.Instance.UI.controlls:ToEnd()
				end

				UIMgr.AddPanel(PageGenName(), wrap_cb)
			else
				ScenarioKit.Instance.UI.controlls:ToEnd()
			end
		end
	end, _("Desc_MakeSure"))
end

function SceneScenario:Lua_UpdateHistoryLine(line, data)
	local AvatorBorder = line.avator.transform.parent.parent:Find("Avator")
	local AvatorBorderImage = GOUtil.FindChildComponent(line.gameObject, "AvatorBox", "Image")
	local backImage = GOUtil.FindChildComponent(line.gameObject, "Back", "Image")
	local gChapter = GOUtil.FindChildGameObject(line.gameObject, "Chapter")
	local gBg = GOUtil.FindChildGameObject(line.gameObject, "Image (1)")
	local gName = GOUtil.FindChildGameObject(line.gameObject, "Name")
	local gTxt = GOUtil.FindChildGameObject(line.gameObject, "Txt")

	if data.actorId == -1 and data.actorName == "" and data.Txt == "" then
		backImage.color = Color(1, 1, 1, 1)

		AvatorBorder.gameObject:SetActive(false)
		AvatorBorderImage.gameObject:SetActive(false)
		line.avator.gameObject:SetActive(false)
		gChapter:SetActive(true)
		gBg:SetActive(false)
		gName:SetActive(false)
		gTxt:SetActive(false)

		local chapter = ScenarioKit.Instance.UI.Chapter
		local cName = GOUtil.FindChildComponent(line.gameObject, "Chapter/Title", "Text")

		cName.text = chapter.ChapterTitle.text

		local n1t = GOUtil.FindChildComponent(line.gameObject, "Chapter/Number0/t", "Image")
		local n1s = GOUtil.FindChildComponent(line.gameObject, "Chapter/Number0/s", "Image")
		local n2t = GOUtil.FindChildComponent(line.gameObject, "Chapter/Number1/t", "Image")
		local n2s = GOUtil.FindChildComponent(line.gameObject, "Chapter/Number1/s", "Image")
		local number0 = chapter.number0
		local number1 = chapter.number1

		if number0 < 10 then
			n1t.gameObject:SetActive(false)
		end

		local t = number0 / 10
		local s = number0 % 10

		if number0 == 0 then
			local n1 = GOUtil.FindChildComponent(line.gameObject, "Chapter/Number0", "Image")

			n1.enabled = true

			n1s.gameObject:SetActive(false)
		else
			local n1 = GOUtil.FindChildComponent(line.gameObject, "Chapter/Number0", "Image")

			n1.enabled = false

			n1s.gameObject:SetActive(true)
			GOUtil.SetImageOverrideSprite(n1t, chapter.numbers:get_Item(t))
			GOUtil.SetImageOverrideSprite(n1s, chapter.numbers:get_Item(s))
		end

		if number1 < 10 then
			n2t.gameObject:SetActive(false)
		end

		t = number1 / 10
		s = number1 % 10

		GOUtil.SetImageOverrideSprite(n2t, chapter.numbers:get_Item(t))
		GOUtil.SetImageOverrideSprite(n2s, chapter.numbers:get_Item(s))

		return
	end

	AvatorBorder.gameObject:SetActive(true)
	line.avator.gameObject:SetActive(true)
	gChapter:SetActive(false)
	gBg:SetActive(true)
	gName:SetActive(true)
	gTxt:SetActive(true)

	local actor = actorData[data.actorId]

	if actor ~= nil then
		AvatorBorder.gameObject:SetActive(true)
		AvatorBorderImage.gameObject:SetActive(false)

		backImage.color = Color(1, 1, 1, 1)

		UIUtil.SetImageSprite(line.avator, actor.CharacterIcon, nil, true)
		UIUtil.SetImageSprite(AvatorBorderImage, "UI/PageStory/AtlasScenario/IC_BG_head_01", nil, false)
	else
		AvatorBorder.gameObject:SetActive(false)
		AvatorBorderImage.gameObject:SetActive(true)

		backImage.color = Color(0.85, 0.92, 0.93, 1)

		local infoItem = ItemManager:Get(PlayerInst.InfoPlayer.headId)

		UIUtil.SetImageSprite(line.avator, infoItem:GetIcon(), nil, true)

		local infoItem = ItemManager:Get(PlayerInst.InfoPlayer.headFrame)

		UIUtil.SetImageSprite(AvatorBorderImage, infoItem:GetIcon(), nil, false)
	end

	if not string.isNullOrEmpty(data.strIcon) then
		UIUtil.SetImageSprite(line.avator, data.strIcon, nil, true)
	end

	local nameTxt = GOUtil.FindChildComponent(line.gameObject, "Name", "Text")

	nameTxt.text = ScenarioKit.Instance.Language:Get(data.actorName)

	local txtTxt = GOUtil.FindChildComponent(line.gameObject, "Txt", "TextView")

	txtTxt.Text = ScenarioKit.Instance.Language:Get(data.Txt)
end

function SceneScenario:EndScenario()
	self:RequestEnd()
end

function SceneScenario:ShowEnding(param)
	local endingObj = GOUtil.FindChildGameObject(ScenarioKit.Instance.UI.gameObject, "MainCanvas/Ending/root")

	GOUtil.SetActive(endingObj, true)
end

function SceneScenario:OnInit(vParam)
	SceneScenario.StoryPrefabPath = vParam.StoryPrefabPath
	SceneScenario.InputParam = vParam
	SceneScenario.InputParam.index = 1
	SceneScenario.forceExit = vParam.forceExit
end

function SceneScenario:OnRegisterEvent()
	return
end

function SceneScenario:OnUpdate()
	return
end

function SceneScenario:OnUnRegisterEvent()
	Event.Instance:Fire("CloseDlgShare")
end

function SceneScenario:OnDestroy()
	Object.Destroy(self.goprefab)
end

function SceneScenario:OnPurge()
	print("卸载剧本资源", self.SceneStoryPrefab)
	ResourceMgr.Unload(self.SceneStoryPrefab)

	self.SceneStoryPrefab = nil
end

function SceneScenario:OnEnd()
	return
end

return SceneScenario
