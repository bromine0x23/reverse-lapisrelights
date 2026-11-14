-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Scene/SceneCall.lua

require("Scene/SceneBase")
require("Scenario/ScenarioKitLua")
require("UI/Page/PageCommunication/PagePhone")

local curPagePhone

SceneCall = class("SceneCall", SceneBase, true)

function SceneCall:OnCache()
	if self.from == 2 then
		self.infoCall = PhoneCallManager:Get(self.callId)
		self.StoryPrefabPath = self.infoCall.data.Path

		ResourceMgr.SubmitCache(self.StoryPrefabPath, self, "SceneStoryPrefab")
	end

	UIMgr.CachePrefab("UI/PageCommunication/PagePhone")
	UIMgr.CachePrefab("UI/PageCommunication/PagePhoneMsgList")
end

function SceneCall:OnCreate()
	self.PagePhone = PagePhone()
	curPagePhone = self.PagePhone

	if self.from == 2 then
		GOUtil.InstantiatePrefab(self.SceneStoryPrefab, nil)

		local data = {}

		data.infoCall = self.infoCall
		data.roleId = self.roleId
		data.stageId = self.stageId

		UIMgr.SwitchPanel(self.PagePhone, data, true)
		UIMgr.SetCurPanel(self.PagePhone)
	else
		UIMgr.SwitchPanel(PagePhoneMsgList, self.roleId)
	end
end

function SceneCall.CreateInstance()
	if not SceneCall.Instance then
		SceneCall.Instance = SceneCall()
	end

	return SceneCall.Instance
end

function SceneCall.DestroyInstance()
	SceneCall.Instance = nil
end

function SceneCall:LoadStory(callId)
	if self.GoPrefab then
		Object.DestroyImmediate(self.GoPrefab)

		self.GoPrefab = nil
	end

	self.infoCall = PhoneCallManager:Get(callId)

	local StoryPrefab = ResourceMgr.LoadSync(self.infoCall.data.Path)

	self.GoPrefab = GOUtil.InstantiatePrefab(StoryPrefab, nil)

	local data = {}

	data.infoCall = self.infoCall
	data.roleId = self.roleId

	UIMgr.SwitchPanel(self.PagePhone, data)
end

function SceneCall:LoadAssetsComplate()
	local camera = GameObject.Find("Camera")

	if camera then
		-- block empty
	end

	local panel = curPagePhone

	ScenarioKit.Instance.Blueprint:Play()
	panel:StartLoaded()
end

function SceneCall:OnComplete()
	print("翻訳不要")

	local panel = UIMgr.GetCurPanel()

	panel:OnComplete()
end

function SceneCall:OnExit(isManualEnd)
	local panel = UIMgr.GetCurPanel()

	panel:OnEnd(isManualEnd)
end

function SceneCall:ToEnd(param)
	ScenarioKit.Instance.UI.controlls:ToEnd()
end

function SceneCall:StopVoice()
	ScenarioKit.Instance.Sounds:StopVoice()
end

function SceneCall:GetCurDialog(str, actorId, flag, nameKey)
	local chatData = {}

	chatData.actorId = actorId
	chatData.content = str
	chatData.flag = flag
	chatData.nameKey = nameKey

	local panel = UIMgr.GetCurPanel()

	panel:UpdateChat(chatData)
end

function SceneCall:GetAnswer(listAnswer)
	local list = {}

	for i = 0, listAnswer.Count - 1 do
		local obj = listAnswer:get_Item(i)

		table.insert(list, obj)
	end

	local panel = UIMgr.GetCurPanel()

	panel:UpdateAnswerList(list)
end

function SceneCall:ShowLoading()
	LoadingMgr.Show(eLoadingType.Repeat)
end

function SceneCall:HideLoading()
	LoadingMgr.Hide(eLoadingType.Repeat)
end

function SceneCall:EndScenario()
	local panel = UIMgr.GetCurPanel()

	panel:OnEnd(false)
end

function SceneCall:OnInitEditor()
	self.from = 2
	self.callId = 1
	self.roleId = 101

	local go = GameObject.Find("PagePhone")

	self.PagePhone = PagePhone()
	self.PagePhone.UIRootObject = go

	UIMgr.SetCurPanel(self.PagePhone)

	local data = {}

	data.infoCall = nil
	data.roleId = 101
	data.stageId = 0

	self.PagePhone:OnEnter(data)
	self.PagePhone:OnRegisterEvent()

	curPagePhone = self.PagePhone
end

function SceneCall:OnInit(vParam)
	self.from = vParam.from
	self.callId = vParam.callId
	self.roleId = vParam.roleId
	self.stageId = vParam.stageId
end

function SceneCall:OnRegisterEvent()
	return
end

function SceneCall:OnUpdate()
	return
end

function SceneCall:OnUnRegisterEvent()
	return
end

function SceneCall:OnDestroy()
	return
end

function SceneCall:OnPurge()
	self.PagePhone = nil
	curPagePhone = nil
end

function SceneCall:OnEnd()
	return
end

return SceneCall
