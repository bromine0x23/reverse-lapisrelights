-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Page/PageLogin/PlayerCreate.lua

require("UI/Page/PageLogin/PageCharacterTest")
require("UI/Page/PageLogin/PageTestResult")
require("UI/Page/PageLogin/PageUserNameInput")
require("UI/Page/PageLogin/PageCharCreateConversation")
require("UI/Page/PageLogin/PageTestResultAnimation")
require("UI/Page/PageLogin/PagePlayerSexSelect")

PlayerCreate = class("PlayerCreate")

function PlayerCreate:ctor()
	self.DlgExploreConversation = DlgExploreConversation()
	self.PageCharacterTest = PageCharacterTest(self)
	self.PageTestResult = PageTestResult(self)
	self.PageUserNameInput = PageUserNameInput(self)
	self.PageCharCreateConversation = PageCharCreateConversation()
	self.PageTestResultAnimation = PageTestResultAnimation(self)
	self.PagePlayerSexSelect = PagePlayerSexSelect(self)
	self.GetCharTbl = {}
	self.CreateCharIDContainer = Container()

	self:InitQuestionData()

	self.TouchHeadSucceed = false
	self.noteEnd = false
end

function PlayerCreate:Cache()
	self.PageCharacterTest:Cache()
	MxResMgr.Instance:SubmitCacheLua("BGM/BGM032", self, "BGMAudioClip")
end

function PlayerCreate:Purge()
	self.PageCharacterTest:Purge()

	self.PageCharacterTest = nil

	self.PageTestResult:Purge()

	self.PageTestResult = nil

	self.PageTestResultAnimation:Purge()

	self.PageTestResultAnimation = nil

	self.PageUserNameInput:Purge()

	self.PageUserNameInput = nil

	self.PageCharCreateConversation:Purge()

	self.PageCharCreateConversation = nil

	self.DlgExploreConversation:Purge()

	self.DlgExploreConversation = nil

	self.PagePlayerSexSelect:Purge()

	self.PagePlayerSexSelect = nil
	self.QuestionDataArray = nil
	self.QuestionDataTbl = nil
	self.CreateCharIDContainer = nil
	self.TouchPrompt = nil
	self.BGMAudioClip = nil
end

function PlayerCreate:PurgeOnConcert()
	self.TouchPrompt = nil
	self.GetCharTbl = nil
end

function PlayerCreate:InitQuestionData()
	self.QuestionDataArray = DataManager.Instance:GetAllRecords_Lua("Question")

	local questionCount = self.QuestionDataArray.Length
	local data

	for i = 0, questionCount - 1 do
		data = self.QuestionDataArray[i]

		if not self.CreateCharIDContainer:Contains(data.Character1) then
			self.CreateCharIDContainer:Push(data.Character1)
		end

		if not self.CreateCharIDContainer:Contains(data.Character2) then
			self.CreateCharIDContainer:Push(data.Character2)
		end
	end
end

function PlayerCreate:CacheTestCharacterMotion(motionIdx)
	if self.PageCharacterTest == nil then
		return
	end

	self.PageCharacterTest:CacheCharacterMotion(motionIdx)
end

function PlayerCreate:CalcGetCharacter(answerContainer)
	if answerContainer == nil then
		return
	end

	local answerCount = answerContainer:GetCount()

	self.GetCharTbl = nil
	self.GetCharTbl = {}
	self.QuestionDataTbl = nil
	self.QuestionDataTbl = {}

	for i = 1, answerCount do
		local answer = answerContainer:GetValueByIndex(i)

		self.QuestionDataTbl[i] = {}
		self.QuestionDataTbl[i].data = self.QuestionDataArray[i - 1]
		self.QuestionDataTbl[i].AnswerOption = answer
	end

	local function sortFunc(data1, data2)
		if data1.data.GroupId == data2.data.GroupId then
			return data1.data.ID < data2.data.ID
		end

		return data1.data.GroupId < data2.data.GroupId
	end

	table.sort(self.QuestionDataTbl, sortFunc)

	local char1Point = 0
	local char2Point = 0
	local curGroupID = 1
	local data, preData
	local charID = 0
	local answer = 0

	function FillGetCharList()
		if char1Point >= char2Point then
			charID = preData.Character1
		else
			charID = preData.Character2
		end

		table.insert(self.GetCharTbl, charID)
	end

	for i = 1, answerCount do
		preData = data
		data = self.QuestionDataTbl[i].data

		if curGroupID ~= data.GroupId then
			FillGetCharList()

			curGroupID = data.GroupId
			char1Point = 0
			char2Point = 0
		end

		answer = self.QuestionDataTbl[i].AnswerOption
		char1Point = char1Point + data.CasePoints:get_Item(answer - 1):get_Item(0)
		char2Point = char2Point + data.CasePoints:get_Item(answer - 1):get_Item(1)
	end

	preData = self.QuestionDataTbl[answerCount].data

	FillGetCharList()
end

function PlayerCreate:ShowConversation(param, callback)
	CreateDlgInScene(self.DlgExploreConversation, param)

	self.DlgExploreConversation.OnFinish = callback
end

function PlayerCreate:Init()
	MxAudioMgr.Instance:SetSoundVolume(0.13999999999999999)

	if self.BGMAudioClip ~= nil then
		MxAudioMgr.Instance:PlayMusic(self.BGMAudioClip, true, 0)
	end

	local function conversation2CB()
		SwitchToPage(self.PageCharacterTest)
	end

	local function conversation1CB()
		SwitchToPage(self.PagePlayerSexSelect)

		self.PagePlayerSexSelect.OnDlgClose[self.PagePlayerSexSelect] = function(dlg)
			dlg.OnDlgClose[self.PagePlayerSexSelect] = nil

			SwitchToPage(self.PageCharCreateConversation)
			self:ShowConversation(1002, conversation2CB)
		end
	end

	SwitchToPage(self.PageCharCreateConversation)
	self:ShowConversation(1001, conversation1CB)
end

function PlayerCreate:TryCreateTouchStudent()
	if not PlayerInst.IsNewbie or SceneConcert.Instance == nil then
		return
	end

	SceneConcert.Instance.NotesPlayManagerGO:SetActive(false)

	local cg = GOUtil.GetComponent(SceneConcert.Instance.PageConcert.UIRootObject, "CanvasGroup")

	cg.alpha = 0

	local function showTouchUI()
		local roleId = self.GetCharTbl[Mathf.Random(1, #self.GetCharTbl)]

		CreateDlgInScene(SceneConcert.Instance.PageClassroomTouchStudent, roleId)

		local light = GOUtil.FindChildComponent(SceneConcert.Instance.PageClassroomTouchStudent.RTCamera.gameObject, "Directional light", "Light")

		if light ~= nil then
			light.enabled = true
		end

		SceneConcert.Instance.PageClassroomTouchStudent.Image_CharacterView.gameObject:SetActive(false)
		SceneConcert.Instance.PageClassroomTouchStudent.ScreenRacaster.gameObject:SetActive(true)
	end

	SceneConcert.Instance:ShowConversation({
		ID = 1005,
		Params = {
			Roles = self.GetCharTbl
		}
	}, function()
		local dlg = DlgInstructionVideo()

		CreateDlgInScene(dlg, {
			"0.mp4"
		})

		dlg.OnFinish = showTouchUI
	end)
end

function PlayerCreate:CreateTouchPrompt()
	if self.TouchPrompt == nil and SceneConcert.Instance ~= nil and SceneConcert.Instance.PageClassroomTouchStudent ~= nil then
		self.TouchPrompt = GOUtil.InstantiatePrefab(SceneConcert.Instance.PrefabTouchPrompt, SceneConcert.Instance.PageClassroomTouchStudent.UIRootObject)
	end
end

function PlayerCreate:OnDragHead()
	UIUtility.SetVisible(self.TouchPrompt, false)
end

function PlayerCreate:OnFingerUp()
	if not self.TouchHeadSucceed then
		UIUtility.SetVisible(self.TouchPrompt, true)
	end
end

function PlayerCreate:OnTouchHeadSucceed()
	self.TouchHeadSucceed = true

	UIUtility.SetVisible(self.TouchPrompt, false)
end

function PlayerCreate:GotoSupport()
	if self.GetCharTbl == nil or self.GetCharTbl == 0 then
		SceneMgr.LoadScene("Classroom", nil)

		return
	end

	self.PageUserNameInput:HideButBk()
	self:ShowConversation(1004, function()
		local infoSupport = LiveManager:GetSupport(DataManager.Instance:GetConfigArgInt("NewbieSupportId"))
		local concert_info = {}

		concert_info.support_id = infoSupport.data.ID
		concert_info.song_id = infoSupport.data.SongID
		concert_info.character_ids = {}
		concert_info.isExploreLive = false

		for i = 1, #self.GetCharTbl do
			table.insert(concert_info.character_ids, self.GetCharTbl[i])
		end

		SceneMgr.LoadScene("Concert", concert_info)
	end)
end

function PlayerCreate:PlaySupport()
	if FingerGestures.Instance ~= nil then
		FingerGestures.Instance.gameObject:SetActive(false)
	end

	if SceneConcert.Instance ~= nil then
		SceneConcert.Instance.PageClassroomTouchStudent:Close()
	end

	SceneConcert.Instance:ShowConversation(1006, function()
		local dlg = DlgInstructionVideo()

		CreateDlgInScene(dlg, {
			"1-1.mp4",
			"1-2.mp4",
			"1-3.mp4",
			"1-4.mp4"
		})

		local function callbackEnd(...)
			local cg = GOUtil.GetComponent(SceneConcert.Instance.PageConcert.UIRootObject, "CanvasGroup")

			cg.alpha = 1

			SceneConcert.Instance.NotesPlayManagerGO:SetActive(true)
			SceneConcert.Instance:Prepare()
		end

		dlg.OnFinish = callbackEnd
	end)
end

function PlayerCreate:OnNoteAdd(curNoteNum)
	self.NoteLimitNum = self.NoteLimitNum or DataManager.Instance:GetConfigArgInt("ExitNotesNum")

	if curNoteNum == self.NoteLimitNum then
		if SceneConcert.Instance ~= nil then
			SceneConcert.Instance.NotesPlayManager:Pause()
			SceneConcert.Instance.PerformActors:Pause()
		end

		if self.noteEnd then
			return
		end

		if not self.noteEnd then
			self.noteEnd = true
		end

		SceneConcert.Instance:ShowConversation(1007, function()
			PlayerInst.IsNewbie = false

			InstructionMgr:Start()
			SceneMgr.LoadScene("Classroom", nil)
		end)
	end
end

function PlayerCreate.GetInstance()
	PlayerCreate.Instance = PlayerCreate.Instance or PlayerCreate()

	return PlayerCreate.Instance
end
