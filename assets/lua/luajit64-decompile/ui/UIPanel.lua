-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/UIPanel.lua

UIPanel = class("UIPanel")
UIPanel.instanceID = 0

function UIPanel:ctor(uiPrefabPath)
	self.listChildPanel = {}
	self.UIPrefabPath = uiPrefabPath
	self.UIRootObject = nil
	self.UIPrefabCache = nil
	self.instId = 0
	self.closed = false
	self.dictSFXPath = {}
	self.asyncLoadCount = 0
	self.hasPreload = false
end

function UIPanel:AddChildPanel(panel, vParam)
	local data = {}

	data.panel = panel
	data.vParam = vParam

	table.insert(self.listChildPanel, data)
end

function UIPanel:GetChildPanel(strPanelName)
	for _, v in pairs(self.listChildPanel) do
		if v and v.panel.className == strPanelName then
			return v.panel
		end
	end

	return nil
end

function UIPanel:AddChildPanelImmediately(panel, vParam)
	panel:Create(self.UIRootObject, vParam, false)
end

function UIPanel:Show(isShow)
	self.UIRootObject:SetActive(isShow)
end

function UIPanel:Cache()
	UIMgr.CachePrefab(self.UIPrefabPath)

	for i = 1, #self.listChildPanel do
		self.listChildPanel[i].panel:Cache()
	end
end

function UIPanel:PreLoad()
	self.asyncLoadCount = 0
	self.hasPreload = false
end

function UIPanel:LoadResAsync(path, field, type)
	if self.asynProcess == nil then
		self.asynProcess = {}
	end

	if self.asynProcess[path] ~= nil then
		return
	end

	self.asynProcess[path] = ResourceMgr.BeginSubmit(function()
		self.asynProcess[path] = nil
		self.asyncLoadCount = self.asyncLoadCount - 1

		self:CheckPreLoad()
	end)

	ResourceMgr.SubmitCache(path, self, field, type)
	ResourceMgr.EndSubmit()

	self.asyncLoadCount = self.asyncLoadCount + 1
	self.hasPreload = true
end

function UIPanel:Purge()
	self.asyncLoadCount = 0
	self.hasPreload = false
	self.parentPanel = nil
	self.dictSFXPath = {}

	if self.listChildPanel then
		for i = 1, #self.listChildPanel do
			self.listChildPanel[i].panel:Purge()

			self.listChildPanel[i].panel = nil
		end

		self.listChildPanel = {}
	end

	self:OnUnRegisterEvent()

	self.instId = 0

	Object.Destroy(self.UIRootObject)

	self.UIRootObject = nil

	if UIMgr.GetCachedPrefab(self.UIPrefabPath) == nil then
		ResourceMgr.Unload(self.UIPrefabCache)

		self.UIPrefabCache = nil
	end

	UnloadAllImageSprite(self)
	self:UnloadAssets()
	UIMgr.ListChildPurge(self)
	UIMgr:RemoveSafeArea(self)
end

function UIPanel:Close()
	self:Purge()

	self.closed = true
end

function UIPanel:Create(uiRoot, vParam)
	LoadingMgr.Show(eLoadingType.Repeat)

	self.uiRoot = uiRoot
	self.vParam = vParam
	self.closed = false
	self.asyncLoadCount = 0
	self.hasPreload = false
	self.loadComplete = false
	self.isloadMain = false

	self:PreLoad(vParam)

	if self.hasPreload == false and self.isloadMain ~= true then
		self:StartLoadMain()
	end
end

function UIPanel:StartLoadMain()
	self.isloadMain = true

	local cachedPrefab = UIMgr.GetCachedPrefab(self.UIPrefabPath)

	if cachedPrefab == nil then
		if self.isKeep or self.isSyncLoad then
			self.UIPrefabCache = ResourceMgr.LoadSync(self.UIPrefabPath, GameObject)

			self:OnAsyncPrecacheAllFinish()
		else
			ResourceMgr.BeginSubmit(function()
				self:OnAsyncPrecacheAllFinish()
			end)
			ResourceMgr.SubmitCache(self.UIPrefabPath, self, "UIPrefabCache", GameObject)
			ResourceMgr.EndSubmit()
		end
	else
		self.UIPrefabCache = cachedPrefab

		self:OnAsyncPrecacheAllFinish()
	end
end

function UIPanel:OnAsyncPrecacheAllFinish()
	local parentGo = self.uiRoot

	if self.isKeep then
		self.UIPrefabCache.DontDisposeOnUnloadAll = true
	end

	self.UIRootObject = GOUtil.InstantiateUIPrefab(self.UIPrefabCache, parentGo)

	self.UIRootObject:SetActive(false)

	for i = 1, #self.listChildPanel do
		local panel = self.listChildPanel[i].panel
		local vParam = self.listChildPanel[i].vParam

		panel.parentPanel = self

		panel:Create(self.UIRootObject, vParam, false)
	end

	if #self.listChildPanel < 1 then
		self.loadComplete = true

		self:DealWithEnter()
	end
end

function UIPanel:CheckLoadComplete()
	local loadComplete = false

	for i = 1, #self.listChildPanel do
		local panel = self.listChildPanel[i].panel

		if panel.loadComplete ~= true then
			return false
		end
	end

	return true
end

function UIPanel:DealWithEnter()
	self.UIRootObject:SetActive(true)
	self:OnEnter(self.vParam)
	self:OnRegisterEvent()

	self.uiRoot = nil
	self.vParam = nil
	self.isOnEnter = true
	self.isLoaded = false

	Event.Instance:Fire("NotifyPanelLoaded", self.className)
	TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
		InstructionMgr:OnPageLoaded(self.className)
		InstructionMgr:TriggerInPage()
		UIMgr.OnPanelEnter(self.className)
	end, nil)
	self:DealWithParentEnter()

	if self.needPrePurge then
		self.needPrePurge = false

		UIMgr.ClearRoot(self.className)
	end

	LoadingMgr.Hide(eLoadingType.Repeat)
end

function UIPanel:DealWithParentEnter()
	if self.parentPanel and self.parentPanel:CheckLoadComplete() and not self.parentPanel.isOnEnter then
		self.parentPanel.loadComplete = true

		self.parentPanel:DealWithEnter()
	end
end

function UIPanel:CheckPreLoad()
	if self.asyncLoadCount == 0 then
		self.hasPreload = false

		if self.isloadMain ~= true then
			self:StartLoadMain()
		end
	end
end

function UIPanel:OnLoaded()
	if not self.isLoaded then
		self.isLoaded = true

		TimerMgr.AddTimer(eTimerType.FrameCount, 1, function()
			Event.Instance:Fire("OnPageLoaded", self.className)
		end, nil)
	end
end

function UIPanel:OnEnter(vParam)
	return
end

function UIPanel:OnRegisterEvent()
	return
end

function UIPanel:OnUnRegisterEvent()
	return
end

function UIPanel:AddListener(go, callback, triggerType)
	EventListenerMgr.AddUIListener(go, callback, self, triggerType)
end

function UIPanel:RemoveListener(go, callback, triggerType)
	EventListenerMgr.RemoveUIListener(go, callback, self, triggerType)
end

function UIPanel:AddClick(go, callback, sfxPath)
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
		path = PATH_SFX_UI_CLICK
	end

	if path then
		self.dictSFXPath[go:GetInstanceID()] = path

		EventListenerMgr.AddUIListener(go, self.OnClickSoundEvent, self, EventTriggerType.PointerClick)
	end
end

function UIPanel:RemoveClick(go, callback)
	if go == nil then
		return
	end

	EventListenerMgr.RemoveUIListener(go, callback, self, EventTriggerType.PointerClick)
	EventListenerMgr.RemoveUIListener(go, self.OnClickSoundEvent, self, EventTriggerType.PointerClick)
end

function UIPanel:OnClickSoundEvent(data)
	if data == nil then
		return
	end

	local go = data.pointerPress

	if go == nil then
		return
	end

	local path = self.dictSFXPath[go:GetInstanceID()] or PATH_SFX_UI_CANCEL

	SoundMgr.Play(path)
end

function UIPanel:GetChildGameObject(internal_path)
	return GOUtil.FindChildGameObject(self.UIRootObject, internal_path)
end

function UIPanel:GetChildComponent(internal_path, com_name)
	return GOUtil.FindChildComponent(self.UIRootObject, internal_path, com_name)
end

function UIPanel:LoadAssetsAsync(path, type)
	if self.assetsTable == nil then
		self.assetsTable = {}
	end

	if self.asynProcess == nil then
		self.asynProcess = {}
	end

	if self.asynProcess[path] ~= nil then
		return
	end

	self.asynProcess[path] = ResourceMgr.BeginSubmit(function()
		self.asyncLoadCount = self.asyncLoadCount - 1

		if self.asynProcess and self.asynProcess[path] then
			self.asynProcess[path] = nil
		end

		self:CheckPreLoad()
	end)

	if type == nil then
		type = Sprite
	end

	ResourceMgr.SubmitCache(path, self.assetsTable, path, type)
	ResourceMgr.EndSubmit()

	self.asyncLoadCount = self.asyncLoadCount + 1
	self.hasPreload = true
end

function UIPanel:UnloadAssets()
	if self.assetsTable ~= nil then
		for key, value in pairs(self.assetsTable) do
			ResourceMgr.Unload(value)
		end

		self.assetsTable = nil
	end

	if self.asynProcess ~= nil then
		for key, value in pairs(self.asynProcess) do
			if value ~= nil then
				ResourceMgr.Cancel(value)
			end
		end

		self.asynProcess = nil
	end
end

function UIPanel:UnloadAssetsByPath(path)
	if self.assetsTable ~= nil and self.assetsTable[path] then
		ResourceMgr.Unload(self.assetsTable[path])

		self.assetsTable[path] = nil
	end
end

function UIPanel:SetImageSprite(img, path)
	if self.assetsTable[path] then
		UIUtilSetImageSprite(img, self.assetsTable[path])
	end
end

function UIPanel:SetRawImageTexture(rawImage, path)
	if self.assetsTable[path] then
		UIUtilSetRawImageTexture(rawImage, self.assetsTable[path])
	end
end

function UIPanel:SetVideoPlayerClip(player, clippath)
	if self.assetsTable[clippath] then
		UIUtilSetVideoPlayerClip(player, self.assetsTable[clippath])
	end
end

function UIPanel:SetImageSpriteAsync(img, path, panel, isNative, setAlpha)
	if path == "" then
		return
	end

	if setAlpha then
		img.color = Color.clear
	end

	ResourceMgr.BeginSubmit(function()
		if self[path] then
			UIUtil.SetImageSprite(img, self[path], panel, isNative)

			if setAlpha then
				img.color = Color.white
			end

			DealWithListRef(panel, self[path])
		end
	end)
	ResourceMgr.SubmitCache(path, self, path, Sprite)
	ResourceMgr.EndSubmit()
end

function UIPanel:SetSafeArea(safeAreaObj)
	UIMgr:SetSafeArea(self, safeAreaObj)
end

function UIPanel:IsShow()
	return self.UIRootObject ~= nil and GOUtil.IsActiveSelf(self.UIRootObject)
end
