-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Item/UITab.lua

UITab = class("UITab")

function UITab:ctor(tabRootGo, btnCount, clickCall, luaObj, defaultIdx)
	if defaultIdx == nil then
		defaultIdx = 1
	end

	self.tabRootGo = tabRootGo
	self.btnCount = btnCount
	self.clickCall = clickCall
	self.index = defaultIdx
	self.luaObj = luaObj

	self:Init()
	self:Update()
end

function UITab:Init()
	self.rootGos = {}
	self.btnGos = {}
	self.selectGos = {}

	for i = 1, self.btnCount do
		local root = GOUtil.FindChildGameObject(self.tabRootGo, "Btn" .. i)
		local btnGo = GOUtil.FindChildGameObject(root, "Btn")
		local selectGo = GOUtil.FindChildGameObject(root, "Select")

		btnGo.name = i

		EventListenerMgr.AddUIListener(btnGo, self.BtnClick, self, EventTriggerType.PointerClick)
		table.insert(self.rootGos, root)
		table.insert(self.btnGos, btnGo)
		table.insert(self.selectGos, selectGo)
	end
end

function UITab:Update()
	if self.preIdx ~= self.index then
		GOUtil.SetActive(self.btnGos[self.index], false)
		GOUtil.SetActive(self.selectGos[self.index], true)

		if self.preIdx ~= nil then
			GOUtil.SetActive(self.btnGos[self.preIdx], true)
			GOUtil.SetActive(self.selectGos[self.preIdx], false)
		end

		self.preIdx = self.index
	end
end

function UITab:BtnClick(data)
	local go = data.pointerPress

	self.index = tonumber(go.name)

	SoundMgr.Play(PATH_SFX_UI_DIALOG)

	if GetConfigArgInt("FriendHelpMaxTimes") - InfoGameInst:GetFriendHelpTimes() == 0 and self.index == 1 and GameObject.Find("PanelChooseRoleCard(Clone)") then
		UIMgr.ShowMsg("助っ人回数使用済み")

		return
	end

	self:Update()
	self.clickCall(self.luaObj, self.index)
end

function UITab:Dispose()
	for i = 1, self.btnCount do
		local btnGo = self.btnGos[i]

		EventListenerMgr.RemoveUIListener(btnGo, self.BtnClick, self, EventTriggerType.PointerClick)
	end
end
