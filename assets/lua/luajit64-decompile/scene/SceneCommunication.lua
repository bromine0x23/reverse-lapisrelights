-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Scene/SceneCommunication.lua

require("Scene/SceneBase")
require("Scenario/ScenarioKitLua")
require("UI/Page/PageCommunication/PageCommunication")

SceneCommunication = class("SceneCommunication", SceneBase, true)

function SceneCommunication:OnCache()
	return
end

function SceneCommunication:OnCreate()
	self.PageCommunication = PageCommunication()

	UIMgr.SwitchPanel(self.PageCommunication, self.data, true)
end

function SceneCommunication.CreateInstance()
	if not SceneCommunication.Instance then
		SceneCommunication.Instance = SceneCommunication()
	end

	return SceneCommunication.Instance
end

function SceneCommunication.DestroyInstance()
	SceneCommunication.Instance = nil
end

local goCamera, goPath

function SceneCommunication:LoadStory(topicId)
	self.topicId = topicId

	local infoTopic = TopicManager:GetTopic(topicId)

	SceneCommunication.Instance.strSave = infoTopic.pb.record

	local StoryPrefabPath = infoTopic.data.Path

	if self.GoPrefab then
		Object.DestroyImmediate(self.GoPrefab)

		self.GoPrefab = nil
	end

	local StoryPrefab = ResourceMgr.LoadSync(StoryPrefabPath)

	self.GoPrefab = GOUtil.InstantiatePrefab(StoryPrefab, nil)
	self.PageCommunication.state = eCommuState.LoadStory

	self.PageCommunication:UpdatePanel()

	goPath = self.GoPrefab
end

function SceneCommunication:DestoryStory()
	if goCamera then
		goCamera:SetActive(true)
	end

	TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
		if goPath then
			Object.DestroyImmediate(goPath)

			goPath = nil
			self.GoPrefab = nil
		end
	end, nil)
end

function SceneCommunication:LoadAssetsComplate()
	local camera = GameObject.Find("Camera")

	if camera then
		camera:SetActive(false)
	end

	goCamera = camera

	local panel = UIMgr.GetCurPanel()

	panel.state = eCommuState.StartChat

	panel:UpdatePanel()
	panel:HideBg()

	if SceneCommunication.Instance then
		ScenarioKit.Instance.Blueprint:Play(nil)
	else
		ScenarioKit.Instance.Blueprint:Play(nil)
	end

	if SceneCommunication.Instance and SceneCommunication.Instance.strSave then
		panel:LoadChat(SceneCommunication.Instance.topicId)
	end
end

function SceneCommunication:ToEnd(param)
	if ScenarioKit.Instance ~= nil then
		ScenarioKit.Instance.Events.ToEnd:Dispatch(nil)
	end
end

function SceneCommunication:OnExit(isManualEnd)
	if not isManualEnd then
		self:DestoryStory()
	end

	local panel = UIMgr.GetCurPanel()

	panel:OnEnd(isManualEnd)
	panel:ShowBg()
end

function SceneCommunication:GetCurDialog(str, actorId, flag)
	local chatData = {}

	chatData.actorId = actorId
	chatData.content = str
	chatData.flag = flag

	local panel = UIMgr.GetCurPanel()

	if actorId < 0 then
		chatData.isReaded = false

		panel:UpdateChat(chatData)
		panel:UpdateAnswer(chatData)
	else
		panel:UpdateChat(chatData)
	end
end

function SceneCommunication:GetAnswer(listAnswer)
	local list = {}

	for i = 0, listAnswer.Count - 1 do
		local obj = listAnswer:get_Item(i)

		table.insert(list, obj)
	end

	local panel = UIMgr.GetCurPanel()

	panel:UpdateAnswerList(list)
end

function SceneCommunication:ShowLoading()
	LoadingMgr.Show(eLoadingType.Repeat)
end

function SceneCommunication:HideLoading()
	LoadingMgr.Hide(eLoadingType.Repeat)
end

function SceneCommunication:EndScenario()
	return
end

function SceneCommunication:ShowEnding(param)
	return
end

function SceneCommunication:OnInitEditor()
	local go = GameObject.Find("PageCommunication")
	local panel = self.PageCommunication

	panel = PageCommunication()
	panel.UIRootObject = go

	UIMgr.SetCurPanel(panel)
	panel:PreLoad()
	panel:OnEnter({
		topicId = 1,
		roleId = 101
	})
	panel:OnRegisterEvent()
end

function SceneCommunication:OnInit(vParam)
	self.roleId = vParam.roleId
	self.data = vParam
end

function SceneCommunication:OnRegisterEvent()
	return
end

function SceneCommunication:OnUpdate()
	return
end

function SceneCommunication:OnUnRegisterEvent()
	return
end

function SceneCommunication:OnDestroy()
	goCamera = nil
	goPath = nil
end

function SceneCommunication:OnPurge()
	return
end

function SceneCommunication:OnEnd()
	return
end

return SceneCommunication
