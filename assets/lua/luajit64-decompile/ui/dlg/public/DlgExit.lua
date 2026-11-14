-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/UI/Dlg/Public/DlgExit.lua

DlgExit = class("DlgExit", UIPanel)

function DlgExit:ctor()
	self.UIPrefabPath = "UI/Public/DlgExit"
	self.cb = nil
	self.preCb = nil
	self.homeCb = nil
end

function DlgExit:OnRegisterEvent()
	self:AddClick(self.BtnReturn, self.OnClickedBtnReturn, PATH_SFX_UI_CANCEL)
	self:AddClick(self.BtnHelp, self.OnClickedBtnHelp)
	self:AddClick(self.BtnWorldMap, self.OnClickedBtnWorldMap)
	EventListenerMgr.AddAnimListener(self.BtnReturn, self.OnBack, self, eAnimEventType.OnAnimationEnd)
end

function DlgExit:OnUnRegisterEvent()
	self:RemoveClick(self.BtnReturn, self.OnClickedBtnReturn)
	self:RemoveClick(self.BtnHelp, self.OnClickedBtnHelp)
	self:RemoveClick(self.BtnWorldMap, self.OnClickedBtnWorldMap)
	EventListenerMgr.RemoveAnimListener(self.BtnReturn, self.OnBack, self, eAnimEventType.OnAnimationEnd)
end

function DlgExit:OnEnter(vParam)
	vParam = vParam or {}
	self.panel = vParam.panel
	self.cb = vParam.callback
	self.preCb = vParam.preCallback
	self.homeCb = vParam.homeCallback
	self.helpCb = vParam.helpCallback

	local g = self.UIRootObject

	self.UIRootObject.transform:SetAsLastSibling()

	self.TxtExit = GOUtil.FindChildComponent(g, "Back/A/T", "Text")
	self.TxtExit.text = vParam.title or ""
	self.TPrompt = self:GetChildComponent("TPrompt", "Text")
	self.TPrompt.text = ""
	self.BtnReturn = GOUtil.FindChildGameObject(g, "Back")
	self.BtnWorldMap = GOUtil.FindChildGameObject(g, "Back/A/BtnMap")
	self.BtnHelp = GOUtil.FindChildGameObject(g, "Back/A/BtnHelp")

	self.BtnHelp:SetActive(self.helpCb ~= nil)

	self.GoAntiTouch = GOUtil.FindChildGameObject(g, "AntiTouch")

	self.GoAntiTouch:SetActive(false)

	self.ReturnAnimator = GOUtil.GetComponent(self.BtnReturn, "Animator")

	self:SetSafeArea(self.BtnReturn)

	if vParam.hideMapBtn ~= nil then
		self.BtnWorldMap:SetActive(vParam.hideMapBtn)
	elseif ThemeManager.TypeID == 1 then
		self.BtnWorldMap:SetActive(true)
	else
		self.BtnWorldMap:SetActive(false)
	end
end

function DlgExit:SetTextExit(strTitle)
	if self.TxtExit then
		self.TxtExit.text = strTitle
	end
end

function DlgExit:SetPrompt(strPrompt)
	if self.TPrompt then
		self.TPrompt.text = strPrompt
	end
end

function DlgExit:OnBack()
	if OperationActiveMgr.UpdateOperationFlag and UIMgr.GetPrePanel() and ThemeManager.TypeID == 1 then
		require("UI/Page/PageClassroom/PageMainStage")
		UIMgr.ClearPreviewActor()

		local function DlgWorldMapEvent()
			if self.cb and self.returnIndex == 1 then
				self.cb(self.panel)
			else
				UIMgr.ClearMain()
				UIMgr.SwitchPanel(PageMainStage, nil, true)
			end

			FavorMgr.ShowFavorUnlock = false
		end

		if SceneMgr.GetCurrentScene().className ~= "SceneMainStage" then
			SceneMgr.LoadScene("MainStage", {
				from = 14,
				func = DlgWorldMapEvent
			})
		else
			DlgWorldMapEvent()
		end

		self.cb = nil
		self.panel = nil
		OperationActiveMgr.UpdateOperationFlag = false

		return
	end

	if self.cb then
		if self.returnIndex == 1 then
			self.cb(self.panel)
		elseif self.homeCb then
			self.homeCb(self.panel)

			self.homeCb = nil
		else
			UIMgr.Clear()

			local function wrap_cb()
				if SceneMgr.GetCurrentScene() == SceneMainStage.Instance then
					UIMgr.SwitchPanel(PageMainStage(), nil, true)
				else
					SceneMgr.LoadScene("MainStage", nil)
				end
			end

			TimerMgr.AddTimer(eTimerType.FrameCount, 1, wrap_cb, nil)
		end
	else
		self:Close()
	end

	self.cb = nil
	self.panel = nil
end

function DlgExit:CommonFun()
	if self.preCb then
		local function wrap_cb(index)
			if index == 1 then
				self.ReturnAnimator:Play("Back")
				self.GoAntiTouch:SetActive(true)
			end
		end

		self.preCb(self.panel, wrap_cb)
	else
		self.ReturnAnimator:Play("Back")
		self.GoAntiTouch:SetActive(true)
	end
end

function DlgExit:OnClickedBtnReturn()
	self.returnIndex = 1

	self:CommonFun()
end

function DlgExit:OnClickedBtnHelp()
	self.returnIndex = 3

	if self.helpCb then
		self.helpCb(self.panel)
	end
end

function DlgExit:OnClickedBtnWorldMap()
	if self:GetChildGameObject("DlgWorldMap(Clone)") == nil then
		local g = GameObject.Find("PageInteraction(Clone)")

		if g and GameObject.Find("ImagePrompt") and GameObject.Find("ImagePrompt").activeSelf then
			return
		end

		require("UI/Dlg/Public/DlgWorldMap")
		UIMgr.AddPanel(DlgWorldMap(), nil, self.UIRootObject, self.worldIsKeep)
	elseif self:GetChildGameObject("DlgWorldMap(Clone)") then
		require("UI/Dlg/Public/DlgWorldMap")
		Event.Instance:Fire("DlgWorldMapEventClose")
		print("++++++++++++++++++++++++")
	end
end

function DlgExit.GetSweepItemState()
	local g = {}

	g = GameObject.Find("PanelRoleCard(Clone)")

	if g then
		return true
	end

	g = GameObject.Find("PanelAssetStage(Clone)")

	if g and GOUtil.FindChildGameObject(g, "TagGroup/2/Select").activeSelf then
		return true
	end

	g = GameObject.Find("PanelAssetStage(Clone)")

	if g and GOUtil.FindChildGameObject(g, "TagGroup/2/Select").activeSelf then
		return true
	end

	return false
end

function DlgExit:HideHelpBtn()
	self.BtnHelp:SetActive(false)
end

function DlgExit:ShowHelpBtn()
	self.BtnHelp:SetActive(true)
end
