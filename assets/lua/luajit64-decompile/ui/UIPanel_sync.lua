-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/UIPanel_sync.lua

UIPanel_sync = class("UIPanel_sync")

function UIPanel_sync:ctor(uiPrefabPath)
	self.listChildPanel = {}
	self.UIPrefabPath = uiPrefabPath
	self.UIRootObject = nil
	self.UIPrefabCache = nil
	self.instId = 0
	self.closed = false
	self.dictSFXPath = {}
end

function UIPanel_sync:AddChildPanel(panel, vParam)
	local data = {}

	data.panel = panel
	data.vParam = vParam

	table.insert(self.listChildPanel, data)
end

function UIPanel_sync:GetChildPanel(strPanelName)
	for _, v in pairs(self.listChildPanel) do
		if v and v.panel.className == strPanelName then
			return v.panel
		end
	end

	return nil
end

function UIPanel_sync:AddChildPanelImmediately(panel, vParam)
	panel:Create(self.UIRootObject, vParam, false)
end

function UIPanel_sync:Show(isShow)
	self.UIRootObject:SetActive(isShow)
end

function UIPanel_sync:Cache()
	UIMgr.CachePrefab(self.UIPrefabPath)

	for i = 1, #self.listChildPanel do
		self.listChildPanel[i].panel:Cache()
	end
end

function UIPanel_sync:PreLoad()
	return
end

function UIPanel_sync:Purge()
	self.dictSFXPath = {}

	if self.listChildPanel then
		for i = 1, #self.listChildPanel do
			self.listChildPanel[i].panel:Purge()
		end

		self.listChildPanel = {}
	end

	self:OnUnRegisterEvent()

	self.instId = 0

	Object.Destroy(self.UIRootObject)

	self.UIRootObject = nil

	UnloadAllImageSprite(self)
end

function UIPanel_sync:Close()
	self:Purge()

	self.closed = true
end

function UIPanel_sync:Create(uiRoot, vParam)
	self.uiRoot = uiRoot
	self.vParam = vParam

	self:PreLoad(vParam)

	local cachedPrefab = UIMgr.GetCachedPrefab(self.UIPrefabPath)

	if cachedPrefab == nil then
		self.UIPrefabCache = ResourceMgr.LoadSync(self.UIPrefabPath, GameObject)
	else
		self.UIPrefabCache = cachedPrefab
	end

	self:OnAsyncPrecacheAllFinish()
end

function UIPanel_sync:OnAsyncPrecacheAllFinish()
	LoadingMgr.Hide(eLoadingType.Repeat)

	local parentGo = self.uiRoot

	self.UIRootObject = GOUtil.InstantiateUIPrefab(self.UIPrefabCache, parentGo)

	for i = 1, #self.listChildPanel do
		local panel = self.listChildPanel[i].panel
		local vParam = self.listChildPanel[i].vParam

		panel:Create(self.UIRootObject, vParam, false)
	end

	self:OnEnter(self.vParam)
	self:OnRegisterEvent()

	self.uiRoot = nil
	self.vParam = nil
	self.isLoaded = false

	TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
		InstructionMgr:TriggerInPage()
	end, nil)
end

function UIPanel_sync:OnLoaded()
	if not self.isLoaded then
		self.isLoaded = true

		TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
			Event.Instance:Fire("OnPageLoaded", self.className)
		end, nil)
	end
end

function UIPanel_sync:OnEnter(vParam)
	return
end

function UIPanel_sync:OnRegisterEvent()
	return
end

function UIPanel_sync:OnUnRegisterEvent()
	return
end

function UIPanel_sync:AddListener(go, callback, triggerType)
	EventListenerMgr.AddUIListener(go, callback, self, triggerType)
end

function UIPanel_sync:RemoveListener(go, callback, triggerType)
	EventListenerMgr.RemoveUIListener(go, callback, self, triggerType)
end

function UIPanel_sync:AddClick(go, callback, sfxPath)
	if go == nil then
		return
	end

	EventListenerMgr.AddUIListener(go, callback, self, EventTriggerType.PointerClick)

	local path

	if sfxPath ~= nil then
		if sfxPath ~= "mute" then
			path = sfxPath
		end
	else
		path = "Play_SE_020_0030"
	end

	if path then
		self.dictSFXPath[go:GetInstanceID()] = path

		EventListenerMgr.AddUIListener(go, self.OnClickSoundEvent, self, EventTriggerType.PointerClick)
	end
end

function UIPanel_sync:RemoveClick(go, callback)
	if go == nil then
		return
	end

	EventListenerMgr.RemoveUIListener(go, callback, self, EventTriggerType.PointerClick)
	EventListenerMgr.RemoveUIListener(go, self.OnClickSoundEvent, self, EventTriggerType.PointerClick)
end

function UIPanel_sync:OnClickSoundEvent(data)
	local go = data.pointerPress
	local path = self.dictSFXPath[go:GetInstanceID()]

	SoundMgr.Play(path)
end

function UIPanel_sync:GetChildGameObject(internal_path)
	return GOUtil.FindChildGameObject(self.UIRootObject, internal_path)
end

function UIPanel_sync:GetChildComponent(internal_path, com_name)
	return GOUtil.FindChildComponent(self.UIRootObject, internal_path, com_name)
end

function UIPanel_sync:IsShow()
	return self.UIRootObject ~= nil and GOUtil.IsActiveSelf(self.UIRootObject)
end
