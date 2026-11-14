-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Manager/BackKeyMgr.lua

BackKeyMgr = {}
BackKeyMgr.SceneName = {
	Scenario = "Scenario",
	MainStage = "MainStage",
	PlayerBirthday = "PlayerBirthday",
	Battle = "Battle",
	AR = "AR",
	Communication = "Communication",
	Call = "Call",
	Login = "Login"
}
BackKeyMgr.SceneClassTable = {
	Battle = {
		"SceneFightNormal",
		"SceneFightBoss"
	},
	MainStage = {
		"SceneMainStage"
	},
	Scenario = {
		"SceneScenario"
	},
	Communication = {
		"SceneCommunication"
	},
	Call = {
		"SceneCall"
	},
	Login = {
		"SceneLogin"
	},
	PlayerBirthday = {
		"ScenePlayerBirthday"
	},
	AR = {
		"SceneAR"
	}
}

function BackKeyMgr:IsInScene(sceneName)
	local currScene = SceneMgr.GetCurrentScene()

	if currScene ~= nil then
		local sceneTb = self.SceneClassTable[sceneName]

		if sceneTb ~= nil then
			return table.contains(sceneTb, currScene.className)
		end
	end

	return false
end

function BackKeyMgr:IsInGameScene()
	return self:IsInScene(self.SceneName.Battle) or self:IsInScene(self.SceneName.Scenario) or self:IsInScene(self.SceneName.Communication) or self:IsInScene(self.SceneName.Call)
end

function BackKeyMgr:ProcessScene()
	local currScene = SceneMgr.GetCurrentScene()

	if self:IsInScene(self.SceneName.MainStage) then
		return false
	elseif self:IsInScene(self.SceneName.Login) then
		local loginPanel = UIMgr.GetCurPanel()

		if loginPanel then
			return loginPanel:OnBackAndroid()
		end

		return false
	elseif self:IsInScene(self.SceneName.Battle) then
		self:ProcessBattle(currScene)

		return true
	elseif self:IsInScene(self.SceneName.Scenario) then
		self:ProcessScenario()

		return true
	elseif self:IsInScene(self.SceneName.Communication) then
		UIMgr.ClickDlgExit()

		return true
	elseif self:IsInScene(self.SceneName.Call) then
		self:ProcessCall(currScene)

		return true
	elseif self:IsInScene(self.SceneName.AR) then
		self:ProcessAr(currScene)

		return true
	elseif self:IsInScene(self.SceneName.PlayerBirthday) then
		return true
	else
		return false
	end
end

function BackKeyMgr:ProcessAr(currScene)
	if currScene then
		currScene:OnBackAndroid()
	end
end

function BackKeyMgr:ProcessScenario()
	if ScenarioKit.Instance then
		if ScenarioKit.Instance.UI.History ~= nil and GOUtil.IsActiveSelf(ScenarioKit.Instance.UI.History.gameObject) then
			GOUtil.SetActive(ScenarioKit.Instance.UI.History.gameObject, false)

			return
		end

		if ScenarioKit.Instance.UI.video ~= nil and GOUtil.IsActiveSelf(ScenarioKit.Instance.UI.video.gameObject) then
			ScenarioKit.Instance.UI.video:Stop()

			return
		end

		local endingObj = GOUtil.FindChildGameObject(ScenarioKit.Instance.UI.gameObject, "MainCanvas/Ending")

		if GOUtil.IsActiveSelf(endingObj) and ScenarioKit.Instance.Events ~= nil and ScenarioKit.Instance.Events.OnExit ~= nil then
			ScenarioKit.Instance.Events.OnExit:Dispatch(nil)

			return
		end

		if GOUtil.IsActiveSelf(ScenarioKit.Instance.UI.DialogPanel.gameObject) and ScenarioKit.Instance.Events ~= nil and ScenarioKit.Instance.Events.OnClickSkip ~= nil then
			ScenarioKit.Instance.Events.OnClickSkipAll:Dispatch(nil)
		end
	end
end

function BackKeyMgr:ProcessCall(currScene)
	if currScene.PagePhone then
		if UIMgr.PopChildByName("DlgHistory") then
			return
		end

		currScene.PagePhone:OnClickedSkip()
	end
end

function BackKeyMgr:ProcessBattle(currScene)
	if UIMgr.PopChild() then
		return
	end

	if currScene.PageFight ~= nil then
		currScene.PageFight:OnBackAndroid()
	end
end
